"""Account settings, ported from CUI's ``examples/settings.c``.

    python examples/settings.py
    python examples/settings.py --shot dev/out/settings.png

Section navigation, forms, preferences and a danger zone.  On a narrow window
the sections become tabs and each setting's label sits above its control.
"""

from __future__ import annotations

import cui

from _common import DANGER, TEXT_SECONDARY, main


class State:
    def __init__(self) -> None:
        self.section = 0
        self.first = "Maya"
        self.last = "Okafor"
        self.email = "maya@fieldwork.studio"
        self.username = "maya.okafor"
        self.bio = "Product designer in Berlin. Currently on onboarding and the settings pages."
        self.website = "https://fieldwork.studio"
        self.timezone = 3
        self.language = 0
        self.email_comments = True
        self.email_mentions = True
        self.email_digest = False
        self.push_all = False
        self.push_mentions = True
        self.desktop = False
        self.theme = 0
        self.density = 0
        self.accent = 0
        self.font_scale = 1.0
        self.reduced_motion = False
        self.confirm_delete = False
        self.confirm_text = ""
        self.dirty = False


def field_row(ui: cui.UI, title: str, desc: str | None) -> None:
    with ui.column(width=cui.Size.FILL, min_width=200, max_width=240, gap=3):
        ui.label(title)
        if desc:
            ui.text(desc, size=12, color=TEXT_SECONDARY)


def profile(ui: cui.UI, state: State) -> None:
    with ui.card(gap=24):
        with ui.row(gap=16):
            ui.avatar("Maya Okafor", size=64)
            with ui.column(gap=8, width=cui.Size.FILL):
                ui.label("Profile photo")
                with ui.row(gap=8):
                    ui.button("Upload", icon=cui.Icon.UPLOAD, size=cui.ControlSize.SM)
                    ui.button("Remove", variant=cui.ButtonVariant.GHOST, size=cui.ControlSize.SM)
        ui.separator()
        with ui.grid(columns=2, min_column_width=220, gap=16):
            result = ui.text_input("first", value=state.first, label="First name")
            state.first = result.text
            state.dirty |= result.changed
            result = ui.text_input("last", value=state.last, label="Last name")
            state.last = result.text
            state.dirty |= result.changed
            result = ui.text_input("email", value=state.email, label="Email", icon=cui.Icon.MAIL,
                                   hint="Used for sign in and notifications.")
            state.email = result.text
            state.dirty |= result.changed
            result = ui.text_input(
                "user", value=state.username, label="Username", icon=cui.Icon.AT_SIGN,
                error="Usernames cannot contain spaces." if " " in state.username else None,
            )
            state.username = result.text
            state.dirty |= result.changed
        result = ui.text_input("web", value=state.website, label="Website", icon=cui.Icon.GLOBE,
                               placeholder="https://")
        state.website = result.text
        state.dirty |= result.changed
        result = ui.textarea("bio", value=state.bio, label="Bio", height=100,
                             hint="A few words about you. Shown on your public profile.")
        state.bio = result.text
        state.dirty |= result.changed
        with ui.grid(columns=2, min_column_width=220, gap=16):
            zones = ["Pacific Time (UTC-8)", "Eastern Time (UTC-5)", "London (UTC+0)",
                     "Berlin (UTC+1)", "Tehran (UTC+3:30)", "Tokyo (UTC+9)"]
            timezone = ui.select("tz", zones, index=state.timezone, label="Time zone",
                                 searchable=True)
            state.dirty |= timezone != state.timezone
            state.timezone = timezone
            langs = ["English", "Deutsch", "Español", "Français", "Italiano", "Português"]
            language = ui.select("lang", langs, index=state.language, label="Language")
            state.dirty |= language != state.language
            state.language = language


def notifications(ui: cui.UI, state: State) -> None:
    with ui.card(gap=20):
        with ui.row(align=cui.Align.START, gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Email", "What we send to your inbox.")
            with ui.column(gap=14, width=cui.Size.FILL):
                state.email_comments = ui.checkbox(
                    "Comments", value=state.email_comments,
                    description="When someone replies to your comment.")
                state.email_mentions = ui.checkbox(
                    "Mentions", value=state.email_mentions,
                    description="When someone mentions you.")
                state.email_digest = ui.checkbox(
                    "Weekly digest", value=state.email_digest,
                    description="A summary of activity every Monday.")
        ui.separator()
        with ui.row(align=cui.Align.START, gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Push", "Notifications on your devices.")
            with ui.column(gap=14, width=cui.Size.FILL):
                state.push_all = ui.switch("Everything", value=state.push_all)
                state.push_mentions = ui.switch("Mentions only", value=state.push_mentions)
                state.desktop = ui.switch(
                    "Desktop notifications", value=state.desktop,
                    description="Show a banner even when the app is in the background.")


def appearance(ui: cui.UI, state: State) -> None:
    with ui.card(gap=20):
        with ui.row(gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Theme", "Choose how the app looks.")
            themes = ["Light", "Dark"]
            icons = [cui.Icon.SUN, cui.Icon.MOON]
            state.theme = ui.segmented("theme", themes, index=state.theme, icons=icons)
            ui.set_theme(state.theme)
        ui.separator()
        with ui.row(gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Accent", "Used for selection and focus.")
            accents = ["Neutral", "Violet", "Blue", "Green", "Amber", "Orange", "Coral", "Rose"]
            state.accent = ui.select("accent", accents, index=state.accent, width=cui.Size.px(200))
            ui.set_accent(state.accent)
        ui.separator()
        with ui.row(gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Density", None)
            state.density = ui.segmented("density", ["Comfortable", "Compact"],
                                         index=state.density, size=cui.ControlSize.SM)
        ui.separator()
        with ui.row(gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Text size", "Scales all text in the app.")
            state.font_scale = ui.slider("##fontscale", value=state.font_scale,
                                         minimum=0.85, maximum=1.3, step=0.05,
                                         show_value=True, format="%.2fx")
            ui.context.font_scale = state.font_scale
        ui.separator()
        with ui.row(gap=24, wrap=True, width=cui.Size.FILL):
            field_row(ui, "Reduce motion", "Keep state changes, drop travel and bounce.")
            state.reduced_motion = ui.switch("##motion", value=state.reduced_motion)
            ui.set_reduced_motion(state.reduced_motion)


def account(ui: cui.UI, state: State) -> None:
    with ui.card(gap=16):
        ui.label("Sessions")
        ui.list_item("MacBook Pro, Berlin", icon=cui.Icon.MONITOR, subtitle="This device",
                     trailing="Now")
        ui.list_item("Windows desktop, Tehran", icon=cui.Icon.MONITOR, subtitle="Chrome",
                     trailing="2h ago")
        ui.list_item("Linux laptop, Tokyo", icon=cui.Icon.MONITOR, subtitle="Firefox",
                     trailing="Yesterday")
    with ui.card(gap=14):
        with ui.row(gap=16, wrap=True, width=cui.Size.FILL):
            with ui.column(gap=4, width=cui.Size.FILL, min_width=220):
                ui.text("Delete account", font=cui.MEDIUM, color=DANGER)
                ui.secondary("Permanently remove your account and all of its data. "
                             "This cannot be undone.")
            if ui.button("Delete account", variant=cui.ButtonVariant.DANGER):
                state.confirm_delete = True
                state.confirm_text = ""

    was_open = state.confirm_delete

    def dialog_body(ui: cui.UI) -> None:
        result = ui.text_input("confirm", value=state.confirm_text, placeholder="DELETE",
                               autofocus=True)
        state.confirm_text = result.text

        def footer(ui: cui.UI) -> None:
            if ui.button("Cancel"):
                state.confirm_delete = False
            if ui.button("Delete account", variant=cui.ButtonVariant.DANGER,
                         disabled=state.confirm_text != "DELETE"):
                state.confirm_delete = False
                ui.toast("Account scheduled for deletion",
                         description="You have 14 days to change your mind.",
                         tone=cui.Tone.DANGER)

        ui.dialog_footer(footer)

    still_open = ui.dialog(
        "Delete account",
        open=was_open,
        description="Type DELETE to confirm. Your projects, comments and files will be removed.",
        body=dialog_body,
    )
    state.confirm_delete = state.confirm_delete and still_open


def frame(ui: cui.UI, state: State) -> None:
    sections = ["Profile", "Notifications", "Appearance", "Account"]
    icons = [cui.Icon.USER, cui.Icon.BELL, cui.Icon.PALETTE, cui.Icon.SHIELD]
    descs = ["How others see you.", "Choose what you hear about.", "Make it yours.",
             "Security and data."]
    narrow = ui.context.size[0] < 760
    with ui.scroll(id="page", width=cui.Size.FILL, fade_edges=True):
        with ui.row(justify=cui.Justify.CENTER, align=cui.Align.START):
            with ui.column(width=cui.Size.FILL, max_width=1040,
                           pad_x=16 if narrow else 40, pad_top=20 if narrow else 40,
                           pad_bottom=80, gap=20 if narrow else 28):
                with ui.column(gap=6):
                    ui.breadcrumb(["Workspace", "Settings", sections[state.section]])
                    ui.heading("Settings", level=1)
                if narrow:
                    state.section = ui.tabs("sections", sections, index=state.section,
                                            variant=cui.TabsVariant.PILL, icons=icons)
                with ui.row(gap=40, align=cui.Align.START):
                    if not narrow:
                        with ui.column(width=cui.Size.px(220), gap=2):
                            for index, section in enumerate(sections):
                                if ui.nav_item(section, icon=icons[index],
                                               selected=state.section == index,
                                               group="sections"):
                                    state.section = index
                    with ui.column(width=cui.Size.FILL, gap=20):
                        with ui.column(gap=4):
                            ui.heading(sections[state.section], level=3)
                            ui.secondary(descs[state.section])
                        if state.section == 0:
                            profile(ui, state)
                        elif state.section == 1:
                            notifications(ui, state)
                        elif state.section == 2:
                            appearance(ui, state)
                        else:
                            account(ui, state)
                        with ui.row(gap=8, justify=cui.Justify.END):
                            if ui.button("Discard", variant=cui.ButtonVariant.GHOST,
                                         disabled=not state.dirty):
                                state.dirty = False
                            if ui.button("Save changes", variant=cui.ButtonVariant.PRIMARY,
                                         disabled=not state.dirty, icon=cui.Icon.CHECK):
                                state.dirty = False
                                ui.toast("Settings saved", tone=cui.Tone.SUCCESS)


if __name__ == "__main__":
    raise SystemExit(main(frame, State(), title="Settings", width=1180, height=860))
