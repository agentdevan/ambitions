# Architecture Remediation Baseline

Status: AMB-1657 evidence baseline

Snapshot date: 2026-07-02

Repo state: `0055a18a1fab4d2c62d6dc73bf7597e630d07b8e` on `main`

Scope: M00 canon/governance/baseline sequence only

This document is an architecture remediation baseline, not remediation proof.
It does not prove source migration, runtime authority migration, runtime
correctness, build health, device behavior, accessibility behavior, privacy or
legal review, TestFlight behavior, App Store behavior, or product completion.

Evidence class: Implemented Yellow. The tables below are static source and
configuration evidence captured from tracked repository files. They are useful
for prioritizing remediation, but they are not Green without linked build,
test, runtime, device, and review artifacts for the exact claim.

## Command Evidence

- `git status --short --branch`
- `git rev-parse HEAD`
- `git ls-remote origin refs/heads/main`
- `git ls-files`
- `python3 scripts/ambitions-architecture-inventory.py --json`
- Static Swift/source scans using Python standard library only
- `project.yml`
- `Package.swift`
- `Packages/AmbitionsExperienceKernel/Package.swift`

The existing architecture inventory reported 207 required final-tree entries,
207 source-present entries, and 0 blocking entries. That is source-present
evidence only. It must not be converted into a broader Green claim.

## File Count By Root

| Root | Tracked files |
| --- | ---: |
| `.agents` | 6 |
| `.github` | 7 |
| `.gitignore` | 1 |
| `.gitleaks.toml` | 1 |
| `.markdownlint-cli2.yaml` | 1 |
| `.semgrep` | 1 |
| `.swiftlint.yml` | 1 |
| `.xcode-version` | 1 |
| `.xcodebuildmcp` | 2 |
| `.yamllint.yml` | 1 |
| `AGENTS.md` | 1 |
| `AppUI/Sources` | 7 |
| `Brewfile` | 1 |
| `DesignTokens` | 17 |
| `Makefile` | 1 |
| `Native/Ambitions/App` | 40 |
| `Native/Ambitions/Composer` | 16 |
| `Native/Ambitions/Core` | 724 |
| `Native/Ambitions/DesignSystem` | 98 |
| `Native/Ambitions/Diagnostics` | 6 |
| `Native/Ambitions/Interaction` | 8 |
| `Native/Ambitions/Language` | 10 |
| `Native/Ambitions/PreviewSupport` | 9 |
| `Native/Ambitions/Projection` | 174 |
| `Native/Ambitions/Quality` | 42 |
| `Native/Ambitions/Rendering` | 10 |
| `Native/Ambitions/Resources` | 23 |
| `Native/Ambitions/Scenarios` | 38 |
| `Native/Ambitions/Stage` | 57 |
| `Native/Ambitions/Support` | 10 |
| `Native/Ambitions/Surfaces` | 72 |
| `Native/Ambitions/Trust` | 15 |
| `Native/AmbitionsShareExtension` | 4 |
| `Native/AmbitionsTests` | 414 |
| `Native/AmbitionsUITests` | 5 |
| `Native/AmbitionsWidgetExtension` | 5 |
| `Package.swift` | 1 |
| `Packages/AmbitionsExperienceKernel/.gitignore` | 1 |
| `Packages/AmbitionsExperienceKernel/Codex` | 34 |
| `Packages/AmbitionsExperienceKernel/Docs` | 8 |
| `Packages/AmbitionsExperienceKernel/Makefile` | 1 |
| `Packages/AmbitionsExperienceKernel/Package.swift` | 1 |
| `Packages/AmbitionsExperienceKernel/README.md` | 1 |
| `Packages/AmbitionsExperienceKernel/Scripts` | 5 |
| `Packages/AmbitionsExperienceKernel/Sources` | 115 |
| `Packages/AmbitionsExperienceKernel/Tests` | 1 |
| `Packages/AmbitionsExperienceKernel/ambitions_experience_kernel_performance_report.json` | 1 |
| `Packages/AmbitionsExperienceKernel/release_manifest.json` | 1 |
| `Packages/AmbitionsExperienceKernel/release_readiness_report.json` | 1 |
| `Packages/AmbitionsExperienceKernel/snapshot_matrix_checklist.md` | 1 |
| `README.md` | 1 |
| `Sources` | 111 |
| `assets` | 4 |
| `docs` | 1229 |
| `fixtures` | 23 |
| `frontend` | 28 |
| `project.yml` | 1 |
| `requirements-ci.txt` | 1 |
| `scripts` | 58 |
| `source-atlas` | 25 |
| `tools` | 3270 |

Tracked repository total: 6752 files.

## Swift LOC By Root

| Root | Swift files | Swift LOC |
| --- | ---: | ---: |
| `AppUI/Sources` | 7 | 1651 |
| `Native/Ambitions/App` | 39 | 4893 |
| `Native/Ambitions/Composer` | 16 | 2669 |
| `Native/Ambitions/Core` | 722 | 151098 |
| `Native/Ambitions/DesignSystem` | 98 | 12556 |
| `Native/Ambitions/Diagnostics` | 6 | 369 |
| `Native/Ambitions/Interaction` | 8 | 729 |
| `Native/Ambitions/Language` | 10 | 589 |
| `Native/Ambitions/PreviewSupport` | 9 | 2021 |
| `Native/Ambitions/Projection` | 174 | 34094 |
| `Native/Ambitions/Quality` | 42 | 2554 |
| `Native/Ambitions/Rendering` | 10 | 697 |
| `Native/Ambitions/Scenarios` | 38 | 3407 |
| `Native/Ambitions/Stage` | 57 | 6238 |
| `Native/Ambitions/Support` | 8 | 1656 |
| `Native/Ambitions/Surfaces` | 72 | 12182 |
| `Native/Ambitions/Trust` | 15 | 1591 |
| `Native/AmbitionsShareExtension` | 2 | 277 |
| `Native/AmbitionsTests` | 414 | 117718 |
| `Native/AmbitionsUITests` | 5 | 3370 |
| `Native/AmbitionsWidgetExtension` | 3 | 503 |
| `Package.swift` | 1 | 31 |
| `Packages/AmbitionsExperienceKernel/Package.swift` | 1 | 24 |
| `Packages/AmbitionsExperienceKernel/Sources` | 15 | 1446 |
| `Packages/AmbitionsExperienceKernel/Tests` | 1 | 54 |
| `Sources` | 111 | 25091 |
| `tools` | 4 | 1939 |

Tracked Swift total: 1888 files, 389447 LOC.

## Largest 100 Swift Files

| Rank | LOC | Path |
| ---: | ---: | --- |
| 1 | 3186 | `Native/AmbitionsUITests/AmbitionsUITests.swift` |
| 2 | 2485 | `Native/AmbitionsTests/You/YouFeatureServiceTests.swift` |
| 3 | 2048 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift` |
| 4 | 1753 | `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift` |
| 5 | 1681 | `tools/mcp/ambitions_native_mcp/Sources/AmbitionsNativeMCPCore/AmbitionsNativeMCPCore.swift` |
| 6 | 1644 | `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift` |
| 7 | 1628 | `Native/AmbitionsTests/Today/TodayViewModelTests.swift` |
| 8 | 1565 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift` |
| 9 | 1399 | `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift` |
| 10 | 1373 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackModelsTests.swift` |
| 11 | 1350 | `Native/AmbitionsTests/Domain/AmbitionsMoatScenarioProof98Tests.swift` |
| 12 | 1348 | `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift` |
| 13 | 1258 | `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` |
| 14 | 1223 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransportTests.swift` |
| 15 | 1216 | `Native/AmbitionsTests/LocalRuntimeOS/TrustSystem/ActionClosureReceiptModelsTests.swift` |
| 16 | 1173 | `Native/AmbitionsTests/Domain/LifeKnowledgeOperationModelsTests.swift` |
| 17 | 1158 | `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift` |
| 18 | 1109 | `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift` |
| 19 | 1035 | `Native/AmbitionsTests/Domain/IOS26NotionP0ContractHarnessTests.swift` |
| 20 | 971 | `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift` |
| 21 | 912 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasCapabilityPathCompositionModelsTests.swift` |
| 22 | 891 | `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift` |
| 23 | 868 | `Native/AmbitionsTests/Runtime/CaptureRuntimeGauntletTests.swift` |
| 24 | 868 | `Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift` |
| 25 | 849 | `Native/AmbitionsTests/Runtime/GoldenVerticalSliceRuntimeTests.swift` |
| 26 | 846 | `Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift` |
| 27 | 841 | `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift` |
| 28 | 837 | `Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutorTests.swift` |
| 29 | 817 | `Native/AmbitionsTests/App/ExternalRoutingTests.swift` |
| 30 | 763 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackFactoryModelsTests.swift` |
| 31 | 733 | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctorRepairOperator.swift` |
| 32 | 709 | `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift` |
| 33 | 708 | `Native/AmbitionsTests/Services/GoalContradictionServiceTests.swift` |
| 34 | 706 | `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/PersonalizationFactorLedgerTests.swift` |
| 35 | 695 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasLaunchFloorShardIndexModels.swift` |
| 36 | 678 | `Native/AmbitionsTests/App/AppShellNavigationTests.swift` |
| 37 | 672 | `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift` |
| 38 | 665 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepositoryTests.swift` |
| 39 | 661 | `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift` |
| 40 | 635 | `Native/AmbitionsTests/Services/CanonicalNowStateProjectorTests.swift` |
| 41 | 630 | `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/ReplayableDecisionTraceTests.swift` |
| 42 | 620 | `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift` |
| 43 | 618 | `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift` |
| 44 | 605 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift` |
| 45 | 602 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackFetchPipelineTests.swift` |
| 46 | 601 | `Native/AmbitionsTests/Domain/RecommendationMutationLabModelsTests.swift` |
| 47 | 599 | `Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` |
| 48 | 595 | `Native/Ambitions/Core/Domain/CommitmentWaitingModels.swift` |
| 49 | 589 | `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` |
| 50 | 583 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransport.swift` |
| 51 | 572 | `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift` |
| 52 | 571 | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/DryRunMigration.swift` |
| 53 | 570 | `Native/Ambitions/Core/Domain/ReminderModels.swift` |
| 54 | 558 | `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift` |
| 55 | 554 | `Native/AmbitionsTests/Domain/AmbitionGraphProjectionStoreTests.swift` |
| 56 | 552 | `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift` |
| 57 | 548 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRepositoryBackedRemoteRefreshTests.swift` |
| 58 | 547 | `Native/Ambitions/Core/Domain/AmbitionsProductCanonV2Models.swift` |
| 59 | 543 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasVisionOCRFallbackModels.swift` |
| 60 | 542 | `Native/Ambitions/Core/Domain/AmbitionsOSExperienceModels.swift` |
| 61 | 541 | `Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift` |
| 62 | 536 | `Native/AmbitionsTests/Services/ExecutionResilienceProjectorTests.swift` |
| 63 | 534 | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` |
| 64 | 533 | `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift` |
| 65 | 524 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift` |
| 66 | 523 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackBackgroundRefreshTaskTests.swift` |
| 67 | 522 | `Native/Ambitions/Core/Runtime/FirstRunActivationRuntime.swift` |
| 68 | 519 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublishedPackSchemaDecoder.swift` |
| 69 | 516 | `Native/Ambitions/Core/Domain/GoalEngine/GoalUnderstandingModels.swift` |
| 70 | 515 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasLocalPackCacheTests.swift` |
| 71 | 515 | `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift` |
| 72 | 515 | `Native/Ambitions/DesignSystem/ProductObjects/GoalMissionControlLanePrimitives.swift` |
| 73 | 513 | `Native/AmbitionsTests/Services/GoalBelievabilityProjectorTests.swift` |
| 74 | 513 | `Native/Ambitions/Projection/SurfaceLenses/DayRailProjection.swift` |
| 75 | 512 | `Native/Ambitions/Core/Runtime/HighRiskSafetyJurisdictionGate.swift` |
| 76 | 512 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasSeedFoundry.swift` |
| 77 | 511 | `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift` |
| 78 | 510 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasOfflineNoAccountPlanningScaleTests.swift` |
| 79 | 508 | `Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/ExternalActionCommandServiceTests.swift` |
| 80 | 508 | `Native/Ambitions/Core/Runtime/GoalUnderstandingService.swift` |
| 81 | 507 | `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrator.swift` |
| 82 | 506 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackFetchPipeline.swift` |
| 83 | 505 | `Native/Ambitions/Core/Runtime/StepQualityFirewall.swift` |
| 84 | 504 | `Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift` |
| 85 | 503 | `Native/Ambitions/Core/Domain/AmbitionsOSRecommendationStartHereModels.swift` |
| 86 | 502 | `Sources/Theme/PanelDensitySize.swift` |
| 87 | 502 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasLocalPackCache.swift` |
| 88 | 497 | `Native/Ambitions/Core/Domain/AmbitionsOSSourceTruthModels.swift` |
| 89 | 491 | `Native/Ambitions/Core/Domain/NorthStarModels.swift` |
| 90 | 489 | `Native/Ambitions/Core/Runtime/GoalExplainabilityProjector.swift` |
| 91 | 489 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystem.swift` |
| 92 | 488 | `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift` |
| 93 | 487 | `Native/AmbitionsTests/Services/LifeAreaAtlasProjectorTests.swift` |
| 94 | 486 | `Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift` |
| 95 | 483 | `Sources/Theme/AmbitionTheme+02-AmbitionTheme.swift` |
| 96 | 480 | `Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/CommandSpineLeafTests.swift` |
| 97 | 480 | `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/StoragePrivacySecurityBoundary.swift` |
| 98 | 479 | `Native/AmbitionsTests/Domain/ReminderNaturalLanguageCaptureParserTests.swift` |
| 99 | 473 | `Sources/Components/ShellChromePrimitives.swift` |
| 100 | 472 | `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/ReplayableDecisionTrace.swift` |

## Architecture Naming Counts

The filename scan counts Swift file basenames containing the term. This is a
pressure signal, not symbol ownership proof.

| Term | Swift filename basename hits |
| --- | ---: |
| `Engine` | 81 |
| `Kernel` | 25 |
| `System` | 34 |
| `Runtime` | 109 |
| `Service` | 141 |
| `Ledger` | 43 |
| `Manager` | 1 |
| `Coordinator` | 10 |

## Split-File Count

Swift files whose filename contains `+02`, `+03`, or `+04`: 257.

| Root | Split files |
| --- | ---: |
| `Native/Ambitions/Core` | 172 |
| `Native/Ambitions/DesignSystem` | 16 |
| `Native/Ambitions/Projection` | 25 |
| `Native/Ambitions/Stage` | 6 |
| `Native/Ambitions/Surfaces` | 13 |
| `Sources` | 25 |

## Test Target File Count

| Test root | Swift files |
| --- | ---: |
| `Native/AmbitionsTests` | 414 |
| `Native/AmbitionsUITests` | 5 |
| Package or support test files | 2 |
| Total | 421 |

## Package And Target Dependency Graph

`project.yml` defines the XcodeGen source of truth for the app graph.

| Target | Type | Sources | Dependencies |
| --- | --- | --- | --- |
| `Ambitions` | iOS application | `Native/Ambitions`, app resources | `AmbitionsDesignSystem`, `AmbitionsWidgetUI`, `AmbitionsExperienceKernel`, embeds widget and share extensions |
| `AmbitionsWidgetExtension` | iOS app extension | `Native/AmbitionsWidgetExtension`, selected `Projection/ExternalSnapshots` files | none declared |
| `AmbitionsShareExtension` | iOS app extension | `Native/AmbitionsShareExtension`, selected `Projection/ExternalSnapshots` files | `AppIntents.framework` |
| `AmbitionsTests` | iOS unit test bundle | `Native/AmbitionsTests` | `Ambitions`, `AmbitionsDesignSystem` |
| `AmbitionsUITests` | iOS UI test bundle | `Native/AmbitionsUITests` | `Ambitions`, `AppIntents.framework` |

Root `Package.swift` defines package `AmbitionsDesignSystem` with products
`AmbitionsDesignSystem` from `Sources` and `AmbitionsWidgetUI` from
`AppUI/Sources`. `AmbitionsWidgetUI` depends on `AmbitionsDesignSystem`.

`Packages/AmbitionsExperienceKernel/Package.swift` defines package
`AmbitionsExperienceKernel` with product `AmbitionsExperienceKernel`, one
source target, and one test target. Its Swift tools declaration and platform
floor differ from the app package and should remain visible during future
package-governance work.

## Direct Persistence Write Candidates

This is a static marker scan. A row is not proof of an illegal write path. It is
a candidate for later runtime-authority review.

High-confidence production/support write-marker candidates: 43 files. Additional
SwiftData context/model candidates without direct write markers in this scan: 12
files.

| LOC | Path | Markers |
| ---: | --- | --- |
| 337 | `Native/Ambitions/Core/Domain/RealityModels.swift` | `.write(`, `FileManager` |
| 281 | `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureAttachmentVault.swift` | `.write(`, `FileManager` |
| 66 | `Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph/CaptureRouteGraphFileStore.swift` | `.write(`, `FileManager` |
| 187 | `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor+02-AmbitionsCommandExecutor+03-scheduleMutationIntent.swift` | `FileManager` |
| 533 | `Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift` | `.write(`, `FileManager` |
| 174 | `Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift` | `.write(`, `FileManager` |
| 109 | `Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift` | `.write(` |
| 92 | `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline.swift` | `try save(` |
| 49 | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox+EventKitStoreClientLive.swift` | `try save(` |
| 80 | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/FileSideEffectLedgerRepository.swift` | `.write(`, `FileManager` |
| 50 | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectLedgerSwiftDataRepository.swift` | `context.insert`, `import SwiftData` |
| 294 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository+Storage.swift` | `.write(` |
| 470 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository.swift` | `FileManager` |
| 320 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshService.swift` | `FileManager` |
| 140 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift` | `.write(`, `FileManager` |
| 164 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift` | `.write(`, `FileManager` |
| 173 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift` | `.write(`, `FileManager` |
| 286 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift` | `FileManager` |
| 318 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/LocalRuntimeStorageCore.swift` | `FileManager` |
| 264 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift` | `try save(`, `FileManager` |
| 524 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift` | `context.delete`, `context.save`, `try save(`, `FileManager`, `import SwiftData`, `ModelContext` |
| 252 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift` | `try save(`, `FileManager` |
| 257 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift` | `FileManager` |
| 133 | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/LifeCalendarStore.swift` | `.write(`, `FileManager` |
| 187 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/GoalIntentCompilerReceiptPersistenceAdapter.swift` | `try save(` |
| 223 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TodayReceiptCommandService.swift` | `try save(` |
| 489 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystem.swift` | `try save(` |
| 448 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystemSwiftDataRepositories.swift` | `context.insert`, `context.delete`, `import SwiftData` |
| 534 | `Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift` | `FileManager` |
| 98 | `Native/Ambitions/Core/Persistence/LifeContextPersistence.swift` | `context.insert`, `import SwiftData` |
| 232 | `Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift` | `try save(` |
| 317 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+03-Array.swift` | `context.delete`, `import SwiftData` |
| 335 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+04-SwiftDataGoalPersistence.swift` | `context.insert`, `context.delete`, `import SwiftData`, `ModelContext` |
| 110 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift` | `context.insert`, `import SwiftData` |
| 34 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataAppStateRepository.swift` | `context.insert`, `import SwiftData` |
| 169 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+07-SwiftDataRuntimeSnapshotLedgerRepository.swift` | `context.insert`, `import SwiftData` |
| 157 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+08-SwiftDataReminderRepository.swift` | `context.insert`, `import SwiftData` |
| 119 | `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` | `FileManager` |
| 147 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift` | `.write(`, `FileManager` |
| 133 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift` | `.write(` |
| 75 | `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | `FileManager` |
| 1681 | `tools/mcp/ambitions_native_mcp/Sources/AmbitionsNativeMCPCore/AmbitionsNativeMCPCore.swift` | `.write(`, `FileManager` |
| 157 | `tools/mcp/ambitions_native_mcp/Tests/AmbitionsNativeMCPTests/AmbitionsNativeMCPTests.swift` | `.write(`, `FileManager` |
| 372 | `Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/StoreInvariantChecker.swift` | `import SwiftData`, `ModelContext` |
| 169 | `Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ExecutionLedgerReplayInspectionSwiftDataRepository.swift` | `import SwiftData` |
| 332 | `Native/Ambitions/Core/Persistence/SwiftDataModels+02-CaptureRecord.swift` | `import SwiftData` |
| 346 | `Native/Ambitions/Core/Persistence/SwiftDataModels+03-EntityRevisionTombstoneRecord.swift` | `import SwiftData` |
| 58 | `Native/Ambitions/Core/Persistence/SwiftDataModels+04-AmbitionGraphProjectionRecordModel.swift` | `import SwiftData` |
| 358 | `Native/Ambitions/Core/Persistence/SwiftDataModels.swift` | `import SwiftData` |
| 345 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+02-persisted.swift` | `import SwiftData` |
| 335 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+03-feedbackRecord.swift` | `import SwiftData` |
| 319 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+04-apply.swift` | `import SwiftData` |
| 295 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping+05-entityRevisionTombstone.swift` | `import SwiftData` |
| 6 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories+02-RepositoryMapping.swift` | `import SwiftData` |
| 69 | `Native/Ambitions/Core/Persistence/SwiftDataRepositories.swift` | `import SwiftData` |

## Widget, App Intent, And Share Extension Mutation Candidates

This is a static target/symbol/word scan. A row is not proof of mutation outside
runtime law. It marks files to inspect before source migration.

Production candidate files excluding test files: 33.

| LOC | Path | Markers |
| ---: | --- | --- |
| 231 | `AppUI/Sources/WidgetComponents.swift` | widget UI package |
| 333 | `AppUI/Sources/WidgetFamiliesPrimary.swift` | mutation/write language, widget UI package |
| 124 | `AppUI/Sources/WidgetFamiliesRituals.swift` | widget UI package |
| 381 | `AppUI/Sources/WidgetFamiliesSecondary.swift` | mutation/write language, widget UI package |
| 92 | `AppUI/Sources/WidgetFeed.swift` | widget UI package |
| 334 | `AppUI/Sources/WidgetFoundation.swift` | mutation/write language, widget UI package |
| 156 | `AppUI/Sources/WidgetPreviews.swift` | mutation/write language, widget UI package |
| 21 | `Native/Ambitions/App/AppIntentLaunchRouter.swift` | AppIntent |
| 285 | `Native/Ambitions/App/Intents/AmbitionsAppShortcutDestination.swift` | AppIntent, mutation/write language |
| 105 | `Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift` | AppIntent, mutation/write language |
| 161 | `Native/Ambitions/App/Intents/AmbitionsDeepActionShortcut.swift` | AppIntent, mutation/write language |
| 100 | `Native/Ambitions/App/Intents/AmbitionsShortcutsProvider.swift` | AppIntent |
| 156 | `Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift` | AppIntent, mutation/write language |
| 69 | `Native/Ambitions/App/Intents/AmbitionsSystemControlIntent.swift` | AppIntent |
| 28 | `Native/Ambitions/App/Intents/OpenAmbitionsDestinationIntent.swift` | AppIntent |
| 40 | `Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/AppIntentProjection.swift` | AppIntent |
| 88 | `Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift` | AppIntent, mutation/write language |
| 147 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift` | external snapshot/shared projection, mutation/write language |
| 324 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads+02-ExternalObjectReopeningProjector.swift` | external snapshot/shared projection, mutation/write language |
| 312 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift` | external snapshot/shared projection, mutation/write language |
| 158 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceContractModels.swift` | external snapshot/shared projection, mutation/write language |
| 177 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceControlContracts.swift` | external snapshot/shared projection, mutation/write language |
| 605 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift` | external snapshot/shared projection, mutation/write language |
| 469 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift` | external snapshot/shared projection, mutation/write language |
| 133 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift` | external snapshot/shared projection, mutation/write language |
| 209 | `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift` | external snapshot/shared projection |
| 219 | `Native/Ambitions/Projection/ExternalSnapshots/NextStepActivityAttributes.swift` | external snapshot/shared projection, mutation/write language |
| 75 | `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` | external snapshot/shared projection, mutation/write language |
| 89 | `Native/AmbitionsShareExtension/ShareIntakeView.swift` | mutation/write language, share extension target |
| 188 | `Native/AmbitionsShareExtension/ShareViewController.swift` | mutation/write language, share extension target |
| 11 | `Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift` | widget extension target |
| 115 | `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift` | widget extension target |
| 377 | `Native/AmbitionsWidgetExtension/NextStepWidget.swift` | mutation/write language, widget extension target |

## AMB-1657 Baseline Result

Baseline artifacts exist for counts, owner map, and risk register. This closes
the data-gathering slice only. It does not authorize source migration. The next
M00 follow-up is AMB-1658 governance rules, then the runtime authority map work
called out by the Codex Execution Index.
