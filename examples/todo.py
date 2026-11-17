"""A to-do list, ported from CUI's ``examples/todo.c``.

    python examples/todo.py
    python examples/todo.py --shot dev/out/todo.png

It shows the things most apps need: your own data as the state, a list that
grows, a filter, a confirmation dialog and saving to a file.
"""

from __future__ import annotations

from dataclasses import dataclass

import cui

from _common import BACKGROUND, main

MAX_TASKS = 200
PATH = "todo.txt"


@dataclass
class Task:
    title: str
    done: bool = False


class State:
    def __init__(self) -> None:
        self.tasks: list[Task] = []
        self.draft = ""
        self.filter = 0  # 0 all, 1 open, 2 done
        self.confirm_clear = False
        self.path = PATH

    # -- persistence: one task a line, "x Buy milk" or "- Buy milk" --------

    def load(self) -> bool:
        try:
            with open(self.path, encoding="utf-8") as handle:
                for line in handle:
                    line = line.rstrip("\r\n")
                    if len(line) < 3:
                        continue
                    if len(self.tasks) < MAX_TASKS:
                        self.tasks.append(Task(line[2:], line[0] == "x"))
        except OSError:
            return False
        return True

    def save(self) -> None:
        try:
            with open(self.path, "w", encoding="utf-8") as handle:
                for task in self.tasks:
                    handle.write(("x " if task.done else "- ") + task.title + "\n")
        except OSError:
            pass

    def seed(self) -> None:
        self.tasks = [
            Task("Read the CUI tutorial"),
            Task("Port an example to Python"),
            Task("Ship it", done=True),
        ]

    # -- actions -----------------------------------------------------------

    def add_task(self) -> bool:
        if not self.draft or len(self.tasks) >= MAX_TASKS:
            return False
        self.tasks.append(Task(self.draft))
        self.draft = ""
        return True


def frame(ui: cui.UI, state: State) -> None:
    done = sum(1 for task in state.tasks if task.done)
    changed = False

    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL,
                   align=cui.Align.CENTER, bg=BACKGROUND):
        with ui.column(width=cui.Size.FILL, max_width=560, height=cui.Size.FILL,
                       pad=24, gap=16):
            with ui.row(gap=12, align=cui.Align.END):
                ui.heading("To do", level=2)
                ui.spacer()
                ui.text(f"{len(state.tasks) - done} open, {done} done")

            # Add: Enter in the field or the button.
            with ui.row(gap=8):
                typed = ui.text_input("new-task", value=state.draft,
                                      placeholder="Add a task", width=cui.Size.FILL)
                state.draft = typed.text
                add = ui.button("Add", variant=cui.ButtonVariant.PRIMARY,
                                icon=cui.Icon.PLUS, disabled=not state.draft)
                if typed.submitted or add:
                    changed |= state.add_task()

            with ui.row(gap=8, align=cui.Align.CENTER):
                state.filter = ui.segmented("filter", ["All", "Open", "Done"], index=state.filter)
                ui.spacer()
                if ui.button("Clear done", variant=cui.ButtonVariant.GHOST, disabled=done == 0):
                    state.confirm_clear = True

            # The list: each row gets an id scope, so two tasks may share a title.
            remove = -1
            shown = 0
            with ui.scroll(id="tasks", width=cui.Size.FILL, height=cui.Size.FILL, gap=2):
                for index, task in enumerate(state.tasks):
                    if (state.filter == 1 and task.done) or (state.filter == 2 and not task.done):
                        continue
                    shown += 1
                    with ui.id(index):
                        with ui.row(gap=8, align=cui.Align.CENTER, width=cui.Size.FILL):
                            task.done = ui.checkbox(task.title, value=task.done)
                            ui.spacer()
                            if ui.icon_button(cui.Icon.X, tooltip="Delete",
                                              variant=cui.ButtonVariant.GHOST,
                                              size=cui.ControlSize.SM):
                                remove = index
                if not shown:
                    ui.empty_state(
                        "Nothing here" if state.tasks else "No tasks yet",
                        icon=cui.Icon.LIST_CHECKS,
                        description=("No task matches this filter." if state.tasks
                                     else "Type one above and press Enter."),
                    )
            if remove >= 0:  # after the loop, so the rows stay in step with the array
                del state.tasks[remove]
                changed = True

    # A dialog is drawn while its bool is true; closing it sets the bool to false.
    was_open = state.confirm_clear

    def dialog_body(ui: cui.UI) -> None:
        def footer(ui: cui.UI) -> None:
            if ui.button("Cancel"):
                state.confirm_clear = False
            if ui.button("Clear", variant=cui.ButtonVariant.DANGER):
                state.tasks = [task for task in state.tasks if not task.done]
                state.confirm_clear = False
                ui.toast("Finished tasks cleared")

        ui.dialog_footer(footer)

    still_open = ui.dialog(
        "Clear finished tasks?",
        open=was_open,
        description="They are removed from the list and from the file.",
        width=380,
        body=dialog_body,
    )
    state.confirm_clear = state.confirm_clear and still_open

    if changed:
        state.save()


if __name__ == "__main__":
    app_state = State()
    if not app_state.load():
        app_state.seed()
    raise SystemExit(main(frame, app_state, title="To do", width=520, height=640))
