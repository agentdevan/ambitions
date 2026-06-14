# AMB-1053 Parallel Implementation Guard Prompt

Issue: `AMB-1053` / `M01.T05`

Scope: Source Atlas cache and failure-safe app consumption.

Planned source boundary:
- Add a local Source Atlas cache coordinator value model under `Native/Ambitions/Persistence/`.
- Compose existing Source Atlas store, freshness manifest, and query engine value models without changing locked Domain, Services, or Runtime owners.
- Add focused unit tests under `Native/AmbitionsTests/Domain/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for the new source/test owners.

Allowed behavior:
- Verify pack payload hashes against local cache payloads and the freshness manifest.
- Quarantine corrupt, unsupported, contradicted, revoked, manifest-mismatched, and unsafe request inputs.
- Keep cache resolution local and deterministic.
- Build only privacy-safe public-pack request descriptors that contain public pack identifiers, manifest version, hash, and static route/query metadata.
- Block request descriptors that contain personal identifiers, private planning context, secrets, tokens, API keys, or private file locators.
- Return an inspectable fallback result when no eligible pack can support current app consumption.

Forbidden behavior:
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public Source Atlas, request descriptors, pack locators, or validation fixtures.
- No user-facing UI changes.
- No release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or full-project readiness claims.

Expected validation:
- AMB-1053 focused unit tests for cache verification, manifest freshness/revocation, privacy-safe request blocking, quarantine, and local fallback.
- Adjacent Source Atlas store/query/offline fallback tests.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
