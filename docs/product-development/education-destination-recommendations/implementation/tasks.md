# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add education recommendation canon and the three Domain model files.
   Dependency: Capability and public-reference foundations. Trace: Design
   contracts, REQ-001 through REQ-006. Acceptance: route form, authority lane,
   source claim, user input/consent, uncertainty, option, and lifecycle encode
   every claim ceiling without Goal or score semantics. Test:
   `Native/AmbitionsTests/Domain/EducationRecommendationModelsTests.swift`.
2. Implement `EducationEligibilityPolicy.swift` with the six authority lanes,
   exact-purpose consent, source certificate, and sensitive-output gates.
   Dependency: Task 1. Trace: authority/privacy, REQ-003 through REQ-010,
   REQ-017. Acceptance: CIP/classification never becomes requirements,
   accreditation never becomes transfer, provider facts never become acceptance,
   and unknown/conflict fails closed. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/EducationEligibilityPolicyTests.swift`.
3. Implement `EducationOptionComposer.swift`,
   `EducationExplanationBuilder.swift`, and
   `EducationExplorationCoordinator.swift`. Dependency: Tasks 1-2. Trace: flows,
   REQ-001, REQ-002, REQ-006 through REQ-014. Acceptance: deterministic
   qualitative options, separate route/authority meanings, truthful sparse and
   unavailable states, correction, cancellation, and stale recovery. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/EducationOptionComposerTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/EducationExplorationCoordinatorTests.swift`.
4. Implement `EducationExplorationStore.swift` and
   `EducationPreferenceCommandService.swift` with additive empty migration,
   CAS, events, Receipts, History, replay, archive/Trash/restore/delete, and
   consent expiry. Dependency: Tasks 1-3. Trace: persistence/recovery, REQ-011
   through REQ-016, REQ-018. Acceptance: explicit preference mutations settle
   once, stale revisions fail closed, consent is purpose-bound, deletion is
   non-reconstructive, and replay rebuilds the same projection. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/EducationPreferenceCommandServiceTests.swift`.
5. Implement `EducationRecommendationProjector.swift`,
   `EducationExplorationView.swift`, and `EducationOptionInspectionView.swift`.
   Dependency: Tasks 1-4. Trace: review/accessibility, REQ-001, REQ-005,
   REQ-008, REQ-009, REQ-014 through REQ-019. Acceptance: every authority and
   unknown state is readable nonvisually; no provider write or hidden adoption
   occurs. Tests: `Native/AmbitionsUITests/EducationExplorationUITests.swift`.
6. Add destination-adoption handoff compatibility, update canon, regenerate the
   project, and run verification. Dependency: Tasks 1-5. Trace: all REQ-001
   through REQ-019. Acceptance: all requirements pass while education-specific
   authority remains independent of career and hobby policies. Tests: run
   `implementation/verification.md` in full.
