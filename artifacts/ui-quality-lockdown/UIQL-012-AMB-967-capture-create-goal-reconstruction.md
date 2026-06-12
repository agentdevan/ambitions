# AMB-967 / UIQL-012 Capture + Create Goal Reconstruction

Date: 2026-06-12
Program: UIQL
Actual Linear issue: AMB-967
UIQL sequence label: UIQL-012
Status: local scoped Green pending closeout commit and manual push

## Claim

Capture remains a global action only and now reveals local route review after text exists. Create Goal now opens as an object-native setup surface, shows a first path before save, keeps local save/receipt language visible, and avoids the prior generic stacked setup/card preview in the scoped first-path proof path.

## What Changed

- `Native/Ambitions/App/AppShellView.swift`
  - Added an activated Capture route reveal that appears only after typed text exists.
  - Exposed all four required route choices as visible correction buttons: Needs a Place, Ready to Place, Grow into Goal, Held for Review.
  - Replaced classifier/debug-adjacent copy with local receipt and local route language.
  - Increased the activated seam height so route labels and receipt copy fit above the dock/keyboard.
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
  - Reframed route review helper copy around after-typing review instead of pre-save policy language.
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
  - Replaced `Input policies` and `Thinks` with active local input/reason language.
- `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`
  - Replaced `Auto-detect` with `Let Ambitions shape it`.
  - Reordered the first-path preview before seed review.
  - Removed the first-path preview from a generic card shell and rendered it as an in-flow `Goal to path` object section.
  - Reframed the seed review as a local save checkpoint.
- `Native/Ambitions/Domain/GoalEngine/GoalEnginePlanner.swift`
  - Replaced the visible starter-plan section `Smallest Next Move` with `Smallest Next Step`.
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
  - Added AMB-967 source contract coverage for route reveal, required route labels, local receipt copy, and forbidden synthetic/AI/debug copy.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Updated activated Capture route assertions for the current route reveal.
  - Added the AMB-967 screenshot matrix for Capture activated, Capture keyboard, Capture route reveal, Create Goal default, Create Goal first-path preview, and Create Goal large Dynamic Type.

## Validation

- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'id=8ACCD665-4807-4102-B526-5A1AE20686A8' -only-testing:AmbitionsTests/CapturePlacementReviewStateTests/testAMB967CaptureAndCreateGoalStayObjectNativeWithoutSyntheticIssueDriftCopy`
  - Final passing log: `artifacts/ui-quality-lockdown/script-output/AMB-967-capture-create-goal-source-contract-final.log`
  - Exit code: 0
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'id=8ACCD665-4807-4102-B526-5A1AE20686A8' -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB967CaptureCreateGoalScreenshotMatrix -resultBundlePath artifacts/ui-quality-lockdown/script-output/AMB-967-capture-create-goal-screenshot-matrix-rerun9.xcresult`
  - Final passing log: `artifacts/ui-quality-lockdown/script-output/AMB-967-capture-create-goal-screenshot-matrix-rerun9.log`
  - Exit code: 0
- Final UIQL closeout scans are recorded in the run-state after the closeout commit.

## Screenshot Visual Evaluation

Final screenshot directory: `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/`

- Capture activated: `53B1D787-D4EA-4F34-BDE9-0269437749D3.png`
  - Capture is a global seam, not a tab.
  - No route reveal appears before text exists.
  - Text field, close button, save/route/mic controls, dock, and safe areas remain readable.
- Capture keyboard: `E339CA2B-CAB7-4FBE-9D27-DC350DC4D996.png`
  - Typed text is visible.
  - Route reveal appears after input.
  - All four route labels fit while the keyboard is present.
  - Local receipt copy remains visible above the dock/keyboard.
- Capture route reveal: `81ECB722-297A-4872-A57D-2F68D9FBEC7A.png`
  - Route choices remain visible and correction-capable.
  - No cloud classifier/AI wrapper copy is visible.
- Create Goal default: `C9DF3963-F0E3-4052-B76E-9F155FDBC1C5.png`
  - First viewport starts with `Set up this goal`, `Describe the goal plainly`, `Let Ambitions shape it`, and local save/receipt path copy.
  - It does not open as a stacked hero/intake/card flow.
- Create Goal first-path preview: `968D64E9-24BF-4CA1-84C2-8FEAAB2DF3E9.png`
  - `Goal to path` is visible before save.
  - `Smallest Next Step` uses canonical step language.
  - No first-path preview text is clipped in the inspected viewport.
- Create Goal large Dynamic Type: `2D390290-E516-4049-B80F-722D0CE5487B.png`
  - Large text fits the first viewport with the title, explanation, and title field visible.
  - No active first-viewport copy is clipped.

## UIQL Firewall Verdict

UIQL firewall verdict: Green locally, pending commit and manual push
Actual Linear issue: AMB-967
UIQL sequence label: UIQL-012
Active root/source dependency: `AmbitionsApp` -> `LaunchGateView` -> `AmbitionsRootView` -> `AppShellView`; Create Goal overlay through `ambitions://overlay/create-goal`
Product object: global Capture route review and Create Goal first-path setup
Surface owner: `Native/Ambitions/App/AppShellView.swift`; `Native/Ambitions/Features/Capture/*`; `Native/Ambitions/Features/Goals/CreateGoalScreen.swift`; `Native/Ambitions/Domain/GoalEngine/GoalEnginePlanner.swift`
Existing primitives inspected: activated Capture seam, Capture route preview primitives, Create Goal object stage, TagPill/SectionHeader primitives
Screenshot visual evaluation: current rerun9 screenshots inspected; screenshot paths alone were not treated as proof
Accessibility variant evidence: large Dynamic Type Create Goal screenshot captured; formal AMB-968 accessibility pass remains next
Copy/canon scan: final scans recorded in closeout validation; active AMB-967 copy repaired away from AI/classifier/policy/Auto-detect/move language in scoped paths
Card/list/dashboard anatomy scan: first-path preview no longer uses an `AppCard`; broader remaining Create Goal lower sections are outside the first-path proof viewport and remain subject to later audit if surfaced
Shell/safe-area/dock proof: Capture seam route labels and local receipt are visible above the dock/keyboard in final screenshots
Focused validation: source contract and screenshot matrix passed
Changed files: listed above
Proof artifacts: this report, rerun9 screenshots, final source-contract log, rerun9 screenshot-matrix log
Red blockers: none for scoped AMB-967 local evidence
Yellow tooling/device limits: GitHub push is pending by owner instruction; Linear Done is not claimed before push; AMB-968 formal accessibility proof not yet complete; no physical-device proof
No-claim boundary: no owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, full accessibility certification, VoiceOver certification, performance proof, privacy/legal approval, PLOS runtime completion, AMB-968 completion, AMB-970 independent audit, or AMB-969 approval package
Next dependency: AMB-968 / UIQL-013 Accessibility Variant Proof Pass

## Linear Closeout Text

AMB-967 / UIQL-012 closeout: Capture + Create Goal Reconstruction

Status: local scoped Green, push pending by owner instruction
Pushed to main: no
Commit: pending local AMB-967 closeout commit
Artifacts:
- `artifacts/ui-quality-lockdown/UIQL-012-AMB-967-capture-create-goal-reconstruction.md`
- `artifacts/ui-quality-lockdown/UIQL-012-AMB-967_REPAIR_REFRAME_REPORT.md`
- `artifacts/ui-quality-lockdown/script-output/AMB-967-capture-create-goal-source-contract-final.log`
- `artifacts/ui-quality-lockdown/script-output/AMB-967-capture-create-goal-screenshot-matrix-rerun9.log`
Screenshots:
- `artifacts/ui-quality-lockdown/screenshots/amb-967/rerun9/`

Validation:
- source contract: passed
- screenshot matrix: passed
- final UIQL scans/preflight: recorded in closeout commit artifacts

No-claim boundary:
- No owner approval claimed.
- No release/TestFlight/App Store readiness claimed.
- No full accessibility certification, VoiceOver certification, physical-device proof, or product completion claimed.

Next dependency: AMB-968 / UIQL-013 Accessibility Variant Proof Pass.
