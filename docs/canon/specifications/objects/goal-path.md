+++
spec_id = "OBJECT-GOAL-PATH"
title = "Goal Path"
kind = "object"
status = "normative"
owner_domain = "object-goal-path"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.goal-path.adaptation-triggers", "object.goal-path.emotional-posture", "object.goal-path.identity-lifecycle", "object.goal-path.receipt",
  "object.goal-path.accessibility",
  "object.goal-path.strategy",
  "object.goal-path.adaptation-boundary",
]
inherits = ["OBJECT-CANONICAL-GRAPH-001", "OBJECT-FUTURE-STEP-IDENTITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-GOAL", "SURFACE-GOALS", "SURFACE-TIME", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Planning/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Goals/", "Native/Ambitions/Quality/"]
+++

# Goal Path

## OBJ-GOAL-PATH-IDENTITY-001 — Versioned adaptive route

- **Concept:** `object.goal-path.identity-lifecycle`
- **Modality:** `MUST`
- **Scope:** Goal Path identity, nodes, and version lineage
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-PATH-ADAPTATION-001`
- **Supersedes:** none

A Goal Path MUST be one versioned, inspectable adaptive route owned by a Goal, with ordered nodes referencing canonical Steps, Proof targets, Recovery Segments, review points, and schedule-change consequences. Nodes do not copy their referenced objects.

Goal Path MUST support Start, Current Position, Recommended step, Step, Substep Group, Proof Moment, Recovery Segment, Schedule Change, Adaptive Change, Decision Point, Pause, Resume, and Closure node roles.

## OBJ-GOAL-PATH-RECEIPT-001 — Material path changes are receipted

- **Concept:** `object.goal-path.receipt`
- **Modality:** `MUST`
- **Scope:** Generated or edited path and schedule state
- **Status:** `normative`
- **Verification:** `SCENARIO-GOAL-PATH-RECEIPT-001`
- **Supersedes:** none

Path generation or editing that changes accepted path or schedule state MUST produce a truthful automatic Receipt and replayable History Event after material confirmation; preview rejection preserves the prior path unchanged.

Goal Path adaptation MUST NOT materially alter the user’s plan silently.

Ambitions MAY classify reordering or rescoping unscheduled work, optional preparation Substeps, suggested placement, and Reminder recommendations as minor adaptation.

When a goal pivots, Ambitions MUST preserve progress.

## OBJ-GOAL-PATH-EMOTIONAL-POSTURE-001 — Personal proof trail with adult forward motion
- **Concept:** `object.goal-path.emotional-posture`
- **Modality:** `MUST`
- **Scope:** Goal Path language, presentation, progress, proof, and recovery
- **Status:** `normative`
- **Verification:** `REVIEW-GOAL-PATH-EMOTIONAL-POSTURE-001`
- **Supersedes:** none

Goal Path MUST feel like a personal, alive, inspectable proof trail with calm forward motion through action, recovery, schedule reality, and accumulated proof. It MUST NOT use quest, points, levels, badges, streak anxiety, childish progression, or other game-pressure framing.

<!-- canon-section: stable-identity -->
One current Goal Path identity retains ordered immutable version lineage. Regeneration, reflow, node edits, and recovery create versions/events, not parallel unlinked paths.

Canonical identifiers route path actions deterministically.

<!-- canon-section: user-meaning -->
The path shows how the Goal can become real, what comes now and later, what changed, and where proof or review matters; it is not a decorative graph or rigid project plan.

Its user-facing contract communicates ordered movement, consequence, and choice.

<!-- canon-section: relationships -->
It belongs to one Goal and references Step identities, including Future Step roles, Proof targets, Recovery Segments, Schedule Placements, Closures, Receipts, and History Events. One Step may have one primary Goal/Path participation while contextual links remain distinct.

<!-- canon-section: lifecycle -->
Lifecycle is provisional, reviewable, active, superseded-version, closed-with-Goal, archived-with-Goal, Trashed-with-governed-scope, restored, or permanently deleted. Node execution/recovery and placement states are orthogonal.

Each lifecycle value has an explicit user consequence and retained lineage rule.

<!-- canon-section: valid-transitions -->
Valid transitions are provisional→reviewable→active; active→new active version after accepted material edit; active→closed with Goal closure; current version→superseded when successor commits; governed Trash/restore; and permanent deletion only through confirmed Goal/path scope.

Accepted transitions record prior identifiers and restoration targets.

<!-- canon-section: invalid-transitions -->
Invalid transitions include automatic activation of material assumptions, copying a Step for Goals and Time, treating Future Step as a second identity, editing a superseded version as current, dropping proof/recovery lineage, or mutating placement without the canonical Step and placement owners.

Validators reject each prohibited transition before persistence.

<!-- canon-section: commands -->
Generate, clarify, review, activate, edit node/order, change pace, accept reflow, add/remove referenced Step, recover, close, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay`, with idempotent versioning and rollback to the last honest path.

<!-- canon-section: recurrence-scheduling -->
The path references recurring Step series and their occurrence scopes; it does not own recurrence identities. Future Step is the same Step in a flexible future role/placement window. Material deadline, pace, recurrence, or placement impact is previewed.

Series edits carry an explicit occurrence scope into the owning Step command.

<!-- canon-section: deletion-trash-restore-archive -->
Closing or archiving a Goal Path does not delete referenced objects or history. Trash previews dependent placements and orphan risk. Restore repairs ordered projections; permanent deletion explicitly resolves referenced-object and version-lineage scope.

Rollback restores prior identifiers while history records the attempted mutation.

<!-- canon-section: history-receipts -->
Every accepted material generation, version, reflow, recovery, closure, Trash, restore, and conversion impact records before/after lineage, assumptions, actor/source, Receipt, replay result, and rollback target. User Proof is referenced, not replaced by the Receipt.

Inspection links each Receipt to canonical object identifiers.

<!-- canon-section: privacy-sync-classification -->
Path assumptions, order, constraints, proof links, schedule impact, and recovery are private local graph data. R2/Source Atlas may provide public references only and never receives the path. Future continuity requires approved conflict/version/deletion law.

Local authority and egress classification remain inspectable on every imported or exported path record.

<!-- canon-section: import-export -->
Imported plans are candidates until reviewed into a local path version. Export is explicit, scoped, and provenance-bearing.

The review records accepted, rejected, and unchanged nodes with source lineage.

<!-- canon-section: projection-surfaces -->
Goals shows the full path, Today shows executable now context, Time shows placements, Motion communicates accepted consequence, and Search/Trust inspect versions. Every projection retains Goal Path and referenced canonical IDs.

<!-- canon-section: accessibility -->
An ordered semantic list exposes node order, current position, state, rationale, proof rule, schedule impact, and actions with Start/Now/Next/Finish navigation; no horizontal visual interpretation, motion, or color is required.

Ordered controls expose state, rationale, and action labels.

<!-- canon-section: source-test-ownership -->
Canonical target ownership is `Core/Domain/` and `Core/LocalRuntimeOS/Planning/`, `Scheduling/`, `Commands/`, and `Inspection/`; `Surfaces/Goals/` presents it and `Quality/` proves generation assumptions, material confirmation, adaptation, Future Step singularity, receipt/replay continuity, rollback, offline, privacy, and nonvisual parity.

Tests bind each mutation scenario to the stable Goal Path and referenced object identifiers.

## OBJ-GOAL-PATH-ADAPTATION-TRIGGERS-001 — Goal Path adaptation triggers

- **Concept:** `object.goal-path.adaptation-triggers`
- **Modality:** `MUST`
- **Scope:** Goal Path adaptation triggers
- **Status:** `normative`
- **Verification:** `REVIEW-OBJ-GOAL-PATH-ADAPTATION-TRIGGERS-001`
- **Supersedes:** none

Goal Path adaptation MAY respond to missed Steps, changed time reality, Proof or completion changes, learned behavior, and new scheduled Steps; material changes MUST remain inspectable, confirmed, receipted, and reversible.

## OBJ-GOAL-PATH-ACCESSIBILITY-001 — Goal Path accessibility

- **Concept:** `object.goal-path.accessibility`
- **Modality:** `MUST`
- **Scope:** Goal Path reading and interaction
- **Status:** `normative`
- **Verification:** `A11Y-GOAL-PATH-001`
- **Supersedes:** none

Goal Path MUST expose route order, node identity, state, next Step, Proof, recovery, and every drilldown action through a nonvisual semantic representation.

## OBJ-GOAL-PATH-STRATEGY-001 — Goal Path strategy

- **Concept:** `object.goal-path.strategy`
- **Modality:** `MUST`
- **Scope:** Goal Path generation and adaptation
- **Status:** `normative`
- **Verification:** `TEST-GOAL-PATH-STRATEGY-001`
- **Supersedes:** none

Goal Path strategy MUST remain inspectable, assumption-bound, editable, and subordinate to user-confirmed Goal intent.

## OBJ-GOAL-PATH-ADAPTATION-BOUNDARY-001 — Goal Path adaptation boundary

- **Concept:** `object.goal-path.adaptation-boundary`
- **Modality:** `MUST`
- **Scope:** Adaptive path changes
- **Status:** `normative`
- **Verification:** `TEST-GOAL-PATH-ADAPTATION-001`
- **Supersedes:** none

Goal Path adaptation MUST preview assumptions and consequences, preserve prior path history, respect protected boundaries, and require confirmation for material change.
