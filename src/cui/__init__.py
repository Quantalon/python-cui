"""CUI for Python: immediate-mode native UI, drawn by a C library.

    import cui

    state = {"name": ""}

    def frame(ui):
        with ui.column(pad=24, gap=12):
            ui.heading("Hello, CUI")
            state["name"] = ui.text_input("name", value=state["name"], label="Name").text

    cui.App().run(frame, title="Hello", width=900, height=600)

The widgets are CUI's own C components, called through generated Cython
wrappers; the low-level surface (one function per C function, option structs as
keyword arguments) lives in :mod:`cui._api`, and the friendly one in
:mod:`cui.ui`.
"""

from __future__ import annotations

import sys as _sys

from ._gen import constants as _constants
from ._cui import App, Context, DrawData, SoftwareRenderer, file_dialog
from ._types import (
    CanvasResult,
    ChartAnnotation,
    Color,
    Corners,
    Date,
    DotChartResult,
    DotSeries,
    EventTrackResult,
    KeyCombo,
    Rect,
    Series,
    Size,
    SizeKind,
    TextFlags,
    TextMetrics,
    TextResult,
    Vec2,
)

__version__ = "1.4.0.0"
CUI_VERSION = "1.4.0"

# Every enum and icon constant from CUI's headers: ThemeMode, Accent, Token,
# ButtonVariant, ControlSize, Tone, Key, Mod, ICON_PLUS, ...
globals().update({name: value for name, value in vars(_constants).items() if not name.startswith("_")})

# CUI spells the platform's main shortcut modifier as a macro alias.
Mod.PRIMARY = Mod.SUPER if _sys.platform == "darwin" else Mod.CTRL

from ._gen.model import *  # noqa: E402,F403  (the plain data structs as NamedTuples)
from .ui import UI  # noqa: E402

__all__ = [
    "App",
    "CanvasResult",
    "ChartAnnotation",
    "Color",
    "Context",
    "CUI_VERSION",
    "Corners",
    "Date",
    "DotChartResult",
    "DotSeries",
    "DrawData",
    "EventTrackResult",
    "KeyCombo",
    "Rect",
    "Series",
    "Size",
    "SizeKind",
    "SoftwareRenderer",
    "TextFlags",
    "TextMetrics",
    "TextResult",
    "UI",
    "Vec2",
    "__version__",
    "file_dialog",
]
__all__ += [name for name in vars(_constants) if not name.startswith("_")]
__all__ += [name for name in vars(_sys.modules[__name__]) if name[:1].isupper() and name not in __all__]
