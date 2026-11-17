#include "_trampoline.h"

static void pycui__store_failure(pycui_run_state *st) {
    PyObject *type = NULL, *value = NULL, *traceback = NULL;
    PyErr_Fetch(&type, &value, &traceback);
    if (type != NULL) {
        PyErr_NormalizeException(&type, &value, &traceback);
        if (value == NULL) { /* normalization failed: fall back to the type */
            value = type;
            type = NULL;
        }
        if (traceback != NULL) {
            PyException_SetTraceback(value, traceback);
        }
        st->error = value; /* take ownership of the fetched reference */
        value = NULL;
        st->traceback = traceback;
        traceback = NULL;
    }
    Py_XDECREF(type);
    Py_XDECREF(value);
    Py_XDECREF(traceback);
    PyErr_Clear();
    st->quit = 1;
}

void pycui_frame_trampoline(cui_ctx *ui, void *user) {
    pycui_run_state *st = (pycui_run_state *)user;
    PyGILState_STATE gil;
    PyObject *res;

    if (st == NULL || st->callable == NULL) {
        /* Nothing to call: end the loop rather than spin. */
        cui_app_quit(NULL);
        return;
    }
    if (st->error != NULL) { /* a previous frame already failed */
        cui_app_quit(NULL);
        return;
    }

    gil = PyGILState_Ensure();

    /* Give the Python Context object the current frame's cui_ctx. */
    res = PyObject_CallMethod(st->ui, "_bind_ptr", "K", (unsigned long long)(uintptr_t)ui);
    if (res == NULL) {
        pycui__store_failure(st);
        cui_app_quit(NULL);
        PyGILState_Release(gil);
        return;
    }
    Py_DECREF(res);

    res = PyObject_CallFunctionObjArgs(st->callable, st->ui, NULL);
    if (res == NULL) {
        pycui__store_failure(st);
        cui_app_quit(NULL);
        PyGILState_Release(gil);
        return;
    }
    Py_DECREF(res);
    PyGILState_Release(gil);
}

PyObject *pycui_run_state_take_raise_info(pycui_run_state *st) {
    PyObject *info;
    if (st->error == NULL) {
        Py_RETURN_NONE;
    }
    info = PyTuple_New(2);
    if (info == NULL) {
        return NULL;
    }
    PyTuple_SET_ITEM(info, 0, st->error); /* steals the reference */
    st->error = NULL;
    if (st->traceback != NULL) {
        PyTuple_SET_ITEM(info, 1, st->traceback); /* steals the reference */
        st->traceback = NULL;
    } else {
        Py_INCREF(Py_None);
        PyTuple_SET_ITEM(info, 1, Py_None);
    }
    return info;
}

void pycui_run_state_release(pycui_run_state *st) {
    Py_XDECREF(st->callable);
    Py_XDECREF(st->ui);
    Py_XDECREF(st->error);
    Py_XDECREF(st->traceback);
    st->callable = NULL;
    st->ui = NULL;
    st->error = NULL;
    st->traceback = NULL;
}
