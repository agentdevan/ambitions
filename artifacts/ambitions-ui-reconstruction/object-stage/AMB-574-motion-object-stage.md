# AMB-574 Motion Object-Stage Primitive

Verdict: Green

## Scope

AMB-574 replaced the active Motion first-viewport lane card/panel chrome with a named Motion Current object-stage primitive.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Motion first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `MotionObjectStagePrimitiveContract.current` so the Motion first viewport has an inspectable Motion Current primitive contract.
- Replaced the active Motion field panel, lane cards, lane state-row panels, trace pills, and source/proof/receipt panel chrome with line, texture, and inline source/proof/receipt relationships.
- Reworked the Motion Current field into a full-bleed proof-thread texture while preserving static Reduce Motion marks and stronger Increase Contrast rules.
- Replaced lane card and row-panel backgrounds with Motion-owned top/bottom rules plus left-thread markers.
- Added Motion-owned bottom chrome clearance and a veil so the first viewport proof does not depend on readable lane text behind shell/tab-bar chrome.
- Extended the focused Motion test class with AMB-574 contract, registry, source-structure, and bottom-clearance assertions.
- Registered `motion-object-stage` in the primitive invention registry and allowed AMB-574 through the design primitive concept lock.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface motion -AmbitionsScreenshotMode YES -AmbitionsMotionRenderState proof`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png`
- Visual inspection result: first viewport presents a Motion Current object stage with a full-bleed proof-thread field, source/proof/receipt relationships, and first lane entry rendered without the prior rounded Motion field panel, lane cards, lane row panels, trace pills, or source/proof/receipt panel chrome.
- Proof boundary: this screenshot proves the Motion object-stage first viewport. It does not claim full lower-scroll lane visual approval or shared shell/tab-bar chrome repair; inherited native tab-bar chrome remains outside this AMB-574 object-stage proof.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-574 TEST=AmbitionsTests/MotionCurrentScreenTests` — passed
- Final focused log: `.codex/xcode-logs/AMB-574/20260608T095832Z-AmbitionsTests-MotionCurrentScreenTests-42042-20442/focused-test.log`
- Output: `Executed 11 tests, with 0 failures (0 unexpected)`

## Changed Files

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now includes `motion-object-stage` in the current registry table and a detailed primitive entry.
- `docs/codex/concept-lock-registry.yml` now allows AMB-574 for `design_primitives`.

## Rollback Notes

- Revert the AMB-574 commit to restore the prior Motion first-viewport field panel, lane cards, lane state-row panels, trace pills, and source/proof/receipt panel treatment.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png`

## Remaining Yellow Debt

- None for the AMB-574 Motion object-stage scope.
- Shared shell/tab-bar lower-viewport polish is not claimed by this report and remains outside this issue's changed-file boundary.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png
Focused tests:
- make xcode-focused-test BATCH=AMB-574 TEST=AmbitionsTests/MotionCurrentScreenTests — passed; Executed 11 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift
- Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/motion-object-stage-amb-574.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
Rollback notes:
- Revert the AMB-574 commit to restore the prior Motion first-viewport field panel, lane cards, lane state-row panels, trace pills, and source/proof/receipt panel treatment.
Remaining Yellow debt:
- None for the AMB-574 Motion object-stage scope; shared shell/tab-bar lower-viewport polish is outside this issue.
