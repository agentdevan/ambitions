# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/current-opportunity-availability-intelligence --json
python3 scripts/ambitions-canon.py check
python3 -m unittest discover -s tools/tests -p 'test_ambitions_canon_compiler.py'
python3 -m pytest tools/source-atlas/foundry/tests/test_current_authority_source_admission.py tools/source-atlas/foundry/tests/test_current_authority_temporal_states.py tools/source-atlas/foundry/tests/test_current_authority_rights.py tools/source-atlas/foundry/tests/test_current_authority_conflicts_profiles.py tools/source-atlas/foundry/tests/test_current_authority_release.py tools/source-atlas/foundry/tests/test_current_authority_coverage.py
python3 tools/source-atlas/source-atlas-foundry.py current-authority validate-fixtures
python3 tools/source-atlas/source-atlas-foundry.py current-authority build --source synthetic-conformance-v1 --output /tmp/ambitions-current-authority-build
python3 tools/source-atlas/source-atlas-foundry.py current-authority verify --release /tmp/ambitions-current-authority-build/current-authority-release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-CURRENT-AUTHORITY --test AmbitionsTests/CurrentAuthorityModelsTests --test AmbitionsTests/CurrentAuthoritySemanticParityTests --test AmbitionsTests/CurrentAuthoritySnapshotStoreTests --test AmbitionsTests/CurrentAuthorityMigrationTests --test AmbitionsTests/CurrentAuthorityQueryFilterTests --test AmbitionsTests/CurrentAuthorityExpirationDependencyTests --test AmbitionsTests/CurrentAuthorityConcurrencyTests --test AmbitionsTests/CurrentAuthorityPrivacyBoundaryTests --test AmbitionsTests/CurrentAuthoritySafeLinkTests --test AmbitionsTests/CurrentAuthorityPurgeTests --test AmbitionsTests/CurrentOpportunityInspectionTests --test AmbitionsTests/CurrentOpportunityAccessibilityTests
make test-local BATCH=PDL-CURRENT-AUTHORITY-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-CURRENT-AUTHORITY
git diff --check
```

Record exact commands, exit status, counts, hashes and device/OS. Repeat the
Foundry build from locked inputs with network denied and require identical
bytes. If any real source is enabled, archive its signed terms/admission review,
source locks and field-purpose matrix and run its adapter-specific golden/fault/
withdrawal suite. Never commit secrets, API keys, private data or unlicensed
content.

## Required evidence

- Golden parity for all claim/value/absence/time/conflict/purpose states.
- Admission fails for unknown rights/retention, field overreach, changed terms,
  unsupported time, unsafe URLs, private canaries and non-deterministic bytes.
- DST/timezone/clock rollback/future timestamp/expiry/supersession property tests.
- No-results, no-source, offline, stale, corrupt, rate-limit, withdrawal and LKG
  states preserve destination knowledge and truthful current claims.
- Network capture and committed artifact scans show no private query, location,
  Goal, identity, schedule, Capability/Proof, correction or behavior data.
- Local filters leave public bytes unchanged and persist no joined graph.
- Fault injection across stage/promote/read/filter/rollback/clear/purge proves
  immutable readers, stale-result rejection, idempotency and deletion terminality.
- Exact dependency invalidation changes no Goal/Step/Time/simulation bytes.
- Safe-link attacks fail closed and no transaction API exists.
- Security evidence covers artifact tampering, signature/source-lock failure,
  unsafe-link inputs, private-query canaries and prohibited boundary reachability.
- Accessibility evidence covers all time/state/source/unknown/conflict content
  and controls on simulator and physical device.
- Physical-device storage, validation, promotion, query/filter, clear/purge,
  memory, energy and background performance metrics meet thresholds established
  before implementation acceptance.
- Direct-user evidence passes claim-bound comprehension thresholds; evaluation
  reports source/geography/subject/time denominators and false-current hard gate.

## Final claim ceiling

Passing proves the bounded registry, conformance source and any separately
admitted real source for its exact approved fields/purposes. It does not prove
universal opportunity coverage, personal eligibility, availability guarantee,
transaction success, recommendation/path usefulness, deployment or release.
