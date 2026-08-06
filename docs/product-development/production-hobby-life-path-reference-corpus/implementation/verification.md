# Verification

## Exact commands

Run from repository root and record exit status, hashes, and launched/executed/
passed/failed/skipped counts where available.

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/production-hobby-life-path-reference-corpus --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/source-atlas/foundry/tests/test_possibility_catalog_wikidata.py tools/source-atlas/foundry/tests/test_possibility_catalog_editorial.py tools/source-atlas/foundry/tests/test_possibility_catalog_materials.py tools/source-atlas/foundry/tests/test_possibility_catalog_overlays.py tools/source-atlas/foundry/tests/test_possibility_catalog_rights_cultural.py tools/source-atlas/foundry/tests/test_possibility_catalog_release.py tools/source-atlas/foundry/tests/test_possibility_catalog_coverage.py
python3 tools/source-atlas/source-atlas-foundry.py possibility-catalog validate-fixtures
python3 tools/source-atlas/source-atlas-foundry.py possibility-catalog build --source-lock tools/source-atlas/config/possibility-catalog-sources-v1.json --entity-allowlist tools/source-atlas/config/possibility-catalog-entity-allowlist-v1.json --editorial tools/source-atlas/config/possibility-catalog-editorial-v1.json --output /tmp/ambitions-possibility-catalog-build
python3 tools/source-atlas/source-atlas-foundry.py possibility-catalog verify --release /tmp/ambitions-possibility-catalog-build/possibility-catalog-release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-POSSIBILITY-CATALOG --test AmbitionsTests/PossibilityCatalogModelsTests --test AmbitionsTests/PossibilityCatalogArtifactDecoderTests --test AmbitionsTests/PossibilityCatalogSemanticValidatorTests --test AmbitionsTests/PossibilityCatalogSnapshotStoreTests --test AmbitionsTests/PossibilityCatalogSnapshotMigrationTests --test AmbitionsTests/PossibilityCatalogCoordinatorTests --test AmbitionsTests/PossibilityCatalogQueryTests --test AmbitionsTests/PossibilityCatalogInvalidationPurgeTests --test AmbitionsTests/PossibilityCatalogPrivacyBoundaryTests --test AmbitionsTests/PossibilityCatalogInspectionTests --test AmbitionsTests/PossibilityCatalogAccessibilityTests
make test-local BATCH=PDL-POSSIBILITY-CATALOG-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-POSSIBILITY-CATALOG
git diff --check
```

Acquire exact public records once through the approved source lock, then repeat
the build from locked bytes with network denied and require identical output
hashes. Never place private values, API secrets, production signing material,
or restricted media in committed fixtures. Run strict SwiftLint with the exact
pinned workflow arguments; rerun XcodeGen and require generated-project parity;
run the unchanged Code Quality workflow on the implementation branch.

## Source, editorial, rights, and foundry evidence

- Record every QID/revision/entity hash, structured field/relation/reference,
  redirect/merge/deprecation, acquisition locator/time, CC0 extraction policy,
  and excluded prose/media field.
- Bind every included identity to a signed editorial decision, evidence, facets,
  risk, purpose, non-claims, language/cultural state, review date/expiry and
  lineage. No arbitrary graph result or count target may enter.
- Record exact Smithsonian record/media CC0 states and Library item/set rights
  advisories; prove no portal/metadata rights inheritance.
- Record exact NPS pages/revisions and AmeriCorps release/method/population/
  geography/period/unit/limits.
- Rebuild twice from locked bytes/clock/policies and require identical shard/
  manifest hashes, ordering, coverage and decisions.
- Independently adjudicate multi-facet, redirect/merge/delete/vandalism,
  unreviewed relation, low-risk, tool/safety/provider/protected-context,
  harmful label, rights/cultural, overlay, correction and withdrawal fixtures.

## Domain, authority, dignity, and safety evidence

- Prove no transitive/source graph closure, name-similarity merge, embedding
  expansion, inferred synonym, universal hierarchy or equivalence.
- Prove editorial eligibility cannot strengthen source facts or inherit across
  a redirect/merge/source change without an exact reviewed decision.
- Prove only complete reviewed-low creative/knowledge records become
  recommendation-discovery eligible; service/physical records remain reference
  only even with general overlays.
- Prove records/projections do not assert user interest, identity, personality,
  proficiency, health/access suitability, likely enjoyment/success, best use
  of time, duty, productivity, publication, competition, credentialization or
  monetization.
- Prove NPS does not complete activity/site/emergency safety and AmeriCorps does
  not create opportunity, eligibility, placement, community rank or normative
  participation.
- Coverage reports expose cultural/geographic/language/accessibility gaps and
  hard failures independently of record count.

## Privacy, security, recovery, and purge evidence

- Seed unique canaries for user/device ID, Goal, Life Area, Capability, Proof,
  interest, schedule, location, health, disability/access, relationship,
  religion/politics, selection, correction, rejection and recommendation.
  Require zero occurrence in endpoint/parameter/header/key/request/R2/artifact/
  cache/filename/log/diagnostic/analytics/crash/export/feedback/foundry output.
- Static ownership proves no private repository, model/admin leakage,
  recommendation, popularity/profile, canonical mutation, or external-write
  client enters the catalog.
- Fault-inject size/decompression/hash/signature/schema/source/editorial/rights/
  cultural/risk/count/coverage/evaluation/disk/cancel/duplicate/process-kill/
  index/pointer failures at every transition; preserve current/LKG and prevent
  mixed snapshots.
- Interrupt rights/cultural purge at every phase; prove immediate projection
  disablement and eventual removal from raw/media/archive/shard/index/search/
  extracted text/rendering/thumbnail/contact sheet/model cache/export/temp,
  with only permitted opaque lineage and resumed relaunch work.

## Migration, runtime, accessibility, and device evidence

- Clean install loads bootstrap offline. Upgrade keeps legacy creative/NPS/
  AmeriCorps packs independent and creates only exact reviewed overlay links;
  interruption/rollback never mutates their source claims or private data.
- Unknown schemas/enums fail closed; lifecycle journals replay idempotently and
  rebuild identical projections.
- Simulator and supported physical iPhone cover browse/search, multi/ambiguous
  facets, eligible/reference-only, starter material rights, overlays, source
  change, offline, invalid, update/retry/clear/rollback/purge and source links.
- Accessibility covers semantic source/editorial separation, labels/values/
  traits, card alternatives, multilingual announcements, largest Dynamic Type,
  contrast, non-color states, stable focus/status, Reduced Motion, RTL,
  VoiceOver, Voice Control, Switch Control and hardware keyboard.
- Measure bootstrap/full/optional-media download/install/staging sizes, update
  delta, record/index counts, validation memory, index open, first search,
  cold/warm browse/search, paging, promotion, rollback, rebuild, clear, purge,
  energy, background budget and main-thread responsiveness on launch-floor
  physical device. Approve thresholds from evidence before merge.

## Final claim ceiling

Completion requires linked evidence for every `REQ-001` through `REQ-018` and
green applicable source/editorial/rights/cultural, foundry, privacy/security,
dignity/safety, recovery/migration, accessibility, performance, build,
simulator, and device lanes. Social/physical recommendation eligibility,
current providers/opportunities/safety completeness, model use, personal
recommendation usefulness, external action, merge, deployment, and release
remain explicit N/A or insufficient until their owners produce evidence.
