# Implementation Plan

## Outcome and boundary

Implement the approved production United States education, credential, and
provider reference corpus as source-native signed Source Atlas releases. Bundle
a representative offline bootstrap; support exact release-pinned CIP 2020,
IPEDS, College Scorecard, and DAPIP layers; and expose immutable local
claim-bounded queries and accessible source inspection.

The implementation must not create a universal provider/program record, use
“latest” as a release ID, query public sources with private intent/location,
mirror CTDL/CASE content without exact rights, rank providers/programs, predict
personal outcomes, infer admission/transfer/licensure, treat accreditation as
endorsement, create user Proof, make recommendations, or mutate private state.

## Affected components and exact files

### Canon

- Update `docs/canon/specifications/systems/source-atlas.md`.
- Update `docs/canon/specifications/objects/source-reference.md`.
- Update `docs/canon/specifications/global/trust-inspection.md`.
- Update `docs/canon/specifications/systems/privacy-and-data-classification.md`.
- No dedicated education-destination canon specification exists at baseline;
  do not invent one in this implementation. The four exact existing owners
  above carry the corpus contract, while the approved product-development
  documents retain the education-destination product detail.
- If already present from its owning implementation, update
  `docs/canon/specifications/systems/intelligence-evaluation.md` only with the
  education-corpus evidence binding; otherwise leave it untouched and record
  the pending reference.

### Foundry contracts, configuration, and source adapters

Add under `tools/source-atlas/foundry/`:

- `education_corpus_models.py`
- `education_corpus_source_manifest.py`
- `education_corpus_cip_2020.py`
- `education_corpus_ipeds.py`
- `education_corpus_college_scorecard.py`
- `education_corpus_dapip.py`
- `education_corpus_ctdl_case_reservations.py`
- `education_corpus_identity_assertions.py`
- `education_corpus_rights.py`
- `education_corpus_semantic_validation.py`
- `education_corpus_coverage.py`
- `education_corpus_release_diff.py`
- `education_corpus_release_builder.py`
- `education_corpus_cli.py`

Add schemas/configuration:

- `tools/source-atlas/foundry/contracts/education-corpus-release-v1.schema.json`
- `tools/source-atlas/foundry/contracts/education-corpus-shard-v1.schema.json`
- `tools/source-atlas/foundry/contracts/education-corpus-rights-v1.schema.json`
- `tools/source-atlas/foundry/contracts/education-corpus-coverage-v1.schema.json`
- `tools/source-atlas/foundry/contracts/education-corpus-identity-assertion-v1.schema.json`
- `tools/source-atlas/config/education-corpus-sources-v1.json`
- `tools/source-atlas/config/education-corpus-semantic-policy-v1.json`
- `tools/source-atlas/config/education-corpus-rights-policy-v1.json`
- `tools/source-atlas/fixtures/education-corpus/` containing the exact ordinary,
  alternative-provider-absent, historical-completion/no-current-offering,
  mixed-year, imputed, suppressed, branch ambiguity, merger/closure, changed
  accreditation, identity conflict, CTDL/CASE rights-blocked, malformed,
  private-canary, correction, withdrawal, offline, and purge fixtures named in
  `implementation/tasks.md`.

Update `tools/source-atlas/foundry/cli.py` only to register the cohesive
education-corpus subcommand. Extend the existing College Scorecard adapter by
calling shared transport helpers; do not treat its three-school pilot as
production authority or silently change its evidence.

### Bundled public resources and refresh registry

- Add
  `Native/Ambitions/Resources/SourceAtlasEducationCorpus/education-corpus-bootstrap-v1.json`.
- Add the foundry-generated and byte-reviewed
  `Native/Ambitions/Resources/SourceAtlasEducationCorpus/education-corpus-bootstrap-v1.saec`.
- Update `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
  with fixed public release entries for the approved source-family shards.
- Update `project.yml` to add
  `Native/Ambitions/Resources/SourceAtlasEducationCorpus` as a resource build
  phase, then regenerate `Ambitions.xcodeproj/project.pbxproj` with XcodeGen.
  This is required because `Resources/**` is excluded from the recursive Swift
  source declaration.

### Native education-corpus domain and runtime

Add under
`Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/EducationCorpus/`:

- `EducationCorpusIdentityModels.swift`
- `EducationCorpusClassificationModels.swift`
- `EducationCorpusObservationModels.swift`
- `EducationCorpusRecognitionModels.swift`
- `EducationCorpusRightsModels.swift`
- `EducationCorpusCoverageModels.swift`
- `EducationCorpusReleaseManifestModels.swift`
- `EducationCorpusArtifactDecoder.swift`
- `EducationCorpusSemanticValidator.swift`
- `EducationCorpusIdentityResolver.swift`
- `EducationCorpusSnapshotStore.swift`
- `EducationCorpusSnapshotMigration.swift`
- `EducationCorpusQueryIndex.swift`
- `EducationCorpusQueryActor.swift`
- `EducationCorpusCoordinator.swift`
- `EducationCorpusInvalidationPlanner.swift`
- `EducationCorpusRightsPurgeService.swift`
- `EducationCorpusReadClient.swift`

Update only these existing composition/delivery files:

- `Native/Ambitions/App/Bootstrap/RuntimeBootstrap.swift`
- `Native/Ambitions/App/AppSourceAtlasLifecycleRefreshScheduler.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients/RuntimeProjectionQueryClients.swift`

No canonical command, recommendation, model, or private repository client may
be injected into the corpus owner.

### Inspection and accessibility

Add:

- `Native/Ambitions/Trust/EducationCorpusInspectionModels.swift`
- `Native/Ambitions/Trust/EducationCorpusInspectionProjection.swift`
- `Native/Ambitions/Trust/EducationCorpusInspectionView.swift`
- `Native/Ambitions/Trust/EducationCorpusInspectionAccessibility.swift`

Update:

- `Native/Ambitions/Trust/SourceInspectionView.swift`
- `Native/Ambitions/Trust/InspectionSurface.swift`
- `Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceSourceAtlasPrimaryProjection.swift`
- `Native/Ambitions/Surfaces/You/YouRootDetailContent+Sections.swift`

### Exact test files

Add:

- `tools/source-atlas/foundry/tests/test_education_corpus_cip_2020.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_ipeds.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_scorecard.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_dapip.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_identity.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_rights.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_release.py`
- `tools/source-atlas/foundry/tests/test_education_corpus_coverage.py`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusModelsTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusArtifactDecoderTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusSemanticValidatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusIdentityResolverTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusSnapshotStoreTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusSnapshotMigrationTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusCoordinatorTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusQueryTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusInvalidationPurgeTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/EducationCorpus/EducationCorpusPrivacyBoundaryTests.swift`
- `Native/AmbitionsTests/Trust/EducationCorpusInspectionTests.swift`
- `Native/AmbitionsTests/Quality/EducationCorpusAccessibilityTests.swift`
- `Native/AmbitionsUITests/EducationCorpusInspectionUITests.swift`

## Data flow and interfaces

The foundry fetches only configured official public releases, records raw
bytes/source/rights evidence, parses source-native records, applies the exact
semantic field policy, builds explicit identity assertions, runs semantic,
coverage, and evaluation gates, and emits signed immutable `.saec` archives.
Existing public refresh infrastructure transfers only fixed artifact IDs.
Native byte and semantic validation stages releases, then
`EducationCorpusCoordinator` atomically promotes an immutable snapshot.

`EducationCorpusReadClient` accepts only public source/record/claim-family/
snapshot selectors. It has no user, private context, network, command, rank,
approval, model, or write method. Planning/model owners perform private joins
locally and cannot feed selections or outcomes back to the corpus.

## Persistence, migration, concurrency, and recovery

Use the Source Atlas public cache, never the canonical private store. Archives
and shards are immutable/content-addressed; indices are rebuildable; current,
last-known-good, superseded, and invalidated pointers reference complete
snapshot manifests. One coordinator actor serializes promotion, rollback,
invalidation, reset, and purge. Readers lease an immutable snapshot during
refresh. Commands and journals are idempotent by source/release/hash.

Migration installs the v1 corpus independently, maps only exact legacy public
claim IDs through explicit relations, and marks the narrow prior pack
superseded without reinterpreting unmatched claims. Failure preserves the old
pack and private core. Rights purge disables projections immediately and
resumes deletion across archive, shard, index, searchable text, extracted
content, rendering, thumbnail/contact-sheet, export, and cache layers until
only legally permitted opaque lineage remains.

## Rollout and implementation order

Land canon/contracts/config first; CIP and source value semantics second; IPEDS
and Scorecard third; DAPIP and identity assertions fourth; rights/CTDL/CASE
gates fifth; foundry release/coverage sixth; native models/decoder seventh;
store/migration/coordinator eighth; query/read boundary ninth; inspection and
accessibility tenth; resources/registry/project generation eleventh; complete
evaluation and proof last.

Production promotion remains disabled until source, rights, identity,
statistical, coverage, privacy, accessibility, performance, device, and
regression evidence passes. Current offerings, recommendation, model use,
direct-user usefulness, merge, deployment, and release remain separate.

## Grooming review and approval

Review verdict: **PASS** after two repair rounds. The first repair replaced vague
provider integration with exact existing You/Trust composition files, made the
resource build-phase edit explicit because `Resources/**` is excluded, and
included derived renderings/contact sheets in purge. Exact canon-resolution,
foundry, schema/config, resource, native, inspection, project, and test paths
are named. The second repair reconciled the Design and plan on
`tools/source-atlas/foundry/education_corpus_*.py` and removed a runtime canon-
path discovery step after live canon inspection proved no dedicated education
specification exists. No product authority is deferred to implementation.

Devan delegated approval authority for this documentation program. The
implementation grooming set was approved under that authority on 2026-08-04.
This makes the initiative implementation-ready as documentation; it does not
claim source, build, runtime, device, merge, deployment, or release work.
