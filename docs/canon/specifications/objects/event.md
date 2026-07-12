+++
spec_id = "OBJECT-EVENT"
title = "Event"
kind = "object"
status = "normative"
owner_domain = "object-event"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.event.identity-lifecycle"]
inherits = ["OBJECT-TAXONOMY-001", "OBJECT-LIFECYCLE-DELETION-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "SURFACE-TIME", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
[object_boundary]
executable_completable = "No"
occupies_duration = "Required for timed event"
consumes_capacity = "Yes according to blocking state"
due_date = "End time is not a due date"
recurrence = "Event series + exceptions"
substeps = "No"
goal_path_node = "May be contextual"
proof_requirement = "Normally no"
attendees_rsvp = "Yes"
alerts = "Optional"
type_conversion = "Explicit, receipt-backed"
laws = { schedule_placement_nonduplication = "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001", future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001", reminder_acknowledgement_noncompletion = "OBJECT-REMINDER-COMPLETION-001", proof_receipt_separation = "OBJECT-PROOF-REQUIREMENT-001" }
+++

# Event

## OBJ-EVENT-IDENTITY-001 — Time-range commitment

- **Concept:** `object.event.identity-lifecycle`
- **Modality:** `MUST NOT`
- **Scope:** Event identity, time commitment, and completion boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-EVENT-BOUNDARY-001`
- **Supersedes:** none

An Event is one fixed-by-default time-range commitment with recurrence, attendees, location, alerts, source, and Schedule Placement. It MUST NOT be completed like a Step; occurrence elapsed/cancelled/attended state never fabricates user-work completion.

<!-- canon-section: stable-identity -->
Event and recurring-series identities survive edit, move, exception, cancellation, archive, Trash, restore, import reconciliation, and projection changes. Stable identifiers bind occurrences to their series.

<!-- canon-section: user-meaning -->
An Event represents committed time, attendance, or a calendar fact; it is distinct from executable work, notification intent, and non-executable information. Time-range semantics define the object.

<!-- canon-section: relationships -->
It may link contextually to a Goal, Step, attendees, location, notification rules, Source Reference, Import/Diff Record, attachments, placement, Receipts, and History Events without inheriting Step completion. Relationships retain canonical identifiers.

<!-- canon-section: lifecycle -->
Lifecycle is active, cancelled, archived, Trashed, restored, or permanently deleted; elapsed and attended are occurrence/time facts, while imported/linked/external are source axes. Typed axes record each fact separately.

<!-- canon-section: valid-transitions -->
Valid transitions include create→active, active↔rescheduled placement, active→cancelled, active/cancelled→archived, supported states→Trash, Trash→prior valid state, scoped recurrence edits, and explicit compatible conversion. Accepted transitions retain prior facts.

<!-- canon-section: invalid-transitions -->
Invalid transitions include Event→completed Step state, attendee response completing work, time movement changing lifecycle, importing an external item as an Event without approval, recurrence edit without scope, or placement copy identity. Validators reject prohibited transitions before persistence.

<!-- canon-section: commands -->
Create, edit range, place/reflow, change attendees/location/alerts, edit recurrence/exception, cancel, archive, convert, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay` with material preview and rollback. Typed commands preserve source and series identifiers.

<!-- canon-section: recurrence-scheduling -->
An Event requires a time range and consumes capacity through its Schedule Placement; due date and Substeps do not apply. Recurrence uses one series with occurrence exceptions and explicit occurrence/future/series/import-range scope. Occurrence scope is recorded on the command.

<!-- canon-section: deletion-trash-restore-archive -->
Cancel, archive, Trash, and permanent deletion are distinct. Restore repairs series/placement projections; deletion confirms occurrence/series, attendee, external-write, history/search, export, and approved-continuity scope. Rollback preserves the last accepted calendar fact.

<!-- canon-section: history-receipts -->
Material time, recurrence, attendee, source, conversion, cancellation, Trash, restore, and external-effect changes create automatic Receipts and before/after History Events, including pending/reconciled external state. Inspection binds each record to Event and occurrence identifiers.

<!-- canon-section: privacy-sync-classification -->
Titles, ranges, attendees, locations, notes, and Goal links are private local graph data; Account and R2 never receive them. External calendar access uses minimum necessary scope, explicit permission, source lineage, and local authority. Classification is inspectable.

<!-- canon-section: import-export -->
External items remain privacy-filtered capacity facts or import candidates until reviewed as a native Event/link; re-import reconciles Source Reference and Import/Diff lineage. Export/writeback is previewed and tracks local acceptance separately from external result.

<!-- canon-section: projection-surfaces -->
Time owns primary Event presentation; Today may show execution-relevant context, Goals may show contextual links, and Search/Trust inspect it. Every actionable projection retains Event/series/occurrence IDs and routes commands canonically.

<!-- canon-section: accessibility -->
Semantics expose title, range/time zone, fixed/flexible state, recurrence scope, attendees, location, alerts, source, conflict, consequence, and actions with non-drag alternatives. Ordered controls state each affected occurrence scope.

<!-- canon-section: source-test-ownership -->
Canonical value semantics belong to `Core/Domain/`; mutation, recurrence, placement, external reconciliation, and inspection belong to `Core/LocalRuntimeOS/Scheduling/`, `ExternalWrites/`, `Commands/`, and `Inspection/`; Time presents it and `Quality/` proves boundary, series exceptions, import/link, rollback, offline, privacy, and accessibility. Tests bind outcomes to stable Event identifiers; current implementation compliance is unclaimed.
