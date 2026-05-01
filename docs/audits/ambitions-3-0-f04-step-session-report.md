# Ambitions 3.0 F04 Step Session Report

Date: 2026-05-01

## Result

F04 is Green with accepted background Yellow recorded.

## Scope

F04 implemented the Today-owned Step Session rename/routing slice after F03.5:

- `Start now` now routes through `TodayEntryContext.stepSession`.
- Today action state uses `.startStepSession` for the scoped Step Session action.
- The bounded execution support surface is exposed as `TodayStepSessionState`,
  `TodayStepSessionCard`, and `today.support.step-session`.
- Legacy `.focus` entry context remains as a compatibility alias for existing
  shell and external routes until F15.

F04 did not implement Action Closure, Still Counts, Proof, Receipt Ledger, Plan
Life Suite, Shell/Meridian, runtime dependencies, workflow changes, or release
claims.

## Files Changed

- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/App/AppNavigation.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/DayRailStepDetailState.swift`
- `Native/Ambitions/Features/Today/TodayExecutionCompatibility.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## Validation

- `scripts/build-local.sh`: PASS on `iPhone 17`
- `TodayViewModelTests`: PASS, 29 tests
- `TodayFreshGoalVisibilityTests`: PASS, 5 tests
- `TodayShellIntegrationTests`: PASS, 1 test
- focused Step Session unit proof:
  `testStepSessionEntryContextSurfacesBoundedStepSession`: PASS
- `git diff --check`: PASS
- touched-path copy scan: no user-facing `Focus screenlet`, `Focus Session`,
  fake AI confidence/explanation, timer-first, or silent-automation regression
  introduced; test guard strings remain intentional
- `scripts/swiftui-architecture-scan.sh`: advisory only

## Accepted Background Yellow

- Doc QA remains advisory/PARTIAL from known markdown, deprecated-language, and
  link backlog.
- Full UI smoke has known pre-existing readiness failures.
- The focused UI smoke
  `testTodayStartNowCanOpenBoundedStepSession` failed before Step Session
  assertion because `waitForTodayScreenReady` could not establish the existing
  `today.screen` / hero readiness state.
- `TodayExecutionProjector.swift`, `TodayPanels.swift`, and
  `TodayFeatureService.swift` remain known large files. F04 did not
  significantly worsen the architecture scan; `TodayFeatureService.swift`
  changed by two lines and `TodayPanels.swift` remained at the same scan size.
- Legacy shell/external `focus` naming remains compatibility debt for F15.

## Gate Decision

F04 may be committed and the train may continue to F05 Action Closure / Still
Counts. F05 must not widen into Proof/Receipt Ledger beyond compile-safe stubs.

FAANG handoff remains PARTIAL.
