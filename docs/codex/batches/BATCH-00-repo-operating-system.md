# Batch 00 — Repo Operating System / Canon Alignment

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-stale_or_unknown_active_status-53071610

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-authority-check**
> AMB-291 note: This batch/prompt is not standalone authority and must read the listed source-of-truth files before use.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof
> Dispositions: rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Purpose

Lock the repo onto the canonical planning stack, keep runtime truth aligned to the native SwiftUI app, and make the active batch queue explicit before feature work continues.

## Outcome Recorded Here

- `docs/codex/CONTEXT_INDEX.md` is present and defines source-of-truth precedence.
- The canonical planning stack remains:
  - `MASTER_PRODUCT_SPEC.md`
  - `docs/canon/Ambitions_OS_Master_Roadmap.md`
  - `docs/canon/Ambitions_Surgical_Execution_Plan.md`
  - `docs/canon/Ambitions_Codex_Batch_Plan.md`
  - `docs/codex/BATCH_REGISTRY.md`
- `Native/Ambitions/` remains the shipping source of truth.
- The active batch queue is now advanced so Batch 01 is the only active batch and Batch 02 remains queued.

## Notes

- This control file records batch-state truth only. It does not reopen Batch 00 implementation work.
- Any remaining runtime-truth copy cleanup that is explicitly scoped inside Batch 01 should be handled there, not by reactivating Batch 00.

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
