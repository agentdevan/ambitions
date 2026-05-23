# Historical Catch-Up Intake

Batch: `IOS26-T04A-B02`

## Implemented

- Added a You-owned `Life Context` catch-up surface under `What Ambitions Knows`.
- Added a progressive disclosure model for stable basics, mobility and access, history and limits, and sensitive eligibility context.
- Added editable local-fact affordance paths for each visible prompt.
- Added a typed Capture background-fact route marker for `Needs a Place` and `Needs Review`.
- Kept sensitive runtime use blocked by default unless explicitly allowed.

## Local-fact coverage

- Profile updates: age or birthday, life stage, school or work status, timezone and location, transportation access, travel radius.
- Opportunity updates: facilities and equipment access.
- Historical fact updates: experience, prior attempts, blockers, deadlines, assumptions, and older context that should be reviewed.
- Eligibility updates: sex or eligibility context only when materially relevant.

## Verification status

- Source implemented in the approved You and Capture boundaries only.
- `xcodegen generate` passed during the runner-governed B02 session.
- `scripts/build-local.sh` passed during the runner-governed B02 session.
- `make xcode-build-for-testing BATCH=IOS26-T04A-B02-REPAIR11` passed after a clean DerivedData build.
- `make xcode-focused-test BATCH=IOS26-T04A-B02-FINAL2 TEST=AmbitionsTests` passed.
- `git diff --check` passed.
- `make xcode-focused-test BATCH=IOS26-T04A-B02-FINAL TEST=AmbitionsUITests` did not pass as a full-suite proof. It reported five broad harness failures outside the B02 Life Context surface: `testDemoTimePressureScrubberUpdatesSelectedDayAndReflowDecision`, `testDemoTimeWorkspaceShowsBatch49CoreModules`, `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`, `testTodayCanHandOffToGoalDetail`, and `testTodayStartNowCanOpenBoundedStepSession`. Those failures are not claimed as repaired by this batch.

## Claim boundary

- Claimed: the You dashboard can project saved local Life Context bundles into a visible `Life Context` / `Catch Me Up` review surface with source, freshness, runtime-use, edit, pause, and delete affordance labels.
- Claimed: Capture has typed background-fact route markers for Needs Place and Needs Review instead of string-only routing.
- Claimed: sensitive Life Context facts remain blocked from runtime use unless explicit permission is present in the underlying local bundle.
- Not claimed: a production-complete interactive intake wizard, full UI accessibility verification, full AmbitionsUITests suite health, App Store readiness, external opportunity discovery, or medical/legal/recruiting advice.

## Notes

- Catch Me Up is surfaced as calm local context, not a chat transcript and not a new top-level destination.
- Edit, pause, and delete paths remain visible where the facts are shown.
