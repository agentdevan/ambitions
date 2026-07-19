+++
spec_id = "OBJECT-EVENT"
title = "Event"
kind = "object"
status = "normative"
owner_domain = "object-event"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.event.all-day-capacity", "object.event.identity-lifecycle", "object.event.multi-day", "object.event.recurrence-edit", "object.event.source-selection", "object.event.time-zone"]
inherits = ["OBJECT-TAXONOMY-001", "OBJECT-LIFECYCLE-DELETION-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "SURFACE-TIME", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/Time/", "Native/Ambitions/Core/LocalRuntimeOS/Transactions/", "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/", "Native/Ambitions/Core/LocalRuntimeOS/State/", "Native/Ambitions/Core/LocalRuntimeOS/Storage/", "Native/Ambitions/Core/LocalRuntimeOS/Projections/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
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

When an Apple Calendar item is imported into Ambitions Time, it MUST become an Ambitions-native Fixed Event by default.

An Event MUST occupy a time range.

Events MAY be all-day, multi-day, recurring, located, or attendee-bearing.

Events MUST remain time-range commitments with schedule placement, recurrence, attendees, location, alerts, and source metadata, and MUST be Fixed by default.

An Event MUST be a time-range commitment or occurrence.

## OBJ-EVENT-SOURCE-SELECTION-001 — Time creation keeps source visible
- **Concept:** `object.event.source-selection`
- **Modality:** `MUST`
- **Scope:** Event creation from Time
- **Status:** `normative`
- **Verification:** `SCENARIO-EVENT-SOURCE-SELECTION-001`
- **Supersedes:** none

An Event created from Time MUST default to the Ambitions-owned local source and expose an explicit source picker for eligible Apple Calendar calendars. Selecting an external source preserves preview, permission, local receipt, and external-result separation.

## OBJ-EVENT-ALL-DAY-CAPACITY-001 — All-day identity and capacity are separate
- **Concept:** `object.event.all-day-capacity`
- **Modality:** `MUST`
- **Scope:** Imported and native all-day Events
- **Status:** `normative`
- **Verification:** `SCENARIO-EVENT-ALL-DAY-CAPACITY-001`
- **Supersedes:** none

An all-day Event MUST remain one date-based Event shown in the all-day rail and chronological views. Import defaults it to Fixed without consuming hourly capacity; review exposes No capacity impact, Light context marker, Protected day, and Reduces available working time, and the selected effect remains editable.

All-day Events MUST NOT consume hourly capacity unless the user marks them Protected or blocking.

After import, an external calendar item MUST become an Ambitions-native Event and MUST default to Fixed.

## OBJ-EVENT-TIME-ZONE-001 — Explicit zone mode prevents silent shifts
- **Concept:** `object.event.time-zone`
- **Modality:** `MUST`
- **Scope:** Timed and all-day Event storage, display, edit, recurrence, and import
- **Status:** `normative`
- **Verification:** `SCENARIO-EVENT-TIME-ZONE-DST-001`
- **Supersedes:** none

A timed Event MUST store whether it is anchored to an event zone, floating local time, or following the device zone; an all-day Event remains date-based. Display uses the active view zone while Detail exposes the stored zone and original time. Zone changes preview results, and DST ambiguity or missing local time uses system calendar APIs and a Receipt for any visible change.

Explicit zone mode prevents silent shifts MUST preserve authored time-zone semantics.

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
Canonical value semantics belong to `Core/Domain/`; mutation, recurrence, placement, external reconciliation, and inspection belong to `Core/LocalRuntimeOS/Scheduling/`, `ExternalWrites/`, `Commands/`, and `Inspection/`; Time presents it and `Quality/` proves boundary, series exceptions, import/link, rollback, offline, privacy, and accessibility. Tests bind outcomes to stable Event identifiers;



## OBJ-EVENT-MULTI-DAY-001 — Multi-day Event identity

- **Concept:** `object.event.multi-day`
- **Modality:** `MUST`
- **Scope:** Multi-day Event identity
- **Status:** `normative`
- **Verification:** `REVIEW-OBJ-EVENT-MULTI-DAY-001`
- **Supersedes:** none

A multi-day Event MUST retain one identity across continuous Week and Month treatment, per-day Day portions, and one complete List range, and edit, recurrence, Receipt, source, deletion, and capacity consequences MUST operate on that identity.

## OBJ-EVENT-RECURRENCE-EDIT-001 — Recurring Event edit scope

- **Concept:** `object.event.recurrence-edit`
- **Modality:** `MUST`
- **Scope:** Recurring Event edit scope
- **Status:** `normative`
- **Verification:** `REVIEW-OBJ-EVENT-RECURRENCE-EDIT-001`
- **Supersedes:** none

Imported native recurring Events MUST support this occurrence, this and following, and entire series scopes, previewing affected occurrences, conflicts, reflow, Protected/Fixed consequences, and Receipt creation before commit.
