# clang include shims

`tools/gen_cui.py` runs libclang over CUI's public headers to read declarations.
It does not compile anything, but the headers `#include` four C standard
headers, so libclang still has to resolve them.

Those headers must not come from the host:

* the `libclang` wheel on PyPI ships `clang/cindex.py` and the native
  `libclang` library, but no C standard headers;
* on Windows libclang happens to find the Visual Studio / Windows SDK headers,
  while on Linux it finds none, so `bool`, `size_t` and `va_list` silently
  degrade to error-recovery types and the generated API changes;
* different C libraries and libclang builds would otherwise make the
  checked-in generated files depend on whoever ran the generator.

The generator therefore parses with `-nostdinc -isystem tools/clang-include`.
These shims define exactly the types CUI's headers use (`bool`, `true`,
`false`, `size_t`, `ptrdiff_t`, `NULL`, the fixed-width integers, `va_list`),
using the compiler's predefined `__*_TYPE__` macros so they follow the fixed
target triple.

They are parse input only and are never compiled into PYCUI. If CUI starts
using another standard type, add it here; a missing one now fails the
generation step with libclang's diagnostics instead of quietly producing a
different API.
