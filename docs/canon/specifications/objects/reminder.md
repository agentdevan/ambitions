+++
spec_id = "OBJECT-REMINDER"
title = "Reminder"
kind = "object"
status = "normative"
owner_domain = "object-reminder"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.reminder.identity-capacity", "object.reminder.replacement-target"]
inherits = ["OBJECT-REMINDER-COMPLETION-001", "OBJECT-LIFECYCLE-DELETION-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "SURFACE-TODAY", "SURFACE-TIME", "APP-PERMISSIONS"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Today/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
[object_boundary]
executable_completable = "No, unless linked to Step"
occupies_duration = "No"
consumes_capacity = "No"
due_date = "Optional reminder date"
recurrence = "Reminder repetition"
substeps = "No"
goal_path_node = "May support a Step"
proof_requirement = "No"
attendees_rsvp = "No"
alerts = "Core capability"
type_conversion = "Explicit, receipt-backed"
laws = { schedule_placement_nonduplication = "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001", future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001", reminder_acknowledgement_noncompletion = "OBJECT-REMINDER-COMPLETION-001", proof_receipt_separation = "OBJECT-PROOF-REQUIREMENT-001" }
+++

# Reminder

## OBJ-REMINDER-IDENTITY-001 — Notification intent without independent capacity

- **Concept:** `object.reminder.identity-capacity`
- **Modality:** `MUST NOT`
- **Scope:** Reminder identity, capacity, acknowledgement, and linked work
- **Status:** `normative`
- **Verification:** `SCENARIO-REMINDER-COMPLETION-001`
- **Supersedes:** none

A Reminder is one notification intent that may link to a Step, Event, or Goal and may carry time/location triggers. It MUST NOT consume capacity independently or complete user work; linkage preserves the capacity and completion authority of the linked object.

A Reminder MUST represent notification intent.

Reminders MUST remain notification intents and MAY link to a Step, Event, or Goal with optional date, time, or location metadata.

An empty Time slot MUST support tap or long-press creation of an Event, Step, or Reminder with date and time prefilled.

A Reminder MAY carry date, time, location, recurrence, urgency, notes, and notification rules.

Imported alerts MAY become Ambitions-native notification rules on the Event, not separate Reminders.

A Reminder MUST be a return point that asks the user to remember or act.

<!-- canon-section: stable-identity -->
Reminder identity survives trigger edits, delivery, snooze, dismissal, acknowledgement, recurrence, archive, Trash, restore, conversion, and linked-object changes. Delivery instances reference the canonical Reminder/series.

<!-- canon-section: user-meaning -->
A Reminder helps the user remember or notice something; it is not executable work, a time-range commitment, a Note, a Schedule Placement, or Proof. Notification intent defines the object.

<!-- canon-section: relationships -->
It may link contextually to a Step, Event, Goal, location, notification rule, source, recurrence series, Receipts, and History Events. The linked object retains completion/capacity authority and its canonical identity.

<!-- canon-section: lifecycle -->
Lifecycle is active, inactive, archived, Trashed, restored, or permanently deleted; scheduled trigger, delivered, snoozed, dismissed, and acknowledged are notification/occurrence axes. Recurrence and linked-work state remain separate.

<!-- canon-section: valid-transitions -->
Valid transitions include create→active, active↔inactive, trigger→delivered, delivered→snoozed/dismissed/acknowledged, occurrence reschedule, active/inactive→archived, supported states→Trash, Trash→prior state, scoped recurrence edit, and explicit conversion. Each transition records its axis.

<!-- canon-section: invalid-transitions -->
Invalid transitions include acknowledgement/dismissal completing a Step or Goal, Reminder consuming capacity without linked/converted capacity-bearing object, linked Step completion erasing recurrence automatically, permission denial deleting intent, or recurrence edit without scope. Validators reject these paths before persistence.

<!-- canon-section: commands -->
Create, edit trigger/link, activate/deactivate, deliver-result, snooze, dismiss, acknowledge, reschedule, recur, convert, archive, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay`; system delivery facts and user actions remain distinguishable. Commands name Reminder and occurrence IDs.

<!-- canon-section: recurrence-scheduling -->
Reminder repetition uses one series and explicit occurrence/future/series scope. Trigger date/time/location is not a due date or Schedule Placement and consumes no capacity; conversion/linking previews any new time/capacity consequence. Scope is stored with mutation lineage.

<!-- canon-section: deletion-trash-restore-archive -->
Inactive, acknowledged, archive, Trash, and permanent deletion are distinct. Restore repairs pending triggers/projections without fabricating delivery; permanent deletion confirms series, linked-object, notification-center, history/search, and continuity scope. Rollback preserves accepted intent.

<!-- canon-section: history-receipts -->
Creation, material trigger/link/rule changes, recurrence scope, conversion, archive, Trash, restore, and permanent deletion produce automatic Receipts/History Events. Delivery, snooze, dismissal, and acknowledgement are inspectable facts but never user Proof or work completion.

<!-- canon-section: privacy-sync-classification -->
Reminder content, triggers, location, links, delivery/acknowledgement history, and behavior are private local data excluded from Account/R2/Source Atlas. System notification delivery uses minimum necessary content and explicit privacy settings. Local classification remains inspectable.

<!-- canon-section: import-export -->
Imported alarms/tasks remain candidates until reviewed into Reminder or another native type. Export/share is explicit; re-import reconciles source lineage. Conversion preserves original intent and field-impact history.

<!-- canon-section: projection-surfaces -->
Today and Time may project relevant Reminders, Goals shows contextual links, and Search/Trust inspect them; notification surfaces are external projections. Every action routes through canonical Reminder or linked-object commands.

<!-- canon-section: accessibility -->
Semantics expose reminder text, trigger, recurrence scope, linked object, delivery state, privacy, and distinct snooze/dismiss/acknowledge/open-linked-work actions. Labels never call acknowledgement completion.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; trigger/recurrence/notification mutation and inspection belong to `Core/LocalRuntimeOS/Scheduling/`, `Commands/`, and `Inspection/`; Today/Time present it and `Quality/` proves acknowledgement noncompletion, linked capacity, recurrence scope, permission denial, replay, Trash/restore, privacy, and accessibility. Tests bind actions to stable Reminder identifiers;



## OBJ-REMINDER-REPLACEMENT-TARGET-001 — Reminder replacement target and claim ceiling

- **Concept:** `object.reminder.replacement-target`
- **Modality:** `MUST NOT`
- **Scope:** Reminder replacement target and claim ceiling
- **Status:** `normative`
- **Verification:** `REVIEW-OBJ-REMINDER-REPLACEMENT-TARGET-001`
- **Supersedes:** none

Ambitions SHOULD target first-class replacement of ordinary personal reminder planning while preserving Reminder notification, capacity, recurrence, and completion boundaries; it MUST NOT claim parity until complete current evidence satisfies the replacement bar.
