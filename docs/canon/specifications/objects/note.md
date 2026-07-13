+++
spec_id = "OBJECT-NOTE"
title = "Note"
kind = "object"
status = "normative"
owner_domain = "object-note"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.note.identity-execution"]
inherits = ["OBJECT-TAXONOMY-001", "OBJECT-LIFECYCLE-DELETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "GLOBAL-CAPTURE", "GLOBAL-SEARCH", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Composer/Capture/", "Native/Ambitions/Quality/"]
[object_boundary]
executable_completable = "No"
occupies_duration = "No"
consumes_capacity = "No"
due_date = "No until promoted"
recurrence = "No"
substeps = "No"
goal_path_node = "No until promoted"
proof_requirement = "No"
attendees_rsvp = "No"
alerts = "Optional only after promotion"
type_conversion = "Promote explicitly"
laws = { schedule_placement_nonduplication = "OBJ-SCHEDULE-PLACEMENT-IDENTITY-001", future_step_singularity = "OBJECT-FUTURE-STEP-IDENTITY-001", reminder_acknowledgement_noncompletion = "OBJECT-REMINDER-COMPLETION-001", proof_receipt_separation = "OBJECT-PROOF-REQUIREMENT-001" }
+++

# Note

## OBJ-NOTE-IDENTITY-001 — Non-executable information

- **Concept:** `object.note.identity-execution`
- **Modality:** `MUST NOT`
- **Scope:** Note identity, information, and promotion boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-NOTE-PROMOTION-001`
- **Supersedes:** none

A Note is one durable non-executable information object optionally linked to a Life Area, Goal, source, or attachments. It MUST NOT gain execution, capacity, recurrence, due-date, attendee, alert, completion, or Goal Path Step semantics until explicit receipt-backed promotion.

A Note MUST be context without inherent execution, duration, or completion law.

<!-- canon-section: stable-identity -->
Note identity survives content edits, links, attachments, archive, Trash, restore, source changes, and promotion lineage. Editor buffers and surface cards remain projections of the canonical Note.

<!-- canon-section: user-meaning -->
A Note preserves information, reflection, or a thought without asking the user to execute or complete it. Information remains useful without planning pressure.

<!-- canon-section: relationships -->
It may link to a Life Area, Goal, Source Reference, attachments, related objects, Receipts, and History Events. Links provide context and never grant executable or capacity-bearing behavior.

<!-- canon-section: lifecycle -->
Lifecycle is active, archived, Trashed, restored, or permanently deleted; draft editing and source/import states are separate axes. Promotion records lineage to a destination object rather than silently changing lifecycle.

<!-- canon-section: valid-transitions -->
Valid transitions include create→active, active content/link edits, active→archived, archive→active, supported state→Trash, Trash→prior state, permanent deletion after confirmation, and explicit promotion/conversion with field review. Accepted transitions retain provenance.

<!-- canon-section: invalid-transitions -->
Invalid transitions include direct scheduling, recurrence, due date, completion, Goal Path executable-node status, notification behavior, or silent conversion based on shared metadata. Validators reject executable mutations against Note identity.

<!-- canon-section: commands -->
Create, edit, link/unlink, attach, archive, restore, promote/convert, Trash, restore from Trash, and permanently delete use `Command → Event → Projection → Receipt → Replay`; promotion preserves source Note lineage and rollback handling. Commands name source and destination identifiers.

<!-- canon-section: recurrence-scheduling -->
Notes do not recur, carry due dates, consume capacity, own alerts, or receive Schedule Placements. Promotion to Step/Event/Reminder previews every introduced scheduling/recurrence field and keeps conversion lineage. Time fields belong to the destination type.

<!-- canon-section: deletion-trash-restore-archive -->
Archive removes ordinary active presentation while preserving search/inspection. Trash preserves content, links, attachments, and promotion lineage; restore repairs projections; permanent deletion confirms attachment/source/history/search/export scope and rollback limits. Each operation remains distinct.

<!-- canon-section: history-receipts -->
Material edits, links, attachment changes, promotion, archive, Trash, restore, and permanent deletion produce automatic Receipts/History Events. Note content or reflection may support user Proof only through an explicit Proof object/link.

<!-- canon-section: privacy-sync-classification -->
Note content, links, attachments, and provenance are private local graph data excluded from Account/R2/Source Atlas/hosted AI. Export and future approved continuity require explicit scope and local authority. Classification is inspectable.

Egress commands enumerate included fields and retain local provenance.

<!-- canon-section: import-export -->
Captured/shared/imported text becomes a reviewed Note or Saved-for-Later Draft with Source Reference, never an invisible remote authority. Export is previewed; re-import reconciles provenance. Promotion preserves original source text.

<!-- canon-section: projection-surfaces -->
Capture creates it, Search and Trust inspect it, Goals/You may show contextual links, and other surfaces show only earned context. Actionable projections retain Note identity and route commands canonically.

<!-- canon-section: accessibility -->
Semantics expose content summary, links, source, attachments, lifecycle, privacy, and explicit promote/archive/Trash actions without implying executability. Reading and editing order remains stable at large text sizes.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; capture routing, mutation, conversion lineage, and inspection belong to `Core/LocalRuntimeOS/CaptureRouting/`, `Commands/`, and `Inspection/`; Capture presents creation and `Quality/` proves nonexecution, promotion, attachment/privacy, Trash/restore, replay, offline, and accessibility. Tests bind changes to stable Note identifiers;
