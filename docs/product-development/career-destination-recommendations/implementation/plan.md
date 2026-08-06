# Implementation Plan

## Outcome and boundary

Deliver local, inspectable career exploration in separate continuity and
aspiration lanes. Candidate composition joins user-selected direction and
Capability projections with verified public career references entirely on
device. Results are possibilities, not fit scores, predictions, hiring or
licensing decisions, Goals, or routes. Saving preference state is explicit;
Goal creation belongs to destination-adoption-and-pivot.

## Affected components and exact files

- Add `docs/canon/specifications/systems/career-destination-recommendations.md`;
  update `systems/local-learning.md`, `systems/private-life-runtime.md`,
  `systems/source-atlas.md`, and `surfaces/you.md`.
- Add `Native/Ambitions/Core/Domain/CareerRecommendation/CareerRecommendationModels.swift`
  and `CareerPreferenceModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/CareerExploration/CareerExplorationCoordinator.swift`,
  `CareerEligibilityPolicy.swift`, `CareerCandidateComposer.swift`, and
  `CareerExplanationBuilder.swift`.
- Add `Commands/CareerPreferenceCommandService.swift`,
  `State/CareerPreferenceStore.swift`, and
  `Projections/CareerRecommendationProjector.swift`.
- Add `Native/Ambitions/Surfaces/Goals/CareerExplorationView.swift` and
  `Native/Ambitions/Trust/CareerRecommendationInspectionView.swift`.

## Data flow, persistence, and migration

The actor coordinator freezes selected direction, Capability and preference
revisions, approved public artifact revisions, policy, consent, and clock. It
requests public artifacts only by fixed public IDs, performs the private join
locally, classifies derived output, and deterministically emits qualitative
lane projections with rationale and uncertainty. Aspiration disambiguation uses
a bounded in-memory index built from the verified local public snapshot; it has
no persistent search index and cannot shape a remote request. Only explicit dismiss,
correction, exclusion, save, archive, Trash, restore, or deletion commands are
durable. The new preference store starts empty; no historical recommendation,
North Star, Goal, or Source Atlas score is migrated. Replay rebuilds preferences
and saved directions, never the transient candidate set.

## Dependencies, order, and rollout

Hard dependencies are capability-continuity-foundation and public-reference-
knowledge-foundation. Implement canon/models, policy/composition, preferences,
projection/inspection, and UI in that order. Destination adoption consumes a
typed candidate handoff later. Ship behind an explicit entry point with
synthetic verified career fixtures first; no hosted matching, account, automatic
Goal creation, passive inference, or general success probability is permitted.
