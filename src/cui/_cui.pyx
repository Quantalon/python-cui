# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: embedsignature=True
"""cui._cui — the Cython extension behind the :mod:`cui` package.

The hand-written core: context and app lifetime, the software renderer, the
string/buffer keep-alive machinery, and the conversions the generated wrappers
in :mod:`cui._api` call.  Nothing here is generated.
"""

from libc.stddef cimport size_t
from libc.stdint cimport int64_t, uint8_t, uint32_t, uint64_t, uintptr_t
from libc.string cimport memcpy, memset, strlen

from cpython.buffer cimport PyBUF_SIMPLE, PyBUF_WRITABLE, Py_buffer, PyBuffer_Release, PyObject_GetBuffer
from cpython.bytes cimport PyBytes_AsString, PyBytes_AsStringAndSize, PyBytes_FromStringAndSize
from cpython.ref cimport PyObject, Py_INCREF, Py_XDECREF
from cpython.unicode cimport PyUnicode_AsUTF8AndSize

from ._types import Color, Corners, Date, KeyCombo, Rect, Size, TextResult, Vec2
from .cui_decl cimport *

cdef extern from "_trampoline.h":
    ctypedef struct pycui_run_state:
        PyObject *callable
        PyObject *ui
        PyObject *error
        PyObject *traceback
        int quit

    void pycui_frame_trampoline(cui_ctx *ui, void *user) noexcept nogil
    object pycui_run_state_take_raise_info(pycui_run_state *st)
    void pycui_run_state_release(pycui_run_state *st)


# ---------------------------------------------------------------------------
# Conversions
# ---------------------------------------------------------------------------

cdef cui_color _color(object value) except *:
    """Accept a Color, an (r, g, b[, a]) tuple or a packed 0xRRGGBB int."""
    cdef cui_color c
    cdef object r, g, b, a
    if value is None:
        c.r = c.g = c.b = c.a = 0
        return c
    if isinstance(value, Color):
        c.r = value[0]
        c.g = value[1]
        c.b = value[2]
        c.a = value[3]
        return c
    if isinstance(value, int):
        c.r = (value >> 16) & 0xFF
        c.g = (value >> 8) & 0xFF
        c.b = value & 0xFF
        c.a = 255 if value <= 0xFFFFFF else (value >> 24) & 0xFF
        return c
    r, g, b = value[0], value[1], value[2]
    a = value[3] if len(value) > 3 else 255
    c.r = <uint8_t>r
    c.g = <uint8_t>g
    c.b = <uint8_t>b
    c.a = <uint8_t>a
    return c


cdef cui_size _size(object value) except *:
    """Accept a Size, a (kind, value) pair or a number of logical points."""
    cdef cui_size s
    if value is None:
        s.kind = 0
        s.value = 0
        return s
    if isinstance(value, Size):
        s.kind = <int>value[0]
        s.value = <float>value[1]
        return s
    if isinstance(value, (int, float)):
        s.kind = 2  # CUI_SIZE_FIXED
        s.value = <float>value
        return s
    s.kind = <int>value[0]
    s.value = <float>value[1]
    return s


# Value-struct conversions, shared with the generated wrappers in cui._api.

cdef void to_color(object value, cui_color *out) except *:
    out[0] = _color(value)


cdef object from_color(cui_color *value):
    return Color(value[0].r, value[0].g, value[0].b, value[0].a)


cdef void to_size(object value, cui_size *out) except *:
    out[0] = _size(value)


cdef object from_size(cui_size *value):
    return Size(value[0].kind, value[0].value)


cdef void to_vec2(object value, cui_vec2 *out) except *:
    if value is None:
        out[0].x = 0.0
        out[0].y = 0.0
        return
    out[0].x = <float>value[0]
    out[0].y = <float>value[1]


cdef object from_vec2(cui_vec2 *value):
    return Vec2(value[0].x, value[0].y)


cdef void to_rect(object value, cui_rect *out) except *:
    if value is None:
        out[0].x = 0.0
        out[0].y = 0.0
        out[0].w = 0.0
        out[0].h = 0.0
        return
    out[0].x = <float>value[0]
    out[0].y = <float>value[1]
    out[0].w = <float>value[2]
    out[0].h = <float>value[3]


cdef object from_rect(cui_rect *value):
    return Rect(value[0].x, value[0].y, value[0].w, value[0].h)


cdef void to_date(object value, cui_date *out) except *:
    if value is None:
        out[0].year = 0
        out[0].month = 0
        out[0].day = 0
        return
    out[0].year = <int>value[0]
    out[0].month = <int>value[1]
    out[0].day = <int>value[2]


cdef object from_date(cui_date *value):
    return Date(value[0].year, value[0].month, value[0].day)


cdef void to_corners(object value, cui_corners *out) except *:
    cdef float radius
    if value is None:
        out[0].tl = out[0].tr = out[0].br = out[0].bl = 0.0
        return
    if isinstance(value, (int, float)):
        radius = <float>value
        out[0].tl = out[0].tr = out[0].br = out[0].bl = radius
        return
    out[0].tl = <float>value[0]
    out[0].tr = <float>value[1]
    out[0].br = <float>value[2]
    out[0].bl = <float>value[3]


cdef object from_corners(cui_corners *value):
    return Corners(value[0].tl, value[0].tr, value[0].br, value[0].bl)


cdef void to_key_combo(object value, cui_key_combo *out) except *:
    if value is None:
        out[0].mods = 0
        out[0].key = 0
        return
    out[0].mods = <int>value[0]
    out[0].key = <int>value[1]


cdef object from_key_combo(cui_key_combo *value):
    return KeyCombo(value[0].mods, value[0].key)


# ---------------------------------------------------------------------------
# Software renderer
# ---------------------------------------------------------------------------

cdef class SoftwareRenderer:
    """The portable software rasterizer: no GPU, no window, no display."""

    cdef cui_sw_renderer *_sw

    def __cinit__(self):
        self._sw = cui_sw_create()
        if self._sw == NULL:
            raise MemoryError("cui_sw_create() returned NULL")

    def __dealloc__(self):
        if self._sw != NULL:
            cui_sw_destroy(self._sw)
            self._sw = NULL

    def __repr__(self):
        return "<cui.SoftwareRenderer>"

    cdef cui_renderer_iface _iface(self):
        return cui_sw_iface(self._sw)

    def set_threads(self, int threads):
        """Worker threads used by render(); 1 is single threaded."""
        cui_sw_set_threads(self._sw, threads)

    def render(self, DrawData draw_data, str fmt="rgba"):
        """Rasterize draw data into a ``bytes`` object of RGBA/BGRA pixels."""
        cdef const cui_draw_data *dd
        cdef int w, h
        cdef cui_sw_format format
        cdef Py_ssize_t size
        cdef char *raw
        cdef object out

        if draw_data._ptr == NULL:
            raise RuntimeError("draw data is no longer valid")
        dd = draw_data._ptr
        w = dd.width_px
        h = dd.height_px
        if w <= 0 or h <= 0:
            raise RuntimeError("draw data has no pixels (viewport not set?)")
        format = CUI_SW_BGRA if fmt.lower() == "bgra" else CUI_SW_RGBA
        size = <Py_ssize_t>w * h * 4
        out = PyBytes_FromStringAndSize(NULL, size)
        PyBytes_AsStringAndSize(out, &raw, &size)
        with nogil:
            cui_sw_render(self._sw, dd, raw, w, h, w * 4, format)
        return out

    def render_to(self, DrawData draw_data, object buffer, str fmt="rgba"):
        """Rasterize into a writable buffer (``bytearray`` or NumPy array)."""
        cdef const cui_draw_data *dd
        cdef int w, h
        cdef cui_sw_format format
        cdef Py_buffer view

        if draw_data._ptr == NULL:
            raise RuntimeError("draw data is no longer valid")
        dd = draw_data._ptr
        w = dd.width_px
        h = dd.height_px
        if PyObject_GetBuffer(buffer, &view, PyBUF_WRITABLE | PyBUF_SIMPLE) != 0:
            raise BufferError("render_to() needs a writable buffer")
        try:
            if view.len < <Py_ssize_t>w * h * 4:
                raise ValueError("buffer is smaller than %d x %d x 4 bytes" % (w, h))
            format = CUI_SW_BGRA if fmt.lower() == "bgra" else CUI_SW_RGBA
            with nogil:
                cui_sw_render(self._sw, dd, view.buf, w, h, w * 4, format)
        finally:
            PyBuffer_Release(&view)
        return buffer


cdef class DrawData:
    """The vertex/command lists CUI produced for one frame.

    Only valid until the next :meth:`Context.begin_frame`.
    """

    cdef const cui_draw_data *_ptr
    cdef object _owner

    def __repr__(self):
        cdef const cui_draw_data *dd = self._ptr
        if dd == NULL:
            return "<cui.DrawData (invalid)>"
        return "<cui.DrawData %dx%d, %d vertices, %d commands>" % (
            dd.width_px, dd.height_px, dd.vertex_count, dd.command_count)

    @property
    def width_px(self):
        return 0 if self._ptr == NULL else self._ptr.width_px

    @property
    def height_px(self):
        return 0 if self._ptr == NULL else self._ptr.height_px

    @property
    def vertex_count(self):
        return 0 if self._ptr == NULL else self._ptr.vertex_count

    @property
    def index_count(self):
        return 0 if self._ptr == NULL else self._ptr.index_count

    @property
    def command_count(self):
        return 0 if self._ptr == NULL else self._ptr.command_count

    @property
    def font_atlas(self):
        """Opaque handle of the font atlas texture the frame samples."""
        return 0 if self._ptr == NULL else <uintptr_t>self._ptr.font_atlas

    def clear_color(self):
        cdef cui_color c = self._ptr.clear_color
        return Color(c.r, c.g, c.b, c.a)

    def write_png(self, str path):
        """Rasterize the frame with its context's renderer and write a PNG."""
        cdef const cui_draw_data *dd = self._ptr
        cdef Context owner
        cdef object renderer
        cdef bytes pixels
        if dd == NULL:
            raise RuntimeError("draw data is no longer valid")
        renderer = None
        if self._owner is not None:
            owner = self._owner
            renderer = owner._renderer
        if renderer is None:
            raise RuntimeError("no software renderer is bound to this context")
        pixels = (<SoftwareRenderer>renderer).render(self, "rgba")
        if not cui_write_png(path.encode("utf-8"), <const char *>pixels,
                             dd.width_px, dd.height_px, dd.width_px * 4):
            raise OSError("cui_write_png failed: %s" % path)


# ---------------------------------------------------------------------------
# Context
# ---------------------------------------------------------------------------

cdef class Context:
    """A CUI context: the thing every component is drawn into.

    A context belongs to the thread that created it; every call checks that.
    The class attributes are declared in _cui.pxd so the generated wrappers in
    cui._api can use them directly.
    """

    def __cinit__(self, *args, **kwargs):
        self._ui = NULL
        self._owns = False
        self._keep = []
        self._text_buffers = {}
        self._id_stack = []
        self._disabled_stack = []
        self._width = 0.0
        self._height = 0.0
        self._scale = 1.0
        self._thread_id = None
        self._renderer = None

    def __dealloc__(self):
        if self._owns and self._ui != NULL:
            cui_destroy(self._ui)
        self._ui = NULL

    def __repr__(self):
        if self._ui == NULL:
            return "<cui.Context (destroyed)>"
        return "<cui.Context %dx%d @%.1fx>" % (
            <int>self._width, <int>self._height, self._scale)

    # -- creation ----------------------------------------------------------

    @classmethod
    def create(cls, renderer=None, theme=0, accent=0, no_default_fonts=False, direction=0):
        """Create a context. ``renderer`` is a :class:`SoftwareRenderer`."""
        cdef Context self = cls.__new__(cls)
        cdef cui_ctx_desc desc
        cdef cui_renderer_iface iface
        cdef SoftwareRenderer sw
        memset(&desc, 0, sizeof(desc))
        if renderer is None:
            raise TypeError("Context.create() needs a renderer, e.g. SoftwareRenderer()")
        if not isinstance(renderer, SoftwareRenderer):
            raise TypeError("renderer must be a SoftwareRenderer")
        sw = renderer
        iface = sw._iface()
        desc.renderer = iface
        desc.theme = <int>theme
        desc.accent = <int>accent
        desc.no_default_fonts = bool(no_default_fonts)
        desc.direction = <int>direction
        self._ui = cui_create(&desc)
        if self._ui == NULL:
            raise RuntimeError("cui_create() returned NULL")
        self._owns = True
        self._renderer = renderer
        self._thread_id = _current_thread()
        return self

    cdef void _adopt(self, cui_ctx *ui):
        """Wrap a context owned by the app layer (no destroy on GC)."""
        if self._ui != NULL and self._ui != ui:
            self._keep = []
            self._text_buffers.clear()
        self._ui = ui
        self._owns = False
        if self._thread_id is None:
            self._thread_id = _current_thread()

    def _bind_ptr(self, uintptr_t address):
        """Bind the Python object to the C context the app loop passes in."""
        self._adopt(<cui_ctx *>address)

    # -- lifetime ----------------------------------------------------------

    def destroy(self):
        """Free the context now instead of at garbage collection."""
        if self._owns and self._ui != NULL:
            cui_destroy(self._ui)
        self._ui = NULL
        self._owns = False
        self._keep = []
        self._text_buffers.clear()
        self._renderer = None

    cdef cui_ctx *_ctx(self) except NULL:
        if self._ui == NULL:
            raise RuntimeError("CUI context is already destroyed")
        if self._thread_id != _current_thread():
            raise RuntimeError("a CUI context may only be used from the thread that created it")
        return self._ui

    # -- frame -------------------------------------------------------------

    def set_viewport(self, float width, float height, float scale=1.0):
        """Logical size in points and the pixel scale (2.0 on a retina screen)."""
        self._width = width
        self._height = height
        self._scale = scale
        cui_set_viewport(self._ctx(), width, height, scale)

    def begin_frame(self, float dt=1.0 / 60.0):
        """Start a frame. Releases the previous frame's kept-alive objects."""
        self._keep = []
        cui_begin_frame(self._ctx(), dt)

    def end_frame(self):
        """Finish the frame; :meth:`draw_data` is valid from here on."""
        cui_end_frame(self._ctx())

    @property
    def width(self):
        return self._width

    @property
    def height(self):
        return self._height

    @property
    def scale(self):
        return self._scale

    @property
    def size(self):
        cdef cui_vec2 v = cui_viewport_size(self._ctx())
        return (v.x, v.y)

    @property
    def dpi_scale(self):
        return cui_dpi_scale(self._ctx())

    @property
    def time(self):
        return cui_time(self._ctx())

    @property
    def delta_time(self):
        return cui_delta_time(self._ctx())

    @property
    def frame_count(self):
        return cui_frame_count(self._ctx())

    def needs_redraw(self):
        return bool(cui_needs_redraw(self._ctx()))

    def next_wakeup(self):
        return cui_next_wakeup(self._ctx())

    def request_redraw(self):
        cui_request_redraw(self._ctx())

    def request_wakeup(self, float seconds):
        cui_request_wakeup(self._ctx(), seconds)

    def draw_data(self):
        cdef DrawData dd = DrawData.__new__(DrawData)
        dd._ptr = cui_get_draw_data(self._ctx())
        dd._owner = self
        return dd

    def render(self, renderer=None, str fmt="rgba"):
        """Render the current frame offscreen and return the pixels."""
        cdef DrawData dd = self.draw_data()
        cdef object target = renderer if renderer is not None else self._renderer
        if target is None:
            raise RuntimeError("no software renderer is bound to this context")
        return (<SoftwareRenderer>target).render(dd, fmt)

    def screenshot(self, str path):
        """Render the current frame and write it to a PNG file."""
        cdef DrawData dd = self.draw_data()
        dd.write_png(path)
        return dd

    # -- ids ---------------------------------------------------------------

    def make_id(self, str value):
        return cui_make_id(self._ctx(), self._s(value))

    def push_id(self, value):
        if isinstance(value, str):
            cui_push_id(self._ctx(), self._s(value))
        else:
            cui_push_id_int(self._ctx(), <int>value)
        self._id_stack.append(value)

    def pop_id(self):
        if not self._id_stack:
            raise RuntimeError("pop_id() without a matching push_id()")
        self._id_stack.pop()
        cui_pop_id(self._ctx())

    def push_disabled(self, bint disabled=True):
        cui_push_disabled(self._ctx(), disabled)
        self._disabled_stack.append(disabled)

    def pop_disabled(self):
        if not self._disabled_stack:
            raise RuntimeError("pop_disabled() without a matching push_disabled()")
        self._disabled_stack.pop()
        cui_pop_disabled(self._ctx())

    @property
    def last_id(self):
        return cui_last_id(self._ctx())

    @property
    def last_hovered(self):
        return bool(cui_last_hovered(self._ctx()))

    @property
    def disabled(self):
        return bool(cui_is_disabled(self._ctx()))

    def get_rect(self, uint32_t id):
        cdef cui_rect r = cui_get_rect(self._ctx(), id)
        return (r.x, r.y, r.w, r.h)

    def last_rect(self):
        cdef cui_rect r = cui_last_rect(self._ctx())
        return (r.x, r.y, r.w, r.h)

    # -- string and buffer keep-alive --------------------------------------

    cdef const char *_s(self, object value) except NULL:
        """UTF-8 pointer for a str, kept alive for the rest of the frame."""
        cdef const char *p
        cdef Py_ssize_t n
        if value is None:
            raise TypeError("expected a string, got None")
        if not isinstance(value, str):
            value = str(value)
        p = PyUnicode_AsUTF8AndSize(value, &n)
        if p == NULL:
            raise UnicodeError("could not encode %r as UTF-8" % (value,))
        if <Py_ssize_t>strlen(p) != n:
            raise ValueError("CUI strings cannot contain NUL bytes")
        self._keep.append(value)
        return p

    cdef const char *const *_s_array(self, object values, int *count) except NULL:
        """UTF-8 array pointer for a sequence of str, alive for the frame."""
        cdef list items
        cdef Py_ssize_t i, n
        cdef const char **arr
        cdef const char *p
        cdef bytes block
        cdef char *raw
        if values is None:
            count[0] = 0
            return NULL
        items = [v if isinstance(v, str) else str(v) for v in values]
        n = len(items)
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(char *) * (n if n > 0 else 1))
        raw = PyBytes_AsString(block)
        arr = <const char **>raw
        for i in range(n):
            p = PyUnicode_AsUTF8AndSize(items[i], NULL)
            if p == NULL:
                raise UnicodeError("could not encode item %d as UTF-8" % i)
            arr[i] = p
        count[0] = <int>n
        self._keep.append(items)   # the str objects behind the pointers
        self._keep.append(block)   # the pointer array itself
        return <const char *const *>arr

    cdef char *_text_buffer(self, object key, object text, size_t *cap) except NULL:
        """Persistent NUL-terminated UTF-8 buffer for CUI's editable text APIs."""
        cdef bytearray buf
        cdef bytes encoded
        cdef Py_ssize_t n
        buf = self._text_buffers.get(key)
        if buf is None:
            buf = bytearray(256)
            self._text_buffers[key] = buf
        encoded = (text or "").encode("utf-8")
        n = len(encoded)
        if len(buf) < n + 1:
            buf = bytearray(n + 64)
            self._text_buffers[key] = buf
        memcpy(<char *>buf, <const char *>encoded, n + 1)
        cap[0] = <size_t>len(buf)
        self._keep.append(buf)
        return <char *>buf

    cdef object _text_result(self, object key, int flags):
        cdef bytearray buf
        cdef object text
        buf = self._text_buffers.get(key)
        if buf is None:
            text = ""
        else:
            text = bytes(buf).split(b"\x00", 1)[0].decode("utf-8", "replace")
        return TextResult(text, flags)

    # -- marshalling for the generated wrappers ----------------------------

    cdef const char *const *_s_array_z(self, object values) except NULL:
        """NULL-terminated UTF-8 array, for struct fields without a count."""
        cdef list items
        cdef Py_ssize_t i, n
        cdef const char **arr
        cdef const char *p
        cdef bytes block
        if values is None:
            return NULL
        items = [v if isinstance(v, str) else str(v) for v in values]
        n = len(items)
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(char *) * (n + 1))
        arr = <const char **>PyBytes_AsString(block)
        for i in range(n):
            p = PyUnicode_AsUTF8AndSize(items[i], NULL)
            if p == NULL:
                raise UnicodeError("could not encode item %d as UTF-8" % i)
            arr[i] = p
        arr[n] = NULL
        self._keep.append(items)
        self._keep.append(block)
        return <const char *const *>arr

    cdef const float *_c_float_array(self, object values, int *count) except NULL:
        cdef list seq
        cdef Py_ssize_t i, n
        cdef float *buf
        cdef bytes block
        if values is None:
            count[0] = 0
            return NULL
        seq = list(values)
        n = len(seq)
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(float) * (n if n else 1))
        buf = <float *>PyBytes_AsString(block)
        for i in range(n):
            buf[i] = <float>seq[i]
        count[0] = <int>n
        self._keep.append(block)
        return buf

    cdef const double *_c_double_array(self, object values, int *count) except NULL:
        cdef list seq
        cdef Py_ssize_t i, n
        cdef double *buf
        cdef bytes block
        if values is None:
            count[0] = 0
            return NULL
        seq = list(values)
        n = len(seq)
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(double) * (n if n else 1))
        buf = <double *>PyBytes_AsString(block)
        for i in range(n):
            buf[i] = <double>seq[i]
        count[0] = <int>n
        self._keep.append(block)
        return buf

    cdef const int *_c_int_array(self, object values, int *count) except NULL:
        cdef list seq
        cdef Py_ssize_t i, n
        cdef int *buf
        cdef bytes block
        if values is None:
            count[0] = 0
            return NULL
        seq = list(values)
        n = len(seq)
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(int) * (n if n else 1))
        buf = <int *>PyBytes_AsString(block)
        for i in range(n):
            buf[i] = <int>seq[i]
        count[0] = <int>n
        self._keep.append(block)
        return buf

    cdef const void *_c_bytes(self, object data, size_t *size) except NULL:
        cdef char *raw
        cdef Py_ssize_t n
        if data is None:
            size[0] = 0
            return NULL
        PyBytes_AsStringAndSize(data, &raw, &n)
        size[0] = <size_t>n
        self._keep.append(data)
        return <const void *>raw

    # -- plain components (the generated wrappers cover the full API) -------

    def text(self, str text):
        self._check_str(text)
        cui_label(self._ctx(), self._s(text))

    def heading(self, str text, int level=1):
        self._check_str(text)
        cui_heading(self._ctx(), self._s(text), level)

    def label(self, str text):
        self._check_str(text)
        cui_label(self._ctx(), self._s(text))

    def secondary(self, str text):
        self._check_str(text)
        cui_secondary(self._ctx(), self._s(text))

    def muted(self, str text):
        self._check_str(text)
        cui_muted(self._ctx(), self._s(text))

    def code(self, str text):
        self._check_str(text)
        cui_code(self._ctx(), self._s(text))

    def kbd(self, str keys):
        self._check_str(keys)
        cui_kbd(self._ctx(), self._s(keys))

    def link(self, str text):
        self._check_str(text)
        return bool(cui_link(self._ctx(), self._s(text)))

    def separator(self):
        cui_separator(self._ctx())

    def spacer(self):
        cui_spacer(self._ctx())

    def gap(self, float size):
        cui_gap(self._ctx(), size)

    def measure_text(self, str text, int font=0, float size=0.0):
        cdef cui_text_metrics m
        cdef bytes b = text.encode("utf-8")
        m = cui_measure_text(self._ctx(), font, size, b, <int>len(b))
        return (m.width, m.height, m.ascent, m.descent, m.line_height)

    cdef void _check_str(self, object value) except *:
        if isinstance(value, str) and "\x00" in value:
            raise ValueError("CUI strings cannot contain NUL bytes")

    # -- boxes -------------------------------------------------------------

    def begin_box(self, int direction=0, **opts):
        cdef cui_box box
        memset(&box, 0, sizeof(box))
        box.dir = direction
        self._fill_box(&box, opts)
        return cui_box_begin(self._ctx(), &box)

    def begin_row(self, **opts):
        cdef cui_box box
        memset(&box, 0, sizeof(box))
        box.dir = 1
        self._fill_box(&box, opts)
        return cui_row_begin(self._ctx(), &box)

    def begin_column(self, **opts):
        cdef cui_box box
        memset(&box, 0, sizeof(box))
        box.dir = 0
        self._fill_box(&box, opts)
        return cui_column_begin(self._ctx(), &box)

    def end_box(self):
        cui_box_end(self._ctx())

    cdef void _fill_box(self, cui_box *box, dict opts) except *:
        cdef object key, value
        for key, value in opts.items():
            if key == "id":
                box.id = self._s(value)
            elif key == "width":
                box.width = _size(value)
            elif key == "height":
                box.height = _size(value)
            elif key == "min_width":
                box.min_width = <float>value
            elif key == "max_width":
                box.max_width = <float>value
            elif key == "min_height":
                box.min_height = <float>value
            elif key == "max_height":
                box.max_height = <float>value
            elif key == "pad":
                box.pad = <float>value
            elif key == "pad_x":
                box.pad_x = <float>value
            elif key == "pad_y":
                box.pad_y = <float>value
            elif key == "pad_top":
                box.pad_top = <float>value
            elif key == "pad_right":
                box.pad_right = <float>value
            elif key == "pad_bottom":
                box.pad_bottom = <float>value
            elif key == "pad_left":
                box.pad_left = <float>value
            elif key == "gap":
                box.gap = <float>value
            elif key == "columns":
                box.columns = <int>value
            elif key == "min_column_width":
                box.min_column_width = <float>value
            elif key == "wrap":
                box.wrap = bool(value)
            elif key == "align":
                box.align = <int>value
            elif key == "justify":
                box.justify = <int>value
            elif key == "bg":
                box.bg = _color(value)
            elif key == "border_color":
                box.border_color = _color(value)
            elif key == "border":
                box.border = <float>value
            elif key == "radius":
                box.radius = <float>value
            elif key == "elevation":
                box.elevation = <int>value
            elif key == "scroll_x":
                box.scroll_x = bool(value)
            elif key == "scroll_y":
                box.scroll_y = bool(value)
            elif key == "clip":
                box.clip = bool(value)
            elif key == "opacity":
                box.opacity = <float>value
            elif key == "direction":
                box.direction = <int>value
            else:
                raise TypeError("unknown box option %r" % (key,))


# ---------------------------------------------------------------------------
# App: window + event loop
# ---------------------------------------------------------------------------

cdef class App:
    """A window with an event loop, backed by CUI's native app layer."""

    cdef cui_app *_app
    cdef Context _context
    cdef object _desc_keep
    cdef bint _owns

    def __cinit__(self):
        self._app = NULL
        self._owns = False
        self._context = None

    def __dealloc__(self):
        if self._owns and self._app != NULL:
            cui_app_destroy(self._app)
        self._app = NULL

    def __repr__(self):
        if self._app == NULL:
            return "<cui.App (not created)>"
        return "<cui.App backend=%s>" % self.backend

    @property
    def context(self):
        cdef Context ctx
        if self._app == NULL:
            raise RuntimeError("App has not been created yet")
        if self._context is None:
            self._context = Context.__new__(Context)
        ctx = self._context
        ctx._adopt(cui_app_ui(self._app))
        return ctx

    @property
    def backend(self):
        if self._app == NULL:
            return "none"
        return cui_app_backend(self._app).decode("utf-8", "replace")

    @property
    def is_software(self):
        if self._app == NULL:
            return False
        return bool(cui_app_is_software(self._app))

    cdef void _fill_desc(self, cui_app_desc *d, dict desc) except *:
        cdef object title
        title = desc.pop("title", "CUI")
        self._desc_keep = title
        d.title = <const char *>PyUnicode_AsUTF8AndSize(title, NULL)
        d.width = <int>desc.pop("width", 1080)
        d.height = <int>desc.pop("height", 720)
        d.min_width = <int>desc.pop("min_width", 360)
        d.min_height = <int>desc.pop("min_height", 280)
        d.fixed_size = bool(desc.pop("fixed_size", False))
        d.continuous = bool(desc.pop("continuous", False))
        d.no_vsync = bool(desc.pop("no_vsync", False))
        d.hidden = bool(desc.pop("hidden", False))
        d.renderer = <int>desc.pop("renderer", 0)
        d.theme = <int>desc.pop("theme", 0)
        d.accent = <int>desc.pop("accent", 0)
        d.follow_system_theme = bool(desc.pop("follow_system_theme", False))
        if desc:
            raise TypeError("unknown app option(s): %s" % ", ".join(sorted(desc)))

    def create(self, **desc):
        cdef cui_app_desc d
        memset(&d, 0, sizeof(d))
        self._fill_desc(&d, dict(desc))
        self._app = cui_app_create(&d)
        if self._app == NULL:
            raise RuntimeError("cui_app_create() failed (no window available?)")
        self._owns = True
        return self

    def frame(self):
        """Present, wait for input, start the next frame. False when closed."""
        cdef bint ok
        cdef Context ctx
        if self._app == NULL:
            raise RuntimeError("App has not been created")
        ok = cui_app_frame(self._app)
        if ok:
            if self._context is None:
                self._context = Context.__new__(Context)
            ctx = self._context
            ctx._adopt(cui_app_ui(self._app))
        return bool(ok)

    def run(self, frame, **desc):
        """Create the window and call ``frame(context)`` until it closes.

        The loop runs with the GIL released, so other Python threads keep
        running while the window waits for input.  An exception raised inside
        ``frame`` stops the loop, unwinds cleanly and is re-raised here.
        """
        cdef cui_app_desc d
        cdef pycui_run_state st
        cdef Context ctx
        cdef int rc
        cdef object info = None

        memset(&d, 0, sizeof(d))
        memset(&st, 0, sizeof(st))
        self._fill_desc(&d, dict(desc))
        ctx = Context.__new__(Context)
        Py_INCREF(frame)
        st.callable = <PyObject *>frame
        Py_INCREF(ctx)
        st.ui = <PyObject *>ctx
        try:
            with nogil:
                rc = cui_app_run(&d, pycui_frame_trampoline, &st)
            info = pycui_run_state_take_raise_info(&st)
        finally:
            pycui_run_state_release(&st)
        if info is not None:
            raise info[0].with_traceback(info[1])
        return rc

    def quit(self):
        cui_app_quit(self._app)

    def set_title(self, str title):
        cdef bytes b = title.encode("utf-8")
        cui_app_set_title(self._app, b)

    def set_size(self, int width, int height):
        cui_app_set_size(self._app, width, height)

    @property
    def size(self):
        cdef cui_vec2 v = cui_app_size(self._app)
        return (v.x, v.y)

    def close(self):
        if self._owns and self._app != NULL:
            cui_app_destroy(self._app)
        self._app = NULL
        self._owns = False


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

cdef _current_thread():
    import threading
    return threading.get_ident()

