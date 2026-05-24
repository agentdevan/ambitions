<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04H - Project Step Operations / Todoist Things Replacement

## Purpose
Build the local-first project/task/area/view foundation that replaces Todoist and Things 3 jobs through Ambitions-native GoalThreads, Commitments, Steps, Life Areas, SavedViews, closure, and Today/Upcoming/Open/Held execution.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md
- IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md
- IOS26-T04H-B03-labels-filters-and-saved-views.md
- IOS26-T04H-B04-today-upcoming-open-held-view-engine.md
- IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md
- IOS26-T04H-B06-project-step-closure-proof-replay.md
- IOS26-T04H-B07-todoist-things-replacement-gauntlet.md

## Proof root
`build/reports/project-step-operations/`

## Train closeout
`build/reports/project-step-operations/TRAIN_04H_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/project-step-operations/`.
- Downstream broad claims remain blocked unless all required P0 gates are Green or accepted Yellow with explicit no-claim boundary.

## Claims forbidden
- Calendar replacement is implemented unless T04F is Green.
- Reminders replacement is implemented unless T04G is Green.
- Todoist replacement is implemented unless T04H is Green.
- Things 3 replacement is implemented unless T04H is Green.
- Notion replacement is implemented unless T04I is Green.
- Ambitions replaces productivity apps unless all replacement P0 and runtime gauntlets are Green.
- Release-ready or App Store-ready.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T04H-B01 prompts/batches/IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md
scripts/ambitions-codex-train.sh IOS26-T04H-B02 prompts/batches/IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md
scripts/ambitions-codex-train.sh IOS26-T04H-B03 prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md
scripts/ambitions-codex-train.sh IOS26-T04H-B04 prompts/batches/IOS26-T04H-B04-today-upcoming-open-held-view-engine.md
scripts/ambitions-codex-train.sh IOS26-T04H-B05 prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md
scripts/ambitions-codex-train.sh IOS26-T04H-B06 prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md
scripts/ambitions-codex-train.sh IOS26-T04H-B07 prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md
```

## Batch summaries
- IOS26-T04H-B01: `prompts/batches/IOS26-T04H-B01-goal-thread-project-commitment-hierarchy.md` - GoalThread project commitment hierarchy
- IOS26-T04H-B02: `prompts/batches/IOS26-T04H-B02-step-dependencies-deadlines-priority-without-scores.md` - Step dependencies deadlines priority without scores
- IOS26-T04H-B03: `prompts/batches/IOS26-T04H-B03-labels-filters-and-saved-views.md` - Labels filters and saved views
- IOS26-T04H-B04: `prompts/batches/IOS26-T04H-B04-today-upcoming-open-held-view-engine.md` - Today Upcoming Open Held view engine
- IOS26-T04H-B05: `prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md` - Bulk operations and low-friction planning
- IOS26-T04H-B06: `prompts/batches/IOS26-T04H-B06-project-step-closure-proof-replay.md` - Project step closure proof replay
- IOS26-T04H-B07: `prompts/batches/IOS26-T04H-B07-todoist-things-replacement-gauntlet.md` - Todoist Things replacement gauntlet

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
