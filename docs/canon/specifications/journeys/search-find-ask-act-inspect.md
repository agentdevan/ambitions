+++
spec_id = "JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT"
title = "Search Find Ask Act Inspect"
kind = "journey"
status = "normative"
owner_domain = "journey-search-find-ask-act-inspect"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.search.find-ask-act-inspect"]
inherits = ["LAW-SEARCH-PRIVATE-COMMAND-LAYER-001", "LAW-LOCAL-AUTHORITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "LAW-RUNTIME-DURABLE-SUCCESS-001", "ACCESSIBILITY-SEMANTIC-EQUIVALENCE-001"]
depends_on = ["CONSTITUTION", "GLOBAL-SEARCH", "JOURNEY-SEARCH-FIND-ACT-INSPECT", "GLOBAL-CAPTURE", "GLOBAL-TRUST-INSPECTION", "APP-NAVIGATION", "APP-DEEP-LINKING"]
source_owners = ["Native/Ambitions/Stage/", "Native/Ambitions/Core/LocalRuntimeOS/Search/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Composer/Capture/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Search Find Ask Act Inspect

This journey composes with the preserved `JOURNEY-SEARCH-FIND-ACT-INSPECT-001` deterministic fallback and adds the selected Ask and Capture-routing behavior without replacing that fallback or inventing mutation, creation, or disclosure authority.

## JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001 — One input, grounded understanding, owner-routed consequence

- **Concept:** `journey.search.find-ask-act-inspect`
- **Modality:** `MUST`
- **Scope:** Unified Search input, immediate deterministic Find, optional grounded Ask, canonical-owner Act, Capture handoff, contextual Inspect, interruption, and deterministic offline fallback
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001`
- **Supersedes:** none

Search MUST accept one input, return immediate deterministic Find results, MAY progressively add an optional grounded Ask answer, present only owner-routed action proposals, hand creation intent to Capture, and keep Inspect in relevant context. Ask history stays session-local unless explicit user action routes a question, answer, proposal, or derived object to an identified canonical owner. The user MUST distinguish retrieved fact, inferred interpretation, and proposed change, and Ask unavailability MUST preserve a deterministic Find / Act / Inspect fallback.

<!-- canon-section: trigger-starting-state -->
Triggers are shell Search, keyboard shortcut, deep link, object handoff, creation intent detected in Search, or restored non-durable session context. Starting state records origin route and focus, privacy-authorized scope, index health, query, filters, deterministic results, approved local source availability, selection, and current session boundary.

<!-- canon-section: preconditions -->
Privacy filtering MUST precede retrieval and synthesis. Deterministic local projections and the current canonical object owners MUST remain independently addressable; account, network, hosted AI, cloud profiling, conversational intelligence, and a complete index are not prerequisites.

<!-- canon-section: happy-path -->
Accept the input; immediately rank privacy-authorized local objects and projections while typing; classify exact-search, natural-language-question, action, and creation intent without hiding ambiguity; optionally synthesize a bounded on-device answer grounded in displayed objects and approved local reference sources; label support, assumptions, uncertainty, retrieved fact, inferred interpretation, and proposed change; route Open or Inspect in context; route creation to Capture; preview a material action; re-resolve current owner and state; obtain explicit confirmation; let the owner commit and issue History, Receipt, and applicable Undo; then restore predictable Search context and focus.

<!-- canon-section: branches -->
Branch evidence covers exact Find, bounded Ask, owner-routed action, Capture handoff, inspection, privacy filtering, and approved-reference outcomes.
Branches include exact Find, optional Ask, Ask unavailable, ambiguous intent, mixed Find and Ask, unsupported question, proposed action, stale proposal, creation handoff, Open step, Start now, Source, Privacy, History, Proof, Receipts, no result, filtered private result, and approved-reference unavailability. Search MUST expose the applicable branch without fabricating support or a generic mutation path.

<!-- canon-section: cancellation -->
Cancel query, Ask synthesis, result open, inspection, creation handoff, or action preview with no canonical mutation. Cancellation returns to the exact origin, query, result, and focus where disclosure remains authorized; canceling synthesis leaves deterministic results usable.

<!-- canon-section: interruption-resume -->
Within the current session, resume query, scope, filters, deterministic results, selected object, supporting objects, answer, assumptions, uncertainty, proposal, origin, scroll, and focus. Re-resolve index, source, privacy, object, and owner revisions before showing resumed synthesis or proposal. After session expiry, regenerate from current state instead of restoring conversational history; explicit persistence remains owner-routed.

<!-- canon-section: commit-boundary -->
Find, Ask, proposal, Capture handoff, and Inspect are non-durable in Search. Creation commits only in Capture under Capture policy. A material action crosses the boundary only inside its canonical owner after current-state validation, visible consequence preview, explicit confirmation, typed local commit, projection, History, Receipt, and applicable Undo; result-list optimism is never success.

<!-- canon-section: failure -->
Failure evidence preserves deterministic results, query context, truthful canonical state, privacy boundaries, and exact recovery ownership.
No result, partial or corrupt index, Ask unavailable, unsupported synthesis, missing or changed grounding, stale source, privacy suppression, deleted object, stale proposal, owner rejection, projection delay, Capture rejection, and external-effect failure MUST preserve query context, identify what remains usable, withhold unsupported content, and leave canonical state truthful.

<!-- canon-section: recovery -->
Recovery offers query repair, scope refinement, deterministic Find / Act / Inspect fallback, local index rebuild from canonical projections, bounded Ask retry after grounding revalidation, current-object reopen, proposal regeneration, owner-command retry when idempotent, Capture return, or contextual Trust inspection. Recovery MUST NOT invent a result, answer, source, owner, or mutation.

<!-- canon-section: undo-rollback -->
Search itself has no mutation to undo. Dismissal rolls back only non-durable query, answer, proposal, or inspection presentation. Capture owns cancellation of uncommitted creation. Canonical Undo appends its owner-defined reversing mutation and Search refreshes the same stable result identity from the resulting projection and History.

<!-- canon-section: receipts-proof -->
Queries, answers, session-local history, proposals, and inspections create no mutation Receipt. Accepted owner actions expose their Receipt and History. Every substantive Ask answer exposes privacy-authorized supporting objects, approved sources, assumptions, and uncertainty; contextual Trust inspection distinguishes Source, Privacy, History, Proof, and Receipts without self-certifying an answer.

<!-- canon-section: accessibility -->
VoiceOver orders dismiss, unified input and scope, deterministic result count and status, ranked objects, bounded answer, supporting objects and sources, assumptions and uncertainty, proposed actions, and Inspect controls. Labels and non-color cues distinguish retrieved fact, inferred interpretation, and proposed change. Dynamic Type reflows vertically; reduced motion replaces progressive transitions with immediate state-preserving updates; Reduce Transparency uses opaque semantic grouping; focus returns to the originating object or input.

<!-- canon-section: offline -->
Find, result opening, local action proposals, owner routing, Capture handoff, contextual Inspect, local index rebuild, History, Receipts, replay, and Undo remain usable offline. Ask MAY run on device from privacy-authorized local data and approved cached references, but its absence or cancellation returns gracefully to the deterministic Find / Act / Inspect fallback without changing retrieval authority or disclosing private data.

<!-- canon-section: scenario-tests -->
Scenario evidence binds retrieval, grounding, session boundaries, owner routing, mutation safety, offline fallback, recovery, focus, and non-color accessibility.
Execute `SCENARIO-JOURNEY-SEARCH-FIND-ASK-ACT-INSPECT-001`, `SCENARIO-JOURNEY-SEARCH-ASK-UNAVAILABLE-001`, `SCENARIO-JOURNEY-SEARCH-GROUNDING-CHANGE-001`, `SCENARIO-JOURNEY-SEARCH-SESSION-EXPIRY-001`, `SCENARIO-JOURNEY-SEARCH-CAPTURE-HANDOFF-001`, `SCENARIO-JOURNEY-SEARCH-STALE-PROPOSAL-001`, `SCENARIO-JOURNEY-SEARCH-PRIVACY-001`, `SCENARIO-JOURNEY-SEARCH-OFFLINE-001`, and `SCENARIO-JOURNEY-SEARCH-ACCESSIBILITY-001`; prove immediate deterministic retrieval, optional synthesis, evidence distinctions, session-local history, owner routing, no silent mutation, offline fallback, recovery, focus, and non-color accessibility equivalence.
