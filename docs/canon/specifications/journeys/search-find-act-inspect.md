+++
spec_id = "JOURNEY-SEARCH-FIND-ACT-INSPECT"
title = "Search Find Act Inspect"
kind = "journey"
status = "normative"
owner_domain = "journey-search-find-act-inspect"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.search.find-act-inspect"]
inherits = ["LAW-LOCAL-AUTHORITY-001", "OBJECT-CANONICAL-GRAPH-001", "CONTROL-MATERIAL-CONFIRMATION-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "GLOBAL-SEARCH", "GLOBAL-TRUST-INSPECTION", "APP-NAVIGATION", "APP-DEEP-LINKING"]
source_owners = ["Native/Ambitions/Stage/", "Native/Ambitions/Core/LocalRuntimeOS/Search/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Search Find Act Inspect

This shadow journey coordinates Search routing and canonical-owner actions without duplicating object lifecycle or Trust disclosure law.

## JOURNEY-SEARCH-FIND-ACT-INSPECT-001 — Search never becomes mutation authority

- **Concept:** `journey.search.find-act-inspect`
- **Modality:** `MUST`
- **Scope:** Query, result selection, contextual action, and Trust inspection
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-SEARCH-FIND-ACT-INSPECT-001`
- **Supersedes:** none

Search MUST resolve local canonical identities, then route Open, Act, or Inspect to the owning destination. Query, ranking, selection, and action preview are non-durable; material action commits only after canonical revalidation and confirmation, and inspection itself never mutates.

<!-- canon-section: trigger-starting-state -->
Triggers are shell Search, keyboard shortcut, deep link, object handoff, or restored query; starting state records origin route/focus, privacy-safe scope, index freshness/health, query, filters, selection, and local projection availability.

<!-- canon-section: preconditions -->
The local index can identify result type and canonical ID or state a scoped gap; privacy filters apply before display. Network, account, hosted AI, and a complete index are not prerequisites for safe local results.

<!-- canon-section: happy-path -->
Accept query, rank deterministic local projections, expose identity/state and safe actions, re-resolve the selected canonical object, open owner detail or Trust inspection, or preview/confirm an action, commit through the owner, update results, issue Receipt, and restore predictable focus/return context.

<!-- canon-section: branches -->
Branches are Open step, Start now, schedule/reschedule, add Proof, pause/resume, review conflict, open setting, inspect Source/Privacy/History/Receipt, refine scope, open Capture, or no result. Unsupported/stale actions are withheld or revalidated, never guessed.

<!-- canon-section: cancellation -->
Cancel query, filter, result open, inspection, or action preview with no canonical mutation and return to exact origin/query/result focus. Canceling index rebuild retains last valid local results where safe.

<!-- canon-section: interruption-resume -->
Resume query, scope, filters, selected result, origin, scroll, pending non-durable preview, and focus. Re-resolve index/object revisions; stale action previews require renewed validation and confirmation.

<!-- canon-section: commit-boundary -->
Search/index/view/inspection state is non-mutating. An action crosses the boundary only inside its canonical owner after current validation, material confirmation, local commit, projection, and Receipt; result-list optimism is not success.

<!-- canon-section: failure -->
Every failure state retains the query, scope, resolved result identity, origin route, last valid projection fingerprint, and safe action set.
No result, partial/stale/corrupt index, unavailable projection, suppressed private data, deleted object, command rejection, projection delay, or external failure preserves query context and accurately limits available actions.

<!-- canon-section: recovery -->
Offer query repair, scope/filter change, local index rebuild from canonical projections, reopen current object, refresh action preview, retry owner command idempotently, inspect failure, or use Capture without fabricating a match.

<!-- canon-section: undo-rollback -->
Canonical undo appends a reversing mutation and Search refreshes the same stable result identity from the resulting projection.
Undo routes to the canonical owner and returns Search to the re-resolved result; index projections follow authoritative history. Inspection and index rebuild need no data rollback because they cannot mutate canonical state.

<!-- canon-section: receipts-proof -->
Queries/views produce no mutation Receipt. Accepted owner actions expose their Receipt/History; Trust inspection labels Proof, Source, Privacy, History, and Receipt distinctly and cannot self-certify any claim.

<!-- canon-section: accessibility -->
VoiceOver orders dismiss, query/scope, filters, result count/status, ranked results, actions, and inspection; headings/rotor and named actions preserve parity, Dynamic Type reflows vertically, reduced effects retain announcements, and focus returns to originating result/origin.

<!-- canon-section: offline -->
Query, ranking, filtering, approved local actions, owner routing, Trust inspection, rebuild from local projections, receipts, replay, and undo work offline; network cannot change core ranking authority or disclose more private content.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-SEARCH-FIND-ACT-INSPECT-001`, `SCENARIO-JOURNEY-SEARCH-STALE-ACTION-001`, `SCENARIO-JOURNEY-SEARCH-INDEX-REBUILD-001`, `SCENARIO-JOURNEY-SEARCH-PRIVACY-001`, `SCENARIO-JOURNEY-SEARCH-OFFLINE-001`, and `SCENARIO-JOURNEY-SEARCH-FOCUS-001`; assert canonical ID routing, preview non-durability, inspection non-mutation, false-success prevention, offline behavior, deterministic recovery, receipts, and accessibility.
