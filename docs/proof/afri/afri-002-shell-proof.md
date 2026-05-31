# AFRI-002 Shell Proof

Status: Green for canonical shell source, build, and focused shell UI smoke test. Screenshot artifact path is Yellow: simulator screenshot export failed after a Green UI test.
Issue: AMB-354 / AFRI-002 -- Canonical root shell and app chrome integrity
Created: 2026-05-31
Repo: `/Users/devan/Documents/GitHub/ambitions`
Commit inspected before change: `8d6b74a65`
Scope: canonical app shell owner, shell chrome guard scope, and proof note.

This proof note is not release proof, App Store proof, accessibility certification, performance proof, privacy/legal approval, or device proof.

## Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Changes

- Mounted the existing global shell entry affordance in `AmbitionsRootView` through the canonical `TabView` shell path.
- Replaced the empty floating control lane with a stable lane containing the global entry button and `shell.floating-control-lane` accessibility identifier.
- Preserved the native button role for `shell.global-entry-button`.
- Exposed the continuity ribbon for `.execution` posture so Today participates in the canonical shell continuity contract.
- Narrowed the `persistence_external_surfaces` concept lock from all of `Native/Ambitions/App` to the specific App files that own external launch/routing/container command surfaces, so shell chrome repairs do not trip unrelated external-surface locks.
- Recorded that shell receipt chrome is display-only; `SourceRecord` and `ReplayTrace` wiring remains owned by runtime/proof layers.

## Acceptance Evidence

- Canonical tabs remain `Today / Goals / Capture / Time / You`.
- No new top-level destination was added.
- Global entry opens through the shell command path and does not replace top-level IA.
- Overlay host remains the existing `navigation.activeOverlay` sheet host.
- Shell safe-area behavior is covered by the focused UI smoke test assertion that the global entry button does not intersect the tab bar.

## Validation Run

- `python3 scripts/ambitions-champion-coverage-check.py`
  - Result: Red before shell edits.
  - Boundary: pre-existing coverage defects in unrelated compatibility/proof/runtime files; not caused by AFRI-002 shell changes.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-354 --prompt /tmp/AMB-354-AFRI-002-guard-prompt.md`
  - Result: Green.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-354 --prompt /tmp/AMB-354-AFRI-002-guard-prompt.md --changed-from 8d6b74a65 --changed-path Native/Ambitions/App --changed-path docs/codex/concept-lock-registry.yml`
  - Result: Red twice during repair, then Green after lock-scope and SourceRecord/ReplayTrace boundary repair.
  - Final report path: `build/reports/parallel-implementation-guard/AMB-354-post.md`.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces build-for-testing`
  - Result: `** TEST BUILD SUCCEEDED **`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - Result after repair: `** TEST SUCCEEDED **`.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_09-11-41--0400.xcresult`.

## Screenshot Proof Path

Screenshot capture was attempted after the Green UI test:

- MCP screenshot result: failed to capture screenshot.
- `xcrun simctl io 8ACCD665-4807-4102-B526-5A1AE20686A8 screenshot output/afri-002-shell-smoke-20260531.png`
  - Result: `simctl.SimDisplayScreenshotWriter.ScreenshotError`, code 2, `Error creating the image`.
- `xcrun simctl io 8ACCD665-4807-4102-B526-5A1AE20686A8 screenshot --type=jpeg output/afri-002-shell-smoke-20260531.jpg`
  - Result: `simctl.SimDisplayScreenshotWriter.ScreenshotError`, code 2, `Error creating the image`.
- `xcrun xcresulttool export attachments --path /Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_09-11-41--0400.xcresult --output-path output/afri-002-xcresult-attachments`
  - Result: no matching attachments in the passing UI test result.

Screenshot artifact status: Yellow, blocked by local simulator screenshot export. Behavioral shell proof is the Green focused UI test result bundle above.

## Not Verified

- Full app test suite.
- Full UI suite.
- Physical device behavior.
- Signed archive, TestFlight, App Store, privacy/legal, performance, or public accessibility proof.

## Rollback

- Revert `Native/Ambitions/App/AmbitionsRootView.swift`, `Native/Ambitions/App/AppShellView.swift`, `docs/codex/concept-lock-registry.yml`, and this proof note.
