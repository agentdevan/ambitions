<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# TRAIN_16 — Release proof, App Store readiness, final validation

## Objective
Install and run the `Release proof, App Store readiness, final validation` train only through the Ambitions runner when dependencies are satisfied.

## Why it exists
This train matures Ambitions toward an iOS 26-minimum flagship native iPhone app while preserving truth-file authority, local-first architecture, and proof honesty.

## Dependencies
See `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

## Batch list
- IOS26-T16-B01
- IOS26-T16-B02
- IOS26-T16-B03

## Source scope
See the exact source areas in each mapped batch prompt.

## Core Replacement Foundation Gate
- No release/App Store claim until replacement foundation proof and Private Life Runtime integration proof exist.

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
scripts/ambitions-codex-train.sh IOS26-T16-B01 prompts/batches/IOS26-T16-B01-full-local-validation-packet.md
scripts/ambitions-codex-train.sh IOS26-T16-B02 prompts/batches/IOS26-T16-B02-privacy-app-store-packet.md
scripts/ambitions-codex-train.sh IOS26-T16-B03 prompts/batches/IOS26-T16-B03-signed-archive-testflight-gate.md
```

## Batch summaries
- IOS26-T16-B01: `prompts/batches/IOS26-T16-B01-full-local-validation-packet.md`
- IOS26-T16-B02: `prompts/batches/IOS26-T16-B02-privacy-app-store-packet.md`
- IOS26-T16-B03: `prompts/batches/IOS26-T16-B03-signed-archive-testflight-gate.md`

## Post-batch gates
Record accepted Yellow gates in `docs/codex/POST_BATCH_GATE_REGISTRY.md`.
