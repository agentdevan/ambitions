# AFI14 Cross-Surface Coherence Review

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Accepted Yellow
Date: 2026-05-08

## Scope

AFI14 verifies that active Ambitions Flagship Interface surfaces operate as one
product family rather than disconnected one-off screens.

Active top-level AFI surfaces remain:

```text
Today
Goals
Capture
Time
You
```

`Plan` is not a top-level AFI surface. Plan remains valid only as an
action/contextual noun and internal compatibility seam where current code still
requires it.

## Completed Evidence

- Product grammar is locked to:

```text
Capture -> Clarify -> Shape -> Start -> Close -> Remember
```

- Every active top-level surface participates in the grammar.
- Cross-surface handoffs are recorded for Capture, Goals, Time, Today, and You.
- Trust routing is required for each handoff.
- The proof model makes no runtime behavior, rendered proof, human approval, or
  release-readiness claim.

## Files

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift`
- `docs/audits/afi14-cross-surface-coherence-review-report.md`

## Validation

See `docs/audits/afi14-cross-surface-coherence-review-report.md` for raw
command evidence and no-claim boundaries.

## Result

Accepted Yellow. AFI14 source/test coherence proof exists, but rendered
cross-surface walkthrough, human founder acceptance, device proof, and release
claims remain blocked.

## Next Eligible Batch

AFI15 Founder Acceptance Review.

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
