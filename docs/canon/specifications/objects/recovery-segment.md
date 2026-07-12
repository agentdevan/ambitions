+++
spec_id = "OBJECT-RECOVERY-SEGMENT"
title = "Recovery Segment"
kind = "object"
status = "normative"
owner_domain = "object-recovery-segment"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.recovery-segment.identity"]
inherits = ["CONTROL-UNDO-RECOVERY-001", "OBJECT-CANONICAL-GRAPH-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL-PATH", "OBJECT-STEP", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Stage/Motion/", "Native/Ambitions/Quality/"]
+++

# Recovery Segment

## OBJ-RECOVERY-SEGMENT-IDENTITY-001 — Inspectable reality-changed path segment

- **Concept:** `object.recovery-segment.identity`
- **Modality:** `MUST`
- **Scope:** Missed/blocked work, recommendation, user choice, and path recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-RECOVERY-001`
- **Supersedes:** none

A Recovery Segment MUST be one non-shaming inspectable path segment linked to a Goal Path, affected missed/blocked Step or reality change, recommendation with rationale, user choice, accepted path/placement effects, Receipt, and rollback.

<!-- canon-section: stable-identity -->
Recovery Segment identity survives recommendation refresh, user rejection/acceptance, path adaptation, subject completion, archive, Trash, restore, and projection changes. Accepted and superseded proposals retain lineage.

<!-- canon-section: user-meaning -->
Recovery helps the user continue when reality changes, preserving progress and dignity through concrete choices such as Still counts, Move it, Blocked, Waiting, Not needed, Review, and Undo.

<!-- canon-section: relationships -->
It belongs to one Goal Path context and references affected Steps/placements/constraints, recommendation/alternatives/rationale, user decision, resulting path state, Proof context, Receipt, and History Events. Referenced objects retain identity.

<!-- canon-section: lifecycle -->
Lifecycle is proposed, reviewed, accepted, rejected, superseded-with-lineage, resolved, archived-with-path, Trashed under governed scope, restored, or permanently deleted; blockage/waiting and placement states remain orthogonal.

<!-- canon-section: valid-transitions -->
Valid transitions include detected→proposed, proposed→reviewed, reviewed→accepted/rejected, accepted→resolved or superseded by later reality, governed Trash/restore, and deletion after path/history scope review. User choice controls material effects.

Accepted choices record affected path and placement identifiers.

<!-- canon-section: invalid-transitions -->
Invalid transitions include recommendation silently changing path/time, rejection treated as failure/shame, recovery completing work, replacing Step identity, erasing prior Proof/progress, or protected-boundary override without authority. Validators preserve the prior path.

Validation rejects unauthorized effects before canonical persistence.

<!-- canon-section: commands -->
Propose, review, choose alternative, accept, reject, edit, apply path/placement recovery, resolve, Undo/rollback, archive, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay`; proposals remain non-authoritative until acceptance.

<!-- canon-section: recurrence-scheduling -->
Recovery Segment does not recur or consume capacity. Its accepted changes target explicit Step/placement/series occurrence scope and preview protected/fixed boundaries, deadline, pace, and downstream path effects.

<!-- canon-section: deletion-trash-restore-archive -->
Resolution/archive preserves recovery history. Trash/delete previews Goal Path, Step, placement, Receipt, proof/progress, search/export, and rollback scope; restore repairs path inspection without reapplying rejected effects.

<!-- canon-section: history-receipts -->
Proposal/rejection may record inspectable rationale; accepted material path/placement change always creates Receipt and before/after History Events. User Proof/progress remains separate and preserved.

<!-- canon-section: privacy-sync-classification -->
Reality changes, constraints, behavior, recommendation rationale, user choices, and path effects are private local graph data excluded from Account/R2/Source Atlas/hosted AI. Local explanation remains inspectable.

<!-- canon-section: import-export -->
External schedule/source changes may trigger local recovery candidates without exporting private context. Export of recovery history is explicit; re-import/reconciliation cannot auto-accept a recovery choice.

<!-- canon-section: projection-surfaces -->
Goals owns full path recovery, Today/Time show affected action/time context, Motion communicates accepted consequence/re-entry, and Search/Trust inspect lineage. Projections retain Recovery Segment and affected IDs.

<!-- canon-section: accessibility -->
Semantics expose changed reality, affected objects, recommendation, rationale, alternatives, protected boundaries, consequences, accept/reject/edit/Undo actions, and focus restoration without motion/spatial/color dependence.

<!-- canon-section: source-test-ownership -->
Canonical semantics belong to `Core/Domain/`; detection/recommendation, scheduling impact, commands, rollback, and inspection belong to `Core/LocalRuntimeOS/Planning/`, `Scheduling/`, `Commands/`, and `Inspection/`; Motion presents consequence and `Quality/` proves user control, protected boundaries, progress/Proof preservation, rollback/replay, offline, privacy, and accessibility. Tests bind recovery to stable segment/path/Step IDs; current implementation compliance is unclaimed.
