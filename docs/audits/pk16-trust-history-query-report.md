# PK16 Trust History Query Report

## Scope implemented
- Added bounded trust-history query contracts in `Native/Ambitions/Persistence/PersistenceContracts.swift`:
  - `TrustHistoryQuery`
  - `TrustHistoryQueryResult`
  - `TrustHistoryQueryProjection`
  - `TrustHistoryQueryItemKind`
  - `TrustHistoryQueryRepository`
- Added SwiftData read-only implementation in `Native/Ambitions/Persistence/SwiftDataRepositories.swift`:
  - `SwiftDataTrustHistoryQueryRepository`
- Added focused tests in `Native/AmbitionsTests/Persistence/TrustHistoryQueryRepositoryTests.swift`.

## Query behavior added
- Merges historical Action Receipt and Event Ledger records into one deterministic stream.
- Supports facets currently available in source models:
  - Receipt: source domain, privacy, proof relevance, trust status, time window.
  - Event ledger: source, privacy, requires-review, user-confirmed, proof-reference kinds, proof-reference presence, time window.
- Deterministic ordering:
  - `occurredAt` descending
  - `actionReceipt` before `eventLedger` for equal timestamps
  - `id` ascending as final tie-break.
- Read-only behavior only: no schema or storage type additions.

## Review repair
- GPT-5.5 review found and repaired an inverted `requiresProofReferences` filter.
- Added focused proof that `requiresProofReferences: true` returns only events with proof references and `requiresProofReferences: false` returns only events without proof references.

## EFC / AIR applicability
- EFC01 invoked: private product evidence remains local/read-only through receipt and event truth.
- EFC11 invoked: review/user-confirmed facets expose support/data-control posture without remote measurement or support tooling.
- EFC12 invoked: proof and receipt metadata are shaped for local query/proof portability posture.
- EFC05 not applicable: recommendation trust evidence was not touched.
- EFC13 not applicable: cadence or signal history was not touched.
- AIR04, AIR10, AIR18, and AIR33 invoked through trust-history query inheritance over event/receipt proof and review metadata.

## Validation
- `xcodegen generate` -> passed.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/TrustHistoryQueryRepositoryTests test` -> passed, 3 tests, 0 failures.
- `git diff --check` -> passed.
- `scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Persistence/PersistenceContracts.swift Native/Ambitions/Persistence/SwiftDataRepositories.swift Native/AmbitionsTests/Persistence/TrustHistoryQueryRepositoryTests.swift docs/audits/pk16-trust-history-query-report.md` -> passed, no blocking hits.

## Non-claims
- No UI, top-level IA, schema/storage type, cloud/backend/sync/account, telemetry, analytics, hosted AI, dependency, signing, entitlement, workflow, release/readiness, device, accessibility, performance, TestFlight/App Store, legal/privacy, or full-suite Green claim is made.
