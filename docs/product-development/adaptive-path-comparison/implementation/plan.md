# Implementation Plan

## Outcome and boundary

Provide side-effect-free comparison of materially distinct route candidates for
the same Goal outcome. The session explains consequences, shared progress,
tradeoffs, assumptions, source boundaries, and continue/pause/bridge/smaller-
first alternatives without ranking a winner. Only explicit confirmation creates
a typed Goal Path handoff; comparison itself owns no Goal, Path, Step, Proof,
placement, schedule, Life Branch, or external mutation.

## Affected components and exact files

- Update `docs/canon/specifications/objects/goal-path.md` and
  `systems/private-life-runtime.md`.
- Add `Native/Ambitions/Core/Domain/GoalEngine/PathComparisonModels.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/PathComparison/PathComparisonCoordinator.swift`,
  `PathDifferenceEngine.swift`, and `PathComparisonExplanationBuilder.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/State/PathComparisonSessionStore.swift`.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Storage/PathComparisonDraftSchema.swift`;
  it registers a protected draft table in `CanonicalRuntimeStore` through
  `RuntimeGenerationDatabaseAuthority` but never enters the canonical object or
  semantic-event mutation registry.
- Add `Native/Ambitions/Surfaces/Goals/PathComparisonView.swift` and
  `PathComparisonDetailView.swift`.

## Data flow, persistence, and concurrency

The actor coordinator freezes Goal, current path, candidate, Capability, Proof,
source, constraint, policy, and clock revisions. The difference engine groups
consequence-equivalent routes, retains omission reasons, and produces stable
material signatures. A private draft store may retain review position, edits,
decision, and handoff checkpoint atomically, but never canonical route authority.
Migration creates an empty v1 draft collection. Generation tokens, expected
revisions, cancellation, checkpoint recovery, and replay prevent stale handoffs;
the Goal Path owner independently revalidates any accepted choice.
`AcceptGoalPathVersionCommand` is the exact activation owner and consumes the
session's `SelectedPathProposalV1` only after full Goal/outcome/path/source/
constraint revalidation.

## Dependencies, order, and rollout

Depend on goal-path generation and the Goal Path owner. Implement models and
difference law, coordinator/session store, explanation, UI, then typed handoff.
Scheduling and Life Branch remain separate consumers. Ship only with bounded
two-to-four candidate fixtures and no scalar score, probability, or generative
selection.
