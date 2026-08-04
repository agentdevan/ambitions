# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add hobby recommendation canon, `HobbyRecommendationModels.swift`, and the
   synthetic corpus fixture. Dependency: Capability and public-reference
   foundations. Trace: Design summary, REQ-001 through REQ-008. Acceptance:
   exactly the approved families, temporary inputs, candidate fields, corpus
   certificate, consent, and non-authoritative handoff are typed without score,
   prediction, provider, or persistence fields. Test:
   `Native/AmbitionsTests/Domain/HobbyRecommendationModelsTests.swift`.
2. Implement `HobbyDestinationEligibilityPolicy.swift`. Dependency: Task 1.
   Trace: eligibility/privacy, REQ-002 through REQ-008, REQ-011, REQ-013.
   Acceptance: authority, rights, freshness, low-risk entry, protected consent,
   output sensitivity, excluded dependencies, and sparse/unavailable behavior
   fail closed before ordering. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/HobbyDestinationEligibilityPolicyTests.swift`.
3. Implement `HobbyCandidateWindowPolicy.swift`. Dependency: Tasks 1-2. Trace:
   neutral window/overflow, REQ-006, REQ-007, REQ-015. Acceptance: public-ID/
   visible-name tie break, first-from-each family, alternation, maximum four,
   full overflow, no padding, stable permutation results, and suppression before
   counts. Test: `Native/AmbitionsTests/LocalRuntimeOS/Planning/HobbyCandidateWindowPolicyTests.swift`.
4. Implement `HobbyExplorationCoordinator.swift` as an in-memory actor with
   revision tokens, cancellation, cleanup, and the absolute diagnostic firewall.
   Dependency: Tasks 1-3. Trace: session/recovery/privacy, REQ-001, REQ-003,
   REQ-010 through REQ-013. Acceptance: relaunch begins empty; different private
   contexts produce byte-identical allowlisted static diagnostics or none; no
   private state reaches persistence or observability. Test:
   `Native/AmbitionsTests/LocalRuntimeOS/Planning/HobbyExplorationCoordinatorTests.swift`.
5. Implement `HobbyExplorationView.swift` and `HobbySourceInspectionView.swift`.
   Dependency: Task 4. Trace: full user flow/accessibility, REQ-001, REQ-006
   through REQ-015. Acceptance: explicit entry, correction, None, unrelated
   exploration, overflow, dismissal advancement, source limits, nonmutating
   interest handoff, quiet failure, and assistive parity. Test:
   `Native/AmbitionsUITests/HobbyExplorationUITests.swift`.
6. Update canon, regenerate project state, and run verification. Dependency:
   Tasks 1-5. Trace: all REQ-001 through REQ-015. Acceptance: no user record/
   event/Receipt/learning mutation exists and all requirements pass. Tests: run
   `implementation/verification.md` in full.
