# AMB-1813 UI Test Monolith Split Inventory

Status: Implemented Yellow

AMB-1813 inventories the current UI test suite shape and moves one low-risk launch URL journey out of the `AmbitionsUITests` monolith into a named focused lane without weakening its assertions.

## Current Inventory

| File | Role | Tests | Lines |
| --- | --- | ---: | ---: |
| `Native/AmbitionsUITests/AmbitionsUITests.swift` | Legacy catch-all UI test monolith | 61 | 3215 |
| `Native/AmbitionsUITests/LaunchURLFocusedUITests.swift` | First focused launch URL lane | 1 | 60 |
| `Native/AmbitionsUITests/DeterministicScreenshotLaneUITests.swift` | Deterministic screenshot lane | 1 | 102 |
| `Native/AmbitionsUITests/VisualTargetAttachmentUITests.swift` | Rendered proof screenshot attachments | 2 | 121 |
| `Native/AmbitionsUITests/FirstViewportCopyBudgetUITests.swift` | Focused first-viewport copy budget | 1 | 24 |
| `Native/AmbitionsUITests/ProductObjectDominanceUITests.swift` | Focused product-object dominance | 1 | 20 |
| `Native/AmbitionsUITests/SingleCrownOwnershipUITests.swift` | Focused crown ownership | 1 | 19 |

## Split Lane

- New lane: `AmbitionsUITests/LaunchURLFocusedUITests/testLaunchURLCanLandOnCanonicalTimeSurface`
- Removed from monolith: `AmbitionsUITests/AmbitionsUITests/testLaunchURLCanLandOnCanonicalTimeSurface`
- Journey: `ambitions://tab/time` opens the canonical Time surface.
- Parity preserved: preview bootstrap, launch URL, Time root destination assertion, selected Time surface assertion, and `time.screen` existence assertion.
- Failure visibility preserved: the focused lane keeps `continueAfterFailure = false` and names the journey directly in the class and test identifier.

## Remaining Debt

- `AmbitionsUITests.swift` remains the monolith and still needs Today, Goals, Time, You, Capture, shell, onboarding/offline, widget, deep-link, and helper extraction leaves.
- Shared UI test launch/wait helpers remain inside the monolith for now. This slice duplicates only the minimal launch URL helpers needed to avoid moving shared helper authority prematurely.
- No full UI suite Green, Visual Green, Release Green, or coverage-parity Green is claimed.

## Closeout Validation

- XCTest/UI execution: not run under the current user instruction authorizing issue completion without testing.
- `xcodegen generate`: passed; generated project had no diff.
- `swiftc -parse Native/AmbitionsUITests/LaunchURLFocusedUITests.swift`: passed.
- `python3 scripts/ambitions-remediation-governance-check.py`: GREEN.
- `python3 scripts/ambitions-quality-gate.py`: GREEN.
- `git diff --check && git diff --cached --check`: passed.
- `scripts/ambitions-xcode-sim-health.sh --json --timeout 20s`: passed after clearing active Xcode blockers with the repo repair path.
