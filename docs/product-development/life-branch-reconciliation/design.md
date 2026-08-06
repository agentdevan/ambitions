+++
initiative = "life-branch-reconciliation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Life Branch is a contextual, local reconciliation workflow for the one approved
relocation scenario. It starts only after a user confirms a permanent move on a
known date for protected caregiving and the current education, employment, and
Time facts form a conflict that ordinary owners cannot repair independently.
The design adds no root surface and no alternate copy of the private graph.

The workflow has five explicit boundaries:

1. **Changed-reality intake** records the user's confirmed trigger without
   changing any affected Goal, Path, Step, placement, or external obligation.
2. **Simpler-owner assessment** asks the existing Goal, Goal Path, Recovery
   Segment, destination-pivot, and Scheduling policies whether one bounded edit
   can restore an honest graph. It also binds the current Life Branch slot as
   either an existing branch ID and revision or an explicit revision-bound
   absence. A successful simpler-owner answer exits to that owner and creates
   no Life Branch candidate; an unresolved existing branch blocks this bounded
   workflow rather than being replaced.
3. **Candidate materialization and certification** derives two or three
   complete, policy-distinct typed deltas over current canonical identities.
   Deterministic evaluation classifies each candidate `valid`, `fragile`,
   `blocked`, `invalid`, `stale`, or `expired`; only `valid` is selectable.
4. **Review and selection** is side-effect-free. Selection records a review
   preference in a rebuildable local checkpoint, not a canonical mutation or a
   second branch of the user's life.
5. **Promotion** revalidates the complete read set and certificate, then asks
   for one explicit all-or-none confirmation. One parent local transaction
   compare-and-swaps the still-empty Life Branch slot and applies typed changes
   through the existing object owners. Recipient-owned and external effects are
   persisted only as post-local intents and retain independent results. This
   Design cannot supersede an existing branch as part of promotion.

The current repository contains normative Life Branch, certificate, and CEBR
contracts but no complete Life Branch source implementation. The architecture
below therefore introduces a bounded new planning and coordination slice while
reusing the existing canonical object owners, optimistic revision checks,
atomic commit coordinator, event journal, Receipt/History pipeline, projection
invalidations, and external-operation outbox. It does not treat adjacent
transaction code as proof that cross-owner promotion already works.

## User flows

### Primary flow: relocation creates a genuinely coupled conflict

1. The user confirms: “I am moving permanently on this date to provide
   caregiving,” including only the facts they choose to state. The entry point
   may appear from the affected Goal, Time conflict, Today recovery prompt, or
   You/Trust inspection, but every entry resolves the same assessment identity.
2. A **What changed** summary shows the trigger, effective date, current graph
   revision, affected credential Goal and onsite-work Goal, their current Goal
   Paths and placements, protected caregiving Time, and separately labeled
   provider/employer facts. It also states whether the graph has no active Life
   Branch or identifies the existing branch and its current lifecycle state.
   Forecasts and inferred changes are excluded.
3. Ambitions runs the simpler-owner assessment and presents an ordered
   **Why this needs coordinated review** list. Each row names the owner checked,
   the attempted bounded repair, the protected condition it could not preserve,
   and an action to inspect that owner's facts. If an active, stale, expired, or
   otherwise unresolved branch already occupies the one-branch slot, assessment
   stops here with **Resolve the current branch first** and an inspection route;
   no replacement candidate is materialized.
4. If all four threshold clauses pass, the user chooses **Compare complete
   options**. Candidate construction is cancellable and makes no canonical
   changes. A missing or stale provider/employer fact yields a blocked or
   fragile result with the exact fact and a local/manual or public-reference
   refresh action; it never becomes assumed success.
5. The main comparison shows two or three candidates. An ordered summary for
   each names what it protects, changes, defers, ends, sacrifices, assumes,
   costs, leaves unresolved, and can reverse. It also lists every affected
   canonical object and every local, recipient, joint, or external effect.
   Blocked and consequence-equivalent options remain inspectable with reasons
   but cannot displace a materially distinct valid choice.
6. The user can inspect details, edit a declared relaxable condition, choose a
   lighter correction, refresh facts, keep the current conflict, defer, or
   reject all. Attempting to change a protected condition exits to its owning
   control; returning starts recertification from the resulting revision.
7. Choosing a valid candidate opens **Review one coordinated change**. The
   confirmation summary groups changes by canonical owner, names unchanged
   protected facts, shows irreversible or compensating-only consequences, and
   lists external follow-ups separately. It also states that promotion is bound
   to the displayed revision-proven absence of another active branch and will
   fail rather than replace one if that fact changes. No “best option” language
   appears.
8. Immediately before confirmation, Ambitions re-reads the graph and all
   declared dependencies, including the revision-bound absence of an active
   branch. A changed dependency or branch-slot revision marks the affected
   candidate or certificate stale and returns focus to the changed fact or
   current branch. A current result with the slot still empty enables **Apply
   local changes**.
9. Confirmation submits one idempotent promotion command. Local changes either
   settle together with creation of the one active branch or none settle.
   Success opens a Receipt summary stating exactly which existing objects
   changed, which branch ID and revision became active locally, the prior
   revision-bound absence it replaced, and which external/recipient effects
   remain pending.
10. After resolution, ordinary Goal and Time surfaces again show current truth.
    Trust/History retains the branch decision, certificate, Receipt, external
    status, and safe rollback or compensation route; there is no persistent
    branch dashboard.

### Simpler owner succeeds

- If current facts show that the existing job is officially remote and a Time
  reflow alone resolves the conflict, assessment explains that result and
  offers **Review schedule changes** through Scheduling.
- If one Goal Path revision, Recovery Segment, Goal lifecycle action, or
  destination pivot is independently sufficient, the corresponding owner gets
  a typed handoff. No branch, certificate, branch candidate, or branch Receipt
  is created.
- Returning from that owner reruns assessment only if the original conflict is
  still present at a newer revision.

### Blocked authority or incomplete candidate

- If remote-program availability, employer agreement, enrollment consequences,
  or another material external fact is absent, stale, or contradictory, every
  dependent candidate identifies that fact as unknown and becomes fragile or
  blocked. The user may inspect the last labeled source snapshot, refresh a
  public fact without private context, enter a user-known fact as declared
  context, choose a different complete correction, or defer.
- If candidate completeness cannot account for one affected Goal, accepted
  placement, protected rule, Proof condition, resource/obligation, or external
  follow-up, the candidate is blocked. The missing consequence is not hidden
  behind a generic confidence state.

### Keep the conflict, defer, reject all, and interruption

- **Keep this for now** preserves current canonical state and records no
  acceptance. The UI states which conflict remains and returns to its owning
  object.
- **Review later** stores only a private, non-authoritative review checkpoint.
  On resume, candidates and certificates are rebuilt or revalidated before any
  old status is shown as current.
- **Reject all** preserves the graph and the factual trigger. It does not infer
  a life preference or suppress unrelated future review.
- Cancellation during materialization or review discards transient computation
  and preserves the last review checkpoint. Cancellation before promotion
  creates no Receipt because no meaningful mutation occurred.

### Failure after confirmation and external reconciliation

- A stale read, failed certificate check, command rejection, conflict, storage
  failure, newly occupied branch slot, changed active-branch revision, or crash
  before atomic local settlement produces no branch success and leaves the
  prior graph readable. Recovery offers refresh, inspect the current branch,
  select another correction, retry the same idempotent command only after its
  original bindings remain current, defer, or return. Retry never converts a
  blocked replacement into supersession.
- Once local settlement succeeds, projection catch-up and external intents are
  independent recovery work. Provider, employer, recipient, tuition, calendar,
  or notification failures remain `pending`, `failed`, `cancelled`, or
  `reconciled`; they cannot rewrite the accepted local result.
- **Undo** is shown only when the typed inverse remains safe. If later work,
  another person's decision, or an external effect invalidates exact reversal,
  the user receives a compensating recovery preview instead of destructive
  rollback.
- If an active branch's bound base revision or declared dependency changes, its
  lifecycle becomes `stale`. If its bound policy revision or horizon expires,
  it becomes `expired`. Both remain inspectable and preserve lineage, but
  neither authorizes continued branch-dependent action or a replacement
  promotion. This bounded Design requires the prior branch to reach a terminal
  or explicitly resolved disposition before another branch can activate.

## States and recovery

### Assessment and review states

- `not_applicable`: the trigger or scenario does not match the approved
  relocation boundary; no branch entry remains visible.
- `awaiting_confirmation`: changed reality has not been explicitly confirmed;
  nothing is inferred or assessed as canonical truth.
- `assessing_simpler_owners`: read-only owner checks are running against one
  graph revision.
- `handoff_available`: one simpler owner can restore coherence; branch creation
  is suppressed.
- `threshold_failed`: the problem spans several objects but does not satisfy all
  four conjunctive clauses; the explanation names the failed clause.
- `active_branch_blocked`: an active, stale, expired, or otherwise unresolved
  Life Branch already occupies the canonical branch slot. Its ID, revision,
  status, and inspection/recovery route are shown; no candidate is created.
- `materializing`: bounded deterministic candidate construction is in progress
  and cancellable.
- `reviewable`: two or three complete candidates and their current certificates
  are available.
- `review_stale`: a declared dependency changed; affected consequences are
  marked while unaffected review context remains readable.
- `no_complete_candidate`: current facts produce only incomplete, blocked, or
  consequence-equivalent corrections. The existing graph remains authoritative.
- `deferred`, `conflict_kept`, or `rejected`: no candidate was promoted and no
  canonical object changed.

### Candidate and certificate states

Each candidate has a stable simulation fingerprint and one immutable
certificate revision. The assessment, candidate, and certificate all carry the
same `ActiveLifeBranchBinding`: either `none` plus the observed branch-slot
revision, or the existing branch ID, revision, and status. Only the explicit
current `none` binding can produce a promotable candidate; an existing
unresolved branch produces `blocked`:

- `valid`: complete under current revisions and eligible for selection.
- `fragile`: a bounded repair or unresolved non-material fact is visible, but
  the candidate cannot be presented as feasible or promoted.
- `blocked`: a hard conflict, missing material authority, or incomplete
  consequence prevents selection.
- `invalid`: the delta violates identity, authority, protected-boundary, or
  product-scope law.
- `stale`: one declared dependency changed after evaluation.
- `expired`: the certificate's bound policy revision or validity horizon is no
  longer current.
- `superseded`: a newer certificate exists for the candidate fingerprint.

Unknown is a fact state inside the certificate, never a numeric confidence.
Missing dependency indexes conservatively stale the complete candidate.

### Promotion and settled states

- `selected_for_confirmation`: review preference only; no canonical mutation.
- `revalidating`: current graph, policy, certificate, authority, and materiality
  checks are running.
- `confirmation_required`: exact local changes, external intents, and the
  revision-bound absence of another active branch are frozen to a confirmation
  digest.
- `committing`: the one parent local transaction has claimed its idempotency key.
- `active_local`: local owners and lineage settled atomically; one or more
  external/recipient results are not final.
- `active`: local state is settled and all tracked post-local effects reached a
  terminal reconciled posture. This state does not claim another principal
  accepted the user's request.
- `stale`: the branch was active but its bound graph base or a declared
  dependency changed. It remains inspectable and occupies the branch slot, but
  is non-authorizing until explicitly resolved.
- `expired`: the branch's bound policy revision or validity horizon expired. It
  remains inspectable and occupies the branch slot, but is non-authorizing until
  explicitly resolved.
- `commit_failed`: no local settlement occurred; the last honest graph remains.
- `rolled_back`: a typed safe reversal settled as a new mutation with lineage.
- `compensation_required` or `compensated`: exact reversal was unsafe and a
  separately confirmed recovery changed current truth.
- `superseded`: an inspectable canonical lifecycle state reserved for a future
  explicitly supported replacement transaction. No command in this bounded
  Design can enter it, and promotion cannot activate a replacement while the
  prior branch is active, stale, expired, or otherwise unresolved.

`rolled_back`, a `compensated` result explicitly marked resolved, or another
terminal/resolved canonical disposition releases the one-branch slot.
`active_local`, `active`, `stale`, `expired`, `compensation_required`, and
unresolved compensation continue to occupy it. External-result completion alone
changes `active_local` to `active`; it does not resolve the branch or make
replacement permissible.

### Empty, stale, and corruption recovery

- No qualifying conflict shows no empty branch workspace; the user stays in the
  ordinary Goal or Time flow.
- Zero valid candidates explains the blocked conflict and its missing facts; it
  never manufactures a fallback “best” option.
- A changed revision invalidates only its dependency-index impact cone. Loss of
  completeness, missing dependency metadata, policy migration, or graph
  corruption invalidates the whole candidate with a precise reason.
- A base/dependency change transitions an occupying active branch to `stale`;
  policy or horizon expiry transitions it to `expired`. The former certificate,
  decision basis, and lifecycle lineage remain readable, but neither state can
  authorize effects or be treated as an empty branch slot.
- Finding an existing unresolved branch during resume discards any earlier
  empty-slot assumption, marks the candidate review stale, and routes to that
  branch. The workflow never manufactures a `superseded` transition to recover.
- A corrupt review checkpoint is disposable and rebuilt from canonical facts.
  Corrupt canonical branch/certificate/event data follows persistence
  quarantine, safe export/backup, and repair-preview law; it is never silently
  reset.
- Resume restores the trigger, review position, candidate fingerprints, user
  edits to relaxable conditions, selection, and focus, then displays all of
  them as revalidating until current checks finish.

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
- Experience authority: Task 7 may implement only the routes, hierarchy, components, actions, and visible/recovery states already resolved by User flows and States and recovery. It may not add a root, alter IA, introduce custom assets, or change the visual language without returning to Scope and Design.

## Architecture and data

### Ownership and component boundaries

The implementation adds a bounded vertical slice while preserving existing
owners:

- `Core/Domain/` defines `LifeBranchID`, `LifeBranchRevision`,
  `LifeBranchTrigger`, `LifeBranchDeltaOperation`, `LifeBranchCandidate`,
  `BranchViabilityCertificate`, `BranchDependency`, `BranchAuthorityPartition`,
  `ActiveLifeBranchBinding`, `BranchStatus`, and lineage value types.
  `ActiveLifeBranchBinding` represents either an existing branch ID/revision/
  status or explicit absence at a branch-slot revision. Delta operations
  reference existing canonical IDs; they do not embed copies of Goals, Paths,
  Steps, placements, Proof, Receipts, or History.
- `Core/LocalRuntimeOS/Planning/` owns `LifeBranchNecessityAssessor`,
  `LifeBranchCandidateMaterializer`, `BranchViabilityEvaluator`, deterministic
  conflict-core/correction-set derivation, dependency indexing, bounded impact-
  cone traversal, and plain-language projections. It cannot commit objects.
- Existing Goal, Goal Path, Recovery Segment, destination-pivot, and Scheduling
  policies expose read-only assessment adapters returning `sufficient`,
  `insufficient(reason:)`, or `unavailable(reason:)` against explicit revisions.
  The Life Branch assessor cannot reinterpret those owners' rules.
- `Core/LocalRuntimeOS/Commands/` owns `PromoteLifeBranchCommand`, branch
  rollback/compensation commands, idempotency, confirmation binding, and typed
  expansion to owner mutations.
- `Core/LocalRuntimeOS/Transactions/` coordinates one parent semantic
  transaction. The existing atomic commit path must be extended only as needed
  to accept a validated multi-aggregate write set and branch lineage while
  retaining its current CAS, crash-phase, Receipt, projection-invalidation,
  tombstone, and external-operation invariants.
- `Core/LocalRuntimeOS/Inspection/` owns branch/certificate/Receipt/History
  inspection and redacted diagnostic traces.
- Goals is the primary contextual review surface; Time and Today link to the
  same review when they detect the conflict; You/Trust presents historical
  authority and lineage. No surface persists or mutates a branch directly.

### Deterministic assessment and candidate construction

`LifeBranchAssessmentInput` binds the confirmed trigger, base graph revision,
bounded horizon, affected IDs and revisions, protected/fixed conditions,
provider/employer source revisions, policy revision, current clock, and
recorded seed. It also binds the observed active branch ID and revision or an
explicit absence at the current branch-slot revision. An unresolved existing
branch ends assessment with `active_branch_blocked`; the bounded workflow does
not interpret it as a candidate or replacement target. Otherwise assessment
follows a fixed order: Goal, Goal Path, Recovery Segment, destination pivot,
then Scheduling. A sufficient owner response ends assessment immediately and
records the handoff reason.

If all threshold clauses pass, candidate materialization consumes only the
confirmed snapshot and declared policies. It emits a bounded two-or-three-item
set after:

1. generating typed policy-distinct correction sets;
2. rejecting operations outside the approved scenario or without an owner;
3. suppressing timeslot-only and consequence-equivalent sets by semantic
   fingerprint while retaining their inspectable reasons;
4. proving coverage of every affected object, protected condition, obligation,
   unresolved fact, and external follow-up; and
5. producing stable ordering from semantic fingerprints, never a desirability
   or success score.

Generative text may restate an already-certified consequence through a local,
deterministic formatter. It cannot invent operations, close completeness gaps,
evaluate viability, choose a candidate, or receive private context externally.

### Certificate and dependency model

Each immutable certificate binds candidate and base revisions, evaluation time,
horizon, source/fact/policy/authority/capacity revisions, protected and
relaxable conditions, unresolved questions, invalidation conditions, status,
deterministic fingerprint, and the assessment's exact active-branch binding.
An explicit current absence is a hard certificate dependency; any existing
unresolved branch makes the certificate blocked. Every certificate component
and delta operation records hard or relaxable dependencies. The impact-cone
traversal is stable, cycle-detecting, bounded, and conservative: a cycle,
missing index, unknown owner, changed branch-slot revision, or changed existing
branch revision invalidates the whole affected candidate rather than reusing
stale evidence. Policy/horizon expiry produces `expired`, not a permissive
re-evaluation.

Certificate status is operational metadata, not a user score. The presentation
translates exact conflict and repair facts into calm language while retaining
an inspection route to source revisions and authority partitions.

### Review persistence

Candidate materialization remains simulation and creates no canonical branch
or object mutation. A private `LifeBranchReviewCheckpoint` may persist enough
non-authoritative state for interruption recovery: assessment ID, trigger ID,
base revision, active-branch binding, candidate fingerprints, certificate IDs,
relaxable edits, selection, review position, focus token, and timestamps.
Candidate semantic deltas and certificate truth are rebuilt or reloaded from
their versioned planning records and must revalidate both the branch ID/revision
or explicit absence before use; a checkpoint never becomes mutation input by
itself.

Planning records use stable versioned encodings and private-data classification.
Deleting a disposable checkpoint cannot delete canonical state. Retention ends
after resolution, explicit rejection, expiry, or user deletion except for the
minimum branch decision/Receipt/History lineage required by canonical law.

### Promotion transaction and concurrency

`PromoteLifeBranchCommand` binds the selected candidate fingerprint,
certificate fingerprint, base graph revision, every affected object revision,
policy/source revisions, the exact active-branch binding, complete local
operation list, external intent list, confirmation digest, and idempotency key.
Preparation repeats certificate and authority evaluation and builds:

- a read set containing every hard dependency, affected aggregate revision,
  and the branch-slot revision or existing branch ID/revision;
- an ordered write set of owner-typed local mutations plus creation of one new
  branch and lineage only when the read set proves the slot was explicitly
  empty; the created branch binds the resulting post-transaction graph revision
  while its certificate retains the pre-promotion base revision;
- projection invalidations for Goals, Today, Time, You/Trust, Search, and
  Receipt inspection as applicable;
- one parent rollback plan or an explicit non-reversible/compensation posture;
  and
- separately typed external-operation intents with minimum payloads.

The atomic coordinator performs optimistic compare-and-swap on the complete
read set, including the branch-slot absence predicate. Any concurrent affected
revision, branch-slot revision change, newly created branch, or changed existing
branch revision rejects the preparation as stale; no subset commits. The write
set has no update or supersede operation for an existing branch. Commands are
idempotent: retrying the same confirmed digest after its successful branch
creation returns the original durable result, while a retry with no matching
prior result must still prove the original branch binding. Changed operations,
revisions, or branch binding require a new assessment and confirmation. UI
tasks may cancel assessment and simulation, but cannot cancel after the local
transaction reaches its durable commit point.

Local commit order remains event/object state, projection invalidation, Receipt
and History lineage, rollback/compensation disposition, and external intent
creation under one parent semantic transaction. The Receipt and History bind
the prior branch-slot revision, created branch ID/revision, certificate,
confirmation digest, resulting graph revision, and resulting lifecycle state.
External executors run only after durable local success and reconcile
independently. Ordinary replay never reissues them.

### Replay, rollback, and compensation

Canonical events carry versioned branch/certificate references, exact typed
owner changes, before/after revisions, confirmation, Receipt, causal parent,
active-branch before/after binding, lifecycle transition, and replay
fingerprint. Replay reconstructs logically equivalent branch occupancy,
stale/expired/rolled-back/compensated lineage, certificate references, and
canonical owner state without consulting the review checkpoint or network.
Projection rebuilds derive current contextual entry, non-authorizing lifecycle
status, and historical inspection from canonical facts. `superseded` remains a
decodable inspectable status but this Design emits no supersession event.

When the active branch's base graph revision or a declared dependency changes,
the lifecycle evaluator fails branch-dependent authorization immediately and
records a typed transition to `stale` through the normal command/event sequence.
When the bound policy revision or horizon is no longer current, it does the same
for `expired`. Until that transition is durably projected, every promotion and
branch-dependent command independently derives the fail-closed stale/expired
result from current revisions and clock; projection lag cannot extend authority.

A safe rollback command targets the accepted parent transaction and contains
typed inverses with current expected revisions and the exact occupying branch
ID/revision. It commits as a new transaction, transitions that branch to
`rolled_back`, and retains the original event and external attempts. If inverse
preconditions fail, `BranchCompensationPlanner` produces a reviewable owner-
typed recovery; it never edits history or claims exact reversal. A failed
rollback or pending compensation leaves the branch slot occupied. Only a
durably terminal/resolved rollback or compensation disposition releases it;
neither retry nor compensation silently marks the branch `superseded`.

### Schema and migration

The first implementation introduces version-1 encodings for branch identity,
delta operations, certificates, dependency indexes, review checkpoints,
promotion events, and inspection projections. Storage changes are additive and
use the repository's explicit schema-plan mechanism. Because no current source
implementation exists, migration establishes one revisioned branch slot with an
explicit “no active branch” binding for existing stores and performs no inferred
backfill from Goals, Paths, or Time. Version 1 can decode and inspect `stale`,
`expired`, `rolled_back`, `compensation_required`, `compensated`, and reserved
`superseded` lineage even though this bounded workflow cannot create a direct
supersession. A store containing more than one occupying branch or an ambiguous
absence is quarantined for repair rather than choosing a winner.

The migration must be deterministic, idempotent, crash-safe, preserve the last
readable store and rollback/export path, support the declared direct-upgrade
horizon, and prove pre/post replay equivalence. Future event decoders preserve
historical operation meaning; unsupported versions block with recovery rather
than reset. Physical table/file placement, indices, retention bounds, and the
exact atomic-coordinator extension remain grooming decisions after focused
schema and performance tests.

## Privacy and accessibility

Every trigger, affected identity, correction set, candidate, certificate,
caregiving/location/employment/education fact, schedule consequence, selection,
checkpoint, Receipt, and recovery record is private local graph data. Review,
certification, selection, commit, replay, rollback, and inspection work offline
without an account. Public-reference refresh requests contain only fixed public
source identifiers and region/program keys already classified as public; no
Goal, schedule, location, caregiving, candidate, or private correlation ID may
cross that boundary. Unknown classification or redaction fails closed.

Recipient and external intent payloads are not assembled until the local
confirmation preview identifies the destination and minimum fields. Each intent
has its own destination disclosure, result, cancellation/retry policy, Receipt
link, and retention rule. No Ambitions backend, Account, R2, Source Atlas,
hosted model, telemetry, diagnostic upload, widget, notification, clipboard, or
external adapter receives a private branch payload. Notifications and widgets
use minimized generic status unless the user explicitly enables a more detailed
local projection.

The review uses a vertically ordered disclosure rather than requiring a branch
diagram. Semantic order is: trigger; why review is needed; simpler-owner result;
candidate identity and viability; protected conditions; changes/sacrifices;
unknowns/assumptions; affected objects; authority partitions; local consequence;
external intents; confirmation scope; recovery. A visual summary or comparison
table is supplementary.

Every action has a named control for VoiceOver, Voice Control, Switch Control,
and Full Keyboard Access, including inspect source, expand candidate, edit a
relaxable condition, use simpler owner, choose lighter correction, keep
conflict, defer, reject all, refresh, select, confirm, cancel, retry, rollback,
compensate, inspect the current branch, and return to its recovery route.
Assistive output names the occupying branch status, why it blocks promotion,
whether it is stale or expired and therefore non-authorizing, and that this
workflow cannot replace or supersede it. Candidate and status labels never rely
on color, icon, position, or motion. Dynamic Type may collapse comparison into
per-candidate sections; RTL preserves logical consequence order. Increased
contrast and reduced motion retain every state and action.

Focus returns to the exact owner result, changed dependency, blocked candidate,
selected summary, active-branch blocker, confirmation error, committed result,
external result, or recovery action. A branch-slot CAS failure focuses the
current branch heading and announces that no replacement was applied. Stale or
expired transitions focus their explanation and first valid resolution action.
Materialization, revalidation, and commit state changes use concise
announcements without repeated progress chatter. Sensitive details are not
spoken or shown on a lock-screen projection without an explicit existing
visibility choice.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| `REQ-001` | Confirmed `LifeBranchTrigger`, base graph revision, horizon, affected IDs, protected facts, authority/source revisions, and the existing branch ID/revision or explicit absence form the assessment input; inferred or forecast triggers stay `awaiting_confirmation`. |
| `REQ-002` | Fixed-order read-only assessment adapters test Goal, Goal Path, Recovery Segment, destination pivot, and Scheduling; any sufficient result produces `handoff_available` and suppresses candidate creation. |
| `REQ-003` | `LifeBranchNecessityAssessor` records and exposes all four conjunctive threshold results; failure of any clause produces `threshold_failed`. |
| `REQ-004` | Input validation admits only the approved relocation/caregiving/credential/onsite-work scenario; current remote-work or remote-program facts route to the simpler owner. |
| `REQ-005` | Bounded materialization emits two or three complete policy-distinct candidates, completeness coverage, and inspectable suppressed/blocked reasons; omitted consequences block certification. |
| `REQ-006` | Ordered candidate projections enumerate protected, changed, deferred, ended, sacrificed, assumed, costly, unresolved, and reversible consequences without aggregation or score. |
| `REQ-007` | Every delta and intent carries `user`, `recipient`, `joint`, or `external` authority; promotion writes only user-owned local operations and stores other effects as post-local intents. |
| `REQ-008` | Immutable certificates bind exact revisions and active-branch observation and use valid/fragile/blocked/invalid/stale/expired/superseded operational states; only current `valid` with an explicitly empty branch slot enables selection. |
| `REQ-009` | Materialization, comparison, editing, refresh, defer, reject, and selection remain planning simulation; checkpoints are non-authoritative and contain no duplicate canonical objects. |
| `REQ-010` | Review exposes every required action; relaxable edits recertify, while protected edits exit to the owning command before reassessment. |
| `REQ-011` | Promotion binds a fresh read set, revisioned active-branch absence, and confirmation digest, then CAS-creates one branch in the parent atomic local transaction across existing owners with Receipt, History, replay, recovery, and separately persisted external intents; direct replacement/supersession is unavailable. |
| `REQ-012` | CAS rejection, branch-slot occupation/revision change, and crash-before-settlement preserve the previous graph; idempotent retry returns only the exact prior result or revalidates the original binding; post-local external failure cannot change local success. |
| `REQ-013` | Typed rollback revalidates current revisions and the occupying branch, records `rolled_back` as a new mutation, and releases the slot only at a terminal/resolved disposition; unsafe reversal routes to explicit compensating recovery while preserving original lineage and external attempts. |
| `REQ-014` | Certificate dependency indexes drive bounded impact-cone invalidation; changed active-branch binding or missing indexes/lost completeness conservatively stale the candidate, while active-branch dependency/base change yields inspectable non-authorizing `stale` and policy/horizon expiry yields `expired`. |
| `REQ-015` | All private branch data remains local/offline; public refresh uses fixed public identifiers only and the privacy firewall denies every prohibited destination or unknown class. |
| `REQ-016` | Contextual projections disappear when threshold fails or reconciliation settles; canonical Goals and Time remain primary and Trust/History alone retains lineage. |
| `REQ-017` | The fixed semantic order, named non-gesture controls, focus/announcement rules, Dynamic Type, contrast, reduced-motion, RTL, and non-color behavior provide complete nonvisual parity. |

## Verification design

Verification must preserve the current proof ceiling: passing model or
transaction tests does not establish app, device, accessibility, or release
readiness. Grooming should map every test below to the Scope acceptance criteria
and the five CEBR owner boundaries.

### Domain and policy tests

- Exercise `AC-001` through `AC-004` with the worked relocation fixture,
  forecasts/unconfirmed facts, remote-work and remote-program simpler repairs,
  multi-object-but-independent repairs, grouped-preview-only cases, and a
  refused non-approved sensitive-domain trigger.
- Prove candidate completeness and two-or-three bounds; omit each Goal, Path,
  placement, protected rule, obligation, Proof condition, and external follow-
  up in turn and require `blocked` (`AC-005`).
- Prove policy-distinct fingerprints, consequence-equivalent suppression,
  stable ordering, no scalar/best label, and the full consequence vocabulary
  (`AC-005`, `AC-006`).
- Cover all authority partitions and assert that recipient/joint/external
  effects cannot enter the local mutation write set (`AC-007`).
- Cover every certificate state, exact revision/fingerprint binding, hard and
  relaxable dependencies, missing-index conservative invalidation, bounded
  cycle handling, impact-cone-only staleness, policy/horizon expiry, and the
  active-branch ID/revision-or-explicit-absence binding (`AC-008`, `AC-014`).
- Prove that `active_local`, `active`, `stale`, `expired`, and
  `compensation_required` branches block candidate promotion; terminal/resolved
  lineage permits a newly assessed candidate; and no bounded command can create
  `superseded` or automatically replace an existing branch.

### Mutation, concurrency, persistence, and replay tests

- Snapshot every canonical aggregate before all pre-confirmation actions and
  prove byte-equivalent state afterward (`AC-009`, `AC-010`).
- Test concurrent edits to every affected owner between materialization,
  selection, confirmation, preparation, and commit, including creation of an
  active branch, transition of its status, and change of its revision. Each
  stale read or changed branch binding must reject the whole parent transaction
  with no partial owner settlement (`AC-011`, `AC-012`).
- Race two otherwise valid promotions against the same explicit-absence
  revision. Exactly one may create the active branch; the loser fails closed and
  exposes the winner without mutation or automatic supersession.
- Assert that the winning branch binds the atomic transaction's resulting graph
  revision while its certificate preserves the pre-promotion base. The branch
  must not become stale because of its own promotion writes; the next declared
  dependency/base change must stale it.
- Run duplicate command and process-restart races; one confirmation digest and
  idempotency key must yield one local result, Receipt, History lineage, branch
  transition, and external-intent set. A duplicate after success returns that
  exact branch result; a non-matching retry against an occupied or revision-
  changed slot is rejected.
- Inject failure at every atomic coordinator phase, before and after the durable
  local boundary. Pre-boundary failures preserve the old graph; projection or
  external recovery after local settlement cannot report rollback (`AC-012`).
- Replay from an empty projection store and supported historical schema; assert
  equivalent canonical objects, branch-slot occupancy, active/stale/expired/
  rolled-back/compensated lineage, certificate references, Receipt/History,
  pending external state, and no external reissue. Reserved `superseded` must
  decode for inspection but cannot be emitted by bounded-v1 commands.
- Prove safe typed rollback, conflict-blocked rollback, subsequent-work and
  external-effect compensation, slot retention until a terminal/resolved
  disposition (including unresolved compensation), and retention of original
  decision basis (`AC-013`).
- Test additive migration from every supported direct-upgrade version, crash at
  each migration phase, second-run idempotency, unsupported-old-store recovery,
  corrupt certificate/checkpoint handling, backup/restore, and exact pre/post
  replay equivalence. Existing stores must emerge with an explicit revisioned
  no-active-branch binding; ambiguous absence or multiple occupying branches
  must quarantine rather than infer or select one.

### Runtime and degraded-path tests

- Drive the complete Goals/Time contextual flow for valid, fragile, blocked,
  stale, no-complete-candidate, handoff, keep-conflict, defer, reject, commit,
  external failure, active-branch-blocked, active-branch stale/expired, rollback,
  and compensation states.
- Change an active branch's base/dependency and assert immediate non-authorizing
  `stale`; advance beyond its policy/horizon and assert `expired`. Both remain
  inspectable, continue occupying the slot, block replacement, and preserve the
  original certificate/Receipt/History lineage.
- Remove or stale provider and employer facts and verify that dependent
  candidates fail closed while unaffected consequences remain inspectable.
  Public refresh must not receive private scenario parameters.
- Verify the contextual entry disappears after resolution and never creates a
  root, standing hypothetical-self list, score, or engagement prompt (`AC-016`).
- Build and run the changed-scope native target plus focused domain,
  transaction, replay, Scheduling handoff, inspection, and UI tests. Existing
  path-comparison tests remain regression coverage but do not substitute for
  Life Branch tests.

### Privacy and security tests

- Enumerate branch fields, derived explanations, identifiers, checkpoints,
  certificates, Receipts, diagnostics, projections, notifications, widgets,
  clipboard/share paths, external intents, and public-reference requests across
  every declared destination. Unknown/mixed classes and private correlation IDs
  must fail closed (`AC-015`).
- Assert offline creation, assessment, materialization, review, selection,
  local commit, replay, rollback, compensation, and inspection with network and
  account unavailable.
- Verify local file protection, export/deletion preview, redacted diagnostics,
  minimum external intent fields, and independent outbox cancellation/retry.

### Accessibility and device evidence

- Directly verify the complete ordered review and every action with VoiceOver,
  Voice Control, Switch Control, and Full Keyboard Access on a supported device
  or simulator lane appropriate to each technology (`AC-017`).
- Cover candidate replacement, stale-fact return, commit result, external
  failure, active-branch blocker, stale/expired non-authorizing explanation,
  branch-slot race rejection, rollback/compensation, focus restoration, and
  announcements. Assistive output must state that no replacement or
  supersession occurred.
- Test accessibility sizes, increased contrast, reduced motion, RTL, non-color
  state, lock-screen privacy, interruption/relaunch, and device rotation without
  losing review position or controls.

### Performance and resource evidence

- Calibrate before setting budgets using the bounded scenario plus
  representative affected-object, dependency, candidate, event-history, and
  external-intent scales. Measure cold/warm assessment, certificate rebuild,
  impact-cone refresh, comparison projection, confirmation preparation, replay,
  memory, storage, and energy on declared device/OS/build/tool conditions.
- Candidate construction, graph traversal, migration, and replay must be
  deterministic, bounded, cancellable before commit, and off-main when material.
  Product caps and regression thresholds are chosen from measured evidence in
  grooming, not invented by this Design.

## Open decisions

There is no unresolved product decision requiring a return to Scope.

Technical decisions for grooming are the exact Swift file/type partition, the
physical schema and indexes for branch/certificate/checkpoint records, the
smallest safe extension of the existing atomic commit coordinator for a
multi-owner write set, the direct-upgrade horizon, and calibrated horizon,
dependency, history, and performance caps. These choices may not weaken the
conjunctive threshold, two-or-three complete-candidate boundary, certificate
gate, authority partition, one-parent local transaction, revision-bound empty-
branch CAS, existing-branch promotion block, non-authorizing stale/expired
lifecycle, inspectable historical lineage, or recovery semantics fixed above.
Direct replacement and supersession are not grooming choices: they require a
separately approved future transaction and are unavailable in this bounded
Design.
