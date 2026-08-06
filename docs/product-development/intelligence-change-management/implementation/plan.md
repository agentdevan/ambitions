# Implementation Plan

## Outcome and boundary

Implement secure immutable intelligence artifact/trust/compatibility/evaluation/
impact/lifecycle management over existing domain pipelines. Do not add arbitrary
remote config, private rollout cohorts/migrations, canonical mutation, unsafe
downgrade/LKG or false provenance/security claims.

## Exact expected files

- Add `docs/canon/specifications/systems/intelligence-change-management.md` and
  update Source Atlas/private runtime/artifact registries/evaluation/privacy/
  security/degraded/trust/History/migration/deletion/offline canon.
- Add `tools/intelligence-release/` with `models.py`, `manifest_builder.py`,
  `provenance_builder.py`, `trust_metadata.py`, `compatibility.py`,
  `change_diff.py`, `evaluation_bundle.py`, `release_builder.py`, `cli.py`,
  `contracts/intelligence-artifact-v1.schema.json`,
  `contracts/intelligence-release-v1.schema.json`,
  `contracts/task-compatibility-v1.schema.json`,
  `contracts/intelligence-evaluation-bundle-v1.schema.json`,
  `config/trust-root-v1.json`, `config/release-policy-v1.json`,
  `fixtures/root-rotation.json`, `fixtures/incompatible-model-update.json`,
  `fixtures/revoked-source-release.json`, `tests/test_release_builder.py`,
  `tests/test_trust_metadata.py`, `tests/test_compatibility.py`, and
  `tests/test_change_diff.py`; integrate existing Foundry CLIs through explicit
  adapters.
- Add under
  `Native/Ambitions/Core/LocalRuntimeOS/IntelligenceChangeManagement/`:
  `IntelligenceArtifactModels.swift`, `IntelligenceReleaseModels.swift`,
  `IntelligenceTrustModels.swift`, `IntelligenceTrustVerifier.swift`,
  `IntelligenceQuarantineStore.swift`, `IntelligenceArtifactStore.swift`,
  `IntelligenceAttestationStore.swift`, `DomainSemanticValidatorRegistry.swift`,
  `DomainValidationReceiptModels.swift`, `TaskCompatibilityModels.swift`,
  `TaskCompatibilityGraph.swift`, `IntelligenceEnvironmentDetector.swift`,
  `IntelligenceEvaluationGate.swift`, `IntelligenceChangeClassifier.swift`,
  `IntelligenceDependencyGraph.swift`, `IntelligenceImpactPlanner.swift`,
  `IntelligenceGenerationStore.swift`, `IntelligenceReaderLease.swift`,
  `IntelligenceGenerationCoordinator.swift`, `IntelligenceChangeJournal.swift`,
  `IntelligencePromotionService.swift`, `IntelligenceRollbackService.swift`,
  `IntelligenceRevocationService.swift`, `IntelligenceWithdrawalService.swift`,
  `IntelligencePurgeService.swift`, `IntelligenceRecoveryService.swift`,
  `IntelligenceConsumerNotifier.swift`, `OwnerReconciliationInputBuilder.swift`,
  `IntelligenceChangeProjections.swift`, `IntelligenceChangeDiagnostics.swift`,
  and `IntelligenceStorageClearService.swift`.
- Add pinned trust root and bundled release/compatibility resources under
  `Native/Ambitions/Resources/IntelligenceReleases/`; update `project.yml` and
  regenerate because the new directory is excluded.
- Update Source Atlas refresh/bootstrap and typed consumer boundary clients only;
  inject no private repository/command or dynamic code execution.
- Add Trust/update/degraded surfaces under
  `Native/Ambitions/Trust/IntelligenceReleases/` as
  `IntelligenceReleaseStatusView.swift`, `IntelligenceChangeNotesView.swift`,
  `IntelligenceDegradedStateView.swift`, and
  `IntelligenceReleasePreviewFixtures.swift`; add tests under
  `Native/AmbitionsTests/LocalRuntimeOS/IntelligenceChangeManagement/` as
  `IntelligenceArtifactStoreTests.swift`, `IntelligenceTrustVerifierTests.swift`,
  `DomainSemanticValidatorRegistryTests.swift`,
  `TaskCompatibilityGraphTests.swift`, `IntelligenceEvaluationGateTests.swift`,
  `IntelligenceImpactPlannerTests.swift`,
  `IntelligenceGenerationCoordinatorTests.swift`,
  `IntelligencePromotionRollbackTests.swift`,
  `IntelligenceRevocationPurgeTests.swift`, and
  `IntelligenceChangePrivacySecurityTests.swift`; add
  `Native/AmbitionsTests/Quality/IntelligenceChangeAccessibilityTests.swift` and
  `Native/AmbitionsUITests/IntelligenceChangeUITests.swift`.

Sequence: canon/contracts; manifest/provenance; trust verifier; domain validator;
compatibility/environment; evaluation gate; change/impact; stores/generation;
promotion/rollback; revocation/purge/recovery; inspection/accessibility; resources/
integration; full proof/security review.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact tooling/native/
resource/UI/test files, existing Foundry integration, no-command/dynamic-code
boundary and security proof are named. Devan delegated approval; grooming
approved 2026-08-04.
