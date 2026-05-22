<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# IOS26-T03-B01 Broad Suite Yellow Repair

Status: Runner-required repair prompt
Owner: Codex operator
Scope: Repair the current broad `AmbitionsTests` Yellow that blocks committing the already-run `IOS26-T03-B01` runtime-kernel slice.

## Required Read Order

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. `README.md`
10. `docs/README.md`
11. `project.yml`
12. `Package.swift`

## Starting State

The worktree intentionally contains the uncommitted `IOS26-T03-B01` runtime-kernel slice:

- `Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift`
- `Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift`
- `Native/Ambitions/Runtime/PrivateLifeRuntimeKernelContracts.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests.swift`
- `Native/AmbitionsTests/Runtime/AmbitionsRuntimeKernelContractsTests.swift`
- `build/reports/private-life-runtime/kernel-contracts.md`

Do not revert or rewrite those files except to preserve compile/test compatibility if directly required.

## Repair Target

Latest broad-suite summary:

- `.codex/xcode-summaries/IOS26-T03-B01/20260522T154136Z/focused-test-summary.json`
- log `.codex/xcode-logs/IOS26-T03-B01/20260522T154136Z/focused-test.log`

Failing test families:

- `AmbitionsOSVerticalSliceProofModelsTests`
- `AppShellNavigationTests`
- `CoreSurfaceIntegrationScenarioTests`
- `SourceAtlasCoverageRuntimeFixtureModelsTests`

Repair only the smallest live-source or test drift needed to make these families pass without weakening truth, release, privacy, or local-first boundaries.

Known likely drift points:

- `AppMeridianShellChromeState.launchDefault.rollbackLabel` must satisfy both rollback-to-native and meridian-opt-in contract tests without reintroducing a noncanonical tab.
- The You system-center local memory status has conflicting expectations between local proof integration and current You service tests; repair by aligning the assertion or source with active truth without weakening local-only wording.
- `SourceAtlasCoverageRuntimeFixtureModelsTests.repoRoot()` appears to resolve to `Native/` instead of the repo root; fix the fixture-root lookup rather than moving fixture files.
- `AmbitionsOSVerticalSliceProofModelsTests` expects action receipt order while `AmbitionsOSProofTrustReceipt` normalizes receipt IDs deterministically; repair the assertion or model only if active source truth supports it.

## Allowed Files

Prefer these files only:

- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift`
- `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests.swift`
- `Native/AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests.swift`
- `build/reports/private-life-runtime/kernel-contracts.md`

If a different file is required, stop and explain why before broadening.

## Validation

Run:

```bash
git diff --check
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/AppShellNavigationTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests
make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests
```

If broad `AmbitionsTests` still fails outside the repaired families, classify the failures with owner/no-claim boundary and do not overclaim Green.

## Closeout

Return Green only if the focused repaired families and broad `AmbitionsTests` pass. Otherwise return Yellow or Red with exact failures and no release/test-suite overclaim.
