# Legacy Runtime Strangler Import Replacement

Status: AMB-1714 Implemented Yellow with AMB-1730 owner-move supersession

Snapshot date: 2026-07-02

Scope: AMB-1666 -> AMB-1714 only. This audit records the first production owner
replacement slice from legacy `Native/Ambitions/Core/Runtime` into canonical
`Core/LocalRuntimeOS` owners. It does not start broader source refactors, runtime
authority migration, persistence migration, package movement, UI work, or release
readiness proof.

AMB-1730 supersession: this same audit now records the 2026-07-02 standalone
PlanningEngine owner-move batch and the follow-on standalone TimeEngine
owner-move batch. AMB-1730 lowered active legacy runtime production files from
`111` to `95` by moving source files out of `Core/Runtime` and into
`Core/LocalRuntimeOS/PlanningEngine` and `Core/LocalRuntimeOS/TimeEngine`.
This remains Implemented Yellow because `95` legacy runtime production files
still exist.

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

No compatibility shim was added by this slice. The moved files retain existing
type names and behavior; the change is path ownership and proof coverage.

## Remaining Yellow Runtime Surface

`Native/Ambitions/Core/Runtime/*.swift` count reduced from `115` in AMB-1713 to
`112` after AMB-1714, to `111` after AMB-1716, to `100` after the first
AMB-1730 PlanningEngine batch, and to `95` after the AMB-1730 TimeEngine batch.
The remaining files stay Yellow, not Green:

- `82` move-candidate files remain in legacy runtime owner scope.
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

## AMB-1730 Evidence Update

Before count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reported `currentLegacyRuntimeFiles=111`,
  `legacyRuntimeFileCeiling=111`, and `findingCount=0`.

After count:

- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  reports `baselineLegacyRuntimeFiles=95`,
  `currentLegacyRuntimeFiles=95`, `legacyRuntimeFileCeiling=95`, and
  `findingCount=0`.

Files moved/deleted/quarantined/converted:

- Moved `16` standalone PlanningEngine and TimeEngine source files listed in
  `AMB-1730 Moved Rows`.
- Deleted no Swift behavior.
- Quarantined no test-support files.
- Converted no adapter shims.

Remaining files:

- `95` production Swift files remain under `Native/Ambitions/Core/Runtime`.

Remaining blockers:

- Remaining move-candidate, adapter-shim, test-only-support, and unresolved
  rows still need source movement, deletion, quarantine, or approved shim proof
  before AMB-1666 or AMB-1730 can be Green.
- This slice does not remove persistence direct writes, external adapter gaps,
  or unsafe repository mutation paths.

Rollback plan:

- Move the AMB-1730 files back from
  `Native/Ambitions/Core/LocalRuntimeOS/PlanningEngine/` and
  `Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/` to
  `Native/Ambitions/Core/Runtime/`, restore the guard ceiling to `111`, remove
  the AMB-1730 ownership assertions, regenerate the project, and rerun the
  focused PlanningEngine/TimeEngine/service tests plus the required remediation
  guards.

## Validation

Validation run:

- `python3 scripts/ambitions-remediation-governance-check.py` -> passed.
- `python3 scripts/ambitions-runtime-direct-write-audit.py --json` -> completed
  with no command failure; existing runtime authority findings remain Yellow and
  outside AMB-1714.
- `xcodegen --version` -> `Version: 2.45.4`.
- `xcodegen generate` -> passed.
- MCP `test_sim` focused on
  `CoreRuntimeCanonicalOwnershipTests`,
  `PrivateLifeRuntimeKernelOwnershipTests`, and `ProjectionEngineTests` timed
  out after 300 seconds before result proof.
- First shell `xcodebuild` focused test attempt wrote
  `artifacts/amb-1714/results/focused-runtime-ownership.xcresult` and failed
  before selected test assertions ran with:
  `Failed to establish communication with the test runner. (Underlying Error: Channel disconnected)`.
- Warm shell retry with `-parallel-testing-enabled NO` wrote
  `artifacts/amb-1714/results/focused-runtime-ownership-retry.xcresult` and
  passed: `11` selected tests, `0` failures.
- `git diff --check` -> clean.
- `find Native/Ambitions/Core/Runtime -maxdepth 1 -name '*.swift' | wc -l`
  -> `112`.

Validation not run:

- Full test suite.
- Physical device runtime proof.
- Accessibility, performance, privacy/legal, TestFlight, App Store, or release
  readiness proof.

## Claim Ceiling

Final Architecture Tree inspected: yes.

Canonical owners touched:

- `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`
- `Core/LocalRuntimeOS/ProjectionEngine`
- Legacy owner retired for three files: `Core/Runtime`

Files moved or created:

- Moved `PrivateLifeRuntime.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/PrivateLifeRuntimeKernel`.
- Moved `RuntimeProjectionPipeline.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/ProjectionEngine`.
- Moved `RuntimeSnapshot.swift` from `Core/Runtime` to
  `Core/LocalRuntimeOS/ProjectionEngine`.
- Created this audit overlay.

Old/non-canonical paths removed:

- `Native/Ambitions/Core/Runtime/PrivateLifeRuntime.swift`
- `Native/Ambitions/Core/Runtime/RuntimeProjectionPipeline.swift`
- `Native/Ambitions/Core/Runtime/RuntimeSnapshot.swift`

Compatibility shims left behind by this slice: none.

Yellow architecture debt remains because `112` legacy runtime files still exist,
including adapter shims, test-only support, and the unresolved
`RuntimePackageBoundaryModels.swift` owner decision. Next repair trains:
AMB-1715, AMB-1716, and AMB-1667 children for unsafe write/persistence authority.

No equivalent-folder or close-enough path interpretation was used.
