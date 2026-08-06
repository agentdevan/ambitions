# Implementation Plan

## Outcome and boundary

Implement revisioned ambition interpretation and grounded destination proposal
sets over admitted corpora/private runtime, with exact validation, accessible
inspection and adoption input. Do not implement path generation, automatic Goal
creation, hidden profiles, hosted search, source content or external actions.

## Exact expected files

- Add `docs/canon/specifications/systems/grounded-destination-proposals.md`; update
  recommendation, Goal/destination, Capability, Source Atlas/current authority,
  private runtime, trust/degraded and adoption specifications.
- Add task bundle/contracts/golden fixtures under
  `tools/generative-runtime/config/tasks/destination-proposals-v1/` as
  `task-manifest.json`, `input.schema.json`, `output.schema.json`, `prompt.md`,
  `validation-policy.json`, `fixtures/astronaut-pivot.json`,
  `fixtures/sparse-sources.json`, and `fixtures/adversarial-aliases.json`; add tests in
  `tools/generative-runtime/tests/test_destination_proposal_task.py`.
- Add the following files under
  `Native/Ambitions/Core/LocalRuntimeOS/Planning/DestinationProposals/`:
  `AmbitionInterpretationModels.swift`, `AmbitionInterpretationRepository.swift`,
  `DestinationCandidateModels.swift`, `DestinationCandidateProvider.swift`,
  `CareerDestinationCandidateProvider.swift`,
  `EducationDestinationCandidateProvider.swift`,
  `HobbyLifeDestinationCandidateProvider.swift`,
  `DestinationEvidenceAdapters.swift`, `DestinationRetrievalPolicy.swift`,
  `DestinationCandidateBundleAssembler.swift`,
  `DestinationGenerationTaskModels.swift`,
  `DestinationProposalValidationPipeline.swift`,
  `GroundedDestinationProposalModels.swift`,
  `GroundedDestinationProposalRepository.swift`,
  `DestinationProposalCoordinator.swift`,
  `DestinationProposalInvalidationService.swift`,
  `DestinationProposalMigration.swift`, `DestinationProposalPurgeService.swift`,
  `DestinationProposalProjections.swift`, and
  `DestinationAdoptionInputBuilder.swift`.
- Update runtime boundary clients/bootstrap and only the existing destination
  adoption input seam; inject no command into the coordinator.
- Add proposal surfaces/components under
  `Native/Ambitions/Surfaces/Goals/DestinationProposals/` as
  `AmbitionInterpretationView.swift`, `DestinationProposalSetView.swift`,
  `DestinationProposalDetailView.swift`, `DestinationProposalComparisonView.swift`,
  `DestinationProposalCorrectionView.swift`, and
  `DestinationProposalPreviewFixtures.swift`.
- Add unit tests under
  `Native/AmbitionsTests/LocalRuntimeOS/Planning/DestinationProposals/` as
  `AmbitionInterpretationTests.swift`, `DestinationCandidateBundleTests.swift`,
  `DestinationProposalValidationTests.swift`,
  `DestinationProposalCoordinatorTests.swift`,
  `DestinationProposalRepositoryTests.swift`,
  `DestinationProposalAdoptionBoundaryTests.swift`, and
  `DestinationProposalPrivacyTests.swift`; add
  `Native/AmbitionsTests/Quality/DestinationProposalAccessibilityTests.swift`
  and `Native/AmbitionsUITests/DestinationProposalUITests.swift`.
- Update `project.yml` only if the new grouped resources/task registry require
  explicit inclusion; regenerate Xcode rather than hand-editing it.

Sequence: canon/task contracts; interpretation; domain providers/bundle;
validators; runtime task; set repository/lifecycle; comparison/inspection;
adoption handoff; accessibility; integration/resources; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact owner directories,
task fixture, validation, adoption and tests are named; project editing is
conditional on verified resource inclusion. Devan delegated approval; grooming
approved 2026-08-04. No implementation/runtime/device/merge evidence is claimed.
