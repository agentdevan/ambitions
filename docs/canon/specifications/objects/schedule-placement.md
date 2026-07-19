+++
spec_id = "OBJECT-SCHEDULE-PLACEMENT"
title = "Schedule Placement"
kind = "object"
status = "normative"
owner_domain = "object-schedule-placement"
canon_revision = 1
profile = "object-v1"
owns_concepts = ["object.schedule-placement.identity", "object.graph.single-canonical", "object.graph.projection-ownership",
  "object.schedule-change-set.identity",
  "object.scheduling.exactness",
  "object.schedule-placement.atomicity",
]
inherits = ["OBJECT-CANONICAL-GRAPH-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONST-RUNTIME-MUTATION-001"]
depends_on = ["CONSTITUTION", "OBJECT-STEP", "OBJECT-EVENT", "SURFACE-TIME", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Core/Domain/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
+++

# Schedule Placement

## OBJ-SCHEDULE-PLACEMENT-IDENTITY-001 — Relationship between object and Time

- **Concept:** `object.schedule-placement.identity`
- **Modality:** `MUST NOT`
- **Scope:** Schedule Placement identity and object-copy boundary
- **Status:** `normative`
- **Verification:** `SCENARIO-SCHEDULE-PLACEMENT-ORTHOGONAL-001`
- **Supersedes:** none

A Schedule Placement is one identified relationship between a canonical capacity-bearing object and Time, containing range/window, fixed/flexible/protected state, fit assumptions, and reflow rule. It MUST NOT duplicate the Step or Event or acquire its lifecycle/execution identity.

Goals MAY have target dates or windows, while Steps, Reminders, and Events MUST carry exact scheduling when scheduled.

A Schedule Placement MUST relate one object to Time.

A Placement MUST be the relationship between an object and time reality.

Ambitions MUST NOT create vague someday goals.

## SYS-CANONICAL-GRAPH-001 — One graph across objects and surfaces

- **Concept:** `object.graph.single-canonical`
- **Modality:** `MUST`
- **Scope:** Canonical object graph
- **Status:** `normative`
- **Verification:** `SCENARIO-CANONICAL-IDENTITY-001`
- **Supersedes:** none

The Atlas MUST represent one canonical local identity graph of objects and typed relationships. Surface, Search, widget, App Intent, import, accessibility, and Time views resolve graph identifiers and cannot become separate stores.

Surfaces MUST be lenses.

## SYS-PROJECTION-OWNERSHIP-001 — Projections never own divergent copies

- **Concept:** `object.graph.projection-ownership`
- **Modality:** `MUST NOT`
- **Scope:** Read projection and mutation routing
- **Status:** `normative`
- **Verification:** `AUDIT-PROJECTION-OWNERSHIP-001`
- **Supersedes:** none

A projection MUST NOT own a divergent object copy or mutate canonical state directly. An actionable projection carries canonical object/relationship identifiers and routes a typed command to the owning runtime authority.

Surfaces MUST NOT own divergent copies of canonical objects.

Projection loss MUST NOT equal user-data loss.

<!-- canon-section: stable-identity -->
Placement identity survives range/window edits, reflow, conflict, protection, detachment, Trash governed by the subject, restore, and projection changes. It always references one canonical subject identity.

<!-- canon-section: user-meaning -->
Schedule Placement answers when a Step or Event is expected to occupy time and how flexibly it may move. The user sees time consequence without a duplicate object.

<!-- canon-section: relationships -->
It references one Step/Event subject, range or window, recurrence occurrence where applicable, protection/flexibility policy, conflicts, source, Receipts, and History Events. Subject lifecycle remains authoritative.

<!-- canon-section: lifecycle -->
Relationship lifecycle is proposed, accepted, detached, superseded-with-lineage, Trashed with governed subject/scope, restored, or permanently deleted; fixed/flexible/protected, conflict, time, execution, and recovery are orthogonal axes.

<!-- canon-section: valid-transitions -->
Valid transitions include proposed→accepted after material preview, accepted→moved/reflowed/protected/flexed through commands, accepted→detached, scoped occurrence edits, governed Trash/restore, and deletion after consequence review. Each change retains subject identity.

<!-- canon-section: invalid-transitions -->
Invalid transitions include creating a Step/Event copy, placement changing subject lifecycle/execution/proof, auto-moving protected/fixed time outside authority, hidden external content leaking through capacity, or recurrence mutation without scope. Validators reject the placement change before commit.

<!-- canon-section: commands -->
Propose, accept, move, resize/window, protect/unprotect, change flexibility/reflow rule, detach, resolve conflict, Trash, restore, and delete use `Command → Event → Projection → Receipt → Replay` with affected objects, tradeoffs, external effects, and rollback preview.

<!-- canon-section: recurrence-scheduling -->
Placement may target a single occurrence, selected future occurrences, entire series, or import range while the recurrence series remains owned by Step/Event. Capacity uses accepted ranges/windows; Reminder triggers and due dates are not placements.

<!-- canon-section: deletion-trash-restore-archive -->
Detaching/removing placement does not delete or complete its subject. Trash/restore follows subject and relationship scope; permanent deletion confirms occurrence/series, protected-time, conflict, external-write, history/search, and rollback consequences.

<!-- canon-section: history-receipts -->
Accepted placement, reflow, protection, conflict resolution, detach, Trash, restore, and external reconciliation produce automatic Receipts and before/after History Events tied to placement/subject/occurrence IDs. These records remain distinct from Proof.

<!-- canon-section: privacy-sync-classification -->
Private ranges/windows, labels, Goal links, constraints, and reflow rules remain local. Privacy-filtered external capacity may influence fit without exposing content; Account/R2 never receive private placement data.

<!-- canon-section: import-export -->
External calendar facts remain capacity or import/link candidates until approved. Import creates a local Event plus placement or a reviewed link; export/writeback is scoped and reconciled separately from local acceptance.

<!-- canon-section: projection-surfaces -->
Time owns primary placement presentation; Today and Goals show fit/path context, Motion shows accepted movement, and Search/Trust inspect it. Projections render subject identity plus relationship state.

<!-- canon-section: accessibility -->
Semantics expose subject, exact range/window, fixed/flexible/protected state, conflict, rationale, affected objects, recurrence scope, and move/resize alternatives without drag, timeline position, motion, or color dependence.

<!-- canon-section: source-test-ownership -->
Relationship semantics belong to `Core/Domain/`; capacity, proposal, reflow, conflict, commands, and inspection belong to `Core/LocalRuntimeOS/Scheduling/`, `Commands/`, and `Inspection/`; Time presents it and `Quality/` proves nonduplication, axes, protected boundaries, recurrence scope, external visibility, rollback/replay, offline, privacy, and accessibility. Tests bind each change to placement and subject identifiers;

## OBJ-SCHEDULE-CHANGE-SET-IDENTITY-001 — Schedule change-set identity

- **Concept:** `object.schedule-change-set.identity`
- **Modality:** `MUST`
- **Scope:** Schedule mutation proposals
- **Status:** `normative`
- **Verification:** `TEST-SCHEDULE-CHANGE-SET-001`
- **Supersedes:** none

A schedule change set MUST have stable identity, ordered proposed mutations, validation state, consequences, commit boundary, rollback linkage, and Receipt linkage.

## OBJ-SCHEDULING-EXACTNESS-001 — Scheduling exactness

- **Concept:** `object.scheduling.exactness`
- **Modality:** `MUST`
- **Scope:** Accepted schedule placements
- **Status:** `normative`
- **Verification:** `TEST-SCHEDULING-EXACTNESS-001`
- **Supersedes:** none

An accepted placement MUST preserve exact subject, interval, authority, recurrence scope, capacity consequence, provenance, and conflict state.

## OBJ-SCHEDULE-PLACEMENT-ATOMICITY-001 — Placement atomicity

- **Concept:** `object.schedule-placement.atomicity`
- **Modality:** `MUST`
- **Scope:** Schedule placement mutation
- **Status:** `normative`
- **Verification:** `TEST-SCHEDULE-PLACEMENT-ATOMICITY-001`
- **Supersedes:** none

A placement mutation MUST atomically preserve object, interval, capacity, conflict, recurrence, History, Receipt, and rollback consistency.
