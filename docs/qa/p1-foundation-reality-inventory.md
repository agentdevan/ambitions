# P1 Foundation Reality Inventory

Status: Active P1 inventory
Baseline SHA: `30da6e81c69146d68d6f1060320533c6d52a62c4`
Date: 2026-06-24
Scope: P1 Foundation Reality source/test/QA inspection for reminders/Steps, recurring Steps, quick Capture, calendar-grade Time foundation, local search, private notifications, local persistence/offline core, completion/closure, and missed Step recovery.
Owner posture: evidence inventory and implementation planning, not implementation proof.

This document is not Runtime Green, Interaction Green, Visual Green, Release Green, or implementation completeness proof. It classifies current source and test evidence to plan the next source trains.

## Executive Verdict

Overall P1 posture: Partial with Missing and Unknown gaps.

Existing support is strongest for local persistence source, Step/goal plan models, local quick Capture save paths, private notification copy at unit-test level, local search scaffolding, Time projection scaffolding, and completion mutation/receipt primitives.

Partial support dominates because the app has source and focused tests for pieces of the foundation, but not enough current end-to-end rendered, relaunch, accessibility, device, offline/no-account, notification delivery, and scenario-gate proof to upgrade the P1 foundation to Runtime Green or Interaction Green.

Missing support remains highest around a real Step core that can be created, completed, rescheduled, repeated, paused, persisted, rendered, and recovered from as one user-visible foundation object. Recurring Step repeat/pause behavior is the clearest high-risk gap because current evidence shows recurring metadata and ongoing cadence defaults, not a proven recurrence engine with pause/relaunch/UI behavior.

Recommended next train: P1A Step Core Reality.

## P1 Gate Map

| Gate | Current status | Evidence paths | What current source proves | What current source does not prove | Required future proof | Recommended owner area | Suggested next train |
|---|---|---|---|---|---|---|---|
| `foundation_reminder_can_be_created_completed_and_rescheduled` | Partial | `Native/Ambitions/Core/Domain/Step.swift`; `Native/Ambitions/Core/Domain/ReminderModels.swift`; `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`; `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`; `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` | Step and reminder records exist; reminders round-trip through SwiftData; Today completion can update a Step, feedback, evidence, command execution, and event ledger in focused tests. | One user-visible reminder-like Step create/complete/reschedule flow is not proven end-to-end; rendered UI, relaunch persistence, accessibility, and real notification interaction are not proven. | Focused create/complete/reschedule source tests, relaunch persistence test, rendered UI test, accessibility labels/actions, and receipt/proof assertions. | `Core/Domain`, `Core/Persistence`, `Core/Runtime`, `Projection/Commands`, `Surfaces/Today`, `Surfaces/Time` | P1A Step Core Reality |
| `foundation_recurring_step_repeats_and_can_be_paused` | Partial | `Native/Ambitions/Core/Domain/Planning/PlanningDomainModels.swift`; `Native/Ambitions/Core/Domain/ReminderModels.swift`; `Native/AmbitionsTests/Domain/PlanningDomainModelsTests.swift`; `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift` | Ongoing planning cadence maps to `repeatWithinWindow`; Step can be repeatable; reminder metadata can identify recurrence and preserve notes through repository round trip. | Actual repeat generation, pause behavior, recurrence state transition, rendered controls, and relaunch proof are not proven. | Recurrence engine test, pause/resume test, persisted recurrence instance test, UI test, and recovery/notification interaction proof. | `Core/Domain`, `Core/Runtime`, `Core/Persistence`, `Projection/Commands` | P1B Recurring Steps and Persistence |
| `foundation_quick_capture_saves_without_network` | Partial | `Native/Ambitions/Core/Runtime/AmbitionsCommandExecutor+02-AmbitionsCommandExecutor.swift`; `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift`; `Native/Ambitions/App/ShellCommandRouter.swift`; `Native/Ambitions/Composer/Capture/`; `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`; `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`; `Native/AmbitionsTests/Runtime/LocalOnlyProofHarnessTests.swift` | Quick Capture writes to the local capture repository; shell quick Capture routes as a global overlay; focused tests prove local capture persistence and no-account local capture in an in-memory runtime composition. | No-network device workflow, relaunch proof, full composer save path on current build, Dynamic Type/VoiceOver proof, and production persistent-store proof are not established. | Offline launch plus quick Capture test, persistent store relaunch test, rendered composer save test, route correction receipt proof, and accessibility proof. | `Composer/Capture`, `Core/Runtime`, `Core/Persistence`, `Stage/Overlays` | P1C Capture Saves Locally |
| `foundation_calendar_planning_shows_fixed_points_and_open_windows` | Partial | `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`; `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCalendarContracts.swift`; `Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift`; `Native/Ambitions/Surfaces/Time/`; `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift`; `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift` | Time has fixed/open row contracts, calendar read/write boundaries, open-window projection, placement candidate guards, and tests for Time field state and calendar permission fallback. | Calendar-grade interaction is not proven with rendered screenshots, VoiceOver, actual calendar permission/device behavior, or durable placement persistence. | Rendered Time proof with fixed points/open windows, permission-denied and permission-granted manual QA, accessibility labels, no silent calendar write proof, and persistence/relaunch proof for placed Steps. | `Core/Time`, `Core/Permissions`, `Projection/SurfaceLenses`, `Surfaces/Time` | P1D Time Foundation |
| `foundation_search_finds_goals_steps_proof_life_capital_and_settings` | Partial | `Native/Ambitions/Core/Runtime/SearchIndex.swift`; `Native/Ambitions/Core/Runtime/MemoryLensService+SearchAdapters.swift`; `Native/Ambitions/Projection/OverlayLenses/SearchLens.swift`; `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceEverythingSearchProjection.swift`; `Native/AmbitionsTests/App/ShellCommandRouterTests.swift` | Local search record/index types exist; Memory Lens adapters produce goal, Step, proof, capture, time, and setting results; You Everything Search includes life context documents and local-only footer copy. | Search across first-class Life Capital is not proven because Life Capital is not yet first-class; route proof is partial; rendered search and accessibility proof are not current. | Search tests covering goals, Steps, proof, life context/Life Capital placeholder, settings, empty results, route handoff, and local-only guarantee; rendered overlay test. | `Core/Runtime`, `Projection/OverlayLenses`, `Projection/SurfaceLenses`, `Stage/Overlays` | P1E Local Search Foundation |
| `foundation_notification_copy_is_private_by_default` | Partial | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`; `Native/Ambitions/Core/Permissions/NotificationPermission.swift`; `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`; `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift` | Unit tests prove notification bodies use private generic copy and do not expose sensitive ambient focus details; local notification scheduling logs local-only side effects. | Device lock-screen behavior, notification settings, permission UX, delivered notification screenshots, and end-to-end tap actions are not proven. | Notification content tests, device/simulator notification delivery proof, lock-screen/default privacy proof, permission-state UX proof, and action routing proof. | `Core/Permissions`, `App`, `Projection/ExternalSnapshots`, `Surfaces/You` | P1F Private Notifications and Missed Recovery |
| `foundation_offline_core_runs_without_account` | Partial | `Native/Ambitions/App/AppContainerFactory.swift`; `Native/Ambitions/Core/Persistence/LocalStore.swift`; `Native/Ambitions/Core/Runtime/AmbitionsRuntimeServices.swift`; `Native/AmbitionsTests/Runtime/LocalOnlyProofHarnessTests.swift`; `Native/Ambitions/Resources/PrivacyInfo.xcprivacy` | Live bootstrap uses persistent SwiftData mode; runtime capabilities expose local-only boundaries; tests prove no-account goal/capture/Today in an in-memory local composition and no remote intelligence backend. | Real app launch offline/no-account on device or simulator, persistent relaunch, network-disabled workflow, account bypass UX, and release evidence are not proven. | No-account launch UI test, network-disabled smoke workflow, persistent relaunch proof, privacy boundary scan, and release-evidence packet if claiming release posture. | `App`, `Core/Persistence`, `Core/Runtime`, `Surfaces/You` | P1A/P1C plus cross-train offline proof |
| `foundation_completion_creates_visible_closure` | Partial | `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`; `Native/Ambitions/Projection/Mutations/StageMutation.swift`; `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService.swift`; `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`; `Native/AmbitionsTests/Projection/MutationsCanonicalOwnershipTests.swift` | Completion updates Step state, feedback, evidence, command records, event ledger, and mutation/receipt/proof primitives in focused tests. | Rendered closure surface, VoiceOver announcement on device/simulator, visible receipt inspection path, and undo behavior are not proven end-to-end. | Completion UI test, rendered closure proof, accessibility announcement/action proof, receipt inspection test, and relaunch proof. | `Core/Runtime`, `Projection/Mutations`, `Projection/SurfaceLenses`, `Surfaces/Today`, `Trust` | P1A Step Core Reality |
| `foundation_missed_step_asks_what_changed` | Partial | `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift`; `Native/Ambitions/Projection/SurfaceLenses/TimeRecoveryReceiptMaturityProjection.swift`; `Native/Ambitions/Projection/SurfaceLenses/TimeCalendarRecoveryProjection.swift`; `Native/AmbitionsTests/Domain/RescheduleEngineTests.swift`; `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift` | Recovery/reschedule decisions exist for delay/skip/stuck/blockers; reminder missed trigger can become `needsRecovery`; Time recovery projections emphasize review and no silent rescheduling. | User-visible missed Step prompt specifically asking what changed is not proven; rendered options, persistence, and copy audit are not proven for the missed-Step scenario. | Missed-Step scenario test, copy audit, rendered recovery options, persistence/relaunch proof, and no-shame vocabulary scan. | `Core/Domain`, `Core/Runtime`, `Projection/SurfaceLenses`, `Surfaces/Today`, `Surfaces/Time` | P1F Private Notifications and Missed Recovery |
| `origin_many_goals_many_obligations_today_remains_clear` | Partial | `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService.swift`; `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository03-openWindows.swift`; `Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift`; `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` | Today has Start Here/action projection, open-window/recovery support, and completion behavior tests. | Overloaded-day rendered clarity, first-viewport non-dashboard proof, Dynamic Type, and accessibility proof are not current. | Dense many-goals/many-obligations fixture, rendered Today first-viewport proof, UI hierarchy assertions, visual review, and accessibility proof. | `Projection/SurfaceLenses`, `Surfaces/Today`, `DesignSystem/ProductObjects` | After P1A, focused Today density proof train |
| `origin_missed_obligation_asks_what_changed_without_shame` | Partial | `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift`; `Native/Ambitions/Projection/SurfaceLenses/TimeRecoveryReceiptMaturityProjection.swift`; `Native/AmbitionsTests/Domain/RescheduleEngineTests.swift`; `scripts/ambitions-vocabulary-drift-scan.py` | Recovery logic and Time copy posture avoid silent rescheduling and support gentle recovery. | Exact missed-obligation interaction with "what changed" prompt is not proven; rendered copy and accessibility proof are absent. | Missed-obligation UI scenario, copy lint, no-shame vocabulary scan, recovery action persistence, and receipt proof. | `Core/Domain`, `Projection/SurfaceLenses`, `Surfaces/Today`, `Surfaces/Time` | P1F Private Notifications and Missed Recovery |

## Source Inventory by Area

### Steps / Reminders

Source paths inspected: `Native/Ambitions/Core/Domain/Step.swift`, `Native/Ambitions/Core/Domain/ReminderModels.swift`, `Native/Ambitions/Core/Domain/Planning/PlanningDomainModels.swift`, `Native/Ambitions/Core/Persistence/SwiftDataModels.swift`, `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`, `Native/Ambitions/Projection/Commands/CommandRouter.swift`, `Native/Ambitions/Interaction/TodayCommandHandler.swift`, `Native/Ambitions/Interaction/TodayCommandActionHandler.swift`.

Tests inspected: `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`, `Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift`, `Native/AmbitionsTests/Domain/PlanningDomainModelsTests.swift`, `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`, `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift`.

Current behavior found: Step domain and SwiftData `StepRecord` exist; reminder domain and SwiftData `ReminderRecord`/repository exist; reminder parser handles concrete, recurring, waiting, blocked, and ambiguous reminder language; Today completion updates Step state in focused tests.

Current gaps: no single proven create/complete/reschedule UI flow for a reminder-like Step; no rendered reminder management proof; no persistent relaunch proof for user-created reminder-like Step across app launch.

Risk level: High.

Scenario gates affected: `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_recurring_step_repeats_and_can_be_paused`, `foundation_completion_creates_visible_closure`.

### Recurring Steps

Source paths inspected: `Native/Ambitions/Core/Domain/Planning/PlanningDomainModels.swift`, `Native/Ambitions/Core/Domain/ReminderModels.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`, `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift`.

Tests inspected: `Native/AmbitionsTests/Domain/PlanningDomainModelsTests.swift`, `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`, `Native/AmbitionsTests/Domain/RescheduleEngineTests.swift`.

Current behavior found: ongoing cadence defaults to seven days; repeatable Step flags exist; recurring reminder metadata can round-trip; recurring notes can be preserved across reschedule/snooze/missed helper methods.

Current gaps: no recurring instance generator, no pause/resume state machine, no UI controls, no relaunch proof, no notification scheduling proof for recurring Step sequences.

Risk level: Red for P1 completeness.

Scenario gates affected: `foundation_recurring_step_repeats_and_can_be_paused`.

### Capture

Source paths inspected: `Native/Ambitions/Composer/Capture/`, `Native/Ambitions/Core/Domain/CaptureModels.swift`, `Native/Ambitions/Core/Runtime/CaptureService.swift`, `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift`, `Native/Ambitions/Core/Runtime/AmbitionsCommandExecutor+02-AmbitionsCommandExecutor.swift`, `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift`.

Tests inspected: `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`, `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`, `Native/AmbitionsTests/Runtime/CaptureRuntimeGauntletTests.swift`, `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`, `Native/AmbitionsTests/Runtime/LocalOnlyProofHarnessTests.swift`.

Current behavior found: global Capture overlay routing exists; quick Capture can create local captures; capture routes, states, receipts, assumptions, and correction actions have focused tests; no cloud/LLM dependency is asserted in capture runtime gauntlet.

Current gaps: no current end-to-end rendered/offline/relaunch proof for the production composer; some paths still route to Capture inbox style semantics as compatibility naming; accessibility/device proof not current.

Risk level: Medium.

Scenario gates affected: `foundation_quick_capture_saves_without_network`, `foundation_search_finds_goals_steps_proof_life_capital_and_settings`.

### Time Foundation

Source paths inspected: `Native/Ambitions/Core/Time/`, `Native/Ambitions/Core/Permissions/CalendarReminders/`, `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCalendarContracts.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift`, `Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift`, `Native/Ambitions/Surfaces/Time/`, `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift`.

Tests inspected: `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift`, `Native/AmbitionsTests/Time/TimeFieldMutationCoordinatorTests.swift`, `Native/AmbitionsTests/Time/TimeLensProjectionTests.swift`, `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift`.

Current behavior found: Time projects open/protected/fixed/goal-load rows; calendar read/write permission boundaries exist; Time placement requires real eligible Step; focused tests cover open windows, free-floating capture-derived placement candidates, no silent calendar writes, and mutation receipt primitives.

Current gaps: actual calendar-grade rendered proof, real calendar permission behavior, persistent placement, UI accessibility, and device proof are absent. Some Time change paths are projection-level and not a full durable scheduling system.

Risk level: High.

Scenario gates affected: `foundation_calendar_planning_shows_fixed_points_and_open_windows`, `origin_many_goals_many_obligations_today_remains_clear`.

### Search

Source paths inspected: `Native/Ambitions/Core/Runtime/SearchIndex.swift`, `Native/Ambitions/Core/Runtime/MemoryLensService+SearchAdapters.swift`, `Native/Ambitions/Projection/OverlayLenses/SearchLens.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceEverythingSearchProjection.swift`, `Native/Ambitions/Stage/Overlays/QuietCommandMemoryLensOverlay.swift`.

Tests inspected: `Native/AmbitionsTests/App/ShellCommandRouterTests.swift`, `Native/AmbitionsTests/Projection/OverlayLensesCanonicalOwnershipTests.swift`, search-related route assertions in UI/unit tests by source inspection.

Current behavior found: deterministic local index and search-result adapters exist; You Everything Search builds local documents for goals, captures, proof, feedback, teaching, event ledger, life context, and settings; SearchLens states local-only trust.

Current gaps: there is no focused P1 search test proving all required families in one flow; Life Capital is represented as life context, not first-class Life Capital; rendered search overlay and accessibility proof are not current.

Risk level: Medium.

Scenario gates affected: `foundation_search_finds_goals_steps_proof_life_capital_and_settings`.

### Notifications

Source paths inspected: `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/Permissions/NotificationPermission.swift`, `Native/Ambitions/Core/Permissions/NotificationRuntime.swift`, `Native/Ambitions/App/AppBootstrapper.swift`.

Tests inspected: `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`, `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`.

Current behavior found: local notification categories, schedule refresh, generic private notification title/body, stale snapshot clearing, failure logging, authorization fallback, and action payload parsing have unit coverage.

Current gaps: device lock-screen proof, permission settings UX, actual delivered notification screenshots, and end-to-end notification action routing are not current.

Risk level: High.

Scenario gates affected: `foundation_notification_copy_is_private_by_default`, `lock_screen_notifications_private_by_default`.

### Persistence / Offline

Source paths inspected: `Native/Ambitions/Core/Persistence/LocalStore.swift`, `Native/Ambitions/Core/Persistence/SwiftDataModels.swift`, `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift`, `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/Core/Runtime/AmbitionsRuntimeServices.swift`, `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`.

Tests inspected: `Native/AmbitionsTests/Runtime/LocalOnlyProofHarnessTests.swift`, `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`, `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`, `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`.

Current behavior found: SwiftData `ModelContainer` is configured with CloudKit disabled; live bootstrap uses persistent mode; repository wiring is centralized through `AppContainerFactory`; local-only runtime capability tests exist; privacy manifest test asserts no collected data/accessed API declarations.

Current gaps: physical device persistence, corruption recovery in release, migration safety, export/delete UX, account bypass UI, and network-disabled app workflow are not release-proven.

Risk level: High.

Scenario gates affected: `foundation_offline_core_runs_without_account`, `foundation_quick_capture_saves_without_network`, `foundation_reminder_can_be_created_completed_and_rescheduled`.

### Missed Step Recovery

Source paths inspected: `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift`, `Native/Ambitions/Core/Domain/RecoveryState.swift`, `Native/Ambitions/Core/Runtime/RecoveryEngine.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeRecoveryReceiptMaturityProjection.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeCalendarRecoveryProjection.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository03-openWindows.swift`.

Tests inspected: `Native/AmbitionsTests/Domain/RescheduleEngineTests.swift`, `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`, `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift`.

Current behavior found: reschedule decisions handle delay, skip, stuck, blockers, waiting, not ready, smaller-step fallback, and deterministic decisions; reminder helper can mark missed trigger as `needsRecovery`; Time recovery projections use non-shaming boundaries.

Current gaps: missed Step prompt that explicitly asks "what changed?" is not proven as rendered/user-visible behavior; persistence of the user's answer and receipt path are not proven.

Risk level: High.

Scenario gates affected: `foundation_missed_step_asks_what_changed`, `origin_missed_obligation_asks_what_changed_without_shame`.

### Completion / Closure

Source paths inspected: `Native/Ambitions/Core/Runtime/ClosureEngine.swift`, `Native/Ambitions/Projection/Mutations/ClosureStageMutation.swift`, `Native/Ambitions/Projection/Mutations/StageMutation.swift`, `Native/Ambitions/Projection/Mutations/MutationProof.swift`, `Native/Ambitions/Projection/Mutations/MutationReceipt.swift`, `Native/Ambitions/Trust/ReceiptInspectionView.swift`, `Native/Ambitions/Trust/ProofInspectionView.swift`.

Tests inspected: `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`, `Native/AmbitionsTests/Projection/MutationsCanonicalOwnershipTests.swift`, `Native/AmbitionsTests/App/ClosureRecoveryPrimitiveFamilyTests.swift`.

Current behavior found: completion path writes feedback/evidence/command/event records and updates Step state in focused tests; closure mutation produces local proof, receipt, undo, haptic, motion, and accessibility-announcement primitives.

Current gaps: rendered closure sheet, visible receipt inspection, accessibility action proof, and undo end-to-end behavior are not current.

Risk level: Medium.

Scenario gates affected: `foundation_completion_creates_visible_closure`, `foundation_missed_step_asks_what_changed`.

## Architecture Ownership Findings

| Area | Canonical owner expected | Current owner path | Compatibility debt | Required migration | `Features/` in active path? |
|---|---|---|---|---|---|
| Step domain | `Core/Domain/Step.swift` | `Native/Ambitions/Core/Domain/Step.swift` plus planning models under `Core/Domain/Planning/` | Low for canonical Step model; old `Native/Ambitions/Domain/` still exists elsewhere as legacy debt. | Keep new Step work in `Core/Domain`, `Core/Runtime`, `Core/Persistence`, `Projection`, and canonical surfaces. | Not required for Step core. |
| Reminder models/persistence | `Core/Domain`, `Core/Persistence`, `Core/Permissions` | `Native/Ambitions/Core/Domain/ReminderModels.swift`; `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`; `Native/Ambitions/Core/Permissions/` | Medium: reminders are canonical enough for P1, but recurring behavior is metadata-heavy. | Add recurrence behavior under `Core/Runtime` or `Core/Domain`; avoid `Features/`. | No. |
| Capture | `Composer/Capture`, `Projection/Overlay*`, `Core/Runtime` | `Native/Ambitions/Composer/Capture/`, `Native/Ambitions/Core/Runtime/CaptureService*`, `Native/Ambitions/Stage/Overlays/` | Medium: legacy `Native/Ambitions/Features/Capture/` still exists; some "capture inbox" naming remains compatibility semantics. | P1C should keep product logic under `Composer/Capture` and `Core/Runtime`; use only minimal shims if needed. | Yes, legacy path exists but should not be expanded. |
| Time | `Core/Time`, `Core/Permissions`, `Projection/SurfaceLenses`, `Surfaces/Time` | Canonical paths exist and are used by tests. | Medium: older `Features/Time` and other legacy dirs remain in repo, but active P1 files inspected are mostly canonical. | P1D should avoid creating feature-owned scheduling logic. | Legacy exists; do not touch unless migrating. |
| Search | `Projection/OverlayLenses`, `Projection/OverlayScenes`, `Core/Runtime`, `Stage/Overlays` | `Native/Ambitions/Core/Runtime/SearchIndex.swift`, `MemoryLensService+SearchAdapters.swift`, `Projection/OverlayLenses/SearchLens.swift` | Low/Medium: Search has canonical overlay lens and runtime index, but P1 coverage is not complete. | Add focused tests and route proof under canonical owners. | No need. |
| Notifications | `Core/Permissions`, `App`, `Projection/ExternalSnapshots`, `Surfaces/You` | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `NotificationRuntime.swift`, `NotificationPermission.swift` | Low for source ownership; runtime proof gap remains. | P1F should add tests and UI/settings proof without moving ownership. | No. |
| Persistence/offline | `Core/Persistence`, `Core/Runtime`, `App` | `Native/Ambitions/Core/Persistence/`, `AppContainerFactory.swift`, runtime services | Medium: root `Native/Ambitions/Persistence/` still exists as legacy compatibility. | Keep new persistence under `Core/Persistence`; only migrate legacy if touched. | No. |
| Completion/closure | `Core/Runtime`, `Projection/Mutations`, `Trust`, `Surfaces/Today` | `ClosureEngine.swift`, `Projection/Mutations/*`, `Trust/*`, Today service | Low for canonical mutation ownership; rendered proof gap remains. | P1A should connect Step closure proof without expanding non-canonical paths. | No. |

Final Architecture Tree inspected: yes. Canonical owners touched by this inventory: docs only. Source owners inspected: `App`, `Core`, `Projection`, `Composer`, `Stage`, `Surfaces`, `Trust`, `Quality`. Files moved or created: one QA inventory document. Old/non-canonical paths removed: none. Compatibility shims left behind: none added. No "equivalent" folder/path interpretation was used.

## Proof Gap Matrix

| Behavior | Source present? | Wired? | Persisted? | Tested? | Rendered? | Accessible? | Offline/account-free proven? | Status |
|---|---|---|---|---|---|---|---|---|
| Create reminder-like Step | Yes | Partial | Partial | Partial | Not proven | Not proven | Not proven | Partial |
| Complete Step | Yes | Yes for Today path | Yes | Yes, focused | Partial source projection only | Partial source primitive | Not release-proven | Partial |
| Reschedule Step/reminder | Yes | Partial | Partial | Partial helper/engine tests | Not proven | Not proven | Not proven | Partial |
| Recurring Step repeats | Yes | Yes for scoped runtime service | Yes | Yes, focused | Not proven | Not proven | Partial local-only runtime proof | Partial |
| Recurring Step pause | Yes | Yes for scoped runtime service | Yes | Yes, focused | Not proven | Not proven | Partial local-only runtime proof | Partial |
| Quick Capture saves locally | Yes | Yes for command/shell paths | Yes | Yes, focused | Partial | Partial source/test | Partial in local-only tests | Partial |
| Calendar fixed points/open windows | Yes | Partial | Not proven for placement | Yes, projection tests | Not current proof | Partial source/test | Not relevant/partial | Partial |
| Local search across required families | Yes | Partial | Uses repositories | Partial route tests | Not current proof | Partial source summary | Yes by design, not release-proven | Partial |
| Private notification copy | Yes | Yes for planner | Side-effect ledger | Yes, focused | Not device-proven | Not proven | Local-only side effect tested | Partial |
| Offline core without account | Yes | Partial | Yes source | Partial in-memory runtime tests | Not current proof | Not proven | Partial test proof | Partial |
| Missed Step asks what changed | Partial | Not proven | Partial reminder/recovery state | Partial engine tests | Not proven | Not proven | Not proven | Partial |
| Visible closure/receipt | Yes | Partial | Yes for evidence/event/command | Yes, focused | Not current proof | Partial primitive only | Not release-proven | Partial |

## Recommended Source Train Sequence

### P1A Step Core Reality

Goal: prove one canonical Step can be created from existing goal/planning source, shown in Today, completed, closed with proof/evidence/receipt, rescheduled through a command/recovery path, and persisted through repository state.

Files likely touched: `Native/Ambitions/Core/Domain/Step.swift`, `Native/Ambitions/Core/Domain/Planning/PlanningDomainModels.swift`, `Native/Ambitions/Core/Runtime/ClosureEngine.swift`, `Native/Ambitions/Projection/Commands/`, `Native/Ambitions/Projection/Mutations/`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService*`, `Native/AmbitionsTests/Today/`, `Native/AmbitionsTests/Persistence/`.

Gates targeted: `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_completion_creates_visible_closure`, `foundation_offline_core_runs_without_account` support only.

Non-goals: recurring repeat/pause, full goal pathing, Life Capital, Future Steps, calendar write behavior, visual redesign, release claims.

Validation required: focused unit tests for Step create/complete/reschedule/persist; `product-experience-gate-index-check.py`; skill registry and claim/copy/local-first scans; `git diff --check`; no full build unless source changes require it.

Closeout status allowed: Source Green at most if source/tests pass; Runtime Green only with current deterministic local runtime proof; Interaction Green only with UI/accessibility proof; Ready for Visual Review only with rendered screenshots for visual scope.

### P1B Recurring Steps and Persistence

Goal: implement/prove recurrence generation and pause/resume for Steps/reminders using local persistence.

Files likely touched: `Core/Domain/Planning`, `Core/Domain/ReminderModels.swift`, `Core/Runtime`, `Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift`, focused tests.

Gates targeted: `foundation_recurring_step_repeats_and_can_be_paused`.

Non-goals: notification delivery, Time visual redesign, Future Steps.

Validation required: recurrence unit tests, pause/resume tests, repository relaunch-equivalent tests, copy scans, local-first scan.

Closeout status allowed: Source Green/Runtime Green only if repeat and pause behavior are deterministic and persisted; no Interaction Green without UI proof.

### P1C Capture Saves Locally

Goal: prove production quick Capture saves locally without network, survives relaunch, stays global composer/overlay, and exposes honest receipt/failure states.

Files likely touched: `Composer/Capture`, `Core/Runtime/CaptureService*`, `Core/Persistence`, `Stage/Overlays`, capture/shell tests.

Gates targeted: `foundation_quick_capture_saves_without_network`, search support for captures.

Non-goals: full route graph expansion, Source Atlas marketplace, Life Capital, calendar placement.

Validation required: capture persistence test using SwiftData store, shell overlay test, network-disabled or no-network proof if available, accessibility checks if UI changes.

Closeout status allowed: Source Green/Runtime Green with source/tests and local persistence proof; Interaction Green requires UI proof.

### P1D Time Foundation

Goal: prove fixed points, open windows, protected windows, and real Step placement boundaries in Time without silent calendar writes.

Files likely touched: `Core/Time`, `Core/Permissions/CalendarReminders`, `Projection/SurfaceLenses/Time*`, `Projection/Mutations/Time*`, `Surfaces/Time`, Time tests.

Gates targeted: `foundation_calendar_planning_shows_fixed_points_and_open_windows`.

Non-goals: full-path scheduling, Make Room/Add with conflict, Future Steps, visual flagship redesign.

Validation required: Time projection tests, calendar denied/granted boundary tests, no silent write assertions, rendered accessibility proof for UI claims.

Closeout status allowed: Source Green/Runtime Green for projection/runtime; Ready for Visual Review only with screenshots; no Visual Green.

### P1E Local Search Foundation

Goal: prove local search finds goals, Steps, proof, captures, life context/Life Capital placeholder naming, and settings, then routes safely.

Files likely touched: `Core/Runtime/SearchIndex.swift`, `MemoryLensService+SearchAdapters.swift`, `Projection/OverlayLenses/SearchLens.swift`, `Stage/Overlays`, You search projection/tests.

Gates targeted: `foundation_search_finds_goals_steps_proof_life_capital_and_settings`.

Non-goals: first-class Life Capital implementation beyond search naming placeholder, Future Steps, external/cloud search.

Validation required: deterministic search tests, route handoff tests, local-only/no external service assertion, empty/budget states, accessibility proof if UI changes.

Closeout status allowed: Source Green/Runtime Green for local search; Interaction Green only with overlay UI proof.

### P1F Private Notifications and Missed Recovery

Goal: prove private notification copy, permission-aware local scheduling, notification action routing, and missed Step recovery that asks what changed without shame.

Files likely touched: `Core/Permissions/LocalNotificationFoundation.swift`, `NotificationRuntime.swift`, `AppBootstrapper.swift`, `Core/Domain/Reschedule`, `Projection/SurfaceLenses/TimeRecovery*`, `Surfaces/Today`, `Surfaces/Time`, notification/recovery tests.

Gates targeted: `foundation_notification_copy_is_private_by_default`, `foundation_missed_step_asks_what_changed`, `origin_missed_obligation_asks_what_changed_without_shame`.

Non-goals: push notifications, remote notification service extension, account-gated notification behavior, productivity score/streaks.

Validation required: notification copy tests, permission fallback tests, notification action routing tests, missed Step UI/copy tests, vocabulary/copy scans, device or simulator notification proof for Interaction Green.

Closeout status allowed: Source Green/Runtime Green with tests; Interaction Green only with delivered notification and UI proof.

## Do-Not-Do List

- No Life Capital implementation yet unless strictly needed as placeholder for search route naming.
- No full goal pathing yet.
- No Future Steps yet.
- No Make Room/Add with conflict yet.
- No Source Atlas expansion.
- No visual flagship redesign.
- No release claims.
- No new persistent surfaces.
- Do not make Capture a tab or root destination.
- Do not make Motion a destination.
- Do not expand `Features/` as an active owner.
- Do not use Source Atlas/R2 for private user context.
- Do not add cloud AI/core LLM runtime dependency.

## Gate Index and Action Map Updates

This inventory updates `docs/qa/product-experience-scenario-gates.md` and `docs/qa/product-experience-scenario-gates.yaml` only for notification private-copy evidence:

- `foundation_notification_copy_is_private_by_default`: Missing -> Partial.
- `lock_screen_notifications_private_by_default`: Missing -> Partial.

The upgrade is limited to Partial because current evidence is source/unit-test proof only. Device lock-screen proof, permission settings proof, delivered notification screenshots, and end-to-end notification tap handling are still required.

This inventory updates `docs/truth/PRODUCT_EXPERIENCE_ACTION_MAP.md` only to refresh the notification-support row and audit commit/date. It does not convert the action map into this report.

No other gate statuses are upgraded because current source/tests do not establish complete user-visible behavior.

## P1A Step Core Reality Addendum

Date: 2026-06-24
Commit: P1A final commit recorded in train closeout
Gates targeted: `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_completion_creates_visible_closure`, `foundation_missed_step_asks_what_changed`, `foundation_offline_core_runs_without_account`, `origin_missed_obligation_asks_what_changed_without_shame`

Source changed:

- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`
- `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`

Proof added:

- Focused source/runtime test creates a simple canonical `Step`, persists it through the SwiftData-backed goal repository, reloads it through a second repository facade, renders it through the current Today service projection, reschedules it through the existing Today action path, records non-shaming missed-Step recovery with `What changed?`, completes it, persists completed state, records local completion evidence, and verifies local-only runtime capability flags.
- The implementation routes through existing `Goal`, `GoalPlan`, `PlanSection`, `Step`, `AppRepositories`, `RepositoryBackedTodayService`, `RescheduleEngine`, feedback, evidence, and event-ledger primitives. It does not introduce a parallel Step model.
- Missed/reschedule copy uses `What changed?`, `Move it`, `Still counts`, `Blocked`, and `Not needed`, with no shame/scoring/streak language in the scoped path.

Remaining gaps:

- Scenario gate statuses remain unchanged because the proof is focused source/runtime coverage, not full rendered interaction, device, notification, Dynamic Type, VoiceOver, or visual review proof.
- P1A does not implement recurring Steps, full Capture, full Time foundation, Life Capital, Future Steps, Make Room/Add with conflict, notification delivery, full goal pathing, reviews, or release readiness.
- Existing Step behavior still depends on broader `Goal` repository persistence rather than a dedicated final Step repository boundary; this is acceptable for P1A but should be revisited during P1B/P1D architecture hardening.

Gate index updates: none. Current evidence improves scoped source/runtime proof but does not justify upgrading any target gate beyond Partial without rendered interaction/accessibility proof.

## P1A.1 Step Interaction Proof Addendum

Date: 2026-06-24
Baseline commit: `e6d4d91363a571fa74d2e0e870da2867bd87276d`
Final commit: P1A.1 final commit recorded in train closeout
Gates targeted: `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_completion_creates_visible_closure`, `foundation_missed_step_asks_what_changed`, `origin_missed_obligation_asks_what_changed_without_shame`

Source changed:

- `Native/Ambitions/Projection/SurfaceLenses/DayRailStepDetailState.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TodayActionClosureSheetState.swift`
- `Native/Ambitions/Stage/Overlays/TodayStepDetailSheet.swift`
- `Native/Ambitions/DesignSystem/ProductObjects/TodayPanels+02-TodayTinyActionButton.swift`
- `Native/Ambitions/DesignSystem/ProductObjects/TodayPanels+06-TodayPrimaryActionButton.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Interaction proof added:

- Focused UI test proves the rendered Step detail sheet exposes a Step title, `Mark Done`, `Move it`, and `Close the loop` controls through the current Today sheet/rendering path.
- The same UI test proves the rendered closure/recovery sheet shows `What changed?` and exposes `Done`, `Still counts`, `Move it`, `Blocked`, and `Not needed` as accessible outcome controls.
- The closure UI proof selects `Move it`, verifies the consequence preview remains visible, verifies `Save outcome` can be reached as a hittable control, and captures screenshot attachment `p1a1-rendered-step-recovery-controls` in the focused UI test xcresult.
- Focused P1A runtime test was rerun after the UI changes and still proves local create, Today projection, reschedule, missed recovery, completion, persistence/reload, and local-only capability flags.

Accessibility proof added:

- Rendered Step detail controls now expose stable accessibility identifiers and action-specific hints for complete, reschedule/move, defer, and Time handoff actions.
- Today tiny action buttons now expose stable accessibility labels and identifiers, making the current rendered complete action testable.
- The UI proof verifies the main Step detail actions and closure recovery outcomes are discoverable/hittable through XCTest accessibility queries.

Screenshot/visual proof status:

- Screenshot attachment produced by the focused UI test for the rendered closure/recovery sheet.
- This is Ready for Visual Review evidence only. It is not Visual Green because manual visual review, full device matrix, Dynamic Type sweep, Reduce Motion/Reduce Transparency/Increase Contrast sweep, and VoiceOver runtime review were not completed.

Remaining gaps:

- Gate statuses remain unchanged. P1A.1 adds partial rendered interaction evidence but does not prove full end-to-end normal-user tap mutation from the Today Start Here/Day Rail card into persisted completion/reschedule.
- The normal rendered Day Rail detail-open tap route did not produce reliable sheet presentation during this train and should be handled by a follow-up interaction repair before claiming Interaction Green.
- VoiceOver runtime, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, device, notification, recurring Step, and release proof remain unclaimed.

Gate index updates: none. Current evidence adds partial rendered interaction proof, but the target gates stay Partial until the normal user path, accessibility sweeps, and full end-to-end interaction proof are current.

## P1A.2 Normal Rendered Step Tap-to-Mutation Addendum

Date: 2026-06-24
Baseline commit: `1c7bc779506f739309f9d5423c2e6029212c9b0e`
Final commit: P1A.2 final commit recorded in train closeout
Gates targeted: `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_completion_creates_visible_closure`, `foundation_missed_step_asks_what_changed`, `foundation_offline_core_runs_without_account`, `origin_missed_obligation_asks_what_changed_without_shame`

Source changed:

- `Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels+02-AmbitionsDayRailView+03-mappedRowNode.swift`
- `Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels+02-AmbitionsDayRailView+04-upNextRow.swift`
- `Native/Ambitions/Stage/Overlays/TodayStepDetailSheet.swift`
- `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
- `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Normal rendered path proof added:

- The compact Day Rail `Up next` Step rows now use the existing `DayRailRowState.stepDetail` route instead of rendering as static text, so a user can tap a real visible Today Step row and open `TodayStepDetailSheet`.
- Focused UI proof starts from `TodayRealityRailRow`, opens `TodayStepDetail`, and verifies the normal rendered path exposes Step title, `Mark Done`, `Move it`, `Close the loop`, and recovery controls.

Mutation proof added:

- `testP1A2NormalRenderedStepCompletesFromTodayDetail` taps a normal Day Rail Step row, taps `Mark Done`, and verifies visible `Completion recorded` feedback.
- `testP1A2NormalRenderedStepMovesAndExposesRecoveryFromTodayDetail` taps a normal Day Rail Step row, verifies recovery controls, taps `Move it`, and verifies visible `What changed?` feedback.
- The P1A runtime test was rerun and still proves create, Today projection, reschedule, missed recovery, completion, persistence/reload, and local-only capability flags.

Accessibility proof added:

- The visible Start Here title affordance and Day Rail Step rows expose `Open step` labels, values, hints, and stable accessibility identifiers.
- Post-mutation feedback is exposed as a combined accessibility element with title and body values.
- The focused UI tests verify normal Step row, completion, move, and recovery controls through XCTest accessibility queries.

Screenshot/visual proof status:

- Screenshot attachment `p1a2-normal-step-recovery-controls` is produced by the focused UI test.
- This is Ready for Visual Review evidence only. It is not Visual Green because manual visual review, full device matrix, Dynamic Type sweep, Reduce Motion/Reduce Transparency/Increase Contrast sweep, and VoiceOver runtime review were not completed.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1A.2 proves the scoped normal rendered Step row interaction path, but it does not prove full reminder creation UI, recurring Steps, notification delivery, broad VoiceOver/manual accessibility sweeps, device proof, or release readiness.
- The normal Start Here hero can still represent a recovery/protection recommendation that is not itself a Step mutation target; P1A.2 repairs the real visible Day Rail Step row path instead of forcing non-Step hero recommendations to mutate.

Gate index updates: none. Current evidence materially improves normal rendered Step interaction proof, but the target gates stay Partial until full creation, accessibility sweep, device, and broader scenario proof are current.

## P1B Recurring Steps and Persistence Addendum

Date: 2026-06-24
Baseline commit: `9a8a5e3ebb227d5e3cc63ad12be5c58a595e1155`
Final commit: P1B final commit recorded in train closeout
Gates targeted: `foundation_recurring_step_repeats_and_can_be_paused`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`

Source changed:

- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
- `Native/AmbitionsTests/Runtime/RecurringStepLifecycleServiceTests.swift`

Recurrence proof added:

- The scoped runtime can create a recurring Step using existing `Goal`, `GoalPlan`, `PlanSection`, `Step`, `GoalTiming`, `StepType.recurringRoutine`, and SwiftData repository paths rather than introducing a parallel recurrence model.
- The runtime generates deterministic scheduled occurrence projections from persisted Step/Goal cadence state.
- Completing one generated occurrence records local feedback and progress evidence, advances the next suggested occurrence, and leaves the Step planned, repeatable, and recurring.
- Pausing the recurrence persists `GoalLifecycleState.paused` and suppresses generated occurrences; service-level resume restores active state and occurrence generation.

Persistence proof added:

- Focused P1B runtime tests create recurring Steps through `SimpleStepLifecycleService`, reload through a second repository facade backed by the same in-memory SwiftData store, and verify recurrence cadence, repeatable state, completion evidence, pause state, and resumed generation survive repository reload.
- The scoped recurrence path stores state in current local goal/step persistence mappings, including repeat cadence and repeatable Step metadata.

Offline/account-free proof added:

- Focused tests assert the current runtime boundary remains `localOnly` and has no remote intelligence backend.
- The scoped recurrence path uses local repositories only and does not require account, network, R2, Source Atlas upload, hosted AI, or private-life-graph backend behavior.

UI/accessibility proof status:

- No UI files were changed in P1B.
- No Interaction Green, Visual Green, Release Green, device validation, Dynamic Type sweep, Reduce Motion/Reduce Transparency/Increase Contrast sweep, or VoiceOver runtime proof is claimed.
- P1A.2 normal rendered Step path tests were not rerun because P1B did not touch Today rendered UI.

Remaining gaps:

- The recurring Step scenario gate moves from Unknown to Partial only. Runtime/persistence proof is current, but rendered recurring Step creation/pause controls, broad accessibility proof, device proof, notification delivery proof, and release proof remain unproven.
- P1B does not implement full Capture UI, full Time foundation, Life Capital, Future Steps, Make Room/Add with conflict, full goal pathing, reviews, notification delivery, visual redesign, or release/device validation.
- Service-level resume is implemented because it is feasible in the current runtime, but no rendered resume control is claimed.

Gate index updates:

- `foundation_recurring_step_repeats_and_can_be_paused`: Unknown -> Partial.
- No other scenario gate status changes. P1B adds supporting source/runtime evidence for reminder-like recurring Step behavior, offline/account-free runtime boundaries, and Today clarity by not changing Today UI, but it does not satisfy the full user-visible definitions for those broader gates.

## P1C Capture Saves Locally Addendum

Date: 2026-06-24
Baseline commit: `7730680cb21fbc556f6f079eefdd6dd19411f04d`
Final commit: P1C final commit recorded in train closeout
Gates targeted: `foundation_quick_capture_saves_without_network`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`, `origin_high_ambition_low_operating_structure_user_can_start`

Source changed:

- `Native/Ambitions/Core/Runtime/AmbitionsRuntimeFactory.swift`
- `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`
- `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift`
- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`

Capture local-save proof added:

- The production runtime factory now gives `DefaultCaptureService` the existing `SimpleStepLifecycleService`, so Step-routed Capture saves use current local `Goal`, `GoalPlan`, `PlanSection`, `Step`, and SwiftData repository paths rather than a parallel Step model.
- A `.timeSeed` Capture save creates a local simple Step immediately, saves a local Capture receipt, links the Capture to the Step's local goal, and keeps the Capture route as `Step`/Today rather than a detached draft pile.
- Routing an already-saved Capture to Time/Step creates the same local Step path when the Capture is not already linked, preserving safe raw Capture storage for unclear input.

Step routing proof added:

- `testP1CCaptureStepSaveCreatesLocalStepAndFeedsTodayProjection` proves a shell/global Capture save with a Step route persists a Step through the existing goal repository and appears through the current Today projection target.
- The proof asserts the persisted Today target uses the created local goal and Step IDs, preserving the P1A/P1A.2 Today path rather than adding Capture-specific rendering.

Persistence proof added:

- Focused tests use a shared in-memory SwiftData store plus a second repository facade to verify Capture and Step state reload from repository persistence.
- The created Step remains planned, non-repeatable, and stored under the existing Step lifecycle model.

Offline/account-free proof added:

- The scoped tests assert `AmbitionsRuntimeCapabilities.currentLocalRuntime` remains local-only and has no remote intelligence backend.
- The Capture-to-Step path uses local repositories only and does not require an account, network, R2, Source Atlas upload, hosted AI, or a private-life-graph backend.

UI/accessibility proof status:

- No SwiftUI files were changed in P1C.
- Existing Capture composer controls already expose text-entry/save accessibility identifiers and labels; this train does not add new rendered UI proof.
- Interaction Green is not claimed because no focused rendered Capture-to-Today UI test, VoiceOver runtime pass, Dynamic Type sweep, Reduce Motion/Reduce Transparency/Increase Contrast sweep, device proof, or screenshot review was completed in this train.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1C adds scoped Source/Runtime proof for local Capture-to-Step routing, but the full `foundation_quick_capture_saves_without_network` gate still needs rendered composer interaction proof, broader accessibility proof, device/simulator no-network workflow proof, and release-grade offline/no-account evidence before any status upgrade.
- P1C does not implement full Capture intelligence, Life Capital, Future Steps, Make Room, Add with conflict, full goal pathing, reviews, notification delivery, visual redesign, recurring Step UI, account work, R2 work, or release/device validation.
- Existing low-confidence Capture input can still save as a raw Capture/Open Field item until the user chooses a route; this is intentional and not a generic inbox/feed claim.

Gate index updates: none. Current evidence strengthens scoped source/runtime support, but all targeted scenario gates remain Partial because full user-visible, accessibility, no-network, device, and release evidence is not current.

## P1D Time Foundation Addendum

Date: 2026-06-24
Baseline commit: `122c1f6f4d738332fbc052e86a630ab11b96c394`
Final commit: P1D final commit recorded in train closeout
Gates targeted: `foundation_calendar_planning_shows_fixed_points_and_open_windows`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_quick_capture_saves_without_network`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`, `time_shows_whether_goal_fits` as limited qualitative scaffolding only

Source changed:

- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCandidateProjection.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TimeProjectionUtilityDatePressure.swift`
- `Native/AmbitionsTests/Time/P1DTimeFoundationTests.swift`
- `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift`

Time foundation proof added:

- Time now projects fixed points, open windows, and locally scheduled simple Steps through the existing `Goal`, `GoalPlan`, `PlanSection`, `Step`, `GoalTiming`, SwiftData repository, and Time projection paths.
- The scoped runtime can place an existing local Step in Time by writing `windowStart`, `windowEnd`, and `suggestedNextAt` on the existing Step timing model instead of creating a parallel schedule model.
- Time placement writes a local `itemScheduled` ledger event from Time with no calendar write and no network/account/R2/Source Atlas dependency.

Fixed point and open window proof added:

- `testP1DTimeProjectsFixedPointsOpenWindowsAndScheduledLocalSteps` proves a deadline-backed local Step appears as a fixed Time block and that open-window rows remain distinguishable from fixed time.
- Low-context Time now labels open windows as `Low context` until local Steps, protected time, or calendar context exist, avoiding fake capacity/open-time claims.
- Existing `TimeProjectionServiceTests` were rerun after replacing the obsolete raw-Capture placement assertion with the stricter local-Step-only placement contract.

Scheduled Step placement proof added:

- `SimpleStepLifecycleService.placeStepInTime(...)` persists scheduled local Step placement through the current local Step lifecycle and repository path.
- Scheduled local Steps use the existing Time week context and placement candidate projection, with timing copy labeled `Scheduled` from the persisted window start.
- Recurrence scaffolding is preserved: scheduled placement does not erase repeat cadence or repeatable Step metadata, and the P1B recurrence regression still passes.

Capture-created Step in Time proof added:

- `testP1DCaptureCreatedStepAppearsInTimeOnlyAfterLocalStepScheduling` proves a P1C Capture-created Step can appear in Time after it is scheduled through the current local Step path.
- Raw Capture records no longer become synthetic Time placement candidates with `capture.<id>` step IDs; Time waits for a real local Step before placement.

Persistence/offline proof added:

- Focused P1D tests use in-memory SwiftData stores and repository reload paths to verify scheduled Step timing persists locally.
- Tests assert `AmbitionsRuntimeCapabilities.currentLocalRuntime` remains local-only with no remote intelligence backend.
- P1A runtime, P1B recurrence, and P1C Capture local-save regressions were rerun and passed.

UI/accessibility proof status:

- No SwiftUI files were changed in P1D.
- No rendered Time interaction proof, screenshot proof, manual visual review, VoiceOver runtime pass, Dynamic Type sweep, Reduce Motion/Reduce Transparency/Increase Contrast sweep, device validation, Visual Green, Interaction Green, or Release Green is claimed.
- Existing projection models retain accessibility summary strings for fixed point and open window rows, but this train does not claim rendered accessibility proof.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1D proves scoped source/runtime Time foundation, but `foundation_calendar_planning_shows_fixed_points_and_open_windows` still needs rendered Time proof with accessibility queries before Interaction Green.
- Full capacity simulation, full goal fit, Future Steps, Make Room, Add with conflict, Life Capital, Source Atlas expansion, reviews, notification delivery, visual redesign, account work, R2 work, device proof, and release proof remain out of scope and unclaimed.
- `time_shows_whether_goal_fits` remains Partial only as qualitative LifeShape/capacity scaffolding; no full fit simulation or over-capacity warning is claimed.

Gate index updates: none. Current evidence strengthens scoped source/runtime support for Time foundation, but all targeted scenario gates remain Partial because rendered interaction/accessibility, device, visual, no-network workflow, and release evidence are not current.

## P1E Rendered Time Foundation Proof Addendum

Date: 2026-06-24
Baseline commit: `9f44d8c7849e21641b27e430168211702730ac90`
Final commit: P1E final commit recorded in train closeout
Gates targeted: `foundation_calendar_planning_shows_fixed_points_and_open_windows`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_quick_capture_saves_without_network`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`; `time_shows_whether_goal_fits` remains limited qualitative support only

Source changed:

- `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`
- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift`
- `Native/Ambitions/Projection/SurfaceLenses/TimePlacementCalendarContracts.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Rendered Time proof added:

- The normal rendered Time route `TimeSurface -> TimeViewModel -> RepositoryBackedTimeService -> TimeProjectionService -> TimeLifeSuiteProjector -> LifeShapeFieldView` now has focused UI proof.
- A DEBUG-only UI test seed creates a local Step through `SimpleStepLifecycleService.createSimpleStep(...)`, schedules it through `SimpleStepLifecycleService.placeStepInTime(...)`, and adds a local fixed-point goal through the existing goal repository path.
- `testP1ERenderedTimeFoundationShowsProjectedFixedOpenAndScheduledStepSemantics` opens Time through the normal shell route and verifies rendered fixed point, open window, and scheduled local Step rows.

Fixed/open/scheduled Step UI proof added:

- Fixed point proof: the rendered row `time.calendar.fixed-point` is visible and exposes fixed-point summary semantics.
- Open window proof: the rendered row `time.calendar.open-window` is visible and exposes open-window semantics without converting Time into a calendar clone.
- Scheduled Step proof: the rendered row `time.calendar.scheduled-step` is visible and exposes the scheduled local Step title `Mail the library card form` after scheduling through the local Step/Time path.

Low-context/no-fake-capacity proof added:

- The focused UI test launches a low-context preview route and verifies the open-window row remains `Low context` and local.
- The test asserts the low-context route does not fabricate `7 open days`, `optimized`, or AI recommendation claims.
- The scheduled Step row remains staged in the low-context route and does not leak the seeded Step.

Accessibility proof added:

- LifeShape horizon rows now expose explicit row-level accessibility labels, values, hints, and identifiers for fixed point, open window, scheduled Step, and related Time rows.
- The focused UI test queries rendered accessibility identifiers and labels for fixed/open/scheduled Step semantics.

Screenshot/visual proof status:

- The focused UI test attaches screenshot `p1e-rendered-time-foundation` in the result bundle.
- This is Ready for Visual Review evidence only. No Visual Green, Release Green, device validation, manual visual approval, or release readiness is claimed.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1E proves scoped rendered Time interaction/accessibility for fixed/open/scheduled local Step semantics, but full calendar planning still needs broader permission/device, no-network workflow, persistence/relaunch, visual review, and release evidence.
- Reminder-like create/complete/reschedule remains Partial; P1E proves scheduled Step rendering, not a full rendered create/complete/reschedule flow.
- Quick Capture and offline/no-account gates receive supporting evidence only through the preserved local Step path and low-context/no-network-claim boundaries; this train does not prove full no-network device workflow or rendered Capture save.
- `time_shows_whether_goal_fits` remains Partial qualitative support only; no full fit simulation, over-capacity warning, Future Steps, Make Room, Add with conflict, Life Capital, Source Atlas expansion, notification delivery, visual redesign, account work, R2 work, or release/device validation is claimed.

Gate index updates: none. The evidence is scoped rendered interaction/accessibility support for P1D Time foundation, not full gate completion.

## P1E.1 Time Persistence / Relaunch / No-Account Workflow Proof Addendum

Date: 2026-06-24
Baseline commit: `a8ee7257c1633d9572df09b54c19f4ca3f6452bd`
Final commit: P1E.1 final commit recorded in train closeout
Gates targeted: `foundation_calendar_planning_shows_fixed_points_and_open_windows`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_quick_capture_saves_without_network`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`; `time_shows_whether_goal_fits` remains limited qualitative support only

Source changed:

- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`
- `Native/AmbitionsTests/Time/P1DTimeFoundationTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Persisted/reload-backed Time proof added:

- P1E depended on DEBUG demo/preview test seeding, and demo/preview bootstraps use in-memory stores. P1E.1 adds a DEBUG-only live persistent bootstrap seed path for UI proof.
- The DEBUG seed still creates a local Step through `SimpleStepLifecycleService.createSimpleStep(...)`, schedules it through `SimpleStepLifecycleService.placeStepInTime(...)`, and writes the fixed point through the existing goal repository path.
- `testP1E1PersistedScheduledStepSurvivesRepositoryAndTimeServiceReload` proves a scheduled local Step survives repository/service reconstruction and still projects fixed/open/scheduled Time semantics.
- `testP1E1RenderedTimeFoundationPersistsAcrossLiveNoAccountRelaunch` seeds live persistent state once, terminates the app, relaunches live without the seed flag, and verifies the rendered Time path still exposes the scheduled local Step.

No-account/offline proof added:

- The live DEBUG seed marks local bootstrap/onboarding state complete in `AppStateSnapshot` so the UI test can open Time without sign-in or account setup.
- The runtime test asserts the current runtime boundary remains `.localOnly`, sync backend remains `.localOnly`, and no remote intelligence backend is present.
- The proof path uses local SwiftData repositories and does not require account, network, R2, Source Atlas upload, hosted AI, cloud LLM, or a private backend.

Rendered Time proof status:

- The relaunch-backed UI test opens Time through the normal shell route after live persistent relaunch and verifies `time.calendar.fixed-point`, `time.calendar.open-window`, and `time.calendar.scheduled-step`.
- The scheduled row exposes `Mail the library card form` only after it was persisted through the local Step/Time path.

Accessibility proof status:

- The relaunch-backed UI test queries rendered accessibility identifiers and labels for fixed/open/scheduled Step semantics after relaunch.
- Existing P1E row-level accessibility labels, values, hints, and identifiers remain the rendered accessibility proof surface.

Screenshot/visual proof status:

- The relaunch-backed UI test attaches screenshot `p1e1-reload-backed-time-foundation` in the result bundle.
- This is Ready for Visual Review evidence only. No Visual Green, Release Green, device validation, manual visual approval, or release readiness is claimed.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1E.1 proves scoped local persistence/relaunch support for rendered Time foundation, but full gate completion still needs broader no-network/device proof, calendar permission proof, manual visual review, persistence/relaunch coverage beyond the seeded Step, and release evidence.
- Reminder-like create/complete/reschedule remains Partial; P1E.1 proves scheduled Step persistence and rendering, not a full rendered create/complete/reschedule flow.
- Quick Capture and offline/no-account gates receive supporting evidence only; this train does not prove rendered Capture save, full network-disabled workflow, account UX, or release-grade offline evidence.
- `time_shows_whether_goal_fits` remains Partial qualitative support only; no full fit simulation, over-capacity warning, Future Steps, Make Room, Add with conflict, Life Capital, Source Atlas expansion, notification delivery, visual redesign, account work, R2 work, or release/device validation is claimed.

Gate index updates: none. The evidence is scoped persistence/relaunch/rendered interaction support for P1D/P1E Time foundation, not full gate completion.

## P1F Local Search Foundation Addendum

Date: 2026-06-24
Baseline commit: `26e5715d967b9a6c30428ed11e87404f1c8e3c8a`
Final commit: P1F final commit recorded in train closeout
Gates targeted: `foundation_search_finds_goals_steps_proof_life_capital_and_settings`, `foundation_quick_capture_saves_without_network`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_offline_core_runs_without_account`, `origin_many_goals_many_obligations_today_remains_clear`

Source changed:

- `Native/AmbitionsTests/Runtime/P1FLocalSearchFoundationTests.swift`

Local search proof added:

- `testP1FLocalSearchFindsFoundationObjectsWithoutAccountOrNetwork` creates a Step through the local Capture service path, persists proof evidence and a `Move it` feedback event, reloads repository facades, and verifies `DefaultMemoryLensService` can find the Step, capture-created Step source, proof, recent change, Time route, and Privacy setting.
- The Step search result preserves the canonical Step action language with `Open step`, routes to the existing goal context, and exposes planned Step context without introducing hosted AI, semantic cloud search, account state, R2, Source Atlas expansion, or a parallel search model.
- The proof asserts current runtime capability flags remain local-only, with no remote intelligence backend and no sync backend.

Life Context placeholder proof added:

- `testP1FYouEverythingSearchKeepsLifeContextAsLocalPlaceholderOnly` verifies You Everything Search includes a local Life Context result and filter while preserving footer copy that no external service is used.
- The test explicitly verifies no `Life Capital` filter is claimed. Life Capital remains a missing first-class implementation and must stay Partial until a future scoped train implements and proves it.

Validation status:

- Focused validation passed with `scripts/ambitions-xcode-test-focused.sh --batch P1F_LOCAL_SEARCH --test AmbitionsTests/P1FLocalSearchFoundationTests --timeout 15m --kill-after 60s`.
- The first focused wrapper run built but discovered zero tests because the local generated Xcode project had not picked up the new file. `xcodegen generate` was run locally; `Ambitions.xcodeproj` remains generated and untracked.
- A test-harness compile repair and a Life Context projection-expectation repair were made before the passing run. No production source changed.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1F proves scoped local source/runtime search coverage, not rendered search interaction, route UI, broad accessibility behavior, visual review, device proof, release readiness, or full no-network workflow proof.
- `foundation_search_finds_goals_steps_proof_life_capital_and_settings` remains Partial because first-class Life Capital is not implemented and rendered search/accessibility proof is not current.
- This phase does not implement semantic AI search, hosted search, Source Atlas expansion, Future Steps, Make Room, Add with conflict, full goal pathing, account behavior, R2 behavior, notification delivery, visual redesign, or release/device validation.

Gate index updates: none. Evidence is recorded in this inventory addendum only; gate status remains Partial until broader rendered and missing-object proof exists.

## P1G Private Notifications Foundation Addendum

Date: 2026-06-24
Baseline commit: `b6fd660c0da3135f3f39b3ce4ef99696f6f7a728`
Final commit: P1G final commit recorded in train closeout
Gates targeted: `foundation_notification_copy_is_private_by_default`, `lock_screen_notifications_private_by_default`, `personal_learning_insights_not_shown_aggressively`, `notification_does_not_emotionally_label_user`, `reminder_notification_can_be_plain_and_calendar_like`, `foundation_offline_core_runs_without_account`

Source changed:

- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`

Private notification proof added:

- `testP1GPrivateNotificationCopyAndPayloadExcludeSensitiveLockScreenContext` verifies local notification title/body stay generic when the external snapshot contains sensitive therapy, diagnosis, account, tax, and private-goal context.
- The same test verifies notification payload values do not include those sensitive terms and preserve only route/ID/local-first continuity fields needed to reopen in-app context.
- Existing notification tests still prove generic ritual copy, stale-snapshot clearing, authorization-missing fallback, failed refresh fallback, local-only side-effect ledger records, request lifecycle state, and category registration.

Permission/tap-routing proof added:

- `testP1GPermissionOptInFailureRegistersCategoriesAndReturnsFalse` proves permission opt-in failure returns `false` after registering the local categories instead of claiming a granted workflow.
- `NotificationResponsePayloadParserTests` were rerun and prove current parser mapping for default open, snooze, and complete actions while preserving canonical route payload values.

Validation status:

- Focused notification validation passed with `scripts/ambitions-xcode-test-focused.sh --batch P1G_PRIVATE_NOTIFICATIONS --test AmbitionsTests/LocalNotificationFoundationTests --timeout 15m --kill-after 60s` after clearing repo-local DerivedData to prove all 16 tests were discovered.
- Focused payload validation passed with `scripts/ambitions-xcode-test-focused.sh --batch P1G_NOTIFICATION_PAYLOAD --test AmbitionsTests/NotificationResponsePayloadParserTests --timeout 15m --kill-after 60s`.
- No production source changed.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1G proves scoped source/runtime request construction, private copy, local side-effect logging, permission fallback, and parser mapping. It does not prove delivered device notifications, lock-screen screenshots, simulator/device delivery, permission settings UI, foreground/background tap routing through the running app, broad accessibility behavior, visual review, release readiness, or App Store privacy approval.
- Notification implementation remains under current `Core/Permissions` ownership for this phase. `Core/Notifications` canonical ownership remains an architecture follow-up if the final architecture tree requires a future move; no new root notification surface, notification center, account/R2 behavior, or remote notification service was added.
- This phase does not implement push notifications, hosted notification services, account-gated notification behavior, private life graph sync, notification delivery claims, visual redesign, or release/device validation.

Gate index updates: none. Evidence is recorded in this inventory addendum only; gate status remains Partial until delivered-device/permission/tap-routing proof exists.

## P1H Missed Step Recovery End-to-End Addendum

Date: 2026-06-24
Baseline commit: `6a22e3b65f55b9bdc50e711dc2b428770779b1fd`
Final commit: P1H final commit recorded in train closeout
Gates targeted: `foundation_missed_step_asks_what_changed`, `origin_missed_obligation_asks_what_changed_without_shame`, `foundation_completion_creates_visible_closure`, `foundation_reminder_can_be_created_completed_and_rescheduled`, `foundation_offline_core_runs_without_account`

Source changed:

- `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
- `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift`

Recovery proof added:

- `testP1HMissedStepRecoveryPersistsThroughReloadWithoutShameCopy` creates a local Step, marks it missed through `SimpleStepLifecycleService.markMissedStepForRecovery(...)`, verifies the `What changed?` prompt, `Move it`, `Still counts`, `Blocked`, `Waiting`, and `Not needed` options, then reloads repository facades from the same SwiftData store.
- The test proves skipped and delayed recovery feedback events persist through reload, the Step remains planned with a new suggested next time, and the normal Today projection still points to the recovered Step through the local runtime path.
- Recovery persisted wording was repaired from `without shame` to `without blame`, and the test asserts recovery prompt/feedback copy does not contain shame, overdue, failed, lazy, streak, score, or productivity-pressure terms.

Validation status:

- Focused P1H validation passed with `scripts/ambitions-xcode-test-focused.sh --batch P1H_MISSED_RECOVERY --test AmbitionsTests/TodayCommandHandlerTests/testP1HMissedStepRecoveryPersistsThroughReloadWithoutShameCopy --timeout 15m --kill-after 60s`.
- P1A regression passed with `scripts/ambitions-xcode-test-focused.sh --batch P1H_P1A_REGRESSION --test AmbitionsTests/TodayCommandHandlerTests/testP1ASimpleStepLifecycleCreatesRendersReschedulesCompletesAndRecoversLocally --timeout 15m --kill-after 60s`.

Remaining gaps:

- Scenario gate statuses remain unchanged. P1H proves source/runtime persistence/reload and Today projection support, but it does not prove a fresh rendered UI recovery flow, screenshot artifact, manual visual review, VoiceOver/Dynamic Type sweep, device proof, notification interaction, or release readiness.
- The normal Step detail surface already exposes `Close the loop`, `Move it`, and receipt copy, but this phase does not claim rendered Interaction Green because no new UI test or screenshot was produced for the missed-Step recovery choices.
- This phase does not implement full coaching, behavior profiling, full goal pathing, Life Capital, Future Steps, Make Room, Add with conflict, Source Atlas expansion, notification delivery, visual redesign, account work, R2 work, or release/device validation.

Gate index updates: none. Evidence is recorded in this inventory addendum only; gate status remains Partial until rendered recovery and broader accessibility/device proof exists.

## Recommended Immediate Next Prompt

```text
From /Users/devan/Documents/GitHub/ambitions on main, run P1E Rendered Time Foundation Proof.

Work only on main. Do not create branches or PRs.

Scope: produce focused rendered Time proof for the P1D Time foundation without broad redesign.

Use active truth files and retained skills first. Preserve Today / Goals / Time / You as the only persistent surfaces, Capture as global composer, Motion as behavior, Trust as Proof / Source / Privacy / History / Receipts, and local-first/offline core law.

Do not implement Life Capital, Future Steps, full goal pathing, Make Room/Add with conflict, Source Atlas expansion, recurring Step UI, visual redesign, account work, R2 work, notification delivery, or release claims.

Required gate: `foundation_calendar_planning_shows_fixed_points_and_open_windows`.

Before edits, prove active runtime/source ownership. Keep new implementation under canonical owners only: Projection/SurfaceLenses, Surfaces/Time, DesignSystem/ProductObjects, Trust, Quality, and tests.

Validation: focused Time UI/accessibility tests, P1D runtime regression, product experience gate check, skill registry check, vocabulary/copy/claim/local-first scans, unsupported-claim scan on changed files, and git diff --check. Do not claim Visual Green or Release Green without current proof.
```
