"""Tests for the hand-written canvas and chart wrappers."""

from __future__ import annotations

import pytest

import cui


def make_context(width: float = 420.0, height: float = 320.0):
    renderer = cui.SoftwareRenderer()
    context = cui.Context.create(renderer=renderer)
    context.set_viewport(width, height, 1.0)
    return context, cui.UI(context)


def test_canvas_runs_its_paint_callback_and_returns_a_rect():
    context, ui = make_context()
    seen: list[cui.Rect] = []

    def paint(rect: cui.Rect) -> None:
        seen.append(rect)
        ui.draw_rect(rect, cui.Color(20, 30, 40, 255))
        ui.draw_circle((rect.x + rect.w / 2, rect.y + rect.h / 2), 12,
                       cui.Color(200, 80, 60, 255))

    for _ in range(2):
        context.begin_frame()
        with ui.column(pad=16, width=cui.Size.FILL):
            result = ui.canvas("paint", 200, 80, paint)
        context.end_frame()

    assert seen, "the paint callback should run while the frame is drawn"
    assert isinstance(result, cui.CanvasResult)
    assert result.rect.w == pytest.approx(200)
    assert result.rect.h == pytest.approx(80)


def test_canvas_exception_is_re_raised_after_the_frame():
    context, ui = make_context()

    def paint(rect: cui.Rect) -> None:
        raise RuntimeError("paint failed")

    with pytest.raises(RuntimeError, match="paint failed"):
        context.begin_frame()
        ui.canvas("paint", 100, 50, paint)
        context.end_frame()


def test_charts_and_event_track_render_offscreen(tmp_path):
    context, ui = make_context(640.0, 520.0)
    events = [8.0, 10.75]
    selected = 1

    def frame() -> None:
        nonlocal selected
        with ui.column(pad=16, gap=10, width=cui.Size.FILL):
            ui.line_chart(
                "line",
                [cui.Series("This year", [1, 3, 2, 5, 4], color=cui.Color(80, 140, 220, 255))],
                labels=["a", "b", "c", "d", "e"],
                area=True,
                height=120,
            )
            ui.bar_chart("bar", [cui.Series("Count", [2, 4, 3])], height=100)
            annotations = [cui.ChartAnnotation(cui.AnnotationKind.Y, 0, 3, "3", None, False)]
            ui.dot_chart(
                "dots",
                [cui.DotSeries([0, 1, 2, 3, 2, 1], "level", True)],
                6,
                x_min=0,
                x_max=5,
                height=120,
                annotations=annotations,
            )
            ui.donut_chart("donut", [3, 2, 1], ["a", "b", "c"], height=120)
            track = ui.event_track("events", events, 8, 0, 24, selected=selected, step=0.25)
            selected = track.selected

        def paint(rect: cui.Rect) -> None:
            ui.draw_polygon([(rect.x, rect.y), (rect.x + 40, rect.y),
                             (rect.x + 20, rect.y + 30)], cui.Color(80, 140, 220, 255))
            ui.draw_polyline([(rect.x, rect.y), (rect.x + 40, rect.y + 20)], 2,
                             cui.Color(200, 80, 60, 255))

        ui.canvas("poly", 60, 40, paint)

    for _ in range(2):
        context.begin_frame()
        frame()
        context.end_frame()

    path = tmp_path / "charts.png"
    context.screenshot(str(path))
    assert path.stat().st_size > 1000
    assert selected == 1


def test_font_scale_round_trips():
    context, _ui = make_context()
    context.begin_frame()
    context.font_scale = 1.15
    assert context.font_scale == pytest.approx(1.15, rel=1e-4)
    context.end_frame()
