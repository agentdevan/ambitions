# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add career recommendation canon, `CareerRecommendationModels.swift`, and
   `CareerPreferenceModels.swift`. Dependency: Capability and public-reference
   foundations. Trace: Design summary/contracts, REQ-001 through REQ-004.
   Acceptance: advisory candidates, lane, input category, public claim,
   uncertainty, rationale, privacy, and lifecycle are typed without Goal/Path/
   score fields. Test: `Native/AmbitionsTests/Domain/CareerRecommendationModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `CareerEligibilityPolicy.swift` and privacy classification using
   the public-reference certificate and fixed public artifact IDs. Dependency:
   Task 1. Trace: gates/privacy, REQ-003, REQ-005, REQ-008, REQ-010, REQ-012.
   Acceptance: unsupported authority, protected inference, stale/conflicting
   facts, and private-egress attempts fail closed. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/CareerEligibilityPolicyTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `CareerCandidateComposer.swift`, `CareerExplanationBuilder.swift`,
   and `CareerExplorationCoordinator.swift`. Dependency: Tasks 1-2. Trace:
   primary/alternate flows, REQ-001 through REQ-009. Acceptance: continuity and
   aspiration lanes remain distinct, ordering is deterministic and non-ranked,
   no capability overlap becomes eligibility, and cancellation/staleness is
   safe. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/CareerCandidateComposerTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/CareerExplorationCoordinatorTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `CareerPreferenceStore.swift` and
   `CareerPreferenceCommandService.swift` with empty additive migration.
   Dependency: Tasks 1-3. Trace: correction/dismissal/recovery, REQ-006,
   REQ-009 through REQ-011, REQ-013. Acceptance: exact-basis dismiss, broader
   exclusion, correction, disable/reset, archive/Trash/restore/delete, CAS,
   idempotency, replay, and quarantine pass. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/CareerPreferenceCommandServiceTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
5. Implement `CareerRecommendationProjector.swift`,
   `CareerExplorationView.swift`, and `CareerRecommendationInspectionView.swift`.
   Dependency: Tasks 1-4. Trace: presentation/accessibility, REQ-001, REQ-004,
   REQ-007, REQ-008, REQ-011, REQ-013. Acceptance: rationale, source limits,
   uncertainty, lane semantics, correction, quiet failure, and candidate handoff
   are fully nonvisual and never imply Goal creation. Tests:
   `Native/AmbitionsUITests/CareerExplorationUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: required. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
6. Add typed handoff compatibility tests for destination-adoption-and-pivot,
   then regenerate canon/project state and run verification. Dependency: Tasks
   1-5. Trace: all REQ-001 through REQ-013. Acceptance: all requirements pass
   without enabling adoption or direct network access. Tests: run
   `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
