"""Notes: a small but complete app, ported from CUI's ``examples/notes.c``.

    python examples/notes.py
    python examples/notes.py --shot dev/out/notes.png

Split view, search, create, edit, pin and delete notes, with keyboard shortcuts
and a command palette.  On a phone the list and the editor take turns.
"""

from __future__ import annotations

from dataclasses import dataclass

import cui

from _common import ACCENT, BACKGROUND, SURFACE_MUTED, TEXT_MUTED, TRANSPARENT, main

MAX_NOTES = 64
TAGS = ["Personal", "Work", "Ideas"]
FILTERS = ["All", "Personal", "Work", "Ideas"]

COMMANDS = [
    cui.Command("New note", cui.Icon.SQUARE_PEN, "Notes", "Ctrl N"),
    cui.Command("Pin or unpin note", cui.Icon.BOOKMARK, "Notes", None),
    cui.Command("Delete note", cui.Icon.TRASH_2, "Notes", "Del"),
    cui.Command("Toggle dark mode", cui.Icon.MOON, "View", None),
]


@dataclass
class Note:
    title: str
    body: str = ""
    pinned: bool = False
    tag: int = 0


class State:
    def __init__(self) -> None:
        self.notes: list[Note] = []
        self.selected = 0
        self.query = ""
        self.split = 0.32
        self.palette = False
        self.confirm_delete = False
        self.dark = False
        self.filter = 0
        self.one_pane = False  # a phone: the list or the open note
        self.editing = False


# -- model -----------------------------------------------------------------


def matches(note: Note, query: str) -> bool:
    if not query:
        return True
    haystack = f"{note.title} {note.body}".lower()
    return query.lower() in haystack


def add_note(state: State, title: str, body: str, tag: int) -> None:
    if len(state.notes) >= MAX_NOTES:
        return
    state.notes.append(Note(title, body, False, tag))
    state.selected = len(state.notes) - 1
    state.editing = True


def delete_selected(state: State) -> None:
    if state.selected < 0 or state.selected >= len(state.notes):
        return
    del state.notes[state.selected]
    if state.selected >= len(state.notes):
        state.selected = len(state.notes) - 1


def preview_text(body: str) -> str:
    """One line of the note: its lines joined with a dot, list markers dropped."""
    if not body:
        return "No content"
    preview = ""
    for line in body.split("\n"):
        if len(preview) >= 152:
            break
        line = line.lstrip("-* ")
        if line:
            preview += ("  \u00b7  " if preview else "") + line
    return preview[:159]


def word_count(body: str) -> int:
    """A word has a letter or digit in it, so list dashes do not count."""
    words = 0
    in_word = False
    for char in body:
        if char.isspace():
            in_word = False
            continue
        if not in_word and char.isalnum():
            words += 1
            in_word = True
    return words


def export_note(ui: cui.UI, note: Note) -> None:
    name = f"{note.title or 'note'}.txt"
    path = cui.file_dialog(kind=cui.FileDialogKind.SAVE, title="Export note",
                           filter_name="Text", filter="txt", default_name=name)
    if not path:
        return
    try:
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(f"{note.title}\n\n{note.body}\n")
    except OSError:
        ui.toast("Could not write the file", tone=cui.Tone.DANGER)
    else:
        ui.toast("Note exported", description=path, tone=cui.Tone.SUCCESS)


# -- panes -----------------------------------------------------------------


def list_pane(ui: cui.UI, state: State) -> None:
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, bg=SURFACE_MUTED,
                   pad=12, gap=10):
        with ui.row(gap=8, pad_x=4, pad_top=4):
            ui.text("Notes", font=cui.MEDIUM, size=16, width=cui.Size.FILL, nowrap=True)
            if ui.icon_button(cui.Icon.SQUARE_PEN, tooltip="New note", shortcut="Ctrl N"):
                add_note(state, "Untitled", "", state.filter - 1 if state.filter > 0 else 0)
        typed = ui.search("q", value=state.query, placeholder="Search notes",
                          size=cui.ControlSize.SM)
        state.query = typed.text
        state.filter = ui.segmented("filter", FILTERS, index=state.filter,
                                    size=cui.ControlSize.SM, full_width=True)
        with ui.scroll(id="list", gap=2, fade_edges=True):
            shown = 0
            for pass_index in (0, 1):
                row = 0
                while row < len(state.notes):
                    note = state.notes[row]
                    index = row
                    row += 1
                    if (pass_index == 0) != note.pinned:
                        continue
                    if state.filter > 0 and note.tag != state.filter - 1:
                        continue
                    if not matches(note, state.query):
                        continue
                    with ui.id(index):
                        row_icon = cui.Icon.BOOKMARK if note.pinned else cui.Icon.FILE_TEXT
                        if ui.list_item(note.title or "Untitled",
                                        subtitle=preview_text(note.body),
                                        selected=state.selected == index,
                                        icon=row_icon):
                            state.selected = index
                            state.editing = True

                        def note_menu(ui: cui.UI, note: Note = note,
                                      index: int = index) -> None:
                            if ui.menu_item("Unpin" if note.pinned else "Pin to top",
                                            icon=cui.Icon.BOOKMARK):
                                note.pinned = not note.pinned
                            if ui.menu_item("Duplicate", icon=cui.Icon.COPY):
                                add_note(state, note.title, note.body, note.tag)
                            ui.menu_separator()
                            if ui.menu_item("Delete", icon=cui.Icon.TRASH_2, danger=True):
                                state.selected = index
                                state.confirm_delete = True

                        ui.context_menu("note-menu", body=note_menu)
                    shown += 1
            if shown == 0:
                ui.empty_state("No notes found", icon=cui.Icon.SEARCH,
                               description="Try another search or create a note.")


def editor_pane(ui: cui.UI, state: State) -> None:
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL,
                   pad_x=16 if state.one_pane else 40,
                   pad_y=16 if state.one_pane else 28, gap=16):
        if state.selected < 0 or state.selected >= len(state.notes):
            ui.spacer()
            if ui.empty_state("Nothing selected", icon=cui.Icon.NOTEBOOK_PEN,
                              description="Pick a note on the left or start a new one.",
                              action="New note"):
                add_note(state, "Untitled", "", 0)
            ui.spacer()
            return
        note = state.notes[state.selected]
        with ui.row(gap=8):
            if state.one_pane and ui.icon_button(cui.Icon.CHEVRON_LEFT, tooltip="All notes"):
                state.editing = False
            tone = (cui.Tone.INFO if note.tag == 1
                    else cui.Tone.VIOLET if note.tag == 2 else cui.Tone.NEUTRAL)
            ui.badge(TAGS[note.tag], tone=tone)
            ui.text("Pinned" if note.pinned else "", size=12, color=TEXT_MUTED,
                    nowrap=True, width=cui.Size.FILL)
            if ui.icon_button(cui.Icon.BOOKMARK,
                              tooltip="Unpin" if note.pinned else "Pin",
                              selected=note.pinned,
                              color=ACCENT if note.pinned else TRANSPARENT):
                note.pinned = not note.pinned

            def note_actions(ui: cui.UI, note: Note = note) -> None:
                for tag in range(3):
                    if ui.menu_item(TAGS[tag], icon=cui.Icon.TAG, checked=note.tag == tag):
                        note.tag = tag
                ui.menu_separator()
                if ui.menu_item("Export as text", icon=cui.Icon.DOWNLOAD):
                    export_note(ui, note)
                ui.menu_separator()
                if ui.menu_item("Delete note", icon=cui.Icon.TRASH_2, danger=True,
                                shortcut="Del"):
                    state.confirm_delete = True

            ui.menu("Note actions", body=note_actions, icon_only=True,
                    icon=cui.Icon.ELLIPSIS, placement=cui.Placement.BOTTOM_END)

        with ui.id(state.selected):
            typed = ui.text_input("title", value=note.title, placeholder="Title",
                                  size=cui.ControlSize.LG)
            note.title = typed.text
            typed = ui.textarea("body", value=note.body, placeholder="Start writing",
                                height=-1)
            note.body = typed.text
            ui.text(f"{word_count(note.body)} words  \u00b7  {len(note.body)} characters")


# -- frame -----------------------------------------------------------------


def frame(ui: cui.UI, state: State) -> None:
    if ui.shortcut(cui.Mod.PRIMARY, cui.Key.KEY_N):
        add_note(state, "Untitled", "", 0)
    if ui.shortcut(cui.Mod.PRIMARY, cui.Key.KEY_K):
        state.palette = True
    if not ui.wants_keyboard() and ui.key_pressed(cui.Key.KEY_DELETE) and state.notes:
        state.confirm_delete = True
    state.one_pane = ui.context.size[0] < 640

    with ui.box(width=cui.Size.FILL, height=cui.Size.FILL, bg=BACKGROUND):
        if not state.one_pane:
            split = ui.split("split", state.split, min_first=240, min_second=360)
            with split:
                list_pane(ui, state)
                split.next()
                editor_pane(ui, state)
            state.split = split.ratio
        elif state.editing and state.selected >= 0:
            editor_pane(ui, state)
        else:
            list_pane(ui, state)

    was_open = state.confirm_delete

    def dialog_body(ui: cui.UI) -> None:
        def footer(ui: cui.UI) -> None:
            if ui.button("Cancel"):
                state.confirm_delete = False
            if ui.button("Delete note", variant=cui.ButtonVariant.DANGER):
                delete_selected(state)
                state.confirm_delete = False
                ui.toast("Note deleted")

        ui.dialog_footer(footer)

    still_open = ui.dialog("Delete this note?", open=was_open,
                           description="The note will be removed permanently.",
                           width=380, body=dialog_body)
    state.confirm_delete = state.confirm_delete and still_open

    chosen, state.palette = ui.command_palette(COMMANDS, open=state.palette)
    if chosen == 0:
        add_note(state, "Untitled", "", 0)
    elif chosen == 1:
        if 0 <= state.selected < len(state.notes):
            note = state.notes[state.selected]
            note.pinned = not note.pinned
    elif chosen == 2:
        state.confirm_delete = True
    elif chosen == 3:
        state.dark = ui.get_theme_mode() != cui.ThemeMode.DARK
        ui.set_theme(cui.ThemeMode.DARK if state.dark else cui.ThemeMode.LIGHT)


def seed(state: State) -> None:
    add_note(state, "Launch checklist",
             "Ship the 1.0 release.\n\n- Final pass on docs\n- Record the demo video\n"
             "- Write the announcement post\n- Celebrate", 1)
    add_note(state, "Reading list",
             "The Design of Everyday Things\nA Pattern Language\n"
             "The Art of Computer Programming", 0)
    add_note(state, "App ideas",
             "A calm habit tracker with springy check marks. A tiny music player that "
             "lives in the menu bar.", 2)
    add_note(state, "Meeting notes",
             "Discussed the roadmap for Q1. Focus on accessibility, keyboard support "
             "and docs.", 1)
    state.notes[0].pinned = True
    state.selected = 0
    state.editing = False  # a phone opens on the list


if __name__ == "__main__":
    app_state = State()
    seed(app_state)
    raise SystemExit(main(frame, app_state, title="Notes", width=1100, height=720,
                          accent=cui.Accent.AMBER))
