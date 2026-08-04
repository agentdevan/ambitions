+++
initiative = "destination-adoption-and-pivot"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

This design introduces a private local `DestinationDirection` as the smallest
durable pre-Goal owner. It preserves one advisory outcome, its user wording,
rationale, uncertainty, provenance, bounded dismissal state, and any later
promotion lineage without acquiring Goal, Goal Path, Step, Proof-rule, or Time
semantics. A transient recommendation can be reviewed without persistence;
`Keep for later` creates or updates a `DestinationDirection`. The existing
source-level `NorthStar` value model may inform projections but is not promoted
to canonical ownership by this work, and a Saved-for-Later Draft remains the
owner of unresolved Capture input rather than becoming a destination library.

Adoption is an owner handoff. An `AdoptionReview` freezes the candidate,
duplicate findings, selected Life Area, and explicit relationship proposals.
Duplicate review has four terminally different branches. `Open existing` is
navigation only. `Relate candidate` explicitly confirms a typed private
life-graph relationship while retaining or creating a dormant direction and
never creating a Goal. `Refine` invalidates dependent rationale, duplicate, and
relationship review and reruns them without mutation. Only `Continue distinct`
may reach Goal confirmation and send the idempotent
`CreateProvisionalGoalFromDirection` command to the Goal owner. Successful
distinct settlement creates exactly one provisional Goal and its
Receipt/History lineage; it does not create or accept a route. Goal-path
generation may be offered only after that settlement has succeeded.

A changed-destination pivot uses the same adoption boundary but binds an old
Goal and its revision. The old Goal is never edited into the new outcome.
Creating the new provisional Goal and keeping, pausing, or ending the old Goal
are separately owned mutations with separately visible results. For a
continue-distinct pivot, the normal sequence first preserves the new intent as
a provisional Goal, then attempts the chosen old-Goal command and any approved
relationship commands. The UI may
say “New Goal created; old Goal still needs review,” but not “Pivot complete,”
when a later command fails or becomes stale. If the user requires all changes
to settle atomically, this flow makes no mutation and hands a typed proposal to
Life Branch assessment.

The design treats “this still counts” as a relationship review, never a copy or
credit decision. Retained personal evidence, apparent relevance, possible
support for a sourced condition, named-policy recognition, and external
acceptance remain separate states. A relationship to the new Goal cannot mark
work complete, satisfy a requirement, change Proof, or make an eligibility
claim.

## User flows

### Inspect an advisory candidate

1. Open a candidate from a recommendation surface, a user-entered direction,
   or a contextual Goal prompt. The header says `Possibility — not a Goal` and
   shows the proposed outcome and Life Area.
2. Review “Why this appeared,” with local input categories, explanation,
   uncertainty, and each public claim's authority, region/program, retrieval
   date, and freshness. Protected derived output has already failed closed and
   therefore never opens this flow.
3. Choose `Edit direction`, `Correct why`, `Keep for later`, `Dismiss`, or
   `Make this a Goal`. Navigation, source inspection, and cancellation create
   no durable object or Receipt.
4. Editing the outcome invalidates unsupported rationale, source claims,
   duplicate findings, and relationship proposals. Review resumes at the first
   invalidated section rather than carrying authority to new wording.

### Keep for later

1. Preview the exact direction, Life Area, retained rationale categories, and
   the statement that no Goal, route, Step, Proof requirement, placement, or
   deadline will be created.
2. Confirm `Keep for later`. The direction owner creates one
   `DestinationDirection` with dormant lifecycle and a Receipt/History Event.
3. The result offers `Open direction` and `Done`. Search and contextual Goals
   review can find it, but Today and root navigation do not become direction
   backlogs.
4. A saved direction can be edited, archived, restored, moved to Trash,
   restored from Trash, or permanently deleted through its owner. Dismissal is
   distinct from lifecycle deletion. Trash is recoverable and removes the
   direction from ordinary projections. Permanent deletion previews the exact
   direction, rationale, source-link, review-draft, search/export, and promotion-
   lineage consequences; it never deletes a promoted Goal or any source Goal,
   Proof, capability, Receipt, or History object.

### Dismiss or set a broader exclusion

1. `Dismiss` records only the exact candidate identity, outcome fingerprint,
   rationale/evidence basis, source revision set, and review context. The sheet
   explains that materially changed evidence may create a new basis.
2. `Don't suggest directions like this` is a separate secondary action. It
   previews the exact scope—named outcome, category, or declared evidence use—
   and never offers a personality or permanent-interest interpretation.
3. The resulting local-learning influence is inspectable, correctable,
   disableable, and resettable from You. Removing it restores eligibility for
   future review; it does not recreate deleted candidates or directions.

### Adopt a new direction

1. `Make this a Goal` opens an adoption review bound to the candidate revision.
   The user confirms exact outcome wording and one Life Area.
2. A duplicate pass lists equivalent or related saved directions and Goals by
   stable identity and lifecycle. The four choices have separate exits:
   - `Open existing` navigates to the selected direction or Goal. It issues no
     command, changes no candidate, direction, relationship, or Goal, creates no
     Receipt, and returns to the same duplicate review after revalidation.
   - `Relate candidate` previews the exact candidate/direction and selected
     existing identity, the qualitative `related` meaning, and the fact that no
     Goal will be created. Explicit `Confirm relationship` first retains a
     transient candidate as one dormant `DestinationDirection` when no stable
     direction exists, then sends `RelateDirectionToExistingItem` to the private
     life-graph relationship owner. An already saved direction remains dormant.
     Success settles this review as `relatedExisting`, preserving both objects;
     it never marks the direction `promoted` and never invokes Goal creation.
   - `Refine outcome` returns to outcome editing. The selection itself issues no
     owner command or Receipt, and no canonical object, relationship, or
     lifecycle mutation occurs. Changing wording invalidates every dependent
     rationale support fingerprint, duplicate-set fingerprint, duplicate
     decision, and proposed relationship, then reruns rationale and duplicate
     review from the changed candidate before any branch can be confirmed.
   - `Continue distinct` records the explicit distinct decision and is the only
     branch that advances to provisional-Goal confirmation.
3. For `Continue distinct` only, the confirmation summary says `Creates: one
   distinct provisional Goal` and `Does not create: a route, Steps, Proof
   requirements, schedule, merge, replacement, or reactivation`.
4. Confirming `Continue distinct` submits one
   `CreateProvisionalGoalFromDirection` command with candidate lineage,
   original intent, outcome, Life Area, expected candidate revision,
   duplicate-set fingerprint, explicit distinct decision, and idempotency key.
   Open, relate, and refine paths cannot construct or dispatch this command.
5. On durable distinct-creation success, the result resolves the new Goal,
   Receipt, and History Event. The direction becomes `promoted` with a link to
   the Goal; the source candidate remains inspectable according to its retention
   choice.
6. The user may open the Goal, finish, or separately start Goal-path generation.
   No default action starts planning or scheduling.

### Pivot to a changed destination

1. From an existing Goal, choose `Change destination`, enter or select a new
   direction, and compare the old and proposed outcomes. A semantic comparison
   asks whether the desired outcome is changing.
2. If only a degree, role, preparation sequence, Step order, or schedule changes
   while the outcome remains the same, exit this flow without mutation and
   route to Goal-path generation or adaptive path comparison.
3. For a changed outcome, run the same four-branch duplicate review before
   progress continuity. Open navigates without mutation; relate confirms one
   dormant-direction relationship and exits with the old Goal unchanged and no
   new Goal; refine invalidates and reruns review; only continue-distinct moves
   forward. For that distinct branch, each old Proof, capability,
   completed-work, or context item is labeled `Retained evidence`, `May be
   relevant`, `May support a condition`, `Recognized by named policy`, or
   `External authority decides`. The user may propose links only; unchecked
   items remain unchanged.
4. Choose what happens to the old Goal: `Keep unchanged`, `Pause`, `End with
   Closure`, or `Cancel`. Completion and archive are not shortcuts in this
   flow. Ending invokes the existing Closure review before pivot confirmation.
5. Review a settlement plan listing each owner and consequence. If the user
   selects `Require all changes together`, stop and hand the plan to Life
   Branch assessment. Otherwise confirm independent settlement.
6. On the continue-distinct branch, the Goal owner first creates the new
   provisional Goal. After success, the old Goal owner performs the confirmed
   keep/no-op, pause, or Ended Closure action. The relationship owner then
   creates only the approved links.
7. Show per-operation results. Full success says the new Goal exists and states
   the old Goal's exact state. Partial success names what settled, what did not,
   and offers retry, review current state, or return. It never rewrites either
   outcome or deletes original evidence.

### Cancel, resume, and reverse

- Cancel before provisional Goal settlement creates no Goal and preserves a
  saved direction or resumable review only when the user asked to retain it.
- Cancel before `Confirm relationship` creates no direction or relationship.
  After relation success the branch is already truthfully settled; removing the
  relationship is a separate confirmed relationship-owner command, and the
  dormant direction remains unless its owner separately archives or deletes it.
- Resume restores the candidate revision, edits, Life Area, duplicate decision,
  selected relationships, old-Goal choice, semantic focus, and base revisions.
  Changed inputs mark only affected sections stale and block confirmation until
  they are refreshed.
- `Undo Goal creation`, `Resume old Goal`, `Correct Closure`, and `Remove
  relationship` are separate owner actions. Availability is shown only when an
  implemented inverse or compensating command is currently valid. Genuine
  later work and external consequences are never erased to simulate reversal.

## States and recovery

### Direction and review states

`DestinationDirection` lifecycle is `dormant`, `archived`, `trashed`,
`promoted`, or `permanentlyDeleted`. Review state is orthogonal:
`unreviewed`, `reviewable`, `needsCorrection`, `stale`, `blockedProtected`, or
`settled`. Candidate origin is `userEntered`, `localRecommendation`,
`savedDirection`, or `goalPivot`; it does not confer authority.

An `AdoptionReview` is `editing`, `duplicateReview`, `confirmingRelationship`,
`submittingRelationship`, `relatedExisting`, `continuityReview`,
`confirmationReady`, `submittingGoal`, `submittingOldGoal`,
`submittingRelationships`, `partiallySettled`, `settled`, `stale`, `cancelled`,
or `failed`. Its duplicate decision is exactly one of `none`,
`openExisting(existingID)`, `relateCandidate(existingID)`, `refine`, or
`continueDistinct`. `Open existing` leaves the review in `duplicateReview`;
`Refine` clears the decision and returns it to `editing`; `Relate candidate`
ends at `relatedExisting` after relationship-owner success; only
`continueDistinct` can make the review `confirmationReady` for Goal creation.
Presentation derives from recorded owner results rather than an optimistic
aggregate flag.

### Visible empty, blocked, and degraded states

- No rationale: show `You entered this direction` or the available evidence
  categories; do not fabricate an explanation.
- No duplicates: say `No related saved directions or Goals found in the current
  local revision`; this is not a global uniqueness claim.
- No continuity candidates: adoption proceeds without a transfer section.
- Stale or unavailable public facts: adoption of intent remains available, but
  facts appear as unknown/review-needed and no eligibility or current-route
  claim is displayed.
- Protected derived candidate: remain quiet and retain only a content-minimized
  local denial diagnostic. User-entered protected intent can be reviewed locally.
- Goal store unavailable: preserve the candidate/review and offer retry or keep
  for later; never report a provisional Goal.
- Direction store unavailable during `Relate candidate`: create neither the
  dormant direction nor relationship, preserve the review, and offer retry.
- Private life-graph relationship owner unavailable: if no direction was newly
  retained, make no mutation; if direction retention already settled, show the
  dormant unlinked direction as the exact partial result and retry only the
  relationship command. Never fall through to Goal creation.
- Existing duplicate removed or revised: mark only the duplicate decision
  stale, show the current identity/state, and require a new open, relate,
  refine, or distinct choice.
- All-or-none request: show why Life Branch is required and preserve this review
  without issuing any owner command.

### Concurrency and stale recovery

Every preview binds candidate/direction revision, Goal graph revision, relevant
Goal revisions, source-manifest revision, evidence-link revisions, duplicate-set
fingerprint, selected existing-object revision, privacy-policy revision, and
confirmation-scope fingerprint. Before each mutation, the coordinator re-reads
the owning object and validates only the command it is about to send. A mismatch
returns a typed stale result and never silently recomputes inside a confirmed
scope. `Open existing` performs navigation after a read and no mutation.
`Refine` invalidates the old confirmation scope before rerunning review.
`Relate candidate` revalidates the candidate/direction, target, and relationship
graph revisions at explicit confirmation. `Continue distinct` separately
revalidates the candidate and frozen duplicate set before Goal creation.

After partial settlement, recovery starts from authoritative owner results.
Idempotent retry uses the original operation key for an unknown result and a new
key only for a newly confirmed command. Projection delay shows `Saved locally;
updating view` after durable success. Crash recovery replays committed events,
then resumes the first unsettled operation; it cannot duplicate the Goal or
relationships. For `Relate candidate`, direction retention and relationship
creation have stable independent operation keys; replay reconstructs at most one
dormant direction and one typed relationship, and retry after an unknown result
reuses the unsettled operation's original key. A stale result requires a fresh
relationship confirmation and key. Relationship failure never changes the
direction to `promoted` and never enables Goal creation. A failed old-Goal or
link mutation leaves the new provisional Goal honest and visible. A failed
new-Goal mutation prevents every later pivot operation.

## Architecture and data

### Ownership and components

- **Destination direction domain owner:** defines `DestinationDirectionID`,
  lifecycle, source/rationale snapshots, promotion lineage, and validation. It
  is non-executable and cannot own Goal Path, Step, Proof, or placement state.
- **Candidate projection service:** assembles user-entered or locally produced
  candidate views from already-local inputs. It performs output-sensitive
  classification before presentation and emits no canonical command.
- **Direction repository and commands:** persist keep/edit/archive/Trash/
  restore/delete/promotion-link operations through `Command → Event →
  Projection → Receipt → Replay`.
- **Duplicate resolver:** deterministically compares normalized outcome keys and
  explicit relationships over a frozen local graph revision. It returns
  candidates and reasons, never a merge decision.
- **Continuity projector:** reads source IDs and produces typed relationship
  proposals. It cannot mutate or clone the source object and cannot turn
  relevance into requirement satisfaction.
- **Private life-graph relationship owner:** is the sole mutation authority for
  accepted typed relationships between a `DestinationDirectionID` and an
  existing direction or Goal ID. It validates both identities and revisions,
  persists `LifeGraphRelationship` identity and lineage, and owns relationship
  event, Receipt, replay, retry, and removal semantics. The duplicate resolver,
  adoption coordinator, Goals surface, and either endpoint owner cannot write
  this relationship directly.
- **Adoption coordinator:** stores review checkpoints, validates confirmation
  fingerprints, dispatches commands to owners, and records per-command results.
  It has no direct database write path and no authority to synthesize atomicity.
- **Goal, Closure, Receipt, History, privacy, and Life Branch owners:** retain
  their existing canonical mutation and recovery authority.
- **Goals surface:** presents the ordered flow and owner results. Search and
  Trust expose saved directions and provenance; no new root surface is added.

### Persistent records

`DestinationDirectionV1` contains stable ID, schema version, original and
current outcome wording, one primary Life Area, origin, rationale entries,
local input-category labels, source-claim references with captured freshness,
uncertainty categories, privacy class, lifecycle, candidate/outcome fingerprint,
created/updated revisions, promoted Goal ID if any, and Receipt/History links.
It does not store a score, inferred trait, accepted route, Step, Proof rule,
deadline, or schedule fact.

Permanent deletion removes or irreversibly redacts direction wording, rationale,
private input categories, source-link detail, dismissal context, and retained
review content so the direction cannot be reconstructed from projections,
search, diagnostics, or export. A content-free integrity tombstone may retain
only stable deletion/lineage identifiers and policy facts where Receipt/History
law requires them. The promoted Goal keeps its own user-owned outcome and
original-intent history; its surviving lineage says only that a source direction
was governed-deleted and never preserves the deleted direction's private content.

`DestinationRationaleEntryV1` binds an explanation to an input category or
public claim ID, source revision, uncertainty, and supported outcome fingerprint.
Changing the outcome disables entries whose support fingerprint no longer
matches until they are explicitly recomputed or removed.

`DestinationDismissalV1` binds the exact outcome, rationale/evidence basis,
source revisions, and review context. A broader exclusion is a separate local-
learning influence with explicit scope and controls. Neither record is a hidden
interest profile.

`AdoptionReviewCheckpointV1` is a private local draft containing candidate and
base revisions, edited outcome, Life Area, the typed duplicate decision and
selected existing-object revision, proposed relationship IDs and
classifications, old Goal/choice when applicable, confirmation scope, semantic
focus, and per-operation settlement results. It records whether a relate branch
retained a dormant direction and whether the relationship owner settled, so
recovery never substitutes Goal creation. It is not a Goal, Receipt, or source
of mutation truth.

The accepted duplicate relationship is one private `LifeGraphRelationship`
owned by the private life-graph relationship owner. It contains a stable
relationship ID, `relatesTo` kind, source `DestinationDirectionID`, target saved
direction or Goal ID, expected source/target revisions, qualitative explanation,
created/updated revision, operation/idempotency key, and Receipt/History links.
It grants no execution, completion, Proof, eligibility, merge, replacement, or
reactivation semantics. Removing it uses that same owner's correction/removal
command and does not delete either endpoint.

`ProgressRelationshipProposalV1` contains source object ID and revision, target
provisional Goal ID once known, relationship kind, continuity class, explanation,
supporting public-claim/policy reference if present, and `externalAuthority`
when acceptance is outside Ambitions. Accepted graph relationships reference
source IDs; they never copy evidence content or state.

### Commands, events, and replay

The direction owner exposes typed keep, edit, lifecycle, dismissal-reset, and
promotion-lineage commands. `OpenExistingDuplicate` is a navigation intent only
and never enters the command bus. `RefineDuplicateOutcome` is a review-state
transition that invalidates dependent rationale, duplicate, and relationship
results; it issues no canonical owner command or Receipt.

After explicit `Confirm relationship`, a transient candidate first uses the
direction owner's idempotent `KeepDirectionForRelationship` command to obtain
one dormant `DestinationDirectionID`; an existing saved direction needs no
retention command and remains dormant. The coordinator then sends
`RelateDirectionToExistingItem` to the private life-graph relationship owner
with source/target identities and revisions, duplicate-set and confirmation
fingerprints, relationship meaning, and its own stable idempotency key. Success
creates one relationship Event, Projection change, Receipt, and History entry;
it creates no Goal, promotion link, route, Step, Proof rule, or Time mutation.

Only a confirmed `continueDistinct` decision enables the Goal handoff's typed
`CreateProvisionalGoalFromDirection` command with expected revisions and a
stable idempotency key. Every other duplicate decision is rejected at that
command boundary. Pivot settlement stores an ordered operation plan, but each
operation is a real owner command and result; `keep unchanged` is an explicit
reviewed no-op, not a mutation Receipt.

Events are immutable, projections are rebuildable, and every durable owner
mutation commits its History Event atomically before success. Replay reconstructs
direction lifecycle, promotion lineage, Goal creation, Goal lifecycle, and
relationships without relying on the checkpoint. Relationship replay is keyed
by relationship identity and operation key, so duplicate delivery cannot create
parallel links. If retaining a direction succeeds but relationship creation is
unknown or fails, replay exposes the dormant direction plus unsettled
relationship operation and retry resumes only that operation. A Receipt links
to the exact owner command and affected IDs. Candidate inspection, preview,
cancellation, source refresh, opening an existing item, and selecting refine do
not issue Receipts.

### Persistence migration and compatibility

This is an additive schema. Existing Goals, Saved-for-Later Drafts, North Star
value fixtures, Proof, relationships, and History are not retyped or backfilled
automatically. The new direction-to-existing relationship kind is absent by
default and appears only after explicit relate confirmation; migration never
infers it from label similarity or existing duplicate candidates.
If a future implementation finds persisted North Star-shaped data, it remains
readable under its existing schema and is offered for explicit user-reviewed
import into `DestinationDirection`; label similarity never migrates it silently.
Decoder migration preserves unknown enum values as needs-review instead of
choosing lifecycle or authority. Rollback leaves new records readable by the
last compatible build or quarantined with export/restore recovery; it never
deletes Goals created by a newer version.

### Concurrency and resource behavior

Domain values are `Sendable`; repositories serialize writes per stable object
ID; cross-owner coordination is an actor with cancellation-safe operation
records. Read models may build off-main from immutable snapshots. Duplicate and
continuity scans are deterministic, order-independent, bounded to explicit
candidate sets, and cancellable. Grooming must establish representative scale,
device/build/tool, warm/cold percentiles, memory/energy/storage, and regression
thresholds rather than inventing numeric performance claims here.

## Privacy and accessibility

All candidates, directions, rationale, private input categories, duplicate
relationships, review checkpoints, Goal links, exclusions, and settlement
history are `private life graph`. Candidate composition, duplicate review,
continuity projection, adoption, replay, search, and recovery work offline and
without an account. Public-reference fetches use only finite allowlisted public
artifact IDs; no outcome wording, Goal ID, capability, rationale, rejection,
stable private identifier, or private-derived cache key may enter Source Atlas,
R2, Account, telemetry, diagnostics, support upload, or hosted AI.
`Relate candidate` confirmation and its relationship Event/Receipt remain local
private-graph data; neither endpoint identity nor the fact that the user chose
open, relate, refine, or distinct may become an external query or diagnostic
value.

The output itself is classified before presentation. A locally derived
candidate or rationale that reveals protected health, disability, citizenship,
religion, finances, age, family, legal, or similarly sensitive context remains
quiet. User-entered protected intent may be stored locally, but is excluded from
suggestion expansion and external projection. Unknown classification fails
closed. Local diagnostics contain policy/category/correlation identifiers only,
never outcome or rationale values.

The semantic order is: state (`Possibility — not a Goal`), outcome, Life Area,
rationale and uncertainty, sources/freshness, duplicate relationships,
the four duplicate choices and their distinct consequences, continuity
distinctions, old-Goal choice, exact confirmation scope, per-owner result, and
recovery. Relationship graphics are optional decoration; the complete decision
is an ordered list. Every action has a unique visible label and accessibility
name including the affected direction or Goal and consequence. The labels are
`Open <existing item> — no changes`, `Relate <direction> to <existing item> —
no Goal`, `Refine <direction> — review again`, and `Continue as a distinct Goal`;
they are never collapsed into a generic Continue action.

VoiceOver rotor/heading order follows the semantic order. Voice Control,
Switch Control, and Full Keyboard Access reach edit, source inspection, keep,
dismiss, broader exclusion, duplicate choice, continuity selection,
confirmation, cancel, retry, and owner recovery without drag, swipe-only,
long-press, color, or diagram position. Dynamic Type reflows comparison cards
into one column without truncating outcome or consequence. Increased contrast,
Differentiate Without Color, Reduce Transparency, and Reduce Motion preserve
state. Opening an existing item announces that no changes were made and return
focus lands on its duplicate row. Relate confirmation reads both identities,
the `related` meaning, and `No Goal will be created`; success announces the
dormant direction and relationship, while partial failure focuses `Retry
relationship`. Refine returns focus to the outcome field and announces that
rationale, duplicate, and relationship review must run again. Only the distinct
branch exposes and focuses `Create distinct provisional Goal`. Validation moves
focus to the exact stale or invalid field; mutation success announces the
affected object and focuses its result; partial failure focuses the first
unsettled owner action.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Advisory header, rationale/source inspection, typed origin, uncertainty and output classification keep candidates distinct from Goals and predictions. |
| REQ-002 | `DestinationDirection` is a non-executable durable owner with explicit lifecycle and no Goal/Path/Step/Proof/Time fields. |
| REQ-003 | Exact-basis dismissal, separate scoped exclusion, outcome support fingerprints, and edit invalidation bound every control. |
| REQ-004 | `CreateProvisionalGoalFromDirection`, explicit consequence preview, Goal-owner settlement, and separate path handoff create exactly one provisional Goal. |
| REQ-005 | Frozen duplicate pass yields four complete branch contracts: open is navigation-only; relate explicitly confirms one private life-graph-owner relationship while retaining a dormant direction and creating no Goal; refine invalidates dependent rationale/duplicate/relationship review and reruns without mutation; only continue-distinct can issue `CreateProvisionalGoalFromDirection`. Revision checks, idempotent relationship retry/replay, branch-specific failure, and accessible consequence labels satisfy AC-005 without silent merge or duplicate activation. |
| REQ-006 | Outcome comparison routes same-outcome changes away; changed outcomes retain the old Goal and receive a new Goal ID. |
| REQ-007 | Pivot review exposes keep/pause/Ended Closure/cancel and delegates every transition to the old Goal/Closure owner. |
| REQ-008 | Typed continuity classes and ID-only graph relationships preserve source evidence without copying, completion, equivalency, or acceptance claims. |
| REQ-009 | Unknown/review-needed source and personal facts do not block adoption of intent and cannot become eligibility or route claims. |
| REQ-010 | Ordered owner settlement, per-operation results, partial-state language, and Life Branch handoff preserve honest completion semantics. |
| REQ-011 | Versioned checkpoints, revision revalidation, idempotent retries, and distinct owner reversals preserve truth through cancellation and interruption. |
| REQ-012 | Private classification, local composition, finite public requests, output-sensitive fail-closed policy, and egress tests enforce the boundary. |
| REQ-013 | Qualitative language and forbidden score/shame assertions cover low overlap, dismissal, pause, Ended, and unrelated evidence. |
| REQ-014 | Ordered nonvisual representation, named controls, focus/announcement recovery, assistive input, Dynamic Type, contrast, and reduced-effects behavior preserve the full decision. |

## Verification design

### Automated and model verification

- Unit tests validate every direction lifecycle transition, unsupported
  transition, rationale support fingerprint, exact dismissal basis, broader
  exclusion reset, output classification, deterministic duplicate ordering,
  recoverable Trash, and permanent-deletion minimization without deletion of a
  promoted Goal or source evidence.
- Duplicate-branch matrix tests assert `Open existing` performs navigation with
  zero commands/Events/Receipts; `Refine` invalidates rationale, duplicate-set,
  decision, and proposed-link state and reruns review with zero owner mutations;
  `Relate candidate` requires explicit confirmation, leaves or creates one
  dormant direction, creates exactly one `relatesTo` relationship through the
  private life-graph relationship owner, and creates zero Goals; and only
  `Continue distinct` can dispatch `CreateProvisionalGoalFromDirection`.
- Relationship-owner contract tests cover transient and saved directions,
  expected source/target/graph revisions, stale target, removed target,
  unavailable direction/relationship stores, unknown result, projection delay,
  repeated delivery under one idempotency key, newly confirmed retry under a
  new key, partial retained-direction/link-failure recovery, removal, and replay
  to exactly one relationship with no `promoted` lifecycle or Goal side effect.
- Contract tests prove a candidate and saved direction cannot carry Goal,
  Goal Path, Step, Proof-rule, placement, deadline, completion, or score fields.
- Goal handoff tests reject open/relate/refine decisions at the command boundary;
  for explicit continue-distinct they bind candidate, duplicate-set, and Goal
  revisions, create one provisional Goal under repeated idempotent delivery,
  retain original intent/lineage, and create no route or Time mutation.
- Pivot matrices cover same-outcome exit; changed outcome with keep, pause,
  Ended Closure, and cancel; new-Goal failure; stale old Goal; relationship
  failure; projection delay; unknown command result; retry; and Life Branch
  all-or-none handoff. Assertions inspect authoritative IDs and owner results.
- Continuity fixtures prove all five meanings remain distinct, links retain
  source IDs, and no relationship changes Proof, completion, requirement,
  eligibility, equivalency, or external-acceptance state.
- Replay/property tests rebuild equivalent projections under permuted input,
  interruption after every event, duplicate command delivery, rollback, archive,
  Trash/restore, and governed deletion. Branch replay fixtures prove navigation
  and refine add no owner event, relate restores a dormant direction plus at
  most one relationship without a Goal, and continue-distinct restores exactly
  one provisional Goal without an inferred relationship.

### Build, runtime, migration, and performance evidence

- Run changed-scope format/lint/static analysis, secrets/privacy scanning,
  canon check, project generation check when `project.yml` changes, focused unit
  and integration suites, and the relevant app build/test lane.
- Runtime tests launch from candidate, saved direction, Search, and old Goal;
  background/terminate at every review and settlement state; relaunch offline;
  and verify exact focus, lineage, Receipt/History, and no duplicate Goal.
- Duplicate-review runtime tests exercise all four choices from equivalent saved
  direction and active/paused/ended/archived Goal rows. They verify open-and-
  return with no mutation, relate confirmation and success/partial/retry states,
  refine invalidation and rerun, distinct-only Goal confirmation, and that no
  failure path silently falls through to another branch.
- Migration fixtures cover empty stores, existing Goals/Drafts, compatible and
  unknown direction schemas, legacy North Star-shaped fixtures with no silent
  import, stores with no direction relationships, unknown relationship kinds,
  downgrade quarantine, and rollback without loss or inferred links.
- Instrument representative candidate/direction/Goal/evidence scales. Record
  device, OS, build, tool, cold/warm latency distributions, memory, energy, and
  storage; establish thresholds during grooming and fail regressions thereafter.

### Privacy, accessibility, and device evidence

- Executable egress tests inject every private field into URL, path, headers,
  body, cache key, log, telemetry, crash/support payload, Account, R2, Source
  Atlas, hosted-model, clipboard, Spotlight, and external projection attempts;
  each prohibited destination fails closed. Mixed public/private and derived
  sensitive-output cases are mandatory.
- Direct VoiceOver, Voice Control, Switch Control, Full Keyboard Access,
  Dynamic Type, increased contrast, Differentiate Without Color, Reduce
  Transparency, and Reduce Motion verification covers normal, no-duplicate,
  stale, blocked, partial, error, resume, and reversal states on a physical
  supported iPhone. Automated accessibility audits supplement but do not replace
  direct assistive-technology proof.
- Direct assistive-technology scripts verify the four duplicate actions remain
  separately named and reachable; each reads its object identities and exact
  consequence; open announces no change and restores row focus; relate reads
  explicit confirmation and `no Goal`, then focuses success or retry; refine
  focuses the invalidated outcome and review-needed announcement; and only
  continue-distinct exposes provisional-Goal confirmation.
- Device evidence must distinguish source/build/test success from rendered,
  interaction, accessibility, privacy, performance, and release proof.

## Open decisions

No unresolved product decision blocks grooming. These technical selections
remain for grooming and may not change the behavior above:

- the concrete Swift module/file split and storage table/event names for
  `DestinationDirectionV1` and `AdoptionReviewCheckpointV1`;
- whether compatible source-level North Star fixtures receive a read-only
  adapter before an explicit import tool exists;
- the mutation-registry rows and inverse-command availability for direction
  lifecycle, promotion lineage, and relationship removal; and
- calibrated candidate/evidence scale and device performance thresholds.

If implementation discovers that separate owner settlement cannot honestly
present the required partial results, or that a saved direction cannot be
modeled without Goal-like execution semantics, that is a product contradiction
and must return to Scope rather than being hidden in grooming.
