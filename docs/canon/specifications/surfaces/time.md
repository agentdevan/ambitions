+++
spec_id = "SURFACE-TIME"
title = "Time"
kind = "surface"
status = "normative"
owner_domain = "surface-time"
canon_revision = 1
profile = "surface-v1"
owns_concepts = [
  "surface.time.primary-identity",
  "surface.time.views",
  "surface.time.day",
  "surface.time.first-viewport",
  "surface.time.purpose",
  "surface.time.visual-authority",
]
inherits = [
  "CONST-IA-ROOT-001",
  "PLATFORM-CALENDAR-REPLACEMENT-001",
  "TIME-EXTERNAL-VISIBILITY-001",
  "CONTROL-MATERIAL-CONFIRMATION-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL", "APP-NAVIGATION", "APP-PERMISSIONS"]
source_owners = [
  "Native/Ambitions/Surfaces/Time/",
  "Native/Ambitions/Core/Time/",
  "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/",
  "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/",
  "Native/Ambitions/Core/LocalRuntimeOS/Continuity/",
  "Native/Ambitions/Core/LocalRuntimeOS/Inspection/",
  "Native/Ambitions/Quality/",
]
+++

# Time

This shadow specification defines Time as the intended first-class temporal operating surface. It states a replacement target and acceptance bar, not current parity, migration completion, or readiness.

## SPEC-SURFACE-TIME-PRIMARY-IDENTITY-001 — First-class Life Calendar target

- **Concept:** `surface.time.primary-identity`
- **Modality:** `MUST`
- **Scope:** Time root and temporal depth
- **Status:** `normative`
- **Verification:** `PROOF-CALENDAR-GRADE-001`
- **Supersedes:** none

Time MUST target first-class replacement of ordinary personal calendar planning while expressing Protected, Fixed, Flexible, and Suggested time, capacity, conflict, and adjustment. It is neither an anti-calendar nor a calendar clone. This target MUST NOT be described as current external-calendar parity or readiness until the complete proof bar is current.

## SPEC-SURFACE-TIME-VIEWS-001 — Calendar-grade view family

- **Concept:** `surface.time.views`
- **Modality:** `MUST`
- **Scope:** Day, Week, Month, Year, and List
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-VIEWS-001`, `A11Y-TIME-LIST-PARITY-001`
- **Supersedes:** none

Time MUST provide Day, Week, Month, Year, and List with a visible Today control, last-used-view restoration, and discoverable view switching. List is the complete chronological and screen-reader-friendly counterpart to grids. Month and Year expose semantic summaries and drilldown rather than illegible object density.

## SPEC-SURFACE-TIME-DAY-001 — Direct, inspectable day planning

- **Concept:** `surface.time.day`
- **Modality:** `MUST`
- **Scope:** Day view and temporal object manipulation
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-DAY-001`, `A11Y-TIME-EDIT-ACTIONS-001`
- **Supersedes:** none

Day MUST show the current-time marker, all-day rail, Events, Steps, Reminders, time-authority semantics, Goal context, and relevant proof or adjustment markers. Drag and resize MUST have explicit Move, Change start, Change duration, and typed edit alternatives with the same conflict preview, consequence summary, confirmation, focus return, and receipt.

## SPEC-SURFACE-TIME-FIRST-VIEWPORT-001 — Temporal reality before controls

- **Concept:** `surface.time.first-viewport`
- **Modality:** `MUST`
- **Scope:** Time first visible and semantic viewport
- **Status:** `normative`
- **Verification:** `PROOF-TIME-FIRST-VIEWPORT-001`
- **Supersedes:** none

The first viewport MUST foreground the selected range, Now or Today anchor, protected and fixed reality, flexible capacity, visible conflicts, and the next meaningful temporal object. View switching, search/filter, external-diff review, and creation remain discoverable but subordinate to temporal reality.

## SPEC-SURFACE-TIME-PURPOSE-001 — Fit, consequence, and user authority

- **Concept:** `surface.time.purpose`
- **Modality:** `MUST`
- **Scope:** Placement, creation, conflict, adjustment, and import review
- **Status:** `normative`
- **Verification:** `SCENARIO-TIME-FIT-001`
- **Supersedes:** none

Time MUST answer how time is arranged, what is protected or fixed, what can move, and what happens when reality changes. It previews conflict, recurrence, deadline, external-write, and adjustment consequences before material commit. External visibility and capacity reservation remain separate; an unreviewed external candidate never appears as an Ambitions Event.

## SPEC-SURFACE-TIME-VISUAL-AUTHORITY-001 — Approved Time package, separate implementation proof

- **Concept:** `surface.time.visual-authority`
- **Modality:** `MUST`
- **Scope:** Time grid, list, and direct-manipulation visual authority
- **Status:** `normative`
- **Verification:** `PROOF-TIME-VISUAL-MAPPING-001`
- **Supersedes:** none

Visual authority MUST use stable external IDs and keep approved package authority and implementation evidence distinct. Owner-approved VSP-04 package `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:202:93` is the Time visual target. Candidate naming does not weaken its durable owner approval. The package does not prove calendar parity, direct-manipulation behavior, SwiftUI parity, accessibility, device behavior, runtime behavior, Visual Green, or release status.

## Completeness contract

<!-- canon-section: purpose-user-question -->
Time answers where commitments and Steps live, what capacity remains, what can move, and the inspectable consequences of making reality fit.

<!-- canon-section: entry-exit -->
Entry is root selection, Today/Goal handoff, Search, Capture placement, restoration, deep link, or external-diff review. Exit preserves range, view, selection, scroll anchor, edit draft, and focus through native back or root/overlay handoff.

<!-- canon-section: routes-presentation -->
Day, Week, Month, Year, and List live under the Time root. Object detail is compact where sufficient; complex recurrence, grouped adjustment, import review, and export use focused native review. No view becomes a root.

<!-- canon-section: displayed-objects -->
Canonical identity connects each temporal object to its owning record and receipt chain.
Time projects canonical Events, Steps, Reminders, Future Steps, all-day/multi-day spans, placements, protected blocks, conflicts, recovery windows, proof markers, and reviewed provenance. Unreviewed candidates remain review records, not native Events.

<!-- canon-section: resting-states -->
Required states include each view at empty, populated, dense, selected, editing, previewing, conflicting, importing, restored, and today/now anchored conditions, plus external-hidden-capacity-reserved state.

<!-- canon-section: loading-transitional -->
Range load, recurrence expansion, view switch, drag/resize preview, conflict simulation, import scan, commit, external reconciliation, undo, and restoration keep last valid local content until deterministic replacement is ready.

<!-- canon-section: empty-degraded -->
Time distinguishes genuinely empty, permission denied, stale source, pending external diff, partial import, external-write failure, sync pending/conflict, offline healthy, and local-store degradation. Ambitions-owned Time remains usable; failures preserve drafts and accepted local intent.

<!-- canon-section: commands-actions -->
Create Event/Step/Reminder, select, edit, move, resize, schedule, reschedule, change authority/rule, scope recurrence, delete/Trash/restore, import/link/reserve/ignore/reject, export, review conflict, and undo all route through canonical commands. Every spatial action has named controls and List access.

<!-- canon-section: durable-effects -->
Accepted creation, placement, recurrence, import, adjustment, deletion, restore, notification, export, and external write produce canonical events, projections, receipts, replay state, and outbox/reconciliation state where external effects apply.

<!-- canon-section: failure-rollback -->
Invalid placement does not commit. Partial external failure keeps local commit and durable result state. Recurrence and grouped changes retain scope preview and rollback context. Retry is idempotent; undo restores the prior valid placement without erasing receipt history.

<!-- canon-section: offline -->
All Ambitions-owned views, objects, placement, conflict preview, local search/filter, edit, receipts, and replay work without account or network. Optional source unavailability does not hide or corrupt local calendar reality.

<!-- canon-section: privacy-data-classification -->
Calendar contents, attendees, location, schedule assumptions, capacity, Goal links, proof, and history are private local data. Import/export and external writes use minimum payload, contextual consent, redaction, preview, receipt, and recovery. R2 and Account never receive private temporal context.

<!-- canon-section: accessibility-reading-order -->
Each grid exposes ordered date/time headings, object labels/values/actions, conflict and preview summaries, and jump controls. List supplies full range navigation and action parity. Month/Year provide verbal summaries; drag/resize has explicit alternatives; focus returns to the changed object.

<!-- canon-section: dynamic-type -->
At larger sizes controls and object detail reflow, grids retain meaningful minimum geometry, and List becomes the complete alternative without losing recurrence, time authority, conflict, provenance, or action capability.

<!-- canon-section: reduce-motion -->
Drag ghosts, range transitions, adjustment previews, and object moves become static outlines, verbal summaries, or immediate updates while keeping consequence, focus, and receipt semantics.

<!-- canon-section: reduce-transparency -->
Grid layers, overlays, and materials become opaque semantic surfaces with equivalent boundaries, current-time visibility, conflict distinction, selection, and contrast.

<!-- canon-section: copy-state-language -->
Use Event, Step, Reminder, Protected, Fixed, Flexible, Suggested, Move it, Review, and Undo. Translate internal reflow language into Adjust plan, Make this fit, or Resolve conflict. Avoid parity, readiness, shame, density scoring, or runtime vocabulary.

<!-- canon-section: visual-authority -->
The named package controls geometry, hierarchy, composition, states, and adaptive layout.
Stable package ID `FIGMA:SWtHm9ouHTPbEFfNrrtZwv:202:93` supplies approved Time design authority. Calendar behavior, source rendering, accessibility/device evidence, implementation parity, replacement readiness, and release proof remain separate.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Surfaces/Time/` owns presentation; `Core/Time/` owns temporal primitives; `Core/LocalRuntimeOS/Scheduling/`, `ExternalWrites/`, `Continuity/`, and `Inspection/` own behavior and facts; `Quality/` owns proof. Current compliance is unclaimed.

<!-- canon-section: tests -->
Tests cover five views, recurrence/exceptions, time zones/DST, all-day/multi-day, authority/rules, drag and named alternatives, conflict/adjustment, creation/edit/delete/restore, import outcomes, external failures, search/filter/export, notifications, offline/replay, scale, VoiceOver/List parity, Dynamic Type, reduced effects, contrast, and focus.

<!-- canon-section: proof -->
Calendar replacement claims require current calendar-grade scenario, migration, receipt/replay, device performance, screenshot/video, semantic parity, accessibility, privacy, failure/recovery, and owner-accepted visual evidence. This spec and a successful compiler build provide none of that readiness proof.

<!-- canon-section: performance -->
Resource behavior is bounded, cancellable, local, and foreground-safe.
Time range loading, recurrence expansion, scrolling, direct manipulation, named-edit preview, and List search MUST remain bounded and cancellable, perform no interaction-path network gating or synchronous disk I/O, use no polling or unbounded background loop, and preserve foreground responsiveness under Low Power Mode, thermal pressure, protected-data unavailability, and storage pressure. `GAP-PERFORMANCE-CALIBRATION-SURFACES-GLOBALS-001` records the missing Article 31 calibration. Implementation authorization requires an owner-approved performance-registry record declaring device floor, OS, build configuration, representative temporal/recurrence data scale, warm/cold state, measurement tool, percentile/maximum, frame/scroll metric, and regression threshold. Current performance and physical-device proof remain absent.
