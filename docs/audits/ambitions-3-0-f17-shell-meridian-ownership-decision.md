# Ambitions 3.0 F17 Shell / Meridian Ownership Decision

Date: 2026-05-01
Gate: Green
Batch: F17 Repair Decision

## Executive Decision

F17 repair is Green.

The shell ownership ambiguity from the F17 readiness audit is resolved without
app behavior changes. F18 is authorized to implement a feature-flagged Meridian
presentation only if it follows this ownership contract and preserves the
native `TabView` fallback.

This decision does not claim FAANG handoff readiness. FAANG handoff remains
PARTIAL until F27 reruns and passes the full handoff gate.

## Ownership Contract

### AmbitionsRootView

`Native/Ambitions/App/AmbitionsRootView.swift` owns:

- app bootstrapping;
- dependency/container injection;
- root environment setup;
- onboarding presentation;
- high-level shell presentation-mode selection.

`AmbitionsRootView` must not own:

- per-destination route behavior;
- deep link translation;
- App Intent route semantics;
- widget route semantics;
- Meridian rendering details beyond choosing the active presentation mode.

F18 may add a small app-local shell presentation-mode selector here, defaulting
to native fallback. The selector must be reversible and testable without remote
configuration or new runtime dependencies.

### AppShellView

`Native/Ambitions/App/AppShellView.swift` owns:

- canonical destination composition around current feature surfaces;
- native shell scaffold behavior;
- native `TabView` fallback reachability;
- route parity coordination with the root navigation model;
- the current stable shell chrome, command sheet, memory lens, and continuity
  surfaces.

`AppShellView` remains the fallback owner for stable native navigation. F18
must not remove, rename, or hide the fallback behind an irreversible path.

### Meridian Shell

The Meridian shell owns only an alternate shell presentation.

It may:

- render an alternate destination rail or shell chrome;
- be enabled by a local feature flag, launch argument, or test/previews-only
  configuration;
- call the existing navigation model to select canonical destinations.

It must not:

- remove the native `TabView` fallback;
- duplicate route state;
- create stringly typed route expansion when a typed route exists;
- own feature-level state projection;
- make destination access indirect or puzzle-like;
- change product behavior beyond shell presentation.

### Shared Shell Primitives

Shared shell primitives under `Sources/`, `AppUI/Sources/`, and existing shell
component files own reusable visual primitives only.

They may own:

- layout primitives;
- typography, spacing, icon, and selection visuals;
- accessibility labels and identifiers for their own controls.

They must not own:

- destination business logic;
- route stacks;
- deep link, widget, or App Intent semantics;
- feature-specific view state or projection.

### Route Model

The canonical route model remains typed and app-local:

- `Native/Ambitions/App/AppTab.swift` owns canonical destination identity.
- `Native/Ambitions/App/AppNavigation.swift` owns selected tab, route stacks,
  overlays, reentry context, and compatibility normalization.
- `Native/Ambitions/App/AppExternalRouting.swift` owns external route
  translation and dispatch.

F18 must keep all destination selection funneled through `AppNavigationModel`.
Legacy `habits` and `insights` compatibility must continue to normalize to Plan
and You-owned supporting routes.

## Feature Flag Source Of Truth

F18 may introduce one app-local shell presentation-mode contract in
`Native/Ambitions/App/`.

Required properties:

- default: native fallback;
- Meridian opt-in: launch argument, test fixture, preview configuration, or an
  equivalent local debug/test switch;
- no remote configuration;
- no paid service;
- no runtime dependency;
- no workflow changes.

The feature flag must select presentation only. It must not fork route
semantics.

## Rollback Path

Rollback is a one-setting change:

1. set shell presentation mode to native fallback;
2. keep `AppNavigationModel` route state intact;
3. keep external route URLs unchanged;
4. keep App Intent and widget handoffs pointed at the existing external router.

Rollback must not require data migration, dependency changes, workflow changes,
or route rewrites.

## Fallback Path

Native fallback is the existing five-destination shell:

- Today;
- Goals;
- Capture;
- Plan;
- You.

The fallback remains available by default and must remain testable after F18.
Meridian may be enabled in previews/tests, but production default remains
native fallback unless a later Green gate explicitly changes it.

## Accessibility Fallback Requirements

F18 must preserve the native `TabView` accessibility path.

Any Meridian destination rail must provide:

- stable labels for Today, Goals, Capture, Plan, and You;
- stable accessibility identifiers;
- VoiceOver-reachable controls;
- Dynamic Type-safe labels or values;
- visible selected state without color-only meaning;
- no motion-only orientation.

If Meridian accessibility proof is incomplete, the native fallback remains the
shipping path and F18 cannot claim accessibility readiness.

## Deep Link / App Intent / Widget Implications

F18 must not change route URLs or external route ownership.

Affected surfaces remain:

- `OpenAmbitionsDestinationIntent`;
- `AppIntentLaunchRouter`;
- `DefaultAppExternalRouter`;
- widget URLs from `ExternalWidgetProjection`;
- Live Activity return URLs where present.

All external surfaces must continue to route through `AppExternalRoute` and
`AppNavigationModel`.

## F18 Allowed Files

F18 may touch:

- `Native/Ambitions/App/AmbitionsRootView.swift`;
- `Native/Ambitions/App/AppShellView.swift`;
- new app-local shell presentation files under `Native/Ambitions/App/`;
- existing reusable shell primitive files under `Sources/` or
  `AppUI/Sources/` only for presentation-only primitives;
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`;
- `Native/AmbitionsTests/App/ExternalRoutingTests.swift`;
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`;
- `Native/AmbitionsUITests/AmbitionsUITests.swift` only if needed to add
  parity coverage, not weaken or delete tests;
- F18 audit/report/tracking files.

## F18 Forbidden Files

F18 must not touch:

- `.github/workflows/**`;
- runtime dependency manifests;
- persistence migrations;
- unrelated feature screens;
- App Store or TestFlight claim docs except truthful audit reports;
- UI tests for deletion unless replacement or retirement evidence is provided.

## F18 Route Parity Requirements

F18 Green requires proof that both native fallback and Meridian-enabled paths
preserve:

- all five canonical destination selections;
- legacy `habits` to Plan compatibility;
- legacy `insights` to You/history compatibility;
- deep link dispatch through `DefaultAppExternalRouter`;
- App Intent queued URL dispatch;
- widget route handoff;
- fallback restoration without route loss.

## F19 Required Safety Tests

F19 must add or verify:

- route parity tests for native fallback and Meridian;
- fallback safety tests;
- one-tap destination access proof;
- shell rollback proof;
- accessibility navigation checks;
- state restoration review where feasible;
- deep link/App Intent compatibility checks where scoped.

## Accepted Background Yellow

These are recorded and do not block this repair because they were not worsened:

- doc QA advisory backlog unchanged;
- known full UI smoke failures before F21;
- pre-existing architecture warnings unchanged;
- compatibility seams unchanged.

## F17 Repair Gate

Green.

Reasons:

- shell ownership is explicit;
- F18 can be feature-flagged with native fallback default;
- native fallback remains intact;
- top-level destinations remain reachable;
- route parity can be tested against existing typed route owners;
- accessibility fallback is clear;
- rollback is clear;
- no dependency or workflow changes are needed;
- no app behavior changed in this repair.

F18 is authorized to start only within this contract.
