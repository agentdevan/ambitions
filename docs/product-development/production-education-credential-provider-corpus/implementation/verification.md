# Verification

## Exact automated, foundry, static, and build commands

Run from repository root. Record exit status, exact source/resource hashes, and
launched/executed/passed/failed/skipped counts where available.

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/production-education-credential-provider-corpus --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/source-atlas/foundry/tests/test_education_corpus_cip_2020.py tools/source-atlas/foundry/tests/test_education_corpus_ipeds.py tools/source-atlas/foundry/tests/test_education_corpus_scorecard.py tools/source-atlas/foundry/tests/test_education_corpus_dapip.py tools/source-atlas/foundry/tests/test_education_corpus_identity.py tools/source-atlas/foundry/tests/test_education_corpus_rights.py tools/source-atlas/foundry/tests/test_education_corpus_release.py tools/source-atlas/foundry/tests/test_education_corpus_coverage.py
python3 tools/source-atlas/source-atlas-foundry.py education-corpus validate-fixtures
python3 tools/source-atlas/source-atlas-foundry.py education-corpus build --source-lock tools/source-atlas/config/education-corpus-sources-v1.json --semantic-policy tools/source-atlas/config/education-corpus-semantic-policy-v1.json --output /tmp/ambitions-education-corpus-build
python3 tools/source-atlas/source-atlas-foundry.py education-corpus verify --release /tmp/ambitions-education-corpus-build/education-corpus-release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-EDUCATION-CORPUS --test AmbitionsTests/EducationCorpusModelsTests --test AmbitionsTests/EducationCorpusArtifactDecoderTests --test AmbitionsTests/EducationCorpusSemanticValidatorTests --test AmbitionsTests/EducationCorpusIdentityResolverTests --test AmbitionsTests/EducationCorpusSnapshotStoreTests --test AmbitionsTests/EducationCorpusSnapshotMigrationTests --test AmbitionsTests/EducationCorpusCoordinatorTests --test AmbitionsTests/EducationCorpusQueryTests --test AmbitionsTests/EducationCorpusInvalidationPurgeTests --test AmbitionsTests/EducationCorpusPrivacyBoundaryTests --test AmbitionsTests/EducationCorpusInspectionTests --test AmbitionsTests/EducationCorpusAccessibilityTests
make test-local BATCH=PDL-EDUCATION-CORPUS-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-EDUCATION-CORPUS
git diff --check
```

The production-source build may require network to acquire the exact approved
source releases. Repeat the `build` from locked local source bytes with network
denied and require identical output hashes. Never put private values, API keys,
signing material, or production credentials in committed commands/fixtures.

Run strict SwiftLint against every changed Swift file using the pinned container
and exact strict arguments in `.github/workflows/code-quality.yml`. After the
generated project is committed, rerun `xcodegen generate` and require
`git diff --exit-code -- Ambitions.xcodeproj`. Run the unchanged Code Quality
workflow on the published implementation branch.

## Source, access, rights, and foundry evidence

- Record CIP 2020, exact IPEDS components/releases, exact Scorecard releases,
  and exact DAPIP downloads: locators, retrieved times, raw hashes, schemas/data
  dictionaries, archive members, source terms, and field policies.
- Replace every provisional source-lock placeholder with exact immutable
  release/file/member/hash data before producing a candidate archive. “Latest”
  or an unversioned API response fails.
- Reconcile expected/parsed/eligible/inspection-only/suppressed/missing/rejected/
  rights-blocked counts per source, component, cohort, claim, and shard.
- Prove CTDL bulk and CASE framework content remain blocked without exact
  consumer access, redistribution, retention/update, publisher, version, and
  content-rights evidence even when syntax and technical conformance pass.
- Verify required attribution and exclusions for government source material,
  publisher records, logos/images, marketing assets, and derived content.
- Rebuild twice from locked bytes, clean directories, injected clock, and exact
  adapter/schema/policy versions; require identical archive/manifest hashes and
  ordering.
- Independently adjudicate golden records for ordinary, alternative-provider-
  absent, historical-completion/no-offering, mixed-year, imputed, suppressed,
  branch ambiguity, merger/closure, changed recognition, identity conflict,
  correction, and rights withdrawal.

## Automated domain, identity, and statistical evidence

- Round-trip every model; reject duplicate/reused IDs, unknown fields, unsupported
  schemas, missing definitions, conflated null/suppression, and stronger-purpose
  reuse.
- Prove CIP classification/crosswalk never creates offering, curriculum,
  competency, recognition, or equivalence.
- Prove IPEDS completions are historical, different component years remain
  distinct, and reported/imputed/derived/suppressed/not-applicable/missing/
  revised states survive Python/Swift parity.
- Prove Scorecard measures retain institution/field/credential level, cohort,
  horizon, population, source year, unit, definition, and suppression and
  cannot produce prediction, ranking, ROI, or a personal value.
- Prove DAPIP recognition retains exact entity/program/site, agency/scope,
  status/action/dates/disclaimer and cannot become endorsement, transfer,
  licensure, acceptance, or inherit across scope.
- Prove shared names/addresses/domains cannot confirm identity; only permitted
  confirmed assertions allow claim-family-specific traversal. Ambiguous and
  conflicting links fail closed.
- Coverage/evaluation reports retain exact denominators/exclusions and one-
  claim hard failure even when aggregate coverage is high.

## Privacy, security, failure, and purge evidence

- Seed unique canaries for user/device ID, ambition, Goal, education history,
  user-held credential, Capability, Proof, finances, schedule, location,
  disability/accommodation, immigration, recommendation, correction,
  selection, and rejection. Assert zero occurrence in acquisition, endpoint,
  parameter, header, object key, request, R2, artifact, cache, filename, log,
  diagnostic, analytics, crash material, export, feedback, and foundry report.
- Static ownership proves no canonical command/mutation, private repository,
  recommendation/ranking, model, user analytics, or production external-write
  client enters Education Corpus.
- Fault-inject size/decompression, hash/signature, schema, wrong release,
  unknown field, source, rights, semantic, count, identity, coverage,
  evaluation, disk-full, cancellation, duplicate delivery, process kill,
  index corruption, and pointer failure at every transition. Current/LKG stays
  consistent and no mixed snapshot becomes visible.
- Interrupt clear and rights purge at every phase; prove immediate projection
  disablement, eventual deletion from archive/shard/index/search/extracted-
  text/rendering/thumbnail/contact-sheet/export/cache, resumed work after
  relaunch, and only legally permitted opaque lineage remains.

## Migration and replay evidence

- Clean install loads the bundled bootstrap and accounts for every included
  record, claim, source, and adversarial state offline.
- Upgrade with the narrow legacy `education_credentialing` pack installs the
  new schema independently, maps only exact public IDs, preserves legacy
  inspection until promotion, marks it superseded, guesses/reinterprets no
  claim, and can recover after interruption.
- Unknown future schemas/enums fail closed. Snapshot/index/promotion/rollback/
  invalidation/reset/purge journals replay idempotently and rebuild equivalent
  public projections.
- Private canonical schemas/data remain byte/record unchanged through install,
  refresh, clear, rollback, correction, and purge.

## Runtime, accessibility, and device evidence

- On simulator and supported physical iPhone, prove local search/inspection for
  institution, CIP, historical completions, descriptive measures, recognition,
  mixed-year, imputed, suppressed, branch ambiguity, merger/closure, identity
  conflict, rights-blocked, offline, updated, invalid, and unavailable states.
- Verify distinct source panels, exact definitions/limitations, source links,
  agency verification link labeling, update review, retry, clear, rollback,
  purge/relaunch, and no ranking/recommendation/private mutation.
- Accessibility proof covers semantic headings/labels/values/traits, card
  alternatives to tables, spoken codes/abbreviations, focus/status recovery,
  largest Dynamic Type, contrast, Reduced Motion, RTL, VoiceOver, Voice Control,
  Switch Control, and hardware keyboard. Separate simulator and device proof.
- Network-denial proof shows bundled/installed records retain actual age and
  partial source availability while the private core stays useful.

## Performance and resource evidence

Record raw/downloaded/archive/shard/app-install sizes, update delta, record/
index counts, staging peak, decompression/validation memory, index open, first
search result, cold/warm institution and field queries, paging, identity join,
promotion, rollback, rebuild, clear, purge, energy, background budget, and main-
thread responsiveness on the supported launch-floor physical device. Establish
and approve thresholds from measurements before merge. If the required
bootstrap or useful fixed public partitions do not fit, return to Scope; do not
silently drop source semantics or fetch user-derived shards.

## Final claim ceiling

Completion requires linked evidence for every `REQ-001` through `REQ-020` and
green applicable source, access/rights, foundry, identity, automated, build,
privacy/security, recovery, migration, performance, accessibility, simulator,
and physical-device lanes. Current offerings/acceptance, CTDL/CASE content
without separate approval, cross-taxonomy equivalence, personal recommendation,
model use, direct-user usefulness, merge, deployment, and release evidence stay
explicitly N/A or insufficient until their owners produce them.
