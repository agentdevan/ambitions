# Legacy Runtime Production Use Guard

Status: AMB-1715 Implemented Yellow

Snapshot date: 2026-07-02

Scope: AMB-1666 -> AMB-1715, with AMB-1716 and AMB-1730 supersessions applied.
This retained audit installs a guard for new production use of the legacy
`Native/Ambitions/Core/Runtime` owner. AMB-1716 extends the retired-path set for
the first test-support quarantine. AMB-1730 extends it for the standalone
PlanningEngine, goal clarification/contradiction, TimeEngine, step
planning/scheduling, MemoryLens/SearchRecall, and final all-remaining
owner-move batches. It does not prove full LocalRuntimeOS completion.

Evidence class: Implemented Yellow. The guard reports new production legacy
runtime owner growth and explicit new production source references to
`Core/Runtime`. It preserves the AMB-1730 zero-ceiling baseline of `0`
remaining legacy runtime production files. It does not prove runtime correctness, device
behavior, accessibility behavior, privacy/legal approval, TestFlight readiness,
App Store readiness, or Green project status.

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
proof automation outranks prose
```

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Guard Behavior

Retained script:

- `scripts/ambitions-legacy-runtime-production-use-guard.py`

The guard:

- parses the AMB-1713 classification baseline from
  `docs/audits/legacy-runtime-strangler-classification.md`;
- subtracts the AMB-1714, AMB-1716, and AMB-1730 retired legacy owner paths;
- keeps the current legacy runtime production-file ceiling at `0`;
- reports any new production Swift file under `Native/Ambitions/Core/Runtime`;
- reports any AMB-1714, AMB-1716, or AMB-1730 retired legacy owner path that is
  reintroduced;
- reports new production Swift diff lines outside `Core/Runtime` that
  explicitly reference `Core/Runtime`; and
- allows test or preview support paths to mention `Core/Runtime` for validation
  or quarantine work.

The guard is wired into:

- `scripts/ambitions-remediation-governance-check.py`

This means the required remediation governance check now runs the AMB-1715
legacy runtime production-use guard.

## Claim Ceiling

Final Architecture Tree inspected: yes.

Canonical owners touched:

- `Quality` / repo governance scripts
- `docs/audits`

Production Swift behavior touched: none.

Files created by AMB-1715:

- `scripts/ambitions-legacy-runtime-production-use-guard.py`
- `docs/audits/legacy-runtime-production-use-guard.md`

Files updated by AMB-1715:

- `scripts/ambitions-remediation-governance-check.py`

Old/non-canonical paths removed: none.

Compatibility shims left behind by this slice: none added.

AMB-1716 supersession:

- Retired path added:
  `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift`
- Quarantined support owner:
  `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`
- Active guard ceiling: `111` legacy runtime production files.

AMB-1730 supersession:

- Retired paths added:
  - `Native/Ambitions/Core/Runtime/BufferEngine.swift`
  - `Native/Ambitions/Core/Runtime/CapacityEngine.swift`
  - `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService+03-defaultAssumption.swift`
  - `Native/Ambitions/Core/Runtime/GoalClarificationService+02-DefaultGoalClarificationService.swift`
  - `Native/Ambitions/Core/Runtime/GoalClarificationService+03-ClassificationConfidence.swift`
  - `Native/Ambitions/Core/Runtime/GoalClarificationService.swift`
  - `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService+03-energyContradictions.swift`
  - `Native/Ambitions/Core/Runtime/GoalContradictionService+02-DefaultGoalContradictionService.swift`
  - `Native/Ambitions/Core/Runtime/GoalContradictionService+03-GoalResourceEntity.swift`
  - `Native/Ambitions/Core/Runtime/GoalContradictionService.swift`
  - `Native/Ambitions/Core/Runtime/GoalDomainPackService.swift`
  - `Native/Ambitions/Core/Runtime/GoalDomainPacks.swift`
  - `Native/Ambitions/Core/Runtime/GoalEnergyFitService.swift`
  - `Native/Ambitions/Core/Runtime/GoalEnergyLearningService.swift`
  - `Native/Ambitions/Core/Runtime/GoalFreshnessUpdateService.swift`
  - `Native/Ambitions/Core/Runtime/GoalPathCompilerService.swift`
  - `Native/Ambitions/Core/Runtime/GoalResourceGraphService.swift`
  - `Native/Ambitions/Core/Runtime/GoalTeachingSignalService.swift`
  - `Native/Ambitions/Core/Runtime/GoalUnderstandingService.swift`
  - `Native/Ambitions/Core/Runtime/MemoryLensResult+SearchPresentation.swift`
  - `Native/Ambitions/Core/Runtime/MemoryLensService+SearchAdapters.swift`
  - `Native/Ambitions/Core/Runtime/MemoryLensService.swift`
  - `Native/Ambitions/Core/Runtime/OneStepGoalProjector.swift`
  - `Native/Ambitions/Core/Runtime/OpenCapacityEngine.swift`
  - `Native/Ambitions/Core/Runtime/PressureEngine.swift`
  - `Native/Ambitions/Core/Runtime/RecommendationExplanationAdapter.swift`
  - `Native/Ambitions/Core/Runtime/RecoveryEngine.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+02-ScheduleInstallRecord.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+02-evaluate.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel+03-makeReceipt.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+03-ScheduleInstallKernel.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel+04-ScheduleInstallRecord.swift`
  - `Native/Ambitions/Core/Runtime/ScheduleInstallKernel.swift`
  - `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService+Recurring.swift`
  - `Native/Ambitions/Core/Runtime/SimpleStepLifecycleService.swift`
  - `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+02-evaluate.swift`
  - `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine+03-makeReceipt.swift`
  - `Native/Ambitions/Core/Runtime/StepElasticityEngine+02-StepElasticityEngine.swift`
  - `Native/Ambitions/Core/Runtime/StepElasticityEngine+03-StepElasticityEngineInput.swift`
  - `Native/Ambitions/Core/Runtime/StepElasticityEngine.swift`
  - `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+02-compile.swift`
  - `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler+03-edgeKind.swift`
  - `Native/Ambitions/Core/Runtime/StepGraphCompiler+02-StepGraphCompiler.swift`
  - `Native/Ambitions/Core/Runtime/StepGraphCompiler.swift`
  - `Native/Ambitions/Core/Runtime/StepQualityFirewall.swift`
  - `Native/Ambitions/Core/Runtime/StepReallocationRuntimeBridge.swift`
  - `Native/Ambitions/Core/Runtime/TimeRitualGoalSemantics.swift`
- Canonical owner:
  `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/` and
  `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/`, plus
  `Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/`
- Active guard ceiling: `0` legacy runtime production files.
- Guard proof:
  `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reports `baselineLegacyRuntimeFiles=0`,
  `currentLegacyRuntimeFiles=0`, `legacyRuntimeFileCeiling=0`,
  and `findingCount=0`.

Remaining proof gap: Swift/Xcode validation was skipped by user instruction. No
Swift files remain under `Core/Runtime`; the empty `Core/Runtime` owner
directory was pruned after the guard reached zero. The final AMB-1730 owner pass
moved the remaining adapter-shim classified files to
`Core/LocalRuntimeOS/RuntimeBoundary`, the production-coupled Golden Vertical
Slice / RuntimeCore proof harness to `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`,
and the unresolved `RuntimePackageBoundaryModels.swift` owner decision to
`Core/LocalRuntimeOS/RuntimeBoundary` with an updated LocalRuntimeOS source
root. `tools/mcp/ambitions_native_mcp` now reports `Core/Runtime` as a
removed/forbidden owner rather than a canonical owner. Next repair train:
focused owner build/typecheck/tests when build validation is re-enabled.

No equivalent-folder or close-enough path interpretation was used.
