# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add credential canon and the three Credential Domain files. Dependency:
   Capability/public-reference foundations and Proof owner. Trace: Design model,
   REQ-001 through REQ-006. Acceptance: artifact, issuer, achievement, evidence,
   endorsement, validity, receiver acceptance, relationship, lifecycle, and
   lineage remain independently representable. Test:
   `Native/AmbitionsTests/Domain/CredentialModelsTests.swift`.
2. Implement `CredentialArtifactStagingService.swift` and
   `Repair/CredentialImport/CredentialArtifactVerifier.swift`. Dependency: Task 1. Trace: intake/trust,
   REQ-001 through REQ-008, REQ-012. Acceptance: scoped file access, size/schema/
   signature/issuer/key/status/expiry checks for the pinned VC 2.0/Open Badges
   3.0.3 JSON/JSON-LD + EdDSA Data Integrity + local Multikey/`did:key` allowlist,
   deterministic preview, encrypted staging, unsupported-method failure, and
   cleanup. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Repair/CredentialArtifactVerifierTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Attachments/CredentialArtifactStagingServiceTests.swift`.
3. Implement `CredentialStoreSchema.swift`, `CredentialStateStore.swift`, and
   `CredentialSchemaMigration.swift`. Dependency: Tasks 1-2. Trace: persistence,
   REQ-006, REQ-009 through REQ-015. Acceptance: empty additive migration,
   encrypted content-addressed artifact, CAS, lifecycle, supersession lineage,
   revocation snapshots, deletion/redaction, quarantine, backup, and replay.
   Test: `Native/AmbitionsTests/LocalRuntimeOS/State/CredentialStateStoreTests.swift`.
4. Implement `CredentialCommandService.swift` with separately confirmed Proof
   and Capability relationships. Dependency: Tasks 1-3. Trace: acceptance and
   recovery, REQ-004 through REQ-013. Acceptance: one Credential under duplicate
   delivery; edges never change Proof/Capability meaning; stale status requires
   review; no external acceptance or automatic replacement. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/CredentialCommandServiceTests.swift`.
5. Implement `CredentialStatusRequestPolicy.swift` and
   `CredentialStatusCheckService.swift`. Dependency: Tasks 1-4. Trace: explicit
   current-status flow, REQ-003 through REQ-008, REQ-011 through REQ-015.
   Acceptance: only supported signed locators enter a reviewed no-contact plan;
   confirmation binds normalized hosts/resources and Credential revision;
   SSRF/DNS/redirect/auth/private-data attacks fail closed; cancellation,
   timeout, ambiguous invocation, reconciliation, retry, deletion race, and
   replay produce truthful external-operation state without automatic reissue.
   Tests: `Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/CredentialStatusRequestPolicyTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/ExternalOperations/CredentialStatusCheckServiceTests.swift`.
6. Implement `CredentialInspectionProjection.swift`,
   `CredentialImportView.swift`, and `CredentialInspectionView.swift`.
   Dependency: Tasks 1-5. Trace: flows/privacy/accessibility, REQ-001 through
   REQ-015. Acceptance: every trust layer, source/status time, limitations,
   relationships, status-check preview/result, expiry/revocation, correction,
   deletion, and recovery is readable without trust-badge compression. Test:
   `Native/AmbitionsUITests/VerifiableCredentialImportUITests.swift`.
7. Add adversarial artifact and network/status fixtures, update canon, regenerate
   project, and run verification. Dependency: Tasks 1-6. Trace: all REQ-001
   through REQ-015. Acceptance: all requirements pass without competence,
   equivalency, acceptance, or hosted-verification claim. Tests: run
   `implementation/verification.md` in full.
