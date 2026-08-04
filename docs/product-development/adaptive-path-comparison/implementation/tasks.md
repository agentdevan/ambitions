# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Update Goal Path/private-runtime canon and add `PathComparisonModels.swift`.
   Dependency: goal-path-generation. Trace: Design summary/contracts, REQ-001
   through REQ-005. Acceptance: session, candidate, consequence, difference,
   equivalence, decision, and handoff types have stable revision bindings and no
   mutation or score fields. Test:
   `Native/AmbitionsTests/Domain/PathComparisonModelsTests.swift`.
2. Implement `PathDifferenceEngine.swift`. Dependency: Task 1. Trace: candidate
   materiality/equivalence, REQ-002 through REQ-009. Acceptance: deterministic
   consequence signatures, equivalence suppression, omission reasons, shared
   progress, protected/sacrificed conditions, unknowns, and no hidden ordering
   preference. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/PathDifferenceEngineTests.swift`.
3. Implement `PathComparisonDraftSchema.swift`, `PathComparisonCoordinator.swift`,
   `PathComparisonExplanationBuilder.swift`, and
   `PathComparisonSessionStore.swift`. Dependency: Tasks 1-2. Trace: flows,
   recovery/persistence, REQ-001, REQ-006 through REQ-014. Acceptance: edit,
   refresh, defer, reject, resume, cancellation, stale invalidation, atomic
   checkpoint/decision, protected `CanonicalRuntimeStore` draft-table migration,
   CAS, and local-only replay pass without semantic events. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Storage/PathComparisonDraftSchemaTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/PathComparisonCoordinatorTests.swift`.
4. Implement the `AcceptGoalPathVersionCommand` selection handoff. Dependency: Tasks 1-3 and Goal
   Path owner. Trace: confirmation, REQ-010 through REQ-013, REQ-016.
   Acceptance: comparison emits one revision-bound intent; only the Goal Path
   command can settle it, and stale/duplicate delivery cannot create two paths.
   Test: `Native/AmbitionsTests/LocalRuntimeOS/Planning/PathComparisonHandoffTests.swift`.
5. Implement `PathComparisonView.swift` and `PathComparisonDetailView.swift`.
   Dependency: Tasks 1-4. Trace: user flow/accessibility, REQ-001 through
   REQ-016. Acceptance: ordered nonvisual comparison, explicit non-ranking,
   complete alternatives, source/unknown inspection, named controls, Dynamic
   Type, and focus recovery. Test:
   `Native/AmbitionsUITests/AdaptivePathComparisonUITests.swift`.
6. Update canon, regenerate project state, and run verification. Dependency:
   Tasks 1-5. Trace: all REQ-001 through REQ-016. Acceptance: all requirements
   pass with zero comparison-owned canonical or external mutation. Tests: run
   every exact command and evidence lane in `implementation/verification.md`.
