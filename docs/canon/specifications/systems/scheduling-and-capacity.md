+++
spec_id = "SYSTEM-SCHEDULING-CAPACITY"
title = "Scheduling and Capacity"
kind = "system"
status = "normative"
owner_domain = "system-scheduling-capacity"
canon_revision = 1
profile = "system-v1"
owns_concepts = ["system.scheduling.capacity", "system.scheduling.reflow", "system.scheduling.transition-buffer",
  "system.scheduling.fit",
  "system.scheduling.infeasibility",
]
inherits = ["MISSION-REFLOW-001", "TIME-EXTERNAL-VISIBILITY-001", "CONTROL-MATERIAL-CONFIRMATION-001", "RUNTIME-MUTATION-SEQUENCE-001"]
depends_on = ["CONSTITUTION", "SURFACE-TIME", "OBJECT-SCHEDULE-PLACEMENT", "JOURNEY-SCHEDULE-REFLOW", "SYSTEM-PRIVATE-LIFE-RUNTIME"]
source_owners = ["Native/Ambitions/Core/Time/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Quality/"]
+++

# Scheduling and Capacity

This shadow system target defines capacity and reflow behavior; object and journey specifications retain identity and user-flow law.

## SYSTEM-SCHEDULING-CAPACITY-001 — Capacity is honest and semantically unequal

- **Concept:** `system.scheduling.capacity`
- **Modality:** `MUST`
- **Scope:** Protected, Fixed, Flexible, Suggested, external-visible, external-capacity-only, recurrence, time-zone, and recovery time
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-SCHEDULING-CAPACITY-001`
- **Supersedes:** none

Capacity MUST derive from canonical placements, constraints, recurrence, locale/calendar/time-zone rules, user availability and energy, and reviewed external-capacity decisions. External visibility and capacity reservation remain separate. Protected time is not violated by default, Fixed time requires scoped override, Flexible time moves only within its rule, and Suggested time is not committed capacity.

Today fit suggestions SHOULD appear only when open space satisfies duration, transition buffer, Protected and Fixed boundaries, upcoming Event risk, deadline safety, learned completion likelihood, Step shape, and a clear user-facing reason.

External candidate visibility and capacity awareness MUST be separate.

Ambitions MUST NOT treat all time as equivalent.

Ambitions MUST state when current constraints cannot accommodate all work by the deadline.

Priority MUST tell Ambitions how much a Goal matters.

Priority MUST be both inferred and user-controlled.

## SYSTEM-SCHEDULING-REFLOW-001 — Reflow is inspectable and locally committed

- **Concept:** `system.scheduling.reflow`
- **Modality:** `MUST`
- **Scope:** Placement, resize, defer, recurrence edit, missed work, conflict, import, completion, and recovery
- **Status:** `normative`
- **Verification:** `SCENARIO-SYSTEM-SCHEDULING-REFLOW-001`
- **Supersedes:** none

A material schedule change MUST present the trigger, changed objects, before/after placements, protected/fixed boundaries, conflicts, downstream Goal/deadline/notification/external effects, rationale, confirmation scope, and rollback. Preview is non-durable; acceptance follows the runtime mutation sequence and local commit before notification/EventKit/widget effects.

Reflow MUST consider deadline safety, calendar fit, Protected and Fixed boundaries, Goal priority, learned completion behavior, Step shape, energy and context, transitions, and downstream impact and MUST show near-term conflicts without silently moving near-term work; minor future placement changes MAY commit without blocking confirmation only when explicitly authorized outside Protected, Fixed, and protected near-term boundaries and MUST remain visible through an inline marker, Receipt, History, and Undo; material or grouped changes MUST require confirmation.

## SYSTEM-SCHEDULING-TRANSITION-BUFFER-001 — Transition time is inspectable capacity
- **Concept:** `system.scheduling.transition-buffer`
- **Modality:** `MUST`
- **Scope:** Optional location-aware pre-event and post-event time
- **Status:** `normative`
- **Verification:** `SCENARIO-SCHEDULING-TRANSITION-BUFFER-001`
- **Supersedes:** none

When sufficient local context exists, Scheduling MAY propose inspectable pre-event or post-event transition buffers that consume capacity. It MUST NOT insert them silently unless an explicit user rule permits it. Manual locations and no-location use remain first class; location permission is just in time, and network routing is optional enrichment rather than core authority.

Events and scheduled Steps MAY carry a manual or permission-backed location.

## SYSTEM-SCHEDULING-FIT-001 — Scheduling fit

- **Concept:** `system.scheduling.fit`
- **Modality:** `MUST`
- **Scope:** Placement and reflow
- **Status:** `normative`
- **Verification:** `TEST-SCHEDULING-FIT-001`
- **Supersedes:** none

Scheduling fit MUST evaluate temporal authority, capacity, duration, recurrence, deadlines, travel or transition needs, protected boundaries, and user preference without silently mutating state.

## SYSTEM-SCHEDULING-INFEASIBILITY-001 — Scheduling infeasibility

- **Concept:** `system.scheduling.infeasibility`
- **Modality:** `MUST`
- **Scope:** Unsatisfied scheduling constraints
- **Status:** `normative`
- **Verification:** `SCENARIO-SCHEDULING-INFEASIBILITY-001`
- **Supersedes:** none

When constraints are infeasible, scheduling MUST preserve state, explain the blocking constraints, offer user-controlled repair options, and avoid false certainty or silent degradation.

## Completeness contract

<!-- canon-section: responsibility-non-responsibility -->
Owns capacity calculation, constraint evaluation, recurrence expansion, placement, conflict, reflow, recovery windows, and schedule change sets. It does not own Event/Step identity, external adapter authority, surface layout, notification delivery, or silent automation permission.

<!-- canon-section: inputs-outputs -->
The contract consumes canonical temporal facts and emits a reviewed fit result.
Inputs are canonical objects/placements, dependencies, duration/range/recurrence/time-zone, Protected/Fixed/Flexible/Suggested rules, capacity/energy, external capacity decisions, policy revision, clock, and user automation scope. Outputs are deterministic fit result, proposal/change set, conflicts/tradeoffs, confirmation requirement, accepted command, Receipt, and rollback plan.

<!-- canon-section: authority-boundary -->
`Core/LocalRuntimeOS/Scheduling/` owns scheduling policy; `Core/Time/` owns temporal primitives; Time presents; adapters provide facts and receive outbox effects. No external calendar, notification scheduler, view, or hosted planner mutates canonical schedule state.

<!-- canon-section: data-classification -->
Schedules, capacity, availability, protected boundaries, inferred fit, conflicts, and recovery are private graph data. External effects receive only user-approved minimum fields; R2/Source Atlas receive none of this context.

<!-- canon-section: state-model -->
The state model binds each placement to one object, rule, scope, and lifecycle phase.
Placements preserve object identity and distinguish proposed, committed, moved, conflicted, deferred, canceled, completed, missed/recovery, and externally pending states plus recurrence scope and rule revision.

<!-- canon-section: failure-recovery -->
Invalid or impossible plans remain proposals with explicit constraint failures. Interrupted reflow restores the last committed schedule; partial external failure retains accepted local state and offers reconcile/retry/undo. Time-zone/DST/source changes trigger deterministic review.

<!-- canon-section: local-network-boundary -->
Scheduling, capacity, reflow, conflict review, and recovery operate fully offline/no-account from local facts. Network/reference unavailability yields conservative local behavior, never a blocked core or fabricated fit.

<!-- canon-section: determinism -->
Equivalent canonical schedule, temporal culture, constraints, policy, clock, and seed produce equivalent placement/change sets. Tie-breaking is stable and recorded; network timing cannot change accepted order.

<!-- canon-section: observability -->
Local redacted traces bind fit inputs, selected change, and durable result.
Inspection records trigger, input revisions, constraint/policy version, candidates considered, selected/rejected reasons, before/after placement facts, protected boundaries, confirmation, Receipt, rollback, and external result with private content redacted from diagnostics.

<!-- canon-section: source-ownership -->
Exact target owners are `Core/Time/`, `Core/LocalRuntimeOS/Scheduling/`, `Commands/`, and `Inspection/`; `Surfaces/Time/` presents and `Quality/` proves.

<!-- canon-section: tests-proof -->
Cover Protected/Fixed/Flexible/Suggested rules, overload, impossible deadline, recurrence/exception scopes, DST/time-zone/calendar/locale, external-hidden-capacity, conflict and no-safe-fit, material confirmation, cancellation/interruption, duplicate commands, replay/undo, notification/external-write failure, offline, accessibility summaries, and historical policy replay.

<!-- canon-section: performance-resource-constraints -->
Expansion, simulation, search, and reflow are bounded, cancellable, off-main where material, and use explicit product-scale caps without inventing values here. Article 31 calibration must define representative horizon/object/recurrence/conflict scale, device/OS/build/tool, warm/cold state, percentile/maximum, energy/memory, and regression threshold before implementation authorization or performance Green.
