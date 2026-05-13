# Frontend Surface Coverage Map

Status: Active no-missed-surfaces map

This map lists destination roots, child surfaces, drill-downs, sheets, trays, modal/overlay states, empty/error/recovery states, canon status, recipe file, and source truth.

## Shell

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Global App Shell | app_shell | global | intended_canon | `docs/canon/frontend/recipes/shell/global_app_shell.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Destination Dock | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/destination_dock.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Destination Tab Item | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/destination_tab_item.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Compact Surface Header | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/compact_surface_header.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Context Crown | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/context_crown.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Back Navigation | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/back_navigation.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Sheet Chrome | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/sheet_chrome.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Tray Chrome | navigation_chrome | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/tray_chrome.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Receipt Toast / Inline Confirmation | overlay | component_surface | intended_canon | `docs/canon/frontend/recipes/shell/receipt_toast_inline_confirmation.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Global Empty State Shell | empty_state | global | intended_canon | `docs/canon/frontend/recipes/shell/global_empty_state_shell.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Global Error / Fallback Shell | error_state | global | intended_canon | `docs/canon/frontend/recipes/shell/global_error_fallback_shell.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Today

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Today Root / Reality Meridian | top_level_surface | destination_root | intended_canon | `docs/canon/frontend/recipes/today/today_root_reality_meridian.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Current Context Header | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_current_context_header.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Start Here Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_start_here_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Reality Meridian Rail | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_reality_meridian_rail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Recommended Step Object | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_recommended_step_object.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Now / Next / Later Sequence | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_now_next_later_sequence.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Upcoming Commitments Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_upcoming_commitments_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Closure Prompt Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_closure_prompt_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Receipt Shelf | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_receipt_shelf.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Source Freshness Indicator | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/today_source_freshness_indicator.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Step Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/step_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Step Session | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/step_session.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Recommendation Source Sheet | sheet | transient_surface | intended_canon | `docs/canon/frontend/recipes/today/recommendation_source_sheet.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Closure Sheet | sheet | transient_surface | intended_canon | `docs/canon/frontend/recipes/today/closure_sheet.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Receipt Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/receipt_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Proof Attachment Detail | drill_down | secondary_surface | planned_canon | `docs/canon/frontend/recipes/today/proof_attachment_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Adjust Plan / Reflow Preview Entry | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/adjust_plan_reflow_preview_entry.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Blocked Detail | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/blocked_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Waiting Detail | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/waiting_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goal Thread Context from Today | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/today/goal_thread_context_from_today.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Local Runtime Source Detail from Today | drill_down | secondary_surface | unresolved_direction | `docs/canon/frontend/recipes/today/local_runtime_source_detail_from_today.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Empty State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_empty_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today No Schedule Data State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_no_schedule_data_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Overloaded State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_overloaded_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Recovery State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_recovery_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Vacation / Away State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/today/today_vacation_away_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Protected Time State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_protected_time_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today Stale Recommendation State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/today/today_stale_recommendation_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Goals

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Goals Root / Constellation Atlas | top_level_surface | destination_root | intended_canon | `docs/canon/frontend/recipes/goals/goals_root_constellation_atlas.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals Life Area Map | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/goals/goals_life_area_map.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Selected Life Area Surface | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/goals/selected_life_area_surface.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Ambition Graph | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/ambition_graph.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goal Thread Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/goal_thread_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goal Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/goal_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Commitment Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/commitment_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Proof Trail | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/goals/proof_trail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Proof Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/proof_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Proof Gap State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/proof_gap_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Blocker Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/blocker_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Alternate Path Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/alternate_path_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Milestone Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/milestone_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Recommended Step Context from Goals | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/goals/recommended_step_context_from_goals.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Reflection / Recovery Detail | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/reflection_recovery_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals Empty State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/goals_empty_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals Review State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/goals_review_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals Blocked State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/goals_blocked_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals Archive / Historical Goal State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/goals/goals_archive_historical_goal_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Capture

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Capture Root / Atmosphere Composer | top_level_surface | destination_root | intended_canon | `docs/canon/frontend/recipes/capture/capture_root_atmosphere_composer.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Idle Composer | composer_state | primary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_idle_composer.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Active Text Entry | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_active_text_entry.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Dictation State | row | state_variant | planned_canon | `docs/canon/frontend/recipes/capture/capture_dictation_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Attachment / Proof Picker | drill_down | secondary_surface | planned_canon | `docs/canon/frontend/recipes/capture/capture_attachment_proof_picker.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Post-Input Route Reveal | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_post_input_route_reveal.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Save as Proof Route | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_save_as_proof_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Make Commitment Route | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_make_commitment_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Grow into Goal Route | row | component_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_grow_into_goal_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Mark Constraint Route | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_mark_constraint_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Reflect Route | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_reflect_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Hold / Needs a Place Route | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/capture/capture_hold_needs_a_place_route.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Receipt | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/capture/capture_receipt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Parse Uncertain State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/capture/capture_parse_uncertain_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Offline Local-Only State | row | state_variant | planned_canon | `docs/canon/frontend/recipes/capture/capture_offline_local_only_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Error / Failed Attachment State | error_state | state_variant | planned_canon | `docs/canon/frontend/recipes/capture/capture_error_failed_attachment_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Empty First-Use State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/capture/capture_empty_first_use_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Time

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Time Root / LifeShape Field | top_level_surface | destination_root | intended_canon | `docs/canon/frontend/recipes/time/time_root_lifeshape_field.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Scope Control | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/time_scope_control.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Day LifeShape Surface | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/day_lifeshape_surface.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Week LifeShape Surface | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/week_lifeshape_surface.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Month LifeShape Surface | drill_down | primary_surface | planned_canon | `docs/canon/frontend/recipes/time/month_lifeshape_surface.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Open Time Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/open_time_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Protected Time Region | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/time/protected_time_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Pressure Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/pressure_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Best Fit Region | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/time/best_fit_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Recovery / Flex Region | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/time/recovery_flex_region.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Review Pressure Surface | drill_down | primary_surface | unresolved_direction | `docs/canon/frontend/recipes/time/review_pressure_surface.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Best Fit Explanation Sheet | sheet | transient_surface | intended_canon | `docs/canon/frontend/recipes/time/best_fit_explanation_sheet.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Protected Time Detail | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/time/protected_time_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Day Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/day_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Week Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/week_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Month Detail | drill_down | secondary_surface | unresolved_direction | `docs/canon/frontend/recipes/time/month_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Reflow Preview Tray | tray | transient_surface | intended_canon | `docs/canon/frontend/recipes/time/reflow_preview_tray.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Shape Day Flow | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/shape_day_flow.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Reflow Week Flow | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/reflow_week_flow.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Shape Month Flow | drill_down | secondary_surface | unresolved_direction | `docs/canon/frontend/recipes/time/shape_month_flow.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Receipt Detail | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/time_receipt_detail.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Schedule & Availability Entry | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/schedule_and_availability_entry.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Planning Defaults Entry | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/time/planning_defaults_entry.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Vacation / Away Time Entry | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/time/vacation_away_time_entry.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time No Calendar Data State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/time/time_no_calendar_data_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Overloaded State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/time/time_overloaded_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Protected Block State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/time/time_protected_block_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Vacation / Away State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/time/time_vacation_away_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time Stale Source State | state_surface | state_variant | unresolved_direction | `docs/canon/frontend/recipes/time/time_stale_source_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## You

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| You Root / User System Profile | top_level_surface | destination_root | intended_canon | `docs/canon/frontend/recipes/you/you_root_user_system_profile.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| User Profile Header | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/you/user_profile_header.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Local Runtime Trust Panel | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/you/local_runtime_trust_panel.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Planning Setup Section | drill_down | primary_surface | intended_canon | `docs/canon/frontend/recipes/you/planning_setup_section.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Schedule & Availability | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/schedule_and_availability.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Planning Defaults | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/planning_defaults.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Vacation / Away Time | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/you/vacation_away_time.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Automation & Trust | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/automation_and_trust.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Notifications | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/notifications.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture Preferences | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/capture_preferences.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Focus / Session Defaults | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/focus_session_defaults.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Privacy | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/privacy.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Personal Runtime | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/personal_runtime.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Local Data / Reset / Forget | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/local_data_reset_forget.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Help | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/help.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| About Ambitions | drill_down | secondary_surface | intended_canon | `docs/canon/frontend/recipes/you/about_ambitions.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| You Empty / First-Run State | empty_state | state_variant | intended_canon | `docs/canon/frontend/recipes/you/you_empty_first_run_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| You Trust Warning State | state_surface | state_variant | intended_canon | `docs/canon/frontend/recipes/you/you_trust_warning_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| You Offline Local-Only State | row | state_variant | planned_canon | `docs/canon/frontend/recipes/you/you_offline_local_only_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Cross Surface

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| Commitment Staging Tray | tray | transient_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/commitment_staging_tray.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Reflow Preview Tray | tray | transient_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/reflow_preview_tray.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Receipt System | drill_down | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/receipt_system.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Closure System | drill_down | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/closure_system.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Proof Trail System | drill_down | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/proof_trail_system.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Recommendation Source System | drill_down | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/recommendation_source_system.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Why This Sheet | sheet | transient_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/why_this_sheet.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Source Freshness Badge | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/source_freshness_badge.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Still Counts State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/still_counts_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Moved State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/moved_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Skipped / Not Needed State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/skipped_not_needed_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Blocked State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/blocked_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Waiting State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/waiting_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Needs Recovery State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/needs_recovery_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Needs Review State | state_surface | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/needs_review_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Protected Marker | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/protected_marker.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Pressure Marker | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/pressure_marker.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Best Fit Marker | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/best_fit_marker.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Open Marker | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/open_marker.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Primary CTA | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/primary_cta.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Secondary CTA | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/secondary_cta.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Destructive CTA | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/destructive_cta.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Disabled CTA | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/disabled_cta.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Chevron / Disclosure Row | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/chevron_disclosure_row.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| QuietGlass Wrapper | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/quietglass_wrapper.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| GraphiteRecess Base | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/graphiterecess_base.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| LuminousTrace State Line | row | state_variant | planned_canon | `docs/canon/frontend/recipes/cross_surface/luminoustrace_state_line.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| CelestialField Semantic Layer | row | component_surface | planned_canon | `docs/canon/frontend/recipes/cross_surface/celestialfield_semantic_layer.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |

## Onboarding

| Surface | Type | Level | Status | Recipe File | Source Truth |
|---|---|---|---|---|---|
| First Run Root | onboarding | destination_root | planned_canon | `docs/canon/frontend/recipes/onboarding/first_run_root.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Schedule Setup Prompt | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/schedule_setup_prompt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Planning Defaults Prompt | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/planning_defaults_prompt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Privacy / Local Runtime Explanation | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/privacy_local_runtime_explanation.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Capture First-Use Prompt | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/capture_first_use_prompt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Goals First-Use Prompt | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/goals_first_use_prompt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Time First-Use Prompt | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/time_first_use_prompt.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
| Today First-Use State | onboarding | component_surface | planned_canon | `docs/canon/frontend/recipes/onboarding/today_first_use_state.md` | `docs/truth/PRODUCT_DESIGN_TRUTH.md` |
