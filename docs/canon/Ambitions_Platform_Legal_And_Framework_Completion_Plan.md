# Ambitions Platform, Legal, And Framework Completion Plan
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth / docs-only source truth. No production Swift implementation in this file.
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion

## 0. Purpose

This plan closes the non-user-facing side of Ambitions so the app, repo, framework, schema, platform integrations, legal posture, privacy posture, performance posture, and handoff quality can reach the same 10/10 FAANG flagship bar as the user-facing product objects.

FCP makes Ambitions feel 10/10. PFC makes Ambitions operate, scale, sync, monetize, comply, build, test, and hand off like a 10/10.

This file is not implementation. It authorizes later named PFC batches only after dependencies, file boundaries, approval phrases, and gates pass.

## 1. Core Standard

A 10/10 Ambitions codebase and platform foundation must be:

- understandable by a FAANG iOS/product/platform team in one onboarding session
- cleanly modularized by domain, feature, shared primitives, services, tests, previews, and platform extensions
- schema-documented, migration-safe, backup-safe, and deletion/export-safe
- offline-first where practical, sync-safe where implemented, and honest when local-only
- privacy-first, data-minimized, user-controlled, and source-aware
- legally reviewed before public launch claims
- App Store policy-aware and claim-bound
- performance-budgeted, battery-aware, and render-safe
- accessible and reduced-motion safe across app, widgets, Live Activities, controls, notifications, and external surfaces
- CI-backed, testable, reproducible, and clean from prompt-built artifacts
- safe to hand to a senior iOS team without explaining hidden Codex history

## 2. Non-User-Facing Domains That Must Reach 10/10

### 2.1 Repo And Build System

Required closure:

- deterministic local setup
- XcodeGen/project generation clarity
- no stale generated artifacts
- no dead files
- no unused prompt leftovers in production areas
- dependency policy enforced
- clean CI build matrix
- reproducible unsigned and release-style builds
- clear environment/config separation
- secrets absent from repo
- onboarding README and architecture map are current

### 2.2 Architecture And Framework Boundaries

Required closure:

- domain models separated from SwiftUI views
- services separated from projections/view state
- feature modules own feature UI and tests
- shared primitives are small and generic only where intentionally shared
- no mega-files without extraction plan
- no hidden global state
- no UI reading persistence directly unless explicitly architected
- no business logic trapped in views
- no duplicate source-of-truth models

### 2.3 Persistence, Schema, And Migration

Required closure:

- documented local schema
- migration ladder
- rollback/restore plan
- corruption recovery
- archive/export/import posture
- privacy-sensitive field classification
- retention rules
- deletion semantics
- fixture coverage for old payloads
- no silent schema mutation

### 2.4 iCloud / CloudKit / Sync

Required closure:

- sync strategy: none/local-only, iCloud private database, or explicit future server
- CloudKit container and zones documented if used
- local-only fallback
- conflict/merge/tombstone rules
- privacy class per synced field
- account unavailable/degraded states
- offline queue and retry posture
- sync telemetry that does not expose private content
- user-facing sync truth and settings

### 2.5 External Platform Surfaces

Required closure:

- WidgetKit strategy
- Live Activities / ActivityKit strategy
- App Intents / Shortcuts strategy
- Control Center controls strategy if used
- Lock Screen privacy behavior
- notifications strategy
- Focus / calendar / reminder integration posture
- deep links from widgets and Live Activities to exact app scenes
- external-surface accessibility labels
- stale snapshot behavior

### 2.6 Monetization And Entitlements

Required closure:

- business model decision
- free tier boundaries
- subscription tiers
- StoreKit 2 products and entitlement model
- paywall review and App Review safety
- restoration flow
- Family Sharing decision
- trials/offers/win-back posture
- cancellation and manage-subscription affordances
- no dark patterns
- external purchase/link posture only with jurisdiction-aware legal review
- monetization must not degrade trust, privacy, recovery, or accessibility

### 2.7 Privacy, Legal, And Compliance

Required closure:

- public privacy policy before App Store submission
- terms of service if accounts/subscriptions/cloud/backend exist
- App Store privacy labels based on actual data collection
- `PrivacyInfo.xcprivacy` and required-reason API declarations where applicable
- third-party SDK inventory and privacy manifests
- data processing map
- data retention/deletion/export policy
- children/minors posture
- health/medical/legal/financial advice boundaries
- crisis/safety boundaries
- jurisdiction-sensitive features documented
- open-source license inventory
- trademark/IP review
- accessibility legal posture reviewed by human/legal where needed
- legal review checklist before public launch

### 2.8 Security And Abuse Resistance

Required closure:

- threat model
- secrets scanning
- Keychain use for sensitive tokens
- no sensitive content in logs
- encryption posture documented
- cloud permissions minimized
- App Groups/widget sharing boundary reviewed
- backup behavior documented
- jailbroken/device compromise non-claim boundary
- rate limiting if backend introduced
- supply chain review
- red-team fixture suite for unsafe recommendations, privacy leaks, and hallucinated claims

### 2.9 Performance, Battery, And Reliability

Required closure:

- launch-time budget
- memory budget
- animation/rendering budget
- widget reload budget
- Live Activity update budget
- background task policy
- sync power policy
- Instruments proof before release claim
- slow-device test matrix
- crash handling strategy
- logging/diagnostics policy
- no always-on expensive observers

### 2.10 Data Freshness, Source Truth, And Receipts

Required closure:

- source freshness states
- stale source gating
- provenance map
- data update cadence
- source conflict behavior
- user-confirmed vs system-inferred separation
- refresh receipts
- no recommendation based on stale/unknown data without visible review

### 2.11 QA, Testing, And Release Engineering

Required closure:

- unit tests
- domain contract tests
- migration tests
- sync conflict tests
- StoreKit tests
- widget/Live Activity tests
- App Intent tests
- accessibility tests
- UI tests
- performance tests
- privacy/copy/release-claim scans
- CI artifacts
- TestFlight checklist
- App Store submission checklist
- rollback plan

### 2.12 Product Analytics And Observability

Required closure:

- analytics decision: none, local-only, privacy-preserving, or third-party
- event taxonomy if any
- no private content in events
- consent/opt-out if applicable
- diagnostics vs analytics separation
- crash reporting posture
- retention policy
- privacy labels reflect actual collection

## 3. Legal Completeness Boundary

Codex can create checklists, source truth, code, tests, scans, and evidence. Codex cannot certify the app as legally compliant. Public legal readiness requires a qualified human legal/privacy review before launch.

PFC must make the app legally reviewable and reduce obvious risk, but final legal signoff is a human-proof stop.

## 4. External Platform Baseline Requirements

Apple platform constraints must be treated as source-truth inputs:

- Widgets and Live Activities must be glanceable, focused, and privacy-safe.
- Live Activities must have a defined beginning and end, avoid sensitive Lock Screen content, avoid ads/promotions, deep-link to relevant app content, and respect ActivityKit/WidgetKit constraints.
- CloudKit/iCloud sync must be privacy-aware, container/zone/schema-managed, and honest about account unavailable/local-only states.
- StoreKit monetization must use entitlement verification, restore paths, App Store testing, and App Review-safe paywall behavior.
- App privacy labels and required-reason API privacy manifests must match actual collection and third-party SDK behavior.

## 5. PFC Completion Rule

PFC completes only when every platform/framework/legal domain is either:

- implemented with tests and evidence,
- explicitly deferred with a safe product boundary and no public claim, or
- blocked on human/legal/platform proof with a clear checklist.

No public launch or FAANG handoff claim may be made until PFC handoff, FCP handoff, AOS/LDI relevant handoff, release evidence, human visual/accessibility/device proof, and legal/privacy review gates are complete or explicitly scoped out.
