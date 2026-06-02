<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-037 - Notification language and timing system

Linear issue: AMB-459
Project: Ambitions Experience Sovereignty Program
Milestone: M07 - Native Platform Experience Depth

## Required Truth Checks

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`

## Batch Goal

Validate allowed triggers, copy, timing, protected-time posture, and control surfaces for local scheduling with safe defaults and recoverable behavior.

## Implementation Scope

- `Native/Ambitions/Notifications`
- `Native/Ambitions/Runtime/Notification*`
- `Native/Ambitions/App/AppExternalRouting.swift` (notification/command routing path)
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`
- `Native/AmbitionsTests/App/ExternalActionCommandServiceTests.swift`

## Required Product Outcomes

- Notification language is clear, source-aware, and tone-safe.
- Timing policy respects protected time and explicit user controls.
- Invalid payloads resolve to explicit safe fallbacks.

## Required Evidence Packet

Create: `build/reports/aesp/AESP-037/notification-language-and-timing-system-evidence.md`

## Required Validation

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AESP-037
make xcode-focused-test BATCH=AESP-037 TEST=AmbitionsTests/App/LocalNotificationFoundationTests
make xcode-focused-test BATCH=AESP-037 TEST=AmbitionsTests/App/NotificationResponsePayloadParserTests
make xcode-focused-test BATCH=AESP-037 TEST=AmbitionsTests/App/ExternalActionCommandServiceTests
make xcode-focused-test BATCH=AESP-037 TEST=AmbitionsTests
```
