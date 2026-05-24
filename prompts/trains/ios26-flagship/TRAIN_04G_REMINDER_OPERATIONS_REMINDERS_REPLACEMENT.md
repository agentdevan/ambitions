<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04G - Reminder Operations / Reminders Replacement

## Purpose
Build the local-first reminder/trigger system that replaces Reminders jobs through Commitments, Steps, triggers, closure, receipts, and replay.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04G-B01-reminder-trigger-models-and-repositories.md
- IOS26-T04G-B02-local-notification-scheduling-abstraction.md
- IOS26-T04G-B03-natural-reminder-capture-parser.md
- IOS26-T04G-B04-recurring-reminders-and-followups.md
- IOS26-T04G-B05-reminder-closure-recovery-receipts.md
- IOS26-T04G-B06-reminders-replacement-gauntlet.md

## Proof root
`build/reports/reminder-operations/`

## Train closeout
`build/reports/reminder-operations/TRAIN_04G_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/reminder-operations/`.
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
scripts/ambitions-codex-train.sh IOS26-T04G-B01 prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md
scripts/ambitions-codex-train.sh IOS26-T04G-B02 prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md
scripts/ambitions-codex-train.sh IOS26-T04G-B03 prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md
scripts/ambitions-codex-train.sh IOS26-T04G-B04 prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md
scripts/ambitions-codex-train.sh IOS26-T04G-B05 prompts/batches/IOS26-T04G-B05-reminder-closure-recovery-receipts.md
scripts/ambitions-codex-train.sh IOS26-T04G-B06 prompts/batches/IOS26-T04G-B06-reminders-replacement-gauntlet.md
```

## Batch summaries
- IOS26-T04G-B01: `prompts/batches/IOS26-T04G-B01-reminder-trigger-models-and-repositories.md` - Reminder trigger models and repositories
- IOS26-T04G-B02: `prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md` - Local notification scheduling abstraction
- IOS26-T04G-B03: `prompts/batches/IOS26-T04G-B03-natural-reminder-capture-parser.md` - Natural reminder capture parser
- IOS26-T04G-B04: `prompts/batches/IOS26-T04G-B04-recurring-reminders-and-followups.md` - Recurring reminders and followups
- IOS26-T04G-B05: `prompts/batches/IOS26-T04G-B05-reminder-closure-recovery-receipts.md` - Reminder closure recovery receipts
- IOS26-T04G-B06: `prompts/batches/IOS26-T04G-B06-reminders-replacement-gauntlet.md` - Reminders replacement gauntlet

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
