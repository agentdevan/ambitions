# UIQL-006 Time / LifeShape Field Proof

Status: Scoped Green with Yellow tooling limits
Program: UIQL
Issue: UIQL-006 - Time / LifeShape Field quality gate
Branch: main
Base commit: `2d9dd87549ef71887ec10d363f5a1f9381436eec`
Closeout commit: pending at proof creation

## Claim

The Time first viewport now presents Time as `Shape Time` / `LifeShape Field` with a `Capacity` shell lens, readable Week shape copy, and no bottom dock mask covering text. The scoped automation validates the active Time route and LifeShape Field after rebuilding the UI test bundle.

## What Changed

- `Native/Ambitions/App/AppShellView.swift`
  - Time shaping posture now presents the visible header lens as `Capacity` instead of surfacing the internal `Plan` mode lens.
- `Native/Ambitions/Features/Time/TimeScreen.swift`
  - Replaced the opaque bottom safe-area mask with clear bottom spacing so Time content is not hidden behind the native dock region.
- `Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
  - Moved Week shape title/summary above the texture marks, bounded non-accessibility line counts, and adjusted first-viewport mark density/height so primary copy remains readable.
- `Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift`
  - Updated the primitive contract test to require the clear bottom inset and reject the removed opaque bottom mask colors.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Retargeted stale Time workspace assertions from legacy hero/depth checklist expectations to the active Time screen and LifeShape Field identifiers.

## Visual Evaluation

Screenshot inspected: `artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-final.png`

Visual result:

- Header reads `TIME · Shape Time · Capacity`.
- Primary object is `LifeShape Field`.
- Week shape copy is readable in the first viewport.
- The bottom dock blur no longer occludes visible text.
- No owner approval, full accessibility certification, device proof, or release readiness is claimed from the screenshot.

Before screenshot retained for repair context: `artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-before.png`.

## Validation

Final Green evidence:

- `git diff --check`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/uiql-shell.log`
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-006`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-006-build-for-testing-final-20260611T102057Z.log`
  - Result: `Test Build Succeeded`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-006 --only-testing AmbitionsUITests/AmbitionsUITests/testDemoTimeWorkspaceShowsBatch49CoreModules`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T102158Z.log`
  - Result: `EXECUTED_TESTS=1`, `FAILURE_CLASS=passed`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-006 --only-testing AmbitionsTests/TimeFeatureServiceTests/testAMB573TimeObjectStagePrimitiveContractReplacesFirstViewportGenericGeometry`
  - Exit code: `0`
  - Artifact: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-object-stage-primitive-focused-test-final-20260611T094333Z.log`
  - Result: `EXECUTED_TESTS=1`, `FAILURE_CLASS=passed`

Repair evidence retained:

- Initial UI test failure: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-initial-20260611T093636Z.log`
- Stale compiled-test and brittle assertion retries: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T094508Z.log` through `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T101510Z.log`
- Rebuilt passing UI test before the final shell-test cleanup: `artifacts/ui-quality-lockdown/script-output/UIQL-006-time-workspace-ui-test-final-20260611T101849Z.log`

## Green / Yellow / Red

Green:

- Scoped Time / LifeShape Field first-viewport repair is complete.
- Final build-for-testing succeeded.
- Focused Time UI test passed after rebuilding.
- Focused Time primitive source test passed.
- Fast UIQL scans passed.
- Current screenshot was visually evaluated.

Yellow:

- Linear issue `UIQL-006` was not found by the available connector, so manual closeout text is required.
- The Xcode wrapper continues to print `result bundle missing` after successful build/test footers; raw logs and XCTest summaries are used as scoped evidence.
- Several failed UI test logs are retained as repair evidence only; they are not Green proof.
- This does not prove full VoiceOver order, Dynamic Type matrix, Reduce Motion, Increase Contrast, physical-device behavior, performance, privacy/legal approval, owner approval, TestFlight readiness, App Store readiness, or release readiness.

Red:

- None for the scoped UIQL-006 Time first-viewport quality gate.

## Manual Linear Closeout

```text
UIQL-006 Time / LifeShape Field quality gate

Status: Scoped Green after push to main.
Push hash: <fill after push>
App source changed: yes, scoped to Time shell/header and Time LifeShape Field UI quality.
Issue scope: Time / LifeShape Field only.

Evidence:
- Header now reads TIME · Shape Time · Capacity.
- LifeShape Field is the first-viewport Time object.
- Week shape copy is readable and no longer hidden by the dock mask.
- Final screenshot visually evaluated: artifacts/ui-quality-lockdown/screenshots/UIQL-006-time-lifeshape-final.png
- git diff --check: passed.
- uiql-scan-banned-copy: passed.
- uiql-scan-card-anatomy: passed.
- uiql-mini-regression: passed.
- build-for-testing: Test Build Succeeded.
- focused UI test: AmbitionsUITests/testDemoTimeWorkspaceShowsBatch49CoreModules passed, EXECUTED_TESTS=1.
- focused unit test: TimeFeatureServiceTests/testAMB573TimeObjectStagePrimitiveContractReplacesFirstViewportGenericGeometry passed, EXECUTED_TESTS=1.

Yellow:
- Linear issue was not available to the connector in this Codex run.
- Xcode wrapper still reports missing .xcresult bundles after successful build/test footers.
- No owner approval, release readiness, TestFlight/App Store readiness, physical-device proof, full accessibility certification, or performance claim.

Next: UIQL-007 after clean main preflight.
```
