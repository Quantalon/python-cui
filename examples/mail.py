"""A three pane mail inbox, ported from CUI's ``examples/mail.c``.

    python examples/mail.py
    python examples/mail.py --shot dev/out/mail.png

Folders, search, a reading pane and a compose dialog.  Narrower windows drop
to two panes with the folders in a drawer, and a phone shows one pane at a
time.  Each list row paints its own selection/hover fill and hairline with
``ui.canvas`` and the immediate drawing helpers, as the C ``paint_row`` does.
"""

from __future__ import annotations

from dataclasses import dataclass

import cui

from _common import (
    ACCENT,
    BACKGROUND,
    BORDER_SUBTLE,
    HOVER,
    SURFACE_MUTED,
    TEXT_MUTED,
    TEXT_SECONDARY,
    TRANSPARENT,
    WARNING,
    main,
)

ACTIVE = cui.Color.token(cui.Token.ACTIVE)


@dataclass
class Message:
    """One mail row, the fields of the C ``message`` struct."""

    sender: str
    email: str
    subject: str
    preview: str
    time: str
    body: str
    folder: int  # 0 inbox, 1 starred, 2 sent, 3 archive
    unread: bool
    starred: bool
    label: int  # -1 none, else tone


class State:
    def __init__(self) -> None:
        self.folder = 0
        self.selected = 0
        self.query = ""
        self.split1 = 0.2
        self.split2 = 0.38
        self.compose = False
        self.to = ""
        self.subject = ""
        self.body = ""
        self.dark = False
        self.panes = 3  # 3, 2 or 1, from the window width
        self.reading = False  # one pane: the message is open
        self.drawer = False  # folders in a drawer below three panes
        self.hover: dict[int, bool] = {}  # per row, the C canvas bool state
        self.messages = [
            Message(
                "Jonas Berg", "jonas@northlight.io",
                "Review of the onboarding flow",
                "I went through all six screens on a 13 inch laptop. Step three scrolls before the button is visible.",
                "9:41",
                "Hi Maya,\n\nI went through all six screens on a 13 inch laptop. Step three scrolls before the button is visible, and the skip link reads like an error.\n\nCould we look at it together on Thursday at 10?\n\nJonas",
                0, True, True, cui.Tone.INFO,
            ),
            Message(
                "Priya Nair", "priya@harbor.dev",
                "Invoice 2024-118",
                "The October invoice is attached. Payment terms are 30 days as usual.",
                "8:15",
                "Hi,\n\nThe October invoice is attached. Payment terms are 30 days as usual. Let me know if the purchase order number needs to change.\n\nPriya",
                0, True, False, -1,
            ),
            Message(
                "Tomas Rivera", "tomas@kiln.app",
                "Export is slow for large projects",
                "A 900 file project takes about four minutes to export on my machine.",
                "Yesterday",
                "A 900 file project takes about four minutes to export on my machine, most of it in the thumbnail step. I attached a trace.\n\nTomas",
                0, False, True, cui.Tone.WARNING,
            ),
            Message(
                "Lena Fischer", "lena@fischer.dev",
                "Re: Release notes draft",
                "Looks good. I tightened the second paragraph and fixed two links.",
                "Yesterday",
                "Looks good. I tightened the second paragraph and fixed two links that pointed at the old docs.\n\nLena",
                0, False, False, cui.Tone.SUCCESS,
            ),
            Message(
                "Aiko Tanaka", "aiko@tanaka.design",
                "Icons for the settings page",
                "Here are the twelve icons at 16 and 20 px, outline only.",
                "Mon",
                "Here are the twelve icons at 16 and 20 px, outline only, on the same 1.5 px stroke as the rest of the set.\n\nAiko",
                0, False, False, cui.Tone.VIOLET,
            ),
            Message(
                "Sam Whitfield", "sam@whitfield.co",
                "Office closed on Friday",
                "The building is closed for maintenance. Work from home if you can.",
                "Mon",
                "The building is closed for maintenance on Friday. Work from home if you can; the server room stays reachable over the VPN.\n\nSam",
                3, False, True, -1,
            ),
        ]
        # main() in the C file opens with the first message already read.
        self.messages[0].unread = False


def match(message: Message, query: str) -> bool:
    """The C ``match``: a case-insensitive substring of sender, subject, preview."""
    if not query:
        return True
    hay = f"{message.sender} {message.subject} {message.preview}".lower()
    return query.lower() in hay


def in_folder(message: Message, folder: int) -> bool:
    if folder == 1:
        return message.starred
    return message.folder == folder


def folders(ui: cui.UI, state: State, drawer: bool) -> None:
    names = ["Inbox", "Starred", "Sent", "Archive"]
    icons = [cui.Icon.INBOX, cui.Icon.STAR, cui.Icon.SEND, cui.Icon.ARCHIVE]
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL,
                   bg=TRANSPARENT if drawer else SURFACE_MUTED,
                   pad=0 if drawer else 12, gap=2):
        with ui.row(pad_x=6, pad_bottom=12, gap=10):
            ui.avatar("Maya Okafor", size=28)
            with ui.column(gap=0, width=cui.Size.FILL):
                ui.text("Maya Okafor", font=cui.MEDIUM, nowrap=True)
                ui.text("maya@fieldwork.studio", size=12, color=TEXT_SECONDARY, nowrap=True)
        if ui.button("Compose", variant=cui.ButtonVariant.PRIMARY,
                     icon=cui.Icon.SQUARE_PEN, full_width=True):
            state.compose = True
            state.drawer = False
        ui.gap(10)
        for f in range(4):
            unread = sum(1 for m in state.messages if in_folder(m, f) and m.unread)
            badge = str(unread) if unread else None
            if ui.nav_item(names[f], icon=icons[f], selected=state.folder == f,
                           badge=badge):
                state.folder = f
                state.selected = -1
                state.drawer = False
                state.reading = False
        ui.spacer()
        ui.nav_section("Labels")
        labels = ["Work", "Personal", "Urgent"]
        tones = [cui.Tone.INFO, cui.Tone.VIOLET, cui.Tone.WARNING]
        for label, tone in zip(labels, tones):
            with ui.row(gap=10, pad_x=10, pad_y=6):
                ui.badge(label, tone=tone)


def paint_row(ui: cui.UI, rect: cui.Rect, hovered: bool, selected: bool,
              last: bool) -> None:
    """The C ``paint_row``: a quiet fill when selected or hovered, a hairline between."""
    if selected:
        ui.draw_rect(rect, ACTIVE, radius=10)
    elif hovered:
        ui.draw_rect(rect, HOVER, radius=10)
    elif not last:
        ui.draw_rect(cui.Rect(rect.x + 26, rect.y + rect.h - 1,
                              rect.w - 38, 1), BORDER_SUBTLE)


def message_list(ui: cui.UI, state: State) -> None:
    names = ["Inbox", "Starred", "Sent", "Archive"]
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, gap=10, pad=12):
        with ui.row(pad_x=4, pad_top=4, gap=6, width=cui.Size.FILL):
            if state.panes < 3 and ui.icon_button(cui.Icon.MENU, tooltip="Folders"):
                state.drawer = True
            with ui.box(width=cui.Size.FILL):
                ui.heading(names[state.folder], 4)
            if state.panes < 3 and ui.icon_button(cui.Icon.SQUARE_PEN, tooltip="Compose"):
                state.compose = True
        found = ui.search("search", value=state.query, placeholder="Search mail",
                          size=cui.ControlSize.SM)
        state.query = found.text
        with ui.scroll(id="list", gap=0, fade_edges=True):
            shown = 0
            for i, message in enumerate(state.messages):
                if not in_folder(message, state.folder) or not match(message, state.query):
                    continue
                shown += 1
                with ui.id(i):
                    following = i + 1
                    while following < len(state.messages) and (
                        not in_folder(state.messages[following], state.folder)
                        or not match(state.messages[following], state.query)
                    ):
                        following += 1
                    hover = state.hover.get(i, False)
                    last = (following >= len(state.messages)
                            or state.selected == following)
                    with ui.box(dir=cui.Dir.STACK, width=cui.Size.FILL):
                        def paint(rect: cui.Rect, hovered: bool = hover,
                                  selected: bool = state.selected == i,
                                  is_last: bool = last) -> None:
                            paint_row(ui, rect, hovered, selected, is_last)

                        result = ui.canvas("bg", cui.Size.FILL, cui.Size.FILL, paint)
                        # The C code reads the previous frame's hover for this
                        # frame's fill, then stores what the canvas reported.
                        state.hover[i] = result.hovered
                        if result.clicked:
                            state.selected = i
                            message.unread = False
                            state.reading = True
                        # Every row keeps the dot's gutter, so names line up read or unread.
                        with ui.row(width=cui.Size.FILL, pad_y=12, pad_right=12,
                                    align=cui.Align.START):
                            with ui.box(width=cui.Size.px(26), pad_top=6,
                                        align=cui.Align.CENTER):
                                if message.unread:
                                    with ui.box(width=cui.Size.px(7),
                                                height=cui.Size.px(7), radius=4,
                                                bg=ACCENT):
                                        pass
                            with ui.column(gap=3, width=cui.Size.FILL):
                                with ui.row(gap=8, width=cui.Size.FILL):
                                    ui.text(message.sender,
                                            font=cui.MEDIUM if message.unread else cui.BODY,
                                            nowrap=True, width=cui.Size.FILL)
                                    ui.text(message.time, size=12, color=TEXT_MUTED,
                                            nowrap=True)
                                ui.text(message.subject, font=cui.MEDIUM, size=12.5,
                                        nowrap=True)
                                ui.text(message.preview, size=12, color=TEXT_SECONDARY,
                                        nowrap=True)

                    def row_menu(ui: cui.UI, message: Message = message) -> None:
                        if ui.menu_item("Mark as read" if message.unread else "Mark as unread",
                                        icon=cui.Icon.MAIL):
                            message.unread = not message.unread
                        if ui.menu_item("Unstar" if message.starred else "Star",
                                        icon=cui.Icon.STAR):
                            message.starred = not message.starred
                        if ui.menu_item("Archive", icon=cui.Icon.ARCHIVE):
                            message.folder = 3

                    ui.context_menu("row-menu", body=row_menu)
            if not shown:
                ui.empty_state("No messages", icon=cui.Icon.INBOX,
                               description="You are all caught up.")


def reading_pane(ui: cui.UI, state: State) -> None:
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL):
        if state.selected < 0:
            with ui.column(width=cui.Size.FILL, height=cui.Size.FILL,
                           justify=cui.Justify.CENTER):
                ui.empty_state("No message selected", icon=cui.Icon.MAIL,
                               description="Choose a message to read it here.")
            return
        message = state.messages[state.selected]
        with ui.row(gap=4, pad_x=12 if state.panes == 1 else 20, pad_y=10):
            if state.panes == 1 and ui.icon_button(cui.Icon.CHEVRON_LEFT,
                                                   tooltip="Back to the list"):
                state.reading = False
            if ui.icon_button(cui.Icon.ARCHIVE, tooltip="Archive", shortcut="E"):
                message.folder = 3
                state.selected = -1
                ui.toast("Archived", action="Undo")
            ui.icon_button(cui.Icon.TRASH_2, tooltip="Delete")
            if ui.icon_button(cui.Icon.STAR,
                              tooltip="Unstar" if message.starred else "Star",
                              selected=message.starred,
                              color=WARNING if message.starred else TRANSPARENT):
                message.starred = not message.starred
            ui.spacer()
            if ui.button("Reply", icon=cui.Icon.UNDO_2, size=cui.ControlSize.SM):
                state.compose = True
                state.to = message.email
                state.subject = f"Re: {message.subject}"
        ui.separator()
        if state.selected < 0:
            return
        with ui.scroll(id="reader", pad=16 if state.panes == 1 else 28, gap=18,
                       fade_edges=True):
            ui.heading(message.subject, 3)
            with ui.row(gap=12):
                ui.avatar(message.sender, size=36)
                with ui.column(gap=1, width=cui.Size.FILL):
                    ui.text(message.sender, font=cui.MEDIUM, nowrap=True)
                    ui.text(message.email, size=12, color=TEXT_SECONDARY, nowrap=True)
                if message.label >= 0:
                    label = ("Work" if message.label == cui.Tone.INFO
                             else "Personal" if message.label == cui.Tone.VIOLET
                             else "Urgent" if message.label == cui.Tone.WARNING
                             else "Merged")
                    ui.badge(label, tone=message.label)
                ui.text(message.time, size=12, color=TEXT_MUTED, nowrap=True)
            ui.text(message.body, line_height=1.6)


def frame(ui: cui.UI, state: State) -> None:
    if not ui.wants_keyboard() and ui.key_pressed(cui.Key.KEY_C):
        state.compose = True
    width = ui.context.size[0]
    state.panes = 1 if width < 720 else 2 if width < 1100 else 3
    if state.panes == 3:
        state.drawer = False
    with ui.box(width=cui.Size.FILL, height=cui.Size.FILL, bg=BACKGROUND):
        if state.panes == 3:
            with ui.split("outer", state.split1, min_first=200, min_second=600) as outer:
                folders(ui, state, False)
                outer.next()
                with ui.split("inner", state.split2, min_first=280, min_second=320) as inner:
                    message_list(ui, state)
                    inner.next()
                    reading_pane(ui, state)
                state.split2 = inner.ratio
            state.split1 = outer.ratio
        elif state.panes == 2:
            with ui.split("inner", state.split2, min_first=260, min_second=320) as inner:
                message_list(ui, state)
                inner.next()
                reading_pane(ui, state)
            state.split2 = inner.ratio
        elif state.reading and state.selected >= 0:
            reading_pane(ui, state)
        else:
            message_list(ui, state)

    was_open = state.drawer

    def drawer_body(ui: cui.UI) -> None:
        folders(ui, state, True)

    still_open = ui.sheet("Mail", open=was_open, side=cui.Side.LEFT, size=280,
                          body=drawer_body)
    state.drawer = state.drawer and still_open

    was_open = state.compose

    def compose_body(ui: cui.UI) -> None:
        result = ui.text_input("to", value=state.to, label="To",
                               icon=cui.Icon.AT_SIGN, autofocus=True)
        state.to = result.text
        result = ui.text_input("subject", value=state.subject, label="Subject")
        state.subject = result.text
        result = ui.textarea("body", value=state.body, height=180,
                             placeholder="Write your message")
        state.body = result.text

        def footer(ui: cui.UI) -> None:
            if ui.button("Discard", variant=cui.ButtonVariant.GHOST):
                state.compose = False
                state.to = state.subject = state.body = ""
            if ui.button("Send", variant=cui.ButtonVariant.PRIMARY,
                         icon=cui.Icon.SEND, disabled=not state.to):
                state.compose = False
                ui.toast("Message sent",
                         description=state.subject if state.subject else "No subject",
                         tone=cui.Tone.SUCCESS)
                state.to = state.subject = state.body = ""

        ui.dialog_footer(footer)

    still_open = ui.dialog("New message", open=was_open, width=560,
                           body=compose_body)
    state.compose = state.compose and still_open


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Mail", width=1280, height=800,
                          theme=cui.ThemeMode.LIGHT, accent=cui.Accent.BLUE))
