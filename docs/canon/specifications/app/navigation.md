+++
spec_id = "APP-NAVIGATION"
title = "App Navigation"
kind = "app"
status = "normative"
owner_domain = "app-navigation"
canon_revision = 1
profile = "system-v1"
owns_concepts = [
  "app.navigation.ia-map",
  "app.navigation.presentation",
  "app.navigation.restoration",
  "app.navigation.root-interaction",
  "app.navigation.state",
]
inherits = [
  "CONST-IA-ROOT-001",
  "LAW-IA-NONROOT-001",
  "LAW-SHELL-STAGE-001",
  "CONTROL-FORCE-NOTHING-001",
  "PLATFORM-NATIVE-IPHONE-001",
  "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001",
]
depends_on = ["CONSTITUTION", "APP-SHELL"]
source_owners = [
  "Native/Ambitions/App/",
  "Native/Ambitions/Stage/",
  "Native/Ambitions/Quality/",
]
+++

# App Navigation

This specification owns route relationships and presentation semantics, not the root IA itself.

## SPEC-APP-NAVIGATION-IA-MAP-001 — Navigation maps constitutional owners

- **Concept:** `app.navigation.ia-map`
- **Modality:** `MUST`
- **Scope:** Whole-app route graph and ownership lookup
- **Status:** `normative`
- **Verification:** `AUDIT-APP-NAVIGATION-IA-MAP-001`, `SCENARIO-APP-NAVIGATION-OWNERSHIP-001`
- **Supersedes:** none

The navigation graph MUST map each constitutional root to its owning root presentation and map each non-root system to the owner declared by `LAW-IA-NONROOT-001`. This file does not reproduce or amend those sets. Routes for drilldowns, Capture, Search, Trust inspection, setup, permissions, degraded recovery, and external entry remain subordinate to their owning specifications. A route may present an owner; it cannot become a second owner or canonical store.

## SPEC-APP-NAVIGATION-PRESENTATION-001 — Presentation follows route kind

- **Concept:** `app.navigation.presentation`
- **Modality:** `MUST`
- **Scope:** Root, drilldown, object detail, review, choice, inspection, Capture, and Search presentations
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-NAVIGATION-PRESENTATION-001`, `AUDIT-APP-NAVIGATION-DEPTH-001`
- **Supersedes:** none

A root route MUST present at Stage root with root switching available. A normal drilldown uses native full-screen depth and native return. Compact object detail, small choices, and contextual inspection use the smallest native presentation that preserves clarity and accessibility. Complex review, Capture, and Search use full-screen presentation with their own cancellation and recovery contracts. Root chrome visibility is delegated to `APP-SHELL`; presentation choice may not create an alternate root.

Root navigation MAY appear at root depth.

## SPEC-APP-NAVIGATION-ROOT-INTERACTION-001 — Root interaction preserves useful state

- **Concept:** `app.navigation.root-interaction`
- **Modality:** `MUST`
- **Scope:** Tap, re-tap, long-press disclosure, and assistive root activation
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-NAVIGATION-ROOT-SWITCH-001`, `SCENARIO-APP-NAVIGATION-ROOT-RESET-001`
- **Supersedes:** none

Activating a different root MUST switch to that root while preserving reasonable per-root navigation and content state. Re-activating the current root returns to the canonical anchor defined by that surface specification, without deleting drafts or accepted state. Long press may disclose a label and description but is never required. Assistive activation exposes the same roots, labels, selection state, and predictable result.

Tapping a root icon MUST switch roots while preserving each root’s reasonable state.

Ambitions MUST support thin use and deep use.

## APP-NAVIGATION-RESTORATION-001 — Restoration validates before presentation

- **Concept:** `app.navigation.restoration`
- **Modality:** `MUST`
- **Scope:** Relaunch, interruption, memory pressure, and invalidated route restoration
- **Status:** `normative`
- **Verification:** `SCENARIO-APP-NAVIGATION-RESTORE-001`, `SCENARIO-APP-NAVIGATION-INVALIDATED-001`
- **Supersedes:** none

Navigation restoration MUST validate that the target owner and referenced local object still exist and remain eligible before presenting depth. A valid route restores the prior root, depth, selection, and focus as far as product meaning permits. An invalid or unavailable target degrades to the nearest valid owning context with a calm explanation and repair action; it must not fabricate an object, reveal a private fallback, or trap the user at an empty route.

Required proof MUST be visible before completion.

## APP-NAVIGATION-STATE-001 — One route owner at each depth

- **Concept:** `app.navigation.state`
- **Modality:** `MUST`
- **Scope:** Route stack, overlays, modal presentation, and dismissal
- **Status:** `normative`
- **Verification:** `AUDIT-APP-NAVIGATION-SINGLE-OWNER-001`, `SCENARIO-APP-NAVIGATION-DISMISSAL-001`
- **Supersedes:** none

Navigation state MUST distinguish the selected root, ordered drilldown path, optional presentation, return target, and focus target. Only one owner may control a given presentation layer. Dismissal returns through the recorded parent or owner-defined safe fallback. Route state is not canonical object state and cannot bypass mutation, confirmation, receipt, or replay law.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Navigation owns route identity, parent-child relationships, presentation kind, root switching, dismissal, restoration, and focus return. It does not own the constitutional root set, shell rendering, destination behavior, canonical objects, or product mutation.

<!-- canon-section: inputs-outputs -->
Inputs are typed route requests, selected root, current depth, eligible destination owners, object-resolution results, presentation context, and accessibility focus. Outputs are a validated route transition, presentation instruction, return target, and focus target or a safe degraded result.

<!-- canon-section: authority-boundary -->
The Constitution owns root and non-root IA. `APP-SHELL` owns chrome visibility and containment. Destination specifications own content and actions. Navigation references those owners and MUST NOT restate, weaken, or duplicate them.

<!-- canon-section: data-classification -->
Route identifiers and restoration metadata remain local. Object identifiers are minimum-necessary references; route labels, logs, and restoration payloads must not include sensitive titles, proof, notes, attachments, or inferred private context.

<!-- canon-section: state-model -->
The navigation record separates root selection, depth, presentation, return, and focus.

Navigation state contains selected root, root-local state token, ordered drilldown path, optional presentation, parent return target, focus target, and resolution status. Invalid states include unknown owner, duplicate presentation owner, orphan depth, unauthorized target, and stale object reference.

<!-- canon-section: failure-recovery -->
Route failure retains the current valid owner and chooses one safe recovery transition.

Unknown, stale, unauthorized, or unrenderable routes resolve to the nearest safe owning context and expose retry, dismiss, or local repair when useful. Failure never creates placeholder product behavior or destroys draft/canonical state.

<!-- canon-section: local-network-boundary -->
All local routes, root switching, dismissal, and restoration work offline and without an account. A destination that requires optional network data must own its own degraded state; navigation still opens the safe local context.

<!-- canon-section: determinism -->
The same typed route, eligibility result, current stack, and presentation policy produce the same transition or rejection. Navigation does not infer hidden destinations from unstructured strings or server response content.

<!-- canon-section: observability -->
Proof must expose route ID, owner, source class, resolution result, selected root, depth, presentation owner, dismissal target, and focus result with private payloads redacted. Logs and maps are evidence aids, not claims of runtime correctness.

<!-- canon-section: source-ownership -->
Canonical target ownership is exact: `Stage/` owns the navigation graph, route depth, presentation, restoration, and focus containment; `App/` owns external route entry, root-scene assembly, and dependency injection only; `Quality/` owns route-depth proof. A source repair must move or collapse that graph into `Stage/` without treating `App/` as an equivalent owner. Source presence remains implementation evidence and does not establish compliance.

<!-- canon-section: tests-proof -->
Required tests cover every route kind, root switch and re-tap, per-root state preservation, back and edge swipe, cancellation, interrupted restoration, stale object targets, duplicate-owner rejection, VoiceOver selection and focus order, Dynamic Type, Reduce Motion, and safe offline behavior.

<!-- canon-section: performance-resource-constraints -->
On the oldest supported physical iPhone in an optimized build, measured with a graph of 4 roots, 250 typed route definitions, maximum depth 20, and a queue capped at 32 requests, local route resolution MUST complete within 20 ms at P95, transition dispatch within 50 ms at P95, and restoration decision within 100 ms at P95 across 1,000 operations. Requests beyond the depth or queue ceiling MUST fail closed. Ten thousand resolutions MUST add no more than 8 MiB resident memory, perform zero synchronous disk I/O on the interaction path, and perform zero network calls. Navigation MUST use no polling or autonomous background loop. These are normative targets;
