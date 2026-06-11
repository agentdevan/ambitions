# AMB-962 / UIQL-007 Today Reconstruction Proof

Status: Green for scoped AMB-962 Today Reconstruction
Date: 2026-06-11
Branch: main
Base commit before AMB-962 work: `8b689fce8b13311e3325c125b1125d478b764fba`
Closeout commit: pending at artifact creation

## Claim

Today now opens on a flagship Reality Meridian / Start Here object rather than a generic agenda, task list, calendar rail, passive empty state, dashboard stack, or implementation-spec surface.

The scoped AMB-962 repair:

- keeps `Start here` dominant and connected to the current Meridian node;
- exposes `Recommended step`, primary action, and `Why this?` receipt affordance;
- uses exact source-unavailable copy: `Source unavailable. Manual planning still works.`;
- gives the no-step state five visible recovery/build paths: `Capture what changed`, `Shape Time`, `Review source`, `Close Today`, and `Protect this window`;
- exposes the Start Here receipt seam in the closure path before outcome selection;
- makes `Still Counts`, `Waiting`, `Blocked`, and `Not needed` visible closure outcomes;
- repairs large Dynamic Type top safe-area collision and dock-covered text in the Today first viewport.

## Touched Files

- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayStartHereSurface.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- UIQL artifacts, proof ledger, and script-output logs

## Validation

- `git diff --check`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: `0`
  - Logs: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`, `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`, `artifacts/ui-quality-lockdown/script-output/uiql-shell.log`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB962TodayReconstructionScreenshotMatrix`
  - Exit code: `0`
  - Result bundle: `artifacts/ui-quality-lockdown/script-output/AMB-962-today-reconstruction-screenshot-matrix-rerun8.xcresult`
  - Log: `artifacts/ui-quality-lockdown/script-output/AMB-962-today-reconstruction-screenshot-matrix-rerun8.log`
  - Result: 1 UI test executed, 0 failures
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8` with focused Today selectors:
  - `AmbitionsTests/TodayViewModelTests/testF01DayRailFoundationProjectsStartHereRowsAndFutureSlots`
  - `AmbitionsTests/TodayViewModelTests/testFCP05StartHereSurfaceCarriesSourceTimeGoalAndReceiptSeam`
  - `AmbitionsTests/TodayViewModelTests/testF05ActionClosureSheetSupportsStillCountsWithReceiptPreview`
  - `AmbitionsTests/TodayViewModelTests/testF06ActionClosureProjectsProofReceiptPeekBeforePersistence`
  - `AmbitionsTests/TodayRealityMeridianExperienceElevationTests`
  - Exit code: `0`
  - Result bundle: `artifacts/ui-quality-lockdown/script-output/AMB-962-today-focused-unit-tests-rerun1.xcresult`
  - Log: `artifacts/ui-quality-lockdown/script-output/AMB-962-today-focused-unit-tests-rerun1.log`
  - Result: 10 tests executed, 0 failures

## Screenshot Matrix

Final passing screenshots are exported under `artifacts/ui-quality-lockdown/screenshots/amb-962/rerun8/`:

- Default Today: `3A215C8D-140E-42BC-8C43-5DFB89C9BA92.png`
- Source unavailable/manual planning: `5FF71434-252C-4AF8-ADC1-912BF10E383D.png`
- Active/recommended step: `FBBD0E75-3E88-42A3-90DE-4AE3D7F6A70B.png`
- Large Dynamic Type: `A3126CA1-E88D-4C4C-B887-D5C624560062.png`
- Receipt visible: `BF829265-8F61-4CE6-B320-0072B956EEA2.png`
- Reduce Motion/static equivalent: `E1EEFD6B-66F5-44CB-A99D-4AF192098165.png`
- No-step paths: `C0AB76FE-3D5F-40BF-B116-97FD146DF9B5.png`
- Manifest: `artifacts/ui-quality-lockdown/screenshots/amb-962/rerun8/manifest.json`

## Visual Evaluation

Current screenshots were visually inspected after export.

Green observations:

- Default, source-unavailable, and active-step states show a single Today Reality Meridian / Start Here object, not a task list, agenda, card stack, dashboard, chatbot, or calendar clone.
- Source-unavailable state shows `Source unavailable. Manual planning still works.` and keeps the user on a manual-safe path.
- Receipt-visible state shows the Start Here receipt seam, local storage context, outcome map, and visible closure outcomes.
- No-step state shows five action paths above the dock and does not collapse into a passive blank state.
- Large Dynamic Type no longer collides with the status/header chrome and no longer leaves lower explanatory text trapped under the dock.

## Repair Evidence

Failed/intermediate matrix runs are retained as repair evidence only:

- `AMB-962-today-reconstruction-screenshot-matrix.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun1.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun2.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun3.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun4.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun5.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun6.log`
- `AMB-962-today-reconstruction-screenshot-matrix-rerun7.log`
- `AMB-962-today-focused-unit-tests.log`

These logs do not support Green claims; they explain the repair path documented in `UIQL-007-AMB-962_REPAIR_REFRAME_REPORT.md`.

## No-Claim Boundaries

This proof does not claim:

- owner approval;
- release readiness, TestFlight readiness, or App Store readiness;
- physical-device proof;
- full accessibility certification;
- VoiceOver certification;
- performance proof;
- privacy/legal approval;
- PLOS runtime completeness;
- Goals, Time, Motion, You, or Capture reconstruction completion;
- AMB-963 or later UIQL issue completion.

## Linear Closeout Text

Use this for AMB-962 after the commit is pushed:

```text
AMB-962 / UIQL-007 Today Reconstruction is complete.

Commit: <commit hash>

Scope:
- Reconstructed Today around the Reality Meridian / Start Here object.
- Added the exact source-unavailable copy: "Source unavailable. Manual planning still works."
- Added no-step recovery/build paths: Capture what changed, Shape Time, Review source, Close Today, Protect this window.
- Exposed the Start Here receipt seam in the closure path and made Still Counts, Waiting, Blocked, and Not needed visible.
- Repaired large Dynamic Type top chrome collision and dock-covered Today text.

Validation:
- git diff --check: passed
- UIQL mini-regression: passed
- AMB-962 screenshot matrix UI test: passed, 1 test / 0 failures
- Focused Today unit tests: passed, 10 tests / 0 failures

Artifacts:
- Proof: artifacts/ui-quality-lockdown/UIQL-007-AMB-962-today-reconstruction.md
- Repair reframe: artifacts/ui-quality-lockdown/UIQL-007-AMB-962_REPAIR_REFRAME_REPORT.md
- Final screenshot matrix: artifacts/ui-quality-lockdown/screenshots/amb-962/rerun8/
- UI test log: artifacts/ui-quality-lockdown/script-output/AMB-962-today-reconstruction-screenshot-matrix-rerun8.log
- Focused unit log: artifacts/ui-quality-lockdown/script-output/AMB-962-today-focused-unit-tests-rerun1.log

Red blockers: none for scoped AMB-962.
Yellow: no physical-device proof, no full accessibility certification, no owner approval, no release/TestFlight/App Store readiness claim.
Next dependency: AMB-963 / UIQL-008 Goals Reconstruction.
```
