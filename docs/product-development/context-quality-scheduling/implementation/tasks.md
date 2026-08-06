# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Update scheduling/placement/reflow/Time canon and add the two ContextFit
   Domain files. Dependency: existing Scheduling owners. Trace: Design summary,
   REQ-001 through REQ-005. Acceptance: structural window facts, surrounding
   context, qualitative fit, unknown, observation, consent, and revision types
   exist without scalar user traits. Test:
   `Native/AmbitionsTests/Domain/ContextFitModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `ContextFitPolicy.swift`. Dependency: Task 1. Trace: fit law,
   REQ-002 through REQ-009. Acceptance: deterministic qualitative comparison,
   protected-boundary preservation, honest unknowns, no minute-equivalence,
   no private public-query, and no automatic placement. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Scheduling/ContextFitPolicyTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `ContextObservationStore.swift` and
   `ContextObservationCoordinator.swift` with additive empty migration.
   Dependency: Tasks 1-2. Trace: observation/correction/privacy, REQ-004,
   REQ-007 through REQ-012. Acceptance: explicit confirmation, purpose binding,
   correction, disable/reset, archive/Trash/restore/delete, CAS, idempotency,
   replay, and protected-data expiry. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Scheduling/ContextObservationCoordinatorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `ContextFitComparisonCoordinator.swift` and
   `ContextFitProjector.swift`. Dependency: Tasks 1-3. Trace: comparison and
   recovery, REQ-001 through REQ-014. Acceptance: revision-bound snapshots,
   cancellation, stale invalidation, deterministic ordering, complete reasons,
   preview-only behavior, offline replay, and no main-thread policy work. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Scheduling/ContextFitComparisonCoordinatorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Implement `ContextFitReviewView.swift` and adapt the result into
   `ScheduleInstallPreview` through `ScheduleInstallKernel.swift`,
   `ScheduleInstallKernelEvaluation.swift`, and `ScheduleInstallKernelReceipt.swift`.
   Dependency: Task 4. Trace: user flow and
   accessibility, REQ-001, REQ-005, REQ-006, REQ-009 through REQ-014.
   Acceptance: semantic context, alternatives, unknowns, observation controls,
   protected-time warnings, exact confirmation, assistive parity, and truthful
   owner result. Test: `Native/AmbitionsUITests/ContextQualitySchedulingUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
6. Update canon, regenerate project state, and run verification. Dependency:
   Tasks 1-5. Trace: all REQ-001 through REQ-014. Acceptance: all requirements
   pass and only the existing Scheduling owner can settle placement. Tests: run
   `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
