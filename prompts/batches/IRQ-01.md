<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# IRQ-01 - Review Queue Model

## Batch ID

IRQ-01

## Runner command

```bash
scripts/ambitions-codex-train.sh IRQ-01 prompts/batches/IRQ-01.md
```

Equivalent:

```bash
make batch BATCH=IRQ-01 PROMPT=prompts/batches/IRQ-01.md
```

## Objective

Implement IRQ-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/SCI-03.md` before coding.

## Allowed scope

Review queue model, buckets, actions, state transitions, fixtures, and queue tests.

## Forbidden scope

Bulk acceptance of protected/high-risk claims, review bypass, source provenance loss, UI sprawl, or release/readiness claims.

## Validation expectations

Run the queue tests named by the train manifest and any related source/claim tests. Record true commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on review bypass, provenance loss, bulk sensitive acceptance, queue state corruption, or cloud dependency.

## Rollback expectations

Revert only IRQ-01-owned files.

## Final report expectations

Create `docs/audits/irq-01-batch-closeout-report.md`.
