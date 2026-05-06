# PFC20 Notifications / Calendar / Reminders Implementation Proof Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Green as bounded notification, calendar, and reminders
implementation proof.
Date: 2026-05-06
Train: PFC01-PFC40 Platform / Framework / Compliance Completion Train
Owner: Integrations / Notifications / EventKit / Privacy

## Purpose

Implement or repair the existing notification, Calendar, and Reminders seams so
the PFC19 strategy remains source-enforced, privacy-safe, and testable.

PFC20 does not approve Focus Filter implementation, onboarding permission
prompts, silent calendar writes, silent reminder writes, entitlements, signing,
project wiring, release readiness, App Store readiness, TestFlight readiness,
physical-device proof, public accessibility conformance, legal/privacy
compliance, or final privacy-label truth.

## Source Truth

Read before execution:

- `docs/canon/Ambitions_Notifications_Focus_Calendar_Reminders_Strategy.md`
- `docs/audits/pfc19-notifications-focus-calendar-reminders-strategy-report.md`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Notifications/NotificationRuntime.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- focused notification, external-action, Calendar, and Reminders tests

## Allowed Files

- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Services/ExternalActionCommandService.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- focused notification, external-action, Calendar, and Reminders tests
- PFC20 prompt/report and train-state docs

## Forbidden Files

- Focus Filter runtime, onboarding permission prompts, entitlements, signing,
  provisioning, project files, workflows, dependencies, persistence schema,
  sync/account/backend runtime, AI/LDI runtime, new top-level destinations,
  silent calendar/reminder writes, App Store Connect state, release/legal/
  privacy readiness claims, and physical-device/public accessibility claims.

## Required Acceptance

- Notification visible/spoken copy hides ambient focus, goal, calendar, and
  private step detail by default.
- Notification mutation actions route into Ambitions instead of completing or
  snoozing work in the background.
- Notification category copy opens Ambitions for closure review.
- EventKit reminder/calendar notes stay minimal and explicit-request grounded.
- Calendar reads remain Plan-owned, derived, and raw-title redacted.
- Today does not request Calendar access or write Calendar blocks.
- Build/test evidence proves the existing notification/EventKit code still
  compiles.
- Real notification delivery, device EventKit behavior, and rendered platform
  proof remain Yellow-owned.

## Required Validation

Run:

- `git status --short`
- `git diff --check`
- focused notification / external-action / EventKit tests
- `scripts/build-local.sh`
- relevant CQS scans `|| true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Closeout

Close Green if scoped source behavior is implemented and tested, build proof
passes, no forbidden files are touched, and remaining notification delivery,
device EventKit, App Store, and accessibility proof is explicitly Yellow-owned.
