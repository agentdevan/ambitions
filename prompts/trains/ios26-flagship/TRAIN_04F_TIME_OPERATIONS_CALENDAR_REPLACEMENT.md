<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04F - Time Operations / Calendar Replacement

## Purpose
Build the local-first Time Operations foundation that replaces Calendar jobs without making Time a calendar clone.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04F-B01-local-schedule-models-and-repositories.md
- IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md
- IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md
- IOS26-T04F-B04-conflict-pressure-protected-time-engine.md
- IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md
- IOS26-T04F-B06-calendar-replacement-gauntlet.md

## Proof root
`build/reports/time-operations/`

## Train closeout
`build/reports/time-operations/TRAIN_04F_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/time-operations/`.
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
scripts/ambitions-codex-train.sh IOS26-T04F-B01 prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md
scripts/ambitions-codex-train.sh IOS26-T04F-B02 prompts/batches/IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md
scripts/ambitions-codex-train.sh IOS26-T04F-B03 prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md
scripts/ambitions-codex-train.sh IOS26-T04F-B04 prompts/batches/IOS26-T04F-B04-conflict-pressure-protected-time-engine.md
scripts/ambitions-codex-train.sh IOS26-T04F-B05 prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md
scripts/ambitions-codex-train.sh IOS26-T04F-B06 prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md
```

## Batch summaries
- IOS26-T04F-B01: `prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md` - Local schedule models and repositories
- IOS26-T04F-B02: `prompts/batches/IOS26-T04F-B02-eventkit-mirror-and-permission-boundary.md` - EventKit mirror and permission boundary
- IOS26-T04F-B03: `prompts/batches/IOS26-T04F-B03-recurrence-availability-and-free-time-engine.md` - Recurrence availability and free-time engine
- IOS26-T04F-B04: `prompts/batches/IOS26-T04F-B04-conflict-pressure-protected-time-engine.md` - Conflict pressure and protected-time engine
- IOS26-T04F-B05: `prompts/batches/IOS26-T04F-B05-schedule-mutation-receipts-and-replay.md` - Schedule mutation receipts and replay
- IOS26-T04F-B06: `prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md` - Calendar replacement gauntlet

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
