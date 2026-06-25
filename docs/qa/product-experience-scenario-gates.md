# Product Experience Scenario Gates

Status: Active QA index for `docs/truth/PRODUCT_EXPERIENCE_CANON.md`  
Scope: Scenario gates from the official v1 Product Experience Canon  
Owner posture: QA planning and evidence index, not implementation proof
Last audited commit: f51576616f06c3127c2add5f3a94f284e178b6ba
Last audited date: 2026-06-24

Machine-readable companion: `docs/qa/product-experience-scenario-gates.yaml`.

The YAML companion is the machine-readable scenario gate index. Keep it aligned with this Markdown table whenever gate IDs, statuses, evidence paths, future proof, canon source, owner area, or tests change.

Statuses mean:

- Existing: direct evidence was found for the user-visible behavior in current source/tests.
- Partial: related source/tests exist, but the full gate is not proven.
- Missing: inspection found no sufficient source/test evidence for the gate.
- Unknown: not enough evidence was inspected in this docs train to classify confidently.

## Origin Golden Scenario

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `origin_high_ambition_low_operating_structure_user_can_start` | A high-agency user with more ambition than operating structure can see what matters and start with a fitting Step. | Partial | `docs/truth/PRODUCT_ORIGIN_TRUTH.md`, `Native/Ambitions/Projection/SurfaceLenses/TodayExecutionProjector.swift`, `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift` | End-to-end first-session scenario, rendered Today proof, accessibility proof |
| `origin_many_goals_many_obligations_today_remains_clear` | Many simultaneous goals and obligations do not turn Today into a cluttered list or dashboard. | Partial | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `Native/Ambitions/Projection/SurfaceLenses/TodayExecutionProjector.swift` | Overloaded-day scenario test, rendered first-viewport proof, visual review |
| `origin_goal_without_known_path_generates_clarifying_path` | A goal without a known path generates clarifying questions or a provisional path instead of generic failure. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalClarificationModels.swift`, `Native/AmbitionsTests/Services/GoalClarificationServiceTests.swift` | Goal intake UI/runtime proof with clarification, provisional save, and path continuation |
| `origin_user_not_starting_from_zero_when_life_capital_exists` | Existing Life Capital influences planning so the user is not treated like a beginner when relevant proof or capability exists. | Missing | None found for first-class Life Capital planning influence | Life Capital model, path-shortening test, You surface proof, receipt/proof trail |
| `origin_missed_obligation_asks_what_changed_without_shame` | A missed obligation asks what changed and offers recovery without shame or productivity scoring. | Partial | `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` | Rendered missed-obligation interaction, screenshot/manual review, accessibility and device proof |
| `origin_new_goal_conflict_shows_make_room_options` | Adding a conflicting new goal shows Make room options instead of silently overcommitting the schedule. | Missing | None found for full Make room flow | Capacity simulation test, Make room options UI, receipt and persistence proof |

## Foundation

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `foundation_reminder_can_be_created_completed_and_rescheduled` | User can create, complete, and reschedule a reminder-like Step. | Partial | `Native/Ambitions/Core/Domain/Planning/`, `Native/Ambitions/Projection/Commands/CommandRouter.swift` | Focused create/complete/reschedule test, rendered UI proof, persistence proof |
| `foundation_recurring_step_repeats_and_can_be_paused` | Recurring Steps repeat and can be paused. | Partial | `Native/Ambitions/Core/Domain/Planning/PlanningDomainModels.swift`, `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`, `Native/AmbitionsTests/Runtime/RecurringStepLifecycleServiceTests.swift` | Rendered recurring Step UI test, accessibility proof, device/release proof, notification delivery proof if claimed |
| `foundation_quick_capture_saves_without_network` | Quick Capture saves locally without network. | Partial | `Native/Ambitions/Projection/OverlayScenes/CaptureStageScene.swift`, `Native/Ambitions/Core/Persistence/`, `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift` | Rendered Capture save proof, network-disabled device workflow, release evidence |
| `foundation_calendar_planning_shows_fixed_points_and_open_windows` | Time shows fixed points and open windows. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCalendarContracts.swift`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift` | Rendered Time proof with fixed/open windows and accessibility labels |
| `foundation_search_finds_goals_steps_proof_life_capital_and_settings` | Search finds goals, Steps, proof, Life Capital, and settings. | Partial | `Native/Ambitions/Core/Runtime/MemoryLensService.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceEverythingSearchProjection.swift`, `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift` | First-class Life Capital and Future Steps search proof, rendered route/accessibility proof |
| `foundation_notification_copy_is_private_by_default` | Notifications use private lock-screen copy by default. | Partial | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`, `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift` | Device lock-screen proof, permission settings proof, delivered notification screenshot, end-to-end app tap-routing proof |
| `foundation_offline_core_runs_without_account` | Core app runs without account or network. | Partial | `docs/truth/IMPLEMENTATION_TRUTH.md`, `Native/Ambitions/Core/Persistence/`, `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift`, `Native/AmbitionsTests/Time/P1DTimeFoundationTests.swift` | Network-disabled device workflow, no-account launch matrix, release evidence |
| `foundation_completion_creates_visible_closure` | Completing work creates visible closure. | Partial | `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`, `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` | Broader completion UI proof, receipt/proof assertion across rendered paths, accessibility proof |
| `foundation_missed_step_asks_what_changed` | Missed Step asks what changed. | Partial | `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` | Rendered missed-step recovery options, screenshot/manual review, accessibility and device proof |

## Goal Path

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `goal_creation_generates_full_scheduled_path` | Goal creation produces a full scheduled path. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrator.swift` | End-to-end goal creation path and schedule test |
| `vague_goal_requests_clarification` | Vague goal asks clarifying questions. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalClarificationModels.swift`, `Native/AmbitionsTests/Services/GoalClarificationServiceTests.swift` | UI flow with skip/partial answer and saved provisional state |
| `goal_with_deadline_places_future_steps` | Deadline goal places Future Steps. | Missing | Goal timing exists, Future Step placement not proven | Deadline-to-Future-Step scheduling test |
| `goal_without_deadline_generates_flexible_path` | Goal without deadline gets flexible path. | Partial | `Native/Ambitions/Core/Domain/Planning/DeterministicGoalPlanner.swift` | Flexible scheduled path proof |
| `lifelong_goal_creates_cadence_and_renewable_horizon` | Lifelong goal creates cadence and renewable horizon. | Missing | None found | Lifelong goal model, rolling horizon tests, review renewal proof |
| `goal_path_has_stages_milestones_steps_proof_and_review_points` | Goal path includes stages, milestones, Steps, proof, and review points. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels+02-GoalCompiledPathCompilerCore+02-compile.swift` | Full path object and rendered drilldown proof |
| `goal_drilldown_shows_full_live_visual_path` | Goal drilldown shows live visual path. | Partial | `Native/Ambitions/DesignSystem/ProductObjects/GoalComponents+05-LifePathThreadSurface.swift` | UI test and visual review of full path |
| `today_shows_only_relevant_schedule_slice` | Today shows the current slice, not the entire long-term path. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TodayExecutionProjector.swift` | Today scenario test and screenshot proof |
| `time_shows_whether_goal_fits` | Time shows whether a goal fits. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimePressureProjection.swift`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCapacity.swift` | Fit/over-capacity scenario test |

## Scheduling / Future Steps

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `future_step_has_time_window` | Future Step has a time window. | Missing | None found as named Future Step | Future Step model, window persistence, Time rendering |
| `future_step_links_to_goal_path_and_stage` | Future Step links to goal path and stage. | Missing | Path stages exist, Future Step link not found | Relationship tests and drilldown proof |
| `far_future_step_uses_path_impact_preview` | Far-future edit shows path-impact preview. | Missing | None found | Edit preview test and UI proof |
| `near_term_step_edits_normally` | Near-term Step edits normally. | Partial | `Native/Ambitions/Projection/Commands/CommandRouter.swift` | Edit UI/runtime/persistence proof |
| `full_path_scheduling_does_not_create_vague_someday_items` | Scheduling avoids vague someday items. | Missing | None found | Scheduler assertions and copy audit |
| `future_steps_are_visually_lighter_than_committed_near_term_steps` | Far Future Steps render lighter than near-term committed Steps. | Missing | None found | Rendered UI proof and accessibility labels |

## Adjustment

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `automatic_future_adjustment_occurs_only_where_allowed` | Automatic adjustment follows automation permissions. | Missing | None found | Automation policy tests |
| `automatic_adjustment_does_not_move_next_seven_days_silently` | Next seven days are not silently moved. | Missing | None found | Protected-window guard tests |
| `user_caused_adjustment_shows_impact_summary` | User-caused adjustment shows impact summary. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimeReflowDecisionProjector.swift` | User-caused change UI and receipt proof |
| `life_capital_change_shows_affected_paths` | Life Capital edit shows affected paths. | Missing | None found for Life Capital | Life Capital edit/resimulation proof |
| `deadline_change_resimulates_path` | Deadline change resimulates path. | Partial | `Native/AmbitionsTests/Runtime/StepReallocationRuntimeBridgeTests.swift` | End-to-end deadline change test |
| `missed_step_asks_what_changed` | Missed Step asks what changed. | Partial | `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift` | Missed-step interaction proof |
| `ignored_plan_suggests_contextual_recovery` | Ignored plan suggests contextual recovery. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimeCalendarRecoveryProjection.swift` | Multi-day ignored-plan scenario proof |

## Conflict

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `new_goal_over_capacity_shows_this_does_not_fit_yet` | Over-capacity goal shows `This does not fit yet`. | Missing | None found | Capacity simulation UI and copy test |
| `make_room_flow_lists_resolution_options` | Make room flow lists resolution options. | Missing | None found | Make room flow test |
| `add_with_conflict_creates_path_and_visible_conflict` | Add with conflict creates path and visible conflict. | Missing | None found | Add-with-conflict runtime/UI proof |
| `lower_pace_option_reduces_future_step_density` | Lower pace reduces Future Step density. | Missing | None found | Pace simulation test |
| `change_deadline_option_resimulates_fit` | Change deadline resimulates fit. | Partial | `Native/AmbitionsTests/Runtime/StepReallocationRuntimeBridgeTests.swift` | Fit-state resimulation proof |
| `pause_another_goal_option_requires_user_approval` | Pausing another goal requires approval. | Missing | None found | Approval flow and receipt proof |
| `conflict_state_remains_visible_until_resolved` | Conflict remains visible until resolved. | Missing | None found | Persistence/relaunch conflict proof |

## Priority

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `priority_supports_low_normal_high` | Priority supports Low, Normal, High. | Partial | `Native/Ambitions/Projection/Commands/AmbitionsCommandTaxonomy.swift` | User-facing priority model and UI proof |
| `priority_can_be_inferred` | Priority can be inferred. | Partial | `Native/Ambitions/Core/Domain/GoalBelievabilityModels.swift` | Inference tests and explanation proof |
| `priority_can_be_overridden_by_user` | User can override priority. | Unknown | Command/payload support not fully inspected | Override UI/runtime test |
| `priority_does_not_include_must_fit_as_goal_type` | `Must Fit` is not a goal type. | Unknown | No direct source hit found in sampled paths | Forbidden-language scan and model assertion |
| `make_room_is_action_not_priority` | Make room is an action, not priority. | Missing | None found | Flow/model tests |
| `lower_priority_goals_can_be_suggested_for_pause_or_move` | Lower-priority goals can be suggested for pause/move. | Missing | None found | Conflict-resolution simulation test |

## Life Capital

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `life_capital_visible_in_you` | Life Capital appears in You. | Missing | No named `Life Capital` surface found | You section UI proof |
| `life_capital_supports_capability_credential_resource_relationship_accomplishment_proof_pattern` | Life Capital supports all canon content types. | Partial | `Native/Ambitions/Core/Domain/SourceAtlasPackModels+06-SourceAtlasPack.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceLifeContextRuntimeProjection.swift` | Dedicated Life Capital model/tests |
| `life_capital_manual_edit_resimulates_affected_paths` | Manual edit resimulates affected paths. | Missing | None found | Edit/resimulation/receipt proof |
| `life_capital_archive_stops_future_planning_influence` | Archive stops future planning influence. | Missing | None found | Archive influence tests |
| `life_capital_delete_removes_item` | Delete removes item. | Missing | None found | Delete/history/search tests |
| `life_capital_patterns_show_broad_stats` | Patterns show broad stats. | Partial | `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceLearningControlsProjection.swift` | Pattern rows and planning effect proof |
| `life_capital_prevents_beginner_path_when_user_has_relevant_capability` | Relevant capability prevents beginner path. | Missing | None found | Capability-aware path-shortening test |
| `life_capital_relationship_resource_can_influence_goal_path` | Relationship/resource can influence path. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels+02-GoalResourceGraphBuilderCore.swift` | Life Capital to path influence proof |

## Proof / Progress

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `proof_optional_but_attachable` | Proof is optional and attachable. | Partial | `Native/Ambitions/Core/Persistence/PersistenceContracts.swift`, `Native/Ambitions/DesignSystem/ProductObjects/ProofStitchView.swift` | Add-proof flow and optionality tests |
| `proof_not_graded_by_strength` | Proof is not graded by strength. | Unknown | Source Atlas has proof-strength concepts for source/reference contexts | Product proof UI audit |
| `completed_step_can_create_proof` | Completed Step can create proof. | Partial | `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift` | Completion-to-proof test |
| `proof_can_update_life_capital` | Proof can update Life Capital. | Missing | None found | Proof-to-Life-Capital influence proof |
| `pivot_preserves_progress` | Pivot preserves progress. | Missing | None found | Pivot transfer scenario test |
| `pivot_does_not_create_false_completion` | Pivot does not falsely complete new work. | Missing | None found | No-false-completion assertions |
| `still_counts_preserves_thread` | Still counts preserves thread. | Partial | `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift` | Recovery/pivot behavior proof |
| `review_surfaces_accomplishments_and_proof` | Review surfaces accomplishments and proof. | Partial | `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceReviewProjection.swift` | Review UI/export proof |

## Source Atlas

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `source_atlas_invisible_by_default` | Source Atlas is invisible by default. | Partial | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceSourceAtlasPrimaryProjection.swift` | Surface audit proving no marketplace/center |
| `source_atlas_does_not_upload_private_user_context` | Source Atlas does not upload private context. | Partial | `Native/Ambitions/Core/Domain/SourceAtlasPackModels+06-SourceAtlasPack.swift`, `docs/truth/RELEASE_TRUTH.md` | Request-shape privacy proof |
| `source_atlas_pack_not_browsed_as_marketplace` | User does not browse packs as marketplace. | Partial | `docs/truth/PRODUCT_EXPERIENCE_CANON.md` | UI audit and route absence test |
| `source_atlas_enriches_path_when_relevant` | Source Atlas enriches path locally. | Partial | `Native/Ambitions/Core/Domain/SourceAtlasPackModels+06-SourceAtlasPack.swift` | Local composition test |
| `source_inspection_available_when_user_asks_why` | Source inspection appears when asked why. | Partial | `Native/Ambitions/Projection/OverlayScenes/InspectionStageScene.swift`, `Native/Ambitions/Trust/` | Inspection UI proof |
| `source_freshness_change_can_trigger_review_state` | Freshness change can trigger review. | Partial | `Native/Ambitions/Core/Domain/GoalEngine/GoalFreshnessUpdateModels.swift` | Freshness scenario test |

## Onboarding

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `onboarding_uses_chapters` | Onboarding uses chapters. | Missing | None found | Chapter model/UI proof |
| `onboarding_saves_every_answer_immediately` | Every answer saves immediately. | Missing | None found | Persistence test |
| `onboarding_allows_skip_without_data_loss` | Skip does not lose data. | Missing | None found | Skip/resume test |
| `onboarding_progress_shows_percentage` | Setup progress shows weighted percentage. | Missing | None found | Progress calculation/UI proof |
| `setup_personalization_available_in_you` | Setup & Personalization remains in You. | Missing | None found as named section | You route proof |
| `first_goal_recommended_but_skippable` | First goal is recommended but skippable. | Missing | None found | Onboarding flow test |
| `first_path_preview_generated_when_first_goal_exists` | First goal creates first path preview. | Missing | None found | First path preview test |

## Reviews

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `week_review_user_launched` | Week in Review is user-launched. | Missing | Reviews projection exists, Week shell not proven | User-launched Week review UI test |
| `month_review_user_launched` | Month in Review is user-launched. | Missing | Reviews projection exists, Month shell not proven | User-launched Month review UI test |
| `year_review_user_launched` | Year in Review is user-launched. | Missing | Reviews projection exists, Year shell not proven | User-launched Year review UI test |
| `review_includes_accomplishments` | Review includes accomplishments. | Partial | `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceReviewProjection.swift` | Rendered review content proof |
| `review_includes_broad_patterns` | Review includes broad patterns. | Partial | `Native/Ambitions/Projection/SurfaceLenses/YouHistoryPatternProjection.swift` | Pattern review proof |
| `review_includes_life_capital_changes` | Review includes Life Capital changes. | Missing | None found | Life Capital review proof |
| `review_can_update_future_paths_with_approval` | Review can update future paths with approval. | Missing | None found | Approval/update/receipt proof |
| `review_exports_markdown_pdf_and_share_sheet` | Review exports Markdown/PDF/share sheet. | Missing | None found | Export tests |
| `review_avoids_productivity_score_and_shame` | Review avoids score/shame. | Partial | `scripts/ambitions-vocabulary-drift-scan.py` | Rendered copy audit |

## Notifications

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `lock_screen_notifications_private_by_default` | Lock-screen notifications are private by default. | Partial | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift` | Device lock-screen proof, permission settings proof, delivered notification screenshot, end-to-end action routing proof |
| `personal_learning_insights_not_shown_aggressively` | Personal learning insights are not aggressive notifications. | Missing | None found | Notification route/copy audit |
| `notification_does_not_emotionally_label_user` | Notification avoids emotional labels. | Missing | None found | Notification copy test |
| `pattern_notice_opens_in_app_context` | Pattern notice opens in-app context. | Missing | None found | Notification tap routing proof |
| `reminder_notification_can_be_plain_and_calendar_like` | Reminder notification can be plain/calendar-like. | Unknown | Notification authorization state exists | Notification scheduling and copy proof |

## Automation

| Gate ID | User-visible behavior | Current status | Evidence path if found | Required future proof |
|---|---|---|---|---|
| `automation_configurable_globally` | Automation is globally configurable. | Missing | None found | Settings model/UI proof |
| `automation_configurable_per_life_area` | Automation is configurable per life area. | Missing | None found | Life-area setting proof |
| `automation_configurable_per_goal` | Automation is configurable per goal. | Missing | None found | Goal-level setting proof |
| `automation_never_forces` | Automation never forces. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimeReflowDecisionProjector.swift`, `docs/truth/PRODUCT_EXPERIENCE_CANON.md` | Policy tests and destructive-action proof |
| `automation_respects_protected_near_term_placement` | Automation respects protected near-term placement. | Missing | None found | Seven-day guard test |
| `automation_shows_user_caused_impact` | User-caused automation impact is visible. | Partial | `Native/Ambitions/Projection/SurfaceLenses/TimeReflowDecisionProjector.swift` | User-caused impact UI proof |
