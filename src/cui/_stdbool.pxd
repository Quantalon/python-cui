# C's `bool` as a Cython type.
#
# `ctypedef bint bool` is exactly what Cython's own libc/stdbool.pxd declares:
# Cython treats the value as an integer, but the generated C names the type
# `bool`, which is what CUI's headers use.  That is what makes `bool *`
# out-parameters type-correct in the generated C (`uint8_t *` is an error with
# GCC 14 and later).
#
# It is repeated here because libc/stdbool.pxd only ships with Cython 3.3 and
# pyproject.toml still allows Cython 3.0.
cdef extern from "<stdbool.h>":
    ctypedef bint bool
