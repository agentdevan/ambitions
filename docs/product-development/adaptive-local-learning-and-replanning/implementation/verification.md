# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/adaptive-local-learning-and-replanning --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/local-learning/tests
python3 tools/local-learning/cli.py validate-fixtures
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/source-atlas-no-private-graph-egress-audit.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-LOCAL-LEARNING --test AmbitionsTests/LearningObservationAdapterTests --test AmbitionsTests/LearningObservationLedgerTests --test AmbitionsTests/PatternHypothesisPolicyTests --test AmbitionsTests/PlanningInfluenceActivationTests --test AmbitionsTests/PlanningInfluenceConsumerTests --test AmbitionsTests/LearningCorrectionScopeTests --test AmbitionsTests/LearningDependencyReplanTests --test AmbitionsTests/LocalLearningMigrationPurgeTests --test AmbitionsTests/LocalLearningPrivacySecurityTests --test AmbitionsTests/LocalLearningAccessibilityTests
make test-local BATCH=PDL-LOCAL-LEARNING-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-LOCAL-LEARNING
git diff --check
```

## Required evidence

- Only allowlisted minimal owner events ingest; duplicates/forgeries/excluded
  content fail and raw private values never copy.
- Stable reordered evidence/policy produces identical hypotheses, evidence/
  counterevidence and explanations.
- Every implicit candidate affects zero consumers before confirmed command.
- Prohibited trait/score/shame/injection corpus fails data/copy validation.
- Influence/correction scope, expiry/contradiction, disabled/sparse/neutral and
  reset semantics preserve Capability/Context/canonical bytes.
- Replan fan-out is exact and bounded; owner candidates/deltas cause no mutation.
- Race/policy/clock/replay/migration/archive/delete/fault-purge tests prove stale
  discard, idempotency and deletion terminality.
- Logs/metrics/receipts contain no payload/profile canaries.
- Accessibility/device proof covers evidence, uncertainty, scope, controls and
  deltas; performance/resource thresholds are measured.
- Longitudinal/slice/user evidence measures false patterns, burden, correction,
  oscillation, privacy/bias/dignity and usefulness before any future expansion.

## Final claim ceiling

Passing proves explicit/candidate local learning and non-mutating replanning for
tested policies/consumers. It does not prove auto-active personalization,
real-life outcome improvement, canonical changes, deployment or release.
