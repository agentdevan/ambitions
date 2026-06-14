# AMB-1127 Parallel Implementation Guard Prompt

Issue: `AMB-1127` / `M01.T06A`

Scope: Source Atlas Pack / Seed Foundry reusable source-bound seeds.

Planned source boundary:
- Add a Source Atlas Seed Foundry value-model owner under `Native/Ambitions/Persistence/`.
- Reuse existing `SourceAtlasPack`, `SourceAtlasClaim`, `SourceAtlasRequirement`, `SourceAtlasFreshnessPolicy`, `SourceAtlasRiskPolicy`, `SourceAtlasFreshnessManifest`, and pack supply-chain acceptance concepts.
- Add focused unit tests under `Native/AmbitionsTests/Domain/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for the new source/test owners.

Allowed behavior:
- Define reusable source-bound seed descriptors with pack state, seed reuse policy, freshness windows, release acceptance records, contradiction/revocation gates, and current-use eligibility.
- Validate that a seed can drive current use only when it is source-bound, claim-bound, release-recorded, non-expired, non-contradicted, non-revoked, review-approved, and backed by a pack whose Source Atlas validator has no blocking issues.
- Produce deterministic pack-state matrix rows and sample release acceptance records that can be asserted in tests and closeout evidence.
- Keep all behavior local, deterministic, value-model-only, and inspectable.

Forbidden behavior:
- No app execution engine, background layer, SwiftUI, navigation, shell, UI, or app-entry source edits for this issue.
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public Source Atlas, seed descriptors, release records, pack locators, or validation fixtures.
- No plan activation, user obligation mutation, schedule storage, external publication, live download, or pack deployment behavior.
- No release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or full-project readiness claims.

Expected validation:
- AMB-1127 focused unit tests for pack-state matrix, freshness-window gates, contradiction/revocation blocking, reusable seed policy, and release acceptance record evidence.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
