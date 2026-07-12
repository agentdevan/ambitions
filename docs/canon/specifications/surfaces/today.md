+++
spec_id = "SURFACE-TODAY"
title = "Today"
kind = "surface"
status = "normative"
owner_domain = "surface-today"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.today.missed-placement-continuity",
  "surface.today.purpose",
  "surface.today.temporal-rail",
  "surface.today.eligibility",
  "surface.today.screen-inventory",
  "surface.today.first-viewport",
  "surface.today.states",
  "surface.today.visual-authority",
  "surface.today.object-row",
]
inherits = [
  "CONST-IA-ROOT-001",
  "SURFACE-TODAY-IDENTITY-001",
  "CONTROL-FORCE-NOTHING-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
  "CONST-PROOF-EVIDENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION"]
source_owners = [
  "Native/Ambitions/Surfaces/Today/",
  "Native/Ambitions/Core/LocalRuntimeOS/Projections/",
  "Native/Ambitions/Core/LocalRuntimeOS/PrivateLifeRuntimeKernel/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Quality/",
]
+++

# Today

This shadow specification defines the intended Today surface.

## SPEC-SURFACE-TODAY-PURPOSE-001 — Reality around now

- **Concept:** `surface.today.purpose`
- **Modality:** `MUST`
- **Scope:** Today root identity
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-REALITY-001`
- **Supersedes:** none

Today MUST remain an object-led reality surface answering what reality can hold around now and what the user should act on next. It must not become a generic agenda, task backlog, dashboard, recommendation feed, full calendar, or CTA stack. The temporal rail supports this identity; it does not replace it.

Today’s temporal rail MUST NOT replace the object-led current-reality viewport as the primary product identity.



Today SHOULD show today’s schedule and current operating reality.

Today MUST present reality around now rather than a task list or dashboard.

## SPEC-SURFACE-TODAY-TEMPORAL-RAIL-001 — Supporting temporal anatomy

- **Concept:** `surface.today.temporal-rail`
- **Modality:** `MUST`
- **Scope:** Rolling prior and upcoming context
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-TEMPORAL-RAIL-001`, `A11Y-TODAY-TEMPORAL-LIST-001`
- **Supersedes:** none

The supporting rail MUST provide a rolling plus-or-minus twenty-four-hour context anchored on Now, expanding meaningful periods and compressing empty stretches. Now is semantically strongest and Next is secondary. Ordered list navigation, date/time headings, jump-to-Now, and explicit object actions MUST provide complete non-spatial access without requiring rail position, drag, or visual distance.

Today’s temporal rail MUST span a rolling 48-hour window, with upward scrolling revealing the prior 24 hours and downward scrolling revealing the next 24 hours.

Today’s rolling `±24-hour` rail MUST remain supporting temporal anatomy and MUST NOT become the primary product identity.

Time order MUST remain the temporal rail’s legibility law.

## SPEC-SURFACE-TODAY-ELIGIBILITY-001 — Execution-relevant projection only

- **Concept:** `surface.today.eligibility`
- **Modality:** `MUST`
- **Scope:** Today projection membership
- **Status:** `normative`
- **Verification:** `TEST-TODAY-ELIGIBILITY-001`, `TEST-TODAY-NO-BACKLOG-001`
- **Supersedes:** none

Today MUST project only execution-relevant scheduled Steps, Reminders, Events, all-day or due items, recovery-eligible flexible work, and at most one earned fit suggestion. It MUST exclude broad backlog, unscheduled Goal inventory, Saved for Later inventory, and unreviewed external candidates.

Today MUST contain only execution-relevant objects, not broad backlog or project inventory.

Today MUST NOT show broad backlog, unscheduled goal inventory, future project lists, or Saved for Later.

## SPEC-SURFACE-TODAY-SCREEN-INVENTORY-001 — Root and owned depth

- **Concept:** `surface.today.screen-inventory`
- **Modality:** `MUST`
- **Scope:** Today root and contextual depth
- **Status:** `normative`
- **Verification:** `AUDIT-TODAY-ROUTES-001`
- **Supersedes:** none

Today owns its root Reality Window, Start here object presentation, supporting temporal rail, compact closure/recovery affordances, and Today-specific empty or degraded states. Object detail, complex rescheduling, recurrence, multi-item adjustment, and long-range editing hand off to their canonical object, Time, Motion, or Trust owners; they do not become duplicate Today stores or routes.

Each Today row MUST have an explicit primary action.

Today MUST use a compact reschedule sheet offering later today, tomorrow, pick time, flexible or Fixed state, and a suggested slot for low-risk single-object changes.

## SPEC-SURFACE-TODAY-FIRST-VIEWPORT-001 — Start here dominates

- **Concept:** `surface.today.first-viewport`
- **Modality:** `MUST`
- **Scope:** First visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-TODAY-FIRST-VIEWPORT-001`, `A11Y-TODAY-ORDER-001`
- **Supersedes:** none

When available, the first viewport MUST communicate Now, usable capacity, one dominant `Start here` Step or action, protected boundaries, the next fixed point, why the Step fits, and current closure, proof, or recovery state. `Start here` is a real best executable fit, not an enlarged task row. The semantic order presents context, Start here identity and reason, primary action, boundaries, next fixed point, then supporting rail.

Today MUST present one object-led current-reality viewport centered on `Start here`.

Today’s first viewport MUST NOT show a broad backlog, motivational paragraph, score, or multiple suggestion cards.

Today fit suggestions SHOULD be executable and object-aware.

Today SHOULD use one shared object-row system exposing time, object title, primary action, status marker, relevant trust marker, and optional Goal or source context.

## SPEC-SURFACE-TODAY-STATES-001 — Calm complete state set

- **Concept:** `surface.today.states`
- **Modality:** `MUST`
- **Scope:** Resting, transitional, degraded, and recovery states
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-STATES-001`
- **Supersedes:** none

Today MUST distinguish loading, low-density, empty, populated, dense, stale external context, offline-healthy, permission denied, conflict, partial failure, recovery, destructive confirmation, and restored state. Empty space remains calm and may offer Capture, View Time, or Review Goals; it MUST NOT be filled with backlog or low-confidence suggestions.

## SPEC-SURFACE-TODAY-VISUAL-AUTHORITY-001 — Approved Today package, separate implementation proof

- **Concept:** `surface.today.visual-authority`
- **Modality:** `MUST`
- **Scope:** Today visual direction, final target, and implementation evidence
- **Status:** `normative`
- **Verification:** `PROOF-TODAY-VISUAL-MAPPING-001`
- **Supersedes:** none

Today visual review MUST use stable external reference IDs and preserve the difference between approved direction, approved final package, and implementation proof. Owner-approved VSP-02 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:160:93` is the Today visual target.

## SPEC-SURFACE-TODAY-MISSED-CONTINUITY-001 — Missed time preserves history and current status
- **Concept:** `surface.today.missed-placement-continuity`
- **Modality:** `MUST`
- **Scope:** A Today item that did not happen at its planned time
- **Status:** `normative`
- **Verification:** `SCENARIO-TODAY-MISSED-CONTINUITY-001`
- **Supersedes:** none

Today MUST retain the original placement in inspection, present the object's current status near Now, and offer at most one new-placement suggestion only when the complete fit threshold passes. Missing a time never silently moves the object or erases its prior schedule truth.

## SPEC-SURFACE-TODAY-ROW-001 — Today object row

- **Concept:** `surface.today.object-row`
- **Modality:** `MUST`
- **Scope:** Today object rows
- **Status:** `normative`
- **Verification:** `A11Y-TODAY-ROW-001`
- **Supersedes:** none

A Today object row MUST expose object identity, relevant context and state, primary action, secondary controls, and nonvisual semantics without duplicating Start here authority.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Today answers what reality can hold around now and what to act on next, preserving Intent through Action without becoming a backlog or calendar clone.

<!-- canon-section: entry-exit -->
Entry is root selection, restoration, deep-link handoff, or post-action return. Exit uses another root, native object depth, full-screen Capture/Search, Time handoff, or contextual Trust inspection; return restores Now, selection, and focus.

<!-- canon-section: routes-presentation -->
Today presents at Stage root. Compact reversible actions remain contextual; object depth uses native navigation; complex temporal editing goes to Time; Capture/Search are overlays, never Today children or roots.

<!-- canon-section: displayed-objects -->
Displayed objects retain canonical identity and show time, title, primary action, placement/lifecycle summary, Goal context, and a trust marker only when relevant. Protected and Fixed are anchored; Flexible, Suggested, and recovery states are lighter without using color alone.

<!-- canon-section: resting-states -->
Resting states are empty, low-density, normal, dense, active execution, closure-ready, and recovery-needed, with Now and Start here dominant whenever eligible.

<!-- canon-section: loading-transitional -->
Projection refresh, start, completion, proof handoff, undo, reschedule preview, and restoration preserve the prior usable projection until a validated replacement is ready and announce accepted state changes.

<!-- canon-section: empty-degraded -->
Offline local Today remains usable. Stale external facts are disclosed only when interpretation changes. Permission or projection failure preserves local objects and offers retry, Time, Capture, or diagnostics without fabricating a recommendation.

<!-- canon-section: commands-actions -->
Primary actions adapt to the object and use locked language such as `Start now` and `Open step`. Complete, Still counts, Move it, Blocked, Waiting, Not needed, Protected, Review, and Undo route through canonical commands. Drag has explicit Move/Edit alternatives.

<!-- canon-section: durable-effects -->
Accepted start, placement, completion, closure, proof, recovery, and undo operations follow Command to Event to Projection to Receipt to Replay and update linked Goal Path and Time projections without duplicate identity.

<!-- canon-section: failure-rollback -->
Rejected validation leaves state unchanged and explains the next safe action. Partial or external failure preserves the accepted local intent, exposes receipt status, and offers idempotent retry, undo, or Time-based repair; projection failure falls back to the last valid local state.

<!-- canon-section: offline -->
Eligibility, Start here, start/complete, local proof/closure, receipts, history, and replay work without account or network. Optional external freshness cannot gate local execution.

<!-- canon-section: privacy-data-classification -->
Today uses private local schedule, Goal, proof, recovery, and learned-fit context. Shell, logs, notifications, and visual proof redact sensitive titles and rationale by default; no private graph data goes to Account, R2, Source Atlas, or hosted AI.

<!-- canon-section: accessibility-reading-order -->
VoiceOver exposes ordered Now, Start here reason/state/actions, boundaries, next fixed point, then chronological objects. The rail has list-equivalent navigation, headings, jump controls, custom actions, and verbal adjustment summaries; no spatial-only meaning or action is permitted.

<!-- canon-section: dynamic-type -->
At every supported size, Start here identity/action remains first, rows reflow vertically, reasons and state do not truncate into ambiguity, and the rail may switch to its semantic list without hiding capability.

<!-- canon-section: reduce-motion -->
Object continuity, completion, and rail transitions become restrained fades or immediate state changes while retaining announcements, focus, receipt, and undo semantics.

<!-- canon-section: reduce-transparency -->
Atmosphere and materials resolve to opaque semantic surfaces with equivalent hierarchy, contrast, boundaries, and non-color state encoding.

<!-- canon-section: copy-state-language -->
Use `Start here`, `Recommended step`, `Step`, `Start now`, `Open step`, and the locked humane closure vocabulary. Do not expose runtime terms, shame, overdue pressure, AI branding, or productivity scoring.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:160:93` supplies approved Today design authority. It remains distinct from source rendering, accessibility/device evidence, implementation parity, and release proof.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Today/` owns presentation; `Core/LocalRuntimeOS/Projections/`, `PrivateLifeRuntimeKernel/`, and `Scheduling/` own local facts and fit; `Quality/` owns proof.

<!-- canon-section: tests -->
Tests cover eligibility and exclusion, one-suggestion threshold, state matrix, Start here actions, completion/proof/undo/replay, restoration, dense data, offline, stale external facts, VoiceOver order/actions, list equivalence, Dynamic Type, Reduce Motion/Transparency, contrast, and focus.

<!-- canon-section: proof -->
Evidence artifacts bind executed scenarios to exact source revisions and environments.
Required proof includes current-revision scenario logs, receipts/replay evidence, density and accessibility screenshot matrices, semantic action output, focus restoration, independent visual mapping/acceptance, exact commands and exits, and explicit skipped checks. This spec itself proves none of them.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Today projection, refresh, and primary-action work MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative Today data scale, warm/cold state, measurement tool, percentile/maximum, and regression threshold.
