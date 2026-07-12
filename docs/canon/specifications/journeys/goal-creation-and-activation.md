+++
spec_id = "JOURNEY-GOAL-CREATION-AND-ACTIVATION"
title = "Goal Creation and Activation"
kind = "journey"
status = "normative"
owner_domain = "journey-goal-creation-and-activation"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.goal-activation.route-generation"]
inherits = ["CONTROL-FORCE-NOTHING-001", "CONTROL-MATERIAL-CONFIRMATION-001", "OBJECT-GOAL-LIFECYCLE-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "SURFACE-GOALS", "OBJECT-GOAL", "OBJECT-GOAL-PATH", "OBJECT-STEP", "OBJECT-SCHEDULE-PLACEMENT"]
source_owners = ["Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Goal Creation and Activation

This shadow journey composes Goal, Goal Path, Step, and placement owners without copying their lifecycle laws or asserting implementation.

## JOURNEY-GOAL-ACTIVATION-001 — Activation follows reviewed route generation

- **Concept:** `journey.goal-activation.route-generation`
- **Modality:** `MUST`
- **Scope:** Goal intent, route proposal, initial Steps, and activation
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-GOAL-ACTIVATION-001`
- **Supersedes:** none

Goal creation MUST first commit a typed durable provisional Goal shell and original intent with Receipt/replay. Accepted clarification edits are separate typed durable Goal commits. Generated Goal Path versions, Steps, dates, proof expectations, and placements remain non-durable proposals until reviewed; activation is a later confirmed commit, and optional scheduling is distinct again.

<!-- canon-section: trigger-starting-state -->
Triggers are Goals create, Capture promotion, template/reference handoff, or restoration of provisional intent; starting state records Life Area context, source intent, existing related Goals, constraints, and local availability.

<!-- canon-section: preconditions -->
The user can state a meaningful outcome; the local command path can durably preserve a provisional Goal shell before planning; duplicate/relationship checks and constraint facts are readable. A deadline, account, network, generated full path, or Proof is not required unless chosen or already declared by owning law.

<!-- canon-section: happy-path -->
Validate and commit a typed provisional Goal creation command, project the Draft Goal, and issue its Receipt/replay before route generation. Commit each accepted clarification through the Goal owner with its own before/after Receipt. Then compute non-durable route/Path/Step/placement proposals, let the user edit, omit, or reject them, confirm activation scope, commit activation locally, and, only if separately selected and confirmed, commit scheduling through its owner.

<!-- canon-section: branches -->
Branches are create and retain the provisional Goal without planning, accept a clarification commit, reject a clarification and retain the last durable Goal, activate Goal only, activate Goal plus selected path nodes, separately schedule selected Steps, choose a lighter route, link a Life Area, merge/decline a duplicate, or reject every generated route/Path/Step proposal while keeping or safely reversing the provisional Goal. Owning object specs control lifecycle and identity.

<!-- canon-section: cancellation -->
Cancel before provisional creation with no Goal mutation. After the provisional Goal commits, cancel clarification or route review by retaining the last durable Goal and its Receipts; reversing the provisional creation uses the Goal owner's safe-reversal command and history. Cancellation never activates the Goal, accepts a clarification, converts suggestions into Steps, or schedules anything.

<!-- canon-section: interruption-resume -->
The provisional Goal Receipt/replay binds canonical identity, original intent, accepted clarification commits, and last durable Goal state; the planning draft separately binds route fingerprint, uncommitted edits, exclusions, review position, constraint fingerprint, and focus.
Resume from the durable provisional Goal and clarification history, then restore the non-durable planning draft if valid. Re-read changed constraints and mark stale route/Path/Step/placement proposals before further confirmation.

<!-- canon-section: commit-boundary -->
There are four explicit boundaries: typed provisional Goal creation is a durable local commit with Receipt/replay; each accepted clarification is a durable Goal edit commit with Receipt/replay; route/Path/Step/placement simulation remains non-durable until confirmed activation commits the selected Goal/Path scope; optional scheduling is a separate confirmed placement commit. No planning preview rewrites the provisional Goal.

<!-- canon-section: failure -->
Provisional-create rejection leaves original input recoverable and creates no Goal. Clarification rejection retains the prior durable Goal. Planning failure, insufficient context, invalid dependency, stale capacity, activation rejection, scheduling rejection, or projection delay retains the last durable phase and cannot claim a later phase or invent a partial path.

<!-- canon-section: recovery -->
Offer retry provisional creation idempotently from preserved input, submit a corrected clarification, reject clarification, edit/simplify/remove a proposed node, activate without a path, reject all route proposals, recompute from current facts, retry only the failed typed command, or return to the last durable Goal state and its Receipt.

<!-- canon-section: undo-rollback -->
Safe reversal of provisional creation, rollback of a clarification, undo of activation, and rollback of optional scheduling are distinct owning commands. Each restores the prior valid phase while retaining Goal/Path/placement lineage and every Receipt; already-started or externally written consequences require explicit reconciliation.

<!-- canon-section: receipts-proof -->
The mutation chain records provisional Goal creation, each clarification before/after, planning rejection, activation scope, accepted path fingerprint, separately selected placements, rollback, and distinct external outcomes.
Receipt/history distinguish provisional creation, clarification acceptance/rejection, route proposal rejection, activation, accepted path version, optional scheduling, each rollback, and any external result. Proof expectations are shown before activation and user Proof remains separate from system Receipts.

<!-- canon-section: accessibility -->
Semantics expose outcome, proposed path order, dependency, timing, proof expectation, consequence, inclusion state, alternatives, and confirmation; reorder/spatial path editing has named controls, comparisons stack at Dynamic Type, reduced effects preserve sequence, and focus returns to the changed node.

<!-- canon-section: offline -->
The device path supports provisional persistence, local planning, review, activation, scheduling, receipts, replay, and rollback.
Provisional save, deterministic local route behavior available in the installed product, review, activation, placement, receipts, and rollback work without account/network; unavailable public reference enrichment cannot block or silently alter the local route.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-GOAL-ACTIVATION-001`, `SCENARIO-JOURNEY-GOAL-PROVISIONAL-COMMIT-001`, `SCENARIO-JOURNEY-GOAL-CLARIFICATION-COMMIT-001`, `SCENARIO-JOURNEY-GOAL-ROUTE-REJECT-001`, `SCENARIO-JOURNEY-GOAL-PARTIAL-PATH-001`, `SCENARIO-JOURNEY-GOAL-SCHEDULE-SEPARATE-001`, `SCENARIO-JOURNEY-GOAL-STALE-RESUME-001`, and `SCENARIO-JOURNEY-GOAL-UNDO-001`; assert one stable Goal ID, typed durable provisional and clarification commits with receipts/replay, cancellation and rejection from each phase, non-durable route/Path/Step/placement previews, separate activation/scheduling commits, phase-specific rollback, Force Nothing, offline parity, proof advance notice, and focus order.
