"""Metrics dashboard, ported from CUI's ``examples/dashboard.c``.

    python examples/dashboard.py
    python examples/dashboard.py --shot dev/out/dashboard.png

A sidebar, a top bar, a strip of figures, a line chart, a donut and a table.
Below 760 points the sidebar becomes a drawer sheet and the panels stack.

The binding does not expose CUI's table sort pointer, so the table keeps the
sample's own newest-first order and the search box filters it in Python.
"""

from __future__ import annotations

from typing import NamedTuple

import cui

from _common import BACKGROUND, DANGER, FOREGROUND, SUCCESS, SURFACE_MUTED, TEXT_SECONDARY, main


class Order(NamedTuple):
    id: str
    customer: str
    email: str
    date: str
    status: str
    tone: int
    amount: float


ORDERS = (
    Order("#3021", "Nora Lindqvist", "nora@lindqvist.se", "Nov 5", "Paid", cui.Tone.SUCCESS, 184.20),
    Order("#3020", "Kwame Asante", "kwame@asante.co", "Nov 5", "Pending", cui.Tone.WARNING, 42.75),
    Order("#3019", "Hana Novak", "hana@novak.cz", "Nov 4", "Paid", cui.Tone.SUCCESS, 318.40),
    Order("#3018", "Felix Moreau", "felix@moreau.fr", "Nov 4", "Refunded", cui.Tone.DANGER, 96.00),
    Order("#3017", "Iris Coleman", "iris@coleman.org", "Nov 3", "Paid", cui.Tone.SUCCESS, 471.15),
    Order("#3016", "Ravi Shah", "ravi@shah.in", "Nov 3", "Paid", cui.Tone.SUCCESS, 1236.80),
)

NAV_ITEMS = (
    ("Overview", cui.Icon.LAYOUT_DASHBOARD, None),
    ("Orders", cui.Icon.SHOPPING_CART, "12"),
    ("Customers", cui.Icon.USERS, None),
    ("Products", cui.Icon.PACKAGE, None),
    ("Analytics", cui.Icon.CHART_BAR, None),
    ("Settings", cui.Icon.SETTINGS, None),
)

MONTHS = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
THIS_YEAR = (31, 34, 33, 38, 42, 40, 46, 52, 49, 55, 61, 64)
LAST_YEAR = (24, 26, 27, 29, 31, 30, 34, 36, 35, 39, 41, 44)

SOURCES = ("Search", "Direct", "Social", "Email")
SOURCE_SHARE = (42, 26, 18, 14)


class State:
    def __init__(self) -> None:
        self.nav = 0
        self.range = 1
        self.search = ""
        self.page = 0
        self.selected = 0
        self.dark = False
        self.palette = False
        self.drawer = False


def compact(ui: cui.UI) -> bool:
    return ui.context.size[0] < 760


def nav_items(ui: cui.UI, state: State) -> None:
    for index, (label, icon, badge) in enumerate(NAV_ITEMS):
        if ui.nav_item(label, icon=icon, selected=state.nav == index, badge=badge):
            state.nav = index
            state.drawer = False


def sidebar(ui: cui.UI, state: State) -> None:
    with ui.column(width=cui.Size.px(232), height=cui.Size.FILL, bg=SURFACE_MUTED, pad=12, gap=2):
        with ui.row(gap=10, pad_x=8, pad_top=6, pad_bottom=16):
            with ui.box(width=cui.Size.px(26), height=cui.Size.px(26), radius=7, bg=FOREGROUND,
                        dir=cui.Dir.STACK, align=cui.Align.CENTER, justify=cui.Justify.CENTER):
                ui.text("L", font=cui.DISPLAY, size=14, color=BACKGROUND)
            ui.text("Larkspur Supply", font=cui.MEDIUM, size=15, nowrap=True)
        nav_items(ui, state)
        ui.spacer()
        with ui.card(pad=16, gap=10):
            ui.text("Next payout", size=12, color=TEXT_SECONDARY)
            ui.text("$4,812.30", font=cui.DISPLAY, size=20, tabular=True)
            ui.text("To the account ending 4417 on Nov 8.", size=12, color=TEXT_SECONDARY)


def topbar(ui: cui.UI, state: State) -> None:
    narrow = compact(ui)
    with ui.row(gap=8 if narrow else 12, pad_x=12 if narrow else 32, pad_y=14, width=cui.Size.FILL):
        if narrow and ui.icon_button(cui.Icon.MENU, tooltip="Menu"):
            state.drawer = True
        with ui.box(width=cui.Size.grow(4), max_width=320):
            result = ui.search("search", value=state.search,
                               placeholder="Search orders, customers")
            state.search = result.text
        ui.spacer()
        mode = ui.get_theme_mode()
        icon = cui.Icon.SUN if mode == cui.ThemeMode.DARK else cui.Icon.MOON
        if ui.icon_button(icon, tooltip="Toggle theme"):
            state.dark = mode != cui.ThemeMode.DARK
            ui.set_theme(cui.ThemeMode.DARK if state.dark else cui.ThemeMode.LIGHT)
        ui.icon_button(cui.Icon.BELL, tooltip="Notifications")

        def account_menu(menu_ui: cui.UI) -> None:
            menu_ui.menu_label("nora@larkspur.co")
            menu_ui.menu_item("Profile", icon=cui.Icon.USER)
            menu_ui.menu_item("Billing", icon=cui.Icon.CREDIT_CARD)
            menu_ui.menu_item("Keyboard shortcuts", icon=cui.Icon.KEYBOARD, shortcut="?")
            menu_ui.menu_separator()
            menu_ui.menu_item("Log out", icon=cui.Icon.LOG_OUT)

        ui.menu("Account", icon=cui.Icon.CIRCLE_USER, variant=cui.ButtonVariant.GHOST,
                placement=cui.Placement.BOTTOM_END, body=account_menu)


def kpi(ui: cui.UI, label: str, value: str, change: str, good: bool) -> None:
    with ui.column(width=cui.Size.grow(1), pad_x=22, gap=6):
        ui.text(label, size=13, color=TEXT_SECONDARY)
        # the figures roll when the range changes
        ui.number_roll(label, value, font=cui.DISPLAY, size=26)
        ui.text(change, size=12, color=SUCCESS if good else DANGER)


def content(ui: cui.UI, state: State) -> None:
    narrow = compact(ui)

    with ui.row(gap=12, wrap=True, width=cui.Size.FILL):
        with ui.column(gap=4, width=cui.Size.FILL, min_width=220):
            ui.heading("Overview", level=2)
            ui.secondary("November 1 to 30, all channels")
        state.range = ui.segmented("range", ("7 days", "30 days", "12 months"),
                                   index=state.range, size=cui.ControlSize.SM)
        ui.button("Export", icon=cui.Icon.DOWNLOAD, size=cui.ControlSize.SM)

    # one strip of figures rather than four look-alike cards; the chart below
    # carries the trend
    with ui.card(dir=cui.Dir.ROW, gap=0, pad=0):
        revenue = ("$15,830", "$64,210", "$702,480")
        orders = ("318", "1,286", "14,903")
        conversion = ("4.3%", "4.1%", "3.8%")
        refunds = ("1.5%", "1.7%", "2.0%")
        since = ("on last week", "on October", "on last year")
        k = state.range
        revenue_change = f"{'+31.0%' if k == 2 else '+12.4%' if k else '+3.1%'} {since[k]}"
        orders_change = f"{'+22.6%' if k == 2 else '+7.3%' if k else '+1.9%'} {since[k]}"
        # without room for four figures in a strip, two per line and no hairlines
        room = ui.context.size[0] - (32 if narrow else 297)
        two = room < 720
        with ui.box(dir=cui.Dir.GRID if two else cui.Dir.ROW, columns=2, width=cui.Size.FILL,
                    gap=20 if two else 0, pad_y=4 if two else 0):
            kpi(ui, "Revenue", revenue[k], revenue_change, True)
            if not two:
                ui.separator()
            kpi(ui, "Orders", orders[k], orders_change, True)
            if not two:
                ui.separator()
            kpi(ui, "Conversion", conversion[k],
                "+0.6 pts" if k == 2 else "+0.4 pts" if k else "+0.2 pts", True)
            if not two:
                ui.separator()
            kpi(ui, "Refund rate", refunds[k],
                "-0.3 pts, fewer returns" if k == 2
                else "-0.6 pts, fewer returns" if k else "-0.2 pts, fewer returns", True)

    with ui.row(gap=16, align=cui.Align.STRETCH, wrap=True, width=cui.Size.FILL):
        with ui.card(gap=16, width=cui.Size.grow(2), min_width=300):
            with ui.row():
                with ui.column(gap=2, width=cui.Size.FILL):
                    ui.text("Revenue", font=cui.MEDIUM)
                    ui.text("Compared with last year", size=12, color=TEXT_SECONDARY)
                ui.badge("+18%", tone=cui.Tone.SUCCESS, icon=cui.Icon.TRENDING_UP)
            series = (cui.Series("This year", THIS_YEAR), cui.Series("Last year", LAST_YEAR))
            ui.line_chart("rev", series, labels=MONTHS, label_count=12, area=True, smooth=True,
                          height=230, format="$%.0fk")
        with ui.card(gap=16, width=cui.Size.grow(1), min_width=260):
            with ui.column(gap=2):
                ui.text("Where orders come from", font=cui.MEDIUM)
                ui.text("Share of November orders", size=12, color=TEXT_SECONDARY)
            with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, justify=cui.Justify.CENTER):
                ui.donut_chart("src", SOURCE_SHARE, SOURCES, height=170, format="%.0f%%")

    with ui.card(gap=14):
        with ui.row():
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.text("Recent orders", font=cui.MEDIUM)
                ui.text("Newest first", size=12, color=TEXT_SECONDARY)
            ui.button("View all", variant=cui.ButtonVariant.GHOST, icon_right=cui.Icon.ARROW_RIGHT,
                      size=cui.ControlSize.SM)
        columns = (
            cui.TableColumn("Order", cui.Size.px(90), cui.TextAlign.LEFT, True),
            cui.TableColumn("Customer", cui.Size.FILL, cui.TextAlign.LEFT, True),
            cui.TableColumn("Date", cui.Size.px(90), cui.TextAlign.LEFT, False),
            cui.TableColumn("Status", cui.Size.px(120), cui.TextAlign.LEFT, True),
            cui.TableColumn("Amount", cui.Size.px(110), cui.TextAlign.RIGHT, True),
        )
        with ui.table("orders", columns, selectable=True) as table:
            if table.result:
                for index, order in enumerate(ORDERS):
                    if state.search and (state.search not in order.customer
                                         and state.search not in order.id):
                        continue
                    if table.row(state.selected == index):
                        state.selected = index
                    table.cell_text(order.id)
                    table.cell()
                    ui.avatar(order.customer, size=28)
                    with ui.column(gap=0, width=cui.Size.FILL):
                        ui.text(order.customer, font=cui.MEDIUM, nowrap=True)
                        ui.text(order.email, size=12, color=TEXT_SECONDARY, nowrap=True)
                    table.cell_text(order.date)
                    table.cell()
                    ui.badge(order.status, tone=order.tone, dot=True)
                    table.cell_text(f"${order.amount:.2f}")
        with ui.row(wrap=True, gap=8, width=cui.Size.FILL):
            with ui.box(width=cui.Size.FILL, min_width=200):
                ui.text("Showing 1 to 6 of 1,286 orders", size=12, color=TEXT_SECONDARY)
            state.page = ui.pagination("pages", 215, page=state.page)


def frame(ui: cui.UI, state: State) -> None:
    if ui.shortcut(cui.Mod.PRIMARY, cui.Key.KEY_K):
        state.palette = True

    narrow = compact(ui)
    if not narrow:
        state.drawer = False
    with ui.row(width=cui.Size.FILL, height=cui.Size.FILL, align=cui.Align.STRETCH, bg=BACKGROUND):
        if not narrow:
            sidebar(ui, state)
            ui.separator()
        with ui.column(width=cui.Size.FILL):
            topbar(ui, state)
            ui.separator()
            with ui.scroll(id="content", pad=16 if narrow else 32, gap=16 if narrow else 24,
                           fade_edges=True):
                content(ui, state)

    def drawer_body(sheet_ui: cui.UI) -> None:
        nav_items(sheet_ui, state)

    still_open = ui.sheet("Larkspur Supply", open=state.drawer, side=cui.Side.LEFT, size=280,
                          body=drawer_body)
    state.drawer = state.drawer and still_open

    commands = (
        cui.Command("Create order", cui.Icon.PLUS, "Actions", "Ctrl N"),
        cui.Command("Add customer", cui.Icon.USER_PLUS, "Actions", None),
        cui.Command("Export report", cui.Icon.DOWNLOAD, "Actions", None),
        cui.Command("Go to analytics", cui.Icon.CHART_BAR, "Navigation", None),
    )
    chosen, state.palette = ui.command_palette(commands, open=state.palette)
    if chosen >= 0:
        ui.toast(commands[chosen].title, tone=cui.Tone.SUCCESS)


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Larkspur Dashboard", width=1360, height=900,
                          accent=cui.Accent.BLUE))
