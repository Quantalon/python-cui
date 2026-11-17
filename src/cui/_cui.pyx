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

from ._types import (
    CanvasResult,
    ChartAnnotation,
    Color,
    Corners,
    Date,
    DotChartResult,
    DotSeries,
    EventTrackResult,
    KeyCombo,
    Rect,
    Series,
    Size,
    TextResult,
    Vec2,
)
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

    ctypedef struct pycui_canvas_state:
        PyObject *callable

    void pycui_canvas_trampoline(cui_ctx *ui, cui_rect rect, void *user) noexcept nogil
    float pycui_theme_font_scale(cui_ctx *ui) noexcept
    void pycui_theme_set_font_scale(cui_ctx *ui, float value) noexcept


# Exceptions raised by a canvas paint callback run from CUI's paint phase.  They
# cannot unwind through the C stack, so they are parked here until the frame
# around them finishes, then raised from Python.
_paint_errors = []


cdef void _raise_paint_error() except *:
    cdef object exc
    if _paint_errors:
        exc = _paint_errors.pop(0)
        del _paint_errors[:]
        raise exc



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
# Chart data: C arrays of structs whose fields are Python-owned strings and
# value arrays.  Everything is parked in Context._keep until the frame ends.
# ---------------------------------------------------------------------------

cdef const cui_series *_series_array(Context ctx, object values, int *count) except NULL:
    cdef list seq
    cdef Py_ssize_t n, i
    cdef bytes block
    cdef cui_series *arr
    cdef const float *data
    cdef int inner = 0
    cdef object item
    if values is None:
        count[0] = 0
        return NULL
    seq = list(values)
    n = len(seq)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_series) * (n if n else 1))
    arr = <cui_series *>PyBytes_AsString(block)
    memset(arr, 0, sizeof(cui_series) * (n if n else 1))
    for i in range(n):
        item = seq[i]
        if not isinstance(item, Series):
            raise TypeError("chart series must be cui.Series values")
        data = ctx._c_float_array(item.values, &inner)
        arr[i].values = data
        arr[i].count = inner
        if item.name is not None:
            arr[i].name = ctx._s(item.name)
        if item.color is not None:
            arr[i].color = _color(item.color)
    count[0] = <int>n
    ctx._keep.append(block)
    return arr


cdef const cui_dot_series *_dot_series_array(Context ctx, object values, int *count) except NULL:
    cdef list seq
    cdef Py_ssize_t n, i
    cdef bytes block
    cdef cui_dot_series *arr
    cdef const float *data
    cdef int inner = 0
    cdef object item
    if values is None:
        count[0] = 0
        return NULL
    seq = list(values)
    n = len(seq)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_dot_series) * (n if n else 1))
    arr = <cui_dot_series *>PyBytes_AsString(block)
    memset(arr, 0, sizeof(cui_dot_series) * (n if n else 1))
    for i in range(n):
        item = seq[i]
        if not isinstance(item, DotSeries):
            raise TypeError("dot-chart series must be cui.DotSeries values")
        data = ctx._c_float_array(item.values, &inner)
        arr[i].values = data
        arr[i].accent = <uint8_t>bool(item.accent)
        if item.name is not None:
            arr[i].name = ctx._s(item.name)
    count[0] = <int>n
    ctx._keep.append(block)
    return arr


cdef const cui_vec2 *_vec2_array(Context ctx, object points, int *count) except NULL:
    cdef list seq
    cdef Py_ssize_t n, i
    cdef bytes block
    cdef cui_vec2 *arr
    if points is None:
        count[0] = 0
        return NULL
    seq = list(points)
    n = len(seq)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_vec2) * (n if n else 1))
    arr = <cui_vec2 *>PyBytes_AsString(block)
    for i in range(n):
        arr[i].x = <float>seq[i][0]
        arr[i].y = <float>seq[i][1]
    count[0] = <int>n
    ctx._keep.append(block)
    return arr


cdef const cui_chart_annotation *_annotation_array(Context ctx, object values, int *count) except NULL:
    cdef list seq
    cdef Py_ssize_t n, i
    cdef bytes block
    cdef cui_chart_annotation *arr
    cdef object item
    if values is None:
        count[0] = 0
        return NULL
    seq = list(values)
    n = len(seq)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_chart_annotation) * (n if n else 1))
    arr = <cui_chart_annotation *>PyBytes_AsString(block)
    memset(arr, 0, sizeof(cui_chart_annotation) * (n if n else 1))
    for i in range(n):
        item = seq[i]
        if not isinstance(item, ChartAnnotation):
            raise TypeError("chart annotations must be cui.ChartAnnotation values")
        arr[i].kind = <int>item.kind
        arr[i].x = <double>item.x
        arr[i].y = <double>item.y
        arr[i].accent = <uint8_t>bool(item.accent)
        if item.label is not None:
            arr[i].label = ctx._s(item.label)
        if item.detail is not None:
            arr[i].detail = ctx._s(item.detail)
    count[0] = <int>n
    ctx._keep.append(block)
    return arr


cdef void _fill_chart_opts(Context ctx, cui_chart_opts *o, dict opts) except *:
    cdef const char *const *labels
    cdef int n_labels = 0
    cdef const cui_chart_annotation *notes
    cdef int n_notes = 0
    cdef object key, value
    for key, value in opts.items():
        if key == "width":
            to_size(value, &o.width)
        elif key == "height":
            o.height = <float>value
        elif key == "labels":
            labels = ctx._s_array(value, &n_labels)
            o.labels = labels
            o.label_count = n_labels
        elif key == "label_count":
            o.label_count = <int>value
        elif key == "area":
            o.area = <uint8_t>bool(value)
        elif key == "no_grid":
            o.no_grid = <uint8_t>bool(value)
        elif key == "no_legend":
            o.no_legend = <uint8_t>bool(value)
        elif key == "stacked":
            o.stacked = <uint8_t>bool(value)
        elif key == "smooth":
            o.smooth = <uint8_t>bool(value)
        elif key == "format":
            o.format = ctx._s(value) if value is not None else NULL
        elif key == "min":
            o.min = <float>value
        elif key == "max":
            o.max = <float>value
        elif key == "annotations":
            notes = _annotation_array(ctx, value, &n_notes)
            o.annotations = notes
            o.annotation_count = n_notes
        elif key == "annotation_count":
            o.annotation_count = <int>value
        else:
            raise TypeError("unknown chart option %r" % (key,))


cdef void _fill_dot_chart_opts(Context ctx, cui_dot_chart_opts *o, dict opts) except *:
    cdef const cui_chart_annotation *notes
    cdef int n_notes = 0
    cdef object key, value
    for key, value in opts.items():
        if key == "width":
            to_size(value, &o.width)
        elif key == "height":
            o.height = <float>value
        elif key == "x_min":
            o.x_min = <double>value
        elif key == "x_max":
            o.x_max = <double>value
        elif key == "x_units":
            o.x_units = <int>value
        elif key == "x_format":
            o.x_format = ctx._s(value) if value is not None else NULL
        elif key == "x_step":
            o.x_step = <double>value
        elif key == "min":
            o.min = <float>value
        elif key == "max":
            o.max = <float>value
        elif key == "format":
            o.format = ctx._s(value) if value is not None else NULL
        elif key == "unit":
            o.unit = ctx._s(value) if value is not None else NULL
        elif key == "pitch":
            o.pitch = <float>value
        elif key == "no_grid":
            o.no_grid = <uint8_t>bool(value)
        elif key == "no_axis":
            o.no_axis = <uint8_t>bool(value)
        elif key == "no_readout":
            o.no_readout = <uint8_t>bool(value)
        elif key == "annotations":
            notes = _annotation_array(ctx, value, &n_notes)
            o.annotations = notes
            o.annotation_count = n_notes
        elif key == "annotation_count":
            o.annotation_count = <int>value
        else:
            raise TypeError("unknown dot-chart option %r" % (key,))



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
        self._split_buffers = {}
        self._split_stack = []
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
            self._split_buffers.clear()
            self._split_stack = []
        self._ui = ui
        self._owns = False
        if self._thread_id is None:
            self._thread_id = _current_thread()

    def _bind_ptr(self, uintptr_t address):
        """Bind the Python object to the C context the app loop passes in."""
        self._adopt(<cui_ctx *>address)
        # A new app frame starts here: release the strings and arrays the paint
        # phase of the previous frame may still have referenced.
        self._keep = []
        _raise_paint_error()

    # -- lifetime ----------------------------------------------------------

    def destroy(self):
        """Free the context now instead of at garbage collection."""
        if self._owns and self._ui != NULL:
            cui_destroy(self._ui)
        self._ui = NULL
        self._owns = False
        self._keep = []
        self._text_buffers.clear()
        self._split_buffers.clear()
        self._split_stack = []
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
        _raise_paint_error()
        self._keep = []
        cui_begin_frame(self._ctx(), dt)

    def end_frame(self):
        """Finish the frame; :meth:`draw_data` is valid from here on."""
        cui_end_frame(self._ctx())
        # Nothing that CUI kept can reach Python after the paint phase: drop the
        # strings and canvas callbacks so a callback that closes over this
        # Context cannot form a reference cycle with it.
        self._keep = []
        _raise_paint_error()

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

    # -- custom paint ------------------------------------------------------

    def canvas(self, id, width, height, paint):
        """A box of ``width`` x ``height`` painted by ``paint(rect)``.

        The callback runs while CUI paints the frame, after layout, so it must
        draw through this same context.  Its exception is re-raised after the
        frame instead of crossing the C stack.
        """
        cdef cui_canvas_result res
        cdef pycui_canvas_state state
        cdef object wrapper

        if not callable(paint):
            raise TypeError("canvas() needs a callable paint(rect)")

        def call(object rect):
            try:
                paint(Rect(rect[0], rect[1], rect[2], rect[3]))
            except BaseException as exc:
                _paint_errors.append(exc)
                cui_app_quit(NULL)

        wrapper = call
        self._keep.append(wrapper)
        state.callable = <PyObject *>wrapper
        res = cui_canvas(self._ctx(), self._s(id), _size(width), _size(height),
                         <cui_paint_fn>pycui_canvas_trampoline, &state, sizeof(state))
        return CanvasResult(
            Rect(res.rect.x, res.rect.y, res.rect.w, res.rect.h),
            bool(res.hovered),
            bool(res.pressed),
            bool(res.clicked),
            Vec2(res.mouse.x, res.mouse.y),
        )

    def draw_polyline(self, points, float thickness, color, bint closed=False):
        """Draw a connected line through ``points`` (a sequence of (x, y))."""
        cdef int n = 0
        cdef const cui_vec2 *arr = _vec2_array(self, points, &n)
        cui_draw_polyline(self._ctx(), arr, n, thickness, _color(color), closed)

    def draw_polygon(self, points, color):
        """Draw a filled polygon through ``points``."""
        cdef int n = 0
        cdef const cui_vec2 *arr = _vec2_array(self, points, &n)
        cui_draw_polygon(self._ctx(), arr, n, _color(color))

    # -- containers --------------------------------------------------------

    def split_begin(self, id, ratio=0.0, **opts):
        """Start a split view; the ratio lives in the context, not on the stack."""
        cdef cui_split_opts o
        cdef bytes block
        cdef float *ptr
        cdef object key = id
        cdef object option, value
        block = self._split_buffers.get(key)
        if block is None:
            block = PyBytes_FromStringAndSize(NULL, sizeof(float))
            self._split_buffers[key] = block
        ptr = <float *>PyBytes_AsString(block)
        ptr[0] = <float>ratio
        memset(&o, 0, sizeof(o))
        for option, value in opts.items():
            if option == "vertical":
                o.vertical = <uint8_t>bool(value)
            elif option == "min_first":
                o.min_first = <float>value
            elif option == "min_second":
                o.min_second = <float>value
            elif option == "width":
                to_size(value, &o.width)
            elif option == "height":
                to_size(value, &o.height)
            else:
                raise TypeError("unknown split option %r" % (option,))
        cui_split_begin(self._ctx(), self._s(id), ptr, &o)
        self._split_stack.append((key, block))
        return float(ptr[0])

    def split_next(self):
        """The divider has been laid out; build the second pane."""
        cui_split_next(self._ctx())

    def split_end(self):
        """Close the split view and return the (possibly dragged) ratio."""
        cdef bytes block
        cdef float *ptr
        cdef tuple entry
        if not self._split_stack:
            raise RuntimeError("split_end() without a matching split_begin()")
        entry = self._split_stack.pop()
        cui_split_end(self._ctx())
        block = entry[1]
        ptr = <float *>PyBytes_AsString(block)
        return float(ptr[0])

    # -- charts ------------------------------------------------------------

    def line_chart(self, id, series, **opts):
        """A line chart: a sequence of :class:`cui.Series`."""
        cdef cui_chart_opts o
        cdef const cui_series *arr
        cdef int n = 0
        memset(&o, 0, sizeof(o))
        _fill_chart_opts(self, &o, opts)
        arr = _series_array(self, series, &n)
        cui_line_chart_ex(self._ctx(), self._s(id), arr, n, &o)

    def bar_chart(self, id, series, **opts):
        """A bar chart: a sequence of :class:`cui.Series`."""
        cdef cui_chart_opts o
        cdef const cui_series *arr
        cdef int n = 0
        memset(&o, 0, sizeof(o))
        _fill_chart_opts(self, &o, opts)
        arr = _series_array(self, series, &n)
        cui_bar_chart_ex(self._ctx(), self._s(id), arr, n, &o)

    def donut_chart(self, id, values, labels=None, **opts):
        """A donut chart: a value per label, with an optional legend."""
        cdef cui_chart_opts o
        cdef const float *vals
        cdef int n_vals = 0
        cdef dict options = dict(opts)
        if labels is not None:
            options["labels"] = labels
        memset(&o, 0, sizeof(o))
        _fill_chart_opts(self, &o, options)
        vals = self._c_float_array(values, &n_vals)
        if o.label_count and o.label_count != n_vals:
            raise ValueError("donut_chart() needs one label per value")
        cui_donut_chart_ex(self._ctx(), self._s(id), vals, o.labels, n_vals, &o)

    def dot_chart(self, id, series, int count=0, **opts):
        """A dot-matrix chart: a sequence of :class:`cui.DotSeries`."""
        cdef cui_dot_chart_opts o
        cdef const cui_dot_series *arr
        cdef cui_dot_chart_result r
        cdef int n = 0
        cdef object seq
        cdef Py_ssize_t longest = 0
        seq = list(series) if series is not None else []
        for item in seq:
            if not isinstance(item, DotSeries):
                raise TypeError("dot-chart series must be cui.DotSeries values")
            if len(item.values) > longest:
                longest = len(item.values)
        if count <= 0:
            count = <int>longest
        memset(&o, 0, sizeof(o))
        _fill_dot_chart_opts(self, &o, opts)
        arr = _dot_series_array(self, seq, &n)
        r = cui_dot_chart_ex(self._ctx(), self._s(id), arr, n, count, &o)
        return DotChartResult(int(r.hovered), float(r.x), float(r.value), bool(r.clicked))

    def event_track(self, id, times, capacity, minimum, maximum, selected=-1, **opts):
        """A draggable event track; returns the edited times and selection."""
        cdef cui_event_track_opts o
        cdef cui_event_track_result r
        cdef double *buf
        cdef bytes block
        cdef int count
        cdef int selected_out = <int>selected
        cdef int i
        cdef object key, value
        times = list(times or [])
        if capacity < len(times):
            raise ValueError("capacity is smaller than the number of times")
        if capacity <= 0:
            raise ValueError("capacity must be positive")
        block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(double) * capacity)
        buf = <double *>PyBytes_AsString(block)
        count = len(times)
        for i in range(count):
            buf[i] = <double>times[i]
        self._keep.append(block)
        memset(&o, 0, sizeof(o))
        o.selected = &selected_out
        for key, value in opts.items():
            if key == "width":
                to_size(value, &o.width)
            elif key == "step":
                o.step = <double>value
            elif key == "units":
                o.units = <int>value
            elif key == "format":
                o.format = self._s(value) if value is not None else NULL
            elif key == "label_step":
                o.label_step = <double>value
            elif key == "no_add":
                o.no_add = <uint8_t>bool(value)
            elif key == "no_remove":
                o.no_remove = <uint8_t>bool(value)
            elif key == "no_axis":
                o.no_axis = <uint8_t>bool(value)
            else:
                raise TypeError("unknown event-track option %r" % (key,))
        r = cui_event_track_ex(self._ctx(), self._s(id), buf, &count, <int>capacity,
                               <double>minimum, <double>maximum, &o)
        return EventTrackResult(
            [float(buf[i]) for i in range(count)],
            int(selected_out),
            bool(r.changed),
            int(r.added),
            int(r.removed),
            bool(r.dragging),
        )

    # -- theme -------------------------------------------------------------

    @property
    def font_scale(self):
        """User text scale multiplier; changing it affects the next frame."""
        return pycui_theme_font_scale(self._ctx())

    @font_scale.setter
    def font_scale(self, float value):
        pycui_theme_set_font_scale(self._ctx(), value)

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
# Native file dialogs
# ---------------------------------------------------------------------------

cdef object _file_dialog(cui_app *app, dict opts) except *:
    cdef cui_file_dialog_opts o
    cdef char out[4096]
    cdef object kind = opts.pop("kind", 0)
    cdef object title = opts.pop("title", None)
    cdef object filter_name = opts.pop("filter_name", None)
    cdef object filter_value = opts.pop("filter", None)
    cdef object default_name = opts.pop("default_name", None)
    cdef const char *c_title = NULL
    cdef const char *c_filter_name = NULL
    cdef const char *c_filter = NULL
    cdef const char *c_default_name = NULL
    if opts:
        raise TypeError("unknown file-dialog option(s): %s" % ", ".join(sorted(opts)))
    memset(&o, 0, sizeof(o))
    o.kind = <int>kind
    if title is not None:
        c_title = PyUnicode_AsUTF8AndSize(title, NULL)
        o.title = c_title
    if filter_name is not None:
        c_filter_name = PyUnicode_AsUTF8AndSize(filter_name, NULL)
        o.filter_name = c_filter_name
    if filter_value is not None:
        c_filter = PyUnicode_AsUTF8AndSize(filter_value, NULL)
        o.filter = c_filter
    if default_name is not None:
        c_default_name = PyUnicode_AsUTF8AndSize(default_name, NULL)
        o.default_name = c_default_name
    if not cui_app_file_dialog(app, &o, out, sizeof(out)):
        return None
    return out.decode("utf-8", "replace")


def file_dialog(**opts):
    """Run a native open/save/folder dialog; returns the path or ``None``.

    Called from an ``App.run`` frame this uses that window; outside a running
    app it returns ``None`` (CUI needs a window to parent the dialog).
    """
    return _file_dialog(NULL, dict(opts))


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
        if self._context is not None:
            self._context._keep = []
        return bool(ok)

    def run(self, frame, **desc):
        """Create the window and call ``frame(ui)`` until it closes.

        ``ui`` is the :class:`cui.UI` facade over the frame's
        :class:`cui.Context`, also reachable as ``ui.context``.  The loop runs
        with the GIL released, so other Python threads keep running while the
        window waits for input.  An exception raised inside ``frame`` stops the
        loop, unwinds cleanly and is re-raised here.
        """
        cdef cui_app_desc d
        cdef pycui_run_state st
        cdef Context ctx
        cdef int rc
        cdef object info = None
        cdef object invoke
        cdef object ui

        memset(&d, 0, sizeof(d))
        memset(&st, 0, sizeof(st))
        self._fill_desc(&d, dict(desc))
        ctx = Context.__new__(Context)
        # The C trampoline binds the frame's cui_ctx onto ``ctx`` and calls the
        # frame callable with it; the callable gets the UI facade instead.
        from .ui import UI

        ui = UI(ctx)
        invoke = lambda _context: frame(ui)
        Py_INCREF(invoke)
        st.callable = <PyObject *>invoke
        Py_INCREF(ctx)
        st.ui = <PyObject *>ctx
        try:
            with nogil:
                rc = cui_app_run(&d, pycui_frame_trampoline, &st)
            info = pycui_run_state_take_raise_info(&st)
        finally:
            pycui_run_state_release(&st)
            # Break the frame's keep-alive chain (a canvas callback may close
            # over this Context) before the app object goes away.
            ctx._keep = []
        if info is not None:
            raise info[0].with_traceback(info[1])
        _raise_paint_error()
        return rc

    def quit(self):
        cui_app_quit(self._app)

    def set_title(self, str title):
        cdef bytes b = title.encode("utf-8")
        cui_app_set_title(self._app, b)

    def set_size(self, int width, int height):
        cui_app_set_size(self._app, width, height)

    def file_dialog(self, **opts):
        """Run a native open/save/folder dialog owned by this window."""
        if self._app == NULL:
            raise RuntimeError("App has not been created")
        return _file_dialog(self._app, dict(opts))

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

