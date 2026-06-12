# AMB-966 / UIQL-011 You Reconstruction

Status: scoped local Green, push pending owner manual push
Program: UIQL - Flagship UI Quality Lockdown
Linear issue: AMB-966
Sequence label: UIQL-011
Branch: main

## Claim

You now presents the first viewport as a User System Profile control surface for how Ambitions works for the user, not as a generic settings wall, admin panel, dashboard, or social profile. The default You root exposes:

- `Personal Runtime / User System Profile`
- `How Ambitions works for me`
- Trust & Automation
- Personal Runtime
- Receipts & History

The required Trust & Automation, Personal Runtime, Receipts & History, Local Data Controls, large Dynamic Type, requested Increase Contrast, and bottom-inset proof paths were exercised by the AMB-966 screenshot matrix and visually inspected.

## What Changed

- Replaced visible `Runtime Governance` copy with `How Ambitions works for me`.
- Rendered all three priority You routes in the first control field instead of only the first route.
- Tightened You root header/priority spacing so the priority routes remain readable above the dock in the default proof path.
- Added stable You screenshot/test anchors.
- Removed redundant detail-sheet navigation titles that clipped at large Dynamic Type.
- Shortened You status labels that truncated in the Trust and Receipts paths.
- Added an AMB-966 source contract and screenshot matrix.

## Files Touched

- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouRootSurface.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/Ambitions/Features/You/YouTrustHistoryProjector.swift`
- `Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ui-quality-lockdown/UIQL-011-AMB-966-you-reconstruction.md`
- `artifacts/ui-quality-lockdown/UIQL-011-AMB-966_REPAIR_REFRAME_REPORT.md`
- `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/`
- UIQL run-state, changelog, decisions, repair, review, and proof-ledger artifacts.

## Validation

- `git diff --check`
  - Exit code: 0
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: 0
  - Result: changed Swift source contains no UIQL-banned copy, adds no UIQL card-anatomy blockers, and passes shell scan.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PersonalSystemCenterDesignSystemTests/testAMB576YouObjectStageControlPrimitiveReplacesGenericProfileSettingsContainers`
  - Final log: `artifacts/ui-quality-lockdown/script-output/AMB-966-you-source-contract-tests-rerun3.log`
  - Exit code: 0
  - Result: 1 test, 0 failures.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB966YouReconstructionScreenshotMatrix -resultBundlePath artifacts/ui-quality-lockdown/script-output/AMB-966-you-screenshot-matrix-rerun12.xcresult`
  - Final log: `artifacts/ui-quality-lockdown/script-output/AMB-966-you-screenshot-matrix-rerun12.log`
  - Exit code: 0
  - Result: 1 test, 0 failures.

## Screenshot Proof

Final exported screenshots: `artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/`

- Default You: `F13E5529-DCE6-4EE3-9A64-3EBB36407610.png`
  - Visually inspected: User System Profile header, `How Ambitions works for me`, Trust & Automation, Personal Runtime, and Receipts & History are readable above the dock.
- Trust & Automation: `3A41C82F-9023-461A-BB03-C99BA0D12E9C.png`
  - Visually inspected: guided automation and confirmation boundary are readable; no truncated `Requires confirmation` pill remains.
- Personal Runtime: `180E7FEF-F872-4A93-96D7-3B1427AB82FA.png`
  - Visually inspected: local inspection, controls, and receipt posture are visible without implementation/debug framing.
- Receipts & History: `AB24B5F9-8805-4563-890E-0CB8431B9B7D.png`
  - Visually inspected: privacy, automation history, source, review, and boundary state are visible; the prior `5 guarded boun...` truncation is repaired.
- Large Dynamic Type: `102FE7B1-3A72-4CBC-BB72-7023C4185204.png`
  - Visually inspected: Personal Runtime detail path is readable at Accessibility XL after removing the clipped sheet navigation title.
- Requested Increase Contrast launch: `815ABB73-018A-42D1-AC84-3CAA98F8AE4A.png`
  - Visually inspected: current automated launch uses the contrast request argument; this is not a certified system Increase Contrast proof.
- Bottom inset / Local Data Controls: `59CB6DC8-F9DD-431F-B604-3F829F9E3E62.png`
  - Visually inspected: Local Data Controls remains reachable above the dock and the dock remains legible.

## Red / Yellow / Green

Green:

- Scoped AMB-966 You Reconstruction evidence is locally Green.
- The default You first viewport no longer reads as a settings/list wall.
- Required You routes are visible/reachable and current screenshots were actually inspected.
- Focused source contract and screenshot matrix pass.

Yellow:

- Push is pending owner manual push to `origin/main`; Linear Done must wait until the pushed commit is visible on `main`.
- The requested Increase Contrast screenshot is a best-effort launch-argument proof and not a formal system setting certification.
- No physical-device proof, VoiceOver certification, full accessibility certification, performance proof, owner approval, TestFlight readiness, App Store readiness, or release readiness is claimed.

Red:

- None remaining for scoped local AMB-966 evidence after final repair.

## Non-Claims

This does not claim owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, full accessibility certification, VoiceOver certification, performance proof, privacy/legal approval, PLOS runtime completeness, AMB-967+ completion, or Linear Done before the local commit is pushed.

## Linear Closeout Boundary

Do not move AMB-966 to Done until the owner manually pushes this local commit and the commit is visible on `origin/main`.

Manual/push-pending Linear comment:

```text
AMB-966 / UIQL-011 You Reconstruction is locally complete and awaiting owner manual push to main.

Local evidence:
- You root now presents Personal Runtime / User System Profile and "How Ambitions works for me."
- Trust & Automation, Personal Runtime, Receipts & History, and Local Data Controls are visible/reachable through the You control surface.
- Final screenshot matrix passed: artifacts/ui-quality-lockdown/script-output/AMB-966-you-screenshot-matrix-rerun12.log
- Final screenshots visually inspected: artifacts/ui-quality-lockdown/screenshots/amb-966/rerun12/
- Focused source contract passed: artifacts/ui-quality-lockdown/script-output/AMB-966-you-source-contract-tests-rerun3.log
- UIQL mini-regression passed.

Push status: pending owner manual push.
Linear status: should remain In Progress until pushed commit is visible on main.
No owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, VoiceOver certification, or full accessibility certification claimed.
Next dependency after push-visible closeout: AMB-967 / UIQL-012 Capture + Create Goal Reconstruction.
```
