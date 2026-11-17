/* sizeof() of CUI's handle structs and setters for fields whose C name
 * is a Python keyword, for the generated wrappers.
 *
 * GENERATED FILE: produced by tools/gen_cui.py; do not edit by hand.
 */
#ifndef PYCUI_SIZES_H
#define PYCUI_SIZES_H

#include <cui/cui.h>

static size_t pycui_sizeof_cui_date_range(void) { return sizeof(cui_date_range); }
static size_t pycui_sizeof_cui_diff_range(void) { return sizeof(cui_diff_range); }
static size_t pycui_sizeof_cui_diff_row(void) { return sizeof(cui_diff_row); }
static size_t pycui_sizeof_cui_image_view(void) { return sizeof(cui_image_view); }
static size_t pycui_sizeof_cui_kanban_move(void) { return sizeof(cui_kanban_move); }
static size_t pycui_sizeof_cui_kv_pair(void) { return sizeof(cui_kv_pair); }
static size_t pycui_sizeof_cui_log_buffer(void) { return sizeof(cui_log_buffer); }
static size_t pycui_sizeof_cui_node_view(void) { return sizeof(cui_node_view); }
static size_t pycui_sizeof_cui_now_playing(void) { return sizeof(cui_now_playing); }
static size_t pycui_sizeof_cui_regex_match(void) { return sizeof(cui_regex_match); }
static size_t pycui_sizeof_cui_terminal_buffer(void) { return sizeof(cui_terminal_buffer); }
static void pycui_set_cui_box__(cui_box *target, int value) { target->_ = value; }
static void pycui_set_cui_card_opts__(cui_card_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_scroll_opts__(cui_scroll_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_split_opts__(cui_split_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_text_opts__(cui_text_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_button_opts__(cui_button_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_segmented_opts__(cui_segmented_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_check_opts__(cui_check_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_slider_opts__(cui_slider_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_chip_opts__(cui_chip_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_input_opts__(cui_input_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_number_opts__(cui_number_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_select_opts__(cui_select_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_date_opts__(cui_date_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tabs_opts__(cui_tabs_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_nav_opts__(cui_nav_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_popover_opts__(cui_popover_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tour_opts__(cui_tour_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_menu_opts__(cui_menu_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_menu_item_opts__(cui_menu_item_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dialog_opts__(cui_dialog_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_sheet_opts__(cui_sheet_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_toast_opts__(cui_toast_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_alert_opts__(cui_alert_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_progress_opts__(cui_progress_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_badge_opts__(cui_badge_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_avatar_opts__(cui_avatar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_empty_opts__(cui_empty_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_metric_opts__(cui_metric_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tree_opts__(cui_tree_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_list_item_opts__(cui_list_item_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_table_opts__(cui_table_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_chart_opts__(cui_chart_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_image_opts__(cui_image_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_image_viewer_opts__(cui_image_viewer_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_cropper_opts__(cui_cropper_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_radio_cards_opts__(cui_radio_cards_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tag_opts__(cui_tag_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_hold_opts__(cui_hold_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_timeline_opts__(cui_timeline_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_split_button_opts__(cui_split_button_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_toggle_group_opts__(cui_toggle_group_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_confirm_opts__(cui_confirm_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_status_button_opts__(cui_status_button_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_speed_dial_opts__(cui_speed_dial_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_user_menu_opts__(cui_user_menu_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_grid_opts__(cui_grid_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tree_table_opts__(cui_tree_table_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_path_bar_opts__(cui_path_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_file_browser_opts__(cui_file_browser_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_file_picker_opts__(cui_file_picker_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_code_opts__(cui_code_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_json_opts__(cui_json_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_markdown_opts__(cui_markdown_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_code_editor_opts__(cui_code_editor_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_diff_opts__(cui_diff_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_chat_opts__(cui_chat_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_comment_opts__(cui_comment_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_carousel_opts__(cui_carousel_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_compare_opts__(cui_compare_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_card_stack_opts__(cui_card_stack_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_counter_opts__(cui_counter_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_ticker_opts__(cui_ticker_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_heatmap_opts__(cui_heatmap_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_calendar_heatmap_opts__(cui_calendar_heatmap_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_treemap_opts__(cui_treemap_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_radar_opts__(cui_radar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_funnel_opts__(cui_funnel_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_sankey_link_from(cui_sankey_link *target, int value) { target->from = value; }
static void pycui_set_cui_sankey_opts__(cui_sankey_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_waffle_opts__(cui_waffle_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_split_bar_opts__(cui_split_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_bar_list_opts__(cui_bar_list_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_rings_opts__(cui_rings_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_scatter_opts__(cui_scatter_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_radial_gauge_opts__(cui_radial_gauge_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_candlestick_opts__(cui_candlestick_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_text_fx_opts__(cui_text_fx_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_gradient_text_opts__(cui_gradient_text_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_gradient_text_opts_from(cui_gradient_text_opts *target, cui_color value) { target->from = value; }
static void pycui_set_cui_spotlight_opts__(cui_spotlight_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_loader_opts__(cui_loader_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dock_opts__(cui_dock_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dock_item_opts__(cui_dock_item_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tab_bar_opts__(cui_tab_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tile_opts__(cui_tile_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_waveform_opts__(cui_waveform_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_now_playing_opts__(cui_now_playing_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_reasoning_opts__(cui_reasoning_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tool_call_opts__(cui_tool_call_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_agent_plan_opts__(cui_agent_plan_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_agent_status_opts__(cui_agent_status_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_context_opts__(cui_context_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_response_actions_opts__(cui_response_actions_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_prompt_suggestions_opts__(cui_prompt_suggestions_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_model_picker_opts__(cui_model_picker_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_composer_opts__(cui_composer_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_voice_orb_opts__(cui_voice_orb_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_kanban_column_opts__(cui_kanban_column_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_week_opts__(cui_week_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_month_opts__(cui_month_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_gantt_opts__(cui_gantt_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_hover_card_opts__(cui_hover_card_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_confirm_popover_opts__(cui_confirm_popover_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_expandable_text_opts__(cui_expandable_text_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_expandable_card_opts__(cui_expandable_card_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_banner_opts__(cui_banner_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_countdown_opts__(cui_countdown_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_checklist_opts__(cui_checklist_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_multi_select_opts__(cui_multi_select_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_date_range_opts__(cui_date_range_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_time_opts__(cui_time_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_wheel_opts__(cui_wheel_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_ruler_opts__(cui_ruler_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_histogram_opts__(cui_histogram_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_knob_opts__(cui_knob_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_fader_opts__(cui_fader_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_level_meter_opts__(cui_level_meter_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_signature_opts__(cui_signature_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dropzone_opts__(cui_dropzone_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_inline_edit_opts__(cui_inline_edit_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_scrub_opts__(cui_scrub_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_money_opts__(cui_money_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_shortcut_recorder_opts__(cui_shortcut_recorder_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_node_editor_opts__(cui_node_editor_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_node_opts__(cui_node_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_pin_opts__(cui_pin_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_menu_bar_opts__(cui_menu_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_menu_bar_menu_opts__(cui_menu_bar_menu_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_toolbar_opts__(cui_toolbar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_tool_opts__(cui_tool_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_status_bar_opts__(cui_status_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_status_item_opts__(cui_status_item_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_status_progress_opts__(cui_status_progress_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_doc_tabs_opts__(cui_doc_tabs_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dockspace_opts__(cui_dockspace_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dock_panel_opts__(cui_dock_panel_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_inspector_opts__(cui_inspector_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_prop_opts__(cui_prop_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_log_view_opts__(cui_log_view_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_terminal_opts__(cui_terminal_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_emoji_picker_opts__(cui_emoji_picker_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_hex_view_opts__(cui_hex_view_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_flame_opts__(cui_flame_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_curve_opts__(cui_curve_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_gradient_opts__(cui_gradient_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_timeline_editor_opts__(cui_timeline_editor_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_kv_editor_opts__(cui_kv_editor_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_problems_opts__(cui_problems_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_pipeline_opts__(cui_pipeline_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_query_opts__(cui_query_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_schedule_opts__(cui_schedule_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_keymap_opts__(cui_keymap_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_commit_graph_opts__(cui_commit_graph_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_graph_edge_from(cui_graph_edge *target, int value) { target->from = value; }
static void pycui_set_cui_graph_opts__(cui_graph_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_waterfall_opts__(cui_waterfall_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_trace_opts__(cui_trace_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_regex_tester_opts__(cui_regex_tester_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_test_explorer_opts__(cui_test_explorer_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_stack_trace_opts__(cui_stack_trace_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_request_bar_opts__(cui_request_bar_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_uptime_opts__(cui_uptime_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_time_histogram_opts__(cui_time_histogram_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_coverage_opts__(cui_coverage_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_blame_opts__(cui_blame_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_feature_flags_opts__(cui_feature_flags_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_api_param_in(cui_api_param *target, const char * value) { target->in = value; }
static void pycui_set_cui_api_explorer_opts__(cui_api_explorer_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dot_chart_opts__(cui_dot_chart_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_event_track_opts__(cui_event_track_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_readout_opts__(cui_readout_opts *target, int value) { target->_ = value; }
static void pycui_set_cui_dot_display_opts__(cui_dot_display_opts *target, int value) { target->_ = value; }

#endif /* PYCUI_SIZES_H */
