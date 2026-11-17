"""Shared fixtures: an offscreen CUI context and a way to render it."""

from __future__ import annotations

import pytest

import cui


@pytest.fixture
def renderer():
    return cui.SoftwareRenderer()


@pytest.fixture
def ctx(renderer):
    context = cui.Context.create(renderer=renderer)
    context.set_viewport(400, 300, 1.0)
    yield context
    context.destroy()


@pytest.fixture
def ui(ctx):
    return cui.UI(ctx)


def frame(ctx, build, count=2, dt=1 / 60.0):
    """Run ``build(ui)`` for a few frames and return the last draw data."""
    ui = cui.UI(ctx)
    for _ in range(count):
        ctx.begin_frame(dt)
        build(ui)
        ctx.end_frame()
    return ctx.draw_data()


def pixels(ctx, renderer):
    return renderer.render(ctx.draw_data())


def non_background(pixels: bytes) -> int:
    """Count pixels that differ from the frame's most common colour."""
    counts: dict[bytes, int] = {}
    for index in range(0, len(pixels), 4):
        chunk = pixels[index : index + 4]
        counts[chunk] = counts.get(chunk, 0) + 1
    background = max(counts, key=counts.get)
    return len(pixels) // 4 - counts[background]
