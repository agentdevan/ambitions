# Ambitions 3.0 F18 Feature-Flagged Meridian Shell Report

Date: 2026-05-01
Gate: Green
Batch: F18 Feature-Flagged Meridian Shell Implementation

## Executive Verdict

F18 is Green.

Meridian is implemented as an alternate shell presentation behind an app-local
feature flag. Native `TabView` fallback remains the default path, the five
canonical destinations remain reachable, and route ownership remains in
`AppNavigationModel` and `AppExternalRoute`.

This does not claim FAANG handoff readiness. FAANG handoff remains PARTIAL.

## Implementation

Added:

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`

Updated:

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`

## Feature Flag

The feature flag source of truth is `AppShellPresentationMode`.

Default:

- `nativeFallback`

Meridian opt-in:

- launch argument `--ambitions-shell=meridian`;
- launch argument pair `--ambitions-shell meridian`;
- environment value `AMBITIONS_SHELL_PRESENTATION=enabled`;
- equivalent truthy values handled by the local resolver.

Rollback:

- pass `--ambitions-shell=native`;
- omit the flag entirely;
- use any non-Meridian value.

No remote configuration, paid service, runtime dependency, or workflow change
was added.

## Shell Behavior

Native fallback:

- existing `TabView(selection: $navigation.selectedTab)` remains present;
- fallback is the default production path;
- existing tab items and native accessibility path remain intact.

Meridian:

- hides the native tab bar only when the local Meridian mode is enabled;
- renders `AppMeridianDestinationRail` as a presentation-only rail;
- calls `navigation.selectTab(tab)` for destination changes;
- does not duplicate route state;
- does not change deep link, App Intent, widget, or Live Activity route URLs.

## Destination Access

Meridian destinations are generated from `AppTab.allCases`, which remains:

- Today;
- Goals;
- Capture;
- Plan;
- You.

No top-level destination was added or removed.

## Accessibility

`AppMeridianDestinationRail` provides:

- stable labels for each destination;
- stable accessibility identifiers;
- selected/not-selected accessibility values;
- visible selected state via fill, stroke, and foreground change;
- horizontal accommodation for larger text while native fallback remains
  available.

This is implementation evidence only, not a public accessibility verification
claim.

## Route / External Surface Impact

No route URLs changed.

No changes were made to:

- `AppExternalRouting`;
- `OpenAmbitionsDestinationIntent`;
- widget projection;
- Live Activity return URLs.

Route parity remains typed and app-local through the existing route model.

## F18.5 Trigger Evaluation

F18.5 is not triggered.

Rationale:

- no shell state ownership ambiguity remains;
- no route ownership moved into Meridian;
- feature flag default and rollback are tested;
- native fallback remains the default and remains testable;
- accessibility fallback is explicit;
- architecture scan remains advisory with the same pre-existing root shell
  responsibility-review class and no new extraction-required shell file.

## Validation

- `xcodegen generate`: PASS.
- Focused `AppShellNavigationTests`: PASS, `20` tests, `0` failures.
- Focused `ExternalRoutingTests` + `AppIntentRoutingTests`: PASS, `31` tests,
  `0` failures.
- `scripts/build-local.sh`: PASS on `iPhone 17`.
- `scripts/swiftui-architecture-scan.sh || true`: advisory/PARTIAL with
  pre-existing warnings; no new extraction-required shell file.
- `git diff --check`: PASS.
- Copy guard over touched app/test scope: advisory hits are existing test guard
  strings or unrelated app bootstrap failure-state identifiers, not new
  user-facing shell copy.

## Gate Result

Green.

Reasons:

- feature-flagged Meridian presentation exists;
- native fallback is preserved and default;
- all five canonical destinations remain reachable through the same typed
  destination set;
- route and external-surface ownership remain unchanged;
- focused shell and routing tests pass;
- build passes;
- no workflow or runtime dependency files changed.

Next batch: F19 Shell Route Parity / Fallback Safety.
