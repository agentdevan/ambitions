+++
spec_id = "OBJECT-STEP"
title = "Step"
kind = "object"
status = "normative"
owner_domain = "object-step"
canon_revision = 1
profile = "object-v1"
owns_concepts = [
  "object.step.identity-lifecycle",
  "object.boundary.recurrence",
  "object.boundary.conversion",
  "object.boundary.shared-metadata",
  "object.schedule-state.orthogonality",
  "object.recurrence.series-model",
  "object.lifecycle.semantic-separation",
  "object.lifecycle.conversion-deletion-restore",
  "object.substep.identity-scheduling",
  "object.goal-link.primary",
  "object.future-step.receipt",
]
inherits = ["OBJECT-FUTURE-STEP-IDENTITY-001", "OBJECT-PROOF-REQUIREMENT-001", "OBJECT-LIFECYCLE-DELETION-001", "OBJECT-REMINDER-COMPLETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL-PATH", "SURFACE-TODAY", "SURFACE-GOALS", "SURFACE-TIME", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Today/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
[object_boundary]
executable_completable = "Yes"
occupies_duration = "Optional"
consumes_capacity = "When scheduled"
due_date = "Yes"
recurrence = "Repeatable Step series"
substeps = "Yes"
goal_path_node = "Yes"
proof_requirement = "Optional/suggested/required"
attendees_rsvp = "No"
alerts = "Optional"
type_conversion = "Explicit, receipt-backed"
laws = { schedule_placement_nonduplication = "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001", future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001", reminder_acknowledgement_noncompletion = "OBJECT-REMINDER-COMPLETION-001", proof_receipt_separation = "OBJECT-PROOF-REQUIREMENT-001" }
+++

# Step

## OBJ-STEP-IDENTITY-001 — Executable unit of work

- **Concept:** `object.step.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Step semantic identity and execution
- **Status:** `normative`
- **Verification:** `SCENARIO-STEP-LIFECYCLE-001`
- **Supersedes:** none

A Step MUST be one executable unit of user work with optional primary Goal/Goal Path participation, Substeps, due date, Proof rule, recurrence series, and Schedule Placement relationship. Future Step is this same identity in a flexible future role/placement state, never a second record.

## OBJ-RECURRENCE-BOUNDARY-001 — Recurrence remains type-specific

- **Concept:** `object.boundary.recurrence`
- **Modality:** `MUST`
- **Scope:** Step, Event, Reminder, and Note recurrence
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-RECURRENCE-BOUNDARY-001`
- **Supersedes:** none

Recurrence MUST preserve distinct semantics: Steps use repeatable work series, Events use time-range series with exceptions, Reminders repeat notification intent, and Notes do not recur.

## OBJ-CONVERSION-LAW-001 — Explicit compatible conversion

- **Concept:** `object.boundary.conversion`
- **Modality:** `MUST`
- **Scope:** Step, Event, Reminder, Note, draft, and compatible object conversion
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-CONVERSION-001`
- **Supersedes:** none

Compatible conversion MUST show source/destination meaning, field-impact summary, capacity/time/proof/recurrence consequences, relationship and attachment handling, retained/retired identity lineage, rollback, and explicit confirmation. Acceptance uses the runtime mutation sequence and a Receipt; Note becomes executable only through explicit promotion.

## OBJ-TYPE-BOUNDARY-001 — Shared metadata does not erase type

- **Concept:** `object.boundary.shared-metadata`
- **Modality:** `MUST NOT`
- **Scope:** Canonical object taxonomy
- **Status:** `normative`
- **Verification:** `AUDIT-OBJECT-TYPE-BOUNDARY-001`
- **Supersedes:** none

Shared attachments, tags, alerts, Source References, notes, locations, dates, or Goal links MUST NOT erase the Step/Event/Reminder/Note boundary or promote a role, projection, or implementation type into a new canonical object.

## OBJ-SCHEDULE-STATE-001 — Placement is orthogonal

- **Concept:** `object.schedule-state.orthogonality`
- **Modality:** `MUST`
- **Scope:** Object lifecycle, time, and Schedule Placement
- **Status:** `normative`
- **Verification:** `SCENARIO-SCHEDULE-PLACEMENT-ORTHOGONAL-001`
- **Supersedes:** none

Schedule state MUST remain orthogonal to object type, lifecycle, execution, proof, and recovery. Scheduling creates or changes a Schedule Placement relationship; it never copies or converts the object implicitly.

## OBJ-RECURRENCE-SERIES-001 — Series identity and occurrence scope

- **Concept:** `object.recurrence.series-model`
- **Modality:** `MUST`
- **Scope:** Supported recurring object families
- **Status:** `normative`
- **Verification:** `SCENARIO-RECURRENCE-SCOPE-001`
- **Supersedes:** none

Recurrence MUST use one series identity with occurrence projections and exceptions. Mutations declare occurrence-only, this-and-future, entire-series, or selected-import-range scope and preserve unaffected occurrences, lineage, receipts, replay, and rollback.

## OBJ-LIFECYCLE-SEPARATION-001 — Completion is not deletion

- **Concept:** `object.lifecycle.semantic-separation`
- **Modality:** `MUST NOT`
- **Scope:** Completion, closure, archive, Trash, and permanent deletion
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-DELETION-001`
- **Supersedes:** none

Completion MUST NOT mean deletion; Closure MUST NOT mean archive; archive MUST NOT mean Trash or permanent deletion. Each operation retains its own consequence, history, planning influence, restore, and rollback semantics.

## OBJ-DELETION-RESTORE-001 — Preserve lineage through conversion and deletion

- **Concept:** `object.lifecycle.conversion-deletion-restore`
- **Modality:** `MUST`
- **Scope:** Conversion, Trash, restore, and permanent deletion
- **Status:** `normative`
- **Verification:** `SCENARIO-OBJECT-DELETION-001`, `SCENARIO-OBJECT-CONVERSION-001`
- **Supersedes:** none

Conversion MUST preserve or explicitly retire identity lineage, source, attachments, relationships, Proof, recurrence scope, and Receipt. Supported soft deletion moves to Trash; restore creates history and revalidates projections; permanent deletion confirms exact object/series/dependent/history/search/export scope, irreversibility, rollback limit, and tombstone handling only if an approved continuity system exists.

## OBJ-SUBSTEP-IDENTITY-001 — Substep stays subordinate

- **Concept:** `object.substep.identity-scheduling`
- **Modality:** `MUST NOT`
- **Scope:** Substep identity and scheduling
- **Status:** `normative`
- **Verification:** `SCENARIO-SUBSTEP-PROMOTION-001`
- **Supersedes:** none

A Substep MUST NOT be independently scheduled or treated as a top-level canonical Step until explicit promotion previews identity, parent relationship, placement/capacity, due date, proof, and recurrence consequences and commits through a Receipt-backed command.

## OBJ-GOAL-LINK-001 — Primary Goal without type collapse

- **Concept:** `object.goal-link.primary`
- **Modality:** `MAY`
- **Scope:** Goal relationships for Step, Event, and Reminder
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-LINK-BOUNDARY-001`
- **Supersedes:** none

A Step MAY have one primary Goal/Path participation. Events and Reminders may link to Goals contextually without becoming Goal-owned Steps or inheriting executable/completion semantics.

## OBJ-FUTURE-STEP-RECEIPT-001 — Future Step changes preserve one lineage

- **Concept:** `object.future-step.receipt`
- **Modality:** `MUST`
- **Scope:** Future Step path or placement changes
- **Status:** `normative`
- **Verification:** `SCENARIO-FUTURE-STEP-IDENTITY-001`
- **Supersedes:** none

A path- or placement-affecting Future Step change MUST mutate the same Step identity and produce a Receipt/History Event. Near/far horizon changes may differ in preview depth, but never in identity, mutation owner, or replay lineage.

<!-- canon-section: stable-identity -->
Step identity survives editing, scheduling, start, waiting/blocking, completion, closure, recurrence occurrence projection, Future Step horizon changes, archive, Trash, restore, and compatible conversion lineage.

<!-- canon-section: user-meaning -->
A Step is work the user can actually do. It is distinct from an Event commitment, Reminder notification intent, Note information, Schedule Placement relationship, Closure outcome, Proof evidence, and automatic Receipt.

<!-- canon-section: relationships -->
It may have one primary Goal/Path, parent/child Substeps, one recurrence series, multiple occurrence projections, placements, Proof, Closure, notification rules, attachments, sources, recovery, Receipts, and History Events. Relationships reference IDs and never copy identity.

<!-- canon-section: lifecycle -->
Lifecycle is Draft, Ready, Active, Completed, Archived, Trashed, restored, or permanently deleted. Scheduled is placement; Started is execution; Waiting/Blocked are execution/recovery; Future is horizon/placement role. These axes remain orthogonal.

Each axis changes only through its owning typed command and records the affected axis explicitly.

<!-- canon-section: valid-transitions -->
Valid transitions include Draft→Ready; Ready/Active→started execution; active execution↔Waiting/Blocked; active→Completed through honest closure and predeclared Proof rule; live→Archived; supported live→Trash; Trash→prior valid state; recurrence changes at explicit scope; and compatible conversion through preview/receipt.

<!-- canon-section: invalid-transitions -->
Invalid transitions include Event-style attendance completing a Step, Reminder acknowledgement completing work, Note edit creating execution, Schedule Placement creating a duplicate Step, surprise required Proof at completion, Future Step copy identity, Substep independent scheduling before promotion, or recurrence mutation without scope.

Validation rejects each path before commit and retains the last accepted Step state.

<!-- canon-section: commands -->
Create, edit, link Goal, add/promote Substep, schedule/reflow, start, wait, block, resume, complete/close, attach Proof, recur/edit occurrence, convert, archive, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay`; rejected commands preserve last honest state and issue inspectable rejection lineage.

<!-- canon-section: recurrence-scheduling -->
Step recurrence uses one series plus occurrences/exceptions and explicit scope. Duration is an optional estimate; capacity is consumed only through a Schedule Placement. Due date is optional and distinct from placement. Future Step uses a flexible future placement window on the same Step.

<!-- canon-section: deletion-trash-restore-archive -->
Archive removes ordinary planning influence without erasing completion/history. Trash preserves recoverable identity, series, placement, proof, and relationships. Restore repairs projections/placements; permanent deletion confirms recurrence and dependent data scope and states irreversible limits.

<!-- canon-section: history-receipts -->
Meaningful mutations record actor/source, before/after facts, affected relationships/occurrences/placements, accepted/rejected result, rollback target, automatic Receipt, and replay outcome. User Proof remains distinct and never validates the runtime mutation by itself.

<!-- canon-section: privacy-sync-classification -->
Step content, Goal/path links, due dates, placements, Proof, recovery, and behavior are private local graph data. Account/R2/Source Atlas never receive them. Future approved continuity must retain local authority, conflict/recurrence/deletion semantics, and explicit consent.

Every egress-capable command exposes its data scope and preserves a local authoritative record.

<!-- canon-section: import-export -->
Imported tasks/reminders/events remain candidates or their native types until explicit conversion. Export is scoped and previewed. Re-import uses Source Reference and Import/Diff lineage to reconcile rather than duplicate or silently change type.

<!-- canon-section: projection-surfaces -->
Today projects executable fit, Goals projects path participation, Time projects Schedule Placement, Search/Trust inspect identity/history, and widgets/App Intents act through canonical commands. Every projection retains the Step ID.

<!-- canon-section: accessibility -->
Semantics expose executable state, lifecycle, placement/time, due date, recurrence scope, proof rule, Goal/parent relation, recovery, consequence, and actions without color, drag, timeline position, or animation dependence; alternatives exist for schedule/reorder/series scope.

<!-- canon-section: source-test-ownership -->
Canonical target ownership is `Core/Domain/` and `Core/LocalRuntimeOS/Planning/`, `Scheduling/`, `Commands/`, and `Inspection/`; Today/Goals/Time present projections and `Quality/` proves boundary matrix, axes, Future Step singularity, recurrence scope, conversion, Proof/Receipt separation, Reminder noncompletion, Trash/restore, replay, offline, privacy, and accessibility. Current source compliance is unclaimed.

Tests resolve every action and expected event to the stable Step, series, placement, and lineage identifiers.
