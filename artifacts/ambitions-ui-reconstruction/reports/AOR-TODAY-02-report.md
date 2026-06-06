# AOR-TODAY-02 Report - Start Here Recommendation Contract

Status: Green with explicit screenshot-state blockers
Issue: AMB-533
Date: 2026-06-06
Base commit: `a30e8405a76c0f48a9500f3a8ea9d6c5887f3d97`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Scope

AMB-533 updated the Today Reality Meridian Start Here presentation so the recommended step reads as the action expression of the active Now node, not as a detached card.

## Changed Source

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
  - Added Reduce Motion-aware static origin markers.
  - Added a current Now connector overlay inside the recommendation block.
  - Split source/freshness/receipt labels into stable compact rows so labels remain inspectable.
  - Added compact receipt labeling in the Start Here metadata row.
  - Normalized visible primary and secondary Start Here action labels to the AMB-533 approved language set.
  - Expanded the Reality Meridian accessibility summary so Start Here is semantically attached to the current Now node and includes source, freshness, receipt, and primary action.

## Supporting Changes

- `docs/codex/concept-lock-registry.yml`
  - Added `AMB-533` to the allowed `today_start_here` locked-concept prefixes.
- `prompts/batches/AMB-533.md`
  - Runner header and self-heal boundary are installed.

## Screenshot Evidence

- `artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
  - Current default Today screenshot.
  - Captured from booted `iPhone 17e`, 1170 x 2532.
  - Launch: `xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`
- `artifacts/ambitions-ui-reconstruction/screenshots/today-recommendation-after-final.png`
  - Supplemental active recommendation screenshot using DEBUG demo bootstrap mode.
  - Captured from booted `iPhone 17e`, 1170 x 2532.
  - Launch: `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=demo xcrun simctl launch --terminate-running-process booted com.ambitions.ios --args -AmbitionsInitialSurface today -AmbitionsScreenshotMode YES`

## Explicit Screenshot-State Blockers

- `artifacts/ambitions-ui-reconstruction/screenshots/today-trust-open-after-final.png` was not produced.
  - Blocker: current source inspection found no deterministic `trust-open` screenshot launch route. Raw `simctl` in this environment provides screenshots and UI settings but no tap automation. XcodeBuildMCP UI snapshot was configured to a different shutdown simulator, not the booted `iPhone 17e`.
- `artifacts/ambitions-ui-reconstruction/screenshots/today-receipt-available-after-final.png` was not produced.
  - Blocker: current source inspection found no deterministic `receipt-available` screenshot launch route, and AMB-533 did not add new fixture or launch-argument infrastructure.

## Validation

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-533`
  - Green.
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-533 --prompt prompts/batches/AMB-533.md --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-533-pre.md`
- `git diff --check`
  - Passed.
- `make xcode-build-for-testing BATCH=AMB-533`
  - Passed.
- `make xcode-focused-test BATCH=AMB-533 TEST=AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
  - Passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-533 --prompt prompts/batches/AMB-533.md --changed-from a30e8405a76c0f48a9500f3a8ea9d6c5887f3d97 --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-533-post.md`
- `xcrun simctl install booted .codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`
  - Passed.
- `xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png`
  - Passed.
- `xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/today-recommendation-after-final.png`
  - Passed.
- `sips -g pixelWidth -g pixelHeight artifacts/ambitions-ui-reconstruction/screenshots/today-default-after-final.png artifacts/ambitions-ui-reconstruction/screenshots/today-recommendation-after-final.png`
  - Both screenshots are 1170 x 2532.

## Proof Boundaries

- Current evidence proves a local build, focused Today test lane, guard status, and simulator screenshots for the scoped AMB-533 change.
- This does not prove human visual approval, full VoiceOver traversal, Dynamic Type acceptance, Reduce Motion device QA, performance, physical-device behavior, release readiness, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof.

## Rollback

Revert the AMB-533 commit, or remove the source/report/screenshot changes listed above and regenerate Today screenshots from the prior commit.
