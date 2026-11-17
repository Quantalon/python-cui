"""Context and renderer lifetime."""

from __future__ import annotations

import threading

import pytest

import cui


def test_create_and_destroy():
    sw = cui.SoftwareRenderer()
    ctx = cui.Context.create(renderer=sw)
    ctx.set_viewport(200, 100, 1.0)
    assert ctx.size == (200, 100)
    assert repr(ctx).startswith("<cui.Context")
    ctx.destroy()
    assert "destroyed" in repr(ctx)


def test_use_after_destroy_raises():
    sw = cui.SoftwareRenderer()
    ctx = cui.Context.create(renderer=sw)
    ctx.destroy()
    with pytest.raises(RuntimeError):
        ctx.begin_frame()


def test_wrong_thread_is_rejected():
    sw = cui.SoftwareRenderer()
    ctx = cui.Context.create(renderer=sw)
    errors = []

    def use_from_another_thread():
        try:
            ctx.begin_frame()
        except RuntimeError as exc:  # pragma: no branch - the happy path is the bug
            errors.append(str(exc))

    thread = threading.Thread(target=use_from_another_thread)
    thread.start()
    thread.join()
    assert errors and "thread" in errors[0]
    ctx.destroy()


def test_needs_renderer():
    with pytest.raises(TypeError):
        cui.Context.create()


def test_frame_counters(ctx):
    ctx.begin_frame()
    ctx.end_frame()
    ctx.begin_frame()
    ctx.end_frame()
    assert ctx.frame_count >= 2
    assert ctx.time >= 0.0
    assert isinstance(ctx.needs_redraw(), bool)


def test_draw_data_is_reported(ctx):
    ctx.begin_frame()
    with cui.UI(ctx).column(pad=8):
        cui.UI(ctx).heading("Hi")
    ctx.end_frame()
    dd = ctx.draw_data()
    assert dd.width_px == 400
    assert dd.height_px == 300
    assert dd.vertex_count > 0
    assert dd.command_count > 0
    assert dd.font_atlas != 0


def test_software_renderer_render_to_buffer(ctx):
    ctx.begin_frame()
    with cui.UI(ctx).column():
        cui.UI(ctx).text("hello")
    ctx.end_frame()
    buffer = bytearray(400 * 300 * 4)
    sw = cui.SoftwareRenderer()
    sw.render_to(ctx.draw_data(), buffer)
    assert non_zero(buffer)


def non_zero(buffer) -> bool:
    return any(buffer)
