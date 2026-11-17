"""Issue tracker, ported from CUI's ``examples/tracker.c``.

    python examples/tracker.py
    python examples/tracker.py --shot dev/out/tracker.png

Grouped issue list with custom status and priority glyphs and a detail pane
with properties and activity.  Dark by default.  Narrower windows open the
detail in a sheet, and a phone keeps the sidebar in a drawer.
"""

from __future__ import annotations

import math
from typing import NamedTuple

import cui

from _common import (
    BACKGROUND,
    SURFACE,
    SURFACE_MUTED,
    TEXT_MUTED,
    TEXT_SECONDARY,
    TRANSPARENT,
    main,
)

ST_BACKLOG, ST_TODO, ST_PROGRESS, ST_REVIEW, ST_DONE = range(5)
PRI_NONE, PRI_LOW, PRI_MEDIUM, PRI_HIGH, PRI_URGENT = range(5)
TAU = 6.2831853


class Issue(NamedTuple):
    key: str
    title: str
    assignee: str
    date: str
    status: int
    priority: int
    labels: tuple[str | None, str | None]
    label_tones: tuple[int, int]


ISSUES = (
    Issue("ENG-214", "Text input drops the last character on fast typing", "Maya Okafor", "Nov 6",
          ST_PROGRESS, PRI_URGENT, ("Bug", "Input"), (cui.Tone.DANGER, cui.Tone.NEUTRAL)),
    Issue("ENG-209", "Spring animations for popover placement flips", "Jonas Berg", "Nov 8",
          ST_PROGRESS, PRI_HIGH, ("Motion", None), (cui.Tone.VIOLET, 0)),
    Issue("ENG-205", "Software renderer: SIMD path for text quads", "Lena Fischer", "Nov 12",
          ST_PROGRESS, PRI_MEDIUM, ("Perf", None), (cui.Tone.TEAL, 0)),
    Issue("ENG-198", "Keyboard navigation for the color picker", "Priya Nair", "Nov 7",
          ST_REVIEW, PRI_HIGH, ("A11y", "Input"), (cui.Tone.INFO, cui.Tone.NEUTRAL)),
    Issue("ENG-196", "Wayland backend through libdecor", "Tomas Rivera", "Nov 9",
          ST_REVIEW, PRI_MEDIUM, ("Platform", None), (cui.Tone.ROSE, 0)),
    Issue("ENG-221", "Inline IME composition on macOS", "Aiko Tanaka", "Nov 14",
          ST_TODO, PRI_HIGH, ("Platform", "Input"), (cui.Tone.ROSE, cui.Tone.NEUTRAL)),
    Issue("ENG-219", "Virtual table with sticky header", "Sam Whitfield", "Nov 18",
          ST_TODO, PRI_MEDIUM, ("Data", None), (cui.Tone.TEAL, 0)),
    Issue("ENG-217", "Docs: theming cookbook", "Maya Okafor", "Nov 20",
          ST_TODO, PRI_LOW, ("Docs", None), (cui.Tone.NEUTRAL, 0)),
    Issue("ENG-188", "Ship 1.0 release notes", "Jonas Berg", "Nov 1",
          ST_DONE, PRI_MEDIUM, ("Docs", None), (cui.Tone.NEUTRAL, 0)),
    Issue("ENG-185", "Gliding highlight in segmented controls", "Priya Nair", "Oct 30",
          ST_DONE, PRI_LOW, ("Motion", None), (cui.Tone.VIOLET, 0)),
)

STATUS_NAMES = ("Backlog", "Todo", "In progress", "In review", "Done")
PRIORITY_NAMES = ("No priority", "Low", "Medium", "High", "Urgent")

COMMANDS = (
    cui.Command("Create issue", cui.Icon.PLUS, "Issues", "C"),
    cui.Command("Assign to me", cui.Icon.USER, "Issues", "I"),
    cui.Command("Change status", cui.Icon.CIRCLE_DOT, "Issues", "S"),
    cui.Command("Go to inbox", cui.Icon.INBOX, "Navigation", "G I"),
    cui.Command("Go to cycles", cui.Icon.REFRESH_CW, "Navigation", "G C"),
)


class State:
    def __init__(self) -> None:
        self.nav = 6
        self.tab = 0
        self.selected = 0
        self.palette = False
        self.comment = ""
        self.subscribed = False
        self.panes = 3
        self.drawer = False
        self.sheet = False
        self.row_hover: dict[int, bool] = {}


# --- custom glyphs -------------------------------------------------------

def _paint_status(ui: cui.UI, status: int, r: cui.Rect) -> None:
    c = (r.x + r.w / 2, r.y + r.h / 2)
    rad = 6.5
    with ui.clip(r):
        if status == ST_BACKLOG:  # dashed ring
            muted = ui.token_color(cui.Token.TEXT_MUTED)
            for i in range(8):
                ui.draw_arc(c, rad, TAU * i / 8 + 0.12, TAU * (i + 1) / 8 - 0.12, 1.5, muted)
        elif status == ST_TODO:
            ui.draw_arc(c, rad, 0, TAU, 1.5, ui.token_color(cui.Token.TEXT_SECONDARY))
        elif status in (ST_PROGRESS, ST_REVIEW):  # ring with a half pie
            col = ui.token_color(cui.Token.WARNING if status == ST_PROGRESS else cui.Token.ACCENT)
            frac = 0.5 if status == ST_PROGRESS else 0.75
            ui.draw_arc(c, rad, 0, TAU, 1.5, col)
            points = [c]
            for i in range(33):
                a = -TAU / 4 + TAU * frac * i / 32
                points.append((c[0] + math.cos(a) * (rad - 3), c[1] + math.sin(a) * (rad - 3)))
            # the pie is not convex for frac > 0.5: draw it as two halves
            if frac <= 0.5:
                ui.draw_polygon(points, col)
            else:
                ui.draw_polygon(points[:18], col)
                ui.draw_polygon([c] + points[17:34], col)
        elif status == ST_DONE:
            ui.draw_circle(c, rad + 0.75, ui.token_color(cui.Token.ACCENT))
            ui.draw_icon(cui.Icon.CHECK, r, 10, ui.token_color(cui.Token.ACCENT_FOREGROUND))


def status_icon(ui: cui.UI, id: str, status: int) -> None:
    ui.canvas(id, cui.Size.px(16), cui.Size.px(16),
              lambda r: _paint_status(ui, status, r))


def _paint_priority(ui: cui.UI, priority: int, r: cui.Rect) -> None:
    on = ui.token_color(cui.Token.TEXT_SECONDARY)
    off = on.with_alpha(int(on.a * 0.3 + 0.5))
    with ui.clip(r):
        if priority == PRI_URGENT:
            b = cui.Rect(r.x + 1, r.y + 1, r.w - 2, r.h - 2)
            ui.draw_rect(b, ui.token_color(cui.Token.WARNING), 3.5)
            ui.draw_rect(cui.Rect(b.x + b.w / 2 - 0.9, b.y + 3, 1.8, 5.5),
                         cui.Color.rgb(0x1A1A1A), 0.9)
            ui.draw_rect(cui.Rect(b.x + b.w / 2 - 0.9, b.y + b.h - 4.6, 1.8, 1.8),
                         cui.Color.rgb(0x1A1A1A), 0.9)
            return
        if priority == PRI_NONE:
            for i in range(3):
                ui.draw_rect(cui.Rect(r.x + 2 + i * 4.5, r.y + r.h / 2 - 0.75, 3, 1.5),
                             off, 0.75)
            return
        for i in range(3):
            h = 4 + i * 3.5
            ui.draw_rect(cui.Rect(r.x + 2 + i * 4.5, r.y + r.h - 2 - h, 3, h),
                         on if i < priority else off, 1)


def priority_icon(ui: cui.UI, id: str, priority: int) -> None:
    ui.canvas(id, cui.Size.px(16), cui.Size.px(16),
              lambda r: _paint_priority(ui, priority, r))


# A full-width hover/selection background behind a row of components.
def _paint_row(ui: cui.UI, hovered: bool, selected: bool, radius: float, r: cui.Rect) -> None:
    if selected:
        col = ui.token_color(cui.Token.ACTIVE)
    elif hovered:
        col = ui.token_color(cui.Token.HOVER)
    else:
        return
    with ui.clip(r):
        ui.draw_rect(r, col, radius)


def row_background(ui: cui.UI, state: State, index: int, selected: bool,
                   radius: float) -> bool:
    hovered = state.row_hover.get(index, False)

    def paint(r: cui.Rect) -> None:
        _paint_row(ui, hovered, selected, radius, r)

    res = ui.canvas("bg", cui.Size.FILL, cui.Size.FILL, paint)
    state.row_hover[index] = res.hovered
    return res.clicked


# --- panes ---------------------------------------------------------------

def sidebar(ui: cui.UI, state: State, drawer: bool) -> None:
    with ui.column(width=cui.Size.FILL if drawer else cui.Size.px(240),
                   height=cui.Size.FILL,
                   bg=TRANSPARENT if drawer else SURFACE_MUTED,
                   pad=0 if drawer else 12, gap=2):
        with ui.row(gap=10, pad_x=6, pad_top=4, pad_bottom=12,
                    align=cui.Align.CENTER):
            with ui.box(dir=cui.Dir.STACK, width=cui.Size.px(26), height=cui.Size.px(26),
                        radius=8, bg=ui.token_color(cui.Token.ACCENT),
                        align=cui.Align.CENTER, justify=cui.Justify.CENTER):
                ui.icon(cui.Icon.TARGET, 16, cui.Color.token(cui.Token.ACCENT_FOREGROUND))
            ui.text("Orbit", font=cui.MEDIUM, size=15, width=cui.Size.FILL, nowrap=True)
            ui.icon_button(cui.Icon.SQUARE_PEN, size=cui.ControlSize.SM, tooltip="New issue")

        main_items = ("Inbox", "My issues", "Views")
        main_icons = (cui.Icon.INBOX, cui.Icon.CIRCLE_USER, cui.Icon.LAYERS)
        main_badges = ("4", None, None)
        for i in range(3):
            if ui.nav_item(main_items[i], icon=main_icons[i], badge=main_badges[i],
                           selected=state.nav == i, group="nav"):
                state.nav = i
                state.drawer = False
        with ui.box(height=cui.Size.px(12)):
            pass
        ui.nav_section("Workspace")
        ws_items = ("Projects", "Cycles", "Roadmap")
        ws_icons = (cui.Icon.BOX, cui.Icon.REFRESH_CW, cui.Icon.MAP_PIN)
        for i in range(3):
            if ui.nav_item(ws_items[i], icon=ws_icons[i], selected=state.nav == 3 + i,
                           group="nav"):
                state.nav = 3 + i
                state.drawer = False
        with ui.box(height=cui.Size.px(12)):
            pass
        ui.nav_section("Teams")
        teams = ("Engine", "Design", "Platform")
        team_icons = (cui.Icon.CPU, cui.Icon.PALETTE, cui.Icon.SERVER)
        for i in range(3):
            if ui.nav_item(teams[i], icon=team_icons[i], selected=state.nav == 6 + i,
                           group="nav"):
                state.nav = 6 + i

        ui.spacer()
        with ui.card(pad=14, gap=10, muted=False):
            with ui.row(gap=8, align=cui.Align.CENTER):
                ui.icon(cui.Icon.ZAP, 14, cui.Color.token(cui.Token.ACCENT))
                ui.text("Cycle 24", font=cui.MEDIUM, size=13, width=cui.Size.FILL)
                ui.text("6 days left", size=12, color=TEXT_MUTED)
            ui.progress(0.64, height=6)
            ui.text("32 of 50 issues done", size=12, color=TEXT_SECONDARY)
        with ui.box(height=cui.Size.px(8)):
            pass
        with ui.row(gap=10, pad_x=6, pad_y=4, align=cui.Align.CENTER):
            ui.avatar("Maya Okafor", size=28, status="online")
            with ui.column(gap=0, width=cui.Size.FILL):
                ui.text("Maya Okafor", font=cui.MEDIUM, size=13, nowrap=True)
                ui.text("maya@orbit.dev", size=12, color=TEXT_MUTED, nowrap=True)
            ui.icon_button(cui.Icon.SETTINGS, size=cui.ControlSize.SM, tooltip="Settings")


def issue_row(ui: cui.UI, state: State, index: int) -> None:
    it = ISSUES[index]
    with ui.id(index):
        with ui.box(dir=cui.Dir.STACK, width=cui.Size.FILL, height=cui.Size.px(44)):
            if row_background(ui, state, index, state.selected == index, 8):
                state.selected = index
                state.sheet = state.panes < 3
            with ui.row(width=cui.Size.FILL, height=cui.Size.FILL, pad_x=12, gap=12,
                        align=cui.Align.CENTER):
                priority_icon(ui, "prio", it.priority)
                ui.text(it.key, font=cui.MONO, size=12, color=TEXT_MUTED,
                        width=cui.Size.px(62), nowrap=True)
                status_icon(ui, "status", it.status)
                ui.text(it.title, width=cui.Size.FILL, nowrap=True)
                if state.panes > 1:  # a phone keeps the title, the status and who has it
                    for l in range(2):
                        if it.labels[l]:
                            ui.badge(it.labels[l], tone=it.label_tones[l])
                    ui.text(it.date, size=12, color=TEXT_MUTED, width=cui.Size.px(46),
                            align=cui.TextAlign.RIGHT, nowrap=True)
                ui.avatar(it.assignee, size=22)


def issue_list(ui: cui.UI, state: State) -> None:
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL):
        phone = state.panes == 1
        with ui.row(width=cui.Size.FILL, pad_x=12 if phone else 24, pad_y=14,
                    gap=6 if phone else 12, align=cui.Align.CENTER):
            if phone and ui.icon_button(cui.Icon.MENU, tooltip="Menu"):
                state.drawer = True
            ui.breadcrumb(("Engine", "Issues"))
            ui.spacer()
            if phone:
                ui.icon_button(cui.Icon.FILTER, tooltip="Filter")
                ui.icon_button(cui.Icon.PLUS, variant=cui.ButtonVariant.PRIMARY,
                               size=cui.ControlSize.SM, tooltip="New issue")
            else:
                ui.button("Filter", icon=cui.Icon.FILTER, size=cui.ControlSize.SM,
                          variant=cui.ButtonVariant.GHOST)
                ui.button("Display", icon=cui.Icon.SLIDERS_HORIZONTAL,
                          size=cui.ControlSize.SM, variant=cui.ButtonVariant.GHOST)
                ui.button("New issue", icon=cui.Icon.PLUS, size=cui.ControlSize.SM,
                          variant=cui.ButtonVariant.PRIMARY)
        with ui.row(width=cui.Size.FILL, pad_x=12 if phone else 24, pad_bottom=12,
                    align=cui.Align.CENTER):
            state.tab = ui.tabs("views", ("All issues", "Active", "Backlog"),
                                index=state.tab, variant=cui.TabsVariant.PILL)
            ui.spacer()
            people = ("Maya Okafor", "Jonas Berg", "Priya Nair", "Lena Fischer", "Aiko Tanaka")
            ui.avatar_group(people, 4, 24)
        ui.separator()
        with ui.scroll(id="issues", pad=4 if phone else 12, gap=2, fade_edges=True):
            order = (ST_PROGRESS, ST_REVIEW, ST_TODO, ST_DONE)
            for g, st in enumerate(order):
                count = sum(1 for issue in ISSUES if issue.status == st)
                with ui.id(100 + st):
                    with ui.row(width=cui.Size.FILL, pad_x=12, pad_top=14 if g else 4,
                                pad_bottom=6, gap=10, align=cui.Align.CENTER):
                        status_icon(ui, "group", st)
                        ui.text(STATUS_NAMES[st], font=cui.MEDIUM, size=13, nowrap=True)
                        ui.text(str(count), size=13, color=TEXT_MUTED)
                        ui.spacer()
                        ui.icon_button(cui.Icon.PLUS, size=cui.ControlSize.SM,
                                       tooltip="Add issue")
                for i, issue in enumerate(ISSUES):
                    if issue.status == st:
                        issue_row(ui, state, i)


def property_label(ui: cui.UI, name: str) -> None:
    ui.text(name, size=13, color=TEXT_SECONDARY, width=cui.Size.px(96), nowrap=True)


def detail(ui: cui.UI, state: State, in_sheet: bool) -> None:
    it = ISSUES[state.selected]
    with ui.column(width=cui.Size.FILL if in_sheet else cui.Size.px(380),
                   height=cui.Size.FILL,
                   bg=TRANSPARENT if in_sheet else SURFACE):
        if not in_sheet:
            with ui.row(width=cui.Size.FILL, pad_x=20, pad_y=14, gap=6,
                        align=cui.Align.CENTER):
                ui.text(it.key, font=cui.MONO, size=12, color=TEXT_SECONDARY)
                ui.copy_button("copy", it.key)
                ui.spacer()
                if ui.icon_button(cui.Icon.BELL, size=cui.ControlSize.SM,
                                  tooltip="Unsubscribe" if state.subscribed else "Subscribe"):
                    state.subscribed = not state.subscribed

                def more_menu(ui: cui.UI) -> None:
                    ui.menu_item("Copy link", icon=cui.Icon.LINK, shortcut="Ctrl L")
                    ui.menu_item("Duplicate", icon=cui.Icon.COPY)
                    ui.menu_separator()
                    ui.menu_item("Delete issue", icon=cui.Icon.TRASH_2, danger=True)

                ui.menu("More", icon=cui.Icon.ELLIPSIS, icon_only=True,
                        variant=cui.ButtonVariant.GHOST,
                        placement=cui.Placement.BOTTOM_END, body=more_menu)
        if not in_sheet:
            ui.separator()
        with ui.scroll(id="detail", pad=0 if in_sheet else 20, gap=18, fade_edges=True):
            ui.text(it.title, font=cui.DISPLAY, size=20, line_height=1.3)
            ui.text("Typing quickly into a focused field sometimes loses the final keystroke "
                    "when the frame that receives it also changes focus. Repro: type and press "
                    "Tab in the same frame.", color=TEXT_SECONDARY)
            with ui.column(gap=12, width=cui.Size.FILL):
                with ui.row(gap=8, align=cui.Align.CENTER):
                    property_label(ui, "Status")
                    status_icon(ui, "d-status", it.status)
                    ui.text(STATUS_NAMES[it.status], size=13)
                with ui.row(gap=8, align=cui.Align.CENTER):
                    property_label(ui, "Priority")
                    priority_icon(ui, "d-prio", it.priority)
                    ui.text(PRIORITY_NAMES[it.priority], size=13)
                with ui.row(gap=8, align=cui.Align.CENTER):
                    property_label(ui, "Assignee")
                    ui.avatar(it.assignee, size=20)
                    ui.text(it.assignee, size=13)
                with ui.row(gap=6, align=cui.Align.CENTER):
                    property_label(ui, "Labels")
                    for l in range(2):
                        if it.labels[l]:
                            ui.badge(it.labels[l], tone=it.label_tones[l])
                with ui.row(gap=8, align=cui.Align.CENTER):
                    property_label(ui, "Cycle")
                    ui.icon(cui.Icon.REFRESH_CW, 14, TEXT_SECONDARY)
                    ui.text("Cycle 24", size=13)
                with ui.row(gap=8, align=cui.Align.CENTER):
                    property_label(ui, "Due date")
                    ui.icon(cui.Icon.CALENDAR, 14, TEXT_SECONDARY)
                    ui.text(it.date, size=13)
            ui.separator()
            ui.text("Activity", font=cui.MEDIUM)
            with ui.column(gap=0, width=cui.Size.FILL):
                ui.timeline_item("Maya moved this to In progress", time="2h ago",
                                 icon=cui.Icon.ARROW_RIGHT, tone=cui.Tone.WARNING)
                ui.timeline_item("Jonas linked a pull request", time="5h ago",
                                 icon=cui.Icon.GIT_BRANCH, tone=cui.Tone.ACCENT,
                                 description="Keep pending text across focus changes")
                ui.timeline_item("Priya set the priority to Urgent", time="Yesterday",
                                 icon=cui.Icon.CIRCLE_ALERT, tone=cui.Tone.WARNING)
                ui.timeline_item("Issue created", time="Nov 2", icon=cui.Icon.PLUS, last=True)
        ui.separator()
        with ui.row(width=cui.Size.FILL, pad=0 if in_sheet else 16, pad_top=16, gap=8,
                    align=cui.Align.CENTER):
            result = ui.text_input("comment", value=state.comment,
                                   placeholder="Leave a comment", width=cui.Size.FILL)
            state.comment = result.text
            ui.icon_button(cui.Icon.SEND, variant=cui.ButtonVariant.PRIMARY, tooltip="Send")


def frame(ui: cui.UI, state: State) -> None:
    if ui.shortcut(cui.Mod.PRIMARY, cui.Key.KEY_K):
        state.palette = True
    vw = ui.context.size[0]
    state.panes = 1 if vw < 760 else 2 if vw < 1200 else 3
    if state.panes > 1:
        state.drawer = False
    if state.panes == 3:
        state.sheet = False

    with ui.row(width=cui.Size.FILL, height=cui.Size.FILL, align=cui.Align.STRETCH,
                bg=BACKGROUND):
        if state.panes > 1:
            sidebar(ui, state, False)
            ui.separator()
        issue_list(ui, state)
        if state.panes == 3:
            ui.separator()
            detail(ui, state, False)

    drawer_open = ui.sheet("Orbit", open=state.drawer, side=cui.Side.LEFT, size=280,
                           body=lambda sheet: sidebar(sheet, state, True))
    state.drawer = state.drawer and drawer_open
    sheet_open = ui.sheet(ISSUES[state.selected].key, open=state.sheet,
                          size=vw if state.panes == 1 else 420,
                          body=lambda sheet: detail(sheet, state, True))
    state.sheet = state.sheet and sheet_open

    chosen, state.palette = ui.command_palette(COMMANDS, open=state.palette)
    if chosen >= 0:
        ui.toast(COMMANDS[chosen].title, tone=cui.Tone.SUCCESS)


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Orbit", width=1440, height=900,
                          theme=cui.ThemeMode.DARK, accent=cui.Accent.NEUTRAL))
