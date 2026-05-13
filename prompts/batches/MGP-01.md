<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MGP-01 - Monetization

## Batch ID

MGP-01

## Runner command

```bash
scripts/ambitions-codex-train.sh MGP-01 prompts/batches/MGP-01.md
```

Equivalent:

```bash
make batch BATCH=MGP-01 PROMPT=prompts/batches/MGP-01.md
```

## Objective

Implement MGP-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/LSF-01.md` before coding.

## Allowed scope

Free/Core/Cloud tier gates, entitlement boundaries, purchase/feature-gate fixtures, and focused entitlement tests.

## Forbidden scope

Paywalling trust controls, correction/export/delete/privacy/accessibility controls, hidden lock-in, or release/readiness claims.

## Validation expectations

Run entitlement tests named by the train manifest and any relevant feature-gate tests. Record commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on trust-control paywalling, hidden lock-in, entitlement bypass, or missing proof for changed UI.

## Rollback expectations

Revert only MGP-01-owned files.

## Final report expectations

Create `docs/audits/mgp-01-batch-closeout-report.md`.
