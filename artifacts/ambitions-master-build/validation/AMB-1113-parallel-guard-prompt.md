# AMB-1113 Parallel Implementation Guard Prompt

Issue: `AMB-1113` / `M02.T00`

Scope: Runtime core umbrella split-chain gate.

Planned source boundary:
- Add a local value-model gate under `Native/Ambitions/Runtime/`.
- Add focused unit tests under `Native/AmbitionsTests/Runtime/`.
- Extend `docs/codex/existing-code-champion-coverage.yml` for the new source/test owners if a new file is added.
- Extend the existing `private_life_runtime` and `proof_receipt_replay` locked owners only through the active AMB-1113 allowlist; do not create a parallel owner.

Allowed behavior:
- Define a deterministic chain manifest for the M02 runtime segments: path selection, quality firewall, graph compile, elasticity, schedule install, consequence reflow, and high-risk safety.
- Validate whether each segment is present, locally owned, source-checked, reversible where required, and inspection-ready.
- Produce stable chain rows, block reasons, and a local gate record that fails closed until all required segments can drive visible execution.
- Preserve `SourceRecord` as the source boundary, `Receipt` as the durable trust artifact, `ReplayTrace` as the inspection boundary, and What Ambitions knows / You inspection as the user-owned review path.
- Keep this issue as the umbrella gate only; later component trains still own their deeper engines.

Forbidden behavior:
- No SwiftUI, navigation, shell, app-entry, widget, share extension, or user-facing UI edits.
- No Cloudflare/R2 SDK, network client, backend, account system, telemetry, analytics, hosted inference, or required cloud LLM path.
- No private user data in public packs, chain manifests, authority records, or validation fixtures.
- No schedule persistence, external publication, live download, pack deployment, hidden mutation, or silent plan rewrite behavior.
- No release, privacy/legal, accessibility, device, performance, TestFlight, App Store, or full-project readiness claims.
- No claim that the locked runtime compiler or proof/receipt/replay concept is final; AMB-1113 only adds the umbrella gate and leaves later component trains owned.

Expected validation:
- AMB-1113 focused unit tests for all required segments accepted, missing segment blocked, unsafe downstream segment blocked, reversible schedule/reflow requirements, deterministic ordering, and local-only gate behavior.
- Champion coverage check.
- Parallel implementation guard pre/post.
- `xcodegen generate`.
- Focused `xcodebuild test` and `xcodebuild build-for-testing`.
