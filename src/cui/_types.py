"""Value types shared by the high-level API and the generated wrappers.

Everything here is a small immutable value: it converts to one of CUI's plain
C structs at the call site and costs nothing to pass around.
"""

from __future__ import annotations

from typing import NamedTuple

__all__ = [
    "Color",
    "Size",
    "SizeKind",
    "TextResult",
    "TextFlags",
    "Date",
    "Rect",
    "Vec2",
    "TextMetrics",
    "Corners",
    "KeyCombo",
]


class Color(NamedTuple):
    """An RGBA color, or a semantic theme token.

    Three ways to write one, all accepted by every ``color=`` argument::

        Color(255, 0, 0)            # plain RGBA
        Color.rgb(0xE5484D)        # packed RGB
        Color.token(Token.ACCENT)  # follows the theme and the accent
    """

    r: int
    g: int
    b: int
    a: int = 255

    def __repr__(self):  # pragma: no cover - cosmetic
        return f"Color(0x{self.r:02x}{self.g:02x}{self.b:02x}, a={self.a})"

    @classmethod
    def rgb(cls, value: int, alpha: int = 255) -> Color:
        """Build from a packed ``0xRRGGBB`` integer."""
        return cls((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, alpha)

    @classmethod
    def rgba(cls, value: int) -> Color:
        """Build from a packed ``0xRRGGBBAA`` integer."""
        return cls((value >> 24) & 0xFF, (value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)

    @classmethod
    def token(cls, token) -> Color:
        """Build the placeholder CUI resolves against the current theme.

        CUI encodes a token color as ``(token index, 0xC5, 0x1D, 0)``; that is
        what ``cui_color`` values produced by ``CUI_TOKEN_COLOR`` look like, and
        exactly what this returns.
        """
        return cls(int(token), 0xC5, 0x1D, 0)

    def with_alpha(self, alpha: int) -> Color:
        return Color(self.r, self.g, self.b, alpha)

    @property
    def is_token(self) -> bool:
        """True when this color is a theme token rather than a literal."""
        return self.g == 0xC5 and self.b == 0x1D and self.a == 0

    @property
    def packed(self) -> int:
        """``0xRRGGBBAA``."""
        return (self.r << 24) | (self.g << 16) | (self.b << 8) | self.a


class SizeKind:
    """How a :class:`Size` is resolved (mirrors ``cui_size_kind``)."""

    FIT = 0
    GROW = 1
    FIXED = 2
    PERCENT = 3


class Size(NamedTuple):
    """A width or height: fit the content, grow, fixed points or a percent.

    Most arguments take a plain number (points) or one of the constructors::

        Size.FILL          # grow to fill the parent
        Size.fit()         # the smallest that fits the content
        Size.px(240)       # 240 points
        Size.percent(50)   # half the parent
        Size.grow(2)       # share of the free space, weighted
    """

    kind: int
    value: float = 0.0

    def __repr__(self):  # pragma: no cover - cosmetic
        names = {0: "fit", 1: "grow", 2: "px", 3: "%"}
        return f"Size.{names.get(self.kind, self.kind)}({self.value:g})"

    @classmethod
    def fit(cls) -> Size:
        return cls(SizeKind.FIT, 0.0)

    @classmethod
    def grow(cls, weight: float = 1.0) -> Size:
        return cls(SizeKind.GROW, weight)

    @classmethod
    def px(cls, points: float) -> Size:
        return cls(SizeKind.FIXED, points)

    @classmethod
    def percent(cls, percent: float) -> Size:
        return cls(SizeKind.PERCENT, percent)


Size.FILL = Size(SizeKind.GROW, 1.0)  # type: ignore[attr-defined]
Size.FIT = Size(SizeKind.FIT, 0.0)  # type: ignore[attr-defined]


class TextFlags:
    """Bits returned by CUI's editable text components."""

    CHANGED = 1
    SUBMITTED = 2
    FOCUSED = 4
    BLURRED = 8


class TextResult(NamedTuple):
    """What a text field returned this frame.

    The text is the buffer *after* the call: CUI edits it in place, so
    ``state.name = ui.text_input("name", value=state.name).text`` keeps the
    caret and selection working across frames.
    """

    text: str
    flags: int = 0

    @property
    def changed(self) -> bool:
        return bool(self.flags & TextFlags.CHANGED)

    @property
    def submitted(self) -> bool:
        return bool(self.flags & TextFlags.SUBMITTED)

    @property
    def focused(self) -> bool:
        return bool(self.flags & TextFlags.FOCUSED)

    @property
    def blurred(self) -> bool:
        return bool(self.flags & TextFlags.BLURRED)


class Date(NamedTuple):
    """A calendar date (month is 1..12)."""

    year: int
    month: int
    day: int

    @classmethod
    def today(cls) -> Date:
        import datetime

        now = datetime.date.today()
        return cls(now.year, now.month, now.day)

    @classmethod
    def from_date(cls, value) -> Date:
        return cls(value.year, value.month, value.day)

    def to_date(self):
        import datetime

        return datetime.date(self.year, self.month, self.day)

    def __repr__(self):  # pragma: no cover - cosmetic
        return f"Date({self.year}, {self.month}, {self.day})"


class Rect(NamedTuple):
    x: float
    y: float
    w: float
    h: float


class Vec2(NamedTuple):
    x: float
    y: float


class TextMetrics(NamedTuple):
    width: float
    height: float
    ascent: float
    descent: float
    line_height: float


class Corners(NamedTuple):
    """Per-corner radii; a plain number means the same radius everywhere."""

    tl: float = 0.0
    tr: float = 0.0
    br: float = 0.0
    bl: float = 0.0


class KeyCombo(NamedTuple):
    """A recorded keyboard shortcut: modifier bits plus a key."""

    mods: int = 0
    key: int = 0
