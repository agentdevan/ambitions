# AOR-YOU-02 Personal Runtime, Trust, Receipts Drill-Downs

## Status

Green for AMB-553 source implementation, focused local validation, and scoped You drill-down proof.

Formal accessibility conformance, physical-device behavior, performance, privacy/legal approval, TestFlight readiness, App Store readiness, CI, and release readiness are not claimed.

## Issue

Ambitions issue: AMB-553

## Scope

Extend the AMB-552 User System Profile reconstruction with reachable Personal Runtime and Privacy / Local Data Controls drill-downs that state whether each claim is runtime-backed, fixture-only, or blocked-pending-model.

Required AMB-553 drill-down coverage:

- Trust & Automation
- Personal Runtime
- Privacy / Local Data Controls
- Receipts & History

The patch stays inside the existing You owner path and does not create a parallel You/Profile/Personal Runtime implementation.

## Files Changed

- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `prompts/batches/AMB-553.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-02-report.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/you-personal-runtime-local-data-amb-553.png`

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Runner and Repair Notes

- Runner cycle 1 reached a Yellow locked-path precheck because the prompt's candidate paths included broader domain owners.
- The prompt was repaired to limit app source edits to `Native/Ambitions/Features/You/**`, direct focused You tests, reports, screenshots, and inspect-only treatment for broader app/shared/project files.
- Runner cycle 2 reached a Red patch-model blocker because `gpt-5.3-codex-spark` was unsupported for the active account.
- Runner cycle 3 used `PATCH_MODEL=gpt-5.5` and reached a nested Codex usage-limit blocker.
- Manual implementation proceeded under the same Green pre-guard and locked You-owner boundary after the user granted full authority to complete issues through AMB-602.
- A post-change guard Red from new copy using the stale "dashboard" term was repaired before final validation.

## Validation

Build/test proof:

- `make xcode-build-for-testing BATCH=AMB-553`
  - Result: passed
  - Summary: `.codex/xcode-summaries/AMB-553/20260608T003439Z-bft-39184-14015/build-for-testing-summary.json`
- `make xcode-focused-test BATCH=AMB-553 TEST=AmbitionsUITests/AmbitionsUITests/testYouTrustSurfaceShowsConservativeExternalStatusLabels`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-553/20260608T002807Z-AmbitionsUITests-AmbitionsUITests-testYouTrustSurfaceShowsConservativeExternalSt-37196-14110/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-553 TEST=AmbitionsUITests/AmbitionsUITests/testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-553/20260608T003202Z-AmbitionsUITests-AmbitionsUITests-testYouLifeContextLedgerInspectionShowsRuntime-38292-12584/focused-test-summary.json`
- `make xcode-focused-test BATCH=AMB-553 TEST=AmbitionsUITests/AmbitionsUITests/testYouPersonalRuntimeAndLocalDataControlsShowHonestStatusLabels`
  - Result: passed, 1 test executed
  - Summary: `.codex/xcode-summaries/AMB-553/20260608T003604Z-AmbitionsUITests-AmbitionsUITests-testYouPersonalRuntimeAndLocalDataControlsShow-39475-20994/focused-test-summary.json`

Guard/proof commands:

- `python3 scripts/ambitions-champion-coverage-check.py`
  - Result: GREEN
  - Report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-553 --prompt prompts/batches/AMB-553.md --batch-type source-changing`
  - Result: GREEN
  - Report: `build/reports/parallel-implementation-guard/AMB-553-pre.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-553 --prompt prompts/batches/AMB-553.md --changed-from e99944f30ef4242019c1a63b209d979d7bdac0d3 --batch-type source-changing`
  - Result: GREEN
  - Report: `build/reports/parallel-implementation-guard/AMB-553-post.md`
- `git diff --check`
  - Result: passed, no whitespace errors

Screenshot proof:

- `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=preview xcrun simctl launch --terminate-running-process 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios --args -AmbitionsInitialSurface you -AmbitionsScreenshotMode YES`
- `xcrun simctl io 81485ACD-AF10-4B92-8C03-9BB8805A4A23 screenshot artifacts/ambitions-ui-reconstruction/screenshots/you-personal-runtime-local-data-amb-553.png`
- Result: local simulator PNG captured and visually inspected as nonblank.

The screenshot captures the You root state. Opened-sheet evidence for Personal Runtime and Privacy / Local Data Controls is covered by the focused UI test above.

## Validation Not Run

- No formal accessibility audit.
- No physical-device run.
- No performance profiling.
- No archive/export/signing/TestFlight/App Store validation.
- No privacy/legal review.
- No CI validation.

## Proof Boundaries

- Verified: AMB-553 You drill-down reachability, honest runtime-backed/fixture-only/blocked-pending-model labels, local-data control copy, receipt boundary copy, local build-for-testing, three focused UI tests, champion coverage, and pre/post parallel implementation guard status.
- Not verified: formal accessibility conformance, physical-device behavior, performance, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, or CI.
- This report does not claim that Private Life Runtime behavior is complete. It verifies the scoped You inspection/control routes and current local UI labels covered by the listed tests.

## Risks / Yellow Items

- Formal accessibility and device proof remain owner/manual follow-up outside this AMB-553 local validation scope.
- The screenshot is root-level local simulator evidence; opened Personal Runtime and Privacy / Local Data Controls sheets are proven by UI automation rather than separate screenshot artifacts.
- Export/import, sync continuity, privacy/legal approval, and destructive local-data controls remain blocked-pending-model and are intentionally unclaimed.

## Rollback

- Revert `Native/Ambitions/Features/You/YouRootSurface.swift`.
- Revert `Native/Ambitions/Features/You/YouScreen.swift`.
- Revert `Native/AmbitionsUITests/AmbitionsUITests.swift`.
- Remove `prompts/batches/AMB-553.md`.
- Remove `artifacts/ambitions-ui-reconstruction/reports/AOR-YOU-02-report.md`.
- Remove `artifacts/ambitions-ui-reconstruction/screenshots/you-personal-runtime-local-data-amb-553.png`.

## Next Eligible Issue

- `AMB-554`
