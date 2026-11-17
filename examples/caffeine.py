"""Caffeine: how much is still in you at bedtime.

Ported from CUI's ``examples/caffeine.c``.

    python examples/caffeine.py
    python examples/caffeine.py --shot dev/out/caffeine.png

Drag a cup along the time axis, click the chart to add one, double-click a cup
to remove it: the curve, the peak and the verdict follow.  It shows the
instrument components together: a dot-matrix chart with annotations, an event
track under it, readouts and a dot-matrix display.
"""

from __future__ import annotations

import math

import cui

from _common import BACKGROUND, TEXT_MUTED, main

MAX_CUPS = 12
SAMPLES = 145  # every 10 minutes from 06:00 to 06:00
DAY_START = 6.0
DAY_END = 30.0
BEDTIME = 23.0
LIMIT_MG = 50.0
CUP_MG = 95.0
HALF_LIFE = 5.0


class State:
    def __init__(self) -> None:
        self.cups = [8.0, 10.75, 12.25]
        self.selected = 2


def cup_level(t: float) -> float:
    """One cup's caffeine at ``t`` hours after drinking it."""
    if t <= 0:
        return 0.0
    ke = math.log(2.0) / HALF_LIFE
    ka = math.log(2.0) / 0.25
    return CUP_MG * ka / (ka - ke) * (math.exp(-ke * t) - math.exp(-ka * t))


def level_at(cups: list[float], at: float) -> float:
    return sum(cup_level(at - cup) for cup in cups)


def clock_text(hours: float) -> str:
    minutes = int(round(hours * 60)) % (24 * 60)
    return f"{minutes // 60:02d}:{minutes % 60:02d}"


def frame(ui: cui.UI, state: State) -> None:
    count = len(state.cups)

    # The model: every cup's curve, the total's peak and what is left at bedtime.
    curve = [[0.0] * SAMPLES for _ in range(MAX_CUPS)]
    peak = 0.0
    peak_at = DAY_START
    for sample in range(SAMPLES):
        at = DAY_START + (DAY_END - DAY_START) * sample / (SAMPLES - 1)
        total = 0.0
        for index in range(count):
            value = cup_level(at - state.cups[index])
            curve[index][sample] = value
            total += value
        if total > peak:
            peak = total
            peak_at = at

    at_bed = level_at(state.cups, BEDTIME)

    # The verdict: the latest time the last cup could be drunk and still be under the line.
    if count == 0:
        verdict = "NO CUPS YET"
    elif level_at(state.cups[:-1], BEDTIME) > LIMIT_MG:
        verdict = "OVER THE LINE EVEN WITHOUT THE LAST CUP"
    else:
        lo, hi = DAY_START, BEDTIME
        for _ in range(40):
            mid = (lo + hi) / 2
            if level_at(state.cups[:-1] + [mid], BEDTIME) <= LIMIT_MG:
                lo = mid
            else:
                hi = mid
        verdict = f"LAST CUP BY {clock_text(math.floor(lo * 4) / 4)}"

    with ui.column(width=cui.Size.FILL, height=cui.Size.FILL,
                   bg=BACKGROUND, align=cui.Align.CENTER):
        with ui.column(width=cui.Size.FILL, max_width=880, height=cui.Size.FILL,
                       pad=28, gap=22):
            with ui.row(width=cui.Size.FILL, gap=28, wrap=True, align=cui.Align.END):
                with ui.column(gap=4):
                    ui.text("CAFFEINE", font=cui.MONO)
                    ui.text(f"{count} CUPS \u00b7 {count * CUP_MG:.0f} MG \u00b7 HALF-LIFE {HALF_LIFE:.0f}H",
                            font=cui.MONO, color=TEXT_MUTED, size=12)
                ui.spacer()
                ui.readout("PEAK", f"{peak:.0f}" if count else "\u2014", unit="MG",
                           detail=clock_text(peak_at) if count else "",
                           size=cui.ControlSize.SM)
                ui.readout("AT BED", f"{at_bed:.0f}", unit="MG", size=cui.ControlSize.SM,
                           accent=at_bed > LIMIT_MG,
                           detail="OVER THE LINE" if at_bed > LIMIT_MG else "UNDER THE LINE")

            with ui.column(width=cui.Size.FILL, gap=0):
                peak_label = f"PEAK {peak:.0f} MG"
                bed_label = f"{at_bed:.0f} MG STILL IN YOU"
                notes = [
                    cui.ChartAnnotation(cui.AnnotationKind.Y, 0, LIMIT_MG, "50", None, False),
                    cui.ChartAnnotation(cui.AnnotationKind.X, BEDTIME, 0, "BED 23:00",
                                        bed_label, False),
                    cui.ChartAnnotation(cui.AnnotationKind.X, peak_at, 0, peak_label,
                                        clock_text(peak_at), False),
                ]
                series = [
                    cui.DotSeries(curve[index], None, index == state.selected)
                    for index in range(count)
                ]
                result = ui.dot_chart(
                    "level", series, SAMPLES,
                    height=300, x_min=DAY_START, x_max=DAY_END,
                    x_units=cui.AxisUnits.HOURS, min=0, max=260, unit="MG",
                    no_axis=True, annotations=notes if count else notes[:1],
                )
                # A click on the chart pours a cup there.
                if result.clicked and count < MAX_CUPS:
                    at = math.floor(result.x * 4 + 0.5) / 4
                    state.cups.append(at)
                    state.cups.sort()
                    state.selected = state.cups.index(at)
                track = ui.event_track(
                    "cups", state.cups, MAX_CUPS, DAY_START, DAY_END,
                    selected=state.selected, step=0.25,
                    units=cui.AxisUnits.HOURS, label_step=6,
                )
                state.cups = track.times
                state.selected = track.selected

            ui.spacer()
            ui.dot_display(verdict, pitch=3, width=cui.Size.FILL,
                           accent=bool(count) and verdict.startswith("O"))


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Caffeine", width=900, height=700,
                          theme=cui.ThemeMode.DARK, accent=cui.Accent.BLUE))
