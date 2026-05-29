# Batch 21 — Ambitions 2.0 Batch 02 / External Knowledge Ingestion Core

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

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
