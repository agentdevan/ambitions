+++
spec_id = "SURFACE-YOU"
title = "You"
kind = "surface"
status = "normative"
owner_domain = "surface-you"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.you.identity",
  "surface.you.screen-inventory",
  "surface.you.first-viewport",
  "surface.you.depth",
  "surface.you.visual-authority",
]
inherits = [
  "CONST-IA-ROOT-001",
  "SURFACE-YOU-DEPTH-001",
  "LAW-ACCOUNT-BOUNDARY-001",
  "LAW-OFFLINE-NO-ACCOUNT-001",
  "PRIVACY-VISIBILITY-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Surfaces/You/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Continuity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/",
  "Native/Ambitions/Diagnostics/",
  "Native/Ambitions/Quality/",
]
+++

# You

This shadow specification defines the intended personal-system surface without asserting current account, sync, privacy, diagnostics, accessibility, or release behavior.

## SPEC-SURFACE-YOU-IDENTITY-001 — Searchable personal-system command center

- **Concept:** `surface.you.identity`
- **Modality:** `MUST`
- **Scope:** You root and settings depth
- **Status:** `normative`
- **Verification:** `SCENARIO-YOU-COMMAND-CENTER-001`
- **Supersedes:** none

You MUST be a low-scroll, searchable command center for identity, Setup & Personalization, Life Capital, preferences, automation, privacy, data, security, continuity, notifications, sources, receipts, history, and redacted diagnostics. It is not a profile feed, manifesto, help center, memory dossier, or debug console.

## SPEC-SURFACE-YOU-SCREEN-INVENTORY-001 — Plain groups with owned depth

- **Concept:** `surface.you.screen-inventory`
- **Modality:** `MUST`
- **Scope:** You root and owned settings/review routes
- **Status:** `normative`
- **Verification:** `AUDIT-YOU-ROUTES-001`
- **Supersedes:** none

You owns Account & Sync, Privacy & Security, Automation & Behavior, Notifications & Presence, Appearance, Data & Storage, Sources & Imports, Receipts & History, Diagnostics, Setup & Personalization, and Life Capital entry. Contextual Trust details remain owned by Trust inspection even when searchable archives are reachable through You.

## SPEC-SURFACE-YOU-FIRST-VIEWPORT-001 — Identity and current state first

- **Concept:** `surface.you.first-viewport`
- **Modality:** `MUST`
- **Scope:** You first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-YOU-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST show a quiet identity/profile summary, optional account and continuity state, privacy state, automation posture, notification state, data/security shortcuts, and settings search. Only current problems or required actions are elevated; broad stats, patterns, and diagnostics remain deeper and object-specific.

## SPEC-SURFACE-YOU-DEPTH-001 — Useful depth without dashboard drift

- **Concept:** `surface.you.depth`
- **Modality:** `MUST`
- **Scope:** Stats, Life Capital, learning, diagnostics, and history
- **Status:** `normative`
- **Verification:** `AUDIT-YOU-DEPTH-001`
- **Supersedes:** none

Life Capital, broad Patterns, learning controls, receipts/history, sync conflict, and redacted diagnostics MAY have deep inspectable routes. They MUST NOT dominate the root, expose a psychological dossier or runtime architecture, create productivity scoring, or imply account/network ownership of the private graph.

## SPEC-SURFACE-YOU-VISUAL-AUTHORITY-001 — Approved You package, separate implementation proof

- **Concept:** `surface.you.visual-authority`
- **Modality:** `MUST`
- **Scope:** You root and settings visual authority
- **Status:** `normative`
- **Verification:** `PROOF-YOU-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish approved design target from implementation evidence. Owner-approved VSP-06 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:240:93` is the You visual target. Its Yellow approval does not prove SwiftUI parity, accessibility, device behavior, account/R2/privacy readiness, runtime behavior, Visual Green, or release status.

## Completeness contract

<!-- canon-section: purpose-user-question -->
You answers what Ambitions knows or is allowed to do, what the user controls, how private data is handled, and where personal-system settings and evidence can be inspected or changed.

<!-- canon-section: entry-exit -->
Entry is root selection, settings Search, permission/account/diagnostic handoff, notification deep link, or restoration. Exit uses native back/root switching while preserving query, group, detail state, unsaved edits, and focus.

<!-- canon-section: routes-presentation -->
The root is a searchable grouped index. Complex setup, Life Capital, conflict review, export preview, destructive review, and diagnostics use native depth or focused review; contextual Trust inspection remains a separate non-root owner.

<!-- canon-section: displayed-objects -->
Displayed objects include profile summary, explicit account/continuity/privacy/permission states, automation policies, notification controls, Life Capital, source/import status, receipts/history links, data controls, and redacted health facts. Internal models never become primary objects.

<!-- canon-section: resting-states -->
Required states include no-account healthy, optional account signed in/out, continuity disabled/pending/conflicted, permissions available/denied, normal, action-required, setup partial/complete, Life Capital empty/populated, and diagnostics healthy/degraded.

<!-- canon-section: loading-transitional -->
Transition state records operation phase, retained local snapshot, progress, cancellation, and focus target.
Sign-in/out, continuity preflight, permission return, export, delete/reset preview, Life Capital impact simulation, source review, and diagnostics refresh preserve local data and expose cancellable progress where work is not immediate.

<!-- canon-section: empty-degraded -->
The degraded-state matrix pairs each capability condition with preserved local function and a precise recovery action.
No account is a healthy state. Denied permission, unavailable network, stale source, continuity conflict, export failure, or diagnostics failure preserves local core and offers exact recovery. Empty Life Capital or history is not filled with fabricated insight.

<!-- canon-section: commands-actions -->
Search setting, edit preference, change automation, manage permission, sign in/out, review continuity conflict, add/edit/archive/delete Life Capital, export, backup/restore, lock, Trash/restore, reset/delete, inspect receipt/history, and retry diagnostics use explicit validated actions and consequence review.

<!-- canon-section: durable-effects -->
Accepted policy, privacy, security, Life Capital, source, continuity, export, archive/delete, and destructive operations create canonical local events/receipts where product-significant, replay safely, and update affected paths only after preview/approval.

<!-- canon-section: failure-rollback -->
Failed sign-in, sync, export, import, permission, or diagnostics work does not erase local data or accepted settings. Destructive actions require scope preview and confirmation. Retry is idempotent; rollback/restore retains history and revalidates projections.

<!-- canon-section: offline -->
All local settings, privacy explanations, Life Capital, automation controls, local history, export preparation, app lock, and diagnostics remain available as applicable without account or network. Optional identity or reference access never gates core use.

<!-- canon-section: privacy-data-classification -->
The classification matrix assigns each datum to local graph, continuity, account, public-reference, export, or diagnostic scope.
You explicitly separates local private graph, optional CloudKit continuity, Ambitions Account identity/entitlement, public-only R2/reference access, permissions, exports, and diagnostics. Private content is excluded from diagnostic/export packages by default and needs explicit preview/inclusion.

<!-- canon-section: accessibility-reading-order -->
VoiceOver reads identity/current action state, search, then groups in stable order. Every toggle exposes label, current value, consequence, and exact action; destructive and conflict reviews expose complete summaries and focus-safe choices without relying on icons, color, or spatial grouping.

<!-- canon-section: dynamic-type -->
Groups and detail reflow to one column; labels, values, warnings, search results, and destructive consequences remain fully readable and actionable with no horizontal dependency.

<!-- canon-section: reduce-motion -->
Group expansion, status changes, setup progress, and drilldown transitions use restrained fades or immediate updates while retaining announcements, progress, and focus.

<!-- canon-section: reduce-transparency -->
Materials become opaque semantic backgrounds with equivalent grouping, hierarchy, contrast, selection, and privacy/action state.

<!-- canon-section: copy-state-language -->
Use plain account, privacy, sync/continuity, notification, Life Capital, source, receipt, history, export, archive, and delete language. Avoid runtime taxonomy, psychological labels, productivity scores, AI memory, or proof/readiness claims.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:240:93` supplies approved You design authority. Source rendering, privacy/account behavior, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/You/` owns presentation; `Core/LocalRuntimeOS/PrivacySecurity/`, `Continuity/`, `Inspection/`, and `Diagnostics/` own facts/behavior; app `Diagnostics/` presents redacted health; `Quality/` owns proof. Current source compliance is unclaimed.

<!-- canon-section: tests -->
Tests cover grouping/search/deep links, no-account use, privacy boundaries, permission recovery, automation scope, Life Capital impact/archive/delete, sign-out local retention, continuity conflict, export/diagnostic redaction, destructive previews, offline, VoiceOver order/actions, Dynamic Type, reduced effects, contrast, and focus.

<!-- canon-section: proof -->
Required proof includes state/scenario logs, privacy-boundary evidence, redacted export/diagnostics fixtures, receipts/replay, screenshot/accessibility matrices, independent visual mapping/acceptance, exact commands/exits, current environment, skipped checks, known risks, and rollback. No readiness is inferred from this spec.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
You root loading, settings search, Life Capital/history access, and redacted diagnostics refresh MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative settings/Life Capital/history data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold. Current performance and physical-device proof remain absent.
