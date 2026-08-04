# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Define `CapabilityExportModels.swift` and canon updates. Dependency:
   capability-continuity-foundation. Trace: Design summary and records, REQ-001
   through REQ-004. Acceptance: selection, purpose, revision, policy, hash,
   lifecycle, expiry, and result exist without storing rendered content or
   implying delivery. Test: `Native/AmbitionsTests/Domain/CapabilityExportModelsTests.swift`.
2. Implement `CapabilityExportPolicy.swift`. Dependency: Task 1. Trace: privacy
   classification/redaction, REQ-003, REQ-005 through REQ-009. Acceptance:
   protected, third-party, revoked, deleted, unsupported, and stale facets fail
   closed; no universal proficiency or acceptance claim is generated. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/PrivacySecurity/CapabilityExportPolicyTests.swift`.
3. Implement `CapabilityExportRecordStore.swift` with additive empty migration,
   expiry, deletion, CAS, idempotency, and replay. Dependency: Tasks 1-2. Trace:
   recovery/persistence, REQ-008, REQ-010 through REQ-012. Acceptance: no
   rendered bytes survive in state, projections, logs, or backups. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/State/CapabilityExportRecordStoreTests.swift`.
4. Implement `Repair/CapabilityExport/CapabilityAdvisorSummaryRenderer.swift`,
   `CapabilityExportArtifactService.swift`,
   `CapabilityExportHandoffService.swift`, `CapabilityExportCommandService.swift`,
   and `CapabilityExportProjection.swift`. Dependency: Tasks 1-3. Trace: preview,
   confirmation, staleness, deletion, REQ-001 through REQ-013. Acceptance: local
   deterministic render, revision revalidation, truthful attempted/completed/
   cancelled/ambiguous result, exact LF-normalized UTF-8 bytes, protected
   ephemeral cleanup, and no automatic external write or replayed handoff.
   Tests: `Native/AmbitionsTests/LocalRuntimeOS/Repair/CapabilityAdvisorSummaryRendererTests.swift`,
   `Native/AmbitionsTests/LocalRuntimeOS/ExternalOperations/CapabilityExportHandoffServiceTests.swift`,
   and `Native/AmbitionsTests/LocalRuntimeOS/Commands/CapabilityExportCommandServiceTests.swift`.
5. Implement `CapabilityExportView.swift` with exact selection, preview,
   accessibility, stale recovery, expiry, and deletion controls. Dependency:
   Task 4. Trace: user flow/accessibility, REQ-001, REQ-002, REQ-004, REQ-013,
   REQ-014. Acceptance: no hidden preselection, share-sheet delivery claim,
   clipboard default, or inaccessible redaction state. Tests:
   `Native/AmbitionsUITests/CapabilityExportUITests.swift`.
6. Regenerate canon/project state and run verification. Dependency: Tasks 1-5.
   Trace: all REQ-001 through REQ-014. Acceptance: all requirements are covered
   and no unauthorized external adapter or persistent rendered-content path
   exists. Tests: run `implementation/verification.md` in full.
