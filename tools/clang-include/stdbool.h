/* Minimal <stdbool.h> for tools/gen_cui.py's libclang parse.
 *
 * Parse-only shim; see tools/clang-include/README.md. Not used by the build.
 */
#ifndef PYCUI_CLANG_INCLUDE_STDBOOL_H
#define PYCUI_CLANG_INCLUDE_STDBOOL_H

#define bool _Bool
#define true 1
#define false 0

#endif /* PYCUI_CLANG_INCLUDE_STDBOOL_H */
