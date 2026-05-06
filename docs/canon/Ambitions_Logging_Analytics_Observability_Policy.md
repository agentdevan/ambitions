# Ambitions Logging Analytics Observability Policy
<!-- markdownlint-disable MD013 -->

Status: Active PFC29 observability/privacy source truth
Date: 2026-05-05
Owner: Observability / Privacy / Platform
Result: Green no-analytics policy; future observability remains gated

## Purpose

PFC29 defines Ambitions' logging, analytics, observability, crash reporting,
diagnostic, and local event-ledger posture.

This policy protects deeply personal life data by making the current runtime
stance explicit:

```text
No developer analytics, no remote telemetry, no crash-reporting SDK, no ad or
tracking SDK, and no private user content in logs.
```

This document is not a telemetry implementation, crash-reporting
implementation, privacy compliance certification, legal signoff, App Store
approval, TestFlight readiness claim, release-readiness claim, physical-device
proof, public accessibility conformance claim, or final signed-binary privacy
report.

## Source Truth

- `project.yml`
- `Package.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/canon/Ambitions_Privacy_Data_Map_And_App_Privacy_Labels.md`
- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/canon/Ambitions_Security_Threat_Model_And_Secrets_Audit.md`
- `docs/canon/Ambitions_Terms_Privacy_Policy_Legal_Review_Packet.md`
- `docs/canon/Ambitions_Safety_Professional_Boundary_Crisis_Policy.md`
- `Native/Ambitions/Domain/EventLedgerModels.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `AppUI/Sources/WidgetFoundation.swift`
- `AppUI/Sources/WidgetPreviews.swift`

## Current Runtime Decision

Current Ambitions runtime observability decision:

```text
No remote analytics or telemetry.
No third-party crash reporting SDK.
No developer collection of diagnostics.
Local product event ledgers remain user-trust/receipt data, not analytics.
```

Current repo evidence:

- `Package.swift` contains local package products only.
- `project.yml` wires native app, widget extension, share extension, unit
  tests, and UI tests; no analytics/crash/tracking dependency is wired.
- `PrivacyInfo.xcprivacy` declares no tracking, no collected data types, and no
  accessed API categories.
- PFC24 maps diagnostics, analytics, advertising, and tracking to "not
  collected / no tracking" for current repo behavior.
- PFC28 records logging/analytics/crash as a future threat-model owner.
- `EventLedgerModels` and related persistence/service code are local product
  receipts and feedback history; they are not remote telemetry.
- `AppUI` widget `analyticsID` is a local view-model/previews metadata field in
  the component package and is not evidence of a shipped analytics pipeline.

## Allowed Local Diagnostics

Allowed without reopening PFC29:

- Local test logs produced by build/test tooling.
- Local simulator logs used by developers during validation.
- Local event ledger and receipt records stored as user data and surfaced as
  product trust/history.
- Local import/export warnings, validation reports, and batch audit reports
  that avoid real private user data.
- Static source scans and generated QA logs that remain repo-local and contain
  no secrets or personal user content.

Allowed local diagnostics must:

- avoid raw capture text, goal titles, calendar event titles, proof contents,
  memory contents, source URLs, crisis/professional-boundary content, minors
  content, health/legal/financial details, and credentials;
- prefer typed IDs, counts, categories, states, and redacted labels;
- stay out of widgets, Live Activities, notifications, App Intents, Spotlight,
  screenshots, and public reports unless explicitly privacy-reviewed;
- never imply developer collection when data remains local.

## Forbidden Until Future Approval

Do not add or claim:

- analytics SDKs;
- crash-reporting SDKs;
- remote telemetry;
- session replay;
- attribution, ads, tracking, or cross-app tracking;
- server-side diagnostic upload;
- hosted AI transcript logging;
- user-data event export to developer services;
- production dashboards fed by private user behavior;
- A/B testing, experiments, or cohort tracking;
- "privacy compliant", "secure", "anonymous analytics", "crash reporting
  enabled", "production telemetry", or similar public readiness claims.

## Future Observability Gate

If future work proposes analytics, crash reporting, diagnostics upload, or
observability collection, it must first produce a new approved batch with:

1. Product reason and user benefit.
2. Data-minimization table.
3. Event taxonomy using no raw private user content.
4. Redaction rules for every field.
5. Storage/retention/deletion/export posture.
6. Opt-in/opt-out and user-control posture where required.
7. App Privacy label update.
8. Privacy manifest and SDK manifest review.
9. Legal/privacy review.
10. Security threat-model update.
11. Tests/scans proving private content is not logged or uploaded.
12. Release-claim boundary and rollback plan.

## Event Taxonomy Boundary

Current product event/receipt data is local trust data, not analytics. Future
remote analytics may not reuse local receipt/event objects directly.

If remote analytics is ever approved, the taxonomy must be limited to
non-content operational facts such as:

- app lifecycle health state;
- feature availability state;
- permission state category, not source content;
- redacted error category;
- local-only sync unavailable state;
- validation/build diagnostic category during internal testing.

Forbidden event fields:

- raw capture text;
- goal, Task, Step, plan, proof, receipt, memory, source, calendar, reminder,
  notification, widget, Live Activity, App Intent, Share Extension, or LDI
  content;
- source URLs or uploaded evidence;
- precise life-domain sensitive categories when they identify health, legal,
  financial, crisis, minors, education/student-data, relationship, family, or
  career/professional details;
- user identifiers unless an approved account/legal/privacy model exists;
- device identifiers used for tracking;
- secrets, tokens, keys, passwords, or auth material.

## Logging Rules

Production logging must default to:

- no raw user content;
- no secrets;
- no calendar/reminder titles or notes;
- no proof/evidence contents;
- no source URLs unless redacted and user-approved;
- no crisis or professional-boundary content;
- no hidden memory, AOS, LDI, Found Life, or Searchable Life Recall content;
- redacted error categories instead of payload dumps;
- local developer-only diagnostics unless a future approved telemetry batch
  proves otherwise.

## PFC29 Decision

PFC29 closes with an explicit no-analytics/no-remote-observability policy for
current repo behavior. It does not add runtime logging, analytics, crash
reporting, dependencies, entitlements, privacy manifest entries, App Store
metadata, release artifacts, or user-facing telemetry controls. Any future
observability implementation must reopen this policy and pass privacy, legal,
security, App Privacy, privacy manifest, and release-claim gates.
