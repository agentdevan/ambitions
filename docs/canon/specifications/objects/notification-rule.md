+++
spec_id = "OBJECT-NOTIFICATION-RULE"
title = "Notification Rule"
kind = "object"
status = "normative"
owner_domain = "object-notification-rule"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.notification-rule.identity"]
inherits = ["CONTROL-MATERIAL-CONFIRMATION-001", "OBJECT-REMINDER-COMPLETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-REMINDER", "OBJECT-EVENT", "APP-PERMISSIONS", "SURFACE-YOU"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/You/", "Native/Ambitions/Quality/"]
+++

# Notification Rule

## OBJ-NOTIFICATION-RULE-IDENTITY-001 — Editable local-first alert behavior

- **Concept:** `object.notification-rule.identity`
- **Modality:** `MUST`
- **Scope:** Notification trigger, quiet hours, privacy, and object relationship
- **Status:** `normative`
- **Verification:** `SCENARIO-NOTIFICATION-RULE-001`
- **Supersedes:** none

A Notification Rule MUST be one editable local-first alert-behavior identity linking a canonical object or object class, trigger, authorization boundary, quiet-hour behavior, privacy presentation, and fallback. It never completes work or replaces Reminder identity.

<!-- canon-section: stable-identity -->
Rule identity survives trigger/policy edits, permission denial, quiet-hour deferral, delivery outcomes, archive, Trash, restore, and object relinking. Delivery requests reference the stable rule and subject.

<!-- canon-section: user-meaning -->
A Notification Rule explains when and how Ambitions may get the user’s attention, what appears, and how to change it. It avoids fake urgency and pressure.

<!-- canon-section: relationships -->
It may reference Reminder, Event, Step, Goal, review/automation policy, quiet-hour preference, permission state, Receipts, and History Events. Subject semantics remain owned by the subject.

<!-- canon-section: lifecycle -->
Lifecycle is active, inactive, archived, Trashed, restored, or permanently deleted; authorized/denied, scheduled/delivered/failed/deferred, and quiet-hour state are orthogonal. Each state remains inspectable.

<!-- canon-section: valid-transitions -->
Valid transitions include create→inactive/active after permission/choice, active↔inactive, trigger/privacy/quiet-hour edits, active/inactive→archived, supported state→Trash, Trash→prior state, and deletion after consequence review. Delivery outcomes do not alter lifecycle automatically.

<!-- canon-section: invalid-transitions -->
Invalid transitions include permission denial deleting the rule, delivery/dismissal/acknowledgement completing linked work, quiet-hour deferral changing subject schedule, hidden sensitive content by default, or silent activation beyond delegated authority. Validators preserve prior policy.

<!-- canon-section: commands -->
Create, edit trigger/content policy, activate/deactivate, change quiet-hour/fallback, relink, record delivery result, archive, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay`; OS scheduling remains a reconciled external effect.

<!-- canon-section: recurrence-scheduling -->
Rules may derive repeated delivery requests from a Reminder/Event/Step series but do not own recurrence or capacity. Every request carries subject occurrence and rule IDs; quiet-hour movement changes delivery only.

<!-- canon-section: deletion-trash-restore-archive -->
Deactivate, archive, Trash, and permanent deletion are distinct. Restore reconciles pending OS requests; deletion confirms linked subjects, scheduled requests, delivery history, search/export, and rollback scope without deleting subjects.

<!-- canon-section: history-receipts -->
Material policy/authority/trigger changes, archive, Trash, restore, and deletion produce automatic Receipts/History Events. Delivery attempt/result is inspectable; acknowledgement remains distinct from work completion and Proof.

<!-- canon-section: privacy-sync-classification -->
Rule content, subject links, timing, delivery behavior, and privacy preferences are private local data. Notification payloads use minimum necessary content; Account/R2 never receive private graph context.

<!-- canon-section: import-export -->
Imported alerts remain candidates or source facts until reviewed into a local rule/Reminder. Export is explicit; OS request reconciliation preserves local rule authority and source/result lineage.

<!-- canon-section: projection-surfaces -->
You owns broad controls; object detail and contextual permission/notification flows show scoped rules; system notifications project delivery. Every action routes through canonical rule or linked-object commands.

<!-- canon-section: accessibility -->
Semantics expose subject, trigger, quiet-hour behavior, privacy content level, permission, active state, fallback, and actions in plain language. Notification actions distinguish acknowledge, snooze, dismiss, and open linked work.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; scheduling, OS reconciliation, mutation, and inspection belong to `Core/LocalRuntimeOS/Scheduling/`, `ExternalWrites/`, `Commands/`, and `Inspection/`; You presents controls and `Quality/` proves permission denial, quiet hours, privacy payload, delivery failure/retry, noncompletion, recurrence linkage, Trash/restore, replay, offline, and accessibility. Tests bind requests to rule/subject identifiers; current implementation compliance is unclaimed.
