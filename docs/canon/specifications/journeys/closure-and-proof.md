+++
spec_id = "JOURNEY-CLOSURE-AND-PROOF"
title = "Closure and Proof"
kind = "journey"
status = "normative"
owner_domain = "journey-closure-and-proof"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.step-closure.required-proof"]
inherits = ["OBJECT-PROOF-REQUIREMENT-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "OBJECT-GOAL", "OBJECT-CLOSURE", "OBJECT-PROOF", "OBJECT-RECEIPT", "GLOBAL-TRUST-INSPECTION", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Stage/Motion/", "Native/Ambitions/Trust/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Closure and Proof

This shadow journey coordinates closure evidence; owning object specifications retain completion, closure, ending, archive, deletion, Proof, and Receipt semantics.

## JOURNEY-STEP-CLOSURE-001 — Required Proof is known before closure

- **Concept:** `journey.step-closure.required-proof`
- **Modality:** `MUST`
- **Scope:** Step or Goal closure with optional, suggested, or required Proof
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-STEP-CLOSURE-001`
- **Supersedes:** none

Closure MUST apply the Proof rule disclosed before the current work began. Required Proof blocks validated closure until user-approved evidence is attached; it cannot appear as a surprise, be graded, be replaced by an automatic Receipt, or be weakened during closure. A predeclared-rule edit applies only to future work because no cited owning law authorizes a current-closure override.

Goal closure SHOULD show a compact review of the path, proof, recovery segments, remaining open items, schedule cleanup, and final receipt.

Completion and closure MUST be distinct where product meaning requires it.

Ambitions SHOULD NOT state that old Proof does not apply.

Ambitions MUST operate on the honor system.

<!-- canon-section: trigger-starting-state -->
Triggers are completion, Still counts, Goal close/end review, Proof addition, or correction/undo; starting state identifies the canonical object, declared Proof rule, existing evidence, closure options, dependent path effects, and prior Receipts.

<!-- canon-section: preconditions -->
The object resolves to current identity; supported closure choices and Proof rule are readable; material downstream consequences can be previewed. Closure is not inferred from schedule, animation, notification acknowledgement, or attachment presence.

<!-- canon-section: happy-path -->
Select the truthful closure state, show the previously declared Proof rule and downstream effects, attach or approve evidence when needed, preview material consequences, confirm, validate and commit locally, update affected paths, issue a Receipt/History event, and reveal contextual inspection.

<!-- canon-section: branches -->
Each branch binds the canonical object ID, current-work rule fingerprint, closure scope, evidence links, and owning command.
Branches are complete, Still counts, Not needed, Goal Ended, add optional/suggested/required Proof, postpone closure, correct a previously recorded closure through its owner, close a scoped recurring occurrence, or separately edit the predeclared Proof rule for future work. A future-work rule edit cannot satisfy or alter the current closure. Object owners define valid transitions.

<!-- canon-section: cancellation -->
Canceling review or Proof selection leaves object, evidence draft, and path unchanged; discarding a proof draft is explicit. No preview creates closure or attaches evidence.

<!-- canon-section: interruption-resume -->
The recovery record binds object identity, closure choice, current-work Proof rule, proof draft, attachment results, consequence fingerprint, and semantic focus.
Resume the same object, closure option, current-work Proof rule, proof draft, attachment states, consequence preview version, and focus. changed dependencies invalidate the preview and require renewed review.

<!-- canon-section: commit-boundary -->
The closure command validates the canonical object ID, current-work rule fingerprint, evidence IDs, recurrence scope, and consequence fingerprint before local commit.
Closure choice, Proof draft, and consequence preview are non-durable proposals. Closure becomes durable only after the unchanged current-work rule and evidence validate, explicit confirmation where material, authoritative local commit, projection, and Receipt;

<!-- canon-section: failure -->
Missing required Proof, attachment failure, stale object/path, invalid recurrence scope, command rejection, or projection failure preserves the prior honest state and never shows closure success.

<!-- canon-section: recovery -->
The recovery action set preserves the canonical object ID and current-work rule while changing only evidence, closure choice, or retry state through their owners.
Offer attach/replace evidence, postpone the current closure, choose another truthful closure permitted by the owning object, refresh the preview, retry idempotently, inspect failure, or return without shame. A rule edit may be offered only as a separate future-work command and cannot recover the blocked current closure.

<!-- canon-section: undo-rollback -->
Each reversal records the object ID, governing rule fingerprint, prior closure state, restored path influence, evidence disposition, and Receipt chain.
Undo/correction of a committed closure restores prior object and path influence through the owner, retains Proof according to its lifecycle, and appends rather than erases Receipt/History. It does not retroactively rewrite the Proof rule that governed that work. A future-work rule edit has its own rollback and never changes current-work validation; external effects reconcile separately.

<!-- canon-section: receipts-proof -->
The rule records use distinct scope IDs and history entries, so neither can substitute for the other.
Proof is user-approved honor-system evidence; Receipt is automatic mutation evidence. The chain records the rule visible before current work, any rejected current-closure attempt, closure choice/scope, evidence linkage, local commit, downstream changes, undo/correction, and external state without grading Proof.

<!-- canon-section: accessibility -->
Semantics expose object, closure choice, proof rule/status, attachments, downstream consequences, confirmation, and recovery; evidence actions have labels/status, comparisons are verbalized, Dynamic Type stacks content, reduced motion preserves sequence, and focus returns to the object or failed field.

<!-- canon-section: offline -->
Device-owned evidence and object facts support local review, commit, projection, Receipt, replay, correction, and undo.
Local closure review, locally available Proof attachment, validation, commit, receipts/history, correction, replay, and undo work without account/network; external-source evidence may remain unavailable without fabricating satisfaction.

<!-- canon-section: scenario-tests -->
The fixture binds one object and rule pair plus a separate rule scope, then asserts the first pair remains unchanged across every command.
Execute `SCENARIO-JOURNEY-STEP-CLOSURE-001`, `SCENARIO-JOURNEY-CLOSURE-PROOF-OPTIONAL-001`, `SCENARIO-JOURNEY-CLOSURE-PROOF-REQUIRED-001`, `SCENARIO-JOURNEY-CLOSURE-CURRENT-RULE-HOLDS-001`, `SCENARIO-JOURNEY-CLOSURE-FUTURE-RULE-EDIT-001`, `SCENARIO-JOURNEY-CLOSURE-CANCEL-001`, `SCENARIO-JOURNEY-CLOSURE-STALE-001`, and `SCENARIO-JOURNEY-CLOSURE-UNDO-001`; assert advance notice, required Proof blocks current closure, a rule edit affects future work only, rejected attempts/history remain inspectable, proposal non-durability, valid scope, false-success prevention, Proof/Receipt separation, offline replay, and focus.
