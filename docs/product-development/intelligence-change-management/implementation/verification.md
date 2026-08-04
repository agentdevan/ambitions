# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/intelligence-change-management --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/intelligence-release/tests
python3 tools/intelligence-release/cli.py validate-fixtures
python3 tools/intelligence-release/cli.py run-trust-attack-matrix
python3 tools/intelligence-release/cli.py build --config tools/intelligence-release/config/bundled-release-v1.json --output /tmp/ambitions-intelligence-release
python3 tools/intelligence-release/cli.py verify --release /tmp/ambitions-intelligence-release/release.json
python3 scripts/source-atlas-boundary-audit.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-INTELLIGENCE-CHANGE --test AmbitionsTests/IntelligenceArtifactManifestTests --test AmbitionsTests/IntelligenceTrustMetadataTests --test AmbitionsTests/IntelligenceSemanticValidatorTests --test AmbitionsTests/IntelligenceCompatibilityEvaluationTests --test AmbitionsTests/IntelligenceChangeImpactTests --test AmbitionsTests/IntelligenceGenerationStoreTests --test AmbitionsTests/IntelligencePromotionRollbackTests --test AmbitionsTests/IntelligenceRevocationPurgeTests --test AmbitionsTests/IntelligenceChangePrivacySecurityTests --test AmbitionsTests/IntelligenceChangeAccessibilityTests
make test-local BATCH=PDL-INTELLIGENCE-CHANGE-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-INTELLIGENCE-CHANGE
git diff --check
```

Repeat release build network-denied and require identical bytes. Record exact
commands/status/counts/hashes, trust root/role versions, artifact/provenance
claims, compatibility tuple, evaluation IDs and device/OS/model environment.

## Required evidence

- Manifest/material/provenance/attestation immutability and honest guarantee level.
- Root rotation, bad threshold/algorithm/signature/hash/length, rollback, freeze,
  mix-match, wrong target and metadata depth/size/clock attacks fail closed.
- Signed but semantically invalid/rights-unknown/source-lock-broken artifact fails.
- Compatibility and Evaluation wrong/stale/similar/hard-fail tuples never pass.
- Every stage/promote/read/rollback/revoke/purge fault/relaunch has one immutable
  reader generation and truthful terminal state.
- OS model change disables/falls back without pretending rollback.
- Impact exactness and mutation spies preserve canonical/private owner bytes;
  public packages execute no private migrations/code.
- Rights/security purge removes all prohibited shared/raw/derived bytes and
  tombstones prevent replay resurrection.
- Fixed public requests/logs/metrics contain no private/cohort canary.
- Accessibility/device storage/network/verification/promotion/query/purge/
  background performance and user change comprehension pass.

## Final claim ceiling

Passing proves the release/change mechanism and exact tested artifacts/tuples;
it does not confer semantic quality beyond bound Evaluation receipts, guarantee
OS model rollback, activate every task, deploy or release the app.
