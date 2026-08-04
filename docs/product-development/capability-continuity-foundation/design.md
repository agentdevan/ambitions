+++
initiative = "capability-continuity-foundation"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Capability continuity is implemented as a new canonical, private local object
family projected inside You > Life Capital. A confirmed `CapabilityRecord`
owns the user's name and meaning, lifecycle, privacy classification, default-off
future-use permission, and references to independently governed evidence. It is
not a Proof subtype, learned preference, public taxonomy node, or planning
input. No current feature consumes it.

Local Learning may produce a review candidate only from the exact accepted
evidence and explicit wording allowed by Scope. The candidate remains a
separate `CapabilityProposalRecord` with no canonical Capability identity or
planning influence until confirmation. Confirmation routes through the
canonical capability mutation owner and preserves user-stated, practiced, and
Proof-linked facets as independent explanations rather than levels.

The experience has two calm entry points: persistent inspection and manual
entry in You > Life Capital, and one proposal card embedded in an already-open
Goal review, closure, ending, known-pivot, or Life Capital inspection. It adds
no root destination, score, badge, automatic Goal mutation, recommendation,
path, or Time behavior.

## User flows

### Inspect or manually add a capability

1. The user opens You, chooses Life Capital, then Capabilities. The collection
   opens with a concise collection-level notice: these are private, user-owned
   interpretations and no current feature uses them to change planning.
2. The active collection lists the capability name, plain-language meaning,
   provenance summary, evidence-review state, lifecycle, and future-use state.
   It contains no aggregate total, progress ring, level, rank, or comparative
   ordering. Archived and Trash collections are separate explicit filters.
3. `Add Capability` opens a local editor for name, meaning, and optional
   context. Saving creates a user-stated capability with future use off. No
   evidence is required and no evidence facet is fabricated.
4. Detail shows, in order, meaning; user-stated/practiced/Proof-linked
   explanations; exact evidence relationships; uncertainty or stale/conflict
   notices; privacy handling; future-use permission; current consumers; and
   lifecycle controls. In this increment current consumers is the one honest
   collection-level no-consumer statement, not repeated promotional copy.
5. Edit changes only the capability-side name, meaning, context, privacy, or
   relationship interpretation. A relationship can be removed without editing
   its Goal, Step, History, or Proof source.

### Review a system proposal

1. Local Learning observes an accepted eligible practice or Proof relationship
   and evaluates the exact user-authored wording, source availability,
   contradiction state, privacy classification, existing confirmed/pending
   basis, and retained Not-this fingerprint.
2. If a named capability is not supportable, the owning surface may show only
   `What did you practice or learn?`; the user can enter their own wording or
   leave. Sensitive, contradictory, weak, unavailable, or duplicate evidence
   produces no named proposal.
3. An eligible proposal is queued for the next associated calm surface. It
   never interrupts the completion control. If no associated review occurs,
   the card waits for the next user-opened Capabilities collection.
4. The card shows proposed meaning, why it appeared, exact evidence,
   uncertainty, future-use-off, and the no-current-consumer boundary. The
   actions are `Confirm`, `Edit`, `Not now`, and `Not this`.
5. `Not now` leaves the proposal pending for a later review. `Not this` stores
   only a content-minimized basis fingerprint and dismissal state. Neither
   creates a Capability or influence. A later unchanged observation, relaunch,
   or elapsed time cannot re-present it.
6. `Edit` revalidates evidence against the edited meaning before confirmation.
   Unsupported practiced or Proof-linked facets are removed from the preview;
   the user can save the edited text as user-stated, choose other evidence, or
   cancel. `Confirm` atomically creates the user-owned Capability, settles the
   proposal, and emits truthful History and Receipt records.

### Accumulate evidence without silent merging

1. When eligible evidence could relate to a confirmed Capability, the review
   presents the existing Capability and the new evidence side by side in a
   verbal, stacked comparison.
2. The user chooses `Add to this capability`, `Keep separate`, or `Create a new
   capability`. Label similarity never preselects or hides an option.
3. Adding creates one capability-side relationship and preserves both source
   objects. Removing it deletes only that relationship. Any consumers would be
   listed and re-evaluated, but this increment has none.

### Manage suggestion learning

1. Learning controls list pending proposals and remembered Not-this
   dismissals using content-minimized explanations and stable identities.
2. The user may remove one retained state or choose `Reset suggestions`.
3. Reset preview states that confirmed Capabilities, evidence links, explicit
   settings, and source History stay unchanged. Confirming reset clears only
   pending and Not-this states and records the mutation.
4. Unchanged evidence becomes eligible again only after the user explicitly
   requests reconsideration from a later Life Capital inspection; reset does
   not immediately display cards elsewhere.

### Archive, Trash, restore, and permanently delete

1. Archive preview says the record leaves the active collection, stops any
   future influence, preserves its content and relationships, and can be
   restored. Restore returns it to its prior valid active state, leaving future
   permission as the last explicit setting.
2. Move to Trash preview says the record leaves regular views and influence but
   remains exactly recoverable. Restore from Trash reinstates the last valid
   live state and relationships that are still valid.
3. Permanent deletion is available only from Trash. Consequence review names
   the capability content, derived interpretation, evidence relationships, and
   future influence that will be removed; source Goals, Steps, Proof, Receipts,
   and History remain governed by their owners.
4. Confirmation removes reconstructable Capability content and leaves only a
   stable, disclosed deletion tombstone containing integrity identifiers and
   deletion facts, never name, meaning, evidence context, or searchable text.
   The result clearly states that restoration is unavailable.

### Reconcile source lifecycle

- Source archive preserves an available relationship. Source Trash makes the
  relationship unavailable/recoverable and blocks new proposal use. Restore
  restores it if the source revision remains valid.
- Source correction, unlink, governed redaction, or permanent deletion updates
  the capability-side relationship to missing, redacted, contradicted, or
  needs-review without retaining removed source content. The confirmed
  Capability stays intact unless separately changed by the user.
- Ending, completing, archiving, or changing the originating Goal does not
  remove or downgrade the Capability.

## States and recovery

### Visible collection and record states

- **Empty active collection:** explains Capabilities in plain language, offers
  `Add Capability`, and repeats the one no-current-consumer disclosure.
- **Active:** inspectable and editable; future use is independently on or off.
- **Needs evidence review:** the capability remains user-owned while one or
  more evidence relationships are stale, contradicted, redacted, or missing.
- **Protected local record:** visible to the user, classified as protected, and
  locked out of future use. A false-positive correction is available; genuine
  protected content cannot be enabled in this increment.
- **Archived:** absent from the active collection, inspectable under Archived,
  no influence, restorable.
- **Trashed:** absent from ordinary and archived lists, inspectable under
  Trash, no influence, restorable or permanently deletable.
- **Deleted tombstone:** not shown as a Capability; visible only through the
  relevant deletion History/Receipt explanation and contains no recoverable
  content.

### Proposal and learning states

- **Ineligible/quiet:** no visible proposal and no diagnostic containing
  private evidence values.
- **Neutral reflection available:** no inferred name; manual text only.
- **Pending/unpresented:** eligible and waiting for the deterministic next calm
  moment.
- **Presented:** exact proposal revision is on screen; no Capability exists.
- **Not now:** pending for later and non-influential.
- **Not this:** content-minimized dismissal retained for that basis.
- **Needs revalidation:** source, classification, or evidence changed before
  confirmation; refresh the card and require review of the new basis.
- **Settled:** confirmed into a Capability or removed/reset; cannot present
  again under the old basis.

### Failure and recovery

- Stale proposal revision, changed source, changed privacy classification, or
  duplicate settlement rejects confirmation before mutation. The card explains
  what changed and offers `Review updated proposal`, `Save as user-stated`, or
  cancel as applicable.
- Command, storage, projection, or Receipt failure preserves the prior
  canonical state and the local draft. Retry uses the same idempotency key;
  false success is forbidden.
- A concurrent edit uses revision comparison. Non-overlapping source-lifecycle
  reconciliation may be replayed after the user's current edit; conflicting
  meaning/evidence edits require a fresh combined review and never last-write-
  win silently.
- Reset, archive, Trash, restore, and permission-change interruption resume at
  the last committed boundary with the same consequence summary. Permanent
  deletion cannot report success until content removal, projection rebuild,
  tombstone persistence, Receipt, and replay checks all succeed.
- After success focus returns to the affected record or collection result. On
  rejection it returns to the invalid field or recovery action. Cancellation
  returns to the initiating control with no mutation.

## Architecture and data

### Ownership and affected components

- **Domain:** introduce the canonical `CapabilityRecord`,
  `CapabilityEvidenceRelationship`, `CapabilityLifecycle`,
  `CapabilityFutureUseState`, and content-free `CapabilityDeletionTombstone`.
  These are private object semantics; `ProofResourceGraphModels` and public
  Source Atlas capability graphs are not reused as the canonical identity.
- **Local Learning:** add a deterministic `CapabilityProposalPolicy` and
  proposal/dismissal repository. It consumes accepted local observation
  envelopes and emits proposal candidates or a typed quiet reason. It cannot
  write Capability records.
- **Commands/Transactions:** add one `CapabilityCommandService` handling create,
  confirm, edit, attach/detach evidence, permission, archive, Trash, restore,
  permanent delete, Not now, Not this, reset, and explicit reconsideration.
  Every durable action follows Command -> Event -> Projection -> Receipt ->
  Replay in one local transaction boundary.
- **Projections:** add `CapabilityCollectionProjection` for You/Life Capital,
  `CapabilityProposalProjection` for calm Goal/Life Capital hosts, and
  capability inspection/history projections. Goals and You remain presentation
  owners, not mutation owners.
- **Privacy/Inspection:** classify both proposed output and linked context
  before a named proposal is stored or shown; expose handling and lineage with
  redacted diagnostics.

### Canonical data contracts

`CapabilityRecord` carries stable ID, schema/revision, created/updated time,
name, plain-language meaning, optional relevant context, lifecycle and prior
valid lifecycle, privacy classification, future-use permission, creation kind,
relationship IDs, and consumer bindings. Consumer bindings are empty in this
increment. It stores no level, score, public taxonomy identity, credential,
personality inference, or source-object content copy.

`CapabilityEvidenceRelationship` carries its own stable ID and revision,
Capability ID, typed source reference, source revision/fingerprint, relation
kind (`practiced` or `proofLinked`), user-approved context, dates, freshness,
availability/contradiction/redaction state, and lineage IDs. Provenance facets
are derived from current relationships plus the user's confirmed/manual claim;
they are not an ordered enum.

`CapabilityProposalRecord` carries proposal ID/revision, normalized proposed
name and meaning, exact source references, evidence-basis fingerprint,
eligibility event, presentation host, proposed relationship kinds, uncertainty,
output/context privacy decision, status, presented count, material-evidence
revision, and no canonical Capability ID until settlement. `NotThisRecord`
retains only the basis fingerprint, policy version, timestamps, and reconsidered
state; it cannot reconstruct sensitive source text.

Events and Receipts store operation, affected stable IDs, before/after
lifecycle or permission state, relationship consequences, privacy category,
consumer impact count, recovery/undo availability, and redacted summaries.
Permanent-deletion events replace content-bearing event projections with the
governed content-free deletion fact required by canon; immutable source-object
history remains in those source owners.

### Data flow and deterministic policy

1. Source owners publish accepted observation envelopes with stable source ID,
   revision, event kind, user-authored capability-bearing text locator, Proof
   relationship if any, availability, contradiction, and privacy class.
2. Proposal policy verifies allowed event kind, explicit naming support,
   accepted state, source availability, output/context classification, and the
   deduplication key `(source IDs + source revisions + normalized meaning +
   policy version)`.
3. Eligible proposals persist locally and are projected only to the calculated
   next calm host. Ineligible sensitive output produces no named proposal
   record; local redacted diagnostics may retain only category and policy code.
4. User action compiles a typed command with expected proposal/Capability and
   source revisions. The command transaction appends semantic event, updates
   canonical state and projections, creates Receipt/History, then validates
   replay equivalence.
5. Source lifecycle events enqueue idempotent relationship reconciliation by
   stable source identity. They never mutate the source and never delete the
   Capability automatically.

### Persistence, migration, concurrency, and replay

- Add versioned local stores for Capability records, evidence relationships,
  proposal controls, and deletion tombstones under the canonical runtime
  persistence owner. Public/reference caches never contain them.
- The initial migration creates empty stores and projection schema only. It
  performs no inference or backfill from existing Goals, Proof, History,
  Source Atlas graphs, or user profile data. Therefore no historical work can
  silently become a Capability.
- Migration is idempotent, crash-resumable, checksum/invariant verified, and
  preserves a readable rollback point. Unsupported/corrupt records quarantine
  with redacted diagnosis rather than being deleted.
- All commands carry command ID/idempotency key, object ID, expected revision,
  policy/schema revision, and relevant source fingerprints. Store writes and
  event/Receipt linkage are atomic. Equal-order conflicts use causal command
  order, never timestamp-only last-write-wins.
- Replay from events must reproduce collection membership, proposal/dismissal
  state, relationship availability, privacy/future-use state, and content-free
  tombstones without re-running inference or issuing external effects.
- Projection rebuild may reread canonical local records but cannot fetch public
  data, reinterpret old evidence under a new policy, or re-present a settled
  proposal. A new policy acts only through a separately accepted new basis or
  explicit reconsideration.

## Privacy and accessibility

All records, proposals, evidence links, corrections, settings, History,
Receipts, and diagnostics are private local graph data. They work without an
account or network and are denied to Account, R2, Source Atlas, hosted AI,
telemetry, external profiles, and public cache/request paths. No proposal text,
source identity, capability ID, deduplication fingerprint derived from private
data, or consumer history may influence a network request, log, cache key, or
feedback payload.

Classification occurs twice: the source observation is checked before policy,
then the proposed/manual output and linked context are checked before storage,
display, or enabling future use. Unknown or protected derived output fails
quiet for proposals. A manual protected record remains visible locally with a
plain explanation and future use locked. False-positive correction reruns the
same deterministic classification policy; it cannot override a genuinely
protected result by assertion alone. Diagnostics contain typed reason codes and
correlation IDs, never capability/evidence text.

The collection and every review use native headings, lists, disclosure groups,
forms, toggles, alerts, and buttons with a stable semantic order. VoiceOver
reads capability identity and meaning before provenance, uncertainty, privacy,
future-use state, lifecycle, and actions. Evidence relationships are verbalized
as source name/type, date, relation, and availability; no graph or color is
required. Every action has a unique accessible label containing the affected
Capability and consequence.

Voice Control, Switch Control, Full Keyboard Access, and hardware keyboard can
reach manual entry, proposal decisions, evidence choices, correction,
permission, reset, archive, Trash, restore, and deletion without gesture.
Dynamic Type stacks comparisons and consequence previews without truncation;
Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color, RTL,
Reduce Motion, and Reduce Transparency preserve all states. Sensitive content
uses the owning locked-device/screen-capture policy. Status changes are
announced once; modal focus is contained; success, cancellation, error, and
recovery use stable focus IDs.

## Requirement traceability

| Scope requirement | Design decisions |
| --- | --- |
| REQ-001 | Canonical `CapabilityRecord`; You > Life Capital collection; confirmed/manual ownership boundary; no root dashboard. |
| REQ-002 | Manual `Add Capability` flow creates a user-stated record with no evidence prerequisite. |
| REQ-003 | Accepted observation envelope, explicit-wording policy, exact basis fingerprint, neutral reflection fallback, quiet sensitive/weak/conflicted path, at-most-once host selection. |
| REQ-004 | Separate non-authoritative proposal store; calm host projections; Confirm/Edit/Not now/Not this; edited-meaning evidence revalidation. |
| REQ-005 | Independent user-stated, practiced, and Proof-linked explanations derived from relationships; no ordered level or score. |
| REQ-006 | Stable evidence-relationship objects; explicit accumulate/keep-separate/create-new choice; source lifecycle reconciler; correction affects only declared consumers. |
| REQ-007 | Distinct proposal-control, reset, archive, Trash, restore, and deletion commands and state machines; content-minimized dismissal and tombstone. |
| REQ-008 | Capability identity is independent of Goal lifecycle; source Goal state updates relationship availability only where Scope requires. |
| REQ-009 | No time-based Capability mutation; freshness and contradiction live on evidence relationships. |
| REQ-010 | Default-off future-use state, empty consumer bindings, collection-level no-consumer disclosure, no planning interface in this increment. |
| REQ-011 | Separate IDs/types for Capability, evidence, Proof, credential, requirement, resource, interest, and eligibility; no label-based merge. |
| REQ-012 | Output-plus-context classification, protected manual state, local stores, prohibited-egress enforcement, redacted diagnostics. |
| REQ-013 | Calm copy and qualitative facets; schema and projections contain no score/rank/level/XP/personality field. |
| REQ-014 | Capability-only command owner and transaction write set; source references are read-only; adjacency invariant tests. |
| REQ-015 | Command/Event/Projection/Receipt/Replay, revision/idempotency checks, precise consequence previews, deterministic restore, deletion boundary. |
| REQ-016 | Semantic order, named controls, assistive input equivalence, reflow/reduced-effects/non-color behavior, focus and announcements, direct-device matrix. |

## Verification design

| Lane | Required evidence |
| --- | --- |
| Domain/unit | Capability identity and lifecycle transitions; independent provenance facets; no score fields; proposal eligibility/ineligibility table; exact explicit-wording and neutral-reflection fixtures; materially-new-evidence and at-most-once deduplication; evidence accumulation choices; source lifecycle matrix; privacy classification. |
| Command/integration | Every durable action follows one local atomic Command/Event/Projection/Receipt/Replay chain; stale revision, duplicate command, cancellation, interruption, projection failure, and idempotent retry; permanent deletion leaves only the permitted tombstone. |
| Adjacency | Snapshot Goal, North Star, Goal Path, Life Branch, Step, Proof, schedule, destination, and completion state before every Capability action and prove byte/semantic equality afterward. |
| Migration/replay | Empty-store migration with no historical backfill; every supported schema upgrade and crash point; rollback/quarantine; projection deletion and rebuild; repeated replay equivalence; source-deletion/redaction replay without content resurrection. |
| Privacy/security | Offline/no-account scenarios; exhaustive destination-denial tests; derived protected output and unknown classification fail quiet; manual protected record future-use lock; false-positive correction; logs/snapshots/diagnostics/search/index/export surfaces contain no prohibited payload; content-free tombstone non-reconstruction. |
| UI/runtime | Manual create/edit/inspect; calm closure and Life Capital proposal hosts; Not now/Not this/reset; multi-Goal accumulation; archive/Trash/restore/delete; stale/conflicted/missing evidence; empty and failure recovery; no interruption at Step completion. |
| Accessibility | Direct VoiceOver order/actions and announcements, Voice Control, Switch Control, Full Keyboard Access/hardware keyboard, Dynamic Type through accessibility sizes, Bold Text, Button Shapes, Increase Contrast, Differentiate Without Color, Reduce Motion/Transparency, RTL, focus on success/cancel/reject/recovery, and sensitive locked-device behavior. |
| Performance/resource | Measure active/archived/Trash collection projection, proposal evaluation, source reconciliation, migration, and replay using representative small/large evidence counts on named device/OS/build. Grooming sets percentile, maximum, memory, energy, storage, and regression budgets from the measurements; all material work is bounded, cancellable, and off-main. |
| Build/static | Regenerate the Xcode project from `project.yml` for added files; compile affected app/test targets; run SwiftLint, static analysis, secrets/privacy scans, `git diff --check`, canon check after owning canon changes, and the changed-scope Code Quality lane. |

## Open decisions

No unresolved product decision remains. Grooming must resolve only these
technical choices without changing behavior:

- the exact Swift persistence records/indexes and event payload versioning for
  Capability, relationship, proposal-control, and tombstone state;
- whether source-lifecycle reconciliation is performed in the source command's
  local transaction or by a causally linked idempotent follow-up transaction;
- exact SwiftUI file decomposition and stable focus-ID naming within existing
  Goals and You surface owners; and
- measured performance/storage budgets and fixture scale.

If implementation cannot make deletion non-reconstructable while preserving
the required deterministic integrity tombstone, or cannot classify derived
output before proposal persistence, that is a Design blocker and must not be
resolved by weakening Scope.
