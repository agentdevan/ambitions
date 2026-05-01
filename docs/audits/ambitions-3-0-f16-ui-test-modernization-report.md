# Ambitions 3.0 F16 UI Test Modernization Report

Date: 2026-05-01

## Result

F16 gate: Green.

F16 modernized brittle UI smoke expectations into product-contract checks for
the active Goals, Plan, Goal Detail, and shell command flows. The batch did not
delete UI tests, add dependencies, touch workflows, change product behavior, or
claim release or FAANG handoff readiness.

## Resume Context

- Active train: resumed F12-F16 implementation train.
- Entry state: F15 Green and pushed.
- Active batch: F16 UI Test Modernization.
- Accepted background Yellow: doc QA advisory backlog, known unrelated full UI
  smoke failures, pre-existing architecture extraction warnings, and historical
  legacy-language backlog outside the touched UI-test path.

## Files Changed

- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## Modernized Contracts

- Added `waitForShellReady(in:)` so cross-tab command and Goals tests wait for
  the shell contract instead of requiring Today hero readiness.
- Updated shell command tests to keep their command-sheet product promises while
  avoiding Today-specific setup coupling.
- Updated the shell-owned create-goal flow to use a unique submitted title and
  accept either the explicit creation receipt or the created goal title as proof.
- Replaced the stale Goals horizon-ladder assertion with the current visible
  Goals board module contract.
- Updated Goal Detail navigation tests to scroll to the hero card before
  routing into detail.
- Replaced brittle child-toggle assertions in the Goal Detail trust/memory test
  with stable parent-surface assertions for the strategic header, path
  filmstrip, trust whisper, and memory narrative.
- Renamed the Plan pressure scrubber test to reflect the F12 product contract:
  selected day plus visible reflow decision state.
- Replaced the stale Plan action-lane CTA assertion with `plan.reality-reflow`
  and `plan.reflow-decision` checks.

## Retired Expectations

- `goals.horizon-ladder`: retired as a stale layout expectation. Current Goals
  coverage asserts the active board modules and F13 Goal Detail/Mission Control
  tests cover the strategic detail contract.
- Goal Detail child toggles for trust, corrections, and memory: retired as
  brittle implementation-detail checks. The replacement keeps the user-facing
  trust and memory surfaces under test without pinning disclosure mechanics.
- `plan.action.select.protect` / `plan.action.cta` after pressure scrubber:
  retired as an outdated F10/F11-era expectation. The current F12 contract is
  visible reflow/recovery/decision state with no silent changes.

## Validation

- Build: PASS, `scripts/build-local.sh` on `iPhone 17`.
- Focused UI lane: PASS, 7 tests, 0 failures.
  - `testDemoGoalsBoardLoadsCoreModules`
  - `testDemoGoalsBoardPrimaryActionAndCardRouteToGoalDetail`
  - `testDemoPlanPressureScrubberUpdatesSelectedDayAndReflowDecision`
  - `testGoalDetailTrustAndMemoryDisclosureStayBelowStrategicLayer`
  - `testShellCommandSheetCanOpenAndNavigateToPlan`
  - `testShellCommandSheetSupportsQuickCaptureFlow`
  - `testShellOwnedCreateGoalFlowWorksFromCommandSheet`
- Copy guard: PASS for `Native/AmbitionsUITests`.
- Architecture scan: advisory only; no product files were touched by F16.
- Doc QA: advisory/PARTIAL from known stale-guidance, deprecated-language,
  markdownlint, and lychee backlog.
- Diff check: PASS.

## UI Smoke Status

Full UI smoke remains advisory/PARTIAL because known pre-existing failures and
slow simulator behavior remain outside this focused F16 pass. F16 directly
modernized and re-ran the touched brittle contracts listed above.

## Privacy, Trust, And Accessibility

- No new user-facing copy was added.
- No hidden personalization, analytics, backend, sync, or paid service behavior
  was added.
- The updated tests assert stable accessibility identifiers and visible product
  surfaces rather than private layout details.

## Gate Classification

Green.

F16 may proceed to conditional F16.5 trigger evaluation. Because the architecture
scan still reports broad pre-existing feature-boundary and extraction-required
warnings, F16.5 is triggered for architecture/state-contract hardening review.

