+++
spec_id = "OBJECT-PROOF"
title = "Proof"
kind = "object"
status = "normative"
owner_domain = "object-proof"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.proof.identity"]
inherits = ["OBJECT-PROOF-REQUIREMENT-001", "OBJECT-LIFECYCLE-DELETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL", "OBJECT-STEP", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Trust/", "Native/Ambitions/Quality/"]
+++

# Proof

## OBJ-PROOF-IDENTITY-001 — User-approved evidence or reflection

- **Concept:** `object.proof.identity`
- **Modality:** `MUST`
- **Scope:** Proof identity, requirement level, and Receipt boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-PROOF-REQUIREMENT-001`
- **Supersedes:** none

Proof MUST be one user-approved evidence or reflection object linked to a Step, Goal, Closure, or Life Capital context. It works on the honor system, is never graded by strength, and remains distinct from the automatic Receipt that attests to a system mutation.

<!-- canon-section: stable-identity -->
Proof identity survives attachment edits, links, requirement-level context, progress transfer, archive, Trash, restore, and relevance changes. Stable identifiers preserve evidence lineage.

<!-- canon-section: user-meaning -->
Proof helps the user remember what happened, preserve progress, and carry useful experience forward without compliance theater or shame. Evidence remains user-controlled.

<!-- canon-section: relationships -->
Proof may link to Steps, Goals, Closures, attachments, source, Life Capital, Receipts that changed planning, and History Events. Links never auto-complete related work.

<!-- canon-section: lifecycle -->
Lifecycle is active, archived, Trashed, restored, or permanently deleted; optional/suggested/required is a predeclared requirement axis, while relevance is contextual. Each axis remains independently inspectable.

<!-- canon-section: valid-transitions -->
Valid transitions include create→active, attach/detach approved relationships, active→archived, archive→active, supported state→Trash, Trash→prior state, and permanent deletion after consequence review. Accepted changes preserve provenance.

<!-- canon-section: invalid-transitions -->
Invalid transitions include surprise required status at completion, automatic grading, Receipt masquerading as Proof, evidence attachment fabricating work completion, silent relevance deletion, or remote profiling. Validators preserve user choice.

<!-- canon-section: commands -->
Create, edit reflection, attach/remove evidence, link/unlink, change predeclared requirement before work, transfer context, archive, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay`; Proof content remains separate from the resulting Receipt.

<!-- canon-section: recurrence-scheduling -->
Proof neither recurs nor consumes capacity and has no Schedule Placement, due date, attendees, or alerts. A proof target/requirement may be referenced by a Step or Goal Path without scheduling Proof itself.

<!-- canon-section: deletion-trash-restore-archive -->
Archive, irrelevance, Trash, and permanent deletion are distinct. Trash preserves content/attachments/links; restore repairs progress/Life Capital projections; permanent deletion confirms linked-object, attachment, history/search/export, and rollback scope.

<!-- canon-section: history-receipts -->
Proof is user evidence; Receipts are automatic mutation records. Creating/editing/linking/deleting Proof produces its own Receipt/History Event, and planning changes caused by Proof produce a separate consequence Receipt.

<!-- canon-section: privacy-sync-classification -->
Proof content, reflection, attachments, links, and inferred capability context are private local graph data excluded from Account/R2/Source Atlas/hosted AI. Explicit export controls every included field.

<!-- canon-section: import-export -->
Imported evidence remains a reviewed local Proof with Source Reference and attachment provenance. Export is explicit; re-import reconciles stable lineage and never grades authenticity.

<!-- canon-section: projection-surfaces -->
Goals, Today, You/Life Capital, Search, and Trust may project relevant Proof. Every projection states evidence context without score language and retains canonical identity.

<!-- canon-section: accessibility -->
Semantics expose evidence type, summary, linked object, requirement level established before work, privacy/source, lifecycle, and actions without image-only or color-only meaning. Attachments include accessible descriptions.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; links, planning effects, commands, and inspection belong to `Core/LocalRuntimeOS/Planning/`, `Commands/`, and `Inspection/`; Trust presents inspection and `Quality/` proves requirement notice, non-grading, Proof/Receipt separation, transfer without false completion, Trash/restore, privacy, offline, and accessibility. Tests bind evidence to stable Proof identifiers; current implementation compliance is unclaimed.
