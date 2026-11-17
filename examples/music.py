"""Music player: cover art, a track list, a "made for you" grid and a transport bar.

Ported from CUI's ``examples/music.c``.

    python examples/music.py
    python examples/music.py --shot dev/out/music.png

The album covers, equalizer and row highlights are custom-painted with
``ui.canvas``; the rest mixes stock components with generated cover art.
"""

from __future__ import annotations

import math

import cui

from _common import (
    ACCENT,
    BACKGROUND,
    FOREGROUND,
    HOVER,
    SURFACE,
    SURFACE_MUTED,
    TEXT_MUTED,
    TEXT_SECONDARY,
    TRANSPARENT,
    main,
)

ACTIVE = cui.Color.token(cui.Token.ACTIVE)

# title, artist, album, seconds, cover art index
TRACKS = [
    ("Low Tide", "Marlow Avenue", "Night Shift", 222, 0),
    ("Static Bloom", "Velvet Circuit", "Soft Machines", 247, 1),
    ("Low Orbit", "Kaito Mori", "Satellites", 198, 2),
    ("Paper Lanterns", "The Quiet Hours", "Ember", 263, 3),
    ("Glass Harbor", "Ilse Varga", "Tidal", 231, 4),
    ("After Hours", "Hollis & Grey", "Night Shift", 214, 0),
    ("Signal / Noise", "Pale Static", "Frequencies", 276, 5),
]

# Cover art: flat shapes in a few printed colors, like a screen printed sleeve.
# Each index picks a palette and a composition: terracotta, ink, sage, ochre,
# navy and cream.
PALETTES = [
    (0xC8553D, 0xF2E8CF, 0x2D3047),
    (0x2D3047, 0xE0A458, 0xF2E8CF),
    (0x5B8E7D, 0xF2E8CF, 0x2D3047),
    (0xE0A458, 0x2D3047, 0xC8553D),
    (0x1F3A5F, 0x8FB8DE, 0xF2E8CF),
    (0xF2E8CF, 0xC8553D, 0x2D3047),
]


class State:
    def __init__(self) -> None:
        self.nav = 0
        self.playing = 0
        self.playlist = 0
        self.paused = False
        self.shuffle = False
        self.liked = [True, False, True, False, False, False, False]
        self.position = 74.0
        self.volume = 70.0
        self.time = 0.0
        self.search = ""
        self.drawer = False
        self.playlist_hover = [False] * 5
        self.track_hover = [False] * len(TRACKS)


def compact(ui: cui.UI) -> bool:
    return ui.context.size[0] < 820


def fmt_time(seconds: int) -> str:
    return f"{seconds // 60}:{seconds % 60:02d}"


# -- custom painting -------------------------------------------------------


def paint_art(ui: cui.UI, art: int, radius: float, icon: bool):
    """The flat screen-printed sleeve for one palette/composition."""
    bg = cui.Color.rgb(PALETTES[art % 6][0])
    ca = cui.Color.rgb(PALETTES[art % 6][1])
    cb = cui.Color.rgb(PALETTES[art % 6][2])

    def paint(r: cui.Rect) -> None:
        s = r.w
        ui.draw_rect(r, bg, radius=radius)
        with ui.clip(r):
            kind = art % 6
            if kind == 0:  # a low sun and a small moon
                ui.draw_circle((r.x + s * 0.62, r.y + s * 0.70), s * 0.36, ca)
                ui.draw_circle((r.x + s * 0.24, r.y + s * 0.26), s * 0.09, cb)
            elif kind == 1:  # three bands
                for k in range(3):
                    ui.draw_rect(
                        cui.Rect(r.x, r.y + s * (0.22 + k * 0.2), s, s * 0.09),
                        cb if k == 1 else ca,
                    )
            elif kind == 2:  # a quarter disc in the corner, a bar across
                ui.draw_circle((r.x, r.y + s), s * 0.62, ca)
                ui.draw_rect(cui.Rect(r.x + s * 0.5, r.y + s * 0.18, s * 0.34, s * 0.08), cb)
            elif kind == 3:  # rings
                for k in (3, 2, 1):
                    ui.draw_arc(
                        (r.x + s * 0.5, r.y + s * 0.5),
                        s * 0.12 * k,
                        0,
                        6.2831853,
                        s * 0.035,
                        cb if k == 2 else ca,
                    )
            elif kind == 4:  # a grid of dots, one out of place
                for y in range(4):
                    for x in range(4):
                        ui.draw_circle(
                            (r.x + s * (0.2 + x * 0.2), r.y + s * (0.2 + y * 0.2)),
                            s * 0.045,
                            cb if (x == 2 and y == 1) else ca,
                        )
            else:  # half a disc on a line
                ui.draw_circle((r.x + s * 0.5, r.y + s * 0.58), s * 0.3, ca)
                ui.draw_rect(cui.Rect(r.x, r.y + s * 0.58, s, s * 0.42), bg)
                ui.draw_rect(cui.Rect(r.x + s * 0.1, r.y + s * 0.58, s * 0.8, s * 0.025), cb)
        if icon:
            ui.draw_icon(cui.Icon.MUSIC, r, s * 0.3, ui.api.alpha(cb, 0.9))

    return paint


def cover(ui: cui.UI, id: str, art: int, size: float, radius: float) -> None:
    ui.canvas(
        id,
        cui.Size.px(size),
        cui.Size.px(size),
        paint_art(ui, art, radius, False),
    )


def paint_eq(ui: cui.UI, t: float):
    """Equalizer bars for the playing row."""

    def paint(r: cui.Rect) -> None:
        for i in range(3):
            h = 4 + 8 * (0.5 + 0.5 * math.sin(t * 6 + i * 1.9))
            ui.draw_rect(
                cui.Rect(r.x + 2 + i * 4.5, r.y + r.h - 2 - h, 3, h),
                ACCENT,
                radius=1,
            )

    return paint


def row_background(ui: cui.UI, hovered: bool, selected: bool) -> tuple[bool, bool]:
    """The full-row highlight behind a list row; returns clicked and hovered."""

    def paint(r: cui.Rect) -> None:
        if selected:
            ui.draw_rect(r, ACTIVE, radius=10)
        elif hovered:
            ui.draw_rect(r, HOVER, radius=10)

    result = ui.canvas("bg", cui.Size.FILL, cui.Size.FILL, paint)
    return result.clicked, result.hovered


# -- sidebar ---------------------------------------------------------------


def library(ui: cui.UI, state: State) -> None:
    """Navigation and playlists: in the sidebar, or in a drawer when narrow."""
    items = ["Home", "Browse", "Radio"]
    icons = [cui.Icon.HOUSE, cui.Icon.COMPASS, cui.Icon.RADIO]
    for i in range(3):
        if ui.nav_item(items[i], icon=icons[i], selected=state.nav == i, group="nav"):
            state.nav = i
            state.drawer = False

    with ui.box(height=cui.Size.px(14)):
        pass

    with ui.row(pad_right=4, align=cui.Align.CENTER):
        with ui.box(width=cui.Size.FILL):
            ui.nav_section("Your library")
        ui.icon_button(cui.Icon.PLUS, size=cui.ControlSize.SM, tooltip="New playlist")

    lists = ["Late Night Coding", "Deep Focus", "Long Drive", "Morning Coffee", "Rainy Afternoons"]
    counts = ["48 songs", "112 songs", "64 songs", "37 songs", "29 songs"]

    with ui.id("library"):
        for i in range(5):
            with ui.id(i):
                with ui.box(dir=cui.Dir.STACK, width=cui.Size.FILL, height=cui.Size.px(52)):
                    clicked, state.playlist_hover[i] = row_background(
                        ui, state.playlist_hover[i], state.playlist == i
                    )
                    if clicked:
                        state.playlist = i
                        state.drawer = False
                    with ui.row(
                        width=cui.Size.FILL,
                        height=cui.Size.FILL,
                        pad_x=8,
                        gap=12,
                        align=cui.Align.CENTER,
                    ):
                        cover(ui, "art", 5 if i == 4 else i, 38, 8)
                        with ui.column(gap=0, width=cui.Size.FILL):
                            ui.text(lists[i], font=cui.MEDIUM, size=13, nowrap=True)
                            ui.text(counts[i], size=12, color=TEXT_MUTED, nowrap=True)


def sidebar(ui: cui.UI, state: State) -> None:
    with ui.column(
        width=cui.Size.px(248),
        height=cui.Size.FILL,
        bg=SURFACE_MUTED,
        pad=12,
        gap=2,
    ):
        with ui.row(
            gap=10,
            pad_x=6,
            pad_top=4,
            pad_bottom=14,
            align=cui.Align.CENTER,
        ):
            with ui.box(
                width=cui.Size.px(26),
                height=cui.Size.px(26),
                radius=13,
                bg=ACCENT,
                dir=cui.Dir.STACK,
                align=cui.Align.CENTER,
                justify=cui.Justify.CENTER,
            ):
                ui.icon(cui.Icon.AUDIO_LINES, 14, cui.Color.token(cui.Token.ACCENT_FOREGROUND))
            ui.text("Tempo", font=cui.MEDIUM, size=15)
        library(ui, state)


# -- main content ----------------------------------------------------------


def more_menu(ui: cui.UI) -> None:
    ui.menu_item("Add to queue", icon=cui.Icon.LIST)
    ui.menu_item("Share", icon=cui.Icon.SHARE_2)


def hero(ui: cui.UI, state: State) -> None:
    narrow = compact(ui)
    with ui.row(
        width=cui.Size.FILL,
        gap=20 if narrow else 28,
        align=cui.Align.END,
        wrap=True,
    ):
        art = 148 if narrow else 196
        ui.canvas(
            "hero-art",
            cui.Size.px(art),
            cui.Size.px(art),
            paint_art(ui, 0, 16, False),
        )
        with ui.column(gap=10, width=cui.Size.FILL, min_width=260):
            ui.text(
                "Late Night Coding",
                font=cui.DISPLAY,
                size=32 if narrow else 44,
                line_height=1.1,
            )
            ui.text(
                "Warm synths and steady beats for the hours after everyone has logged off.",
                color=TEXT_SECONDARY,
            )
            with ui.row(gap=8, align=cui.Align.CENTER):
                ui.avatar("Mara Quinn", size=22)
                ui.text("Mara Quinn", font=cui.MEDIUM, size=13)
                ui.text("·  48 songs  ·  3 h 12 min", size=13, color=TEXT_MUTED)
            with ui.box(height=cui.Size.px(4)):
                pass
            with ui.row(gap=8, align=cui.Align.CENTER, wrap=True):
                if ui.button(
                    "Play" if state.paused else "Pause",
                    icon=cui.Icon.PLAY if state.paused else cui.Icon.PAUSE,
                    variant=cui.ButtonVariant.PRIMARY,
                    size=cui.ControlSize.LG,
                ):
                    state.paused = not state.paused
                if ui.button(
                    "Shuffle",
                    icon=cui.Icon.SHUFFLE,
                    size=cui.ControlSize.LG,
                    variant=(
                        cui.ButtonVariant.SECONDARY
                        if state.shuffle
                        else cui.ButtonVariant.OUTLINE
                    ),
                ):
                    state.shuffle = not state.shuffle
                ui.icon_button(cui.Icon.HEART, size=cui.ControlSize.LG, tooltip="Save to library")
                ui.icon_button(cui.Icon.DOWNLOAD, size=cui.ControlSize.LG, tooltip="Download")
                ui.menu(
                    "More",
                    icon=cui.Icon.ELLIPSIS,
                    icon_only=True,
                    variant=cui.ButtonVariant.GHOST,
                    body=more_menu,
                )


def track_list(ui: cui.UI, state: State) -> None:
    album = ui.context.size[0] >= 600  # a phone shows the title, the artist and the length
    with ui.column(width=cui.Size.FILL, gap=2):
        with ui.row(
            width=cui.Size.FILL,
            pad_x=14,
            pad_bottom=8,
            gap=14,
            align=cui.Align.CENTER,
        ):
            ui.text(
                "#",
                size=12,
                color=TEXT_MUTED,
                width=cui.Size.px(18),
                align=cui.TextAlign.CENTER,
            )
            ui.text("Title", size=12, color=TEXT_MUTED, width=cui.Size.FILL)
            if album:
                ui.text("Album", size=12, color=TEXT_MUTED, width=cui.Size.px(180))
            with ui.box(width=cui.Size.px(28)):
                pass
            with ui.box(width=cui.Size.px(44), align=cui.Align.END):
                ui.icon(cui.Icon.CLOCK, 14, TEXT_MUTED)
        ui.separator()
        with ui.box(height=cui.Size.px(6)):
            pass
        with ui.id("tracks"):
            for i, track in enumerate(TRACKS):
                title, artist, album_name, seconds, art_index = track
                playing = state.playing == i
                with ui.id(i):
                    with ui.box(
                        dir=cui.Dir.STACK,
                        width=cui.Size.FILL,
                        height=cui.Size.px(56),
                    ):
                        clicked, state.track_hover[i] = row_background(
                            ui, state.track_hover[i], playing
                        )
                        if clicked:
                            state.playing = i
                            state.position = 0
                            state.paused = False
                        with ui.row(
                            width=cui.Size.FILL,
                            height=cui.Size.FILL,
                            pad_x=14,
                            gap=14,
                            align=cui.Align.CENTER,
                        ):
                            if playing and not state.paused:
                                ui.canvas(
                                    "eq",
                                    cui.Size.px(18),
                                    cui.Size.px(16),
                                    paint_eq(ui, state.time),
                                )
                            else:
                                ui.text(
                                    str(i + 1),
                                    size=13,
                                    color=ACCENT if playing else TEXT_MUTED,
                                    width=cui.Size.px(18),
                                    align=cui.TextAlign.CENTER,
                                    tabular=True,
                                )
                            with ui.row(gap=12, width=cui.Size.FILL, align=cui.Align.CENTER):
                                cover(ui, "art", art_index, 40, 8)
                                with ui.column(gap=1, width=cui.Size.FILL):
                                    ui.text(
                                        title,
                                        font=cui.MEDIUM,
                                        nowrap=True,
                                        color=ACCENT if playing else FOREGROUND,
                                    )
                                    ui.text(
                                        artist,
                                        size=13,
                                        color=TEXT_SECONDARY,
                                        nowrap=True,
                                    )
                            if album:
                                ui.text(
                                    album_name,
                                    size=13,
                                    color=TEXT_SECONDARY,
                                    width=cui.Size.px(180),
                                    nowrap=True,
                                )
                            liked = state.liked[i]
                            if ui.icon_button(
                                cui.Icon.HEART,
                                size=cui.ControlSize.SM,
                                color=ACCENT if liked else TEXT_MUTED,
                                tooltip="Remove from liked" if liked else "Like",
                            ):
                                state.liked[i] = not liked
                            ui.text(
                                fmt_time(seconds),
                                size=13,
                                color=TEXT_SECONDARY,
                                width=cui.Size.px(44),
                                align=cui.TextAlign.RIGHT,
                                tabular=True,
                            )


def made_for_you(ui: cui.UI) -> None:
    names = ["Daily Mix 1", "Focus Flow", "Discover Weekly", "Release Radar"]
    descriptions = [
        "Hollis & Grey, Kaito Mori and more",
        "Instrumental, no lyrics",
        "New music picked for you",
        "Fresh from artists you follow",
    ]
    with ui.row(width=cui.Size.FILL, align=cui.Align.CENTER):
        ui.text("Made for you", font=cui.DISPLAY, size=20, width=cui.Size.FILL)
        ui.button(
            "Show all",
            variant=cui.ButtonVariant.GHOST,
            size=cui.ControlSize.SM,
            icon_right=cui.Icon.ARROW_RIGHT,
        )
    with ui.box(
        dir=cui.Dir.GRID,
        columns=4,
        min_column_width=160,
        gap=16,
        width=cui.Size.FILL,
    ):
        for i in range(4):
            with ui.id(i):
                with ui.card(pad=12, gap=10, hoverable=True):
                    ui.canvas(
                        "art",
                        cui.Size.FILL,
                        cui.Size.px(150),
                        paint_art(ui, (i + 2) % 6, 10, False),
                    )
                    with ui.column(gap=2, width=cui.Size.FILL):
                        ui.text(names[i], font=cui.MEDIUM, nowrap=True)
                        ui.text(descriptions[i], size=12, color=TEXT_SECONDARY, nowrap=True)


# -- transport -------------------------------------------------------------


def player_bar(ui: cui.UI, state: State) -> None:
    track = TRACKS[state.playing]
    title, artist, _album, seconds, art_index = track
    narrow = compact(ui)
    with ui.row(
        width=cui.Size.FILL,
        height=cui.Size.px(72 if narrow else 84),
        pad_x=12 if narrow else 20,
        gap=8 if narrow else 24,
        align=cui.Align.CENTER,
        bg=SURFACE,
    ):
        with ui.row(
            width=cui.Size.FILL if narrow else cui.Size.px(300),
            gap=12,
            align=cui.Align.CENTER,
        ):
            cover(ui, "now-art", art_index, 52, 10)
            with ui.column(gap=2, width=cui.Size.FILL):
                ui.text(title, font=cui.MEDIUM, nowrap=True)
                ui.text(artist, size=12, color=TEXT_SECONDARY, nowrap=True)
            liked = state.liked[state.playing]
            if ui.icon_button(
                cui.Icon.HEART,
                size=cui.ControlSize.SM,
                color=ACCENT if liked else TEXT_MUTED,
                tooltip="Remove from liked" if liked else "Like",
            ):
                state.liked[state.playing] = not liked

        if narrow:  # a mini player: play and skip; the full controls need the width
            if ui.icon_button(
                cui.Icon.PLAY if state.paused else cui.Icon.PAUSE,
                variant=cui.ButtonVariant.PRIMARY,
                size=cui.ControlSize.LG,
                tooltip="Play" if state.paused else "Pause",
            ):
                state.paused = not state.paused
            if ui.icon_button(cui.Icon.SKIP_FORWARD, tooltip="Next"):
                state.playing = (state.playing + 1) % len(TRACKS)
                state.position = 0
            return

        with ui.column(width=cui.Size.FILL, gap=6, align=cui.Align.CENTER):
            with ui.row(gap=10, align=cui.Align.CENTER):
                if ui.icon_button(
                    cui.Icon.SHUFFLE,
                    size=cui.ControlSize.SM,
                    selected=state.shuffle,
                    color=ACCENT if state.shuffle else TRANSPARENT,
                    tooltip="Shuffle",
                ):
                    state.shuffle = not state.shuffle
                if ui.icon_button(cui.Icon.SKIP_BACK, tooltip="Previous"):
                    state.playing = (state.playing + len(TRACKS) - 1) % len(TRACKS)
                    state.position = 0
                if ui.icon_button(
                    cui.Icon.PLAY if state.paused else cui.Icon.PAUSE,
                    variant=cui.ButtonVariant.PRIMARY,
                    size=cui.ControlSize.LG,
                    tooltip="Play" if state.paused else "Pause",
                ):
                    state.paused = not state.paused
                if ui.icon_button(cui.Icon.SKIP_FORWARD, tooltip="Next"):
                    state.playing = (state.playing + 1) % len(TRACKS)
                    state.position = 0
                ui.icon_button(cui.Icon.REPEAT, size=cui.ControlSize.SM, tooltip="Repeat")
            with ui.row(width=cui.Size.FILL, gap=12, align=cui.Align.CENTER):
                ui.text(
                    fmt_time(int(state.position)),
                    size=12,
                    color=TEXT_MUTED,
                    tabular=True,
                    width=cui.Size.px(36),
                    align=cui.TextAlign.RIGHT,
                )
                state.position = ui.slider(
                    "##position",
                    value=state.position,
                    minimum=0,
                    maximum=seconds,
                    width=cui.Size.FILL,
                )
                ui.text(
                    fmt_time(seconds),
                    size=12,
                    color=TEXT_MUTED,
                    tabular=True,
                    width=cui.Size.px(36),
                )
        with ui.row(
            width=cui.Size.px(300),
            gap=8,
            align=cui.Align.CENTER,
            justify=cui.Justify.END,
        ):
            ui.icon_button(cui.Icon.MIC, size=cui.ControlSize.SM, tooltip="Lyrics")
            ui.icon_button(cui.Icon.LIST, size=cui.ControlSize.SM, tooltip="Queue")
            ui.icon(
                cui.Icon.VOLUME_2 if state.volume > 0 else cui.Icon.VOLUME_X,
                16,
                TEXT_SECONDARY,
            )
            state.volume = ui.slider(
                "##volume",
                value=state.volume,
                minimum=0,
                maximum=100,
                width=cui.Size.px(110),
            )


# -- frame -----------------------------------------------------------------


def frame(ui: cui.UI, state: State) -> None:
    now = ui.context.time
    dt = now - state.time if state.time > 0 else 0.0
    if dt > 0.25:
        dt = 0.25
    state.time = now
    if not state.paused:
        state.position += dt
        if state.position >= TRACKS[state.playing][3]:
            state.playing = (state.playing + 1) % len(TRACKS)
            state.position = 0
        ui.context.request_redraw()  # keep the clock and the equalizer moving

    if not ui.wants_keyboard() and ui.key_pressed(cui.Key.KEY_SPACE):
        state.paused = not state.paused

    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL, bg=BACKGROUND):
        narrow = compact(ui)
        if not narrow:
            state.drawer = False
        with ui.row(width=cui.Size.FILL, height=cui.Size.FILL, align=cui.Align.STRETCH):
            if not narrow:
                sidebar(ui, state)
                ui.separator()
            with ui.column(width=cui.Size.FILL):
                with ui.row(
                    width=cui.Size.FILL,
                    pad_x=12 if narrow else 32,
                    pad_y=14,
                    gap=8,
                    align=cui.Align.CENTER,
                ):
                    if narrow:
                        if ui.icon_button(cui.Icon.MENU, tooltip="Library"):
                            state.drawer = True
                    else:
                        ui.icon_button(cui.Icon.CHEVRON_LEFT, tooltip="Back")
                        ui.icon_button(cui.Icon.CHEVRON_RIGHT, tooltip="Forward")
                    with ui.box(width=cui.Size.grow(4), max_width=320):
                        typed = ui.search(
                            "search",
                            value=state.search,
                            placeholder="Songs, artists, podcasts",
                        )
                        state.search = typed.text
                    ui.spacer()
                    ui.icon_button(cui.Icon.BELL, tooltip="What's new")
                    ui.avatar("Mara Quinn", size=30)
                with ui.scroll(
                    id="main",
                    pad=16 if narrow else 32,
                    gap=20 if narrow else 28,
                    fade_edges=True,
                ):
                    hero(ui, state)
                    track_list(ui, state)
                    made_for_you(ui)
        ui.separator()
        player_bar(ui, state)

    state.drawer = ui.sheet(
        "Tempo",
        open=state.drawer,
        side=cui.Side.LEFT,
        size=300,
        body=lambda drawer_ui: library(drawer_ui, state),
    )


if __name__ == "__main__":
    raise SystemExit(
        main(
            frame,
            State(),
            title="Tempo",
            width=1440,
            height=1180,
            theme=cui.ThemeMode.DARK,
            accent=cui.Accent.CORAL,
        )
    )
