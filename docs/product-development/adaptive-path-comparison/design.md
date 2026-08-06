+++
initiative = "adaptive-path-comparison"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Adaptive path comparison is a Goals-owned, local planning workspace for two to
four meaningfully different routes toward one unchanged Goal outcome. It
normalizes generated candidates and the current accepted Goal Path baseline
into an ordered qualitative comparison. It never exposes or derives a route
score. Every visible statement retains its source, freshness, uncertainty, and
correction route.

The comparison runtime has three deliberately separate artifacts:

1. `PathComparisonSession` is a recoverable, non-canonical review draft. It
   contains candidate identities, revision bindings, user-local presentation
   priorities, corrections, omissions, and review position. Persisting this
   draft does not create a Goal Path or grant execution authority.
2. `PathComparisonProjection` is a deterministic, side-effect-free rendering
   of the session against current Goal, Goal Path, Proof, capability, public
   reference, and Scheduling snapshots. It contains the visible candidate set,
   discoverable omitted set, qualitative rows, and stale or blocked reasons.
3. `SelectedPathProposal` is an immutable handoff envelope naming exactly one
   candidate and the exact comparison revision the user selected. It records a
   decision, not activation. Only the canonical Goal Path activation command
   may revalidate that envelope, preview accepted node/Step/Proof consequences,
   and create one new Goal Path version.

The current `AmbitionsOSPathPortfolio` and `MultiPathLattice` types are useful
input adapters but remain value-model-only. Their numeric `weight` and current
`canDriveVisibleExecution` vocabulary are not user authority and do not cross
the new comparison boundary. The implementation introduces a score-free
comparison model rather than extending numeric lattice weights into product
semantics.

Goals presents the comparison as a vertically ordered route review, with an
optional visual table only as a secondary presentation. The current route is
always first and clearly identified. User-pinned priorities reorder explanatory
sections within this one session; they never choose a route or become a global
profile. Capacity is obtained through a non-durable Scheduling simulation and
is shown as one tradeoff. Comparison owns selection only. Goal Path owns
revalidation and activation. Scheduling alone owns placement and reflow.

## User flows

### 1. Open a same-outcome comparison

1. From Goal detail or a generated-route review, the user chooses **Compare
   routes**.
2. `PathComparisonCoordinator` resolves the canonical Goal ID and exact desired
   outcome, then captures a revision-bound baseline:
   - current accepted Goal Path version, including completed nodes, user edits,
     accepted Proof links, placements, assumptions, and source revisions; or
   - before first activation, the focused non-canonical proposal, explicitly
     labeled **Proposed baseline — not active**.
3. Every candidate is checked against that Goal ID and outcome fingerprint. A
   changed outcome is excluded with **Review as a different destination**,
   which hands off to destination adoption/pivot without changing the Goal.
4. The difference engine groups consequence-equivalent variants while keeping
   every source lineage inspectable. It selects two to four visible candidates,
   including the baseline, by deterministic diversity rules. All additional
   material candidates remain under **Other routes**, each with a stable
   omission reason and **Compare instead** action.
5. The user lands on a plain-language summary: what stays the same, what differs
   most, known unknowns, and the statement **Choosing here will not change your
   Goal or schedule**.

If fewer than two current, materially different candidates are available, the
workspace does not fabricate comparison. It shows the baseline, explains why
other candidates were combined, stale, or blocked, and offers refresh, return
to route generation, or continue reviewing the single proposal.

### 2. Review routes and evidence

The default order is baseline, user-substituted visible choices, then stable
candidate identity. Each route is an expandable semantic section with:

- inclusion reason and route identity;
- what it preserves and changes;
- requirements and external-authority conditions;
- completed progress and personal evidence continuity;
- duration range, cost/resource, location/availability, and capacity pressure;
- reversibility and user-declared priorities;
- sources, retrieval/freshness state, assumptions, uncertainty, and unknowns;
- actions to inspect source, inspect evidence meaning, correct an input, edit
  user-controlled wording, omit, or substitute another route.

The Proof section uses five explicit labels: **retained personal evidence**,
**relevant to this route**, **may support a sourced condition**, **recognized by
named policy**, and **accepted by external authority**. The first two may be
derived locally with evidence; the latter three require their named authority
and never imply proficiency or acceptance from overlap alone.

The Time section asks Scheduling for an exact-revision, non-committing pressure
preview. It lists affected windows, Protected/Fixed boundaries, transitions,
recovery, uncertainty, and infeasibility. It does not offer a placement action
and cannot select the easiest route.

### 3. Change the visible set or explanation order

1. **Other routes** lists every additional materially distinct candidate and a
   reason such as **similar consequence combined**, **source review needed**,
   **stale availability**, or **outside the four-route review**.
2. **Compare instead** replaces one non-baseline visible route. The baseline
   cannot be removed while an accepted path exists.
3. The projection is recomputed with the same candidate identities and stable
   revision. Focus returns to the inserted candidate and an announcement names
   what changed.
4. The user may mark considerations as important for this decision. This only
   changes section order and the selection summary; resetting priorities
   restores the stable default. No numeric weight is stored or displayed.

### 4. Correct or edit an input

An inspection sheet identifies the owning fact. Canonical corrections route to
that object's existing owner; source-backed route edits become un-attributed
user draft content until renewed generation or authority review. Comparison
does not perform the correction itself. On return, changed revisions stale only
dependent rows and candidates. The user may refresh those rows, remove an
invalid candidate, or exit. A stale candidate cannot be selected.

### 5. Defer or reject every candidate

- **Decide later** retains the recoverable session and current review position,
  marks it deferred, and leaves the accepted path unchanged.
- **None of these routes** records a local comparison decision with the exact
  candidate set and reason if supplied, closes the active review, and leaves the
  accepted path unchanged. It does not retire a Goal Path or suppress future
  materially changed candidates.
- Returning later always revalidates before presenting the session as current.

### 6. Select one proposal

1. **Select for activation review** opens a summary naming the candidate,
   rejected visible alternatives, important tradeoffs, unresolved unknowns,
   stale-sensitive sources, capacity consequences, and the explicit statement
   **This does not activate a path or schedule work**.
2. Confirmation writes one idempotent `SelectedPathProposal` bound to the Goal,
   current path/baseline revision, candidate revision, comparison fingerprint,
   source/fact revisions, and selection time. Goal, Goal Path, Step, Proof,
   capability, placement, and Time stores remain unchanged.
3. The Goals surface routes the envelope to the canonical Goal Path activation
   review. That owner re-resolves the Goal outcome, current path version,
   sources, Proof, capabilities, constraints, and confirmation scope.
4. If revalidation succeeds, Goal Path shows its own activation preview and
   requires its own explicit confirmation before creating one new version.
   Scheduling remains a later separate action.
5. If revalidation fails or facts changed, the comparison returns as stale with
   the affected rows highlighted. No activation is reported and the last
   accepted path remains current.

Repeated taps or resumed handoffs with the same selection key return the same
proposal. A changed candidate or comparison revision requires a new selection.

### 7. Boundary handoffs

- A candidate with a different desired outcome exits to destination
  adoption/pivot.
- A timeslot-only difference is removed from route comparison and may be
  inspected in Time.
- A user-requested complete, all-or-none correction across several canonical
  owners is assessed by Life Branch only when ordinary Goal Path and Time
  mechanisms are insufficient.
- None of these handoffs changes canonical state merely by opening it.

## States and recovery

### Session states

`PathComparisonSessionState` is one of:

- `assembling`: inputs are resolving; cancel returns to Goal detail;
- `ready`: two to four current material candidates can be compared;
- `insufficientAlternatives`: fewer than two current material candidates; no
  selection is available;
- `partiallyStale`: at least one row or candidate changed; unaffected routes
  remain inspectable but stale candidates cannot be selected;
- `blocked`: the baseline, Goal outcome, privacy classification, or minimum
  source contract cannot be resolved safely;
- `deferred`: recoverable review retained with no path effect;
- `rejectedAll`: decision history retained with no path effect;
- `selectedPendingActivation`: one immutable selection proposal exists but no
  Goal Path mutation has occurred;
- `handoffStale`: activation revalidation rejected the envelope;
- `closed`: activation completed elsewhere or the user deliberately discarded
  the draft; canonical History remains owned by the activating owner.

The UI never calls `selectedPendingActivation` active, accepted, or scheduled.

### Candidate and row states

Each candidate is `current`, `stale`, `blocked`, `needsSourceReview`,
`outcomeMismatch`, `equivalentGrouped`, or `omittedDiscoverable`. Each tradeoff
cell is `known`, `unknown`, `notApplicable`, `stale`, or `contradicted` and
retains its input binding. Unknown and not-applicable are visibly distinct.
Blocking is candidate-local unless the baseline or shared Goal binding is
invalid.

### Failure and recovery rules

- **Interrupted assembly or refresh:** cancel in-flight work, retain the last
  coherent projection, and show retry. A partial projection never replaces the
  previous one.
- **Relaunch:** load the last checksummed session, resolve all revision bindings,
  rebuild the deterministic projection, and restore candidate expansion,
  review position, and semantic focus. Any mismatch becomes stale before an
  action is enabled.
- **Corrupt or unsupported draft:** quarantine the draft, preserve every
  canonical object, and offer **Start a fresh comparison** or return. Do not
  guess candidate meaning from partial bytes.
- **Source unavailable:** keep last known content plainly labeled with its
  retrieval state for inspection, block selection of a source-dependent route,
  and offer refresh, substitute, generic/manual route review, or exit.
- **Scheduling preview unavailable or infeasible:** label capacity unknown or
  no safe fit, preserve all placements, and allow route inspection; selection
  remains blocked only when the missing capacity fact is material to the
  candidate's declared validity.
- **Concurrent Goal/path/fact edit:** discard the late computation, mark only
  dependent rows stale, and preserve user notes, priorities, inclusion choices,
  scroll position, and focus.
- **Selection write failure:** remain in review with the candidate highlighted;
  do not hand off or claim selection.
- **Activation failure:** return the exact Goal Path error and recovery action,
  retain `SelectedPathProposal` as an unactivated decision, and preserve the
  last accepted path.
- **Rollback after activation:** Goal Path creates a new restoring mutation and
  retains selection and subsequent-work history. Comparison cannot delete that
  history or perform rollback.

All cancellation before Goal Path commit discards only non-durable projection
work or retains the explicitly saved draft; it never rolls back canonical
objects because comparison never changed them.

## Frontend experience specification

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: Use only the visible meaning, actions, limits, and recovery language resolved by User flows and States and recovery; localization must preserve every non-claim.
- Accessibility: Use native semantic containers and controls with the exact reading order, reflow, assistive actions, focus, announcements, non-color status, and reduced-effects behavior defined below.
- Visual proof: Before the frontend task starts, render one production-intended SwiftUI fixture in one representative viewport, record protected characteristics, and obtain owner approval. Runtime navigation/state, screenshot, accessibility, and named-device proof remain separately required.
- Visual gate: required
- Experience authority: Task 5 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Component ownership

- `PathComparisonCoordinator` in `Core/LocalRuntimeOS/Planning/` owns session
  orchestration, cancellation, revision checks, and handoff construction. It
  has no canonical command executor dependency.
- `PathCandidateAdapter` normalizes Goal Path generation output,
  `AmbitionsOSPathPortfolio`, and the current Goal Path baseline into
  `ComparablePathCandidateV1`. It rejects mismatched outcomes and strips
  numeric weights from the product model.
- `PathDifferenceEngine` creates material-consequence signatures, groups
  equivalent candidates without merging lineage, and creates the visible and
  discoverable sets. The stable order is baseline first, user-substituted
  choices in explicit order, then normalized candidate ID; internal model
  scores never participate.
- `PathTradeoffProjector` produces the ordered qualitative dimensions and input
  bindings. `ProofContinuityProjector` owns evidence-language distinctions.
- `SchedulePressurePreviewing` is a read-only protocol implemented by
  Scheduling. It accepts candidate Step-shape summaries and an exact schedule
  snapshot, and returns affected windows, constraints, uncertainty, and a
  revision digest. It cannot return a placement command or commit token.
- `PathComparisonFreshnessMonitor` maps changed Goal, path, Proof, capability,
  source, cost, availability, constraint, and Time revisions to dependent rows.
- `PathComparisonSessionRepository` persists non-canonical draft state locally.
  `GoalPathActivationHandoff` accepts only a `SelectedPathProposal` and routes
  it to the separate activation review.
- Goals projection and views render the model and send user intent to the
  coordinator. They never mutate a candidate or canonical object directly.

### Core records

`ComparablePathCandidateV1` contains stable candidate ID, Goal ID, outcome
fingerprint, candidate revision, route-kind and structure signature, source
claim bindings, assumption bindings, requirement/gate references, progress and
Proof references, resource/duration/location/availability facts, reversibility,
and privacy class. It carries no aggregate score and cannot conform to a
canonical Goal Path identity protocol.

`PathComparisonInputBindingV1` contains owner kind, owner ID, field/claim ID,
revision or retrieval version, freshness state, uncertainty, handling class,
and correction route. A row is derived only from declared bindings.

`PathComparisonSessionV1` contains:

- session ID and monotonically increasing draft revision;
- Goal ID and exact outcome fingerprint;
- baseline kind/ID/revision and candidate identities/revisions;
- visible IDs, omitted IDs with stable reasons, and equivalent groups;
- session-local priority IDs and user corrections/edits with provenance state;
- expanded sections, review anchor/focus ID, decision state, and timestamps;
- policy/schema versions, comparison fingerprint, and checksummed input-binding
  manifest;
- optional selected-proposal ID, never a Goal Path version ID.

`SelectedPathProposalV1` contains proposal ID, idempotency key, session and
revision, Goal/outcome binding, baseline/current-path binding, chosen candidate
and revision, rejected visible candidate IDs, qualitative selection reason,
unresolved unknowns, source/fact revision manifest, capacity-preview digest,
comparison fingerprint, created time, local-only handling class, and
`activationState = pending`. It contains no canonical Steps, accepted Proof
rules, placement mutations, or activation Receipt.

### Persistence and migration

The session repository is an actor-isolated, local-only draft store using the
repository's protected application-data boundary. Writes use encode-to-temp,
checksum verification, flush, and atomic replace. The selected proposal and
session decision are committed together in one draft-store transaction so a
crash cannot produce a handoff without its review context. Canonical stores and
the runtime Event Journal are read-only to this transaction.

Schema v1 starts with no migrated comparison authority. Existing
`MultiPathLatticePersistenceSnapshot` and `MultiPathSelectionReceipt` values
remain test/value-model artifacts and are not interpreted as selected or
activated product decisions. A compatible future migration must preserve
stable IDs, source bindings, and explicit user choices; a lossy or unknown
schema is quarantined and rebuilt from canonical inputs with the user informed.
Deleting a comparison draft removes only draft state, never the Goal, path,
Proof, source records, or Goal Path activation History.

### Determinism, concurrency, and replay

All computations receive an injected clock, comparison-policy revision,
locale/time-zone snapshot, and stable input order. Equivalent inputs produce
the same consequence groups, visible-set reasons, rows, and fingerprint.
Presentation order does not depend on dictionary order, task completion order,
or hash randomization.

`PathComparisonCoordinator` is an actor. Each refresh has a generation token
and captured revision manifest. A later generation cancels the earlier one;
late results whose token or manifest no longer matches are discarded. Draft
writes use expected session revision. Selection uses an idempotency key derived
from session ID, draft revision, candidate ID/revision, and comparison
fingerprint. Only one proposal can be current for that exact review.

Replay of a comparison means deterministic reconstruction of the draft
projection from its retained bindings and policy version; it is not canonical
mutation replay. Goal Path activation records the proposal ID and fingerprint
in its own Command/Event/Projection/Receipt/Replay chain after fresh
revalidation. A replayed selection can never bypass that command or create a
second Goal Path version.

### Canon and expected source impact

Implementation grooming should add the comparison/candidate/proposal distinction
to Goal Path canon, non-durable pressure semantics to Scheduling canon, and the
ordered comparison flow to Goals surface canon. Expected code owners are
`Core/LocalRuntimeOS/Planning/`, read-only adapters in Scheduling/Proof/public
reference owners, `Surfaces/Goals/`, local draft persistence, and focused
Quality fixtures. No new root surface or mutation owner is introduced.

## Privacy and accessibility

All comparison sessions, private input bindings, candidate rationale, Goal and
path facts, Proof/capability links, cost, location, schedule pressure,
priorities, corrections, decision history, and selected proposals are private
local graph or private local draft data. The full flow works without account or
network. Public-reference adapters receive only public identifiers selected
without private context; Account, R2, Source Atlas, hosted AI, telemetry,
analytics, diagnostics, support upload, and external calendars receive no
comparison payload. A mixed public/private row inherits the private class.

Every stored or rendered field carries an owning handling class. Diagnostics
contain only schema/policy revision, correlation IDs, field-category names,
stale/blocked reason codes, and safe payload-shape hashes. They exclude titles,
outcomes, candidate text, sources joined to a user, schedule windows, cost,
location, Proof, capability, and priority values. Unknown classification fails
closed. Protected facts are used only when explicitly supplied and locally
permitted; absence stays unknown and is never converted to a negative claim.

The primary accessible form is an ordered list, not the optional visual matrix.
Its semantic order is: Goal and unchanged outcome; comparison status; baseline;
each candidate's identity and inclusion reason; material differences; sources
and unknowns; evidence continuity; capacity pressure; user priorities;
selection consequence; then actions. Headings and stable semantic focus IDs
support rotor and keyboard navigation.

Every action has a named control and accessibility action: inspect route,
inspect source, correct input, compare another route, mark consideration,
reset priorities, defer, reject all, select for activation review, refresh, and
return. No drag, horizontal swipe, chart position, color, motion, or haptic is
required. Voice Control names are unique; Switch Control and Full Keyboard
Access reach the same controls; RTL changes layout but not semantic order.

Dynamic Type may replace columns with per-candidate sections and must keep all
source, unknown, and action content reachable. Increase Contrast, Bold Text,
Button Shapes, Differentiate Without Color, Reduce Transparency, and Reduce
Motion retain state labels and boundaries. Refresh announces affected routes;
replacement focuses the inserted candidate; staleness focuses the changed row;
selection focuses the pending-activation summary; failures focus the recovery
action. Modal review contains focus and cancellation restores it to the exact
initiating control or nearest stable owner fallback.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| `REQ-001` | Goal/outcome fingerprints gate admission; outcome mismatches are excluded and handed to pivot without a Goal command. |
| `REQ-002` | The baseline adapter binds the current accepted version and its completed work, Proof, edits, placements, assumptions, and sources; pre-activation focus is labeled non-canonical; incomplete baseline blocks selection. |
| `REQ-003` | `PathDifferenceEngine` produces a two-to-four visible set including the baseline plus a stable discoverable omitted set with user substitution. |
| `REQ-004` | Material-consequence signatures cover gates, structure, authority, duration, resources, location, capacity, reversibility, evidence, and priorities; equivalent variants are grouped without merging lineage. |
| `REQ-005` | Score-free ordered tradeoff rows require preserve/change/require/cost/assume/unknown/risk semantics and typed source/freshness/correction bindings; missing data is explicit. |
| `REQ-006` | `ProofContinuityProjector` preserves the five evidence meanings, never grades Proof, and never mutates source evidence when relevance changes. |
| `REQ-007` | The read-only Scheduling protocol returns revision-bound pressure only, with affected windows and uncertainty and no command or placement token. |
| `REQ-008` | Session-local priority IDs reorder explanations only, are inspectable/resettable, and never participate in candidate eligibility or a numeric aggregate. |
| `REQ-009` | Typed source bindings carry authority, context, retrieval, freshness, and uncertainty; source edits remove attribution and stale only dependent candidates; professional claims remain disallowed. |
| `REQ-010` | Comparison uses a non-canonical draft transaction and read-only canonical dependencies; every action, including selection, is prohibited from using a canonical executor. |
| `REQ-011` | Named defer, reject-all, inspect/correct, substitute, and select actions preserve the accepted route; the selection summary includes alternatives, consequences, unknowns, and pending activation. |
| `REQ-012` | `SelectedPathProposalV1` is the sole output and carries exact lineage; `GoalPathActivationHandoff` requires the separate owner to revalidate and create any new version. |
| `REQ-013` | The freshness monitor maps each changed fact to dependent rows and disables selection/handoff for stale candidates until refresh. |
| `REQ-014` | Checksummed draft recovery restores review context and focus; every failure preserves the accepted route; activation rollback remains Goal Path-owned. |
| `REQ-015` | Local-only classification, offline operation, fail-closed egress, minimized diagnostics, and protected-fact unknown behavior are enforced at every adapter and store. |
| `REQ-016` | Ordered list semantics, named non-gesture controls, focus/announcement rules, input equivalence, Dynamic Type, contrast, reduced effects, RTL, and non-color states provide full parity. |

## Verification design

### Automated model and policy tests

- Add `PathDifferenceEngineTests` covering two/four candidate bounds, mandatory
  baseline, stable omission reasons, user substitution, outcome mismatch,
  material-consequence grouping, and wording/timeslot equivalence.
- Add `PathTradeoffProjectorTests` for every dimension, explicit unknown versus
  not-applicable, source bindings, professional-boundary copy, five Proof
  meanings, and absence of scalar/best/success/ability language.
- Add `PathComparisonFreshnessTests` proving Goal, path, Proof, capability,
  source, cost, availability, constraint, and Time changes stale only dependent
  rows and disable only invalid selections.
- Add property tests that random candidate input ordering produces identical
  visible sets, qualitative order, omission reasons, and fingerprints.
- Keep and adapt `MultiPathLatticeTests` and
  `AlternatePathPortfolioTests` as lower-level input-contract tests; add an
  explicit assertion that their numeric weights and runtime-ready flags never
  enter `PathComparisonProjection` or activation authority.

### Integration, persistence, concurrency, and replay

- Snapshot every canonical Goal, Goal Path, Step, Proof, capability, placement,
  and Time store before and after open, refresh, edit, reorder, substitute,
  defer, reject-all, and select; require byte-equivalent canonical state.
- Exercise selected-proposal handoff through Goal Path activation: stale
  baseline/source/fact rejects before preview; accepted activation creates
  exactly one new version and its own Receipt/replay; duplicate selection or
  handoff creates neither duplicate proposal nor duplicate version.
- Crash at draft encode, atomic replace, selected-proposal transaction, handoff,
  activation validation, and post-activation projection. Recovery must produce
  the last coherent session and accepted Goal Path without mixed authority.
- Test optimistic revision conflicts and deliberately out-of-order refresh
  completion; late results cannot replace newer user choices.
- Test v1 empty initialization, round-trip, checksum corruption, unsupported
  schema quarantine, deletion of a draft, and the explicit non-migration of old
  lattice value-model snapshots.
- Rebuild from retained policy/input revisions and compare fingerprints;
  activation replay must retain the selected proposal binding while remaining
  owned by Goal Path.

### Runtime and degraded scenarios

- Run the astronaut same-outcome fixture with current-route, education,
  experience, and pilot-hours candidates; separately test changed-destination,
  wording-only, timeslot-only, stale availability, source outage, missing Proof,
  unknown capability, capacity infeasibility, reject-all, defer, interruption,
  and activation failure.
- Verify the main set remains bounded at representative route/source/Proof and
  schedule scale; omitted candidates stay discoverable. Grooming must calibrate
  horizon/count, device/OS/build/tool, cold/warm percentile and maximum, memory,
  energy, cancellation latency, and regression threshold before making a
  performance claim.
- Run changed-scope build, lint, static-analysis, canon, secrets, and focused
  test lanes; no runtime or release claim follows from source tests alone.

### Privacy and accessibility evidence

- Execute class/destination privacy abuse tests for Account, R2, Source Atlas,
  hosted AI, telemetry, logs, diagnostics, support, external calendar, widgets,
  Spotlight, clipboard, and public-reference request construction. Inspect
  derived/mixed rows and identifiers as well as raw fields.
- Verify full offline/no-account comparison and selected-proposal recovery.
- On representative iPhone sizes and supported OS versions, directly verify
  VoiceOver order/rotor/actions/announcements/focus, Voice Control names, Switch
  Control, Full Keyboard Access and hardware keyboard, Dynamic Type through
  accessibility sizes, Bold Text, Button Shapes, Increase Contrast,
  Differentiate Without Color, Reduce Motion/Transparency, reach/handedness,
  RTL/localization, locked-device privacy, every degraded/failure state, and
  list parity with the optional matrix. Automated checks and screenshots are
  supporting evidence, not direct accessibility proof.

## Open decisions

No unresolved product decision remains. Grooming must resolve these technical
implementation choices without changing Scope behavior:

- choose the existing protected local-store primitive used by
  `PathComparisonSessionRepository` and define its concrete schema migration
  registration;
- name the exact Goal Path activation command/input type that consumes
  `SelectedPathProposalV1` once the Goal Path generation/activation seam lands;
- calibrate bounded comparison and Scheduling-preview performance limits on
  representative devices rather than inventing numeric thresholds here; and
- choose the concrete SwiftUI decomposition for list/table adaptation while
  retaining the semantic order and action/focus contract above.

If implementation discovers that a selected proposal must itself mutate Goal,
Goal Path, Step, Proof, capability, placement, or Time state, that is a Scope
conflict and must return to product review rather than be resolved in grooming.
