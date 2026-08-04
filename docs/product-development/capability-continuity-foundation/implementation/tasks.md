# Implementation Tasks

Every unqualified source basename below resolves to the unique repository path
listed in `implementation/plan.md`; no same-name alternative is in scope. Test
files are named with full repository-relative paths.

1. Add the Capability canon and value contracts in
   `docs/canon/specifications/objects/capability.md`,
   `Native/Ambitions/Core/Domain/Capability/CapabilityModels.swift`, and
   `CapabilityEvidenceModels.swift`. Dependency: none. Trace: Design summary,
   Architecture, REQ-001 through REQ-006. Acceptance: stable identity,
   non-exclusive provenance facets, lifecycle, evidence-edge, permission, and
   claim ceilings are representable without scores or duplicated Proof. Tests:
   `Native/AmbitionsTests/Domain/CapabilityModelsTests.swift`.
2. Add `CapabilityStoreSchema.swift`, `CapabilityStateStore.swift`, and
   `CapabilitySchemaMigration.swift`. Dependency: Task 1. Trace: persistence and
   recovery, REQ-007, REQ-009, REQ-013, REQ-015. Acceptance: empty additive
   migration, revision CAS, idempotent append, archive/Trash/restore/redaction,
   quarantine, backup, and replay invariants pass. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Storage/CapabilityStateStoreTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Repair/CapabilitySchemaMigrationTests.swift`.
3. Implement `CapabilityProposalPolicy.swift` using only approved completion,
   evidence, permission, and lifecycle inputs. Dependency: Tasks 1-2. Trace:
   proposal flow and privacy boundary, REQ-002 through REQ-005, REQ-010,
   REQ-014. Acceptance: proposals are deterministic, quiet when unsupported,
   never inferred from Receipt kind alone, and cannot create or edit Capability.
   Tests: `Native/AmbitionsTests/LocalRuntimeOS/Planning/CapabilityProposalPolicyTests.swift`.
4. Implement `CapabilityCommandService.swift`,
   `CapabilitySourceLifecycleReconciler.swift`, and extend the existing event,
   Receipt, History, and replay registries with typed Capability operations.
   Dependency: Tasks 1-3. Trace: command and recovery flows, REQ-006 through
   REQ-013. Acceptance: create, confirm, edit, evidence attach/detach,
   permission, archive, Trash, restore, and deletion settle atomically and
   duplicate delivery returns one result. Source lifecycle changes reconcile in
   a separately owned causally linked idempotent transaction and expose any
   temporary pending state truthfully. Tests:
   `Native/AmbitionsTests/LocalRuntimeOS/Commands/CapabilityCommandServiceTests.swift`
   and `Native/AmbitionsTests/LocalRuntimeOS/Planning/CapabilitySourceLifecycleReconcilerTests.swift`.
5. Implement `CapabilityProjector.swift`, `CapabilityCollectionView.swift`, and
   `CapabilityProposalCard.swift`, then wire existing You/Goals composition.
   Dependency: Task 4. Trace: user flows, states, accessibility, REQ-001,
   REQ-004, REQ-008, REQ-011, REQ-012, REQ-016. Acceptance: calm review,
   correction, provenance inspection, lifecycle recovery, Dynamic Type, and
   assistive-control paths work without adding a root or score. Tests:
   `Native/AmbitionsTests/You/CapabilityCollectionProjectionTests.swift` and
   `Native/AmbitionsUITests/CapabilityContinuityUITests.swift`.
6. Update `local-learning.md`, `you.md`, and `closure-and-proof.md`; regenerate
   canon and `Ambitions.xcodeproj`, then run the full verification contract.
   Dependency: Tasks 1-5. Trace: all REQ-001 through REQ-016. Acceptance: canon,
   source boundaries, focused tests, build-for-testing, privacy, accessibility,
   migration, and replay evidence are green with no downstream consumer enabled.
   Tests: run every exact command and evidence lane in
   `implementation/verification.md`.
