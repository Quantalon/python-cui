"""Personal finance, ported from CUI's ``examples/finance.c``.

    python examples/finance.py
    python examples/finance.py --shot dev/out/finance.png

Top navigation, a balance chart, a painted payment card, budgets, savings
goals and recent transactions, dark with the green accent.
"""

from __future__ import annotations

import cui

from _common import (
    ACCENT,
    ACCENT_FOREGROUND,
    BACKGROUND,
    DANGER,
    FOREGROUND,
    SUCCESS,
    TEXT_MUTED,
    TEXT_SECONDARY,
    TRANSPARENT,
    main,
)

TABS = ["Overview", "Accounts", "Payments", "Cards", "Insights"]

MONTHS = ["Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov"]
BALANCE = [31.2, 32.8, 32.1, 34.6, 36.0, 35.2, 38.4, 40.1, 39.3, 42.8, 45.1, 48.2]
SPENT = [4.1, 3.8, 4.4, 3.9, 4.2, 4.6, 3.7, 4.0, 4.5, 3.6, 3.9, 3.4]

# merchant, category, icon, when, amount, tone
TXNS = [
    ("Salary", "Income", cui.Icon.BRIEFCASE, "Today, 09:12", 6200.00, cui.Tone.SUCCESS),
    ("Blue Bottle", "Coffee", cui.Icon.GIFT, "Today, 08:40", -6.50, cui.Tone.WARNING),
    ("Fieldnotes Rent", "Housing", cui.Icon.BUILDING_2, "Yesterday", -1850.00, cui.Tone.INFO),
    ("Night Market", "Groceries", cui.Icon.SHOPPING_CART, "Yesterday", -84.20, cui.Tone.TEAL),
    ("Cloud Storage", "Subscriptions", cui.Icon.CLOUD, "Nov 3", -9.99, cui.Tone.VIOLET),
    ("Transfer from Sam", "Transfer", cui.Icon.ARROW_DOWN, "Nov 2", 120.00, cui.Tone.SUCCESS),
]

# The three commands of the C palette, in the same order: index 1 toggles the
# card freeze, the others toast their title.
COMMANDS = [
    cui.Command("Send money", cui.Icon.SEND, "Actions", None),
    cui.Command("Freeze card", cui.Icon.LOCK, "Actions", None),
    cui.Command("Download statement", cui.Icon.DOWNLOAD, "Actions", None),
]

BUDGETS = [
    ("Groceries", cui.Icon.SHOPPING_CART, 640.0, 800.0),
    ("Dining out", cui.Icon.GIFT, 420.0, 400.0),
    ("Transport", cui.Icon.MAP_PIN, 96.0, 250.0),
    ("Entertainment", cui.Icon.MUSIC, 186.0, 200.0),
]

GOALS = [
    ("Japan trip", "$3,240 of $4,000", 0.81),
    ("New laptop", "$1,100 of $2,400", 0.46),
    ("Emergency", "$9,800 of $10k", 0.98),
]

SPEND_VALUES = [1850.0, 640.0, 420.0, 310.0]
SPEND_NAMES = ["Housing", "Groceries", "Dining", "Other"]

# tone -> the token used for the transaction icon and its tint, as in C.
TONE_TOKENS = [
    cui.Token.TEXT_SECONDARY,
    cui.Token.INFO,
    cui.Token.SUCCESS,
    cui.Token.WARNING,
    cui.Token.DANGER,
    cui.Token.SERIES_2,
    cui.Token.SERIES_3,
    cui.Token.SERIES_4,
    cui.Token.ACCENT,
]


class State:
    def __init__(self) -> None:
        self.tab = 0
        self.range = 2
        self.card = 0
        self.frozen = False
        self.palette = False
        self.search = ""


def compact(ui: cui.UI) -> bool:
    return ui.context.size[0] < 900


# --- the payment card ----------------------------------------------------


def paint_card(ui: cui.UI, r: cui.Rect, frozen: bool) -> None:
    rad = 18.0
    ui.draw_shadow(r, 32, -6, (0, 16), cui.Color.rgba(0x00000080), radius=rad)
    ui.draw_rect_gradient(r, cui.Color.rgb(0x1F6F5C), cui.Color.rgb(0x0B2A24), radius=rad)
    # Printed rings, like the guilloche on a real card; no glow.
    with ui.clip(r):
        ui.draw_arc((r.x + r.w * 0.92, r.y + r.h * 1.05), r.h * 0.75,
                    0, 6.2831853, 1, cui.Color.rgba(0xFFFFFF1C))
        ui.draw_arc((r.x + r.w * 0.92, r.y + r.h * 1.05), r.h * 0.55,
                    0, 6.2831853, 1, cui.Color.rgba(0xFFFFFF14))
    ui.draw_rect_border(r, TRANSPARENT, cui.Color.rgba(0xFFFFFF22),
                        radius=rad, border_width=1)

    white = cui.Color.rgb(0xFFFFFF)
    soft = cui.Color.rgba(0xFFFFFFB0)
    ui.draw_text("Halden", (r.x + 24, r.y + 22), white, font=cui.DISPLAY, size=17)
    ui.draw_icon(cui.Icon.WIFI, cui.Rect(r.x + r.w - 48, r.y + 16, 28, 28), 18, soft)
    # chip
    chip = cui.Rect(r.x + 24, r.y + r.h * 0.40, 40, 30)
    ui.draw_rect_gradient(chip, cui.Color.rgb(0xF3D58A), cui.Color.rgb(0xB8913F), radius=6)
    ui.draw_line((chip.x, chip.y + 15), (chip.x + 40, chip.y + 15), 1, cui.Color.rgba(0x00000040))
    ui.draw_line((chip.x + 14, chip.y), (chip.x + 14, chip.y + 30), 1, cui.Color.rgba(0x00000040))
    ui.draw_line((chip.x + 26, chip.y), (chip.x + 26, chip.y + 30), 1, cui.Color.rgba(0x00000040))
    ui.draw_text("4821  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  0937",
                 (r.x + 24, r.y + r.h - 64), white, font=cui.MONO, size=17)
    ui.draw_text("MARA QUINN", (r.x + 24, r.y + r.h - 34), soft, font=cui.BODY, size=12)
    ui.draw_text("09 / 29", (r.x + r.w * 0.5, r.y + r.h - 34), soft, font=cui.BODY, size=12)
    ui.draw_text("DEBIT", (r.x + r.w - 66, r.y + r.h - 40), white, font=cui.MEDIUM, size=13)
    if frozen:
        ui.draw_rect(r, cui.Color.rgba(0x0A0F0EC0), radius=rad)
        ui.draw_icon(cui.Icon.LOCK, r, 28, white)


# --- pieces --------------------------------------------------------------


def topbar(ui: cui.UI, s: State) -> None:
    narrow = compact(ui)
    with ui.row(width=cui.Size.FILL, pad_x=16 if narrow else 32, pad_top=14,
                gap=12 if narrow else 28, align=cui.Align.CENTER):
        with ui.row(gap=10, align=cui.Align.CENTER):
            with ui.box(dir=cui.Dir.STACK, width=cui.Size.px(26), height=cui.Size.px(26),
                        radius=13, bg=ACCENT, align=cui.Align.CENTER,
                        justify=cui.Justify.CENTER):
                ui.text("h", font=cui.DISPLAY, size=15, color=ACCENT_FOREGROUND)
            ui.text("Halden", font=cui.DISPLAY, size=17)
        if not narrow:
            s.tab = ui.tabs("nav", TABS, index=s.tab)
        ui.spacer()
        with ui.box(width=cui.Size.grow(4), max_width=220):
            result = ui.search("search", value=s.search, placeholder="Search")
            s.search = result.text
        ui.icon_button(cui.Icon.BELL, tooltip="Notifications")
        ui.avatar("Mara Quinn", size=32, status="online")
    if narrow:
        with ui.box(width=cui.Size.FILL, pad_x=16, pad_top=6):
            s.tab = ui.tabs("nav", TABS, index=s.tab)


def balance_card(ui: cui.UI, s: State) -> None:
    with ui.card(gap=18, width=cui.Size.grow(2), min_width=300):
        with ui.row(width=cui.Size.FILL, align=cui.Align.START, wrap=True, gap=12):
            with ui.column(gap=6, width=cui.Size.FILL, min_width=240):
                ui.text("Total balance", size=13, color=TEXT_SECONDARY)
                with ui.row(gap=12, align=cui.Align.CENTER):
                    ui.text("$48,250.32", font=cui.DISPLAY, size=38, tabular=True)
                    ui.badge("+6.9%", tone=cui.Tone.SUCCESS, icon=cui.Icon.TRENDING_UP)
                ui.text("+$3,104 since last month across 4 accounts",
                        size=13, color=TEXT_MUTED)
            s.range = ui.segmented("range", ["1M", "6M", "1Y", "All"],
                                   index=s.range, size=cui.ControlSize.SM)
        # The C builds a Balance and a Spending series but passes count = 1,
        # so only Balance is drawn.
        series = [cui.Series("Balance", BALANCE), cui.Series("Spending", SPENT)]
        ui.line_chart("balance", series[:1], labels=MONTHS, label_count=12,
                      area=True, smooth=True, height=236, format="$%.0fk",
                      no_legend=True)


def card_panel(ui: cui.UI, s: State) -> None:
    with ui.card(gap=18, width=cui.Size.grow(1), min_width=280):
        with ui.row(width=cui.Size.FILL, align=cui.Align.CENTER):
            ui.label("My cards")
            ui.spacer()
            ui.button("Add", icon=cui.Icon.PLUS, size=cui.ControlSize.SM,
                      variant=cui.ButtonVariant.GHOST)
        frozen = s.frozen  # the C copies its paint data when the canvas is built
        ui.canvas("card", cui.Size.FILL, cui.Size.px(200),
                  lambda rect, frozen=frozen: paint_card(ui, rect, frozen))
        with ui.grid(columns=3, gap=10, width=cui.Size.FILL):
            for label, icon in (("Send", cui.Icon.ARROW_UP_RIGHT),
                                ("Request", cui.Icon.ARROW_DOWN),
                                ("Top up", cui.Icon.PLUS)):
                ui.button(label, icon=icon, full_width=True)
        with ui.row(width=cui.Size.FILL, gap=12, align=cui.Align.CENTER):
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.text("Freeze card", font=cui.MEDIUM, size=13)
                ui.text("Block new payments instantly", size=12, color=TEXT_MUTED)
            s.frozen = ui.switch("##freeze", value=s.frozen)


def spending_card(ui: cui.UI) -> None:
    def options(menu_ui: cui.UI) -> None:
        menu_ui.menu_item("Export CSV", icon=cui.Icon.DOWNLOAD)
        menu_ui.menu_item("Edit categories", icon=cui.Icon.TAG)

    with ui.card(gap=20, width=cui.Size.grow(1), min_width=260):
        with ui.row(width=cui.Size.FILL, align=cui.Align.CENTER):
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.label("Spending")
                ui.text("November, by category", size=12, color=TEXT_SECONDARY)
            ui.menu("Options", body=options, icon=cui.Icon.ELLIPSIS, icon_only=True,
                    variant=cui.ButtonVariant.GHOST, placement=cui.Placement.BOTTOM_END)
        ui.donut_chart("spend", values=SPEND_VALUES, labels=SPEND_NAMES,
                       height=150, format="$%.0f")


def budgets_card(ui: cui.UI) -> None:
    with ui.card(gap=16, width=cui.Size.grow(1), min_width=260):
        with ui.row(width=cui.Size.FILL, align=cui.Align.CENTER):
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.label("Budgets")
                ui.text("12 days left this month", size=12, color=TEXT_SECONDARY)
            ui.button("Edit", size=cui.ControlSize.SM, variant=cui.ButtonVariant.GHOST)
        for index, (name, icon, used, total) in enumerate(BUDGETS):
            with ui.id(index):
                with ui.column(gap=8, width=cui.Size.FILL):
                    with ui.row(width=cui.Size.FILL, gap=8, align=cui.Align.CENTER):
                        ui.icon(icon, 14, TEXT_SECONDARY)
                        ui.text(name, size=13, width=cui.Size.FILL, nowrap=True)
                        ui.text(f"${used:.0f} / ${total:.0f}", size=12, tabular=True,
                                color=DANGER if used > total else TEXT_SECONDARY)
                    # One rule for every budget: over is red, the last tenth is
                    # amber, the rest is plain.
                    value = used / total
                    tone = (cui.Tone.DANGER if value > 1 else
                            cui.Tone.WARNING if value >= 0.9 else cui.Tone.NEUTRAL)
                    ui.progress(min(value, 1.0), height=6, tone=tone)


def goals_card(ui: cui.UI) -> None:
    with ui.card(gap=18, width=cui.Size.grow(1), min_width=260):
        with ui.row(width=cui.Size.FILL, align=cui.Align.CENTER):
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.label("Savings goals")
                ui.text("On track for 2 of 3", size=12, color=TEXT_SECONDARY)
            ui.icon_button(cui.Icon.PLUS, size=cui.ControlSize.SM, tooltip="New goal")
        with ui.row(width=cui.Size.FILL, justify=cui.Justify.BETWEEN):
            for index, (name, amount, value) in enumerate(GOALS):
                with ui.id(index):
                    with ui.column(gap=8, align=cui.Align.CENTER):
                        ui.progress_ring("##goal", value, 72)
                        ui.text(name, font=cui.MEDIUM, size=13)
                        ui.text(amount, size=11, color=TEXT_MUTED)


def tone_icon(ui: cui.UI, icon: str, tone: int) -> None:
    color = ui.token_color(TONE_TOKENS[tone])
    with ui.box(width=cui.Size.px(38), height=cui.Size.px(38), radius=12,
                bg=ui.api.alpha(color, 0.14), dir=cui.Dir.STACK,
                align=cui.Align.CENTER, justify=cui.Justify.CENTER):
        ui.icon(icon, 16, color)


def transactions_card(ui: cui.UI) -> None:
    with ui.card(gap=6, width=cui.Size.grow(2)):
        with ui.row(width=cui.Size.FILL, pad_bottom=8, align=cui.Align.CENTER):
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.label("Recent transactions")
                ui.text("Across all accounts", size=12, color=TEXT_SECONDARY)
            ui.button("View all", variant=cui.ButtonVariant.GHOST,
                      size=cui.ControlSize.SM, icon_right=cui.Icon.ARROW_RIGHT)
        for index, (merchant, category, icon, when, amount, tone) in enumerate(TXNS):
            with ui.id(index):
                with ui.row(width=cui.Size.FILL, gap=14, pad_y=7, align=cui.Align.CENTER):
                    tone_icon(ui, icon, tone)
                    with ui.column(gap=1, width=cui.Size.FILL):
                        ui.text(merchant, font=cui.MEDIUM, nowrap=True)
                        ui.text(when, size=12, color=TEXT_MUTED, nowrap=True)
                    # a phone keeps the merchant and the amount
                    if ui.context.size[0] >= 560:
                        ui.badge(category)
                    money = f"{'-' if amount < 0 else '+'}${abs(amount):.2f}"
                    ui.text(money, font=cui.MEDIUM, tabular=True,
                            width=cui.Size.px(110), align=cui.TextAlign.RIGHT,
                            color=SUCCESS if amount > 0 else FOREGROUND)


def frame(ui: cui.UI, state: State) -> None:
    if ui.shortcut(cui.Mod.PRIMARY, cui.Key.KEY_K):
        state.palette = True
    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, bg=BACKGROUND):
        topbar(ui, state)
        ui.separator()
        narrow = compact(ui)
        with ui.scroll(id="main", pad=16 if narrow else 32, gap=16 if narrow else 20,
                       fade_edges=True):
            with ui.row(width=cui.Size.FILL, align=cui.Align.END, wrap=True, gap=12):
                with ui.column(gap=4, width=cui.Size.FILL, min_width=240):
                    ui.text("Overview", font=cui.DISPLAY, size=28)
                    ui.text("Four accounts, synced at 6:42 pm", color=TEXT_SECONDARY)
                with ui.row(gap=8):
                    ui.button("Statements", icon=cui.Icon.FILE_TEXT,
                              variant=cui.ButtonVariant.OUTLINE)
                    ui.button("Move money", icon=cui.Icon.SEND,
                              variant=cui.ButtonVariant.PRIMARY)
            with ui.row(width=cui.Size.FILL, gap=16 if narrow else 20,
                        align=cui.Align.STRETCH, wrap=True):
                balance_card(ui, state)
                card_panel(ui, state)
            with ui.row(width=cui.Size.FILL, gap=16 if narrow else 20,
                        align=cui.Align.STRETCH, wrap=True):
                spending_card(ui)
                budgets_card(ui)
                goals_card(ui)
            with ui.row(width=cui.Size.FILL, gap=20, align=cui.Align.STRETCH):
                transactions_card(ui)

    choice, state.palette = ui.command_palette(COMMANDS, open=state.palette)
    if choice == 1:
        state.frozen = not state.frozen
    elif choice >= 0:
        ui.toast(COMMANDS[choice].title, tone=cui.Tone.SUCCESS)


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Halden", width=1440, height=940,
                          theme=cui.ThemeMode.DARK, accent=cui.Accent.GREEN))
