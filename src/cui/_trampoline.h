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
#include <cui/cui_app.h> /* cui_app_quit: only declared by the app layer */

typedef struct pycui_run_state {
    PyObject *callable; /* frame(ui) */
    PyObject *ui;       /* the Python Context object */
    PyObject *error;    /* BaseException instance, or NULL */
    PyObject *traceback;
    int quit;
} pycui_run_state;

/* The C frame callback handed to cui_app_run. */
void pycui_frame_trampoline(cui_ctx *ui, void *user);

/* Canvas: CUI calls this while it paints a frame.  The Python callable is kept
 * alive by the context; it receives a (x, y, w, h) tuple and draws through the
 * same context. */
typedef struct pycui_canvas_state {
    PyObject *callable;
} pycui_canvas_state;

void pycui_canvas_trampoline(cui_ctx *ui, cui_rect rect, void *user);

/* The two theme fields the Python context exposes; the cui_theme layout stays
 * private to C. */
float pycui_theme_font_scale(cui_ctx *ui);
void pycui_theme_set_font_scale(cui_ctx *ui, float value);

/* New reference: None when nothing was raised, else (exception, traceback).
 * The state keeps no reference to the exception afterwards. */
PyObject *pycui_run_state_take_raise_info(pycui_run_state *st);

/* Drop the references the state still holds. */
void pycui_run_state_release(pycui_run_state *st);

#endif /* PYCUI_TRAMPOLINE_H */
