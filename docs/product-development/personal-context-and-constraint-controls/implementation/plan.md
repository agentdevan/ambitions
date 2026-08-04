# Implementation Plan

## Outcome and boundary

Implement the protected typed Personal Context Registry, purpose grants,
ephemeral read views, influence inspection, what-if overrides and lifecycle.
Keep imports, hidden inference, suggestion defaults, hosted sharing and consumer
mutation unavailable.

## Exact expected files

- Add `docs/canon/specifications/systems/personal-context-registry.md`; update
  privacy, permissions, local learning, planning/scheduling/simulation, private
  runtime, trust/degraded, History/Receipts and deletion specifications.
- Add under `Native/Ambitions/Core/LocalRuntimeOS/PersonalContext/`:
  `ContextFactModels.swift`, `ContextPayloadModels.swift`,
  `ContextPurposeGrantModels.swift`, `ContextPurposeGrantStore.swift`,
  `TaskLocalContextOverrideModels.swift`, `PersonalContextRepository.swift`,
  `PersonalContextEvents.swift`, `PersonalContextMigration.swift`,
  `PersonalContextResolver.swift`, `ContextPrecedenceConflictEngine.swift`,
  `ContextUnitTimeZoneResolver.swift`, `PersonalContextReadCapability.swift`,
  `PersonalContextReadClient.swift`, `ResolvedContextViewAssembler.swift`,
  `ContextInfluenceModels.swift`, `ContextInfluenceRecorder.swift`,
  `ContextInfluenceProjector.swift`, `ContextDependencyIndex.swift`,
  `ContextDependencyNotifier.swift`, `ContextImpactPreviewService.swift`,
  `PersonalContextLifecycleService.swift`, `PersonalContextPurgeService.swift`,
  and the disabled `ContextSuggestionClient.swift`.
- Add boundary registrations to
  `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/` and bootstrap; no
  Source Atlas/remote client or consumer write interface.
- Add context library/capture/impact surfaces under
  `Native/Ambitions/Surfaces/You/PersonalContext/` as
  `PersonalContextLibraryView.swift`, `PersonalContextFactEditorView.swift`,
  `PersonalContextInfluenceView.swift`, `PersonalContextImpactView.swift`, and
  `PersonalContextPreviewFixtures.swift`; add
  `TaskLocalContextOverrideSheet.swift` under
  `Native/Ambitions/Surfaces/Shared/PersonalContext/`.
- Add unit tests under
  `Native/AmbitionsTests/LocalRuntimeOS/PersonalContext/` as
  `ContextFactModelsTests.swift`, `ContextPurposeGrantTests.swift`,
  `PersonalContextRepositoryTests.swift`, `PersonalContextResolverTests.swift`,
  `ContextPrecedenceConflictTests.swift`, `ContextUnitTimezoneTests.swift`,
  `PersonalContextReadBoundaryTests.swift`, `TaskLocalContextOverrideTests.swift`,
  `ContextInfluenceImpactTests.swift`, `PersonalContextMigrationPurgeTests.swift`,
  and `PersonalContextPrivacyTests.swift`; add
  `Native/AmbitionsTests/Quality/PersonalContextAccessibilityTests.swift` and
  `Native/AmbitionsUITests/PersonalContextUITests.swift` plus the preview
  fixtures named above.
- Update `project.yml` only if verified resources require it; regenerate.

Sequence: canon/models; repository/grants; resolver/precedence/units; read
capabilities; task overrides; influence/dependencies; mutation/impact/lifecycle;
UI/accessibility; consumer conformance harness; integration; full proof.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Exact native/UI/test
owners, no-remote/no-write boundary, disabled suggestion policy and device/user
evidence hold are explicit. Devan delegated approval; grooming approved
2026-08-04. No runtime/device/usefulness/release evidence is claimed.
