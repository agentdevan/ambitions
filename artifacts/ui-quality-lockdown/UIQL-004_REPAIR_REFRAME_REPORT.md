# UIQL-004 Repair Reframe Report

Status: Resolved for scoped UIQL-004 closeout.
Program: UIQL
Issue: UIQL-004
Date: 2026-06-11

## Trigger

UIQL-004 exceeded three repair cycles because a newly added standalone UI test selector was compiled into `AmbitionsUITests.xctest` but returned intermittent zero-test discovery results through `scripts/ambitions-xcode-test-focused.sh`.

## What Failed

- Initial standalone selector returned `EXECUTED_TESTS=0`.
- Renamed selector also returned `EXECUTED_TESTS=0`.
- Moving the selector near the already-discovered Today UIQL selector produced one real test run, but later assertion repair returned to zero-test discovery.
- A noisy parallel unit run also returned `EXECUTED_TESTS=0`; it was not used as evidence and was rerun serially.

## What Did Not Fail

- The app build did not fail.
- The new Start Here kernel projection unit tests passed when run through exact focused selectors.
- The already-established Today UIQL preview UI test selector remained discoverable and passed after the UIQL-004 assertions were folded into it.
- The current screenshot visually showed the Start Here recommendation object with source, proof, receipt, primary action, and adjustment controls.

## Reframed Repair

The final repair removed the unstable standalone UIQL-004 UI test method and folded the Start Here recommendation object checks into `testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy`, the stable Today preview UIQL selector already covering the same preview scenario.

This keeps UI automation proof real and executed:

- Final UI automation executed one test.
- Final UI automation had zero failures.
- The executed test now asserts the UIQL-004 recommendation object evidence in addition to the UIQL-003 first-viewport checks.

## Evidence Accepted

- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-proof-via-today-ui-test-20260611T074511Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-public-focused-test-final-20260611T074834Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-004-start-here-kernel-private-focused-test-final-serial-20260611T075123Z.log`
- `artifacts/ui-quality-lockdown/screenshots/UIQL-004-start-here-recommendation-final.png`

## Evidence Rejected

The following logs are retained as repair evidence but are not used for Green:

- `UIQL-004-start-here-recommendation-object-ui-test-20260611T072225Z.log`
- `UIQL-004-start-here-recommendation-proof-ui-test-20260611T072550Z.log`
- `UIQL-004-start-here-recommendation-ui-test-final-20260611T074138Z.log`
- `UIQL-004-start-here-kernel-private-focused-test-final-20260611T074834Z.log`
- `UIQL-004-designsystem-kernel-tests-20260611T071749Z.log`

## Remaining Risk

Yellow tooling risk: focused UI test discovery for newly appended methods is unreliable in the current local wrapper/test bundle path. The safe next action is to keep future UIQL UI automation on known-discovered selectors or add a dedicated wrapper diagnostic before relying on a newly appended UI test selector.

No product Yellow is accepted for UIQL-004 scope.
