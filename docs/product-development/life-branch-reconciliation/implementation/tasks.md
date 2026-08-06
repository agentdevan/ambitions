# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Update the four owning canon files and add the three Life Branch Domain files.
   Dependency: stable upstream owner contracts. Trace: Design summary/model,
   REQ-001 through REQ-008. Acceptance: identity, typed delta, authority,
   certificate, dependency/impact cone, lifecycle, active-slot binding, lineage,
   and claim ceilings compile without duplicate canonical objects. Test:
   `Native/AmbitionsTests/Domain/LifeBranchModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `LifeBranchStoreSchema.swift`, `LifeBranchStateStore.swift`, and
   `LifeBranchSchemaMigration.swift`. Dependency: Task 1. Trace: persistence and
   one-active invariant, REQ-008, REQ-009, REQ-011 through REQ-016. Acceptance:
   explicit revisioned absence, one occupant maximum, empty additive migration,
   lifecycle/lineage decoding, CAS, replay, backup/restore, and ambiguous-store
   quarantine. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/State/LifeBranchStateStoreTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Repair/LifeBranchSchemaMigrationTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `LifeBranchNecessityAssessor.swift` with read-only adapters for
   Goal, Goal Path, Recovery, destination pivot, and Scheduling. Dependency:
   Tasks 1-2. Trace: threshold/scenario, REQ-001 through REQ-004. Acceptance:
   all four clauses are conjunctive, simpler-owner success exits without a
   candidate, existing unresolved branch blocks, and non-approved scenarios do
   not enter the workflow. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/LifeBranchNecessityAssessorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `LifeBranchCandidateMaterializer.swift` and
   `BranchViabilityEvaluator.swift`. Dependency: Tasks 1-3. Trace: complete
   candidates/certificates, REQ-005 through REQ-010, REQ-014. Acceptance: two or
   three policy-distinct complete deltas, omission blocking, equivalence
   suppression, authority partition, impact-cone invalidation, active-slot
   binding, valid-only selection, and no model certification. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/LifeBranchCandidateMaterializerTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/BranchViabilityEvaluatorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Implement `LifeBranchCommandService.swift` and
   `LifeBranchPromotionTransaction.swift`. Dependency: Tasks 1-4. Trace:
   confirmation/promotion/failure, REQ-007, REQ-011, REQ-012, REQ-015.
   Acceptance: complete read/write sets, branch-absence CAS, one winner under
   racing promotions, atomic local settlement, truthful external intents,
   idempotent retry, crash recovery, and zero supersession operation. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Transactions/LifeBranchPromotionTransactionTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. Implement stale/expired lifecycle transitions, safe rollback, and
   `BranchCompensationPlanner.swift`. Dependency: Task 5. Trace: recovery,
   REQ-012 through REQ-014. Acceptance: stale/expired remain inspectable,
   non-authorizing occupants; rollback/compensation preserves lineage and
   releases the slot only at a terminal resolved disposition. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/LifeBranchRecoveryTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
7. Implement `LifeBranchProjector.swift`, `LifeBranchReviewView.swift`, and
   contextual entry/Trust inspection. Dependency: Tasks 1-6. Trace: all flows,
   REQ-001 through REQ-017. Acceptance: complete nonvisual comparison, source/
   authority/unknown inspection, exact confirmation, partial external results,
   active-branch blocker, recovery, Dynamic Type, and assistive parity. Test:
   `Native/AmbitionsUITests/LifeBranchReconciliationUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
8. Regenerate canon/project state and run the full fault/race verification.
   Dependency: Tasks 1-7. Trace: all REQ-001 through REQ-017. Acceptance: every
   requirement passes and no general scenario, supersession, or external-success
   claim is introduced. Tests: run `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
