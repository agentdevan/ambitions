<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PPL-02 - Delete/Restore

## Batch ID

PPL-02

## Runner command

```bash
scripts/ambitions-codex-train.sh PPL-02 prompts/batches/PPL-02.md
```

Equivalent:

```bash
make batch BATCH=PPL-02 PROMPT=prompts/batches/PPL-02.md
```

## Objective

Implement PPL-02 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/PPL-01.md` before coding.

## Allowed scope

Delete receipts, restore drill, restore fixtures, focused restore tests, and rollback evidence.

## Forbidden scope

Irreversible silent delete, hidden retained state, paywalling trust controls, source/proof loss, or release/readiness claims.

## Validation expectations

Run the restore tests named by the train manifest and any relevant source/storage tests. Record commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on irreversible mutation, missing deletion receipt, restore mismatch, hidden retained state, or trust-control paywalling.

## Rollback expectations

Revert only PPL-02-owned files.

## Final report expectations

Create `docs/audits/ppl-02-batch-closeout-report.md`.
