<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-036 - Live Activity experience system

Linear issue: AMB-458
Project: Ambitions Experience Sovereignty Program
Milestone: M07 - Native Platform Experience Depth

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Batch Goal

Verify Live Activity projection, lifecycle updates, copy, redaction, stale-state handling, and open/close fallback behavior for local-first continuity.

## Implementation Scope

- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/Ambitions/Notifications/NotificationRuntime.swift`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`

## Required Product Outcomes

- Live Activity states remain consistent with in-app source/reason updates.
- Privacy and redaction states are clear.
- Unavailable updates have deterministic fallback behavior.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-036/live-activity-experience-system-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-036
make xcode-focused-test BATCH=AESP-036 TEST=AmbitionsTests/App/LocalNotificationFoundationTests
make xcode-focused-test BATCH=AESP-036 TEST=AmbitionsTests/App/NotificationResponsePayloadParserTests
make xcode-focused-test BATCH=AESP-036 TEST=AmbitionsTests/App/ExternalSurfaceActionPayloadTests
make xcode-focused-test BATCH=AESP-036 TEST=AmbitionsTests
```
