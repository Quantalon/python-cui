"""Shared runner for the ported CUI examples.

Each example is a normal windowed app::

    python examples/todo.py

and the same frame code can render itself offscreen, which is what the tests
and the screenshots in the README use::

    python examples/todo.py --shot dev/out/todo.png

The offscreen path needs no window, display or GPU: CUI's software renderer
draws into memory and :meth:`cui.Context.screenshot` writes the PNG.
"""

from __future__ import annotations

import argparse
import os
import sys
from typing import Any, Callable

import cui


# The C examples spell these as macros (CUI_COLOR_BACKGROUND, ...); in Python
# the same values are theme tokens resolved by CUI at draw time.
BACKGROUND = cui.Color.token(cui.Token.BACKGROUND)
SURFACE = cui.Color.token(cui.Token.SURFACE)
SURFACE_RAISED = cui.Color.token(cui.Token.SURFACE_RAISED)
SURFACE_MUTED = cui.Color.token(cui.Token.SURFACE_MUTED)
FOREGROUND = cui.Color.token(cui.Token.FOREGROUND)
TEXT_SECONDARY = cui.Color.token(cui.Token.TEXT_SECONDARY)
TEXT_MUTED = cui.Color.token(cui.Token.TEXT_MUTED)
BORDER = cui.Color.token(cui.Token.BORDER)
BORDER_SUBTLE = cui.Color.token(cui.Token.BORDER_SUBTLE)
ACCENT = cui.Color.token(cui.Token.ACCENT)
ACCENT_FOREGROUND = cui.Color.token(cui.Token.ACCENT_FOREGROUND)
SUCCESS = cui.Color.token(cui.Token.SUCCESS)
WARNING = cui.Color.token(cui.Token.WARNING)
DANGER = cui.Color.token(cui.Token.DANGER)
INFO = cui.Color.token(cui.Token.INFO)
HOVER = cui.Color.token(cui.Token.HOVER)
SCRIM = cui.Color.token(cui.Token.SCRIM)
TRANSPARENT = cui.Color(0, 0, 0, 0)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a PYCUI example.")
    parser.add_argument("--shot", metavar="PNG", help="render offscreen to this PNG instead of opening a window")
    parser.add_argument("--frames", type=int, default=3, help="frames rendered before the screenshot (default: 3)")
    parser.add_argument("--dark", action="store_true", help="force the dark theme")
    parser.add_argument("--light", action="store_true", help="force the light theme")
    return parser.parse_args(argv)


def run(
    frame: Callable[..., None],
    state: Any,
    *,
    title: str,
    width: int,
    height: int,
    theme: int | None = None,
    accent: int | None = None,
    argv: list[str] | None = None,
    **desc: Any,
) -> int:
    """Run ``frame(ui, state)`` in a window, or render it to a PNG.

    ``theme`` and ``accent`` are the example's defaults; ``--dark`` / ``--light``
    override the theme.  Extra keyword arguments go to :class:`cui.App`.
    """
    args = parse_args(argv)
    if theme is None:
        theme = cui.ThemeMode.LIGHT
    if accent is None:
        accent = cui.Accent.NEUTRAL
    if args.dark:
        theme = cui.ThemeMode.DARK
    elif args.light:
        theme = cui.ThemeMode.LIGHT

    if args.shot:
        path = args.shot
        parent = os.path.dirname(os.path.abspath(path))
        if parent:
            os.makedirs(parent, exist_ok=True)
        renderer = cui.SoftwareRenderer()
        context = cui.Context.create(renderer=renderer, theme=theme, accent=accent)
        context.set_viewport(width, height, 1.0)
        ui = cui.UI(context)
        for _ in range(max(1, args.frames)):
            context.begin_frame()
            frame(ui, state)
            context.end_frame()
        context.screenshot(path)
        print(f"{context.draw_data()} -> {path}")
        return 0

    app = cui.App()
    app.run(lambda ui: frame(ui, state), title=title, width=width, height=height,
            theme=theme, accent=accent, **desc)
    return 0


def main(frame: Callable[..., None], state: Any, **options: Any) -> int:
    """Entry point for an example's ``__main__`` block."""
    return run(frame, state, argv=sys.argv[1:], **options)
