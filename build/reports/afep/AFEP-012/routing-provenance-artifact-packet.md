# AFEP-012 Routing and Provenance Packet

Batch: `AFEP-012`
Scope: Deterministic routing projections and provenance for staged Capture inputs

## What changed

- `CaptureDraftRoutePreview` now carries staged-input projections.
- Capture preview copy now includes the staged-input visible copy, staging policy, and accessibility review summary.
- The draft route preview card renders a staging section with privacy, export, redaction, retention, and route candidate details.
- `CaptureRuntimeReceipt` and `CaptureRuntimeReplayTrace` now retain staged-input projections for inspectable replay.

## Deterministic route projection

- Each staged input projects to a fixed set of route candidates.
- Each candidate carries a route, title, and local policy labels for privacy, export, redaction, and retention.
- The preview keeps the route proof seam visible before save.
- The inspection summary keeps `SourceRecord`, `Receipt`, `ReplayTrace`, and staging visible in one place.

## Provenance labels

- Provenance labels explain where the staged input came from.
- Policy labels explain why the staged input stays local and reviewable before save.
- Accessibility review summaries explain the user-facing review posture for each staged kind.

## Validation

- `make xcode-build-for-testing BATCH=AFEP-012` - succeeded
- Focused Capture and Domain test lanes passed after the staged-input changes were compiled.
- `make xcode-focused-test BATCH=AFEP-012 TEST=AmbitionsTests/YouFeatureServiceTests` remained flaky at the wrapper level; the selected tests in the log passed after restart.

## Boundary

- No cloud, analytics, hosted inference, or server routing was introduced.
- No top-level IA or routing shell changes were made.
- No screenshot or state restoration proof was captured here.
