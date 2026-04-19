# Batch 09 — Canon Batch 6 / External Action Infrastructure

## Status

Completed

## Goal

Build the reusable outside-the-app action infrastructure once so future App Intents, widgets, Live Activities, notifications, controls, and other ambient surfaces can consume the same canonical command pipeline and Now State snapshot instead of duplicating business logic.

## In Scope

- audit and harden current external routing, deep-link, action, and snapshot seams
- add an app-side canonical command pipeline backed by existing services
- refine shared deep-link, notification, widget, and future App Intent payload normalization
- expand the canonical external snapshot / Now State model with additive privacy-safe fields
- keep shared snapshot storage on the existing `SharedExternalSnapshotStore` seam
- add focused tests for command execution, route normalization, and snapshot compatibility

## Out Of Scope

- actual App Intents implementation
- widgets, Live Activities, controls, or notification UI rollout
- widget-specific command handlers or notification-only business logic
- share extension UI
- sync
- life graph / household / device work
- broad UI redesign
- speculative cross-surface features not consumed by current code or tests

## Current Repo Notes

- `AppExternalRouting` already handles deep links, notification payloads, and widget payloads.
- `AppBootstrapper` currently owns bespoke notification-action execution and should forward parsed payloads into the canonical command executor instead.
- `ExternalSurfaceSnapshot` already exports a minimal privacy-safe `nextAction` payload for shared external readers.
- `SharedExternalSnapshotStore` already defines the App Group-backed snapshot file location with an application-support fallback.
- `project.yml` already defines `AmbitionsWidgetExtension`, and both app and widget targets already include the shared App Group entitlement.
- Widget and Live Activity source should remain unchanged unless additive snapshot or URL helper compatibility requires a small compile fix.

## Exit Criteria

- one app-side command executor can perform external actions through existing Today, Goals, and Capture service seams
- deep links, notification payloads, widget payloads, and future external payloads share deterministic route normalization
- Now State snapshot additions are additive, backward-decodable, and privacy-safe
- notification actions no longer execute bespoke business logic inside `AppBootstrapper`
- no actual App Intents, new widget behavior, controls, share extension UI, sync, or new ambient surfaces are added
- generation, simulator build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Completion Notes

- Added `ExternalActionCommandService` as the app-side canonical executor for external actions, backed by the existing Today, Goals, Capture, and routing seams rather than surface-specific business logic.
- Moved notification action execution out of `AppBootstrapper`; it now forwards parsed payloads into the canonical executor before routing.
- Added deterministic route URL and payload generation for current destinations only: Today, Goals, goal detail, captures inbox, and fallback routing.
- Expanded `ExternalSurfaceSnapshot` additively with optional privacy-safe Now State fields and preserved decode compatibility for older `external_surface_snapshot.v1` payloads.
- Kept widget and Live Activity source unchanged; existing extension sources compiled against the additive snapshot model.
- Validation passed on the local available `iPhone 17` simulator because exact `iPhone 16` was not installed on this machine:
  - `xcodegen generate`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - `xcrun simctl list devices available | rg "iPhone 17|iPhone 16|iPhone 15"`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ExternalActionCommandServiceTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ExternalRoutingTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests test`
