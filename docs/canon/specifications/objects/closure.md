+++
spec_id = "OBJECT-CLOSURE"
title = "Closure"
kind = "object"
status = "normative"
owner_domain = "object-closure"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.closure.identity-lifecycle"]
inherits = ["OBJECT-LIFECYCLE-DELETION-001", "OBJECT-PROOF-REQUIREMENT-001", "CONTROL-UNDO-RECOVERY-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL", "OBJECT-STEP", "OBJECT-PROOF", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Stage/Motion/", "Native/Ambitions/Quality/"]
+++

# Closure

## OBJ-CLOSURE-IDENTITY-001 — Honest completion or ending event

- **Concept:** `object.closure.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Closure identity, outcome, Proof, and rollback
- **Status:** `normative`
- **Verification:** `SCENARIO-CLOSURE-OUTCOME-001`
- **Supersedes:** none

A Closure MUST be one honest outcome record for a Step or Goal, using Completed, Not needed, Still counts, or Closed with risk as applicable, with optional reflection/Proof and the automatic Receipt of the resulting mutation kept separate.

<!-- canon-section: stable-identity -->
Closure identity survives reflection/Proof edits, correction, reversal, archive of its subject, Trash governed by history law, and projection changes. Corrections append lineage rather than rewriting history silently.

<!-- canon-section: user-meaning -->
Closure helps the user say truthfully how a work loop ended and what still matters, without shame or forced binary success. Outcomes preserve progress and recovery context.

Plain outcome choices preserve honest user control.

<!-- canon-section: relationships -->
It belongs to one Step or Goal outcome and may link Proof, reflection, recovery, affected recurrence scope, Receipt, and History Events. Closure never owns the subject identity.

<!-- canon-section: lifecycle -->
Lifecycle is accepted, corrected/superseded-with-lineage, reversed-with-lineage, archived-with-subject context, Trashed under governed scope, restored, or permanently deleted. Outcome and proof state are separate axes.

<!-- canon-section: valid-transitions -->
Valid transitions include proposed→accepted after requirement/consequence review, accepted→corrected or reversed through explicit command, governed Trash/restore, and deletion after history/proof scope confirmation. Each accepted transition records prior outcome.

<!-- canon-section: invalid-transitions -->
Invalid transitions include surprise required Proof, Reminder acknowledgement creating Closure, archive as Closure, deletion as Closure, automatic success from elapsed time, or correction erasing prior outcome. Validators preserve the last honest record.

<!-- canon-section: commands -->
Close as Completed/Not needed/Still counts/Closed with risk, add reflection/Proof, correct, reverse, Trash, restore, and permanently delete use `Command → Event → Projection → Receipt → Replay`; rollback restores subject state while retaining closure history.

<!-- canon-section: recurrence-scheduling -->
Closure does not recur or consume capacity. Closing a recurring Step declares occurrence/future/series scope and previews subsequent occurrence effects; placements change only through their owner.

The closure command records the selected recurrence scope explicitly.

<!-- canon-section: deletion-trash-restore-archive -->
Closure, archive, Trash, and permanent deletion are distinct. Trash/delete is constrained by audit/history integrity and previews subject/Proof/receipt/search/export scope; restore repairs subject projections without fabricating work state.

<!-- canon-section: history-receipts -->
Closure is the user-meaningful outcome object; the Receipt automatically records the mutation, while History Events preserve before/after state and corrections. Proof remains optional/suggested/predeclared-required user evidence.

<!-- canon-section: privacy-sync-classification -->
Outcome, reflection, Proof, risk, and recovery context are private local graph data excluded from Account/R2/Source Atlas. Export is explicit and local authority remains inspectable.

<!-- canon-section: import-export -->
Imported completion claims remain candidates until user-approved Closure. Export includes selected outcome/reflection/Proof only after preview; re-import cannot overwrite local outcome lineage.

<!-- canon-section: projection-surfaces -->
Today/Goals/Time present subject consequence, Motion communicates closure/re-entry, and Search/Trust inspect outcome/history. Every projection resolves Closure and subject identifiers.

<!-- canon-section: accessibility -->
Semantics expose subject, outcome choices, proof rule known before action, reflection, recurrence scope, downstream consequences, Undo/reversal, and focus restoration. Non-color labels preserve Still counts and risk meaning.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; closure commands, recurrence impact, rollback, and inspection belong to `Core/LocalRuntimeOS/Planning/`, `Commands/`, and `Inspection/`; `Stage/Motion/` presents consequence and `Quality/` proves every outcome, Proof notice, recurrence scope, correction/reversal, receipt separation, replay, privacy, and accessibility. Tests bind outcomes to stable Closure/subject identifiers; current implementation compliance is unclaimed.
