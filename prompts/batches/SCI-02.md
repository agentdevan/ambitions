<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# SCI-02 - Staleness

## Batch ID

SCI-02

## Runner command

```bash
scripts/ambitions-codex-train.sh SCI-02 prompts/batches/SCI-02.md
```

Equivalent:

```bash
make batch BATCH=SCI-02 PROMPT=prompts/batches/SCI-02.md
```

## Objective

Implement SCI-02 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/SCI-01.md` before coding.

## Allowed scope

Freshness policy by source/domain, stale downgrade rules, related fixtures, and focused tests.

## Forbidden scope

Permanent stale influence, silent freshness promotion, source provenance loss, cloud-only judgment, or release/readiness claims.

## Validation expectations

Run the stale-source tests named by the train manifest and any related source/claim tests. Record true commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on permanent stale influence, review-gating bypass, hidden source promotion, or cloud dependency.

## Rollback expectations

Revert only SCI-02-owned files.

## Final report expectations

Create `docs/audits/sci-02-batch-closeout-report.md`.
