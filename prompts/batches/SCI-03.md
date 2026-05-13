<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# SCI-03 - Contradictions

## Batch ID

SCI-03

## Runner command

```bash
scripts/ambitions-codex-train.sh SCI-03 prompts/batches/SCI-03.md
```

Equivalent:

```bash
make batch BATCH=SCI-03 PROMPT=prompts/batches/SCI-03.md
```

## Objective

Implement SCI-03 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/SCI-02.md` before coding.

## Allowed scope

Contradiction groups, conflict routing, provenance-preserving conflict fixtures, and focused conflict tests.

## Forbidden scope

Silent winner-picking, source provenance loss, automatic override, review-state bypass, or release/readiness claims.

## Validation expectations

Run the conflict tests named by the train manifest and any related source/claim tests. Record true commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on silent winner-picking, provenance loss, review-gating bypass, or hidden source promotion.

## Rollback expectations

Revert only SCI-03-owned files.

## Final report expectations

Create `docs/audits/sci-03-batch-closeout-report.md`.
