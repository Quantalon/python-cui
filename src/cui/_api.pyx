# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# cython: embedsignature=True
"""cui._api — one generated wrapper per callable CUI function.

Every wrapper takes the :class:`cui._cui.Context` first.  Option structs become
keyword-only arguments, out-parameters become extra return values, text buffers
come back as :class:`cui.TextResult`.

GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
"""

from libc.stddef cimport size_t
from libc.string cimport memset

from cpython.bytes cimport PyBytes_AsString, PyBytes_FromStringAndSize
from cpython.mem cimport PyMem_Free, PyMem_Malloc

from ._cui cimport (
    Context,
    _color,
    _size,
    from_color,
    from_corners,
    from_date,
    from_key_combo,
    from_rect,
    from_size,
    from_vec2,
    to_color,
    to_corners,
    to_date,
    to_key_combo,
    to_rect,
    to_size,
    to_vec2,
)
from ._types import Color, Corners, Date, KeyCombo, Rect, Size, TextResult, Vec2
from .cui_decl cimport *

cdef inline bytes _utf8(object value):
    if value is None:
        return b""
    if isinstance(value, bytes):
        return value
    return value.encode("utf-8")


cdef inline object _decode(const char *value):
    if value == NULL:
        return None
    return value.decode("utf-8", "replace")


# Some CUI helpers take no context, so they have no frame to keep strings alive
# in; those keep-alives land here instead.
_KEEP: list = []

cdef inline void _keep_alive(Context ctx, object value):
    if ctx is not None:
        ctx._keep.append(value)
    else:
        _KEEP.append(value)


cdef inline const char *const *_s_array_any(Context ctx, object values, int *count) except NULL:
    """A UTF-8 string array, kept alive by the frame or by _KEEP."""
    cdef list items, encoded
    cdef Py_ssize_t i, n
    cdef const char **arr
    cdef bytes block
    if values is None:
        count[0] = 0
        return NULL
    if ctx is not None:
        return ctx._s_array(values, count)
    items = [v if isinstance(v, str) else str(v) for v in values]
    encoded = [_utf8(v) for v in items]
    n = len(encoded)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(char *) * (n if n else 1))
    arr = <const char **>PyBytes_AsString(block)
    for i in range(n):
        arr[i] = <const char *>encoded[i]
    count[0] = <int>n
    _KEEP.append(encoded)
    _KEEP.append(block)
    return <const char *const *>arr


cdef extern from "_gen/sizes.h":
    size_t pycui_sizeof_cui_date_range() noexcept nogil
    size_t pycui_sizeof_cui_diff_range() noexcept nogil
    size_t pycui_sizeof_cui_diff_row() noexcept nogil
    size_t pycui_sizeof_cui_image_view() noexcept nogil
    size_t pycui_sizeof_cui_kanban_move() noexcept nogil
    size_t pycui_sizeof_cui_kv_pair() noexcept nogil
    size_t pycui_sizeof_cui_log_buffer() noexcept nogil
    size_t pycui_sizeof_cui_node_view() noexcept nogil
    size_t pycui_sizeof_cui_now_playing() noexcept nogil
    size_t pycui_sizeof_cui_regex_match() noexcept nogil
    size_t pycui_sizeof_cui_terminal_buffer() noexcept nogil
    void pycui_set_cui_box__(cui_box *target, int) noexcept nogil
    void pycui_set_cui_card_opts__(cui_card_opts *target, int) noexcept nogil
    void pycui_set_cui_scroll_opts__(cui_scroll_opts *target, int) noexcept nogil
    void pycui_set_cui_split_opts__(cui_split_opts *target, int) noexcept nogil
    void pycui_set_cui_text_opts__(cui_text_opts *target, int) noexcept nogil
    void pycui_set_cui_button_opts__(cui_button_opts *target, int) noexcept nogil
    void pycui_set_cui_segmented_opts__(cui_segmented_opts *target, int) noexcept nogil
    void pycui_set_cui_check_opts__(cui_check_opts *target, int) noexcept nogil
    void pycui_set_cui_slider_opts__(cui_slider_opts *target, int) noexcept nogil
    void pycui_set_cui_chip_opts__(cui_chip_opts *target, int) noexcept nogil
    void pycui_set_cui_input_opts__(cui_input_opts *target, int) noexcept nogil
    void pycui_set_cui_number_opts__(cui_number_opts *target, int) noexcept nogil
    void pycui_set_cui_select_opts__(cui_select_opts *target, int) noexcept nogil
    void pycui_set_cui_date_opts__(cui_date_opts *target, int) noexcept nogil
    void pycui_set_cui_tabs_opts__(cui_tabs_opts *target, int) noexcept nogil
    void pycui_set_cui_nav_opts__(cui_nav_opts *target, int) noexcept nogil
    void pycui_set_cui_popover_opts__(cui_popover_opts *target, int) noexcept nogil
    void pycui_set_cui_tour_opts__(cui_tour_opts *target, int) noexcept nogil
    void pycui_set_cui_menu_opts__(cui_menu_opts *target, int) noexcept nogil
    void pycui_set_cui_menu_item_opts__(cui_menu_item_opts *target, int) noexcept nogil
    void pycui_set_cui_dialog_opts__(cui_dialog_opts *target, int) noexcept nogil
    void pycui_set_cui_sheet_opts__(cui_sheet_opts *target, int) noexcept nogil
    void pycui_set_cui_toast_opts__(cui_toast_opts *target, int) noexcept nogil
    void pycui_set_cui_alert_opts__(cui_alert_opts *target, int) noexcept nogil
    void pycui_set_cui_progress_opts__(cui_progress_opts *target, int) noexcept nogil
    void pycui_set_cui_badge_opts__(cui_badge_opts *target, int) noexcept nogil
    void pycui_set_cui_avatar_opts__(cui_avatar_opts *target, int) noexcept nogil
    void pycui_set_cui_empty_opts__(cui_empty_opts *target, int) noexcept nogil
    void pycui_set_cui_metric_opts__(cui_metric_opts *target, int) noexcept nogil
    void pycui_set_cui_tree_opts__(cui_tree_opts *target, int) noexcept nogil
    void pycui_set_cui_list_item_opts__(cui_list_item_opts *target, int) noexcept nogil
    void pycui_set_cui_table_opts__(cui_table_opts *target, int) noexcept nogil
    void pycui_set_cui_chart_opts__(cui_chart_opts *target, int) noexcept nogil
    void pycui_set_cui_image_opts__(cui_image_opts *target, int) noexcept nogil
    void pycui_set_cui_image_viewer_opts__(cui_image_viewer_opts *target, int) noexcept nogil
    void pycui_set_cui_cropper_opts__(cui_cropper_opts *target, int) noexcept nogil
    void pycui_set_cui_radio_cards_opts__(cui_radio_cards_opts *target, int) noexcept nogil
    void pycui_set_cui_tag_opts__(cui_tag_opts *target, int) noexcept nogil
    void pycui_set_cui_hold_opts__(cui_hold_opts *target, int) noexcept nogil
    void pycui_set_cui_timeline_opts__(cui_timeline_opts *target, int) noexcept nogil
    void pycui_set_cui_split_button_opts__(cui_split_button_opts *target, int) noexcept nogil
    void pycui_set_cui_toggle_group_opts__(cui_toggle_group_opts *target, int) noexcept nogil
    void pycui_set_cui_confirm_opts__(cui_confirm_opts *target, int) noexcept nogil
    void pycui_set_cui_status_button_opts__(cui_status_button_opts *target, int) noexcept nogil
    void pycui_set_cui_speed_dial_opts__(cui_speed_dial_opts *target, int) noexcept nogil
    void pycui_set_cui_user_menu_opts__(cui_user_menu_opts *target, int) noexcept nogil
    void pycui_set_cui_grid_opts__(cui_grid_opts *target, int) noexcept nogil
    void pycui_set_cui_tree_table_opts__(cui_tree_table_opts *target, int) noexcept nogil
    void pycui_set_cui_path_bar_opts__(cui_path_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_file_browser_opts__(cui_file_browser_opts *target, int) noexcept nogil
    void pycui_set_cui_file_picker_opts__(cui_file_picker_opts *target, int) noexcept nogil
    void pycui_set_cui_code_opts__(cui_code_opts *target, int) noexcept nogil
    void pycui_set_cui_json_opts__(cui_json_opts *target, int) noexcept nogil
    void pycui_set_cui_markdown_opts__(cui_markdown_opts *target, int) noexcept nogil
    void pycui_set_cui_code_editor_opts__(cui_code_editor_opts *target, int) noexcept nogil
    void pycui_set_cui_diff_opts__(cui_diff_opts *target, int) noexcept nogil
    void pycui_set_cui_chat_opts__(cui_chat_opts *target, int) noexcept nogil
    void pycui_set_cui_comment_opts__(cui_comment_opts *target, int) noexcept nogil
    void pycui_set_cui_carousel_opts__(cui_carousel_opts *target, int) noexcept nogil
    void pycui_set_cui_compare_opts__(cui_compare_opts *target, int) noexcept nogil
    void pycui_set_cui_card_stack_opts__(cui_card_stack_opts *target, int) noexcept nogil
    void pycui_set_cui_counter_opts__(cui_counter_opts *target, int) noexcept nogil
    void pycui_set_cui_ticker_opts__(cui_ticker_opts *target, int) noexcept nogil
    void pycui_set_cui_heatmap_opts__(cui_heatmap_opts *target, int) noexcept nogil
    void pycui_set_cui_calendar_heatmap_opts__(cui_calendar_heatmap_opts *target, int) noexcept nogil
    void pycui_set_cui_treemap_opts__(cui_treemap_opts *target, int) noexcept nogil
    void pycui_set_cui_radar_opts__(cui_radar_opts *target, int) noexcept nogil
    void pycui_set_cui_funnel_opts__(cui_funnel_opts *target, int) noexcept nogil
    void pycui_set_cui_sankey_link_from(cui_sankey_link *target, int) noexcept nogil
    void pycui_set_cui_sankey_opts__(cui_sankey_opts *target, int) noexcept nogil
    void pycui_set_cui_waffle_opts__(cui_waffle_opts *target, int) noexcept nogil
    void pycui_set_cui_split_bar_opts__(cui_split_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_bar_list_opts__(cui_bar_list_opts *target, int) noexcept nogil
    void pycui_set_cui_rings_opts__(cui_rings_opts *target, int) noexcept nogil
    void pycui_set_cui_scatter_opts__(cui_scatter_opts *target, int) noexcept nogil
    void pycui_set_cui_radial_gauge_opts__(cui_radial_gauge_opts *target, int) noexcept nogil
    void pycui_set_cui_candlestick_opts__(cui_candlestick_opts *target, int) noexcept nogil
    void pycui_set_cui_text_fx_opts__(cui_text_fx_opts *target, int) noexcept nogil
    void pycui_set_cui_gradient_text_opts__(cui_gradient_text_opts *target, int) noexcept nogil
    void pycui_set_cui_gradient_text_opts_from(cui_gradient_text_opts *target, cui_color) noexcept nogil
    void pycui_set_cui_spotlight_opts__(cui_spotlight_opts *target, int) noexcept nogil
    void pycui_set_cui_loader_opts__(cui_loader_opts *target, int) noexcept nogil
    void pycui_set_cui_dock_opts__(cui_dock_opts *target, int) noexcept nogil
    void pycui_set_cui_dock_item_opts__(cui_dock_item_opts *target, int) noexcept nogil
    void pycui_set_cui_tab_bar_opts__(cui_tab_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_tile_opts__(cui_tile_opts *target, int) noexcept nogil
    void pycui_set_cui_waveform_opts__(cui_waveform_opts *target, int) noexcept nogil
    void pycui_set_cui_now_playing_opts__(cui_now_playing_opts *target, int) noexcept nogil
    void pycui_set_cui_reasoning_opts__(cui_reasoning_opts *target, int) noexcept nogil
    void pycui_set_cui_tool_call_opts__(cui_tool_call_opts *target, int) noexcept nogil
    void pycui_set_cui_agent_plan_opts__(cui_agent_plan_opts *target, int) noexcept nogil
    void pycui_set_cui_agent_status_opts__(cui_agent_status_opts *target, int) noexcept nogil
    void pycui_set_cui_context_opts__(cui_context_opts *target, int) noexcept nogil
    void pycui_set_cui_response_actions_opts__(cui_response_actions_opts *target, int) noexcept nogil
    void pycui_set_cui_prompt_suggestions_opts__(cui_prompt_suggestions_opts *target, int) noexcept nogil
    void pycui_set_cui_model_picker_opts__(cui_model_picker_opts *target, int) noexcept nogil
    void pycui_set_cui_composer_opts__(cui_composer_opts *target, int) noexcept nogil
    void pycui_set_cui_voice_orb_opts__(cui_voice_orb_opts *target, int) noexcept nogil
    void pycui_set_cui_kanban_column_opts__(cui_kanban_column_opts *target, int) noexcept nogil
    void pycui_set_cui_week_opts__(cui_week_opts *target, int) noexcept nogil
    void pycui_set_cui_month_opts__(cui_month_opts *target, int) noexcept nogil
    void pycui_set_cui_gantt_opts__(cui_gantt_opts *target, int) noexcept nogil
    void pycui_set_cui_hover_card_opts__(cui_hover_card_opts *target, int) noexcept nogil
    void pycui_set_cui_confirm_popover_opts__(cui_confirm_popover_opts *target, int) noexcept nogil
    void pycui_set_cui_expandable_text_opts__(cui_expandable_text_opts *target, int) noexcept nogil
    void pycui_set_cui_expandable_card_opts__(cui_expandable_card_opts *target, int) noexcept nogil
    void pycui_set_cui_banner_opts__(cui_banner_opts *target, int) noexcept nogil
    void pycui_set_cui_countdown_opts__(cui_countdown_opts *target, int) noexcept nogil
    void pycui_set_cui_checklist_opts__(cui_checklist_opts *target, int) noexcept nogil
    void pycui_set_cui_multi_select_opts__(cui_multi_select_opts *target, int) noexcept nogil
    void pycui_set_cui_date_range_opts__(cui_date_range_opts *target, int) noexcept nogil
    void pycui_set_cui_time_opts__(cui_time_opts *target, int) noexcept nogil
    void pycui_set_cui_wheel_opts__(cui_wheel_opts *target, int) noexcept nogil
    void pycui_set_cui_ruler_opts__(cui_ruler_opts *target, int) noexcept nogil
    void pycui_set_cui_histogram_opts__(cui_histogram_opts *target, int) noexcept nogil
    void pycui_set_cui_knob_opts__(cui_knob_opts *target, int) noexcept nogil
    void pycui_set_cui_fader_opts__(cui_fader_opts *target, int) noexcept nogil
    void pycui_set_cui_level_meter_opts__(cui_level_meter_opts *target, int) noexcept nogil
    void pycui_set_cui_signature_opts__(cui_signature_opts *target, int) noexcept nogil
    void pycui_set_cui_dropzone_opts__(cui_dropzone_opts *target, int) noexcept nogil
    void pycui_set_cui_inline_edit_opts__(cui_inline_edit_opts *target, int) noexcept nogil
    void pycui_set_cui_scrub_opts__(cui_scrub_opts *target, int) noexcept nogil
    void pycui_set_cui_money_opts__(cui_money_opts *target, int) noexcept nogil
    void pycui_set_cui_shortcut_recorder_opts__(cui_shortcut_recorder_opts *target, int) noexcept nogil
    void pycui_set_cui_node_editor_opts__(cui_node_editor_opts *target, int) noexcept nogil
    void pycui_set_cui_node_opts__(cui_node_opts *target, int) noexcept nogil
    void pycui_set_cui_pin_opts__(cui_pin_opts *target, int) noexcept nogil
    void pycui_set_cui_menu_bar_opts__(cui_menu_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_menu_bar_menu_opts__(cui_menu_bar_menu_opts *target, int) noexcept nogil
    void pycui_set_cui_toolbar_opts__(cui_toolbar_opts *target, int) noexcept nogil
    void pycui_set_cui_tool_opts__(cui_tool_opts *target, int) noexcept nogil
    void pycui_set_cui_status_bar_opts__(cui_status_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_status_item_opts__(cui_status_item_opts *target, int) noexcept nogil
    void pycui_set_cui_status_progress_opts__(cui_status_progress_opts *target, int) noexcept nogil
    void pycui_set_cui_doc_tabs_opts__(cui_doc_tabs_opts *target, int) noexcept nogil
    void pycui_set_cui_dockspace_opts__(cui_dockspace_opts *target, int) noexcept nogil
    void pycui_set_cui_dock_panel_opts__(cui_dock_panel_opts *target, int) noexcept nogil
    void pycui_set_cui_inspector_opts__(cui_inspector_opts *target, int) noexcept nogil
    void pycui_set_cui_prop_opts__(cui_prop_opts *target, int) noexcept nogil
    void pycui_set_cui_log_view_opts__(cui_log_view_opts *target, int) noexcept nogil
    void pycui_set_cui_terminal_opts__(cui_terminal_opts *target, int) noexcept nogil
    void pycui_set_cui_emoji_picker_opts__(cui_emoji_picker_opts *target, int) noexcept nogil
    void pycui_set_cui_hex_view_opts__(cui_hex_view_opts *target, int) noexcept nogil
    void pycui_set_cui_flame_opts__(cui_flame_opts *target, int) noexcept nogil
    void pycui_set_cui_curve_opts__(cui_curve_opts *target, int) noexcept nogil
    void pycui_set_cui_gradient_opts__(cui_gradient_opts *target, int) noexcept nogil
    void pycui_set_cui_timeline_editor_opts__(cui_timeline_editor_opts *target, int) noexcept nogil
    void pycui_set_cui_kv_editor_opts__(cui_kv_editor_opts *target, int) noexcept nogil
    void pycui_set_cui_problems_opts__(cui_problems_opts *target, int) noexcept nogil
    void pycui_set_cui_pipeline_opts__(cui_pipeline_opts *target, int) noexcept nogil
    void pycui_set_cui_query_opts__(cui_query_opts *target, int) noexcept nogil
    void pycui_set_cui_schedule_opts__(cui_schedule_opts *target, int) noexcept nogil
    void pycui_set_cui_keymap_opts__(cui_keymap_opts *target, int) noexcept nogil
    void pycui_set_cui_commit_graph_opts__(cui_commit_graph_opts *target, int) noexcept nogil
    void pycui_set_cui_graph_edge_from(cui_graph_edge *target, int) noexcept nogil
    void pycui_set_cui_graph_opts__(cui_graph_opts *target, int) noexcept nogil
    void pycui_set_cui_waterfall_opts__(cui_waterfall_opts *target, int) noexcept nogil
    void pycui_set_cui_trace_opts__(cui_trace_opts *target, int) noexcept nogil
    void pycui_set_cui_regex_tester_opts__(cui_regex_tester_opts *target, int) noexcept nogil
    void pycui_set_cui_test_explorer_opts__(cui_test_explorer_opts *target, int) noexcept nogil
    void pycui_set_cui_stack_trace_opts__(cui_stack_trace_opts *target, int) noexcept nogil
    void pycui_set_cui_request_bar_opts__(cui_request_bar_opts *target, int) noexcept nogil
    void pycui_set_cui_uptime_opts__(cui_uptime_opts *target, int) noexcept nogil
    void pycui_set_cui_time_histogram_opts__(cui_time_histogram_opts *target, int) noexcept nogil
    void pycui_set_cui_coverage_opts__(cui_coverage_opts *target, int) noexcept nogil
    void pycui_set_cui_blame_opts__(cui_blame_opts *target, int) noexcept nogil
    void pycui_set_cui_feature_flags_opts__(cui_feature_flags_opts *target, int) noexcept nogil
    void pycui_set_cui_api_param_in(cui_api_param *target, const char *) noexcept nogil
    void pycui_set_cui_api_explorer_opts__(cui_api_explorer_opts *target, int) noexcept nogil
    void pycui_set_cui_dot_chart_opts__(cui_dot_chart_opts *target, int) noexcept nogil
    void pycui_set_cui_event_track_opts__(cui_event_track_opts *target, int) noexcept nogil
    void pycui_set_cui_readout_opts__(cui_readout_opts *target, int) noexcept nogil
    void pycui_set_cui_dot_display_opts__(cui_dot_display_opts *target, int) noexcept nogil

cdef class DateRange:
    """Opaque `cui_date_range` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_date_range())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_date_range())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.DateRange>"


cdef class DiffRange:
    """Opaque `cui_diff_range` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_diff_range())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_diff_range())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.DiffRange>"


cdef class DiffRow:
    """Opaque `cui_diff_row` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_diff_row())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_diff_row())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.DiffRow>"


cdef class ImageView:
    """Opaque `cui_image_view` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_image_view())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_image_view())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.ImageView>"


cdef class KanbanMove:
    """Opaque `cui_kanban_move` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_kanban_move())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_kanban_move())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.KanbanMove>"


cdef class KvPair:
    """Opaque `cui_kv_pair` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_kv_pair())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_kv_pair())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.KvPair>"


cdef class LogBuffer:
    """Opaque `cui_log_buffer` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_log_buffer())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_log_buffer())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.LogBuffer>"


cdef class NodeView:
    """Opaque `cui_node_view` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_node_view())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_node_view())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.NodeView>"


cdef class NowPlaying:
    """Opaque `cui_now_playing` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_now_playing())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_now_playing())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.NowPlaying>"


cdef class RegexMatch:
    """Opaque `cui_regex_match` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_regex_match())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_regex_match())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.RegexMatch>"


cdef class TerminalBuffer:
    """Opaque `cui_terminal_buffer` storage owned by Python and zero initialized."""

    cdef void *_mem

    def __cinit__(self):
        self._mem = PyMem_Malloc(pycui_sizeof_cui_terminal_buffer())
        if self._mem == NULL:
            raise MemoryError("out of memory")
        memset(self._mem, 0, pycui_sizeof_cui_terminal_buffer())

    def __dealloc__(self):
        if self._mem != NULL:
            PyMem_Free(self._mem)
            self._mem = NULL

    def __repr__(self):
        return "<cui.TerminalBuffer>"


cdef inline void *_pack_cui_candle(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_candle`."""
    cdef Py_ssize_t i, n
    cdef cui_candle *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_candle) * (n if n else 1))
    buf = <cui_candle *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_candle) * (n if n else 1))
    for i in range(n):
        item = items[i]
        buf[i].open = <float>item.open
        buf[i].high = <float>item.high
        buf[i].low = <float>item.low
        buf[i].close = <float>item.close
        buf[i].volume = <float>item.volume
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_choice(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_choice`."""
    cdef Py_ssize_t i, n
    cdef cui_choice *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_choice) * (n if n else 1))
    buf = <cui_choice *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_choice) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.description))
        buf[i].description = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.badge))
        buf[i].badge = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_command(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_command`."""
    cdef Py_ssize_t i, n
    cdef cui_command *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_command) * (n if n else 1))
    buf = <cui_command *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_command) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.group))
        buf[i].group = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.shortcut))
        buf[i].shortcut = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_curve_key(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_curve_key`."""
    cdef Py_ssize_t i, n
    cdef cui_curve_key *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_curve_key) * (n if n else 1))
    buf = <cui_curve_key *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_curve_key) * (n if n else 1))
    for i in range(n):
        item = items[i]
        buf[i].x = <float>item.x
        buf[i].y = <float>item.y
        buf[i].in_dx = <float>item.in_dx
        buf[i].in_dy = <float>item.in_dy
        buf[i].out_dx = <float>item.out_dx
        buf[i].out_dy = <float>item.out_dy
        buf[i].mode = <uint8_t>item.mode
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_flame_span(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_flame_span`."""
    cdef Py_ssize_t i, n
    cdef cui_flame_span *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_flame_span) * (n if n else 1))
    buf = <cui_flame_span *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_flame_span) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.name))
        buf[i].name = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].start = <double>item.start
        buf[i].end = <double>item.end
        buf[i].depth = <int>item.depth
        buf[i].color_key = <uint32_t>item.color_key
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_gradient_stop(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_gradient_stop`."""
    cdef Py_ssize_t i, n
    cdef cui_gradient_stop *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_gradient_stop) * (n if n else 1))
    buf = <cui_gradient_stop *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_gradient_stop) * (n if n else 1))
    for i in range(n):
        item = items[i]
        buf[i].pos = <float>item.pos
        to_color(item.color, &buf[i].color)
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_grid_column(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_grid_column`."""
    cdef Py_ssize_t i, n
    cdef cui_grid_column *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_grid_column) * (n if n else 1))
    buf = <cui_grid_column *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_grid_column) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].width = <float>item.width
        buf[i].align = <int>item.align
        buf[i].sortable = <uint8_t>bool(item.sortable)
        buf[i].fixed = <uint8_t>bool(item.fixed)
        buf[i].priority = <int>item.priority
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_markdown_result(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_markdown_result`."""
    cdef Py_ssize_t i, n
    cdef cui_markdown_result *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_markdown_result) * (n if n else 1))
    buf = <cui_markdown_result *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_markdown_result) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.link))
        buf[i].link = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.hovered_link))
        buf[i].hovered_link = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].task_offset = <int>item.task_offset
        buf[i].task_line = <int>item.task_line
        buf[i].task_checked = <uint8_t>bool(item.task_checked)
        buf[i].height = <float>item.height
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_model(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_model`."""
    cdef Py_ssize_t i, n
    cdef cui_model *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_model) * (n if n else 1))
    buf = <cui_model *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_model) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.name))
        buf[i].name = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.detail))
        buf[i].detail = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.badge))
        buf[i].badge = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_plan_step(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_plan_step`."""
    cdef Py_ssize_t i, n
    cdef cui_plan_step *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_plan_step) * (n if n else 1))
    buf = <cui_plan_step *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_plan_step) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.detail))
        buf[i].detail = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].status = <int>item.status
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_presence_user(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_presence_user`."""
    cdef Py_ssize_t i, n
    cdef cui_presence_user *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_presence_user) * (n if n else 1))
    buf = <cui_presence_user *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_presence_user) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.name))
        buf[i].name = <const char *>pycui_strings[len(pycui_strings) - 1]
        to_color(item.color, &buf[i].color)
        buf[i].avatar = <uintptr_t>item.avatar
        buf[i].idle = <uint8_t>bool(item.idle)
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_prompt_suggestion(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_prompt_suggestion`."""
    cdef Py_ssize_t i, n
    cdef cui_prompt_suggestion *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_prompt_suggestion) * (n if n else 1))
    buf = <cui_prompt_suggestion *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_prompt_suggestion) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.detail))
        buf[i].detail = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_sankey_link(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_sankey_link`."""
    cdef Py_ssize_t i, n
    cdef cui_sankey_link *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_sankey_link) * (n if n else 1))
    buf = <cui_sankey_link *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_sankey_link) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_set_cui_sankey_link_from(&buf[i], item.from_)
        buf[i].to = <int>item.to
        buf[i].value = <float>item.value
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_source(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_source`."""
    cdef Py_ssize_t i, n
    cdef cui_source *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_source) * (n if n else 1))
    buf = <cui_source *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_source) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.url))
        buf[i].url = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.snippet))
        buf[i].snippet = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_speed_action(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_speed_action`."""
    cdef Py_ssize_t i, n
    cdef cui_speed_action *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_speed_action) * (n if n else 1))
    buf = <cui_speed_action *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_speed_action) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.label))
        buf[i].label = <const char *>pycui_strings[len(pycui_strings) - 1]
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_swipe_action(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_swipe_action`."""
    cdef Py_ssize_t i, n
    cdef cui_swipe_action *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_swipe_action) * (n if n else 1))
    buf = <cui_swipe_action *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_swipe_action) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.label))
        buf[i].label = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].tone = <int>item.tone
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_tab_bar_item(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_tab_bar_item`."""
    cdef Py_ssize_t i, n
    cdef cui_tab_bar_item *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_tab_bar_item) * (n if n else 1))
    buf = <cui_tab_bar_item *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_tab_bar_item) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.icon))
        buf[i].icon = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.label))
        buf[i].label = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].badge = <int>item.badge
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_table_column(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_table_column`."""
    cdef Py_ssize_t i, n
    cdef cui_table_column *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_table_column) * (n if n else 1))
    buf = <cui_table_column *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_table_column) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        to_size(item.width, &buf[i].width)
        buf[i].align = <int>item.align
        buf[i].sortable = <uint8_t>bool(item.sortable)
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_ticker_item(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_ticker_item`."""
    cdef Py_ssize_t i, n
    cdef cui_ticker_item *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_ticker_item) * (n if n else 1))
    buf = <cui_ticker_item *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_ticker_item) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.label))
        buf[i].label = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.value))
        buf[i].value = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].delta = <float>item.delta
        buf[i].lower_is_better = <uint8_t>bool(item.lower_is_better)
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_toc_item(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_toc_item`."""
    cdef Py_ssize_t i, n
    cdef cui_toc_item *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_toc_item) * (n if n else 1))
    buf = <cui_toc_item *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_toc_item) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.anchor))
        buf[i].anchor = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].level = <int>item.level
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_tour_step(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_tour_step`."""
    cdef Py_ssize_t i, n
    cdef cui_tour_step *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_tour_step) * (n if n else 1))
    buf = <cui_tour_step *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_tour_step) * (n if n else 1))
    for i in range(n):
        item = items[i]
        buf[i].target = <uint32_t>item.target
        pycui_strings.append(_utf8(item.title))
        buf[i].title = <const char *>pycui_strings[len(pycui_strings) - 1]
        pycui_strings.append(_utf8(item.body))
        buf[i].body = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].placement = <int>item.placement
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


cdef inline void *_pack_cui_viz_item(Context ctx, object items, int *count) except NULL:
    """Copy Python values into an array of `cui_viz_item`."""
    cdef Py_ssize_t i, n
    cdef cui_viz_item *buf
    cdef object item
    cdef bytes block
    cdef list pycui_strings = []
    if items is None:
        count[0] = 0
        return NULL
    n = len(items)
    block = PyBytes_FromStringAndSize(NULL, <Py_ssize_t>sizeof(cui_viz_item) * (n if n else 1))
    buf = <cui_viz_item *>PyBytes_AsString(block)
    memset(buf, 0, sizeof(cui_viz_item) * (n if n else 1))
    for i in range(n):
        item = items[i]
        pycui_strings.append(_utf8(item.label))
        buf[i].label = <const char *>pycui_strings[len(pycui_strings) - 1]
        buf[i].value = <float>item.value
        to_color(item.color, &buf[i].color)
    count[0] = <int>n
    _keep_alive(ctx, block)
    _keep_alive(ctx, pycui_strings)
    return <void *>buf


def viewport_size(Context ctx):
    """Wrap ``cui_viewport_size``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_result = cui_viewport_size(pycui_ctx)
    return from_vec2(&pycui_result)

def dpi_scale(Context ctx):
    """Wrap ``cui_dpi_scale``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef double pycui_result = cui_dpi_scale(pycui_ctx)
    return float(pycui_result)

def input_mouse_move(Context ctx, x, y):
    """Wrap ``cui_input_mouse_move``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_mouse_move(pycui_ctx, <float>x, <float>y)
    return None

def input_mouse_button(Context ctx, button, down):
    """Wrap ``cui_input_mouse_button``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_mouse_button(pycui_ctx, <int>button, <uint8_t>bool(down))
    return None

def input_mouse_leave(Context ctx):
    """Wrap ``cui_input_mouse_leave``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_mouse_leave(pycui_ctx)
    return None

def input_scroll(Context ctx, dx, dy):
    """Wrap ``cui_input_scroll``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_scroll(pycui_ctx, <float>dx, <float>dy)
    return None

def input_key(Context ctx, key, down, mods):
    """Wrap ``cui_input_key``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_key(pycui_ctx, <int>key, <uint8_t>bool(down), <int>mods)
    return None

def input_text(Context ctx, utf8):
    """Wrap ``cui_input_text``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_text(pycui_ctx, ctx._s(utf8))
    return None

def input_focus(Context ctx, window_focused):
    """Wrap ``cui_input_focus``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_focus(pycui_ctx, <uint8_t>bool(window_focused))
    return None

def input_file_hover(Context ctx, hovering, x, y):
    """Files dragged from the OS: hover while a drag is over the window (where the platform reports it), then the drop itself. Paths are UTF-8 and copied."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_input_file_hover(pycui_ctx, <uint8_t>bool(hovering), <float>x, <float>y)
    return None

def input_file_drop(Context ctx, paths, x, y):
    """Wrap ``cui_input_file_drop``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_paths
    cdef int pycui_n_paths
    pycui_ptr_paths = _s_array_any(ctx, paths, &pycui_n_paths)
    cui_input_file_drop(pycui_ctx, pycui_ptr_paths, pycui_n_paths, <float>x, <float>y)
    return None

def dropped_file_count(Context ctx):
    """Files dropped this frame (dropzones claim theirs first)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_dropped_file_count(pycui_ctx)
    return int(pycui_result)

def dropped_file(Context ctx, index):
    """Wrap ``cui_dropped_file``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *pycui_result = cui_dropped_file(pycui_ctx, <int>index)
    return _decode(pycui_result)

def file_drag_active(Context ctx):
    """Wrap ``cui_file_drag_active``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_file_drag_active(pycui_ctx)
    return bool(pycui_result)

def get_cursor(Context ctx):
    """Wrap ``cui_get_cursor``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_get_cursor(pycui_ctx)
    return int(pycui_result)

def key_pressed(Context ctx, key):
    """Queries, useful for app level shortcuts."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_key_pressed(pycui_ctx, <int>key)
    return bool(pycui_result)

def key_down(Context ctx, key):
    """Wrap ``cui_key_down``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_key_down(pycui_ctx, <int>key)
    return bool(pycui_result)

def shortcut(Context ctx, mods, key):
    """Wrap ``cui_shortcut``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_shortcut(pycui_ctx, <int>mods, <int>key)
    return bool(pycui_result)

def key_mods(Context ctx):
    """Wrap ``cui_key_mods``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_key_mods(pycui_ctx)
    return int(pycui_result)

def mouse_pos(Context ctx):
    """Wrap ``cui_mouse_pos``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_result = cui_mouse_pos(pycui_ctx)
    return from_vec2(&pycui_result)

def mouse_down(Context ctx, b):
    """Wrap ``cui_mouse_down``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_mouse_down(pycui_ctx, <int>b)
    return bool(pycui_result)

def mouse_clicked(Context ctx, b):
    """Wrap ``cui_mouse_clicked``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_mouse_clicked(pycui_ctx, <int>b)
    return bool(pycui_result)

def wants_keyboard(Context ctx):
    """True when a text field has keyboard focus (so the app should not treat typing as shortcuts)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_wants_keyboard(pycui_ctx)
    return bool(pycui_result)

def wants_mouse(Context ctx):
    """Wrap ``cui_wants_mouse``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_wants_mouse(pycui_ctx)
    return bool(pycui_result)

def set_theme(Context ctx, mode):
    """Wrap ``cui_set_theme``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_set_theme(pycui_ctx, <int>mode)
    return None

def get_theme_mode(Context ctx):
    """Wrap ``cui_get_theme_mode``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_get_theme_mode(pycui_ctx)
    return int(pycui_result)

def set_accent(Context ctx, accent):
    """Wrap ``cui_set_accent``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_set_accent(pycui_ctx, <int>accent)
    return None

def get_accent(Context ctx):
    """Wrap ``cui_get_accent``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_get_accent(pycui_ctx)
    return int(pycui_result)

def set_reduced_motion(Context ctx, reduced):
    """Wrap ``cui_set_reduced_motion``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_set_reduced_motion(pycui_ctx, <uint8_t>bool(reduced))
    return None

def color_of(Context ctx, c):
    """Wrap ``cui_color_of``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_color pycui_value_c
    to_color(c, &pycui_value_c)
    cdef cui_color pycui_result = cui_color_of(pycui_ctx, pycui_value_c)
    return from_color(&pycui_result)

def token_color(Context ctx, token):
    """Wrap ``cui_token_color``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_color pycui_result = cui_token_color(pycui_ctx, <int>token)
    return from_color(&pycui_result)

def accent_name(accent):
    """Wrap ``cui_accent_name``."""
    cdef const char *pycui_result = cui_accent_name(<int>accent)
    return _decode(pycui_result)

def oklch(l, c, h_degrees, alpha):
    """Color helpers. Mixing is done in OKLab, like CSS color-mix(in oklab)."""
    cdef cui_color pycui_result = cui_oklch(<float>l, <float>c, <float>h_degrees, <float>alpha)
    return from_color(&pycui_result)

def mix(a, b, t):
    """Wrap ``cui_mix``."""
    cdef cui_color pycui_value_a
    cdef cui_color pycui_value_b
    to_color(a, &pycui_value_a)
    to_color(b, &pycui_value_b)
    cdef cui_color pycui_result = cui_mix(pycui_value_a, pycui_value_b, <float>t)
    return from_color(&pycui_result)

def alpha(c, alpha_multiplier):
    """Wrap ``cui_alpha``."""
    cdef cui_color pycui_value_c
    to_color(c, &pycui_value_c)
    cdef cui_color pycui_result = cui_alpha(pycui_value_c, <float>alpha_multiplier)
    return from_color(&pycui_result)

def font_load_memory(Context ctx, data, copy):
    """Load a TrueType/OpenType font. The data must stay alive if copy is false. Returns a font id, or -1 on failure."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const void *pycui_ptr_data
    cdef size_t pycui_size_data
    pycui_ptr_data = ctx._c_bytes(data, &pycui_size_data)
    cdef long long pycui_result = cui_font_load_memory(pycui_ctx, pycui_ptr_data, pycui_size_data, <uint8_t>bool(copy))
    return int(pycui_result)

def font_load_file(Context ctx, path):
    """Wrap ``cui_font_load_file``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_font_load_file(pycui_ctx, ctx._s(path))
    return int(pycui_result)

def font_set_role(Context ctx, role, font):
    """Replace one of the built-in roles (e.g. use your brand font as CUI_FONT_BODY)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_font_set_role(pycui_ctx, <int>role, <int>font)
    return None

def font_add_fallback(Context ctx, font, fallback):
    """Glyphs missing from `font` are looked up in `fallback` (e.g. CJK, emoji)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_font_add_fallback(pycui_ctx, <int>font, <int>fallback)
    return None

def box_begin(Context ctx, *, id=None, dir=None, width=None, height=None, min_width=None, max_width=None, min_height=None, max_height=None, pad=None, pad_x=None, pad_y=None, pad_top=None, pad_right=None, pad_bottom=None, pad_left=None, gap=None, columns=None, min_column_width=None, wrap=False, align=None, justify=None, bg=None, border_color=None, border=None, radius=None, radius_tl=None, radius_tr=None, radius_br=None, radius_bl=None, elevation=None, scroll_x=False, scroll_y=False, clip=False, opacity=None, direction=None):
    """Wrap ``cui_box_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_box opts
    memset(&opts, 0, sizeof(opts))
    if id is not None:
        opts.id = ctx._s(id)
    if dir is not None:
        opts.dir = <int>(dir)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_width is not None:
        opts.min_width = <float>(min_width)
    if max_width is not None:
        opts.max_width = <float>(max_width)
    if min_height is not None:
        opts.min_height = <float>(min_height)
    if max_height is not None:
        opts.max_height = <float>(max_height)
    if pad is not None:
        opts.pad = <float>(pad)
    if pad_x is not None:
        opts.pad_x = <float>(pad_x)
    if pad_y is not None:
        opts.pad_y = <float>(pad_y)
    if pad_top is not None:
        opts.pad_top = <float>(pad_top)
    if pad_right is not None:
        opts.pad_right = <float>(pad_right)
    if pad_bottom is not None:
        opts.pad_bottom = <float>(pad_bottom)
    if pad_left is not None:
        opts.pad_left = <float>(pad_left)
    if gap is not None:
        opts.gap = <float>(gap)
    if columns is not None:
        opts.columns = <int>(columns)
    if min_column_width is not None:
        opts.min_column_width = <float>(min_column_width)
    opts.wrap = <uint8_t>bool(wrap)
    if align is not None:
        opts.align = <int>(align)
    if justify is not None:
        opts.justify = <int>(justify)
    if bg is not None:
        to_color(bg, &opts.bg)
    if border_color is not None:
        to_color(border_color, &opts.border_color)
    if border is not None:
        opts.border = <float>(border)
    if radius is not None:
        opts.radius = <float>(radius)
    if radius_tl is not None:
        opts.radius_tl = <float>(radius_tl)
    if radius_tr is not None:
        opts.radius_tr = <float>(radius_tr)
    if radius_br is not None:
        opts.radius_br = <float>(radius_br)
    if radius_bl is not None:
        opts.radius_bl = <float>(radius_bl)
    if elevation is not None:
        opts.elevation = <int>(elevation)
    opts.scroll_x = <uint8_t>bool(scroll_x)
    opts.scroll_y = <uint8_t>bool(scroll_y)
    opts.clip = <uint8_t>bool(clip)
    if opacity is not None:
        opts.opacity = <float>(opacity)
    if direction is not None:
        opts.direction = <int>(direction)
    cdef long long pycui_result = cui_box_begin(pycui_ctx, &opts)
    return int(pycui_result)

def box_end(Context ctx):
    """Wrap ``cui_box_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_box_end(pycui_ctx)
    return None

def row_begin(Context ctx, *, id=None, dir=None, width=None, height=None, min_width=None, max_width=None, min_height=None, max_height=None, pad=None, pad_x=None, pad_y=None, pad_top=None, pad_right=None, pad_bottom=None, pad_left=None, gap=None, columns=None, min_column_width=None, wrap=False, align=None, justify=None, bg=None, border_color=None, border=None, radius=None, radius_tl=None, radius_tr=None, radius_br=None, radius_bl=None, elevation=None, scroll_x=False, scroll_y=False, clip=False, opacity=None, direction=None):
    """Wrap ``cui_row_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_box opts
    memset(&opts, 0, sizeof(opts))
    if id is not None:
        opts.id = ctx._s(id)
    if dir is not None:
        opts.dir = <int>(dir)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_width is not None:
        opts.min_width = <float>(min_width)
    if max_width is not None:
        opts.max_width = <float>(max_width)
    if min_height is not None:
        opts.min_height = <float>(min_height)
    if max_height is not None:
        opts.max_height = <float>(max_height)
    if pad is not None:
        opts.pad = <float>(pad)
    if pad_x is not None:
        opts.pad_x = <float>(pad_x)
    if pad_y is not None:
        opts.pad_y = <float>(pad_y)
    if pad_top is not None:
        opts.pad_top = <float>(pad_top)
    if pad_right is not None:
        opts.pad_right = <float>(pad_right)
    if pad_bottom is not None:
        opts.pad_bottom = <float>(pad_bottom)
    if pad_left is not None:
        opts.pad_left = <float>(pad_left)
    if gap is not None:
        opts.gap = <float>(gap)
    if columns is not None:
        opts.columns = <int>(columns)
    if min_column_width is not None:
        opts.min_column_width = <float>(min_column_width)
    opts.wrap = <uint8_t>bool(wrap)
    if align is not None:
        opts.align = <int>(align)
    if justify is not None:
        opts.justify = <int>(justify)
    if bg is not None:
        to_color(bg, &opts.bg)
    if border_color is not None:
        to_color(border_color, &opts.border_color)
    if border is not None:
        opts.border = <float>(border)
    if radius is not None:
        opts.radius = <float>(radius)
    if radius_tl is not None:
        opts.radius_tl = <float>(radius_tl)
    if radius_tr is not None:
        opts.radius_tr = <float>(radius_tr)
    if radius_br is not None:
        opts.radius_br = <float>(radius_br)
    if radius_bl is not None:
        opts.radius_bl = <float>(radius_bl)
    if elevation is not None:
        opts.elevation = <int>(elevation)
    opts.scroll_x = <uint8_t>bool(scroll_x)
    opts.scroll_y = <uint8_t>bool(scroll_y)
    opts.clip = <uint8_t>bool(clip)
    if opacity is not None:
        opts.opacity = <float>(opacity)
    if direction is not None:
        opts.direction = <int>(direction)
    cdef long long pycui_result = cui_row_begin(pycui_ctx, &opts)
    return int(pycui_result)

def column_begin(Context ctx, *, id=None, dir=None, width=None, height=None, min_width=None, max_width=None, min_height=None, max_height=None, pad=None, pad_x=None, pad_y=None, pad_top=None, pad_right=None, pad_bottom=None, pad_left=None, gap=None, columns=None, min_column_width=None, wrap=False, align=None, justify=None, bg=None, border_color=None, border=None, radius=None, radius_tl=None, radius_tr=None, radius_br=None, radius_bl=None, elevation=None, scroll_x=False, scroll_y=False, clip=False, opacity=None, direction=None):
    """Wrap ``cui_column_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_box opts
    memset(&opts, 0, sizeof(opts))
    if id is not None:
        opts.id = ctx._s(id)
    if dir is not None:
        opts.dir = <int>(dir)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_width is not None:
        opts.min_width = <float>(min_width)
    if max_width is not None:
        opts.max_width = <float>(max_width)
    if min_height is not None:
        opts.min_height = <float>(min_height)
    if max_height is not None:
        opts.max_height = <float>(max_height)
    if pad is not None:
        opts.pad = <float>(pad)
    if pad_x is not None:
        opts.pad_x = <float>(pad_x)
    if pad_y is not None:
        opts.pad_y = <float>(pad_y)
    if pad_top is not None:
        opts.pad_top = <float>(pad_top)
    if pad_right is not None:
        opts.pad_right = <float>(pad_right)
    if pad_bottom is not None:
        opts.pad_bottom = <float>(pad_bottom)
    if pad_left is not None:
        opts.pad_left = <float>(pad_left)
    if gap is not None:
        opts.gap = <float>(gap)
    if columns is not None:
        opts.columns = <int>(columns)
    if min_column_width is not None:
        opts.min_column_width = <float>(min_column_width)
    opts.wrap = <uint8_t>bool(wrap)
    if align is not None:
        opts.align = <int>(align)
    if justify is not None:
        opts.justify = <int>(justify)
    if bg is not None:
        to_color(bg, &opts.bg)
    if border_color is not None:
        to_color(border_color, &opts.border_color)
    if border is not None:
        opts.border = <float>(border)
    if radius is not None:
        opts.radius = <float>(radius)
    if radius_tl is not None:
        opts.radius_tl = <float>(radius_tl)
    if radius_tr is not None:
        opts.radius_tr = <float>(radius_tr)
    if radius_br is not None:
        opts.radius_br = <float>(radius_br)
    if radius_bl is not None:
        opts.radius_bl = <float>(radius_bl)
    if elevation is not None:
        opts.elevation = <int>(elevation)
    opts.scroll_x = <uint8_t>bool(scroll_x)
    opts.scroll_y = <uint8_t>bool(scroll_y)
    opts.clip = <uint8_t>bool(clip)
    if opacity is not None:
        opts.opacity = <float>(opacity)
    if direction is not None:
        opts.direction = <int>(direction)
    cdef long long pycui_result = cui_column_begin(pycui_ctx, &opts)
    return int(pycui_result)

def spacer(Context ctx):
    """Wrap ``cui_spacer``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_spacer(pycui_ctx)
    return None

def gap(Context ctx, size):
    """Wrap ``cui_gap``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_gap(pycui_ctx, <float>size)
    return None

def separator(Context ctx):
    """Wrap ``cui_separator``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_separator(pycui_ctx)
    return None

def card_begin(Context ctx, *, id=None, width=None, height=None, min_width=None, max_width=None, pad=None, pad_x=None, pad_y=None, gap=None, dir=None, align=None, wrap=False, hoverable=False, muted=False, selected=False):
    """Wrap ``cui_card_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_card_opts opts
    memset(&opts, 0, sizeof(opts))
    if id is not None:
        opts.id = ctx._s(id)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_width is not None:
        opts.min_width = <float>(min_width)
    if max_width is not None:
        opts.max_width = <float>(max_width)
    if pad is not None:
        opts.pad = <float>(pad)
    if pad_x is not None:
        opts.pad_x = <float>(pad_x)
    if pad_y is not None:
        opts.pad_y = <float>(pad_y)
    if gap is not None:
        opts.gap = <float>(gap)
    if dir is not None:
        opts.dir = <int>(dir)
    if align is not None:
        opts.align = <int>(align)
    opts.wrap = <uint8_t>bool(wrap)
    opts.hoverable = <uint8_t>bool(hoverable)
    opts.muted = <uint8_t>bool(muted)
    opts.selected = <uint8_t>bool(selected)
    cdef bint pycui_result = cui_card_begin(pycui_ctx, &opts)
    return bool(pycui_result)

def card_end(Context ctx):
    """Wrap ``cui_card_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_card_end(pycui_ctx)
    return None

def scroll_begin(Context ctx, *, id=None, width=None, height=None, horizontal=False, pad=None, gap=None, fade_edges=False, fade_color=None):
    """Wrap ``cui_scroll_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_scroll_opts opts
    memset(&opts, 0, sizeof(opts))
    if id is not None:
        opts.id = ctx._s(id)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    opts.horizontal = <uint8_t>bool(horizontal)
    if pad is not None:
        opts.pad = <float>(pad)
    if gap is not None:
        opts.gap = <float>(gap)
    opts.fade_edges = <uint8_t>bool(fade_edges)
    if fade_color is not None:
        to_color(fade_color, &opts.fade_color)
    cui_scroll_begin(pycui_ctx, &opts)
    return None

def scroll_end(Context ctx):
    """Wrap ``cui_scroll_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_scroll_end(pycui_ctx)
    return None

def scroll_to(Context ctx, scroll_id, y):
    """Wrap ``cui_scroll_to``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_scroll_to(pycui_ctx, ctx._s(scroll_id), <float>y)
    return None

def text(Context ctx, text, *, font=None, size=None, color=None, align=None, nowrap=False, tabular=False, selectable=False, width=None, line_height=None, direction=None):
    """Wrap ``cui_text_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_text_opts opts
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if align is not None:
        opts.align = <int>(align)
    opts.nowrap = <uint8_t>bool(nowrap)
    opts.tabular = <uint8_t>bool(tabular)
    opts.selectable = <uint8_t>bool(selectable)
    if width is not None:
        to_size(width, &opts.width)
    if line_height is not None:
        opts.line_height = <float>(line_height)
    if direction is not None:
        opts.direction = <int>(direction)
    cui_text_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def heading(Context ctx, text, level):
    """Wrap ``cui_heading``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_heading(pycui_ctx, ctx._s(text), <int>level)
    return None

def label(Context ctx, text):
    """Wrap ``cui_label``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_label(pycui_ctx, ctx._s(text))
    return None

def secondary(Context ctx, text):
    """Wrap ``cui_secondary``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_secondary(pycui_ctx, ctx._s(text))
    return None

def muted(Context ctx, text):
    """Wrap ``cui_muted``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_muted(pycui_ctx, ctx._s(text))
    return None

def code(Context ctx, text):
    """Wrap ``cui_code``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_code(pycui_ctx, ctx._s(text))
    return None

def kbd(Context ctx, keys):
    """Wrap ``cui_kbd``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_kbd(pycui_ctx, ctx._s(keys))
    return None

def link(Context ctx, text):
    """Wrap ``cui_link``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_link(pycui_ctx, ctx._s(text))
    return bool(pycui_result)

def icon(Context ctx, icon, size, color):
    """Wrap ``cui_icon``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_color pycui_value_color
    to_color(color, &pycui_value_color)
    cui_icon(pycui_ctx, ctx._s(icon), <float>size, pycui_value_color)
    return None

def button(Context ctx, label, *, variant=None, size=None, icon=None, icon_right=None, disabled=False, loading=False, full_width=False, selected=False, tooltip=None, shortcut=None, width=None, color=None):
    """Wrap ``cui_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_button_opts opts
    memset(&opts, 0, sizeof(opts))
    if variant is not None:
        opts.variant = <int>(variant)
    if size is not None:
        opts.size = <int>(size)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if icon_right is not None:
        opts.icon_right = ctx._s(icon_right)
    opts.disabled = <uint8_t>bool(disabled)
    opts.loading = <uint8_t>bool(loading)
    opts.full_width = <uint8_t>bool(full_width)
    opts.selected = <uint8_t>bool(selected)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    if shortcut is not None:
        opts.shortcut = ctx._s(shortcut)
    if width is not None:
        to_size(width, &opts.width)
    if color is not None:
        to_color(color, &opts.color)
    cdef bint pycui_result = cui_button_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def icon_button(Context ctx, icon, *, variant=None, size=None, icon_right=None, disabled=False, loading=False, full_width=False, selected=False, tooltip=None, shortcut=None, width=None, color=None):
    """Square/round button with only an icon. Give it a tooltip so it has a name."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_button_opts opts
    memset(&opts, 0, sizeof(opts))
    if variant is not None:
        opts.variant = <int>(variant)
    if size is not None:
        opts.size = <int>(size)
    if icon_right is not None:
        opts.icon_right = ctx._s(icon_right)
    opts.disabled = <uint8_t>bool(disabled)
    opts.loading = <uint8_t>bool(loading)
    opts.full_width = <uint8_t>bool(full_width)
    opts.selected = <uint8_t>bool(selected)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    if shortcut is not None:
        opts.shortcut = ctx._s(shortcut)
    if width is not None:
        to_size(width, &opts.width)
    if color is not None:
        to_color(color, &opts.color)
    cdef bint pycui_result = cui_icon_button_ex(pycui_ctx, ctx._s(icon), &opts)
    return bool(pycui_result)

def segmented(Context ctx, id, items, index=0, *, size=None, full_width=False, icons=None):
    """Wrap ``cui_segmented_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    cdef cui_segmented_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if size is not None:
        opts.size = <int>(size)
    opts.full_width = <uint8_t>bool(full_width)
    if icons is not None:
        opts.icons = ctx._s_array_z(icons)
    cdef bint pycui_result = cui_segmented_ex(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def checkbox(Context ctx, label, value=False, *, description=None, disabled=False, indeterminate=False):
    """Wrap ``cui_checkbox_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_value = <c_bool>bool(value)
    cdef cui_check_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    opts.disabled = <uint8_t>bool(disabled)
    opts.indeterminate = <uint8_t>bool(indeterminate)
    cdef bint pycui_result = cui_checkbox_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), bool(pycui_out_value))

def switch(Context ctx, label, value=False, *, description=None, disabled=False, indeterminate=False):
    """Wrap ``cui_switch_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_value = <c_bool>bool(value)
    cdef cui_check_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    opts.disabled = <uint8_t>bool(disabled)
    opts.indeterminate = <uint8_t>bool(indeterminate)
    cdef bint pycui_result = cui_switch_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), bool(pycui_out_value))

def radio(Context ctx, label, option, value=0, *, description=None, disabled=False, indeterminate=False):
    """Wrap ``cui_radio_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_value = <int>value
    cdef cui_check_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    opts.disabled = <uint8_t>bool(disabled)
    opts.indeterminate = <uint8_t>bool(indeterminate)
    cdef bint pycui_result = cui_radio_ex(pycui_ctx, ctx._s(label), &pycui_out_value, <int>option, &opts)
    return (bool(pycui_result), int(pycui_out_value))

def radio_group(Context ctx, id, items, index=0):
    """Wrap ``cui_radio_group``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    cdef bint pycui_result = cui_radio_group(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_index)
    return (bool(pycui_result), int(pycui_out_index))

def slider(Context ctx, label, min, max, value=0.0, *, step=None, show_value=False, format=None, disabled=False, width=None):
    """Elastic slider: the track stretches like rubber when dragged past its ends."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_slider_opts opts
    memset(&opts, 0, sizeof(opts))
    if step is not None:
        opts.step = <float>(step)
    opts.show_value = <uint8_t>bool(show_value)
    if format is not None:
        opts.format = ctx._s(format)
    opts.disabled = <uint8_t>bool(disabled)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_slider_ex(pycui_ctx, ctx._s(label), &pycui_out_value, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def range_slider(Context ctx, label, min, max, lo=0.0, hi=0.0):
    """Wrap ``cui_range_slider``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_lo = <float>lo
    cdef float pycui_out_hi = <float>hi
    cdef bint pycui_result = cui_range_slider(pycui_ctx, ctx._s(label), &pycui_out_lo, &pycui_out_hi, <float>min, <float>max)
    return (bool(pycui_result), float(pycui_out_lo), float(pycui_out_hi))

def rating(Context ctx, id, max, value=0):
    """Wrap ``cui_rating``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_value = <int>value
    cdef bint pycui_result = cui_rating(pycui_ctx, ctx._s(id), &pycui_out_value, <int>max)
    return (bool(pycui_result), int(pycui_out_value))

def chip(Context ctx, label, selected=False, *, icon=None, disabled=False):
    """Wrap ``cui_chip_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_selected = <c_bool>bool(selected)
    cdef cui_chip_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    opts.disabled = <uint8_t>bool(disabled)
    cdef bint pycui_result = cui_chip_ex(pycui_ctx, ctx._s(label), &pycui_out_selected, &opts)
    return (bool(pycui_result), bool(pycui_out_selected))

def input(Context ctx, id, text='', *, label=None, placeholder=None, icon=None, hint=None, error=None, password=False, disabled=False, clearable=False, autofocus=False, read_only=False, size=None, width=None, height=None, prefix=None, suffix=None):
    """Single line text field. Returns CUI_CHANGED / CUI_SUBMITTED (Enter) flags."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_input_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_input_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if hint is not None:
        opts.hint = ctx._s(hint)
    if error is not None:
        opts.error = ctx._s(error)
    opts.password = <uint8_t>bool(password)
    opts.disabled = <uint8_t>bool(disabled)
    opts.clearable = <uint8_t>bool(clearable)
    opts.autofocus = <uint8_t>bool(autofocus)
    opts.read_only = <uint8_t>bool(read_only)
    if size is not None:
        opts.size = <int>(size)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if prefix is not None:
        opts.prefix = ctx._s(prefix)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    cdef int pycui_flags
    pycui_flags = cui_input_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_input_ex', id, 'text'), pycui_flags)

def textarea(Context ctx, id, text='', *, label=None, placeholder=None, icon=None, hint=None, error=None, password=False, disabled=False, clearable=False, autofocus=False, read_only=False, size=None, width=None, height=None, prefix=None, suffix=None):
    """Multi-line text area with word wrap."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_input_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_textarea_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if hint is not None:
        opts.hint = ctx._s(hint)
    if error is not None:
        opts.error = ctx._s(error)
    opts.password = <uint8_t>bool(password)
    opts.disabled = <uint8_t>bool(disabled)
    opts.clearable = <uint8_t>bool(clearable)
    opts.autofocus = <uint8_t>bool(autofocus)
    opts.read_only = <uint8_t>bool(read_only)
    if size is not None:
        opts.size = <int>(size)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if prefix is not None:
        opts.prefix = ctx._s(prefix)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    cdef int pycui_flags
    pycui_flags = cui_textarea_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_textarea_ex', id, 'text'), pycui_flags)

def search(Context ctx, id, text='', *, label=None, placeholder=None, icon=None, hint=None, error=None, password=False, disabled=False, clearable=False, autofocus=False, read_only=False, size=None, width=None, height=None, prefix=None, suffix=None):
    """Search field with a search icon and a clear button."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_input_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_search_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if hint is not None:
        opts.hint = ctx._s(hint)
    if error is not None:
        opts.error = ctx._s(error)
    opts.password = <uint8_t>bool(password)
    opts.disabled = <uint8_t>bool(disabled)
    opts.clearable = <uint8_t>bool(clearable)
    opts.autofocus = <uint8_t>bool(autofocus)
    opts.read_only = <uint8_t>bool(read_only)
    if size is not None:
        opts.size = <int>(size)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if prefix is not None:
        opts.prefix = ctx._s(prefix)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    cdef int pycui_flags
    pycui_flags = cui_search_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_search_ex', id, 'text'), pycui_flags)

def number(Context ctx, id, min, max, value=0.0, *, label=None, step=None, decimals=None, disabled=False, width=None, suffix=None):
    """Wrap ``cui_number_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef double pycui_out_value = <double>value
    cdef cui_number_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if step is not None:
        opts.step = <double>(step)
    if decimals is not None:
        opts.decimals = <int>(decimals)
    opts.disabled = <uint8_t>bool(disabled)
    if width is not None:
        to_size(width, &opts.width)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    cdef bint pycui_result = cui_number_ex(pycui_ctx, ctx._s(id), &pycui_out_value, <double>min, <double>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def select(Context ctx, id, items, index=0, *, label=None, placeholder=None, icons=None, searchable=False, disabled=False, width=None):
    """Wrap ``cui_select_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    cdef cui_select_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if icons is not None:
        opts.icons = ctx._s_array_z(icons)
    opts.searchable = <uint8_t>bool(searchable)
    opts.disabled = <uint8_t>bool(disabled)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_select_ex(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def date_today():
    """Wrap ``cui_date_today``."""
    cdef cui_date pycui_result = cui_date_today()
    return from_date(&pycui_result)

def calendar(Context ctx, id, value=None):
    """Wrap ``cui_calendar``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_date pycui_out_value
    to_date(value, &pycui_out_value)
    cdef bint pycui_result = cui_calendar(pycui_ctx, ctx._s(id), &pycui_out_value)
    return (bool(pycui_result), from_date(&pycui_out_value))

def date_picker(Context ctx, id, value=None, *, label=None, placeholder=None, width=None):
    """Wrap ``cui_date_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_date pycui_out_value
    cdef cui_date_opts opts
    to_date(value, &pycui_out_value)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_date_picker_ex(pycui_ctx, ctx._s(id), &pycui_out_value, &opts)
    return (bool(pycui_result), from_date(&pycui_out_value))

def color_picker(Context ctx, id, value=None):
    """Wrap ``cui_color_picker``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_color pycui_out_value
    to_color(value, &pycui_out_value)
    cdef bint pycui_result = cui_color_picker(pycui_ctx, ctx._s(id), &pycui_out_value)
    return (bool(pycui_result), from_color(&pycui_out_value))

def tabs(Context ctx, id, items, index=0, *, variant=None, icons=None, full_width=False):
    """Wrap ``cui_tabs_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    cdef cui_tabs_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if variant is not None:
        opts.variant = <int>(variant)
    if icons is not None:
        opts.icons = ctx._s_array_z(icons)
    opts.full_width = <uint8_t>bool(full_width)
    cdef bint pycui_result = cui_tabs_ex(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def nav_item(Context ctx, label, *, icon=None, badge=None, selected=False, group=None):
    """Wrap ``cui_nav_item_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_nav_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if badge is not None:
        opts.badge = ctx._s(badge)
    opts.selected = <uint8_t>bool(selected)
    if group is not None:
        opts.group = ctx._s(group)
    cdef bint pycui_result = cui_nav_item_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def nav_section(Context ctx, title):
    """Wrap ``cui_nav_section``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_nav_section(pycui_ctx, ctx._s(title))
    return None

def breadcrumb(Context ctx, items):
    """Wrap ``cui_breadcrumb``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    cdef long long pycui_result = cui_breadcrumb(pycui_ctx, pycui_ptr_items, pycui_n_items)
    return int(pycui_result)

def pagination(Context ctx, id, page_count, page=0):
    """Wrap ``cui_pagination``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_page = <int>page
    cdef bint pycui_result = cui_pagination(pycui_ctx, ctx._s(id), &pycui_out_page, <int>page_count)
    return (bool(pycui_result), int(pycui_out_page))

def stepper(Context ctx, steps, current):
    """Wrap ``cui_stepper``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_steps
    cdef int pycui_n_steps
    pycui_ptr_steps = _s_array_any(ctx, steps, &pycui_n_steps)
    cui_stepper(pycui_ctx, pycui_ptr_steps, pycui_n_steps, <int>current)
    return None

def popover_begin(Context ctx, id, *, placement=None, width=None, pad=None, gap=None):
    """Wrap ``cui_popover_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_popover_opts opts
    memset(&opts, 0, sizeof(opts))
    if placement is not None:
        opts.placement = <int>(placement)
    if width is not None:
        opts.width = <float>(width)
    if pad is not None:
        opts.pad = <float>(pad)
    if gap is not None:
        opts.gap = <float>(gap)
    cdef bint pycui_result = cui_popover_begin(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def popover_end(Context ctx):
    """Wrap ``cui_popover_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_popover_end(pycui_ctx)
    return None

def tour(Context ctx, id, steps, step=0, *, width=None, padding=None, block_target=False, next_label=None, back_label=None, done_label=None, count_format=None):
    """What happened this frame: one of CUI_TOUR_*."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_steps
    cdef int pycui_n_steps
    cdef int pycui_out_step = <int>step
    cdef cui_tour_opts opts
    pycui_ptr_steps = _pack_cui_tour_step(ctx, steps, &pycui_n_steps)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        opts.width = <float>(width)
    if padding is not None:
        opts.padding = <float>(padding)
    opts.block_target = <uint8_t>bool(block_target)
    if next_label is not None:
        opts.next_label = ctx._s(next_label)
    if back_label is not None:
        opts.back_label = ctx._s(back_label)
    if done_label is not None:
        opts.done_label = ctx._s(done_label)
    if count_format is not None:
        opts.count_format = ctx._s(count_format)
    cdef long long pycui_result = cui_tour_ex(pycui_ctx, ctx._s(id), <const cui_tour_step *>pycui_ptr_steps, pycui_n_steps, &pycui_out_step, &opts)
    return (int(pycui_result), int(pycui_out_step))

def popover_open(Context ctx, id):
    """Wrap ``cui_popover_open``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_popover_open(pycui_ctx, ctx._s(id))
    return None

def popover_close(Context ctx, id):
    """Wrap ``cui_popover_close``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_popover_close(pycui_ctx, ctx._s(id))
    return None

def popover_toggle(Context ctx, id):
    """Wrap ``cui_popover_toggle``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_popover_toggle(pycui_ctx, ctx._s(id))
    return None

def popover_is_open(Context ctx, id):
    """Wrap ``cui_popover_is_open``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_popover_is_open(pycui_ctx, ctx._s(id))
    return bool(pycui_result)

def menu_begin(Context ctx, label, *, icon=None, variant=None, placement=None, width=None, icon_only=False):
    """Wrap ``cui_menu_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_menu_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if variant is not None:
        opts.variant = <int>(variant)
    if placement is not None:
        opts.placement = <int>(placement)
    if width is not None:
        opts.width = <float>(width)
    opts.icon_only = <uint8_t>bool(icon_only)
    cdef bint pycui_result = cui_menu_begin(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def menu_end(Context ctx):
    """Wrap ``cui_menu_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_menu_end(pycui_ctx)
    return None

def context_menu_begin(Context ctx, id):
    """Context menu: opens on right click over the previous component."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_context_menu_begin(pycui_ctx, ctx._s(id))
    return bool(pycui_result)

def context_menu_end(Context ctx):
    """Wrap ``cui_context_menu_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_context_menu_end(pycui_ctx)
    return None

def menu_item(Context ctx, label, *, icon=None, shortcut=None, danger=False, disabled=False, checked=False):
    """Wrap ``cui_menu_item_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_menu_item_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if shortcut is not None:
        opts.shortcut = ctx._s(shortcut)
    opts.danger = <uint8_t>bool(danger)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checked = <uint8_t>bool(checked)
    cdef bint pycui_result = cui_menu_item_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def menu_separator(Context ctx):
    """Wrap ``cui_menu_separator``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_menu_separator(pycui_ctx)
    return None

def menu_label(Context ctx, text):
    """Wrap ``cui_menu_label``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_menu_label(pycui_ctx, ctx._s(text))
    return None

def tooltip(Context ctx, text):
    """Tooltip for the previous component, shown after a short hover delay."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_tooltip(pycui_ctx, ctx._s(text))
    return None

def dialog_begin(Context ctx, title, open=False, *, description=None, width=None, no_close_button=False, persistent=False):
    """Modal dialog. Shown while *open is true; closing sets it to false."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_dialog_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    if width is not None:
        opts.width = <float>(width)
    opts.no_close_button = <uint8_t>bool(no_close_button)
    opts.persistent = <uint8_t>bool(persistent)
    cdef bint pycui_result = cui_dialog_begin(pycui_ctx, ctx._s(title), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def dialog_end(Context ctx):
    """Wrap ``cui_dialog_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dialog_end(pycui_ctx)
    return None

def dialog_footer_begin(Context ctx):
    """A right-aligned row for dialog actions."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dialog_footer_begin(pycui_ctx)
    return None

def dialog_footer_end(Context ctx):
    """Wrap ``cui_dialog_footer_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dialog_footer_end(pycui_ctx)
    return None

def sheet_begin(Context ctx, title, open=False, *, side=None, size=None, description=None):
    """Wrap ``cui_sheet_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_sheet_opts opts
    memset(&opts, 0, sizeof(opts))
    if side is not None:
        opts.side = <int>(side)
    if size is not None:
        opts.size = <float>(size)
    if description is not None:
        opts.description = ctx._s(description)
    cdef bint pycui_result = cui_sheet_begin(pycui_ctx, ctx._s(title), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def sheet_end(Context ctx):
    """Wrap ``cui_sheet_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_sheet_end(pycui_ctx)
    return None

def toast(Context ctx, title, *, description=None, tone=None, duration=None, action=None, show_timer=False):
    """Queue a toast. Returns a handle; cui_toast_action_clicked(handle) tells whether its action button was pressed."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_toast_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    if tone is not None:
        opts.tone = <int>(tone)
    if duration is not None:
        opts.duration = <float>(duration)
    if action is not None:
        opts.action = ctx._s(action)
    opts.show_timer = <uint8_t>bool(show_timer)
    cdef long long pycui_result = cui_toast_ex(pycui_ctx, ctx._s(title), &opts)
    return int(pycui_result)

def toast_action_clicked(Context ctx, handle):
    """Wrap ``cui_toast_action_clicked``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_toast_action_clicked(pycui_ctx, <int>handle)
    return bool(pycui_result)

def toast_dismiss(Context ctx, handle):
    """Wrap ``cui_toast_dismiss``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_toast_dismiss(pycui_ctx, <int>handle)
    return None

def alert(Context ctx, title, *, description=None, tone=None, icon=None, dismissible=False):
    """Inline alert. Returns false once dismissed (when dismissible)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_alert_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    if tone is not None:
        opts.tone = <int>(tone)
    if icon is not None:
        opts.icon = ctx._s(icon)
    opts.dismissible = <uint8_t>bool(dismissible)
    cdef bint pycui_result = cui_alert_ex(pycui_ctx, ctx._s(title), &opts)
    return bool(pycui_result)

def progress(Context ctx, value, *, indeterminate=False, tone=None, height=None, label=None, show_value=False, width=None):
    """Wrap ``cui_progress_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_progress_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.indeterminate = <uint8_t>bool(indeterminate)
    if tone is not None:
        opts.tone = <int>(tone)
    if height is not None:
        opts.height = <float>(height)
    if label is not None:
        opts.label = ctx._s(label)
    opts.show_value = <uint8_t>bool(show_value)
    if width is not None:
        to_size(width, &opts.width)
    cui_progress_ex(pycui_ctx, <float>value, &opts)
    return None

def spinner(Context ctx, size):
    """Wrap ``cui_spinner``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_spinner(pycui_ctx, <float>size)
    return None

def skeleton(Context ctx, width, height):
    """Wrap ``cui_skeleton``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_size pycui_value_width
    to_size(width, &pycui_value_width)
    cui_skeleton(pycui_ctx, pycui_value_width, <float>height)
    return None

def badge(Context ctx, text, *, tone=None, dot=False, solid=False, icon=None, size=None):
    """Wrap ``cui_badge_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_badge_opts opts
    memset(&opts, 0, sizeof(opts))
    if tone is not None:
        opts.tone = <int>(tone)
    opts.dot = <uint8_t>bool(dot)
    opts.solid = <uint8_t>bool(solid)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if size is not None:
        opts.size = <int>(size)
    cui_badge_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def avatar(Context ctx, name, *, size=None, image=None, status=None, square=False):
    """Wrap ``cui_avatar_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_avatar_opts opts
    memset(&opts, 0, sizeof(opts))
    if size is not None:
        opts.size = <float>(size)
    if image is not None:
        opts.image = <uintptr_t>(image)
    if status is not None:
        opts.status = ctx._s(status)
    opts.square = <uint8_t>bool(square)
    cui_avatar_ex(pycui_ctx, ctx._s(name), &opts)
    return None

def avatar_group(Context ctx, names, max_visible, size):
    """Wrap ``cui_avatar_group``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_names
    cdef int pycui_n_names
    pycui_ptr_names = _s_array_any(ctx, names, &pycui_n_names)
    cui_avatar_group(pycui_ctx, pycui_ptr_names, pycui_n_names, <int>max_visible, <float>size)
    return None

def empty_state(Context ctx, title, *, icon=None, description=None, action=None):
    """Empty state. Returns true when its action button is clicked."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_empty_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if description is not None:
        opts.description = ctx._s(description)
    if action is not None:
        opts.action = ctx._s(action)
    cdef bint pycui_result = cui_empty_state_ex(pycui_ctx, ctx._s(title), &opts)
    return bool(pycui_result)

def metric(Context ctx, label, value, *, delta=None, delta_label=None, spark=None, spark_count=None, icon=None, width=None, lower_is_better=False):
    """Wrap ``cui_metric_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_metric_opts opts
    memset(&opts, 0, sizeof(opts))
    if delta is not None:
        opts.delta = <float>(delta)
    if delta_label is not None:
        opts.delta_label = ctx._s(delta_label)
    if spark_count is not None:
        opts.spark_count = <int>(spark_count)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if width is not None:
        to_size(width, &opts.width)
    opts.lower_is_better = <uint8_t>bool(lower_is_better)
    cui_metric_ex(pycui_ctx, ctx._s(label), ctx._s(value), &opts)
    return None

def meter(Context ctx, label, used, total, unit):
    """Wrap ``cui_meter``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_meter(pycui_ctx, ctx._s(label), <float>used, <float>total, ctx._s(unit))
    return None

def accordion_begin(Context ctx, title, open=False):
    """Accordion / disclosure. Content animates its height."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef bint pycui_result = cui_accordion_begin(pycui_ctx, ctx._s(title), &pycui_out_open)
    return (bool(pycui_result), bool(pycui_out_open))

def accordion_end(Context ctx):
    """Wrap ``cui_accordion_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_accordion_end(pycui_ctx)
    return None

def tree_begin(Context ctx, label, open=False, *, icon=None, leaf=False, selected=False):
    """Wrap ``cui_tree_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_tree_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    opts.leaf = <uint8_t>bool(leaf)
    opts.selected = <uint8_t>bool(selected)
    cdef bint pycui_result = cui_tree_begin(pycui_ctx, ctx._s(label), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def tree_end(Context ctx):
    """Wrap ``cui_tree_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_tree_end(pycui_ctx)
    return None

def tree_clicked(Context ctx):
    """Wrap ``cui_tree_clicked``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_tree_clicked(pycui_ctx)
    return bool(pycui_result)

def list_item(Context ctx, title, *, icon=None, subtitle=None, trailing=None, selected=False, avatar=None):
    """Wrap ``cui_list_item_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_list_item_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if subtitle is not None:
        opts.subtitle = ctx._s(subtitle)
    if trailing is not None:
        opts.trailing = ctx._s(trailing)
    opts.selected = <uint8_t>bool(selected)
    if avatar is not None:
        opts.avatar = ctx._s(avatar)
    cdef bint pycui_result = cui_list_item_ex(pycui_ctx, ctx._s(title), &opts)
    return bool(pycui_result)

def virtual_list_begin(Context ctx, id, count, row_height, height, first=0, last=0):
    """Virtual list: only the visible rows are built, so lists with a million rows stay fast. Fills first/last with the visible range."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_size pycui_value_height
    cdef int pycui_out_first = <int>first
    cdef int pycui_out_last = <int>last
    to_size(height, &pycui_value_height)
    cui_virtual_list_begin(pycui_ctx, ctx._s(id), <int>count, <float>row_height, pycui_value_height, &pycui_out_first, &pycui_out_last)
    return int(pycui_out_first), int(pycui_out_last)

def virtual_list_end(Context ctx):
    """Wrap ``cui_virtual_list_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_virtual_list_end(pycui_ctx)
    return None

def table_begin(Context ctx, id, columns, *, sort=None, height=None, striped=False, compact=False, selectable=False):
    """Wrap ``cui_table_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_columns
    cdef int pycui_n_columns
    cdef cui_table_opts opts
    pycui_ptr_columns = _pack_cui_table_column(ctx, columns, &pycui_n_columns)
    memset(&opts, 0, sizeof(opts))
    if height is not None:
        to_size(height, &opts.height)
    opts.striped = <uint8_t>bool(striped)
    opts.compact = <uint8_t>bool(compact)
    opts.selectable = <uint8_t>bool(selectable)
    cdef bint pycui_result = cui_table_begin_ex(pycui_ctx, ctx._s(id), <const cui_table_column *>pycui_ptr_columns, pycui_n_columns, &opts)
    return bool(pycui_result)

def table_row(Context ctx, selected):
    """Begin a row. Returns true when the row is clicked."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_table_row(pycui_ctx, <uint8_t>bool(selected))
    return bool(pycui_result)

def table_cell(Context ctx):
    """Next cell; put any components inside, or use cui_table_cell_text."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_table_cell(pycui_ctx)
    return None

def table_cell_text(Context ctx, text):
    """Wrap ``cui_table_cell_text``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_table_cell_text(pycui_ctx, ctx._s(text))
    return None

def table_end(Context ctx):
    """Wrap ``cui_table_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_table_end(pycui_ctx)
    return None

def sparkline(Context ctx, values, width, height, color):
    """Wrap ``cui_sparkline``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const float *pycui_ptr_values
    cdef int pycui_n_values
    cdef cui_size pycui_value_width
    cdef cui_color pycui_value_color
    pycui_ptr_values = ctx._c_float_array(values, &pycui_n_values)
    to_size(width, &pycui_value_width)
    to_color(color, &pycui_value_color)
    cui_sparkline(pycui_ctx, pycui_ptr_values, pycui_n_values, pycui_value_width, <float>height, pycui_value_color)
    return None

def gauge(Context ctx, label, value, size):
    """Wrap ``cui_gauge``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_gauge(pycui_ctx, ctx._s(label), <float>value, <float>size)
    return None

def image_create(Context ctx, w, h, rgba):
    """Images"""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const void *pycui_ptr_rgba
    cdef size_t pycui_size_rgba
    pycui_ptr_rgba = ctx._c_bytes(rgba, &pycui_size_rgba)
    cdef long long pycui_result = cui_image_create(pycui_ctx, <int>w, <int>h, pycui_ptr_rgba)
    return int(pycui_result)

def image_load(Context ctx, path, w=0, h=0):
    """Wrap ``cui_image_load``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_w = <int>w
    cdef int pycui_out_h = <int>h
    cdef long long pycui_result = cui_image_load(pycui_ctx, ctx._s(path), &pycui_out_w, &pycui_out_h)
    return (int(pycui_result), int(pycui_out_w), int(pycui_out_h))

def image_destroy(Context ctx, tex):
    """Wrap ``cui_image_destroy``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_image_destroy(pycui_ctx, <uintptr_t>tex)
    return None

def image(Context ctx, tex, *, width=None, height=None, radius=None, tint=None):
    """Wrap ``cui_image_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_image_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if radius is not None:
        opts.radius = <float>(radius)
    if tint is not None:
        to_color(tint, &opts.tint)
    cui_image_ex(pycui_ctx, <uintptr_t>tex, &opts)
    return None

def image_viewer(Context ctx, id, tex, image_w, image_h, view, *, width=None, height=None, max_zoom=None, no_toolbar=False, checkerboard=False):
    """Returns true when the view changed."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_image_view *pycui_ptr_view
    cdef cui_image_viewer_opts opts
    if view is None:
        raise TypeError("this function needs a cui.ImageView handle")
    pycui_ptr_view = <cui_image_view *>(<ImageView>view)._mem
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if max_zoom is not None:
        opts.max_zoom = <float>(max_zoom)
    opts.no_toolbar = <uint8_t>bool(no_toolbar)
    opts.checkerboard = <uint8_t>bool(checkerboard)
    cdef bint pycui_result = cui_image_viewer_ex(pycui_ctx, ctx._s(id), <uintptr_t>tex, <int>image_w, <int>image_h, pycui_ptr_view, &opts)
    return bool(pycui_result)

def cropper(Context ctx, id, tex, image_w, image_h, crop=None, *, width=None, height=None, aspect=None, round=False, min_size=None):
    """Returns true when the crop changed."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_out_crop
    cdef cui_cropper_opts opts
    to_rect(crop, &pycui_out_crop)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if aspect is not None:
        opts.aspect = <float>(aspect)
    opts.round = <uint8_t>bool(round)
    if min_size is not None:
        opts.min_size = <float>(min_size)
    cdef bint pycui_result = cui_cropper_ex(pycui_ctx, ctx._s(id), <uintptr_t>tex, <int>image_w, <int>image_h, &pycui_out_crop, &opts)
    return (bool(pycui_result), from_rect(&pycui_out_crop))

def command_palette(Context ctx, commands, open=False):
    """Spotlight style command palette. Returns the index of the chosen command, or -1. Open it with a shortcut: if (cui_shortcut(ui, CUI_MOD_PRIMARY, CUI_KEY_K)) open = true;"""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef void *pycui_ptr_commands
    cdef int pycui_n_commands
    pycui_ptr_commands = _pack_cui_command(ctx, commands, &pycui_n_commands)
    cdef long long pycui_result = cui_command_palette(pycui_ctx, &pycui_out_open, <const cui_command *>pycui_ptr_commands, pycui_n_commands)
    return (int(pycui_result), bool(pycui_out_open))

def radio_cards(Context ctx, id, choices, index=0, *, columns=None):
    """Wrap ``cui_radio_cards_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_choices
    cdef int pycui_n_choices
    cdef int pycui_out_index = <int>index
    cdef cui_radio_cards_opts opts
    pycui_ptr_choices = _pack_cui_choice(ctx, choices, &pycui_n_choices)
    memset(&opts, 0, sizeof(opts))
    if columns is not None:
        opts.columns = <int>(columns)
    cdef bint pycui_result = cui_radio_cards_ex(pycui_ctx, ctx._s(id), <const cui_choice *>pycui_ptr_choices, pycui_n_choices, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def tag_input(Context ctx, id, text='', *, label=None, placeholder=None, max_tags=None, width=None):
    """Wrap ``cui_tag_input_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_tag_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_tag_input_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if max_tags is not None:
        opts.max_tags = <int>(max_tags)
    if width is not None:
        to_size(width, &opts.width)
    cdef int pycui_flags
    pycui_flags = cui_tag_input_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_tag_input_ex', id, 'text'), pycui_flags)

def otp_input(Context ctx, id, code, length):
    """One time code input: `length` boxes; code must hold length + 1 bytes. Returns true when all boxes are filled (once per change)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_otp_input(pycui_ctx, ctx._s(id), ctx._s(code), <int>length)
    return bool(pycui_result)

def button_group_begin(Context ctx):
    """Connected buttons. Put buttons between begin and end."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_button_group_begin(pycui_ctx)
    return None

def button_group_end(Context ctx):
    """Wrap ``cui_button_group_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_button_group_end(pycui_ctx)
    return None

def copy_button(Context ctx, id, text):
    """Icon button that copies text to the clipboard and confirms with a check. Keyboard focus stays on the button when the check appears or disappears."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_copy_button(pycui_ctx, ctx._s(id), ctx._s(text))
    return bool(pycui_result)

def hold_button(Context ctx, label, *, duration=None, icon=None, variant=None):
    """Wrap ``cui_hold_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_hold_opts opts
    memset(&opts, 0, sizeof(opts))
    if duration is not None:
        opts.duration = <float>(duration)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if variant is not None:
        opts.variant = <int>(variant)
    cdef bint pycui_result = cui_hold_button_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def password_strength(Context ctx, password):
    """Password strength meter (0 weak .. 4 strong). Returns the score."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_password_strength(pycui_ctx, ctx._s(password))
    return int(pycui_result)

def timeline_item(Context ctx, title, *, time=None, description=None, icon=None, tone=None, last=False):
    """Wrap ``cui_timeline_item_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_timeline_opts opts
    memset(&opts, 0, sizeof(opts))
    if time is not None:
        opts.time = ctx._s(time)
    if description is not None:
        opts.description = ctx._s(description)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if tone is not None:
        opts.tone = <int>(tone)
    opts.last = <uint8_t>bool(last)
    cui_timeline_item_ex(pycui_ctx, ctx._s(title), &opts)
    return None

def reorder_begin(Context ctx, id, count, order=0):
    """Reorderable list: drag rows to reorder. `order` holds your item indices in display order and is rewritten when a row is dropped. Build the rows in display order: for (i...) cui_reorder_item(ui, i) { draw item order[i] }. Returns true on the frame the order changes."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_order = <int>order
    cui_reorder_begin(pycui_ctx, ctx._s(id), &pycui_out_order, <int>count)
    return int(pycui_out_order)

def reorder_end(Context ctx):
    """Wrap ``cui_reorder_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_reorder_end(pycui_ctx)
    return bool(pycui_result)

def reorder_item_begin(Context ctx, position):
    """Wrap ``cui_reorder_item_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_reorder_item_begin(pycui_ctx, <int>position)
    return None

def reorder_item_end(Context ctx):
    """Wrap ``cui_reorder_item_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_reorder_item_end(pycui_ctx)
    return None

def progress_ring(Context ctx, label, value, size):
    """Circular progress with the value in the middle."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_progress_ring(pycui_ctx, ctx._s(label), <float>value, <float>size)
    return None

def split_button(Context ctx, label, items, *, variant=None, size=None, icon=None, item_icons=None, disabled=False):
    """Wrap ``cui_split_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_split_button_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if variant is not None:
        opts.variant = <int>(variant)
    if size is not None:
        opts.size = <int>(size)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if item_icons is not None:
        opts.item_icons = ctx._s_array_z(item_icons)
    opts.disabled = <uint8_t>bool(disabled)
    cdef long long pycui_result = cui_split_button_ex(pycui_ctx, ctx._s(label), pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def toggle_group(Context ctx, id, labels, values=False, *, icons=None, exclusive=False, icon_only=False, size=None):
    """Wrap ``cui_toggle_group_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_labels
    cdef int pycui_n_labels
    cdef c_bool pycui_out_values = <c_bool>bool(values)
    cdef cui_toggle_group_opts opts
    pycui_ptr_labels = _s_array_any(ctx, labels, &pycui_n_labels)
    memset(&opts, 0, sizeof(opts))
    if icons is not None:
        opts.icons = ctx._s_array_z(icons)
    opts.exclusive = <uint8_t>bool(exclusive)
    opts.icon_only = <uint8_t>bool(icon_only)
    if size is not None:
        opts.size = <int>(size)
    cdef bint pycui_result = cui_toggle_group_ex(pycui_ctx, ctx._s(id), pycui_ptr_labels, pycui_n_labels, &pycui_out_values, &opts)
    return (bool(pycui_result), bool(pycui_out_values))

def confirm_button(Context ctx, label, *, confirm_label=None, icon=None, variant=None, size=None, timeout=None):
    """Wrap ``cui_confirm_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_confirm_opts opts
    memset(&opts, 0, sizeof(opts))
    if confirm_label is not None:
        opts.confirm_label = ctx._s(confirm_label)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if variant is not None:
        opts.variant = <int>(variant)
    if size is not None:
        opts.size = <int>(size)
    if timeout is not None:
        opts.timeout = <float>(timeout)
    cdef bint pycui_result = cui_confirm_button_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def status_button(Context ctx, label, status, *, busy_label=None, success_label=None, error_label=None, icon=None, variant=None, size=None):
    """Wrap ``cui_status_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_status_button_opts opts
    memset(&opts, 0, sizeof(opts))
    if busy_label is not None:
        opts.busy_label = ctx._s(busy_label)
    if success_label is not None:
        opts.success_label = ctx._s(success_label)
    if error_label is not None:
        opts.error_label = ctx._s(error_label)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if variant is not None:
        opts.variant = <int>(variant)
    if size is not None:
        opts.size = <int>(size)
    cdef bint pycui_result = cui_status_button_ex(pycui_ctx, ctx._s(label), <int>status, &opts)
    return bool(pycui_result)

def speed_dial(Context ctx, id, actions, *, icon=None, placement=None, tooltip=None):
    """Wrap ``cui_speed_dial_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_actions
    cdef int pycui_n_actions
    cdef cui_speed_dial_opts opts
    pycui_ptr_actions = _pack_cui_speed_action(ctx, actions, &pycui_n_actions)
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if placement is not None:
        opts.placement = <int>(placement)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    cdef long long pycui_result = cui_speed_dial_ex(pycui_ctx, ctx._s(id), <const cui_speed_action *>pycui_ptr_actions, pycui_n_actions, &opts)
    return int(pycui_result)

def theme_switcher(Context ctx, with_system, mode=0):
    """Theme switcher: light, dark and (optionally) system, as a compact icon segmented control. mode is 0 light, 1 dark, 2 system. Light and dark are applied for you; for system call cui_set_theme with the OS setting. Returns true when mode changed."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_mode = <int>mode
    cdef bint pycui_result = cui_theme_switcher(pycui_ctx, &pycui_out_mode, <uint8_t>bool(with_system))
    return (bool(pycui_result), int(pycui_out_mode))

def theme_toggle(Context ctx):
    """Sun and moon icon button that toggles the theme with a morph."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_theme_toggle(pycui_ctx)
    return bool(pycui_result)

def user_menu_begin(Context ctx, name, *, detail=None, status=None, avatar=None, compact=False, placement=None, width=None):
    """Wrap ``cui_user_menu_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_user_menu_opts opts
    memset(&opts, 0, sizeof(opts))
    if detail is not None:
        opts.detail = ctx._s(detail)
    if status is not None:
        opts.status = ctx._s(status)
    if avatar is not None:
        opts.avatar = <uintptr_t>(avatar)
    opts.compact = <uint8_t>bool(compact)
    if placement is not None:
        opts.placement = <int>(placement)
    if width is not None:
        opts.width = <float>(width)
    cdef bint pycui_result = cui_user_menu_begin(pycui_ctx, ctx._s(name), &opts)
    return bool(pycui_result)

def user_menu_end(Context ctx):
    """Wrap ``cui_user_menu_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_user_menu_end(pycui_ctx)
    return None

def swipe_item_begin(Context ctx, id, left, right):
    """Wrap ``cui_swipe_item_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_left
    cdef int pycui_n_left
    cdef void *pycui_ptr_right
    cdef int pycui_n_right
    pycui_ptr_left = _pack_cui_swipe_action(ctx, left, &pycui_n_left)
    pycui_ptr_right = _pack_cui_swipe_action(ctx, right, &pycui_n_right)
    cui_swipe_item_begin(pycui_ctx, ctx._s(id), <const cui_swipe_action *>pycui_ptr_left, pycui_n_left, <const cui_swipe_action *>pycui_ptr_right, pycui_n_right)
    return None

def swipe_item_end(Context ctx):
    """Wrap ``cui_swipe_item_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_swipe_item_end(pycui_ctx)
    return int(pycui_result)

def data_grid_begin(Context ctx, id, columns, row_count, first=0, last=0, *, width=None, height=None, row_height=None, selected=None, sort=None, striped=False, cursor=None, hide_checkboxes=False, anchor=None):
    """Wrap ``cui_data_grid_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_columns
    cdef int pycui_n_columns
    cdef int pycui_out_first = <int>first
    cdef int pycui_out_last = <int>last
    cdef cui_grid_opts opts
    pycui_ptr_columns = _pack_cui_grid_column(ctx, columns, &pycui_n_columns)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if row_height is not None:
        opts.row_height = <float>(row_height)
    opts.striped = <uint8_t>bool(striped)
    opts.hide_checkboxes = <uint8_t>bool(hide_checkboxes)
    cdef bint pycui_result = cui_data_grid_begin_ex(pycui_ctx, ctx._s(id), <const cui_grid_column *>pycui_ptr_columns, pycui_n_columns, <int>row_count, &pycui_out_first, &pycui_out_last, &opts)
    return (bool(pycui_result), int(pycui_out_first), int(pycui_out_last))

def data_grid_row(Context ctx, row):
    """Wrap ``cui_data_grid_row``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_data_grid_row(pycui_ctx, <int>row)
    return bool(pycui_result)

def data_grid_cell(Context ctx):
    """Wrap ``cui_data_grid_cell``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_data_grid_cell(pycui_ctx)
    return None

def data_grid_cell_text(Context ctx, text):
    """Wrap ``cui_data_grid_cell_text``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_data_grid_cell_text(pycui_ctx, ctx._s(text))
    return None

def data_grid_cell_edit(Context ctx, text=''):
    """Editable text cell: double click (or Enter on the cursor row) to edit, Enter or clicking away commits, Esc reverts. True when committed."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    pycui_buf_buf = ctx._text_buffer(('cui_data_grid_cell_edit', 'text'), text, &pycui_cap_buf)
    cdef int pycui_flags
    pycui_flags = cui_data_grid_cell_edit(pycui_ctx, pycui_buf_buf, pycui_cap_buf)
    return ctx._text_result(('cui_data_grid_cell_edit', 'text'), pycui_flags)

def data_grid_edit(Context ctx, text=''):
    """The same editable text, inside the current cell (after an avatar, say)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    pycui_buf_buf = ctx._text_buffer(('cui_data_grid_edit', 'text'), text, &pycui_cap_buf)
    cdef int pycui_flags
    pycui_flags = cui_data_grid_edit(pycui_ctx, pycui_buf_buf, pycui_cap_buf)
    return ctx._text_result(('cui_data_grid_edit', 'text'), pycui_flags)

def data_grid_end(Context ctx):
    """Wrap ``cui_data_grid_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_data_grid_end(pycui_ctx)
    return None

def tree_cell(Context ctx, label, depth, has_children, icon, open=False):
    """Tree cell: indentation, a disclosure chevron and a label, for tree tables (use it in a table or grid cell). Returns true when *open toggled."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef bint pycui_result = cui_tree_cell(pycui_ctx, ctx._s(label), <int>depth, <uint8_t>bool(has_children), &pycui_out_open, ctx._s(icon))
    return (bool(pycui_result), bool(pycui_out_open))

def tree_table_row(Context ctx):
    """The next row in view: returns its node, or -1 when done. Then build its cells: cui_tree_table_name first, then cui_data_grid_cell(_text)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_tree_table_row(pycui_ctx)
    return int(pycui_result)

def tree_table_name(Context ctx, label, icon):
    """The first cell: indentation, guides, the chevron, an icon and the name (cut short with a tooltip of the whole name when it does not fit)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_tree_table_name(pycui_ctx, ctx._s(label), ctx._s(icon))
    return None

def tree_table_depth(Context ctx):
    """Wrap ``cui_tree_table_depth``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_tree_table_depth(pycui_ctx)
    return int(pycui_result)

def path_bar_menu_begin(Context ctx, id, segment=0):
    """True while the menu of separator *segment is showing: build menu items for the children of that segment, then call cui_path_bar_menu_end."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_segment = <int>segment
    cdef bint pycui_result = cui_path_bar_menu_begin(pycui_ctx, ctx._s(id), &pycui_out_segment)
    return (bool(pycui_result), int(pycui_out_segment))

def path_bar_menu_end(Context ctx):
    """Wrap ``cui_path_bar_menu_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_path_bar_menu_end(pycui_ctx)
    return None

def file_picker(Context ctx, id, open=False, out='', *, title=None, save=False, folders=False, start=None, name=None, filter=None, filter_label=None, list=None, list_user=None):
    """True once, with the chosen path in out, when the dialog is confirmed; *open turns false then, or on Cancel and Esc."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef char *pycui_buf_out
    cdef size_t pycui_cap_out
    cdef cui_file_picker_opts opts
    pycui_buf_out = ctx._text_buffer(('cui_file_picker_ex', id, 'out'), out, &pycui_cap_out)
    memset(&opts, 0, sizeof(opts))
    if title is not None:
        opts.title = ctx._s(title)
    opts.save = <uint8_t>bool(save)
    opts.folders = <uint8_t>bool(folders)
    if start is not None:
        opts.start = ctx._s(start)
    if name is not None:
        opts.name = ctx._s(name)
    if filter is not None:
        opts.filter = ctx._s(filter)
    if filter_label is not None:
        opts.filter_label = ctx._s(filter_label)
    cdef int pycui_flags
    pycui_flags = cui_file_picker_ex(pycui_ctx, ctx._s(id), &pycui_out_open, pycui_buf_out, pycui_cap_out, &opts)
    return ctx._text_result(('cui_file_picker_ex', id, 'out'), pycui_flags)

def code_block(Context ctx, id, code, *, lang=None, title=None, line_numbers=False, highlight_from=None, highlight_to=None, max_height=None, size=None, no_header=False):
    """Wrap ``cui_code_block_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_code_opts opts
    memset(&opts, 0, sizeof(opts))
    if lang is not None:
        opts.lang = ctx._s(lang)
    if title is not None:
        opts.title = ctx._s(title)
    opts.line_numbers = <uint8_t>bool(line_numbers)
    if highlight_from is not None:
        opts.highlight_from = <int>(highlight_from)
    if highlight_to is not None:
        opts.highlight_to = <int>(highlight_to)
    if max_height is not None:
        opts.max_height = <float>(max_height)
    if size is not None:
        opts.size = <float>(size)
    opts.no_header = <uint8_t>bool(no_header)
    cui_code_block_ex(pycui_ctx, ctx._s(id), ctx._s(code), &opts)
    return None

def json_view(Context ctx, id, json, *, expand_depth=None, max_height=None):
    """Wrap ``cui_json_view_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_json_opts opts
    memset(&opts, 0, sizeof(opts))
    if expand_depth is not None:
        opts.expand_depth = <int>(expand_depth)
    if max_height is not None:
        opts.max_height = <float>(max_height)
    cdef bint pycui_result = cui_json_view_ex(pycui_ctx, ctx._s(id), ctx._s(json), &opts)
    return bool(pycui_result)

def markdown_apply_task(text, result):
    """Writes a reported task toggle into text ('x' or ' ' between the brackets). Returns false when nothing was toggled or text no longer has a box there."""
    cdef bytes pycui_bytes_text = _utf8(text)
    cdef void *pycui_ptr_result
    cdef int pycui_n_result
    pycui_ptr_result = _pack_cui_markdown_result(None, result, &pycui_n_result)
    cdef bint pycui_result = cui_markdown_apply_task(<const char *>pycui_bytes_text, <const cui_markdown_result *>pycui_ptr_result)
    return bool(pycui_result)

def code_editor_goto(Context ctx, id, line, column):
    """On the editor's next frame: put the caret at a line and column (1 based), focus the editor and scroll there. Call from the same id scope."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_code_editor_goto(pycui_ctx, ctx._s(id), <int>line, <int>column)
    return None

def code_editor_select(Context ctx, id, anchor, cursor):
    """On the next frame: select bytes anchor..cursor, focus and scroll there."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_code_editor_select(pycui_ctx, ctx._s(id), <int>anchor, <int>cursor)
    return None

def code_editor_find(Context ctx, id, query):
    """Opens the find bar with query and selects the next match (NULL closes)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_code_editor_find(pycui_ctx, ctx._s(id), ctx._s(query))
    return None

def diff_view_rows(Context ctx, id, rows, first, cap):
    """Wrap ``cui_diff_view_rows``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_diff_row *pycui_ptr_rows
    if rows is None:
        raise TypeError("this function needs a cui.DiffRow handle")
    pycui_ptr_rows = <cui_diff_row *>(<DiffRow>rows)._mem
    cdef long long pycui_result = cui_diff_view_rows(pycui_ctx, ctx._s(id), pycui_ptr_rows, <int>first, <int>cap)
    return int(pycui_result)

def diff_words(old_line, old_len, new_line, new_len, old_ranges, new_ranges, cap, old_count=0, new_count=0):
    """Wrap ``cui_diff_words``."""
    cdef bytes pycui_bytes_old_line = _utf8(old_line)
    cdef bytes pycui_bytes_new_line = _utf8(new_line)
    cdef cui_diff_range *pycui_ptr_old_ranges
    cdef int pycui_out_old_count = <int>old_count
    cdef cui_diff_range *pycui_ptr_new_ranges
    cdef int pycui_out_new_count = <int>new_count
    if old_ranges is None:
        raise TypeError("this function needs a cui.DiffRange handle")
    pycui_ptr_old_ranges = <cui_diff_range *>(<DiffRange>old_ranges)._mem
    if new_ranges is None:
        raise TypeError("this function needs a cui.DiffRange handle")
    pycui_ptr_new_ranges = <cui_diff_range *>(<DiffRange>new_ranges)._mem
    cdef bint pycui_result = cui_diff_words(<const char *>pycui_bytes_old_line, <int>old_len, <const char *>pycui_bytes_new_line, <int>new_len, pycui_ptr_old_ranges, &pycui_out_old_count, pycui_ptr_new_ranges, &pycui_out_new_count, <int>cap)
    return (bool(pycui_result), int(pycui_out_old_count), int(pycui_out_new_count))

def chat_message(Context ctx, text, *, mine=False, author=None, time=None, status=None, grouped=False, last_in_group=False, avatar=None, markdown=False, markdown_result=None):
    """Wrap ``cui_chat_message_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_chat_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.mine = <uint8_t>bool(mine)
    if author is not None:
        opts.author = ctx._s(author)
    if time is not None:
        opts.time = ctx._s(time)
    if status is not None:
        opts.status = ctx._s(status)
    opts.grouped = <uint8_t>bool(grouped)
    opts.last_in_group = <uint8_t>bool(last_in_group)
    if avatar is not None:
        opts.avatar = <uintptr_t>(avatar)
    opts.markdown = <uint8_t>bool(markdown)
    cui_chat_message_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def chat_divider(Context ctx, label):
    """Wrap ``cui_chat_divider``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_chat_divider(pycui_ctx, ctx._s(label))
    return None

def typing_indicator(Context ctx, name):
    """Wrap ``cui_typing_indicator``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_typing_indicator(pycui_ctx, ctx._s(name))
    return None

def comment(Context ctx, id, author, text, *, time=None, depth=None, likes=None, liked=None, edited=False, badge=None):
    """Wrap ``cui_comment_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_comment_opts opts
    memset(&opts, 0, sizeof(opts))
    if time is not None:
        opts.time = ctx._s(time)
    if depth is not None:
        opts.depth = <int>(depth)
    opts.edited = <uint8_t>bool(edited)
    if badge is not None:
        opts.badge = ctx._s(badge)
    cdef long long pycui_result = cui_comment_ex(pycui_ctx, ctx._s(id), ctx._s(author), ctx._s(text), &opts)
    return int(pycui_result)

def presence(Context ctx, id, users, max_visible, size):
    """Wrap ``cui_presence``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_users
    cdef int pycui_n_users
    pycui_ptr_users = _pack_cui_presence_user(ctx, users, &pycui_n_users)
    cui_presence(pycui_ctx, ctx._s(id), <const cui_presence_user *>pycui_ptr_users, pycui_n_users, <int>max_visible, <float>size)
    return None

def carousel_begin(Context ctx, id, count, index=0, *, height=None, auto_advance=None, gap=None, no_arrows=False, no_dots=False, loop=False):
    """Wrap ``cui_carousel_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_index = <int>index
    cdef cui_carousel_opts opts
    memset(&opts, 0, sizeof(opts))
    if height is not None:
        opts.height = <float>(height)
    if auto_advance is not None:
        opts.auto_advance = <float>(auto_advance)
    if gap is not None:
        opts.gap = <float>(gap)
    opts.no_arrows = <uint8_t>bool(no_arrows)
    opts.no_dots = <uint8_t>bool(no_dots)
    opts.loop = <uint8_t>bool(loop)
    cdef bint pycui_result = cui_carousel_begin(pycui_ctx, ctx._s(id), <int>count, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def carousel_slide_begin(Context ctx):
    """Wrap ``cui_carousel_slide_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_carousel_slide_begin(pycui_ctx)
    return None

def carousel_slide_end(Context ctx):
    """Wrap ``cui_carousel_slide_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_carousel_slide_end(pycui_ctx)
    return None

def carousel_end(Context ctx):
    """Wrap ``cui_carousel_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_carousel_end(pycui_ctx)
    return None

def image_compare(Context ctx, id, before, after, pos=0.0, *, width=None, height=None, before_label=None, after_label=None, aspect=None):
    """Wrap ``cui_image_compare_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_pos = <float>pos
    cdef cui_compare_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if before_label is not None:
        opts.before_label = ctx._s(before_label)
    if after_label is not None:
        opts.after_label = ctx._s(after_label)
    if aspect is not None:
        opts.aspect = <float>(aspect)
    cdef bint pycui_result = cui_image_compare_ex(pycui_ctx, ctx._s(id), <uintptr_t>before, <uintptr_t>after, &pycui_out_pos, &opts)
    return (bool(pycui_result), float(pycui_out_pos))

def card_stack_begin(Context ctx, id, count, *, width=None, height=None, visible=None):
    """Wrap ``cui_card_stack_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_card_stack_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if visible is not None:
        opts.visible = <int>(visible)
    cui_card_stack_begin(pycui_ctx, ctx._s(id), <int>count, &opts)
    return None

def card_stack_item_begin(Context ctx, depth):
    """Wrap ``cui_card_stack_item_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_card_stack_item_begin(pycui_ctx, <int>depth)
    return None

def card_stack_item_end(Context ctx):
    """Wrap ``cui_card_stack_item_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_card_stack_item_end(pycui_ctx)
    return None

def card_stack_end(Context ctx):
    """Wrap ``cui_card_stack_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef long long pycui_result = cui_card_stack_end(pycui_ctx)
    return int(pycui_result)

def counter(Context ctx, id, value, *, format=None, size=None, font=None, color=None, group_thousands=False):
    """Wrap ``cui_counter_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_counter_opts opts
    memset(&opts, 0, sizeof(opts))
    if format is not None:
        opts.format = ctx._s(format)
    if size is not None:
        opts.size = <float>(size)
    if font is not None:
        opts.font = <int>(font)
    if color is not None:
        to_color(color, &opts.color)
    opts.group_thousands = <uint8_t>bool(group_thousands)
    cui_counter_ex(pycui_ctx, ctx._s(id), <double>value, &opts)
    return None

def ticker(Context ctx, id, items, *, speed=None, height=None):
    """Wrap ``cui_ticker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_ticker_opts opts
    pycui_ptr_items = _pack_cui_ticker_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if speed is not None:
        opts.speed = <float>(speed)
    if height is not None:
        opts.height = <float>(height)
    cui_ticker_ex(pycui_ctx, ctx._s(id), <const cui_ticker_item *>pycui_ptr_items, pycui_n_items, &opts)
    return None

def heatmap(Context ctx, id, rows, cols, values=0.0, *, row_labels=None, col_labels=None, cell=None, min=None, max=None, color=None, format=None, width=None):
    """Wrap ``cui_heatmap_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_values = <float>values
    cdef cui_heatmap_opts opts
    memset(&opts, 0, sizeof(opts))
    if row_labels is not None:
        opts.row_labels = ctx._s_array_z(row_labels)
    if col_labels is not None:
        opts.col_labels = ctx._s_array_z(col_labels)
    if cell is not None:
        opts.cell = <float>(cell)
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if color is not None:
        to_color(color, &opts.color)
    if format is not None:
        opts.format = ctx._s(format)
    if width is not None:
        to_size(width, &opts.width)
    cdef long long pycui_result = cui_heatmap_ex(pycui_ctx, ctx._s(id), &pycui_out_values, <int>rows, <int>cols, &opts)
    return (int(pycui_result), float(pycui_out_values))

def calendar_heatmap(Context ctx, id, start, days, values=0.0, *, cell=None, color=None, format=None, unit=None):
    """Wrap ``cui_calendar_heatmap_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_date pycui_value_start
    cdef float pycui_out_values = <float>values
    cdef cui_calendar_heatmap_opts opts
    to_date(start, &pycui_value_start)
    memset(&opts, 0, sizeof(opts))
    if cell is not None:
        opts.cell = <float>(cell)
    if color is not None:
        to_color(color, &opts.color)
    if format is not None:
        opts.format = ctx._s(format)
    if unit is not None:
        opts.unit = ctx._s(unit)
    cdef long long pycui_result = cui_calendar_heatmap_ex(pycui_ctx, ctx._s(id), pycui_value_start, &pycui_out_values, <int>days, &opts)
    return (int(pycui_result), float(pycui_out_values))

def treemap(Context ctx, id, items, *, width=None, height=None, format=None):
    """Wrap ``cui_treemap_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_treemap_opts opts
    pycui_ptr_items = _pack_cui_viz_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if format is not None:
        opts.format = ctx._s(format)
    cdef long long pycui_result = cui_treemap_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def funnel(Context ctx, id, stages, *, width=None, height=None, format=None, color=None):
    """Wrap ``cui_funnel_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_stages
    cdef int pycui_n_stages
    cdef cui_funnel_opts opts
    pycui_ptr_stages = _pack_cui_viz_item(ctx, stages, &pycui_n_stages)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if format is not None:
        opts.format = ctx._s(format)
    if color is not None:
        to_color(color, &opts.color)
    cdef long long pycui_result = cui_funnel_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_stages, pycui_n_stages, &opts)
    return int(pycui_result)

def sankey(Context ctx, id, nodes, links, *, width=None, height=None, format=None, node_width=None):
    """Wrap ``cui_sankey_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_nodes
    cdef int pycui_n_nodes
    cdef void *pycui_ptr_links
    cdef int pycui_n_links
    cdef cui_sankey_opts opts
    pycui_ptr_nodes = _s_array_any(ctx, nodes, &pycui_n_nodes)
    pycui_ptr_links = _pack_cui_sankey_link(ctx, links, &pycui_n_links)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if format is not None:
        opts.format = ctx._s(format)
    if node_width is not None:
        opts.node_width = <float>(node_width)
    cdef long long pycui_result = cui_sankey_ex(pycui_ctx, ctx._s(id), pycui_ptr_nodes, pycui_n_nodes, <const cui_sankey_link *>pycui_ptr_links, pycui_n_links, &opts)
    return int(pycui_result)

def waffle(Context ctx, id, items, *, cell=None, columns=None, rows=None, format=None):
    """Wrap ``cui_waffle_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_waffle_opts opts
    pycui_ptr_items = _pack_cui_viz_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if cell is not None:
        opts.cell = <float>(cell)
    if columns is not None:
        opts.columns = <int>(columns)
    if rows is not None:
        opts.rows = <int>(rows)
    if format is not None:
        opts.format = ctx._s(format)
    cdef long long pycui_result = cui_waffle_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def split_bar(Context ctx, id, items, *, width=None, height=None, format=None, no_legend=False):
    """Wrap ``cui_split_bar_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_split_bar_opts opts
    pycui_ptr_items = _pack_cui_viz_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if format is not None:
        opts.format = ctx._s(format)
    opts.no_legend = <uint8_t>bool(no_legend)
    cdef long long pycui_result = cui_split_bar_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def bar_list(Context ctx, id, items, *, width=None, format=None, max_rows=None, keep_order=False, color=None):
    """Wrap ``cui_bar_list_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_bar_list_opts opts
    pycui_ptr_items = _pack_cui_viz_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if format is not None:
        opts.format = ctx._s(format)
    if max_rows is not None:
        opts.max_rows = <int>(max_rows)
    opts.keep_order = <uint8_t>bool(keep_order)
    if color is not None:
        to_color(color, &opts.color)
    cdef long long pycui_result = cui_bar_list_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def activity_rings(Context ctx, id, rings, *, size=None, thickness=None, center=None, caption=None, legend=False):
    """Wrap ``cui_activity_rings_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_rings
    cdef int pycui_n_rings
    cdef cui_rings_opts opts
    pycui_ptr_rings = _pack_cui_viz_item(ctx, rings, &pycui_n_rings)
    memset(&opts, 0, sizeof(opts))
    if size is not None:
        opts.size = <float>(size)
    if thickness is not None:
        opts.thickness = <float>(thickness)
    if center is not None:
        opts.center = ctx._s(center)
    if caption is not None:
        opts.caption = ctx._s(caption)
    opts.legend = <uint8_t>bool(legend)
    cdef long long pycui_result = cui_activity_rings_ex(pycui_ctx, ctx._s(id), <const cui_viz_item *>pycui_ptr_rings, pycui_n_rings, &opts)
    return int(pycui_result)

def radial_gauge(Context ctx, id, value, min, max, *, label=None, format=None, unit=None, size=None, sweep=None, bands=None, band_count=None, ticks=None, target=None, show_target=False, no_needle=False):
    """Wrap ``cui_radial_gauge_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_radial_gauge_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if format is not None:
        opts.format = ctx._s(format)
    if unit is not None:
        opts.unit = ctx._s(unit)
    if size is not None:
        opts.size = <float>(size)
    if sweep is not None:
        opts.sweep = <float>(sweep)
    if band_count is not None:
        opts.band_count = <int>(band_count)
    if ticks is not None:
        opts.ticks = <int>(ticks)
    if target is not None:
        opts.target = <float>(target)
    opts.show_target = <uint8_t>bool(show_target)
    opts.no_needle = <uint8_t>bool(no_needle)
    cui_radial_gauge_ex(pycui_ctx, ctx._s(id), <float>value, <float>min, <float>max, &opts)
    return None

def candlestick(Context ctx, id, candles, *, width=None, height=None, labels=None, format=None, overlays=None, overlay_count=None, no_volume=False, ohlc=False, up=None, down=None):
    """Returns the candle under the crosshair (pointer or keys), or -1."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_candles
    cdef int pycui_n_candles
    cdef cui_candlestick_opts opts
    pycui_ptr_candles = _pack_cui_candle(ctx, candles, &pycui_n_candles)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if labels is not None:
        opts.labels = ctx._s_array_z(labels)
    if format is not None:
        opts.format = ctx._s(format)
    if overlay_count is not None:
        opts.overlay_count = <int>(overlay_count)
    opts.no_volume = <uint8_t>bool(no_volume)
    opts.ohlc = <uint8_t>bool(ohlc)
    if up is not None:
        to_color(up, &opts.up)
    if down is not None:
        to_color(down, &opts.down)
    cdef long long pycui_result = cui_candlestick_ex(pycui_ctx, ctx._s(id), <const cui_candle *>pycui_ptr_candles, pycui_n_candles, &opts)
    return int(pycui_result)

def shimmer_text(Context ctx, text, *, font=None, size=None, color=None, width=None, nowrap=False, speed=None, delay=None, caret=False):
    """Text with a highlight sweeping across it, for "Thinking..." states."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_text_fx_opts opts
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.nowrap = <uint8_t>bool(nowrap)
    if speed is not None:
        opts.speed = <float>(speed)
    if delay is not None:
        opts.delay = <float>(delay)
    opts.caret = <uint8_t>bool(caret)
    cui_shimmer_text_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def typewriter(Context ctx, id, text, *, font=None, size=None, color=None, width=None, nowrap=False, speed=None, delay=None, caret=False):
    """Types the text out. When the text grows (streamed tokens) it carries on from where it was; other changes start over. Returns true once complete."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_text_fx_opts opts
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.nowrap = <uint8_t>bool(nowrap)
    if speed is not None:
        opts.speed = <float>(speed)
    if delay is not None:
        opts.delay = <float>(delay)
    opts.caret = <uint8_t>bool(caret)
    cdef bint pycui_result = cui_typewriter_ex(pycui_ctx, ctx._s(id), ctx._s(text), &opts)
    return bool(pycui_result)

def text_reveal(Context ctx, id, text, *, font=None, size=None, color=None, width=None, nowrap=False, speed=None, delay=None, caret=False):
    """Words fade and rise into place one after another, when first shown and again whenever the text changes."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_text_fx_opts opts
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.nowrap = <uint8_t>bool(nowrap)
    if speed is not None:
        opts.speed = <float>(speed)
    if delay is not None:
        opts.delay = <float>(delay)
    opts.caret = <uint8_t>bool(caret)
    cui_text_reveal_ex(pycui_ctx, ctx._s(id), ctx._s(text), &opts)
    return None

def word_rotate(Context ctx, id, words, interval, *, font=None, size=None, color=None, width=None, nowrap=False, speed=None, delay=None, caret=False):
    """One word at a time; the next one rolls up into place and the width follows."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_words
    cdef int pycui_n_words
    cdef cui_text_fx_opts opts
    pycui_ptr_words = _s_array_any(ctx, words, &pycui_n_words)
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.nowrap = <uint8_t>bool(nowrap)
    if speed is not None:
        opts.speed = <float>(speed)
    if delay is not None:
        opts.delay = <float>(delay)
    opts.caret = <uint8_t>bool(caret)
    cui_word_rotate_ex(pycui_ctx, ctx._s(id), pycui_ptr_words, pycui_n_words, <float>interval, &opts)
    return None

def number_roll(Context ctx, id, text, *, font=None, size=None, color=None, width=None, nowrap=False, speed=None, delay=None, caret=False):
    """A figure whose changed digits roll into place: up when the value rises, down when it falls, a beat apart from the left; unchanged characters stay still. Pass the formatted text ("$64,210", "1.2k"); digits are tabular."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_text_fx_opts opts
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.nowrap = <uint8_t>bool(nowrap)
    if speed is not None:
        opts.speed = <float>(speed)
    if delay is not None:
        opts.delay = <float>(delay)
    opts.caret = <uint8_t>bool(caret)
    cui_number_roll_ex(pycui_ctx, ctx._s(id), ctx._s(text), &opts)
    return None

def gradient_text(Context ctx, text, *, font=None, size=None, from_=None, to=None, animate=False, width=None):
    """Wrap ``cui_gradient_text_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_gradient_text_opts opts
    cdef cui_color pycui_kw_from_
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if from_ is not None:
        to_color(from_, &pycui_kw_from_)
        pycui_set_cui_gradient_text_opts_from(&opts, pycui_kw_from_)
    if to is not None:
        to_color(to, &opts.to)
    opts.animate = <uint8_t>bool(animate)
    if width is not None:
        to_size(width, &opts.width)
    cui_gradient_text_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def spotlight_begin(Context ctx, id, *, width=None, height=None, pad=None, gap=None, color=None, beam=False):
    """Wrap ``cui_spotlight_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_spotlight_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if pad is not None:
        opts.pad = <float>(pad)
    if gap is not None:
        opts.gap = <float>(gap)
    if color is not None:
        to_color(color, &opts.color)
    opts.beam = <uint8_t>bool(beam)
    cui_spotlight_begin(pycui_ctx, ctx._s(id), &opts)
    return None

def spotlight_end(Context ctx):
    """Wrap ``cui_spotlight_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_spotlight_end(pycui_ctx)
    return None

def loader(Context ctx, *, style=None, size=None, color=None):
    """Wrap ``cui_loader_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_loader_opts opts
    memset(&opts, 0, sizeof(opts))
    if style is not None:
        opts.style = <int>(style)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    cui_loader_ex(pycui_ctx, &opts)
    return None

def dock_begin(Context ctx, id, *, size=None, magnify=None):
    """Wrap ``cui_dock_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_dock_opts opts
    memset(&opts, 0, sizeof(opts))
    if size is not None:
        opts.size = <float>(size)
    if magnify is not None:
        opts.magnify = <float>(magnify)
    cui_dock_begin(pycui_ctx, ctx._s(id), &opts)
    return None

def dock_item(Context ctx, icon, label, *, color=None, running=False, badge=None):
    """Wrap ``cui_dock_item_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_dock_item_opts opts
    memset(&opts, 0, sizeof(opts))
    if color is not None:
        to_color(color, &opts.color)
    opts.running = <uint8_t>bool(running)
    if badge is not None:
        opts.badge = <int>(badge)
    cdef bint pycui_result = cui_dock_item_ex(pycui_ctx, ctx._s(icon), ctx._s(label), &opts)
    return bool(pycui_result)

def dock_separator(Context ctx):
    """Wrap ``cui_dock_separator``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dock_separator(pycui_ctx)
    return None

def dock_end(Context ctx):
    """Wrap ``cui_dock_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dock_end(pycui_ctx)
    return None

def tab_bar(Context ctx, id, items, selected=0, *, width=None, labels_on_selected_only=False):
    """Wrap ``cui_tab_bar_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_selected = <int>selected
    cdef cui_tab_bar_opts opts
    pycui_ptr_items = _pack_cui_tab_bar_item(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    opts.labels_on_selected_only = <uint8_t>bool(labels_on_selected_only)
    cdef bint pycui_result = cui_tab_bar_ex(pycui_ctx, ctx._s(id), <const cui_tab_bar_item *>pycui_ptr_items, pycui_n_items, &pycui_out_selected, &opts)
    return (bool(pycui_result), int(pycui_out_selected))

def control_tile(Context ctx, label, on=False, *, icon=None, detail=None, color=None, width=None, wide=False):
    """Wrap ``cui_control_tile_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_on = <c_bool>bool(on)
    cdef cui_tile_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if detail is not None:
        opts.detail = ctx._s(detail)
    if color is not None:
        to_color(color, &opts.color)
    if width is not None:
        to_size(width, &opts.width)
    opts.wide = <uint8_t>bool(wide)
    cdef bint pycui_result = cui_control_tile_ex(pycui_ctx, ctx._s(label), &pycui_out_on, &opts)
    return (bool(pycui_result), bool(pycui_out_on))

def waveform(Context ctx, id, peaks, progress=0.0, *, width=None, height=None, bar=None, gap=None, color=None):
    """Wrap ``cui_waveform_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const float *pycui_ptr_peaks
    cdef int pycui_n_peaks
    cdef float pycui_out_progress = <float>progress
    cdef cui_waveform_opts opts
    pycui_ptr_peaks = ctx._c_float_array(peaks, &pycui_n_peaks)
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if bar is not None:
        opts.bar = <float>(bar)
    if gap is not None:
        opts.gap = <float>(gap)
    if color is not None:
        to_color(color, &opts.color)
    cdef bint pycui_result = cui_waveform_ex(pycui_ctx, ctx._s(id), pycui_ptr_peaks, pycui_n_peaks, &pycui_out_progress, &opts)
    return (bool(pycui_result), float(pycui_out_progress))

def now_playing(Context ctx, id, np, *, width=None, compact=False):
    """Wrap ``cui_now_playing_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_now_playing *pycui_ptr_np
    cdef cui_now_playing_opts opts
    if np is None:
        raise TypeError("this function needs a cui.NowPlaying handle")
    pycui_ptr_np = <cui_now_playing *>(<NowPlaying>np)._mem
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    opts.compact = <uint8_t>bool(compact)
    cdef long long pycui_result = cui_now_playing_ex(pycui_ctx, ctx._s(id), pycui_ptr_np, &opts)
    return int(pycui_result)

def reasoning_begin(Context ctx, id, *, thinking=False, seconds=None, title=None):
    """Wrap ``cui_reasoning_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_reasoning_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.thinking = <uint8_t>bool(thinking)
    if seconds is not None:
        opts.seconds = <float>(seconds)
    if title is not None:
        opts.title = ctx._s(title)
    cdef bint pycui_result = cui_reasoning_begin(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def reasoning_end(Context ctx):
    """Wrap ``cui_reasoning_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_reasoning_end(pycui_ctx)
    return None

def tool_call(Context ctx, id, name, *, status=None, icon=None, detail=None, input=None, output=None, seconds=None):
    """Wrap ``cui_tool_call_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_tool_call_opts opts
    memset(&opts, 0, sizeof(opts))
    if status is not None:
        opts.status = <int>(status)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if detail is not None:
        opts.detail = ctx._s(detail)
    if input is not None:
        opts.input = ctx._s(input)
    if output is not None:
        opts.output = ctx._s(output)
    if seconds is not None:
        opts.seconds = <float>(seconds)
    cui_tool_call_ex(pycui_ctx, ctx._s(id), ctx._s(name), &opts)
    return None

def agent_plan(Context ctx, id, steps, *, title=None):
    """Wrap ``cui_agent_plan_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_steps
    cdef int pycui_n_steps
    cdef cui_agent_plan_opts opts
    pycui_ptr_steps = _pack_cui_plan_step(ctx, steps, &pycui_n_steps)
    memset(&opts, 0, sizeof(opts))
    if title is not None:
        opts.title = ctx._s(title)
    cdef long long pycui_result = cui_agent_plan_ex(pycui_ctx, ctx._s(id), <const cui_plan_step *>pycui_ptr_steps, pycui_n_steps, &opts)
    return int(pycui_result)

def agent_status(Context ctx, text, *, status=None, seconds=None, icon=None):
    """Wrap ``cui_agent_status_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_agent_status_opts opts
    memset(&opts, 0, sizeof(opts))
    if status is not None:
        opts.status = <int>(status)
    if seconds is not None:
        opts.seconds = <float>(seconds)
    if icon is not None:
        opts.icon = ctx._s(icon)
    cui_agent_status_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def source_list(Context ctx, id, sources):
    """Wrap ``cui_source_list``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_sources
    cdef int pycui_n_sources
    pycui_ptr_sources = _pack_cui_source(ctx, sources, &pycui_n_sources)
    cdef long long pycui_result = cui_source_list(pycui_ctx, ctx._s(id), <const cui_source *>pycui_ptr_sources, pycui_n_sources)
    return int(pycui_result)

def citation(Context ctx, number, source):
    """Wrap ``cui_citation``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_source
    cdef int pycui_n_source
    pycui_ptr_source = _pack_cui_source(ctx, source, &pycui_n_source)
    cdef bint pycui_result = cui_citation(pycui_ctx, <int>number, <const cui_source *>pycui_ptr_source)
    return bool(pycui_result)

def context_meter(Context ctx, id, used, limit, *, parts=None, part_count=None, unit=None):
    """Wrap ``cui_context_meter_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_context_opts opts
    memset(&opts, 0, sizeof(opts))
    if part_count is not None:
        opts.part_count = <int>(part_count)
    if unit is not None:
        opts.unit = ctx._s(unit)
    cui_context_meter_ex(pycui_ctx, ctx._s(id), <float>used, <float>limit, &opts)
    return None

def response_actions(Context ctx, id, *, copy_text=None, vote=None, no_regenerate=False, no_share=False):
    """Wrap ``cui_response_actions_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_response_actions_opts opts
    memset(&opts, 0, sizeof(opts))
    if copy_text is not None:
        opts.copy_text = ctx._s(copy_text)
    opts.no_regenerate = <uint8_t>bool(no_regenerate)
    opts.no_share = <uint8_t>bool(no_share)
    cdef long long pycui_result = cui_response_actions_ex(pycui_ctx, ctx._s(id), &opts)
    return int(pycui_result)

def prompt_suggestions(Context ctx, id, items, *, columns=None):
    """Wrap ``cui_prompt_suggestions_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    cdef cui_prompt_suggestions_opts opts
    pycui_ptr_items = _pack_cui_prompt_suggestion(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if columns is not None:
        opts.columns = <int>(columns)
    cdef long long pycui_result = cui_prompt_suggestions_ex(pycui_ctx, ctx._s(id), <const cui_prompt_suggestion *>pycui_ptr_items, pycui_n_items, &opts)
    return int(pycui_result)

def model_picker(Context ctx, id, models, selected=0, *, ghost=False, placement=None):
    """Wrap ``cui_model_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_models
    cdef int pycui_n_models
    cdef int pycui_out_selected = <int>selected
    cdef cui_model_picker_opts opts
    pycui_ptr_models = _pack_cui_model(ctx, models, &pycui_n_models)
    memset(&opts, 0, sizeof(opts))
    opts.ghost = <uint8_t>bool(ghost)
    if placement is not None:
        opts.placement = <int>(placement)
    cdef bint pycui_result = cui_model_picker_ex(pycui_ctx, ctx._s(id), <const cui_model *>pycui_ptr_models, pycui_n_models, &pycui_out_selected, &opts)
    return (bool(pycui_result), int(pycui_out_selected))

def chat_composer(Context ctx, id, text='', *, placeholder=None, busy=False, attachments=None, attachment_count=None, removed=None, models=None, model_count=None, model=None, max_lines=None, width=None):
    """Wrap ``cui_chat_composer_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_composer_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_chat_composer_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    opts.busy = <uint8_t>bool(busy)
    if attachments is not None:
        opts.attachments = ctx._s_array_z(attachments)
    if attachment_count is not None:
        opts.attachment_count = <int>(attachment_count)
    if model_count is not None:
        opts.model_count = <int>(model_count)
    if max_lines is not None:
        opts.max_lines = <int>(max_lines)
    if width is not None:
        to_size(width, &opts.width)
    cdef int pycui_flags
    pycui_flags = cui_chat_composer_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_chat_composer_ex', id, 'text'), pycui_flags)

def voice_orb(Context ctx, id, state, level, *, size=None, color=None):
    """Wrap ``cui_voice_orb_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_voice_orb_opts opts
    memset(&opts, 0, sizeof(opts))
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    cdef bint pycui_result = cui_voice_orb_ex(pycui_ctx, ctx._s(id), <int>state, <float>level, &opts)
    return bool(pycui_result)

def kanban_begin(Context ctx, id):
    """Wrap ``cui_kanban_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_kanban_begin(pycui_ctx, ctx._s(id))
    return None

def kanban_column_begin(Context ctx, title, card_count, *, dot=None, limit=None, width=None):
    """Wrap ``cui_kanban_column_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_kanban_column_opts opts
    memset(&opts, 0, sizeof(opts))
    if dot is not None:
        to_color(dot, &opts.dot)
    if limit is not None:
        opts.limit = <int>(limit)
    if width is not None:
        opts.width = <float>(width)
    cdef bint pycui_result = cui_kanban_column_begin_ex(pycui_ctx, ctx._s(title), <int>card_count, &opts)
    return bool(pycui_result)

def kanban_card_begin(Context ctx, card_id):
    """Wrap ``cui_kanban_card_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_kanban_card_begin(pycui_ctx, <int>card_id)
    return bool(pycui_result)

def kanban_card_end(Context ctx):
    """Wrap ``cui_kanban_card_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_kanban_card_end(pycui_ctx)
    return None

def kanban_column_end(Context ctx):
    """Wrap ``cui_kanban_column_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_kanban_column_end(pycui_ctx)
    return None

def kanban_end(Context ctx, move):
    """Wrap ``cui_kanban_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_kanban_move *pycui_ptr_move
    if move is None:
        raise TypeError("this function needs a cui.KanbanMove handle")
    pycui_ptr_move = <cui_kanban_move *>(<KanbanMove>move)._mem
    cdef bint pycui_result = cui_kanban_end(pycui_ctx, pycui_ptr_move)
    return bool(pycui_result)

def hover_card_begin(Context ctx, id, *, placement=None, width=None, delay=None):
    """Wrap ``cui_hover_card_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_hover_card_opts opts
    memset(&opts, 0, sizeof(opts))
    if placement is not None:
        opts.placement = <int>(placement)
    if width is not None:
        opts.width = <float>(width)
    if delay is not None:
        opts.delay = <float>(delay)
    cdef bint pycui_result = cui_hover_card_begin(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def hover_card_end(Context ctx):
    """Wrap ``cui_hover_card_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_hover_card_end(pycui_ctx)
    return None

def confirm_popover(Context ctx, id, *, title=None, description=None, confirm_label=None, cancel_label=None, danger=False, placement=None):
    """Wrap ``cui_confirm_popover_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_confirm_popover_opts opts
    memset(&opts, 0, sizeof(opts))
    if title is not None:
        opts.title = ctx._s(title)
    if description is not None:
        opts.description = ctx._s(description)
    if confirm_label is not None:
        opts.confirm_label = ctx._s(confirm_label)
    if cancel_label is not None:
        opts.cancel_label = ctx._s(cancel_label)
    opts.danger = <uint8_t>bool(danger)
    if placement is not None:
        opts.placement = <int>(placement)
    cdef bint pycui_result = cui_confirm_popover_ex(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def expandable_text(Context ctx, id, text, *, lines=None, size=None, color=None, fade_to=None):
    """Wrap ``cui_expandable_text_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_expandable_text_opts opts
    memset(&opts, 0, sizeof(opts))
    if lines is not None:
        opts.lines = <int>(lines)
    if size is not None:
        opts.size = <float>(size)
    if color is not None:
        to_color(color, &opts.color)
    if fade_to is not None:
        to_color(fade_to, &opts.fade_to)
    cdef bint pycui_result = cui_expandable_text_ex(pycui_ctx, ctx._s(id), ctx._s(text), &opts)
    return bool(pycui_result)

def expandable_card_begin(Context ctx, title, open=False, *, description=None, icon=None, badge=None, badge_tone=None):
    """Wrap ``cui_expandable_card_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_expandable_card_opts opts
    memset(&opts, 0, sizeof(opts))
    if description is not None:
        opts.description = ctx._s(description)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if badge is not None:
        opts.badge = ctx._s(badge)
    if badge_tone is not None:
        opts.badge_tone = <int>(badge_tone)
    cdef bint pycui_result = cui_expandable_card_begin(pycui_ctx, ctx._s(title), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def expandable_card_end(Context ctx):
    """Wrap ``cui_expandable_card_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_expandable_card_end(pycui_ctx)
    return None

def toc(Context ctx, scroll_id, items):
    """Wrap ``cui_toc``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_items
    cdef int pycui_n_items
    pycui_ptr_items = _pack_cui_toc_item(ctx, items, &pycui_n_items)
    cdef long long pycui_result = cui_toc(pycui_ctx, ctx._s(scroll_id), <const cui_toc_item *>pycui_ptr_items, pycui_n_items)
    return int(pycui_result)

def toc_anchor(Context ctx, anchor):
    """Wrap ``cui_toc_anchor``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_toc_anchor(pycui_ctx, ctx._s(anchor))
    return None

def banner(Context ctx, text, open=False, *, tone=None, icon=None, action=None, dismissible=False):
    """Wrap ``cui_banner_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_banner_opts opts
    memset(&opts, 0, sizeof(opts))
    if tone is not None:
        opts.tone = <int>(tone)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if action is not None:
        opts.action = ctx._s(action)
    opts.dismissible = <uint8_t>bool(dismissible)
    cdef bint pycui_result = cui_banner_ex(pycui_ctx, ctx._s(text), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def countdown(Context ctx, id, seconds_left, *, hide_days=False, compact=False):
    """Wrap ``cui_countdown_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_countdown_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.hide_days = <uint8_t>bool(hide_days)
    opts.compact = <uint8_t>bool(compact)
    cui_countdown_ex(pycui_ctx, ctx._s(id), <double>seconds_left, &opts)
    return None

def multi_select(Context ctx, id, items, selected=False, *, label=None, placeholder=None, icons=None, searchable=False, max_chips=None, width=None):
    """Wrap ``cui_multi_select_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef c_bool pycui_out_selected = <c_bool>bool(selected)
    cdef cui_multi_select_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if icons is not None:
        opts.icons = ctx._s_array_z(icons)
    opts.searchable = <uint8_t>bool(searchable)
    if max_chips is not None:
        opts.max_chips = <int>(max_chips)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_multi_select_ex(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_selected, &opts)
    return (bool(pycui_result), bool(pycui_out_selected))

def range_calendar(Context ctx, id, range, months):
    """One or two months side by side; click a start and an end."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_date_range *pycui_ptr_range
    if range is None:
        raise TypeError("this function needs a cui.DateRange handle")
    pycui_ptr_range = <cui_date_range *>(<DateRange>range)._mem
    cdef bint pycui_result = cui_range_calendar(pycui_ctx, ctx._s(id), pycui_ptr_range, <int>months)
    return bool(pycui_result)

def date_range_picker(Context ctx, id, range, *, label=None, placeholder=None, width=None, no_presets=False):
    """Wrap ``cui_date_range_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_date_range *pycui_ptr_range
    cdef cui_date_range_opts opts
    if range is None:
        raise TypeError("this function needs a cui.DateRange handle")
    pycui_ptr_range = <cui_date_range *>(<DateRange>range)._mem
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if width is not None:
        to_size(width, &opts.width)
    opts.no_presets = <uint8_t>bool(no_presets)
    cdef bint pycui_result = cui_date_range_picker_ex(pycui_ctx, ctx._s(id), pycui_ptr_range, &opts)
    return bool(pycui_result)

def date_to_days(d):
    """Wrap ``cui_date_to_days``."""
    cdef cui_date pycui_value_d
    to_date(d, &pycui_value_d)
    cdef long long pycui_result = cui_date_to_days(pycui_value_d)
    return int(pycui_result)

def date_from_days(days):
    """Wrap ``cui_date_from_days``."""
    cdef cui_date pycui_result = cui_date_from_days(<int>days)
    return from_date(&pycui_result)

def time_picker(Context ctx, id, hour=0, minute=0, *, label=None, twelve_hour=False, minute_step=None, width=None):
    """Wrap ``cui_time_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_hour = <int>hour
    cdef int pycui_out_minute = <int>minute
    cdef cui_time_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    opts.twelve_hour = <uint8_t>bool(twelve_hour)
    if minute_step is not None:
        opts.minute_step = <int>(minute_step)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_time_picker_ex(pycui_ctx, ctx._s(id), &pycui_out_hour, &pycui_out_minute, &opts)
    return (bool(pycui_result), int(pycui_out_hour), int(pycui_out_minute))

def wheel_picker(Context ctx, id, items, index=0, *, rows=None, width=None, loop=False, join_left=False, join_right=False):
    """Wrap ``cui_wheel_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    cdef cui_wheel_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if rows is not None:
        opts.rows = <int>(rows)
    if width is not None:
        to_size(width, &opts.width)
    opts.loop = <uint8_t>bool(loop)
    opts.join_left = <uint8_t>bool(join_left)
    opts.join_right = <uint8_t>bool(join_right)
    cdef bint pycui_result = cui_wheel_picker_ex(pycui_ctx, ctx._s(id), pycui_ptr_items, pycui_n_items, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def time_dial(Context ctx, id, size, hour=0, minute=0):
    """Time dial: a clock face. Drag the hand to set hours, then minutes."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_hour = <int>hour
    cdef int pycui_out_minute = <int>minute
    cdef bint pycui_result = cui_time_dial(pycui_ctx, ctx._s(id), &pycui_out_hour, &pycui_out_minute, <float>size)
    return (bool(pycui_result), int(pycui_out_hour), int(pycui_out_minute))

def ruler_slider(Context ctx, label, min, max, value=0.0, *, step=None, major_every=None, spacing=None, format=None, unit=None, width=None):
    """Wrap ``cui_ruler_slider_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_ruler_opts opts
    memset(&opts, 0, sizeof(opts))
    if step is not None:
        opts.step = <float>(step)
    if major_every is not None:
        opts.major_every = <int>(major_every)
    if spacing is not None:
        opts.spacing = <float>(spacing)
    if format is not None:
        opts.format = ctx._s(format)
    if unit is not None:
        opts.unit = ctx._s(unit)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_ruler_slider_ex(pycui_ctx, ctx._s(label), &pycui_out_value, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def histogram_slider(Context ctx, label, bins, min, max, lo=0.0, hi=0.0, *, height=None, format=None):
    """Wrap ``cui_histogram_slider_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const float *pycui_ptr_bins
    cdef int pycui_n_bins
    cdef float pycui_out_lo = <float>lo
    cdef float pycui_out_hi = <float>hi
    cdef cui_histogram_opts opts
    pycui_ptr_bins = ctx._c_float_array(bins, &pycui_n_bins)
    memset(&opts, 0, sizeof(opts))
    if height is not None:
        opts.height = <float>(height)
    if format is not None:
        opts.format = ctx._s(format)
    cdef bint pycui_result = cui_histogram_slider_ex(pycui_ctx, ctx._s(label), pycui_ptr_bins, pycui_n_bins, &pycui_out_lo, &pycui_out_hi, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_lo), float(pycui_out_hi))

def knob(Context ctx, id, min, max, value=0.0, *, label=None, format=None, unit=None, size=None, step=None, reset=None, bipolar=False, log_scale=False, hide_value=False, disabled=False, color=None):
    """Wrap ``cui_knob_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_knob_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if format is not None:
        opts.format = ctx._s(format)
    if unit is not None:
        opts.unit = ctx._s(unit)
    if size is not None:
        opts.size = <float>(size)
    if step is not None:
        opts.step = <float>(step)
    if reset is not None:
        opts.reset = <float>(reset)
    opts.bipolar = <uint8_t>bool(bipolar)
    opts.log_scale = <uint8_t>bool(log_scale)
    opts.hide_value = <uint8_t>bool(hide_value)
    opts.disabled = <uint8_t>bool(disabled)
    if color is not None:
        to_color(color, &opts.color)
    cdef bint pycui_result = cui_knob_ex(pycui_ctx, ctx._s(id), &pycui_out_value, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def fader(Context ctx, id, min, max, value=0.0, *, label=None, format=None, unit=None, length=None, horizontal=False, step=None, reset=None, ticks=None, tick_count=None, meter=None, meter_channels=None, hide_value=False, disabled=False):
    """Wrap ``cui_fader_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_fader_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if format is not None:
        opts.format = ctx._s(format)
    if unit is not None:
        opts.unit = ctx._s(unit)
    if length is not None:
        opts.length = <float>(length)
    opts.horizontal = <uint8_t>bool(horizontal)
    if step is not None:
        opts.step = <float>(step)
    if reset is not None:
        opts.reset = <float>(reset)
    if tick_count is not None:
        opts.tick_count = <int>(tick_count)
    if meter_channels is not None:
        opts.meter_channels = <int>(meter_channels)
    opts.hide_value = <uint8_t>bool(hide_value)
    opts.disabled = <uint8_t>bool(disabled)
    cdef bint pycui_result = cui_fader_ex(pycui_ctx, ctx._s(id), &pycui_out_value, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def level_meter(Context ctx, id, channels, levels=0.0, *, min_db=None, max_db=None, length=None, thickness=None, horizontal=False, scale=False, segmented=False, hold=None, decay=None):
    """Returns true when the clip light was clicked to clear it."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_levels = <float>levels
    cdef cui_level_meter_opts opts
    memset(&opts, 0, sizeof(opts))
    if min_db is not None:
        opts.min_db = <float>(min_db)
    if max_db is not None:
        opts.max_db = <float>(max_db)
    if length is not None:
        opts.length = <float>(length)
    if thickness is not None:
        opts.thickness = <float>(thickness)
    opts.horizontal = <uint8_t>bool(horizontal)
    opts.scale = <uint8_t>bool(scale)
    opts.segmented = <uint8_t>bool(segmented)
    if hold is not None:
        opts.hold = <float>(hold)
    if decay is not None:
        opts.decay = <float>(decay)
    cdef bint pycui_result = cui_level_meter_ex(pycui_ctx, ctx._s(id), &pycui_out_levels, <int>channels, &opts)
    return (bool(pycui_result), float(pycui_out_levels))

def signature_pad(Context ctx, id, *, width=None, height=None, placeholder=None, ink=None):
    """Wrap ``cui_signature_pad_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_signature_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if ink is not None:
        to_color(ink, &opts.ink)
    cdef bint pycui_result = cui_signature_pad_ex(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def signature_clear(Context ctx, id):
    """Wrap ``cui_signature_clear``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_signature_clear(pycui_ctx, ctx._s(id))
    return None

def dropzone(Context ctx, id, *, title=None, description=None, icon=None, accept=None, height=None, width=None, compact=False):
    """Wrap ``cui_dropzone_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_dropzone_opts opts
    memset(&opts, 0, sizeof(opts))
    if title is not None:
        opts.title = ctx._s(title)
    if description is not None:
        opts.description = ctx._s(description)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if accept is not None:
        opts.accept = ctx._s(accept)
    if height is not None:
        opts.height = <float>(height)
    if width is not None:
        to_size(width, &opts.width)
    opts.compact = <uint8_t>bool(compact)
    cdef long long pycui_result = cui_dropzone_ex(pycui_ctx, ctx._s(id), &opts)
    return int(pycui_result)

def path_has_extension(path, accept):
    """Wrap ``cui_path_has_extension``."""
    cdef bytes pycui_bytes_path = _utf8(path)
    cdef bytes pycui_bytes_accept = _utf8(accept)
    cdef bint pycui_result = cui_path_has_extension(<const char *>pycui_bytes_path, <const char *>pycui_bytes_accept)
    return bool(pycui_result)

def avatar_upload(Context ctx, id, name, size, image=0):
    """Avatar upload: a round avatar that takes a dropped image, with a camera badge on hover. Returns 1 when *image changed, -1 when clicked (browse), 0 otherwise. A dropped image is loaded with cui_image_load."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef uintptr_t pycui_out_image = <uintptr_t>image
    cdef long long pycui_result = cui_avatar_upload(pycui_ctx, ctx._s(id), ctx._s(name), &pycui_out_image, <float>size)
    return (int(pycui_result), int(pycui_out_image))

def inline_edit(Context ctx, id, text='', *, font=None, size=None, placeholder=None, width=None):
    """Wrap ``cui_inline_edit_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_inline_edit_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_inline_edit_ex', id, 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if font is not None:
        opts.font = <int>(font)
    if size is not None:
        opts.size = <float>(size)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if width is not None:
        to_size(width, &opts.width)
    cdef int pycui_flags
    pycui_flags = cui_inline_edit_ex(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_inline_edit_ex', id, 'text'), pycui_flags)

def scrub(Context ctx, label, min, max, value=0.0, *, step=None, format=None, suffix=None, icon=None, width=None):
    """Wrap ``cui_scrub_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_scrub_opts opts
    memset(&opts, 0, sizeof(opts))
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if icon is not None:
        opts.icon = ctx._s(icon)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_scrub_ex(pycui_ctx, ctx._s(label), &pycui_out_value, <float>min, <float>max, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def money_input(Context ctx, id, value=0.0, *, label=None, symbol=None, code=None, decimals=None, width=None, hint=None):
    """Wrap ``cui_money_input_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef double pycui_out_value = <double>value
    cdef cui_money_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if symbol is not None:
        opts.symbol = ctx._s(symbol)
    if code is not None:
        opts.code = ctx._s(code)
    if decimals is not None:
        opts.decimals = <int>(decimals)
    if width is not None:
        to_size(width, &opts.width)
    if hint is not None:
        opts.hint = ctx._s(hint)
    cdef bint pycui_result = cui_money_input_ex(pycui_ctx, ctx._s(id), &pycui_out_value, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def shortcut_recorder(Context ctx, id, combo=None, *, placeholder=None, width=None):
    """Wrap ``cui_shortcut_recorder_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_key_combo pycui_out_combo
    cdef cui_shortcut_recorder_opts opts
    to_key_combo(combo, &pycui_out_combo)
    memset(&opts, 0, sizeof(opts))
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_shortcut_recorder_ex(pycui_ctx, ctx._s(id), &pycui_out_combo, &opts)
    return (bool(pycui_result), from_key_combo(&pycui_out_combo))

def shortcut_label(Context ctx, combo):
    """Wrap ``cui_shortcut_label``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_key_combo pycui_value_combo
    to_key_combo(combo, &pycui_value_combo)
    cdef const char *pycui_result = cui_shortcut_label(pycui_ctx, pycui_value_combo)
    return _decode(pycui_result)

def key_name(key):
    """Wrap ``cui_key_name``."""
    cdef const char *pycui_result = cui_key_name(<int>key)
    return _decode(pycui_result)

def node_editor_begin(Context ctx, id, view, *, width=None, height=None, min_zoom=None, max_zoom=None, no_grid=False, minimap=False):
    """Wrap ``cui_node_editor_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_node_view *pycui_ptr_view
    cdef cui_node_editor_opts opts
    if view is None:
        raise TypeError("this function needs a cui.NodeView handle")
    pycui_ptr_view = <cui_node_view *>(<NodeView>view)._mem
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_zoom is not None:
        opts.min_zoom = <float>(min_zoom)
    if max_zoom is not None:
        opts.max_zoom = <float>(max_zoom)
    opts.no_grid = <uint8_t>bool(no_grid)
    opts.minimap = <uint8_t>bool(minimap)
    cdef bint pycui_result = cui_node_editor_begin_ex(pycui_ctx, ctx._s(id), pycui_ptr_view, &opts)
    return bool(pycui_result)

def node_editor_end(Context ctx):
    """Wrap ``cui_node_editor_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_node_editor_end(pycui_ctx)
    return None

def node_begin(Context ctx, node_id, title, x=0.0, y=0.0, *, width=None, icon=None):
    """Wrap ``cui_node_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_x = <float>x
    cdef float pycui_out_y = <float>y
    cdef cui_node_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        opts.width = <float>(width)
    if icon is not None:
        opts.icon = ctx._s(icon)
    cdef bint pycui_result = cui_node_begin_ex(pycui_ctx, <int>node_id, &pycui_out_x, &pycui_out_y, ctx._s(title), &opts)
    return (bool(pycui_result), float(pycui_out_x), float(pycui_out_y))

def node_end(Context ctx):
    """Wrap ``cui_node_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_node_end(pycui_ctx)
    return None

def node_input(Context ctx, pin_id, label, *, type=None):
    """Wrap ``cui_node_input_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_pin_opts opts
    memset(&opts, 0, sizeof(opts))
    if type is not None:
        opts.type = <int>(type)
    cdef bint pycui_result = cui_node_input_ex(pycui_ctx, <int>pin_id, ctx._s(label), &opts)
    return bool(pycui_result)

def node_output(Context ctx, pin_id, label, *, type=None):
    """Wrap ``cui_node_output_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_pin_opts opts
    memset(&opts, 0, sizeof(opts))
    if type is not None:
        opts.type = <int>(type)
    cdef bint pycui_result = cui_node_output_ex(pycui_ctx, <int>pin_id, ctx._s(label), &opts)
    return bool(pycui_result)

def node_content_begin(Context ctx):
    """A row for ordinary components. They are laid out at 100% and scaled with the view, so their text is sharpest at 100% zoom and below."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_node_content_begin(pycui_ctx)
    return None

def node_content_end(Context ctx):
    """Wrap ``cui_node_content_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_node_content_end(pycui_ctx)
    return None

def node_link(Context ctx, link_id, from_pin, to_pin):
    """A link from an output pin to an input pin. Returns true while it is selected."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_node_link(pycui_ctx, <int>link_id, <int>from_pin, <int>to_pin)
    return bool(pycui_result)

def node_link_created(Context ctx, from_pin=0, to_pin=0):
    """What the user did this frame, one event per call; call them after cui_node_editor_begin (and up to the end of the frame)."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_from_pin = <int>from_pin
    cdef int pycui_out_to_pin = <int>to_pin
    cdef bint pycui_result = cui_node_link_created(pycui_ctx, &pycui_out_from_pin, &pycui_out_to_pin)
    return (bool(pycui_result), int(pycui_out_from_pin), int(pycui_out_to_pin))

def node_link_removed(Context ctx, link_id=0):
    """Wrap ``cui_node_link_removed``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_link_id = <int>link_id
    cdef bint pycui_result = cui_node_link_removed(pycui_ctx, &pycui_out_link_id)
    return (bool(pycui_result), int(pycui_out_link_id))

def node_deleted(Context ctx, node_id=0):
    """Wrap ``cui_node_deleted``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_node_id = <int>node_id
    cdef bint pycui_result = cui_node_deleted(pycui_ctx, &pycui_out_node_id)
    return (bool(pycui_result), int(pycui_out_node_id))

def menu_bar_begin(Context ctx, id, *, no_border=False):
    """Wrap ``cui_menu_bar_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_menu_bar_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.no_border = <uint8_t>bool(no_border)
    cui_menu_bar_begin(pycui_ctx, ctx._s(id), &opts)
    return None

def menu_bar_end(Context ctx):
    """Wrap ``cui_menu_bar_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_menu_bar_end(pycui_ctx)
    return None

def menu_bar_menu_begin(Context ctx, label, *, mnemonic=None, width=None, disabled=False):
    """Wrap ``cui_menu_bar_menu_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_menu_bar_menu_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        opts.width = <float>(width)
    opts.disabled = <uint8_t>bool(disabled)
    cdef bint pycui_result = cui_menu_bar_menu_begin(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def menu_bar_menu_end(Context ctx):
    """Wrap ``cui_menu_bar_menu_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_menu_bar_menu_end(pycui_ctx)
    return None

def toolbar_begin(Context ctx, id, *, no_border=False):
    """Wrap ``cui_toolbar_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_toolbar_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.no_border = <uint8_t>bool(no_border)
    cui_toolbar_begin(pycui_ctx, ctx._s(id), &opts)
    return None

def toolbar_end(Context ctx):
    """Wrap ``cui_toolbar_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_toolbar_end(pycui_ctx)
    return None

def toolbar_button(Context ctx, icon, *, label=None, tooltip=None, shortcut=None, toggle=None, disabled=False):
    """Wrap ``cui_toolbar_button_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_tool_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    if shortcut is not None:
        opts.shortcut = ctx._s(shortcut)
    opts.disabled = <uint8_t>bool(disabled)
    cdef bint pycui_result = cui_toolbar_button_ex(pycui_ctx, ctx._s(icon), &opts)
    return bool(pycui_result)

def toolbar_separator(Context ctx):
    """Wrap ``cui_toolbar_separator``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_toolbar_separator(pycui_ctx)
    return None

def toolbar_spacer(Context ctx):
    """Wrap ``cui_toolbar_spacer``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_toolbar_spacer(pycui_ctx)
    return None

def status_bar_begin(Context ctx, id, *, no_border=False):
    """Wrap ``cui_status_bar_begin``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_status_bar_opts opts
    memset(&opts, 0, sizeof(opts))
    opts.no_border = <uint8_t>bool(no_border)
    cui_status_bar_begin(pycui_ctx, ctx._s(id), &opts)
    return None

def status_bar_end(Context ctx):
    """Wrap ``cui_status_bar_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_status_bar_end(pycui_ctx)
    return None

def status_bar_spacer(Context ctx):
    """Wrap ``cui_status_bar_spacer``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_status_bar_spacer(pycui_ctx)
    return None

def status_bar_text(Context ctx, text, *, icon=None, tone=None, tooltip=None, disabled=False):
    """A message; `tone` colors its icon."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_status_item_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if tone is not None:
        opts.tone = <int>(tone)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    cui_status_bar_text_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def status_bar_item(Context ctx, label, *, icon=None, tone=None, tooltip=None, disabled=False):
    """A small clickable item ("Ln 12, Col 4", "UTF-8"). Returns true when clicked."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_status_item_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    if tone is not None:
        opts.tone = <int>(tone)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    cdef bint pycui_result = cui_status_bar_item_ex(pycui_ctx, ctx._s(label), &opts)
    return bool(pycui_result)

def status_bar_progress(Context ctx, value, *, label=None, indeterminate=False, width=None):
    """Wrap ``cui_status_bar_progress_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_status_progress_opts opts
    memset(&opts, 0, sizeof(opts))
    if label is not None:
        opts.label = ctx._s(label)
    opts.indeterminate = <uint8_t>bool(indeterminate)
    if width is not None:
        opts.width = <float>(width)
    cui_status_bar_progress_ex(pycui_ctx, <float>value, &opts)
    return None

def dockspace_begin(Context ctx, id, *, layout=None, width=None, height=None, min_panel_width=None, min_panel_height=None, shortcuts=False):
    """Wrap ``cui_dockspace_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_dockspace_opts opts
    memset(&opts, 0, sizeof(opts))
    if layout is not None:
        opts.layout = ctx._s(layout)
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        to_size(height, &opts.height)
    if min_panel_width is not None:
        opts.min_panel_width = <float>(min_panel_width)
    if min_panel_height is not None:
        opts.min_panel_height = <float>(min_panel_height)
    opts.shortcuts = <uint8_t>bool(shortcuts)
    cui_dockspace_begin_ex(pycui_ctx, ctx._s(id), &opts)
    return None

def dockspace_end(Context ctx):
    """Wrap ``cui_dockspace_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dockspace_end(pycui_ctx)
    return None

def dock_panel_begin(Context ctx, title, open=False, *, icon=None, dirty=False):
    """Wrap ``cui_dock_panel_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef cui_dock_panel_opts opts
    memset(&opts, 0, sizeof(opts))
    if icon is not None:
        opts.icon = ctx._s(icon)
    opts.dirty = <uint8_t>bool(dirty)
    cdef bint pycui_result = cui_dock_panel_begin_ex(pycui_ctx, ctx._s(title), &pycui_out_open, &opts)
    return (bool(pycui_result), bool(pycui_out_open))

def dock_panel_end(Context ctx):
    """Wrap ``cui_dock_panel_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_dock_panel_end(pycui_ctx)
    return None

def dock_save(Context ctx, id, text=''):
    """Saved layout: one line, e.g. dock1 h0.22([*Scene tree,Assets],v0.7([*Viewport],[*Log,-Console])) h splits side by side and v stacks, the number is the first child's share, [..] is a leaf's tabs in order, * the selected tab, - a closed panel; a backslash escapes , [ ] ( ) and itself in names. cui_dock_save returns the full length (as snprintf does) and writes what fits, or 0 when there is no layout. cui_dock_load replaces the layout (and sets each panel's *open from it on its next frame); names it does not know yet are kept for when they appear. Malformed text returns false and changes nothing."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    pycui_buf_buf = ctx._text_buffer(('cui_dock_save', id, 'text'), text, &pycui_cap_buf)
    cdef int pycui_flags
    pycui_flags = cui_dock_save(pycui_ctx, ctx._s(id), pycui_buf_buf, pycui_cap_buf)
    return ctx._text_result(('cui_dock_save', id, 'text'), pycui_flags)

def dock_load(Context ctx, id, text):
    """Wrap ``cui_dock_load``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_dock_load(pycui_ctx, ctx._s(id), ctx._s(text))
    return bool(pycui_result)

def inspector_begin(Context ctx, id, *, width=None, label_width=None):
    """Wrap ``cui_inspector_begin_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_inspector_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if label_width is not None:
        opts.label_width = <float>(label_width)
    cdef bint pycui_result = cui_inspector_begin_ex(pycui_ctx, ctx._s(id), &opts)
    return bool(pycui_result)

def inspector_end(Context ctx):
    """Wrap ``cui_inspector_end``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_inspector_end(pycui_ctx)
    return None

def inspector_group(Context ctx, title, open=False):
    """A folding group header. Build its rows only when this returns true (it stays true while the group animates closed). open may be NULL for a plain section that does not fold."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_open = <c_bool>bool(open)
    cdef bint pycui_result = cui_inspector_group(pycui_ctx, ctx._s(title), &pycui_out_open)
    return (bool(pycui_result), bool(pycui_out_open))

def prop_float(Context ctx, label, value=0.0, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Wrap ``cui_prop_float_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_prop_opts opts
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_float_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def prop_int(Context ctx, label, value=0, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Wrap ``cui_prop_int_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef int pycui_out_value = <int>value
    cdef cui_prop_opts opts
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_int_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), int(pycui_out_value))

def prop_text(Context ctx, label, text='', *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Wrap ``cui_prop_text_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef char *pycui_buf_buf
    cdef size_t pycui_cap_buf
    cdef cui_prop_opts opts
    pycui_buf_buf = ctx._text_buffer(('cui_prop_text_ex', 'text'), text, &pycui_cap_buf)
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef int pycui_flags
    pycui_flags = cui_prop_text_ex(pycui_ctx, ctx._s(label), pycui_buf_buf, pycui_cap_buf, &opts)
    return ctx._text_result(('cui_prop_text_ex', 'text'), pycui_flags)

def prop_bool(Context ctx, label, value=False, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Wrap ``cui_prop_bool_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef c_bool pycui_out_value = <c_bool>bool(value)
    cdef cui_prop_opts opts
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_bool_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), bool(pycui_out_value))

def prop_enum(Context ctx, label, items, index=0, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Wrap ``cui_prop_enum_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *const *pycui_ptr_items
    cdef int pycui_n_items
    cdef int pycui_out_index = <int>index
    cdef cui_prop_opts opts
    pycui_ptr_items = _s_array_any(ctx, items, &pycui_n_items)
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_enum_ex(pycui_ctx, ctx._s(label), pycui_ptr_items, pycui_n_items, &pycui_out_index, &opts)
    return (bool(pycui_result), int(pycui_out_index))

def prop_color(Context ctx, label, value=None, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """A swatch and hex value that opens the color picker."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_color pycui_out_value
    cdef cui_prop_opts opts
    to_color(value, &pycui_out_value)
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_color_ex(pycui_ctx, ctx._s(label), &pycui_out_value, &opts)
    return (bool(pycui_result), from_color(&pycui_out_value))

def prop_vec(Context ctx, label, components, value=0.0, *, min=None, max=None, step=None, format=None, suffix=None, placeholder=None, tooltip=None, disabled=False, checkbox=False):
    """Compact X, Y (Z, W) scrub fields side by side; value holds 2, 3 or 4 floats."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef float pycui_out_value = <float>value
    cdef cui_prop_opts opts
    memset(&opts, 0, sizeof(opts))
    if min is not None:
        opts.min = <float>(min)
    if max is not None:
        opts.max = <float>(max)
    if step is not None:
        opts.step = <float>(step)
    if format is not None:
        opts.format = ctx._s(format)
    if suffix is not None:
        opts.suffix = ctx._s(suffix)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if tooltip is not None:
        opts.tooltip = ctx._s(tooltip)
    opts.disabled = <uint8_t>bool(disabled)
    opts.checkbox = <uint8_t>bool(checkbox)
    cdef bint pycui_result = cui_prop_vec_ex(pycui_ctx, ctx._s(label), &pycui_out_value, <int>components, &opts)
    return (bool(pycui_result), float(pycui_out_value))

def log_append_text(buf, level, time, text, len):
    """Appends len bytes (-1: up to the terminator) stamped with time."""
    cdef cui_log_buffer *pycui_ptr_buf
    cdef bytes pycui_bytes_text = _utf8(text)
    if buf is None:
        raise TypeError("this function needs a cui.LogBuffer handle")
    pycui_ptr_buf = <cui_log_buffer *>(<LogBuffer>buf)._mem
    cui_log_append_text(pycui_ptr_buf, <int>level, <double>time, <const char *>pycui_bytes_text, <int>len)
    return None

def log_clear(buf):
    """Wrap ``cui_log_clear``."""
    cdef cui_log_buffer *pycui_ptr_buf
    if buf is None:
        raise TypeError("this function needs a cui.LogBuffer handle")
    pycui_ptr_buf = <cui_log_buffer *>(<LogBuffer>buf)._mem
    cui_log_clear(pycui_ptr_buf)
    return None

def log_view(Context ctx, id, buf, *, width=None, height=None, timestamps=False, no_toolbar=False, size=None):
    """Toolbar: level filters, a search field that filters and highlights, Follow (keeps the newest line in view; scrolling up turns it off, reaching the bottom turns it back on), Copy (selected lines, or all shown) and Clear. Click a line to select it, Shift+click for a range; with the list focused, arrows move, Shift+arrows extend, Ctrl+A selects all, Ctrl+C copies, Esc clears the selection, End follows again."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_log_buffer *pycui_ptr_buf
    cdef cui_log_view_opts opts
    if buf is None:
        raise TypeError("this function needs a cui.LogBuffer handle")
    pycui_ptr_buf = <cui_log_buffer *>(<LogBuffer>buf)._mem
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    opts.timestamps = <uint8_t>bool(timestamps)
    opts.no_toolbar = <uint8_t>bool(no_toolbar)
    if size is not None:
        opts.size = <float>(size)
    cui_log_view_ex(pycui_ctx, ctx._s(id), pycui_ptr_buf, &opts)
    return None

def terminal_write(t, data, len):
    """Wrap ``cui_terminal_write``."""
    cdef cui_terminal_buffer *pycui_ptr_t
    cdef bytes pycui_bytes_data = _utf8(data)
    if t is None:
        raise TypeError("this function needs a cui.TerminalBuffer handle")
    pycui_ptr_t = <cui_terminal_buffer *>(<TerminalBuffer>t)._mem
    cui_terminal_write(pycui_ptr_t, <const char *>pycui_bytes_data, <int>len)
    return None

def terminal_clear(t):
    """Wrap ``cui_terminal_clear``."""
    cdef cui_terminal_buffer *pycui_ptr_t
    if t is None:
        raise TypeError("this function needs a cui.TerminalBuffer handle")
    pycui_ptr_t = <cui_terminal_buffer *>(<TerminalBuffer>t)._mem
    cui_terminal_clear(pycui_ptr_t)
    return None

def emoji_font_load_file(Context ctx, path):
    """---- Emoji ---- Color emoji come from an emoji font: the system's (cui_emoji_font_load_system, which the picker calls by itself when nothing is loaded) or one the app ships. Bitmap color fonts (sbix as on macOS, CBDT as on Linux and Android) and layered ones (COLR version 0, as on Windows) are read, as is a plain outline font for one-color emoji. Sequences with skin tones, joined people and flags are looked up through the font's ligatures. Big fonts are read from the file as needed rather than loaded whole. Drawn emoji are kept in one texture and reused."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_emoji_font_load_file(pycui_ctx, ctx._s(path))
    return bool(pycui_result)

def emoji_font_load_memory(Context ctx, data, copy):
    """Wrap ``cui_emoji_font_load_memory``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const void *pycui_ptr_data
    cdef size_t pycui_size_data
    pycui_ptr_data = ctx._c_bytes(data, &pycui_size_data)
    cdef bint pycui_result = cui_emoji_font_load_memory(pycui_ctx, pycui_ptr_data, pycui_size_data, <uint8_t>bool(copy))
    return bool(pycui_result)

def emoji_font_load_system(Context ctx):
    """Wrap ``cui_emoji_font_load_system``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_emoji_font_load_system(pycui_ctx)
    return bool(pycui_result)

def emoji_supported(Context ctx, utf8, len):
    """Wrap ``cui_emoji_supported``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef bint pycui_result = cui_emoji_supported(pycui_ctx, ctx._s(utf8), <int>len)
    return bool(pycui_result)

def draw_emoji(Context ctx, utf8, len, r):
    """Wrap ``cui_draw_emoji``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    to_rect(r, &pycui_value_r)
    cui_draw_emoji(pycui_ctx, ctx._s(utf8), <int>len, pycui_value_r)
    return None

def emoji(Context ctx, utf8, size):
    """Wrap ``cui_emoji``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_emoji(pycui_ctx, ctx._s(utf8), <float>size)
    return None

def emoji_picker(Context ctx, id, *, width=None, height=None, size=None, recent=None, recent_cap=None, tone=None, placeholder=None, empty_text=None, hint=None, group_names=None, no_search=False, no_preview=False, no_tone=False):
    """Wrap ``cui_emoji_picker_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_emoji_picker_opts opts
    memset(&opts, 0, sizeof(opts))
    if width is not None:
        to_size(width, &opts.width)
    if height is not None:
        opts.height = <float>(height)
    if size is not None:
        opts.size = <float>(size)
    if recent is not None:
        opts.recent = ctx._s(recent)
    if recent_cap is not None:
        opts.recent_cap = <size_t>(recent_cap)
    if placeholder is not None:
        opts.placeholder = ctx._s(placeholder)
    if empty_text is not None:
        opts.empty_text = ctx._s(empty_text)
    if hint is not None:
        opts.hint = ctx._s(hint)
    if group_names is not None:
        opts.group_names = ctx._s_array_z(group_names)
    opts.no_search = <uint8_t>bool(no_search)
    opts.no_preview = <uint8_t>bool(no_preview)
    opts.no_tone = <uint8_t>bool(no_tone)
    cdef const char *pycui_result = cui_emoji_picker_ex(pycui_ctx, ctx._s(id), &opts)
    return _decode(pycui_result)

def hex_view_goto(Context ctx, id, offset):
    """Go to offset: on the view's next frame its cursor moves to offset, that byte becomes the selection and it scrolls into view (to the middle when it was out of sight). Wire a "Go to" field to it; it is safe to call every frame."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_hex_view_goto(pycui_ctx, ctx._s(id), <size_t>offset)
    return None

def flame_span_rect(Context ctx, flame, span):
    """Where a span was drawn in the latest frame, in points (zero size when out of view). flame is the graph's id: cui_last_id(ui) right after the call."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef void *pycui_ptr_span
    cdef int pycui_n_span
    pycui_ptr_span = _pack_cui_flame_span(ctx, span, &pycui_n_span)
    cdef cui_rect pycui_result = cui_flame_span_rect(pycui_ctx, <uint32_t>flame, <const cui_flame_span *>pycui_ptr_span)
    return from_rect(&pycui_result)

def curve_eval(keys, x):
    """The curve's value at x: exactly what the editor draws. keys sorted by x."""
    cdef void *pycui_ptr_keys
    cdef int pycui_n_keys
    pycui_ptr_keys = _pack_cui_curve_key(None, keys, &pycui_n_keys)
    cdef double pycui_result = cui_curve_eval(<const cui_curve_key *>pycui_ptr_keys, pycui_n_keys, <float>x)
    return float(pycui_result)

def gradient_eval(stops, t):
    """The color at t: exactly what the ramp shows (each channel, alpha too, interpolated in sRGB between the stops on either side; the end colors continue past the first and last stop)."""
    cdef void *pycui_ptr_stops
    cdef int pycui_n_stops
    pycui_ptr_stops = _pack_cui_gradient_stop(None, stops, &pycui_n_stops)
    cdef cui_color pycui_result = cui_gradient_eval(<const cui_gradient_stop *>pycui_ptr_stops, pycui_n_stops, <float>t)
    return from_color(&pycui_result)

def kv_editor(Context ctx, id, pairs, capacity, count=0, *, key_placeholder=None, value_placeholder=None, no_toggles=False, no_secrets=False, read_only=False, width=None):
    """Wrap ``cui_kv_editor_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_kv_pair *pycui_ptr_pairs
    cdef int pycui_out_count = <int>count
    cdef cui_kv_editor_opts opts
    if pairs is None:
        raise TypeError("this function needs a cui.KvPair handle")
    pycui_ptr_pairs = <cui_kv_pair *>(<KvPair>pairs)._mem
    memset(&opts, 0, sizeof(opts))
    if key_placeholder is not None:
        opts.key_placeholder = ctx._s(key_placeholder)
    if value_placeholder is not None:
        opts.value_placeholder = ctx._s(value_placeholder)
    opts.no_toggles = <uint8_t>bool(no_toggles)
    opts.no_secrets = <uint8_t>bool(no_secrets)
    opts.read_only = <uint8_t>bool(read_only)
    if width is not None:
        to_size(width, &opts.width)
    cdef bint pycui_result = cui_kv_editor_ex(pycui_ctx, ctx._s(id), pycui_ptr_pairs, &pycui_out_count, <int>capacity, &opts)
    return (bool(pycui_result), int(pycui_out_count))

def query_op_name(type, op):
    """the operators of a type: text "is", "is not", "contains", "does not contain", "starts with", "ends with"; number "=", "!=", ">", ">=", "<", "<="; choice "is", "is not"; bool "is true", "is false". NULL past the last."""
    cdef const char *pycui_result = cui_query_op_name(<int>type, <int>op)
    return _decode(pycui_result)

def cron_next(cron, after, utc_offset, next=0):
    """The first time after `after` (Unix seconds) the expression matches, in the time zone that is utc_offset minutes east of UTC. Supports *, lists, ranges, steps and the names JAN-DEC and SUN-SAT. False when it is invalid or never runs in the next five years."""
    cdef bytes pycui_bytes_cron = _utf8(cron)
    cdef int64_t pycui_out_next = <int64_t>next
    cdef bint pycui_result = cui_cron_next(<const char *>pycui_bytes_cron, <int64_t>after, <int>utc_offset, &pycui_out_next)
    return (bool(pycui_result), int(pycui_out_next))

def cron_describe(Context ctx, cron):
    """"Every weekday at 09:30", in frame memory; NULL when invalid."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef const char *pycui_result = cui_cron_describe(pycui_ctx, ctx._s(cron))
    return _decode(pycui_result)

def regex_search(pattern, flags, text, len, from_, m):
    """Wrap ``cui_regex_search``."""
    cdef bytes pycui_bytes_pattern = _utf8(pattern)
    cdef bytes pycui_bytes_text = _utf8(text)
    cdef cui_regex_match *pycui_ptr_m
    cdef const char *pycui_out_error = NULL
    if m is None:
        raise TypeError("this function needs a cui.RegexMatch handle")
    pycui_ptr_m = <cui_regex_match *>(<RegexMatch>m)._mem
    cdef long long pycui_result = cui_regex_search(<const char *>pycui_bytes_pattern, <int>flags, <const char *>pycui_bytes_text, <int>len, <int>from_, pycui_ptr_m, &pycui_out_error)
    return (int(pycui_result), _decode(pycui_out_error))

def response_status(Context ctx, status, seconds, bytes):
    """Wrap ``cui_response_status``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_response_status(pycui_ctx, <int>status, <double>seconds, <double>bytes)
    return None

def http_reason(status):
    """Wrap ``cui_http_reason``."""
    cdef const char *pycui_result = cui_http_reason(<int>status)
    return _decode(pycui_result)

def http_method_name(method):
    """Wrap ``cui_http_method_name``."""
    cdef const char *pycui_result = cui_http_method_name(<int>method)
    return _decode(pycui_result)

def readout(Context ctx, label, value, *, unit=None, detail=None, size=None, tone=None, accent=False, align=None, width=None):
    """Wrap ``cui_readout_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_readout_opts opts
    memset(&opts, 0, sizeof(opts))
    if unit is not None:
        opts.unit = ctx._s(unit)
    if detail is not None:
        opts.detail = ctx._s(detail)
    if size is not None:
        opts.size = <int>(size)
    if tone is not None:
        opts.tone = <int>(tone)
    opts.accent = <uint8_t>bool(accent)
    if align is not None:
        opts.align = <int>(align)
    if width is not None:
        to_size(width, &opts.width)
    cui_readout_ex(pycui_ctx, ctx._s(label), ctx._s(value), &opts)
    return None

def dot_display(Context ctx, text, *, pitch=None, color=None, accent=False, no_dim=False, marquee=False, align=None, width=None):
    """Wrap ``cui_dot_display_ex``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_dot_display_opts opts
    memset(&opts, 0, sizeof(opts))
    if pitch is not None:
        opts.pitch = <float>(pitch)
    if color is not None:
        to_color(color, &opts.color)
    opts.accent = <uint8_t>bool(accent)
    opts.no_dim = <uint8_t>bool(no_dim)
    opts.marquee = <uint8_t>bool(marquee)
    if align is not None:
        opts.align = <int>(align)
    if width is not None:
        to_size(width, &opts.width)
    cui_dot_display_ex(pycui_ctx, ctx._s(text), &opts)
    return None

def draw_rect(Context ctx, r, radius, fill):
    """Wrap ``cui_draw_rect``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_corners pycui_value_radius
    cdef cui_color pycui_value_fill
    to_rect(r, &pycui_value_r)
    to_corners(radius, &pycui_value_radius)
    to_color(fill, &pycui_value_fill)
    cui_draw_rect(pycui_ctx, pycui_value_r, pycui_value_radius, pycui_value_fill)
    return None

def draw_rect_border(Context ctx, r, radius, fill, border, border_width):
    """Wrap ``cui_draw_rect_border``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_corners pycui_value_radius
    cdef cui_color pycui_value_fill
    cdef cui_color pycui_value_border
    to_rect(r, &pycui_value_r)
    to_corners(radius, &pycui_value_radius)
    to_color(fill, &pycui_value_fill)
    to_color(border, &pycui_value_border)
    cui_draw_rect_border(pycui_ctx, pycui_value_r, pycui_value_radius, pycui_value_fill, pycui_value_border, <float>border_width)
    return None

def draw_rect_gradient(Context ctx, r, radius, top, bottom):
    """Wrap ``cui_draw_rect_gradient``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_corners pycui_value_radius
    cdef cui_color pycui_value_top
    cdef cui_color pycui_value_bottom
    to_rect(r, &pycui_value_r)
    to_corners(radius, &pycui_value_radius)
    to_color(top, &pycui_value_top)
    to_color(bottom, &pycui_value_bottom)
    cui_draw_rect_gradient(pycui_ctx, pycui_value_r, pycui_value_radius, pycui_value_top, pycui_value_bottom)
    return None

def draw_shadow(Context ctx, r, radius, blur, spread, offset, color):
    """Wrap ``cui_draw_shadow``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_corners pycui_value_radius
    cdef cui_vec2 pycui_value_offset
    cdef cui_color pycui_value_color
    to_rect(r, &pycui_value_r)
    to_corners(radius, &pycui_value_radius)
    to_vec2(offset, &pycui_value_offset)
    to_color(color, &pycui_value_color)
    cui_draw_shadow(pycui_ctx, pycui_value_r, pycui_value_radius, <float>blur, <float>spread, pycui_value_offset, pycui_value_color)
    return None

def draw_line(Context ctx, a, b, thickness, color):
    """Wrap ``cui_draw_line``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_value_a
    cdef cui_vec2 pycui_value_b
    cdef cui_color pycui_value_color
    to_vec2(a, &pycui_value_a)
    to_vec2(b, &pycui_value_b)
    to_color(color, &pycui_value_color)
    cui_draw_line(pycui_ctx, pycui_value_a, pycui_value_b, <float>thickness, pycui_value_color)
    return None

def draw_circle(Context ctx, center, radius, color):
    """Wrap ``cui_draw_circle``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_value_center
    cdef cui_color pycui_value_color
    to_vec2(center, &pycui_value_center)
    to_color(color, &pycui_value_color)
    cui_draw_circle(pycui_ctx, pycui_value_center, <float>radius, pycui_value_color)
    return None

def draw_arc(Context ctx, center, radius, a0, a1, thickness, color):
    """Wrap ``cui_draw_arc``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_value_center
    cdef cui_color pycui_value_color
    to_vec2(center, &pycui_value_center)
    to_color(color, &pycui_value_color)
    cui_draw_arc(pycui_ctx, pycui_value_center, <float>radius, <float>a0, <float>a1, <float>thickness, pycui_value_color)
    return None

def draw_text(Context ctx, font, size, pos, color, text, len):
    """Wrap ``cui_draw_text``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_vec2 pycui_value_pos
    cdef cui_color pycui_value_color
    to_vec2(pos, &pycui_value_pos)
    to_color(color, &pycui_value_color)
    cui_draw_text(pycui_ctx, <int>font, <float>size, pycui_value_pos, pycui_value_color, ctx._s(text), <int>len)
    return None

def draw_icon(Context ctx, icon, r, size, color):
    """Wrap ``cui_draw_icon``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_color pycui_value_color
    to_rect(r, &pycui_value_r)
    to_color(color, &pycui_value_color)
    cui_draw_icon(pycui_ctx, ctx._s(icon), pycui_value_r, <float>size, pycui_value_color)
    return None

def draw_image(Context ctx, tex, r, uv, radius, tint):
    """Wrap ``cui_draw_image``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    cdef cui_rect pycui_value_uv
    cdef cui_corners pycui_value_radius
    cdef cui_color pycui_value_tint
    to_rect(r, &pycui_value_r)
    to_rect(uv, &pycui_value_uv)
    to_corners(radius, &pycui_value_radius)
    to_color(tint, &pycui_value_tint)
    cui_draw_image(pycui_ctx, <uintptr_t>tex, pycui_value_r, pycui_value_uv, pycui_value_radius, pycui_value_tint)
    return None

def push_clip(Context ctx, r):
    """Wrap ``cui_push_clip``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef cui_rect pycui_value_r
    to_rect(r, &pycui_value_r)
    cui_push_clip(pycui_ctx, pycui_value_r)
    return None

def pop_clip(Context ctx):
    """Wrap ``cui_pop_clip``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cui_pop_clip(pycui_ctx)
    return None

def animate(Context ctx, id, target):
    """Animation helpers. Values move toward target with a spring and request frames while moving. Reduced motion makes them snap."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef double pycui_result = cui_animate(pycui_ctx, <uint32_t>id, <float>target)
    return float(pycui_result)

def animate_spring(Context ctx, id, target, duration, bounce):
    """Wrap ``cui_animate_spring``."""
    cdef cui_ctx *pycui_ctx = ctx._ctx()
    cdef double pycui_result = cui_animate_spring(pycui_ctx, <uint32_t>id, <float>target, <float>duration, <float>bounce)
    return float(pycui_result)
