<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_12 — Widgets, Live Activities, App Intents, share extension

## Objective
Install and run the `Widgets, Live Activities, App Intents, share extension` train only through the Ambitions runner when dependencies are satisfied.

## Why it exists
This train matures Ambitions toward an iOS 26-minimum flagship native iPhone app while preserving truth-file authority, local-first architecture, and proof honesty.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Batch list
- IOS26-T12-B01
- IOS26-T12-B02
- IOS26-T12-B03

## Source scope
See the exact source areas in each mapped batch prompt.

## Core Replacement Foundation Gate
- External surfaces must operate on foundation objects, not bespoke shortcut-only models.
- App Intents should support core life jobs where repo-compatible: Capture, Add reminder, Add scheduled block, Add proof, Start here, Search/open object.

## Validation gates
Runner metadata, dependency proof, command logs, Green/Yellow/Red closeout, and post-batch gates for accepted Yellow.

## Proof artifacts
Use the proof roots in the manifest and the specific batch prompt.

## Red/Yellow/Green closeout rules
Green requires evidence. Yellow requires owner, reason, no-claim boundary, and gate. Red stops.

## Rollback strategy
Rollback only touched files. Preserve unrelated dirty work.

## Sequential commands for that train
```bash
scripts/ambitions-codex-train.sh IOS26-T12-B01 prompts/batches/IOS26-T12-B01-widget-live-activity-modernization.md
scripts/ambitions-codex-train.sh IOS26-T12-B02 prompts/batches/IOS26-T12-B02-app-intents-shortcuts-cleanup.md
scripts/ambitions-codex-train.sh IOS26-T12-B03 prompts/batches/IOS26-T12-B03-share-extension-hardening.md
```

## Batch summaries
- IOS26-T12-B01: `prompts/batches/IOS26-T12-B01-widget-live-activity-modernization.md`
- IOS26-T12-B02: `prompts/batches/IOS26-T12-B02-app-intents-shortcuts-cleanup.md`
- IOS26-T12-B03: `prompts/batches/IOS26-T12-B03-share-extension-hardening.md`

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
