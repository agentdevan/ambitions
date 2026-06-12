# UIQL-009 / AMB-964 Time Reconstruction Proof

Status: Local complete; push pending because the owner will push manually when GitHub is fixed.
Program: UIQL
Linear issue: AMB-964
Sequence label: UIQL-009
Date: 2026-06-11 America/New_York

## Claim

AMB-964 reconstructs Time as the LifeShape Field proof surface for the question, "What can my life actually hold?" The scoped repair makes the Time first viewport present a week-capacity object instead of calendar, KPI, dashboard, or metric-row anatomy.

The closing proof shows:

- `LifeShape Field` owns the Time proof object.
- The week capacity line uses the required visible structure: "This week can hold 8 focused blocks, 7 light steps, and 1 protected recovery window."
- The first viewport exposes the shaping actions `Shape week`, `Review pressure`, `Protect this block`, and `Adjust plan`.
- Pressure, manual-only source, calendar-denied/static-equivalent, and large Dynamic Type states have current screenshot proof.
- Large Dynamic Type proof shows the complete capacity sentence, including `protected recovery window`, without relying on screenshot-path proof.

## What Changed

- `Native/Ambitions/Features/Time/TimeLifeSuiteState.swift`
  - Builds a concrete week capacity statement from local active-goal/open-day/protected-recovery context.
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
  - Reorders the Time proof object so the capacity statement and shaping actions are above source/detail lanes.
  - Adds explicit shaping actions required by AMB-964.
  - Adds screenshot render-state source handling for default, manual-only, denied-source, and pressure states.
  - Adds an accessibility-size capacity proof layout so large Dynamic Type shows the complete capacity statement rather than one-word-per-line truncation.
- `Native/Ambitions/Features/Time/TimeScreen.swift`
  - Adds accessibility-size bottom scroll reserve so Time content can clear the Meridian dock.
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
  - Adds AMB-964 unit proof for week capacity language, shaping actions, and anti-dashboard contract.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Adds AMB-964 screenshot matrix proof for default week, pressure/protected, manual-only source, static denied-source equivalent, and large Dynamic Type.

## Validation

- `git diff --check`: passed.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`: passed.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/TimeFeatureServiceTests/testAMB964TimeLifeShapeFieldUsesRequiredWeekCapacityLanguageAndActions`: passed, 1 test, 0 failures. Final log: `artifacts/ui-quality-lockdown/script-output/AMB-964-time-focused-unit-tests-rerun3.log`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix -resultBundlePath artifacts/ui-quality-lockdown/script-output/AMB-964-time-screenshot-matrix-rerun14.xcresult`: passed, 1 test, 0 failures. Final log: `artifacts/ui-quality-lockdown/script-output/AMB-964-time-screenshot-matrix-rerun14.log`.

## Screenshot Proof

Final screenshot directory: `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun14/`

- Default week: `amb-964-time-default-week.png`
- Pressure/protected: `amb-964-time-pressure-protected.png`
- Manual-only source: `amb-964-time-source-unavailable-manual.png`
- Static denied-source equivalent: `amb-964-time-static-equivalent.png`
- Large Dynamic Type: `amb-964-time-large-dynamic-type.png`

Visual inspection result: Green for scoped AMB-964. The default, pressure, manual-only, and denied-source frames visibly show the LifeShape Field capacity object, required capacity sentence, and shaping actions above the dock. The large Dynamic Type frame visibly shows the full capacity sentence including `protected recovery window`; actions remain reachable below and are not used as the large-text proof claim.

## Repair Evidence

More than three repair cycles were needed. Superseded logs and screenshots are repair evidence only:

- `AMB-964-time-screenshot-matrix-rerun1.log` through `AMB-964-time-screenshot-matrix-rerun13.log`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun4/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun6/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun7/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun8/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun9/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun10/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun11/`
- `artifacts/ui-quality-lockdown/screenshots/amb-964/rerun13/`

The final closing proof uses rerun14 screenshots and the final unit test rerun3 only.

## Green / Yellow / Red

- Green: Scoped AMB-964 local product evidence, deterministic scans, focused unit test, screenshot matrix, and visual screenshot evaluation.
- Yellow: Local commit/push pending; no physical-device proof; no full accessibility certification; no VoiceOver certification; no owner approval; no release/TestFlight/App Store readiness.
- Red: None remaining for scoped AMB-964 after rerun14 visual inspection.

## Linear Closeout Text

Do not mark AMB-964 Done until this local commit is visible on `main`.

```text
AMB-964 / UIQL-009 Time Reconstruction is locally complete but not pushed yet.

Local commit: current local `HEAD` at closeout; use `git rev-parse HEAD` before manual push because amending proof metadata changes the exact hash.
Push status: pending; owner will push main manually when GitHub is fixed.

Do not move AMB-964 to Done until the commit is visible on main.

Validation:
- git diff --check: passed
- UIQL mini-regression: passed
- AMB-964 focused Time unit test: passed, 1 test / 0 failures
- AMB-964 screenshot matrix UI test: passed, 1 test / 0 failures
- Final screenshots visually inspected: passed

Artifacts:
- Proof: artifacts/ui-quality-lockdown/UIQL-009-AMB-964-time-reconstruction.md
- Repair reframe: artifacts/ui-quality-lockdown/UIQL-009-AMB-964_REPAIR_REFRAME_REPORT.md
- Final screenshots: artifacts/ui-quality-lockdown/screenshots/amb-964/rerun14/

No-claim boundaries:
- No owner approval claimed.
- No release/TestFlight/App Store readiness claimed.
- No physical-device proof claimed.
- No full accessibility or VoiceOver certification claimed.
- No Linear closure claimed until the local commit is pushed and visible on main.

Next dependency after push/Linear closeout: AMB-965 / UIQL-010 Motion Reconstruction.
```
