# AFI05 Shell And Continuity Chrome Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI05 Shell And Continuity Chrome

## Result

AFI05 aligned the user-facing shell/chrome layer to Today / Goals / Capture /
Time / You while keeping `.plan` as an internal compatibility raw value.

## Files Changed

- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Shared/ActivationContract.swift`
- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- focused app/domain/Plan/Profile/Today/Goals tests
- `docs/AmbitionsCanon/02_Continuity_Layer_Chrome.md`
- `docs/codex/batches/AFI05_Shell_And_Continuity_Chrome.md`
- `docs/audits/afi05-shell-and-continuity-chrome-report.md`
- `docs/handoff/AFI_Ambitions_Flagship_Interface_Completion_Report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/state/active-batch.yml`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/platform-kernel-current-state.md`

## Behavior Changed

The top-level shell label that was previously displayed as Plan now displays
as Time. Internal route/storage compatibility remains `.plan`.

## Tests Run

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AppShellNavigationTests -only-testing:AmbitionsTests/AppShellChromeTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/ActivationContractTests -only-testing:AmbitionsTests/PlanFeatureServiceTests/testTopLevelIARemainsCanonicalFiveTabShell -only-testing:AmbitionsTests/ProfileFeatureServiceTests/testTopLevelShellStillExcludesLegacyProfileInsightsAndHabitsTabs test CODE_SIGNING_ALLOWED=NO`
  - First run failed one stale expected title in `ScreenContractRegistryTests`.
  - Repair: updated the screen-contract expected user-facing title from Plan to Time while preserving `.plan` ID compatibility.
  - Rerun passed: 56 selected tests, 0 failures.
  - Raw log: `.codex/logs/2026-05-08T11-afi05-focused-tests-rerun.raw.log`
- `python3 scripts/ai/acx_local.py bundle quick`
- `python3 scripts/ai/acx_impact.py <AFI05 changed files>`
- `python3 scripts/ai/acx_local.py bundle docs`
- `python3 scripts/ai/acx_local.py bundle batch-closeout`
- `python3 scripts/ai/acx_local.py bundle build-triage`
- `scripts/build-local.sh`
  - Result: Build Succeeded.
  - Raw log: `output/logs/build-local-20260508-114210.log`
- `scripts/global-train-next-batch.sh`
- `scripts/batch-train-gate-check.sh || true`
- `git diff --check`

## Tests Not Run

- Full unit test suite.
- UI test suite.
- Physical-device validation.
- Screenshot or manual accessibility traversal.

## Known Risks

- Internal `.plan` symbols remain intentionally as compatibility seams.
- Visual screenshots were not captured in this batch.
- Broader Plan-to-Time copy migration remains future AFI/compatibility work
  outside this narrow shell/chrome batch.
- ACX docs/batch-closeout bundles reported advisory Yellow scan findings from
  broader historical/source material; no hard Red was found in the AFI05 scope.

## Claims

The user-facing top-level shell/chrome label now follows active AFI IA.

## Non-Claims

No persistence migration, raw-value rename, route rename, full Plan-to-Time code
migration, rendered visual proof, accessibility conformance, performance proof,
release readiness, App Store readiness, TestFlight readiness, physical-device
proof, privacy/legal approval, sync readiness, backend completion, or production
readiness is claimed.

## Next Eligible Batch

AFI06 Today Reality Meridian.
