# Implementation Plan

## Outcome and boundary

Implement a signed, public, source-native Relationship Registry for the exact
approved mapping sets. Preserve mapping-set/endpoint releases, source predicates,
SSSOM-compatible metadata, product use profiles, conflicts/candidates/no-match,
dependency invalidation, offline/LKG and accessible inspection.

Do not merge concepts, materialize graph inference, transfer source claims,
float mappings to new endpoint releases, approve model candidates, infer user
Capability, adjudicate current acceptance, mutate canonical state or perform
external actions.

## Exact affected files

### Canon

- Add `docs/canon/specifications/systems/relationship-registry.md`.
- Update `docs/canon/specifications/systems/source-atlas.md`.
- Update `docs/canon/specifications/objects/source-reference.md`.
- Update `docs/canon/specifications/global/trust-inspection.md`.
- Update `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- If present from its owner, update
  `docs/canon/specifications/systems/intelligence-evaluation.md` only with the
  relationship evidence binding.

### Foundry, schemas, configuration and fixtures

Add under `tools/source-atlas/foundry/`:

- `relationship_registry_models.py`
- `relationship_registry_source_lock.py`
- `relationship_registry_cip_versions.py`
- `relationship_registry_cip_soc.py`
- `relationship_registry_onet_soc.py`
- `relationship_registry_onet_esco.py`
- `relationship_registry_publisher_alignments.py`
- `relationship_registry_candidates.py`
- `relationship_registry_use_profiles.py`
- `relationship_registry_rights.py`
- `relationship_registry_semantic_validation.py`
- `relationship_registry_coverage.py`
- `relationship_registry_release_diff.py`
- `relationship_registry_release_builder.py`
- `relationship_registry_cli.py`

Add:

- `tools/source-atlas/foundry/contracts/relationship-registry-release-v1.schema.json`
- `tools/source-atlas/foundry/contracts/relationship-mapping-set-v1.schema.json`
- `tools/source-atlas/foundry/contracts/relationship-edge-v1.schema.json`
- `tools/source-atlas/foundry/contracts/relationship-use-profile-v1.schema.json`
- `tools/source-atlas/foundry/contracts/relationship-coverage-v1.schema.json`
- `tools/source-atlas/config/relationship-registry-sources-v1.json`
- `tools/source-atlas/config/relationship-registry-predicates-v1.json`
- `tools/source-atlas/config/relationship-registry-use-profiles-v1.json`
- `tools/source-atlas/config/relationship-registry-rights-v1.json`
- `tools/source-atlas/fixtures/relationship-registry/` with every fixed mapping,
  version action, exact/close/broad/narrow/related chain/cycle, conflict,
  candidate/rejected/no-match/unmapped, endpoint drift, rights, private-canary,
  dependency, rollback and purge fixture from `implementation/tasks.md`.

Update `tools/source-atlas/foundry/cli.py` only to register the cohesive
relationship-registry command. Reuse transport/source-lock helpers, not generic
crosswalk arrays as authority.

### Resources and Xcode project

- Add
  `Native/Ambitions/Resources/SourceAtlasRelationshipRegistry/relationship-registry-bootstrap-v1.json`.
- Add generated/byte-reviewed
  `Native/Ambitions/Resources/SourceAtlasRelationshipRegistry/relationship-registry-bootstrap-v1.sarr`.
- Update `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
  with fixed public mapping-set/profile releases.
- Update `project.yml` to add the resource directory, then regenerate
  `Ambitions.xcodeproj/project.pbxproj`; `Resources/**` is otherwise excluded.

### Native registry

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/`:

- `RelationshipConceptModels.swift`
- `RelationshipMappingSetModels.swift`
- `RelationshipPredicateModels.swift`
- `RelationshipEdgeModels.swift`
- `RelationshipUseProfileModels.swift`
- `RelationshipConflictModels.swift`
- `RelationshipCoverageModels.swift`
- `RelationshipDependencyModels.swift`
- `RelationshipRegistryReleaseModels.swift`
- `RelationshipRegistryArtifactDecoder.swift`
- `RelationshipRegistrySemanticValidator.swift`
- `RelationshipRegistrySnapshotStore.swift`
- `RelationshipRegistrySnapshotMigration.swift`
- `RelationshipRegistryQueryIndex.swift`
- `RelationshipRegistryQueryActor.swift`
- `RelationshipDependencyIndex.swift`
- `RelationshipDependencyNotifier.swift`
- `RelationshipRegistryCoordinator.swift`
- `RelationshipRegistryInvalidationPlanner.swift`
- `RelationshipRegistryPurgeService.swift`
- `RelationshipRegistryReadClient.swift`

Update:

- `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift`
- `Native/Ambitions/App/AppSourceAtlasLifecycleRefreshScheduler.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/RuntimeProjectionQueryClients.swift`

No private repository, canonical command, model approval, current-authority or
external-operation client may be injected.

### Trust and exact tests

Add:

- `Native/Ambitions/Trust/RelationshipInspectionModels.swift`
- `Native/Ambitions/Trust/RelationshipInspectionProjection.swift`
- `Native/Ambitions/Trust/RelationshipInspectionView.swift`
- `Native/Ambitions/Trust/RelationshipInspectionAccessibility.swift`

Update `Native/Ambitions/Trust/SourceInspectionView.swift` and
`Native/Ambitions/Trust/InspectionSurface.swift`.

Add foundry tests:

- `tools/source-atlas/foundry/tests/test_relationship_registry_cip_versions.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_cip_soc.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_onet_soc_esco.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_alignments_candidates.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_profiles_inference.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_rights.py`
- `tools/source-atlas/foundry/tests/test_relationship_registry_release_coverage.py`

Add native/UI tests:

- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryModelsTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryArtifactDecoderTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistrySemanticValidatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistrySnapshotStoreTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistrySnapshotMigrationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryCoordinatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryQueryNoInferenceTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipDependencyInvalidationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryInvalidationPurgeTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/RelationshipRegistry/RelationshipRegistryPrivacyBoundaryTests.swift`
- `Native/AmbitionsTests/Trust/RelationshipInspectionTests.swift`
- `Native/AmbitionsTests/Quality/RelationshipInspectionAccessibilityTests.swift`
- `Native/AmbitionsUITests/RelationshipInspectionUITests.swift`

## Data, lifecycle, and rollout

Foundry builds from fixed mapping/source locks, preserves exact source rows and
metadata, applies use-profile policy without rewriting predicates, evaluates,
and emits signed immutable shards. Existing Source Atlas transfers fixed public
IDs. Native parity validates and the coordinator promotes one snapshot.

Use the Source Atlas public cache. Mapping and dependency indices are public,
derived and rebuildable; dependency tokens contain opaque public consumer/
evidence IDs only. Snapshot readers lease immutable generations. One actor
serializes promotion/rollback/invalidation/reset/purge; journals are idempotent.
Legacy crosswalks import only when exact metadata/release/rights reconstruct;
others remain candidates. Withdrawal purges raw/derived/index/render/cache/
export bytes and prohibited dependency metadata.

Implement canon/contracts/predicates first; three current mapping adapters
second; gated ESCO/alignments/candidates third; use profiles/no-inference fourth;
foundry release/coverage fifth; native parity sixth; lifecycle/dependencies
seventh; query eighth; Trust/accessibility ninth; resources/project generation
tenth; complete proof last.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Review made the
dependency files explicitly public/opaque, added a dedicated no-inference test,
and made the resource project edit exact. All canon, foundry, config/schema,
resource, native, Trust, integration and test paths are named.

Devan delegated approval authority for this program. Grooming was approved on
2026-08-04. The documents are implementation-ready; no implementation, build,
runtime, device, merge, deployment or release evidence is claimed.
