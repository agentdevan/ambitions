# PFC20 Notifications / Calendar / Reminders Implementation Proof Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Batch: PFC20 Notifications / Calendar / Reminders Implementation Proof
Owner: Integrations / Notifications / EventKit / Privacy

## Summary

PFC20 hardened the existing notification, Calendar, and Reminders source seams
without adding Focus Filters, onboarding prompts, entitlements, signing, project
changes, dependencies, persistence/schema changes, sync/account/backend
behavior, or release claims. Notification copy now hides ambient private detail
by default, notification mutation actions route into Ambitions instead of
mutating in the background, and EventKit notes remain minimal and explicitly
request-grounded.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_Notifications_Focus_Calendar_Reminders_Strategy.md`
- `docs/audits/pfc19-notifications-focus-calendar-reminders-strategy-report.md`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Notifications/NotificationRuntime.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`
- `Native/AmbitionsTests/App/ExternalActionCommandServiceTests.swift`
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
- `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift`
- `Native/AmbitionsTests/App/CalendarRealityServiceTests.swift`

## Files Changed

- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/App/ExternalActionCommandServiceTests.swift`
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
- `docs/codex/batches/PFC20_Notifications_Calendar_Reminders_Implementation_Proof_Prompt.md`
- `docs/audits/pfc20-notifications-calendar-reminders-implementation-proof-report.md`
- train-state, registry, context, dependency, and global-order docs

No entitlement, signing, project, workflow, dependency, privacy manifest,
persistence schema, sync/account, backend, AI/LDI runtime, Focus Filter,
onboarding prompt, App Store Connect, or release file changed.

## Implementation

- `NextStepLocalNotificationPlanner` no longer uses ambient focus title/detail
  in notification title or body copy.
- Notification body copy now uses private-by-default language:
  `Details stay private until you open Ambitions.`
- The notification closure action is titled `Close the loop` and opens
  Ambitions for review.
- `ExternalActionCommand(notificationPayload:)` now maps notification-origin
  completion, snooze, delay, and smaller-step actions to app routes rather than
  background mutation.
- EventKit reminder/calendar notes now record only that Ambitions created the
  item after an explicit request plus the Ambitions step ID.
- Focused tests prove ambient notification detail suppression, notification
  mutation routing, explicit EventKit note posture, Plan-owned Calendar access,
  Today Calendar denial, and raw calendar-title redaction in derived busy time.

## Tests Run

- `git status --short`
- `git diff --check`
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/LocalNotificationFoundationTests -only-testing:AmbitionsTests/NotificationResponsePayloadParserTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests -only-testing:AmbitionsTests/EventKitIntegrationServiceTests -only-testing:AmbitionsTests/CalendarReminderActionFlowTests -only-testing:AmbitionsTests/CalendarRealityServiceTests`
- `scripts/build-local.sh`
- PFC20-targeted CQS scans
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

- Green.
- `git diff --check` passed.
- Focused Xcode tests passed: `LocalNotificationFoundationTests`,
  `NotificationResponsePayloadParserTests`, `ExternalActionCommandServiceTests`,
  `EventKitIntegrationServiceTests`, `CalendarReminderActionFlowTests`, and
  `CalendarRealityServiceTests` executed 30 tests with 0 failures. Result
  bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.06_11-26-27--0400.xcresult`.
- `scripts/build-local.sh` passed and generated
  `output/logs/build-local-20260506-112929.log`; the build compiled and
  validated the app, widget extension, share extension, and App Intents metadata
  extraction.
- PFC20-targeted CQS privacy/security claim scans reported
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0` for notification source, external-action
  source, EventKit source, focused tests, prompt, and report.
- PFC20-targeted CQS product-drift scan on notification source reported
  `CQS_PRODUCT_DRIFT_HITS=0`.
- `scripts/cqs-accessibility-motion-scan.sh || true` reported existing broad
  advisory hits across `Native/Ambitions`. PFC20 adds source proof that
  notification copy hides private ambient detail, but manual notification
  VoiceOver, Dynamic Type, Reduce Motion, contrast, truncation, and real
  platform proof remain Yellow-owned.
- `scripts/cqs-performance-budget-scan.sh || true` reported existing broad
  advisory hits. PFC20 adds no background refresh loop, broad calendar scan,
  Focus Filter runtime, network work, or high-frequency notification path.
- `scripts/run-doc-qa.sh || true` completed with advisory stale-guidance,
  deprecated-language, markdownlint backlog, and lychee 0 errors / 1 redirect.
  Logs:
  `docs/audits/doc-qa/20260506-112950-stale-guidance.log`,
  `docs/audits/doc-qa/20260506-112950-deprecated-language.log`,
  `docs/audits/doc-qa/20260506-112950-markdownlint.log`, and
  `docs/audits/doc-qa/20260506-112950-lychee.log`.
- `scripts/batch-train-gate-check.sh || true` completed with the expected
  working-tree Yellow hint before commit.

## Repairs Attempted

- Repaired notification copy so private ambient focus detail is not surfaced in
  notification title/body output.
- Repaired notification-origin mutation posture so notification actions route
  into Ambitions rather than silently completing or deferring work.
- Repaired EventKit note content so reminder and event notes are minimal and
  explicit-request grounded.

## Remaining Yellow Items

- Physical notification delivery remains unproven.
- Real-device notification actions remain unproven.
- Physical-device Calendar/Reminders permission and save behavior remains
  unproven.
- Focus Filter implementation remains deferred.
- Manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and truncation review
  remain human/operator proof.
- App Store/TestFlight/release readiness, legal/privacy compliance, final
  privacy-label truth, and public accessibility conformance remain blocked.

## Red Classification

No Red. Notification private-detail exposure, hidden notification mutation,
silent Calendar/Reminders writes, Focus Filter implementation without proof,
entitlement/signing/project changes, unsupported release claims, or device proof
claims without evidence would be Hard Red.

## Rollback Path

Revert the PFC20 commit to restore prior notification copy, notification action
mapping, EventKit notes, focused tests, and PFC20 prompt/report/train-state
updates. No entitlement, signing, project, workflow, dependency, schema, or
generated rollback is needed.

## Next Eligible Batch

PFC22 StoreKit Entitlement Implementation And Tests, or monetization deferral.
