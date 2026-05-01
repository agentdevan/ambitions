# Ambitions 3.0 F21 Full UI Smoke Stabilization Report

Date: 2026-05-01
Gate: Yellow
Batch: F21 Full UI Smoke Stabilization

## Executive Verdict

F21 is Yellow.

`scripts/test-local.sh || true` completed. The unit-test lane passed, but the
full UI smoke lane remains PARTIAL with `29` UI tests run and `8` failures.
The failures overlap the known pre-F21 UI smoke backlog, but the current batch
cannot honestly claim Green because the full UI suite is still failing and the
remaining failures have not all been replaced, retired, or repaired.

The train stops here. Do not run F22 until F21 or F21.5 produces Green.

## Validation Result

- `scripts/test-local.sh || true`: PARTIAL.
- Unit tests: PASS, `779` tests, `0` failures.
- UI tests: PARTIAL, `29` tests, `8` failures.
- Test log: `output/logs/test-local-20260501-114857.log`.
- Result bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.01_11-49-03--0400.xcresult`

## Current UI Failure Set

- `testForcedOnboardingCaptureFirstPathOpensQuickCapture`
- `testPreviewBootstrapCanCreateGoalFromEmptyState`
- `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
- `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry`
- `testTodayCanHandOffToGoalDetail`
- `testTodayCanHandOffToPlan`
- `testTodayStartNowCanOpenBoundedStepSession`
- `testTodaySurfaceShowsDominantHeroAndPrimaryAction`

## Classification

Known backlog overlap:

- `testForcedOnboardingCaptureFirstPathOpensQuickCapture`
- `testPreviewBootstrapCanCreateGoalFromEmptyState`
- `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry`
- `testTodayCanHandOffToGoalDetail`
- `testTodayCanHandOffToPlan`

Renamed known Today/F04 failure class:

- `testTodayStartNowCanOpenBoundedStepSession`, replacing the older
  `testTodayStartFocusCanOpenBoundedFocusScreenlet` failure class.

Known Today readiness failure class:

- `testTodaySurfaceShowsDominantHeroAndPrimaryAction`, matching the documented
  Today `today.screen` / hero-readiness failure pattern from earlier F-series
  reports.

Suite-order / shell-smoke ambiguity:

- `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` passed
  in the F19 focused UI subset and final proof rerun, then failed in the full
  UI suite after earlier failures. This is not accepted as Green; it is a
  F21.5 trigger candidate because it behaves differently in focused and full
  suite order.

## Gate Decision

Yellow.

Reasons:

- full UI smoke still fails;
- a previously passing focused shell smoke test failed in full-suite order;
- the remaining failures are not all repaired, retired, or replaced;
- continuing to F22 would skip the F21 gate.

## F21.5 Trigger

F21.5 is triggered.

Trigger reasons:

- UI tests pass in focused lanes but fail in full suite order;
- repeated simulator/UI smoke timing ambiguity is present;
- wrapper duration is high and failure triage requires reliability hardening.

F21.5 must remain test/reliability focused. It must not weaken tests, delete UI
tests without replacement/retirement evidence, or change product behavior
broadly.

## Accepted Background Yellow

Recorded but not treated as Green:

- doc QA advisory backlog unchanged;
- pre-existing architecture warnings unchanged;
- compatibility seams unchanged;
- known full UI smoke failure class remains the active repair target.

## Next Exact Prompt

```text
Resume the F17-F30 FAANG Handoff Completion Train at F21.5 UI Flake /
Reliability Hardening.

Read:
- docs/audits/ambitions-3-0-f21-full-ui-smoke-stabilization-report.md
- docs/codex/batches/F21_5_UI_Flake_Reliability_Hardening_Prompt.md
- docs/canon/Ambitions_3_0_UI_Test_Contract.md
- Native/AmbitionsUITests/AmbitionsUITests.swift
- output/logs/test-local-20260501-114857.log

Scope:
- classify each remaining UI failure as product bug, stale selector, suite-order
  flake, or missing wait contract;
- repair only UI-test reliability or narrow product-contract waits;
- do not weaken tests to pass;
- do not delete tests without replacement/retirement evidence;
- preserve the canonical five destination shell and native fallback;
- no runtime dependencies or workflow edits.

Required validation:
- rerun focused failing UI tests individually;
- rerun the affected UI subset;
- run scripts/build-local.sh;
- run scripts/test-local.sh || true after repairs;
- update F21/F21.5 reports and tracking.

Continue to F22 only if F21.5 is Green and the F21 gate is reclassified Green.

## F21.5 Addendum

Date: 2026-05-01

F21 is reclassified Green by
`docs/audits/ambitions-3-0-f21-5-ui-flake-reliability-hardening-report.md`.

F21.5 classified all 8 original UI smoke failures, replaced stale or brittle
assertions with current product-contract assertions, did not delete any UI test,
and did not touch app behavior files.

Validation evidence:

- focused repaired UI lanes: PASS
- `scripts/test-local.sh || true`: PASS
- unit lane: `779` tests, `0` failures
- UI lane: `29` tests, `0` failures
- log: `output/logs/test-local-20260501-133620.log`

F22 may proceed after the F21.5 commit/push lands. FAANG handoff remains PARTIAL
until F27 explicitly passes.
```
