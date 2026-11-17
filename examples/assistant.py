"""Muse, an assistant chat, ported from CUI's ``examples/assistant.c``.

    python examples/assistant.py
    python examples/assistant.py --shot dev/out/assistant.png

Reasoning, a tool call, an agent plan, sources, citations and a composer.  The
workspace panel closes below 1180 points and the chat list becomes a drawer
below 760.

Adaptations: the ``chat_composer`` wrapper drops the ``removed``, ``models`` and
``model`` out-parameters, so attachments stay in Python state (the x buttons
report ``REMOVE`` but cannot name the file) and the header model picker is the
only one; ``context_meter`` ignores ``parts``; ``response_actions`` ignores
``vote``.
"""

from __future__ import annotations

import cui

from _common import (
    ACCENT,
    ACCENT_FOREGROUND,
    BACKGROUND,
    SURFACE,
    SURFACE_MUTED,
    TEXT_MUTED,
    TEXT_SECONDARY,
    TRANSPARENT,
    main,
)

MODELS = (
    cui.Model("Atlas", "Longer answers, reads files and code", "New", cui.ICON_LAYERS),
    cui.Model("Atlas Fast", "Short answers in about a second", None, cui.ICON_ZAP),
    cui.Model("Atlas Mini", "Runs on your own machine", None, cui.ICON_BOX),
)

SOURCES = (
    cui.Source(
        "Immediate mode GUIs and why they keep coming back",
        "https://fieldnotes.dev/immediate-mode",
        "Retained and immediate mode toolkits and the trade offs between them.",
    ),
    cui.Source(
        "Notes on subpixel text positioning",
        "https://glyphlab.io/notes/subpixel",
        "Shaping, hinting and subpixel positioning explained with examples.",
    ),
    cui.Source(
        "Spring physics for interface motion",
        "https://motionbook.dev/springs",
        "Why spring physics feel more natural than cubic beziers for interface motion.",
    ),
)

ANSWER = (
    "Mostly because they do very little per frame. The interface is rebuilt from your data each frame, laid out "
    "in one pass and drawn in a handful of batches, so there is no tree of widget objects to keep in sync.\n\n"
    "Text is the expensive part, which is why glyphs are rasterized once into an atlas and reused. And motion "
    "feels quick when it is driven by springs that respond to input at once, instead of fixed length curves."
)

TODAY = ("Why immediate mode feels fast", "Quarterly report summary", "Spring presets for menus")
WEEK = ("Gantt chart layout ideas", "Kanban drag and drop", "Color palette for charts", "Release notes draft")
FILE_NAMES = ("quarterly-report.pdf", "metrics.csv", "notes.md")
FILE_SIZES = ("2.4 MB", "86 KB", "4 KB")
SUGGESTIONS = (
    cui.PromptSuggestion(cui.ICON_CHART_BAR, "Compare with last quarter", "Revenue, churn and costs"),
    cui.PromptSuggestion(cui.ICON_LIST_CHECKS, "Turn this into a checklist", None),
)


class State:
    def __init__(self) -> None:
        self.chat = 0
        self.draft = "Now compare these numbers with last quarter."
        self.asked = ""
        self.model = 0
        self.vote = 0
        self.started = -1.0  # when the live answer began; < 0 idle
        self.asked_once = False
        self.files = ["quarterly-report.pdf", "metrics.csv"]
        self.removed = -1
        self.narrow = False
        self.drawer = False


def sidebar(ui: cui.UI, state: State, drawer: bool) -> None:
    with ui.column(
        width=cui.Size.FILL if drawer else cui.Size.px(264),
        height=cui.Size.FILL,
        bg=TRANSPARENT if drawer else SURFACE_MUTED,
        pad=0 if drawer else 12,
        gap=2,
    ):
        with ui.row(gap=10, pad_x=6, pad_top=4, pad_bottom=10, align=cui.Align.CENTER):
            with ui.box(
                dir=cui.Dir.STACK,
                width=cui.Size.px(28),
                height=cui.Size.px(28),
                radius=9,
                bg=ACCENT,
                align=cui.Align.CENTER,
                justify=cui.Justify.CENTER,
            ):
                ui.text("M", font=cui.DISPLAY, size=16, color=ACCENT_FOREGROUND, line_height=1.0)
            ui.text("Muse", font=cui.MEDIUM, size=15, width=cui.Size.FILL, nowrap=True)
            if ui.icon_button(cui.ICON_SQUARE_PEN, size=cui.ControlSize.SM, tooltip="New chat"):
                state.asked_once = False
                state.started = -1.0
                state.draft = ""

        ui.nav_section("Today")
        for index, title in enumerate(TODAY):
            if ui.nav_item(title, icon=cui.ICON_MESSAGE_SQUARE, selected=state.chat == index,
                           group="chats"):
                state.chat = index
                state.drawer = False

        with ui.box(height=cui.Size.px(10)):
            pass

        ui.nav_section("Previous 7 days")
        for offset, title in enumerate(WEEK):
            if ui.nav_item(title, icon=cui.ICON_MESSAGE_SQUARE, selected=state.chat == 3 + offset,
                           group="chats"):
                state.chat = 3 + offset
                state.drawer = False

        ui.spacer()

        with ui.card(pad=14, gap=8):
            with ui.row(gap=8, align=cui.Align.CENTER):
                ui.icon(cui.ICON_ZAP, 14, ACCENT)
                ui.text("Usage this month", font=cui.MEDIUM, size=13, width=cui.Size.FILL)
            ui.progress(0.42, height=6)
            ui.text("4,210 of 10,000 messages", size=12, color=TEXT_SECONDARY)

        with ui.box(height=cui.Size.px(6)):
            pass

        def menu_body(ui: cui.UI) -> None:
            ui.menu_item("Settings", icon=cui.ICON_SETTINGS)
            ui.menu_item("Keyboard shortcuts", icon=cui.ICON_KEYBOARD)
            ui.menu_separator()
            ui.menu_item("Log out", icon=cui.ICON_LOG_OUT)

        ui.user_menu("Mara Quinn", body=menu_body, detail="mara@muse.dev", status="online")


def answer_block(ui: cui.UI, state: State, key: str, t: float, live: bool) -> None:
    with ui.id(key):
        thinking = live and t < 2.6

        def reasoning_body(ui: cui.UI) -> None:
            ui.text(
                "This is about perceived speed. Two parts: how little work a frame does, and how fast input "
                "reaches the screen.",
                size=13.5,
                color=TEXT_SECONDARY,
            )
            ui.text(
                "Find sources on retained against immediate mode, text rendering cost and interface motion.",
                size=13.5,
                color=TEXT_SECONDARY,
            )

        ui.reasoning(
            "think",
            thinking=thinking,
            seconds=(t if thinking else 2.6) if live else 6,
            body=reasoning_body,
        )

        if not live or t > 1.2:
            status = cui.TaskStatus.RUNNING if live and t < 3.6 else cui.TaskStatus.DONE
            ui.tool_call(
                "search",
                "web_search",
                icon=cui.ICON_GLOBE,
                detail="immediate mode gui performance",
                status=status,
                seconds=1.4 if status == cui.TaskStatus.DONE else t - 1.2,
                input='{"query": "immediate mode gui performance", "limit": 5}',
                output='{"results": 3, "took_ms": 1380}',
            )

        if live and 2.6 < t < 4.2:
            ui.agent_status("Reading 3 sources", status=cui.TaskStatus.RUNNING, seconds=t - 2.6)

        if not live or t > 3.6:
            if live:
                ui.typewriter("answer", ANSWER, size=15, speed=140, caret=True)
            else:
                ui.text(ANSWER, size=15)

            if not live or t > 6.5:
                with ui.row(gap=6, align=cui.Align.CENTER):
                    for index in range(3):
                        ui.citation(index + 1, [SOURCES[index]])

                ui.source_list("sources", SOURCES)

                act = ui.response_actions("actions", copy_text=ANSWER)
                if act & cui.REGENERATE:
                    state.started = ui.context.time
                if act & cui.SHARE:
                    ui.toast("Link copied", tone=cui.Tone.SUCCESS)


def conversation(ui: cui.UI, state: State) -> None:
    now = ui.context.time
    t = float(now - state.started) if state.started >= 0 else 99.0

    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL):
        with ui.row(
            width=cui.Size.FILL,
            pad_x=12 if state.narrow else 20,
            pad_y=12,
            gap=6 if state.narrow else 10,
            align=cui.Align.CENTER,
        ):
            if state.narrow and ui.icon_button(cui.ICON_MENU, tooltip="Chats"):
                state.drawer = True
            _, state.model = ui.model_picker(
                "model", MODELS, state.model, ghost=True, placement=cui.Placement.BOTTOM_START
            )
            ui.spacer()
            ui.context_meter("ctx", 113400, 200000)
            if state.narrow:
                ui.icon_button(cui.ICON_SHARE_2, tooltip="Share")
            else:
                ui.button("Share", icon=cui.ICON_SHARE_2, variant=cui.ButtonVariant.OUTLINE,
                          size=cui.ControlSize.SM)

        ui.separator()

        with ui.scroll(id="chat", width=cui.Size.FILL, height=cui.Size.FILL, fade_edges=True):
            with ui.row(
                width=cui.Size.FILL,
                justify=cui.Justify.CENTER,
                pad_x=12 if state.narrow else 24,
                pad_y=16 if state.narrow else 24,
            ):
                with ui.column(width=cui.Size.FILL, max_width=760, gap=14):
                    ui.chat_message(
                        "Why do immediate mode toolkits feel so fast? Cite a few sources.", mine=True
                    )
                    answer_block(ui, state, "first", t, False)
                    if state.asked_once:
                        ui.gap(12)
                        ui.chat_message(state.asked, mine=True)
                        answer_block(ui, state, "second", t, True)

        busy = state.asked_once and t < 7.5
        with ui.row(
            width=cui.Size.FILL,
            justify=cui.Justify.CENTER,
            pad_x=12 if state.narrow else 24,
            pad_bottom=12 if state.narrow else 20,
        ):
            with ui.column(width=cui.Size.FILL, max_width=760, gap=8):
                typed = ui.chat_composer(
                    "composer",
                    state.draft,
                    placeholder="Ask a follow up",
                    busy=busy,
                    attachments=state.files,
                    attachment_count=len(state.files),
                )
                state.draft = typed.text
                if typed.flags & cui.SEND:
                    state.asked = state.draft
                    state.draft = ""
                    state.asked_once = True
                    state.started = ui.context.time
                if typed.flags & cui.STOP:
                    state.started = ui.context.time - 99
                # The wrapper drops the `removed` index, so this stays a no-op.
                if typed.flags & cui.REMOVE and 0 <= state.removed < len(state.files):
                    del state.files[state.removed]
                    state.removed = -1
                if typed.flags & cui.ATTACH:
                    ui.toast("Drop files on the window to attach them")
                ui.text(
                    "Answers can be wrong. Each one links the sources it used.",
                    size=12,
                    color=TEXT_MUTED,
                    align=cui.TextAlign.CENTER,
                    width=cui.Size.FILL,
                )

        if busy:
            ui.context.request_redraw()


def side_panel(ui: cui.UI, state: State) -> None:
    now = ui.context.time
    t = float(now - state.started) if state.asked_once and state.started >= 0 else 99.0

    with ui.column(width=cui.Size.px(330), height=cui.Size.FILL, bg=SURFACE, pad=20, gap=16):
        ui.text("Workspace", font=cui.MEDIUM, size=15)

        steps = (
            cui.PlanStep(
                "Search for sources",
                "3 results",
                cui.TaskStatus.DONE if t > 3.6 else cui.TaskStatus.RUNNING,
            ),
            cui.PlanStep(
                "Read the sources",
                "3 of 3" if t > 4.2 else "Reading",
                cui.TaskStatus.DONE
                if t > 4.2
                else cui.TaskStatus.RUNNING if t > 2.6 else cui.TaskStatus.PENDING,
            ),
            cui.PlanStep(
                "Write the answer",
                None,
                cui.TaskStatus.DONE
                if t > 7.5
                else cui.TaskStatus.RUNNING if t > 3.6 else cui.TaskStatus.PENDING,
            ),
            cui.PlanStep(
                "Check the citations",
                None,
                cui.TaskStatus.DONE if t > 7.5 else cui.TaskStatus.PENDING,
            ),
        )
        ui.agent_plan("plan", steps, title="Plan")

        ui.label("Files")
        with ui.column(gap=6, width=cui.Size.FILL):
            for index in range(3):
                with ui.id(index):
                    with ui.row(gap=10, align=cui.Align.CENTER, width=cui.Size.FILL, pad=8,
                                radius=12, bg=SURFACE_MUTED):
                        ui.icon(cui.ICON_FILE_TEXT, 16, TEXT_SECONDARY)
                        ui.text(FILE_NAMES[index], size=13, width=cui.Size.FILL, nowrap=True)
                        ui.text(FILE_SIZES[index], size=12, color=TEXT_MUTED)

        ui.label("Try asking")
        pick = ui.prompt_suggestions("sugg", SUGGESTIONS, columns=1)
        if pick >= 0:
            state.draft = SUGGESTIONS[pick].title


def frame(ui: cui.UI, state: State) -> None:
    width = ui.context.size[0]
    state.narrow = width < 760
    if not state.narrow:
        state.drawer = False

    with ui.row(width=cui.Size.FILL, height=cui.Size.FILL, align=cui.Align.STRETCH, bg=BACKGROUND):
        if not state.narrow:
            sidebar(ui, state, False)
            ui.separator()
        conversation(ui, state)
        if width >= 1180:
            ui.separator()
            side_panel(ui, state)

    def drawer_body(ui: cui.UI) -> None:
        sidebar(ui, state, True)

    still_open = ui.sheet(
        "Muse", open=state.drawer, side=cui.Side.LEFT, size=300, body=drawer_body
    )
    state.drawer = state.drawer and still_open


if __name__ == "__main__":
    raise SystemExit(
        main(frame, State(), title="Muse", width=1440, height=900,
             theme=cui.ThemeMode.DARK, accent=cui.Accent.NEUTRAL)
    )
