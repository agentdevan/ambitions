<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# LSF-01 - Local Simulation

## Batch ID

LSF-01

## Runner command

```bash
scripts/ambitions-codex-train.sh LSF-01 prompts/batches/LSF-01.md
```

Equivalent:

```bash
make batch BATCH=LSF-01 PROMPT=prompts/batches/LSF-01.md
```

## Objective

Implement LSF-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/PPL-02.md` before coding.

## Allowed scope

Local what-if capacity model, scenario fixtures, focused tests, and bounded user-controlled simulation.

## Forbidden scope

Autonomous life decisions, cloud-only simulation, hidden recommendation influence, review bypass, or release/readiness claims.

## Validation expectations

Run scenario tests named by the train manifest and any relevant source/time/recommendation tests. Record commands and exit codes.

## Visual proof expectations

Only if user-facing UI changes.

## Hard Red stop conditions

Stop on autonomous decisions, cloud dependency, unbounded recommendation authority, review-gating bypass, or missing proof for changed UI.

## Rollback expectations

Revert only LSF-01-owned files.

## Final report expectations

Create `docs/audits/lsf-01-batch-closeout-report.md`.
