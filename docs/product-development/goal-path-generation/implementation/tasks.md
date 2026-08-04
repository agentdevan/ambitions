# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Update Goal/Goal Path canon and add `GoalPathGenerationModels.swift` plus
   `GoalPathRequirementModels.swift`. Dependency: public-reference foundation.
   Trace: Design contracts, REQ-001 through REQ-006. Acceptance: route fact
   types, AND/OR requirements, alternatives, stages, Proof targets, uncertainty,
   fallbacks, revisions, and claim ceilings are explicit without score or
   schedule authority. Test:
   `Native/AmbitionsTests/Domain/GoalPathGenerationModelsTests.swift`.
2. Implement `GoalPathGenerationLegacyAdapter.swift`,
   `GoalPathCandidateMaterializer.swift`, and
   `GoalPathExplanationBuilder.swift`. Dependency: Task 1. Trace: route
   construction, REQ-002 through REQ-009, REQ-014. Acceptance: deterministic
   complete candidates preserve hard gate/preparation/selection/training and
   source meanings, expose unknowns, suppress contradictions, never infer
   external acceptance, and keep legacy v1 values read-only without flattening
   the v2 grammar. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/GoalPathGenerationLegacyAdapterTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/GoalPathCandidateMaterializerTests.swift`.
3. Implement `GoalPathGenerationCoordinator.swift`,
   `GoalPathReviewDraftStore.swift`, and `GoalPathReviewDraftSchema.swift`.
   Dependency: Tasks 1-2. Trace: review and
   recovery, REQ-001, REQ-007 through REQ-013, REQ-015. Acceptance: edit,
   refresh, defer, reject, resume, cancellation, staleness, CAS, empty migration,
   protected `CanonicalRuntimeStore` draft storage, canonical
   `GoalPathReviewDigest`, and draft deletion remain side-effect-free. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Storage/GoalPathReviewDraftSchemaTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/GoalPathGenerationCoordinatorTests.swift`.
4. Implement `AcceptGoalPathVersionCommand.swift` through the existing Goal
   Path event/projection/Receipt/replay owner. Dependency: Tasks 1-3. Trace:
   adoption, REQ-010 through REQ-013, REQ-016. Acceptance: exact revision and
   confirmation binding, one current path, retained prior version, idempotent
   retry, atomic lineage, and no Goal outcome or Time mutation. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/AcceptGoalPathVersionCommandTests.swift`.
5. Extend `PathIntelligenceProjector.swift`; implement
   `GoalPathGenerationView.swift` and `GoalPathReviewView.swift`. Dependency:
   Tasks 1-4. Trace: presentation/accessibility, REQ-001 through REQ-016.
   Acceptance: ordered semantic route, sources/unknowns, compare/edit/recovery,
   non-color state, Dynamic Type, assistive controls, and separate scheduling
   handoff. Test: `Native/AmbitionsUITests/GoalPathGenerationUITests.swift`.
6. Add adaptive-path-comparison input compatibility, update canon, regenerate
   project state, and run verification. Dependency: Tasks 1-5. Trace: all
   REQ-001 through REQ-016. Acceptance: all requirements pass without destination
   or schedule mutation. Tests: run `implementation/verification.md` in full.
