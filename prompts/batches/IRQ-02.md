<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# IRQ-02 - Review Queue UI

## Batch ID

IRQ-02

## Runner command

```bash
scripts/ambitions-codex-train.sh IRQ-02 prompts/batches/IRQ-02.md
```

Equivalent:

```bash
make batch BATCH=IRQ-02 PROMPT=prompts/batches/IRQ-02.md
```

## Objective

Implement IRQ-02 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/IRQ-01.md` before coding.

## Allowed scope

Review cards, correction fold, review UI fixtures, focused UI tests, screenshots, and accessibility notes where UI changes.

## Forbidden scope

Long intake forms, generic dashboard UI, bulk risky acceptance, review bypass, source provenance loss, or release/readiness claims.

## Validation expectations

Run UI-focused tests and produce screenshot proof for touched surfaces. Record true commands and exit codes.

## Visual proof expectations

Required for every user-facing UI change.

## Hard Red stop conditions

Stop on review bypass, long-form drift, provenance loss, unreviewed promotion, or visual proof absence for UI changes.

## Rollback expectations

Revert only IRQ-02-owned files.

## Final report expectations

Create `docs/audits/irq-02-batch-closeout-report.md`.
