# Flagship Object Surface Matrix

Status: Active trace matrix
Installed: 2026-05-16
Authority: Supporting trace for `FLAGSHIP_OBJECT_SYSTEM_DOCTRINE.md` and `OBJECT_GRAPH_ARCHITECTURE.md`.
Implementation claim: Docs-only. Matrix rows do not prove implementation or readiness.

## Purpose

This matrix maps flagship objects to destination surfaces, source expectations, proof expectations, and maturity gates. It prevents Codex from treating objects as isolated components or decorative views.

## Tier Legend

- FO-P0: primary destination object or Start Here object; requires full proof.
- FO-P1: cross-surface trust/execution object; requires targeted proof.
- FO-P2: supporting state marker or subobject; requires implementation receipt and scoped proof.
- FO-Candidate: future object; requires docs and source-binding plan.

## Primary Destination Objects

| Object | Tier | Destination | Primary Surface IDs | Required Swift Kernel | Required Renderer | Required Proof |
| --- | --- | --- | --- | --- | --- | --- |
| Reality Meridian | FO-P0 | Today | `today_root_reality_meridian`, `today_reality_meridian_rail`, `today_now_next_later_sequence` | `RealityMeridianObjectKernel` | `RealityMeridianView`, `CurrentTimeGlowView` | exact-time proof, drift proof, closure proof, accessibility proof, screenshot/preview matrix |
| Start Here Surface | FO-P0 | Today | `today_start_here_region`, `today_recommended_step_object` | `StartHereObjectKernel` | `StartHereSurfaceView` | why-now proof, time-fit proof, local receipt proof, CTA proof, accessibility proof |
| Constellation Atlas | FO-P0 | Goals | `goals_root_constellation_atlas`, `goals_life_area_map`, `ambition_graph`, `goal_thread_detail` | `ConstellationAtlasObjectKernel` | `ConstellationAtlasView` | label-off proof, lane proof, proof-trail linkage, blocker/recovery proof |
| Atmosphere Composer | FO-P0 | Capture | `capture_root_atmosphere_composer`, `capture_idle_composer`, `capture_active_text_entry`, `capture_post_input_route_reveal` | `AtmosphereComposerObjectKernel` | `AtmosphereComposerView` | bottom-composer proof, route-reveal proof, local-only/offline proof, accessibility proof |
| LifeShape Field | FO-P0 | Time | `time_root_lifeshape_field`, `day_lifeshape_surface`, `week_lifeshape_surface`, `month_lifeshape_surface` | `LifeShapeFieldObjectKernel` | `LifeShapeFieldView` | non-calendar proof, capacity proof, pressure proof, protected/away proof |
| User System Profile | FO-P0 | You | `you_root_user_system_profile`, `user_profile_header`, `local_runtime_trust_panel`, `planning_setup_section` | `UserSystemProfileObjectKernel` | `UserSystemProfileView` | trust proof, local runtime proof, planning setup proof, privacy proof |

## Cross-Surface Flagship Objects

| Object | Tier | Destinations | Surface IDs | Required Swift Kernel | Required Renderer | Required Proof |
| --- | --- | --- | --- | --- | --- | --- |
| Receipt Drawer | FO-P1 | Cross-surface | `receipt_system`, `receipt_detail`, `time_receipt_detail`, `capture_receipt` | `ReceiptObjectKernel` | `ReceiptDrawerView` | source/proof/reason list, no-receipt reason, undo/correction proof |
| Closure Sheet | FO-P1 | Today / Cross-surface | `closure_sheet`, `closure_system`, `today_closure_prompt_region` | `ClosureRecoveryObjectKernel` | `ClosureSheetView` | all closure states, Still Counts, no-shame copy, accessibility proof |
| Recovery Sheet | FO-P1 | Today / Time / Goals | `needs_recovery_state`, `today_recovery_state`, `recovery_flex_region` | `ClosureRecoveryObjectKernel` | `RecoverySheetView` | what changed, repair options, user control, receipt proof |
| Adjust Plan / Reflow Preview | FO-P1 | Today / Time | `adjust_plan_reflow_preview_entry`, `reflow_preview_tray`, `shape_day_flow`, `reflow_week_flow` | `ReflowPreviewObjectKernel` | `ReflowPreviewView` | before/after proof, protected time proof, accept/reject proof |
| Continuity Strip | FO-P1 | Global | `global_app_shell`, `destination_dock`, `tray_chrome` | `ContinuityStripObjectKernel` | `ContinuityStripView` | active state persistence, non-clutter proof, accessibility proof |
| Step Detail | FO-P1 | Today / Goals / Time | `step_detail`, `recommended_step_context_from_goals`, `goal_thread_context_from_today` | `StepDetailObjectKernel` | `StepDetailView` | step context, goal thread, proof, CTA, cancel path |
| Step Session | FO-P1 | Today | `step_session` | `StepSessionObjectKernel` | `StepSessionView` | optional timer, session state, closure transition, reduce-motion proof |
| Proof Trail | FO-P1 | Goals / Today / Cross-surface | `proof_trail`, `proof_detail`, `proof_attachment_detail`, `proof_trail_system` | `ProofTrailObjectKernel` | `ProofTrailView` | evidence, missing proof, attachment, source relationship proof |
| Schedule Conflict Sheet | FO-P1 | Time / Today | `best_fit_explanation_sheet`, `review_pressure_surface`, `time_overloaded_state` | `ScheduleConflictObjectKernel` | `ScheduleConflictSheetView` | conflict reason, hard context, alternatives, user choice proof |
| Source Quality Line | FO-P2 | Cross-surface | `source_freshness_badge`, `today_source_freshness_indicator`, `time_stale_source_state` | `SourceQualityObjectKernel` | `SourceQualityLineView` | fresh/stale/unavailable/local-only proof |
| Local Proof Chip | FO-P2 | Cross-surface | `local_runtime_source_detail_from_today`, `local_runtime_trust_panel`, `automation_and_trust` | `LocalProofObjectKernel` | `LocalProofChipView` | local-only label, inspect path, no marketing-only claim |

## Required Object States By Object

| Object | Required States |
| --- | --- |
| Reality Meridian | normal, active, overrun, protected, away, no schedule data, overloaded, stale source, needs closure, recovery |
| Start Here Surface | normal, compact, active, needs closure, needs recovery, blocked, waiting, no free time, protected block, away, source stale |
| Constellation Atlas | normal, empty, active lane, blocked lane, waiting lane, proof gap, review needed, archived/historical |
| Atmosphere Composer | idle, active text, dictation, attachment, uncertain parse, local-only/offline, failed attachment, route reveal |
| LifeShape Field | day, week, month, overloaded, protected block, away, stale source, conflict, reflow preview |
| User System Profile | normal, first-run, trust warning, local-only/offline, setup incomplete, automation review |
| Receipt Drawer | available, stale, unavailable, local-only, undo available, correction needed |
| Closure Sheet | completed, still counts, moved, skipped/not needed, blocked, waiting, needs recovery, needs review |
| Recovery Sheet | repair available, no safe reflow, user review needed, source stale, protected boundary |

## Required Proof By Tier

### FO-P0

- scenario preview matrix
- screenshot or rendered visual proof
- Dynamic Type proof
- Reduce Motion proof
- VoiceOver proof
- interaction proof
- state transition proof
- source/proof/receipt proof
- unit tests
- UI or targeted interaction tests
- implementation receipt
- rollback notes

### FO-P1

- targeted preview scenarios
- accessibility proof
- interaction proof
- receipt/proof behavior proof
- tests where stateful
- implementation receipt

### FO-P2

- source binding
- accessible label behavior
- visual token use
- implementation receipt if code changed

## Source Binding Status To Establish

Future implementation must update source bindings for each row with one of:

- `canon_only`
- `source_bound_unproven`
- `kernel_installed`
- `state_machine_installed`
- `renderer_installed`
- `previewed`
- `tested`
- `proof_complete`
- `flagship_ready`

## Immediate Gaps To Close

Based on current frontend dashboard patterns, many P0/P1 object surfaces are still canon-only or blocked by missing source binding. The first implementation-facing batch must not pretend these are done. It must install object graph contracts and then bind Today first.

## Next Batch Mapping

| Batch | Objects |
| --- | --- |
| `FLAGSHIP-OBJECT-SYSTEM-01` | object graph contracts, Swift core contracts, gates, matrices |
| `TODAY-FLAGSHIP-OBJECTS-01` | Reality Meridian, Start Here, Current Time Glow, Step Detail |
| `SHARED-RECEIPT-CLOSURE-OBJECTS-01` | Receipt Drawer, Closure Sheet, Recovery Sheet, Reflow Preview |
| `CAPTURE-ATMOSPHERE-OBJECT-01` | Atmosphere Composer, post-capture routing |
| `TIME-LIFESHAPE-OBJECT-01` | LifeShape Field, Day/Week/Month grammar |
| `GOALS-CONSTELLATION-OBJECT-01` | Constellation Atlas, lanes, proof trail |
| `YOU-TRUST-PROFILE-OBJECT-01` | User System Profile, trust panel, planning setup |
| `OBJECT-PROOF-MATRIX-01` | all FO-P0 and FO-P1 proof matrix |
| `APP-DESIGN-AWARDS-READINESS-01` | production-value audit without award claim |
