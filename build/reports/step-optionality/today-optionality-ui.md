# IOS26-T04B-B06 Today Optionality UI

Status: Yellow

## Files changed
- `Native/Ambitions/Features/Today/TodayStepReplacementSheet.swift`
- `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## What changed
- Added `Show another` as a calm secondary Today action next to `Not this`.
- Added a focused replacement sheet that keeps the original recommendation inspectable.
- Capped the replacement list at five options with labels for:
  - Best fit
  - Lighter
  - Shorter
  - No equipment
  - Needs review
- Added deadline and timeline impact copy before approval.
- Added explicit approval flow and a calm local receipt preview.
- Added Today preview fixture coverage for the replacement sheet state.

## Today optionality proof
- The replacement sheet state is built from `StepCandidate` and `StepImpactSimulation`.
- `approvedRail(from:selectedOption:)` swaps the visible hero step only after approval.
- `approvalReceiptPreview(for:)` and `approvalReceiptMessage(for:)` are backed by the existing alternate-step receipt builders.

## Validation
- Passed: `make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsTests/Today/TodayViewModelTests`
- Passed after repair: `make xcode-build-for-testing BATCH=IOS26-T04B-B06-REPAIR`
- Passed after repair: `make xcode-focused-test BATCH=IOS26-T04B-B06-REPAIR TEST=AmbitionsTests/Today/TodayViewModelTests`
- Failed: `make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsTests`
  - Failure was in existing `ActionClosureReceiptModelsTests`, not in the new Today optionality tests.
- UI lane: `make xcode-focused-test BATCH=IOS26-T04B-B06 TEST=AmbitionsUITests` failed before repair with existing broad UI-suite failures.
- UI repair attempts:
  - `make xcode-focused-test BATCH=IOS26-T04B-B06-REPAIR TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapTodayStartHereNotThisOpensReasonSheet` failed before the wrapper accessibility repair because `TodayStartHereNotThis` was not exposed from the preview state.
  - `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapTodayStartHereNotThisOpensReasonSheet CODE_SIGNING_ALLOWED=NO` was used diagnostically and interrupted after proving the wrapper-level `TodayRealityRailHero` element was swallowing the nested optionality controls.
  - After removing the swallowing wrapper identifier and making the tests request the stable preview Today scenario, the wrapper focused UI lane hung repeatedly and was terminated. It is not counted as Green proof.

## Claims allowed
- Today now has a bounded optionality path with inspectable alternatives and explicit approval semantics.
- The new Today unit tests cover the replacement sheet state and approval swap behavior.
- Build-for-testing passed after the repair.

## Claims forbidden
- No full repo-wide green claim.
- No UI-green claim for the batch yet.
- No release or accessibility completion claim.

## Yellow items
- Repo-wide unit lane still has preexisting failing tests outside this patch.
- The focused UI lane remains Yellow because the simulator wrapper hung after repair and was terminated.
- The direct diagnostic UI lane was interrupted and does not count as passing proof.
