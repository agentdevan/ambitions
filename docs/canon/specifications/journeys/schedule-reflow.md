+++
spec_id = "JOURNEY-SCHEDULE-REFLOW"
title = "Schedule Reflow"
kind = "journey"
status = "normative"
owner_domain = "journey-schedule-reflow"
canon_revision = 1
profile = "journey-v1"
owns_concepts = ["journey.time-direct-manipulation.conflict-preview"]
inherits = ["CONTROL-FORCE-NOTHING-001", "CONTROL-MATERIAL-CONFIRMATION-001", "CONTROL-UNDO-RECOVERY-001", "LAW-RUNTIME-DURABLE-SUCCESS-001"]
depends_on = ["CONSTITUTION", "SURFACE-TIME", "OBJECT-SCHEDULE-PLACEMENT", "OBJECT-STEP", "OBJECT-EVENT", "OBJECT-RECOVERY-SEGMENT", "GLOBAL-MOTION"]
source_owners = ["Native/Ambitions/Surfaces/Time/", "Native/Ambitions/Stage/Motion/", "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/", "Native/Ambitions/Core/LocalRuntimeOS/Commands/", "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/", "Native/Ambitions/Core/LocalRuntimeOS/Inspection/", "Native/Ambitions/Quality/"]
+++

# Schedule Reflow

This shadow journey coordinates changed-time consequences without redefining Step, Event, placement, recurrence, or recovery lifecycle.

## JOURNEY-TIME-DIRECT-MANIPULATION-001 — Spatial change previews conflict before commit

- **Concept:** `journey.time-direct-manipulation.conflict-preview`
- **Modality:** `MUST`
- **Scope:** Move, resize, grouped adjustment, and named accessibility alternatives
- **Status:** `normative`
- **Verification:** `SCENARIO-JOURNEY-TIME-DIRECT-MANIPULATION-001`
- **Supersedes:** none

Direct manipulation or its named alternative MUST produce a non-durable preview of conflicts, protected/fixed boundaries, affected objects, capacity, recurrence scope, and external effects. No drop gesture commits a material change without valid confirmation or an exact revocable rule.

Simple reflows MUST show inline ghost previews directly in the grid before commit.

When the user causes an adjustment by adding a new Step, adding a new Goal, changing a deadline, changing a constraint, or creating a conflict, Ambitions SHOULD show the impact.

If a Goal does not fit and the user chooses to add it anyway, Ambitions SHOULD create the Goal and path while keeping the conflict visible until resolved.

Capabilities and other Life Capital MUST be manually editable.

<!-- canon-section: trigger-starting-state -->
Triggers are drag/resize, Move it, Make this fit, Resolve conflict, new capacity fact, or changed commitment; starting state captures canonical placements, current range/time zone, protected/fixed/flexible rules, recurrence scope, source authority, and pending external state.

<!-- canon-section: preconditions -->
Affected identities and current placements resolve; scheduling facts are fresh enough to simulate; external-only capacity remains distinct from native objects; named controls provide parity for every spatial action.

<!-- canon-section: happy-path -->
Simulate candidate movement locally, show a non-durable before/after consequence set and alternatives, let the user reject/edit/accept, validate current facts and authority, confirm material scope, commit local placements atomically, project the result, issue Receipts, then queue external effects.

<!-- canon-section: branches -->
Branches are move one, resize, occurrence/future/series scope, grouped adjustment, protect/fix, accept a visible conflict, choose a lighter path, defer, or reject all. No recommendation forces movement.

<!-- canon-section: cancellation -->
Before commit, cancellation discards the candidate geometry and restores the canonical placement projection and semantic focus.
Canceling a gesture, simulation, or review restores the original visual and semantic state with no durable mutation; canceling external dispatch after local commit follows reconciliation rules rather than pretending the commit vanished.

<!-- canon-section: interruption-resume -->
Before commit, resume the preview with original/current fact revisions and mark it stale when necessary. After commit, resume from durable placements and explicit pending/succeeded/failed external results, never from a drag ghost.

<!-- canon-section: commit-boundary -->
Gesture, candidate coordinates, conflict calculation, and preview are explicitly non-durable. The boundary is confirmed, revalidated atomic local commit and Receipt; external calendar/notification writes occur only afterward and retain separate status.

<!-- canon-section: failure -->
Invalid overlap, protected-boundary violation, stale recurrence/source fact, local rejection, partial projection, or external-write failure preserves last valid canonical placements and identifies exactly what did or did not change.

<!-- canon-section: recovery -->
Offer refresh simulation, choose another slot/scope, retain conflict, reduce grouped scope, retry external reconciliation idempotently, inspect Receipt, or restore the last valid schedule.

<!-- canon-section: undo-rollback -->
Undo/rollback revalidates and restores prior placements as a new canonical mutation with history. Group rollback is atomic locally; external reversals are queued and reconciled per affected item.

<!-- canon-section: receipts-proof -->
Receipts record initiating reason, affected IDs, before/after placements, protected/fixed decisions, recurrence scope, confirmation/rule, local commit, external result, and rollback. Schedule change does not create user Proof.

<!-- canon-section: accessibility -->
Named move/resize controls, date/time pickers, conflict summaries, and ordered before/after lists equal every drag action; VoiceOver announces consequence and result, Dynamic Type can use List, reduced motion uses static outlines/immediate updates, and focus returns to the changed object.

<!-- canon-section: offline -->
Ambitions-owned simulation, conflict review, placement commit, receipts, replay, and rollback work offline. External facts use the last explicitly labeled local snapshot; new external effects remain queued without blocking local truth.

<!-- canon-section: scenario-tests -->
Execute `SCENARIO-JOURNEY-TIME-DIRECT-MANIPULATION-001`, `SCENARIO-JOURNEY-REFLOW-PROTECTED-001`, `SCENARIO-JOURNEY-REFLOW-GROUPED-001`, `SCENARIO-JOURNEY-REFLOW-RECURRENCE-001`, `SCENARIO-JOURNEY-REFLOW-EXTERNAL-FAILURE-001`, and `SCENARIO-JOURNEY-REFLOW-ROLLBACK-001`; assert preview non-durability, named-action parity, atomic local commit, Force Nothing, external-after-local ordering, receipts, replay, and focus.
