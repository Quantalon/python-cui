# Generated API coverage

Produced by `tools/gen_cui.py`; regenerated with the bindings.

- callable CUI functions: **500**
- wrapped: **375**
- left to phase 3: **125**

Wrapped functions take the context first, option structs as keyword
arguments, and return out-parameters alongside the C return value.

## Not wrapped yet

| function | why |
| --- | --- |
| `cui_api_explorer_ex` | takes `const cui_api_endpoint *`, a data array of a struct with pointers |
| `cui_app_backend` | wrapped by hand in `_cui.pyx` |
| `cui_app_create` | wrapped by hand in `_cui.pyx` |
| `cui_app_destroy` | wrapped by hand in `_cui.pyx` |
| `cui_app_file_dialog` | wrapped by hand in `_cui.pyx` |
| `cui_app_frame` | wrapped by hand in `_cui.pyx` |
| `cui_app_is_software` | wrapped by hand in `_cui.pyx` |
| `cui_app_native_window` | wrapped by hand in `_cui.pyx` |
| `cui_app_open_url` | wrapped by hand in `_cui.pyx` |
| `cui_app_quit` | wrapped by hand in `_cui.pyx` |
| `cui_app_run` | wrapped by hand in `_cui.pyx` |
| `cui_app_screenshot` | wrapped by hand in `_cui.pyx` |
| `cui_app_set_size` | wrapped by hand in `_cui.pyx` |
| `cui_app_set_title` | wrapped by hand in `_cui.pyx` |
| `cui_app_size` | wrapped by hand in `_cui.pyx` |
| `cui_app_ui` | wrapped by hand in `_cui.pyx` |
| `cui_bar_chart_ex` | takes `const cui_series *`, a data array of a struct with pointers |
| `cui_begin_frame` | wrapped by hand in `_cui.pyx` |
| `cui_blame_ex` | returns `cui_blame_result` |
| `cui_canvas` | needs a C callback |
| `cui_checklist_ex` | needs caller-allocated struct storage |
| `cui_code_editor_ex` | returns `cui_code_editor_result` |
| `cui_commit_graph_ex` | takes `const cui_commit *`, a data array of a struct with pointers |
| `cui_coverage_ex` | returns `cui_coverage_result` |
| `cui_create` | wrapped by hand in `_cui.pyx` |
| `cui_curve_editor_ex` | returns `cui_curve_result` |
| `cui_delta_time` | wrapped by hand in `_cui.pyx` |
| `cui_destroy` | wrapped by hand in `_cui.pyx` |
| `cui_diff_compute` | needs caller-allocated struct storage |
| `cui_diff_view_ex` | returns `cui_diff_result` |
| `cui_doc_tabs_ex` | returns `cui_doc_tabs_result` |
| `cui_dot_chart_ex` | takes `const cui_dot_series *`, a data array of a struct with pointers |
| `cui_end_frame` | wrapped by hand in `_cui.pyx` |
| `cui_event_track_ex` | returns `cui_event_track_result` |
| `cui_feature_flags_ex` | needs caller-allocated struct storage |
| `cui_file_browser_ex` | returns `cui_file_browser_result` |
| `cui_filter_bar` | takes `const cui_filter_field *`, a data array of a struct with pointers |
| `cui_flame_graph_ex` | returns `cui_flame_result` |
| `cui_flame_sort` | needs caller-allocated struct storage |
| `cui_frame_count` | wrapped by hand in `_cui.pyx` |
| `cui_fs_list` | needs caller-allocated struct storage |
| `cui_gantt_ex` | needs caller-allocated struct storage |
| `cui_get_draw_data` | wrapped by hand in `_cui.pyx` |
| `cui_get_rect` | wrapped by hand in `_cui.pyx` |
| `cui_get_strings` | returns `const cui_strings *` |
| `cui_gl_create` | parameter `loader` has type `cui_gl_loader` |
| `cui_gl_destroy` | takes `cui_gl_renderer *`, a binding-owned type |
| `cui_gl_iface` | takes `cui_gl_renderer *`, a binding-owned type |
| `cui_gl_is_software` | takes `const cui_gl_renderer *`, a binding-owned type |
| `cui_gl_read_pixels` | takes `cui_gl_renderer *`, a binding-owned type |
| `cui_gl_render` | takes `cui_gl_renderer *`, a binding-owned type |
| `cui_gradient_editor_ex` | returns `cui_gradient_result` |
| `cui_graph_view_ex` | returns `cui_graph_result` |
| `cui_hex_view_ex` | returns `cui_hex_result` |
| `cui_is_disabled` | wrapped by hand in `_cui.pyx` |
| `cui_keymap_ex` | returns `cui_keymap_result` |
| `cui_last_hovered` | wrapped by hand in `_cui.pyx` |
| `cui_last_id` | wrapped by hand in `_cui.pyx` |
| `cui_last_rect` | wrapped by hand in `_cui.pyx` |
| `cui_line_chart_ex` | takes `const cui_series *`, a data array of a struct with pointers |
| `cui_log_append` | variadic C function |
| `cui_log_appendv` | needs a C callback |
| `cui_log_get` | takes `const cui_log_buffer *`, a data array of a struct with pointers |
| `cui_log_init` | text buffer without a context to own it |
| `cui_make_id` | wrapped by hand in `_cui.pyx` |
| `cui_markdown_ex` | returns `cui_markdown_result` |
| `cui_measure_text` | wrapped by hand in `_cui.pyx` |
| `cui_month_calendar_ex` | returns `cui_month_result` |
| `cui_needs_redraw` | wrapped by hand in `_cui.pyx` |
| `cui_next_wakeup` | wrapped by hand in `_cui.pyx` |
| `cui_path_bar_ex` | returns `cui_path_bar_result` |
| `cui_pipeline_ex` | returns `cui_pipeline_result` |
| `cui_pop_disabled` | wrapped by hand in `_cui.pyx` |
| `cui_pop_id` | wrapped by hand in `_cui.pyx` |
| `cui_problems_ex` | returns `cui_problems_result` |
| `cui_push_disabled` | wrapped by hand in `_cui.pyx` |
| `cui_push_id` | wrapped by hand in `_cui.pyx` |
| `cui_push_id_int` | wrapped by hand in `_cui.pyx` |
| `cui_query_builder_ex` | takes `const cui_query_field *`, a data array of a struct with pointers |
| `cui_query_match` | takes `const cui_query_field *`, a data array of a struct with pointers |
| `cui_query_text` | takes `const cui_query_field *`, a data array of a struct with pointers |
| `cui_radar_chart_ex` | takes `const cui_series *`, a data array of a struct with pointers |
| `cui_reactions` | needs caller-allocated struct storage |
| `cui_regex_tester_ex` | returns `cui_regex_tester_result` |
| `cui_request_bar_ex` | returns `cui_request_bar_result` |
| `cui_request_redraw` | wrapped by hand in `_cui.pyx` |
| `cui_request_wakeup` | wrapped by hand in `_cui.pyx` |
| `cui_scatter_chart_ex` | takes `const cui_scatter_series *`, a data array of a struct with pointers |
| `cui_schedule_picker_ex` | returns `cui_schedule_result` |
| `cui_set_platform` | takes `const cui_platform_iface *`, a binding-owned type |
| `cui_set_renderer` | wrapped by hand in `_cui.pyx` |
| `cui_set_strings` | takes `const cui_strings *`, a binding-owned type |
| `cui_set_viewport` | wrapped by hand in `_cui.pyx` |
| `cui_signature_points` | parameter `points` has type `const cui_vec2 **` |
| `cui_stack_trace_ex` | takes `const cui_stack_frame *`, a data array of a struct with pointers |
| `cui_state` | returns `void *` |
| `cui_state_on_free` | needs a C callback |
| `cui_sw_create` | wrapped by hand in `_cui.pyx` |
| `cui_sw_destroy` | wrapped by hand in `_cui.pyx` |
| `cui_sw_iface` | wrapped by hand in `_cui.pyx` |
| `cui_sw_last_damage` | wrapped by hand in `_cui.pyx` |
| `cui_sw_render` | wrapped by hand in `_cui.pyx` |
| `cui_sw_set_incremental` | wrapped by hand in `_cui.pyx` |
| `cui_sw_set_threads` | wrapped by hand in `_cui.pyx` |
| `cui_table_cell_textf` | variadic C function |
| `cui_terminal_ex` | returns `cui_terminal_result` |
| `cui_terminal_init` | text buffer without a context to own it |
| `cui_terminal_printf` | variadic C function |
| `cui_test_explorer_ex` | returns `cui_test_explorer_result` |
| `cui_textf` | variadic C function |
| `cui_theme_get` | returns `cui_theme *` |
| `cui_time` | wrapped by hand in `_cui.pyx` |
| `cui_time_histogram_ex` | takes `const cui_histogram_series *`, a data array of a struct with pointers |
| `cui_timeline_editor_ex` | needs caller-allocated struct storage |
| `cui_trace_sort` | needs caller-allocated struct storage |
| `cui_trace_view_ex` | needs caller-allocated struct storage |
| `cui_tree_sort` | needs caller-allocated struct storage |
| `cui_tree_table_begin_ex` | needs caller-allocated struct storage |
| `cui_tree_table_end` | returns `cui_tree_table_events` |
| `cui_uptime_ex` | takes `const cui_uptime_service *`, a data array of a struct with pointers |
| `cui_url_params` | needs caller-allocated struct storage |
| `cui_url_set_params` | takes `const cui_kv_pair *`, a data array of a struct with pointers |
| `cui_waterfall_ex` | takes `const cui_net_request *`, a data array of a struct with pointers |
| `cui_week_calendar_ex` | needs caller-allocated struct storage |
| `cui_write_png` | wrapped by hand in `_cui.pyx` |
