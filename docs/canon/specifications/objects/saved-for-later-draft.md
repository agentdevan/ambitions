+++
spec_id = "OBJECT-SAVED-FOR-LATER-DRAFT"
title = "Saved-for-Later Draft"
kind = "object"
status = "normative"
owner_domain = "object-saved-for-later-draft"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.capture-draft.identity-lifecycle"]
inherits = ["OBJECT-SAVED-FOR-LATER-001", "OBJECT-LIFECYCLE-DELETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "GLOBAL-CAPTURE", "GLOBAL-SEARCH", "OBJECT-STEP", "OBJECT-NOTE"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Composer/Capture/", "Native/Ambitions/Quality/"]
+++

# Saved-for-Later Draft

## OBJ-CAPTURE-DRAFT-IDENTITY-001 — Durable unresolved input

- **Concept:** `object.capture-draft.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Saved-for-Later Draft identity, reachability, and promotion
- **Status:** `normative`
- **Verification:** `SCENARIO-SAVED-FOR-LATER-001`
- **Supersedes:** none

A Saved-for-Later Draft MUST be one durable uncommitted-input identity preserving original Capture text, attachments, source, inferred route, uncertainty, and recovery state. It remains explicitly reachable through Search/contextual review and never becomes a root Inbox, Today backlog, notes feed, or generic destination.

<!-- canon-section: stable-identity -->
Draft identity is assigned locally before optional classification/attachment processing and survives interruption, crash, review, inference changes, archive, Trash, restore, and promotion lineage. Recovery resolves the same identifier.

<!-- canon-section: user-meaning -->
The draft gives uncertain or unfinished input a safe home without forcing classification, scheduling, or execution. Original intent remains legible and editable.

<!-- canon-section: relationships -->
It may retain Capture source/context, attachments, Source References, inferred route candidates, promoted destination identity, Receipts, and History Events. Candidates are advisory links and never canonical objects before promotion.

<!-- canon-section: lifecycle -->
Lifecycle is saved, under explicit review, promoted-with-lineage, archived, Trashed, restored, or permanently deleted; classification/proposal/attachment states are orthogonal. Promotion retains the source draft record or explicit retirement lineage.

<!-- canon-section: valid-transitions -->
Valid transitions include composing→saved, saved↔review, saved/review→promoted after explicit destination confirmation, saved/review→archived, supported states→Trash, Trash→prior state, and permanent deletion after consequence confirmation. Accepted transitions preserve original input.

<!-- canon-section: invalid-transitions -->
Invalid transitions include inferred type silently creating active work, automatic scheduling, Today/root placement, promotion that discards text/attachments/source, dismissal deleting the draft, or classifier failure changing lifecycle. Validators retain the draft before rejecting routing.

<!-- canon-section: commands -->
Save unresolved, edit, attach/remove, review route, choose type, promote, archive, restore, Trash, restore from Trash, and permanently delete use `Command → Event → Projection → Receipt → Replay`; draft persistence precedes optional processing. Commands preserve original and normalized input.

<!-- canon-section: recurrence-scheduling -->
Drafts neither recur nor consume capacity and have no Schedule Placement. Promotion previews destination-specific due date, range, recurrence, alert, capacity, Goal, and proof effects. Scheduling occurs only on the promoted canonical object.

<!-- canon-section: deletion-trash-restore-archive -->
Promotion, archive, Trash, and permanent deletion are distinct. Trash preserves input/attachments/candidates; restore repairs reachability; permanent deletion confirms attachments, promoted-lineage, source, history/search/export, and rollback limits. Dismissal remains non-destructive.

<!-- canon-section: history-receipts -->
Save, material edit, promotion, archive, Trash, restore, and permanent deletion produce automatic Receipts/History Events. Classification proposals and failures are inspectable without becoming user Proof.

<!-- canon-section: privacy-sync-classification -->
Draft text, attachments, inferred routes, context, and uncertainty are private local data excluded from Account/R2/Source Atlas/hosted AI. Permission denial and offline operation preserve the draft. Egress classification is explicit.

<!-- canon-section: import-export -->
Share/import input may enter as a draft with Source Reference until type is confirmed. Export is explicit and previewed; promotion/import preserves source lineage and avoids duplicate destination identities. Original bytes remain locally recoverable until governed deletion.

<!-- canon-section: projection-surfaces -->
Capture owns composition/recovery; Search and contextual review provide reachability; an earned suggestion may invite review. Today and root navigation never become a draft backlog. Projections retain the draft ID.

<!-- canon-section: accessibility -->
Semantics expose original input, attachment state, source, inferred candidate with uncertainty, lifecycle, privacy, and explicit review/promote/archive/Trash actions. Focus restoration returns to the exact draft and failed field.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; persistence, classification/routing, promotion lineage, commands, and inspection belong to `Core/LocalRuntimeOS/CaptureRouting/`, `Commands/`, and `Inspection/`; Capture presents it and `Quality/` proves interruption/crash recovery, explicit promotion, reachability, non-destination law, attachment failure, Trash/restore, replay, offline, privacy, and accessibility. Tests bind recovery to stable draft identifiers; current implementation compliance is unclaimed.
