# Batch 21 — Ambitions 2.0 Batch 02 / External Knowledge Ingestion Core

## Status

Completed

## Goal

Build the first real ingestion and normalization layer on top of the Batch 20 provider boundary so Ambitions can accept externally retrieved knowledge as auditable structured claims and source records without leaking retrieval logic into product surfaces, feature services, or runtime-safe outputs.

This batch stayed deterministic and in-memory. It did not add live web search, external API integrations, networking, persistence, runtime output widening, or product UI.

## What Landed

- added provider-side raw input contracts in `Native/Ambitions/Domain/KnowledgeIngestionModels.swift`
- added deterministic normalization in `Native/Ambitions/Services/KnowledgeIngestionService.swift`
- updated `Native/Ambitions/Services/KnowledgeProviderBoundary.swift` so:
  - `providerInputs` is the primary Batch 21 ingestion path
  - `claimSet` remains an explicit compatibility-only fallback
  - local-only provider behavior remains unchanged
  - registry aggregation normalizes through the shared ingestion service instead of pushing normalization into providers
- normalized provider inputs into auditable `KnowledgeClaim` and `KnowledgeSourceRecord` outputs with:
  - stable deterministic IDs
  - preserved provider identity and provider availability state
  - preserved official vs inferred vs user-provided distinctions
  - preserved freshness states including unknown, stale, and expired
  - preserved trust and confidence labels
  - preserved unresolved conflicts via structural conflict groups and conflict flags
  - preserved structural degradation states for local-only mode, provider unavailable, stale information, low-trust information, and conflicting claims
- added focused tests in:
  - `Native/AmbitionsTests/Domain/KnowledgeIngestionModelsTests.swift`
  - `Native/AmbitionsTests/Services/KnowledgeIngestionServiceTests.swift`
  - updated `Native/AmbitionsTests/Services/KnowledgeProviderBoundaryTests.swift`

## What Did Not Land

- no live web search integration
- no external API integrations
- no networking
- no persisted claims, sources, or conflict groups
- no SwiftData schema expansion
- no runtime ambient snapshot widening
- no widget or dedicated-device payload widening
- no product shell UI
- no Batch 22 clarification logic

## Validation That Actually Ran

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 216 tests and 0 failures

## Completion Notes

- Batch 21 closed with deterministic provider-input normalization as the canonical ingestion boundary on top of the Batch 20 contracts.
- The batch kept structural states authoritative: provider availability, freshness, degradation states, and unresolved conflicts remain preserved instead of being flattened into prose.
- The batch intentionally kept resource modeling narrow to claims and source records only so Batch 26 can introduce the resource graph separately.

## Next Active Batch

Batch 22 — Ambitions 2.0 Batch 03 / Clarification and ambiguity engine
