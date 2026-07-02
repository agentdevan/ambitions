# Runtime Authority Map

Status: AMB-1665 static authority map

Snapshot date: 2026-07-02

Source snapshot inspected for AMB-1707: `78bf205478578720cc91cc6b8fc0604c6d2b5172` on `main`

Scope: M00 runtime authority map only. No Swift behavior, source migration,
runtime authority migration, or product-surface behavior was changed by this
artifact.

Evidence class: Implemented Yellow. This map classifies current source
entry points and direct-write markers so later remediation can proceed without
fake Green. It is static source evidence only. It does not prove runtime
correctness, device behavior, accessibility behavior, privacy/legal approval,
build health, TestFlight readiness, App Store readiness, or total
LocalRuntimeOS completion.

## Canonical Runtime Law

Meaningful Private Life Runtime mutation must preserve:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Current architecture direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
```

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Classification Taxonomy

| Classification | Meaning in this map | Green allowed? |
| --- | --- | --- |
| canonical command | The entry is inside or routes into `Core/LocalRuntimeOS` command/runtime authority. | No. Source-static Yellow until tests/proof cover the exact behavior. |
| adapter into command | The entry collects or routes external/user input, then hands it to command or outbox authority before meaningful state mutation. | No. Adapter tests and receipt proof still required. |
| projection-only read | The entry reads/materializes projection data and must not mutate canonical private graph state. | No. Projection privacy and stale-state proof still required. |
| unsafe write | A direct write marker exists outside canonical runtime authority. | No. Must stay Yellow/Red debt until moved, quarantined, or proven adapter-only. |
| unknown | Static evidence is insufficient to prove the entry is command-routed, adapter-only, or projection-only. | No. Must link follow-up issue. |

## Command Evidence

- `git status --short --branch`
- `git rev-parse HEAD`
- `git ls-remote origin refs/heads/main`
- `rg` source scans for App Intents, widgets, share extension, notifications,
  EventKit/Reminders, CloudKit, external creation import, migration/repair,
  previews/debug fixtures, and direct-write markers.
- `python3 scripts/ambitions-runtime-direct-write-audit.py --json`
- Source inspection of:
  - `Native/Ambitions/App/AppContainerFactory.swift`
  - `Native/Ambitions/App/AppBootstrapper.swift`
  - `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`
  - `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor+ReceiptPersistence.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/RuntimeTransactionCommitPolicy.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/RuntimeCommandMutationCommitter.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ShareExtensionIntake.swift`
  - `Native/AmbitionsShareExtension/ShareViewController.swift`
  - `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift`
  - `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- AMB-1707 source inspection of:
  - `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`
  - `Native/Ambitions/App/ShellCommandRouter.swift`
  - `Native/Ambitions/Stage/AmbitionsStage.swift`
  - `Native/Ambitions/Stage/StageReducer.swift`
  - `Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift`
  - `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`
  - `Native/Ambitions/Composer/Capture/CaptureContinuityLine.swift`
  - `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`
  - `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`
  - `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift`
  - `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
  - `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`
  - `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift`
  - `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`
  - `Native/Ambitions/Surfaces/Goals/CreateGoalViewModel.swift`
  - `Native/Ambitions/Surfaces/Goals/GoalsViewModels.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+02-Snapshot.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+11-applyAdaptiveRecommendation.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+17-submitClarificationAnswer.swift`
  - `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift`
  - `Native/Ambitions/Surfaces/Time/TimeSurface.swift`
  - `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`
  - `Native/Ambitions/Surfaces/Time/TimeRitualsSurface.swift`
  - `Native/Ambitions/Surfaces/Time/TimeRitualsViewModel.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/RepositoryBackedTimeService.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/TimeRitualsProjectionService.swift`
  - `Native/Ambitions/Core/Domain/RealityModels.swift`
  - `Native/Ambitions/Core/Runtime/LocalScheduleBlockRepository.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor+CalendarWriteIntent.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift`
  - `Native/Ambitions/Surfaces/You/YouSurface.swift`
  - `Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift`
  - `Native/Ambitions/Surfaces/You/YouScreen+08-YouPlanningHandoffRow.swift`
  - `Native/Ambitions/Surfaces/You/YouViewModel.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift`

## Entry-Point Inventory

| Entry point | Evidence paths | Classification | Proof ceiling | Follow-up |
| --- | --- | --- | --- | --- |
| App bootstrap and dependency wiring | `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/App/AppBootstrapper.swift` | adapter into command | Source shows runtime services, command executor, external creation import, notification maintenance, and external action service are wired, but this is not behavioral proof. | AMB-1708, AMB-1666 |
| App UI actions | `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Surfaces/You`, `Native/Ambitions/Stage/Overlays` | unsafe write | AMB-1707 traces the main app UI handlers. Some rows are command-routed or projection-only, but Today, Goals, Time rituals, and Capture still have repository writes outside `Core/LocalRuntimeOS/`. | AMB-1666, AMB-1667, AMB-1709 |
| Global Capture | `Native/Ambitions/Composer/Capture`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`, `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | unsafe write | External creation import creates `AmbitionsCommand(kind: .quickCapture)`, but the in-app global Capture and shell Capture UI save through `DefaultCaptureService` repository writes outside LocalRuntimeOS. | AMB-1666, AMB-1667 |
| Today actions | `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift` | unsafe write | Closure and rejection receipts use `TodayReceiptCommandService`, but inline feedback and quick-log actions still save feedback, evidence, goals, or captures through projection/repository paths. | AMB-1666, AMB-1667 |
| Goals actions | `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+02-Snapshot.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | unsafe write | Create, clarification, detail, priority, and adaptive recommendation paths are now traced, but writes still land through Projection/SurfaceLenses and Core/Persistence unit-of-work paths. | AMB-1666, AMB-1667, AMB-1709 |
| Time edits and local schedule blocks | `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Core/Domain/RealityModels.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | unsafe write | `RealityModels.swift` contains local schedule file writes outside LocalRuntimeOS. Canonical TimeEngine storage exists, but authority migration is not complete. | AMB-1709, AMB-1667 |
| You/profile edits | `Native/Ambitions/Surfaces/You`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift` | canonical command | AMB-1707 traces preference save through `YouPreferencesCommandService` and `RuntimeCommandMutationCommitter`; static evidence does not prove every You row is a runtime mutation or device behavior. | AMB-1666, AMB-1667 |
| Widgets and Live Activity | `Native/AmbitionsWidgetExtension/NextStepWidget.swift`, `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift` | projection-only read | Widgets read safe external snapshots and deep link back to app. No widget canonical state write is claimed. | AMB-1708, AMB-1668 |
| App Intents, creation | `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | App Intent input is durable handoff first, then imported as `AmbitionsCommand`; adapter receipt and terminated-app proof remain future work. | AMB-1708, AMB-1668 |
| App Intents, step inspection/control | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`, `Native/Ambitions/App/AppIntentLaunchRouter.swift` | adapter into command | Current source queues app routes for inspection/start/guarded close. Exact mutation receipt proof for each shortcut remains future work. | AMB-1708, AMB-1668 |
| Share Extension | `Native/AmbitionsShareExtension/ShareViewController.swift`, `Native/AmbitionsShareExtension/ShareIntakeView.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ShareExtensionIntake.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | Share saves a local handoff request and opens app for import. Extension payload redaction and terminated-app tests remain future work. | AMB-1708, AMB-1668 |
| Notifications | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift` | adapter into command | Notification scheduling reads safe snapshot data and records side effects. It remains a system adapter, not canonical state authority. | AMB-1708, AMB-1668 |
| EventKit and Reminders | `Native/Ambitions/Core/Permissions/CalendarReminders`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift` | adapter into command | LocalRuntimeOS side-effect outbox exists, but full external adapter enforcement and receipt tests remain future work. | AMB-1708, AMB-1668 |
| CloudKit continuity apply paths | `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift` | adapter into command | Source shows eligibility/zone setup and local-authoritative sync vocabulary. This does not prove approved private graph sync. | AMB-1709, AMB-1668 |
| Import/restore and portable snapshots | `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift` | unsafe write | Legacy snapshot save path remains in Core/Persistence. LocalRuntimeOS backup/migration stores exist, but migration proof is not claimed. | AMB-1709, AMB-1667 |
| Migration and repair | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift` | canonical command | Canonical owner is present, but repair execution authority and migration tests are not proven by this map. | AMB-1709, AMB-1667 |
| Previews, debug, fixtures | `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`, `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`, debug branches in `Native/Ambitions/App/AppContainerFactory.swift` | unknown | Preview/debug paths can seed stores or use temporary file storage. They are not production authority proof and need quarantine review. | AMB-1710 |

## AMB-1707 App UI And Capture Mutation Inventory

Evidence baseline: `78bf205478578720cc91cc6b8fc0604c6d2b5172` on `main`.

This inventory is static source evidence only. It does not prove runtime
correctness, UI behavior, receipt durability, replay correctness, device
behavior, privacy/legal approval, or release readiness.

| Candidate | Evidence paths | Classification | Static finding | Follow-up |
| --- | --- | --- | --- | --- |
| Capture draft typing, route preview, proposal, and cancel | `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift` | projection-only read | Draft text, route choice, preview, proposal, and cancel mutate only local view state until the user accepts save or route actions. | None for AMB-1707; keep runtime proof Yellow until behavior tests cover the save boundary. |
| Global Capture accepted save from composer and activated shell seam | `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift` | unsafe write | UI save calls `CaptureServicing.createCapture`; `DefaultCaptureService` prepares CaptureRouteGraph intake, then persists through `repository.saveCaptures` outside `Core/LocalRuntimeOS/`. | AMB-1666, AMB-1667 |
| Capture continuity line actions: Ready to Place, Keep for review, Idea, Waiting, Review later, Archive, Attach proof | `Native/Ambitions/Composer/Capture/CaptureContinuityLine.swift`, `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift` | unsafe write | Buttons route to `CaptureViewModel`, then `CaptureServicing.updateCaptureState`, `routeToTimeSeed`, `markAsWaiting`, `markAsOptionalSomeday`, `markAsDeliverableSeed`, or `attachCaptureToGoal`; the default service still saves captures through repositories outside LocalRuntimeOS. | AMB-1666, AMB-1667 |
| Capture-to-Goal route transition and post-create attachment | `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`, `Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift`, `Native/Ambitions/Stage/AmbitionsStage.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | unsafe write | Opening Create Goal from a capture is Stage route state, but successful creation and post-create attachment call Goals and Capture services. The capture promotion unit-of-work receipt is Core/Persistence-backed, not LocalRuntimeOS authority proof. | AMB-1666, AMB-1667, AMB-1709 |
| Shell command route transitions and overlay presentation | `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Stage/StageReducer.swift`, `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift` | projection-only read | `presentCommandSheet`, `presentCreateGoal`, `route(to:)`, search result routing, and overlay changes mutate Stage route/overlay state and command history only; they are not private graph mutation proof. | AMB-1708 for external route adapter proof; AMB-1666 if a route becomes a runtime mutation. |
| Shell command quick capture execution | `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift` | unsafe write | `execute(.quickCapture)` validates non-empty text, calls `CaptureServicing.createCapture`, and records shell continuity. The typed proof receipt at this boundary is explicitly unavailable in source comments, and persistence uses the legacy Capture service path. | AMB-1666, AMB-1667 |
| Today navigation, detail, focus, replacement, protection, and Time-shape sheets | `Native/Ambitions/Surfaces/Today/TodaySurface.swift`, `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`, `Native/Ambitions/Surfaces/Today/TodayViewModel.swift` | projection-only read | Start/pause/stop, open detail, open Capture, protection review, Time-shape review, and replacement approval are Stage route, transient message, or sheet/projection state in the inspected paths. | AMB-1666 if any of these become persisted runtime mutations. |
| Today closure and recommendation rejection receipts | `Native/Ambitions/Surfaces/Today/TodaySurface.swift`, `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`, `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift` | canonical command | Closure and rejection call `TodayReceiptCommandService`, which builds `AmbitionsCommand` values and commits through `RuntimeCommandMutationCommitter`; this is source-static command evidence only. | AMB-1666 for behavior proof; AMB-1667 if repository-backed receipt history remains outside canonical storage. |
| Today inline feedback, completion, reschedule, recovery, and quick-log actions | `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift` | unsafe write | `TodayServicing.performAction` reaches `performFeedbackAction`, which writes feedback, evidence, goals, captures, or external reminders through projection/repository services. | AMB-1666, AMB-1667, AMB-1709 |
| Goals Create Goal submit and clarification materialization | `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`, `Native/Ambitions/Surfaces/Goals/CreateGoalViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+02-Snapshot.swift`, `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | unsafe write | Create Goal and clarification save call `GoalsServicing.createGoal` or `submitClarificationAnswer`, then save goals/drafts through repository or Core/Persistence unit-of-work paths. | AMB-1666, AMB-1667, AMB-1709 |
| Goals detail actions, priority changes, and adaptive recommendations | `Native/Ambitions/Surfaces/Goals/GoalsViewModels.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+11-applyAdaptiveRecommendation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift` | unsafe write | Detail actions call `GoalsServicing.performAction`; mutation handlers write feedback, evidence, goals, app-state priority order, or external calendar/reminder side effects through projection/repository services. | AMB-1666, AMB-1667, AMB-1709 |
| Time LifeShape field edit, protected-placement review, and undo | `Native/Ambitions/Surfaces/Time/TimeSurface.swift`, `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`, `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewState.swift` | projection-only read | The inspected LifeShape controls call `TimeFieldMutationCoordinator` and mutate `TimeSurfaceState`, review state, visible mutation, or undo state in memory. No repository persistence is claimed for this UI field path. | AMB-1666 if this UI path becomes a persisted Time mutation. |
| Time calendar-aware action and calendar context observation | `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/RepositoryBackedTimeService.swift` | unsafe write | `makeTimeCalendarAware` reads calendar availability and appends an event-ledger entry from a projection service; it is user-initiated and local, but not a LocalRuntimeOS command-path proof. | AMB-1708, AMB-1709, AMB-1667 |
| Time rituals actions | `Native/Ambitions/Surfaces/Time/TimeRitualsSurface.swift`, `Native/Ambitions/Surfaces/Time/TimeRitualsViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeRitualsProjectionService.swift` | unsafe write | Ritual complete, minimum version, quick log, delay, skip, easier version, and not-relevant actions save feedback, evidence, and goals through `RepositoryBackedTimeRitualsService`. | AMB-1666, AMB-1667, AMB-1709 |
| Confirmed local schedule write command path | `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor+CalendarWriteIntent.swift`, `Native/Ambitions/Core/Runtime/LocalScheduleBlockRepository.swift`, `Native/Ambitions/Core/Domain/RealityModels.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | canonical command | A `scheduleItem` command path exists under LocalRuntimeOS for confirmed calendar-write intent, and canonical `LifeCalendarStore` exists. The executor still writes through legacy `FileLocalScheduleBlockRepository` and `RealityModels` helpers, so migration remains Yellow. | AMB-1709, AMB-1667 |
| You appearance/default preference save | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift`, `Native/Ambitions/Surfaces/You/YouScreen+08-YouPlanningHandoffRow.swift`, `Native/Ambitions/Surfaces/You/YouViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift` | canonical command | Save preferences calls `YouPreferencesCommandService.saveYouPreferences`, builds `AmbitionsCommand(kind: .updateUserPreferences)`, commits through `RuntimeCommandMutationCommitter`, then saves app-state preferences inside the command closure. | AMB-1666 for behavior proof; AMB-1667 if app-state storage authority remains outside canonical storage. |
| You detail, life context, learning-control, and route-opening controls | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Surfaces/You/YouScreen+04-YouLifeContextSurface.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService*.swift` | projection-only read | The inspected controls expand/focus local detail, route to You destinations, or display source-tied learning/privacy controls. AMB-1707 found no additional persisted private graph mutation in these UI controls. | AMB-1666 if future You controls gain persistence. |
| You notification permission action | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` | adapter into command | Notification opt-in is an OS adapter/system permission action, not a private graph mutation. Scheduling proof remains system-surface scope, not AMB-1707 Green proof. | AMB-1708, AMB-1668 |

## Direct-Write Marker Summary

`python3 scripts/ambitions-runtime-direct-write-audit.py --json` currently
classifies 49 production/support direct-write marker files:

| Classification | Count | Meaning |
| --- | ---: | --- |
| canonical command | 25 | Direct-write markers are inside `Core/LocalRuntimeOS`. |
| adapter into command | 2 | System/external paths hand off to command/outbox authority. |
| projection-only read | 2 | External snapshot paths materialize projection data for external readers. |
| unsafe write | 19 | Legacy direct-write markers remain outside LocalRuntimeOS. |
| unknown | 1 | Preview/debug fixture direct-write marker needs quarantine review. |

Marker counts: FileManager 23, SwiftData 22, write_call 14, context_insert 8,
try_save 3, context_delete 3, ModelContext 3, context_save 1.

This is not a Green result. The audit is Yellow because unsafe and unknown rows
remain linked debt.

## Forbidden-Root Direct-Write Classifications

The direct-write audit treats any new production/support direct-write marker
outside `Native/Ambitions/Core/LocalRuntimeOS/` as a finding unless it is
classified here with a follow-up.

| Path | Markers | Classification | Follow-up | Evidence note |
| --- | --- | --- | --- | --- |
| `Native/Ambitions/Core/Domain/RealityModels.swift` | FileManager, write_call | unsafe write | AMB-1709 | Local schedule block file writes live in Core/Domain and must move under LocalRuntimeOS authority. |
| `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` | FileManager | adapter into command | AMB-1708 | Notification scheduling reads safe external snapshots and records side effects; action payloads route back through app command handling. |
| `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift` | SwiftData, context_insert | unsafe write | AMB-1709 | Legacy SwiftData persistence scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift` | try_save | unsafe write | AMB-1709 | Portable snapshot save path remains in legacy Core/Persistence scaffolding. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData model authority remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+03-EntityRevisionTombstoneRecord.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData tombstone model authority remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData projection-record model authority remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataModels.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData model authority remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+02-persisted.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData mapping scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+03-feedbackRecord.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData feedback mapping scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+04-apply.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData apply mapping scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+05-entityRevisionTombstone.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData tombstone mapping scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData mapping scaffolding remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | SwiftData, context_delete | unsafe write | AMB-1709 | Legacy SwiftData repository helper remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+04-SwiftDataGoalPersistence.swift` | SwiftData, ModelContext, context_insert, context_delete | unsafe write | AMB-1709 | Legacy goal persistence writes remain outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift` | SwiftData, context_insert | unsafe write | AMB-1709 | Legacy graph projection record repository writes remain outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataAppStateRepository.swift` | SwiftData, context_insert | unsafe write | AMB-1709 | Legacy app-state repository writes remain outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+07-SwiftDataRuntimeSnapshotLedgerRepository.swift` | SwiftData, context_insert | unsafe write | AMB-1709 | Legacy runtime snapshot ledger repository writes remain outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift` | SwiftData, context_insert | unsafe write | AMB-1709 | Legacy reminder repository writes remain outside Core/LocalRuntimeOS. |
| `Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift` | SwiftData | unsafe write | AMB-1709 | Legacy SwiftData repository authority remains outside Core/LocalRuntimeOS. |
| `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` | FileManager | unknown | AMB-1710 | Preview/debug fixture path uses temporary FileManager storage and needs fixture authority review. |
| `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift` | FileManager, write_call | adapter into command | AMB-1708 | External creation handoff queue is imported by DefaultExternalCreationImportService into AmbitionsCommand. |
| `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift` | write_call | projection-only read | AMB-1708 | External snapshot export writes app-group projection data after privacy validation; it is not canonical private graph state. |
| `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | FileManager | projection-only read | AMB-1708 | Shared snapshot URL helper supports projection export and external-surface reads. |

## Command Event Projection Receipt Replay Matrix

| Runtime law step | Current evidence | Coverage status | Residual gap |
| --- | --- | --- | --- |
| Command | `AmbitionsCommandExecutor`, `RuntimeCommandMutationCommitter`, `DefaultExternalCreationImportService`, `AppIntentBridge`, `ExternalActionCommandService`, `TodayReceiptCommandService`, `YouPreferencesCommandService` | Implemented Yellow | AMB-1707 statically inventories App UI/Capture handlers. Unsafe UI/Capture paths still need command-path conversion and behavior proof in AMB-1666/AMB-1667. System adapter proof remains AMB-1708/AMB-1668. |
| Event | `RuntimeTransactionCommitPolicy`, `RuntimeTransactionCoordinator`, `RuntimeEventStore`, `EventStoreSQLite` | Implemented Yellow | Legacy Core/Persistence and Core/Domain writes can still bypass the canonical event path until AMB-1709/AMB-1667. |
| Projection | `ProjectionStoreSQLite`, `ExternalSurfaceSnapshotWriter`, `ExternalWidgetProjection`, `Projection/SurfaceLenses` | Implemented Yellow | Projection-only external surfaces need adapter-level privacy/staleness proof in AMB-1708/AMB-1668. |
| Receipt | `CommandReceiptFactory`, `CommandJournalAppendReceipt`, `TrustSystem`, `TodayReceiptCommandService`, side-effect outbox records | Implemented Yellow | Not every UI/system mutation candidate has current receipt proof. Unsafe writes are not receipt-proven. |
| Replay | `RuntimeEventCommandReplayAdapter`, `CommandReplayAdapter`, `CommandJournal.linkRuntimeCommit`, `RuntimeTransactionCommitPolicy` idempotency metadata | Implemented Yellow | Replay proof is command-path scoped, not a total app-state replay guarantee. Legacy direct writes remain outside replay proof. |

## Direct-Write CI Audit Design

Implemented script: `scripts/ambitions-runtime-direct-write-audit.py`.

Quality-gate integration: `scripts/ambitions-quality-gate.py` now requires and
runs the direct-write audit.

Audit behavior:

- Scan production/support Swift roots for direct-write markers:
  SwiftData, ModelContext, FileManager, UserDefaults, `.write(`,
  context insert/delete/save, and repository/store save calls.
- Treat `Native/Ambitions/Core/LocalRuntimeOS/` as the canonical owner for
  current direct-write markers, still with Implemented Yellow proof ceiling.
- Treat listed non-LocalRuntimeOS paths as classified Yellow debt only when
  this map mentions both the path and the follow-up.
- Fail on new unclassified direct-write markers outside LocalRuntimeOS.
- Fail when this map is missing, stale, or does not mention the classified
  forbidden-root path and follow-up.

This audit is a governance guard, not proof that unsafe writes are fixed.

## Residual Gaps

| Gap | Status | Follow-up |
| --- | --- | --- |
| App UI and Capture action handlers are statically inventoried, but several paths still write through legacy repository/projection services outside LocalRuntimeOS. | unsafe write / Implemented Yellow by path | AMB-1666, AMB-1667, AMB-1709 |
| System-surface adapter behavior needs terminated-app, extension, notification, widget, and receipt proof. | Implemented Yellow / unknown by path | AMB-1708, AMB-1668 |
| Legacy SwiftData/Core/Persistence and Core/Domain local schedule writes remain outside canonical runtime authority. | unsafe write | AMB-1709, AMB-1667 |
| Preview/debug fixture mutation-like behavior is not quarantined or proven production-isolated by this slice. | unknown | AMB-1710 |
| Runtime authority map and proof matrix are static-source only. | Implemented Yellow | AMB-1711 |
| Direct-write audit is local/static and not yet independently proven in hosted CI. | Implemented Yellow | AMB-1712 |

## Closeout Boundary

- Final Architecture Tree inspected: yes, through `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by AMB-1707: `docs/audits` only. Earlier AMB-1665 slices also touched scripts.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Architecture debt remains: yes, in legacy persistence/domain direct-write paths, system adapter proof, App UI/Capture command-path conversion, and preview/debug fixtures.
- Next repair train: AMB-1708, AMB-1709, AMB-1710, then AMB-1666/AMB-1667/AMB-1668 before source migration parents.
- No equivalent folder/path interpretation was used.
- No Green runtime authority claim is made.
