# Implementation Plan

## Outcome and boundary

Generate a revision-bound, inspectable candidate route for one stable Goal and
allow explicit adoption as a new version of that Goal's single current Goal
Path. The route may contain sourced gates, accepted alternatives, preparation,
milestones, intermediate roles, assessments, credentials, Steps, Proof targets,
uncertainty, fallbacks, and freshness triggers. It is a scenario, not a success
prediction, destination change, schedule, completed requirement, or external
acceptance claim.

## Affected components and exact files

- Update `docs/canon/specifications/objects/goal-path.md`, `objects/goal.md`,
  `journeys/goal-creation-and-activation.md`, and
  `systems/private-life-runtime.md`.
- Add `Native/Ambitions/Core/Domain/GoalEngine/GoalPathGenerationModels.swift`
  and `GoalPathRequirementModels.swift`; keep existing `GoalCompiledPath` v1
  callers behind a read-only
  `Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalPathGeneration/GoalPathGenerationLegacyAdapter.swift`
  during migration rather than reinterpreting or replacing stored v1 values.
- Add `Native/Ambitions/Core/LocalRuntimeOS/Planning/GoalPathGeneration/GoalPathGenerationCoordinator.swift`,
  `GoalPathCandidateMaterializer.swift`, and `GoalPathExplanationBuilder.swift`.
- Add `Commands/AcceptGoalPathVersionCommand.swift`,
  `State/GoalPathReviewDraftStore.swift`,
  `Storage/GoalPathReviewDraftSchema.swift`, and extend
  `Projections/PathIntelligenceProjector.swift`.
- Add `Native/Ambitions/Surfaces/Goals/GoalPathGenerationView.swift` and
  `GoalPathReviewView.swift`.

## Data flow, persistence, and migration

The coordinator freezes Goal/outcome, current Goal Path, selected Capability,
Proof, source, user constraint, policy, and clock revisions. Verified public
claims remain Source References; local deterministic materialization produces
candidate route graphs and explanations. Review drafts are private and non-
authoritative. A `GoalPathReviewDigest` is SHA-256 over canonical encoding of
the candidate, source/fact manifest, Goal/current-path revisions, policy, and
confirmation scope; it detects in-process handoff drift without claiming remote
or cryptographic authority. Acceptance revalidates the full read set and sends one typed
version command to the Goal Path owner, preserving prior versions and lineage.
Migration adds an empty review-draft schema only; existing accepted Goal Paths
are not reinterpreted. `AcceptGoalPathVersionCommand` is the exact owner input
that consumes either a reviewed generation candidate or the adaptive comparison
`SelectedPathProposalV1` after fresh validation. CAS, idempotency, cancellation, and replay preserve one
current path and never duplicate canonical objects.

## Dependencies, order, and rollout

Depend on public references and destination adoption for newly chosen outcomes;
Capability is optional input, not authority. Implement models/claim grammar,
legacy read adapter, materialization, drafts, version acceptance, projections/UI, then adaptive-
comparison compatibility. Scheduling remains a later explicit handoff. Roll out
with synthetic route fixtures and no generative certification or hosted private
context.
