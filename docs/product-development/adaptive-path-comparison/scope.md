+++
initiative = "adaptive-path-comparison"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

For one stable Goal outcome, the user can compare a small set of meaningfully
different route proposals against the current route or current focused proposal.
The comparison explains what each option preserves, changes, requires, costs,
assumes, leaves unknown, and would do to near-term capacity without compressing
unlike tradeoffs into a score.

The user may correct inputs, inspect omitted options, defer, reject every
candidate, or select one proposal. Selection records preference only; it does
not activate a Goal Path version, create Steps, accept Proof rules, change the
Goal, or place work in Time. The canonical Goal Path owner must revalidate and
confirm the selected proposal before mutation.

This Scope owns qualitative selection among multiple routes toward the same
outcome. Changed destinations go to destination adoption and pivot. Complete
cross-object all-or-none corrections go to Life Branch only when that stricter
threshold is met.

## In scope

- Comparison of two to four meaningfully different same-outcome route
  candidates, including the current route baseline when one exists.
- A stable, inspectable reason for each included candidate and a discoverable
  list of materially different omitted candidates with omission reasons.
- Qualitative comparison of requirements, completed progress, Proof continuity,
  capability relevance, duration range, cost/resource pressure, location,
  availability, capacity/Time pressure, reversibility, source freshness,
  uncertainty, and user-declared priorities where applicable.
- Side-effect-free correction, candidate editing, refresh, defer, reject-all,
  and explicit selection.
- Staleness detection and revalidation handoff to the canonical Goal Path owner.
- Local, offline, private, accessible comparison and recovery.

## Out of scope

- Recommending, creating, or changing a Goal outcome.
- Generating authoritative route facts; candidates must arrive from Goal Path
  generation or an equivalent source/freshness contract.
- Activating a Goal Path version, creating canonical Steps, accepting Proof
  rules, committing placements, or changing Time.
- Persisting candidates as parallel canonical Goal Paths or execution owners.
- A composite compatibility, ability, employability, success, or best-path
  score; automatic selection; or schedule-fit authority.
- Comparing routes that differ only in wording, presentation, or timeslot.
- Formal transfer credit, equivalency, eligibility, licensing, hiring,
  admissions, medical, or other professional determination.
- General Life Branch reconciliation, an alternate private graph, or a future-
  self prediction surface.

## Requirements

### REQ-001 — Comparison preserves one Goal outcome

Every candidate must bind the same canonical Goal identity and unchanged
desired outcome. A candidate that changes the outcome must be excluded and
handed to destination adoption/pivot. Candidate review and selection must not
edit the Goal.

### REQ-002 — The current path is the baseline

When a current Goal Path exists, comparison must include its current accepted
version, completed nodes, accepted Proof, user edits, placements, assumptions,
and source state as the baseline. Before first activation, the currently focused
route proposal is the baseline and must be labeled non-canonical. Missing or
stale baseline facts block a decision until refreshed or explicitly shown as
unknown.

### REQ-003 — The visible set is bounded and alternatives remain discoverable

The main comparison must contain two to four candidates, including the baseline.
It must represent the materially distinct viable choices rather than merely the
highest internal rank. Any additional materially distinct candidate must remain
discoverable with its inclusion/omission reason and may replace a visible option
at the user's request. No hidden score may make an option disappear permanently.

### REQ-004 — Candidates must be meaningfully different

An alternative qualifies only when it changes at least one material consequence:
a gate or prerequisite, route structure, authority condition, duration range,
cost/resource commitment, location/availability, capacity pressure,
reversibility, evidence continuity, or user-declared priority tradeoff. Wording,
layout, minor optional detail, or timeslot alone is not a distinct route.
Consequence-equivalent candidates must be combined for review without merging
their source lineage.

### REQ-005 — Comparison is qualitative and evidence-linked

Each visible route must state what it preserves, changes, requires, costs,
assumes, leaves unknown, and places at risk. Applicable dimensions are shown
side by side or in an equivalent ordered form, with source, freshness,
uncertainty, and user-correction links. An unavailable dimension is `unknown`
or `not applicable`, never silently omitted or converted to a number.

### REQ-006 — Progress continuity is not requirement satisfaction

The comparison must distinguish retained personal evidence, relevance to a
candidate, apparent support for a sourced condition, recognition by policy, and
formal external acceptance. Proof and capabilities may show continuity without
being graded or marking a route requirement satisfied. Irrelevance to one route
must not downgrade or erase the original evidence.

### REQ-007 — Capacity is a tradeoff, not selection authority

Comparison may show non-committing schedule pressure using current placements,
Protected/Fixed time, transition and recovery needs, Step shape, and declared
capacity. It must show affected windows and uncertainty, commit no placement,
and never auto-select the easiest route to schedule.

### REQ-008 — User priorities remain explicit and non-numeric

The user may identify which visible considerations matter in this decision and
correct how a route affects them. Those priorities may change explanation and
presentation order but must not become a hidden global preference, personality
inference, or composite route score. Value conflicts remain explained rather
than adjudicated.

### REQ-009 — Source and professional boundaries remain visible

Every hard gate, availability claim, route distinction, and external acceptance
state must retain authority, region/program, retrieval date, freshness, and
uncertainty. Stale or contradicted input may invalidate one candidate without
silently invalidating others. Ambitions must not claim professional eligibility,
formal equivalency, current opening, or likely success. Editing a source-backed
claim or route meaning must remove unsupported attribution and require renewed
generation or authority review before that candidate can be selected.

### REQ-010 — Comparison is side-effect-free

Opening, refreshing, editing, reordering, correcting, omitting, restoring,
deferring, rejecting, or selecting in comparison must leave Goal, Goal Path,
Step, Proof, Closure, capability, placement, and Time state unchanged. Candidate
durability for interruption recovery does not grant canonical path identity or
execution authority.

### REQ-011 — The user can reject all, defer, or select one proposal

Every review must offer inspect, correct inputs, replace an included option,
defer, reject all, and select exactly one candidate. Reject-all and defer preserve
the current accepted path. Selection must show the chosen candidate, rejected
alternatives, material consequences, unresolved unknowns, and the fact that a
separate Goal Path confirmation remains.

### REQ-012 — Selection returns a proposal, not a path mutation

A selected candidate becomes one reviewable proposal for the canonical Goal
Path owner. Selection must retain candidate/source identity and produce truthful
selection history without reporting activation. The Goal Path owner must
revalidate current Goal/path revisions, sources, Proof, capabilities,
constraints, and confirmation scope before creating one new version.

### REQ-013 — Staleness stops selection honestly

Changes to the Goal outcome, current path, completed work, Proof, capability,
source, cost, availability, constraint, or Time facts must mark the affected
comparison rows and candidates stale. The user may refresh, inspect the change,
remove an invalid candidate, or exit; a stale candidate cannot be selected or
handed off as current.

### REQ-014 — Recovery preserves the last accepted route

Cancellation, rejection, interrupted review, failed refresh, stale handoff, or
failed Goal Path activation must preserve the last accepted path and the
comparison decision context. Resume must restore candidate identity, inclusion
reasons, corrections, priorities, review position, and focus after revalidating
facts. Rollback of an activated version belongs to Goal Path and cannot erase
the selection or later started work.

### REQ-015 — Private comparison remains local

Goal, path, Proof, capability, cost, location, schedule, priority, candidate,
and comparison history are private local graph data and must work offline. No
private payload may reach Account, R2, Source Atlas, hosted AI, telemetry, or a
public reference service. Protected facts may be used only when explicitly
provided and locally permitted; missing sensitive facts remain unknown.

### REQ-016 — No visual matrix is required for understanding

Every candidate must have an ordered semantic representation naming identity,
baseline status, inclusion reason, material differences, sources, unknowns,
progress continuity, capacity pressure, priorities, selection consequence, and
actions. VoiceOver, Voice Control, Switch Control, Full Keyboard Access,
Dynamic Type, increased contrast, reduced motion, RTL, and non-color cues must
support the full flow. Focus and announcements must return to the changed row,
candidate, selection summary, or recovery action.

## Acceptance criteria

1. **AC-001 (REQ-001):** Routes for one astronaut-candidacy Goal enter
   comparison; an aerospace-safety destination is excluded and handed to pivot
   without changing the Goal.
2. **AC-002 (REQ-002):** The accepted current Goal Path appears with completed
   work, Proof, edits, placements, assumptions, and source state; a stale or
   incomplete baseline cannot support selection.
3. **AC-003 (REQ-003):** The main review shows two to four routes including the
   baseline, and every additional material option remains discoverable with a
   stable reason and can replace a visible candidate by user choice.
4. **AC-004 (REQ-004):** Materially different education, experience, or pilot
   routes remain separate; wording-only and timeslot-only variants do not.
5. **AC-005 (REQ-005):** Every route exposes applicable tradeoffs and labels
   missing dimensions unknown/not applicable with source and correction access;
   none are compressed into a scalar.
6. **AC-006 (REQ-006):** Reused Proof is shown as personal continuity without
   grading or external acceptance, and irrelevance to another route does not
   modify the Proof or capability.
7. **AC-007 (REQ-007):** Capacity simulation shows affected windows and
   uncertainty while placements remain byte-for-byte unchanged and the
   easiest-to-schedule option is not auto-selected.
8. **AC-008 (REQ-008):** User-declared priorities alter explanation/order only
   within this review, remain inspectable/resettable, and produce no global
   trait or numeric route ranking.
9. **AC-009 (REQ-009):** Stale availability invalidates only dependent routes,
   retains exact authority/freshness explanation, and makes no eligibility,
   equivalency, opening, or success claim. Editing a sourced gate removes its
   unsupported attribution and blocks selection pending renewed review.
10. **AC-010 (REQ-010):** Every comparison action, including selection, leaves
    all canonical Goal, Path, Step, Proof, capability, placement, and Time state
    unchanged.
11. **AC-011 (REQ-011):** Defer and reject-all preserve the current path;
    selection captures one proposal plus alternatives, consequences, unknowns,
    and the pending activation boundary.
12. **AC-012 (REQ-012):** The selected proposal retains lineage and cannot become
    current until fresh Goal Path revalidation and explicit confirmation create
    exactly one new version.
13. **AC-013 (REQ-013):** Changing one source, Proof, capability, Goal, or Time
    fact stales only dependent rows/candidates and blocks their selection until
    refreshed.
14. **AC-014 (REQ-014):** Interruption, stale handoff, activation failure, and
    resume preserve the accepted path, review context, focus, and truthful
    History without duplicate activation.
15. **AC-015 (REQ-015):** Comparison works offline and privacy-egress tests show
    no private payload at any prohibited destination; absent sensitive facts
    remain unknown.
16. **AC-016 (REQ-016):** Direct assistive-technology verification proves full
    ordered comparison, candidate replacement, correction, selection, recovery,
    focus, announcements, Dynamic Type, contrast, reduced motion, RTL, and
    non-color parity.

## Dependencies

- `goal-path-generation` or an equivalent contract supplies candidates with
  stable identity, route semantics, source/freshness, and assumptions.
- A user-owned Goal is required; approved capability continuity may supply
  local evidence but cannot become route authority.
- The canonical Goal Path owner performs revalidation and activation after
  selection. Time/placement owners separately govern any later scheduling.
- `destination-adoption-and-pivot` owns changed outcomes.
- `life-branch-reconciliation` owns only complete cross-object all-or-none
  correction after ordinary Goal Path and Time mechanisms are insufficient.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

- Goal Path canon should explicitly distinguish a current version, comparison
  candidates, one selected proposal, and the later activation command while
  retaining one current Goal Path identity.
- Goal Path adaptation and Receipt canon should own revalidation, version
  confirmation, rollback, and history after comparison selection.
- Goals surface canon should own accessible qualitative comparison without a
  second root surface or visual-only lattice.
- Scheduling canon should define comparison pressure as non-durable simulation,
  never placement authority.
- Proof, capability, public-reference, privacy, History, Receipt, and
  accessibility canon retain their owners and gain only declared comparison
  relationships and consequences.

## Risks and open decisions

Resolved product decisions:

- The visible set contains two to four options including the baseline; omitted
  material alternatives remain discoverable and user-substitutable.
- Meaningful difference is a material consequence, never wording or timeslot.
- Comparison is qualitative. User priorities affect explanation, not authority.
- Selection returns one proposal and never activates it.
- Changed outcomes and cross-object all-or-none corrections leave this flow.

Remaining Design-level risks are comparison density, stable qualitative
ordering, source-change comprehension, preserving context during refresh, and
making omitted candidates discoverable without a dashboard. Design may solve
presentation, but it cannot introduce a score, hidden pruning, or mutation
authority.
