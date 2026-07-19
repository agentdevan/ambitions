# AMB-1818 File Size Cleanup Queue

Status: Implemented Yellow / Ready For Review for this file-size leaf
Date: 2026-07-05T17:02:38Z
Branch: `main`
Baseline main SHA: `7646062f02bd06ff6b9247935b4a94ea63102790`
Commit SHA: artifact commit SHA is recorded in Linear after commit/push
Parent: `AMB-1697` Parent Feature - File-Size Gate and Cleanup Queue
Issue: `AMB-1818` File Size Leaf - Current top cleanup queue

## Scope

This leaf produced a live file-size cleanup queue and split the low-risk
oversized support fixture `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`.

No production runtime authority, mutation path, storage authority, Source Atlas
scope, package boundary, tab/root IA, or release claim changed.

## Split Result

Before this leaf, the largest low-risk support candidate was:

| File | Lines | Guard treatment |
| --- | ---: | --- |
| `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` | 1258 | Preview support; excluded from the production hard-cap guard, but oversized for maintenance. |

After the split:

| File | Lines | Responsibility |
| --- | ---: | --- |
| `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` | 451 | Registry plus compact default fixture seed and existing Source Atlas preview helpers. |
| `Native/Ambitions/PreviewSupport/PreviewYouDashboardFixtures.swift` | 589 | You dashboard preview literal. |
| `Native/Ambitions/PreviewSupport/PreviewInsightsFixtures.swift` | 151 | Insights dashboard preview literal. |
| `Native/Ambitions/PreviewSupport/PreviewExternalBrainScenarios.swift` | 85 | External brain scenario preview literals. |

The Source Atlas preview helpers stayed in the existing `PreviewFixtures.swift`
file to avoid creating new Source Atlas scope without an ADR allowlist.

## Live Top-50 Cleanup Queue

Generated after the split from live Swift files under `Native`, `Sources`,
`AppUI`, and `Packages`.

| Rank | Lines | File |
| ---: | ---: | --- |
| 1 | 3224 | `Native/AmbitionsUITests/AmbitionsUITests.swift` |
| 2 | 2485 | `Native/AmbitionsTests/You/YouFeatureServiceTests.swift` |
| 3 | 2048 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift` |
| 4 | 1753 | `Native/AmbitionsTests/Runtime/StepCandidateFieldGeneratorTests.swift` |
| 5 | 1644 | `Native/AmbitionsTests/Time/TimeProjectionServiceTests.swift` |
| 6 | 1628 | `Native/AmbitionsTests/Today/TodayViewModelTests.swift` |
| 7 | 1606 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasRuntimeBridgeCoverageGauntletTests.swift` |
| 8 | 1399 | `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift` |
| 9 | 1373 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackModelsTests.swift` |
| 10 | 1350 | `Native/AmbitionsTests/Domain/AmbitionsMoatScenarioProof98Tests.swift` |
| 11 | 1348 | `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift` |
| 12 | 1223 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransportTests.swift` |
| 13 | 1218 | `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift` |
| 14 | 1216 | `Native/AmbitionsTests/LocalRuntimeOS/Inspection/ActionClosureReceiptModelsTests.swift` |
| 15 | 1173 | `Native/AmbitionsTests/Domain/LifeKnowledgeOperationModelsTests.swift` |
| 16 | 1158 | `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift` |
| 17 | 1035 | `Native/AmbitionsTests/Domain/IOS26NotionP0ContractHarnessTests.swift` |
| 18 | 971 | `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift` |
| 19 | 891 | `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift` |
| 20 | 868 | `Native/AmbitionsTests/Runtime/CaptureRuntimeGauntletTests.swift` |
| 21 | 868 | `Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift` |
| 22 | 849 | `Native/AmbitionsTests/Runtime/GoldenVerticalSliceRuntimeTests.swift` |
| 23 | 846 | `Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift` |
| 24 | 841 | `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift` |
| 25 | 837 | `Native/AmbitionsTests/LocalRuntimeOS/Commands/AmbitionsCommandExecutorTests.swift` |
| 26 | 823 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasCapabilityPathCompositionModelsTests.swift` |
| 27 | 817 | `Native/AmbitionsTests/App/ExternalRoutingTests.swift` |
| 28 | 763 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPackFactoryModelsTests.swift` |
| 29 | 709 | `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift` |
| 30 | 708 | `Native/AmbitionsTests/Services/GoalContradictionServiceTests.swift` |
| 31 | 706 | `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/PersonalizationFactorLedgerTests.swift` |
| 32 | 678 | `Native/AmbitionsTests/App/AppShellNavigationTests.swift` |
| 33 | 672 | `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift` |
| 34 | 665 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepositoryTests.swift` |
| 35 | 661 | `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift` |
| 36 | 635 | `Native/AmbitionsTests/Services/CanonicalNowStateProjectorTests.swift` |
| 37 | 630 | `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/ReplayableDecisionTraceTests.swift` |
| 38 | 620 | `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift` |
| 39 | 618 | `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift` |
| 40 | 602 | `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackFetchPipelineTests.swift` |
| 41 | 601 | `Native/AmbitionsTests/Domain/RecommendationMutationLabModelsTests.swift` |
| 42 | 599 | `Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` |
| 43 | 595 | `Native/Ambitions/Core/Domain/CommitmentWaitingModels.swift` |
| 44 | 593 | `Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift` |
| 45 | 589 | `Native/AmbitionsTests/Today/TodayCommandHandlerTests.swift` |
| 46 | 589 | `Native/Ambitions/PreviewSupport/PreviewYouDashboardFixtures.swift` |
| 47 | 583 | `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackRemoteTransport.swift` |
| 48 | 577 | `Native/AmbitionsTests/LocalRuntimeOS/Commands/ExternalActionCommandServiceTests.swift` |
| 49 | 572 | `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift` |
| 50 | 571 | `Native/Ambitions/Core/LocalRuntimeOS/Repair/DryRunMigration.swift` |

## Production Guard Snapshot

`scripts/ambitions-remediation-governance-check.py --json` reported:

- `productionSwiftFileCount=1421`
- `swiftHardLineCap=600`
- `overHardLineCapFiles=0`
- top production files: 599, 595, 593, 583, 572, 571, 570, 561, 552, and 547 lines

The top production file is currently under the hard cap by one line:
`Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` at 599 lines.

## Validation Run

| Command | Exit code | Result |
| --- | ---: | --- |
| `xcodegen generate` | 0 | Regenerated the ignored local Xcode project so the split files are visible to local build tooling. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed; `production_swift_files=1421`, `changed_paths=6`. |
| `python3 scripts/ambitions-remediation-governance-check.py` | 0 | Passed; `changed_paths=6`, `production_swift_files=1421`, `overHardLineCapFiles=0`. |
| `python3 scripts/ambitions-remediation-governance-check.py --json` | 0 | Passed; machine-readable snapshot captured in the paired JSON packet. |
| `git diff --check` | 0 | Passed before audit packet creation. |
| `mcp__xcodebuildmcp.session_show_defaults` | 0 | Confirmed `Ambitions`, `Debug`, `iPhone 17 Pro Max`, repo-local DerivedData. |
| `mcp__xcodebuildmcp.build_sim` | timed out | MCP call timed out after 300s; underlying `xcodebuild` remained CPU-active and was stopped after a prolonged compile window. No build success claim is made. |

## Validation Not Run

- XCTest, UI tests, focused test lanes, screenshot capture, app launch proof,
  accessibility walkthrough, physical-device proof, archive, App Store
  validation, TestFlight upload, and release approval were not run.
- The compile-only simulator build did not produce a completed success/failure
  result in the available validation window.

## Non-Claims

- No repo-wide file-size cleanup Green.
- No broad refactor proof.
- No build success, test success, app launch proof, screenshot proof, release
  readiness, or product completion.
- This leaf proves one low-risk support split plus the current cleanup queue;
  `AMB-1697` remains In Progress for CI thresholds, test monolith splits,
  production-file reductions, monthly reporting, and trend tracking.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Native/Ambitions/PreviewSupport` only.
- Files moved or created: three preview-support fixture extension files.
- Old/non-canonical paths removed: none; `PreviewFixtures.swift` remains the
  fixture registry and retains existing Source Atlas helper content.
- Compatibility shims left behind: none.
- Yellow architecture/proof debt remains: yes. The queue identifies large test
  and near-cap production files, but does not close repo-wide file-size debt.
- Next repair train if debt remains: continue `AMB-1697` leaves for CI warning
  thresholds, CI fail thresholds for newly oversized files, focused test
  monolith decomposition, worst production-file reductions, and monthly
  architecture hygiene reporting.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Revert this audit packet and the three new PreviewSupport split files, then
restore the extracted literals into `PreviewFixtures.swift`.
