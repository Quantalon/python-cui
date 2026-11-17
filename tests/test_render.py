"""Rendering, determinism and PNG output."""

from __future__ import annotations

import os

import cui

from conftest import frame, non_background, pixels


def build(ui: cui.UI) -> None:
    with ui.column(pad=20, gap=10, width=cui.Size.FILL, height=cui.Size.FILL):
        ui.heading("Account settings", level=2)
        ui.secondary("Manage your profile, notifications and billing.")
        with ui.row(gap=8):
            ui.button("Save", variant=cui.ButtonVariant.PRIMARY, icon=cui.Icon.CHECK)
            ui.button("Cancel")
            ui.button("Delete", variant=cui.ButtonVariant.DANGER, icon=cui.Icon.TRASH_2)
        with ui.row(gap=8):
            ui.badge("Active", tone=cui.Tone.SUCCESS, dot=True)
            ui.badge("Failed", tone=cui.Tone.DANGER)
            ui.kbd("Ctrl K")
            ui.code("cui_button()")
        ui.switch("Notifications", value=True)
        ui.text_input("name", value="Maya", label="Name")
        ui.select("fruit", ["Apple", "Banana"], index=1)


def test_render_is_not_blank(ctx, renderer):
    frame(ctx, build)
    image = pixels(ctx, renderer)
    assert len(image) == 400 * 300 * 4
    assert non_background(image) > 5000


def test_render_is_deterministic(renderer):
    first = _render_once(renderer)
    second = _render_once(renderer)
    assert first == second


def _render_once(renderer) -> bytes:
    ctx = cui.Context.create(renderer=renderer)
    ctx.set_viewport(400, 300, 1)
    frame(ctx, build, count=3)
    image = pixels(ctx, renderer)
    ctx.destroy()
    return image


def test_png_is_written(ctx, renderer, tmp_path):
    frame(ctx, build)
    path = os.path.join(tmp_path, "shot.png")
    ctx.screenshot(path)
    with open(path, "rb") as handle:
        assert handle.read(8) == b"\x89PNG\r\n\x1a\n"
    assert os.path.getsize(path) > 1000


def test_viewport_scale_changes_pixel_size(renderer):
    ctx = cui.Context.create(renderer=renderer)
    ctx.set_viewport(200, 100, 2.0)
    frame(ctx, build)
    dd = ctx.draw_data()
    assert (dd.width_px, dd.height_px) == (400, 200)
    ctx.destroy()


def test_theme_changes_pixels(renderer):
    light = _render_theme(renderer, cui.ThemeMode.LIGHT)
    dark = _render_theme(renderer, cui.ThemeMode.DARK)
    assert light != dark


def _render_theme(renderer, theme) -> bytes:
    ctx = cui.Context.create(renderer=renderer, theme=theme)
    ctx.set_viewport(200, 100, 1)
    def simple(ui):
        with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, bg=cui.Color.token(cui.Token.BACKGROUND)):
            ui.text("theme")
    frame(ctx, simple)
    image = pixels(ctx, renderer)
    ctx.destroy()
    return image


def test_many_components_stay_fast(ctx):
    import time

    ui = cui.UI(ctx)

    def heavy(ui):
        with ui.column(pad=8, gap=4):
            for _ in range(200):
                ui.text("a line of text")

    ctx.begin_frame()
    heavy(ui)
    ctx.end_frame()
    start = time.perf_counter()
    for _ in range(20):
        ctx.begin_frame()
        heavy(ui)
        ctx.end_frame()
    elapsed = time.perf_counter() - start
    # 200 components x 20 frames; the wrapper layer must not dominate.
    assert elapsed < 2.0
