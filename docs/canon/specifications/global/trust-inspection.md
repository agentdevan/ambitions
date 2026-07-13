+++
spec_id = "GLOBAL-TRUST-INSPECTION"
title = "Trust Inspection"
kind = "global"
status = "normative"
owner_domain = "global-trust-inspection"
canon_revision = 1
profile = "surface-v1"
owns_concepts = ["global.completed.contextual-placement", "global.trust.identity", "global.trust.layers", "global.trust.proportional-receipts", "global.trust.visual-authority"]
inherits = [
  "LAW-IA-TRUST-001",
  "PRIVACY-VISIBILITY-001",
  "OBJECT-PROOF-REQUIREMENT-001",
  "CONST-PROOF-EVIDENCE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Trust/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Language/",
  "Native/Ambitions/Quality/",
]
+++

# Trust Inspection

Trust Inspection uses `surface-v1` because it presents contextual compact and deep inspection UI with visible objects, states, accessibility, and visual contracts. It remains non-root and object-subordinate, not persistent chrome or a dashboard.

## SPEC-GLOBAL-TRUST-INSPECTION-001 — Contextual Proof / Source / Privacy / History / Receipts

- **Concept:** `global.trust.identity`
- **Modality:** `MUST`
- **Scope:** Contextual trust presentation
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-CONTEXT-001`
- **Supersedes:** none

Trust MUST expose Proof, Source, Privacy, History, Receipts, and relevant rationale in the context of the object or change being inspected. It MUST NOT become a root, global dashboard, analytics feed, permanent badge field, architecture browser, or replacement for the object.

Proof MUST appear in completed Step, Goal detail, Receipt, Search result, and related detail flows when relevant.

Proof-required status MUST be visible before execution.

Required proof SHOULD be shown in Today, Goal detail, Capture proposal, and step detail wherever relevant.

## SPEC-GLOBAL-TRUST-LAYERS-001 — Disclosure expands only as needed

- **Concept:** `global.trust.layers`
- **Modality:** `MUST`
- **Scope:** Inline marker, compact row, deep inspection, and searchable archive
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-LAYERS-001`
- **Supersedes:** none

Trust disclosure MUST progress from an inline marker where a fact matters, to a compact detail row, to deep object-specific inspection, with searchable archives reachable through You. Proof requirements appear before execution/completion. Source/privacy details appear at meaningful boundaries. Every claim identifies provenance, freshness/status, affected object/change, and available correction or recovery without overstating evidence.

Source details SHOULD remain inspection-level, not prominent on every recommendation.

Ambitions SHOULD NOT show when a path used external/reference knowledge by default.

Source Atlas SHOULD be invisible by default.

## SPEC-GLOBAL-TRUST-PROPORTIONAL-RECEIPTS-001 — Receipt disclosure matches consequence
- **Concept:** `global.trust.proportional-receipts`
- **Modality:** `MUST`
- **Scope:** Accepted mutations and their immediate confirmation
- **Status:** `normative`
- **Verification:** `SCENARIO-TRUST-PROPORTIONAL-RECEIPT-001`
- **Supersedes:** none

Every accepted mutation MUST create its durable Receipt while disclosure remains proportional: small changes receive lightweight confirmation; meaningful or externally consequential changes expose a Receipt with inspect and Undo where supported; Save for Later uses its specified durable confirmation and exit path.

## SPEC-GLOBAL-TRUST-VISUAL-AUTHORITY-001 — Approved Trust package preserves evidence distinctions

- **Concept:** `global.trust.visual-authority`
- **Modality:** `MUST`
- **Scope:** Markers, rows, and deep inspection visual authority
- **Status:** `normative`
- **Verification:** `PROOF-TRUST-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish approved direction, successor final package, implementation proof, and the evidence being inspected. `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104` remains direction only; owner-approved VSP-07 successor package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93` is the contextual Trust target. Neither node proves SwiftUI parity, accessibility, device/runtime behavior, Visual Green, or release status.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Trust answers what changed or is required, why it matters, where the fact came from, what remains private, what evidence exists, and how the user can correct, undo, or recover.

<!-- canon-section: entry-exit -->
Entry comes from a relevant object marker/detail row, Search Inspect result, receipt/history archive, proof requirement, privacy boundary, or source-change notice. Dismissal returns to the originating object/change and restores focus.

<!-- canon-section: routes-presentation -->
Inline markers and compact rows stay subordinate to the object. Deep inspection uses the smallest native presentation that preserves meaning. Searchable archives live under You entry but remain Trust-owned; no presentation becomes root chrome.

<!-- canon-section: displayed-objects -->
Displayed facts include proof level/evidence, receipt mutation summary, prior/current values where safe, source/provenance/freshness, privacy classification/egress, history sequence, rationale, external result, and available correction/undo/recovery.

<!-- canon-section: resting-states -->
The trust-state matrix separates disclosure depth, evidence status, provenance freshness, receipt result, privacy review, and correction state.
Required states include no special disclosure, marker present, proof optional/suggested/required/satisfied, source current/stale/unavailable, receipt pending/committed/external-failed/undone, privacy-boundary review, history empty/populated, and correction required.

<!-- canon-section: loading-transitional -->
Proof load, receipt resolution, history pagination, source freshness check, privacy preview, undo, correction, and restoration retain the last valid local fact and expose bounded progress or stale state rather than blanking the object.

<!-- canon-section: empty-degraded -->
Each degraded fact retains the originating object, known local evidence, narrow uncertainty, and safe repair controls.
Missing proof, unavailable source, stale freshness, absent receipt detail, partial history, offline, permission denial, or local-store degradation is stated narrowly. The originating object remains usable where safe; retry, correct, export, diagnostics, or dismiss is offered without fabricated evidence.

<!-- canon-section: commands-actions -->
Open proof/source/privacy/history/receipt, add proof, inspect change, correct fact, review privacy boundary, retry external result, undo, export, and open diagnostics are explicit object-scoped actions. Inspection itself cannot mutate canonical state.

<!-- canon-section: durable-effects -->
Viewing is non-mutating. Accepted proof, correction, undo, privacy authorization, or retry routes through canonical commands and produces events, projections, receipts, and replay state. History remains append-only and inspectable.

<!-- canon-section: failure-rollback -->
Inspection failure leaves the source object and accepted state intact. Failed correction/undo retains current state and explains scope. Partial external result remains durable and retryable; privacy denial prevents egress and preserves local content.

<!-- canon-section: offline -->
Local inspection covers proof, receipts, history, privacy classification, rationale, correction, undo, and replay.
Local proof, receipts, history, privacy classification, rationale, correction, and replay remain inspectable offline. Optional source freshness may be stale/unavailable but cannot trigger private upload or block local trust facts.

<!-- canon-section: privacy-data-classification -->
Trust often handles the most sensitive private graph facts. Disclosure is minimum-necessary, contextual, redacted in logs/screenshots by default, protected from shoulder/notification leakage, and never sent to Account, R2, Source Atlas, or hosted AI. Export requires preview.

<!-- canon-section: accessibility-reading-order -->
VoiceOver reads object/change identity, trust category, current status, concise explanation, evidence/provenance, consequence, then actions. History is ordered and headed; before/after values are verbalized safely; markers never rely on color/icon alone; dismissal restores origin focus.

<!-- canon-section: dynamic-type -->
Markers expand into labeled rows, comparisons stack vertically, history and proof wrap fully, and no provenance, privacy consequence, status, or action is truncated into ambiguity.

<!-- canon-section: reduce-motion -->
Disclosure expansion, proof attachment, receipt resolution, history changes, and undo use immediate updates or restrained fades while retaining announcements, sequence, and focus.

<!-- canon-section: reduce-transparency -->
Trust materials become opaque semantic surfaces with equivalent category, hierarchy, comparison, warning, and contrast.

<!-- canon-section: copy-state-language -->
Use Proof, Source, Privacy, History, Receipt, Changed by, Used for planning, Still counts, Review, and Undo contextually. Avoid ledger/runtime/model confidence, surveillance language, shame, or proof-strength grading.

<!-- canon-section: visual-authority -->
The named successor package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable IDs `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:250:104` and `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:257:93` preserve direction/successor provenance. Source rendering, evidence correctness, accessibility/device behavior, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Trust/` owns contextual presentation/disclosure policy; `Core/LocalRuntimeOS/Inspection/` owns facts, receipts, proof, undo, and history; `PrivacySecurity/` owns classification/egress; `Language/` owns humane copy; `Quality/` owns proof.

<!-- canon-section: tests -->
The scenario matrix spans disclosure, evidence, source, receipt, privacy, correction, history, replay, accessibility, and focus behavior.
Tests cover every trust layer/category/state, proof-before-completion, source stale/unavailable, receipt external failure/undo, privacy denial, correction, history order/pagination, redaction, offline/replay, Search/You entry, VoiceOver semantics/order/actions, Dynamic Type, reduced effects, contrast, and focus return.

<!-- canon-section: proof -->
Evidence artifacts bind executed scenarios to exact source revisions and environments.
Required proof includes object-scoped receipts/history/proof fixtures, privacy and redaction evidence, failure/recovery logs, screenshot/accessibility matrices, scoped visual approval, exact commands/exits, source revision, known gaps, and rollback. Trust UI cannot self-certify the claims it displays.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Trust detail, proof/receipt/history paging, correction/undo validation, and freshness work MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve the originating object and foreground responsiveness under resource pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative proof/receipt/history data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.

## SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001 — Contextual Completed placement

- **Concept:** `global.completed.contextual-placement`
- **Modality:** `MUST NOT`
- **Scope:** Contextual Completed placement
- **Status:** `normative`
- **Verification:** `REVIEW-SPEC-COMPLETED-CONTEXTUAL-PLACEMENT-001`
- **Supersedes:** none

Completed MUST remain contextual across Today recent activity, Goals proof/history, Time past context, and You Receipts/History; it MUST NOT become a fifth root or mere completed bin.
