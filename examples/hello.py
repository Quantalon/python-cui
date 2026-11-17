"""The smallest PYCUI app, ported from CUI's ``examples/hello.c``.

    python examples/hello.py
    python examples/hello.py --shot dev/out/hello.png

A column, a heading, a switch and a button: the state lives in a plain Python
object and the frame function reads and writes it.
"""

from __future__ import annotations

import cui

from _common import main


class State:
    def __init__(self) -> None:
        self.notifications = True
        self.clicks = 0


def frame(ui: cui.UI, state: State) -> None:
    with ui.column(pad=32, gap=16, width=cui.Size.FILL):
        ui.heading("Hello, CUI", level=2)
        ui.secondary("A native window, a few components and no dependencies.")
        state.notifications = ui.switch("Notifications", value=state.notifications)
        with ui.row(gap=8):
            if ui.button("Click me", variant=cui.ButtonVariant.PRIMARY):
                state.clicks += 1
            ui.text(f"Clicked {state.clicks} times")


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Hello", width=420, height=300))
