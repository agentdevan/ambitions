# Batch 27 — Ambitions 2.0 Batch 08 / Update and Freshness Engine

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-67904375

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Create the freshness/update infrastructure layer that detects stale or degraded knowledge/resource chains, propagates freshness posture through the resource graph, and preserves update-needed signals structurally for later contradiction, explainability, and runtime/product integration.

This batch stayed infrastructure-only. It did not add live refresh scheduling, web/API integrations, contradiction logic, explanation surfaces, energy logic, UI work, runtime feature widening, or SwiftData schema changes.

## What Landed

- added structural freshness/update contracts in `Native/Ambitions/Domain/GoalEngine/GoalFreshnessUpdateModels.swift`
- added deterministic post-graph freshness evaluation in `Native/Ambitions/Services/GoalFreshnessUpdateService.swift`
- extended `GoalResourceGraph` with compatibility-safe `freshness` metadata that decodes older graph metadata without requiring persistence schema changes
- kept freshness evaluation downstream of graph construction:
  - no freshness logic was pushed into `GoalCompiledPath`
  - `GoalResourceGraph` remains a graph output, not a second source system
- evaluated freshness from existing canonical inputs:
  - `KnowledgeFreshnessMetadata`
  - linked claim/source/provider identity
  - `KnowledgeProviderStatus`
  - resource resolution and missing-resource state
- preserved structural postures for:
  - current enough
  - aging
  - stale
  - expired
  - unknown freshness
  - blocked by missing evidence
  - provider unavailable
- kept placeholder-only and unresolved resources as first-class graph entities after freshness evaluation
- added deterministic freshness lineage references and update severity/flags for downstream machine consumers
- added additive ranking flags for freshness/update impact without changing rank ordering through incidental collection order
- threaded `referenceNow` from goal orchestration into resource graph freshness evaluation
- added focused tests for model round-tripping, severity ordering, stale/expired/aging/unknown detection, provider unavailability, placeholder/unresolved behavior, deterministic lineage, graph metadata, orchestration metadata, and persistence round-tripping

## What Did Not Land

- no live refresh scheduling
- no web search or external API integrations
- no contradiction engine logic
- no explanation surfaces or user-facing explanation prose
- no energy model logic
- no UI changes
- no runtime payload widening
- no SwiftData schema expansion
- no changes to `GoalCompiledPath` freshness behavior
- no Batch 28 implementation

## Validation That Actually Ran

- `xcodegen generate`
- initial red test check after generation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalFreshnessUpdateModelsTests -only-testing:AmbitionsTests/GoalFreshnessUpdateServiceTests test`
  - needs review at compile time because the new freshness/update contracts did not exist yet
- focused freshness tests:
  - `xcodegen generate && xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalFreshnessUpdateModelsTests -only-testing:AmbitionsTests/GoalFreshnessUpdateServiceTests test`
  - passed with 10 tests and 0 failures
- focused Batch 27 integration selection:
  - `xcodegen generate && xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/GoalFreshnessUpdateModelsTests -only-testing:AmbitionsTests/GoalFreshnessUpdateServiceTests -only-testing:AmbitionsTests/GoalResourceGraphModelsTests -only-testing:AmbitionsTests/GoalResourceGraphServiceTests -only-testing:AmbitionsTests/GoalEngineOrchestratorTests -only-testing:AmbitionsTests/PersistenceRepositoryTests test`
  - passed with 39 tests and 0 failures
- simulator build:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - passed
- authoritative validation:
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`
  - passed with 265 tests and 0 failures

## Completion Notes

- Batch 27 closed with freshness/update posture carried through `metadata.resourceGraph`.
- Missing evidence, unknown freshness, and provider unavailable states are preserved structurally instead of being treated as fresh enough.
- Ranking impact is additive and audit-friendly through stable flags, severity, and lineage metadata.
- The checked-out branch remained `main` during implementation and validation.

## Next Active Batch

Batch 28 — Ambitions 2.0 Batch 09 / Energy model foundation

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
