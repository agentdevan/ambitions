# AFRI-033 Unified Screenshot Matrix And Visual QA Proof

Issue: AMB-385 / AFRI-033
Date: 2026-05-31
Commit under validation: `5bb84352a`

## Status

Green for local screenshot matrix wiring, helper-gated export, five-tab UI screenshot smoke, and focused preview compile.

Not final visual approval. Not release readiness.

## Authority Inspected

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `AGENTS.md`
- `Native/Ambitions/PreviewSupport/ShellPreviewMatrix.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `scripts/visual-qa/capture_matrix.sh`
- `scripts/visual-qa/validate_screenshot_callers.sh`

## Change Summary

- Repaired `scripts/visual-qa/capture_matrix.sh` so matrix capture prepares Ambitions before screenshot export instead of allowing a false Green Home-screen capture.
- Added app bundle, app-launch, and route metadata to matrix reports.
- Added launch/route diagnostics so app preparation failures become Red before screenshot export.
- Preserved all screenshot exports through the centralized hardened helper `scripts/sim/simctl_screenshot.sh`.

## Matrix Evidence

Full helper-gated matrix:

- Command: `bash scripts/visual-qa/capture_matrix.sh --output-dir output/visual-qa/afri-033-repaired-full`
- Result: Green
- Report: `output/visual-qa/afri-033-repaired-full/visual-qa-matrix-report.md`
- Captured PNG count: 18
- Bundle: `com.ambitions.ios`
- Helper: `scripts/sim/simctl_screenshot.sh`

Matrix state contract:

- `today-normal`
- `today-low-capacity`
- `today-protected-time`
- `today-recovery`
- `today-source-stale`
- `today-source-unavailable`
- `today-empty-manual`
- `today-receipt`
- `goals-normal`
- `goals-blocked`
- `capture-normal`
- `capture-empty`
- `time-normal`
- `time-protected-time`
- `you-normal`
- `you-dynamic-type`
- `you-reduce-motion`
- `you-increase-contrast`

Forced failure:

- Command: `bash scripts/visual-qa/capture_matrix.sh --smoke --force-failure --output-dir output/visual-qa/afri-033-repaired-forced`
- Result: returned exit status 1 as expected
- Report: `output/visual-qa/afri-033-repaired-forced/visual-qa-matrix-report.md`
- Diagnostic: `output/visual-qa/afri-033-repaired-forced/diagnostics/forced-failure.diagnostic.md`

## UI Screenshot Smoke

- Command: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`
- Result: `** TEST SUCCEEDED **`
- Tests: 1 executed, 0 failures
- Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_19-11-38--0400.xcresult`
- Exported attachments: 5
- Attachment manifest: `output/visual-qa/afri-033-ui-attachments/manifest.json`
- Suggested attachment names cover Today, Goals, Capture, Time, and You.

## Preview Compile

- Command: `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ShellPreviewMatrixTests build-for-testing`
- Result: `** TEST BUILD SUCCEEDED **`

## Additional Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-385 --batch-type guard-repair --prompt /tmp/AMB-385-AFRI-033-guard-prompt.md`
  - Initial result: Yellow from old terminology in prompt text only.
  - Repair: prompt wording revised without changing source.
  - Final result: Green.
- Caller validation: `bash scripts/visual-qa/validate_screenshot_callers.sh`
  - Result: Green.
  - Direct unwrapped simulator screenshot callers: none.
- Syntax: `bash -n scripts/visual-qa/capture_matrix.sh`
  - Result: Green.

## Visual QA Closeout

- Today evidence: screenshot smoke reached Today and captured the current Reality Meridian loading/current-state posture without changing user data.
- Goals evidence: helper-gated and UI-test screenshots show Constellation Atlas as the primary object with direction/proof affordances.
- Capture evidence: UI-test screenshot smoke reached Capture through the canonical shell destination.
- Time evidence: UI-test screenshot smoke reached Time through the canonical shell destination.
- You evidence: UI-test screenshot smoke reached You through the canonical shell destination.
- Dynamic Type / Reduce Motion / Increase Contrast evidence: matrix state paths are named and captured through the helper, but this pass does not certify public accessibility conformance.
- Object-first drift check: evidence remains tied to Today / Goals / Capture / Time / You and their primary objects; no new top-level destination or runtime dependency is introduced.

Known limitation: helper-routed matrix captures may include the app's deep-link context receipt overlay because the matrix uses OS routes to prepare the target tab. The clean five-tab shell screenshots are the kept XCTest attachments from the UI screenshot smoke. This is acceptable for local matrix/export proof and not acceptable as final marketing screenshot approval.

## Proof Boundaries

Verified:

- Current local helper-gated screenshot matrix report.
- Current 18-file matrix screenshot inventory.
- Current five-tab UI screenshot smoke with kept XCTest attachments.
- Focused preview compile path.
- Screenshot callers use the centralized helper.
- Forced helper failure remains Red and diagnostic-linked.

Not verified:

- Physical-device behavior.
- App Store screenshot readiness.
- TestFlight/App Store readiness.
- Public accessibility conformance.
- Manual VoiceOver traversal.
- Human visual approval.
- Performance readiness.
- Privacy/legal approval.
- Release readiness.

## Rollback

Revert the AMB-385 commit to remove the matrix script launch/route preparation repair and this proof packet. The AMB-394 helper remains the lower-level hardened screenshot export gate.
