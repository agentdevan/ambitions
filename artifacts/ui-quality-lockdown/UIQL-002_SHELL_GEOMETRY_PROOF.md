# UIQL-002 Shell Geometry And Safe-Area Proof

Status: Green for the scoped shell geometry and safe-area repair proven by current simulator UI tests. No screenshot, full accessibility certification, owner approval, or release readiness is claimed.

## Scope

UIQL-002 covers top-level shell geometry, safe-area behavior, native dock legibility, and activated Capture seam placement. It does not cover Today, Start Here, Goals, Time, Motion, You, or Capture product-surface quality gates beyond shell chrome and seam placement.

## Current Linear State

Available Linear connector calls returned `Issue not found` for `UIQL-002`. Manual closeout text is included below. No Linear state was updated.

## Source Findings

- `AmbitionsRootView` uses the active SwiftUI native `TabView` with canonical tabs `Today / Goals / Time / Motion / You`.
- Capture is exposed as a shell/global action, not a tab.
- UIQL-002 frame proof exposed two shell geometry Reds:
  - root shell header controls could extend above the top safe boundary in UI test frame coordinates;
  - activated Capture seam overlapped the native tab bar after keyboard dismissal.

## Changes

- `Native/Ambitions/App/AppShellView.swift`
  - Root shell header top clearance now uses `theme.spacing.lg + theme.spacing.lg + theme.spacing.lg`.
  - Header back and trailing controls now use `theme.panel.minimumTapTarget` instead of sub-44pt frames.
- `Native/Ambitions/App/AmbitionsRootView.swift`
  - Activated Capture seam bottom clearance now uses `theme.spacing.xxxl` so it stays above the native tab bar after keyboard dismissal.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Added `testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`.
  - Added `testUIQL002ActivatedCaptureSeamStaysAboveNativeDockAfterKeyboardDismissal`.
  - Added `assertFrame` helper for current simulator frame proof.

## Final Validation

- `git diff --check`
  - Exit: `0`
- `bash scripts/codex/program-proof-index.sh uiql`
  - Exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T021500.log`
  - Result: proof index regenerated with 4 entries.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-preflight.sh`
  - Exit: `0` before edits
  - Artifact: `artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T012519.log`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit: `0`
  - Artifacts: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`, `uiql-card-anatomy.log`, `uiql-shell.log`
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-002`
  - Final exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-002-build-for-testing-after-seam-clearance-fix-20260611T060706Z.log`
- `scripts/ambitions-xcode-test-focused.sh --batch UIQL-002 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`
  - Final exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-clearance-final-20260611T060022Z.log`
  - Result: 1 UI test, 0 failures.
- `scripts/ambitions-xcode-test-focused.sh --batch UIQL-002 --only-testing AmbitionsUITests/AmbitionsUITests/testUIQL002ActivatedCaptureSeamStaysAboveNativeDockAfterKeyboardDismissal`
  - Final exit: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-002-activated-capture-seam-ui-test-after-seam-clearance-fix-20260611T060859Z.log`
  - Result: 1 UI test, 0 failures.

## Failed Evidence Kept

The failed logs are retained because they explain the repair, prevent false Green, and prove why the final patch was necessary:

- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-20260611T052920Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-rerun-20260611T053451Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-fix-20260611T054054Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-fix-2-20260611T054557Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-hit-target-fix-20260611T055100Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-shell-geometry-ui-test-after-header-clearance-fix-20260611T055543Z.log`
- `artifacts/ui-quality-lockdown/script-output/UIQL-002-activated-capture-seam-ui-test-20260611T060258Z.log`

## Gate Status

- Green: shell header actionable controls stay inside the app window and remain hittable in current simulator UI proof.
- Green: native tab bar and five canonical tab buttons stay inside the app window, remain hittable, and meet 44pt minimum hit targets.
- Green: Capture is not a top-level tab.
- Green: activated Capture seam stays above the native tab bar after keyboard dismissal.
- Yellow: screenshot/visual approval is not claimed; this issue used current UI automation frame proof, not screenshot review.
- Yellow: Linear update is manual because `UIQL-002` was not found by the available connector.
- Red: none remaining for UIQL-002 scope.

## Non-Claims

This does not prove screenshot approval, complete accessibility conformance, Dynamic Type coverage beyond the tested frame behavior, VoiceOver order, Reduce Motion behavior, Increase Contrast, physical-device behavior, performance, privacy/legal approval, owner approval, TestFlight readiness, App Store readiness, release readiness, or downstream surface quality gates.

## Manual Linear Closeout

```text
UIQL-002 Shell geometry and safe-area proof

- Pushed to main: pending this commit
- App source changed: yes, shell geometry only
- UI test source changed: yes, UIQL-002 frame proof tests
- New top-level tabs: no
- Capture top-level tab: no
- Validation:
  - uiql-preflight before edits: Green
  - git diff --check: pass
  - uiql-mini-regression: exit 0
  - build-for-testing after final fix: exit 0
  - UIQL-002 shell geometry UI test: 1 test, 0 failures
  - UIQL-002 activated Capture seam UI test: 1 test, 0 failures
- Red blockers: none for UIQL-002 scope
- Yellow: Linear issue not found; screenshot/visual approval and owner approval not claimed
- Owner approval claimed: no
- Release/TestFlight/App Store readiness claimed: no
- Next: UIQL-003 Today / Reality Meridian quality gate
```
