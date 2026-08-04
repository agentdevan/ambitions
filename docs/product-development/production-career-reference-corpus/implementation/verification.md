# Verification

## Exact automated, foundry, static, and build commands

Run from repository root. Record exit status, exact source/resource hashes, and
launched/executed/passed/failed/skipped counts where available.

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/production-career-reference-corpus --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/source-atlas/foundry/tests/test_career_corpus_onet_30_3.py tools/source-atlas/foundry/tests/test_career_corpus_bls_overlays.py tools/source-atlas/foundry/tests/test_career_corpus_rights.py tools/source-atlas/foundry/tests/test_career_corpus_release.py tools/source-atlas/foundry/tests/test_career_corpus_coverage.py
python3 tools/source-atlas/source-atlas-foundry.py career-corpus validate-fixtures
python3 tools/source-atlas/source-atlas-foundry.py career-corpus build --source-lock tools/source-atlas/config/career-corpus-sources-v1.json --output /tmp/ambitions-career-corpus-build
python3 tools/source-atlas/source-atlas-foundry.py career-corpus verify --release /tmp/ambitions-career-corpus-build/career-corpus-release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-CAREER-CORPUS --test AmbitionsTests/CareerCorpusModelsTests --test AmbitionsTests/CareerCorpusArtifactDecoderTests --test AmbitionsTests/CareerCorpusSemanticValidatorTests --test AmbitionsTests/CareerCorpusSnapshotStoreTests --test AmbitionsTests/CareerCorpusSnapshotMigrationTests --test AmbitionsTests/CareerCorpusCoordinatorTests --test AmbitionsTests/CareerCorpusQueryTests --test AmbitionsTests/CareerCorpusInvalidationPurgeTests --test AmbitionsTests/CareerCorpusPrivacyBoundaryTests --test AmbitionsTests/CareerCorpusInspectionTests --test AmbitionsTests/CareerCorpusAccessibilityTests
make test-local BATCH=PDL-CAREER-CORPUS-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-CAREER-CORPUS
git diff --check
```

The production-source build command must run from exact downloaded/captured
source locks and may require network. Repeat `build` from the locked local bytes
with network denied and require identical output hashes. Never put private
values, API secrets, or production signing material in commands or committed
fixtures.

Run strict SwiftLint against every changed Swift file using the pinned
`ghcr.io/realm/swiftlint:latest` container and the exact strict arguments in
`.github/workflows/code-quality.yml`. After the generated project is committed,
rerun `xcodegen generate` and require
`git diff --exit-code -- Ambitions.xcodeproj`. Run the complete unchanged Code
Quality workflow on the published branch.

## Source, rights, and foundry evidence

- Record O*NET 30.3, SOC 2018, OOH/EP 2024–34, May 2025 OEWS, and 2025
  preliminary ORS acquisition locators, retrieved times, raw byte hashes,
  manifests/data dictionaries, exact archive members, and source terms.
- Account for all 1,016 O*NET identities and each normative file: expected,
  parsed, eligible, inspection-only, missing, rejected, and rights-blocked.
- Verify O*NET CC BY 4.0 release attribution, USDOL/ETA credit, change indication,
  trademark wording, external-source exclusions, and no Career Exploration Tool
  content. Verify BLS source/retrieval/downstream-analysis text and no logos/
  protected images.
- Rebuild twice from locked bytes, clean directories, injected clock, and exact
  adapter/schema/policy revisions; require identical shard/manifest hashes and
  record ordering.
- Independently adjudicate golden claims/rows for ordinary, regulated,
  competitive, title-only, aggregate, `all other`, sparse, suppressed,
  preliminary, stale, conflict, correction, and rights-withdrawal cases.

## Automated domain and statistical evidence

- Round-trip every model and reject duplicate/reused IDs, unknown members,
  unsupported schemas, cross-scale comparison, null/suppression conflation,
  missing population/geography/method, and broader claim reuse.
- Prove OOH/O*NET preparation remains typical/distributional, OEWS remains an
  estimate, ORS remains population job requirements rather than personal
  ability/accommodation, and projections remain time-bounded rather than exact
  prediction.
- Prove shared SOC relationships cannot merge records, overwrite sources,
  become equivalence, create a required sequence, or imply personal fit.
- Prove restricted Abilities/Work Styles/Interests/emerging/software/technology
  categories cannot enter generic consumer projections.
- Coverage/evaluation reports include exact denominators/exclusions and retain
  one-claim failure even when aggregate coverage is high.

## Privacy, security, failure, and purge evidence

- Seed unique canaries for user ID, ambition, Goal, Capability, Proof, schedule,
  private location, recommendation, correction, selection, and rejection.
  Assert zero occurrence in source acquisition, endpoints, headers, object keys,
  requests, R2, artifacts, caches, filenames, logs, diagnostics, analytics,
  crash material, exports, feedback, and foundry reports.
- Static ownership proves no canonical command/mutation client, private
  repository, recommendation mutation, production external-operation client, or
  model client enters Career Corpus.
- Fault-inject size/decompression, hash/signature, schema, source, rights,
  semantic, coverage, evaluation, disk-full, cancellation, duplicate delivery,
  process kill, cache/index corruption, and pointer failure at each transition;
  current/last-known-good remains consistent and no mixed snapshot is visible.
- Interrupt rights purge at every phase; prove immediate projection disablement,
  eventual removal from archive/shard/index/search/render/export/cache, resumed
  deletion after relaunch, and only permitted non-recoverable lineage remains.

## Migration and replay evidence

- Clean install loads the bundled v1/30.3 base and accounts for every identity.
- Upgrade with the old software-developer validation pack installs new schema
  independently, preserves old inspection until promotion, marks it superseded,
  copies/reinterprets no claim, and can roll back after interruption.
- Unknown future schemas fail closed. Snapshot/index/promotion/rollback/purge
  journals replay idempotently and rebuild equivalent public projections.
- Private canonical schemas and data remain byte/record unchanged through
  install, refresh, reset, rollback, and purge.

## Runtime, accessibility, and device evidence

- On simulator and supported physical iPhone, prove local search and inspection
  for ordinary, regulated, competitive, title-only, aggregate, sparse,
  suppressed, preliminary, stale, conflict, rights-blocked, offline, updated,
  invalid, and unavailable states.
- Verify separate O*NET/OOH/EP/OEWS/ORS panels, exact statistical disclosure,
  source links, attribution, limitations, update review, retry, reset, rollback,
  and purge/relaunch without recommendation or private mutation.
- Accessibility proof covers semantic headings/labels/values/traits, list
  alternatives to tables, spoken abbreviations, focus/status recovery, largest
  Dynamic Type, contrast, reduced motion, RTL, VoiceOver, Voice Control, Switch
  Control, and hardware keyboard. Record simulator versus physical-device proof
  separately.
- Network-denial proof shows bundled/installed records retain actual age and
  independent partial availability while the private core remains usable.

## Performance and resource evidence

Record raw/downloaded/archive/shard/app-install sizes, update delta, record/
index counts, peak decompression/validation memory, launch index open, first
search result, cold/warm query, paging, promotion, rollback, index rebuild,
purge, energy, and main-thread responsiveness on the supported launch-floor
physical device. Establish and approve regression thresholds from measurements
before merge. If full required base coverage does not fit, return to Scope; do
not silently drop it or fetch a user-derived regional shard.

## Final claim ceiling

Completion requires linked evidence for every `REQ-001` through `REQ-020` and
green applicable source, rights, foundry, native, automated, build,
privacy/security, recovery, migration, performance, accessibility, simulator,
and physical-device lanes. ESCO, cross-taxonomy equivalence, current
opportunity/licensure, personal recommendation, model, direct-user usefulness,
merge, deployment, and release evidence remain separately labeled N/A or
insufficient until their owners produce it.
