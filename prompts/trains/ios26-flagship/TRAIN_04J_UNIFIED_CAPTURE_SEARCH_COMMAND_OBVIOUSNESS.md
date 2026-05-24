<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_04J - Unified Capture Search Command and Obviousness

## Purpose
Make Ambitions obvious and fast enough for a user to operate life from one app.

## Train objective
Create the source, test, proof, and claim-boundary foundation described by this train. This prompt is implementation-ready for runner execution but does not prove implementation by being installed.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`. This train status is `installed_not_run` until runner closeout proof exists.

## Batch list
- IOS26-T04J-B01-universal-quick-capture-router.md
- IOS26-T04J-B02-object-action-engine.md
- IOS26-T04J-B03-everything-search.md
- IOS26-T04J-B04-native-command-surface-without-chat.md
- IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md
- IOS26-T04J-B06-command-search-obviousness-gauntlet.md

## Proof root
`build/reports/life-command-search/`

## Train closeout
`build/reports/life-command-search/TRAIN_04J_CLOSEOUT.md`

## Claims allowed only if Green
- The scoped train contract has been implemented or installed exactly as the batch prompts require.
- Current proof artifacts exist under `build/reports/life-command-search/`.
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
scripts/ambitions-codex-train.sh IOS26-T04J-B01 prompts/batches/IOS26-T04J-B01-universal-quick-capture-router.md
scripts/ambitions-codex-train.sh IOS26-T04J-B02 prompts/batches/IOS26-T04J-B02-object-action-engine.md
scripts/ambitions-codex-train.sh IOS26-T04J-B03 prompts/batches/IOS26-T04J-B03-everything-search.md
scripts/ambitions-codex-train.sh IOS26-T04J-B04 prompts/batches/IOS26-T04J-B04-native-command-surface-without-chat.md
scripts/ambitions-codex-train.sh IOS26-T04J-B05 prompts/batches/IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md
scripts/ambitions-codex-train.sh IOS26-T04J-B06 prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md
```

## Batch summaries
- IOS26-T04J-B01: `prompts/batches/IOS26-T04J-B01-universal-quick-capture-router.md` - Universal quick capture router
- IOS26-T04J-B02: `prompts/batches/IOS26-T04J-B02-object-action-engine.md` - Object action engine
- IOS26-T04J-B03: `prompts/batches/IOS26-T04J-B03-everything-search.md` - Everything search
- IOS26-T04J-B04: `prompts/batches/IOS26-T04J-B04-native-command-surface-without-chat.md` - Native command surface without chat
- IOS26-T04J-B05: `prompts/batches/IOS26-T04J-B05-onboarding-empty-states-and-obviousness.md` - Onboarding empty states and obviousness
- IOS26-T04J-B06: `prompts/batches/IOS26-T04J-B06-command-search-obviousness-gauntlet.md` - Command search obviousness gauntlet

## Red/Yellow/Green closeout rules
Green requires current evidence from the batch prompts. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only files touched by this train. Preserve unrelated dirty work.

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
