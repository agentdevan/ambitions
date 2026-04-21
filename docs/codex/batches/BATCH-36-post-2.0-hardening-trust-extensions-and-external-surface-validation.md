# Batch 36 — Post-2.0 Hardening 02 / Trust, Extensions, and External Surface Validation

## Status

Completed

## Goal

Validate and productize external and trust surfaces against the settled shell, closing truth gaps around share extension, App Intents, widgets, notifications, external routing, and platform-facing claims.

This batch is the second step of the post-2.0 whole-repo/app hardening wave. It should begin only after Batch 35 has stabilized shell truth and Plan canon recovery.

## In Scope

- share extension truth and productization
- App Intents truth and productization
- widgets, notifications, and external-routing validation
- platform-facing trust claims and external-surface truth reconciliation
- shell-aligned validation of external entry points

## Out Of Scope

- new intelligence systems
- speculative new platform surfaces or device programs
- broad shell redesign
- secondary-surface maturity work that belongs in Batch 37
- release-readiness consolidation work that belongs in Batch 38

## Dependency Rules

- do not start this batch until Batch 35 has settled shell truth
- validate external surfaces against the settled shell rather than a moving IA target
- keep the work focused on truth, trust, and productization
- do not pull the later UI/UX excellence wave into this batch

## Exit Criteria

- external surfaces are validated against the settled shell
- share extension and App Intents no longer live in product-truth limbo
- widgets, notifications, and external routes have truthful platform-facing claims
- major trust gaps across external surfaces are closed or explicitly downgraded in truth
- Batch 37 can productize weaker internal surfaces on top of a truthful shell and truthful external boundary

## Validation

- docs/control-file truth checks for touched planning files
- targeted external-surface verification appropriate to the eventual implementation scope
- do not mark this batch completed until platform-facing claims are validated truthfully

## Completion Rule

Batch 36 is complete only when external and trust surfaces are truthful, validated against the stabilized shell, and no longer depend on unresolved shell-level ambiguity.

## Completion Summary

- Centralized external-surface truth wording across Profile, previews, placeholders, and docs.
- Added a narrow Profile trust surface that reflects notification authorization without turning Profile into a broader integration center.
- Kept Share Extension explicitly unshipped in product copy and documentation.
- Shipped App Intents only as navigation-only shortcuts bounded to Today, Plan, and the Captures inbox.
- Preserved centralized routing through `AppExternalRouting` and the shared launch/bootstrap seam.
- Fixed the missing `ambitions://` URL registration so real OS-surface deep links can open the app.

## Validation Outcome

- Passed `xcodegen generate`.
- Passed native simulator build for `Ambitions`.
- Passed targeted external-surface/unit coverage, including routing, payload, snapshot, notification, Profile-truth, and App-Intent routing tests.
- Passed `AmbitionsUITests`, including canonical landing coverage for `ambitions://tab/plan` and `ambitions://captures/inbox`.
- Passed full `AmbitionsTests` (`340` tests, `0` failures) after rerunning the unit suite on its own following a killed runner caused by parallel test execution.
- Confirmed shared snapshot export in the App Group container and real OS-level `ambitions://` route registration with `simctl openurl`.

## Conservative Surfaces After Wrap-Up

- Widgets and Live Activity remain described as `Available in this build, pending Batch 36 validation`.
- Notifications remain described as `Available in this build, pending Batch 36 validation`.
- App Intents remain described as `Available in this build, pending Batch 36 validation` even though the navigation-only implementation shipped.

These surfaces stay conservative because full manual platform confirmation of widget rendering/tap behavior, Live Activity appear-update-end behavior, notification authorization UX in Profile, and App Shortcuts visibility/opening could not be completed reliably in this environment.
