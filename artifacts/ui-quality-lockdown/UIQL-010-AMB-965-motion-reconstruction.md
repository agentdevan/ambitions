# UIQL-010 / AMB-965 Motion Reconstruction Proof

Status: Local complete; push pending because the owner will push manually when GitHub is fixed.
Program: UIQL
Linear issue: AMB-965
Sequence label: UIQL-010
Date: 2026-06-12 America/New_York

## Claim

AMB-965 reconstructs Motion as `Motion Current`, a proof/recovery/re-entry surface that answers: "What moved, what has proof, and what can re-enter?"

The closing proof shows:

- Motion defaults to a proof-present state, not an explainer page.
- The first content object shows proof, recovery, and re-entry relationships.
- `Inspect proof`, `Open receipt`, and `Re-enter thread` are visible actions, not labels only.
- The empty state is explicit: `No proof yet` and `Empty proof state`.
- Recovery and re-entry states are shame-free and source/receipt-bound.
- The receipt path and continuity dock are visible without bottom dock collision.
- Large Dynamic Type shows wrapped action labels without ellipsis or clipped text in the claimed action proof frame.
- No XP, streak, score, analytics-dashboard, generic progress chart, or activity-feed framing is visible in the scoped proof path.

## What Changed

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift`
  - Makes the live default render state proof-present while retaining an explicit empty render state for proof.
  - Moves the Motion Current object before the contextual crown so the first content viewport shows what moved.
  - Adds first-viewport actions for proof inspection, receipt opening, and re-entry.
  - Reorders accessibility-size layout so actions and trace facts are visible before long copy.
  - Adds a Motion scroll identifier for screenshot anchoring.
- `Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift`
  - Adds AMB-965 proof that Motion exposes proof, receipt, and re-entry actions.
  - Updates Motion field and receipt-chip expectations to match current source.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Adds the AMB-965 screenshot matrix for default, empty, proof/recovery/re-entry, receipt/dock, and large Dynamic Type states.
  - Adds Motion screenshot capture and frame-based screenshot anchoring helpers.

## Validation

- `git diff --check`: passed.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`: passed.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/MotionCurrentScreenTests/testAMB965MotionReconstructionExposesProofReceiptAndReentryActions -only-testing:AmbitionsTests/MotionCurrentScreenTests/testMotionCurrentFieldKeepsEmptyStateStructured -only-testing:AmbitionsTests/MotionCurrentScreenTests/testMotionCurrentAffordanceKeepsRuntimeInspectionPathVisible`: passed, 3 tests, 0 failures. Final log: `artifacts/ui-quality-lockdown/script-output/AMB-965-motion-focused-unit-tests-rerun4.log`.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB965MotionReconstructionScreenshotMatrix -resultBundlePath artifacts/ui-quality-lockdown/script-output/AMB-965-motion-screenshot-matrix-rerun5.xcresult`: passed, 1 test, 0 failures. Final log: `artifacts/ui-quality-lockdown/script-output/AMB-965-motion-screenshot-matrix-rerun5.log`.

## Screenshot Proof

Final screenshot directory: `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/`

- Default: `3175465E-AA84-4498-9F9B-58B3A804E28F.png`
- Empty: `F916E545-B09A-4EBD-9C96-AF747F5D1017.png`
- Proof / recovery / re-entry: `F22BFC38-FFAE-4C1A-AC08-F39CC850F5BF.png`
- Receipt / dock clearance: `0D174C92-E272-4779-89F8-162F2AAA7057.png`
- Large Dynamic Type: `9C90891D-10E0-4F38-A68B-6D70D907D5F8.png`

Visual inspection result: Green for scoped AMB-965. Default, empty, and re-entry frames visibly show the Motion Current object, proof/recovery/re-entry rhythm, inspect/open/re-enter actions, and source/proof/receipt facts above the bottom dock. The receipt/dock frame visibly shows the source/proof/receipt inspection stage and Continuity Dock while the bottom Meridian dock remains separate. The large Dynamic Type frame visibly shows full wrapped `Inspect proof`, `Open receipt`, and `Re-enter thread` action labels without ellipsis.

## Repair Evidence

More than three repair cycles were needed. Superseded logs and screenshots are repair evidence only:

- `AMB-965-motion-screenshot-matrix-rerun1.log`
- `AMB-965-motion-screenshot-matrix-rerun2.log`
- `AMB-965-motion-screenshot-matrix-rerun3.log`
- `AMB-965-motion-screenshot-matrix-rerun4.log`
- `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun1/`
- `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun2/`
- `artifacts/ui-quality-lockdown/screenshots/amb-965/rerun4/`

The final closing proof uses rerun5 screenshots and the final unit test rerun4 only.

## Green / Yellow / Red

- Green: Scoped AMB-965 local product evidence, deterministic scans, focused unit tests, screenshot matrix, and visual screenshot evaluation.
- Yellow: Local commit/push pending; no physical-device proof; no full accessibility certification; no VoiceOver certification; no owner approval; no release/TestFlight/App Store readiness.
- Red: None remaining for scoped AMB-965 after rerun5 visual inspection.

## Linear Closeout Text

Do not mark AMB-965 Done until this local commit is visible on `main`.

```text
AMB-965 / UIQL-010 Motion Reconstruction is locally complete but not pushed yet.

Local commit: current local HEAD after the AMB-965 commit; owner will push manually when GitHub is fixed.
Push status: pending.

Do not move AMB-965 to Done until the commit is visible on main.

Validation:
- git diff --check: passed
- UIQL mini-regression: passed
- AMB-965 focused Motion unit tests: passed, 3 tests / 0 failures
- AMB-965 screenshot matrix UI test: passed, 1 test / 0 failures
- Final screenshots visually inspected: passed

Artifacts:
- Proof: artifacts/ui-quality-lockdown/UIQL-010-AMB-965-motion-reconstruction.md
- Repair reframe: artifacts/ui-quality-lockdown/UIQL-010-AMB-965_REPAIR_REFRAME_REPORT.md
- Final screenshots: artifacts/ui-quality-lockdown/screenshots/amb-965/rerun5/

No-claim boundaries:
- No owner approval claimed.
- No release/TestFlight/App Store readiness claimed.
- No physical-device proof claimed.
- No full accessibility or VoiceOver certification claimed.
- No Linear closure claimed until the local commit is pushed and visible on main.

Next dependency after push/Linear closeout: AMB-966 / UIQL-011 You Reconstruction.
```
