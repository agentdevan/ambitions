<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-08 - Candidate Extraction

## Batch ID

HBI-08

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-08 prompts/batches/HBI-08.md
```

Equivalent:

```bash
make batch BATCH=HBI-08 PROMPT=prompts/batches/HBI-08.md
```

## Objective

Implement deterministic local candidate extraction rules for Historical Baseline. Imported evidence may produce candidate claims only; it must not create confirmed facts or active goals directly.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `prompts/batches/HBI-07.md`

## Allowed scope

- Deterministic local extraction rules.
- Candidate claim models/services where not already present.
- Extraction fixtures and tests.
- Source/evidence provenance preservation.

## Forbidden scope

- Cloud AI dependency.
- Hidden inference engines.
- Direct creation of confirmed life facts.
- Direct creation of active goals.
- Release/readiness claims.

## Validation expectations

Run extraction tests proving evidence produces sourced candidate claims with status, confidence placeholder/band support, and review eligibility.

## Visual proof expectations

Not required unless UI is touched.

## Hard Red stop conditions

Stop if extraction bypasses review, loses provenance, introduces cloud dependency, or produces active goals directly.

## Rollback expectations

Revert only HBI-08-owned extraction, fixture, test, and report files.

## Final report expectations

Create `docs/audits/hbi-08-batch-closeout-report.md` with deterministic extraction proof, validation commands, and next eligible batch.
