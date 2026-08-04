# Implementation Plan

## Outcome and boundary

Extend approved Goal Path proposal code with a closed evidence graph,
generative alias composer, validation and semantic deltas. Reuse canonical Path,
comparison and activation owners. Do not implement destination change, automatic
Path/Step/Proof/Time mutation, multi-Goal simulation or external action.

## Exact expected files

- Update/add Goal Path generation canon and relevant Source Atlas/Relationship/
  Current Authority/Capability/Private Runtime/Comparison/Activation/History/
  Evaluation specifications.
- Add task schemas/config/fixtures in
  `tools/generative-runtime/config/tasks/goal-path-proposals-v1/` as
  `task-manifest.json`, `input.schema.json`, `output.schema.json`, `prompt.md`,
  `validation-policy.json`, `fixtures/nasa-astronaut-route.json`,
  `fixtures/sparse-generic-route.json`, and `fixtures/adversarial-graph.json`; add
  `tools/generative-runtime/tests/test_goal_path_proposal_task.py`.
- Add or extend under `Native/Ambitions/Core/Domain/GoalPathGeneration/`:
  `RouteEvidenceGraphModels.swift`, `RouteEvidenceGraphAssembler.swift`,
  `RouteSemanticClassifier.swift`, `RouteEvidenceAdapters.swift`,
  `GenerativeRouteTaskModels.swift`, `GenerativeRouteComposer.swift`,
  `RouteProposalValidationPipeline.swift`, `RouteProposalProjector.swift`,
  `RouteEditableWorkPolicy.swift`, `GroundedGoalPathProposalModels.swift`,
  `GoalPathProposalRepository.swift`, `GoalPathProposalCoordinator.swift`,
  `GoalPathProposalInvalidationService.swift`, `GoalPathProposalMigration.swift`,
  `GoalPathProposalPurgeService.swift`, `RouteMaterialDifferenceClassifier.swift`,
  `RouteProposalDeltaModels.swift`, `RouteProposalDeltaEngine.swift`,
  `GoalPathComparisonInputBuilder.swift`, and
  `GoalPathActivationInputBuilder.swift`; preserve existing
  `GoalPathCompilerService` and types when semantically adequate.
- Update only typed runtime boundary/bootstrap, comparison input and Goal Path
  activation input seams; inject no command or Time client into composition.
- Add or extend UI under `Native/Ambitions/Surfaces/Goals/PathProposal/` as
  `GoalPathProposalOverviewView.swift`, `GoalPathProposalDetailView.swift`,
  `GoalPathProposalDeltaView.swift`, `GoalPathProposalCorrectionView.swift`,
  `GoalPathProposalComparisonView.swift`, and
  `GoalPathProposalPreviewFixtures.swift`; add unit tests under
  `Native/AmbitionsTests/Domain/GoalPathGeneration/` as
  `RouteEvidenceGraphTests.swift`, `GenerativeRouteComposerTests.swift`,
  `RouteProposalValidationTests.swift`,
  `GroundedGoalPathProposalRepositoryTests.swift`, `RouteProposalDeltaTests.swift`,
  `GoalPathProposalComparisonBoundaryTests.swift`,
  `GoalPathProposalActivationBoundaryTests.swift`, and
  `GoalPathProposalPrivacyTests.swift`; add
  `Native/AmbitionsTests/Quality/GoalPathProposalAccessibilityTests.swift` and
  `Native/AmbitionsUITests/GoalPathProposalUITests.swift`.
- Update `project.yml` only if verified new resources require it; regenerate.

Sequence: canon/schemas; evidence graph; semantic adapters; model contract;
validators; proposal/lifecycle; delta; comparison/activation handoffs; UI/
accessibility; integration; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Reuse versus new files,
no-command boundary, task fixture, tests, conditional project edit and proof
ceilings are explicit. Devan delegated approval; grooming approved 2026-08-04.
