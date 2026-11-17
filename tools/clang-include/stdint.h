/* Minimal <stdint.h> for tools/gen_cui.py's libclang parse.
 *
 * Parse-only shim; see tools/clang-include/README.md. Not used by the build.
 */
#ifndef PYCUI_CLANG_INCLUDE_STDINT_H
#define PYCUI_CLANG_INCLUDE_STDINT_H

typedef __INT8_TYPE__ int8_t;
typedef __UINT8_TYPE__ uint8_t;
typedef __INT16_TYPE__ int16_t;
typedef __UINT16_TYPE__ uint16_t;
typedef __INT32_TYPE__ int32_t;
typedef __UINT32_TYPE__ uint32_t;
typedef __INT64_TYPE__ int64_t;
typedef __UINT64_TYPE__ uint64_t;

typedef __INTPTR_TYPE__ intptr_t;
typedef __UINTPTR_TYPE__ uintptr_t;

#endif /* PYCUI_CLANG_INCLUDE_STDINT_H */
