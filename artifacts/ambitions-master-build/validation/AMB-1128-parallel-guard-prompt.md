# AMB-1128 Parallel Implementation Guard Prompt

Issue: `AMB-1128` / `M01.T06B`

Scope: Source Authority Mesh for source eligibility, revocation, jurisdiction compatibility, and share rights.

Planned source boundary:
- Add a Source Atlas Authority Mesh value-model owner under `Native/Ambitions/Persistence/`.
- Reuse existing `SourceAtlasPack`, `SourceAtlasQueryResponse`, `SourceAtlasQueryResult`, `SourceAtlasLocalPackCacheResolution`, `SourceAtlasSeedEligibilityRecord`, `SourceAtlasClaim`, `SourceAtlasRequirement`, and evidence-map concepts.
- Add focused unit tests under `Native/AmbitionsTests/Persistence/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for the new source/test owners.

Allowed behavior:
- Define local source authority records with source state, jurisdiction tags, share-rights policy, and revocation evidence references.
- Validate that a Source Atlas result can support visible Step eligibility, schedule-install eligibility, or user-controlled share only when source authority records are present, non-revoked, jurisdiction-compatible, share-rights-compatible, and fail-closed against cache, seed, claim, and requirement blockers.
- Produce deterministic authority matrix rows, inspection records, revocation evidence summaries, and blocked Step examples that can be asserted in tests and closeout evidence.
- Keep all behavior local, deterministic, value-model-only, and inspectable.

Forbidden behavior:
- No app execution engine, background layer, SwiftUI, navigation, shell, UI, or app-entry source edits for this issue.
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public Source Atlas, authority records, share records, pack locators, or validation fixtures.
- No plan activation, user obligation mutation, schedule storage, external publication, live download, or pack deployment behavior.
- No release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or full-project readiness claims.

Expected validation:
- AMB-1128 focused unit tests for current authority acceptance, source revocation blocking, jurisdiction incompatibility, share-rights blocking, fail-closed cache/seed consumption, and deterministic authority matrix sorting.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
