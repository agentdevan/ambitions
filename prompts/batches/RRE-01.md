<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# RRE-01 - Final Evidence

## Batch ID

RRE-01

## Runner command

```bash
scripts/ambitions-codex-train.sh RRE-01 prompts/batches/RRE-01.md
```

Equivalent:

```bash
make batch BATCH=RRE-01 PROMPT=prompts/batches/RRE-01.md
```

## Objective

Implement RRE-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/MGP-01.md` before coding.

## Allowed scope

Final proof reports, accessibility evidence where UI exists, privacy evidence, guard evidence, and terminal train closeout documentation.

## Forbidden scope

Release claims without proof, App Store/TestFlight/device-readiness claims without proof, skipping required validation, or converting governance install into implementation proof.

## Validation expectations

Run proof reports and gates named by the train manifest. Run `python3 scripts/ambitions-historical-baseline-train-guard.py` if present. Record commands and exit codes honestly.

## Visual proof expectations

Required for every UI surface changed in the train.

## Hard Red stop conditions

Stop on unproven release/readiness claims, missing required proof, unresolved privacy/accessibility evidence gaps, or skipped guard failures.

## Rollback expectations

Revert only RRE-01-owned files unless rollback evidence proves a broader revert is required.

## Final report expectations

Create `docs/audits/rre-01-batch-closeout-report.md` and a Historical Baseline final train evidence summary if all HBI-family batches are complete.
