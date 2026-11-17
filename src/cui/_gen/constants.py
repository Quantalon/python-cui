"""Enum, integer and icon constants from CUI's headers.

GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
"""

from __future__ import annotations

from enum import IntEnum, IntFlag


class Token(IntEnum):
    """Semantic colors. Use these instead of raw colors so your UI follows the theme (light/dark) and the accent. They can go anywhere a cui_color goes."""

    NONE = 0
    BACKGROUND = 1
    SURFACE = 2
    SURFACE_RAISED = 3
    SURFACE_MUTED = 4
    FOREGROUND = 5
    TEXT_SECONDARY = 6
    TEXT_MUTED = 7
    BORDER = 8
    BORDER_SUBTLE = 9
    BORDER_STRONG = 10
    ACCENT = 11
    ACCENT_STRONG = 12
    ACCENT_SUBTLE = 13
    ACCENT_FOREGROUND = 14
    SUCCESS = 15
    WARNING = 16
    DANGER = 17
    INFO = 18
    CONTROL_ON = 19
    CONTROL_GLYPH = 20
    CONTROL_TRACK = 21
    CONTROL_TRACK_HOVER = 22
    CONTROL_THUMB = 23
    CONTROL_THUMB_ON = 24
    HOVER = 25
    ACTIVE = 26
    SCRIM = 27
    FOCUS_RING = 28
    SERIES_1 = 29
    SERIES_2 = 30
    SERIES_3 = 31
    SERIES_4 = 32
    SERIES_5 = 33
    SERIES_6 = 34
    COUNT = 35

class ThemeMode(IntEnum):

    LIGHT = 0
    DARK = 1

class Accent(IntEnum):

    NEUTRAL = 0
    VIOLET = 1
    BLUE = 2
    GREEN = 3
    AMBER = 4
    ORANGE = 5
    CORAL = 6
    ROSE = 7
    COUNT = 8

class TextureFormat(IntEnum):

    R8 = 1
    RGBA8 = 4

class Direction(IntEnum):
    """Zero inherits the parent, or LTR at the context root. With text shaping, AUTO uses the first strong character in descendant text, ignoring explicitly directed subtrees. Without text shaping, AUTO resolves to LTR."""

    INHERIT = 0
    LTR = 1
    RTL = 2
    AUTO = 3

class MouseButton(IntEnum):

    LEFT = 0
    RIGHT = 1
    MIDDLE = 2

class Key(IntEnum):

    KEY_NONE = 0
    KEY_TAB = 1
    KEY_ENTER = 2
    KEY_ESCAPE = 3
    KEY_BACKSPACE = 4
    KEY_DELETE = 5
    KEY_SPACE = 6
    KEY_LEFT = 7
    KEY_RIGHT = 8
    KEY_UP = 9
    KEY_DOWN = 10
    KEY_HOME = 11
    KEY_END = 12
    KEY_PAGE_UP = 13
    KEY_PAGE_DOWN = 14
    KEY_A = 15
    KEY_B = 16
    KEY_C = 17
    KEY_D = 18
    KEY_E = 19
    KEY_F = 20
    KEY_G = 21
    KEY_H = 22
    KEY_I = 23
    KEY_J = 24
    KEY_K = 25
    KEY_L = 26
    KEY_M = 27
    KEY_N = 28
    KEY_O = 29
    KEY_P = 30
    KEY_Q = 31
    KEY_R = 32
    KEY_S = 33
    KEY_T = 34
    KEY_U = 35
    KEY_V = 36
    KEY_W = 37
    KEY_X = 38
    KEY_Y = 39
    KEY_Z = 40
    KEY_0 = 41
    KEY_1 = 42
    KEY_2 = 43
    KEY_3 = 44
    KEY_4 = 45
    KEY_5 = 46
    KEY_6 = 47
    KEY_7 = 48
    KEY_8 = 49
    KEY_9 = 50
    KEY_MINUS = 51
    KEY_EQUAL = 52
    KEY_COMMA = 53
    KEY_PERIOD = 54
    KEY_SLASH = 55
    KEY_F1 = 56
    KEY_F2 = 57
    KEY_F3 = 58
    KEY_F4 = 59
    KEY_F5 = 60
    KEY_F6 = 61
    KEY_F7 = 62
    KEY_F8 = 63
    KEY_F9 = 64
    KEY_F10 = 65
    KEY_F11 = 66
    KEY_F12 = 67
    KEY_COUNT = 68

class Mod(IntFlag):

    SHIFT = 1
    CTRL = 2
    ALT = 4
    SUPER = 8

class Cursor(IntEnum):

    ARROW = 0
    HAND = 1
    TEXT = 2
    RESIZE_EW = 3
    RESIZE_NS = 4
    MOVE = 5
    NOT_ALLOWED = 6
    COUNT = 7

BODY = 0
MEDIUM = 1
DISPLAY = 2
MONO = 3
ICONS = 4

class SizeKind(IntEnum):

    FIT = 0
    GROW = 1
    FIXED = 2
    PERCENT = 3

class Dir(IntEnum):

    COLUMN = 0
    ROW = 1
    STACK = 2
    GRID = 3

class Align(IntEnum):
    """CUI_ALIGN_DEFAULT: columns stretch their children, rows center them."""

    DEFAULT = 0
    START = 1
    CENTER = 2
    END = 3
    STRETCH = 4

class Justify(IntEnum):

    START = 0
    CENTER = 1
    END = 2
    BETWEEN = 3
    AROUND = 4

class Elevation(IntEnum):

    NONE = 0
    RESTING = 1
    RAISED = 2
    FLOATING = 3

class TextAlign(IntEnum):

    START = 0
    CENTER = 1
    RIGHT = 2
    LEFT = 3
    END = 4

class ButtonVariant(IntEnum):

    DEFAULT = 0
    SECONDARY = 1
    PRIMARY = 2
    OUTLINE = 3
    GHOST = 4
    DANGER = 5
    LINK = 6

class ControlSize(IntEnum):

    MD = 0
    SM = 1
    LG = 2

CHANGED = 1
SUBMITTED = 2
FOCUSED = 4
BLURRED = 8

class TabsVariant(IntEnum):

    UNDERLINE = 0
    PILL = 1

class Placement(IntEnum):

    BOTTOM_START = 0
    BOTTOM = 1
    BOTTOM_END = 2
    TOP_START = 3
    TOP = 4
    TOP_END = 5
    RIGHT_START = 6
    LEFT_START = 7
    RIGHT = 8
    LEFT = 9

NONE = 0
NEXT = 1
BACK = 2
DONE = 3
SKIPPED = 4

class Side(IntEnum):

    RIGHT = 0
    LEFT = 1
    BOTTOM = 2
    TOP = 3

class Tone(IntEnum):

    NEUTRAL = 0
    INFO = 1
    SUCCESS = 2
    WARNING = 3
    DANGER = 4
    VIOLET = 5
    TEAL = 6
    ROSE = 7
    ACCENT = 8

class AnnotationKind(IntEnum):
    """A line, a threshold or a point drawn over a chart, with a two-line label: the label in the foreground color and a muted detail under it. Line and bar charts take them in cui_chart_opts, the dot chart in cui_dot_chart_opts. Labels that would overlap move to the other side of their line, then down."""

    X = 0
    Y = 1
    POINT = 2

class Status(IntEnum):
    """Button that shows the result of the work it started: idle, a spinner while busy, then a check (or an error) that settles back. Width morphs smoothly between the states. Returns true when clicked while idle."""

    IDLE = 0
    BUSY = 1
    SUCCESS = 2
    ERROR = 3

HAS_CHILDREN = 1
OPEN = 2
SELECTED = 4
LOADING = 8

class DiffMode(IntEnum):
    """Diff viewer: compares two versions of a text line by line, side by side or inline, with changed words marked inside changed lines. The texts are yours (UTF-8, read during the call); the view keeps a copy and diffs again only when one of them changes, so it is cheap to call every frame. static cui_diff_mode mode = CUI_DIFF_SPLIT; static int change = 0;                       (the selected change, -1 none) cui_diff_result r = cui_diff_view(ui, "diff", before, after, .mode = mode, .current = &change, .language = "c", .old_title = "parser.c (main)", .new_title = "parser.c"); if (cui_icon_button(ui, CUI_ICON_ARROW_DOWN, .tooltip = "Next change", .shortcut = "N")) change = CUI_MIN(change + 1, r.changes - 1);   (or any index: the view scrolls to it) cui_textf(ui, "+%d -%d", r.added, r.removed); The line diff is Myers' algorithm (the shortest edit script, in linear memory). Very different large texts are capped: past about 16 million search steps the remaining parts are shown as replaced, still a correct diff but not the shortest (r.approximate). Insertions and deletions slide to end on a blank line where they can, the way an added function reads best. Paired changed lines get word marks when they have enough in common. Split shows the old text on the left and the new on the right, rows aligned with a blank filler opposite added or removed lines; narrower than split_min_width (560 points) it shows inline instead (r.mode says which). Each side has its line numbers and a + or - sign. Unchanged stretches keep .context lines (3) beside each change; longer ones fold into a "42 unchanged lines" row that opens on a click. Lines longer than the view scroll sideways, both sides together; the first 1024 bytes of a line are drawn. With the view focused: N or Alt+Down goes to the next change, P or Alt+Up to the previous one, arrows and Page Up/Down scroll, E opens every fold and Shift+E folds them again, Esc clears the selected change. A click on a change selects it. Only the rows in sight are built."""

    SPLIT = 0
    INLINE = 1

class DiffRowKind(IntEnum):
    """The rows the view shows after folding, e.g. to put a comment button beside a line. Copies rows [first, first + cap) and returns how many there are (0 before the view's first frame). Call it in the same id scope as the view."""

    SAME = 0
    REMOVED = 1
    ADDED = 2
    CHANGED = 3
    FOLD = 4

EOL = 1

LIKE = 1
REPLY = 2

class LoaderStyle(IntEnum):

    DOTS = 0
    BARS = 1
    PULSE = 2
    ORBIT = 3
    GRID = 4

TOGGLE = 1
PREV = 2
NEXT = 4
SEEK = 8

class TaskStatus(IntEnum):
    """Tool call: a compact row with the tool, a detail and its status; opens to show the input and the output (shown as JSON when they parse)."""

    PENDING = 0
    RUNNING = 1
    DONE = 2
    FAILED = 3
    SKIPPED = 4

COPY = 1
REGENERATE = 2
UP = 4
DOWN = 8
SHARE = 16

SEND = 1
STOP = 2
ATTACH = 4
REMOVE = 8
MODEL = 16

class VoiceState(IntEnum):
    """Voice orb: a living shape for voice modes. level is the input or output loudness (0..1). Returns true when clicked."""

    IDLE = 0
    LISTENING = 1
    THINKING = 2
    SPEAKING = 3

class LogLevel(IntEnum):
    """Log console. The app owns the storage: give cui_log_init an array of line records and a byte buffer for the text. Appending never allocates; when either is full the oldest lines are dropped (a ring buffer). Lines longer than the text buffer are cut to fit. static cui_log_line lines[4096]; static char text[256 * 1024]; static cui_log_buffer log; cui_log_init(&log, lines, 4096, text, sizeof text); log.now = seconds_since_start();             // optional timestamp source cui_log_append(&log, CUI_LOG_WARN, "Shader %s took %d ms", name, ms); ... cui_log_view(ui, "log", &log, .height = 320, .timestamps = true); Each append is one line: a trailing newline is dropped and other control characters show as spaces. The view keeps its own filter, search, follow and selection state (a small index of the matching lines, at most one entry per line slot, freed with the context)."""

    TRACE = 0
    DEBUG = 1
    INFO = 2
    WARN = 3
    ERROR = 4
    LEVEL_COUNT = 5

class CurveMode(IntEnum):
    """Curve editor: keyframes on a plot, for easing, animation timing and response curves. You own the array of keys, sorted by x; the editor edits it in place (moves, handles, modes, adds and removes) and reports what it did in the result, so data you keep beside each key can follow: static cui_curve_key ease[8] = { { 0, 0 }, { 0.42f, 0.1f }, { 1, 1 } }; static int n = 3, sel = -1; cui_curve_result r = cui_curve_editor(ui, "ease", ease, &n, 8, .selected = &sel); if (r.added >= 0) insert_my_data(r.added); if (r.removed >= 0) remove_my_data(r.removed); ... float y = cui_curve_eval(ease, n, t);   (the same curve the editor draws) The mode of a key shapes the segment that leaves it: SMOOTH and FREE are cubic beziers, LINEAR a straight line, STEP holds the key's value until the next key. A SMOOTH key computes its tangents (no overshoot, flat at the ends and at peaks); a FREE key uses its handles, which are relative to the key in curve units (in_dx <= 0, out_dx >= 0) and are shortened to the neighbouring key so the curve never folds back. The incoming segment of a LINEAR or STEP key arrives with an automatic tangent. Before the first key the curve holds the first value, after the last key the last value. Drag a key to move it (x stays between its neighbours, both axes inside the range); drag the handles of the selected key (a SMOOTH key becomes FREE); Shift or `snap` snaps a drag to the grid. Double click empty space to add a key (on the curve when the click is near it), Delete or Backspace removes the selected key (never fewer than two). Keys are focusable: Tab moves through them, the arrows nudge (Shift for fine steps). Hovering shows the value under the pointer. The row under the plot sets the selected key's mode and exact position (its fields stack on a narrow editor)."""

    SMOOTH = 0
    FREE = 1
    LINEAR = 2
    STEP = 3

class TimelineRuler(IntEnum):
    """Timeline editor (dope sheet): a track list on the left, a time ruler on top and a row per track with its keys (and clips, for video and audio tracks). You own the tracks, their keys and clips, the playhead time and the selection; the editor edits them in place and reports what it did: static cui_curve_key rot[32] = { { 0, 0 }, { 1, 30 }, { 2, 0 } }; static bool rot_sel[32];                   (parallel to the keys) static cui_timeline_track tracks[] = { { "Hero", CUI_ICON_USER, 0 }, { "Rotation", NULL, 1, .keys = rot, .key_count = 3, .key_capacity = 32, .key_selected = rot_sel }, }; static float t; cui_timeline_editor_result r = cui_timeline_editor(ui, "anim", tracks, 2, &t, .end = 4, .fps = 24); if (r.play_toggled) playing = !playing;    (you advance t while playing) float angle = cui_curve_eval(rot, tracks[1].key_count, t); Keys are curve keys (x is the time in seconds, y the value), so a track's array goes straight into cui_curve_editor and cui_curve_eval; the mode sets the mark: a diamond for SMOOTH and FREE, a circle for LINEAR, a square for STEP. Keys stay sorted by time and inside start..end. A track whose next tracks are deeper is a group: a chevron collapses it and its row shows its tracks' keys as small marks. Only the rows in view are visited and only the keys in view are searched (binary searches), so thousands of tracks stay fast. Mouse: click the ruler or drag in it to scrub (snapped to frames); click a key to select it, Shift+click adds, Ctrl+click toggles; drag in empty space for a box selection (Shift or Ctrl adds to the selection); drag selected keys to move them, by whole frames (hold Shift to move freely); double-click a row to add a key there (on the curve, so the motion is kept); drag a clip to move it, its ends to trim it; click a track name to select its keys. The wheel zooms time around the pointer, Shift+wheel or a sideways scroll pans, the wheel over the track list scrolls the rows, and a middle-button drag pans both ways. Hovering a key shows its time and value. Keys when focused: Left/Right step the playhead a frame (Shift: 10), Alt+Left/Right move the selected keys a frame (Shift: 10), Up/Down jump to the previous/next key, Home/End to the start/end, Space reports a play request, Delete or Backspace removes the selected keys and clips, Ctrl+A selects every key on the visible tracks, Esc clears the selection, F fits the whole sequence (animated, snaps with reduced motion), + and - zoom around the playhead. The view follows the playhead when it leaves the view."""

    FRAMES = 0
    SECONDS = 1
    TIMECODE = 2

class Severity(IntEnum):
    """Compiler and linter diagnostics, grouped by file: errors, warnings, notes and hints with their position, source and code. Toggles above filter by severity (with counts) and a field filters by text. A file's header folds its group. Up and Down move the selection, Left and Right fold and unfold, Enter or a double-click reports `activated` (open the file there). Only the rows in view are built, so thousands of diagnostics stay fast. The array needs to be valid only during the call."""

    ERROR = 0
    WARNING = 1
    INFO = 2
    HINT = 3

class JobStatus(IntEnum):
    """A CI/CD run: stages left to right, each a column of jobs with their status and duration. A stage's header sums up its jobs (failed, running, passed). Running jobs spin. Click a job to get its index (open its log). Below 560 points the stages stack top to bottom."""

    PENDING = 0
    RUNNING = 1
    PASSED = 2
    FAILED = 3
    SKIPPED = 4
    CANCELED = 5

class QueryType(IntEnum):
    """Conditions joined by "all" or "any", in groups you can nest: the filter of an issue tracker, a log search or a database view. You own the nodes, in order, each with its depth: node 0 is the outer group (made for you when count is 0). A rule picks a field, an operator for the field's type and a value; a group picks all or any. Returns true when anything changed. cui_query_text writes the query as a sentence, cui_query_match tests a record against it."""

    TEXT = 0
    NUMBER = 1
    CHOICE = 2
    BOOL = 3

ICASE = 1
MULTILINE = 2
DOTALL = 4

class HttpMethod(IntEnum):
    """The method, the URL and Send, as in an API client. Enter in the URL sends; while `loading` the button cancels. cui_response_status shows a response's status, time and size in one line. cui_url_params and cui_url_set_params move a URL's query to and from key-value pairs, decoding and encoding it, so a parameters table can stay in step with the URL."""

    GET = 0
    POST = 1
    PUT = 2
    PATCH = 3
    DELETE = 4
    HEAD = 5
    OPTIONS = 6

class AxisUnits(IntEnum):
    """How an axis labels its values."""

    NUMBER = 0
    HOURS = 1

TEXT = 0
RRECT = 1
SHADOW = 2
IMAGE = 3
SOLID = 4

class SwFormat(IntEnum):

    RGBA = 0
    BGRA = 1

class RendererKind(IntEnum):

    AUTO = 0
    OPENGL = 1
    SOFTWARE = 2

class FileDialogKind(IntEnum):
    """Native file dialogs. Blocking; returns true and writes the chosen path (UTF-8) to out when the user confirms. On Linux this uses zenity or kdialog when installed. Pass NULL as app to use the current app (handy in cui_app_run callbacks)."""

    OPEN = 0
    SAVE = 1
    FOLDER = 2

# Lucide icon strings: one glyph each, usable on their own or in a label.
#     ui.button(ICON_PLUS + ' New project')
ICON_CHECK = '\ue06c'
ICON_X = '\ue1b2'
ICON_PLUS = '\ue13d'
ICON_MINUS = '\ue11c'
ICON_CHEVRON_DOWN = '\ue06d'
ICON_CHEVRON_UP = '\ue070'
ICON_CHEVRON_LEFT = '\ue06e'
ICON_CHEVRON_RIGHT = '\ue06f'
ICON_CHEVRONS_UP_DOWN = '\ue211'
ICON_CHEVRONS_LEFT = '\ue072'
ICON_CHEVRONS_RIGHT = '\ue073'
ICON_SEARCH = '\ue151'
ICON_SETTINGS = '\ue154'
ICON_USER = '\ue19f'
ICON_USERS = '\ue1a4'
ICON_HOUSE = '\ue0f5'
ICON_BELL = '\ue059'
ICON_MAIL = '\ue10f'
ICON_CALENDAR = '\ue063'
ICON_CLOCK = '\ue087'
ICON_TRASH_2 = '\ue18e'
ICON_PENCIL = '\ue1f9'
ICON_COPY = '\ue09e'
ICON_CHECK_CHECK = '\ue38e'
ICON_EYE = '\ue0ba'
ICON_EYE_OFF = '\ue0bb'
ICON_LOCK = '\ue10b'
ICON_UNLOCK = '\ue10c'
ICON_STAR = '\ue176'
ICON_HEART = '\ue0f2'
ICON_INFO = '\ue0f9'
ICON_CIRCLE_ALERT = '\ue077'
ICON_TRIANGLE_ALERT = '\ue193'
ICON_CIRCLE_CHECK = '\ue226'
ICON_CIRCLE_X = '\ue084'
ICON_CIRCLE_HELP = '\ue082'
ICON_ELLIPSIS = '\ue0b6'
ICON_ELLIPSIS_VERTICAL = '\ue0b7'
ICON_MENU = '\ue115'
ICON_PANEL_LEFT = '\ue12a'
ICON_SUN = '\ue178'
ICON_MOON = '\ue11e'
ICON_MONITOR = '\ue11d'
ICON_DOWNLOAD = '\ue0b2'
ICON_UPLOAD = '\ue19e'
ICON_FILE = '\ue0c0'
ICON_FOLDER = '\ue0d7'
ICON_FOLDER_OPEN = '\ue247'
ICON_IMAGE = '\ue0f6'
ICON_LINK = '\ue102'
ICON_EXTERNAL_LINK = '\ue0b9'
ICON_LOG_OUT = '\ue10e'
ICON_LOG_IN = '\ue10d'
ICON_ARROW_RIGHT = '\ue049'
ICON_ARROW_LEFT = '\ue048'
ICON_ARROW_UP = '\ue04a'
ICON_ARROW_DOWN = '\ue042'
ICON_ARROW_UP_RIGHT = '\ue04d'
ICON_REFRESH_CW = '\ue145'
ICON_ROTATE_CCW = '\ue148'
ICON_FILTER = '\ue0dc'
ICON_SLIDERS_HORIZONTAL = '\ue29a'
ICON_GRIP_VERTICAL = '\ue0eb'
ICON_LAYOUT_DASHBOARD = '\ue1c1'
ICON_CHART_BAR = '\ue2a2'
ICON_CHART_LINE = '\ue2a5'
ICON_CHART_PIE = '\ue06b'
ICON_INBOX = '\ue0f7'
ICON_SEND = '\ue152'
ICON_MESSAGE_SQUARE = '\ue117'
ICON_BOOKMARK = '\ue060'
ICON_TAG = '\ue17f'
ICON_ZAP = '\ue1b4'
ICON_SPARKLES = '\ue412'
ICON_SHIELD = '\ue158'
ICON_CREDIT_CARD = '\ue0aa'
ICON_GLOBE = '\ue0e8'
ICON_MAP_PIN = '\ue111'
ICON_PHONE = '\ue133'
ICON_PLAY = '\ue13c'
ICON_PAUSE = '\ue12e'
ICON_SQUARE_TERMINAL = '\ue20a'
ICON_CODE = '\ue093'
ICON_TERMINAL = '\ue181'
ICON_COMMAND = '\ue09a'
ICON_KEYBOARD = '\ue284'
ICON_SAVE = '\ue14d'
ICON_SHARE_2 = '\ue156'
ICON_CLOUD = '\ue088'
ICON_DATABASE = '\ue0ad'
ICON_SERVER = '\ue153'
ICON_CPU = '\ue0a9'
ICON_WIFI = '\ue1ae'
ICON_BATTERY = '\ue053'
ICON_VOLUME_2 = '\ue1ab'
ICON_VOLUME_X = '\ue1ac'
ICON_MIC = '\ue118'
ICON_CAMERA = '\ue064'
ICON_VIDEO = '\ue1a5'
ICON_MUSIC = '\ue122'
ICON_PALETTE = '\ue1dd'
ICON_TYPE = '\ue198'
ICON_BOLD = '\ue05d'
ICON_ITALIC = '\ue0fb'
ICON_UNDERLINE = '\ue19a'
ICON_ALIGN_LEFT = '\ue185'
ICON_LIST = '\ue106'
ICON_LIST_CHECKS = '\ue1d0'
ICON_GRID_3X3 = '\ue0e9'
ICON_MAXIMIZE_2 = '\ue113'
ICON_MINIMIZE_2 = '\ue11b'
ICON_MOVE = '\ue121'
ICON_ZOOM_IN = '\ue1b6'
ICON_ZOOM_OUT = '\ue1b7'
ICON_UNDO_2 = '\ue2a1'
ICON_REDO_2 = '\ue2a0'
ICON_LOADER_CIRCLE = '\ue10a'
ICON_CIRCLE_DOT = '\ue345'
ICON_DOT = '\ue44f'
ICON_PLUS_CIRCLE = '\ue081'
ICON_PACKAGE = '\ue129'
ICON_BOX = '\ue061'
ICON_LAYERS = '\ue529'
ICON_GIT_BRANCH = '\ue0e2'
ICON_ACTIVITY = '\ue038'
ICON_TRENDING_UP = '\ue191'
ICON_TRENDING_DOWN = '\ue190'
ICON_DOLLAR_SIGN = '\ue0b1'
ICON_SHOPPING_CART = '\ue15c'
ICON_WALLET = '\ue204'
ICON_BRIEFCASE = '\ue062'
ICON_BUILDING_2 = '\ue290'
ICON_FLAG = '\ue0d1'
ICON_GIFT = '\ue0e1'
ICON_AWARD = '\ue04f'
ICON_THUMBS_UP = '\ue18a'
ICON_THUMBS_DOWN = '\ue189'
ICON_SMILE = '\ue164'
ICON_AT_SIGN = '\ue04e'
ICON_HASH = '\ue0ef'
ICON_PERCENT = '\ue132'
ICON_PAPERCLIP = '\ue12d'
ICON_PRINTER = '\ue141'
ICON_SCISSORS = '\ue14e'
ICON_CLIPBOARD = '\ue085'
ICON_FILE_TEXT = '\ue0cc'
ICON_NOTEBOOK_PEN = '\ue596'
ICON_SQUARE_PEN = '\ue172'
ICON_BADGE_CHECK = '\ue241'
ICON_CIRCLE_USER = '\ue461'
ICON_USER_PLUS = '\ue1a2'
ICON_KEY_ROUND = '\ue4a3'
ICON_FINGERPRINT = '\ue2cb'
ICON_BUG = '\ue20c'
ICON_ROCKET = '\ue286'
ICON_TARGET = '\ue180'
ICON_COMPASS = '\ue09b'
ICON_HISTORY = '\ue1f5'
ICON_ARCHIVE = '\ue041'
ICON_CIRCLE = '\ue076'
ICON_SQUARE_CHECK = '\ue559'
ICON_SQUARE = '\ue167'
ICON_SKIP_BACK = '\ue15f'
ICON_SKIP_FORWARD = '\ue160'
ICON_SHUFFLE = '\ue15e'
ICON_REPEAT = '\ue146'
ICON_RADIO = '\ue142'
ICON_AUDIO_LINES = '\ue55a'


class Icon:
    """Every icon, as a namespace: ``Icon.PLUS`` is the same string as ICON_PLUS."""

    CHECK = '\ue06c'
    X = '\ue1b2'
    PLUS = '\ue13d'
    MINUS = '\ue11c'
    CHEVRON_DOWN = '\ue06d'
    CHEVRON_UP = '\ue070'
    CHEVRON_LEFT = '\ue06e'
    CHEVRON_RIGHT = '\ue06f'
    CHEVRONS_UP_DOWN = '\ue211'
    CHEVRONS_LEFT = '\ue072'
    CHEVRONS_RIGHT = '\ue073'
    SEARCH = '\ue151'
    SETTINGS = '\ue154'
    USER = '\ue19f'
    USERS = '\ue1a4'
    HOUSE = '\ue0f5'
    BELL = '\ue059'
    MAIL = '\ue10f'
    CALENDAR = '\ue063'
    CLOCK = '\ue087'
    TRASH_2 = '\ue18e'
    PENCIL = '\ue1f9'
    COPY = '\ue09e'
    CHECK_CHECK = '\ue38e'
    EYE = '\ue0ba'
    EYE_OFF = '\ue0bb'
    LOCK = '\ue10b'
    UNLOCK = '\ue10c'
    STAR = '\ue176'
    HEART = '\ue0f2'
    INFO = '\ue0f9'
    CIRCLE_ALERT = '\ue077'
    TRIANGLE_ALERT = '\ue193'
    CIRCLE_CHECK = '\ue226'
    CIRCLE_X = '\ue084'
    CIRCLE_HELP = '\ue082'
    ELLIPSIS = '\ue0b6'
    ELLIPSIS_VERTICAL = '\ue0b7'
    MENU = '\ue115'
    PANEL_LEFT = '\ue12a'
    SUN = '\ue178'
    MOON = '\ue11e'
    MONITOR = '\ue11d'
    DOWNLOAD = '\ue0b2'
    UPLOAD = '\ue19e'
    FILE = '\ue0c0'
    FOLDER = '\ue0d7'
    FOLDER_OPEN = '\ue247'
    IMAGE = '\ue0f6'
    LINK = '\ue102'
    EXTERNAL_LINK = '\ue0b9'
    LOG_OUT = '\ue10e'
    LOG_IN = '\ue10d'
    ARROW_RIGHT = '\ue049'
    ARROW_LEFT = '\ue048'
    ARROW_UP = '\ue04a'
    ARROW_DOWN = '\ue042'
    ARROW_UP_RIGHT = '\ue04d'
    REFRESH_CW = '\ue145'
    ROTATE_CCW = '\ue148'
    FILTER = '\ue0dc'
    SLIDERS_HORIZONTAL = '\ue29a'
    GRIP_VERTICAL = '\ue0eb'
    LAYOUT_DASHBOARD = '\ue1c1'
    CHART_BAR = '\ue2a2'
    CHART_LINE = '\ue2a5'
    CHART_PIE = '\ue06b'
    INBOX = '\ue0f7'
    SEND = '\ue152'
    MESSAGE_SQUARE = '\ue117'
    BOOKMARK = '\ue060'
    TAG = '\ue17f'
    ZAP = '\ue1b4'
    SPARKLES = '\ue412'
    SHIELD = '\ue158'
    CREDIT_CARD = '\ue0aa'
    GLOBE = '\ue0e8'
    MAP_PIN = '\ue111'
    PHONE = '\ue133'
    PLAY = '\ue13c'
    PAUSE = '\ue12e'
    SQUARE_TERMINAL = '\ue20a'
    CODE = '\ue093'
    TERMINAL = '\ue181'
    COMMAND = '\ue09a'
    KEYBOARD = '\ue284'
    SAVE = '\ue14d'
    SHARE_2 = '\ue156'
    CLOUD = '\ue088'
    DATABASE = '\ue0ad'
    SERVER = '\ue153'
    CPU = '\ue0a9'
    WIFI = '\ue1ae'
    BATTERY = '\ue053'
    VOLUME_2 = '\ue1ab'
    VOLUME_X = '\ue1ac'
    MIC = '\ue118'
    CAMERA = '\ue064'
    VIDEO = '\ue1a5'
    MUSIC = '\ue122'
    PALETTE = '\ue1dd'
    TYPE = '\ue198'
    BOLD = '\ue05d'
    ITALIC = '\ue0fb'
    UNDERLINE = '\ue19a'
    ALIGN_LEFT = '\ue185'
    LIST = '\ue106'
    LIST_CHECKS = '\ue1d0'
    GRID_3X3 = '\ue0e9'
    MAXIMIZE_2 = '\ue113'
    MINIMIZE_2 = '\ue11b'
    MOVE = '\ue121'
    ZOOM_IN = '\ue1b6'
    ZOOM_OUT = '\ue1b7'
    UNDO_2 = '\ue2a1'
    REDO_2 = '\ue2a0'
    LOADER_CIRCLE = '\ue10a'
    CIRCLE_DOT = '\ue345'
    DOT = '\ue44f'
    PLUS_CIRCLE = '\ue081'
    PACKAGE = '\ue129'
    BOX = '\ue061'
    LAYERS = '\ue529'
    GIT_BRANCH = '\ue0e2'
    ACTIVITY = '\ue038'
    TRENDING_UP = '\ue191'
    TRENDING_DOWN = '\ue190'
    DOLLAR_SIGN = '\ue0b1'
    SHOPPING_CART = '\ue15c'
    WALLET = '\ue204'
    BRIEFCASE = '\ue062'
    BUILDING_2 = '\ue290'
    FLAG = '\ue0d1'
    GIFT = '\ue0e1'
    AWARD = '\ue04f'
    THUMBS_UP = '\ue18a'
    THUMBS_DOWN = '\ue189'
    SMILE = '\ue164'
    AT_SIGN = '\ue04e'
    HASH = '\ue0ef'
    PERCENT = '\ue132'
    PAPERCLIP = '\ue12d'
    PRINTER = '\ue141'
    SCISSORS = '\ue14e'
    CLIPBOARD = '\ue085'
    FILE_TEXT = '\ue0cc'
    NOTEBOOK_PEN = '\ue596'
    SQUARE_PEN = '\ue172'
    BADGE_CHECK = '\ue241'
    CIRCLE_USER = '\ue461'
    USER_PLUS = '\ue1a2'
    KEY_ROUND = '\ue4a3'
    FINGERPRINT = '\ue2cb'
    BUG = '\ue20c'
    ROCKET = '\ue286'
    TARGET = '\ue180'
    COMPASS = '\ue09b'
    HISTORY = '\ue1f5'
    ARCHIVE = '\ue041'
    CIRCLE = '\ue076'
    SQUARE_CHECK = '\ue559'
    SQUARE = '\ue167'
    SKIP_BACK = '\ue15f'
    SKIP_FORWARD = '\ue160'
    SHUFFLE = '\ue15e'
    REPEAT = '\ue146'
    RADIO = '\ue142'
    AUDIO_LINES = '\ue55a'
