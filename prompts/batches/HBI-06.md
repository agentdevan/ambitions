<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-06 - Selected Media Import

## Batch ID

HBI-06

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-06 prompts/batches/HBI-06.md
```

Equivalent:

```bash
make batch BATCH=HBI-06 PROMPT=prompts/batches/HBI-06.md
```

## Objective

Implement HBI-06 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/HBI-05.md` before coding.

## Allowed scope

Use only selected-user-input media boundaries, local extraction, evidence/source records, fixtures, and focused tests needed for HBI-06.

## Forbidden scope

No broad library default, background indexing, cloud extraction, direct active-goal creation, or release/readiness claims.

## Validation expectations

Run the focused tests named by the train manifest and any relevant privacy/source tests. Record true commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on broad-library default, background indexing, cloud dependency, review-gating bypass, or active-goal creation from imports.

## Rollback expectations

Revert only HBI-06-owned files.

## Final report expectations

Create `docs/audits/hbi-06-batch-closeout-report.md`.
