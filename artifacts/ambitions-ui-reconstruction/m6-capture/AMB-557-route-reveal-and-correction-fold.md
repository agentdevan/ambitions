# AMB-557 Route Reveal And Correction Fold

## Verdict

Yellow.

The Capture activation seam now exposes a calm route reveal and correction fold for `Needs a Place`, `Ready to Place`, `Grow into Goal`, and `Held for Review`. The implementation keeps Capture as the global Atmosphere Composer seam, not a tab, feed, inbox, category grid, intake dashboard, or chat surface.

## Changed Files

- `prompts/batches/AMB-557.md`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ambitions-ui-reconstruction/m6-capture/AMB-557-route-reveal-and-correction-fold.md`

## Behavior

- High-confidence text reveals deterministic route choices in the activated seam.
- Low-confidence text remains save-first as `Needs a Place`.
- `Why this?` explanation copy exists in the correction fold.
- User correction exists through route correction buttons.
- A corrected route becomes local seam state and adds a local correction receipt row.
- Save copy records the selected or corrected route without silently moving user data.
- Source/trust language remains compact and points to `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`.

## Validation

Verified:

- `python3 scripts/ambitions-intelligence-consolidation-champion-check.py --changed-from 027ed5637e5b9bcc679abbd582bccb711a97a0b1 --batch AMB-557` - Green before source edits.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-557 --prompt prompts/batches/AMB-557.md --changed-from 027ed5637e5b9bcc679abbd582bccb711a97a0b1 --batch-type source-changing` - Green after prompt repair.
- `make xcode-focused-test BATCH=AMB-557 TEST=AmbitionsUITests/AmbitionsUITests/testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab` - compiled through build-for-testing; build summary passed at `.codex/xcode-summaries/AMB-557/20260608T043821Z-bft-33183-14814/build-for-testing-summary.json`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-557 --prompt prompts/batches/AMB-557.md --changed-from 027ed5637e5b9bcc679abbd582bccb711a97a0b1 --batch-type source-changing` - Green.
- `bash scripts/release-claim-safety-scan.sh` - Green.
- `git diff --check` - passed.

Failed or blocked:

- Focused UI selector output is not trustworthy Green. The raw focused log at `.codex/xcode-logs/AMB-557/20260608T044504Z-AmbitionsUITests-AmbitionsUITests-testLaunchURLCanOpenGlobalCaptureWithoutTopLev-34953-2598/focused-test.log` failed at initial shell startup with `Failed to get matching snapshots: Timed out while evaluating UI query`, before reaching the AMB-557 fold assertions. A direct alternate-simulator run at `.codex/xcode-logs/AMB-557/manual-direct/focused-test-iphone17.log` stalled before test-event output. Resetting the alternate simulator caused `simctl bootstatus` and `simctl list devices` to hang, so simulator proof is blocked by local Xcode/simulator state.
- Screenshot proof was not produced. `simctl` became unreliable during the reset cycle, so no current Capture screenshot artifact can be claimed for AMB-557.

Not verified:

- Current screenshot proof for the touched Capture states.
- Current visual review or accessibility review beyond source-level Dynamic Type/accessibility identifier coverage and the attempted focused UI selector.
- Device, TestFlight, App Store, performance, privacy/legal, or release readiness.

## Proof Boundaries

This report claims source implementation, guard cleanliness, build-for-testing compile proof, and claim-scan cleanliness only. It does not claim a passing focused UI test, screenshot approval, accessibility approval, release readiness, device proof, CI proof, or production readiness.

## Rollback Notes

- Revert the AMB-557 commit to remove the correction fold, route correction state, save-route copy, focused selector assertions, prompt, and this report.
- If only the UI fold needs rollback, remove `correctionFold`, `correctionButton(_:)`, `correctedRoute`, `correctionReceiptMessage`, `applyRouteCorrection(_:)`, and the related route summary/hint helpers from `Native/Ambitions/App/AppShellView.swift`.

## Required Completion Footer

Verdict: Yellow
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/m6-capture/AMB-557-route-reveal-and-correction-fold.md`
- none - screenshot proof blocked by local simulator/simctl instability; AMB-558 owns the screenshot-board follow-up.
Focused tests:
- `make xcode-focused-test BATCH=AMB-557 TEST=AmbitionsUITests/AmbitionsUITests/testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab` - not Green; build-for-testing passed, but raw focused UI log failed at initial shell startup before AMB-557 assertions.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath /Users/devan/Documents/GitHub/ambitions/.codex/DerivedData/Ambitions test-without-building -only-testing AmbitionsUITests/AmbitionsUITests/testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab CODE_SIGNING_ALLOWED=NO` - not Green; direct alternate-simulator run stalled before test-event output.
Changed files:
- `prompts/batches/AMB-557.md`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ambitions-ui-reconstruction/m6-capture/AMB-557-route-reveal-and-correction-fold.md`
Rollback notes:
- Revert the AMB-557 commit, or remove the correction fold and related route-correction state from `Native/Ambitions/App/AppShellView.swift`.
Remaining Yellow debt:
- AMB-558
