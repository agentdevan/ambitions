# Batch 20 — Ambitions 2.0 Batch 01 / Knowledge Provider Boundary

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
