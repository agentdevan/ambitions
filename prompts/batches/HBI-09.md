<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-09 - Current State Snapshot

## Batch ID

HBI-09

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-09 prompts/batches/HBI-09.md
```

Equivalent:

```bash
make batch BATCH=HBI-09 PROMPT=prompts/batches/HBI-09.md
```

## Objective

Implement HBI-09 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/IRQ-02.md` before coding.

## Allowed scope

Current State Snapshot compiler, snapshot UI, fixtures, focused snapshot tests, and any minimal routing needed to inspect the snapshot from the appropriate owned surface.

## Forbidden scope

Profile form, generic intake form, generic dashboard, automatic source promotion, review bypass, or release/readiness claims.

## Validation expectations

Run snapshot tests and related source/review tests. Record true commands and exit codes.

## Visual proof expectations

Required for user-facing UI changes.

## Hard Red stop conditions

Stop on profile-form drift, review bypass, provenance loss, unproven recommendation influence, or missing visual proof for UI changes.

## Rollback expectations

Revert only HBI-09-owned files.

## Final report expectations

Create `docs/audits/hbi-09-batch-closeout-report.md`.
