# Champion Merge Goals

Batch: `AMB-CHAMPION-MERGE-GOALS-01`

Status: YELLOW

Concept: Goals / GoalThread / Ambition / LifeArea / Constellation Atlas / proof relationship consolidation

Canonical owner before: `goals_root`

Canonical owner after: `goals_root`

Competing implementations:
- Existing goal/life-area projections in `Native/Ambitions/Features/Goals/**`
- Canonical GoalThread / commitment / proof graph helpers in `Native/Ambitions/Domain/AmbitionGraphModels.swift`

Better fragments rescued:
- `LifeGraphResolver.pathStateSummary`
- `LifeAreaAtlasProjector`
- Goals overview Life Area projection and proof summary plumbing
- Canonical GoalThread hierarchy and reference ordering helpers

Active code changed:
- `Native/Ambitions/Domain/AmbitionGraphModels.swift`
- `Native/Ambitions/Domain/LifeAreaModels.swift`
- `Native/Ambitions/Services/LifeAreaAtlasProjector.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/AmbitionsTests/Domain/AmbitionGraphModelsTests.swift`
- `Native/AmbitionsTests/Services/LifeAreaAtlasProjectorTests.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`

Runtime wires:
- `AmbitionGraphSnapshot` now carries `goalThreads` and can project a canonical GoalThread hierarchy.
- `GoalThread` now carries an optional `lifeAreaID` so the thread can align back to its Life Area.
- `LifeAreaAtlasProjector` can accept synthetic GoalThread hierarchies and preserve thread, step, commitment, proof, and receipt references.
- `GoalsLifeAreaItemState` now surfaces `goalThreadSummary`, `goalThreadCount`, `proofCount`, and `receiptCount`.
- `RepositoryBackedGoalsService.loadSnapshot` now builds canonical `AmbitionGraphGoalThreadHierarchy` adapters for active goals.
- `RepositoryBackedGoalsService.makeLifeAreasState` passes those hierarchies into `LifeAreaAtlasProjector` and derives visible Goals Life Area summaries from the canonical relationship hooks.

SourceRecord:
- Preserved existing source-proof boundaries; no new source-recording runtime was introduced.

Receipt:
- Preserved existing proof/receipt behavior in the domain graph helpers and projector hooks.

ReplayTrace:
- Preserved existing replay-trace boundaries; no replay-trace behavior was removed or replaced.

You inspection:
- No You/Profile surface changed in this batch.

Reset/delete:
- No deletion or retirement was performed in this batch.

Tests run:
- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-GOALS-01`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-GOALS-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-GOALS-01.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-CHAMPION-MERGE-GOALS-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-GOALS-01.md --changed-from 115cd3b86234dcfb2a117082953a0688fa9b6fdb`
- `python3 -m py_compile scripts/ambitions-parallel-implementation-guard.py`
- `git diff --check`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-GOALS-01 TEST=AmbitionsTests/Domain/AmbitionGraphModelsTests`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-GOALS-01 TEST=AmbitionsTests/Services/LifeAreaAtlasProjectorTests`
- `make xcode-focused-test BATCH=AMB-CHAMPION-MERGE-GOALS-01 TEST=AmbitionsTests/Goals/GoalsOverviewBoardTests`

Validation results:
- Champion coverage: Green.
- Parallel guard pre: Green.
- Parallel guard post: Green after repairing owner-scoped helper classification and limiting old-term source scanning to active source paths.
- Python compile for the guard: passed.
- Diff whitespace check: passed.
- `AmbitionsTests/Domain/AmbitionGraphModelsTests`: passed before Xcode first-launch/update blocking appeared.
- `AmbitionsTests/Services/LifeAreaAtlasProjectorTests`: previously passed before repair; post-repair rerun was blocked by Xcode/simulator bootstrap instability.
- `AmbitionsTests/Goals/GoalsOverviewBoardTests`: previously passed before repair; post-repair rerun was terminated after the wrapper became stuck behind Xcode first-launch/simulator diagnostics.
- Xcode follow-up: rerun the two blocked focused lanes after the macOS/Xcode update completes.

Proof artifact:
- `build/reports/intelligence-consolidation/champion-merge-goals.md`
- `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-GOALS-01-pre.md`
- `build/reports/parallel-implementation-guard/AMB-CHAMPION-MERGE-GOALS-01-post.md`

Supersession ledger update:
- Not updated. This batch merged GoalThread relationship fragments into the existing Goals owner and did not retire a duplicate source path.

Best-code rescue ledger update:
- Not updated. The batch only rescued the GoalThread / proof relationship fragments into the existing Goals and Life Area seams.

Concept lock update:
- Not updated. The batch did not close duplicate goal-model retirement.

Duplicates remaining:
- Existing historical duplicates remain in the wider repo; this batch did not add a new duplicated owner.

Retirement candidates:
- Duplicate goal-model retirement stays future work.

Yellow/Red items:
- Yellow: Xcode validation is blocked until the macOS/Xcode update and first-launch state settle.
- Green: champion coverage, pre guard, post guard, Python compile, and diff check.

Claims allowed:
- The domain now exposes a canonical GoalThread hierarchy projection.
- Life Area projection can consume thread, step, commitment, proof, and receipt references.
- Goals overview now consumes canonical GoalThread hierarchy hooks for Life Area summaries and proof counts.

Claims forbidden:
- No claim of full duplicate-goal retirement.
- No claim that all focused Xcode lanes passed after the repair.
- No claim that unrelated dirty control-plane files were repaired.
