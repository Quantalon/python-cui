"""The native window and event loop.

These need a desktop session, so they are opt-in:

    $env:PYCUI_WINDOW_TESTS = "1"; python -m pytest tests

The loop is event driven: a static screen sleeps until input arrives, so the
frame callback asks for a wakeup to keep a timer-driven loop (or a test) going.
"""

from __future__ import annotations

import os

import pytest

import cui

pytestmark = pytest.mark.skipif(
    os.environ.get("PYCUI_WINDOW_TESTS") != "1",
    reason="needs a desktop session; set PYCUI_WINDOW_TESTS=1 to run",
)


def test_run_quit_and_redraw():
    app = cui.App()
    frames = []

    def frame(ui):
        assert isinstance(ui, cui.UI)
        frames.append(ui.context.frame_count)
        ui.context.request_wakeup(0.01)
        with ui.column(pad=8):
            ui.heading("trampoline")
        if len(frames) >= 3:
            app.quit()

    assert app.run(frame, title="PYCUI test", width=320, height=200, hidden=True) == 0
    assert len(frames) >= 3


def test_exception_in_frame_stops_the_loop_and_reraises():
    app = cui.App()

    def frame(ui):
        ui.context.request_wakeup(0.01)
        raise RuntimeError("from the frame")

    with pytest.raises(RuntimeError, match="from the frame"):
        app.run(frame, title="PYCUI test", width=320, height=200, hidden=True)


def test_backend_is_reported():
    app = cui.App().create(title="PYCUI test", width=200, height=120, hidden=True)
    try:
        assert app.backend in ("win32", "cocoa", "x11", "sdl2", "glfw")
        assert isinstance(app.is_software, bool)
    finally:
        app.close()


def test_the_loop_releases_the_gil():
    """Other Python threads must keep running while the window waits."""
    import threading
    import time

    app = cui.App()
    counter = {"ticks": 0}
    running = threading.Event()
    running.set()

    def ticker():
        while running.is_set():
            counter["ticks"] += 1
            time.sleep(0.001)

    thread = threading.Thread(target=ticker, daemon=True)
    thread.start()
    start = time.perf_counter()

    def frame(ui):
        ui.context.request_wakeup(0.005)
        if time.perf_counter() - start > 0.3:
            app.quit()

    try:
        app.run(frame, title="PYCUI gil", width=200, height=120, hidden=True)
    finally:
        running.clear()
        thread.join(timeout=1.0)
    assert counter["ticks"] > 20, counter
