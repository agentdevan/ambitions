# Private Life Runtime Kernel Contracts

Batch: IOS26-T03-B01
Scope: Runtime contract layer only
Status: Green after repair cycle and refreshed broad-suite validation

## Implemented surface

- Added `PrivateLifeRuntimeKernelContracting` plus trace context, decision input, decision record, and decision output value models.
- The kernel is local-only by construction through `PrivateLifeRuntimeBoundary.localOnly`.
- Decision records reuse existing `RecommendationTrace` fields for source, reason, fit, uncertainty, control, and receipt behavior.
- Decision records cannot drive recommendation behavior when the attached goal-intelligence context is quarantined for review.
- `AmbitionsRuntimeFactory` now installs `PrivateLifeRuntimeKernel` alongside the existing services.
- `AmbitionsRuntime` exposes the kernel as part of the composed runtime.

## Validation

- `xcodegen generate` - passed in Phase 04 repair pass.
- `scripts/build-local.sh` - passed in Phase 04 repair pass; latest log: `output/logs/build-local-20260522-113452.log`
- `make xcode-focused-test BATCH=IOS26-T03-B01 TEST=AmbitionsTests/Runtime/AmbitionsRuntimeKernelContractsTests` - passed in Phase 04 repair pass; summary: `.codex/xcode-summaries/IOS26-T03-B01/20260522T153729Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T03-B01 TEST=AmbitionsTests/Runtime/AmbitionsRuntimeBoundaryTests` - passed in Phase 04 repair pass; summary: `.codex/xcode-summaries/IOS26-T03-B01/20260522T153936Z/focused-test-summary.json`
- `make xcode-focused-test BATCH=IOS26-T03-B01 TEST=AmbitionsTests` - failed in Phase 04 repair pass due outside-slice failures; summary: `.codex/xcode-summaries/IOS26-T03-B01/20260522T154136Z/focused-test-summary.json`
- `git diff --check` - passed in Phase 04 repair pass.
- `make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/AmbitionsOSVerticalSliceProofModelsTests` - passed in repair review.
- `make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/AppShellNavigationTests` - passed in repair review.
- `make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests` - passed in repair review.
- `make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests` - passed in repair review.
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T03-B01-REPAIR --lane build-for-testing` - passed after refreshing stale test-without-building artifacts; summary: `.codex/xcode-summaries/IOS26-T03-B01-REPAIR/20260522T163155Z/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=IOS26-T03-B01-REPAIR TEST=AmbitionsTests` - passed after build-for-testing refresh; 1626 tests, 0 failures; summary: `.codex/xcode-summaries/IOS26-T03-B01-REPAIR/20260522T163440Z/focused-test-summary.json`

## Notes

- The initial broad `AmbitionsTests` lane reported assertion failures in `AmbitionsOSVerticalSliceProofModelsTests`, `AppShellNavigationTests`, `CoreSurfaceIntegrationScenarioTests`, and `SourceAtlasCoverageRuntimeFixtureModelsTests`; the repair cycle aligned those tests with current source truth.
- The first broad repair rerun used stale test-without-building artifacts. After the wrapper refreshed build-for-testing, broad `AmbitionsTests` passed.
- The runtime-kernel focused tests, factory boundary test, repaired focused families, and refreshed broad suite passed.
- No UI, backend, cloud, or LLM dependency was introduced by this batch.
- The broad test run rewrote generated proof-fixture byproducts under `docs/proof/amb-fe-be/moat-scenario-proof-98/`; those outside-scope byproducts were restored before closeout.
