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
| Recurring Step repeats | Partial | Not proven | Metadata persisted | Partial metadata tests | Not proven | Not proven | Not proven | Unknown/Partial |
| Recurring Step pause | Partial | Not proven | Not proven | Not proven | Not proven | Not proven | Not proven | Missing |
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

## Recommended Immediate Next Prompt

```text
From /Users/devan/Documents/GitHub/ambitions on main, run P1A Step Core Reality.

Work only on main. Do not create branches or PRs.

Scope: implement the smallest canonical Step foundation slice that proves one Step can be created from current local source, appears in Today as a real Step, can be completed with local feedback/evidence/command/event proof, can be rescheduled through the existing safe command/recovery path, and persists through SwiftData repository state.

Use active truth files and retained skills first. Preserve Today / Goals / Time / You as the only persistent surfaces, Capture as global composer, Motion as behavior, Trust as Proof / Source / Privacy / History / Receipts, and local-first/offline core law.

Do not implement recurring Steps, Life Capital, Future Steps, full goal pathing, Make Room/Add with conflict, Source Atlas expansion, visual redesign, account work, R2 work, or release claims.

Required gates: foundation_reminder_can_be_created_completed_and_rescheduled, foundation_completion_creates_visible_closure, and supporting evidence for foundation_offline_core_runs_without_account.

Before edits, prove active runtime/source ownership. Keep new implementation under canonical owners only: Core/Domain, Core/Runtime, Core/Persistence, Projection/Commands, Projection/Mutations, Projection/SurfaceLenses, Surfaces/Today, Surfaces/Time, Trust, and tests.

Validation: focused unit tests for Step create/complete/reschedule/persist, product experience gate check, skill registry check, vocabulary/copy/claim/local-first scans, unsupported-claim scan on changed files, and git diff --check. Do not claim Runtime Green, Interaction Green, Visual Green, or Release Green without current proof.
```
