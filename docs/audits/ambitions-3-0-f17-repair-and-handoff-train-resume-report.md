# Ambitions 3.0 F17 Repair And Handoff Train Resume Report

Date: 2026-05-01
Result: PARTIAL
Train: F17-F30 FAANG Handoff Completion Train

## Executive Verdict

The train resumed after the F17 Yellow stop and completed F17 repair, F18, F19,
and F20 as Green. It stopped at F21 Yellow because full UI smoke remains
PARTIAL.

FAANG handoff remains PARTIAL. Do not claim FAANG handoff readiness.

## Batches Attempted

- F17 repair decision: Green.
- F18 Feature-Flagged Meridian Shell Implementation: Green.
- F18.5 Shell Architecture Hardening: not triggered.
- F19 Shell Route Parity / Fallback Safety: Green.
- F20 External Surfaces Privacy-Safe Projection: Green.
- F21 Full UI Smoke Stabilization: Yellow stop.

## Ownership Decision Summary

F17 repair made shell ownership explicit:

- `AmbitionsRootView` owns root bootstrapping and high-level presentation-mode
  selection.
- `AppShellView` and the existing native `TabView` path own fallback shell
  behavior.
- Meridian owns alternate shell presentation only.
- `AppNavigationModel` and `AppExternalRoute` retain route ownership.
- Shared shell primitives own reusable visuals only.

## F18 Authorization Status

Authorized and completed.

Meridian is implemented behind a local app shell presentation mode. Native
fallback remains default. No runtime dependency, paid service, or workflow
change was added.

## Gate Results

- F17 repair: Green.
- F18: Green.
- F18.5: not triggered.
- F19: Green.
- F20: Green.
- F21: Yellow.
- F21.5: triggered, not run in this pass.
- F22-F30: not attempted.

## Commits

- `d405fa8e` Resolve F17 shell Meridian ownership
- `bfbb038b` Add feature-flagged Meridian shell
- `b759b6ec` Prove F19 shell route parity
- `8ce1b630` Prove F20 external surface privacy projection

## Validation Summary

- Build: PASS on `iPhone 17` through F20 validation.
- F18 focused shell tests: PASS.
- F19 focused route tests: PASS, `55` tests.
- F19 final UI subset proof: PASS, `3` tests.
- F20 focused external/privacy tests: PASS, `50` tests.
- F21 full wrapper: PARTIAL. Unit tests PASS, `779` tests; UI tests PARTIAL,
  `29` tests with `8` failures.
- Architecture scan: advisory/PARTIAL with pre-existing large-file and
  responsibility-review warnings.
- Doc QA: not rerun during F21 stop; known advisory backlog remains accepted
  background Yellow.

## Shell Status

- Native fallback: intact and default.
- Meridian: implemented as alternate local-flagged presentation.
- Route parity: focused tests pass.
- One-tap destination access: focused tests pass.
- External routes: App Intent, widget, notification, and deep-link lanes remain
  canonical.

## Fallback Status

Fallback remains the native five-destination `TabView`:

- Today;
- Goals;
- Capture;
- Plan;
- You.

No fallback navigation was removed.

## FAANG Handoff Status

PARTIAL.

Evidence:

- F17-F20 train gates progressed Green.
- F21 full UI smoke is not Green.
- F27 final FAANG handoff gate was not reached or rerun.

## Remaining Risks

- Full UI smoke remains failing.
- `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces` passed
  focused F19 proof but failed in full-suite order.
- Today readiness / hero / handoff UI smoke failures remain.
- Create-goal and onboarding UI smoke failures remain.
- No device, App Store, TestFlight, or public accessibility readiness claim is
  available.

## Next Exact Prompt

```text
Resume at F21.5 UI Flake / Reliability Hardening using
docs/audits/ambitions-3-0-f21-full-ui-smoke-stabilization-report.md as the
source of truth.

Do not run F22 until F21.5 is Green and the F21 gate is reclassified Green.
Do not weaken UI tests, delete tests without replacement/retirement evidence,
remove native fallback navigation, touch .github/workflows, add runtime
dependencies, or claim FAANG handoff readiness.
```
