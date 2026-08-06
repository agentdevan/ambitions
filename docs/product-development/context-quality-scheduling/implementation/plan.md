# Implementation Plan

## Outcome and boundary

Teach Scheduling to compare the semantic quality of free-time windows for one
Step using surrounding commitments, transitions, recovery, location/tools,
interruption risk, user rules, and explicitly confirmed observations. The
feature offers qualitative fit and a placement/reflow preview; Scheduling alone
may commit a confirmed placement. It does not infer energy/personality, rank the
user, mutate the Step, or treat all free minutes as equivalent.

## Affected components and exact files

- Update `docs/canon/specifications/systems/scheduling-and-capacity.md`,
  `objects/schedule-placement.md`, `journeys/schedule-reflow.md`, and
  `surfaces/time.md`.
- Add `Native/Ambitions/Core/Domain/ContextFit/ContextFitModels.swift` and
  `ContextObservationModels.swift`; the former defines closed qualitative enums
  for focus, effort, interruption, commitment, place/resource, transition,
  setup, recovery, fit, and unknown—never an aggregate numeric score.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ContextFitComparisonCoordinator.swift`,
  `ContextFitPolicy.swift`, and `ContextObservationCoordinator.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/State/ContextObservationStore.swift`
  and `Projections/ContextFitProjector.swift`.
- Add `Native/Ambitions/Surfaces/Time/ContextFitReviewView.swift` and extend
  existing placement preview/confirmation composition through
  `ScheduleInstallPreview` and `ScheduleInstallKernel`; Context Fit receives no
  direct `PlacementEngine` or store write capability.

## Data flow, persistence, and concurrency

Scheduling supplies revisioned Step/window/commitment/transition/recovery/
resource/rule snapshots. Context policy produces qualitative fits and exact
reasons; a confirmed observation may influence later comparisons only through
the explicit local-learning contract. Preview remains simulation. Confirmation
delegates to the existing Schedule Placement command and protected-placement
policy. The observation store starts empty and records correction, disable,
reset, archive/Trash/restore/delete with events and replay. Actor isolation,
generation tokens, expected revisions, and idempotency prevent stale placement
or duplicated learning. Observation tables register inside
`CanonicalRuntimeStore` through `RuntimeGenerationDatabaseAuthority`; retention
and deletion inherit Local Learning/privacy canon instead of a new subsystem.

## Dependencies, order, and rollout

Depend on existing Scheduling and Capability/local-learning contracts; Goal Path
is only a Step source. Implement models/policy, observation lifecycle, comparison
coordinator, projection/UI, then placement integration. Start with explicit user
entry and synthetic schedule fixtures. Passive background inference, health
claims, fixed chronotypes, and automatic schedule mutation remain excluded.
