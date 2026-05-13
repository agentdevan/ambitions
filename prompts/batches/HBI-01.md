<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-01 - Core Schema

## Batch ID

HBI-01

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-01 prompts/batches/HBI-01.md
```

Equivalent:

```bash
make batch BATCH=HBI-01 PROMPT=prompts/batches/HBI-01.md
```

## Objective

Implement the Historical Baseline core schema for `SourceRecord`, `EvidenceItem`, `CandidateClaim`, `LifeFact`, and `CurrentStateSnapshot` without UI polish or source import behavior.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- current storage/domain package source and tests

## Allowed scope

- Add local-first core schema/types for source records, evidence items, candidate claims, confirmed life facts, confidence/status bands, and snapshots.
- Add unit tests proving schema defaults, status transitions, provenance fields, and serialization where applicable.
- Add fixture-only data needed for schema tests.

## Forbidden scope

- UI polish or new top-level surfaces.
- Real source imports.
- Cloud storage or cloud LLM dependency.
- Migration claims without migration proof.
- Release/readiness claims.

## Validation expectations

Run focused schema/unit tests and any existing storage/domain validation lanes. Record commands and true exit codes.

## Visual proof expectations

Not required unless UI is unexpectedly touched. If UI is touched, stop and justify scope.

## Hard Red stop conditions

Stop if schema cannot preserve provenance, candidate status, confidence band, sensitivity, stale/contradiction state, and recommendation-influence eligibility; if cloud storage is introduced; or if existing persistence/migration safety is endangered.

## Rollback expectations

Revert only HBI-01 schema/test/fixture/report files. Preserve HBI train governance files.

## Final report expectations

Create `docs/audits/hbi-01-batch-closeout-report.md` with files changed, schema summary, validation evidence, known debt, and next eligible batch.
