# Runtime Authority Map

Status: AMB-1665 static authority map with AMB-1721 external adapter contract,
AMB-1722 route audit, AMB-1723 EventKit/Reminders addenda, and AMB-1724
projection snapshot/redaction addendum, plus AMB-1730 legacy runtime owner-move
addendum, AMB-1731 direct-write repair addendum, and AMB-1732 external payload
rejection plus EventKit/Reminders result receipt and unused ReminderOutbox
deletion source addendum

Snapshot date: 2026-07-03

Source snapshots inspected:

- AMB-1707: `78bf205478578720cc91cc6b8fc0604c6d2b5172` on `main`
- AMB-1708: `e25b35125096da6f8da1739689f0040870a95ae4` on `main`
- AMB-1709: `b7251077e9280d5d914f7fa2521c9c4a68863898` on `main`
- AMB-1710: `e6139849cdb956782dae4f0f4974705f463759c9` on `main`
- AMB-1719 baseline: `6c60c6c95fadc9990b0d8198ab895e20ec05f8de` on `main`
- AMB-1721 baseline: `35975f72cb5d4918057b879ecfc31f350fdd8121` on `main`
- AMB-1722 baseline: `3ae3b884701babb3694e40a9e5fbaf2f5e62949f` on `main`
- AMB-1723 baseline: `39ebf1cf1550ad6a169ba7c71fa684ae2fdf56b8` on `main`
- AMB-1724 baseline: `38f142973fbecca15efd71a39fcac4ec5fe0c6ed` on `main`
- AMB-1731 repair run: working tree based on `b616fa056570341094d0c42003f0fc1aa1c16058` on `main`
- AMB-1732 repair run: working tree based on `4e6359a668dc711e62c469d95f0c43a85a62347c` on `main`

Scope: M01 AMB-1665 runtime authority map plus AMB-1721 contract, AMB-1722 route
audit, AMB-1723 EventKit/Reminders audit, AMB-1724 projection
snapshot/redaction addenda, AMB-1730/AMB-1731 source repair addenda, and
AMB-1732 external payload rejection receipt, EventKit/Reminders result receipt,
and unused ReminderOutbox deletion source addendum. This artifact records
actual source changes only where named by the addenda and does not promote
parent runtime authority to Green.

Evidence class: Implemented Yellow. This map classifies current source
entry points and direct-write markers so later remediation can proceed without
fake Green. It is static source evidence only. It does not prove runtime
correctness, device behavior, accessibility behavior, privacy/legal approval,
build health, TestFlight readiness, App Store readiness, or total
LocalRuntimeOS completion.

## AMB-1730 Legacy Runtime Owner-Move Addendum

AMB-1730 moved `111` legacy runtime production files out of
`Native/Ambitions/Core/Runtime` and into `Native/Ambitions/Core/LocalRuntimeOS`
owners. Earlier batches moved PlanningEngine, TimeEngine, and SearchRecall
files. The final all-remaining pass moved the remaining CaptureRouteGraph,
PrivacySecurity, PrivateLifeRuntimeKernel, Projections, Boundary,
SourceAtlas, and TimeEngine files. Representative retired files include:

- `BufferEngine.swift`
- `CapacityEngine.swift`
- `GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift`
- `GoalClarificationService+02-DefaultGoalClarificationService.swift`
- `GoalClarificationService+03-ClassificationConfidence.swift`
- `GoalClarificationService.swift`
- `GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift`
- `GoalContradictionService+02-DefaultGoalContradictionService.swift`
- `GoalContradictionService+03-GoalResourceEntity.swift`
- `GoalContradictionService.swift`
- `GoalDomainPackService.swift`
- `GoalDomainPacks.swift`
- `GoalEnergyFitService.swift`
- `GoalEnergyLearningService.swift`
- `GoalFreshnessUpdateService.swift`
- `GoalPathCompilerService.swift`
- `GoalResourceGraphService.swift`
- `GoalTeachingSignalService.swift`
- `GoalUnderstandingService.swift`
- `OneStepGoalProjector.swift`
- `OpenCapacityEngine.swift`
- `PressureEngine.swift`
- `RecommendationExplanationAdapter.swift`
- `RecoveryEngine.swift`
- `ScheduleInstallKernel+02-ScheduleInstallRecord.swift`
- `ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift`
- `ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift`
- `ScheduleInstallKernel+03-ScheduleInstallKernel.swift`
- `ScheduleInstallKernel+04-ScheduleInstallRecord.swift`
- `ScheduleInstallKernel.swift`
- `SimpleStepLifecycleService+Recurring.swift`
- `SimpleStepLifecycleService.swift`
- `StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift`
- `StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift`
- `StepElasticityEngine+02-StepElasticityEngine.swift`
- `StepElasticityEngine+03-StepElasticityEngineInput.swift`
- `StepElasticityEngine.swift`
- `StepGraphCompiler+02-StepGraphCompiler+02-compile.swift`
- `StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift`
- `StepGraphCompiler+02-StepGraphCompiler.swift`
- `StepGraphCompiler.swift`
- `StepQualityFirewall.swift`
- `StepReallocationRuntimeBridge.swift`
- `TimeRitualGoalSemantics.swift`
- `MemoryLensResult+SearchPresentation.swift`
- `MemoryLensService+SearchAdapters.swift` -> `MemoryLensService+SearchResults.swift`
- `MemoryLensService.swift`

Before AMB-1730, the legacy runtime production-use guard reported
`currentLegacyRuntimeFiles=111` and `legacyRuntimeFileCeiling=111`. After the
PlanningEngine, goal clarification/contradiction, TimeEngine, step
planning/scheduling, MemoryLens/SearchRecall, and all-remaining owner moves, it
reports `currentLegacyRuntimeFiles=0` and `legacyRuntimeFileCeiling=0`.

This addendum removes source ownership from `Core/Runtime`. It does not remove
persistence direct writes, complete external adapter command/rejection receipt
proof, run focused Swift/Xcode validation, or make M02 Green.

## AMB-1731 Direct-Write Repair Addendum

AMB-1731 moved legacy direct-write storage and migration authority out of
`Native/Ambitions/Core/Persistence` and `Native/Ambitions/Core/Domain` into
canonical LocalRuntimeOS owners.

Before this repair, `python3 scripts/ambitions-runtime-direct-write-audit.py --json`
reported `unsafe write=19`, `unknown=1`, and
`unsafeOrUnknownProductionRowCount` was not yet enforced. After this repair, the
same guard reports `unsafeOrUnknownProductionRowCount=0`, `status=green`, and
`proofStatus=Implemented Green` for the direct-write audit scope. The post-split
guard output classifies `directWriteMarkerCount=50` files with 45 canonical
LocalRuntimeOS command rows and no unsafe or unknown production rows.

Files moved or converted:

- `Native/Ambitions/Core/Persistence/SwiftDataModels*.swift` ->
  `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStore*`
- `Native/Ambitions/Core/Persistence/SwiftDataRepositories*.swift` ->
  `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftData*`
- `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift` ->
  `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreLifeContextPersistence.swift`
- `Native/Ambitions/Core/Persistence/PortableSnapshotContracts*.swift` and
  `Native/Ambitions/Core/Persistence/PortableSnapshotService*.swift` ->
  `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/Portable*`
- Local schedule JSON file helpers moved from
  `Native/Ambitions/Core/Domain/RealityModels.swift` to
  `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockFileStore.swift`
- Legacy app-group SwiftData store migration helpers live in
  `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift`
  and are covered by the canonical persistence ownership tests.
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` is now
  classified as `test-only support` because the file is `#if DEBUG` fenced and
  uses in-memory preview runtime composition plus a temporary external-creation
  store. It is not production runtime authority.

Guard change:

- `scripts/ambitions-runtime-direct-write-audit.py` now fails when unsafe or
  unknown production direct-write rows exist.
- Reintroduced direct-write markers outside `Core/LocalRuntimeOS` must be
  classified as adapter/projection/test-only support or the guard returns Red.

Remaining direct-write rows are canonical LocalRuntimeOS storage/event/side
effect/source-atlas/time/trust rows, adapter rows, projection-only external
snapshot rows, or DEBUG preview support. No unsafe or unknown production
direct-write rows remain in the current guard output.

Rollback plan: revert the AMB-1731 commit to restore the prior paths and guard
table, then rerun `xcodegen generate`, `git diff --check`,
`python3 scripts/ambitions-runtime-direct-write-audit.py --json`, and the
focused LocalRuntimeOS owner tests. If rollback is required after user data has
been created, preserve the app support SwiftData store and portable snapshot
exports before reverting.

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
| test-only support | The entry is test/debug/preview-only support and is not production runtime authority. | No. Cannot be cited as production proof. |
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
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+ReceiptPersistence.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeTransactionCommitPolicy.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeCommandMutationCommitter.swift`
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
  - `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+04-DefaultCaptureService.swift`
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
  - `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockRepository.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+CalendarWriteIntent.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift`
  - `Native/Ambitions/Surfaces/You/YouSurface.swift`
  - `Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift`
  - `Native/Ambitions/Surfaces/You/YouScreen+08-YouPlanningHandoffRow.swift`
  - `Native/Ambitions/Surfaces/You/YouViewModel.swift`
  - `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift`
- AMB-1708 source inspection of:
  - `project.yml`
  - `Native/Ambitions/App/AmbitionsRootScene.swift`
  - `Native/Ambitions/App/AppBootstrapper.swift`
  - `Native/Ambitions/App/AppExternalRouting.swift`
  - `Native/Ambitions/App/AppExternalRouteOverlayTranslation.swift`
  - `Native/Ambitions/App/AppExternalRoutePayloadTranslation.swift`
  - `Native/Ambitions/App/AppExternalRouteTranslator.swift`
  - `Native/Ambitions/App/AppDeepLinkRegistry.swift`
  - `Native/Ambitions/App/AppIntentLaunchRouter.swift`
  - `Native/Ambitions/App/Intents/AmbitionsAppShortcutDestination.swift`
  - `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`
  - `Native/Ambitions/App/Intents/AmbitionsDeepActionShortcut.swift`
  - `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`
  - `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift`
  - `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads+02-ExternalObjectReopeningProjector.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceControlContracts.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift`
  - `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift`
  - `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService.swift`
  - `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`
  - `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`
  - `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`
  - `Native/Ambitions/Core/Permissions/NextStepLiveActivityService.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CausalMergeEngine.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/ConflictPolicyEngine.swift`
  - `Native/AmbitionsShareExtension/ShareIntakeView.swift`
  - `Native/AmbitionsShareExtension/ShareViewController.swift`
  - `Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift`
  - `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
  - `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- AMB-1709 source inspection of:
  - `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
  - `Native/Ambitions/Core/Persistence/SwiftDataModels*.swift`
  - `Native/Ambitions/Core/Persistence/SwiftDataRepositories*.swift`
  - `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift`
  - `Native/Ambitions/Core/Persistence/PortableSnapshotService*.swift`
  - `Native/Ambitions/Core/Persistence/LegacyImportService.swift`
  - `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`
  - `Native/Ambitions/Core/Persistence/StoreHealthCheck.swift`
  - `Native/Ambitions/Core/Persistence/SupportDiagnosticsBundle.swift`
  - `Native/Ambitions/Core/Domain/RealityModels.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockRepository.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionMaterializer.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/StoreInvariantChecker.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PreMigrationBackup.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/DryRunMigration.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RestoreRollback.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctorRepairOperator.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/SchemaLedger.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEnvelope.swift`
- AMB-1710 source inspection of:
  - `project.yml`
  - `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
  - `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
  - `Native/Ambitions/PreviewSupport/PreviewTimeRitualScenarios.swift`
  - `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift`
  - `Native/Ambitions/PreviewSupport/CaptureComposerPreviews.swift`
  - `Native/Ambitions/PreviewSupport/CaptureAtmosphereComposerPreviews.swift`
  - `Native/Ambitions/PreviewSupport/AppDeepLinkPreviewRouter.swift`
  - `Native/Ambitions/PreviewSupport/StubGoalsService.swift`
  - `Native/Ambitions/PreviewSupport/StubTodayService.swift`
  - `Native/Ambitions/App/AppContainerFactory.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AppServices.swift`
  - `Native/Ambitions/Core/Time/AmbitionsClock.swift`
  - `Native/Ambitions/Core/Time/PreviewClock.swift`
  - `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`
  - `Native/Ambitions/Core/Persistence/PreviewCaptureRepository.swift`
  - `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`
  - `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift`
  - `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasCoverageRuntimeFixtureModels.swift`
  - `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
  - `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`
  - `Native/AmbitionsTests/Time/TimeClockTests.swift`
  - `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`

## Entry-Point Inventory

| Entry point | Evidence paths | Classification | Proof ceiling | Follow-up |
| --- | --- | --- | --- | --- |
| App bootstrap and dependency wiring | `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/App/AppBootstrapper.swift` | adapter into command | Source shows runtime services, command executor, external creation import, notification maintenance, widget/notification payload handling, and external action service are wired, but this is not behavioral proof. | AMB-1666, AMB-1668 |
| App UI actions | `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Surfaces/You`, `Native/Ambitions/Stage/Overlays` | unsafe write | AMB-1707 traces the main app UI handlers. Some rows are command-routed or projection-only, but Today, Goals, Time rituals, and Capture still have repository writes outside `Core/LocalRuntimeOS`. AMB-1709 classifies the shared persistence debt; it does not move authority. | AMB-1666, AMB-1667 |
| Global Capture | `Native/Ambitions/Composer/Capture`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`, `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | unsafe write | External creation import creates `AmbitionsCommand(kind: .quickCapture)`, but the in-app global Capture and shell Capture UI save through `DefaultCaptureService` repository writes without complete command receipt proof. | AMB-1666, AMB-1667 |
| Today actions | `Native/Ambitions/Surfaces/Today`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift` | unsafe write | Closure and rejection receipts use `TodayReceiptCommandService`, but inline feedback and quick-log actions still save feedback, evidence, goals, or captures through projection/repository paths. | AMB-1666, AMB-1667 |
| Goals actions | `Native/Ambitions/Surfaces/Goals`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+02-Snapshot.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryArrayHelpers.swift` | canonical command | AMB-1731 moved the SwiftData repository substrate under LocalRuntimeOS storage. App-wide Goals command/receipt behavior still needs AMB-1666/AMB-1667 proof; this row is not broad UI Green. | AMB-1666, AMB-1667 |
| Time edits and local schedule blocks | `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockFileStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | canonical command | AMB-1731 moved local schedule file IO out of `Core/Domain/RealityModels.swift` and into TimeEngine. Rendered Time behavior and full command/receipt proof remain separate. | AMB-1667, AMB-1717, AMB-1718 |
| You/profile edits | `Native/Ambitions/Surfaces/You`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift` | canonical command | AMB-1707 traces preference save through `YouPreferencesCommandService` and `RuntimeCommandMutationCommitter`; static evidence does not prove every You row is a runtime mutation or device behavior. | AMB-1666, AMB-1667 |
| Widgets and Live Activity UI | `Native/AmbitionsWidgetExtension/NextStepWidget.swift`, `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift`, `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | projection-only read | Widgets and Live Activity UI read verified safe snapshots and deep link back to app. Current widget source does not render a mutating control. | AMB-1668 |
| Widget payload action bridge | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift` | rejectionReceipt source-present / focused XCTest passed | AMB-1732 changes widget payload handling so mutating payload actions downgrade to Today review routing and record a local-only `commandBridge` rejection receipt when a recorder is configured. Current widget UI still does not emit command payloads. Focused simulator XCTest passed; device/lifecycle and replay proof remain missing. | AMB-1668, AMB-1732 |
| Live Activity lifecycle refresh | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/Permissions/NextStepLiveActivityService.swift`, `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift` | adapter into command | Live Activity request/update/end decisions derive from safe external snapshots during notification refresh. This is system-surface side-effect handling, not private graph authority proof. | AMB-1668 |
| App Intents, creation | `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | App Intent input is durable handoff first, then imported as `AmbitionsCommand(kind: .quickCapture)`; adapter receipt and terminated-app proof remain future work. | AMB-1668 |
| App Intents, step inspection/control | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`, `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift`, `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift`, `Native/Ambitions/App/AppIntentLaunchRouter.swift` | adapter into command | Current source queues app routes for inspection/start/system controls. Guarded close opens the app for confirmation; the intent itself does not prove a canonical graph mutation. | AMB-1666, AMB-1668 |
| Share Extension | `Native/AmbitionsShareExtension/ShareViewController.swift`, `Native/AmbitionsShareExtension/ShareIntakeView.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | Share saves a local handoff request and opens app for import into `AmbitionsCommand(kind: .quickCapture)`. Extension payload redaction and terminated-app tests remain future work. | AMB-1668 |
| Notifications | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift`, `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift` | adapter into command / rejectionReceipt source-present / focused XCTest passed | Notification scheduling reads safe snapshot data and records side effects. AMB-1732 changes mutating notification action payloads to downgrade to open-Today routing and record local-only `commandBridge` rejection receipts when a recorder is configured. Focused simulator XCTest passed; device action proof remains missing. | AMB-1668, AMB-1732 |
| EventKit and Reminders | `Native/Ambitions/Core/Permissions/CalendarReminders`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift` | adapter into command / sideEffectOutbox source-present / focused XCTest passed | EventKit and Reminders writes require local commit evidence before external save, and AMB-1732 records success, failed-save, and permission-denied results through `SideEffectOutbox.recordResult`. No-localCommit Today/Goals callers remain blocked/Yellow. AMB-1732 deleted unused `ReminderOutbox` duplicate authority, leaving `EventKitOutbox` as the inspected reminder side-effect path. | AMB-1668, AMB-1732 |
| CloudKit continuity apply paths | `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift` | adapter into command | AMB-1709 found no remote private-graph apply writer in the inspected SyncContinuity files. Source shows feature flag default off, local-store authority, private payload denial, local outbox/review decisions, and zone setup only. It does not prove approved private graph sync or remote apply behavior. | AMB-1668, AMB-1680 |
| Import/restore and portable snapshots | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PortableSnapshotServiceOperations.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift` | canonical command | AMB-1731 moved portable snapshot import/export apply source under MigrationRepair. Existing-data migration proof is limited to focused fixtures until broader migration validation runs. | AMB-1667, AMB-1717, AMB-1720 |
| Migration and repair | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift` | canonical command | Canonical owner is present. AMB-1709 confirms dry-run, backup, doctor, schema-ledger, and rollback scaffolding remain source-static and do not prove repair execution authority or migration safety. | AMB-1667, AMB-1718, AMB-1720 |
| Previews, debug, fixtures | `Native/Ambitions/PreviewSupport`, debug branches in `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`, fixture and clock tests | test-only support | AMB-1731 classifies the `#if DEBUG` preview container temporary store as test-only support. Demo seed paths are still not production authority proof. | AMB-1667, AMB-1668 |

## AMB-1707 App UI And Capture Mutation Inventory

Evidence baseline: `78bf205478578720cc91cc6b8fc0604c6d2b5172` on `main`.

This inventory is static source evidence only. It does not prove runtime
correctness, UI behavior, receipt durability, replay correctness, device
behavior, privacy/legal approval, or release readiness.

| Candidate | Evidence paths | Classification | Static finding | Follow-up |
| --- | --- | --- | --- | --- |
| Capture draft typing, route preview, proposal, and cancel | `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift` | projection-only read | Draft text, route choice, preview, proposal, and cancel mutate only local view state until the user accepts save or route actions. | None for AMB-1707; keep runtime proof Yellow until behavior tests cover the save boundary. |
| Global Capture accepted save from composer and activated shell seam | `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+04-DefaultCaptureService.swift` | unsafe write | UI save calls `CaptureServicing.createCapture`; `DefaultCaptureService` prepares CaptureRouteGraph intake, then persists through `repository.saveCaptures` without complete command receipt proof. | AMB-1666, AMB-1667 |
| Capture continuity line actions: Ready to Place, Keep for review, Idea, Waiting, Review later, Archive, Attach proof | `Native/Ambitions/Composer/Capture/CaptureContinuityLine.swift`, `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Composer/Capture/CaptureViewModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift` | unsafe write | Buttons route to `CaptureViewModel`, then `CaptureServicing.updateCaptureState`, `routeToTimeSeed`, `markAsWaiting`, `markAsOptionalSomeday`, `markAsDeliverableSeed`, or `attachCaptureToGoal`; the default service still saves captures through repositories without complete command receipt proof. | AMB-1666, AMB-1667 |
| Capture-to-Goal route transition and post-create attachment | `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`, `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`, `Native/Ambitions/Stage/Overlays/AppShellOverlayView.swift`, `Native/Ambitions/Stage/AmbitionsStage.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryArrayHelpers.swift` | canonical command | Opening Create Goal from a capture is Stage route state, and AMB-1731 moved the backing unit-of-work storage under LocalRuntimeOS. Complete command receipt proof for the cross-surface flow remains separate. | AMB-1666, AMB-1667 |
| Shell command route transitions and overlay presentation | `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Stage/StageReducer.swift`, `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift` | projection-only read | `presentCommandSheet`, `presentCreateGoal`, `route(to:)`, search result routing, and overlay changes mutate Stage route/overlay state and command history only; they are not private graph mutation proof. | AMB-1666 if a route becomes a runtime mutation; AMB-1668 for external adapter behavior proof. |
| Shell command quick capture execution | `Native/Ambitions/App/ShellCommandRouter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureService+03-DefaultCaptureService.swift` | unsafe write | `execute(.quickCapture)` validates non-empty text, calls `CaptureServicing.createCapture`, and records shell continuity. The typed proof receipt at this boundary is explicitly unavailable in source comments, and persistence uses the Capture service path without complete command receipt proof. | AMB-1666, AMB-1667 |
| Today navigation, detail, focus, replacement, protection, and Time-shape sheets | `Native/Ambitions/Surfaces/Today/TodaySurface.swift`, `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`, `Native/Ambitions/Surfaces/Today/TodayViewModel.swift` | projection-only read | Start/pause/stop, open detail, open Capture, protection review, Time-shape review, and replacement approval are Stage route, transient message, or sheet/projection state in the inspected paths. | AMB-1666 if any of these become persisted runtime mutations. |
| Today closure and recommendation rejection receipts | `Native/Ambitions/Surfaces/Today/TodaySurface.swift`, `Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift`, `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift` | canonical command | Closure and rejection call `TodayReceiptCommandService`, which builds `AmbitionsCommand` values and commits through `RuntimeCommandMutationCommitter`; this is source-static command evidence only. | AMB-1666 for behavior proof; AMB-1667 if repository-backed receipt history remains outside canonical storage. |
| Today inline feedback, completion, reschedule, recovery, and quick-log actions | `Native/Ambitions/Surfaces/Today/TodayViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService.swift`, `Native/Ambitions/Projection/SurfaceLenses/TodayFeatureService+02-RepositoryBackedTodayService+Repository05-performFeedbackAction.swift` | unsafe write | `TodayServicing.performAction` reaches `performFeedbackAction`, which writes feedback, evidence, goals, captures, or external reminders through projection/repository services. | AMB-1666, AMB-1667 |
| Goals Create Goal submit and clarification materialization | `Native/Ambitions/Surfaces/Goals/CreateGoalScreen.swift`, `Native/Ambitions/Surfaces/Goals/CreateGoalViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+02-Snapshot.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryArrayHelpers.swift` | canonical command | Create Goal and clarification save still need full command/receipt behavior proof, but the SwiftData unit-of-work source is no longer owned by `Core/Persistence`. | AMB-1666, AMB-1667 |
| Goals detail actions, priority changes, and adaptive recommendations | `Native/Ambitions/Surfaces/Goals/GoalsViewModels.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+10-performMutation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+11-applyAdaptiveRecommendation.swift`, `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+16-repositories.swift` | unsafe write | Detail actions call `GoalsServicing.performAction`; mutation handlers write feedback, evidence, goals, app-state priority order, or external calendar/reminder side effects through projection/repository services. | AMB-1666, AMB-1667 |
| Time LifeShape field edit, protected-placement review, and undo | `Native/Ambitions/Surfaces/Time/TimeSurface.swift`, `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`, `Native/Ambitions/Surfaces/Time/ProtectedPlacementReviewState.swift` | projection-only read | The inspected LifeShape controls call `TimeFieldMutationCoordinator` and mutate `TimeSurfaceState`, review state, visible mutation, or undo state in memory. No repository persistence is claimed for this UI field path. | AMB-1666 if this UI path becomes a persisted Time mutation. |
| Time calendar-aware action and calendar context observation | `Native/Ambitions/Surfaces/Time/TimeViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/RepositoryBackedTimeService.swift` | unsafe write | `makeTimeCalendarAware` reads calendar availability and appends an event-ledger entry from a projection service; it is user-initiated and local, but not a LocalRuntimeOS command-path proof. | AMB-1667, AMB-1668 |
| Time rituals actions | `Native/Ambitions/Surfaces/Time/TimeRitualsSurface.swift`, `Native/Ambitions/Surfaces/Time/TimeRitualsViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/TimeRitualsProjectionService.swift` | unsafe write | Ritual complete, minimum version, quick log, delay, skip, easier version, and not-relevant actions save feedback, evidence, and goals through `RepositoryBackedTimeRitualsService`. | AMB-1666, AMB-1667 |
| Confirmed local schedule write command path | `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+CalendarWriteIntent.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockRepository.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockFileStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | canonical command | A `scheduleItem` command path exists under LocalRuntimeOS for confirmed calendar-write intent, and AMB-1731 moved file-backed schedule block helpers under TimeEngine. | AMB-1667, AMB-1717, AMB-1718 |
| You appearance/default preference save | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift`, `Native/Ambitions/Surfaces/You/YouScreen+08-YouPlanningHandoffRow.swift`, `Native/Ambitions/Surfaces/You/YouViewModel.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/ObjectState/YouPreferencesCommandService.swift` | canonical command | Save preferences calls `YouPreferencesCommandService.saveYouPreferences`, builds `AmbitionsCommand(kind: .updateUserPreferences)`, commits through `RuntimeCommandMutationCommitter`, then saves app-state preferences inside the command closure. | AMB-1666 for behavior proof; AMB-1667 if app-state storage authority remains outside canonical storage. |
| You detail, life context, learning-control, and route-opening controls | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Surfaces/You/YouScreen+04-YouLifeContextSurface.swift`, `Native/Ambitions/Projection/SurfaceLenses/YouFeatureService*.swift` | projection-only read | The inspected controls expand/focus local detail, route to You destinations, or display source-tied learning/privacy controls. AMB-1707 found no additional persisted private graph mutation in these UI controls. | AMB-1666 if future You controls gain persistence. |
| You notification permission action | `Native/Ambitions/Surfaces/You/YouSurface.swift`, `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` | adapter into command | Notification opt-in is an OS adapter/system permission action, not a private graph mutation. Scheduling proof remains system-surface scope, not AMB-1707 Green proof. | AMB-1668 |

## AMB-1708 System Surface Mutation Inventory

Evidence baseline: `e25b35125096da6f8da1739689f0040870a95ae4` on `main`.

This inventory is static source evidence only. It does not prove runtime
correctness, terminated-app behavior, extension behavior, widget behavior,
notification behavior, Live Activity behavior, EventKit behavior, CloudKit
behavior, receipt durability, replay correctness, device behavior,
privacy/legal approval, or release readiness.

| Candidate | Evidence paths | Classification | Static finding | Follow-up |
| --- | --- | --- | --- | --- |
| Widget extension snapshot rendering | `Native/AmbitionsWidgetExtension/NextStepWidget.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift`, `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | projection-only read | Timeline entries decode verified `ExternalSurfaceSnapshot` records and render/deep-link projection data. The inspected widget UI has no direct canonical state mutation control. | AMB-1668 for device/widget privacy and stale-snapshot proof. |
| Widget payload action bridge | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AmbitionsRuntimeServices.swift` | rejectionReceipt source-present / focused XCTest passed | `handleWidgetPayload` builds `ExternalActionCommand(widgetPayload:)`; AMB-1732 downgrades mutating payload actions to Today review routing and records local-only `commandBridge` rejection receipts when a recorder is configured. Current widget UI does not emit those payloads; device/lifecycle and replay proof remain missing. | AMB-1668 and AMB-1732. |
| Live Activity UI deep links | `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`, `Native/Ambitions/Projection/ExternalSnapshots/NextStepActivityAttributes.swift` | projection-only read | Live Activity regions render content state derived from external snapshots and link back into the app. They do not mutate the private graph in the inspected extension source. | AMB-1668 for device/live-activity proof. |
| Live Activity lifecycle refresh | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/Permissions/NextStepLiveActivityService.swift`, `Native/Ambitions/Projection/ExternalSnapshots/NextStepActivityAttributes.swift` | adapter into command | Notification refresh reads the verified external snapshot, then requests, updates, or ends ActivityKit surfaces. This is an OS side effect derived from projection data, not canonical private graph mutation proof. | AMB-1668. |
| App Intents capture and goal draft creation | `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | Creation intents enqueue `ExternalCreationRequest` handoff records, then app import drains them into `AmbitionsCommand(kind: .quickCapture, actor: .externalSurface)`. | AMB-1668 for terminated-app import and receipt proof. |
| App Intents navigation, step inspection, guarded close, and system controls | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift`, `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift`, `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift`, `Native/Ambitions/App/AppIntentLaunchRouter.swift` | adapter into command | Open/start/show/inspect intents queue URLs for in-app routing. Guarded close and system controls open the app for confirmation; static source does not show those intents directly writing canonical state. | AMB-1666 and AMB-1668. |
| Share Extension save | `Native/AmbitionsShareExtension/ShareViewController.swift`, `Native/AmbitionsShareExtension/ShareIntakeView.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift` | adapter into command | The extension writes a local durable handoff request, then opens Ambitions. App import drains the request into `AmbitionsCommand(kind: .quickCapture)`. | AMB-1668 for extension lifecycle and redaction proof. |
| Notification scheduling | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift` | adapter into command | Scheduling reads a verified external snapshot, builds private-default notification content, replaces pending requests, refreshes Live Activity state, and records side-effect outcome. | AMB-1668 for device notification proof. |
| Notification action payload handling | `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`, `Native/Ambitions/App/AppExternalRouteTranslator.swift` | rejectionReceipt source-present / focused XCTest passed | Notification payload actions route through `ExternalActionCommand(notificationPayload:)`; AMB-1732 downgrades mutating action names to open-Today routing and records local-only `commandBridge` rejection receipts when a recorder is configured. Device action proof remains missing. | AMB-1668 and AMB-1732. |
| Deep links and URL routing | `Native/Ambitions/App/AmbitionsRootScene.swift`, `Native/Ambitions/App/AppBootstrapper.swift`, `Native/Ambitions/App/AppExternalRouting.swift`, `Native/Ambitions/App/AppExternalRouteTranslator.swift`, `Native/Ambitions/App/AppExternalRouteOverlayTranslation.swift`, `Native/Ambitions/App/AppDeepLinkRegistry.swift` | projection-only read | URL handling selects tabs, routes, detail destinations, or overlays. If a route later opens Capture or Create Goal, the downstream in-app mutation remains covered by AMB-1707 and follow-up AMB-1666/AMB-1667. | AMB-1666 if future routes mutate state directly. |
| External snapshot writer and app-group projection export | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift` | projection-only read | The writer reads projection stores, evaluates external privacy gates, and writes redacted app-group snapshot records. This materializes projection data for external readers; it is not private graph authority. | AMB-1668 for external-surface privacy and staleness proof. |
| External object reopening, Spotlight/Handoff payloads, and control contracts | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads+02-ExternalObjectReopeningProjector.swift`, `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceControlContracts.swift` | projection-only read | Payload projectors expose safe titles, routes, and optional interaction contracts. Default indexing/export policy stays disabled until proof-backed eligibility exists. | AMB-1668. |
| EventKit and Reminders external writes | `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`, `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift` | adapter into command / sideEffectOutbox source-present / focused XCTest passed | EventKit and Reminders saves are guarded by local commit evidence and side-effect outbox state, then record success, failed-save, and permission-denied results through `SideEffectOutbox.recordResult`. No-localCommit Today/Goals callers remain blocked/Yellow; unused `ReminderOutbox` duplicate authority was deleted. | AMB-1668 and AMB-1732. |
| CloudKit continuity eligibility, zone setup, and merge vocabulary | `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncContinuityAuthorityGate.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CausalMergeEngine.swift`, `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/ConflictPolicyEngine.swift` | adapter into command | AMB-1709 found no remote private-graph apply writer in the inspected SyncContinuity files. Source shows continuity defaults local-only, CloudKit continuity disabled by default, local store remains authoritative, private payload classes are denied, remote/backend authority is denied, and live CloudKit code only probes status or ensures the core zone. This is not approval or proof of private graph sync. | AMB-1668, AMB-1680. |

## AMB-1709 Persistence Import Repair And Migration Mutation Inventory

Evidence baseline: `b7251077e9280d5d914f7fa2521c9c4a68863898` on `main`.

This inventory is static source evidence only. It does not prove runtime
correctness, migration safety, restore safety, direct-save rejection, receipt
durability, replay correctness, device behavior, privacy/legal approval,
build health, TestFlight readiness, App Store readiness, or total
LocalRuntimeOS completion.

AMB-1717 supersession: `docs/audits/persistence-authority-classification.md`
is the current classification overlay for `Core/Persistence` and related
storage/continuity files. It keeps the same Yellow proof ceiling while adding
per-file role, target-owner, proof-requirement, and direct-mutation status for
AMB-1667.

AMB-1719 supersession: `docs/audits/persistence-direct-save-rejection-proof.md`
is the current direct-save rejection proof overlay. It does not make unsafe
writes safe; it records that direct persistence writes either remain explicitly
unsafe linked debt, are canonical LocalRuntimeOS storage markers with scoped
proof requirements, or are non-production/projection/adapter rows with their
own follow-ups.

AMB-1720 supersession: `docs/audits/persistence-existing-data-migration-proof-plan.md`
is the current existing-data migration proof plan. It defines fixture coverage,
replay expectations, failure modes, proof gates, and residual Yellow gaps for
portable snapshot import/restore, legacy import, demo seed, MigrationRepair,
BackupStore, and MigrationStore surfaces. It is not executable migration safety
proof.

| Candidate | Evidence paths | Classification | Static finding | Follow-up |
| --- | --- | --- | --- | --- |
| Direct SwiftData model authority | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStore*.swift` | canonical command | AMB-1731 moved SwiftData model declarations under LocalRuntimeOS storage. They remain storage substrate and do not by themselves prove every app mutation uses a command receipt. | AMB-1667, AMB-1717, AMB-1718 |
| Direct SwiftData repository writes | `Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftData*.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreLifeContextPersistence.swift` | canonical command | AMB-1731 moved repository write implementations under LocalRuntimeOS storage. The direct-write audit now fails if these implementations return to `Core/Persistence` or any unknown production owner. | AMB-1667, AMB-1717 |
| Portable snapshot import/restore apply | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PortableSnapshotService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PortableSnapshotServiceOperations.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PortableSnapshotServiceReferenceWarnings.swift` | canonical command | AMB-1731 moved portable snapshot import/export apply source under MigrationRepair. Dry-run, import, restore, rollback, and idempotency remain bounded to focused fixture proof unless broader validation is run. | AMB-1667, AMB-1717, AMB-1720 |
| Legacy import and demo seed apply | `Native/Ambitions/Core/Persistence/LegacyImportService.swift`, `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`, `Native/Ambitions/App/AppContainerFactory.swift` | unsafe write | Legacy import transforms prototype snapshots into domain objects, and demo seed wiring applies seed data through repository services. This is useful migration scaffolding but not canonical Command -> Event -> Projection -> Receipt -> Replay authority proof. | AMB-1667, AMB-1717, AMB-1720 |
| Store health and diagnostics | `Native/Ambitions/Core/Persistence/StoreHealthCheck.swift`, `Native/Ambitions/Core/Persistence/SupportDiagnosticsBundle.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/StoreInvariantChecker.swift` | adapter into command | Health and diagnostics inspect stores and invariants. `StoreInvariantChecker` is under LocalRuntimeOS and reads SwiftData through `ModelContext`; it does not itself authorize durable repair. | AMB-1667, AMB-1718, AMB-1720 |
| Local schedule block file storage | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockFileStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LocalScheduleBlockRepository.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+CalendarWriteIntent.swift`, `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | canonical command | AMB-1731 moved durable local schedule block file IO out of `Core/Domain` and into TimeEngine. | AMB-1667, AMB-1717, AMB-1718 |
| Event journal writes | `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift` | canonical command | Event stores append RuntimeEvent envelopes under LocalRuntimeOS, with checksum and append-order validation in source. AMB-1709 does not prove every mutation enters this event path. | AMB-1666, AMB-1667 |
| Projection store writes | `Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionMaterializer.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift` | canonical command | Projection materialization and SQLite/FTS stores live under LocalRuntimeOS and write derived projection/search records. This is storage authority evidence, not proof that all UI surfaces consume only safe projections. | AMB-1668, AMB-1718 |
| LocalRuntimeOS object, backup, blob, and migration stores | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift` | canonical command | Canonical storage owners exist under LocalRuntimeOS. `ObjectStoreSwiftData` owns local SwiftData transaction/reset scaffolding and backup/migration/blob stores write runtime-owned records; this does not migrate legacy repository authority or prove data-loss safety. | AMB-1667, AMB-1718, AMB-1720 |
| Migration dry-run, backup, doctor, and repair planning | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PreMigrationBackup.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/DryRunMigration.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctorRepairOperator.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/SchemaLedger.swift` | canonical command | MigrationRepair code produces backup, dry-run, doctor, schema, readiness, and repair-plan reports while keeping mutation execution blocked by source guardrails. It is not executable migration proof. | AMB-1667, AMB-1718, AMB-1720 |
| Restore rollback wrapper | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RestoreRollback.swift`, `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PortableSnapshotService*.swift` | canonical command | Restore rollback and its portable snapshot delegate now live under LocalRuntimeOS MigrationRepair. Rollback proof remains fixture-scoped unless broader migration validation is run. | AMB-1667, AMB-1717, AMB-1720 |
| CloudKit continuity apply path | `Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/*.swift` | adapter into command | AMB-1709 found no remote private-graph apply writer. Sync envelopes default local-store authoritative, private payload classes are ineligible, backend authority attempts are denied, and live CloudKit code only checks account status or ensures a zone. This does not approve or prove private graph sync. | AMB-1668, AMB-1680 |

## AMB-1710 Preview Debug And Fixture Mutation Inventory

Evidence baseline: `e6139849cdb956782dae4f0f4974705f463759c9` on `main`.

This inventory is static source evidence only. It does not prove runtime
correctness, preview rendering behavior, simulator behavior, release-build
exclusion, receipt durability, replay correctness, device behavior,
privacy/legal approval, build health, TestFlight readiness, App Store
readiness, or total LocalRuntimeOS completion.

| Candidate | Evidence paths | Classification | Static finding | Follow-up |
| --- | --- | --- | --- | --- |
| Preview app container bootstrap | `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`, `project.yml` | unknown | Source is fenced with `#if DEBUG`, uses `PreviewClock`, stubs, and `AmbitionsPersistenceStore(inMemory: true)`, but also creates a preview `SharedExternalCreationStore` with `FileManager.default.temporaryDirectory`. The direct-write audit keeps this row `unknown` as a quarantine sentinel until release-build and adapter behavior proof exists. | AMB-1668 |
| Preview external-creation import handoff | `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`, `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift` | adapter into command | Preview wiring hands pending external creations to `DefaultExternalCreationImportService` and `AmbitionsCommandExecutor`; tests exercise temp-store import through in-memory command journals and preview capture repositories. This is support evidence only, not production proof. | AMB-1668 |
| Preview fixture catalogs and preview-only views | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`, `Native/Ambitions/PreviewSupport/PreviewTimeRitualScenarios.swift`, `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift`, `Native/Ambitions/PreviewSupport/*Previews.swift` | projection-only read | Preview fixtures and preview views provide static presentation data and call the preview container. They do not authorize canonical private graph mutation in the inspected source. | None for AMB-1710; keep proof Yellow. |
| Preview stub services with mutating-looking methods | `Native/Ambitions/PreviewSupport/StubGoalsService.swift`, `Native/Ambitions/PreviewSupport/StubTodayService.swift`, `Native/Ambitions/Core/LocalRuntimeOS/Boundary/AppServices.swift` | projection-only read | `createGoal`, `performAction`, `recordActionClosure`, `saveYouPreferences`, and Capture methods return fixture or synthesized objects without durable persistence in the inspected stubs. They are not live mutation proof. | None for AMB-1710; keep proof Yellow. |
| Debug/demo repository seeding | `Native/Ambitions/App/AppContainerFactory.swift`, `Native/Ambitions/Core/Persistence/DemoSeedPipeline.swift`, `Native/AmbitionsTests/App/AppContainerFactoryTests.swift` | unsafe write | Live bootstrap uses persistent mode and `.never` seed policy; tests assert live fresh repositories are not seeded. Debug/demo paths can still write goals, drafts, evidence, feedback, captures, app state, and optional Time seed data through repositories outside LocalRuntimeOS. | AMB-1667, AMB-1717, AMB-1720 |
| Preview and test clocks | `Native/Ambitions/Core/Time/AmbitionsClock.swift`, `Native/Ambitions/Core/Time/PreviewClock.swift`, `Native/AmbitionsTests/Time/TimeClockTests.swift` | projection-only read | `PreviewClock` and `TestClock` are `#if DEBUG`; clock factory returns `SystemClock` for live when no debug override is supplied, and tests statically check preview-clock leakage in release-scoped Time/Today sources. This is not release-build proof. | None for AMB-1710; keep proof Yellow. |
| In-memory test repositories and fixture generators | `Native/Ambitions/Core/Persistence/PreviewCaptureRepository.swift`, `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`, `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift`, selected `Native/AmbitionsTests` files | projection-only read | Fixture generators produce deterministic local-only values; `PreviewCaptureRepository` stores data in actor memory for tests and support paths. These helpers can support tests but cannot satisfy production mutation proof. AMB-1716 quarantined `LargeStoreFixtureGenerator.swift` out of the production runtime owner. | AMB-1667 if any helper becomes production importable authority. |
| Source Atlas runtime coverage fixtures | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasCoverageRuntimeFixtureModels.swift`, `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`, `source-atlas/fixtures` | projection-only read | Fixture models explicitly carry `cannotSatisfyProofAlone`, `canDriveRuntimeProofAlone == false`, privacy boundary, local-only requirement, and unsafe-boundary validation. They are coverage inputs, not runtime proof. | None for AMB-1710; keep proof Yellow. |
| Test-only temporary file writers | `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`, `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`, other test-only temp-directory fixtures | projection-only read | Test targets use temporary directories and fixture files to exercise stores, import paths, and validators. They are outside production Swift roots for the direct-write audit and cannot be cited as Green release proof. | None for AMB-1710; keep proof Yellow. |

## Direct-Write Marker Summary

`python3 scripts/ambitions-runtime-direct-write-audit.py --json` currently
classifies 50 production/support direct-write marker files:

| Classification | Count | Meaning |
| --- | ---: | --- |
| canonical command | 45 | Direct-write markers are inside `Core/LocalRuntimeOS`. |
| adapter into command | 2 | System/external paths hand off to command/outbox authority. |
| projection-only read | 2 | External snapshot paths materialize projection data for external readers. |
| test-only support | 1 | DEBUG preview support uses temporary storage but is not production runtime authority. |

Marker counts: FileManager 24, SwiftData 22, write_call 14, context_insert 8,
try_save 3, context_delete 3, ModelContext 3, context_save 1.

Current direct-write guard result: `status=green`,
`proofStatus=Implemented Green`, `findingCount=0`, and
`unsafeOrUnknownProductionRowCount=0`. This Green is limited to the static
direct-write audit scope. It does not prove total runtime correctness, visual
behavior, release readiness, privacy/legal approval, or total LocalRuntimeOS
completion.

## Forbidden-Root Direct-Write Classifications

The direct-write audit treats any unsafe or unknown production/support
direct-write marker outside `Native/Ambitions/Core/LocalRuntimeOS/` as a
finding unless it is explicitly classified here as adapter, projection, or
test-only support.

AMB-1731 removed the AMB-1709/AMB-1719 unsafe direct-write rows from the guard
by moving the effective source into `Core/LocalRuntimeOS/Storage`,
`Core/LocalRuntimeOS/MigrationRepair`, and `Core/LocalRuntimeOS/TimeEngine`.
Those old paths are now guarded by ownership tests and the direct-write audit.

AMB-1710 statically classifies the preview/debug/test helper families above,
and AMB-1731 now classifies `PreviewAppContainer.swift` as `test-only support`.
The temporary preview external-creation store must not be treated as production
authority proof or Green adapter proof.

| Path | Markers | Classification | Follow-up | Evidence note |
| --- | --- | --- | --- | --- |
| `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` | FileManager | adapter into command | AMB-1708 | Notification scheduling reads safe external snapshots and records side effects; action payloads route back through app command handling. |
| `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` | FileManager | test-only support |  | DEBUG-only preview fixture composition uses temporary FileManager storage and is not production runtime authority. |
| `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift` | FileManager, write_call | adapter into command | AMB-1708 | External creation handoff queue is imported by DefaultExternalCreationImportService into AmbitionsCommand. |
| `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift` | write_call | projection-only read | AMB-1708 | External snapshot export writes app-group projection data after privacy validation; it is not canonical private graph state. |
| `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | FileManager | projection-only read | AMB-1708 | Shared snapshot URL helper supports projection export and external-surface reads. |

## Command Event Projection Receipt Replay Matrix

| Runtime law step | Current evidence | Coverage status | Residual gap |
| --- | --- | --- | --- |
| Command | `AmbitionsCommandExecutor`, `RuntimeCommandMutationCommitter`, `DefaultExternalCreationImportService`, `AppIntentBridge`, `ExternalActionCommandService`, `TodayReceiptCommandService`, `YouPreferencesCommandService` | Implemented Yellow | AMB-1707 statically inventories App UI/Capture handlers, AMB-1708 statically inventories system-surface handlers, AMB-1709 statically inventories persistence/import/repair apply paths, and AMB-1710 statically separates preview/debug/test helpers. Unsafe UI/Capture paths, debug/demo seed writers, and external-surface device/lifecycle/replay proof still need command-path conversion or behavior proof in AMB-1666/AMB-1667/AMB-1668. |
| Event | `RuntimeTransactionCommitPolicy`, `RuntimeTransactionCoordinator`, `RuntimeEventStore`, `EventStoreSQLite` | Implemented Yellow | AMB-1709 confirms LocalRuntimeOS event stores exist, but legacy Core/Persistence and Core/Domain writes can still bypass the canonical event path until AMB-1667 and children AMB-1717 through AMB-1720. |
| Projection | `ProjectionStoreSQLite`, `ExternalSurfaceSnapshotWriter`, `ExternalWidgetProjection`, `Projection/SurfaceLenses` | Implemented Yellow | AMB-1708 statically inventories projection-only external surfaces, and AMB-1709 classifies LocalRuntimeOS projection stores. Adapter-level privacy, staleness, widget, Live Activity, notification, and projection-consumption proof remain AMB-1668/AMB-1718. |
| Receipt | `CommandReceiptFactory`, `CommandJournalAppendReceipt`, `TrustSystem`, `TodayReceiptCommandService`, side-effect outbox records | Implemented Yellow | Not every UI/system/debug mutation candidate has current receipt proof. Unsafe writes and demo seed writes remain unproven. AMB-1732 adds focused receipt proof for widget/notification rejection receipts and EventKit/Reminders result receipts, but device/lifecycle/replay proof remains missing. |
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

## AMB-1721 External Command Adapter Contract

AMB-1721 installs the system-surface adapter contract in
`docs/audits/external-command-adapter-contract.md`.

The contract defines required evidence fields and classifications for external
readers, external mutators, OS side effects, rejection receipts, unknown paths,
and unsafe debt. It covers command routing, rejection receipts, privacy
redaction, extension-safe inputs, and no direct canonical writes. It does not
add a Swift `ExternalCommandAdapter` protocol, change runtime behavior, migrate
authority, or make adapter paths Green.

Later AMB-1668 leaves must validate each system surface against that contract:
AMB-1722 for App Intent, widget payload, share extension, notification, and app
external-route mutation paths; AMB-1723 for EventKit and Reminders writes; and
AMB-1724 for projection-only snapshots and external readers.

## AMB-1722 App Intent Widget Share Notification Route Audit

AMB-1722 installs the route audit in
`docs/audits/external-adapter-app-intent-widget-share-notification-routing.md`.

The audit keeps the proof ceiling at Implemented Yellow. It classifies App
Intent creation and Share Extension intake as `commandHandoff`, deep links and
current widget/Live Activity UI as non-mutating route/projection paths,
notification scheduling as `sideEffectOutbox`, notification action payloads as
safe app-open handoff with AMB-1732 source-present `rejectionReceipt` handling,
and the widget payload mutation bridge as AMB-1732 source-present
`rejectionReceipt` handling. Focused simulator XCTest passed on 2026-07-03.
Both remain Yellow until device/lifecycle and replay proof complete.

The AMB-1722 audit does not run or prove device widget rendering, device
notification delivery/actions, Live Activity behavior, Shortcuts/Siri
invocation, Share Extension lifecycle, terminated-app import, app-group
read/write behavior on device, EventKit/Reminders writes, external projection
snapshot proof, or release readiness. AMB-1732 still needs device/lifecycle and
replay proof before any parent Green claim.

## AMB-1723 EventKit And Reminders Outbox Audit

AMB-1723 installs the route audit in
`docs/audits/external-adapter-eventkit-reminders-outbox-routing.md`.

The audit keeps the proof ceiling at Implemented Yellow. It classifies EventKit
calendar-event writes, confirmed Time calendar block writes, and Reminders
writes as `sideEffectOutbox` only for local-commit overloads. Current Today and
Goals callers use no-localCommit protocol methods and are treated as
blocked/Yellow, not working external-write proof. AMB-1732 now records
permission-denied, success, and failed-save result receipts through
`SideEffectOutbox.recordResult` for reminders, calendar events, and confirmed
Time calendar blocks. AMB-1732 deletes unused `ReminderOutbox` duplicate
authority, and `SwiftDataReminderRepository` is now canonical LocalRuntimeOS
storage when reminder objects are persisted after external save.

AMB-1723/AMB-1732 do not prove device EventKit/Reminders behavior, permission
prompt behavior, replay/lifecycle behavior beyond focused unit tests, release
readiness, or parent Green.

## AMB-1724 Projection Snapshot And Redaction Audit

AMB-1724 installs the route audit in
`docs/audits/external-adapter-projection-snapshot-redaction.md` and adds focused
XCTest source in
`Native/AmbitionsTests/App/ExternalSurfaceSnapshotBoundaryTests.swift`.

The audit keeps the proof ceiling at Implemented Yellow. It classifies the
external snapshot writer, app-group snapshot store, widget/Live Activity
snapshot readers, privacy external boundary gate, and Spotlight/Handoff
payloads as `projectionOnlyReader` source/test paths. The new test source locks
external snapshot JSON to approved field names and rejects private-class or
checksum-corrupt shared snapshot records before payload decode.

AMB-1724 does not prove device widget rendering, device Live Activity behavior,
Lock Screen privacy, physical app-group read/write behavior, extension
lifecycle, terminated-app behavior, privacy/legal approval, release readiness,
or parent Green. AMB-1732 has source-present widget payload rejection receipt
handling with focused simulator XCTest proof, but device proof, lifecycle proof,
and replay proof remain missing.

## AMB-1732 Validation Evidence

Commands run on 2026-07-03:

- `xcrun simctl boot 0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E`: exit 0.
- `xcrun simctl bootstatus 0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E -b`:
  exit 0.
- `xcodegen generate`: exit 0 after deleting the unused `ReminderOutbox`
  source owner.
- `/usr/local/bin/gtimeout 900 xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E" -derivedDataPath output/DerivedData-XcodeBuildMCP -skipMacroValidation -skipPackagePluginValidation -collect-test-diagnostics never -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -resultBundlePath output/amb1732-external-action-command-service-current.xcresult COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  exit 0, 11 tests passed.
- `/usr/local/bin/gtimeout 1200 xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E" -derivedDataPath output/DerivedData-XcodeBuildMCP -skipMacroValidation -skipPackagePluginValidation -collect-test-diagnostics never -only-testing:AmbitionsTests/EventKitIntegrationServiceTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/SideEffectSystemTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -resultBundlePath output/amb1732-eventkit-reminders-result-receipts-after-prune.xcresult COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES`:
  exit 0, 40 tests passed.
- `git diff --check`: exit 0.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`:
  exit 0, `currentLegacyRuntimeFiles=0`, `legacyRuntimeFileCeiling=0`,
  `findingCount=0`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json`: exit 0,
  `findingCount=0`.
- `python3 scripts/ambitions-remediation-governance-check.py --json`: exit 0,
  `findingCount=0`.
- `python3 scripts/ambitions-quality-gate.py --self-test`: exit 0.
- `python3 scripts/ambitions-runtime-direct-write-audit.py --json`: exit 0,
  `findingCount=0`, `unsafeOrUnknownProductionRowCount=0`.
- `python3 scripts/ambitions-unsupported-claim-scan.py AGENTS.md docs/truth/CODEX_START_HERE.md docs/truth/CODEX_PROCESS_TRUTH.md docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md docs/audits/architecture-remediation-accepted-yellow-misuse-audit.md docs/audits/runtime-authority-map.md docs/audits/external-command-adapter-contract.md docs/audits/external-adapter-app-intent-widget-share-notification-routing.md docs/audits/external-adapter-eventkit-reminders-outbox-routing.md`:
  exit 0.
- `bash scripts/release-claim-safety-scan.sh`: exit 0.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py`: exit 0.
- `python3 scripts/ambitions-skill-registry-check.py`: exit 0.

## Residual Gaps

| Gap | Status | Follow-up |
| --- | --- | --- |
| App UI and Capture action handlers are statically inventoried, but several paths still write through legacy repository/projection services outside LocalRuntimeOS. | unsafe write / Implemented Yellow by path | AMB-1666, AMB-1667 |
| System-surface entry points are statically inventoried by AMB-1708, AMB-1721 defines the adapter contract, AMB-1722 classifies App Intent/widget/share/notification/app routes, AMB-1723 classifies EventKit/Reminders writes, AMB-1724 adds external projection snapshot/redaction source-test boundaries, and AMB-1732 adds source-present notification/widget payload rejection receipts plus EventKit/Reminders result receipts. Terminated-app, extension lifecycle, notification device action, widget payload replay/device proof, Live Activity device behavior, EventKit/Reminders device behavior, CloudKit, and physical app-group proof are still missing. | Implemented Yellow / focused simulator XCTest passed / EventKit-Reminders result receipt source-present / projection snapshot Yellow | AMB-1668, AMB-1680, AMB-1732 |
| Legacy SwiftData/Core/Persistence, portable snapshot import/restore, restore rollback delegation, and Core/Domain local schedule writes remain outside canonical runtime authority; AMB-1720 defines the migration proof plan but does not make these paths Green. | unsafe write / Implemented Yellow plan | AMB-1667, AMB-1717, AMB-1718, AMB-1719, AMB-1720 |
| Preview/debug/test helpers are statically separated by AMB-1710, but the preview temporary external-creation store remains an `unknown` direct-write audit sentinel and debug/demo seed writers remain legacy repository writes; AMB-1720 treats demo seed as fixture input only, not production mutation proof. | Implemented Yellow / unknown sentinel / unsafe write | AMB-1667, AMB-1668, AMB-1717, AMB-1720 |
| Runtime authority map and proof matrix are static-source only. | Implemented Yellow | AMB-1711 |
| Direct-write audit is local/static and not yet independently proven in hosted CI. | Implemented Yellow | AMB-1712 |

## Closeout Boundary

- Final Architecture Tree inspected: yes, through `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched by this map/addenda:
  `docs/audits`, `Core/LocalRuntimeOS/Commands`,
  `Core/LocalRuntimeOS/SideEffectSystem`,
  `Core/Permissions/CalendarReminders`, and `Native/AmbitionsTests`. Earlier
  AMB-1665 slices also touched scripts.
- Swift owners touched by AMB-1732:
  `Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift`,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift`
  deleted as unused duplicate authority,
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectPolicyEngine.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+02-EventKitIntegrationService.swift`,
  `Native/Ambitions/Core/Permissions/CalendarReminders/EventKitIntegrationService+03-EventKitIntegrationService.swift`,
  `Native/AmbitionsTests/LocalRuntimeOS/Commands/ExternalActionCommandServiceTests.swift`,
  `Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem/SideEffectSystemTests.swift`,
  `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`, and
  `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`.
- Files moved or created in Swift source:
  `Native/AmbitionsTests/App/EventKitIntegrationTestDoubles.swift` was created
  as test-only support.
- Old/noncanonical source paths removed:
  `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift`
  was removed after source search found no production callers.
- Compatibility shims left behind: none added by this slice.
- Architecture debt remains: yes, in system adapter device/lifecycle proof, App UI/Capture command-path conversion, widget payload replay/device proof, EventKit/Reminders device permission/write proof, external surface device/lifecycle proof, CloudKit continuity proof limits, the preview temporary external-creation audit sentinel, and debug/demo seed writers.
- Next repair train after AMB-1668 parent Yellow closeout: AMB-1680 Source Atlas Scope Freeze before M10 proof-system work.
- No equivalent folder/path interpretation was used.
- No Green runtime authority claim is made.
