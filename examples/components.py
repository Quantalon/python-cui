"""A complete CUI screen in Python: render it offscreen to a PNG.

    python examples/components.py out.png [--dark]

It shows the shape of a PYCUI app: state in a plain class, one ``frame(ui)``
function built from the ``with``-style containers, and the CUI widgets doing
the drawing.
"""

from __future__ import annotations

import os
import sys

import cui


class State:
    def __init__(self) -> None:
        self.notify = True
        self.name = "Maya Okafor"
        self.fruit = 1
        self.tab = 0


def frame(ui: cui.UI, state: State) -> None:
    with ui.column(pad=24, gap=14, width=cui.Size.FILL, height=cui.Size.FILL):
        ui.heading("Account settings", level=2)
        ui.secondary("Manage your profile, notifications and billing.")

        with ui.row(gap=8):
            if ui.button("Save changes", variant=cui.ButtonVariant.PRIMARY, icon=cui.Icon.CHECK):
                ui.toast("Saved", tone=cui.Tone.SUCCESS)
            ui.button("Cancel")
            ui.button("Delete", variant=cui.ButtonVariant.DANGER, icon=cui.Icon.TRASH_2)

        with ui.row(gap=8):
            ui.badge("Active", tone=cui.Tone.SUCCESS, dot=True)
            ui.badge("Pending", tone=cui.Tone.WARNING)
            ui.badge("Failed", tone=cui.Tone.DANGER)

        with ui.card(gap=12):
            ui.label("Profile")
            state.name = ui.text_input("name", value=state.name, label="Name",
                                       placeholder="Your name").text
            state.fruit = ui.select("fruit", ["Apple", "Banana", "Cherry"],
                                    index=state.fruit, label="Favourite fruit")
            state.notify = ui.switch("Notifications", value=state.notify)

        state.tab = ui.tabs("tabs", ["Overview", "Activity", "Settings"], index=state.tab)


def render(path: str, dark: bool = False, size: tuple[int, int] = (560, 520)) -> cui.DrawData:
    sw = cui.SoftwareRenderer()
    theme = cui.ThemeMode.DARK if dark else cui.ThemeMode.LIGHT
    ctx = cui.Context.create(renderer=sw, theme=theme)
    ctx.set_viewport(*size, 1.0)
    ui = cui.UI(ctx)
    state = State()
    for _ in range(3):  # let the layout settle
        ctx.begin_frame()
        frame(ui, state)
        ctx.end_frame()
    ctx.screenshot(path)
    return ctx.draw_data()


def main(argv: list[str]) -> int:
    path = argv[1] if len(argv) > 1 else "components.png"
    parent = os.path.dirname(os.path.abspath(path))
    os.makedirs(parent, exist_ok=True)
    draw_data = render(path, dark="--dark" in argv)
    print(f"{draw_data} -> {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
