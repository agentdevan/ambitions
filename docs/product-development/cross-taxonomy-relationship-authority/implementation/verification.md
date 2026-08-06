# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/cross-taxonomy-relationship-authority --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/source-atlas/foundry/tests/test_relationship_registry_cip_versions.py tools/source-atlas/foundry/tests/test_relationship_registry_cip_soc.py tools/source-atlas/foundry/tests/test_relationship_registry_onet_soc_esco.py tools/source-atlas/foundry/tests/test_relationship_registry_alignments_candidates.py tools/source-atlas/foundry/tests/test_relationship_registry_profiles_inference.py tools/source-atlas/foundry/tests/test_relationship_registry_rights.py tools/source-atlas/foundry/tests/test_relationship_registry_release_coverage.py
python3 tools/source-atlas/source-atlas-foundry.py relationship-registry validate-fixtures
python3 tools/source-atlas/source-atlas-foundry.py relationship-registry build --source-lock tools/source-atlas/config/relationship-registry-sources-v1.json --profiles tools/source-atlas/config/relationship-registry-use-profiles-v1.json --output /tmp/ambitions-relationship-registry-build
python3 tools/source-atlas/source-atlas-foundry.py relationship-registry verify --release /tmp/ambitions-relationship-registry-build/relationship-registry-release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-RELATIONSHIP-REGISTRY --test AmbitionsTests/RelationshipRegistryModelsTests --test AmbitionsTests/RelationshipRegistryArtifactDecoderTests --test AmbitionsTests/RelationshipRegistrySemanticValidatorTests --test AmbitionsTests/RelationshipRegistrySnapshotStoreTests --test AmbitionsTests/RelationshipRegistrySnapshotMigrationTests --test AmbitionsTests/RelationshipRegistryCoordinatorTests --test AmbitionsTests/RelationshipRegistryQueryNoInferenceTests --test AmbitionsTests/RelationshipDependencyInvalidationTests --test AmbitionsTests/RelationshipRegistryInvalidationPurgeTests --test AmbitionsTests/RelationshipRegistryPrivacyBoundaryTests --test AmbitionsTests/RelationshipInspectionTests --test AmbitionsTests/RelationshipInspectionAccessibilityTests
make test-local BATCH=PDL-RELATIONSHIP-REGISTRY-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-RELATIONSHIP-REGISTRY
git diff --check
```

Record exit statuses, hashes and test counts. Repeat production build from
locked source/mapping bytes with network denied and require identical outputs.
Never commit private data, secrets, production signing material or unlicensed
mapping content. Run strict workflow-equivalent SwiftLint, XcodeGen parity and
the unchanged Code Quality workflow.

## Required evidence

- Exact mapping/source bytes, endpoint releases, schemas, rights, method/QA,
  record counts, SSSOM/source metadata and deterministic repeat-build hashes.
- Golden adjudication for CIP actions, many-to-many CIP–SOC, O*NET granularity,
  gated ESCO QA, provider alignments and candidates.
- Exact/close/broad/narrow/related chains, cycles, inverses, mixed predicates,
  conflicts, candidate/rejected/no-match/unmapped and endpoint drift prove zero
  derived product edges or unrelated claim propagation.
- Purpose-isolation proves search, explanation, overlay join, migration,
  review-only and unavailable remain distinct.
- Private canaries for identity, Goal, Capability/Proof, education, schedule,
  location, recommendation/correction/selection/rejection occur nowhere in
  acquisition, requests, artifacts, keys, logs, diagnostics or dependencies.
- Dependency tokens contain only exact public opaque bindings; release changes
  invalidate exact evidence without editing canonical/private owners.
- Fault injection at every staging/promotion/rollback/index/dependency/purge
  transition preserves immutable reader consistency, LKG and replay.
- Rights purge removes raw/shard/index/source-row/render/cache/export and
  prohibited dependency bytes, resumes after crash and retains only allowed
  lineage.
- Clean install, legacy-candidate migration, offline, reset, correction and
  unknown-schema downgrade remain honest and private-state neutral.
- Accessibility covers list-equivalent chains, plain predicates/direction,
  conflict/method/limits, VoiceOver, largest Dynamic Type, non-color, focus,
  Reduced Motion, RTL, Voice Control, Switch Control and keyboard.
- Physical-device metrics cover download/install/staging/index/dependency sizes,
  validation/promotion, cold/warm exact query, chain/conflict inspection,
  dependency diff, rebuild, rollback, clear/purge, memory, energy, background
  budget and responsiveness; thresholds derive from evidence before merge.
- Direct-user comprehension must show that exact/close/broad/narrow/related and
  publisher alignment do not communicate qualification, credit, mastery or
  universal equivalence.

## Final claim ceiling

Completion requires evidence for every `REQ-001`–`REQ-018` and green applicable
semantic/source/rights, foundry, privacy/security, bias/dignity, recovery/
migration, accessibility, performance, build, simulator and physical-device
lanes. Personal capability transfer, current acceptance/credit/licensure,
generative usefulness, external action, merge, deployment and release remain
N/A or insufficient until their owners prove them.
