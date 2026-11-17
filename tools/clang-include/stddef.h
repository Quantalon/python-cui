/* Minimal <stddef.h> for tools/gen_cui.py's libclang parse.
 *
 * Parse-only shim; see tools/clang-include/README.md. Not used by the build.
 */
#ifndef PYCUI_CLANG_INCLUDE_STDDEF_H
#define PYCUI_CLANG_INCLUDE_STDDEF_H

typedef __SIZE_TYPE__ size_t;
typedef __PTRDIFF_TYPE__ ptrdiff_t;

#define NULL ((void *)0)

#endif /* PYCUI_CLANG_INCLUDE_STDDEF_H */
