# Ambitions 3.0 F21.5 UI Flake / Reliability Hardening Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F21.5 UI Flake / Reliability Hardening

## Result

F21.5 is Green.

F21 is reclassified Green by F21.5 evidence. F22 may proceed after this report
and the tracking updates are committed and pushed.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Original F21 Result

- Full UI smoke command: `scripts/test-local.sh || true`
- Unit lane: `779` tests, `0` failures
- UI lane: `29` tests, `8` failures
- F21 gate: Yellow
- Failure log: `output/logs/test-local-20260501-114857.log`

## Failure Classification Summary

Detailed classification lives in
`docs/audits/ambitions-3-0-f21-5-ui-failure-classification.md`.

| Test | F21 class | F21.5 action |
|---|---|---|
| `testForcedOnboardingCaptureFirstPathOpensQuickCapture` | stale trust-copy expectation | Assert current local/manual trust copy and preserve quick-capture proof. |
| `testPreviewBootstrapCanCreateGoalFromEmptyState` | brittle post-submit acknowledgement wait | Add product-contract acknowledgement helper. |
| `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` | suite-order route readiness ambiguity | Add canonical destination helper and explicit fallback shell mode. |
| `testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry` | stale Today readiness plus brittle command hittability | Use Reality Rail readiness and bounded scroll-to-command action. |
| `testTodayCanHandOffToGoalDetail` | stale Today/Goal Detail handoff expectation | Replace with current Today Step Detail contract. |
| `testTodayCanHandOffToPlan` | stale Today Plan handoff lookup | Assert canonical Plan reachability after Today readiness. |
| `testTodayStartNowCanOpenBoundedStepSession` | stale downstream support-card wait | Assert current Step Detail `Start now` primary action. |
| `testTodaySurfaceShowsDominantHeroAndPrimaryAction` | stale Today hero/support identifiers | Assert Reality Rail and Now/Next/Later section contract. |

## Files Changed

Tests changed:

- `Native/AmbitionsUITests/AmbitionsUITests.swift`

Helpers changed:

- `makeApp`
- `waitForTodayScreenReady`
- `waitForCreatedGoalAcknowledgement`
- `openCanonicalDestination`
- `openTodayStepDetail`
- `todayPrimaryAction`
- existing scroll helpers used for command action hittability

App files touched:

- None

Tests retired or replaced:

- No UI tests were deleted.
- No failing result was hidden.
- Stale assertions were replaced with current product-contract assertions for
  the same user promises or the currently implemented equivalent.

## Product Promises Preserved

- First-run onboarding still proves local/manual trust posture and Capture
  handoff.
- Empty Goals still proves goal creation acknowledgement or visibility.
- The canonical five destinations remain reachable in the fallback shell.
- Today smoke now proves the Ambitions 3.0 Reality Rail signature instead of a
  retired hero-card layout.
- Today recommended work opens the current Step Detail surface and exposes
  `Start now` as the bounded execution entry point.
- Today-to-Plan smoke proves canonical Plan reachability without relying on a
  stale Today-local action identifier.

## Validation

Preflight:

- `git status --short`: clean at start
- `git branch --show-current`: `main`
- `git rev-parse HEAD`: `7d14f72ad080c6bbbd634f3ffd18762f0196504e`
- `git log -1 --oneline`: `7d14f72a Document F21 UI smoke stabilization stop`
- `.github/workflows` status: no changes
- dependency file status: no staged changes
- `scripts/validate-dev-tools.sh || true`: PASS
- `scripts/batch-train-preflight.sh || true`: PASS
- `scripts/batch-train-gate-check.sh || true`: PASS at preflight

Build:

- `scripts/build-local.sh`: PASS
- log: `output/logs/build-local-20260501-124630.log`
- post-repair build: PASS
- log: `output/logs/build-local-20260501-125223.log`

Focused UI lanes:

- Group A original F21 failures: PASS, `3` tests, `0` failures
- log: `output/logs/f21-5-focused-ui-a-20260501-125251.log`
- Group B first repair run: failed, exposing remaining stale Today contracts
- log: `output/logs/f21-5-focused-ui-b-20260501-130202.log`
- Group B rerun: `5` tests, `4` failures, confirming repair scope
- log: `output/logs/f21-5-focused-ui-b-rerun-20260501-131810.log`
- Group B rerun 2: simulator runner bootstrap exit before test execution,
  classified as tooling/simulator flake
- log: `output/logs/f21-5-focused-ui-b-rerun2-20260501-132840.log`
- Group B rerun 3 after final repair: PASS, `5` tests, `0` failures
- log: `output/logs/f21-5-focused-ui-b-rerun3-20260501-133146.log`

Full local suite:

- `scripts/test-local.sh || true`: PASS
- unit lane: `779` tests, `0` failures
- UI lane: `29` tests, `0` failures
- log: `output/logs/test-local-20260501-133620.log`
- final post-cleanup rerun: PASS
- final rerun unit lane: `779` tests, `0` failures
- final rerun UI lane: `29` tests, `0` failures
- final rerun log: `output/logs/test-local-20260501-141053.log`

Additional checks:

- `git diff --check`: PASS before full-suite run
- `scripts/batch-train-gate-check.sh || true`: advisory Yellow while working
  tree had expected in-progress F21.5 edits

## Gate Classification

F21.5 gate: Green

Reasons:

- build passes;
- focused repaired UI lanes pass;
- full local UI smoke passes;
- no app behavior files were changed;
- no test was deleted;
- stale assertions were replaced by product-contract assertions;
- no runtime dependency or workflow file was touched;
- report and tracking updates are in place for commit.

F21 reclassification: Green

Reasons:

- the original `29`-test UI smoke contract now passes in full;
- the original `8` failures are classified and repaired or replaced;
- no product promise was weakened;
- remaining F21 failures: `0`.

F22 may proceed after the F21.5 commit/push lands.

## Remaining Risks

- Doc QA advisory backlog remains accepted background Yellow.
- Pre-existing architecture scan warnings remain accepted background Yellow.
- Compatibility seams remain unchanged.
- FAANG handoff remains PARTIAL until F27 reruns and passes.
- Public accessibility, device, TestFlight, App Store, and final RC claims remain
  unclaimed without matching evidence.
