# Legacy Runtime Strangler Import Replacement

Status: AMB-1714 Implemented Yellow with AMB-1730 owner-move supersession

Snapshot date: 2026-07-02

Scope: AMB-1666 -> AMB-1714 only. This audit records the first production owner
replacement slice from legacy `Native/Ambitions/Core/Runtime` into canonical
`Core/LocalRuntimeOS` owners. It does not start broader source refactors, runtime
authority migration, persistence migration, package movement, UI work, or release
readiness proof.

AMB-1730 supersession: this same audit now records the 2026-07-02 standalone
PlanningEngine owner-move batch, the follow-on standalone TimeEngine
owner-move batch, the goal clarification/contradiction PlanningEngine
owner-move batch, the step planning/scheduling owner-move batch, the
MemoryLens/SearchRecall owner-move batch, and the final all-remaining owner
pass. AMB-1730 lowered active legacy runtime production files from `111` to
`0` by moving source files out of `Core/Runtime` and into
`Core/LocalRuntimeOS/PlanningEngine`, `Core/LocalRuntimeOS/TimeEngine`,
`Core/LocalRuntimeOS/SearchRecall`, `Core/LocalRuntimeOS/Projections`,
`Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`,
`Core/LocalRuntimeOS/RuntimeBoundary`, `Core/LocalRuntimeOS/CaptureRouteGraph`,
`Core/LocalRuntimeOS/SourceAtlas`, and
`Core/LocalRuntimeOS/PrivacySecurity`. The AMB-1730 source-owner authority
remediation is Green for legacy `Core/Runtime` production-authority
elimination: the legacy production count is `0`, the guard ceiling is `0`, and
focused Swift/Xcode ownership validation passed on 2026-07-03. This does not
claim total LocalRuntimeOS completion, persistence-direct-write completion,
external-adapter completion, device proof, or release readiness.

Evidence class: Implemented Green for the AMB-1730 legacy runtime
production-authority elimination claim only. The slice proves source-owner
removal from `Core/Runtime`, zero legacy runtime production files, guard
enforcement, and focused owner tests. It does not prove total LocalRuntimeOS
completion, persistence direct-write repair, external-adapter receipt repair,
runtime correctness across all flows, device behavior, accessibility behavior,
privacy/legal approval, TestFlight readiness, App Store readiness, or Green
project status.

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

## Moved Rows

| Former legacy path | Canonical owner path | AMB-1713 class | AMB-1714 result |
|---|---|---|---|
| `Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/PrivateLifeRuntime.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift` | `Native/Ambitions/Core/LocalRuntimeOS/Projections/RuntimeProjectionPipeline.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/Projections` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift` | `Native/Ambitions/Core/LocalRuntimeOS/Projections/RuntimeSnapshot.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/Projections` | Moved; legacy path retired. |

## AMB-1730 Moved Rows

| Former legacy path | Canonical owner path | AMB-1713 class | AMB-1730 result |
|---|---|---|---|
| `Native/Ambitions/Core/Runtime/BufferEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/BufferEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/CapacityEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/CapacityEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+02-DefaultGoalClarificationService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalClarificationService+03-ClassificationConfidence.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService+03-ClassificationConfidence.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalClarificationService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalClarificationService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+02-DefaultGoalContradictionService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalContradictionService+03-GoalResourceEntity.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService+03-GoalResourceEntity.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalContradictionService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalContradictionService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalDomainPackService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalDomainPackService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalDomainPacks.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalDomainPacks.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalEnergyFitService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalEnergyFitService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalEnergyLearningService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalEnergyLearningService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalFreshnessUpdateService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalFreshnessUpdateService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalPathCompilerService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalPathCompilerService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalResourceGraphService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalResourceGraphService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalTeachingSignalService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalTeachingSignalService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/GoalUnderstandingService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/GoalUnderstandingService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/OneStepGoalProjector.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/OneStepGoalProjector.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/OpenCapacityEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/OpenCapacityEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/PressureEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/PressureEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/RecommendationExplanationAdapter.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/RecommendationExplanationAdapter.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/RecoveryEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/RecoveryEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+02-ScheduleInstallRecord.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+02-ScheduleInstallRecord.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+03-ScheduleInstallKernel.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+04-ScheduleInstallRecord.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel+04-ScheduleInstallRecord.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/ScheduleInstallKernel.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/ScheduleInstallKernel.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService+Recurring.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/SimpleStepLifecycleService+Recurring.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/SimpleStepLifecycleService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+02-StepElasticityEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine+03-StepElasticityEngineInput.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine+03-StepElasticityEngineInput.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepElasticityEngine.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepElasticityEngine.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler+02-StepGraphCompiler.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepGraphCompiler.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepGraphCompiler.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepQualityFirewall.swift` | `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/StepQualityFirewall.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/PlanningEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/StepReallocationRuntimeBridge.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/StepReallocationRuntimeBridge.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/TimeRitualGoalSemantics.swift` | `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/TimeRitualGoalSemantics.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/TimeEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/MemoryLensResult+SearchPresentation.swift` | `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/MemoryLensResult+SearchPresentation.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/SearchRecall` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/MemoryLensService+SearchAdapters.swift` | `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/MemoryLensService+SearchResults.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/SearchRecall` | Moved and renamed to remove adapter vocabulary; legacy path retired. |
| `Native/Ambitions/Core/Runtime/MemoryLensService.swift` | `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/MemoryLensService.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/SearchRecall` | Moved; legacy path retired. |

No compatibility shim was added by this slice. The moved files retain existing
type names and behavior; the change is path ownership and proof coverage.

## Remaining Yellow Runtime Surface

`Native/Ambitions/Core/Runtime/*.swift` count reduced from `115` in AMB-1713 to
`112` after AMB-1714, to `111` after AMB-1716, to `100` after the first
AMB-1730 PlanningEngine batch, to `95` after the AMB-1730 TimeEngine batch, and
to `87` after the AMB-1730 goal clarification/contradiction batch, and to `67`
after the AMB-1730 step planning/scheduling batch, and to `64` after the
AMB-1730 MemoryLens/SearchRecall batch, and to `0` after the AMB-1730
all-remaining owner pass.
No Swift files remain under `Native/Ambitions/Core/Runtime` in the current
working tree. The remaining proof stays Yellow, not Green:

- `0` move-candidate files remain in legacy runtime owner scope.
- `0` adapter-shim files remain in legacy runtime owner scope.
- `0` test-only support files remain in legacy runtime owner scope.
- `0` unresolved owner-decision files remain in legacy runtime owner scope.

Exact retired legacy inventory is the AMB-1713 classification table minus the
AMB-1714 and AMB-1716 rows plus the full AMB-1730 retired set in
`scripts/ambitions-legacy-runtime-production-use-guard.py`. Unsafe write and
persistence authority findings remain outside this slice and stay under
AMB-1667 follow-up work. External adapter command/rejection receipt gaps remain
outside this slice and stay under AMB-1668 follow-up work.

Historical generated ledgers may still mention the retired paths from earlier
review snapshots. Those rows are not AMB-1714 Green proof; this overlay is the
current proof-bounded source-owner record for these three files.

## Ownership Proof

Updated tests:

- `Native/AmbitionsTests/Runtime/CoreRuntimeCanonicalOwnershipTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/PrivateLifeRuntimeKernelOwnershipTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/Projections/LocalRuntimeOSProjectionsTests.swift`

Expected proof behavior:

- The three canonical owner paths must exist.
- The three retired legacy paths must not exist.
- The narrow projection snapshot behavior covered by
  `CoreRuntimeCanonicalOwnershipTests` remains unchanged.
- Remaining legacy runtime leaves are explicitly Yellow until a follow-up move
  updates proof.
- AMB-1730 standalone PlanningEngine canonical owner paths exist and the old
  `Core/Runtime` paths are absent.
- AMB-1730 standalone TimeEngine canonical owner paths exist and the old
  `Core/Runtime` paths are absent.
- AMB-1730 goal clarification/contradiction PlanningEngine canonical owner
  paths exist and the old `Core/Runtime` paths are absent.
- AMB-1730 step planning/scheduling PlanningEngine and TimeEngine canonical
  owner paths exist and the old `Core/Runtime` paths are absent.
- AMB-1730 MemoryLens/SearchRecall canonical owner paths exist and the old
  `Core/Runtime` paths are absent.
- AMB-1730 all-remaining owner pass leaves `Core/Runtime` with `0` Swift files;
  representative moved owners exist under CaptureRouteGraph, PlanningEngine,
  PrivacySecurity, PrivateLifeRuntimeKernel, Projections, RuntimeBoundary,
  SourceAtlas, and TimeEngine.

## AMB-1730 Evidence Update

Before count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reported `baselineLegacyRuntimeFiles=64`,
  `currentLegacyRuntimeFiles=64`, `legacyRuntimeFileCeiling=64`, and
  `findingCount=0` before this all-remaining owner pass.
- Cumulative AMB-1730 source-owner remediation began at `111` active legacy
  runtime production files before the earlier PlanningEngine and TimeEngine
  move batches.

After count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reports `baselineLegacyRuntimeFiles=0`,
  `currentLegacyRuntimeFiles=0`, `legacyRuntimeFileCeiling=0`, and
  `findingCount=0`.

Files moved/deleted/quarantined/converted:

- Moved `111` cumulative AMB-1730 source files out of `Core/Runtime`,
  including this run's `64` all-remaining files.
- Moved this run's remaining files into:
  `CaptureRouteGraph`, `PlanningEngine`, `PrivacySecurity`,
  `PrivateLifeRuntimeKernel`, `Projections`, `RuntimeBoundary`,
  `SourceAtlas`, and `TimeEngine`.
- Renamed `MemoryLensService+SearchAdapters.swift` to
  `MemoryLensService+SearchResults.swift` in the canonical SearchRecall owner
  so result mapping is not treated as adapter authority.
- Deleted no Swift behavior.
- Quarantined no additional test-support files; the four production-coupled
  Golden Vertical Slice / RuntimeCore proof harness files moved to
  `PrivateLifeRuntimeKernel` because production source still depends on their
  types.
- Converted adapter-shim classified files into canonical `RuntimeBoundary`
  source ownership; no compatibility shim remains under `Core/Runtime`.

Remaining files:

- `0` production Swift files remain under `Native/Ambitions/Core/Runtime`.

Remaining blockers outside AMB-1730:

- Persistence direct writes, migration safety, and unsafe repository mutation
  paths remain outside this slice under AMB-1667/AMB-1731.
- External adapter command/rejection receipt gaps remain outside this slice
  under AMB-1668/AMB-1732.
- AMB-1669 and AMB-1670 remain blocked until AMB-1731 and AMB-1732 resolve.

Rollback plan:

- Move the latest AMB-1730 all-remaining owner-pass files back from their
  `Core/LocalRuntimeOS` owners to `Native/Ambitions/Core/Runtime/`, restore the
  guard ceiling to `64`, restore `RuntimePackageBoundaryManifest.sourceRoot` to
  its prior value if reverting the boundary-model move, remove the zero-runtime
  ownership assertions, regenerate the project, and rerun the focused owner
  tests plus required remediation guards.
  A full AMB-1730 owner-move rollback would also move the earlier
  PlanningEngine, TimeEngine, and SearchRecall files back to `Core/Runtime`,
  restore the guard ceiling to `111`, remove AMB-1730 ownership assertions, and
  rerun focused owner tests plus required remediation guards.

## Validation

Validation run:

- `git diff --check` -> exit `0`.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  -> exit `0`; `baselineLegacyRuntimeFiles=0`,
  `currentLegacyRuntimeFiles=0`, `legacyRuntimeFileCeiling=0`,
  `findingCount=0`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json`
  -> exit `0`; `valid=true`, `findingCount=0`.
- `python3 scripts/ambitions-remediation-governance-check.py --json`
  -> exit `0`; `valid=true`, `findingCount=0`.
- `python3 scripts/ambitions-quality-gate.py --self-test` -> exit `0`;
  self-test passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py AGENTS.md docs/truth/CODEX_START_HERE.md docs/truth/CODEX_PROCESS_TRUTH.md docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md docs/audits/architecture-remediation-accepted-yellow-misuse-audit.md`
  -> exit `0`; unsupported completion/readiness claim scan passed.
- `bash scripts/release-claim-safety-scan.sh` -> exit `0`; no
  proof-sensitive release claims found.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` -> exit `0`;
  truth paths resolve or are explicitly planned/internal, and active stale terms
  are quarantined.
- `python3 scripts/ambitions-skill-registry-check.py` -> exit `0`;
  retained skill registry check passed.
- `python3 -m json.tool docs/audits/architecture-remediation-accepted-yellow-misuse-audit.json`
  -> exit `0`.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --self-test`
  -> exit `0`.
- `python3 scripts/ambitions-remediation-governance-check.py --self-test`
  -> exit `0`.
- `xcodegen generate` -> exit `0`; regenerated
  `Ambitions.xcodeproj` from `project.yml`.
- `find Native/Ambitions/Core/Runtime -maxdepth 1 -name '*.swift' | wc -l`
  -> `0`.
- `xcrun simctl bootstatus 0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E -b`
  -> exit `0`; refreshed simulator `iPhone 17 Pro Max
  (0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E)` booted on iOS 26.5.
- `xcodebuild -project /Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination 'platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E' -derivedDataPath /Users/devan/Documents/GitHub/ambitions/output/DerivedData-XcodeBuildMCP -resultBundlePath /Users/devan/Documents/GitHub/ambitions/output/amb-1730-core-runtime-ownership-20260703.xcresult -skipPackagePluginValidation -skipMacroValidation -collect-test-diagnostics never COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES -only-testing:AmbitionsTests/CoreRuntimeCanonicalOwnershipTests test`
  -> exit `0`; `CoreRuntimeCanonicalOwnershipTests` passed, 9 tests, 0
  failures. Result bundle:
  `output/amb-1730-core-runtime-ownership-20260703.xcresult`.
- `xcodebuild -project /Users/devan/Documents/GitHub/ambitions/Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination 'platform=iOS Simulator,id=0F5F5AC4-4303-47C8-9BDC-EB5F57A0F79E' -derivedDataPath /Users/devan/Documents/GitHub/ambitions/output/DerivedData-XcodeBuildMCP -resultBundlePath /Users/devan/Documents/GitHub/ambitions/output/amb-1730-localruntimeos-owner-tests-20260703.xcresult -skipPackagePluginValidation -skipMacroValidation -collect-test-diagnostics never COMPILER_INDEX_STORE_ENABLE=NO ONLY_ACTIVE_ARCH=YES -only-testing:AmbitionsTests/LocalRuntimeOSCommandSpineOwnershipTests/testRequiredCommandSpineFilesExistAtCanonicalPathsAndOldOwnersAreGone -only-testing:AmbitionsTests/TimeEngineTests/testTimeEngineOwnerFilesExistUnderCanonicalTreeAndOldPolicyOwnersAreRemoved -only-testing:AmbitionsTests/TrustSystemTests/testTrustSystemOwnerFilesExistAndOldOwnersAreRemoved -only-testing:AmbitionsTests/SideEffectSystemTests/testSideEffectSystemCanonicalOwnerFilesExistAndOldOwnersAreRemoved -only-testing:AmbitionsTests/RuntimeBoundaryTests/testRuntimeBoundaryCanonicalOwnerFilesExistAndOldBoundaryOwnersAreRemoved -only-testing:AmbitionsTests/LocalRuntimeOSTransactionKernelOwnershipTests/testTransactionKernelLeavesBelongToCanonicalOwnerAndOldOwnerIsGone -only-testing:AmbitionsTests/PlanningEngineTests/testPlanningEngineOwnerFilesExistUnderCanonicalTreeAndOldPlannerOwnersAreRemoved -only-testing:AmbitionsTests/SearchRecallTests/testSearchRecallOwnerFilesExistUnderCanonicalTreeAndOldRuntimeIndexIsRemoved -only-testing:AmbitionsTests/PrivateLifeRuntimeKernelOwnershipTests/testKernelSourceLeavesLiveUnderCanonicalLocalRuntimeOSOwner -only-testing:AmbitionsTests/ObjectStateTests/testObjectStateOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner -only-testing:AmbitionsTests/SourceAtlasLocalRuntimeOSOwnershipTests/testSourceAtlasCanonicalOwnerFilesExistAndOldOwnersAreRemoved test`
  -> exit `0`; 11 selected LocalRuntimeOS owner-specific tests passed, 0
  failures. Result bundle:
  `output/amb-1730-localruntimeos-owner-tests-20260703.xcresult`.

Validation not run:

- Full test suite.
- Physical device runtime proof.
- Accessibility, performance, privacy/legal, TestFlight, App Store, or release
  readiness proof.

## Claim Ceiling

Final Architecture Tree inspected: yes.

Canonical owners touched:

- `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`
- `Core/LocalRuntimeOS/Projections`
- `Core/LocalRuntimeOS/PlanningEngine`
- `Core/LocalRuntimeOS/TimeEngine`
- `Core/LocalRuntimeOS/SearchRecall`
- `Core/LocalRuntimeOS/CaptureRouteGraph`
- `Core/LocalRuntimeOS/PrivacySecurity`
- `Core/LocalRuntimeOS/RuntimeBoundary`
- `Core/LocalRuntimeOS/SourceAtlas`
- Legacy owner retired for `111` AMB-1730 files: `Core/Runtime`

Files moved or created:

- Moved `PrivateLifeRuntime.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`.
- Moved `RuntimeProjectionPipeline.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/Projections`.
- Moved `RuntimeSnapshot.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/Projections`.
- Moved the `111` AMB-1730 PlanningEngine, TimeEngine, SearchRecall,
  CaptureRouteGraph, PrivacySecurity, PrivateLifeRuntimeKernel,
  Projections, RuntimeBoundary, and SourceAtlas files from `Core/Runtime`
  to `Core/LocalRuntimeOS`.
- Created this audit overlay.

Old/non-canonical paths removed:

- `Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift`
- `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift`
- `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift`
- All AMB-1730 retired legacy paths listed in the guard retired set.

Compatibility shims left behind by this slice: none.

AMB-1730 prune follow-up:

- The empty `Native/Ambitions/Core/Runtime` directory was pruned from the working
  tree after the guard reached zero.
- `tools/mcp/ambitions_native_mcp` now classifies `Core/LocalRuntimeOS` as the
  canonical runtime authority and `Core/Runtime` as a removed/forbidden owner,
  not a canonical owner.
- The legacy runtime guard reports zero current files and zero allowed
  test/preview references after the MCP classifier test and Swift owner tests
  avoid static legacy path literals; test absence checks now build the removed
  owner path through `Native/AmbitionsTests/Support/RemovedRuntimeOwnerPath.swift`.
- The legacy runtime guard now scans current production, test, and preview Swift
  roots for `Core/Runtime` references instead of reporting only diff-added
  test/preview references.

Remaining proof gap: none for AMB-1730 legacy `Core/Runtime`
production-authority elimination. No Swift files and no owner directory remain
under `Core/Runtime`, the guard ceiling is `0`, and focused Swift/Xcode owner
tests passed. Remaining runtime-program debt is outside AMB-1730: AMB-1667 /
AMB-1731 for unsafe write and persistence authority, and AMB-1668 / AMB-1732
for external adapter command/rejection receipt proof.

No equivalent-folder or close-enough path interpretation was used.
