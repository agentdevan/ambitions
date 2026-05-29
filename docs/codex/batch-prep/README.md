# Batch Prep Notes

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

This directory stores read-only prep notes used by throughput lanes.

## Purpose

Prep notes support GPT-5.4-mini/unknown-tier preparation lanes by capturing candidate
scope, evidence pointers, risks, and fast-lane validation hints without implementation.

## Current seeded notes

- `PK16.md`
- `PK17.md`
- `PK18.md`
- `PK19.md`
- `PK20.md`
- `PK21.md`
- `PK22.md`
- `PK23.md`
- `PK24.md`
- `PK25.md`

## How to use

- GPT-5.4-mini/unknown-tier models should read these notes before bounded patch generation.
- Missing prompt files are valid; they must be marked `Prompt availability: missing` and kept candidate-only.
- Candidates do not authorize implementation.
- Route to the canonical runner lane for execution through:

```bash
make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

## Tooling

- `scripts/ambitions-batch-lane-classifier.py`
- `scripts/ambitions-batch-prep-scaffold.py`
- `scripts/ambitions-throughput-plan.sh`
- `scripts/ambitions-known-yellow-scan.sh`

## Scope discipline

- Do not rewrite product strategy, IA, route/raw-value definitions, production
  claims, release posture, or proof boundaries from this folder.
- Keep each prep note deterministic and bounded to available evidence.

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
