# Legacy Runtime Strangler Classification

Status: AMB-1713 source-static classification baseline

Snapshot date: 2026-07-02

Repo state inspected: `058bac863a087f435be866636f2a7e414923f093` on `main`

Scope: AMB-1666 -> AMB-1713 only. This audit classifies every Swift file
under `Native/Ambitions/Core/Runtime` at the AMB-1713 snapshot. It does not move
source, delete source, replace imports, add runtime guards, change Swift
behavior, or prove runtime correctness.

Evidence class: Implemented Yellow. The table is current source inventory and
classification evidence only. It does not prove build health, runtime behavior,
device behavior, accessibility behavior, privacy/legal approval, release
readiness, TestFlight readiness, App Store readiness, or total LocalRuntimeOS
completion.

AMB-1714 supersession: `docs/audits/legacy-runtime-strangler-import-replacement.md`
is the current overlay for the three rows moved after this baseline:
`PrivateLifeRuntime.swift`, `RuntimeProjectionPipeline.swift`, and
`RuntimeSnapshot.swift`.

AMB-1716 supersession: `docs/audits/legacy-runtime-strangler-delete-quarantine.md`
is the current overlay for `LargeStoreFixtureGenerator.swift`. That file moved
from production `Core/Runtime` into test support under
`Native/AmbitionsTests/Runtime/Support`. The other AMB-1713 `Test-only support`
rows remain Yellow until a follow-up proves their owner movement or release-inert
scope.

## Canonical Constraints

Runtime mutation law remains:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Remediation direction remains:

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

## Evidence Commands

- `git status --short --branch`
- `git rev-parse HEAD`
- Python standard-library scan of `Native/Ambitions/Core/Runtime/*.swift` for
  file count, line count, and module imports.
- Static source inspection of representative live wiring, adapter, fixture,
  Source Atlas, and runtime-proof families.
- `rg` usage checks for `AnyGoalRuntimeCoverage`, `LargeStoreFixtureGenerator`,
  `DedicatedDevicePrototypeRuntime`, `RuntimeCoreUmbrellaGate`,
  `RuntimeMemoryServicing`, `AmbitionsRuntimeFactory`, `AmbitionsRuntime`, and
  `PrivateLifeRuntime`.

## Classification Summary

| Classification | Count | Meaning for AMB-1666 |
| --- | ---: | --- |
| Delete now | 0 | No file is classified safe for immediate deletion by AMB-1713 alone. |
| Move into LocalRuntimeOS | 101 | Candidate runtime/projection/planning/time/capture/search/source authority that must move under the listed `Core/LocalRuntimeOS` owner before legacy copies are removed. |
| Adapter shim | 8 | Live or boundary wiring that may temporarily remain as a thin shim only if it contains no product policy, storage authority, or durable mutation authority. |
| Test-only support | 5 | Fixture/proof harness support that must be quarantined out of production runtime authority or proven release-inert before AMB-1716 closes. |
| Unresolved | 1 | Owner decision is required before move, delete, or quarantine. |

Proof code legend:

| Code | Proof needed |
| --- | --- |
| P-MOVE | Compile plus focused runtime/projection tests after move; preserve Command -> Event -> Projection -> Receipt -> Replay; prove no legacy production import remains. |
| P-SHIM | Compile plus wiring tests; shim contains no product policy or durable mutation authority; route into LocalRuntimeOS before final Green. |
| P-TEST | Import audit plus focused tests; quarantine out of production authority or prove release-inert support scope before AMB-1716 closes. |
| P-DECIDE | Owner decision record plus import/usage audit before move, delete, or quarantine. |

Follow-up code legend:

| Code | Follow-up |
| --- | --- |
| F-MOVE | AMB-1714 replaces imports to the target owner; AMB-1716 deletes or quarantines the legacy copy. |
| F-SHIM | AMB-1714 routes production imports through a thin boundary; AMB-1715 guards production legacy use; AMB-1716 removes policy from the shim. |
| F-TEST | AMB-1716 quarantines or deletes the production-runtime copy after AMB-1714 usage audit. |
| F-DECIDE | AMB-1714 records the owner decision before code movement; AMB-1716 quarantines if still unresolved. |

## File Classification Table

| Path | Current owner | Current imports | Classification | Target owner | Proof | Follow-up |
| --- | --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/Core/Runtime/AmbitionsRuntimeContracts.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/AmbitionsRuntimeExperienceSnapshotAdapter.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/AmbitionsRuntimeFactory.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/AmbitionsRuntimeGoalIntelligence.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/AmbitionsRuntimeServices.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/AnyGoalRuntimeCoverage+02-PrivacySafeCoverageRequestBuilder.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/AnyGoalRuntimeCoverage+03-AnyGoalRuntimeCoverageEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/AnyGoalRuntimeCoverage+04-AnyGoalCoverageInput.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/AnyGoalRuntimeCoverage.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/AppServices.swift` | `Core/Runtime` | `AmbitionsWidgetUI, Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/BufferEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CanonicalNowStateProjector+02-CanonicalNowStateProjector+03-explanation.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CanonicalNowStateProjector+02-CanonicalNowStateProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CanonicalNowStateProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CapacityEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CaptureService+02-CaptureDraftRouteService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CaptureService+03-DefaultCaptureService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/CaptureService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ClosureEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/DedicatedDevicePrototypeRuntime.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/ExecutionResilienceProjector+02-normalizedAssessments.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ExecutionResilienceProjector+03-waitingOrBlockedWork.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ExecutionResilienceProjector+04-explanationTitle.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ExecutionResilienceProjector+Projector01-nowRecoverySummary.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ExecutionResilienceProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/FirstRunActivationRuntime.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalBelievabilityProjector+02-GoalBelievabilityProjector+03-healthSignals.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalBelievabilityProjector+02-GoalBelievabilityProjector+04-rank.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalBelievabilityProjector+02-GoalBelievabilityProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalBelievabilityProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+03-ClassificationConfidence.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalClarificationService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+03-GoalResourceEntity.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalContradictionService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalDomainPackService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalDomainPacks.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalEnergyFitService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalEnergyLearningService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalExplainabilityProjector.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalFreshnessUpdateService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalPathCompilerService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalResourceGraphService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalTeachingSignalService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoalUnderstandingService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+02-GoldenVerticalSliceInput.swift` | `Core/Runtime` | `Foundation` | `Test-only support` | `Tests/Runtime or Quality quarantine` | `P-TEST` | `F-TEST` |
| `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+03-GoldenVerticalSliceRuntime.swift` | `Core/Runtime` | `Foundation` | `Test-only support` | `Tests/Runtime or Quality quarantine` | `P-TEST` | `F-TEST` |
| `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime.swift` | `Core/Runtime` | `Foundation` | `Test-only support` | `Tests/Runtime or Quality quarantine` | `P-TEST` | `F-TEST` |
| `Native/Ambitions/Core/Runtime/HighRiskSafetyJurisdictionGate.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivacySecurity` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/KnowledgeClaimBoundaryHardener.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/KnowledgeIngestionService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/KnowledgeProviderBoundary.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SourceAtlas` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift` | `Core/Runtime` | `Foundation` | `Test-only support` | `Tests/Runtime or Quality quarantine` | `P-TEST` | `F-TEST` |
| `Native/Ambitions/Core/Runtime/LearningAnticipationService+EvidenceHelpers.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LearningAnticipationService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeAreaAtlasProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeConsequenceEngine+02-LifeConsequenceRecord.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeConsequenceEngine+03-LifeConsequenceEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeConsequenceEngine+04-LifeConsequenceRecord.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeConsequenceEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeShapeBucketBuilder.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LifeShapeEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/LocalScheduleBlockRepository.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/MemoryLensResult+SearchPresentation.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SearchRecall` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/MemoryLensService+SearchAdapters.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SearchRecall` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/MemoryLensService.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/SearchRecall` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/MultiPathLattice.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/NorthStarProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/OneStepGoalProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/OpenCapacityEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/PathIntelligenceProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/PressureEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ProtectionEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RealityIntegrationAdapters.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/RealityModelProjector.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RecommendationEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RecommendationExplanationAdapter.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RecoveryEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ReviewsV1Projector+02-cadenceSummaries.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ReviewsV1Projector+03-progressReceiptLines.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ReviewsV1Projector.swift` | `Core/Runtime` | `AmbitionsDesignSystem, Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RitualOrchestrationService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RuntimeCoreUmbrellaGate.swift` | `Core/Runtime` | `Foundation` | `Test-only support` | `Tests/Runtime or Quality quarantine` | `P-TEST` | `F-TEST` |
| `Native/Ambitions/Core/Runtime/RuntimePackageBoundaryModels.swift` | `Core/Runtime` | `Foundation` | `Unresolved` | `Owner decision required` | `P-DECIDE` | `F-DECIDE` |
| `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/ProjectionEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+02-ScheduleInstallRecord.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+04-ScheduleInstallRecord.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SharedLifeCoordinationService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService+Recurring.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SmartAttachmentCaptureAdapter.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SmartAttachmentService.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/CaptureRouteGraph` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/SnapshotRefreshingServices.swift` | `Core/Runtime` | `Foundation` | `Adapter shim` | `Core/LocalRuntimeOS/RuntimeBoundary shim` | `P-SHIM` | `F-SHIM` |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+03-StepElasticityEngineInput.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepQualityFirewall.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/PlanningEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/StepReallocationRuntimeBridge.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |
| `Native/Ambitions/Core/Runtime/TimeRitualGoalSemantics.swift` | `Core/Runtime` | `Foundation` | `Move into LocalRuntimeOS` | `Core/LocalRuntimeOS/TimeEngine` | `P-MOVE` | `F-MOVE` |

## Explicit Unresolved File

`Native/Ambitions/Core/Runtime/RuntimePackageBoundaryModels.swift` remains
Unresolved because it encodes planned package-boundary vocabulary and a stale
`Native/Ambitions/Runtime` source root while current truth forbids package
boundary cleanup theater without a linked decision record and validation plan.
AMB-1714 must record whether this becomes a `Quality`/test support guard, moves
under a LocalRuntimeOS diagnostics owner, or is quarantined by AMB-1716.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched: `docs/audits` only.
- Swift owners touched: none.
- Files moved or created in Swift source: none.
- Old/noncanonical source paths removed: none.
- Compatibility shims left behind: none added by this slice.
- Yellow architecture debt remains: yes, every `Core/Runtime` Swift file remains
  in place until AMB-1714, AMB-1715, and AMB-1716 replace imports, add guards,
  and delete or quarantine legacy copies.
- Next repair train: AMB-1714 production import replacement, followed by
  AMB-1715 guard installation and AMB-1716 first deletion/quarantine batch.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, build, device, release, or product-completion
  claim is made.
