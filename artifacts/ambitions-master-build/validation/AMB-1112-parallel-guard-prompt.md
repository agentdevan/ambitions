# AMB-1112 Parallel Implementation Guard Prompt

Issue: `AMB-1112` / `M02.T02`

Scope: Any Goal Runtime operating modes and coverage loop.

Planned source boundary:
- Add a local deterministic Any Goal Runtime coverage model under `Native/Ambitions/Runtime/`.
- Add focused runtime tests under `Native/AmbitionsTests/Runtime/`.
- Add AMB-1112 fixture/proof artifacts under `artifacts/ambitions-master-build/validation/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for any new source/test owners.
- Extend locked `runtime_recommendation_compiler` and `proof_receipt_replay` ownership only through the active AMB-1112 allowlist if the guard requires it; do not create a parallel owner.

Allowed behavior:
- Define a local `CoverageNeed` ledger/read model for unsupported, under-covered, unsafe, source-needed, jurisdiction-needed, and supported goal-family routing.
- Define deterministic operating modes for supported, unsupported-but-captured, unsafe-blocked, jurisdiction-needed, awaiting-source, and source-arrived paths.
- Define a privacy-safe coverage request builder that emits abstract family/capability/source gap tags and never emits raw private goal details.
- Define a local source-arrival detector that can reconcile coverage needs against source authority fingerprints without live download, R2 publication, or network transport.
- Define unsupported-but-captured recovery receipts so unsupported goals remain inspectable, recoverable, and replayable instead of disappearing or becoming fake plans.
- Define unsafe-blocked receipts and jurisdiction-needed handoff records that fail closed without ordinary Step generation.
- Cover health, legal/civic, finance, moving, creative, family, education, repair, travel, and sensitive private goal families in fixtures.
- Preserve local-first behavior, deterministic ordering, `SourceRecord`, Proof, Receipt, `ReplayTrace`, and You / What Ambitions Knows inspectability boundaries.

Forbidden behavior:
- No broad SwiftUI expansion, navigation rewrite, shell rewrite, widget redesign, App Intent redesign, or user-facing IA change.
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public packs, coverage requests, fixture output, validation artifacts, or source-arrival traces.
- No silent plan mutation, schedule persistence, external publication, live source download, or hidden Step rewrite behavior.
- No legal advice, financial advice, medical advice, jurisdiction determination, privacy/legal certification, release readiness, device proof, performance proof, TestFlight readiness, App Store readiness, or full-project readiness claims.
- No claim that Any Goal Runtime is complete beyond the AMB-1112 local coverage loop and operating-mode fixtures.

Expected validation:
- AMB-1112 focused Any Goal Runtime tests for supported, unsupported-but-captured, unsafe-blocked, jurisdiction-needed, awaiting-source, and source-arrived paths.
- Goal-family fixture suite covering health, legal/civic, finance, moving, creative, family, education, repair, travel, and sensitive private goals.
- Privacy assertions that raw private goal details do not appear in coverage requests, ledger summaries, recovery receipts, or source-arrival traces.
- Determinism assertions for ledger ordering, stable IDs, and source-arrival reconciliation.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
