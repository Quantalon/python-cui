"""Value classes for the plain data structs that CUI takes as arrays.

GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
"""

from __future__ import annotations

from typing import NamedTuple


class Candle(NamedTuple):
    """Candlestick chart: open, high, low and close per period with volume under it, for prices. The wheel zooms around the pointer, dragging (or Shift+wheel) pans, a crosshair shows each candle's values, and the price axis fits the candles in view. Zoomed out past a few points per candle, candles merge per pixel column, so a long history stays fast. When the view shows the newest candle it follows new ones as they are appended. With the chart focused, Left and Right move the crosshair (Shift: ten at a time), Home and End jump to the ends, + and - zoom and 0 fits everything. cui_candlestick(ui, "btc", candles, count, .labels = dates, .overlays = &sma, .overlay_count = 1);"""

    open: float = None
    high: float = None
    low: float = None
    close: float = None
    volume: float = None


class Choice(NamedTuple):
    """Radio cards: larger selectable cards for choices that need a description (plans, templates)."""

    title: str = None
    description: str = None
    icon: str = None
    badge: str = None


class Command(NamedTuple):
    """------------------------------------------------------------------------ */ /* Command palette (block)                                                  */ /* ------------------------------------------------------------------------"""

    title: str = None
    icon: str = None
    group: str = None
    shortcut: str = None


class CurveKey(NamedTuple):

    x: float = None
    y: float = None
    in_dx: float = None
    in_dy: float = None
    out_dx: float = None
    out_dy: float = None
    mode: int = None


class FlameSpan(NamedTuple):
    """Flame graph / profiler timeline: time runs left to right, call depth top to bottom (row d holds the spans at depth d). You own the spans, the view and the selection; the component pans and zooms *view and writes *selected. static cui_flame_view view;              (zeroed: fits every span) static int selected = -1; cui_flame_sort(spans, count);            (once, after recording) cui_flame_result r = cui_flame_graph(ui, "profile", spans, count, &view, &selected); if (r.selection_changed && selected >= 0) show_details(&spans[selected]); Times are seconds (any origin; the ruler counts from the earliest span). Spans must be sorted by depth, then start (cui_flame_sort does it), and spans of one depth must not overlap: a child lies within its parent. Only the spans in view are visited (binary searches per row), so captures of 100k spans stay fast; spans thinner than a pixel merge into a neutral run. The spans need to be valid only during the call. color_key picks the color (0: hashed from the name), so the same function keeps its color. Mouse: the wheel zooms around the pointer, Shift+wheel or a sideways scroll pans, drag pans (sideways and, for deep stacks, up and down). Click selects a span (empty space clears), double-click zooms to fit it (on empty space: fits everything). Hover shows a tooltip: name, duration and its share of the parent (or of the view, at depth 0). Keys when focused: Left/Right move to the previous/next span in the row, Up to the parent, Down to the first child (the view follows); Shift+Left/ Right pan; + and - zoom; Enter or Space zooms to the selection; Home or F fits everything; Esc fits everything, or when already fitted clears the selection. Zooming to a span or fitting animates (snaps with reduced motion). Not included: an aggregated (merged call tree) flame graph mode."""

    name: str = None
    start: float = None
    end: float = None
    depth: int = None
    color_key: int = None


class GradientStop(NamedTuple):
    """Gradient editor: a color ramp over a checkerboard (so alpha shows) with the stops underneath. You own the stops; the editor edits them in place and keeps them sorted by position. Drag a stop to move it (it may pass its neighbours), drag it off the ramp or press Delete to remove it (never fewer than two), click the ramp or the empty track to add a stop with the color found there. Double click a stop (or Enter on a focused one) to open the color picker; the row under the ramp shows the selected stop's color, location and opacity. Stops are focusable: Tab moves through them, Left and Right nudge (Shift for fine steps)."""

    pos: float = None
    color: Color = None


class GridColumn(NamedTuple):
    """A virtualized table for large data: sticky header, resizable and sortable columns, checkbox selection (click, Ctrl+click, Shift+click, Ctrl+A), keyboard navigation and editable cells. Build only the rows in [first, last): int first, last; if (cui_data_grid_begin(ui, "people", cols, 4, count, &first, &last, .selected = sel)) { for (int r = first; r < last; r++) { cui_data_grid_row(ui, r); cui_data_grid_cell_text(ui, people[r].name); ... } cui_data_grid_end(ui); }"""

    title: str = None
    width: float = None
    align: int = None
    sortable: bool = None
    fixed: bool = None
    priority: int = None


class MarkdownResult(NamedTuple):

    link: str = None
    hovered_link: str = None
    task_offset: int = None
    task_line: int = None
    task_checked: bool = None
    height: float = None


class Model(NamedTuple):
    """Model picker: the current model on a button; a list with details opens."""

    name: str = None
    detail: str = None
    badge: str = None
    icon: str = None


class PlanStep(NamedTuple):
    """Agent plan: steps with their status on a connected rail, and progress."""

    title: str = None
    detail: str = None
    status: int = None


class PresenceUser(NamedTuple):
    """Presence: who is here now. Overlapping avatars with a colored ring each, that spread out on hover and name themselves."""

    name: str = None
    color: Color = None
    avatar: int = None
    idle: bool = None


class PromptSuggestion(NamedTuple):
    """Prompt suggestions: cards to start a conversation with."""

    icon: str = None
    title: str = None
    detail: str = None


class SankeyLink(NamedTuple):
    """Sankey: flows between nodes; columns follow the links from the sources."""

    from_: int = None
    to: int = None
    value: float = None


class Source(NamedTuple):
    """Sources: cards for the documents an answer used, and inline citations that show a card on hover. Both return true / the index when clicked."""

    title: str = None
    url: str = None
    snippet: str = None


class SpeedAction(NamedTuple):
    """Speed dial: a round floating action button that fans out related actions. Returns the chosen action index, or -1."""

    icon: str = None
    label: str = None


class SwipeAction(NamedTuple):
    """Swipe actions: drag a row sideways (or swipe on a trackpad) to reveal actions behind it. A long swipe triggers the first action. The row content goes between begin and end; end returns the chosen action: 0..left_count-1 for left actions, 100 + i for right actions, or -1."""

    icon: str = None
    label: str = None
    tone: int = None


class TabBarItem(NamedTuple):
    """Bottom tab bar for compact layouts, with a pill that glides to the selection."""

    icon: str = None
    label: str = None
    badge: int = None


class TableColumn(NamedTuple):
    """Table"""

    title: str = None
    width: Size = None
    align: int = None
    sortable: bool = None


class TickerItem(NamedTuple):
    """Ticker: items that scroll by continuously, pausing on hover."""

    label: str = None
    value: str = None
    delta: float = None
    lower_is_better: bool = None


class TocItem(NamedTuple):
    """Table of contents for a scroll area: highlights the section in view on a progress rail, and scrolls to a section when clicked. Put cui_toc_anchor(ui, "anchor") at each heading inside the scroll area, and call cui_toc in the same scope as the scroll area. Returns the active index."""

    title: str = None
    anchor: str = None
    level: int = None


class TourStep(NamedTuple):
    """Guided tour: a spotlight on one control at a time, with a card beside it that says what the control does, for onboarding and "what's new". The rest of the window dims; the spotlight glides from one control to the next. Call it after the controls it points at, every frame while *step is 0 or more; it sets *step to -1 when the tour ends. Right or Enter go to the next step, Left goes back and Esc ends the tour. static int step = 0; cui_button(ui, "Export");  steps[1].target = cui_last_id(ui); ... if (step >= 0) cui_tour(ui, "intro", steps, 4, &step);"""

    target: int = None
    title: str = None
    body: str = None
    placement: int = None


class VizItem(NamedTuple):
    """Treemap: rectangles with areas proportional to their values."""

    label: str = None
    value: float = None
    color: Color = None

