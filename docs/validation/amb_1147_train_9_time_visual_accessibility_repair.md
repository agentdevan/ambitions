# AMB-1147 Train 9 Time Visual, Accessibility, and State-Coherence Repair

Date: 2026-06-20

Issue: AMB-1147

Scope: Train 9 conditional repair for Time Refraction only. This note records bounded product-source, UI-test, and focused-runner repairs that close the AMB-1146 screenshot/accessibility proof gap for Time. It is not release readiness, TestFlight, App Store, device, legal, or full accessibility-compliance proof.

Baseline HEAD before this slice: `c504a5c0042b81154ea808a1574bdc3f8a7d68f6`

## Repairs Made

- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift`
  - Manual-only and calendar-denied Time source states now render state-specific source/receipt copy through the first-party LifeShape Field source row.
  - The row now exposes `Manual Time source`, `Calendar denied`, `Manual mode`, `User choice`, and source/privacy detail according to the active render state instead of always showing generic receipt copy.
- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift`
  - The LifeShape Field crown now uses an accessibility-size layout that gives the product-object name its own line.
  - This fixed the visually inspected XXXL/Dynamic Type screenshot where `LifeShape Field` previously truncated as `Life-Shape F...`.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - The AMB-964 Time screenshot matrix relaunches only the large Dynamic Type screenshot capture after completing scroll-based assertions, so the retained visual artifact is a clean first-viewport proof frame.
  - The horizon Month selected-state assertion now accepts semantic selected state from either `isSelected` or an accessibility value containing `Selected`; the previous exact-value assertion rejected the richer accessibility value.
- `scripts/ambitions-xcode-test-focused.sh`
  - The focused runner now treats XCTest failure lines in a successful shell exit log as failure. This prevents false Green when `xcodebuild` produces an XCTest assertion failure but exits 0.

## Focused Evidence

Initial failure that drove the product repair:

- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix --timeout 20m --kill-after 60s`
- Result bundle: `.codex/xcode-results/TRAIN_09_TIME_REPAIR/20260620T115541Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-21443-713/focused-test.xcresult`
- Log: `.codex/xcode-logs/TRAIN_09_TIME_REPAIR/20260620T115541Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-21443-713/focused-test.log`
- Failure: missing required AMB-964 copy `Manual Time source` in `source-unavailable-manual`.
- Runner gap observed: summary reported passed despite the XCTest failure; the focused runner was repaired in this slice.

Initial interaction failure that drove the selected-state assertion repair:

- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testDemoTimeHorizonControlsAndChangeReviewSeamStayInteractive --timeout 15m --kill-after 60s`
- Result bundle: `.codex/xcode-results/TRAIN_09_TIME_REPAIR/20260620T121542Z-AmbitionsUITests-AmbitionsUITests-testDemoTimeHorizonControlsAndChangeReviewSeam-28444-24149/focused-test.xcresult`
- Failure: Month horizon exposed selected state as `Capacity: 8 active goals keep the life view meaningful.. Selected`, not exact string `selected`.

Final passed screenshot matrix:

- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix --timeout 20m --kill-after 60s`
- Summary: `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/focused-test-summary.json`
- Result bundle: `.codex/xcode-results/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/focused-test.xcresult`
- Extract summary: `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/summary.json`
- Status: passed, `executed_tests=1`.

Final screenshot artifacts visually inspected:

- `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/screenshots/amb-964-time-default-week_0_A1CA8402-B999-45A7-9E8B-135C1BAC7A02.png`
- `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/screenshots/amb-964-time-pressure-protected_0_43CD42D6-12FD-4193-AA76-40C1E11E7B19.png`
- `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/screenshots/amb-964-time-source-unavailable-manual_0_217AABDE-EE4A-41B5-97A0-3ADE2DF86BD0.png`
- `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/screenshots/amb-964-time-static-equivalent_0_8467E781-EB34-4614-8BF3-23361544C44B.png`
- `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123256Z-AmbitionsUITests-AmbitionsUITests-testAMB964TimeReconstructionScreenshotMatrix-35860-29182/extract/screenshots/amb-964-time-large-dynamic-type_0_23152FBA-2596-4585-9CBD-2C89476C1373.png`

Visual review notes:

- Default week, pressure, manual-source, and denied-source states show the Time surface as LifeShape Field, not a KPI dashboard, calendar grid, or generic task stack.
- Manual-source and denied-source states are visible in the first viewport through state labels; detailed source/privacy copy is asserted by the UI test after scrolling.
- The Dynamic Type accessibility-size artifact now keeps `LifeShape Field` readable, keeps the `Pressure` state readable, keeps horizon controls inside the viewport, and keeps the root dock safe. The capacity card continues below the viewport at the largest tested size and remains scrollable.
- No screenshot was treated as proof until visually inspected.

Final passed interaction seam:

- Command: `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testDemoTimeHorizonControlsAndChangeReviewSeamStayInteractive --timeout 15m --kill-after 60s`
- Summary: `.codex/xcode-summaries/TRAIN_09_TIME_REPAIR/20260620T123934Z-AmbitionsUITests-AmbitionsUITests-testDemoTimeHorizonControlsAndChangeReviewSeam-37717-21451/focused-test-summary.json`
- Result bundle: `.codex/xcode-results/TRAIN_09_TIME_REPAIR/20260620T123934Z-AmbitionsUITests-AmbitionsUITests-testDemoTimeHorizonControlsAndChangeReviewSeam-37717-21451/focused-test.xcresult`
- Status: passed, `executed_tests=1`.

## Validation

Passed:

- `git diff --check`
- `python3 scripts/ambitions-quality-gate.py --max-per-gate 20`
- `find Native/Ambitions -path '*Features*' -type f -name '*.swift'`
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testAMB964TimeReconstructionScreenshotMatrix --timeout 20m --kill-after 60s`
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_09_TIME_REPAIR --test AmbitionsUITests/AmbitionsUITests/testDemoTimeHorizonControlsAndChangeReviewSeamStayInteractive --timeout 15m --kill-after 60s`

## Accessibility Notes

- Automated UI proof covers Dynamic Type via `UICTContentSizeCategoryAccessibilityXL`.
- Automated UI proof covers semantic Time state/action availability through accessibility identifiers and selected-state values for the LifeShape Field, horizon controls, source states, action controls, and change-review seam.
- Manual VoiceOver rotor traversal, Reduce Transparency, Increase Contrast, and Reduce Motion device-setting screenshots were not run in this slice. Source behavior for contrast and motion remains guarded by existing environment usage in Time product-object code, but this note does not claim full manual accessibility compliance.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `DesignSystem/ProductObjects`, `Native/AmbitionsUITests`, `scripts`, `docs/validation`.
- Files moved or created: one validation note created; no source files moved.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- `Features/` Swift count after validation: zero.
- No equivalent-folder interpretation was used. Time remains under the canonical Time surface and LifeShape Field product-object ownership.

## File Size / Extraction Law

- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift`: 277 LOC.
- `Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift`: 276 LOC.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`: 2347 LOC existing test harness; touched only bounded AMB-964/Time interaction sections.
- `scripts/ambitions-xcode-test-focused.sh`: 177 LOC.

Touched production Swift files remain under 400 LOC.

## Remaining Non-Claims

- This is not a full regression run.
- This is not device proof.
- This is not release Green, TestFlight readiness, App Store readiness, privacy/legal proof, or full accessibility-compliance proof.
- This does not complete Trains 10-13.

## Rollback

Rollback can revert this slice without schema migration. Risk is limited to Time LifeShape Field state rendering, focused UI test assertions/capture behavior, and focused-runner failure classification. If reverted, AMB-1146 reopens the Train 9 proof gap for manual-source copy, Dynamic Type visual proof, and false-Green XCTest detection.
