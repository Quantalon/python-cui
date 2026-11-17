"""Value conversion, string handling and the keep-alive rules."""

from __future__ import annotations

import pytest

import cui
from cui import _api
from cui._types import Color, Size, TextFlags


def test_color_forms():
    assert Color.rgb(0x112233) == (0x11, 0x22, 0x33, 255)
    assert Color.rgba(0x11223344) == (0x11, 0x22, 0x33, 0x44)
    assert Color(1, 2, 3).with_alpha(9) == (1, 2, 3, 9)
    assert Color.token(cui.Token.ACCENT).is_token
    assert not Color(1, 2, 3).is_token
    assert Color(1, 2, 3, 4).packed == 0x01020304


def test_size_forms():
    assert Size.FILL == (cui.SizeKind.GROW, 1.0)
    assert Size.fit() == (cui.SizeKind.FIT, 0.0)
    assert Size.px(12) == (cui.SizeKind.FIXED, 12)
    assert Size.percent(50) == (cui.SizeKind.PERCENT, 50)
    assert Size.grow(2) == (cui.SizeKind.GROW, 2)


def test_color_arguments_accept_all_forms(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column():
        ui.text("int", color=0xFF0000)
        ui.text("tuple", color=(1, 2, 3))
        ui.text("color", color=Color(1, 2, 3))
        ui.text("token", color=Color.token(cui.Token.DANGER))
        ui.text("none", color=None)
    ctx.end_frame()


def test_size_arguments_accept_points_and_sizes(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column(width=Size.FILL):
        ui.text("a")
        with ui.card(width=200, height=Size.px(50)):
            ui.text("b")
    ctx.end_frame()


def test_unicode_and_emoji_survive(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column():
        ui.heading("中文标题 — OK")
        ui.text(cui.Icon.PLUS + " New project")
        ui.text("emoji: \N{ROCKET}")
    ctx.end_frame()


def test_embedded_nul_is_rejected(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with pytest.raises(ValueError):
        ui.text("bad\x00string")


def test_long_text_round_trips(renderer):
    ctx = cui.Context.create(renderer=renderer)
    ctx.set_viewport(400, 300, 1)
    long_text = "é" * 4000
    ctx.begin_frame()
    result = _api.input(ctx, "long", text=long_text)
    ctx.end_frame()
    assert result.text == long_text
    ctx.destroy()


def test_text_input_keeps_its_buffer_across_frames(renderer):
    ctx = cui.Context.create(renderer=renderer)
    ctx.set_viewport(400, 300, 1)
    seen = []
    for _ in range(3):
        ctx.begin_frame()
        result = _api.input(ctx, "name", text="Maya")
        ctx.end_frame()
        seen.append(result.text)
    assert seen == ["Maya", "Maya", "Maya"]
    ctx.destroy()


def test_text_result_flags():
    result = cui.TextResult("x", TextFlags.CHANGED | TextFlags.SUBMITTED)
    assert result.changed and result.submitted
    assert not result.focused and not result.blurred
    assert not cui.TextResult("").changed


def test_string_array_and_numbers(ctx):
    ctx.begin_frame()
    with cui.UI(ctx).column():
        assert _api.tabs(ctx, "tabs", ["One", "Two"], index=1)[1] == 1
        _api.sparkline(ctx, [1.0, 2.0, 3.0, 2.0, 0.5], 120.0, 24.0, Color(20, 20, 20))
    ctx.end_frame()


def test_none_strings_are_rejected(ctx):
    """A required string is not nullable: CUI would read a NULL pointer."""
    ctx.begin_frame()
    with pytest.raises(TypeError):
        _api.text(ctx, None)
    with pytest.raises(TypeError):
        _api.button(ctx, None)
    ctx.end_frame()


def test_value_structs_come_back(ctx):
    ctx.begin_frame()
    assert isinstance(_api.viewport_size(ctx), cui.Vec2)
    assert isinstance(_api.date_today(), cui.Date)
    ctx.end_frame()


def test_out_parameters_are_returned(ctx):
    ctx.begin_frame()
    changed, value = _api.switch(ctx, "notify", value=True)
    assert value is True
    assert changed is False  # nothing happened without input
    changed, index = _api.select(ctx, "pick", ["a", "b"], index=1)
    assert index == 1
    ctx.end_frame()
