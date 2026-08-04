# Implementation Plan

## Outcome and boundary

Introduce `DestinationDirection` as the durable pre-Goal owner and implement the
explicit handoff from an advisory candidate to exactly one provisional Goal.
Duplicate review has four distinct outcomes: open is navigation-only, relate
creates only a private relationship and dormant direction, refine reruns review,
and continue-distinct alone may create a Goal. Changed-destination pivots never
rewrite the old Goal; each owner mutation reports its own result, or an all-or-
none request is handed to Life Branch assessment.

## Affected components and exact files

- Add `docs/canon/specifications/objects/destination-direction.md`; update
  `objects/goal.md`, `journeys/goal-creation-and-activation.md`,
  `systems/private-life-runtime.md`, and `systems/local-learning.md`.
- Add `Native/Ambitions/Core/Domain/DestinationDirection/DestinationDirectionModels.swift`,
  `DestinationAdoptionModels.swift`, and `ProgressRelationshipModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/DestinationAdoption/DestinationAdoptionCoordinator.swift`
  and `DestinationDuplicatePolicy.swift`.
- Add `Commands/DestinationDirectionCommandService.swift`,
  `Commands/CreateProvisionalGoalFromDirectionCommand.swift`,
  `State/DestinationDirectionStore.swift`,
  `State/AdoptionReviewCheckpointStore.swift`, and
  `Projections/DestinationDirectionProjector.swift`.
- Add `Native/Ambitions/Surfaces/Goals/DestinationAdoptionView.swift` and
  `DestinationPivotReviewView.swift`.

## Data flow, persistence, and concurrency

The coordinator freezes candidate, outcome, Life Area, duplicate set, selected
existing-object revision, continuity proposals, old Goal revision, and exact
confirmation scope. Direction, relationship, Goal, Closure, Receipt, History,
and Life Branch owners retain their own commands. Checkpoints are private drafts,
not mutation truth. Each operation has an idempotency key and expected revisions;
replay resumes the first unsettled operation and never manufactures aggregate
success. Migration adds empty direction/checkpoint/relationship collections and
never imports legacy North Star values silently. V1 provides no North Star
adapter; any later import requires its own explicit migration/product decision.
Direction lifecycle, relationship creation/removal, and promotion-lineage
events register with the existing semantic event codec and mutation registry.
Only archive/Trash/restore and relationship removal expose typed inverse
commands; Goal creation and promotion lineage are not undone by deleting the
source direction.

## Dependencies, order, and rollout

Depend on capability continuity and at least one recommendation producer; Goal
and Closure owners are existing dependencies. Implement canon/models, durable
direction owner, duplicate branches, distinct Goal handoff, pivot sequencing,
then UI/recovery. Goal-path generation remains a separate next action. Direct
supersession, merge, activation, external writes, and atomic multi-owner pivot
are excluded; the latter goes to Life Branch.
