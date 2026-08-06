# Implementation Plan

## Outcome and boundary

Implement the approved production United States career reference corpus as
source-native, signed Source Atlas releases. Bundle the complete O*NET 30.3
identity/core-descriptor launch floor, support independently versioned SOC 2018,
OOH/Employment Projections 2024–34, May 2025 OEWS, and 2025 preliminary ORS
overlays, and expose immutable local claim-bounded queries and accessible source
inspection.

The implementation must not create a universal career row, query sources with
private intent/location, infer user traits or compatibility, rank human/career
worth, treat estimates/typical preparation as personal facts or gates, package
ESCO, resolve current opportunities/licensure, make recommendations, or mutate
canonical state.

## Affected components and exact files

### Canon

- Update `docs/canon/specifications/systems/source-atlas.md`.
- Update `docs/canon/specifications/objects/source-reference.md`.
- Update `docs/canon/specifications/global/trust-inspection.md`.
- Update `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- If already present from its owning implementation, update
  `docs/canon/specifications/systems/intelligence-evaluation.md` only with the
  career-corpus evidence binding; otherwise leave it untouched and record the
  pending cross-reference.

### Foundry contracts, configuration, and source adapters

Add under `tools/source-atlas/foundry/`:

- `career_corpus_models.py`
- `career_corpus_source_manifest.py`
- `career_corpus_onet_30_3.py`
- `career_corpus_bls_soc_2018.py`
- `career_corpus_bls_ooh_ep_2024_34.py`
- `career_corpus_bls_oews_2025.py`
- `career_corpus_bls_ors_2025.py`
- `career_corpus_rights.py`
- `career_corpus_semantic_validation.py`
- `career_corpus_coverage.py`
- `career_corpus_release_diff.py`
- `career_corpus_release_builder.py`
- `career_corpus_cli.py`

Add these schemas/configuration:

- `tools/source-atlas/foundry/contracts/career-corpus-release-v1.schema.json`
- `tools/source-atlas/foundry/contracts/career-corpus-shard-v1.schema.json`
- `tools/source-atlas/foundry/contracts/career-corpus-rights-v1.schema.json`
- `tools/source-atlas/foundry/contracts/career-corpus-coverage-v1.schema.json`
- `tools/source-atlas/config/career-corpus-sources-v1.json`
- `tools/source-atlas/config/career-corpus-onet-30.3-file-policy.json`
- `tools/source-atlas/fixtures/career-corpus/` with the exact ordinary,
  regulated, competitive, title-only, aggregate, sparse, suppressed,
  preliminary, stale, conflict, malformed, rights-blocked, private-canary, and
  withdrawal fixtures named in `implementation/tasks.md`.

Update `tools/source-atlas/foundry/cli.py` only to register the new cohesive
career-corpus subcommand. Do not extend the legacy broad-occupational proof into
production authority.

### Bundled public resource and refresh registry

- Add
  `Native/Ambitions/Resources/SourceAtlasCareerCorpus/career-corpus-bootstrap-v1.json`.
- Add the foundry-generated and byte-reviewed
  `Native/Ambitions/Resources/SourceAtlasCareerCorpus/career-corpus-onet-30.3.sacp`.
  Its signed internal manifest contains `metadata`, `identity`, and exactly the
  23 SOC major-group shards `11`, `13`, `15`, `17`, `19`, `21`, `23`, `25`,
  `27`, `29`, `31`, `33`, `35`, `37`, `39`, `41`, `43`, `45`, `47`, `49`,
  `51`, `53`, and `55`.
- Update `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
  with fixed public release entries for the career base and BLS overlays.
- Update `project.yml` to add
  `Native/Ambitions/Resources/SourceAtlasCareerCorpus` as a resource build phase,
  then regenerate `Ambitions.xcodeproj/project.pbxproj` with XcodeGen. This
  resource edit is required because `Resources/**` is excluded from the
  recursive Swift source declaration.

### Native career-corpus domain and runtime

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/CareerCorpus/`:

- `CareerCorpusIdentityModels.swift`
- `CareerCorpusDescriptorModels.swift`
- `CareerCorpusStatisticalModels.swift`
- `CareerCorpusRightsModels.swift`
- `CareerCorpusCoverageModels.swift`
- `CareerCorpusReleaseManifestModels.swift`
- `CareerCorpusArtifactDecoder.swift`
- `CareerCorpusSemanticValidator.swift`
- `CareerCorpusSnapshotStore.swift`
- `CareerCorpusSnapshotMigration.swift`
- `CareerCorpusQueryIndex.swift`
- `CareerCorpusQueryActor.swift`
- `CareerCorpusCoordinator.swift`
- `CareerCorpusInvalidationPlanner.swift`
- `CareerCorpusRightsPurgeService.swift`
- `CareerCorpusReadClient.swift`

Update only these existing composition/delivery files:

- `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift`
- `Native/Ambitions/App/AppSourceAtlasLifecycleRefreshScheduler.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/RuntimeProjectionQueryClients.swift`

No canonical command or mutation client may be injected into the corpus.

### Inspection and accessibility

Add:

- `Native/Ambitions/Trust/CareerCorpusInspectionModels.swift`
- `Native/Ambitions/Trust/CareerCorpusInspectionProjection.swift`
- `Native/Ambitions/Trust/CareerCorpusInspectionView.swift`
- `Native/Ambitions/Trust/CareerCorpusInspectionAccessibility.swift`

Update:

- `Native/Ambitions/Trust/SourceInspectionView.swift`
- `Native/Ambitions/Trust/InspectionSurface.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceSourceAtlasPrimaryProjection.swift`
- `Native/Ambitions/Surfaces/You/YouRootDetailContent+Sections.swift`

### Exact test files

Add:

- `tools/source-atlas/foundry/tests/test_career_corpus_onet_30_3.py`
- `tools/source-atlas/foundry/tests/test_career_corpus_bls_overlays.py`
- `tools/source-atlas/foundry/tests/test_career_corpus_rights.py`
- `tools/source-atlas/foundry/tests/test_career_corpus_release.py`
- `tools/source-atlas/foundry/tests/test_career_corpus_coverage.py`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusModelsTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusArtifactDecoderTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusSemanticValidatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusSnapshotStoreTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusSnapshotMigrationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusCoordinatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusQueryTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusInvalidationPurgeTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/CareerCorpus/CareerCorpusPrivacyBoundaryTests.swift`
- `Native/AmbitionsTests/Trust/CareerCorpusInspectionTests.swift`
- `Native/AmbitionsTests/Quality/CareerCorpusAccessibilityTests.swift`
- `Native/AmbitionsUITests/CareerCorpusInspectionUITests.swift`

## Data flow and interfaces

The foundry fetches only configured official public releases, records exact raw
bytes/source/rights evidence, parses into source-native records, applies the
Scope file/eligibility policy, runs semantic/coverage/evaluation gates, and
emits signed immutable `.sacp` archives. Existing public refresh infrastructure
transfers fixed artifact IDs. Native byte and semantic validation stages the
release, then `CareerCorpusCoordinator` atomically promotes an immutable
snapshot. Query and Trust surfaces acquire snapshot tokens and receive only
public projections.

`CareerCorpusReadClient` accepts source/occupation/claim-family/snapshot
selectors. It has no user, private context, network, command, approval, or write
method. Planning and future model owners perform private joins locally and
cannot feed selection behavior back into the corpus.

## Persistence, migration, concurrency, and recovery

Use the existing public-reference cache/vault, not the canonical private store.
Archives and shards are immutable/content-addressed; indices are rebuildable;
current/last-known-good/superseded pointers reference complete snapshot
manifests. One coordinator actor serializes stage/promote/rollback/purge.
Readers remain on an immutable snapshot during refresh. Batches and journals are
idempotent by release/shard/hash.

Migration installs the new v1 schema and bundled base independently, then marks
the old software-developer validation pack superseded without copying or
reinterpreting its claims. Failure preserves the old pack and private core.
Rights/source purge disables current projections immediately and resumes byte,
index, render-cache, and search-text deletion until only permitted
non-recoverable lineage remains.

## Rollout and implementation order

Land canon/contracts/config first; O*NET adapter and rights second; BLS adapters
third; foundry release/coverage fourth; native models/decoder fifth; store/
migration/coordinator sixth; query/read client seventh; inspection/accessibility
eighth; bundled archive/registry/integration ninth; full evaluation and proof
last. Production promotion remains disabled until source, rights, coverage,
privacy, accessibility, performance, device, and regression evidence pass for
each claim family.

No workflow edit is planned. Model use, ESCO, cross-taxonomy, current authority,
personal recommendation, direct-user usefulness, merge, deployment, and release
remain separate evidence/authority.

## Grooming review and approval

Review verdict: **PASS** after one repair round. The repair replaced a deferred
You integration decision with the two exact existing owning files and routed
all new foundry commands through the repository's established Source Atlas
entrypoint. Exact canon, foundry, schema/config, resource, native,
inspection, composition, generated-project, and test paths are named. The plan
preserves source-native releases, fixed public acquisition, statistical and
rights semantics, immutable snapshots, migration, rollback/purge, public-only
queries, sensitive-inference limits, accessibility, performance, and claim
ceilings without leaving product authority to implementation.

Devan delegated approval authority for this documentation program. The
implementation grooming set was approved under that authority on 2026-08-04.
This makes the initiative implementation-ready as documentation; it does not
claim any source, build, runtime, device, merge, deployment, or release work has
occurred.
