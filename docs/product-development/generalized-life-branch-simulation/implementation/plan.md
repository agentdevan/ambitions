# Implementation Plan

## Outcome and boundary

Implement conformance-first generalized Life Branch simulation and owner-
prepared atomic/saga reconciliation with truthful recovery and external-intent
handoff. Production remains gate-blocked. Do not add raw writes, model commands,
fake rollback/cross-system atomicity or external execution.

## Exact expected files

- Add `docs/canon/specifications/systems/generalized-life-branch.md`; update Life
  Branch/runtime transactions/owners/portfolio/external effects/History/privacy/
  trust/degraded/deletion/evaluation/change canon.
- Add protocol schemas, branch/owner/fault fixtures and signed activation gate
  under `tools/life-branch/` with `models.py`, `protocol_validator.py`,
  `fault_runner.py`, `activation_gate.py`, `cli.py`,
  `contracts/life-branch-v1.schema.json`,
  `contracts/life-branch-owner-protocol-v1.schema.json`,
  `contracts/life-branch-activation-gate-v1.schema.json`,
  `config/owner-protocols-v1.json`, `config/production-activation-v1.json`,
  `fixtures/atomic-local-branch.json`, `fixtures/saga-partial-failure.json`,
  `fixtures/external-intent-only.json`, `tests/test_protocol_validator.py`,
  `tests/test_fault_runner.py`, and `tests/test_activation_gate.py`.
- Add under `Native/Ambitions/Core/LocalRuntimeOS/Simulation/LifeBranch/`:
  `LifeBranchActivationGateModels.swift`, `LifeBranchQualificationService.swift`,
  `LifeBranchSnapshotModels.swift`, `LifeBranchSnapshotAssembler.swift`,
  `LifeBranchModels.swift`, `LifeBranchOperationModels.swift`,
  `LifeBranchSimulationEngine.swift`, `LifeBranchValidationPipeline.swift`,
  `LifeBranchComparisonProjector.swift`, `LifeBranchSensitivityEngine.swift`,
  `LifeBranchOwnerParticipant.swift`, `LifeBranchParticipantRegistry.swift`,
  `LifeBranchPreparedTokenVault.swift`, `LifeBranchProtocolSelector.swift`,
  `LifeBranchAtomicCoordinator.swift`, `LifeBranchSagaCoordinator.swift`,
  `LifeBranchJournal.swift`, `LifeBranchReceiptAssembler.swift`,
  `LifeBranchRecoveryService.swift`, `LifeBranchReconciler.swift`,
  `ExternalActionDraftInputBuilder.swift`, `LifeBranchRepository.swift`,
  `LifeBranchMigration.swift`, `LifeBranchInvalidationService.swift`,
  `LifeBranchLifecycleService.swift`, `LifeBranchPurgeService.swift`, and
  `LifeBranchDiagnostics.swift`.
- Add participant adapters inside each owner domain or a narrow
  `LifeBranch/Participants/` boundary, with no generic repository client.
- Add branch compare/confirmation/progress/recovery UI under
  `Native/Ambitions/Surfaces/Goals/LifeBranch/` as
  `LifeBranchBuilderView.swift`, `LifeBranchComparisonView.swift`,
  `LifeBranchConfirmationView.swift`, `LifeBranchProgressView.swift`,
  `LifeBranchRecoveryView.swift`, and `LifeBranchPreviewFixtures.swift`; add tests under
  `Native/AmbitionsTests/LocalRuntimeOS/Simulation/LifeBranch/` as
  `LifeBranchQualificationTests.swift`, `LifeBranchSnapshotTests.swift`,
  `LifeBranchValidationTests.swift`, `LifeBranchParticipantProtocolTests.swift`,
  `LifeBranchAtomicCoordinatorTests.swift`, `LifeBranchSagaCoordinatorTests.swift`,
  `LifeBranchFaultRecoveryTests.swift`, `LifeBranchExternalBoundaryTests.swift`,
  `LifeBranchMigrationPurgeTests.swift`, and `LifeBranchPrivacySecurityTests.swift`;
  add `Native/AmbitionsTests/Quality/GeneralizedLifeBranchAccessibilityTests.swift`
  and `Native/AmbitionsUITests/GeneralizedLifeBranchUITests.swift`.
- Add signed gate/protocol resource; update `project.yml` and regenerate only if
  verified inclusion requires it.

Sequence: canon/contracts/gate; qualifier/snapshot; branch simulation/validation;
owner protocol/tokens; atomic coordinator; saga/journal/fault recovery; receipts;
external intent; lifecycle/purge; UI/accessibility; integration; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Participant/token,
atomic/saga/journal/recovery/external boundaries, exact UI/tests and activation
gate are named. Devan delegated approval; grooming approved 2026-08-04.
