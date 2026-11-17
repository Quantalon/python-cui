/* Frame-callback trampoline between CUI's C event loop and Python.
 *
 * cui_app_run() calls a plain C function pointer with the GIL *not* held (the
 * binding drops the GIL around the whole loop so other Python threads keep
 * running).  This file is the only place that crosses back into Python from C:
 * it re-acquires the GIL, calls the Python frame callable, and stores any
 * exception instead of letting it unwind through the C stack.
 */
#ifndef PYCUI_TRAMPOLINE_H
#define PYCUI_TRAMPOLINE_H

#include <Python.h>
#include <cui/cui.h>

typedef struct pycui_run_state {
    PyObject *callable; /* frame(ui) */
    PyObject *ui;       /* the Python Context object */
    PyObject *error;    /* BaseException instance, or NULL */
    PyObject *traceback;
    int quit;
} pycui_run_state;

/* The C frame callback handed to cui_app_run. */
void pycui_frame_trampoline(cui_ctx *ui, void *user);

/* New reference: None when nothing was raised, else (exception, traceback).
 * The state keeps no reference to the exception afterwards. */
PyObject *pycui_run_state_take_raise_info(pycui_run_state *st);

/* Drop the references the state still holds. */
void pycui_run_state_release(pycui_run_state *st);

#endif /* PYCUI_TRAMPOLINE_H */
