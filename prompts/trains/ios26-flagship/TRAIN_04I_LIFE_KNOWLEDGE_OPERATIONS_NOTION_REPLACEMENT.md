<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04I - Life Knowledge Operations / Notion Replacement

## Purpose
Build the local-first personal knowledge foundation that replaces personal Notion jobs without creating a Notion clone.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04I-B01-context-entry-collection-template-models.md
- IOS26-T04I-B02-attachments-links-and-source-records.md
- IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md
- IOS26-T04I-B04-local-knowledge-search-and-filters.md
- IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md
- IOS26-T04I-B06-notion-replacement-gauntlet.md

## Proof root
`build/reports/life-knowledge-operations/`

## Train closeout
`build/reports/life-knowledge-operations/TRAIN_04I_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/life-knowledge-operations/`.
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
scripts/ambitions-codex-train.sh IOS26-T04I-B01 prompts/batches/IOS26-T04I-B01-context-entry-collection-template-models.md
scripts/ambitions-codex-train.sh IOS26-T04I-B02 prompts/batches/IOS26-T04I-B02-attachments-links-and-source-records.md
scripts/ambitions-codex-train.sh IOS26-T04I-B03 prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md
scripts/ambitions-codex-train.sh IOS26-T04I-B04 prompts/batches/IOS26-T04I-B04-local-knowledge-search-and-filters.md
scripts/ambitions-codex-train.sh IOS26-T04I-B05 prompts/batches/IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md
scripts/ambitions-codex-train.sh IOS26-T04I-B06 prompts/batches/IOS26-T04I-B06-notion-replacement-gauntlet.md
```

## Batch summaries
- IOS26-T04I-B01: `prompts/batches/IOS26-T04I-B01-context-entry-collection-template-models.md` - Context entry collection template models
- IOS26-T04I-B02: `prompts/batches/IOS26-T04I-B02-attachments-links-and-source-records.md` - Attachments links and source records
- IOS26-T04I-B03: `prompts/batches/IOS26-T04I-B03-relations-backlinks-and-life-knowledge-graph.md` - Relations backlinks and life knowledge graph
- IOS26-T04I-B04: `prompts/batches/IOS26-T04I-B04-local-knowledge-search-and-filters.md` - Local knowledge search and filters
- IOS26-T04I-B05: `prompts/batches/IOS26-T04I-B05-knowledge-to-runtime-source-bridge.md` - Knowledge to runtime source bridge
- IOS26-T04I-B06: `prompts/batches/IOS26-T04I-B06-notion-replacement-gauntlet.md` - Notion replacement gauntlet

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
