# AMB-573 Time Object-Stage Primitive

Verdict: Green

## Scope

AMB-573 replaced the active Time first-viewport LifeShape Field chrome with a named Time object-stage primitive.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Time first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

## Active Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## What Changed

- Added `TimeObjectStagePrimitiveContract.current` so the Time first viewport has an inspectable LifeShape Field primitive contract.
- Replaced the active Time horizon chip strip, rounded LifeShape canvas panel, source/receipt pills, capacity panel treatment, and reflow panel chrome with line, texture, and inline source/receipt relationships.
- Reworked the LifeShape semantic texture into a regular-size two-column object texture while preserving stacked Dynamic Type fallback behavior.
- Added a Time-owned bottom chrome clearance inset and veil so the first viewport proof does not depend on readable text behind shell chrome.
- Extended the focused Time test class with AMB-573 contract, registry, compact texture, Dynamic Type fallback, and bottom-clearance source assertions.
- Registered `time-object-stage` in the primitive invention registry and allowed AMB-573 through the Time/design primitive concept locks.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface time -AmbitionsScreenshotMode YES -AmbitionsTimeRenderState default`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --diagnostic artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.diagnostic.md --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png`
- Visual inspection result: first viewport presents a full-bleed LifeShape Field object stage with inline horizon control and texture rows. The active first viewport no longer depends on the old Time chip strip, rounded canvas panel, source/receipt pills, capacity panel treatment, or reflow panel chrome.
- Proof boundary: this screenshot proves the Time object-stage first viewport. It does not claim full lower-scroll reflow-detail visual approval; lower reflow copy is outside this AMB-573 object-stage proof.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-573 TEST=AmbitionsTests/TimeFeatureServiceTests` — passed
- Final focused log: `.codex/xcode-logs/AMB-573/20260608T092406Z-AmbitionsTests-TimeFeatureServiceTests-27710-9062/focused-test.log`
- Output: `Executed 48 tests, with 0 failures (0 unexpected)`

## Changed Files

- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
- `Native/Ambitions/Features/Time/TimeScreen.swift`
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now includes `time-object-stage` in the current registry table and a detailed primitive entry.
- `docs/codex/concept-lock-registry.yml` now allows AMB-573 for `time_plan_lifeshape` and `design_primitives`.

## Rollback Notes

- Revert the AMB-573 commit to restore the prior Time first-viewport horizon chip strip, rounded LifeShape canvas panel, source/receipt pills, capacity panel treatment, and reflow panel chrome.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png`

## Remaining Yellow Debt

- None for the AMB-573 Time object-stage scope.

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png
Focused tests:
- make xcode-focused-test BATCH=AMB-573 TEST=AmbitionsTests/TimeFeatureServiceTests — passed; Executed 48 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Time/TimeLifeShapeField.swift
- Native/Ambitions/Features/Time/TimeScreen.swift
- Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-573-time-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/time-object-stage-amb-573.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
Rollback notes:
- Revert the AMB-573 commit to restore the prior Time first-viewport horizon chip strip, rounded LifeShape canvas panel, source/receipt pills, capacity panel treatment, and reflow panel chrome.
Remaining Yellow debt:
- None for the AMB-573 Time object-stage scope.
