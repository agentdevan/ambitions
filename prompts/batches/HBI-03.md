<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-03 - Source Adapters Shell

## Batch ID

HBI-03

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-03 prompts/batches/HBI-03.md
```

Equivalent:

```bash
make batch BATCH=HBI-03 PROMPT=prompts/batches/HBI-03.md
```

## Objective

Add the Historical Baseline source-adapter shell: adapter protocols, import plans, import scopes, evidence drafts, and run receipts.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `prompts/batches/HBI-02.md`
- existing Source Atlas/import code and tests

## Allowed scope

- Adapter protocols and pure contract tests.
- Import plan/scope/run-receipt structures.
- Evidence draft boundary objects.
- Fixture-only mock adapters.

## Forbidden scope

- Real Calendar, Files, Photos, PDF, OCR, archive, or network imports.
- UI implementation.
- Cloud import services.
- Active goal creation.

## Validation expectations

Run adapter contract tests proving mock adapters can preview, import evidence drafts, produce run receipts, and fail safely.

## Visual proof expectations

Not required.

## Hard Red stop conditions

Stop if adapter contracts bypass review-gating, create active goals directly, require cloud services, or make downstream personalization claims.

## Rollback expectations

Revert only HBI-03 adapter shell, fixtures, tests, and report files.

## Final report expectations

Create `docs/audits/hbi-03-batch-closeout-report.md` with adapter contracts, validation evidence, no-real-import confirmation, and next eligible batch.
