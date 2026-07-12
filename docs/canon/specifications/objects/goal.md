+++
spec_id = "OBJECT-GOAL"
title = "Goal"
kind = "object"
status = "normative"
owner_domain = "object-goal"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.goal.identity", "object.goal.creation-failure"]
inherits = ["OBJECT-GOAL-LIFECYCLE-001", "OBJECT-PROOF-REQUIREMENT-001", "OBJECT-LIFECYCLE-DELETION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-LIFE-AREA", "SURFACE-GOALS", "SURFACE-TIME", "GLOBAL-TRUST-INSPECTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Quality/"]
+++

# Goal

## OBJ-GOAL-IDENTITY-001 — Desired outcome with a living route

- **Concept:** `object.goal.identity`
- **Modality:** `MUST`
- **Scope:** Goal identity and semantic boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-LIFECYCLE-001`
- **Supersedes:** none

A Goal MUST be one stable desired outcome with a living route. It belongs to one Life Area, owns at most one current Goal Path plus version history, and may relate Steps, Proof, placements, recovery, and closure without absorbing their identities.

## OBJ-GOAL-CREATION-FAILURE-001 — Preserve provisional intent

- **Concept:** `object.goal.creation-failure`
- **Modality:** `MUST`
- **Scope:** Goal creation when full pathing cannot complete
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-CREATION-DEGRADED-001`
- **Supersedes:** none

If pathing cannot complete, Ambitions MUST durably retain a provisional Goal shell and original intent, identify the missing clarification, and allow manual continuation, retry, or safe reversal without fabricating a finished path.

<!-- canon-section: stable-identity -->
Goal identity survives lifecycle, advisory, path-version, schedule, proof, recovery, closure, archive, Trash, restore, and source changes. A Goal card, generated route, or completion view is a projection.

The canonical identifier remains the action-routing key through every state change.

<!-- canon-section: user-meaning -->
A Goal is an outcome the user wants to bring into reality. It is not a task list, streak, score, category, calendar event, or AI-owned plan.

<!-- canon-section: relationships -->
The Goal belongs to one Life Area, owns its Goal Path lineage, may have related Steps, Events, Reminders, Proof, Closures, Recovery Segments, placements, sources, Receipts, and History Events, and never duplicates those records.

<!-- canon-section: lifecycle -->
User-controlled lifecycle is Draft, Ready to Activate, Active, Paused, Completed, Ended, Archived, Trashed, restored, or permanently deleted. Needs Attention, Recovering, Waiting, and Blocked are advisory/recovery axes, never lifecycle replacements; Abandoned is invalid.

<!-- canon-section: valid-transitions -->
Valid transitions include Draft→Ready to Activate after sufficient clarification; Ready→Active after material preview; Active↔Paused; Active/Paused→Completed or Ended through honest Closure; Completed/Ended→Archived; supported live states→Trash; Trash→prior valid state; and resumable Paused/Ended/Archived→an explicitly reviewed active state when semantics permit.

<!-- canon-section: invalid-transitions -->
Invalid transitions include advisory state silently changing lifecycle, Abandoned as a state, generated path auto-activation without confirmation, Reminder acknowledgement completing a Goal, Proof attachment fabricating completion, archive deleting history, or permanent deletion without scoped consequence review.

<!-- canon-section: commands -->
Create, clarify, activate, edit, pause, resume, close, complete, end, archive, restore, Trash, restore from Trash, and permanently delete route through `Command → Event → Projection → Receipt → Replay`; rejected or partial pathing retains the provisional shell and emits truthful failure/rejection lineage.

<!-- canon-section: recurrence-scheduling -->
Goals do not recur as duplicate identities and do not occupy time directly. Goal Path Steps use recurrence series and Schedule Placement relationships; deadlines and pace are separate time/planning facts requiring material preview.

<!-- canon-section: deletion-trash-restore-archive -->
Completion, Ended, Closure, archive, Trash, and permanent deletion are distinct. Trash preserves recoverable graph lineage; restore revalidates paths and placements; permanent deletion confirms dependent-object, history/search, export, recurrence, and approved-continuity tombstone scope.

<!-- canon-section: history-receipts -->
Creation, activation, lifecycle change, material path/schedule edit, proof-sensitive rule change, closure, archive, Trash, restore, and permanent deletion produce automatic Receipts and replayable History Events. User Proof remains separate evidence.

<!-- canon-section: privacy-sync-classification -->
Intent, Life Area, path, Steps, Proof, resources, constraints, schedule fit, recovery, and learning are private local graph data excluded from Account, R2, Source Atlas, and hosted AI. Any future approved continuity preserves local authority and explicit conflict/deletion law.

<!-- canon-section: import-export -->
Imported or shared intent creates a reviewed local Goal or Source Reference; it never becomes authoritative remotely. Export is explicit and scoped. Re-import reconciles stable provenance and conversion lineage rather than cloning the Goal.

<!-- canon-section: projection-surfaces -->
Goals is primary; Today and Time show action/placement context, You may show Life Capital context, and Search/Trust inspect it. Projections preserve canonical ID and never mutate directly.

<!-- canon-section: accessibility -->
Semantic order is outcome, lifecycle, advisory/recovery state, next Step, proof rule, schedule consequence, path position, rationale, and actions. Goal Path remains available as an ordered nonvisual list; confirmation and recovery do not require gesture or color.

VoiceOver exposes each action with the affected Goal and consequence in its label or hint.

<!-- canon-section: source-test-ownership -->
Canonical target ownership is `Core/Domain/` plus `Core/LocalRuntimeOS/Planning/`, `Commands/`, `Scheduling/`, and `Inspection/`; `Surfaces/Goals/` presents it and `Quality/` owns generated-route, lifecycle/advisory separation, recovery/closure, receipt/replay, deletion, privacy, offline, and accessibility proof. Current implementation compliance is unclaimed.
