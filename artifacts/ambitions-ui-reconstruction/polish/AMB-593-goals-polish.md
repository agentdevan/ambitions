# AMB-593 Goals Polish

Verdict: Green for AMB-593 scoped Goals first-viewport polish.

## Scope

AMB-593 polished the Goals first viewport so Constellation Atlas, equal-weight life areas, Orbital Lens context, and source / proof trust depth read as one Direction Atlas object stage.

This is source, focused XCTest, and local simulator screenshot evidence for the scoped Goals presentation change only. It is not release proof, real-device proof, TestFlight proof, App Store proof, CI proof, performance proof, privacy/legal approval, public accessibility approval, or human visual approval.

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

- Converted the Goals equal-weight life area band from horizontal scrolling into a compact equal-weight four-column grid.
- Shortened the visible life-area trace label to `Today` so the first viewport avoids clipped text while preserving full accessibility values.
- Reduced the Atlas relationship field footprint and node sizes so the proof/trust section can appear in the first viewport.
- Added inline Source and Proof trust-depth lanes inside the Atlas object header.
- Kept lower next-step and pressure lanes as secondary detail below the first proof/trust read.
- Updated the Goals object-stage contract text and focused test assertions for the compact grid and inline trust-depth surface.

## Repair Cycle

- Initial AMB-593 screenshot showed the prior horizontal life-area row cropping the third/fourth area and hiding source/proof depth under the bottom veil.
- First repair changed life areas to a two-column grid, but it pushed the Atlas object lower and still hid Source/Proof values.
- Second repair changed the life-area grid to one compact equal row and shortened trace text, but long labels still clipped and trust-depth values were too low.
- Final repair added label tightening, shortened the visible trace label to `Today`, and moved Source/Proof depth inline with the Atlas header.
- One screenshot attempt captured the loading state; it was rejected and replaced with a longer-settle loaded Goals screenshot.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface goals -AmbitionsScreenshotMode YES -AmbitionsGoalsRenderState proof-available`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`
- Visual inspection result: Goals first viewport shows Direction Atlas, four equal-weight life areas, relationship contour, primary goal context, and Source/Proof depth above the bottom veil. No generic status wall, oversized hero shell, ranked output, or generic container stack is introduced in the scoped first viewport.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-593 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed.
- Final focused log: `.codex/xcode-logs/AMB-593/20260608T195315Z-AmbitionsTests-GoalsObjectStagePrimitiveTests-57911-11722/focused-test.log`
- Output: `Executed 3 tests, with 0 failures (0 unexpected)`.

## Guard And Scan Validation

- `python3 scripts/ambitions-champion-coverage-check.py` - Green before source edits; generated report outputs were restored before commit.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-593 --prompt prompts/batches/AMB-593.md --batch-type source-changing` - Green before source edits.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-593 --prompt prompts/batches/AMB-593.md --changed-from b75119333e7211b5b276afd4746e987915c78445 --batch-type source-changing` - Green.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md prompts/batches/AMB-593.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md prompts/batches/AMB-593.md` - no blocking hits.
- `git diff --check` - clean.

## Changed Files

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `prompts/batches/AMB-593.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`

## Proof Boundaries

- Local simulator screenshot evidence proves only the scoped AMB-593 first-viewport Goals polish.
- Focused XCTest evidence proves the Goals object-stage source contract and first-stage source structure checks.
- Manual VoiceOver traversal, Dynamic Type screenshot bands, Reduce Motion walkthrough, Increase Contrast review, performance measurement, physical-device behavior, privacy/legal review, signed archive validation, TestFlight readiness, App Store readiness, CI proof, and release readiness are not claimed.

## Rollback Notes

- Revert the AMB-593 commit to restore the prior horizontal life-area row, original Atlas relationship field sizing, lower-only trust-depth lanes, prompt, report, and screenshot artifact.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`

## Remaining Yellow Debt

- None for the AMB-593 scoped first-viewport Goals polish.

## Required Completion Footer

Verdict: Green
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`
Focused tests:
- `make xcode-focused-test BATCH=AMB-593 TEST=AmbitionsTests/GoalsObjectStagePrimitiveTests` - passed; `Executed 3 tests, with 0 failures (0 unexpected)`
Changed files:
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `prompts/batches/AMB-593.md`
- `artifacts/ambitions-ui-reconstruction/polish/AMB-593-goals-polish.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/amb-593-goals-polish.png`
Rollback notes:
- Revert the AMB-593 commit to restore the prior horizontal life-area row, original Atlas relationship field sizing, lower-only trust-depth lanes, prompt, report, and screenshot artifact.
Remaining Yellow debt:
- None
