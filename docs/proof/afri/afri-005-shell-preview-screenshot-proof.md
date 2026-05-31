# AFRI-005 Shell Preview And Screenshot Baseline Proof

Status: Green
Issue: AMB-357 / AFRI-005 -- Shell preview and screenshot baseline
Created: 2026-05-31
Baseline commit inspected before change: 587abacf7

## Authority Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- Relevant shell, preview support, UI test, and focused unit test sources.

## Change Summary

- Added `ShellPreviewMatrix` under preview support to enumerate the canonical Today, Goals, Capture, Time, and You tabs across light, dark, OLED dark, Dynamic Type accessibility, and Reduce Motion variants.
- Recorded major shell state coverage for steady shell, global entry, continuity receipt, and external route states without changing production runtime behavior.
- Added focused unit tests that fail if the preview matrix loses a canonical tab, required visual variant, major shell state, or screenshot hook.
- Added `AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs` to capture kept XCTest screenshot attachments for every canonical tab.
- Kept preview data isolated from production models; this issue does not introduce app data migrations, SourceRecord ownership changes, receipt owner changes, or ReplayTrace owner changes.

## Validation Run

- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-357 --prompt /tmp/AMB-357-AFRI-005-guard-prompt.md`
  - Result: Green
  - Report: `build/reports/parallel-implementation-guard/AMB-357-pre.md`
- `xcodegen generate`
  - Result: succeeded
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ShellPreviewMatrixTests build-for-testing`
  - Result: `** TEST BUILD SUCCEEDED **`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ShellPreviewMatrixTests -only-testing:AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`
  - Result: `** TEST SUCCEEDED **`
  - Tests: 4 executed, 0 failures
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_11-05-13--0400.xcresult`
- `xcrun xcresulttool export attachments --path /Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_11-05-13--0400.xcresult --output-path /tmp/ambitions-afri-005-attachments`
  - Result: succeeded
  - Exported screenshot attachments: 5
  - Manifest: `/tmp/ambitions-afri-005-attachments/manifest.json`
- `xcrun xcresulttool get object --legacy --path /Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_11-05-13--0400.xcresult --format json`
  - Result: succeeded
  - Confirmed action status and build status succeeded with 4 tests on iPhone 17 simulator `8ACCD665-4807-4102-B526-5A1AE20686A8`

## Proof Boundaries

- Verified: the focused preview matrix compile path, preview matrix unit tests, and UI screenshot smoke hook for all five canonical tabs.
- Screenshot proof path: kept XCTest attachments in the focused UI test result bundle; local attachment export confirmed five captured tab screenshots.
- Not verified: full app test suite, full UI test suite, physical device behavior, signed archive, TestFlight/App Store readiness, public accessibility proof, performance, privacy/legal approval, and release readiness.
- Tooling Yellow isolated from product proof: `scripts/harness/ambitions-xcresult-summary.py` returned Yellow because the current `xcresulttool` CLI requires `--legacy`; direct `xcrun xcresulttool get object --legacy` inspection and attachment export succeeded.
- SourceRecord / Receipt / ReplayTrace boundary: this baseline adds preview and screenshot proof hooks only. It does not alter source-freshness ledgers, receipt semantics, replay trace ownership, planning logic, or persisted user data.

## Rollback Notes

- Revert the AMB-357 commit to remove the preview matrix, focused tests, UI screenshot hook, and this proof note.
- If only screenshot naming changes, update `ShellPreviewMatrix.screenshotHook` and the UI test attachment names, then rerun the focused unit and UI test commands above.
