<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PRI-01 - Runtime Inspection

## Batch ID

PRI-01

## Runner command

```bash
scripts/ambitions-codex-train.sh PRI-01 prompts/batches/PRI-01.md
```

Equivalent:

```bash
make batch BATCH=PRI-01 PROMPT=prompts/batches/PRI-01.md
```

## Objective

Implement PRI-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/HBI-10.md` before coding.

## Allowed scope

Batch-owned inspection receipt model/surface, source influence summary, comprehension fixtures, focused tests, and UI proof if user-facing UI changes.

## Forbidden scope

Noisy internals, hidden influence, source/proof loss, cloud-only runtime dependency, or release/readiness claims.

## Validation expectations

Run the comprehension fixtures and inspection tests named by the train manifest. Record true commands and exit codes.

## Visual proof expectations

Required for user-facing UI changes.

## Hard Red stop conditions

Stop on source influence opacity, provenance loss, review bypass, or missing visual proof for UI changes.

## Rollback expectations

Revert only PRI-01-owned files.

## Final report expectations

Create `docs/audits/pri-01-batch-closeout-report.md`.
