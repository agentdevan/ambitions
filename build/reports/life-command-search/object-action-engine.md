# Object Action Engine

Batch: `IOS26-T04J-B02`
Run directory: `.codex/runs/IOS26-T04J-B02/20260525T162821Z`
Starting commit: `60388bf90d3c52ea95d0b6e95323a20b14fe936f`

## Status

Yellow.

This batch is source-only and proof-boundary only. Xcode/XCTest/simulator validation is intentionally skipped in this turn because `AMBITIONS_SKIP_XCODE_TESTING=1` is set by the operator.

## Files Changed

- `Native/Ambitions/Features/Today/DayRailStepDetailState.swift`
- `Native/Ambitions/Features/Today/TodayStepDetailSheet.swift`
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`

## Implementation Behavior

- The step detail seam now speaks `Open step` instead of the older `Why this?` phrasing.
- The replacement sheet now presents the receipt/impact section as `Show impact`, with a momentum-reflow subtitle that keeps the original step move explicit.
- The five replacement options now use user-facing labels that match the object-action contract:
  - `Keep goal on track`
  - `Make original Step lighter`
  - `Continue this Step`
  - `Use this time elsewhere`
  - `Ride momentum`
- The fallback replacement behavior is keyed to blueprint kind so the label change does not alter caution semantics.

## Source Evidence

- `Native/Ambitions/Features/Today/TodayStepDetailSheet.swift` now exposes `Open step` in the title and accessibility label.
- `Native/Ambitions/Features/Today/DayRailStepDetailState.swift` now includes `Open step` in visible copy.
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift` now carries the momentum-reflow labels and impact section copy.
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift` now asserts the new labels and receipt/impact fields.

## Validation Run

- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04J-B02`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04J-B02`
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04J-B02`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04J-B02 --prompt prompts/batches/IOS26-T04J-B02-object-action-engine.md --changed-from 60388bf90d3c52ea95d0b6e95323a20b14fe936f`

## Validation Not Run

- `xcodebuild`
- `make xcode-focused-test`
- `scripts/ambitions-xcode-validate.sh`
- Any simulator, device, accessibility, performance, CI, TestFlight, or App Store lane

Reason: operator pause on Xcode testing for this batch.

## Claims Allowed

- The Today step detail and replacement seams now use the updated object-action phrasing.
- The replacement option labels and preview copy are source-level updated and test-covered.
- The batch stays local-first and does not add cloud, analytics, or hosted backend behavior.

## Claims Forbidden

- No build proof.
- No XCTest proof.
- No simulator proof.
- No accessibility proof.
- No performance proof.
- No release-readiness claim.

## Proof Boundary

- This batch records the sealed object-action wording and replacement-flow surface only.
- It does not claim the broader app is fully validated.
- `capture_routing` remains an accepted Yellow lock under `capture_root`.
