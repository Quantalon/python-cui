/* Minimal <stdarg.h> for tools/gen_cui.py's libclang parse.
 *
 * Parse-only shim; see tools/clang-include/README.md. Not used by the build.
 */
#ifndef PYCUI_CLANG_INCLUDE_STDARG_H
#define PYCUI_CLANG_INCLUDE_STDARG_H

typedef __builtin_va_list va_list;

#endif /* PYCUI_CLANG_INCLUDE_STDARG_H */
