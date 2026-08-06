# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add destination-direction canon and the three Domain model files.
   Dependency: Capability foundation and advisory candidate contract. Trace:
   Design summary, REQ-001 through REQ-003, REQ-008. Acceptance: direction,
   rationale, duplicate decision, continuity proposal, lifecycle, and adoption
   checkpoint exist without Goal/Path/Step/Proof/Time authority. Test:
   `Native/AmbitionsTests/Domain/DestinationDirectionModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `DestinationDirectionStore.swift`,
   `AdoptionReviewCheckpointStore.swift`, and
   `DestinationDirectionCommandService.swift` with additive empty migration.
   Dependency: Task 1. Trace: persistence/recovery, REQ-002, REQ-003,
   REQ-010 through REQ-012. Acceptance: keep/edit/dismiss/exclude/archive/Trash/
   restore/delete, revision CAS, redaction, Receipts, History, replay, and
   quarantine work without deleting promoted Goals. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/DestinationDirectionCommandServiceTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `DestinationDuplicatePolicy.swift` and all four branches in
   `DestinationAdoptionCoordinator.swift`. Dependency: Tasks 1-2. Trace:
   duplicate review, REQ-004, REQ-005, REQ-011. Acceptance: open/refine issue no
   owner command; relate explicitly confirms one dormant direction and one
   relationship with zero Goals; only continue-distinct reaches Goal creation;
   retries/replay preserve exact partial results. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/DestinationDuplicateBranchTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `CreateProvisionalGoalFromDirectionCommand.swift` and connect the
   existing Goal command/event/projection/Receipt/replay chain. Dependency:
   Tasks 1-3. Trace: adoption, REQ-004 through REQ-006. Acceptance: one
   provisional Goal with a new stable ID and original-intent lineage, no route,
   Steps, Proof rules, placement, schedule, old-Goal rewrite, or duplicate Goal
   under repeated delivery. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/CreateProvisionalGoalFromDirectionTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Implement changed-destination settlement and continuity relationships in
   `DestinationAdoptionCoordinator.swift`. Dependency: Task 4. Trace: pivot,
   REQ-006 through REQ-011. Acceptance: same-outcome exits to path work; changed
   outcome preserves old Goal identity; keep/pause/Closure/cancel and each link
   have truthful owner results; all-or-none makes no mutation and hands to Life
   Branch. Test: `Native/AmbitionsTests/LocalRuntimeOS/Planning/DestinationPivotSettlementTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. Implement `DestinationDirectionProjector.swift`,
   `DestinationAdoptionView.swift`, and `DestinationPivotReviewView.swift`.
   Dependency: Tasks 1-5. Trace: user flows/privacy/accessibility, REQ-001,
   REQ-005, REQ-007 through REQ-014. Acceptance: exact consequence labels,
   partial recovery, source/continuity distinctions, accessible branch focus,
   and no aggregate false success. Test:
   `Native/AmbitionsUITests/DestinationAdoptionAndPivotUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
7. Update canon, regenerate project state, and run verification. Dependency:
   Tasks 1-6. Trace: all REQ-001 through REQ-014. Acceptance: all requirements
   pass and Goal-path or Life-Branch work is not silently executed. Tests: run
   `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
