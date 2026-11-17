# The hand-written core object, declared so the generated wrapper module
# (cui._api) can use it without going through Python.
from libc.stddef cimport size_t

from .cui_decl cimport cui_box, cui_color, cui_corners, cui_ctx, cui_date, cui_key_combo, cui_rect, cui_size, cui_vec2

cdef class Context:
    cdef cui_ctx *_ui
    cdef bint _owns
    cdef object _keep
    cdef dict _text_buffers
    cdef dict _split_buffers
    cdef list _split_stack
    cdef object _thread_id
    cdef float _width
    cdef float _height
    cdef float _scale
    cdef list _id_stack
    cdef list _disabled_stack
    cdef object _renderer

    cdef void _adopt(self, cui_ctx *ui)
    cdef cui_ctx *_ctx(self) except NULL
    cdef const char *_s(self, object value) except NULL
    cdef const char *const *_s_array(self, object values, int *count) except NULL
    cdef const char *const *_s_array_z(self, object values) except NULL
    cdef const float *_c_float_array(self, object values, int *count) except NULL
    cdef const double *_c_double_array(self, object values, int *count) except NULL
    cdef const int *_c_int_array(self, object values, int *count) except NULL
    cdef const void *_c_bytes(self, object data, size_t *size) except NULL
    cdef char *_text_buffer(self, object key, object text, size_t *cap) except NULL
    cdef object _text_result(self, object key, int flags)
    cdef void _check_str(self, object value) except *
    cdef void _fill_box(self, cui_box *box, dict opts) except *

cdef cui_color _color(object value) except *
cdef cui_size _size(object value) except *

cdef void to_color(object value, cui_color *out) except *
cdef object from_color(cui_color *value)
cdef void to_size(object value, cui_size *out) except *
cdef object from_size(cui_size *value)
cdef void to_vec2(object value, cui_vec2 *out) except *
cdef object from_vec2(cui_vec2 *value)
cdef void to_rect(object value, cui_rect *out) except *
cdef object from_rect(cui_rect *value)
cdef void to_date(object value, cui_date *out) except *
cdef object from_date(cui_date *value)
cdef void to_corners(object value, cui_corners *out) except *
cdef object from_corners(cui_corners *value)
cdef void to_key_combo(object value, cui_key_combo *out) except *
cdef object from_key_combo(cui_key_combo *value)
