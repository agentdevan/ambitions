<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
