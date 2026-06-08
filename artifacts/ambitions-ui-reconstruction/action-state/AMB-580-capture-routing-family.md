# AMB-580 Capture Routing Primitive Family

Verdict: Green

## Scope

AMB-580 promoted `capture-routing-family` into a shared action-state primitive family for Global Capture routing. The patch adds a design-system contract plus line-stage and line-row primitives, then routes the activated Capture seam through that family instead of its prior state grid, route proof pills, rounded route option rows, and confidence-worded route labels.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Capture Routing primitive family only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

## Active Truth Inspected

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

## What Changed

- Added `CaptureRoutingPrimitiveFamilyContract.current` with primitive ID `capture-routing-family`.
- Added `CaptureRoutingPrimitiveRole` for route reveal, placement review, route option, correction, receipt, source, input policy, and no-silent-placement roles.
- Added `CaptureRoutingPrimitiveStage` for shared Capture routing line-stage surfaces.
- Added `CaptureRoutingPrimitiveLine` for source, route basis, review state, correction, receipt, and no-silent-placement rows.
- Replaced the activated Capture seam state overview grid with Capture Routing primitives.
- Replaced the route proof pill strip with Capture Routing route option lines.
- Replaced the placement review rounded panel with a Capture Routing placement review stage.
- Replaced the correction option grid wrapper with a Capture Routing correction stage and vertical correction controls.
- Replaced confidence-worded route labels with deterministic route-basis copy: `Route ready after review` and `Needs review before placement`.
- Preserved local correction, no-silent-placement, receipt, SourceRecord, and ReplayTrace language.
- Promoted `capture-routing-family` in the primitive registry.
- Allowed AMB-580 through the Capture routing and design primitive concept locks.
- Classified the new primitive source and focused test in champion coverage metadata.
- Added focused AMB-580 source-structure coverage in `CaptureRoutingPrimitiveFamilyTests`.

## Screenshot Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png`
- Pixel dimensions: 1206 x 2622
- Capture commands:
  - `xcrun simctl install 8ACCD665-4807-4102-B526-5A1AE20686A8 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo SIMCTL_CHILD_AMBITIONS_LAUNCH_URL='ambitions://captures/inbox?origin=widget' xcrun simctl launch --terminate-running-process 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png`
- Visual inspection result: the screenshot shows Today with the activated global Capture seam and the Capture Routing route-reveal line-stage in first-viewport proof position, including deterministic route-basis copy, selected route, and route option lines. It does not show an iOS open-confirmation prompt, Capture as a top-level tab, a category grid, a chat transcript, or stale confidence labels.
- Proof boundary: the screenshot proves the focused local simulator activated Capture route renders the Capture Routing line-stage. It does not prove the full lower-scroll correction fold, manual VoiceOver traversal, real-device rendering, or release readiness.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-580 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed.
- Build-for-testing log: `.codex/xcode-logs/AMB-580/20260608T131259Z-bft-19342-5200/build-for-testing.log`
- Final focused log: `.codex/xcode-logs/AMB-580/20260608T131817Z-AmbitionsTests-CaptureRoutingPrimitiveFamilyTests-21458-29637/focused-test.log`
- Output: `Executed 4 tests, with 0 failures (0 unexpected)`
- Repair notes:
  - Removed old activated-seam confidence properties and replaced them with route-basis/review labels.
  - Replaced state and correction grids with line-stage/list primitives instead of broadening Capture domain models.
  - Reused the app-native AMB-577 Capture launch URL path to avoid external URL confirmation prompts.

## Changed Files

- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift`
- `Sources/Components/CaptureRoutingPrimitiveFamily.swift`
- `artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/codex/existing-code-champion-coverage.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now promotes `capture-routing-family` for AMB-580 and records AMB-580 proof artifacts.
- `docs/codex/concept-lock-registry.yml` now allows AMB-580 for `capture_routing` and `design_primitives`.
- `docs/codex/existing-code-champion-coverage.yml` now classifies the AMB-580 primitive source and focused test.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-580 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed before source edits; report path `build/reports/parallel-implementation-guard/AMB-580-pre.md`.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `make xcode-focused-test BATCH=AMB-580 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests` - passed; final output `Executed 4 tests, with 0 failures (0 unexpected)`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-580 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 111fa1d531ea9eaed6798489e1af1d63c16a995e` - passed; report path `build/reports/parallel-implementation-guard/AMB-580-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 111fa1d531ea9eaed6798489e1af1d63c16a995e` - passed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/App/AppShellView.swift Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift Sources/Components/CaptureRoutingPrimitiveFamily.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml docs/codex/existing-code-champion-coverage.yml artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md` - passed.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed; generated build reports were restored and not committed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-580 commit to restore the prior activated Capture seam route proof strip, placement review, correction fold, state overview, route-basis copy, registry state, concept-lock prefixes, champion coverage metadata, and focused test coverage.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png`

## Remaining Yellow Debt

- None for the AMB-580 Capture Routing primitive family scope.
- Not claimed: full lower-scroll correction fold screenshot, manual accessibility traversal, real-device rendering, performance proof, privacy/legal approval, release proof, TestFlight/App Store readiness, App Store readiness, or CI proof.

## Required Completion Footer

Verdict: Green.
Artifact paths:
- artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png
Focused tests:
- make xcode-focused-test BATCH=AMB-580 TEST=AmbitionsTests/CaptureRoutingPrimitiveFamilyTests - passed; Executed 4 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/App/AppShellView.swift
- Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift
- Sources/Components/CaptureRoutingPrimitiveFamily.swift
- artifacts/ambitions-ui-reconstruction/action-state/AMB-580-capture-routing-family.md
- artifacts/ambitions-ui-reconstruction/screenshots/capture-routing-family-amb-580.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
- docs/codex/existing-code-champion-coverage.yml
Rollback notes:
- Revert the AMB-580 commit to restore the prior activated Capture seam route proof strip, placement review, correction fold, state overview, route-basis copy, registry state, concept-lock prefixes, champion coverage metadata, and focused test coverage.
Remaining Yellow debt:
- None for the AMB-580 Capture Routing primitive family scope.
