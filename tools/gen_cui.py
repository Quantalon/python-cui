#!/usr/bin/env python3
"""Generate PYCUI's Cython layer from CUI's C headers.

Inputs  : CUI/include/cui/{cui,cui_render,cui_app,cui_icons}.h
Outputs : src/cui/cui_decl.pxd      every struct/enum/function Cython needs
          src/cui/_gen/constants.py Python names for enums, integers and icons
          src/cui/_gen/model.py     value classes for CUI's plain data structs
          src/cui/_gen/sizes.h      sizeof() shims for the opaque handle structs
          src/cui/_api.pyx          one wrapper per callable CUI function
          src/cui/_gen/COVERAGE.md  what is wrapped and what is not, and why

`python tools/gen_cui.py --check` regenerates in memory and exits non-zero when
a checked-in file is stale; CI runs exactly that.

The parse is hermetic: clang is given `-nostdinc` and the minimal standard
headers in tools/clang-include/, so the output never depends on the host's C
library. libclang's own wheel ships no headers, and on Linux it used to find
none at all, which silently changed `bool`, `size_t` and `va_list` into
error-recovery types and produced a different API. Parse errors are fatal
instead of being printed and ignored.

Mapping (see vibe/plan.md):
  * option structs (`const X *_opts`)   -> keyword-only arguments
  * out-parameters (`bool *`, `int *`)  -> extra return values
  * `char *buf, size_t cap`             -> `text=` in, `TextResult` out
  * `const char *const *items, int n`   -> a sequence of str
  * `const float *values, int n`        -> a sequence of numbers
  * `const T *items, int n` (plain T)   -> a sequence of `cui.<T>` values
  * `T *` (opaque T)                    -> a zero-initialized Python-owned handle
  * function pointers, variadics and caller-allocated struct arrays are left
    out and reported in COVERAGE.md; those components arrive in phase 3.
"""

from __future__ import annotations

import argparse
import codecs
import dataclasses
import re
import sys
from pathlib import Path

try:
    import clang.cindex as ci
except ImportError:  # pragma: no cover
    sys.exit("libclang is required: pip install libclang")

ROOT = Path(__file__).resolve().parent.parent
CUI_INCLUDE = ROOT / "CUI" / "include"
HEADER_PATHS = [
    CUI_INCLUDE / "cui" / "cui.h",
    CUI_INCLUDE / "cui" / "cui_render.h",
    CUI_INCLUDE / "cui" / "cui_app.h",
]
ICONS_HEADER = CUI_INCLUDE / "cui" / "cui_icons.h"
CLANG_INCLUDE = ROOT / "tools" / "clang-include"

# Fixed parse environment: no host headers and a fixed target, so every
# platform parses CUI's headers exactly the same way.
PARSE_ARGS = [
    "-x", "c",
    "-std=c99",
    "--target=x86_64-unknown-linux-gnu",
    "-nostdinc",
    "-isystem", str(CLANG_INCLUDE),
    "-I", str(CUI_INCLUDE),
    "-fparse-all-comments",
]

# Filled in from the parsed headers; cy() maps enum types to int.
ENUM_NAMES: set[str] = set()

GEN_DIR = ROOT / "src" / "cui" / "_gen"
OUT_DECL = ROOT / "src" / "cui" / "cui_decl.pxd"
OUT_CONSTANTS = GEN_DIR / "constants.py"
OUT_MODEL = GEN_DIR / "model.py"
OUT_SIZES = GEN_DIR / "sizes.h"
OUT_API = ROOT / "src" / "cui" / "_api.pyx"
OUT_API_PYI = ROOT / "src" / "cui" / "_api.pyi"
OUT_INIT_PYI = ROOT / "src" / "cui" / "__init__.pyi"
OUT_COVERAGE = GEN_DIR / "COVERAGE.md"

# Wrapped by hand in _cui.pyx: lifecycle, frames, ids, app and renderer plumbing.
CORE_FUNCTIONS = {
    "cui_create", "cui_destroy", "cui_set_renderer", "cui_set_viewport",
    "cui_begin_frame", "cui_end_frame", "cui_get_draw_data",
    "cui_needs_redraw", "cui_next_wakeup", "cui_request_redraw",
    "cui_request_wakeup", "cui_time", "cui_delta_time", "cui_frame_count",
    "cui_make_id", "cui_push_id", "cui_push_id_int", "cui_pop_id",
    "cui_last_id", "cui_last_rect", "cui_get_rect", "cui_last_hovered",
    "cui_is_disabled", "cui_push_disabled", "cui_pop_disabled",
    "cui_measure_text", "cui_write_png",
    "cui_sw_create", "cui_sw_destroy", "cui_sw_iface", "cui_sw_render",
    "cui_sw_set_threads", "cui_sw_set_incremental", "cui_sw_last_damage",
    # Wrapped by hand because their arguments are arrays of structs that contain
    # pointers, a paint callback, or in/out arrays.
    "cui_canvas", "cui_line_chart_ex", "cui_bar_chart_ex", "cui_dot_chart_ex",
    "cui_event_track_ex", "cui_draw_polyline", "cui_draw_polygon",
    "cui_donut_chart_ex", "cui_split_begin", "cui_split_next", "cui_split_end",
}
CORE_PREFIXES = ("cui_app_",)

INT_CTYPES = {
    "int": "int", "unsigned int": "unsigned int", "long": "long",
    "unsigned long": "unsigned long", "short": "short", "unsigned short": "unsigned short",
    "size_t": "size_t", "int8_t": "int8_t", "uint8_t": "uint8_t",
    "int16_t": "int16_t", "uint16_t": "uint16_t", "int32_t": "int32_t",
    "uint32_t": "uint32_t", "int64_t": "int64_t", "uint64_t": "uint64_t",
    "cui_id": "uint32_t", "cui_font": "int", "cui_texture": "uintptr_t",
}
FLOAT_CTYPES = {"float": "float", "double": "double"}
BOOL_CTYPES = {"_Bool", "bool"}

# C structs that map onto a Python value type from cui._types.
VALUE_STRUCTS = {
    "cui_color": "Color",
    "cui_size": "Size",
    "cui_date": "Date",
    "cui_vec2": "Vec2",
    "cui_rect": "Rect",
    "cui_corners": "Corners",
    "cui_key_combo": "KeyCombo",
}
NOT_A_HANDLE = {
    "cui_ctx", "cui_app", "cui_sw_renderer", "cui_gl_renderer", "cui_theme",
    "cui_draw_data", "cui_renderer_iface", "cui_allocator", "cui_platform_iface",
    "cui_strings", "cui_ctx_desc", "cui_app_desc",
}

# Structs the hand-written core touches field by field, so their layout has to
# be declared even when they are not plain data.
FORCE_LAYOUT = {"cui_ctx_desc", "cui_renderer_iface", "cui_allocator", "cui_draw_data",
                "cui_app_desc", "cui_file_dialog_opts", "cui_series", "cui_dot_series"}

PY_KEYWORDS = {
    "False", "None", "True", "and", "as", "assert", "async", "await", "break",
    "class", "continue", "def", "del", "elif", "else", "except", "finally",
    "for", "from", "global", "if", "import", "in", "is", "lambda", "nonlocal",
    "not", "or", "pass", "raise", "return", "try", "while", "with", "yield",
    "ctx", "self", "opts", "_",
}


# ---------------------------------------------------------------------------
# Model
# ---------------------------------------------------------------------------


@dataclasses.dataclass
class Field:
    name: str
    ctype: str
    comment: str


@dataclasses.dataclass
class Struct:
    name: str
    fields: list[Field]
    comment: str
    header: str


@dataclasses.dataclass
class EnumValue:
    name: str
    value: int


@dataclasses.dataclass
class Enum:
    name: str
    values: list[EnumValue]
    comment: str
    header: str


@dataclasses.dataclass
class Param:
    name: str
    ctype: str
    comment: str


@dataclasses.dataclass
class Func:
    name: str
    ret: str
    params: list[Param]
    comment: str
    variadic: bool
    header: str


@dataclasses.dataclass
class Model:
    structs: dict[str, Struct]
    enums: list[Enum]
    funcs: list[Func]
    enum_names: set[str]
    fnptr_typedefs: set[str]

    def is_enum(self, ctype: str) -> bool:
        return ctype.strip() in self.enum_names


def clean_comment(raw: str | None) -> str:
    if not raw:
        return ""
    text = raw.strip()
    text = re.sub(r"^/\*+!?", "", text)
    text = re.sub(r"\*+/$", "", text)
    lines = []
    for line in text.splitlines():
        line = re.sub(r"^\s*\*?\s?", "", line).strip()
        if line:
            lines.append(line)
    return " ".join(lines)


def parse() -> Model:
    """Parse every public header (they do not all include each other) and merge."""
    index = ci.Index.create()
    known = {str(p.resolve()) for p in HEADER_PATHS}
    structs: dict[str, Struct] = {}
    enums_by_name: dict[str, Enum] = {}
    enums: list[Enum] = []
    funcs_by_name: dict[str, Func] = {}
    fnptr_typedefs: set[str] = set()

    errors: list[str] = []
    for header_path in HEADER_PATHS:
        tu = index.parse(str(header_path), args=PARSE_ARGS)
        for diag in tu.diagnostics:
            if diag.severity < ci.Diagnostic.Error:
                continue
            location = diag.location
            where = f"{Path(location.file.name)}:{location.line}: " if location.file else ""
            print(f"libclang: {where}{diag.spelling}", file=sys.stderr)
            errors.append(f"{where}{diag.spelling}")
        for cursor in tu.cursor.walk_preorder():
            loc = cursor.location.file
            if loc is None:
                continue
            try:
                path = str(Path(loc.name).resolve())
            except OSError:
                continue
            if path not in known:
                continue
            header = Path(path).name
            if cursor.kind == ci.CursorKind.TYPEDEF_DECL:
                underlying = cursor.underlying_typedef_type
                if underlying.kind in (ci.TypeKind.FUNCTIONPROTO, ci.TypeKind.FUNCTIONNOPROTO):
                    fnptr_typedefs.add(cursor.spelling)
                elif underlying.kind == ci.TypeKind.POINTER:
                    if underlying.get_pointee().kind in (
                        ci.TypeKind.FUNCTIONPROTO,
                        ci.TypeKind.FUNCTIONNOPROTO,
                    ):
                        fnptr_typedefs.add(cursor.spelling)
                elif underlying.kind in (ci.TypeKind.RECORD, ci.TypeKind.ELABORATED):
                    declaration = underlying.get_declaration()
                    if declaration.kind in (ci.CursorKind.STRUCT_DECL, ci.CursorKind.UNION_DECL):
                        # `typedef struct cui_sw_renderer cui_sw_renderer;` has no
                        # definition of its own; keep it as an opaque handle.
                        structs.setdefault(cursor.spelling, Struct(cursor.spelling, [], "", header))
            elif cursor.kind == ci.CursorKind.STRUCT_DECL and cursor.spelling:
                fields = [
                    Field(child.spelling, child.type.spelling, clean_comment(child.raw_comment))
                    for child in cursor.get_children()
                    if child.kind == ci.CursorKind.FIELD_DECL
                ]
                existing = structs.get(cursor.spelling)
                if existing is None or (not existing.fields and fields):
                    structs[cursor.spelling] = Struct(
                        cursor.spelling, fields, clean_comment(cursor.raw_comment), header
                    )
            elif cursor.kind == ci.CursorKind.ENUM_DECL:
                values = [
                    EnumValue(child.spelling, child.enum_value)
                    for child in cursor.get_children()
                    if child.kind == ci.CursorKind.ENUM_CONSTANT_DECL
                ]
                if not values:
                    continue
                enum = Enum(cursor.spelling, values, clean_comment(cursor.raw_comment), header)
                if enum.name and enum.name in enums_by_name:
                    continue
                enums.append(enum)
                if enum.name:
                    enums_by_name[enum.name] = enum
            elif (
                cursor.kind == ci.CursorKind.FUNCTION_DECL
                and cursor.spelling.startswith("cui_")
                and cursor.spelling not in funcs_by_name
            ):
                funcs_by_name[cursor.spelling] = Func(
                    cursor.spelling,
                    cursor.result_type.spelling,
                    [Param(a.spelling, a.type.spelling, clean_comment(a.raw_comment)) for a in cursor.get_arguments()],
                    clean_comment(cursor.raw_comment),
                    cursor.type.is_function_variadic(),
                    header,
                )

    enum_names = {e.name for e in enums if e.name and re.fullmatch(r"cui_\w+", e.name)}
    ENUM_NAMES.clear()
    ENUM_NAMES.update(enum_names)
    if errors:
        raise SystemExit(
            f"libclang reported {len(errors)} error(s) while parsing CUI's headers; "
            "a partial parse would generate a different API.\n"
            f"The minimal standard headers it needs live in {CLANG_INCLUDE.relative_to(ROOT)}."
        )
    return Model(structs, enums, list(funcs_by_name.values()), enum_names, fnptr_typedefs)


# ---------------------------------------------------------------------------
# Naming and C type helpers
# ---------------------------------------------------------------------------


def camel(name: str) -> str:
    return "".join(part.capitalize() for part in re.sub(r"^cui_", "", name).split("_"))


def wrapper_name(name: str) -> str:
    name = re.sub(r"^cui_", "", name)
    return name[:-3] if name.endswith("_ex") else name


def safe(name: str) -> str:
    return name + "_" if name in PY_KEYWORDS else name


def pointee(ctype: str) -> str:
    return re.sub(r"\s*\*\s*$", "", ctype.strip()).removeprefix("const ").strip()


def pointer_struct(ctype: str) -> str | None:
    m = re.match(r"^(const\s+)?(cui_\w+)\s*\*\s*$", ctype.strip())
    return m.group(2) if m else None


def cy(ctype: str) -> str:
    """The Cython spelling of a C type, for declarations inside extern blocks."""
    ctype = " ".join(ctype.strip().split())
    if ctype in ("const char *const *", "const char **"):
        return "const char *const *"
    match = re.match(r"^(?P<base>.+?)(?P<stars>\*+)$", ctype)
    if match:
        base = match.group("base").strip()
        stars = " " + "*" * len(match.group("stars"))
        if base.removeprefix("const ").strip() in BOOL_CTYPES:
            return "c_bool" + stars
        return _cy_base(base) + stars
    return _cy_base(ctype)


def _cy_base(ctype: str) -> str:
    if ctype in BOOL_CTYPES:
        return "uint8_t"
    if ctype in INT_CTYPES:
        return INT_CTYPES[ctype]
    if ctype in FLOAT_CTYPES:
        return FLOAT_CTYPES[ctype]
    if ctype in ENUM_NAMES:
        return "int"  # enum layout is int; avoids ordering constraints in the pxd
    return ctype


def layout_struct_names(model: Model) -> dict[str, Struct]:
    """Structs whose layout Cython needs: every type the binding passes by value.

    Option structs (fields assigned), value structs (fields read), plain data
    structs (fields written) and the few binding-owned descriptor structs.
    """
    keep: dict[str, Struct] = {}
    for struct in model.structs.values():
        if (
            struct.name.endswith("_opts")
            or struct.name in VALUE_STRUCTS
            or struct.name in FORCE_LAYOUT
            or is_plain(struct, model)
        ):
            keep[struct.name] = struct
    return keep


def is_plain(struct: Struct, model: Model) -> bool:
    """True when every field can be built from a Python value."""
    if not struct.fields:
        return False
    for field in struct.fields:
        ctype = field.ctype.strip()
        if re.search(r"\[\s*\d+\s*\]$", ctype):
            return False
        if ctype in BOOL_CTYPES or ctype in INT_CTYPES or ctype in FLOAT_CTYPES:
            continue
        if ctype in ("const char *", "char *") or ctype in VALUE_STRUCTS:
            continue
        if model.is_enum(ctype):
            continue
        return False
    return True


# ---------------------------------------------------------------------------
# Parameter classification
# ---------------------------------------------------------------------------


class Unsupported(Exception):
    pass


@dataclasses.dataclass
class Spec:
    kind: str  # ctx bool int float double cstr bytes str_seq num_seq opts
    #            out_scalar out_value text_buffer handle struct_seq
    name: str
    ctype: str
    detail: str = ""
    struct: str | None = None
    consumes: int = 1


def scalar_kind(ctype: str, model: Model) -> str | None:
    ctype = ctype.strip()
    if ctype in BOOL_CTYPES:
        return "bool"
    if ctype in INT_CTYPES or model.is_enum(ctype):
        return "int"
    if ctype in FLOAT_CTYPES:
        return FLOAT_CTYPES[ctype]
    return None


def classify(func: Func, model: Model) -> tuple[list[Spec], str]:
    """Return (specs, return-kind); raise Unsupported with a human reason."""
    specs: list[Spec] = []
    params = list(func.params)
    index = 0

    if params and params[0].ctype == "cui_ctx *":
        specs.append(Spec("ctx", "ctx", "cui_ctx *"))
        index = 1

    while index < len(params):
        param = params[index]
        ctype = param.ctype.strip()
        name = safe(param.name or f"arg{index}")
        following = params[index + 1] if index + 1 < len(params) else None

        # char buffer pairs --------------------------------------------------
        if ctype == "char *" and following is not None and following.ctype.strip() == "size_t":
            specs.append(Spec("text_buffer", name, "char *", consumes=2))
            index += 2
            continue

        # C function pointers and variadics ----------------------------------
        if "(*)" in ctype or ctype.startswith("void (*") or ctype == "va_list":
            raise Unsupported("needs a C callback")
        if ctype in ("cui_paint_fn",):
            raise Unsupported("needs a C callback")

        # counted slices -----------------------------------------------------
        has_count = (
            following is not None
            and following.ctype.strip() in ("int", "size_t")
            and (
                following.name in ("count", "n", "len", "cap", "size")
                or following.name.endswith("_count")
                or following.name.endswith("_size")
            )
        )
        if ctype == "const char **":
            specs.append(Spec("out_cstr", name, ctype))
            index += 1
            continue
        if ctype == "const char *const *" and has_count:
            specs.append(Spec("str_seq", name, ctype, consumes=2))
            index += 2
            continue
        if ctype in ("const float *", "const double *", "const int *") and has_count:
            specs.append(Spec("num_seq", name, ctype, consumes=2))
            index += 2
            continue
        if ctype in ("const void *", "const uint8_t *") and has_count:
            specs.append(Spec("bytes", name, ctype, consumes=2))
            index += 2
            continue

        kind = scalar_kind(ctype, model)
        if kind:
            specs.append(Spec(kind, name, ctype))
            index += 1
            continue

        if ctype in VALUE_STRUCTS:
            specs.append(Spec("value", name, ctype, detail=VALUE_STRUCTS[ctype], struct=ctype))
            index += 1
            continue

        if ctype in ("const char *", "char *"):
            specs.append(Spec("cstr", name, ctype))
            index += 1
            continue

        if ctype in ("const void *", "void *"):
            specs.append(Spec("bytes", name, ctype))
            index += 1
            continue

        if ctype == "const char *const *":
            specs.append(Spec("str_seq", name, ctype))
            index += 1
            continue

        # out-parameters -----------------------------------------------------
        m = re.match(r"^(?:const\s+)?(\w+)\s*\*\s*$", ctype)
        base = m.group(1) if m else None
        if base and re.match(r"^[\w\s]+$", ctype.replace("*", "").strip()):
            if base in BOOL_CTYPES:
                specs.append(Spec("out_scalar", name, ctype, detail="bool"))
                index += 1
                continue
            if base in INT_CTYPES:
                specs.append(Spec("out_scalar", name, ctype, detail=INT_CTYPES[base]))
                index += 1
                continue
            if base in FLOAT_CTYPES:
                specs.append(Spec("out_scalar", name, ctype, detail=FLOAT_CTYPES[base]))
                index += 1
                continue
            if base in VALUE_STRUCTS:
                specs.append(Spec("out_value", name, ctype, detail=VALUE_STRUCTS[base], struct=base))
                index += 1
                continue

        # pointers to CUI structs -------------------------------------------
        pointed = pointer_struct(ctype)
        if pointed:
            if pointed in NOT_A_HANDLE:
                raise Unsupported(f"takes `{ctype}`, a binding-owned type")
            if pointed.endswith("_opts") or pointed == "cui_box":
                specs.append(Spec("opts", name, ctype, struct=pointed))
                index += 1
                continue
            if pointed not in model.structs:
                raise Unsupported(f"takes `{ctype}`, an unknown type")
            if is_plain(model.structs[pointed], model) and ctype.startswith("const "):
                specs.append(Spec("struct_seq", name, ctype, struct=pointed, consumes=2 if has_count else 1))
                index += 2 if has_count else 1
                continue
            if ctype.startswith("const "):
                raise Unsupported(f"takes `{ctype}`, a data array of a struct with pointers")
            if has_count:
                raise Unsupported("needs caller-allocated struct storage")
            specs.append(Spec("handle", name, ctype, struct=pointed))
            index += 1
            continue

        raise Unsupported(f"parameter `{param.name}` has type `{ctype}`")

    # return kind ----------------------------------------------------------
    ret = func.ret.strip()
    has_text = any(s.kind == "text_buffer" for s in specs)
    if has_text and not (specs and specs[0].kind == "ctx"):
        raise Unsupported("text buffer without a context to own it")
    if ret == "void":
        retkind = "void"
    elif ret in BOOL_CTYPES:
        retkind = "bool"
    elif ret in INT_CTYPES or model.is_enum(ret):
        retkind = "int"
    elif ret in FLOAT_CTYPES:
        retkind = "float"
    elif ret == "const char *":
        retkind = "cstr"
    elif ret in VALUE_STRUCTS:
        retkind = "value:" + VALUE_STRUCTS[ret]
    else:
        raise Unsupported(f"returns `{ret}`")
    if has_text and retkind not in ("int", "bool", "void"):
        raise Unsupported(f"returns `{ret}` together with a text buffer")
    if has_text:
        retkind = "text_result_void" if retkind == "void" else "text_result"
    return specs, retkind


# ---------------------------------------------------------------------------
# decls
# ---------------------------------------------------------------------------

DECL_HEADER = '''\
# C declarations of CUI's C API, shared by cui._cui and cui._api.
#
# GENERATED FILE: produced by tools/gen_cui.py from CUI/include/cui/*.h.
# Do not edit by hand; run `python tools/gen_cui.py` instead.

from libc.stddef cimport size_t
from libc.stdint cimport int64_t, uint8_t, uint32_t, uint64_t, uintptr_t
# `c_bool` is C's `bool`: plain `uint8_t` is fine for bool fields and by-value
# parameters (the C compiler converts implicitly), but a pointer has to name the
# real type, or GCC 14 rejects it with `-Wincompatible-pointer-types`.
from ._stdbool cimport bool as c_bool

cdef extern from "cui/cui.h" nogil:
    ctypedef uintptr_t cui_texture
    ctypedef uint32_t cui_id
    ctypedef struct cui_ctx

    # ---- enums ----
'''


def emit_decls(model: Model) -> str:
    blocks: dict[str, list[str]] = {p.name: [] for p in HEADER_PATHS}
    layouts = layout_struct_names(model)
    handled: set[str] = set()

    def block_for(header: str) -> list[str]:
        if header not in blocks:
            blocks[header] = []
        return blocks[header]

    seen_enums: set[str] = set()
    for enum in sorted(model.enums, key=lambda e: e.name or ""):
        if not re.fullmatch(r"cui_\w+", enum.name or "") or enum.name in seen_enums:
            continue
        seen_enums.add(enum.name)
        target = block_for(enum.header)
        target.append(f"    ctypedef enum {enum.name}:")
        for value in enum.values:
            target.append(f"        {value.name} = {value.value}")
        target.append("")
    def layout_order(name: str) -> tuple[int, str]:
        # Value structs first: option structs embed them by value.
        return (0 if name in VALUE_STRUCTS else 1, name)

    ordered: list[str] = []
    visiting: set[str] = set()
    done: set[str] = set()

    def visit(name: str) -> None:
        if name in done or name in visiting:
            return
        visiting.add(name)
        for field in layouts[name].fields:
            base = field.ctype.strip()
            if base in layouts:
                visit(base)
        visiting.discard(name)
        done.add(name)
        ordered.append(name)

    for name in sorted(layouts, key=layout_order):
        visit(name)

    for name in ordered:
        struct = layouts[name]
        handled.add(name)
        block = block_for(struct.header)
        if struct.name == "cui_ctx":
            continue
        block.append(f"    ctypedef struct {name}:")
        declared = 0
        for field in struct.fields:
            if field.name in PY_KEYWORDS:
                continue  # `from`, `in`: Cython cannot name them; shims set them
            fname = safe(field.name)
            ctype = field.ctype.strip()
            if "(*)" in ctype or ctype in model.fnptr_typedefs:
                continue  # callbacks: the binding never reads or writes them
            arr = re.match(r"^(.*?)\[\s*(\d+)\s*\]$", ctype)
            if arr:
                block.append(f"        {cy(arr.group(1).strip())} {fname}[{arr.group(2)}]")
            else:
                block.append(f"        {cy(ctype)} {fname}")
            declared += 1
        if not declared:
            block.append("        int _")
        block.append("")

    for name in sorted(model.structs):
        if name in handled:
            continue
        block_for(model.structs[name].header).append(f"    ctypedef struct {name}")
    for header in blocks:
        blocks[header].append("")

    # The hand-written core needs a few functions whose signatures contain a C
    # function pointer (cui_app_run).  Declare those through a ctypedef so
    # Cython can express them; every other callback function stays undeclared.
    needed = {f.name for f in model.funcs if f.name in CORE_FUNCTIONS or f.name.startswith(CORE_PREFIXES)}
    # Callback typedefs the hand-written core passes through.  libclang only
    # gives us the typedef name, so spell the signatures the binding needs.
    fnptr_layouts = {
        "cui_paint_fn": "ctypedef void (*cui_paint_fn)(cui_ctx *, cui_rect, void *)",
    }
    fnptr_typedefs_by_spelling: dict[tuple[str, str], str] = {}
    for func in model.funcs:
        if func.name not in needed:
            continue
        for param in func.params:
            spelling = param.ctype.strip()
            if "(*)" in spelling:
                key = (func.header, spelling)
                if key not in fnptr_typedefs_by_spelling:
                    if func.name == "cui_canvas":
                        name = "pycui_paint_fn"  # named for the hand-written wrapper
                    else:
                        name = f"pycui_fnptr_{len(fnptr_typedefs_by_spelling) + 1}"
                    fnptr_typedefs_by_spelling[key] = name
                    base = re.sub(r"\(\*\)", f"(*{name})", spelling)
                    block_for(func.header).append(f"    ctypedef {base}")
            elif spelling in fnptr_layouts:
                key = (func.header, spelling)
                if key not in fnptr_typedefs_by_spelling:
                    fnptr_typedefs_by_spelling[key] = spelling
                    block_for(func.header).append(f"    {fnptr_layouts[spelling]}")
    for header in blocks:
        if any(h == header for h, _spelling in fnptr_typedefs_by_spelling):
            blocks[header].append("")

    for func in model.funcs:
        if func.variadic or any(p.ctype.strip() == "va_list" for p in func.params):
            continue
        block = blocks.get(func.header)
        if block is None:
            continue
        parts = []
        skip = False
        for param in func.params:
            spelling = param.ctype.strip()
            if "(*)" in spelling:
                name = fnptr_typedefs_by_spelling.get((func.header, spelling))
                if name is None:
                    skip = True
                    break
                parts.append(f"{name} {safe(param.name) or 'arg'}")
            elif spelling in model.fnptr_typedefs and func.name not in needed:
                skip = True
                break
            else:
                parts.append(f"{cy(param.ctype)} {safe(param.name) or 'arg'}")
        if skip:
            continue
        block.append(f"    {cy(func.ret)} {func.name}({', '.join(parts)})")

    out = [DECL_HEADER]
    for header in ("cui.h", "cui_render.h", "cui_app.h"):
        body = "\n".join(blocks.get(header, [])).strip("\n")
        if not body:
            continue
        out.append("")
        out.append(f'cdef extern from "cui/{header}" nogil:')
        out.append(body)
    out.append("")
    return "\n".join(out)


# ---------------------------------------------------------------------------
# constants.py
# ---------------------------------------------------------------------------


def emit_constants(model: Model) -> str:
    lines = [
        '"""Enum, integer and icon constants from CUI\'s headers.',
        "",
        "GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.",
        '"""',
        "",
        "from __future__ import annotations",
        "",
        "from enum import IntEnum, IntFlag",
        "",
    ]
    for enum in model.enums:
        members = strip_enum_prefix(enum)
        if enum.name and re.fullmatch(r"cui_\w+", enum.name):
            cls = camel(enum.name)
            base = "IntFlag" if _looks_like_flags(members) else "IntEnum"
            lines.append("")
            lines.append(f"class {cls}({base}):")
            if enum.comment and not enum.comment.startswith("---"):
                lines.append(f'    """{enum.comment}"""')
            lines.append("")
            for name, value in members:
                lines.append(f"    {name} = {value}")
        else:
            lines.append("")
            for name, value in members:
                lines.append(f"{name} = {value}")
    icons = parse_icons()
    lines.append("")
    lines.append("# Lucide icon strings: one glyph each, usable on their own or in a label.")
    lines.append("#     ui.button(ICON_PLUS + ' New project')")
    for name, text in icons.items():
        lines.append(f'{re.sub(r"^CUI_ICON_", "ICON_", name)} = {text!r}')
    lines.append("")
    lines.append("")
    lines.append("class Icon:")
    lines.append('    """Every icon, as a namespace: ``Icon.PLUS`` is the same string as ICON_PLUS."""')
    lines.append("")
    for name, text in icons.items():
        lines.append(f"    {re.sub(r'^CUI_ICON_', '', name)} = {text!r}")
    lines.append("")
    return "\n".join(lines)


def strip_enum_prefix(enum: Enum) -> list[tuple[str, int]]:
    """CUI_TOKEN_ACCENT -> ACCENT: drop the members' common name prefix."""
    members = [(re.sub(r"^CUI_", "", value.name), value.value) for value in enum.values]
    if not members:
        return members
    parts = [name.split("_") for name, _v in members]
    prefix: list[str] = []
    for index in range(min(len(p) for p in parts) - 1):
        token = parts[0][index]
        if all(p[index] == token for p in parts):
            prefix.append(token)
        else:
            break
    if not prefix:
        return members
    cut = len("_".join(prefix)) + 1
    stripped = [(name[cut:], value) for name, value in members]
    if not all(re.fullmatch(r"[A-Za-z_]\w*", name) for name, _v in stripped):
        return members  # e.g. CUI_KEY_0 would lose its leading context
    return stripped


def _looks_like_flags(members: list[tuple[str, int]]) -> bool:
    values = [v for _n, v in members]
    if len(values) < 3:
        return False
    powers = all(v == 0 or (v & (v - 1)) == 0 for v in values)
    return powers and max(values) > 2


def parse_icons() -> dict[str, str]:
    text = ICONS_HEADER.read_text(encoding="utf-8")
    icons: dict[str, str] = {}
    for match in re.finditer(r'^#define\s+(CUI_ICON_\w+)\s+"((?:[^"\\]|\\.)*)"', text, re.M):
        name, raw = match.group(1), match.group(2)
        # CUI writes each glyph as UTF-8 bytes in \\x escapes; rebuild them.
        decoded = codecs.decode(raw, "unicode_escape")
        icons[name] = decoded.encode("latin-1").decode("utf-8")
    return icons


# ---------------------------------------------------------------------------
# model.py
# ---------------------------------------------------------------------------


def array_structs(plan: dict[str, tuple[list[Spec], str]], model: Model) -> list[str]:
    names = set()
    for specs, _ret in plan.values():
        for spec in specs:
            if spec.kind == "struct_seq" and spec.struct:
                names.add(spec.struct)
    return sorted(names)


def emit_model(model: Model, arrays: list[str]) -> str:
    lines = [
        '"""Value classes for the plain data structs that CUI takes as arrays.',
        "",
        "GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.",
        '"""',
        "",
        "from __future__ import annotations",
        "",
        "from typing import NamedTuple",
        "",
        "",
    ]
    for name in arrays:
        struct = model.structs[name]
        cls = camel(name)
        lines.append(f"class {cls}(NamedTuple):")
        if struct.comment:
            lines.append(f'    """{struct.comment}"""')
        lines.append("")
        if not struct.fields:
            lines.append("    _: int = 0")
        for field in struct.fields:
            pytype = _py_field_type(field, model)
            if pytype is not None:
                lines.append(f"    {safe(field.name)}: {pytype} = None")
        lines.append("")
        lines.append("")
    return "\n".join(lines)


def _py_field_type(field: Field, model: Model) -> str | None:
    ctype = field.ctype.strip()
    if ctype in BOOL_CTYPES:
        return "bool"
    if ctype in INT_CTYPES:
        return "int"
    if ctype in FLOAT_CTYPES:
        return "float"
    if ctype in ("const char *", "char *"):
        return "str"
    if ctype in VALUE_STRUCTS:
        return VALUE_STRUCTS[ctype]
    if model.is_enum(ctype):
        return "int"
    return None


# ---------------------------------------------------------------------------
# sizes.h
# ---------------------------------------------------------------------------


def keyword_fields(model: Model) -> list[tuple[str, Field]]:
    """Struct fields whose C name is a Python keyword (`from`, `in`).

    Cython cannot name those, so the header declares them through a setter.
    """
    out: list[tuple[str, Field]] = []
    for struct in model.structs.values():
        for field in struct.fields:
            if field.name not in PY_KEYWORDS:
                continue
            ctype = field.ctype.strip()
            if ctype in BOOL_CTYPES or ctype in INT_CTYPES or ctype in FLOAT_CTYPES:
                out.append((struct.name, field))
            elif ctype in ("const char *", "char *") or ctype in VALUE_STRUCTS:
                out.append((struct.name, field))
    return out


def emit_sizes(handles: list[str], model: Model) -> str:
    lines = [
        "/* sizeof() of CUI's handle structs and setters for fields whose C name",
        " * is a Python keyword, for the generated wrappers.",
        " *",
        " * GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.",
        " */",
        "#ifndef PYCUI_SIZES_H",
        "#define PYCUI_SIZES_H",
        "",
        "#include <cui/cui.h>",
        "",
    ]
    for name in handles:
        lines.append(f"static size_t pycui_sizeof_{name}(void) {{ return sizeof({name}); }}")
    for struct_name, field in keyword_fields(model):
        lines.append(
            f"static void pycui_set_{struct_name}_{field.name}("
            f"{struct_name} *target, {field.ctype} value) {{ target->{field.name} = value; }}"
        )
    lines.append("")
    lines.append("#endif /* PYCUI_SIZES_H */")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# _api.pyx
# ---------------------------------------------------------------------------

API_HEADER = '''\
# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: embedsignature=True
"""cui._api — one generated wrapper per callable CUI function.

Every wrapper takes the :class:`cui._cui.Context` first.  Option structs become
keyword-only arguments, out-parameters become extra return values, text buffers
come back as :class:`cui.TextResult`.

GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
"""

from libc.stddef cimport size_t
from libc.string cimport memset

from cpython.bytes cimport PyBytes_AsString, PyBytes_FromStringAndSize
from cpython.mem cimport PyMem_Free, PyMem_Malloc

from ._cui cimport (
    Context,
    _color,
    _size,
    from_color,
    from_corners,
    from_date,
    from_key_combo,
    from_rect,
    from_size,
    from_vec2,
    to_color,
    to_corners,
    to_date,
    to_key_combo,
    to_rect,
    to_size,
    to_vec2,
)
from ._types import Color, Corners, Date, KeyCombo, Rect, Size, TextResult, Vec2
from .cui_decl cimport *

cdef inline bytes _utf8(object value):
    if value is None:
        return b""
    if isinstance(value, bytes):
        return value
    return value.encode("utf-8")


cdef inline object _decode(const char *value):
    if value == NULL:
        return None
    return value.decode("utf-8", "replace")


# Some CUI helpers take no context, so they have no frame to keep strings alive
# in; those keep-alives land here instead.
_KEEP: list = []

cdef inline void _keep_alive(Context ctx, object value):
    if ctx is not None:
        ctx._keep.append(value)
    else:
        _KEEP.append(value)


cdef inline const char *const *_s_array_any(Context ctx, object values, int *count) except NULL:
    """A UTF-8 string array, kept alive by the frame or by _KEEP."""
    cdef list items, encoded
    cdef Py_ssize_t i, n
    cdef const char **arr
    cdef bytes block
    if values is None:
        count[0] = 0
        return NULL
    if ctx is not None:
        return ctx._s_array(values, count)
    items = [v if isinstance(v, str) else str(v) for v in values]
    encoded = [_utf8(v) for v in items]
    n = len(encoded)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(char *) * (n if n else 1))
    arr = <const char **>PyBytes_AsString(block)
    for i in range(n):
        arr[i] = <const char *>encoded[i]
    count[0] = <int>n
    _KEEP.append(encoded)
    _KEEP.append(block)
    return <const char *const *>arr

'''


def emit_api(model: Model, plan: dict[str, tuple[list[Spec], str]], handles: list[str],
             arrays: list[str]) -> str:
    out = [API_HEADER]
    if handles or keyword_fields(model):
        out.append('cdef extern from "_gen/sizes.h":')
        for name in handles:
            out.append(f"    size_t pycui_sizeof_{name}() noexcept nogil")
        for struct_name, field in keyword_fields(model):
            out.append(
                f"    void pycui_set_{struct_name}_{field.name}("
                f"{struct_name} *target, {cy(field.ctype)}) noexcept nogil"
            )
        out.append("")

    for name in handles:
        cls = camel(name)
        out.append(f"cdef class {cls}:")
        out.append(f'    """Opaque `{name}` storage owned by Python and zero initialized."""')
        out.append("")
        out.append("    cdef void *_mem")
        out.append("")
        out.append("    def __cinit__(self):")
        out.append(f"        self._mem = PyMem_Malloc(pycui_sizeof_{name}())")
        out.append("        if self._mem == NULL:")
        out.append('            raise MemoryError("out of memory")')
        out.append(f"        memset(self._mem, 0, pycui_sizeof_{name}())")
        out.append("")
        out.append("    def __dealloc__(self):")
        out.append("        if self._mem != NULL:")
        out.append("            PyMem_Free(self._mem)")
        out.append("            self._mem = NULL")
        out.append("")
        out.append("    def __repr__(self):")
        out.append(f'        return "<cui.{cls}>"')
        out.append("")
        out.append("")

    for name in arrays:
        out.append(pack_function(model, name))

    for func in model.funcs:
        if func.name not in plan:
            continue
        specs, retkind = plan[func.name]
        out.append(emit_function(func, specs, retkind, model))
    return "\n".join(out)


def pack_function(model: Model, struct_name: str) -> str:
    struct = model.structs[struct_name]
    lines = [
        f"cdef inline void *_pack_{struct_name}(Context ctx, object items, int *count) except NULL:",
        f'    """Copy Python values into an array of `{struct_name}`."""',
        "    cdef Py_ssize_t i, n",
        f"    cdef {struct_name} *buf",
        "    cdef object item",
        "    cdef bytes block",
        "    cdef list pycui_strings = []",
        "    if items is None:",
        "        count[0] = 0",
        "        return NULL",
        "    n = len(items)",
        f"    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof({struct_name}) * (n if n else 1))",
        f"    buf = <{struct_name} *>PyBytes_AsString(block)",
        f"    memset(buf, 0, sizeof({struct_name}) * (n if n else 1))",
        "    for i in range(n):",
        "        item = items[i]",
    ]
    for field in struct.fields:
        fname = safe(field.name)
        ctype = field.ctype.strip()
        if field.name in PY_KEYWORDS and (
            ctype in BOOL_CTYPES or ctype in INT_CTYPES or ctype in FLOAT_CTYPES
        ):
            lines.append(
                f"        pycui_set_{struct_name}_{field.name}(&buf[i], item.{fname})"
            )
        elif ctype in BOOL_CTYPES:
            lines.append(f"        buf[i].{fname} = <uint8_t>bool(item.{fname})")
        elif ctype in INT_CTYPES:
            lines.append(f"        buf[i].{fname} = <{INT_CTYPES[ctype]}>item.{fname}")
        elif ctype in FLOAT_CTYPES:
            lines.append(f"        buf[i].{fname} = <{ctype}>item.{fname}")
        elif ctype in ("const char *", "char *"):
            lines.append(f"        pycui_strings.append(_utf8(item.{fname}))")
            if field.name in PY_KEYWORDS:
                lines.append(
                    f"        pycui_set_{struct_name}_{field.name}(&buf[i], <const char *>pycui_strings[len(pycui_strings) - 1])"
                )
            else:
                lines.append(f"        buf[i].{fname} = <const char *>pycui_strings[len(pycui_strings) - 1]")
        elif ctype in VALUE_STRUCTS:
            fn = {"cui_color": "to_color", "cui_size": "to_size", "cui_date": "to_date",
                  "cui_vec2": "to_vec2", "cui_rect": "to_rect"}[ctype]
            lines.append(f"        {fn}(item.{fname}, &buf[i].{fname})")
        else:  # enum
            lines.append(f"        buf[i].{fname} = <int>item.{fname}")
    lines.append("    count[0] = <int>n")
    lines.append("    _keep_alive(ctx, block)")
    lines.append("    _keep_alive(ctx, pycui_strings)")
    lines.append("    return <void *>buf")
    lines.append("")
    lines.append("")
    return "\n".join(lines)


INT_CDEF = {"int": "int", "unsigned int": "unsigned int", "long": "long",
            "size_t": "size_t", "int64_t": "int64_t", "uint64_t": "uint64_t"}


def emit_function(func: Func, specs: list[Spec], retkind: str, model: Model) -> str:
    name = wrapper_name(func.name)
    doc = (func.comment or f"Wrap ``{func.name}``.").replace('"""', "'")
    required: list[str] = []
    optional: list[str] = []
    keyword: list[str] = []
    cdefs: list[str] = []
    setup: list[str] = []
    args: list[str] = []
    outs: list[str] = []
    text_key: str | None = None
    has_ctx = bool(specs) and specs[0].kind == "ctx"
    if has_ctx:
        cdefs.append("    cdef cui_ctx *pycui_ctx = ctx._ctx()")
        args.append("pycui_ctx")

    taken = {spec.name for spec in specs if spec.kind not in ("opts", "ctx")}

    for spec in specs:
        if spec.kind == "ctx":
            continue
        if spec.kind == "opts":
            struct = model.structs[spec.struct]
            cdefs.append(f"    cdef {struct.name} opts")
            setup.append("    memset(&opts, 0, sizeof(opts))")
            args.append("&opts")
            for field in struct.fields:
                if field.name.startswith("_"):
                    continue  # `int _` is CUI's options-struct marker
                if safe(field.name) in taken:
                    continue  # the required argument of the same name wins
                keyword.append(field_arg(field))
                setup.extend(field_assign(field, "opts.", model, struct.name, cdefs))
            continue
        if spec.kind == "text_buffer":
            used = {p.split("=")[0] for p in required + optional}
            param = spec.name if spec.name not in ("buf", "text") else "text"
            while param in used:
                param += "_"
            text_key = _text_key_expr(specs, func.name, param)
            optional.append(f"{param}=''")
            buf_local = f"pycui_buf_{spec.name}"
            cap_local = f"pycui_cap_{spec.name}"
            cdefs.append(f"    cdef char *{buf_local}")
            cdefs.append(f"    cdef size_t {cap_local}")
            setup.append(f"    {buf_local} = ctx._text_buffer({text_key}, {param}, &{cap_local})")
            args.extend([buf_local, cap_local])
            continue
        if spec.kind == "out_cstr":
            local = f"pycui_out_{spec.name}"
            cdefs.append(f"    cdef const char *{local} = NULL")
            args.append(f"&{local}")
            outs.append(f"_decode({local})")
            continue
        if spec.kind in ("out_scalar", "out_value"):
            local = f"pycui_out_{spec.name}"
            if spec.kind == "out_scalar":
                detail = spec.detail
                if detail == "bool":
                    optional.append(f"{spec.name}=False")
                    cdefs.append(f"    cdef c_bool {local} = <c_bool>bool({spec.name})")
                    outs.append(f"bool({local})")
                elif detail in ("float", "double"):
                    optional.append(f"{spec.name}=0.0")
                    cdefs.append(f"    cdef {detail} {local} = <{detail}>{spec.name}")
                    outs.append(f"float({local})")
                else:
                    optional.append(f"{spec.name}=0")
                    cdefs.append(f"    cdef {detail} {local} = <{detail}>{spec.name}")
                    outs.append(f"int({local})")
            else:
                optional.append(f"{spec.name}=None")
                cdefs.append(f"    cdef {spec.struct} {local}")
                setup.append(f"    to_{_value_fn(spec.detail)}({spec.name}, &{local})")
                outs.append(f"from_{_value_fn(spec.detail)}(&{local})")
            args.append(f"&{local}")
            continue
        if spec.kind == "bool":
            required.append(spec.name)
            args.append(f"<uint8_t>bool({spec.name})")
        elif spec.kind == "int":
            required.append(spec.name)
            args.append(f"<{cy(spec.ctype)}>{spec.name}")
        elif spec.kind == "float":
            required.append(spec.name)
            args.append(f"<float>{spec.name}")
        elif spec.kind == "double":
            required.append(spec.name)
            args.append(f"<double>{spec.name}")
        elif spec.kind == "cstr":
            required.append(spec.name)
            if has_ctx:
                args.append(f"ctx._s({spec.name})")
            else:
                keep = f"pycui_bytes_{spec.name}"
                cdefs.append(f"    cdef bytes {keep} = _utf8({spec.name})")
                args.append(f"<const char *>{keep}")
        elif spec.kind == "value":
            required.append(spec.name)
            fn = _value_fn(spec.detail)
            local = f"pycui_value_{spec.name}"
            cdefs.append(f"    cdef {spec.struct} {local}")
            setup.append(f"    to_{fn}({spec.name}, &{local})")
            args.append(local)
        elif spec.kind == "bytes":
            required.append(spec.name)
            cdefs.append(f"    cdef const void *pycui_ptr_{spec.name}")
            cdefs.append(f"    cdef size_t pycui_size_{spec.name}")
            setup.append(f"    pycui_ptr_{spec.name} = ctx._c_bytes({spec.name}, &pycui_size_{spec.name})")
            args.append(f"pycui_ptr_{spec.name}")
            if spec.consumes == 2:
                args.append(f"pycui_size_{spec.name}")
                spec.consumes = 1
        elif spec.kind == "str_seq":
            required.append(spec.name)
            ctx_arg = "ctx" if has_ctx else "None"
            cdefs.append(f"    cdef const char *const *pycui_ptr_{spec.name}")
            cdefs.append(f"    cdef int pycui_n_{spec.name}")
            setup.append(f"    pycui_ptr_{spec.name} = _s_array_any({ctx_arg}, {spec.name}, &pycui_n_{spec.name})")
            args.extend([f"pycui_ptr_{spec.name}", f"pycui_n_{spec.name}"])
        elif spec.kind == "num_seq":
            required.append(spec.name)
            elem = {"const float *": "float", "const double *": "double", "const int *": "int"}[spec.ctype.strip()]
            helper = {"float": "_c_float_array", "double": "_c_double_array", "int": "_c_int_array"}[elem]
            cdefs.append(f"    cdef const {elem} *pycui_ptr_{spec.name}")
            cdefs.append(f"    cdef int pycui_n_{spec.name}")
            setup.append(f"    pycui_ptr_{spec.name} = ctx.{helper}({spec.name}, &pycui_n_{spec.name})")
            args.extend([f"pycui_ptr_{spec.name}", f"pycui_n_{spec.name}"])
        elif spec.kind == "struct_seq":
            required.append(spec.name)
            cdefs.append(f"    cdef void *pycui_ptr_{spec.name}")
            cdefs.append(f"    cdef int pycui_n_{spec.name}")
            ctx_arg = "ctx" if has_ctx else "None"
            setup.append(f"    pycui_ptr_{spec.name} = _pack_{spec.struct}({ctx_arg}, {spec.name}, &pycui_n_{spec.name})")
            args.append(f"<const {spec.struct} *>pycui_ptr_{spec.name}")
            if spec.consumes == 2:
                args.append(f"pycui_n_{spec.name}")
                spec.consumes = 1
        elif spec.kind == "handle":
            required.append(spec.name)
            cls = camel(spec.struct)
            cdefs.append(f"    cdef {spec.struct} *pycui_ptr_{spec.name}")
            setup.append(f"    if {spec.name} is None:")
            setup.append(f'        raise TypeError("this function needs a cui.{cls} handle")')
            setup.append(f"    pycui_ptr_{spec.name} = <{spec.struct} *>(<{cls}>{spec.name})._mem")
            args.append(f"pycui_ptr_{spec.name}")
        else:  # pragma: no cover
            raise Unsupported(spec.kind)

    parts = (["Context ctx"] if has_ctx else []) + required + optional
    if keyword:
        parts.append("*")
        parts.extend(keyword)
    signature = ", ".join(parts)

    body: list[str] = [f"def {name}({signature}):", f'    """{doc}"""']
    body.extend(cdefs)
    body.extend(setup)
    call = f"{func.name}({', '.join(args)})"

    if text_key is not None:
        if retkind == "text_result_void":
            body.append(f"    {call}")
            body.append(f"    return ctx._text_result({text_key}, 0)")
        else:
            body.append("    cdef int pycui_flags")
            body.append(f"    pycui_flags = {call}")
            body.append(f"    return ctx._text_result({text_key}, pycui_flags)")
        body.append("")
        return "\n".join(body)

    if retkind == "void":
        body.append(f"    {call}")
        body.append(f"    return {', '.join(outs)}" if outs else "    return None")
    else:
        if retkind.startswith("value:"):
            value_fn = _value_fn(retkind.split(":", 1)[1])
            struct = {"Color": "cui_color", "Size": "cui_size", "Date": "cui_date",
                      "Vec2": "cui_vec2", "Rect": "cui_rect", "Corners": "cui_corners",
                      "KeyCombo": "cui_key_combo"}[retkind.split(":", 1)[1]]
            body.append(f"    cdef {struct} pycui_result = {call}")
            expr = f"from_{value_fn}(&pycui_result)"
        elif retkind == "cstr":
            body.append(f"    cdef const char *pycui_result = {call}")
            expr = "_decode(pycui_result)"
        elif retkind == "bool":
            body.append(f"    cdef bint pycui_result = {call}")
            expr = "bool(pycui_result)"
        elif retkind == "int":
            body.append(f"    cdef long long pycui_result = {call}")
            expr = "int(pycui_result)"
        else:
            body.append(f"    cdef double pycui_result = {call}")
            expr = "float(pycui_result)"
        if outs:
            body.append(f"    return ({expr}, {', '.join(outs)})")
        else:
            body.append(f"    return {expr}")
    body.append("")
    return "\n".join(body)


def _text_key_expr(specs: list[Spec], func_name: str, param: str) -> str:
    """The dictionary key a text buffer persists under: widget id + field."""
    for spec in specs:
        if spec.kind == "cstr" and spec.name in ("id", "scroll_id"):
            return f"('{func_name}', {spec.name}, '{param}')"
    return f"('{func_name}', '{param}')"


def _value_fn(kind: str) -> str:
    return {"Color": "color", "Size": "size", "Date": "date", "Vec2": "vec2", "Rect": "rect",
            "Corners": "corners", "KeyCombo": "key_combo"}[kind]


def field_arg(field: Field) -> str:
    name = safe(field.name)
    ctype = field.ctype.strip()
    if ctype in BOOL_CTYPES:
        return f"{name}=False"
    return f"{name}=None"


def field_assign(field: Field, prefix: str, model: Model, struct_name: str = "",
                 cdefs: list[str] | None = None) -> list[str]:
    name = safe(field.name)
    ctype = field.ctype.strip()
    out = []
    if field.name in PY_KEYWORDS:
        setter = f"pycui_set_{struct_name}_{field.name}"
        if ctype in BOOL_CTYPES:
            return [f"    {setter}(&opts, <{cy(ctype)}>bool({name}))"]
        if ctype in INT_CTYPES or model.is_enum(ctype):
            return [f"    if {name} is not None:", f"        {setter}(&opts, <{cy(ctype)}>({name}))"]
        if ctype in FLOAT_CTYPES:
            return [f"    if {name} is not None:", f"        {setter}(&opts, <{cy(ctype)}>({name}))"]
        if ctype in VALUE_STRUCTS:
            fn = {"cui_color": "to_color", "cui_size": "to_size", "cui_date": "to_date",
                  "cui_vec2": "to_vec2", "cui_rect": "to_rect"}[ctype]
            if cdefs is not None:
                cdefs.append(f"    cdef {ctype} pycui_kw_{name}")
            return [f"    if {name} is not None:",
                    f"        {fn}({name}, &pycui_kw_{name})",
                    f"        {setter}(&opts, pycui_kw_{name})"]
        return []
    if ctype in BOOL_CTYPES:
        out.append(f"    {prefix}{name} = <uint8_t>bool({name})")
    elif ctype in INT_CTYPES or model.is_enum(ctype):
        out.append(f"    if {name} is not None:")
        out.append(f"        {prefix}{name} = <{cy(ctype)}>({name})")
    elif ctype in FLOAT_CTYPES:
        out.append(f"    if {name} is not None:")
        out.append(f"        {prefix}{name} = <{cy(ctype)}>({name})")
    elif ctype in ("const char *", "char *"):
        out.append(f"    if {name} is not None:")
        out.append(f"        {prefix}{name} = ctx._s({name})")
    elif ctype == "const char *const *":
        out.append(f"    if {name} is not None:")
        out.append(f"        {prefix}{name} = ctx._s_array_z({name})")
    elif ctype in VALUE_STRUCTS:
        fn = {"cui_color": "to_color", "cui_size": "to_size", "cui_date": "to_date",
              "cui_vec2": "to_vec2", "cui_rect": "to_rect"}[ctype]
        out.append(f"    if {name} is not None:")
        out.append(f"        {fn}({name}, &{prefix}{name})")
    return out


# ---------------------------------------------------------------------------
# type stubs
# ---------------------------------------------------------------------------

API_PYI_HEADER = '''"""Type stubs for the generated wrapper layer.

GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
"""

from typing import Any, Sequence

from ._cui import Context
from ._types import Color, Date, Rect, Size, Vec2

'''


def _pyi_type(spec: Spec, model: Model) -> str:
    kind = spec.kind
    if kind == "bool":
        return "bool"
    if kind == "int":
        return "int"
    if kind in ("float", "double"):
        return "float"
    if kind == "cstr":
        return "str | None"
    if kind == "bytes":
        return "bytes | None"
    if kind == "str_seq":
        return "Sequence[str]"
    if kind == "num_seq":
        return "Sequence[float]"
    if kind == "struct_seq":
        return f"Sequence[{camel(spec.struct or '')}]"
    if kind == "handle":
        return camel(spec.struct or "")
    if kind in ("value", "out_value"):
        return spec.detail
    if kind == "out_cstr":
        return "str | None"
    return "Any"


def emit_api_pyi(model: Model, plan: dict[str, tuple[list[Spec], str]], arrays: list[str],
                 handles: list[str]) -> str:
    lines = [API_PYI_HEADER]
    for struct_name in arrays:
        lines.append(f"class {camel(struct_name)}: ...")
    for handle in handles:
        lines.append(f"class {camel(handle)}:")
        lines.append("    def __init__(self) -> None: ...")
    lines.append("")
    for func in model.funcs:
        if func.name not in plan:
            continue
        specs, retkind = plan[func.name]
        parts: list[str] = []
        has_ctx = bool(specs) and specs[0].kind == "ctx"
        if has_ctx:
            parts.append("ctx: Context")
        required: list[str] = []
        optional: list[str] = []
        keyword: list[str] = []
        returns: list[str] = []
        for spec in specs:
            if spec.kind == "ctx":
                continue
            if spec.kind == "opts":
                struct = model.structs[spec.struct]
                taken = {s.name for s in specs if s.kind not in ("opts", "ctx")}
                for field in struct.fields:
                    if field.name.startswith("_") or safe(field.name) in taken:
                        continue
                    keyword.append(f"{safe(field.name)}: {_pyi_field_type(field, model)} = ...")
                continue
            if spec.kind in ("out_scalar", "out_value", "out_cstr"):
                optional.append(f"{spec.name}: {_pyi_type(spec, model)} = ...")
                returns.append(_pyi_type(spec, model))
                continue
            if spec.kind == "text_buffer":
                optional.append("text: str = ...")
                continue
            (optional if spec.kind == "handle" else required).append(
                f"{spec.name}: {_pyi_type(spec, model)}"
            )
        parts.extend(required)
        parts.extend(optional)
        if keyword:
            parts.append("*")
            parts.extend(keyword)
        ret = {
            "void": "None",
            "bool": "bool",
            "int": "int",
            "float": "float",
            "cstr": "str | None",
            "text_result": "TextResult",
            "text_result_void": "TextResult",
        }.get(retkind, "Any")
        if retkind.startswith("value:"):
            ret = retkind.split(":", 1)[1]
        if returns:
            ret = f"tuple[{ret}, {', '.join(returns)}]" if ret != "None" else (
                returns[0] if len(returns) == 1 else f"tuple[{', '.join(returns)}]"
            )
        lines.append(f"def {wrapper_name(func.name)}({', '.join(parts)}) -> {ret}: ...")
    lines.append("")
    return "\n".join(lines)


def _pyi_field_type(field: Field, model: Model) -> str:
    ctype = field.ctype.strip()
    if ctype in BOOL_CTYPES:
        return "bool"
    if ctype in INT_CTYPES or model.is_enum(ctype):
        return "int"
    if ctype in FLOAT_CTYPES:
        return "float"
    if ctype in ("const char *", "char *"):
        return "str | None"
    if ctype == "const char *const *":
        return "Sequence[str] | None"
    if ctype in VALUE_STRUCTS:
        return VALUE_STRUCTS[ctype] + " | None"
    return "Any"


def emit_init_pyi(model: Model) -> str:
    lines = [
        '"""Type stubs for the cui package.',
        "",
        "GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.",
        '"""',
        "",
        "from typing import Any, Sequence",
        "",
        "from ._cui import App, Context, DrawData, SoftwareRenderer, file_dialog",
        "from ._gen.model import *",
        "from ._types import CanvasResult, ChartAnnotation, Color, Corners, Date, DotChartResult, DotSeries, EventTrackResult, KeyCombo, Rect, Series, Size, SizeKind, TextFlags, TextMetrics, TextResult, Vec2",
        "from .ui import UI",
        "",
        "__version__: str",
        "CUI_VERSION: str",
        "",
    ]
    for enum in model.enums:
        members = strip_enum_prefix(enum)
        if enum.name and re.fullmatch(r"cui_\w+", enum.name):
            lines.append(f"class {camel(enum.name)}:")
            for name, value in members:
                lines.append(f"    {name}: int = ...")
            if enum.name == "cui_mod":
                lines.append("    PRIMARY: int = ...")
        else:
            for name, value in members:
                lines.append(f"{name}: int")
        lines.append("")
    for name, value in parse_icons().items():
        lines.append(f'{re.sub(r"^CUI_ICON_", "ICON_", name)}: str')
    lines.append("")
    lines.append("class Icon:")
    for name in parse_icons():
        lines.append(f"    {re.sub(r'^CUI_ICON_', '', name)}: str")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# coverage
# ---------------------------------------------------------------------------


def coverage(model: Model, plan: dict[str, tuple[list[Spec], str]], skipped: dict[str, str],
             core: set[str]) -> str:
    hand = {name for name in skipped if name in core}
    phase3 = {name: why for name, why in skipped.items() if name not in core}
    wrapped = len(plan) + len(hand)
    total = wrapped + len(phase3)
    lines = [
        "# Generated API coverage",
        "",
        "Produced by `tools/gen_cui.py`; regenerated with the bindings.",
        "",
        f"- callable CUI functions: **{total}**",
        f"- wrapped: **{wrapped}** ({len(plan)} generated, {len(hand)} hand-written)",
        f"- left to phase 3: **{len(phase3)}**",
        "",
        "Wrapped functions take the context first, option structs as keyword",
        "arguments, and return out-parameters alongside the C return value.",
        "",
        "## Hand-written in `_cui.pyx`",
        "",
        "| function | why |",
        "| --- | --- |",
    ]
    for name in sorted(hand):
        lines.append(f"| `{name}` | {skipped[name]} |")
    lines.extend([
        "",
        "## Not wrapped yet",
        "",
        "| function | why |",
        "| --- | --- |",
    ])
    for name in sorted(phase3):
        lines.append(f"| `{name}` | {phase3[name]} |")
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail when a generated file is stale")
    options = parser.parse_args()

    model = parse()
    plan: dict[str, tuple[list[Spec], str]] = {}
    skipped: dict[str, str] = {}
    handles: set[str] = set()

    for func in model.funcs:
        if func.variadic:
            skipped[func.name] = "variadic C function"
            continue
        if func.name in CORE_FUNCTIONS or func.name.startswith(CORE_PREFIXES):
            skipped[func.name] = "wrapped by hand in `_cui.pyx`"
            continue
        try:
            specs, retkind = classify(func, model)
            for spec in specs:
                if spec.kind == "handle":
                    handles.add(spec.struct)
                elif spec.kind == "struct_seq" and not is_plain(model.structs[spec.struct], model):
                    raise Unsupported(f"`{spec.struct}` has pointer fields")
        except Unsupported as exc:
            skipped[func.name] = str(exc)
            continue
        plan[func.name] = (specs, retkind)

    arrays = array_structs(plan, model)
    handle_list = sorted(handles)
    core = {f.name for f in model.funcs if f.name in CORE_FUNCTIONS or f.name.startswith(CORE_PREFIXES)}
    files = {
        OUT_DECL: emit_decls(model),
        OUT_CONSTANTS: emit_constants(model),
        OUT_MODEL: emit_model(model, arrays),
        OUT_SIZES: emit_sizes(handle_list, model),
        OUT_API: emit_api(model, plan, handle_list, arrays),
        OUT_API_PYI: emit_api_pyi(model, plan, arrays, handle_list),
        OUT_INIT_PYI: emit_init_pyi(model),
        OUT_COVERAGE: coverage(model, plan, skipped, core),
    }

    stale = []
    for path, content in files.items():
        if options.check:
            current = path.read_text(encoding="utf-8") if path.exists() else ""
            if current != content:
                stale.append(path)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8", newline="\n")

    total = len(plan) + len(skipped)
    hand = sum(1 for name in skipped if name in core)
    print(f"{total} CUI functions: {len(plan) + hand} wrapped ({len(plan)} generated, {hand} hand-written), "
          f"{len(skipped) - hand} deferred")
    if options.check and stale:
        for path in stale:
            print(f"stale: {path.relative_to(ROOT)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
