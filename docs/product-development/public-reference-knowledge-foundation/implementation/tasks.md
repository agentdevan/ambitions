# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Define public-reference identity, authority lane, jurisdiction, claim,
   freshness, rights, conflict, and availability in
   `PublicReferenceKnowledgeModels.swift` and the three owning canon files.
   Dependency: none. Trace: Design summary/data model, REQ-001 through REQ-005.
   Acceptance: the types express authoritative, contextual, unavailable,
   conflicting, and last-known-good states without user fit or acceptance claims.
   Test: `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PublicReferenceKnowledgeModelsTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
2. Implement `PublicReferenceAuthorityPolicy.swift` and extend
   `SourceAtlasPublicPackRequestValidator.swift` and `FreshnessEngine.swift`.
   Dependency: Task 1. Trace: certificate and failure states, REQ-002 through
   REQ-007. Acceptance: rights, region, authority, schema, signature, freshness,
   and conflict fail closed with deterministic reasons. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PublicReferenceAuthorityPolicyTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
3. Implement `PublicReferencePackAdapter.swift` and
   `PublicReferenceRepository.swift` over the verified provider and last-known-
   good store. Dependency: Tasks 1-2. Trace: persistence/replay, REQ-004,
   REQ-006, REQ-008, REQ-010. Acceptance: additive cache migration, atomic pack
   replacement, rollback, cancellation, concurrent refresh, and offline reads
   preserve exact source revisions. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PublicReferenceRepositoryTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
4. Implement `PublicReferenceQueryService.swift`,
   `PublicReferenceInspectionProjection.swift`, and
   `PublicReferenceInspectionView.swift`. Dependency: Task 3. Trace: inspection
   and accessibility, REQ-001, REQ-005, REQ-009, REQ-011. Acceptance: clients
   can inspect authority, retrieval, freshness, limits, conflict, and recheck
   triggers without badges, private context, or a new root surface. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Inspection/PublicReferenceInspectionProjectionTests.swift`
   and `Native/AmbitionsUITests/PublicReferenceInspectionUITests.swift`.
   Frontend: affected — authorized by the approved Scope frontend contract and Design frontend experience specification; Visual gate: approved. Proof: approved native visual calibration, UI runtime, accessibility, and screenshot evidence are required.
5. Refactor `SourceAtlasPackModels+08-SourceAtlasCapabilityPathComposer.swift`
   behind `SourceAtlasPublicPlanningContextModels.swift`, then add public-only
   boundary and consumer-contract fixtures covering career, education, hobby,
   and credential artifact IDs. Dependency: Tasks 1-4. Trace:
   all REQ-001 through REQ-011. Acceptance: every private-field, derived-key,
   open-ended query, unsupported source, and network-order attack fails closed.
   Tests: extend
   `Native/AmbitionsTests/LocalRuntimeOS/Boundary/SourceAtlasNoPrivateGraphEgressAuditTests.swift`
   and add
   `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PublicReferenceConsumerContractTests.swift`.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
6. Regenerate canon/project state and run verification. Dependency: Tasks 1-5.
   Trace: all REQ-001 through REQ-011. Acceptance: no direct consumer network
   path or private/public joined cache is introduced; all evidence lanes pass.
   Tests: run `implementation/verification.md` in full.
   Frontend: none — this task is limited to canon, domain, data, runtime, tooling, integration, or verification foundations and does not create or modify a user interface.
