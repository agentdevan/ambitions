# AMB-577 Capture Object-Stage Primitive

Verdict: Green

## Scope

AMB-577 promoted the Capture `capture-route-ribbon` primitive into a source-backed object-stage primitive for the Global Capture / Atmosphere Composer path. The Capture implementation now uses a shared `CaptureStageGroup` line-stage primitive for route reveal, placement review, continuity lines, receipts, trust seams, first-run guidance, and draft-route review instead of generic composer cards, panels, category buckets, or local draft-route containers.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Capture object-stage primitive only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `CaptureObjectStagePrimitiveContract.current` for the Global Capture / Atmosphere Composer object-stage primitive.
- Added shared `CaptureStageGroup` line-stage chrome for Capture-owned primitive sections.
- Replaced `CaptureDepthDisclosure` with `CaptureDepthDisclosureStage`.
- Replaced grouped category-style capture buckets with ordered `Continuity lines`.
- Replaced capture item card chrome with `captureStageLine`.
- Replaced Capture receipt and trust seam panels with `CaptureStageGroup`.
- Replaced the first-run guide card shell with a line-stage guide.
- Renamed the draft-route preview view from `CaptureDraftRoutePreviewCard` to `CaptureRouteStagePrimitive`.
- Replaced draft-route review, staging, placement shelf, resolver fold, and plan insertion local wrappers with `CaptureStageGroup`.
- Replaced the composer route reveal panel with a `CaptureStageGroup`.
- Added focused AMB-577 source-structure coverage to `CapturePlacementReviewStateTests`.
- Updated existing Capture view-model tests to reference `CaptureRouteStagePrimitive` and repaired obsolete literal scan terms near touched assertions.
- Promoted `capture-route-ribbon` in the primitive invention registry and allowed AMB-577 through Capture routing and design primitive concept locks.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png`
- Pixel dimensions: 1206 x 2622
- Capture commands:
  - `xcrun simctl install 8ACCD665-4807-4102-B526-5A1AE20686A8 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo SIMCTL_CHILD_AMBITIONS_LAUNCH_URL='ambitions://captures/inbox?origin=widget' xcrun simctl launch --terminate-running-process 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png --simulator 8ACCD665-4807-4102-B526-5A1AE20686A8 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png`
- Visual inspection result: the first viewport presents Capture as an activated global action seam over Today, with the route-stage primitive, local placement review, deterministic route controls, input field, and lower receipt line visible. Capture is not shown as a top-level tab, feed, chat surface, floating action button, or category grid.
- Proof boundary: this screenshot proves the scoped activated Global Capture seam and Capture object-stage primitive render. It does not claim full lower-scroll Capture review, shared shell chrome repair, device proof, human visual approval, or full accessibility signoff.
- Screenshot repair note: an initial external `simctl openurl` attempt on another simulator produced the iOS "Open in Ambitions?" confirmation prompt and was discarded. The accepted artifact uses the app-native `AMBITIONS_LAUNCH_URL` hook on a clean simulator path to avoid external URL confirmation.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-577 TEST=AmbitionsTests/CapturePlacementReviewStateTests` - passed after one compile repair cycle.
- Final focused log: `.codex/xcode-logs/AMB-577/20260608T111909Z-AmbitionsTests-CapturePlacementReviewStateTests-76997-10264/focused-test.log`
- Output: `Executed 6 tests, with 0 failures (0 unexpected)`
- Repair note: the first focused run failed during build-for-testing because `CaptureViewModelTests` still referenced the old `CaptureDraftRoutePreviewCard` type. Those references were repaired to `CaptureRouteStagePrimitive`, then the same focused command passed.

## Changed Files

- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now promotes `capture-route-ribbon` for AMB-577 and records AMB-577 proof artifacts.
- `docs/codex/concept-lock-registry.yml` now allows AMB-577 for `capture_routing` and `design_primitives`.

## Validation

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-577 --prompt docs/codex/ambitions_primitive_invention_registry.md` - passed before source edits.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed before source edits; generated build reports were restored and not committed.
- `make xcode-focused-test BATCH=AMB-577 TEST=AmbitionsTests/CapturePlacementReviewStateTests` - failed once during build-for-testing on stale type references, then passed after repair; final output `Executed 6 tests, with 0 failures (0 unexpected)`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-577 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 005c46710b6d4aa9cb4eb4d4f1111212c2bc5100` - passed; report `build/reports/parallel-implementation-guard/AMB-577-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 005c46710b6d4aa9cb4eb4d4f1111212c2bc5100` - passed.
- `bash scripts/release-claim-safety-scan.sh` - passed.
- `bash scripts/codex-forbidden-claim-scan.sh Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift Native/Ambitions/Features/Capture/CaptureScreen.swift Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift Native/AmbitionsTests/Capture/CaptureViewModelTests.swift docs/codex/ambitions_primitive_invention_registry.md docs/codex/concept-lock-registry.yml artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md` - no blocking hits.
- `python3 scripts/ambitions-champion-coverage-check.py` - passed; generated build reports were restored and not committed.
- `git diff --check` - passed.

## Rollback Notes

- Revert the AMB-577 commit to restore the prior Capture route preview card naming, generic route/review panels, capture category buckets, capture item card shell, first-run guide card shell, primitive registry state, concept-lock prefixes, and focused test assertions.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png`

## Remaining Yellow Debt

- None for the AMB-577 Capture object-stage primitive scope.
- Shared shell/tab-bar chrome, full lower-scroll Capture review, manual accessibility traversal, real-device rendering, and release proof are not claimed by this report and remain outside this issue's changed-file boundary.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png
Focused tests:
- make xcode-focused-test BATCH=AMB-577 TEST=AmbitionsTests/CapturePlacementReviewStateTests - passed; Executed 6 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift
- Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift
- Native/Ambitions/Features/Capture/CaptureScreen.swift
- Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift
- Native/AmbitionsTests/Capture/CaptureViewModelTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-577-capture-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/capture-object-stage-amb-577.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
Rollback notes:
- Revert the AMB-577 commit to restore prior Capture route preview card naming, generic route/review panels, category buckets, item card shell, first-run guide card shell, primitive registry state, concept-lock prefixes, and focused test assertions.
Remaining Yellow debt:
- None for the AMB-577 Capture object-stage primitive scope; shared shell/tab-bar chrome, full lower-scroll review, manual accessibility traversal, real-device rendering, and release proof are outside this issue.
