<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# SCI-01 - Confidence Scoring

## Batch ID

SCI-01

## Runner command

```bash
scripts/ambitions-codex-train.sh SCI-01 prompts/batches/SCI-01.md
```

Equivalent:

```bash
make batch BATCH=SCI-01 PROMPT=prompts/batches/SCI-01.md
```

## Objective

Implement SCI-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/HBI-08.md` before coding.

## Allowed scope

Confidence bands, deterministic scoring, source authority inputs, explanation fields, focused fixtures, and tests.

## Forbidden scope

Hidden scoring, fake precision in normal UI, cloud-only judgment, review-state bypass, or release/readiness claims.

## Validation expectations

Run the confidence tests named by the train manifest and any related source/claim tests. Record true commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on hidden scoring, cloud dependency, provenance loss, or review-gating bypass.

## Rollback expectations

Revert only SCI-01-owned files.

## Final report expectations

Create `docs/audits/sci-01-batch-closeout-report.md`.
