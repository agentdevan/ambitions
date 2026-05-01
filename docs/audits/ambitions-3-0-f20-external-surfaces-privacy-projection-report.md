# Ambitions 3.0 F20 External Surfaces Privacy-Safe Projection Report

Date: 2026-05-01
Gate: Green
Batch: F20 External Surfaces Privacy-Safe Projection

## Executive Verdict

F20 is Green.

App Intents, shortcuts, widgets, Live Activities, notification/widget payloads,
and shared external snapshots remain routed through canonical app routes and
privacy-safe projections. A new focused proof confirms that widget and Live
Activity display strings generated from a sensitive goal do not expose the
user-entered goal title, step title, goal ID, or step ID.

This does not claim platform/device readiness. FAANG handoff remains PARTIAL.

## Scope Completed

Updated:

- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`

The implementation surface was already privacy-safe, so F20 added fresh
evidence rather than broad behavior changes.

## External Surface Map

- App Intents: `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- Shortcut descriptors: `AmbitionsAppShortcutDestination`
- External route translation: `Native/Ambitions/App/AppExternalRouting.swift`
- Shared snapshots: `Native/Ambitions/ExternalSnapshots/`
- Widgets: `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- Live Activities: `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`

## Privacy Projection Proof

The focused snapshot test now verifies:

- encoded external snapshots omit user-entered sensitive goal and step titles;
- widget title/detail/lock detail/privacy/accessibility strings omit sensitive
  titles and internal IDs;
- Live Activity title/detail/privacy/state strings omit sensitive titles and
  internal IDs;
- route URLs remain canonical handoffs back into Ambitions.

Sensitive goal and step IDs may remain route references for in-app handoff, but
they are not displayed as external surface text by the generated projections.

## Route Handoff Proof

Focused route tests prove:

- App Intent URLs use canonical routes;
- deep links route through `AppExternalRouteTranslator`;
- notification and widget payloads share route payload shapes;
- legacy compatibility routes still normalize to canonical destinations;
- widget fallback opens Today when no snapshot exists.

## Privacy / Trust Boundaries

F20 did not add:

- backend sync;
- account behavior;
- AI/model claims;
- notification authorization claims;
- device/platform readiness claims;
- paid services;
- runtime dependencies.

External surfaces continue to state privacy-safe summaries and route users back
into the app for detail.

## Validation

- Focused external/privacy test lane: PASS, `50` tests, `0` failures.
- `scripts/build-local.sh`: PASS on `iPhone 17`.
- `scripts/swiftui-architecture-scan.sh || true`: advisory/PARTIAL with
  pre-existing large-file and responsibility-review warnings.
- Copy guard over touched external/privacy scope: only intentional sensitive
  test fixtures with negative assertions.
- `git diff --check`: PASS.

## Gate Result

Green.

Reasons:

- privacy-safe projection tests pass;
- App Intent tests pass;
- widget/external tests pass;
- build passes;
- no sensitive lock-screen or external text leakage was found in generated
  projections;
- no workflow or dependency files changed.

Next batch: F21 Full UI Smoke Stabilization.
