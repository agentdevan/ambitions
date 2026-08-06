# Implementation Plan

## Outcome and boundary

Implement the deterministic local observation/hypothesis/influence runtime,
explicit activation/correction controls and non-mutating owner replan proposals.
Do not implement auto-active implicit learning, hidden profiles/scores, cloud/
model learning, Capability decay or canonical/external mutation.

## Exact expected files

- Update `docs/canon/specifications/systems/local-learning.md`; update privacy,
  Personal Context, Capability, planning/scheduling/Goal Path/Life Branch,
  History/Receipts, trust/degraded, deletion and evaluation canon.
- Add policy schemas/config/golden histories under `tools/local-learning/` with
  `models.py`, `policy_validator.py`, `golden_runner.py`, `cli.py`, `contracts/`,
  `config/`, `fixtures/`, `tests/`; the minimum exact artifacts are
  `contracts/learning-observation-v1.schema.json`,
  `contracts/learning-policy-v1.schema.json`,
  `contracts/planning-influence-v1.schema.json`,
  `config/local-learning-policies-v1.json`,
  `fixtures/confirmed-correction-history.json`,
  `fixtures/counterevidence-history.json`,
  `fixtures/rebuild-order-history.json`,
  `tests/test_policy_validation.py`, and `tests/test_golden_histories.py`.
- Add under `Native/Ambitions/Core/LocalRuntimeOS/LocalLearning/`:
  `LearningObservationModels.swift`, `LearningObservationAdapters.swift`,
  `LearningObservationLedger.swift`, `PatternHypothesisModels.swift`,
  `LearningPolicyRegistry.swift`, `LearningIncrementalAggregator.swift`,
  `LearningRebuildService.swift`, `PlanningInfluenceModels.swift`,
  `PlanningInfluenceRepository.swift`, `LearningMutationModels.swift`,
  `LearningMutationService.swift`, `LearningConsumerCapabilityRegistry.swift`,
  `PlanningInfluenceReadClient.swift`, `InfluenceUseRecorder.swift`,
  `LearningInfluenceProjector.swift`, `LearningDependencyIndex.swift`,
  `LearningImpactPlanner.swift`, `OwnerReplanClients.swift`,
  `AdaptiveReplanProposalModels.swift`, `AdaptiveReplanProposalAssembler.swift`,
  `LocalLearningMigration.swift`, `LocalLearningInvalidationService.swift`,
  `LocalLearningLifecycleService.swift`, `LocalLearningPurgeService.swift`,
  `LocalLearningSecurityValidator.swift`, and `LocalLearningDiagnostics.swift`.
- Add exact owner adapters in that directory; update only typed owner read/
  simulation boundaries and bootstrap. Inject no command client into replan.
- Add learning controls/influence/replan UI under
  `Native/Ambitions/Surfaces/You/LocalLearning/` as
  `LocalLearningControlsView.swift`, `PatternHypothesisReviewView.swift`,
  `PlanningInfluenceDetailView.swift`, `AdaptiveReplanView.swift`, and
  `LocalLearningPreviewFixtures.swift`; add `WhyThisChangedSheet.swift` under
  `Native/Ambitions/Surfaces/Shared/LocalLearning/`.
- Add unit tests under `Native/AmbitionsTests/LocalRuntimeOS/LocalLearning/`,
  specifically `LearningObservationAdapterTests.swift`,
  `LearningObservationLedgerTests.swift`, `LearningPolicyEngineTests.swift`,
  `PatternHypothesisTests.swift`, `PlanningInfluenceActivationTests.swift`,
  `PlanningInfluenceReadBoundaryTests.swift`, `LearningCorrectionTests.swift`,
  `AdaptiveReplanProposalTests.swift`, `LocalLearningMigrationPurgeTests.swift`,
  and `LocalLearningPrivacySecurityTests.swift`; add
  `Native/AmbitionsTests/Quality/LocalLearningAccessibilityTests.swift` and
  `Native/AmbitionsUITests/LocalLearningUITests.swift`.
- Add generated signed policy registry resource; update `project.yml` and
  regenerate only if verified inclusion requires it.

Sequence: canon/contracts; observation adapters/ledger; deterministic policy;
hypothesis UI/activation; influence consumers/use; corrections; dependency/
replan; lifecycle/purge; accessibility; integration/resources; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact policy/native/UI/
test owners, owner adapters, no-command boundary and excluded auto-activation are
named. Devan delegated approval; grooming approved 2026-08-04.
