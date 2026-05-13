<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-10 - Historical Baseline Map

## Batch ID

HBI-10

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-10 prompts/batches/HBI-10.md
```

Equivalent:

```bash
make batch BATCH=HBI-10 PROMPT=prompts/batches/HBI-10.md
```

## Objective

Implement HBI-10 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/HBI-09.md` before coding.

## Allowed scope

Batch-owned map layer, delta summary, fixtures, focused tests, and visual acceptance as specified by the manifest.

## Forbidden scope

Generic dashboard, static profile clone, source/proof loss, review bypass, or release/readiness claims.

## Validation expectations

Run the tests and Visual QA named by the train manifest. Record true commands and exit codes.

## Visual proof expectations

Required for user-facing UI changes.

## Hard Red stop conditions

Stop on generic dashboard drift, review bypass, provenance loss, or missing visual proof for UI changes.

## Rollback expectations

Revert only HBI-10-owned files.

## Final report expectations

Create `docs/audits/hbi-10-batch-closeout-report.md`.
