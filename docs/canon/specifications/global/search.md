+++
spec_id = "GLOBAL-SEARCH"
title = "Search"
kind = "global"
status = "normative"
owner_domain = "global-search"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "global.search.identity",
  "global.search.first-viewport",
  "global.search.index-actions",
  "global.search.visual-authority",
]
inherits = [
  "LAW-IA-NONROOT-001",
  "LAW-LOCAL-AUTHORITY-001",
  "CONST-RUNTIME-MUTATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Stage/",
  "Native/Ambitions/Core/LocalRuntimeOS/Search/",
  "Native/Ambitions/Core/LocalRuntimeOS/Projections/",
  "Native/Ambitions/Core/LocalRuntimeOS/Commands/",
  "Native/Ambitions/Trust/",
  "Native/Ambitions/Quality/",
]
+++

# Search

Search uses `surface-v1` because it presents a full-screen Find / Act / Inspect experience with visible result, action, state, accessibility, and visual contracts. It remains a global overlay/evolution, never a root tab or chatbot destination.

## SPEC-GLOBAL-SEARCH-IDENTITY-001 — Local Find / Act / Inspect

- **Concept:** `global.search.identity`
- **Modality:** `MUST`
- **Scope:** Global Search presentation and behavior
- **Status:** `normative`
- **Verification:** `SCENARIO-SEARCH-IDENTITY-001`
- **Supersedes:** none

Search MUST be deterministic, local-first Find / Act / Inspect across approved private projections. It MUST NOT be chatbot-first, command-line theater, a shallow utility sheet, cloud/LLM dependent, a root, or an alternate canonical store.

## SPEC-GLOBAL-SEARCH-FIRST-VIEWPORT-001 — Query and useful local results first

- **Concept:** `global.search.first-viewport`
- **Modality:** `MUST`
- **Scope:** Search first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-SEARCH-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST foreground the query field, privacy-safe scope, useful recent or exact local results when appropriate, result identity/state, and contextual safe actions. Empty-query content remains calm and bounded; it MUST NOT become a recommendation feed, dashboard, or exposed behavioral dossier.

## SPEC-GLOBAL-SEARCH-INDEX-ACTIONS-001 — One index, canonical actions

- **Concept:** `global.search.index-actions`
- **Modality:** `MUST`
- **Scope:** Index, ranking, result presentation, actions, and inspection
- **Status:** `normative`
- **Verification:** `TEST-SEARCH-RANKING-001`, `SCENARIO-SEARCH-ACTION-001`
- **Supersedes:** none

Search MUST find approved Life Areas, Goals, useful path nodes, Steps, Future Steps, Reminders, Events, Notes, Proof, Life Capital, receipts/history, provenance, and settings. Ranking is measurable and deterministic. Complete/start/schedule/add proof/pause/review/open-setting actions validate against canonical owners; material actions preview and produce receipts. Corruption recovery rebuilds locally without private egress.

## SPEC-GLOBAL-SEARCH-VISUAL-AUTHORITY-001 — Search mapping is a scoped gap

- **Concept:** `global.search.visual-authority`
- **Modality:** `MUST`
- **Scope:** Search overlay, results, actions, and inspection visuals
- **Status:** `normative`
- **Verification:** `PROOF-SEARCH-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual references MUST use stable external IDs and distinguish shell placement authority, dedicated overlay authority, and implementation proof. Owner-approved VSP-01 shell `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:87:2` governs Search placement only. No Search-specific approved overlay package is mapped, leaving a structured P1 gap and no Search visual or implementation claim.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Search answers where a local object or setting is, what safe action can be taken now, and what proof/source/history/privacy context can be inspected.

<!-- canon-section: entry-exit -->
Entry comes from integrated shell/context, keyboard shortcut, deep link, or handoff. Dismissal restores exact root/depth/query-origin focus; opening a result records a return target; accepted action returns to the changed object or results predictably.

<!-- canon-section: routes-presentation -->
Search is full-screen non-root presentation. Result detail uses native depth or owner handoff; contextual Trust inspection is presented by Trust. Search never persists as a root or duplicates destination behavior.

<!-- canon-section: displayed-objects -->
Results show canonical identity, type, relevant status/date/context, privacy-safe excerpt, provenance/trust marker only when relevant, and safe actions. Grouping and ranking rationale remain plain and inspectable without exposing internals.

<!-- canon-section: resting-states -->
Required states are empty query, recent/local suggestions, querying, results, no results, filtered, selected, action preview, action complete, rebuilding, restored, and privacy-suppressed.

<!-- canon-section: loading-transitional -->
Query, filter, index refresh/rebuild, action validation, mutation, inspection handoff, and restoration are cancellable where useful and retain last valid results until deterministic replacement is ready.

<!-- canon-section: empty-degraded -->
The result-state matrix pairs each index, projection, permission, and action condition with preserved query context and repair controls.
No results offers query repair, scope/filter changes, Capture, or exact setting help without fake matches. Corrupt/stale index, unavailable projection, permission denial, partial results, offline, or action rejection states preserve query and disclose what remains searchable.

<!-- canon-section: commands-actions -->
Type/edit query, filter, select, open, complete, Start now, schedule/reschedule, add proof, pause/resume, review conflict, inspect source/receipt/history/privacy, open Capture, and open exact setting use explicit controls and canonical commands. No gesture is required.

<!-- canon-section: durable-effects -->
Queries and result views do not mutate canonical data. Accepted actions follow Command to Event to Projection to Receipt to Replay; index updates consume projections and never write canonical object copies.

<!-- canon-section: failure-rollback -->
Rejected or stale result actions re-resolve the object and leave state unchanged. Partial action/external failure preserves accepted local intent and result status. Index failure quarantines/rebuilds from canonical projections; undo routes to the canonical owner.

<!-- canon-section: offline -->
Query, ranking, filtering, result opening, approved local actions, inspection, rebuild, receipt, and replay work without account/network. Network availability cannot change core ranking authority or reveal more private content.

<!-- canon-section: privacy-data-classification -->
Index and queries are private local data, privacy-filtered at indexing and retrieval. Logs/proof redact query and content by default. Spotlight or optional external handoff uses approved minimum metadata only; Account, R2, Source Atlas, and hosted AI receive no private query/context.

<!-- canon-section: accessibility-reading-order -->
VoiceOver orders dismiss, query/scope, filters, result count/status, then ranked results with identity/value/actions. Custom actions mirror every swipe/context action; headings/rotor support groups; action preview and inspection restore focus to the originating result.

<!-- canon-section: dynamic-type -->
Query, filters, results, excerpts, state, and actions reflow vertically; no horizontal layout, truncation, or hidden context is required to identify or act safely.

<!-- canon-section: reduce-motion -->
Result insertion, ranking changes, owner handoff, and action completion use restrained fades or immediate updates while preserving announcements, selection, and focus.

<!-- canon-section: reduce-transparency -->
Search and result materials become opaque semantic surfaces with equivalent grouping, selection, action, privacy, and contrast cues.

<!-- canon-section: copy-state-language -->
Use Find, Search, Open step, Start now, Review, Source, Receipt, History, Privacy, and Undo contextually. Avoid Ask AI, confidence, runtime/index taxonomy, shame, or productivity scoring.

<!-- canon-section: visual-authority -->
The named shell package controls placement only; overlay geometry remains unmapped.
Stable shell ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:87:2` governs Search placement but does not close the dedicated Search-overlay P1 mapping gap. Search rendering, accessibility/device evidence, implementation parity, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Stage/` owns presentation containment; `Core/LocalRuntimeOS/Search/` owns index/ranking/rebuild; `Projections/` supplies views; `Commands/` owns actions; `Trust/` owns inspection; `Quality/` owns proof. Current compliance is unclaimed.

<!-- canon-section: tests -->
Tests cover exact/prefix/typo/date/context ranking, suppression/privacy, every object family, action safety/material preview, stale object, index corruption/rebuild, partial results, offline, replay/undo, return focus, VoiceOver order/actions/rotor, Dynamic Type, reduced effects, contrast, and scale.

<!-- canon-section: proof -->
Required proof includes declared-corpus ranking metrics, privacy/filter fixtures, action receipts/replay, corruption recovery, screenshot/accessibility matrices, scoped visual approval, exact commands/exits, environment, known gaps, and rollback. Generated index maps are not runtime proof.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Search query, ranking, action revalidation, result paging, and index rebuild MUST remain bounded and cancellable, apply explicit product-scale input/result caps, perform no query-path network gating or synchronous disk write, use no polling or unbounded background loop, and preserve foreground responsiveness during rebuild. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative indexed-record/query/result data scale, warm/cold state, measurement tool, percentile/maximum, rebuild resource measures, and regression threshold. Current performance and physical-device proof remain absent.
