# Ambitions Security Threat Model And Secrets Audit
<!-- markdownlint-disable MD013 -->

Status: Active PFC28 security source truth and repair queue
Date: 2026-05-05
Owner: Security / Privacy / Platform
Result: Green docs/security audit; no security certification claim

## Purpose

PFC28 records the current Ambitions security threat model and secrets audit.
It covers local data, App Groups, widgets, Live Activities, notifications,
App Intents, Share Extension intake, EventKit, privacy manifests, backups,
future sync/cloud/account work, future analytics/logging/crash reporting,
future StoreKit, and future AOS/LDI/Found Life sensitive-memory seams.

This document is not a penetration test, SOC 2 report, legal opinion,
privacy compliance certification, App Store approval, TestFlight readiness
claim, production release approval, physical-device proof, public
accessibility conformance claim, or final signed-binary security report.

## Source Truth

- `project.yml`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/ExternalSnapshots/SharedExternalSnapshotStore.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `docs/canon/Ambitions_3_0_Privacy_Threat_Model.md`
- `docs/canon/Ambitions_4_0_External_Brain_Privacy_Threat_Model.md`
- `docs/canon/DATA_LOCAL_SYNC_EXPORT.md`
- `docs/canon/EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md`
- `docs/canon/Ambitions_Privacy_Data_Map_And_App_Privacy_Labels.md`
- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/canon/Ambitions_Terms_Privacy_Policy_Legal_Review_Packet.md`
- `docs/canon/Ambitions_Safety_Professional_Boundary_Crisis_Policy.md`
- `docs/audits/pfc08-corruption-recovery-backup-restore-plan-report.md`
- `docs/audits/pfc09-icloud-cloudkit-sync-strategy-decision-report.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `docs/audits/pfc13-widgetkit-strategy-object-map-report.md`

## Current Security Posture

Current repo evidence supports this posture:

- Native SwiftUI iOS app with widget and share extensions.
- All three app/extension entitlements use the same App Group:
  `group.com.ambitions.shared`.
- Privacy manifest currently declares no tracking, no collected data types, and
  no accessed API categories.
- `Package.swift` uses local package products only; no active remote runtime
  dependency, ad SDK, analytics SDK, crash SDK, attribution SDK, or tracking SDK
  was found in active source scans.
- Current sync strategy remains local-only and unavailable; no CloudKit,
  iCloud, backend, account, server, or remote user-data claim is implemented.
- EventKit and notification seams exist and must keep permission, local-write,
  external-surface, and log boundaries explicit.
- App Group sharing exists for privacy-safe external snapshots and external
  creation handoff; shared storage must be treated as sensitive.
- StoreKit, subscriptions, paywalls, account services, analytics, crash
  reporting, hosted AI, user-data server, and LDI runtime are not approved by
  PFC28.

## Secrets Audit Result

Tracked-file secret scans found no live credential-shaped secret in active app
source. The only findings were:

- `.env.example` placeholder Supabase URL.
- Local `.agents/skills/supabase*` guidance and reference links.
- The security scan script's own forbidden-token pattern.

No AWS key, Google API key, Stripe key, GitHub token, Slack token, private key,
database URL, service-role key, password assignment, or app runtime API token
was found by the PFC28 tracked-file scan.

This does not certify the repo as secret-free forever. Any future addition of
environment files, SDK config plists, API clients, backend keys, StoreKit
server secrets, analytics/crash SDKs, or AI provider credentials must re-open a
security review before commit and must not put secrets in app source.

## Threat Matrix

| ID | Threat | Current mitigation | Required Green proof before stronger claim | Owner |
| --- | --- | --- | --- | --- |
| SEC-001 | Secret or credential committed to repo. | PFC28 tracked-file scan found no live credential-shaped secret; `.env.example` is placeholder only. | Pre-commit/CI secret scanning policy, final release candidate scan, incident/rotation path if a real secret appears. | PFC28/PFC40/CI |
| SEC-002 | App Group shared storage exposes sensitive user life data to widgets or share extension. | Shared App Group is explicit and PFC12/PFC13 require privacy-safe projections. | Tests that shared snapshots contain only redacted external projections; manual widget/device proof for rendered surfaces. | PFC12/PFC13/PFC14/FVQ |
| SEC-003 | Widget, Live Activity, notification, App Intent, shortcut, Spotlight, or screenshot leaks private goals, proof, memory, crisis, or regulated-domain content. | Privacy threat model, external-surface canon, PFC13 object map, PFC15/PFC17/PFC19 strategies, and PFC27 safety policy require redaction by default. | Rendered/device proof, copy scan, privacy fixture matrix, and external-surface regression tests for every new exposure. | External surfaces/FVQ/PFC |
| SEC-004 | Logs, analytics, crash reporting, or observability capture private user content. | No active analytics/crash SDK/runtime evidence found; PFC29 owns observability policy next. | Event taxonomy or explicit no-analytics decision, redaction rules, log-level policy, and tests/scans proving no private content leaves device. | PFC29 |
| SEC-005 | Privacy manifest and App Privacy labels drift after new APIs, SDKs, or data flows are added. | PFC24 and PFC25 are current source-truth audits; manifest remains empty based on current scans. | Re-run required-reason API audit, inspect SDK manifests, and reconcile signed archive privacy report before submission. | Privacy/Release |
| SEC-006 | EventKit calendar/reminder reads or writes become silent or overbroad. | EventKit seams are explicit; Plan owns calendar permission posture; PFC27 blocks professional/crisis overreach. | Permission-state tests, no-onboarding-prompt proof, user-visible confirmation for writes, and no raw calendar detail on external surfaces. | Plan/Platform |
| SEC-007 | Local backup, export/import, or replace-local-store causes data loss or overexposes sensitive records. | PFC07/PFC08 prove service-level malformed package and local recovery boundaries; user-facing trust UI remains future-owned. | User-facing export/import/delete controls, destructive confirmation proof, production-store migration proof, and device backup/restore evidence. | Persistence/You/PFC40 |
| SEC-008 | Future sync, CloudKit, backend, account, or server memory changes local-first expectations. | PFC09 keeps current runtime local-only/no-launch-sync. | Explicit product/security/legal approval, schema/conflict model, privacy policy/TOS update, migration/rollback proof, account-unavailable states. | PFC10/PFC11/future sync |
| SEC-009 | AOS/LDI/Found Life memory or source packs operationalize unsafe, stale, private, illegal, regulated, or professional-advice content. | Found Life, EB37, PFC26, and PFC27 require source/freshness/privacy/safety boundaries and no professional-service claims. | Typed safety triage, source claim graph, review receipts, no-silent-mutation tests, red-team fixtures, and human review where required. | AOS/LDI/Safety |
| SEC-010 | Preview/demo/test artifacts contain realistic private data or imply release/security proof. | Existing privacy threat model blocks fake/demo overclaim; FVQ records rendered-proof boundaries. | Fixture privacy review, screenshot/demo checklist, no real personal data in assets/logs, and final claim scan. | FVQ/Release |

## Current Repair Queue

No immediate secret-removal repair is required by PFC28.

Required follow-up owners:

1. PFC29 must decide the logging, analytics, observability, and crash-reporting
   posture before any telemetry or diagnostic collection claim.
2. Future CI/release hardening should add a repeatable secret-scan gate and
   document rotation steps for any accidental exposure.
3. Future App Group/widget/share-extension implementation must keep shared
   storage limited to redacted external projections and queued creation handoff.
4. Future CloudKit/sync/account work must reopen threat modeling before
   entitlements, containers, schema, backend, or account UX changes.
5. Future StoreKit/paywall work must keep purchase data, receipt validation,
   server secrets, and restore behavior out of current claims until
   implemented and reviewed.
6. Future AOS/LDI work must preserve source, freshness, safety, legality,
   professional-boundary, and mutation-permission receipts.
7. Release/handoff work must rerun secret scans, privacy-manifest scans, App
   Privacy label reconciliation, and signed-binary/archive review before any
   public readiness claim.

## Stop Conditions

Stop and re-open security review if future work introduces:

- a real credential, private key, service-role key, API token, database URL, or
  password in source;
- new SDK, binary framework, package dependency, analytics, crash reporting,
  ads, tracking, attribution, or hosted AI provider;
- CloudKit, backend, sync, account, server, remote memory, or external storage;
- entitlements, App Groups, Keychain access groups, associated domains,
  background modes, HealthKit, location, camera, photo-library, contacts, or
  network capabilities not covered by current policy;
- logs, screenshots, widgets, notifications, Live Activities, App Intents,
  Spotlight, previews, reports, or test artifacts containing private user data;
- privacy manifest, App Privacy label, legal/privacy, release, App Store,
  TestFlight, physical-device, or accessibility claim drift.

## PFC28 Decision

PFC28 closes as a security threat model and secrets audit. It does not edit
production Swift, entitlements, privacy manifests, project files, dependencies,
workflows, signing, App Store Connect state, or release artifacts. Current
security posture is reviewable, but final security, legal, privacy, release,
physical-device, App Store, TestFlight, and public accessibility claims remain
evidence-bound and human/operator-gated.
