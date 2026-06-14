# AMB-1111 Parallel Implementation Guard Prompt

Issue: `AMB-1111` / `M02.T01`

Scope: Step Quality Firewall fail-closed gate for every visible Step.

Planned source boundary:
- Add a local deterministic Step Quality Firewall/read model under `Native/Ambitions/Runtime/` or existing runtime recommendation ownership.
- Add focused unit tests under `Native/AmbitionsTests/Runtime/`.
- Add a deterministic surface-copy guard script under `scripts/codex/` for protected Step surfaces if no equivalent active validator exists.
- Add AMB-1111 fixture/proof artifacts under `artifacts/ambitions-master-build/validation/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for any new source/test/script owners.
- Extend locked `runtime_recommendation_compiler` and `proof_receipt_replay` ownership only through the active AMB-1111 allowlist; do not create a parallel owner.

Allowed behavior:
- Define `RecommendedStepEligibility` as a local read model for whether a candidate Step may become visible.
- Evaluate Step copy, context fit, source authority, proof expectation, accessibility semantics, high-risk posture, and elasticity coverage.
- Fail closed for generic, ambiguous, shameful, overlong, unsafe, stale-source, high-risk, inaccessible, non-elastic, or repair-less Steps.
- Require every rejection/degraded decision to carry a repair path before blocking visible surfacing.
- Produce stable verdict IDs, blocking codes, accepted/degraded/rejected decisions, and protected-surface scan records.
- Validate protected surfaces: Today, Goals, sharing/external snapshots, Year in Ambitions source if present, widgets, and App Intents.
- Preserve local-first behavior, `SourceRecord`, Proof, Receipt, `ReplayTrace`, and You / What Ambitions Knows inspectability boundaries.

Forbidden behavior:
- No broad SwiftUI expansion, navigation rewrite, shell rewrite, widget redesign, App Intent redesign, or user-facing IA change.
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public packs, fixtures, surface scan output, or validation artifacts.
- No silent plan mutation, schedule persistence, external publication, live download, or hidden Step rewrite behavior.
- No release, privacy/legal, accessibility certification, device, performance, TestFlight, App Store, or full-project readiness claims.
- No claim that Step Quality Firewall is complete beyond the AMB-1111 local fail-closed gate and protected surface copy validator.

Expected validation:
- AMB-1111 focused unit tests for accepted source-backed Step and blocked generic, ambiguous, shameful, overlong, unsafe, stale-source, high-risk, inaccessible, non-elastic, and missing-repair Steps.
- Fixture corpus validator or focused test fixture corpus.
- Forbidden-copy protected surface validator.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
