# Implementation Plan

## Outcome and boundary

Implement the approved production possibility catalog as signed source-native
Source Atlas releases. Bundle a representative offline floor; support a finite
revision-bound Wikidata identity allowlist, signed Ambitions editorial
eligibility, exact rights-qualified Smithsonian/Library starter materials, and
independent NPS/AmeriCorps overlays; expose immutable read-only local queries
and accessible source/editorial inspection.

The implementation must not create a universal hobby taxonomy, perform live
arbitrary graph queries, follow transitive relations, infer user interests or
traits, rank leisure, complete safety/current opportunity claims, recommend
social/physical records, mutate private state, or perform external actions.

## Affected components and exact files

### Canon

- Update `docs/canon/specifications/systems/source-atlas.md`.
- Update `docs/canon/specifications/objects/source-reference.md`.
- Update `docs/canon/specifications/global/trust-inspection.md`.
- Update `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- If the upstream v1 implementation has created it, update
  `docs/canon/specifications/systems/hobby-destination-recommendations.md` only
  to bind the production projection; at the current baseline the file is absent,
  so this implementation must not invent it ahead of its owning v1 work.
- If present from its owning implementation, update
  `docs/canon/specifications/systems/intelligence-evaluation.md` only with the
  catalog evidence binding; otherwise record the pending cross-reference.

### Foundry contracts, configuration, and adapters

Add under `tools/source-atlas/foundry/`:

- `possibility_catalog_models.py`
- `possibility_catalog_source_lock.py`
- `possibility_catalog_wikidata.py`
- `possibility_catalog_editorial.py`
- `possibility_catalog_materials.py`
- `possibility_catalog_overlays.py`
- `possibility_catalog_rights_cultural.py`
- `possibility_catalog_semantic_validation.py`
- `possibility_catalog_coverage.py`
- `possibility_catalog_release_diff.py`
- `possibility_catalog_release_builder.py`
- `possibility_catalog_cli.py`

Add:

- `tools/source-atlas/foundry/contracts/possibility-catalog-release-v1.schema.json`
- `tools/source-atlas/foundry/contracts/possibility-catalog-shard-v1.schema.json`
- `tools/source-atlas/foundry/contracts/possibility-catalog-editorial-v1.schema.json`
- `tools/source-atlas/foundry/contracts/possibility-catalog-rights-v1.schema.json`
- `tools/source-atlas/foundry/contracts/possibility-catalog-coverage-v1.schema.json`
- `tools/source-atlas/config/possibility-catalog-sources-v1.json`
- `tools/source-atlas/config/possibility-catalog-entity-allowlist-v1.json`
- `tools/source-atlas/config/possibility-catalog-editorial-v1.json`
- `tools/source-atlas/config/possibility-catalog-policy-v1.json`
- `tools/source-atlas/fixtures/possibility-catalog/` with exact multi-facet,
  ambiguous, redirect/merge/delete/vandalism, unreviewed relation, low-risk,
  tool/safety/provider/protected-context, harmful label, record/media rights,
  cultural block, NPS/AmeriCorps, malformed, private-canary, correction,
  withdrawal, offline, and purge fixtures from `implementation/tasks.md`.

Update `tools/source-atlas/foundry/cli.py` only to register the cohesive
possibility-catalog subcommand. Reuse generic fixed-source transport helpers;
do not widen the generic Wikidata crosswalk adapter into product eligibility.

### Bundled resources and refresh registry

- Add
  `Native/Ambitions/Resources/SourceAtlasPossibilityCatalog/possibility-catalog-bootstrap-v1.json`.
- Add the generated/byte-reviewed
  `Native/Ambitions/Resources/SourceAtlasPossibilityCatalog/possibility-catalog-bootstrap-v1.sapc`.
- Update `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
  with fixed public catalog/source/editorial release entries.
- Update `project.yml` to add
  `Native/Ambitions/Resources/SourceAtlasPossibilityCatalog` as a resource build
  phase, then regenerate `Ambitions.xcodeproj/project.pbxproj` with XcodeGen
  because `Resources/**` is excluded from recursive Swift sources.

### Native domain and runtime

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/`:

- `PossibilityCatalogIdentityModels.swift`
- `PossibilityCatalogEditorialModels.swift`
- `PossibilityCatalogMaterialModels.swift`
- `PossibilityCatalogOverlayModels.swift`
- `PossibilityCatalogRightsCulturalModels.swift`
- `PossibilityCatalogCoverageModels.swift`
- `PossibilityCatalogReleaseManifestModels.swift`
- `PossibilityCatalogArtifactDecoder.swift`
- `PossibilityCatalogSemanticValidator.swift`
- `PossibilityCatalogSnapshotStore.swift`
- `PossibilityCatalogSnapshotMigration.swift`
- `PossibilityCatalogQueryIndex.swift`
- `PossibilityCatalogQueryActor.swift`
- `PossibilityCatalogCoordinator.swift`
- `PossibilityCatalogInvalidationPlanner.swift`
- `PossibilityCatalogPurgeService.swift`
- `PossibilityCatalogReadClient.swift`

Update:

- `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift`
- `Native/Ambitions/App/AppSourceAtlasLifecycleRefreshScheduler.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/RuntimeProjectionQueryClients.swift`

If the approved v1 hobby consumer files exist, update only:

- `Native/Ambitions/Core/LocalRuntimeOS/Planning/HobbyRecommendation/HobbyDestinationEligibilityPolicy.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Planning/HobbyRecommendation/HobbyExplorationCoordinator.swift`

The consumer integration is a typed read projection. It cannot move private
session data or outcomes into the catalog. If the v1 files are not yet present,
leave integration pending rather than creating the recommendation owner here.

### Inspection and accessibility

Add:

- `Native/Ambitions/Trust/PossibilityCatalogInspectionModels.swift`
- `Native/Ambitions/Trust/PossibilityCatalogInspectionProjection.swift`
- `Native/Ambitions/Trust/PossibilityCatalogInspectionView.swift`
- `Native/Ambitions/Trust/PossibilityCatalogInspectionAccessibility.swift`

Update:

- `Native/Ambitions/Trust/SourceInspectionView.swift`
- `Native/Ambitions/Trust/InspectionSurface.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceSourceAtlasPrimaryProjection.swift`
- `Native/Ambitions/Surfaces/You/YouRootDetailContent+Sections.swift`
- If present, `Native/Ambitions/Trust/HobbySourceInspectionView.swift` only to
  reuse the production claim inspection projection.

### Exact tests

Add:

- `tools/source-atlas/foundry/tests/test_possibility_catalog_wikidata.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_editorial.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_materials.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_overlays.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_rights_cultural.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_release.py`
- `tools/source-atlas/foundry/tests/test_possibility_catalog_coverage.py`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogModelsTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogArtifactDecoderTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogSemanticValidatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogSnapshotStoreTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogSnapshotMigrationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogCoordinatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogQueryTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogInvalidationPurgeTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/PossibilityCatalog/PossibilityCatalogPrivacyBoundaryTests.swift`
- `Native/AmbitionsTests/Trust/PossibilityCatalogInspectionTests.swift`
- `Native/AmbitionsTests/Quality/PossibilityCatalogAccessibilityTests.swift`
- `Native/AmbitionsUITests/PossibilityCatalogInspectionUITests.swift`

If the v1 hobby consumer exists, extend its already named tests with a
production-projection fixture; do not move those tests into Source Atlas.

## Data flow, persistence, migration, and concurrency

Foundry capture compiles only the fixed source lock, records exact entity/
material/overlay bytes and rights, applies structured extraction, joins the
signed editorial manifest, runs semantic/coverage/evaluation gates, and emits
immutable `.sapc` shards. Existing Source Atlas transfers fixed artifact IDs.
Native semantic parity stages and atomically promotes a complete snapshot.

Use the Source Atlas public cache, not private stores. Immutable snapshots and
rebuildable indices use current/LKG pointers and leased generations. A single
coordinator actor serializes promotion, rollback, invalidation, reset, and purge;
commands/journals are idempotent. Migration links legacy source claims only
through explicit overlays and never creates a universal row. Rights/cultural
purge disables projections immediately and removes raw, derived, indexed,
rendered, model-cache, and export bytes before use resumes.

## Rollout and implementation order

Land canon/contracts/policy first; fixed Wikidata/source lock second; editorial
eligibility third; starter materials/rights/cultural state fourth; overlays
fifth; release/coverage sixth; native parity seventh; store/migration/
coordinator eighth; query/read boundary ninth; inspection/accessibility tenth;
resources/registry/project generation eleventh; optional v1 consumer binding
twelfth; full proof last.

Production promotion remains disabled until source, editorial, rights/cultural,
privacy, safety/dignity, coverage, accessibility, performance, device, and
regression evidence passes. Broader recommendation eligibility, current
opportunities, model use, direct-user usefulness, merge, deployment, and
release remain separate.

## Grooming review and approval

Review verdict: **PASS** after one reconciliation round. Review repaired the
dependency boundary by making hobby-recommendation integration conditional on
the exact upstream v1 files rather than recreating that owner, and made
`project.yml`/generated-project work explicit for the excluded resource folder.
Exact existing/conditional canon, foundry, config/schema, resource, native,
inspection, integration, generated-project, and test paths are named.

Devan delegated approval authority for this documentation program. The
implementation grooming set was approved under that authority on 2026-08-04.
This makes the corpus independently implementation-ready and its optional v1
integration dependency explicit; it does not claim source, build, runtime,
device, merge, deployment, or release work.
