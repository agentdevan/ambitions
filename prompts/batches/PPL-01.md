<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PPL-01 - Export

## Batch ID

PPL-01

## Runner command

```bash
scripts/ambitions-codex-train.sh PPL-01 prompts/batches/PPL-01.md
```

Equivalent:

```bash
make batch BATCH=PPL-01 PROMPT=prompts/batches/PPL-01.md
```

## Objective

Implement PPL-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/RHE-01.md` before coding.

## Allowed scope

Portable JSON schema, export bundle, round-trip fixtures, focused export tests, and user-data readability boundaries.

## Forbidden scope

Proprietary-only export, paywalling trust controls, source/proof loss, irreversible mutation, or release/readiness claims.

## Validation expectations

Run the round-trip tests named by the train manifest and any relevant source/storage tests. Record commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on proprietary-only format, source/proof loss, hidden retained records, or trust-control paywalling.

## Rollback expectations

Revert only PPL-01-owned files.

## Final report expectations

Create `docs/audits/ppl-01-batch-closeout-report.md`.
