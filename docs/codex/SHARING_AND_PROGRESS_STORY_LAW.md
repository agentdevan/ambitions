# Sharing And Progress Story Law

Status: Active PLOS M00 governance law
Issue: AMB-643 / PLOS-007
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting PLOS law subordinate to `docs/truth/*`
Runtime implementation proof: none
Sharing implementation proof: none
UI implementation proof: none

This law defines sharing and progress-story boundaries for future PLOS execution. It does not build sharing UI, share hosting, progress stories, export flows, screenshots, or runtime behavior.

## Core Law

Sharing in Ambitions is user-initiated, locally rendered, previewed, redactable, proof-bound, and optional.

Sharing is never a feed, leaderboard, follower graph, XP surface, streak flex, social pressure mechanism, or default hosted artifact.

Progress stories must help the user tell a chosen story with proof and redaction. They must not turn private life execution into social performance.

## Existing Authority Anchors

AMB-643 inspected current docs and source before installing this law. Existing anchors include:

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
  - product truth forbids social feed, leaderboards, karma, public sharing defaults, streak pressure, and generic productivity scoring.
- `Native/AmbitionsShareExtension/ShareIntakeView.swift`
  - current share extension copy states "Saved locally first" and uses local app group handoff.
- `Native/AmbitionsShareExtension/ShareViewController.swift`
  - current share extension appends a local external creation request and opens Ambitions for normal review.
- `Native/Ambitions/ExternalSnapshots/SharedExternalSnapshotStore.swift`
  - current external snapshot store uses an app group path or local fallback.
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
  - current privacy safety models include external projection policies, redaction summaries, receipts, and external-blocked states.
- `Native/Ambitions/Services/SharedLifeCoordinationService.swift`
  - current shared-life service models coordination inside local goal/evidence context.
- `Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift`
  - current protected storage policy blocks external raw projection and keeps export/redaction local unless proven otherwise.
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
  - source/receipt/consequence and fallback disclosure must remain inspectable.

These anchors are existing-first context only. They do not prove sharing implementation.

## Sharing Is

Future PLOS sharing must be:

- user-initiated
- locally rendered
- previewed before leaving the device
- redactable
- proof-bound
- source-aware when source claims are visible
- reversible or cancelable before export/share
- clear about what leaves the device
- never required for core progress

If a user cannot preview and redact the artifact before sharing, the share path is not Green.

## Sharing Is Not

Future PLOS sharing must not become:

- leaderboard
- follower graph
- XP
- streak flex
- public feed
- social pressure
- engagement loop
- shame display
- productivity ranking
- default hosted artifact
- private proof dump
- raw receipt export by default

Sharing is a user-controlled projection, not a social product surface.

## Default Redactions

Default sharing/export redactions must hide or generalize:

- precise location
- calendar titles
- health or medical details
- financial balances
- legal details
- private notes
- other people's names
- exact routines
- raw proof artifacts
- sensitive goal text
- private receipts
- private source imports
- hidden constraints
- minors or student data
- identity-sensitive context

The user may explicitly reveal some details only after preview, but high-risk, third-party, minor/student, crisis/safety, legal, medical, financial, or privacy-blocked data must remain blocked or require a stricter review path.

## Progress Story Contract

A progress story can summarize:

- what changed
- what proof supports it
- what the user chose to include
- what was redacted
- what source or receipt is safe to show
- what remains private

A progress story must not imply:

- public accountability by default
- social proof requirement
- moral ranking
- streak pressure
- exact private routine disclosure
- source authority that is not eligible for sharing
- release/privacy/legal approval

## Green Enforcement

Any future PLOS issue that claims sharing, progress story, export, share extension, proof projection, redaction, or share eligibility Green must reference this law before Green.

Green requires:

- a live `AMB-*` issue identifier
- existing-first inspection of sharing/export/share-extension/privacy/source/proof ownership
- user-initiated flow
- local preview before external projection
- explicit default redactions
- proof and source eligibility boundaries
- clear statement of what leaves the device
- no feed, leaderboard, follower graph, XP, streak flex, or social pressure mechanics
- privacy/legal/release no-claim boundary unless current proof exists

Yellow is allowed when this law is installed but future sharing/export UI, share extension validation, redaction engine, source eligibility, or screenshot/accessibility proof remains owned. Red is required for default hosted sharing, raw proof export, private data exposure, social-feed drift, leaderboard/XP/streak pressure, source/share overclaim, PLOS label Linear access, or phase-order violation.

## Cross-Links

- `docs/codex/LOCAL_DATA_CLOUD_BOUNDARY_LAW.md`
- `docs/codex/HIGH_RISK_DOMAIN_SAFETY_LAW.md`
- `docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md`
- `docs/codex/TRUST_UI_DISCLOSURE_LAW.md`
- `docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md`

Future phase owners:

- AMB-629 / PLOS-M20 must use this law before Sharing and Progress Story System Green.
- AMB-624 / PLOS-M17 must use this law for share/proof UI claims.
- AMB-625 / PLOS-M18 must use this law for high-risk share redaction.

## Non-Claims

AMB-643 does not claim:

- sharing UI implementation
- progress story implementation
- share extension validation
- redaction engine implementation
- hosted share implementation
- screenshot proof
- accessibility verification
- runtime feature implementation
- app source change
- privacy/legal approval
- release readiness
- PLOS-M00 completion
- PLOS-M01 or later execution
