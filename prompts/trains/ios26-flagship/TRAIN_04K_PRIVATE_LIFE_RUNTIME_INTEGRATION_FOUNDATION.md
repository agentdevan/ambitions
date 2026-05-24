<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04K - Private Life Runtime Integration Over Replacement Foundation

## Purpose
Use the proven replacement foundation as the substrate for the Private Life Runtime moat.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04K-B01-foundation-source-adapters.md
- IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md
- IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md
- IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md
- IOS26-T04K-B05-start-here-decision-contract-for-t05.md
- IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md
- IOS26-T04K-B07-foundation-and-moat-closeout.md

## Proof root
`build/reports/private-life-runtime-integration/`

## Train closeout
`build/reports/private-life-runtime-integration/TRAIN_04K_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/private-life-runtime-integration/`.
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
scripts/ambitions-codex-train.sh IOS26-T04K-B01 prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md
scripts/ambitions-codex-train.sh IOS26-T04K-B02 prompts/batches/IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md
scripts/ambitions-codex-train.sh IOS26-T04K-B03 prompts/batches/IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md
scripts/ambitions-codex-train.sh IOS26-T04K-B04 prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md
scripts/ambitions-codex-train.sh IOS26-T04K-B05 prompts/batches/IOS26-T04K-B05-start-here-decision-contract-for-t05.md
scripts/ambitions-codex-train.sh IOS26-T04K-B06 prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md
scripts/ambitions-codex-train.sh IOS26-T04K-B07 prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md
```

## Batch summaries
- IOS26-T04K-B01: `prompts/batches/IOS26-T04K-B01-foundation-source-adapters.md` - Foundation source adapters
- IOS26-T04K-B02: `prompts/batches/IOS26-T04K-B02-multi-path-execution-compiler-over-real-life-objects.md` - Multi-path execution compiler over real life objects
- IOS26-T04K-B03: `prompts/batches/IOS26-T04K-B03-accomplishment-proof-adaptation-engine.md` - Accomplishment proof adaptation engine
- IOS26-T04K-B04: `prompts/batches/IOS26-T04K-B04-personal-operating-model-and-what-ambitions-knows.md` - Personal operating model and What Ambitions knows
- IOS26-T04K-B05: `prompts/batches/IOS26-T04K-B05-start-here-decision-contract-for-t05.md` - Start Here decision contract for T05
- IOS26-T04K-B06: `prompts/batches/IOS26-T04K-B06-cross-surface-private-life-runtime-gauntlet.md` - Cross-surface Private Life Runtime gauntlet
- IOS26-T04K-B07: `prompts/batches/IOS26-T04K-B07-foundation-and-moat-closeout.md` - Foundation and moat closeout

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
