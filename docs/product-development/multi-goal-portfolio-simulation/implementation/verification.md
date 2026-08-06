# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/multi-goal-portfolio-simulation --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/portfolio-simulation/tests
python3 tools/portfolio-simulation/cli.py validate-fixtures
python3 tools/portfolio-simulation/cli.py verify-activation-gate --gate tools/portfolio-simulation/config/production-activation-v1.json
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-PORTFOLIO-SIM --test AmbitionsTests/PortfolioSnapshotTests --test AmbitionsTests/SharedResourceLedgerTests --test AmbitionsTests/PortfolioScenarioEngineTests --test AmbitionsTests/PortfolioSensitivityTests --test AmbitionsTests/PortfolioScenarioRepositoryTests --test AmbitionsTests/PortfolioOwnerHandoffTests --test AmbitionsTests/PortfolioActivationGateTests --test AmbitionsTests/PortfolioPrivacyBiasTests --test AmbitionsTests/PortfolioSimulationAccessibilityTests
make test-local BATCH=PDL-PORTFOLIO-SIM-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-PORTFOLIO-SIM
git diff --check
```

## Required evidence

- Exact selection/snapshot consistency and stale-owner invalidation.
- Unit/range/unknown/shared-allocation/no-double-count property/golden tests.
- Stable non-ranked scenarios, one-variable sensitivity and no prediction/score.
- Goal completion/history/context/capability/source truths remain owner-owned.
- No owner/branch command path; inseparable classification is deterministic.
- Bounded goal/horizon/scenario/resource scale, cancellation and fault recovery.
- Private/sensitive canaries, bias/dignity and payload-free diagnostics pass.
- Security evidence covers malformed/resource-bomb scenarios, stale snapshot
  substitution, signed-gate tampering and prohibited command reachability.
- Migration/archive/delete/purge is resumable and deletion terminal.
- Accessibility/device performance and direct-user scenario comprehension pass.
- Signed gate cites green upstream scheduling/comparison/Life Branch/Context/
  Capability runtime and user evidence; missing/revoked evidence returns
  `conformanceOnly` even when all code tests pass.

## Final claim ceiling

Before the activation gate passes, completion proves only conformance behavior.
Afterward, evidence remains limited to tested goals/resources/horizon/scenario/
device versions. No best-life prediction, owner mutation, deployment or release
is proved.
