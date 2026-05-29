# Batch 20 — Ambitions 2.0 Batch 01 / Knowledge Provider Boundary

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-31467468, AMB28-stale_or_unknown_active_status-12261737

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Define the provider, provenance, freshness, trust, and uncertainty boundary that later Ambitions 2.0 intelligence batches can reuse without leaking retrieval logic into product surfaces or pretending uncertain world knowledge is stable truth.

This batch remained contract-first. It did not add real retrieval, networking, provider integration, or persisted knowledge storage.

## What Landed

- added shared knowledge-boundary domain contracts in `Native/Ambitions/Domain/KnowledgeBoundaryModels.swift`
- added a provider boundary and explicit local-only fallback in `Native/Ambitions/Services/KnowledgeProviderBoundary.swift`
- extended `AmbitionsRuntime` and `RuntimeContextSnapshot` so runtime composition now carries a knowledge provider and exposes provider status
- updated runtime composition to inject `LocalOnlyKnowledgeProvider` by default
- added focused tests for:
  - provider identity, provenance, freshness, trust, and uncertainty contracts
  - local-only / unavailable provider degradation behavior
  - runtime propagation of provider status
- updated dedicated-device runtime tests only as needed to stay compatible with the additive runtime-context contract

## What Did Not Land

- no real retrieval implementation
- no networking
- no external provider API integration
- no product shell UI
- no persisted knowledge claim or resource storage
- no SwiftData schema expansion for knowledge storage
- no Batch 21 ingestion logic

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/Domain/KnowledgeBoundaryModelsTests -only-testing:AmbitionsTests/Services/KnowledgeProviderBoundaryTests -only-testing:AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests test`
  - this succeeded on the available local simulator, though Xcode reported `0 tests` executed under the selected filter path
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 208 tests and 0 failures

## Completion Notes

- Batch 20 closed with a reusable provider/provenance/freshness/trust/uncertainty contract layer in domain, services, and runtime.
- The batch intentionally preserved Ambitions' explicit local-only trust posture and degradation behavior instead of inventing a second runtime trust model.
- Every future retrieved claim can now carry provider identity, provenance, freshness, trust classification, and uncertainty metadata before Batch 21 ingestion work.
- Batch 21 followed this boundary with deterministic ingestion and normalization on top of the Batch 20 contracts.

## Next Active Batch

Batch 22 — Ambitions 2.0 Batch 03 / Clarification and ambiguity engine

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
