# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/generalized-life-branch-simulation --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/life-branch/tests
python3 tools/life-branch/cli.py validate-fixtures
python3 tools/life-branch/cli.py run-fault-matrix
python3 tools/life-branch/cli.py verify-activation-gate --gate tools/life-branch/config/production-activation-v1.json
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-LIFE-BRANCH --test AmbitionsTests/LifeBranchQualificationSnapshotTests --test AmbitionsTests/LifeBranchSimulationValidationTests --test AmbitionsTests/LifeBranchOwnerParticipantTests --test AmbitionsTests/LifeBranchAtomicCoordinatorTests --test AmbitionsTests/LifeBranchSagaRecoveryTests --test AmbitionsTests/LifeBranchReceiptReplayTests --test AmbitionsTests/LifeBranchExternalBoundaryTests --test AmbitionsTests/LifeBranchMigrationPurgeTests --test AmbitionsTests/LifeBranchPrivacySecurityTests --test AmbitionsTests/LifeBranchAccessibilityTests
make test-local BATCH=PDL-LIFE-BRANCH-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-LIFE-BRANCH
git diff --check
```

## Required evidence

- Strict qualifier, keep-current and complete changed/unchanged/invariant sets.
- Snapshot revision consistency and stale confirmation rejection.
- Every owner participant phase and idempotency/expiry/tampered-token behavior.
- Atomic protocol only for proven shared domains; saga prepares all and survives
  every phase fault/relaunch/compensation failure without false success/undo.
- Dependency cycle/unknown/irreversible/budget/injection failures block safely.
- Branch selection causes zero external effect; handoff contains no credential/
  executable payload and requires fresh confirmation.
- Receipts/journals accurately reflect completed/pending/failed/compensated.
- Private canaries, migration/archive/delete/purge and committed History pass.
- Accessibility/device performance and direct-user branch/reversibility/failure/
  external-boundary comprehension pass.
- Missing/revoked v1/portfolio/owner/user gate yields conformance-only despite
  otherwise green code/build tests.

## Final claim ceiling

Before activation, passing proves protocol conformance only. Afterward, it proves
tested owner sets/protocols. It never proves external atomicity/undo, all branch
types, deployment or release.
