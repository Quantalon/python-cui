"""The friendly, Pythonic facade over CUI's immediate-mode API.

    with ui.column(pad=24, gap=12):
        ui.heading("Settings", level=2)
        notify = ui.switch("Notifications", value=notify)
        name = ui.text_input("name", value=name, label="Name").text

Every method maps onto one CUI component.  Containers are context managers, so
the C ``begin``/``end`` pair cannot get out of balance, even when the body
raises.  Components whose C form returns the new state of a value return that
value directly: a switch returns a bool, a slider a float, a select an index.

The lower-level surface — one function per CUI function, option structs as
keyword arguments — is still reachable as ``ui.api`` or by importing
``cui._api``.
"""

from __future__ import annotations

from typing import Any, Callable, Iterable, Sequence

from . import _api
from ._cui import Context
from ._types import Color, Date, Rect, Size, TextResult


class _Block:
    """A container opened by a ``with`` statement."""

    def __init__(self, ui: "UI", begin: Callable[[], Any], end: Callable[[], Any]):
        self._ui = ui
        self._begin = begin
        self._end = end
        self.result: Any = None

    def __enter__(self) -> "_Block":
        self.result = self._begin()
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        self._end()
        return False

    def __getattr__(self, name: str) -> Any:
        return getattr(self._ui, name)


class _Card(_Block):
    """A card; ``clicked`` is available once the block has closed."""

    @property
    def clicked(self) -> bool:
        return bool(self.result)

    def __enter__(self) -> "_Card":
        self.result = self._begin()
        return self


class _Scope:
    """An identity or disabled scope: ``with ui.id('row3'):``."""

    def __init__(self, push: Callable[[], Any], pop: Callable[[], Any]):
        self._push = push
        self._pop = pop

    def __enter__(self) -> "_Scope":
        self._push()
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        self._pop()
        return False


class UI:
    """The component API, bound to one :class:`cui.Context`."""

    __slots__ = ("_ctx",)

    def __init__(self, context: Context):
        self._ctx = context

    def __repr__(self):
        return f"<cui.UI {self._ctx!r}>"

    # -- escape hatches ----------------------------------------------------

    @property
    def context(self) -> Context:
        """The underlying :class:`cui.Context` (frame control, ids, rendering)."""
        return self._ctx

    @property
    def api(self):
        """The generated low-level module, for components without a facade yet."""
        return _api

    def __getattr__(self, name: str):
        # Fall back to the generated wrapper layer so every CUI function is
        # reachable as ui.<name>(...) without needing a facade method.
        function = getattr(_api, name, None)
        if function is None or name.startswith("_"):
            raise AttributeError(name)
        import functools

        return functools.partial(function, self._ctx)

    # -- containers --------------------------------------------------------

    def column(self, **opts) -> _Block:
        """A vertical box (CUI's default direction)."""
        return _Block(self, lambda: _api.column_begin(self._ctx, **opts), lambda: _api.box_end(self._ctx))

    def row(self, **opts) -> _Block:
        """A horizontal box; ``gap`` and ``align`` do most of the work."""
        return _Block(self, lambda: _api.row_begin(self._ctx, **opts), lambda: _api.box_end(self._ctx))

    def box(self, dir: int | None = None, **opts) -> _Block:
        """Any box: pick the direction with ``dir=Dir.ROW`` or ``Dir.GRID``."""
        if dir is None:
            return _Block(self, lambda: _api.box_begin(self._ctx, **opts), lambda: _api.box_end(self._ctx))
        return _Block(
            self,
            lambda: _api.box_begin(self._ctx, dir=dir, **opts),
            lambda: _api.box_end(self._ctx),
        )

    def grid(self, columns: int = 2, **opts) -> _Block:
        """A grid with a fixed column count."""
        from ._gen.constants import Dir

        return _Block(
            self,
            lambda: _api.box_begin(self._ctx, dir=Dir.GRID, columns=columns, **opts),
            lambda: _api.box_end(self._ctx),
        )

    def card(self, **opts) -> _Card:
        """A bordered surface. ``with ui.card() as card:`` then ``card.clicked``."""
        return _Card(self, lambda: _api.card_begin(self._ctx, **opts), lambda: _api.card_end(self._ctx))

    def scroll(self, **opts) -> _Block:
        """A scroll area with smooth scrolling and overlay scrollbars."""
        return _Block(self, lambda: _api.scroll_begin(self._ctx, **opts), lambda: _api.scroll_end(self._ctx))

    def toolbar(self, id: str, **opts) -> _Block:
        return _Block(self, lambda: _api.toolbar_begin(self._ctx, id, **opts), lambda: _api.toolbar_end(self._ctx))

    def id(self, value: str | int) -> _Scope:
        """Scope the identity of the widgets inside, like CUI's ``push_id``."""
        return _Scope(lambda: self._ctx.push_id(value), self._ctx.pop_id)

    def disabled(self, disabled: bool = True) -> _Scope:
        """Draw the components inside in their disabled state."""
        return _Scope(lambda: self._ctx.push_disabled(disabled), self._ctx.pop_disabled)

    # -- text --------------------------------------------------------------

    def text(self, text: str, **opts) -> None:
        _api.text(self._ctx, text, **opts)

    def heading(self, text: str, level: int = 1) -> None:
        _api.heading(self._ctx, text, level)

    def label(self, text: str, **opts) -> None:
        # `label` has no options of its own in CUI; text_opts still apply.
        _api.text(self._ctx, text, **opts)

    def secondary(self, text: str) -> None:
        _api.secondary(self._ctx, text)

    def muted(self, text: str) -> None:
        _api.muted(self._ctx, text)

    def code(self, text: str) -> None:
        _api.code(self._ctx, text)

    def kbd(self, keys: str) -> None:
        _api.kbd(self._ctx, keys)

    def link(self, text: str) -> bool:
        return _api.link(self._ctx, text)

    def icon(self, icon: str, size: float = 16.0, color: Color | None = None) -> None:
        _api.icon(self._ctx, icon, size, color)

    def separator(self) -> None:
        _api.separator(self._ctx)

    def spacer(self) -> None:
        _api.spacer(self._ctx)

    def gap(self, size: float) -> None:
        _api.gap(self._ctx, size)

    # -- buttons -----------------------------------------------------------

    def button(
        self,
        label: str,
        *,
        variant: int | None = None,
        icon: str | None = None,
        disabled: bool = False,
        **opts,
    ) -> bool:
        """A button; true on the frame it is clicked."""
        return _api.button(
            self._ctx, label, variant=variant, icon=icon, disabled=disabled, **opts
        )

    def icon_button(
        self,
        icon: str,
        *,
        variant: int | None = None,
        disabled: bool = False,
        **opts,
    ) -> bool:
        """A square button with only an icon (give it a tooltip in ``opts``)."""
        return _api.icon_button(self._ctx, icon, variant=variant, disabled=disabled, **opts)

    def link_button(self, label: str, **opts) -> bool:
        return _api.button(self._ctx, label, variant=6, **opts)

    # -- selection ---------------------------------------------------------

    def checkbox(self, label: str, value: bool = False, **opts) -> bool:
        """A checkbox; returns the new value."""
        return _api.checkbox(self._ctx, label, value=value, **opts)[1]

    def switch(self, label: str, value: bool = False, **opts) -> bool:
        """A switch; returns the new value."""
        return _api.switch(self._ctx, label, value=value, **opts)[1]

    def radio(self, label: str, value: int, option: int, **opts) -> int:
        """One radio button; returns the selected index."""
        return _api.radio(self._ctx, label, option, value=value, **opts)[1]

    def radio_group(self, id: str, items: Sequence[str], index: int = 0) -> int:
        return _api.radio_group(self._ctx, id, items, index=index)[1]

    def slider(
        self,
        label: str,
        value: float = 0.0,
        minimum: float = 0.0,
        maximum: float = 100.0,
        **opts,
    ) -> float:
        """A slider; returns the new value."""
        return _api.slider(self._ctx, label, minimum, maximum, value=value, **opts)[1]

    def range_slider(
        self,
        label: str,
        lo: float,
        hi: float,
        minimum: float = 0.0,
        maximum: float = 100.0,
    ) -> tuple[float, float]:
        changed, low, high = _api.range_slider(self._ctx, label, lo, hi, minimum, maximum)
        return (low, high)

    def rating(self, id: str, max: int = 5, value: int = 0) -> int:
        return _api.rating(self._ctx, id, max, value=value)[1]

    def segmented(self, id: str, items: Sequence[str], index: int = 0, **opts) -> int:
        return _api.segmented(self._ctx, id, items, index=index, **opts)[1]

    def chip(self, label: str, selected: bool = False, **opts) -> bool:
        return _api.chip(self._ctx, label, selected=selected, **opts)[1]

    def toggle_group(self, id: str, labels: Sequence[str], values=False, **opts):
        """A row of toggles; returns the new values (a bool or a list)."""
        return _api.toggle_group(self._ctx, id, labels, values=values, **opts)[1]

    # -- text input --------------------------------------------------------

    def text_input(self, id: str, value: str = "", **opts) -> TextResult:
        """Single-line text field; the result carries the edited text and flags."""
        return _api.input(self._ctx, id, text=value, **opts)

    # `input` is CUI's name for the same component.
    input_text = text_input

    def textarea(self, id: str, value: str = "", **opts) -> TextResult:
        return _api.textarea(self._ctx, id, text=value, **opts)

    def search(self, id: str, value: str = "", **opts) -> TextResult:
        return _api.search(self._ctx, id, text=value, **opts)

    def tag_input(self, id: str, value: str = "", **opts) -> TextResult:
        return _api.tag_input(self._ctx, id, text=value, **opts)

    def number(
        self,
        id: str,
        value: float = 0.0,
        minimum: float = 0.0,
        maximum: float = 100.0,
        **opts,
    ) -> float:
        return _api.number(self._ctx, id, minimum, maximum, value=value, **opts)[1]

    def money_input(self, id: str, value: float = 0.0, **opts) -> float:
        return _api.money_input(self._ctx, id, value=value, **opts)[1]

    def inline_edit(self, id: str, value: str = "", **opts) -> TextResult:
        return _api.inline_edit(self._ctx, id, text=value, **opts)

    # -- pickers -----------------------------------------------------------

    def select(self, id: str, items: Sequence[str], index: int = 0, **opts) -> int:
        """A select/dropdown; returns the selected index."""
        return _api.select(self._ctx, id, items, index=index, **opts)[1]

    def multi_select(self, id: str, items: Sequence[str], selected=False, **opts):
        return _api.multi_select(self._ctx, id, items, selected=selected, **opts)[1]

    def tabs(self, id: str, items: Sequence[str], index: int = 0, **opts) -> int:
        """Tab strip; returns the selected index."""
        return _api.tabs(self._ctx, id, items, index=index, **opts)[1]

    def date_picker(self, id: str, value: Date | None = None, **opts) -> Date:
        return _api.date_picker(self._ctx, id, value=value, **opts)[1]

    def calendar(self, id: str, value: Date | None = None) -> Date:
        return _api.calendar(self._ctx, id, value=value)[1]

    def color_picker(self, id: str, value: Color | None = None) -> Color:
        return _api.color_picker(self._ctx, id, value=value)[1]

    def time_picker(self, id: str, hour: int = 0, minute: int = 0, **opts):
        return _api.time_picker(self._ctx, id, hour, minute, **opts)

    # -- navigation --------------------------------------------------------

    def nav_item(self, label: str, **opts) -> bool:
        return _api.nav_item(self._ctx, label, **opts)

    def nav_section(self, title: str) -> None:
        _api.nav_section(self._ctx, title)

    def breadcrumb(self, items: Sequence[str]) -> int:
        """Returns the clicked index, or -1."""
        return _api.breadcrumb(self._ctx, items)

    def pagination(self, id: str, page_count: int, page: int = 0) -> int:
        return _api.pagination(self._ctx, id, page_count, page=page)[1]

    def stepper(self, steps: Sequence[str], current: int) -> None:
        _api.stepper(self._ctx, steps, current)

    # -- data display ------------------------------------------------------

    def badge(self, text: str, **opts) -> None:
        _api.badge(self._ctx, text, **opts)

    def avatar(self, name: str, **opts) -> None:
        _api.avatar(self._ctx, name, **opts)

    def progress(self, value: float, **opts) -> None:
        """A progress bar; ``value`` is 0..1."""
        _api.progress(self._ctx, value, **opts)

    def spinner(self, size: float = 16.0) -> None:
        _api.spinner(self._ctx, size)

    def skeleton(self, width: float = 200.0, height: float = 12.0) -> None:
        _api.skeleton(self._ctx, width, height)

    def alert(self, title: str, **opts) -> None:
        _api.alert(self._ctx, title, **opts)

    def toast(self, title: str, **opts) -> None:
        _api.toast(self._ctx, title, **opts)

    def metric(self, label: str, value: str, **opts) -> None:
        _api.metric(self._ctx, label, value, **opts)

    def empty_state(self, title: str, **opts) -> None:
        _api.empty_state(self._ctx, title, **opts)

    def tooltip(self, text: str) -> None:
        """Attach a tooltip to the previous component."""
        _api.tooltip(self._ctx, text)

    def image(self, texture: int, rect: Rect, **opts) -> None:
        _api.image(self._ctx, texture, rect, **opts)

    # -- overlays (callback style) ----------------------------------------

    def dialog(self, title: str, *, open: bool, body: Callable[["UI"], None] | None = None, **opts) -> bool:
        """A modal dialog. Returns the new ``open`` state."""
        visible, new_open = _api.dialog_begin(self._ctx, title, open=open, **opts)
        if visible and body is not None:
            body(self)
        _api.dialog_end(self._ctx)
        return bool(new_open)

    def sheet(self, title: str, *, open: bool, body: Callable[["UI"], None] | None = None, **opts) -> bool:
        visible, new_open = _api.sheet_begin(self._ctx, title, open=open, **opts)
        if visible and body is not None:
            body(self)
        _api.sheet_end(self._ctx)
        return bool(new_open)

    def menu(self, label: str, *, body: Callable[["UI"], None], **opts) -> bool:
        """A dropdown menu anchored to the previous component."""
        visible = _api.menu_begin(self._ctx, label, **opts)
        if visible:
            body(self)
        _api.menu_end(self._ctx)
        return bool(visible)

    def popover(self, id: str, *, body: Callable[["UI"], None], **opts) -> None:
        visible = _api.popover_begin(self._ctx, id, **opts)
        if visible:
            body(self)
        _api.popover_end(self._ctx)

    def accordion(self, title: str, *, open: bool = False, body: Callable[["UI"], None] | None = None, **opts) -> bool:
        visible, new_open = _api.accordion_begin(self._ctx, title, open=open, **opts)
        if visible and body is not None:
            body(self)
        _api.accordion_end(self._ctx)
        return bool(new_open)

    def menu_item(self, label: str, **opts) -> bool:
        """A row inside a menu."""
        return _api.menu_item(self._ctx, label, **opts)

    def menu_separator(self) -> None:
        _api.menu_separator(self._ctx)

    def dialog_footer(self, body: Callable[["UI"], None]) -> None:
        _api.dialog_footer_begin(self._ctx)
        body(self)
        _api.dialog_footer_end(self._ctx)
