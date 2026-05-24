<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04E - Core Replacement Contract Harness

## Purpose
Install executable/testable P0 contract harnesses for replacing Calendar, Reminders, Todoist, Things 3, and Notion before building replacement implementation trains.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04E-B01-calendar-p0-contract-harness.md
- IOS26-T04E-B02-reminders-p0-contract-harness.md
- IOS26-T04E-B03-todoist-p0-contract-harness.md
- IOS26-T04E-B04-things-p0-contract-harness.md
- IOS26-T04E-B05-notion-p0-contract-harness.md
- IOS26-T04E-B06-cross-app-journey-contract-harness.md
- IOS26-T04E-B07-contract-closeout-and-downstream-gates.md

## Proof root
`build/reports/core-replacement-contracts/`

## Train closeout
`build/reports/core-replacement-contracts/TRAIN_04E_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/core-replacement-contracts/`.
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
scripts/ambitions-codex-train.sh IOS26-T04E-B01 prompts/batches/IOS26-T04E-B01-calendar-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B02 prompts/batches/IOS26-T04E-B02-reminders-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B03 prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B04 prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B05 prompts/batches/IOS26-T04E-B05-notion-p0-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B06 prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md
scripts/ambitions-codex-train.sh IOS26-T04E-B07 prompts/batches/IOS26-T04E-B07-contract-closeout-and-downstream-gates.md
```

## Batch summaries
- IOS26-T04E-B01: `prompts/batches/IOS26-T04E-B01-calendar-p0-contract-harness.md` - Calendar replacement contract harness
- IOS26-T04E-B02: `prompts/batches/IOS26-T04E-B02-reminders-p0-contract-harness.md` - Reminders replacement contract harness
- IOS26-T04E-B03: `prompts/batches/IOS26-T04E-B03-todoist-p0-contract-harness.md` - Todoist replacement contract harness
- IOS26-T04E-B04: `prompts/batches/IOS26-T04E-B04-things-p0-contract-harness.md` - Things 3 replacement contract harness
- IOS26-T04E-B05: `prompts/batches/IOS26-T04E-B05-notion-p0-contract-harness.md` - Notion replacement contract harness
- IOS26-T04E-B06: `prompts/batches/IOS26-T04E-B06-cross-app-journey-contract-harness.md` - Cross-app journey contract harness
- IOS26-T04E-B07: `prompts/batches/IOS26-T04E-B07-contract-closeout-and-downstream-gates.md` - Contract closeout and downstream gates

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
