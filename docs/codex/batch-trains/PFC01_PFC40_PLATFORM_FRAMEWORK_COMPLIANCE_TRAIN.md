# PFC01-PFC40 Platform / Framework / Compliance Completion Train
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth; PFC01 Green; PFC02 Green; PFC03 queued next. No implementation starts by reading this file.
Date: 2026-05-05
Train code: PFC

## Required Approval Phrase

`Start Platform Framework Compliance Train`

The global optimized order may also select PFC batches when the user explicitly preauthorizes cross-train sequencing.

## Purpose

PFC makes Ambitions clean, legal-reviewable, platform-complete, performance-safe, sync-ready, monetization-ready, handoff-ready, and indistinguishable from a human-built FAANG-quality iOS codebase.

## Relationship To FCP / AOS / LDI

- FCP makes user-facing objects 10/10.
- AOS/LDI make runtime intelligence and living-dream handling safe and source-grounded.
- PFC makes the app/platform/repo/legal/business/architecture foundation 10/10.
- PFC does not claim legal compliance, App Store readiness, TestFlight readiness, device proof, or privacy signoff. It creates evidence and human-review checkpoints.

## Common Gates

Every PFC batch must pass:

- Source Truth Gate.
- Scope Boundary Gate.
- Legal Claim Boundary Gate.
- Privacy / Data Minimization Gate.
- Architecture / Maintainability Gate.
- Security Gate if sensitive data, sync, storage, or external surface is touched.
- App Store Policy Gate if monetization, privacy labels, widgets, Live Activities, notifications, or external purchases are touched.
- Accessibility Gate if UI, widgets, Live Activities, controls, notifications, or external surfaces are touched.
- Performance / Battery Gate if background work, sync, widgets, Live Activities, animation, or observers are touched.
- Validation Strength Gate.

## Global Stop Conditions

Stop on:

- unsupported legal compliance claim
- unsupported App Store/TestFlight/release readiness claim
- privacy label not matching data behavior
- required-reason API declaration missing when applicable
- sensitive content in logs/widgets/Live Activities/notifications
- unreviewed data collection or third-party SDK
- hidden monetization gate or dark pattern
- sync conflict behavior undefined
- schema migration risk without tests
- entitlement/signing change without explicit approval
- secrets in repo
- Weak/Missing validation for implementation
- file-size/architecture Red

## Batch Order

### PFC01 — Repo And Build System Inventory

Type: Audit/docs.
Owner: Platform / Build.
Goal: Inventory repo layout, build system, project generation, scripts, workflows, generated files, dependencies, local setup, and handoff docs.
Allowed: docs/audits, docs/canon/codex. No production Swift.
Required result: repo/build cleanliness scorecard and repair map.
Status: Green as docs-only inventory and repair map. No production Swift,
project, workflow, dependency, signing, or generated build output changed.

### PFC02 — Architecture Boundary And Module Map

Type: Docs/audit.
Owner: Architecture.
Goal: Map feature/domain/service/shared/test/preview boundaries and identify Codex-smell files.
Required result: architecture boundary map and extraction queue.
Status: Green as docs-only architecture boundary map. Existing large-file and
domain SwiftUI import advisories are Yellow-owned by future architecture,
maintainability, and owner-specific batches.

### PFC03 — Dead Code / Prompt Artifact / Naming Smell Audit

Type: Audit/repair planning.
Owner: Maintainability.
Goal: Identify dead files, prompt-built residue, stale names, duplicate models, and unexplained folders.
Required result: cleanup queue; no deletion without owner proof.

### PFC04 — Dependency And Supply Chain Policy Enforcement

Type: Audit/docs.
Owner: Platform / Security.
Goal: Inventory dependencies, licenses, lockfiles, SDK privacy manifests, and supply-chain risks.
Required result: dependency ledger and license/privacy-SDK review list.

### PFC05 — CI / Local Toolchain Reproducibility

Type: Implementation/docs.
Owner: Build / CI.
Goal: Make local and CI validation reproducible, documented, and evidence-producing.
Required result: clean setup/runbook and validated scripts; no release claim.

### PFC06 — Schema And Persistence Source Truth

Type: Docs/contract.
Owner: Persistence.
Goal: Document current local data models, schema ownership, sensitive fields, retention, export/delete/import posture.
Required result: schema map and migration risk ledger.

### PFC07 — Migration Ladder And Backward Compatibility Tests

Type: Implementation/tests.
Owner: Persistence.
Goal: Add migration fixtures/tests and payload survival proof where applicable.
Required result: migration tests or documented local-only non-schema boundary.

### PFC08 — Corruption Recovery / Backup / Restore Plan

Type: Docs/tests where applicable.
Owner: Persistence / Reliability.
Goal: Define corruption handling, safe fallback, backups, restore, and user-visible recovery copy.
Required result: recovery plan and tests if code exists.

### PFC09 — iCloud / CloudKit Sync Strategy Decision

Type: Docs/architecture.
Owner: Sync / Privacy.
Goal: Decide whether Ambitions is local-only, iCloud private database, or future server-backed. Define no-claim boundaries.
Required result: sync strategy decision record.

### PFC10 — CloudKit Schema / Zone / Conflict Model

Type: Docs/contracts; implementation only if approved.
Owner: Sync.
Goal: Define zones, records, conflicts, tombstones, merges, local-only fallback, account unavailable state.
Required result: CloudKit contract and test plan.

### PFC11 — Sync Implementation And Conflict Tests

Type: Implementation/tests if PFC09/PFC10 approve sync.
Owner: Sync.
Goal: Implement bounded iCloud sync and conflict tests, or explicitly close as deferred local-only.
Required result: sync proof or safe deferral.

### PFC12 — App Groups / Shared Storage Boundary

Type: Docs/implementation.
Owner: Platform.
Goal: Define app/widget/Live Activity shared storage and privacy boundaries.
Required result: app group data map and privacy-safe sharing proof.

### PFC13 — WidgetKit Strategy And Object Map

Type: Docs/product/platform.
Owner: Widgets.
Goal: Define which Ambitions objects are allowed as widgets and what they may expose.
Required result: widget object map and privacy matrix.

### PFC14 — WidgetKit Implementation And Tests

Type: Implementation/tests.
Owner: Widgets.
Goal: Implement or repair widgets with stale-state handling, deep links, privacy redaction, accessibility labels.
Required result: widget tests/previews and privacy proof.

### PFC15 — Live Activities / ActivityKit Strategy

Type: Docs/product/platform.
Owner: Live Activities.
Goal: Define allowed Live Activities: Step Session, commute/protected block, recovery window, or none. Define start/end, privacy, stale behavior.
Required result: ActivityKit strategy and no-ads/no-sensitive-Lock-Screen boundary.

### PFC16 — Live Activities Implementation And Tests

Type: Implementation/tests if approved.
Owner: Live Activities.
Goal: Implement bounded ActivityKit surfaces with deep links, privacy redaction, stale/ended states, Dynamic Type/accessibility proof.
Required result: ActivityKit proof or safe deferral.

### PFC17 — App Intents / Shortcuts / Spotlight Strategy

Type: Docs/platform.
Owner: App Intents.
Goal: Define allowed intents, parameters, privacy, confirmation requirements, and fallback behavior.
Required result: App Intent contract.

### PFC18 — App Intents / Shortcuts Implementation And Tests

Type: Implementation/tests.
Owner: App Intents.
Goal: Implement safe intents for capture, start step, close loop, open plan, review receipts as approved.
Required result: App Intent tests/snapshots and no hidden mutation.

### PFC19 — Notifications / Focus / Calendar / Reminders Integration Strategy

Type: Docs/platform.
Owner: Integrations.
Goal: Define notification, Focus, EventKit, Reminders, and Calendar boundaries.
Required result: integration decision record and permission copy.

### PFC20 — Notifications / Calendar / Reminders Implementation Proof

Type: Implementation/tests if approved.
Owner: Integrations.
Goal: Implement bounded integrations or explicitly defer. No silent calendar writes.
Required result: tests, privacy copy, and permission handling.

### PFC21 — StoreKit / Monetization Strategy

Type: Docs/business/legal.
Owner: Monetization.
Goal: Decide free tier, subscription tiers, entitlement model, paywall rules, trial/offers, cancellation/restore, App Review posture.
Required result: monetization decision record.

### PFC22 — StoreKit Entitlement Implementation And Tests

Type: Implementation/tests if approved.
Owner: Monetization.
Goal: Implement StoreKit 2 products/entitlements/restoration/testing or defer monetization.
Required result: StoreKit tests and no dark pattern proof.

### PFC23 — Paywall / Upgrade UX Compliance Review

Type: UX/legal review; implementation if approved.
Owner: Monetization / Legal.
Goal: Ensure paywall is clear, accessible, review-safe, not manipulative, and not hostile to free users.
Required result: paywall compliance report.

### PFC24 — Privacy Data Map And App Privacy Labels

Type: Docs/legal/privacy.
Owner: Privacy.
Goal: Map data collection, linked/unlinked, tracking, diagnostics, analytics, third-party SDKs, and App Store privacy labels.
Required result: privacy label draft tied to actual behavior.

### PFC25 — Privacy Manifest / Required-Reason API Audit

Type: Docs/implementation.
Owner: Privacy / Platform.
Goal: Audit required-reason APIs and `PrivacyInfo.xcprivacy` needs.
Required result: privacy manifest plan or implementation proof.

### PFC26 — Terms / Privacy Policy / Legal Review Packet

Type: Docs/legal.
Owner: Legal / Privacy.
Goal: Prepare legal-review packet: privacy policy needs, terms needs, data rights, minors, professional advice boundaries, subscriptions, liability.
Required result: human legal-review checklist. No legal compliance claim.

### PFC27 — Safety / Professional Boundary / Crisis Policy

Type: Docs/tests.
Owner: Safety.
Goal: Define health/legal/financial/crisis/professional advice boundaries across app, AOS, LDI, notifications, widgets.
Required result: policy fixtures and copy boundaries.

### PFC28 — Security Threat Model And Secrets Audit

Type: Docs/security; implementation repairs if scoped.
Owner: Security.
Goal: Threat model local data, sync, widgets, logs, App Groups, entitlements, dependencies, backups, and screenshots.
Required result: threat model and repair queue.

### PFC29 — Logging / Analytics / Observability Policy

Type: Docs/implementation.
Owner: Observability / Privacy.
Goal: Decide analytics/crash/logging posture and enforce no private content in telemetry.
Required result: event taxonomy or explicit no-analytics decision.

### PFC30 — Performance Budget And Instruments Plan

Type: Docs/QA.
Owner: Performance.
Goal: Define launch, memory, rendering, animation, widget reload, Live Activity, sync, background-task, battery budgets.
Required result: performance budget and Instruments checklist.

### PFC31 — Performance / Battery Implementation Repairs

Type: Implementation/QA.
Owner: Performance.
Goal: Repair performance risks and produce measured evidence where tooling permits.
Required result: performance proof or human/device proof stop.

### PFC32 — Accessibility Across External Surfaces

Type: Implementation/QA.
Owner: Accessibility.
Goal: Audit app, widgets, Live Activities, controls, notifications, App Intents, Dynamic Type, VoiceOver, Reduce Motion, non-color meaning.
Required result: accessibility matrix and repairs.

### PFC33 — Data Freshness Broker And Stale-State Gates

Type: Implementation/contracts.
Owner: Data Freshness / Trust.
Goal: Centralize source freshness, stale gates, refresh receipts, and conflict posture.
Required result: freshness contracts/tests.

### PFC34 — App Store Metadata / Screenshot / Claim Truth Pack

Type: Docs/marketing/legal.
Owner: App Store / Product Marketing.
Goal: Draft App Store description, screenshots, claims, keywords, support URL, privacy URL, and review notes with evidence boundaries.
Required result: claim-safe App Store packet.

### PFC35 — Test Strategy And Coverage Matrix

Type: Docs/tests.
Owner: QA.
Goal: Full unit/UI/domain/migration/sync/StoreKit/widget/Live Activity/App Intent/accessibility/performance test matrix.
Required result: coverage map and missing-test repair queue.

### PFC36 — Release Engineering And TestFlight Readiness Plan

Type: Docs/build/release.
Owner: Release Engineering.
Goal: Signing, certificates, provisioning, TestFlight, build numbers, release notes, rollback, symbolication, crash monitoring plan.
Required result: human/operator checklist. No readiness claim.

### PFC37 — FAANG Handoff Architecture Packet

Type: Docs/handoff.
Owner: Architecture / Product.
Goal: Produce clean architecture map, schema docs, service docs, ownership map, file layout, onboarding guide, glossary, and runbooks.
Required result: handoff packet a senior iOS team can read.

### PFC38 — Repo Hygiene And Prompt-Built Smell Removal

Type: Audit/implementation repairs.
Owner: Maintainability.
Goal: Remove/repair prompt-built smells, stale docs pointers, duplicate prompt residue, generic naming, unowned files, and confusing scaffolds.
Required result: clean repo report and repairs.

### PFC39 — Full Platform / Legal / Framework Audit

Type: Audit.
Owner: Cross-functional.
Goal: Audit every PFC domain for unresolved Red/Yellow before launch or handoff claims.
Required result: full audit with owners.

### PFC40 — Platform / Framework / Compliance Handoff

Type: Handoff.
Owner: Cross-functional.
Goal: Close PFC with final status, unresolved Yellows, human proof stops, legal signoff requirements, and next launch-readiness lane.
Required result: handoff. No legal compliance claim unless human legal review evidence exists.

## Completion Standard

PFC completes only when all 40 batches are Green or accepted Yellow with owners, no Red remains, and no legal/release/platform/privacy claim exceeds evidence.
