<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# RHE-01 - Recommendation Humility

## Batch ID

RHE-01

## Runner command

```bash
scripts/ambitions-codex-train.sh RHE-01 prompts/batches/RHE-01.md
```

Equivalent:

```bash
make batch BATCH=RHE-01 PROMPT=prompts/batches/RHE-01.md
```

## Objective

Implement RHE-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/PRI-01.md` before coding.

## Allowed scope

Recommendation-weight rules, confidence copy, focused fixtures, red-team tests, and integration gates named by the manifest.

## Forbidden scope

False certainty, hidden influence, review bypass, source/proof loss, or release/readiness claims.

## Validation expectations

Run tests named by the train manifest and any relevant source/recommendation tests. Record commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on false certainty, hidden influence, review bypass, source/proof loss, or missing visual proof for UI changes.

## Rollback expectations

Revert only RHE-01-owned files.

## Final report expectations

Create `docs/audits/rhe-01-batch-closeout-report.md`.
