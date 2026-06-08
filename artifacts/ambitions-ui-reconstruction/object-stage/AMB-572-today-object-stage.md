# AMB-572 Today Object-Stage Primitive

Verdict: Green

## Scope

AMB-572 replaced the remaining first-viewport Today card/container chrome with a named Reality Meridian / Start Here object-stage primitive.

This is source, focused unit-test, and local simulator screenshot evidence for the scoped Today first viewport only. It is not release proof, device proof, human visual approval, performance proof, privacy/legal approval, TestFlight readiness, App Store readiness, CI proof, or full accessibility approval.

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

- Added `TodayObjectStagePrimitiveContract.current` so the Today first viewport has an inspectable primitive contract.
- Replaced Today first-viewport fit/duration capsules and the rounded source/trust strip usage with a line-based source, freshness, receipt, and privacy relationship attached to Start Here.
- Removed the rounded on-device badge treatment from the first-viewport crown.
- Extended the focused Today test class with AMB-572 contract and registry assertions.
- Registered `today-object-stage` in the primitive invention registry and allowed AMB-572 through the Today/design primitive concept locks.

## First Viewport Proof

- Screenshot: `artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png`
- Pixel dimensions: 1170 x 2532
- Capture commands:
  - `xcrun simctl install 81485ACD-AF10-4B92-8C03-9BB8805A4A23 .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
  - `scripts/sim/simctl_screenshot.sh artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png --simulator 81485ACD-AF10-4B92-8C03-9BB8805A4A23 --diagnostic artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.diagnostic.md --retries 3`
  - `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png`
- Visual inspection result: first viewport presents one full-bleed Reality Meridian / Start Here object stage. The prior first-viewport fit/duration capsules, rounded source/trust strip items, and rounded on-device badge are not visible.

## Focused Tests

- `make xcode-focused-test BATCH=AMB-572 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests` — passed
- Final focused log: `.codex/xcode-logs/AMB-572/20260608T081500Z-AmbitionsTests-TodayRealityMeridianExperienceElevationTests-4679-32298/focused-test.log`
- Output: `Executed 6 tests, with 0 failures (0 unexpected)`

## Changed Files

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift`
- `artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `docs/codex/concept-lock-registry.yml`

## Registry Entries

- `docs/codex/ambitions_primitive_invention_registry.md` now includes `today-object-stage` in the current registry table and a detailed primitive entry.
- `docs/codex/concept-lock-registry.yml` now allows AMB-572 for `today_start_here` and `design_primitives`.

## Rollback Notes

- Revert the AMB-572 commit to restore the prior Today first-viewport source strip and local capsule treatment.
- If only proof artifacts need rollback, remove:
  - `artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md`
  - `artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png`

## Remaining Yellow Debt

- None

## Required Completion Footer

Verdict: Green
Artifact paths:
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png
Focused tests:
- make xcode-focused-test BATCH=AMB-572 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests — passed; Executed 6 tests, with 0 failures (0 unexpected)
Changed files:
- Native/Ambitions/Features/Today/DayRailViewState.swift
- Native/Ambitions/Features/Today/TodayDayRailPanels.swift
- Native/AmbitionsTests/Today/TodayRealityMeridianExperienceElevationTests.swift
- artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md
- artifacts/ambitions-ui-reconstruction/screenshots/today-object-stage-amb-572.png
- docs/codex/ambitions_primitive_invention_registry.md
- docs/codex/concept-lock-registry.yml
Rollback notes:
- Revert the AMB-572 commit to restore the prior Today first-viewport source strip and local capsule treatment.
Remaining Yellow debt:
- None
