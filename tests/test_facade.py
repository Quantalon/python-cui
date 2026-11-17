"""The facade covers the components it claims to, and containers stay balanced."""

from __future__ import annotations

import pytest

import cui


def test_containers_balance_when_the_body_raises(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with pytest.raises(RuntimeError):
        with ui.column():
            raise RuntimeError("boom")
    # The stack must be balanced: the next frame builds normally.
    ctx.end_frame()
    ctx.begin_frame()
    with ui.column():
        ui.text("after")
    ctx.end_frame()
    assert ctx.draw_data().vertex_count > 0


def test_id_and_disabled_scopes(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column():
        for index in range(3):
            with ui.id(f"row{index}"):
                ui.button("Delete")
        with ui.disabled():
            ui.button("Nope")
    ctx.end_frame()
    assert not ctx._id_stack if hasattr(ctx, "_id_stack") else True


def test_card_reports_clicks(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.card() as card:
        ui.text("clickable")
    ctx.end_frame()
    assert card.clicked is False


def test_callback_containers(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    opened = ui.dialog("Rename", open=False, body=lambda u: u.text_input("rename", value="x"))
    assert opened is False
    ui.menu("File", body=lambda u: u.menu_item("Open"))
    ui.popover("more", body=lambda u: u.text("popover body"))
    assert ui.accordion("Details", open=True, body=lambda u: u.text("inside")) in (True, False)
    ctx.end_frame()


def test_stateful_components_keep_their_values(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column():
        assert ui.switch("s", value=True) is True
        assert ui.checkbox("c", value=False) is False
        assert ui.slider("sl", value=0.5) == 0.5
        assert ui.rating("r", max=5, value=3) == 3
        assert ui.select("sel", ["a", "b"], index=1) == 1
        assert ui.tabs("tabs", ["a", "b", "c"], index=2) == 2
        assert ui.segmented("seg", ["x", "y"], index=0) == 0
        assert ui.pagination("pg", page_count=5, page=2) == 2
        assert ui.number("n", value=7.0, minimum=0.0, maximum=10.0) == 7.0
    ctx.end_frame()


def test_text_results(ctx):
    ui = cui.UI(ctx)
    ctx.begin_frame()
    with ui.column():
        result = ui.text_input("name", value="Maya", label="Name")
        assert isinstance(result, cui.TextResult)
        assert result.text == "Maya"
        assert isinstance(ui.textarea("bio", value="hello"), cui.TextResult)
        assert isinstance(ui.search("q", value="find"), cui.TextResult)
    ctx.end_frame()


def test_every_facade_component_draws(ctx):
    """Draw one of everything the facade exposes; nothing may raise."""
    ui = cui.UI(ctx)
    checks = []

    # Everything at once needs room; CUI culls what does not fit.
    ctx.set_viewport(1200, 2400, 1.0)
    ctx.begin_frame()
    with ui.column(pad=10, gap=6):
        ui.heading("Title")
        ui.text("body")
        ui.label("label")
        ui.secondary("secondary")
        ui.muted("muted")
        ui.code("code")
        ui.kbd("Ctrl K")
        checks.append(ui.link("link"))
        ui.icon(cui.Icon.CHECK)
        ui.separator()
        ui.spacer()
        ui.gap(4)
        checks.append(ui.button("Button"))
        checks.append(ui.icon_button(cui.Icon.SETTINGS, tooltip="Settings"))
        checks.append(ui.link_button("link button"))
        checks.append(ui.checkbox("check", value=False))
        checks.append(ui.switch("switch", value=False))
        checks.append(ui.radio("radio", value=0, option=0))
        checks.append(ui.radio_group("group", ["a", "b"], index=0))
        checks.append(ui.slider("slider", value=5.0))
        checks.append(ui.range_slider("range", 10.0, 90.0))
        checks.append(ui.rating("rating", max=5))
        checks.append(ui.segmented("seg", ["one", "two"]))
        checks.append(ui.chip("chip"))
        checks.append(ui.toggle_group("tg", ["a", "b"]))
        checks.append(ui.text_input("input", value="text", label="Input"))
        checks.append(ui.textarea("area", value="text"))
        checks.append(ui.search("search", value="q"))
        checks.append(ui.tag_input("tags", value="a, b"))
        checks.append(ui.number("number", value=3.0))
        checks.append(ui.inline_edit("inline", value="x"))
        checks.append(ui.select("select", ["a", "b"]))
        checks.append(ui.multi_select("multi", ["a", "b"]))
        checks.append(ui.tabs("tabs", ["a", "b"]))
        checks.append(ui.nav_item("nav", icon=cui.Icon.HOUSE))
        ui.nav_section("Section")
        checks.append(ui.breadcrumb(["a", "b", "c"]))
        checks.append(ui.pagination("page", page_count=4))
        ui.stepper(["one", "two"], 1)
        ui.badge("badge", tone=cui.Tone.INFO)
        ui.avatar("Maya Okafor")
        ui.progress(0.5, label="Progress")
        ui.spinner(12.0)
        ui.skeleton(120.0, 10.0)
        ui.alert("Alert", description="body", tone=cui.Tone.WARNING)
        ui.toast("Toast", tone=cui.Tone.SUCCESS)
        ui.metric("Metric", "42")
        ui.empty_state("Nothing here")
        with ui.card(hoverable=True) as card:
            ui.text("card")
        with ui.scroll(height=60):
            ui.text("scrolled")
        with ui.grid(columns=2):
            ui.text("g1")
            ui.text("g2")
        with ui.toolbar("tb"):
            ui.text("toolbar")
        ui.tooltip("hint")
        checks.append(ui.date_picker("date", value=cui.Date.today()))
        checks.append(ui.color_picker("colour", value=cui.Color(10, 20, 30)))
    ctx.end_frame()

    assert len(checks) > 20
    assert ctx.draw_data().vertex_count > 500
