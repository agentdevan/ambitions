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
owner-move batch, the step planning/scheduling owner-move batch, and the
MemoryLens/SearchRecall owner-move batch. AMB-1730 lowered active legacy
runtime production files from `111` to `64` by moving source files out of
`Core/Runtime` and into `Core/LocalRuntimeOS/PlanningEngine`,
`Core/LocalRuntimeOS/TimeEngine`, and `Core/LocalRuntimeOS/SearchRecall`. This
remains Implemented Yellow because `64` legacy runtime production files still
exist.

Evidence class: Implemented Yellow. The slice proves a bounded source-owner
reduction and ownership-test update only. It does not prove total
LocalRuntimeOS completion, runtime correctness across all flows, device behavior,
accessibility behavior, privacy/legal approval, TestFlight readiness, App Store
readiness, or Green project status.

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
| `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift` | `Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeProjectionPipeline.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/ProjectionEngine` | Moved; legacy path retired. |
| `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift` | `Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeSnapshot.swift` | Move into LocalRuntimeOS -> `Core/LocalRuntimeOS/ProjectionEngine` | Moved; legacy path retired. |

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
AMB-1730 MemoryLens/SearchRecall batch.
The remaining files stay Yellow, not Green:

- `51` move-candidate files remain in legacy runtime owner scope.
- `8` adapter-shim files remain in legacy runtime owner scope.
- `4` test-only support files remain in legacy runtime owner scope.
- `1` unresolved owner-decision file remains:
  `Native/Ambitions/Core/Runtime/RuntimePackageBoundaryModels.swift`.

Exact remaining legacy inventory is the AMB-1713 classification table minus the
AMB-1714, AMB-1716, and AMB-1730 retired rows above. Follow-up ownership and
deletion remain under AMB-1730/AMB-1666 until no live production authority
remains. Unsafe write and persistence authority findings remain outside this
slice and stay under AMB-1667 follow-up work.

Historical generated ledgers may still mention the retired paths from earlier
review snapshots. Those rows are not AMB-1714 Green proof; this overlay is the
current proof-bounded source-owner record for these three files.

## Ownership Proof

Updated tests:

- `Native/AmbitionsTests/Runtime/CoreRuntimeCanonicalOwnershipTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/PrivateLifeRuntimeKernel/PrivateLifeRuntimeKernelOwnershipTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/ProjectionEngine/ProjectionEngineTests.swift`

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

## AMB-1730 Evidence Update

Before count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reported `baselineLegacyRuntimeFiles=67`,
  `currentLegacyRuntimeFiles=67`, `legacyRuntimeFileCeiling=67`, and
  `findingCount=0` before this MemoryLens/SearchRecall move batch.
- Cumulative AMB-1730 source-owner remediation began at `111` active legacy
  runtime production files before the earlier PlanningEngine and TimeEngine
  move batches.

After count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reports `baselineLegacyRuntimeFiles=64`,
  `currentLegacyRuntimeFiles=64`, `legacyRuntimeFileCeiling=64`, and
  `findingCount=0`.

Files moved/deleted/quarantined/converted:

- Moved `47` standalone PlanningEngine, TimeEngine, and SearchRecall source
  files listed in `AMB-1730 Moved Rows`, including this run's `3`
  MemoryLens/SearchRecall source files.
- Renamed `MemoryLensService+SearchAdapters.swift` to
  `MemoryLensService+SearchResults.swift` in the canonical SearchRecall owner
  so result mapping is not treated as adapter authority.
- Deleted no Swift behavior.
- Quarantined no test-support files.
- Converted no adapter shims.

Remaining files:

- `64` production Swift files remain under `Native/Ambitions/Core/Runtime`.

Remaining blockers:

- Remaining move-candidate, adapter-shim, test-only-support, and unresolved
  rows still need source movement, deletion, quarantine, or approved shim proof
  before AMB-1666 or AMB-1730 can be Green.
- This slice does not remove persistence direct writes, external adapter gaps,
  or unsafe repository mutation paths.

Rollback plan:

- Move the latest AMB-1730 MemoryLens/SearchRecall files back from
  `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/` to
  `Native/Ambitions/Core/Runtime/`, restoring
  `MemoryLensService+SearchResults.swift` to the retired legacy filename
  `MemoryLensService+SearchAdapters.swift`; restore the guard ceiling to `67`,
  remove the current SearchRecall ownership assertions, regenerate the project,
  and rerun the focused MemoryLens/SearchRecall tests plus the required
  remediation guards when build validation is re-enabled. A full
  AMB-1730 owner-move rollback would also move the earlier PlanningEngine and
  TimeEngine files back from
  `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/` and
  `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/` to
  `Native/Ambitions/Core/Runtime/`, restore the guard ceiling to `111`, remove
  the AMB-1730 ownership assertions, regenerate the project, and rerun the
  focused PlanningEngine/TimeEngine/service tests plus the required remediation
  guards.

## Validation

Validation run:

- `git diff --check` -> exit `0`.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  -> exit `0`; `baselineLegacyRuntimeFiles=64`,
  `currentLegacyRuntimeFiles=64`, `legacyRuntimeFileCeiling=64`,
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
  -> `64`.

Validation not run:

- Focused Swift/Xcode validation for the MemoryLens/SearchRecall move batch was
  skipped after user instruction to skip build testing until advised otherwise.
- Full test suite.
- Physical device runtime proof.
- Accessibility, performance, privacy/legal, TestFlight, App Store, or release
  readiness proof.

## Claim Ceiling

Final Architecture Tree inspected: yes.

Canonical owners touched:

- `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`
- `Core/LocalRuntimeOS/ProjectionEngine`
- `Core/LocalRuntimeOS/PlanningEngine`
- `Core/LocalRuntimeOS/TimeEngine`
- `Core/LocalRuntimeOS/SearchRecall`
- Legacy owner retired for `47` AMB-1730 files: `Core/Runtime`

Files moved or created:

- Moved `PrivateLifeRuntime.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`.
- Moved `RuntimeProjectionPipeline.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/ProjectionEngine`.
- Moved `RuntimeSnapshot.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/ProjectionEngine`.
- Moved the `47` AMB-1730 PlanningEngine, TimeEngine, and SearchRecall files
  listed in `AMB-1730 Moved Rows` from `Core/Runtime` to
  `Core/LocalRuntimeOS`.
- Created this audit overlay.

Old/non-canonical paths removed:

- `Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift`
- `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift`
- `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift`
- The `47` AMB-1730 retired legacy paths listed in `AMB-1730 Moved Rows`.

Compatibility shims left behind by this slice: none.

Yellow architecture debt remains because `64` legacy runtime files still exist,
including adapter shims, test-only support, and the unresolved
`RuntimePackageBoundaryModels.swift` owner decision. Next repair trains:
AMB-1730 follow-up owner-move/quarantine batches, plus AMB-1667 children for
unsafe write/persistence authority.

No equivalent-folder or close-enough path interpretation was used.
