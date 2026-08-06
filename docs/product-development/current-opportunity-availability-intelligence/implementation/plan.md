# Implementation Plan

## Outcome and boundary

Implement the approved public Current Authority Registry, synthetic conformance
source, local-only filtering, inspection, exact invalidation and lifecycle. A
real source adapter may be enabled only if its exact source-admission contract
passes. Do not add private remote search, personal eligibility, transactions,
canonical/schedule mutation or unsupported source content.

## Exact affected files

### Canon

- Add `docs/canon/specifications/systems/current-authority-registry.md`.
- Update `docs/canon/specifications/systems/source-atlas.md`.
- Update `docs/canon/specifications/objects/source-reference.md`.
- Update `docs/canon/specifications/global/trust-inspection.md`.
- Update `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- If present from their owners, add typed read-only bindings to destination,
  path, simulation and intelligence-evaluation specifications.

### Foundry and contracts

Add under `tools/source-atlas/foundry/`:

- `current_authority_models.py`
- `current_authority_source_admission.py`
- `current_authority_source_lock.py`
- `current_authority_synthetic_adapter.py`
- `current_authority_temporal_validation.py`
- `current_authority_rights.py`
- `current_authority_conflicts.py`
- `current_authority_use_profiles.py`
- `current_authority_coverage.py`
- `current_authority_release_diff.py`
- `current_authority_release_builder.py`
- `current_authority_cli.py`

Add under `tools/source-atlas/foundry/contracts/`:
`current-authority-release-v1.schema.json`,
`current-authority-offering-v1.schema.json`,
`current-authority-claim-v1.schema.json`,
`current-authority-source-admission-v1.schema.json`,
`current-authority-use-profile-v1.schema.json`, and
`current-authority-coverage-v1.schema.json`. Add
`current-authority-sources-v1.json`, `current-authority-claim-types-v1.json`,
`current-authority-purposes-v1.json`, `current-authority-rights-v1.json`, and
`current-authority-freshness-v1.json` under `tools/source-atlas/config/`. Add
exhaustive synthetic fixtures under
`tools/source-atlas/fixtures/current-authority/`. Register one cohesive
`current-authority` command in `tools/source-atlas/foundry/cli.py`.

### Resources and project

- Add `Native/Ambitions/Resources/SourceAtlasCurrentAuthority/current-authority-conformance-v1.json`.
- Add its generated/byte-reviewed `.saca` artifact.
- Update `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`.
- Update `project.yml`, regenerate `Ambitions.xcodeproj/project.pbxproj` because
  the new resource directory is otherwise excluded.

### Native registry

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/CurrentAuthority/`:

- `CurrentAuthoritySourceAdmissionModels.swift`
- `CurrentAuthorityOfferingModels.swift`
- `CurrentAuthorityClaimModels.swift`
- `CurrentAuthorityTemporalModels.swift`
- `CurrentAuthorityUseProfileModels.swift`
- `CurrentAuthorityConflictModels.swift`
- `CurrentAuthorityCoverageModels.swift`
- `CurrentAuthorityDependencyModels.swift`
- `CurrentAuthorityReleaseModels.swift`
- `CurrentAuthorityArtifactDecoder.swift`
- `CurrentAuthoritySemanticValidator.swift`
- `CurrentAuthoritySnapshotStore.swift`
- `CurrentAuthoritySnapshotMigration.swift`
- `CurrentAuthorityQueryIndex.swift`
- `CurrentAuthorityQueryActor.swift`
- `CurrentAuthorityLocalFilterEvaluator.swift`
- `CurrentAuthorityCoordinator.swift`
- `CurrentAuthorityExpirationEngine.swift`
- `CurrentAuthorityInvalidationPlanner.swift`
- `CurrentAuthorityDependencyNotifier.swift`
- `CurrentAuthoritySafeLinkBuilder.swift`
- `CurrentAuthorityResetPurgeService.swift`
- `CurrentAuthorityReadClient.swift`

Update runtime bootstrap, Source Atlas refresh scheduler/target registry and
projection query clients. Inject no canonical command, scheduling command,
external-operation client or network query client.

### Trust UI and tests

Add `CurrentOpportunityInspectionModels.swift`,
`CurrentOpportunityInspectionProjection.swift`,
`CurrentOpportunityInspectionView.swift`, and
`CurrentOpportunityInspectionAccessibility.swift` under
`Native/Ambitions/Trust/`; integrate them into source inspection. Add
`test_current_authority_source_admission.py`,
`test_current_authority_temporal_states.py`,
`test_current_authority_rights.py`,
`test_current_authority_conflicts_profiles.py`, and
`test_current_authority_release_coverage.py` under
`tools/source-atlas/foundry/tests/`. Add `CurrentAuthorityModelsTests.swift`,
`CurrentAuthorityArtifactDecoderTests.swift`,
`CurrentAuthoritySemanticValidatorTests.swift`,
`CurrentAuthoritySnapshotStoreTests.swift`,
`CurrentAuthoritySnapshotMigrationTests.swift`,
`CurrentAuthorityQueryFilterTests.swift`,
`CurrentAuthorityExpirationTests.swift`,
`CurrentAuthorityDependencyInvalidationTests.swift`,
`CurrentAuthorityConcurrencyTests.swift`,
`CurrentAuthorityPrivacyBoundaryTests.swift`,
`CurrentAuthoritySafeLinkTests.swift`, and
`CurrentAuthorityResetPurgeTests.swift` under
`Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CurrentAuthority/`. Add
`Native/AmbitionsTests/Quality/CurrentOpportunityInspectionAccessibilityTests.swift`
and `Native/AmbitionsUITests/CurrentOpportunityInspectionUITests.swift`.

## Data, lifecycle, and sequencing

Implement schemas/source-admission/temporal policy first; synthetic adapter and
release second; native parity third; immutable lifecycle fourth; query/local
filter fifth; dependency/expiration sixth; Trust/link safety seventh; resource
integration eighth; complete verification last. Each task is independently
reviewable and keeps the registry unavailable until all required gates pass.

Public snapshots are rebuildable. Private filters/dismissals/report drafts stay
in existing private owners and never enter public artifacts. One actor and an
idempotent journal serialize promotion/rollback/expiry/reset/purge. Withdrawal
purges prohibited bytes; evidence tokens contain only public opaque IDs.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. The review made the
synthetic source mandatory, real-source enablement conditional, project/resource
edits exact, private filter persistence absent, and verification/source terms
gates explicit. Devan delegated approval; grooming was approved on 2026-08-04.
No implementation, build, runtime, device, merge or release evidence is claimed.
