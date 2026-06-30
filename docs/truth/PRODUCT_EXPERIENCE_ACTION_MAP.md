# PRODUCT_EXPERIENCE_ACTION_MAP.md

Status: Active actionability map for `PRODUCT_EXPERIENCE_CANON.md`  
Scope: Product-experience canon operationalization, source support inventory, implementation sequencing, and future proof gates  
Owner posture: Planning and QA bridge, not implementation proof
Last audited commit: ac398ccdc175f65b70804dd47ae97803922d7a85
Last audited date: 2026-06-25
Status owner: Product Experience Canon operationalization
Update required when: scenario gate status changes, implementation train claims Green/Yellow, Life Capital/pathing/Future Steps/proof/review/onboarding/automation work lands, or evidence paths change

This is an evidence snapshot and action bridge, not implementation proof.

This file turns the official v1 Product Experience Canon into implementation and validation action. It does not prove that any canon behavior is complete in the app.

## Audit Protocol

Future Codex trains must update this map when scoped evidence changes. Treat status changes as evidence edits, not optimism edits.

Use these status labels:

- Existing: direct current source/test/runtime/UI evidence proves the user-visible behavior for the scoped claim.
- Partial: related source/tests/projections exist, but the complete user-visible behavior is not proven.
- Missing: inspection found no sufficient current source/test evidence.
- Unknown: the train did not inspect enough evidence to classify confidently.

For every status update:

- attach current evidence paths, or use an empty evidence list when none are known
- keep evidence paths specific to source, tests, scripts, proof artifacts, or current docs that were inspected
- include the commit/date if updating a mutable snapshot or gate index
- do not upgrade to Existing without direct evidence for the user-visible behavior
- do not use product canon, planned work, source names, screenshots paths, or string-presence scans as complete implementation proof
- preserve explicit future proof needed when behavior remains Partial, Missing, or Unknown

## Executive Action Summary

The Product Experience Canon adds product-experience authority for Life Capital, full scheduled goal paths, Future Steps, continuous future adjustment, proof/progress transfer, local learning, Source Atlas + local runtime composition, onboarding, reviews, notifications, automation, and scenario gates. The current repo has meaningful source-present scaffolding around goal orchestration, clarification, path compilation, Source Atlas models, proof/receipts, local search, Time placement/reflow projections, You learning controls, and review projections. It does not prove the full canon is implemented, visually accepted, device-validated, or release-ready.

Future work must treat the canon as behavior law, then prove each claim through source, tests, rendered UI, accessibility, privacy, and release evidence where relevant.

## Feature Horizon Matrix to Action Areas

| Horizon | Action area | Product target | Current posture |
|---|---|---|---|
| Foundation Requirement | Reminders, Steps, recurring Steps, quick Capture, calendar-grade Time, search, notifications, completion, missed Step recovery, local persistence, offline core | Make Ambitions useful as a standalone personal planning product | Partial source/runtime support exists across Step lifecycle, rendered Step detail/recovery controls, Day Rail Step row actions, recurring Step persistence, Capture-to-Step local save, Time projection/render/reload, local Search, private notification request construction, missed recovery reload, and source/runtime end-to-end workflows; full rendered E2E, accessibility sweep, network-disabled device workflow, visual, and release proof are not established |
| Core Runtime Requirement | Full path generation, full-path scheduling, Future Steps, priority, capacity fit, protected seven-day placement, simulation, proof preservation, Life Capital, passive learning, Source Atlas inspection | Make Ambitions behave like a Personal Life OS rather than a task/calendar app | Several model/projection pieces exist, including scoped source/runtime proof for protected seven-day placement policy and command preflight; full integrated behavior is still missing or unproven |
| Moat Requirement | Personalized paths per user, Life Capital path shortening, proof/progress transfer, continuous Future Step adjustment, reviews updating future paths, Source Atlas + local runtime composition | Make every user’s Ambitions meaningfully different through local history and context | Mostly future implementation target; do not claim Green |
| Future Expansion | Shared goals, LinkedIn import, third-party data, richer packs, collaborative proof, household planning, user-owned sync | Approved direction only | Not active scope; requires separate canon or boundary |
| Reserved / Not Yet Approved | Hosted private life graph, cloud AI core planning, social feeds, public profiles, productivity scoring, XP/streak pressure, Source Atlas marketplace browsing, third-party behavioral analytics SDK | Must not be implemented under current canon | Guardrail only |

## Runtime Behavior Contract Index

| Contract | Acceptance gate | Future implementation owner area |
|---|---|---|
| Goal Creation Contract | `goal_creation_generates_scheduled_path_or_clarification` | Goal engine, Capture, Goals, Time, receipts |
| Full Goal Path Contract | `full_goal_path_outputs_stages_steps_future_steps_and_fit_state` | Goal path compiler, Goals drilldown, Time fit state, Today slice |
| Full-Path Scheduling Contract | `full_path_scheduling_places_future_steps_with_conflict_state` | Time placement, scheduling engine, conflict model |
| Future Step Contract | `future_step_has_time_window_goal_relationship_and_edit_behavior` | Goal path nodes, Time windows, edit/impact preview |
| Plan Adjustment Contract | `automatic_adjustment_never_silently_moves_protected_near_term_placement` | Time adjustment, automation, receipts, protected-window guards |
| Conflict Resolution Contract | `new_goal_over_capacity_shows_make_room_and_add_with_conflict` | Capacity engine, simulation, Time/Goals conflict flows |
| Life Capital Contract | `life_capital_edit_resimulates_affected_paths` | You, Life Capital store, path resimulation, receipts |
| Proof Contract | `proof_attaches_to_goal_step_life_capital_without_required_grading` | Proof ledger, Goals, Today closure, Life Capital |
| Progress Transfer Contract | `proof_transfers_as_context_not_false_completion` | Goal pivot, proof carry-forward, path compiler |
| Onboarding Contract | `onboarding_saves_each_answer_and_supports_skipping_without_data_loss` | Setup & Personalization, persistence, first path preview |
| Review Contract | `user_launched_review_exports_and_updates_future_paths_when_approved` | You reviews, export, path updates, receipts |
| Source Atlas Contract | `source_atlas_enriches_path_without_exposing_pack_marketplace_or_uploading_private_context` | Source Atlas models, privacy boundary, local composition |

## Scenario Gate Index

The active gate list is maintained in `docs/qa/product-experience-scenario-gates.md`. Future implementation trains must add focused test/proof coverage against the relevant gates instead of relying on canon text or source names.

## Origin-to-Action

`PRODUCT_ORIGIN_TRUTH.md` frames the core user problem as high ambition plus low operating structure. Implementation and QA trains should translate that problem into these action priorities without claiming they are already complete:

| Origin problem | Implementation priority | Actionability target |
|---|---|---|
| The user forgets obligations or daily intentions. | Reminders, Steps, recurring Steps, and calendar-grade planning prevent daily failure. | Today and Time make required action visible, scheduled, recoverable, and private. |
| The user has ambition but no visible route. | Full goal pathing creates direction. | Goals generate staged paths, clarifying questions, milestones, Steps, and proof points. |
| The user cannot see the future shape of a goal. | Future Steps create future foresight. | Time and Goals show flexible future placement, edit impact, and schedule fit without vague someday items. |
| The user has skills, resources, relationships, or proof but planning starts from zero. | Life Capital prevents starting from zero. | You and the runtime carry capabilities, resources, accomplishments, patterns, and proof into path generation. |
| The user loses progress when life changes. | Reviews preserve proof and progress. | Reviews surface accomplishments, proof, Life Capital changes, and approved future-path updates without score or shame. |
| The user overcommits across too many simultaneous goals and obligations. | Conflict simulation prevents overcommitment. | Capacity checks show what does not fit yet and offer Make room options before commitment. |
| The user operates in personal patterns that generic planning cannot see. | Local learning adapts to how the user actually operates. | Local-only behavior, proof, schedule reality, recovery history, and user-approved patterns improve fit without cloud dependency. |

## Existing Repo Support Found

These are source-present or doc-present supports, not full product proof:

| Area | Evidence paths |
|---|---|
| Four-surface product law, Capture global composer, Motion behavior, Trust inspection | `docs/truth/PRODUCT_DESIGN_TRUTH.md`, `AGENTS.md`, `Native/Ambitions/Projection/StageScenes/`, `Native/Ambitions/Projection/OverlayScenes/` |
| Goal orchestration with intake, clarification, understanding, path compilation, resource graph, planner output | `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrator.swift`, `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels+02-GoalCompiledPathCompilerCore+02-compile.swift`, `Native/AmbitionsTests/Services/GoalUnderstandingServiceTests.swift`, `Native/AmbitionsTests/Services/GoalPathCompilerServiceTests.swift` |
| Source Atlas value models, pack validation, runtime boundary concepts, capability graphs | `Native/Ambitions/Core/Domain/SourceAtlasPackModels+06-SourceAtlasPack.swift`, `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift`, `Native/AmbitionsTests/Runtime/SourceAtlasRuntimeBridgeReplayTests.swift` |
| Proof/receipt model and UI affordances | `Native/Ambitions/Projection/Mutations/MutationProof.swift`, `Native/Ambitions/Projection/Mutations/MutationReceipt.swift`, `Native/Ambitions/DesignSystem/ProductObjects/ProofStitchView.swift`, `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift` |
| Time placement, Life Calendar rows, review-before-change posture | `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCalendarContracts.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeReflowDecisionProjector.swift`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift` |
| Protected seven-day placement policy and command preflight | `Native/Ambitions/Core/Runtime/ProtectedStepPlacementPolicy.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/PolicyGuardedCommandExecutor.swift`, `Native/AmbitionsTests/Runtime/ProtectedStepPlacementPolicyTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/PolicyGuardedCommandExecutorTests.swift`, `docs/qa/p2-core-runtime-inventory.md` |
| Local search over goals, captures, proof, feedback, teaching, event history, life context | `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceEverythingSearchProjection.swift`, `Native/Ambitions/Projection/OverlayLenses/SearchLens.swift`, `docs/qa/remediation/dossiers/AMB-1196-search-find-act-inspect.md` |
| You local learning, memory controls, source review, reviews | `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceLearningControlsProjection.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceLifeContextRuntimeProjection.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceSourceAtlasPrimaryProjection.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceReviewProjection.swift` |
| Local persistence source and repository wiring are documented as source-present | `docs/truth/IMPLEMENTATION_TRUTH.md`, `Native/Ambitions/Core/Persistence/`, `Native/Ambitions/App/AppContainerFactory.swift` |
| Scoped foundation source/runtime/rendered-control proof | `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/Runtime/MemoryLensService.swift`, `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`, `Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels+02-AmbitionsDayRailView+04-upNextRow.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`, `Native/AmbitionsTests/Runtime/RecurringStepLifecycleServiceTests.swift`, `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift`, `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`, `Native/AmbitionsTests/Time/P1DTimeFoundationTests.swift`, `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`, `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`, `Native/AmbitionsUITests/AmbitionsUITests.swift` |
| Lightweight canon/language validation hooks | `scripts/ambitions-vocabulary-drift-scan.py`, `scripts/canon-language-drift-scan.sh`, `scripts/release-claim-safety-scan.sh` |

## Partial Support Found

| Canon area | Partial evidence | Gap |
|---|---|---|
| Full goal path generation | Goal orchestrator and compiled path stages exist | Full path to accomplishment, Future Steps, scheduling, fit state, and rendered drilldown are not proven end-to-end |
| Vague goal clarification | Clarification service/tests exist | Skip/partial-answer UX and provisional shell behavior are not proven |
| Source Atlas composition | Pack/value models and bridge tests exist | R2 freshness, privacy boundary release proof, invisible-by-default UX, and local composition with private context are not release-proven |
| Local learning | You learning controls and personalization factor rows exist | Broad Life Capital Patterns and passive learning shaping path/schedule behavior are not fully proven |
| Proof and receipts | Proof/receipt types and UI affordances exist | Proof-to-Life-Capital, progress transfer, and no-false-completion pivots are not fully proven |
| Time adjustment | Reflow decision projection asks for review before changes; deterministic protected seven-day placement policy, command preflight, automatic near-term block, future automation review, Move it user-action handling, and local-only boundary tests have scoped support | Rendered approval/review UI, receipt persistence, accessibility proof, device/no-network proof, and full scheduling architecture centralization are not proven |
| Reviews | You reviews projection exists | Week/Month/Year user-launched review shell, export, and approved future path updates are not fully proven |
| Search | Local search projection exists | Search across Life Capital and Future Steps specifically is not proven |
| Notifications | Notification authorization copy exists in You; local notification planner and tests cover private generic copy | Device lock-screen delivery, permission/settings UX, tap routing, and release evidence are not proven |
| Foundation Step, Capture, Time, Search, notification, and recovery lifecycle | Focused source/runtime and UI tests cover create, Today projection, reschedule, missed recovery, completion, local evidence, SwiftData-backed reload, rendered Step detail controls, closure/recovery controls, Day Rail Step row actions, recurring Step creation/pause/resume, Capture Step-route save, scheduled Step Time projection/rendering/reload, local search, private notification request construction, and a source/runtime E2E workflow | Full reminder creation UI, full recurring Step UI/accessibility proof, rendered Capture-to-Today UI proof, rendered Search/recovery/E2E proof, no-network device workflow, notification delivery, and release proof are not established |
| Automation | Confirmation-aware safety samples and review language exist | Global/per-life-area/per-goal automation levels are not proven |

## Missing Support / Future Implementation Gaps

- User-facing `Life Capital` as a first-class You section with capability, credential, resource, relationship, accomplishment, proof, and pattern records.
- Manual Life Capital add/edit/archive/delete with affected-path preview, receipts, and path resimulation.
- Full-path scheduling that places near-term Steps and flexible Future Steps across time windows.
- Future Step visual model, edit behavior, far-future path-impact preview, and search support.
- Capacity simulation with `This does not fit yet`, Make room, Lower pace, Change deadline, Pause another goal, and Add with conflict flows.
- Rendered approval/review UI and full scheduling centralization for protected seven-day placement beyond the P2A deterministic runtime guard.
- Progress transfer on goal pivot with `You are not starting from zero` and no false completion.
- Onboarding chapters, immediate save behavior, weighted progress, Setup & Personalization persistence, and first path preview.
- Week / Month / Year in Review with export to Markdown/PDF/share sheet and user-approved operational changes.
- Private-by-default lock-screen notification behavior and pattern notices opening in-app context.
- Automation controls globally, per life area, and per goal.
- Source Atlas invisible-by-default user experience and no-marketplace behavior.
- Release proof for account/R2/offline/privacy/accessibility/device behavior where future trains make those claims.

## Recommended Implementation Train Sequence

### P0 — Authority Installation

- product canon file installed
- truth README updated
- product/design/moat cross-links added
- action map created
- scenario gates created

### P1 — Foundation Reality

- reminders/Steps/recurring Steps
- quick Capture
- calendar-grade Time foundation
- local search
- private notifications
- local persistence/offline core
- missed Step asks “what changed?”

### P2 — Core Runtime Behavior

- full goal path generation
- full-path scheduling
- Future Steps
- “This does not fit yet”
- Make room / Add with conflict
- priority Low / Normal / High
- no silent movement inside protected seven-day placement window

### P3 — Life Capital and Learning

- Life Capital visible in You
- manual add/edit/archive/delete
- broad Patterns
- Life Capital path impact preview
- passive learning shaping paths
- proof/progress preservation

### P4 — Moat Expansion

- every user receives different paths
- capability-aware path shortening
- constant future adjustment
- reviews update Life Capital and future paths
- Source Atlas + local runtime composition

### P5 — Future Expansion

- shared goals
- LinkedIn import
- additional third-party data sources
- richer Source Atlas packs
- export expansion
- user-owned sync only if separately approved

## Non-Goals for This Train

- No Swift source feature implementation.
- No runtime wiring changes.
- No new root surfaces.
- No Motion or Capture root IA changes.
- No hosted private life graph, cloud AI core planning, social feeds, public profiles, productivity scoring, XP, or streak systems.
- No Source Atlas marketplace browsing.
- No release, device, accessibility, privacy, account, R2, or offline Green claim.
- No deletion of existing remediation canon or truth files.

## Proof Required Before Any Future Train Can Claim Green

- Source proof: canonical owner paths, compiled code, no forbidden IA drift, focused unit/UI tests for the behavior.
- Runtime proof: deterministic local behavior, mutation/receipt paths, relaunch/persistence where scoped, failure states, and no fake success.
- Scenario proof: relevant gate IDs from `docs/qa/product-experience-scenario-gates.md` exercised by tests or documented manual QA.
- Privacy proof: local-first boundaries, no private life graph upload, no R2 private context, sensitive notification handling where relevant.
- Accessibility proof: VoiceOver, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, tap targets, semantic actions where UI changes.
- Visual proof: reviewable screenshots and independent visual review for product-surface claims.
- Release proof: current commit, branch, commands, logs, environment, exit codes, artifacts, and explicit not-run list.

## Recommended Future Script

Do not create a heavy validation framework from this action map. A future validation train may add a compact planned script, `scripts/product-experience-scenario-gate-check.py`, to read `docs/qa/product-experience-scenario-gates.md`, verify each gate has a status/evidence/proof row, and optionally map gate IDs to tests as implementation coverage lands.
