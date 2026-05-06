# PFC28 Security Threat Model And Secrets Audit Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC28

## Result

PFC28 completed as a docs/security threat model and secrets audit packet. It
creates the current security source truth, records a tracked-file secrets scan,
defines app/security threats across local data, App Groups, widgets, Live
Activities, notifications, App Intents, Share Extension, EventKit, backups,
privacy manifests, future sync/cloud/account, future logging/observability,
StoreKit, AOS, LDI, and Found Life, and leaves final security/release claims
human/operator-gated.

## Source Truth Used

- `project.yml`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/ExternalSnapshots/SharedExternalSnapshotStore.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- PFC08, PFC09, PFC12, PFC13, PFC24, PFC25, PFC26, PFC27 evidence
- Ambitions 3.0 and External Brain privacy threat models
- Data local/sync/export and external-surface canon

## Files Read

- Startup/global order and PFC train docs.
- Current run-state, batch-train-state, registry, context, dependency graph,
  and optimized order.
- Current entitlements, privacy manifest, project wiring, and platform source
  files relevant to shared storage, EventKit, notifications, and external
  surfaces.
- Current privacy, legal, safety, data, external-surface, backup, sync, widget,
  and privacy-manifest evidence.

## Files Changed

- `docs/canon/Ambitions_Security_Threat_Model_And_Secrets_Audit.md`
- `docs/audits/pfc28-security-threat-model-and-secrets-audit-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Added the active PFC28 security threat model and secrets audit packet.
- Recorded current secrets scan findings: no live credential-shaped secret found
  in tracked app source; hits were placeholder/example guidance and scan-script
  patterns.
- Defined ten security threats and current mitigations.
- Added a repair queue for PFC29 observability, future CI/release secret
  scanning, App Group redaction, sync/cloud/account threat modeling, StoreKit,
  AOS/LDI safety, and final release proof.
- Advanced global state from PFC28 queued to PFC28 Green and selected PFC29 as
  the next eligible global batch.

## Product Decisions Preserved

- Ambitions remains Today / Goals / Capture / Plan / You.
- Ambitions remains local-first in current repo evidence.
- No CloudKit, backend, account, analytics, crash reporting, StoreKit, hosted
  AI, server memory, release, App Store, TestFlight, physical-device, or public
  accessibility claim was added.
- PFC28 does not certify security, privacy compliance, legal compliance, or App
  Store readiness.

## Validation Commands

- `git status --short`
- `git diff --check`
- touched-file trailing whitespace scan
- tracked-file secret pattern scan
- `.env` / secret-like filename scan
- platform/security-surface grep for entitlements, EventKit, notifications,
  logging, analytics, network, StoreKit, UserDefaults, and FileManager usage
- `scripts/cqs-product-drift-scan.sh || true`
- `scripts/cqs-privacy-security-claim-scan.sh || true`
- `scripts/cqs-accessibility-motion-scan.sh || true`
- `scripts/cqs-performance-budget-scan.sh || true`
- `scripts/cqs-prompt-built-smell-scan.sh || true`
- `scripts/cqs-architecture-boundary-scan.sh || true`
- `scripts/cqs-preview-coverage-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: PASS.
- Touched-file trailing whitespace scan: PASS.
- Tracked-file secret pattern scan: PASS WITH YELLOW. No live
  credential-shaped secret was found in active app source; hits were
  `.env.example` placeholder text, local Supabase skill guidance/reference
  links, and the scan script's own forbidden-token pattern.
- `.env` / secret-like filename scan: PASS WITH YELLOW. The only relevant
  repo root file was `.env.example`; no real `.env` file was found outside
  ignored/generated paths.
- Platform/security-surface greps: PASS WITH YELLOW. The scan confirmed the
  expected App Group, EventKit, notification, FileManager, privacy manifest,
  local-only sync, and no-active-analytics/no-active-crash/no-active-StoreKit
  posture recorded in the PFC28 packet.
- `scripts/cqs-product-drift-scan.sh || true`: PASS WITH YELLOW. Existing
  repo-wide guard/history hits remain; PFC28 introduced no top-level IA,
  dashboard, chatbot, habit-tracker, productivity-score, or fake-AI drift.
- `scripts/cqs-privacy-security-claim-scan.sh || true`: PASS WITH YELLOW.
  Existing forbidden-claim/token hits remain, and PFC28 necessarily contains
  security/secrets/token wording while explicitly preserving no-certification
  and no-release-claim boundaries.
- `scripts/cqs-accessibility-motion-scan.sh || true`: PASS WITH YELLOW.
  Existing UI accessibility/motion advisory hits remain; PFC28 changed docs
  only and no runtime accessibility or motion behavior.
- `scripts/cqs-performance-budget-scan.sh || true`: PASS WITH YELLOW. Existing
  runtime advisory hits remain; PFC28 changed docs only and no runtime path.
- `scripts/cqs-prompt-built-smell-scan.sh || true`: PASS WITH YELLOW. Existing
  placeholder/stub/generic token backlog remains; PFC28 does not add runtime
  placeholders or implementation claims.
- `scripts/cqs-architecture-boundary-scan.sh || true`: PASS WITH YELLOW.
  Existing large-file/domain SwiftUI import advisories remain; PFC28 changed no
  production architecture files.
- `scripts/cqs-preview-coverage-scan.sh || true`: PASS WITH YELLOW. Existing
  preview/state advisory hits remain; PFC28 changed no visible UI.
- `scripts/run-doc-qa.sh || true`: PASS WITH YELLOW. Stale-guidance and
  deprecated-language scans produced expected repo-wide advisory/history hits;
  markdownlint reported the existing backlog; `lychee` checked 650 links with
  0 errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only gate
  hint was the expected dirty working tree before the PFC28 commit.

## Repairs Attempted

- Replaced the validation placeholder in this report after all PFC28 checks ran.

## Remaining Yellow Items

- Final security review, penetration testing, signed-binary/archive inspection,
  physical-device proof, App Store review, TestFlight upload, legal/privacy
  signoff, and public accessibility conformance remain human/operator gates.
- PFC29 owns logging, analytics, observability, and crash-reporting policy.
- Future CI/release work should add repeatable secret scanning and incident
  rotation steps.
- Future sync/cloud/account, StoreKit, AOS, LDI, App Group, widget, Live
  Activity, notification, App Intent, and backup/restore implementations must
  rerun security/privacy review when they touch runtime behavior.
- Existing CQS/doc-QA advisory backlog remains outside PFC28 scope.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC28 commit to remove the security threat model and restore PFC28
to queued in global order, registry, context, PFC train, and run-state docs.

## Next Eligible Batch

PFC29 Logging / Analytics / Observability Policy is next under full-stack order.

## Continuation Decision

PFC28 may continue to PFC29 after validation passes and the batch is committed.
