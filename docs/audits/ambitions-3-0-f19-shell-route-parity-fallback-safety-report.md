# Ambitions 3.0 F19 Shell Route Parity / Fallback Safety Report

Date: 2026-05-01
Gate: Green
Batch: F19 Shell Route Parity / Fallback Safety

## Executive Verdict

F19 is Green.

The feature-flagged Meridian shell keeps the same canonical destination model,
the same typed external routing model, and the same native fallback route path.
The native fallback remains the default. Meridian uses one-tap destination
buttons generated from `AppTab.allCases` and calls `AppNavigationModel` for
selection.

FAANG handoff remains PARTIAL.

## Scope Completed

Added route/fallback safety tests for:

- Meridian one-tap destination selection;
- shell rollback preserving existing route state;
- native fallback and Meridian sharing canonical route dispatch;
- legacy `habits` compatibility under Plan;
- legacy `insights` compatibility under You/history;
- App Intent route compatibility through the existing focused lane.

No product behavior was changed in F19.

## Route Parity

Route ownership remains:

- `AppTab` for destination identity;
- `AppNavigationModel` for selected tab, route stacks, overlays, and
  compatibility normalization;
- `AppExternalRouteTranslator` and `DefaultAppExternalRouter` for external
  route translation and dispatch.

Both native fallback and Meridian share the same route inputs. No route URL
changed.

## Fallback Safety

Fallback remains:

- default shell presentation mode: `nativeFallback`;
- rollback argument: `--ambitions-shell=native`;
- no persistence migration;
- no workflow change;
- no dependency change;
- no external route rewrite.

The rollback test proves switching shell presentation mode does not mutate
existing `AppNavigationModel` state.

## One-Tap Destination Access

Meridian destinations are generated from `AppTab.allCases`:

- Today;
- Goals;
- Capture;
- Plan;
- You.

The one-tap destination test proves each Meridian destination calls the same
canonical selection path and dismisses shell overlays without adding route
state.

## Deep Link / App Intent / Widget Compatibility

Focused routing tests prove:

- deep links still dispatch to canonical tabs;
- widget and notification payloads still route through shared payloads;
- App Intent URLs remain canonical;
- legacy compatibility tabs still land under their canonical owners.

No widget, Live Activity, App Intent, or external projection files changed in
F19.

## UI Smoke Subset

The F19 UI subset covered:

- canonical five-tab shell and secondary surfaces;
- launch URL to Plan;
- launch URL to top-level Capture.

First combined run: Plan and Capture launch URL tests passed; the canonical
five-tab test failed once. Narrow rerun of the canonical five-tab test passed.
Final proof rerun of the three-test subset passed with `3` tests and `0`
failures.

This is classified as simulator/suite timing ambiguity that was resolved by the
proof rerun, not as a current touched-scope shell regression.

## Validation

- Focused `AppShellNavigationTests` + `ExternalRoutingTests` +
  `AppIntentRoutingTests`: PASS, `55` tests, `0` failures.
- UI smoke subset final proof run: PASS, `3` tests, `0` failures.
- `scripts/build-local.sh`: PASS on `iPhone 17`.
- `scripts/swiftui-architecture-scan.sh || true`: advisory/PARTIAL with
  pre-existing large-file and responsibility-review warnings.
- `git diff --check`: PASS.

## Gate Result

Green.

Reasons:

- route parity is tested;
- fallback safety is tested;
- one-tap destination access is tested;
- legacy route compatibility is tested;
- build passes;
- no runtime dependencies, workflow files, or release-claim files changed.

Next batch: F20 External Surfaces Privacy-Safe Projection.
