# C declarations of CUI's C API, shared by cui._cui and cui._api.
#
# GENERATED FILE: produced by tools/gen_cui.py from CUI/include/cui/*.h.
# Do not edit by hand; run `python tools/gen_cui.py` instead.

from libc.stddef cimport size_t
from libc.stdint cimport int64_t, uint8_t, uint32_t, uint64_t, uintptr_t

cdef extern from "cui/cui.h" nogil:
    ctypedef uintptr_t cui_texture
    ctypedef uint32_t cui_id
    ctypedef struct cui_ctx

    # ---- enums ----


cdef extern from "cui/cui.h" nogil:
    ctypedef enum cui_accent:
        CUI_ACCENT_NEUTRAL = 0
        CUI_ACCENT_VIOLET = 1
        CUI_ACCENT_BLUE = 2
        CUI_ACCENT_GREEN = 3
        CUI_ACCENT_AMBER = 4
        CUI_ACCENT_ORANGE = 5
        CUI_ACCENT_CORAL = 6
        CUI_ACCENT_ROSE = 7
        CUI_ACCENT_COUNT = 8

    ctypedef enum cui_align:
        CUI_ALIGN_DEFAULT = 0
        CUI_ALIGN_START = 1
        CUI_ALIGN_CENTER = 2
        CUI_ALIGN_END = 3
        CUI_ALIGN_STRETCH = 4

    ctypedef enum cui_annotation_kind:
        CUI_ANNOTATION_X = 0
        CUI_ANNOTATION_Y = 1
        CUI_ANNOTATION_POINT = 2

    ctypedef enum cui_axis_units:
        CUI_AXIS_NUMBER = 0
        CUI_AXIS_HOURS = 1

    ctypedef enum cui_button_variant:
        CUI_BUTTON_DEFAULT = 0
        CUI_BUTTON_SECONDARY = 1
        CUI_BUTTON_PRIMARY = 2
        CUI_BUTTON_OUTLINE = 3
        CUI_BUTTON_GHOST = 4
        CUI_BUTTON_DANGER = 5
        CUI_BUTTON_LINK = 6

    ctypedef enum cui_control_size:
        CUI_SIZE_MD = 0
        CUI_SIZE_SM = 1
        CUI_SIZE_LG = 2

    ctypedef enum cui_cursor:
        CUI_CURSOR_ARROW = 0
        CUI_CURSOR_HAND = 1
        CUI_CURSOR_TEXT = 2
        CUI_CURSOR_RESIZE_EW = 3
        CUI_CURSOR_RESIZE_NS = 4
        CUI_CURSOR_MOVE = 5
        CUI_CURSOR_NOT_ALLOWED = 6
        CUI_CURSOR_COUNT = 7

    ctypedef enum cui_curve_mode:
        CUI_CURVE_SMOOTH = 0
        CUI_CURVE_FREE = 1
        CUI_CURVE_LINEAR = 2
        CUI_CURVE_STEP = 3

    ctypedef enum cui_diff_mode:
        CUI_DIFF_SPLIT = 0
        CUI_DIFF_INLINE = 1

    ctypedef enum cui_diff_row_kind:
        CUI_DIFF_ROW_SAME = 0
        CUI_DIFF_ROW_REMOVED = 1
        CUI_DIFF_ROW_ADDED = 2
        CUI_DIFF_ROW_CHANGED = 3
        CUI_DIFF_ROW_FOLD = 4

    ctypedef enum cui_dir:
        CUI_COLUMN = 0
        CUI_ROW = 1
        CUI_STACK = 2
        CUI_GRID = 3

    ctypedef enum cui_direction:
        CUI_DIRECTION_INHERIT = 0
        CUI_DIRECTION_LTR = 1
        CUI_DIRECTION_RTL = 2
        CUI_DIRECTION_AUTO = 3

    ctypedef enum cui_elevation:
        CUI_ELEVATION_NONE = 0
        CUI_ELEVATION_RESTING = 1
        CUI_ELEVATION_RAISED = 2
        CUI_ELEVATION_FLOATING = 3

    ctypedef enum cui_http_method:
        CUI_HTTP_GET = 0
        CUI_HTTP_POST = 1
        CUI_HTTP_PUT = 2
        CUI_HTTP_PATCH = 3
        CUI_HTTP_DELETE = 4
        CUI_HTTP_HEAD = 5
        CUI_HTTP_OPTIONS = 6

    ctypedef enum cui_job_status:
        CUI_JOB_PENDING = 0
        CUI_JOB_RUNNING = 1
        CUI_JOB_PASSED = 2
        CUI_JOB_FAILED = 3
        CUI_JOB_SKIPPED = 4
        CUI_JOB_CANCELED = 5

    ctypedef enum cui_justify:
        CUI_JUSTIFY_START = 0
        CUI_JUSTIFY_CENTER = 1
        CUI_JUSTIFY_END = 2
        CUI_JUSTIFY_BETWEEN = 3
        CUI_JUSTIFY_AROUND = 4

    ctypedef enum cui_key:
        CUI_KEY_NONE = 0
        CUI_KEY_TAB = 1
        CUI_KEY_ENTER = 2
        CUI_KEY_ESCAPE = 3
        CUI_KEY_BACKSPACE = 4
        CUI_KEY_DELETE = 5
        CUI_KEY_SPACE = 6
        CUI_KEY_LEFT = 7
        CUI_KEY_RIGHT = 8
        CUI_KEY_UP = 9
        CUI_KEY_DOWN = 10
        CUI_KEY_HOME = 11
        CUI_KEY_END = 12
        CUI_KEY_PAGE_UP = 13
        CUI_KEY_PAGE_DOWN = 14
        CUI_KEY_A = 15
        CUI_KEY_B = 16
        CUI_KEY_C = 17
        CUI_KEY_D = 18
        CUI_KEY_E = 19
        CUI_KEY_F = 20
        CUI_KEY_G = 21
        CUI_KEY_H = 22
        CUI_KEY_I = 23
        CUI_KEY_J = 24
        CUI_KEY_K = 25
        CUI_KEY_L = 26
        CUI_KEY_M = 27
        CUI_KEY_N = 28
        CUI_KEY_O = 29
        CUI_KEY_P = 30
        CUI_KEY_Q = 31
        CUI_KEY_R = 32
        CUI_KEY_S = 33
        CUI_KEY_T = 34
        CUI_KEY_U = 35
        CUI_KEY_V = 36
        CUI_KEY_W = 37
        CUI_KEY_X = 38
        CUI_KEY_Y = 39
        CUI_KEY_Z = 40
        CUI_KEY_0 = 41
        CUI_KEY_1 = 42
        CUI_KEY_2 = 43
        CUI_KEY_3 = 44
        CUI_KEY_4 = 45
        CUI_KEY_5 = 46
        CUI_KEY_6 = 47
        CUI_KEY_7 = 48
        CUI_KEY_8 = 49
        CUI_KEY_9 = 50
        CUI_KEY_MINUS = 51
        CUI_KEY_EQUAL = 52
        CUI_KEY_COMMA = 53
        CUI_KEY_PERIOD = 54
        CUI_KEY_SLASH = 55
        CUI_KEY_F1 = 56
        CUI_KEY_F2 = 57
        CUI_KEY_F3 = 58
        CUI_KEY_F4 = 59
        CUI_KEY_F5 = 60
        CUI_KEY_F6 = 61
        CUI_KEY_F7 = 62
        CUI_KEY_F8 = 63
        CUI_KEY_F9 = 64
        CUI_KEY_F10 = 65
        CUI_KEY_F11 = 66
        CUI_KEY_F12 = 67
        CUI_KEY_COUNT = 68

    ctypedef enum cui_loader_style:
        CUI_LOADER_DOTS = 0
        CUI_LOADER_BARS = 1
        CUI_LOADER_PULSE = 2
        CUI_LOADER_ORBIT = 3
        CUI_LOADER_GRID = 4

    ctypedef enum cui_log_level:
        CUI_LOG_TRACE = 0
        CUI_LOG_DEBUG = 1
        CUI_LOG_INFO = 2
        CUI_LOG_WARN = 3
        CUI_LOG_ERROR = 4
        CUI_LOG_LEVEL_COUNT = 5

    ctypedef enum cui_mod:
        CUI_MOD_SHIFT = 1
        CUI_MOD_CTRL = 2
        CUI_MOD_ALT = 4
        CUI_MOD_SUPER = 8

    ctypedef enum cui_mouse_button:
        CUI_MOUSE_LEFT = 0
        CUI_MOUSE_RIGHT = 1
        CUI_MOUSE_MIDDLE = 2

    ctypedef enum cui_placement:
        CUI_PLACE_BOTTOM_START = 0
        CUI_PLACE_BOTTOM = 1
        CUI_PLACE_BOTTOM_END = 2
        CUI_PLACE_TOP_START = 3
        CUI_PLACE_TOP = 4
        CUI_PLACE_TOP_END = 5
        CUI_PLACE_RIGHT_START = 6
        CUI_PLACE_LEFT_START = 7
        CUI_PLACE_RIGHT = 8
        CUI_PLACE_LEFT = 9

    ctypedef enum cui_query_type:
        CUI_QUERY_TEXT = 0
        CUI_QUERY_NUMBER = 1
        CUI_QUERY_CHOICE = 2
        CUI_QUERY_BOOL = 3

    ctypedef enum cui_severity:
        CUI_SEVERITY_ERROR = 0
        CUI_SEVERITY_WARNING = 1
        CUI_SEVERITY_INFO = 2
        CUI_SEVERITY_HINT = 3

    ctypedef enum cui_side:
        CUI_SIDE_RIGHT = 0
        CUI_SIDE_LEFT = 1
        CUI_SIDE_BOTTOM = 2
        CUI_SIDE_TOP = 3

    ctypedef enum cui_size_kind:
        CUI_SIZE_FIT = 0
        CUI_SIZE_GROW = 1
        CUI_SIZE_FIXED = 2
        CUI_SIZE_PERCENT = 3

    ctypedef enum cui_status:
        CUI_STATUS_IDLE = 0
        CUI_STATUS_BUSY = 1
        CUI_STATUS_SUCCESS = 2
        CUI_STATUS_ERROR = 3

    ctypedef enum cui_tabs_variant:
        CUI_TABS_UNDERLINE = 0
        CUI_TABS_PILL = 1

    ctypedef enum cui_task_status:
        CUI_TASK_PENDING = 0
        CUI_TASK_RUNNING = 1
        CUI_TASK_DONE = 2
        CUI_TASK_FAILED = 3
        CUI_TASK_SKIPPED = 4

    ctypedef enum cui_text_align:
        CUI_TEXT_START = 0
        CUI_TEXT_CENTER = 1
        CUI_TEXT_RIGHT = 2
        CUI_TEXT_LEFT = 3
        CUI_TEXT_END = 4

    ctypedef enum cui_texture_format:
        CUI_TEXTURE_R8 = 1
        CUI_TEXTURE_RGBA8 = 4

    ctypedef enum cui_theme_mode:
        CUI_THEME_LIGHT = 0
        CUI_THEME_DARK = 1

    ctypedef enum cui_timeline_ruler:
        CUI_TIMELINE_FRAMES = 0
        CUI_TIMELINE_SECONDS = 1
        CUI_TIMELINE_TIMECODE = 2

    ctypedef enum cui_token:
        CUI_TOKEN_NONE = 0
        CUI_TOKEN_BACKGROUND = 1
        CUI_TOKEN_SURFACE = 2
        CUI_TOKEN_SURFACE_RAISED = 3
        CUI_TOKEN_SURFACE_MUTED = 4
        CUI_TOKEN_FOREGROUND = 5
        CUI_TOKEN_TEXT_SECONDARY = 6
        CUI_TOKEN_TEXT_MUTED = 7
        CUI_TOKEN_BORDER = 8
        CUI_TOKEN_BORDER_SUBTLE = 9
        CUI_TOKEN_BORDER_STRONG = 10
        CUI_TOKEN_ACCENT = 11
        CUI_TOKEN_ACCENT_STRONG = 12
        CUI_TOKEN_ACCENT_SUBTLE = 13
        CUI_TOKEN_ACCENT_FOREGROUND = 14
        CUI_TOKEN_SUCCESS = 15
        CUI_TOKEN_WARNING = 16
        CUI_TOKEN_DANGER = 17
        CUI_TOKEN_INFO = 18
        CUI_TOKEN_CONTROL_ON = 19
        CUI_TOKEN_CONTROL_GLYPH = 20
        CUI_TOKEN_CONTROL_TRACK = 21
        CUI_TOKEN_CONTROL_TRACK_HOVER = 22
        CUI_TOKEN_CONTROL_THUMB = 23
        CUI_TOKEN_CONTROL_THUMB_ON = 24
        CUI_TOKEN_HOVER = 25
        CUI_TOKEN_ACTIVE = 26
        CUI_TOKEN_SCRIM = 27
        CUI_TOKEN_FOCUS_RING = 28
        CUI_TOKEN_SERIES_1 = 29
        CUI_TOKEN_SERIES_2 = 30
        CUI_TOKEN_SERIES_3 = 31
        CUI_TOKEN_SERIES_4 = 32
        CUI_TOKEN_SERIES_5 = 33
        CUI_TOKEN_SERIES_6 = 34
        CUI_TOKEN_COUNT = 35

    ctypedef enum cui_tone:
        CUI_TONE_NEUTRAL = 0
        CUI_TONE_INFO = 1
        CUI_TONE_SUCCESS = 2
        CUI_TONE_WARNING = 3
        CUI_TONE_DANGER = 4
        CUI_TONE_VIOLET = 5
        CUI_TONE_TEAL = 6
        CUI_TONE_ROSE = 7
        CUI_TONE_ACCENT = 8

    ctypedef enum cui_voice_state:
        CUI_VOICE_IDLE = 0
        CUI_VOICE_LISTENING = 1
        CUI_VOICE_THINKING = 2
        CUI_VOICE_SPEAKING = 3

    ctypedef struct cui_color:
        uint8_t r
        uint8_t g
        uint8_t b
        uint8_t a

    ctypedef struct cui_corners:
        float tl
        float tr
        float br
        float bl

    ctypedef struct cui_date:
        int year
        int month
        int day

    ctypedef struct cui_key_combo:
        int mods
        int key

    ctypedef struct cui_rect:
        float x
        float y
        float w
        float h

    ctypedef struct cui_size:
        int kind
        float value

    ctypedef struct cui_vec2:
        float x
        float y

    ctypedef struct cui_agent_plan_opts:
        const char * title

    ctypedef struct cui_agent_status_opts:
        int status
        float seconds
        const char * icon

    ctypedef struct cui_alert_opts:
        const char * description
        int tone
        const char * icon
        uint8_t dismissible

    ctypedef struct cui_allocator:
        void * user

    ctypedef struct cui_api_explorer_opts:
        cui_size width
        float height
        int * selected

    ctypedef struct cui_api_explorer_result:
        int selected
        int try_it

    ctypedef struct cui_api_param:
        const char * name
        const char * type
        uint8_t required
        const char * description

    ctypedef struct cui_avatar_opts:
        float size
        uintptr_t image
        const char * status
        uint8_t square

    ctypedef struct cui_badge_opts:
        int tone
        uint8_t dot
        uint8_t solid
        const char * icon
        int size

    ctypedef struct cui_banner_opts:
        int tone
        const char * icon
        const char * action
        uint8_t dismissible

    ctypedef struct cui_bar_list_opts:
        cui_size width
        const char * format
        int max_rows
        uint8_t keep_order
        cui_color color

    ctypedef struct cui_blame_commit:
        const char * hash
        const char * author
        const char * summary
        int64_t time

    ctypedef struct cui_blame_opts:
        cui_size width
        float height
        const char * lang
        int64_t now
        int first_line

    ctypedef struct cui_blame_result:
        int clicked
        int hovered

    ctypedef struct cui_box:
        const char * id
        int dir
        cui_size width
        cui_size height
        float min_width
        float max_width
        float min_height
        float max_height
        float pad
        float pad_x
        float pad_y
        float pad_top
        float pad_right
        float pad_bottom
        float pad_left
        float gap
        int columns
        float min_column_width
        uint8_t wrap
        int align
        int justify
        cui_color bg
        cui_color border_color
        float border
        float radius
        float radius_tl
        float radius_tr
        float radius_br
        float radius_bl
        int elevation
        uint8_t scroll_x
        uint8_t scroll_y
        uint8_t clip
        float opacity
        int direction

    ctypedef struct cui_button_opts:
        int variant
        int size
        const char * icon
        const char * icon_right
        uint8_t disabled
        uint8_t loading
        uint8_t full_width
        uint8_t selected
        const char * tooltip
        const char * shortcut
        cui_size width
        cui_color color

    ctypedef struct cui_cal_event:
        const char * title
        const char * detail
        int day
        float start
        float end
        int tone

    ctypedef struct cui_calendar_heatmap_opts:
        float cell
        cui_color color
        const char * format
        const char * unit

    ctypedef struct cui_candle:
        float open
        float high
        float low
        float close
        float volume

    ctypedef struct cui_candlestick_opts:
        cui_size width
        float height
        const char *const * labels
        const char * format
        const cui_series * overlays
        int overlay_count
        uint8_t no_volume
        uint8_t ohlc
        cui_color up
        cui_color down

    ctypedef struct cui_canvas_result:
        cui_rect rect
        uint8_t hovered
        uint8_t pressed
        uint8_t clicked
        cui_vec2 mouse

    ctypedef struct cui_card_opts:
        const char * id
        cui_size width
        cui_size height
        float min_width
        float max_width
        float pad
        float pad_x
        float pad_y
        float gap
        int dir
        int align
        uint8_t wrap
        uint8_t hoverable
        uint8_t muted
        uint8_t selected

    ctypedef struct cui_card_stack_opts:
        cui_size width
        float height
        int visible

    ctypedef struct cui_carousel_opts:
        float height
        float auto_advance
        float gap
        uint8_t no_arrows
        uint8_t no_dots
        uint8_t loop

    ctypedef struct cui_chart_annotation:
        int kind
        double x
        double y
        const char * label
        const char * detail
        uint8_t accent

    ctypedef struct cui_chart_opts:
        cui_size width
        float height
        const char *const * labels
        int label_count
        uint8_t area
        uint8_t no_grid
        uint8_t no_legend
        uint8_t stacked
        uint8_t smooth
        const char * format
        float min
        float max
        const cui_chart_annotation * annotations
        int annotation_count

    ctypedef struct cui_chat_opts:
        uint8_t mine
        const char * author
        const char * time
        const char * status
        uint8_t grouped
        uint8_t last_in_group
        uintptr_t avatar
        uint8_t markdown
        cui_markdown_result * markdown_result

    ctypedef struct cui_check_opts:
        const char * description
        uint8_t disabled
        uint8_t indeterminate

    ctypedef struct cui_check_step:
        const char * title
        const char * description
        const char * action
        uint8_t done

    ctypedef struct cui_checklist_opts:
        const char * title
        const char * description

    ctypedef struct cui_chip_opts:
        const char * icon
        uint8_t disabled

    ctypedef struct cui_choice:
        const char * title
        const char * description
        const char * icon
        const char * badge

    ctypedef struct cui_code_editor_opts:
        const char * lang
        cui_size width
        float height
        float size
        int tab_size
        uint8_t use_tabs
        uint8_t read_only
        uint8_t no_line_numbers
        uint8_t autofocus
        const char * placeholder
        const cui_text_mark * marks
        int mark_count

    ctypedef struct cui_code_editor_result:
        uint8_t changed
        uint8_t refused
        uint8_t focused
        int cursor
        int anchor
        int line
        int column
        int line_count
        int length
        int bracket
        int bracket_match
        int find_matches
        int find_index

    ctypedef struct cui_code_opts:
        const char * lang
        const char * title
        uint8_t line_numbers
        int highlight_from
        int highlight_to
        float max_height
        float size
        uint8_t no_header

    ctypedef struct cui_command:
        const char * title
        const char * icon
        const char * group
        const char * shortcut

    ctypedef struct cui_comment_opts:
        const char * time
        int depth
        int * likes
        uint8_t * liked
        uint8_t edited
        const char * badge

    ctypedef struct cui_commit_graph_opts:
        cui_size width
        float height
        int * selected

    ctypedef struct cui_commit_graph_result:
        int clicked
        int activated
        int hovered

    ctypedef struct cui_compare_opts:
        cui_size width
        float height
        const char * before_label
        const char * after_label
        float aspect

    ctypedef struct cui_composer_opts:
        const char * placeholder
        uint8_t busy
        const char *const * attachments
        int attachment_count
        int * removed
        const cui_model * models
        int model_count
        int * model
        int max_lines
        cui_size width

    ctypedef struct cui_confirm_opts:
        const char * confirm_label
        const char * icon
        int variant
        int size
        float timeout

    ctypedef struct cui_confirm_popover_opts:
        const char * title
        const char * description
        const char * confirm_label
        const char * cancel_label
        uint8_t danger
        int placement

    ctypedef struct cui_context_opts:
        const cui_viz_item * parts
        int part_count
        const char * unit

    ctypedef struct cui_countdown_opts:
        uint8_t hide_days
        uint8_t compact

    ctypedef struct cui_counter_opts:
        const char * format
        float size
        int font
        cui_color color
        uint8_t group_thousands

    ctypedef struct cui_coverage_file:
        const char * path
        int lines
        int lines_hit
        int branches
        int branches_hit
        int functions
        int functions_hit

    ctypedef struct cui_coverage_opts:
        cui_size width
        float height
        float low
        float high

    ctypedef struct cui_coverage_result:
        int activated
        float lines

    ctypedef struct cui_cropper_opts:
        cui_size width
        cui_size height
        float aspect
        uint8_t round
        float min_size

    ctypedef struct cui_renderer_iface:
        void * user

    ctypedef struct cui_ctx_desc:
        cui_renderer_iface renderer
        cui_allocator allocator
        int theme
        int accent
        uint8_t no_default_fonts
        int direction

    ctypedef struct cui_curve_key:
        float x
        float y
        float in_dx
        float in_dy
        float out_dx
        float out_dy
        uint8_t mode

    ctypedef struct cui_curve_opts:
        float x_min
        float x_max
        float y_min
        float y_max
        cui_size width
        float height
        const char * x_format
        const char * y_format
        const char * x_label
        const char * y_label
        int * selected
        uint8_t snap
        uint8_t show_playhead
        float playhead

    ctypedef struct cui_curve_result:
        uint8_t changed
        int added
        int removed
        int selected
        uint8_t hovered
        float hover_x
        float hover_y

    ctypedef struct cui_date_opts:
        const char * label
        const char * placeholder
        cui_size width

    ctypedef struct cui_date_range:
        cui_date start
        cui_date end

    ctypedef struct cui_date_range_opts:
        const char * label
        const char * placeholder
        cui_size width
        uint8_t no_presets

    ctypedef struct cui_diagnostic:
        int severity
        const char * message
        const char * file
        int line
        int column
        const char * source
        const char * code

    ctypedef struct cui_dialog_opts:
        const char * description
        float width
        uint8_t no_close_button
        uint8_t persistent

    ctypedef struct cui_diff_hunk:
        int old_start
        int old_count
        int new_start
        int new_count

    ctypedef struct cui_diff_opts:
        int mode
        const char * language
        const char * old_title
        const char * new_title
        int * current
        int context
        uint8_t no_fold
        uint8_t ignore_eol
        float split_min_width
        cui_size width
        float height
        float size

    ctypedef struct cui_diff_range:
        int start
        int length

    ctypedef struct cui_diff_result:
        int added
        int removed
        int changes
        int current
        uint8_t current_changed
        int mode
        int folds
        int hidden
        uint8_t recomputed
        uint8_t approximate

    ctypedef struct cui_diff_row:
        int kind
        int old_line
        int new_line
        int change
        int hidden

    ctypedef struct cui_diff_stats:
        int added
        int removed
        int hunks
        int old_lines
        int new_lines
        uint8_t approximate

    ctypedef struct cui_doc_tab:
        const char * title
        const char * icon
        const char * tooltip
        uint8_t dirty

    ctypedef struct cui_doc_tabs_opts:
        uint8_t shortcuts
        uint8_t no_close
        uint8_t no_reorder

    ctypedef struct cui_doc_tabs_result:
        uint8_t changed
        int close
        int move_from
        int move_to

    ctypedef struct cui_dock_item_opts:
        cui_color color
        uint8_t running
        int badge

    ctypedef struct cui_dock_opts:
        float size
        float magnify

    ctypedef struct cui_dock_panel_opts:
        const char * icon
        uint8_t dirty

    ctypedef struct cui_dockspace_opts:
        const char * layout
        cui_size width
        cui_size height
        float min_panel_width
        float min_panel_height
        uint8_t shortcuts

    ctypedef struct cui_dot_chart_opts:
        cui_size width
        float height
        double x_min
        double x_max
        int x_units
        const char * x_format
        double x_step
        float min
        float max
        const char * format
        const char * unit
        float pitch
        uint8_t no_grid
        uint8_t no_axis
        uint8_t no_readout
        const cui_chart_annotation * annotations
        int annotation_count

    ctypedef struct cui_dot_chart_result:
        int hovered
        double x
        float value
        uint8_t clicked

    ctypedef struct cui_dot_display_opts:
        float pitch
        cui_color color
        uint8_t accent
        uint8_t no_dim
        uint8_t marquee
        int align
        cui_size width

    ctypedef struct cui_dot_series:
        const float * values
        const char * name
        uint8_t accent

    ctypedef struct cui_draw_cmd:
        cui_rect clip
        uintptr_t texture
        uint32_t index_offset
        uint32_t index_count

    ctypedef struct cui_draw_data:
        const cui_vertex * vertices
        int vertex_count
        const uint32_t * indices
        int index_count
        const cui_draw_cmd * commands
        int command_count
        int width_px
        int height_px
        cui_color clear_color
        uintptr_t font_atlas

    ctypedef struct cui_dropzone_opts:
        const char * title
        const char * description
        const char * icon
        const char * accept
        float height
        cui_size width
        uint8_t compact

    ctypedef struct cui_emoji_picker_opts:
        cui_size width
        float height
        float size
        char * recent
        size_t recent_cap
        int * tone
        const char * placeholder
        const char * empty_text
        const char * hint
        const char *const * group_names
        uint8_t no_search
        uint8_t no_preview
        uint8_t no_tone

    ctypedef struct cui_empty_opts:
        const char * icon
        const char * description
        const char * action

    ctypedef struct cui_event_track_opts:
        cui_size width
        double step
        int units
        const char * format
        double label_step
        int * selected
        uint8_t no_add
        uint8_t no_remove
        uint8_t no_axis

    ctypedef struct cui_event_track_result:
        uint8_t changed
        int added
        int removed
        int selected
        uint8_t dragging

    ctypedef struct cui_expandable_card_opts:
        const char * description
        const char * icon
        const char * badge
        int badge_tone

    ctypedef struct cui_expandable_text_opts:
        int lines
        float size
        cui_color color
        cui_color fade_to

    ctypedef struct cui_fader_opts:
        const char * label
        const char * format
        const char * unit
        float length
        uint8_t horizontal
        float step
        float reset
        const float * ticks
        int tick_count
        const float * meter
        int meter_channels
        uint8_t hide_value
        uint8_t disabled

    ctypedef struct cui_feature_flags_opts:
        cui_size width
        float height

    ctypedef struct cui_feature_flags_result:
        int flag
        int env

    ctypedef struct cui_file_browser_opts:
        cui_size width
        cui_size height
        const char * filter
        uint8_t folders_only
        uint8_t hidden
        uint8_t no_places
        const char *const * places
        int place_count
        void * list_user
        int max_entries

    ctypedef struct cui_file_browser_result:
        const char * picked
        const char * selected
        uint8_t navigated
        uint8_t error

    ctypedef struct cui_file_entry:
        const char * name
        uint8_t dir
        uint64_t size
        int64_t modified

    ctypedef struct cui_file_picker_opts:
        const char * title
        uint8_t save
        uint8_t folders
        const char * start
        const char * name
        const char * filter
        const char * filter_label
        void * list_user

    ctypedef struct cui_flame_opts:
        cui_size width
        float height
        float row_height
        double min_range

    ctypedef struct cui_flame_result:
        uint8_t selection_changed
        uint8_t view_changed
        int hovered
        int zoomed

    ctypedef struct cui_flame_span:
        const char * name
        double start
        double end
        int depth
        uint32_t color_key

    ctypedef struct cui_flame_view:
        double start
        double end
        float scroll

    ctypedef struct cui_funnel_opts:
        cui_size width
        float height
        const char * format
        cui_color color

    ctypedef struct cui_gantt_opts:
        float day_width
        float row_height
        cui_size height
        int today
        uint8_t read_only

    ctypedef struct cui_gantt_task:
        const char * name
        const char * owner
        int start
        int end
        float progress
        int tone
        int depends_on
        uint8_t milestone

    ctypedef struct cui_gauge_band:
        float to
        int tone

    ctypedef struct cui_gradient_opts:
        cui_size width
        float height
        int * selected

    ctypedef struct cui_gradient_result:
        uint8_t changed
        int added
        int removed
        int selected

    ctypedef struct cui_gradient_stop:
        float pos
        cui_color color

    ctypedef struct cui_gradient_text_opts:
        int font
        float size
        cui_color to
        uint8_t animate
        cui_size width

    ctypedef struct cui_graph_edge:
        int to

    ctypedef struct cui_graph_node:
        const char * label
        const char * detail
        int tone

    ctypedef struct cui_graph_opts:
        cui_size width
        float height
        uint8_t top_down
        int * selected

    ctypedef struct cui_graph_result:
        int clicked
        int activated
        int hovered

    ctypedef struct cui_grid_column:
        const char * title
        float width
        int align
        uint8_t sortable
        uint8_t fixed
        int priority

    ctypedef struct cui_grid_opts:
        cui_size width
        cui_size height
        float row_height
        uint8_t * selected
        cui_table_sort * sort
        uint8_t striped
        int * cursor
        uint8_t hide_checkboxes
        int * anchor

    ctypedef struct cui_heatmap_opts:
        const char *const * row_labels
        const char *const * col_labels
        float cell
        float min
        float max
        cui_color color
        const char * format
        cui_size width

    ctypedef struct cui_hex_range:
        size_t offset
        size_t length
        int tone
        const char * label

    ctypedef struct cui_hex_selection:
        size_t start
        size_t length
        size_t cursor

    ctypedef struct cui_hex_view_opts:
        cui_size width
        float height
        uint64_t base
        int bytes_per_row
        const cui_hex_range * ranges
        int range_count
        uint8_t * edit
        uint8_t no_ascii
        uint8_t no_header
        float size

    ctypedef struct cui_histogram_opts:
        float height
        const char * format

    ctypedef struct cui_hold_opts:
        float duration
        const char * icon
        int variant

    ctypedef struct cui_hover_card_opts:
        int placement
        float width
        float delay

    ctypedef struct cui_image_opts:
        cui_size width
        cui_size height
        float radius
        cui_color tint

    ctypedef struct cui_image_view:
        float zoom
        float cx
        float cy

    ctypedef struct cui_image_viewer_opts:
        cui_size width
        cui_size height
        float max_zoom
        uint8_t no_toolbar
        uint8_t checkerboard

    ctypedef struct cui_inline_edit_opts:
        int font
        float size
        const char * placeholder
        cui_size width

    ctypedef struct cui_input_opts:
        const char * label
        const char * placeholder
        const char * icon
        const char * hint
        const char * error
        uint8_t password
        uint8_t disabled
        uint8_t clearable
        uint8_t autofocus
        uint8_t read_only
        int size
        cui_size width
        float height
        const char * prefix
        const char * suffix

    ctypedef struct cui_inspector_opts:
        cui_size width
        float label_width

    ctypedef struct cui_json_opts:
        int expand_depth
        float max_height

    ctypedef struct cui_kanban_column_opts:
        cui_color dot
        int limit
        float width

    ctypedef struct cui_kanban_move:
        int card
        int from_column
        int to_column
        int to_index

    ctypedef struct cui_keymap_binding:
        cui_key_combo combo
        const char * action
        int category

    ctypedef struct cui_keymap_opts:
        cui_size width
        const char *const * categories
        int category_count
        int * mods
        uint8_t no_function_row

    ctypedef struct cui_keymap_result:
        int clicked
        int conflicts

    ctypedef struct cui_knob_opts:
        const char * label
        const char * format
        const char * unit
        float size
        float step
        float reset
        uint8_t bipolar
        uint8_t log_scale
        uint8_t hide_value
        uint8_t disabled
        cui_color color

    ctypedef struct cui_kv_editor_opts:
        const char * key_placeholder
        const char * value_placeholder
        uint8_t no_toggles
        uint8_t no_secrets
        uint8_t read_only
        cui_size width

    ctypedef struct cui_level_meter_opts:
        float min_db
        float max_db
        float length
        float thickness
        uint8_t horizontal
        uint8_t scale
        uint8_t segmented
        float hold
        float decay

    ctypedef struct cui_list_item_opts:
        const char * icon
        const char * subtitle
        const char * trailing
        uint8_t selected
        const char * avatar

    ctypedef struct cui_loader_opts:
        int style
        float size
        cui_color color

    ctypedef struct cui_log_line:
        uint32_t offset
        uint32_t len
        double time
        uint8_t level

    ctypedef struct cui_log_view_opts:
        cui_size width
        float height
        uint8_t timestamps
        uint8_t no_toolbar
        float size

    ctypedef struct cui_markdown_opts:
        cui_size width
        uint8_t fit_content
        int length
        float size
        cui_color color
        uint8_t streaming
        uint8_t compact

    ctypedef struct cui_markdown_result:
        const char * link
        const char * hovered_link
        int task_offset
        int task_line
        uint8_t task_checked
        float height

    ctypedef struct cui_menu_bar_menu_opts:
        char mnemonic
        float width
        uint8_t disabled

    ctypedef struct cui_menu_bar_opts:
        uint8_t no_border

    ctypedef struct cui_menu_item_opts:
        const char * icon
        const char * shortcut
        uint8_t danger
        uint8_t disabled
        uint8_t checked

    ctypedef struct cui_menu_opts:
        const char * icon
        int variant
        int placement
        float width
        uint8_t icon_only

    ctypedef struct cui_metric_opts:
        float delta
        const char * delta_label
        const float * spark
        int spark_count
        const char * icon
        cui_size width
        uint8_t lower_is_better

    ctypedef struct cui_model:
        const char * name
        const char * detail
        const char * badge
        const char * icon

    ctypedef struct cui_model_picker_opts:
        uint8_t ghost
        int placement

    ctypedef struct cui_money_opts:
        const char * label
        const char * symbol
        const char * code
        int decimals
        cui_size width
        const char * hint

    ctypedef struct cui_month_event:
        const char * title
        cui_date start
        cui_date end
        float time
        uint8_t all_day
        int tone

    ctypedef struct cui_month_opts:
        cui_date * selected
        int first_weekday
        float cell_height
        const char *const * month_names
        const char *const * day_names
        uint8_t hour12
        cui_date today

    ctypedef struct cui_month_result:
        int event
        uint8_t day_clicked
        uint8_t day_activated
        uint8_t month_changed

    ctypedef struct cui_multi_select_opts:
        const char * label
        const char * placeholder
        const char *const * icons
        uint8_t searchable
        int max_chips
        cui_size width

    ctypedef struct cui_nav_opts:
        const char * icon
        const char * badge
        uint8_t selected
        const char * group

    ctypedef struct cui_node_editor_opts:
        cui_size width
        cui_size height
        float min_zoom
        float max_zoom
        uint8_t no_grid
        uint8_t minimap

    ctypedef struct cui_node_opts:
        float width
        const char * icon

    ctypedef struct cui_node_view:
        float x
        float y
        float zoom

    ctypedef struct cui_now_playing:
        const char * title
        const char * artist
        uintptr_t art
        cui_color art_color
        float position
        float duration
        uint8_t playing

    ctypedef struct cui_now_playing_opts:
        cui_size width
        uint8_t compact

    ctypedef struct cui_number_opts:
        const char * label
        double step
        int decimals
        uint8_t disabled
        cui_size width
        const char * suffix

    ctypedef struct cui_path_bar_opts:
        const char * icon
        const char * text
        const char * placeholder
        int size
        cui_size width
        uint8_t menus
        uint8_t no_edit

    ctypedef struct cui_path_bar_result:
        int clicked
        const char * submitted
        uint8_t editing

    ctypedef struct cui_pin_opts:
        int type

    ctypedef struct cui_pipeline_job:
        const char * name
        int stage
        int status
        float duration
        uint8_t allow_failure

    ctypedef struct cui_pipeline_opts:
        cui_size width
        int * selected

    ctypedef struct cui_pipeline_result:
        int clicked
        int hovered

    ctypedef struct cui_plan_step:
        const char * title
        const char * detail
        int status

    ctypedef struct cui_popover_opts:
        int placement
        float width
        float pad
        float gap

    ctypedef struct cui_presence_user:
        const char * name
        cui_color color
        uintptr_t avatar
        uint8_t idle

    ctypedef struct cui_problems_opts:
        cui_size width
        float height
        uint8_t no_toolbar

    ctypedef struct cui_problems_result:
        int selected
        int activated
        int shown

    ctypedef struct cui_progress_opts:
        uint8_t indeterminate
        int tone
        float height
        const char * label
        uint8_t show_value
        cui_size width

    ctypedef struct cui_prompt_suggestion:
        const char * icon
        const char * title
        const char * detail

    ctypedef struct cui_prompt_suggestions_opts:
        int columns

    ctypedef struct cui_prop_opts:
        float min
        float max
        float step
        const char * format
        const char * suffix
        const char * placeholder
        const char * tooltip
        uint8_t disabled
        uint8_t checkbox

    ctypedef struct cui_query_opts:
        cui_size width
        int max_depth
        uint8_t read_only

    ctypedef struct cui_radar_opts:
        float size
        float max
        const char * format
        uint8_t no_legend

    ctypedef struct cui_radial_gauge_opts:
        const char * label
        const char * format
        const char * unit
        float size
        float sweep
        const cui_gauge_band * bands
        int band_count
        int ticks
        float target
        uint8_t show_target
        uint8_t no_needle

    ctypedef struct cui_radio_cards_opts:
        int columns

    ctypedef struct cui_reaction:
        const char * icon
        int count
        uint8_t active

    ctypedef struct cui_readout_opts:
        const char * unit
        const char * detail
        int size
        int tone
        uint8_t accent
        int align
        cui_size width

    ctypedef struct cui_reasoning_opts:
        uint8_t thinking
        float seconds
        const char * title

    ctypedef struct cui_regex_tester_opts:
        cui_size width
        float height
        int * flags

    ctypedef struct cui_regex_tester_result:
        uint8_t valid
        int matches
        const char * error

    ctypedef struct cui_request_bar_opts:
        cui_size width
        uint8_t loading
        const char * placeholder

    ctypedef struct cui_request_bar_result:
        uint8_t send
        uint8_t cancel
        uint8_t changed

    ctypedef struct cui_response_actions_opts:
        const char * copy_text
        int * vote
        uint8_t no_regenerate
        uint8_t no_share

    ctypedef struct cui_rings_opts:
        float size
        float thickness
        const char * center
        const char * caption
        uint8_t legend

    ctypedef struct cui_ruler_opts:
        float step
        int major_every
        float spacing
        const char * format
        const char * unit
        cui_size width

    ctypedef struct cui_sankey_link:
        int to
        float value

    ctypedef struct cui_sankey_opts:
        cui_size width
        float height
        const char * format
        float node_width

    ctypedef struct cui_scatter_opts:
        cui_size width
        float height
        const char * x_label
        const char * y_label
        const char * x_format
        const char * y_format
        uint8_t no_legend

    ctypedef struct cui_schedule_opts:
        cui_size width
        int64_t now
        uint8_t utc
        int next_count

    ctypedef struct cui_schedule_result:
        uint8_t changed
        uint8_t valid
        int64_t next

    ctypedef struct cui_scroll_opts:
        const char * id
        cui_size width
        cui_size height
        uint8_t horizontal
        float pad
        float gap
        uint8_t fade_edges
        cui_color fade_color

    ctypedef struct cui_scrub_opts:
        float step
        const char * format
        const char * suffix
        const char * icon
        cui_size width

    ctypedef struct cui_segmented_opts:
        int size
        uint8_t full_width
        const char *const * icons

    ctypedef struct cui_select_opts:
        const char * label
        const char * placeholder
        const char *const * icons
        uint8_t searchable
        uint8_t disabled
        cui_size width

    ctypedef struct cui_series:
        const char * name
        const float * values
        int count
        cui_color color

    ctypedef struct cui_shadow:
        float y
        float blur
        float spread
        float alpha

    ctypedef struct cui_sheet_opts:
        int side
        float size
        const char * description

    ctypedef struct cui_shortcut_recorder_opts:
        const char * placeholder
        cui_size width

    ctypedef struct cui_signature_opts:
        cui_size width
        float height
        const char * placeholder
        cui_color ink

    ctypedef struct cui_slider_opts:
        float step
        uint8_t show_value
        const char * format
        uint8_t disabled
        cui_size width

    ctypedef struct cui_source:
        const char * title
        const char * url
        const char * snippet

    ctypedef struct cui_speed_action:
        const char * icon
        const char * label

    ctypedef struct cui_speed_dial_opts:
        const char * icon
        int placement
        const char * tooltip

    ctypedef struct cui_split_bar_opts:
        cui_size width
        float height
        const char * format
        uint8_t no_legend

    ctypedef struct cui_split_button_opts:
        int variant
        int size
        const char * icon
        const char *const * item_icons
        uint8_t disabled

    ctypedef struct cui_split_opts:
        uint8_t vertical
        float min_first
        float min_second
        cui_size width
        cui_size height

    ctypedef struct cui_spotlight_opts:
        cui_size width
        cui_size height
        float pad
        float gap
        cui_color color
        uint8_t beam

    ctypedef struct cui_stack_trace_opts:
        cui_size width
        const char * title
        const char * message
        const char * lang

    ctypedef struct cui_stack_trace_result:
        int clicked

    ctypedef struct cui_status_bar_opts:
        uint8_t no_border

    ctypedef struct cui_status_button_opts:
        const char * busy_label
        const char * success_label
        const char * error_label
        const char * icon
        int variant
        int size

    ctypedef struct cui_status_item_opts:
        const char * icon
        int tone
        const char * tooltip
        uint8_t disabled

    ctypedef struct cui_status_progress_opts:
        const char * label
        uint8_t indeterminate
        float width

    ctypedef struct cui_swipe_action:
        const char * icon
        const char * label
        int tone

    ctypedef struct cui_tab_bar_item:
        const char * icon
        const char * label
        int badge

    ctypedef struct cui_tab_bar_opts:
        cui_size width
        uint8_t labels_on_selected_only

    ctypedef struct cui_table_column:
        const char * title
        cui_size width
        int align
        uint8_t sortable

    ctypedef struct cui_table_opts:
        cui_table_sort * sort
        cui_size height
        uint8_t striped
        uint8_t compact
        uint8_t selectable

    ctypedef struct cui_table_sort:
        int column
        uint8_t descending

    ctypedef struct cui_tabs_opts:
        int variant
        const char *const * icons
        uint8_t full_width

    ctypedef struct cui_tag_opts:
        const char * label
        const char * placeholder
        int max_tags
        cui_size width

    ctypedef struct cui_terminal_line:
        uint32_t offset
        uint32_t len
        uint32_t cols

    ctypedef struct cui_terminal_opts:
        cui_size width
        float height
        float size
        const char * prompt
        uint8_t no_input

    ctypedef struct cui_terminal_result:
        const char * command
        uint8_t interrupt

    ctypedef struct cui_test_explorer_opts:
        cui_size width
        float height

    ctypedef struct cui_test_explorer_result:
        int selected
        int activated
        int run
        uint8_t run_all
        int passed
        int failed
        int skipped
        int total

    ctypedef struct cui_test_item:
        const char * name
        int depth
        int status
        float duration
        const char * message

    ctypedef struct cui_text_fx_opts:
        int font
        float size
        cui_color color
        cui_size width
        uint8_t nowrap
        float speed
        float delay
        uint8_t caret

    ctypedef struct cui_text_mark:
        int start
        int end
        int color

    ctypedef struct cui_text_metrics:
        float width
        float height
        float ascent
        float descent
        float line_height

    ctypedef struct cui_text_opts:
        int font
        float size
        cui_color color
        int align
        uint8_t nowrap
        uint8_t tabular
        uint8_t selectable
        cui_size width
        float line_height
        int direction

    ctypedef struct cui_ticker_item:
        const char * label
        const char * value
        float delta
        uint8_t lower_is_better

    ctypedef struct cui_ticker_opts:
        float speed
        float height

    ctypedef struct cui_tile_opts:
        const char * icon
        const char * detail
        cui_color color
        cui_size width
        uint8_t wide

    ctypedef struct cui_time_histogram_opts:
        cui_size width
        float height
        uint8_t utc

    ctypedef struct cui_time_histogram_result:
        uint8_t selection_changed
        int hovered

    ctypedef struct cui_time_opts:
        const char * label
        uint8_t twelve_hour
        int minute_step
        cui_size width

    ctypedef struct cui_timeline_clip:
        float start
        float end
        float offset
        const char * name
        uint8_t selected

    ctypedef struct cui_timeline_editor_opts:
        float start
        float end
        float fps
        int ruler
        cui_timeline_view * view
        float * out
        int * current_track
        int * current_key
        cui_size width
        float height
        float row_height
        float track_width
        uint8_t toggles
        uint8_t free_drag

    ctypedef struct cui_timeline_editor_result:
        uint8_t changed
        uint8_t time_changed
        uint8_t scrubbing
        uint8_t play_toggled
        uint8_t selection_changed
        uint8_t view_changed
        uint8_t keys_moved
        int added_track
        int added_key
        int removed_keys
        int removed_clips
        int clip_track
        int clip
        int toggled
        int current_track
        int current_key
        int hovered_track
        int hovered_key

    ctypedef struct cui_timeline_opts:
        const char * time
        const char * description
        const char * icon
        int tone
        uint8_t last

    ctypedef struct cui_timeline_view:
        float start
        float end
        float scroll

    ctypedef struct cui_toast_opts:
        const char * description
        int tone
        float duration
        const char * action
        uint8_t show_timer

    ctypedef struct cui_toc_item:
        const char * title
        const char * anchor
        int level

    ctypedef struct cui_toggle_group_opts:
        const char *const * icons
        uint8_t exclusive
        uint8_t icon_only
        int size

    ctypedef struct cui_tool_call_opts:
        int status
        const char * icon
        const char * detail
        const char * input
        const char * output
        float seconds

    ctypedef struct cui_tool_opts:
        const char * label
        const char * tooltip
        const char * shortcut
        uint8_t * toggle
        uint8_t disabled

    ctypedef struct cui_toolbar_opts:
        uint8_t no_border

    ctypedef struct cui_tour_opts:
        float width
        float padding
        uint8_t block_target
        const char * next_label
        const char * back_label
        const char * done_label
        const char * count_format

    ctypedef struct cui_tour_step:
        uint32_t target
        const char * title
        const char * body
        int placement

    ctypedef struct cui_trace_marker:
        const char * name
        double time
        int tone

    ctypedef struct cui_trace_opts:
        cui_size width
        float height
        float row_height
        const cui_trace_marker * markers
        int marker_count

    ctypedef struct cui_trace_result:
        uint8_t selection_changed
        uint8_t view_changed
        int hovered

    ctypedef struct cui_trace_span:
        const char * name
        double start
        double end
        int track
        int depth
        uint32_t color_key

    ctypedef struct cui_trace_track:
        const char * name
        uint8_t collapsed

    ctypedef struct cui_trace_view:
        double start
        double end
        float scroll
        double mark_start
        double mark_end

    ctypedef struct cui_tree_node:
        int parent
        int first_child
        int next_sibling
        uint32_t flags

    ctypedef struct cui_tree_opts:
        const char * icon
        uint8_t leaf
        uint8_t selected

    ctypedef struct cui_tree_table_opts:
        cui_size width
        cui_size height
        float row_height
        int root
        cui_table_sort * sort
        int * cursor
        uint8_t guides
        void * user

    ctypedef struct cui_treemap_opts:
        cui_size width
        float height
        const char * format

    ctypedef struct cui_uptime_opts:
        cui_size width
        cui_date last_day

    ctypedef struct cui_uptime_result:
        int service
        int day

    ctypedef struct cui_user_menu_opts:
        const char * detail
        const char * status
        uintptr_t avatar
        uint8_t compact
        int placement
        float width

    ctypedef struct cui_vertex:
        float x
        float y
        float u
        float v
        float lx
        float ly
        float hw
        float hh
        float r_tl
        float r_tr
        float r_br
        float r_bl
        float border
        float mode
        cui_color color
        cui_color border_color

    ctypedef struct cui_viz_item:
        const char * label
        float value
        cui_color color

    ctypedef struct cui_voice_orb_opts:
        float size
        cui_color color

    ctypedef struct cui_waffle_opts:
        float cell
        int columns
        int rows
        const char * format

    ctypedef struct cui_waterfall_opts:
        cui_size width
        float height
        int * selected
        double dom_loaded
        double loaded

    ctypedef struct cui_waterfall_result:
        int clicked
        int activated
        int hovered

    ctypedef struct cui_waveform_opts:
        cui_size width
        float height
        float bar
        float gap
        cui_color color

    ctypedef struct cui_week_opts:
        float start_hour
        float end_hour
        float hour_height
        cui_size height
        uint8_t read_only

    ctypedef struct cui_wheel_opts:
        int rows
        cui_size width
        uint8_t loop
        uint8_t join_left
        uint8_t join_right

    ctypedef struct cui_api_endpoint
    ctypedef struct cui_commit
    ctypedef struct cui_ctx
    ctypedef struct cui_feature_flag
    ctypedef struct cui_filter_field
    ctypedef struct cui_hex_result
    ctypedef struct cui_histogram_series
    ctypedef struct cui_kv_pair
    ctypedef struct cui_log_buffer
    ctypedef struct cui_net_request
    ctypedef struct cui_platform_iface
    ctypedef struct cui_query_field
    ctypedef struct cui_query_node
    ctypedef struct cui_regex_match
    ctypedef struct cui_scatter_series
    ctypedef struct cui_stack_frame
    ctypedef struct cui_strings
    ctypedef struct cui_terminal_buffer
    ctypedef struct cui_theme
    ctypedef struct cui_timeline_track
    ctypedef struct cui_tree_table_events
    ctypedef struct cui_uptime_service

    ctypedef void (*cui_paint_fn)(cui_ctx *, cui_rect, void *)

    cui_ctx * cui_create(const cui_ctx_desc * desc)
    void cui_destroy(cui_ctx * ui)
    void cui_set_renderer(cui_ctx * ui, const cui_renderer_iface * renderer)
    void cui_set_viewport(cui_ctx * ui, float width, float height, float scale)
    cui_vec2 cui_viewport_size(cui_ctx * ui)
    float cui_dpi_scale(cui_ctx * ui)
    void cui_begin_frame(cui_ctx * ui, float dt)
    void cui_end_frame(cui_ctx * ui)
    uint8_t cui_needs_redraw(cui_ctx * ui)
    float cui_next_wakeup(cui_ctx * ui)
    void cui_request_redraw(cui_ctx * ui)
    void cui_request_wakeup(cui_ctx * ui, float seconds)
    double cui_time(cui_ctx * ui)
    float cui_delta_time(cui_ctx * ui)
    uint64_t cui_frame_count(cui_ctx * ui)
    void cui_input_mouse_move(cui_ctx * ui, float x, float y)
    void cui_input_mouse_button(cui_ctx * ui, int button, uint8_t down)
    void cui_input_mouse_leave(cui_ctx * ui)
    void cui_input_scroll(cui_ctx * ui, float dx, float dy)
    void cui_input_key(cui_ctx * ui, int key, uint8_t down, int mods)
    void cui_input_text(cui_ctx * ui, const char * utf8)
    void cui_input_focus(cui_ctx * ui, uint8_t window_focused)
    void cui_input_file_hover(cui_ctx * ui, uint8_t hovering, float x, float y)
    void cui_input_file_drop(cui_ctx * ui, const char *const * paths, int count, float x, float y)
    int cui_dropped_file_count(cui_ctx * ui)
    const char * cui_dropped_file(cui_ctx * ui, int index)
    uint8_t cui_file_drag_active(cui_ctx * ui)
    void cui_set_platform(cui_ctx * ui, const cui_platform_iface * platform)
    int cui_get_cursor(cui_ctx * ui)
    uint8_t cui_key_pressed(cui_ctx * ui, int key)
    uint8_t cui_key_down(cui_ctx * ui, int key)
    uint8_t cui_shortcut(cui_ctx * ui, int mods, int key)
    int cui_key_mods(cui_ctx * ui)
    cui_vec2 cui_mouse_pos(cui_ctx * ui)
    uint8_t cui_mouse_down(cui_ctx * ui, int b)
    uint8_t cui_mouse_clicked(cui_ctx * ui, int b)
    uint8_t cui_wants_keyboard(cui_ctx * ui)
    uint8_t cui_wants_mouse(cui_ctx * ui)
    void cui_set_theme(cui_ctx * ui, int mode)
    int cui_get_theme_mode(cui_ctx * ui)
    void cui_set_accent(cui_ctx * ui, int accent)
    int cui_get_accent(cui_ctx * ui)
    cui_theme * cui_theme_get(cui_ctx * ui)
    void cui_set_reduced_motion(cui_ctx * ui, uint8_t reduced)
    cui_color cui_color_of(cui_ctx * ui, cui_color c)
    void cui_set_strings(cui_ctx * ui, const cui_strings * strings)
    const cui_strings * cui_get_strings(cui_ctx * ui)
    cui_color cui_token_color(cui_ctx * ui, int token)
    const char * cui_accent_name(int accent)
    cui_color cui_oklch(float l, float c, float h_degrees, float alpha)
    cui_color cui_mix(cui_color a, cui_color b, float t)
    cui_color cui_alpha(cui_color c, float alpha_multiplier)
    int cui_font_load_memory(cui_ctx * ui, const void * data, size_t size, uint8_t copy)
    int cui_font_load_file(cui_ctx * ui, const char * path)
    void cui_font_set_role(cui_ctx * ui, int role, int font)
    void cui_font_add_fallback(cui_ctx * ui, int font, int fallback)
    cui_text_metrics cui_measure_text(cui_ctx * ui, int font, float size, const char * text, int len)
    uint32_t cui_box_begin(cui_ctx * ui, const cui_box * opts_)
    void cui_box_end(cui_ctx * ui)
    uint32_t cui_row_begin(cui_ctx * ui, const cui_box * opts_)
    uint32_t cui_column_begin(cui_ctx * ui, const cui_box * opts_)
    void cui_spacer(cui_ctx * ui)
    void cui_gap(cui_ctx * ui, float size)
    void cui_separator(cui_ctx * ui)
    uint8_t cui_card_begin(cui_ctx * ui, const cui_card_opts * opts_)
    void cui_card_end(cui_ctx * ui)
    void cui_scroll_begin(cui_ctx * ui, const cui_scroll_opts * opts_)
    void cui_scroll_end(cui_ctx * ui)
    void cui_scroll_to(cui_ctx * ui, const char * scroll_id, float y)
    void cui_split_begin(cui_ctx * ui, const char * id, float * ratio, const cui_split_opts * opts_)
    void cui_split_next(cui_ctx * ui)
    void cui_split_end(cui_ctx * ui)
    uint32_t cui_make_id(cui_ctx * ui, const char * str)
    void cui_push_id(cui_ctx * ui, const char * str)
    void cui_push_id_int(cui_ctx * ui, int value)
    void cui_pop_id(cui_ctx * ui)
    uint32_t cui_last_id(cui_ctx * ui)
    cui_rect cui_last_rect(cui_ctx * ui)
    cui_rect cui_get_rect(cui_ctx * ui, uint32_t id)
    uint8_t cui_last_hovered(cui_ctx * ui)
    uint8_t cui_is_disabled(cui_ctx * ui)
    void cui_push_disabled(cui_ctx * ui, uint8_t disabled)
    void cui_pop_disabled(cui_ctx * ui)
    void cui_text_ex(cui_ctx * ui, const char * text, const cui_text_opts * opts_)
    void cui_heading(cui_ctx * ui, const char * text, int level)
    void cui_label(cui_ctx * ui, const char * text)
    void cui_secondary(cui_ctx * ui, const char * text)
    void cui_muted(cui_ctx * ui, const char * text)
    void cui_code(cui_ctx * ui, const char * text)
    void cui_kbd(cui_ctx * ui, const char * keys)
    uint8_t cui_link(cui_ctx * ui, const char * text)
    void cui_icon(cui_ctx * ui, const char * icon, float size, cui_color color)
    uint8_t cui_button_ex(cui_ctx * ui, const char * label, const cui_button_opts * opts_)
    uint8_t cui_icon_button_ex(cui_ctx * ui, const char * icon, const cui_button_opts * opts_)
    uint8_t cui_segmented_ex(cui_ctx * ui, const char * id, const char *const * items, int count, int * index, const cui_segmented_opts * opts_)
    uint8_t cui_checkbox_ex(cui_ctx * ui, const char * label, uint8_t * value, const cui_check_opts * opts_)
    uint8_t cui_switch_ex(cui_ctx * ui, const char * label, uint8_t * value, const cui_check_opts * opts_)
    uint8_t cui_radio_ex(cui_ctx * ui, const char * label, int * value, int option, const cui_check_opts * opts_)
    uint8_t cui_radio_group(cui_ctx * ui, const char * id, const char *const * items, int count, int * index)
    uint8_t cui_slider_ex(cui_ctx * ui, const char * label, float * value, float min, float max, const cui_slider_opts * opts_)
    uint8_t cui_range_slider(cui_ctx * ui, const char * label, float * lo, float * hi, float min, float max)
    uint8_t cui_rating(cui_ctx * ui, const char * id, int * value, int max)
    uint8_t cui_chip_ex(cui_ctx * ui, const char * label, uint8_t * selected, const cui_chip_opts * opts_)
    int cui_input_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_input_opts * opts_)
    int cui_textarea_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_input_opts * opts_)
    int cui_search_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_input_opts * opts_)
    uint8_t cui_number_ex(cui_ctx * ui, const char * id, double * value, double min, double max, const cui_number_opts * opts_)
    uint8_t cui_select_ex(cui_ctx * ui, const char * id, const char *const * items, int count, int * index, const cui_select_opts * opts_)
    cui_date cui_date_today()
    uint8_t cui_calendar(cui_ctx * ui, const char * id, cui_date * value)
    uint8_t cui_date_picker_ex(cui_ctx * ui, const char * id, cui_date * value, const cui_date_opts * opts_)
    uint8_t cui_color_picker(cui_ctx * ui, const char * id, cui_color * value)
    uint8_t cui_tabs_ex(cui_ctx * ui, const char * id, const char *const * items, int count, int * index, const cui_tabs_opts * opts_)
    uint8_t cui_nav_item_ex(cui_ctx * ui, const char * label, const cui_nav_opts * opts_)
    void cui_nav_section(cui_ctx * ui, const char * title)
    int cui_breadcrumb(cui_ctx * ui, const char *const * items, int count)
    uint8_t cui_pagination(cui_ctx * ui, const char * id, int * page, int page_count)
    void cui_stepper(cui_ctx * ui, const char *const * steps, int count, int current)
    uint8_t cui_popover_begin(cui_ctx * ui, const char * id, const cui_popover_opts * opts_)
    void cui_popover_end(cui_ctx * ui)
    int cui_tour_ex(cui_ctx * ui, const char * id, const cui_tour_step * steps, int count, int * step, const cui_tour_opts * opts_)
    void cui_popover_open(cui_ctx * ui, const char * id)
    void cui_popover_close(cui_ctx * ui, const char * id)
    void cui_popover_toggle(cui_ctx * ui, const char * id)
    uint8_t cui_popover_is_open(cui_ctx * ui, const char * id)
    uint8_t cui_menu_begin(cui_ctx * ui, const char * label, const cui_menu_opts * opts_)
    void cui_menu_end(cui_ctx * ui)
    uint8_t cui_context_menu_begin(cui_ctx * ui, const char * id)
    void cui_context_menu_end(cui_ctx * ui)
    uint8_t cui_menu_item_ex(cui_ctx * ui, const char * label, const cui_menu_item_opts * opts_)
    void cui_menu_separator(cui_ctx * ui)
    void cui_menu_label(cui_ctx * ui, const char * text)
    void cui_tooltip(cui_ctx * ui, const char * text)
    uint8_t cui_dialog_begin(cui_ctx * ui, const char * title, uint8_t * open, const cui_dialog_opts * opts_)
    void cui_dialog_end(cui_ctx * ui)
    void cui_dialog_footer_begin(cui_ctx * ui)
    void cui_dialog_footer_end(cui_ctx * ui)
    uint8_t cui_sheet_begin(cui_ctx * ui, const char * title, uint8_t * open, const cui_sheet_opts * opts_)
    void cui_sheet_end(cui_ctx * ui)
    int cui_toast_ex(cui_ctx * ui, const char * title, const cui_toast_opts * opts_)
    uint8_t cui_toast_action_clicked(cui_ctx * ui, int handle)
    void cui_toast_dismiss(cui_ctx * ui, int handle)
    uint8_t cui_alert_ex(cui_ctx * ui, const char * title, const cui_alert_opts * opts_)
    void cui_progress_ex(cui_ctx * ui, float value, const cui_progress_opts * opts_)
    void cui_spinner(cui_ctx * ui, float size)
    void cui_skeleton(cui_ctx * ui, cui_size width, float height)
    void cui_badge_ex(cui_ctx * ui, const char * text, const cui_badge_opts * opts_)
    void cui_avatar_ex(cui_ctx * ui, const char * name, const cui_avatar_opts * opts_)
    void cui_avatar_group(cui_ctx * ui, const char *const * names, int count, int max_visible, float size)
    uint8_t cui_empty_state_ex(cui_ctx * ui, const char * title, const cui_empty_opts * opts_)
    void cui_metric_ex(cui_ctx * ui, const char * label, const char * value, const cui_metric_opts * opts_)
    void cui_meter(cui_ctx * ui, const char * label, float used, float total, const char * unit)
    uint8_t cui_accordion_begin(cui_ctx * ui, const char * title, uint8_t * open)
    void cui_accordion_end(cui_ctx * ui)
    uint8_t cui_tree_begin(cui_ctx * ui, const char * label, uint8_t * open, const cui_tree_opts * opts_)
    void cui_tree_end(cui_ctx * ui)
    uint8_t cui_tree_clicked(cui_ctx * ui)
    uint8_t cui_list_item_ex(cui_ctx * ui, const char * title, const cui_list_item_opts * opts_)
    void cui_virtual_list_begin(cui_ctx * ui, const char * id, int count, float row_height, cui_size height, int * first, int * last)
    void cui_virtual_list_end(cui_ctx * ui)
    uint8_t cui_table_begin_ex(cui_ctx * ui, const char * id, const cui_table_column * columns, int column_count, const cui_table_opts * opts_)
    uint8_t cui_table_row(cui_ctx * ui, uint8_t selected)
    void cui_table_cell(cui_ctx * ui)
    void cui_table_cell_text(cui_ctx * ui, const char * text)
    void cui_table_end(cui_ctx * ui)
    void cui_line_chart_ex(cui_ctx * ui, const char * id, const cui_series * series, int count, const cui_chart_opts * opts_)
    void cui_bar_chart_ex(cui_ctx * ui, const char * id, const cui_series * series, int count, const cui_chart_opts * opts_)
    void cui_donut_chart_ex(cui_ctx * ui, const char * id, const float * values, const char *const * labels, int count, const cui_chart_opts * opts_)
    void cui_sparkline(cui_ctx * ui, const float * values, int count, cui_size width, float height, cui_color color)
    void cui_gauge(cui_ctx * ui, const char * label, float value, float size)
    uintptr_t cui_image_create(cui_ctx * ui, int w, int h, const void * rgba)
    uintptr_t cui_image_load(cui_ctx * ui, const char * path, int * w, int * h)
    void cui_image_destroy(cui_ctx * ui, uintptr_t tex)
    void cui_image_ex(cui_ctx * ui, uintptr_t tex, const cui_image_opts * opts_)
    uint8_t cui_image_viewer_ex(cui_ctx * ui, const char * id, uintptr_t tex, int image_w, int image_h, cui_image_view * view, const cui_image_viewer_opts * opts_)
    uint8_t cui_cropper_ex(cui_ctx * ui, const char * id, uintptr_t tex, int image_w, int image_h, cui_rect * crop, const cui_cropper_opts * opts_)
    int cui_command_palette(cui_ctx * ui, uint8_t * open, const cui_command * commands, int count)
    uint8_t cui_radio_cards_ex(cui_ctx * ui, const char * id, const cui_choice * choices, int count, int * index, const cui_radio_cards_opts * opts_)
    uint8_t cui_tag_input_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_tag_opts * opts_)
    uint8_t cui_otp_input(cui_ctx * ui, const char * id, char * code, int length)
    void cui_button_group_begin(cui_ctx * ui)
    void cui_button_group_end(cui_ctx * ui)
    uint8_t cui_copy_button(cui_ctx * ui, const char * id, const char * text)
    uint8_t cui_hold_button_ex(cui_ctx * ui, const char * label, const cui_hold_opts * opts_)
    int cui_password_strength(cui_ctx * ui, const char * password)
    void cui_timeline_item_ex(cui_ctx * ui, const char * title, const cui_timeline_opts * opts_)
    void cui_reorder_begin(cui_ctx * ui, const char * id, int * order, int count)
    uint8_t cui_reorder_end(cui_ctx * ui)
    void cui_reorder_item_begin(cui_ctx * ui, int position)
    void cui_reorder_item_end(cui_ctx * ui)
    void cui_progress_ring(cui_ctx * ui, const char * label, float value, float size)
    int cui_split_button_ex(cui_ctx * ui, const char * label, const char *const * items, int count, const cui_split_button_opts * opts_)
    uint8_t cui_toggle_group_ex(cui_ctx * ui, const char * id, const char *const * labels, int count, uint8_t * values, const cui_toggle_group_opts * opts_)
    uint8_t cui_confirm_button_ex(cui_ctx * ui, const char * label, const cui_confirm_opts * opts_)
    uint8_t cui_status_button_ex(cui_ctx * ui, const char * label, int status, const cui_status_button_opts * opts_)
    int cui_reactions(cui_ctx * ui, const char * id, cui_reaction * items, int count)
    int cui_speed_dial_ex(cui_ctx * ui, const char * id, const cui_speed_action * actions, int count, const cui_speed_dial_opts * opts_)
    uint8_t cui_theme_switcher(cui_ctx * ui, int * mode, uint8_t with_system)
    uint8_t cui_theme_toggle(cui_ctx * ui)
    uint8_t cui_user_menu_begin(cui_ctx * ui, const char * name, const cui_user_menu_opts * opts_)
    void cui_user_menu_end(cui_ctx * ui)
    void cui_swipe_item_begin(cui_ctx * ui, const char * id, const cui_swipe_action * left, int left_count, const cui_swipe_action * right, int right_count)
    int cui_swipe_item_end(cui_ctx * ui)
    uint8_t cui_data_grid_begin_ex(cui_ctx * ui, const char * id, const cui_grid_column * columns, int column_count, int row_count, int * first, int * last, const cui_grid_opts * opts_)
    uint8_t cui_data_grid_row(cui_ctx * ui, int row)
    void cui_data_grid_cell(cui_ctx * ui)
    void cui_data_grid_cell_text(cui_ctx * ui, const char * text)
    uint8_t cui_data_grid_cell_edit(cui_ctx * ui, char * buf, size_t cap)
    uint8_t cui_data_grid_edit(cui_ctx * ui, char * buf, size_t cap)
    void cui_data_grid_end(cui_ctx * ui)
    uint8_t cui_tree_cell(cui_ctx * ui, const char * label, int depth, uint8_t has_children, uint8_t * open, const char * icon)
    uint8_t cui_filter_bar(cui_ctx * ui, const char * id, const cui_filter_field * fields, int count, uint32_t * selected, char * search, size_t search_cap)
    void cui_tree_table_begin_ex(cui_ctx * ui, const char * id, const cui_grid_column * columns, int column_count, cui_tree_node * nodes, int node_count, const cui_tree_table_opts * opts_)
    int cui_tree_table_row(cui_ctx * ui)
    void cui_tree_table_name(cui_ctx * ui, const char * label, const char * icon)
    int cui_tree_table_depth(cui_ctx * ui)
    cui_tree_table_events cui_tree_table_end(cui_ctx * ui)
    cui_path_bar_result cui_path_bar_ex(cui_ctx * ui, const char * id, const char *const * segments, int count, const cui_path_bar_opts * opts_)
    uint8_t cui_path_bar_menu_begin(cui_ctx * ui, const char * id, int * segment)
    void cui_path_bar_menu_end(cui_ctx * ui)
    int cui_fs_list(void * user, const char * path, cui_file_entry * out, int cap, char * names, size_t names_cap, uint8_t hidden)
    cui_file_browser_result cui_file_browser_ex(cui_ctx * ui, const char * id, char * path, size_t path_cap, const cui_file_browser_opts * opts_)
    uint8_t cui_file_picker_ex(cui_ctx * ui, const char * id, uint8_t * open, char * out, size_t out_cap, const cui_file_picker_opts * opts_)
    void cui_code_block_ex(cui_ctx * ui, const char * id, const char * code, const cui_code_opts * opts_)
    uint8_t cui_json_view_ex(cui_ctx * ui, const char * id, const char * json, const cui_json_opts * opts_)
    cui_markdown_result cui_markdown_ex(cui_ctx * ui, const char * id, const char * text, const cui_markdown_opts * opts_)
    uint8_t cui_markdown_apply_task(char * text, const cui_markdown_result * result)
    cui_code_editor_result cui_code_editor_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_code_editor_opts * opts_)
    void cui_code_editor_goto(cui_ctx * ui, const char * id, int line, int column)
    void cui_code_editor_select(cui_ctx * ui, const char * id, int anchor, int cursor)
    void cui_code_editor_find(cui_ctx * ui, const char * id, const char * query)
    cui_diff_result cui_diff_view_ex(cui_ctx * ui, const char * id, const char * old_text, const char * new_text, const cui_diff_opts * opts_)
    int cui_diff_view_rows(cui_ctx * ui, const char * id, cui_diff_row * rows, int first, int cap)
    int cui_diff_compute(const char * old_text, size_t old_len, const char * new_text, size_t new_len, unsigned int flags, cui_diff_hunk * hunks, int cap, cui_diff_stats * stats)
    uint8_t cui_diff_words(const char * old_line, int old_len, const char * new_line, int new_len, cui_diff_range * old_ranges, int * old_count, cui_diff_range * new_ranges, int * new_count, int cap)
    void cui_chat_message_ex(cui_ctx * ui, const char * text, const cui_chat_opts * opts_)
    void cui_chat_divider(cui_ctx * ui, const char * label)
    void cui_typing_indicator(cui_ctx * ui, const char * name)
    int cui_comment_ex(cui_ctx * ui, const char * id, const char * author, const char * text, const cui_comment_opts * opts_)
    void cui_presence(cui_ctx * ui, const char * id, const cui_presence_user * users, int count, int max_visible, float size)
    uint8_t cui_carousel_begin(cui_ctx * ui, const char * id, int count, int * index, const cui_carousel_opts * opts_)
    void cui_carousel_slide_begin(cui_ctx * ui)
    void cui_carousel_slide_end(cui_ctx * ui)
    void cui_carousel_end(cui_ctx * ui)
    uint8_t cui_image_compare_ex(cui_ctx * ui, const char * id, uintptr_t before, uintptr_t after, float * pos, const cui_compare_opts * opts_)
    void cui_card_stack_begin(cui_ctx * ui, const char * id, int count, const cui_card_stack_opts * opts_)
    void cui_card_stack_item_begin(cui_ctx * ui, int depth)
    void cui_card_stack_item_end(cui_ctx * ui)
    int cui_card_stack_end(cui_ctx * ui)
    void cui_counter_ex(cui_ctx * ui, const char * id, double value, const cui_counter_opts * opts_)
    void cui_ticker_ex(cui_ctx * ui, const char * id, const cui_ticker_item * items, int count, const cui_ticker_opts * opts_)
    int cui_heatmap_ex(cui_ctx * ui, const char * id, const float * values, int rows, int cols, const cui_heatmap_opts * opts_)
    int cui_calendar_heatmap_ex(cui_ctx * ui, const char * id, cui_date start, const float * values, int days, const cui_calendar_heatmap_opts * opts_)
    int cui_treemap_ex(cui_ctx * ui, const char * id, const cui_viz_item * items, int count, const cui_treemap_opts * opts_)
    int cui_radar_chart_ex(cui_ctx * ui, const char * id, const cui_series * series, int count, const char *const * axes, int axis_count, const cui_radar_opts * opts_)
    int cui_funnel_ex(cui_ctx * ui, const char * id, const cui_viz_item * stages, int count, const cui_funnel_opts * opts_)
    int cui_sankey_ex(cui_ctx * ui, const char * id, const char *const * nodes, int node_count, const cui_sankey_link * links, int link_count, const cui_sankey_opts * opts_)
    int cui_waffle_ex(cui_ctx * ui, const char * id, const cui_viz_item * items, int count, const cui_waffle_opts * opts_)
    int cui_split_bar_ex(cui_ctx * ui, const char * id, const cui_viz_item * items, int count, const cui_split_bar_opts * opts_)
    int cui_bar_list_ex(cui_ctx * ui, const char * id, const cui_viz_item * items, int count, const cui_bar_list_opts * opts_)
    int cui_activity_rings_ex(cui_ctx * ui, const char * id, const cui_viz_item * rings, int count, const cui_rings_opts * opts_)
    int cui_scatter_chart_ex(cui_ctx * ui, const char * id, const cui_scatter_series * series, int count, const cui_scatter_opts * opts_)
    void cui_radial_gauge_ex(cui_ctx * ui, const char * id, float value, float min, float max, const cui_radial_gauge_opts * opts_)
    int cui_candlestick_ex(cui_ctx * ui, const char * id, const cui_candle * candles, int count, const cui_candlestick_opts * opts_)
    void cui_shimmer_text_ex(cui_ctx * ui, const char * text, const cui_text_fx_opts * opts_)
    uint8_t cui_typewriter_ex(cui_ctx * ui, const char * id, const char * text, const cui_text_fx_opts * opts_)
    void cui_text_reveal_ex(cui_ctx * ui, const char * id, const char * text, const cui_text_fx_opts * opts_)
    void cui_word_rotate_ex(cui_ctx * ui, const char * id, const char *const * words, int count, float interval, const cui_text_fx_opts * opts_)
    void cui_number_roll_ex(cui_ctx * ui, const char * id, const char * text, const cui_text_fx_opts * opts_)
    void cui_gradient_text_ex(cui_ctx * ui, const char * text, const cui_gradient_text_opts * opts_)
    void cui_spotlight_begin(cui_ctx * ui, const char * id, const cui_spotlight_opts * opts_)
    void cui_spotlight_end(cui_ctx * ui)
    void cui_loader_ex(cui_ctx * ui, const cui_loader_opts * opts_)
    void cui_dock_begin(cui_ctx * ui, const char * id, const cui_dock_opts * opts_)
    uint8_t cui_dock_item_ex(cui_ctx * ui, const char * icon, const char * label, const cui_dock_item_opts * opts_)
    void cui_dock_separator(cui_ctx * ui)
    void cui_dock_end(cui_ctx * ui)
    uint8_t cui_tab_bar_ex(cui_ctx * ui, const char * id, const cui_tab_bar_item * items, int count, int * selected, const cui_tab_bar_opts * opts_)
    uint8_t cui_control_tile_ex(cui_ctx * ui, const char * label, uint8_t * on, const cui_tile_opts * opts_)
    uint8_t cui_waveform_ex(cui_ctx * ui, const char * id, const float * peaks, int count, float * progress, const cui_waveform_opts * opts_)
    int cui_now_playing_ex(cui_ctx * ui, const char * id, cui_now_playing * np, const cui_now_playing_opts * opts_)
    uint8_t cui_reasoning_begin(cui_ctx * ui, const char * id, const cui_reasoning_opts * opts_)
    void cui_reasoning_end(cui_ctx * ui)
    void cui_tool_call_ex(cui_ctx * ui, const char * id, const char * name, const cui_tool_call_opts * opts_)
    int cui_agent_plan_ex(cui_ctx * ui, const char * id, const cui_plan_step * steps, int count, const cui_agent_plan_opts * opts_)
    void cui_agent_status_ex(cui_ctx * ui, const char * text, const cui_agent_status_opts * opts_)
    int cui_source_list(cui_ctx * ui, const char * id, const cui_source * sources, int count)
    uint8_t cui_citation(cui_ctx * ui, int number, const cui_source * source)
    void cui_context_meter_ex(cui_ctx * ui, const char * id, float used, float limit, const cui_context_opts * opts_)
    int cui_response_actions_ex(cui_ctx * ui, const char * id, const cui_response_actions_opts * opts_)
    int cui_prompt_suggestions_ex(cui_ctx * ui, const char * id, const cui_prompt_suggestion * items, int count, const cui_prompt_suggestions_opts * opts_)
    uint8_t cui_model_picker_ex(cui_ctx * ui, const char * id, const cui_model * models, int count, int * selected, const cui_model_picker_opts * opts_)
    int cui_chat_composer_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_composer_opts * opts_)
    uint8_t cui_voice_orb_ex(cui_ctx * ui, const char * id, int state, float level, const cui_voice_orb_opts * opts_)
    void cui_kanban_begin(cui_ctx * ui, const char * id)
    uint8_t cui_kanban_column_begin_ex(cui_ctx * ui, const char * title, int card_count, const cui_kanban_column_opts * opts_)
    uint8_t cui_kanban_card_begin(cui_ctx * ui, int card_id)
    void cui_kanban_card_end(cui_ctx * ui)
    void cui_kanban_column_end(cui_ctx * ui)
    uint8_t cui_kanban_end(cui_ctx * ui, cui_kanban_move * move)
    int cui_week_calendar_ex(cui_ctx * ui, const char * id, cui_date week_start, cui_cal_event * events, int count, const cui_week_opts * opts_)
    cui_month_result cui_month_calendar_ex(cui_ctx * ui, const char * id, cui_date * month, const cui_month_event * events, int count, const cui_month_opts * opts_)
    int cui_gantt_ex(cui_ctx * ui, const char * id, cui_gantt_task * tasks, int count, cui_date origin, int days, const cui_gantt_opts * opts_)
    uint8_t cui_hover_card_begin(cui_ctx * ui, const char * id, const cui_hover_card_opts * opts_)
    void cui_hover_card_end(cui_ctx * ui)
    uint8_t cui_confirm_popover_ex(cui_ctx * ui, const char * id, const cui_confirm_popover_opts * opts_)
    uint8_t cui_expandable_text_ex(cui_ctx * ui, const char * id, const char * text, const cui_expandable_text_opts * opts_)
    uint8_t cui_expandable_card_begin(cui_ctx * ui, const char * title, uint8_t * open, const cui_expandable_card_opts * opts_)
    void cui_expandable_card_end(cui_ctx * ui)
    int cui_toc(cui_ctx * ui, const char * scroll_id, const cui_toc_item * items, int count)
    void cui_toc_anchor(cui_ctx * ui, const char * anchor)
    uint8_t cui_banner_ex(cui_ctx * ui, const char * text, uint8_t * open, const cui_banner_opts * opts_)
    void cui_countdown_ex(cui_ctx * ui, const char * id, double seconds_left, const cui_countdown_opts * opts_)
    int cui_checklist_ex(cui_ctx * ui, const char * id, cui_check_step * steps, int count, const cui_checklist_opts * opts_)
    uint8_t cui_multi_select_ex(cui_ctx * ui, const char * id, const char *const * items, int count, uint8_t * selected, const cui_multi_select_opts * opts_)
    uint8_t cui_range_calendar(cui_ctx * ui, const char * id, cui_date_range * range, int months)
    uint8_t cui_date_range_picker_ex(cui_ctx * ui, const char * id, cui_date_range * range, const cui_date_range_opts * opts_)
    int cui_date_to_days(cui_date d)
    cui_date cui_date_from_days(int days)
    uint8_t cui_time_picker_ex(cui_ctx * ui, const char * id, int * hour, int * minute, const cui_time_opts * opts_)
    uint8_t cui_wheel_picker_ex(cui_ctx * ui, const char * id, const char *const * items, int count, int * index, const cui_wheel_opts * opts_)
    uint8_t cui_time_dial(cui_ctx * ui, const char * id, int * hour, int * minute, float size)
    uint8_t cui_ruler_slider_ex(cui_ctx * ui, const char * label, float * value, float min, float max, const cui_ruler_opts * opts_)
    uint8_t cui_histogram_slider_ex(cui_ctx * ui, const char * label, const float * bins, int bin_count, float * lo, float * hi, float min, float max, const cui_histogram_opts * opts_)
    uint8_t cui_knob_ex(cui_ctx * ui, const char * id, float * value, float min, float max, const cui_knob_opts * opts_)
    uint8_t cui_fader_ex(cui_ctx * ui, const char * id, float * value, float min, float max, const cui_fader_opts * opts_)
    uint8_t cui_level_meter_ex(cui_ctx * ui, const char * id, const float * levels, int channels, const cui_level_meter_opts * opts_)
    uint8_t cui_signature_pad_ex(cui_ctx * ui, const char * id, const cui_signature_opts * opts_)
    int cui_signature_points(cui_ctx * ui, const char * id, const cui_vec2 ** points, const int ** stroke_ends, int * stroke_count)
    void cui_signature_clear(cui_ctx * ui, const char * id)
    int cui_dropzone_ex(cui_ctx * ui, const char * id, const cui_dropzone_opts * opts_)
    uint8_t cui_path_has_extension(const char * path, const char * accept)
    int cui_avatar_upload(cui_ctx * ui, const char * id, const char * name, uintptr_t * image, float size)
    int cui_inline_edit_ex(cui_ctx * ui, const char * id, char * buf, size_t cap, const cui_inline_edit_opts * opts_)
    uint8_t cui_scrub_ex(cui_ctx * ui, const char * label, float * value, float min, float max, const cui_scrub_opts * opts_)
    uint8_t cui_money_input_ex(cui_ctx * ui, const char * id, double * value, const cui_money_opts * opts_)
    uint8_t cui_shortcut_recorder_ex(cui_ctx * ui, const char * id, cui_key_combo * combo, const cui_shortcut_recorder_opts * opts_)
    const char * cui_shortcut_label(cui_ctx * ui, cui_key_combo combo)
    const char * cui_key_name(int key)
    uint8_t cui_node_editor_begin_ex(cui_ctx * ui, const char * id, cui_node_view * view, const cui_node_editor_opts * opts_)
    void cui_node_editor_end(cui_ctx * ui)
    uint8_t cui_node_begin_ex(cui_ctx * ui, int node_id, float * x, float * y, const char * title, const cui_node_opts * opts_)
    void cui_node_end(cui_ctx * ui)
    uint8_t cui_node_input_ex(cui_ctx * ui, int pin_id, const char * label, const cui_pin_opts * opts_)
    uint8_t cui_node_output_ex(cui_ctx * ui, int pin_id, const char * label, const cui_pin_opts * opts_)
    void cui_node_content_begin(cui_ctx * ui)
    void cui_node_content_end(cui_ctx * ui)
    uint8_t cui_node_link(cui_ctx * ui, int link_id, int from_pin, int to_pin)
    uint8_t cui_node_link_created(cui_ctx * ui, int * from_pin, int * to_pin)
    uint8_t cui_node_link_removed(cui_ctx * ui, int * link_id)
    uint8_t cui_node_deleted(cui_ctx * ui, int * node_id)
    void cui_menu_bar_begin(cui_ctx * ui, const char * id, const cui_menu_bar_opts * opts_)
    void cui_menu_bar_end(cui_ctx * ui)
    uint8_t cui_menu_bar_menu_begin(cui_ctx * ui, const char * label, const cui_menu_bar_menu_opts * opts_)
    void cui_menu_bar_menu_end(cui_ctx * ui)
    void cui_toolbar_begin(cui_ctx * ui, const char * id, const cui_toolbar_opts * opts_)
    void cui_toolbar_end(cui_ctx * ui)
    uint8_t cui_toolbar_button_ex(cui_ctx * ui, const char * icon, const cui_tool_opts * opts_)
    void cui_toolbar_separator(cui_ctx * ui)
    void cui_toolbar_spacer(cui_ctx * ui)
    void cui_status_bar_begin(cui_ctx * ui, const char * id, const cui_status_bar_opts * opts_)
    void cui_status_bar_end(cui_ctx * ui)
    void cui_status_bar_spacer(cui_ctx * ui)
    void cui_status_bar_text_ex(cui_ctx * ui, const char * text, const cui_status_item_opts * opts_)
    uint8_t cui_status_bar_item_ex(cui_ctx * ui, const char * label, const cui_status_item_opts * opts_)
    void cui_status_bar_progress_ex(cui_ctx * ui, float value, const cui_status_progress_opts * opts_)
    cui_doc_tabs_result cui_doc_tabs_ex(cui_ctx * ui, const char * id, const cui_doc_tab * tabs, int count, int * selected, const cui_doc_tabs_opts * opts_)
    void cui_dockspace_begin_ex(cui_ctx * ui, const char * id, const cui_dockspace_opts * opts_)
    void cui_dockspace_end(cui_ctx * ui)
    uint8_t cui_dock_panel_begin_ex(cui_ctx * ui, const char * title, uint8_t * open, const cui_dock_panel_opts * opts_)
    void cui_dock_panel_end(cui_ctx * ui)
    size_t cui_dock_save(cui_ctx * ui, const char * id, char * buf, size_t cap)
    uint8_t cui_dock_load(cui_ctx * ui, const char * id, const char * text)
    uint8_t cui_inspector_begin_ex(cui_ctx * ui, const char * id, const cui_inspector_opts * opts_)
    void cui_inspector_end(cui_ctx * ui)
    uint8_t cui_inspector_group(cui_ctx * ui, const char * title, uint8_t * open)
    uint8_t cui_prop_float_ex(cui_ctx * ui, const char * label, float * value, const cui_prop_opts * opts_)
    uint8_t cui_prop_int_ex(cui_ctx * ui, const char * label, int * value, const cui_prop_opts * opts_)
    uint8_t cui_prop_text_ex(cui_ctx * ui, const char * label, char * buf, size_t cap, const cui_prop_opts * opts_)
    uint8_t cui_prop_bool_ex(cui_ctx * ui, const char * label, uint8_t * value, const cui_prop_opts * opts_)
    uint8_t cui_prop_enum_ex(cui_ctx * ui, const char * label, const char *const * items, int count, int * index, const cui_prop_opts * opts_)
    uint8_t cui_prop_color_ex(cui_ctx * ui, const char * label, cui_color * value, const cui_prop_opts * opts_)
    uint8_t cui_prop_vec_ex(cui_ctx * ui, const char * label, float * value, int components, const cui_prop_opts * opts_)
    void cui_log_init(cui_log_buffer * buf, cui_log_line * lines, int line_cap, char * text, size_t text_cap)
    void cui_log_append_text(cui_log_buffer * buf, int level, double time, const char * text, int len)
    void cui_log_clear(cui_log_buffer * buf)
    const cui_log_line * cui_log_get(const cui_log_buffer * buf, int i, const char *const * text)
    void cui_log_view_ex(cui_ctx * ui, const char * id, cui_log_buffer * buf, const cui_log_view_opts * opts_)
    void cui_terminal_init(cui_terminal_buffer * t, char * text, size_t text_cap, cui_terminal_line * lines, int line_cap)
    void cui_terminal_write(cui_terminal_buffer * t, const char * data, int len)
    void cui_terminal_clear(cui_terminal_buffer * t)
    cui_terminal_result cui_terminal_ex(cui_ctx * ui, const char * id, cui_terminal_buffer * t, const cui_terminal_opts * opts_)
    uint8_t cui_emoji_font_load_file(cui_ctx * ui, const char * path)
    uint8_t cui_emoji_font_load_memory(cui_ctx * ui, const void * data, size_t size, uint8_t copy)
    uint8_t cui_emoji_font_load_system(cui_ctx * ui)
    uint8_t cui_emoji_supported(cui_ctx * ui, const char * utf8, int len)
    void cui_draw_emoji(cui_ctx * ui, const char * utf8, int len, cui_rect r)
    void cui_emoji(cui_ctx * ui, const char * utf8, float size)
    const char * cui_emoji_picker_ex(cui_ctx * ui, const char * id, const cui_emoji_picker_opts * opts_)
    cui_hex_result cui_hex_view_ex(cui_ctx * ui, const char * id, const uint8_t * data, size_t size, cui_hex_selection * sel, const cui_hex_view_opts * opts_)
    void cui_hex_view_goto(cui_ctx * ui, const char * id, size_t offset)
    cui_flame_result cui_flame_graph_ex(cui_ctx * ui, const char * id, const cui_flame_span * spans, int count, cui_flame_view * view, int * selected, const cui_flame_opts * opts_)
    void cui_flame_sort(cui_flame_span * spans, int count)
    cui_rect cui_flame_span_rect(cui_ctx * ui, uint32_t flame, const cui_flame_span * span)
    cui_curve_result cui_curve_editor_ex(cui_ctx * ui, const char * id, cui_curve_key * keys, int * count, int capacity, const cui_curve_opts * opts_)
    float cui_curve_eval(const cui_curve_key * keys, int count, float x)
    cui_gradient_result cui_gradient_editor_ex(cui_ctx * ui, const char * id, cui_gradient_stop * stops, int * count, int capacity, const cui_gradient_opts * opts_)
    cui_color cui_gradient_eval(const cui_gradient_stop * stops, int count, float t)
    cui_timeline_editor_result cui_timeline_editor_ex(cui_ctx * ui, const char * id, cui_timeline_track * tracks, int count, float * time, const cui_timeline_editor_opts * opts_)
    uint8_t cui_kv_editor_ex(cui_ctx * ui, const char * id, cui_kv_pair * pairs, int * count, int capacity, const cui_kv_editor_opts * opts_)
    cui_problems_result cui_problems_ex(cui_ctx * ui, const char * id, const cui_diagnostic * diags, int count, const cui_problems_opts * opts_)
    cui_pipeline_result cui_pipeline_ex(cui_ctx * ui, const char * id, const char *const * stages, int stage_count, const cui_pipeline_job * jobs, int job_count, const cui_pipeline_opts * opts_)
    uint8_t cui_query_builder_ex(cui_ctx * ui, const char * id, const cui_query_field * fields, int field_count, cui_query_node * nodes, int * count, int capacity, const cui_query_opts * opts_)
    const char * cui_query_op_name(int type, int op)
    size_t cui_query_text(const cui_query_field * fields, int field_count, const cui_query_node * nodes, int count, char * out, size_t cap)
    uint8_t cui_query_match(const cui_query_field * fields, int field_count, const cui_query_node * nodes, int count, const char *const * values)
    cui_schedule_result cui_schedule_picker_ex(cui_ctx * ui, const char * id, char * cron, size_t cap, const cui_schedule_opts * opts_)
    uint8_t cui_cron_next(const char * cron, int64_t after, int utc_offset, int64_t * next)
    const char * cui_cron_describe(cui_ctx * ui, const char * cron)
    cui_keymap_result cui_keymap_ex(cui_ctx * ui, const char * id, const cui_keymap_binding * bindings, int count, const cui_keymap_opts * opts_)
    cui_commit_graph_result cui_commit_graph_ex(cui_ctx * ui, const char * id, const cui_commit * commits, int count, const cui_commit_graph_opts * opts_)
    cui_graph_result cui_graph_view_ex(cui_ctx * ui, const char * id, const cui_graph_node * nodes, int node_count, const cui_graph_edge * edges, int edge_count, const cui_graph_opts * opts_)
    cui_waterfall_result cui_waterfall_ex(cui_ctx * ui, const char * id, const cui_net_request * requests, int count, const cui_waterfall_opts * opts_)
    cui_trace_result cui_trace_view_ex(cui_ctx * ui, const char * id, cui_trace_track * tracks, int track_count, const cui_trace_span * spans, int span_count, cui_trace_view * view, int * selected, const cui_trace_opts * opts_)
    void cui_trace_sort(cui_trace_span * spans, int count)
    int cui_regex_search(const char * pattern, int flags, const char * text, int len, int from_, cui_regex_match * m, const char *const * error)
    cui_regex_tester_result cui_regex_tester_ex(cui_ctx * ui, const char * id, char * pattern, size_t pattern_cap, char * text, size_t text_cap, const cui_regex_tester_opts * opts_)
    cui_test_explorer_result cui_test_explorer_ex(cui_ctx * ui, const char * id, const cui_test_item * items, int count, const cui_test_explorer_opts * opts_)
    cui_stack_trace_result cui_stack_trace_ex(cui_ctx * ui, const char * id, const cui_stack_frame * frames, int count, const cui_stack_trace_opts * opts_)
    cui_request_bar_result cui_request_bar_ex(cui_ctx * ui, const char * id, int * method, char * url, size_t cap, const cui_request_bar_opts * opts_)
    void cui_response_status(cui_ctx * ui, int status, double seconds, double bytes)
    const char * cui_http_reason(int status)
    const char * cui_http_method_name(int method)
    int cui_url_params(const char * url, cui_kv_pair * pairs, int cap)
    uint8_t cui_url_set_params(char * url, size_t cap, const cui_kv_pair * pairs, int count)
    cui_uptime_result cui_uptime_ex(cui_ctx * ui, const char * id, const cui_uptime_service * services, int count, const cui_uptime_opts * opts_)
    cui_time_histogram_result cui_time_histogram_ex(cui_ctx * ui, const char * id, double start, double bucket_seconds, int buckets, const cui_histogram_series * series, int series_count, double * sel_start, double * sel_end, const cui_time_histogram_opts * opts_)
    cui_coverage_result cui_coverage_ex(cui_ctx * ui, const char * id, const cui_coverage_file * files, int count, const cui_coverage_opts * opts_)
    cui_blame_result cui_blame_ex(cui_ctx * ui, const char * id, const char *const * lines, const int * line_commit, int line_count, const cui_blame_commit * commits, int commit_count, const cui_blame_opts * opts_)
    cui_feature_flags_result cui_feature_flags_ex(cui_ctx * ui, const char * id, cui_feature_flag * flags, int count, const char *const * envs, int env_count, const cui_feature_flags_opts * opts_)
    cui_api_explorer_result cui_api_explorer_ex(cui_ctx * ui, const char * id, const cui_api_endpoint * endpoints, int count, const cui_api_explorer_opts * opts_)
    cui_dot_chart_result cui_dot_chart_ex(cui_ctx * ui, const char * id, const cui_dot_series * series, int series_count, int count, const cui_dot_chart_opts * opts_)
    cui_event_track_result cui_event_track_ex(cui_ctx * ui, const char * id, double * times, int * count, int capacity, double min, double max, const cui_event_track_opts * opts_)
    void cui_readout_ex(cui_ctx * ui, const char * label, const char * value, const cui_readout_opts * opts_)
    void cui_dot_display_ex(cui_ctx * ui, const char * text, const cui_dot_display_opts * opts_)
    void cui_draw_rect(cui_ctx * ui, cui_rect r, cui_corners radius, cui_color fill)
    void cui_draw_rect_border(cui_ctx * ui, cui_rect r, cui_corners radius, cui_color fill, cui_color border, float border_width)
    void cui_draw_rect_gradient(cui_ctx * ui, cui_rect r, cui_corners radius, cui_color top, cui_color bottom)
    void cui_draw_shadow(cui_ctx * ui, cui_rect r, cui_corners radius, float blur, float spread, cui_vec2 offset, cui_color color)
    void cui_draw_line(cui_ctx * ui, cui_vec2 a, cui_vec2 b, float thickness, cui_color color)
    void cui_draw_polyline(cui_ctx * ui, const cui_vec2 * points, int count, float thickness, cui_color color, uint8_t closed)
    void cui_draw_polygon(cui_ctx * ui, const cui_vec2 * points, int count, cui_color color)
    void cui_draw_circle(cui_ctx * ui, cui_vec2 center, float radius, cui_color color)
    void cui_draw_arc(cui_ctx * ui, cui_vec2 center, float radius, float a0, float a1, float thickness, cui_color color)
    void cui_draw_text(cui_ctx * ui, int font, float size, cui_vec2 pos, cui_color color, const char * text, int len)
    void cui_draw_icon(cui_ctx * ui, const char * icon, cui_rect r, float size, cui_color color)
    void cui_draw_image(cui_ctx * ui, uintptr_t tex, cui_rect r, cui_rect uv, cui_corners radius, cui_color tint)
    void cui_push_clip(cui_ctx * ui, cui_rect r)
    void cui_pop_clip(cui_ctx * ui)
    cui_canvas_result cui_canvas(cui_ctx * ui, const char * id, cui_size width, cui_size height, cui_paint_fn paint, const void * user, size_t user_size)
    void * cui_state(cui_ctx * ui, uint32_t id, size_t size)
    float cui_animate(cui_ctx * ui, uint32_t id, float target)
    float cui_animate_spring(cui_ctx * ui, uint32_t id, float target, float duration, float bounce)
    const cui_draw_data * cui_get_draw_data(cui_ctx * ui)

cdef extern from "cui/cui_render.h" nogil:
    ctypedef enum cui_sw_format:
        CUI_SW_RGBA = 0
        CUI_SW_BGRA = 1

    ctypedef struct cui_gl_renderer
    ctypedef struct cui_sw_renderer

    cui_sw_renderer * cui_sw_create()
    void cui_sw_destroy(cui_sw_renderer * r)
    cui_renderer_iface cui_sw_iface(cui_sw_renderer * r)
    void cui_sw_render(cui_sw_renderer * r, const cui_draw_data * dd, void * pixels, int width, int height, int stride, int format)
    void cui_sw_set_threads(cui_sw_renderer * r, int threads)
    void cui_sw_set_incremental(cui_sw_renderer * r, uint8_t on)
    uint8_t cui_sw_last_damage(const cui_sw_renderer * r, int * x, int * y, int * w, int * h)
    uint8_t cui_write_png(const char * path, const void * rgba, int width, int height, int stride)
    void cui_gl_destroy(cui_gl_renderer * r)
    cui_renderer_iface cui_gl_iface(cui_gl_renderer * r)
    void cui_gl_render(cui_gl_renderer * r, const cui_draw_data * dd, uint8_t clear)
    void cui_gl_read_pixels(cui_gl_renderer * r, int width, int height, void * rgba)
    uint8_t cui_gl_is_software(const cui_gl_renderer * r)

cdef extern from "cui/cui_app.h" nogil:
    ctypedef enum cui_file_dialog_kind:
        CUI_FILE_OPEN = 0
        CUI_FILE_SAVE = 1
        CUI_FILE_FOLDER = 2

    ctypedef enum cui_renderer_kind:
        CUI_RENDERER_AUTO = 0
        CUI_RENDERER_OPENGL = 1
        CUI_RENDERER_SOFTWARE = 2

    ctypedef struct cui_app_desc:
        const char * title
        int width
        int height
        int min_width
        int min_height
        uint8_t fixed_size
        uint8_t continuous
        uint8_t no_vsync
        uint8_t hidden
        int renderer
        int theme
        int accent
        uint8_t follow_system_theme
        const char * app_id

    ctypedef struct cui_file_dialog_opts:
        int kind
        const char * title
        const char * filter_name
        const char * filter
        const char * default_name

    ctypedef struct cui_app

    ctypedef void (*pycui_fnptr_2)(cui_ctx *, void *)

    cui_app * cui_app_create(const cui_app_desc * desc)
    void cui_app_destroy(cui_app * app)
    uint8_t cui_app_frame(cui_app * app)
    cui_ctx * cui_app_ui(cui_app * app)
    int cui_app_run(const cui_app_desc * desc, pycui_fnptr_2 frame, void * user)
    void cui_app_quit(cui_app * app)
    void cui_app_set_title(cui_app * app, const char * title)
    void cui_app_set_size(cui_app * app, int width, int height)
    cui_vec2 cui_app_size(cui_app * app)
    uint8_t cui_app_is_software(cui_app * app)
    void * cui_app_native_window(cui_app * app)
    const char * cui_app_backend(cui_app * app)
    uint8_t cui_app_file_dialog(cui_app * app, const cui_file_dialog_opts * opts_, char * out, size_t cap)
    uint8_t cui_app_open_url(const char * url)
    uint8_t cui_app_screenshot(cui_app * app, void * rgba, int width, int height)
