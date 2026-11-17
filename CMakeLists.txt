# PYCUI: builds the `cui` Python package and its Cython extensions.
#
# CUI is vendored as the `CUI/` submodule and linked statically into the
# extensions, so the wheel ships no libcui.dll and a CUI upgrade is a submodule
# bump plus a rebuild.
cmake_minimum_required(VERSION 3.24)

project(cui_python LANGUAGES C)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

# CUI is a static archive linked into the shared Python extension modules, so
# its objects must be position independent on ELF platforms (-fPIC).  Without
# this the Linux link fails on relocations against libc symbols.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ---- CUI, statically linked -------------------------------------------------

set(CUI_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CUI_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(CUI_BUILD_SHARED   OFF CACHE BOOL "" FORCE)
set(CUI_WITH_APP       ON  CACHE BOOL "" FORCE)
set(CUI_DEFAULT_FONTS  ON  CACHE BOOL "" FORCE)
set(CUI_STB_IMAGE      ON  CACHE BOOL "" FORCE)
set(CUI_TEXT_SHAPING   OFF CACHE BOOL "" FORCE)
add_subdirectory(CUI EXCLUDE_FROM_ALL)

# The binding reports the CUI version it was compiled against; tools/gen_cui.py
# reads the same header for the generated API.
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/CUI/include/cui/cui.h" _cui_version_line
     REGEX "^#define CUI_VERSION_STRING")
string(REGEX MATCH "\"([0-9.]+)\"" _cui_version "${_cui_version_line}")
set(CUI_VERSION "${CMAKE_MATCH_1}")
message(STATUS "PYCUI: vendored CUI ${CUI_VERSION}")

# ---- Python -----------------------------------------------------------------

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)

# Cython is a build requirement, but it lives in the interpreter's Scripts
# directory on Windows, which is often not on PATH; look there first.
get_filename_component(_py_prefix "${Python_EXECUTABLE}" DIRECTORY)
find_program(CYTHON_EXECUTABLE
    NAMES cython cython3
    HINTS "${_py_prefix}" "${_py_prefix}/Scripts" "${_py_prefix}/bin"
    DOC "Cython compiler for the cui extensions")
if(NOT CYTHON_EXECUTABLE)
    message(FATAL_ERROR "Cython not found; `pip install cython` into ${Python_EXECUTABLE}'s environment")
endif()
message(STATUS "PYCUI: Cython ${CYTHON_EXECUTABLE}")

# ---- Cython extensions ------------------------------------------------------

set(_src "${CMAKE_CURRENT_SOURCE_DIR}/src/cui")
file(GLOB _cython_headers CONFIGURE_DEPENDS "${_src}/*.pxd")

# pycui_extension(<name> [EXTRA_C_SOURCES ...])
#
# Cythonizes <src>/<name>.pyx into a Python module `cui.<name>` and links CUI
# into it.  The generated wrappers ship as a separate translation unit from the
# hand-written core so each stays quick to compile and readable.
function(pycui_extension name)
    set(_pyx "${_src}/${name}.pyx")
    set(_c "${CMAKE_CURRENT_BINARY_DIR}/${name}.c")
    add_custom_command(
        OUTPUT "${_c}"
        COMMAND "${CYTHON_EXECUTABLE}" -3 --fast-fail --module-name "cui.${name}"
                -I "${_src}" "${_pyx}" -o "${_c}"
        DEPENDS "${_pyx}" ${_cython_headers}
        COMMENT "Cythonizing cui.${name}"
        VERBATIM)
    Python_add_library(${name} MODULE WITH_SOABI "${_c}" ${ARGN})
    target_include_directories(${name} PRIVATE "${_src}")
    target_link_libraries(${name} PRIVATE cui::cui)
    target_compile_definitions(${name} PRIVATE CUI_VERSION_STRING="${CUI_VERSION}")
    if(MSVC)
        target_compile_options(${name} PRIVATE /W3 /utf-8)
        target_compile_definitions(${name} PRIVATE _CRT_SECURE_NO_WARNINGS)
    else()
        target_compile_options(${name} PRIVATE -Wall -Wno-unused-function -Wno-unused-variable)
    endif()
    if(APPLE)
        set_target_properties(${name} PROPERTIES INSTALL_RPATH "@loader_path")
    elseif(UNIX)
        set_target_properties(${name} PROPERTIES INSTALL_RPATH "$ORIGIN")
    endif()
    install(TARGETS ${name} DESTINATION cui)
endfunction()

pycui_extension(_cui "${_src}/_trampoline.c")
pycui_extension(_api)

# The pure-Python package files.
install(DIRECTORY "${_src}/"
        DESTINATION cui
        FILES_MATCHING PATTERN "*.py" PATTERN "*.pyi" PATTERN "py.typed")
