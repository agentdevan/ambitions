# Design Truth Refraction Train 3 Validation

Status: Green
Date: 2026-06-18
Branch: `main`
Scope: root Stage shell, four canonical root surfaces, Capture overlay/global composer routing, Motion behavior routing, shell chrome ownership

## Boundary

Train 3 replaces the root product `TabView` architecture with a Stage surface host for the four canonical roots:

- Today
- Goals
- Time
- You

Capture remains an overlay/global composer only. Motion remains Stage/Motion behavior only. This train does not reconstruct Today, Goals, Time, or You feature content beyond route and chrome integration required by the root shell.

Rollback boundary is the Train 3 git commit. No hidden second product shell is retained.

## Runner Admission

Prompt:

```text
prompts/design-truth-refraction/DESIGN-TRUTH-REFRACTION-TRAIN-3-root-stage-shell.md
```

Runner command:

```bash
READ_ONLY_AUDIT=1 AUTO_BRANCH=0 AUTO_COMMIT=0 AUTO_PUSH=0 ALLOW_HISTORICAL_BATCH=1 scripts/ambitions-codex-train.sh DESIGN-TRUTH-REFRACTION-TRAIN-3 prompts/design-truth-refraction/DESIGN-TRUTH-REFRACTION-TRAIN-3-root-stage-shell.md
```

Result: admitted under runner boundary before source edits.

## Xcode Proof

Toolchain note: final Xcode gates used `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. A stale local `/Users/devan/Downloads/Xcode.app` path was not used for final proof because it was missing the CoreData SDK header required by this repo's current build.

Build-for-testing:

```text
status: passed
summary: .codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T174753Z-bft-19309-21631/build-for-testing-summary.json
result bundle: .codex/xcode-results/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T174753Z-bft-19309-21631/build-for-testing.xcresult
```

Focused shell unit suites:

```text
status: passed
tests: 94
summary: .codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T174921Z-validate-19675-31278/validate-summary.json
```

Covered suites:

- `AmbitionsTests/AppShellNavigationTests`
- `AmbitionsTests/AppShellChromeTests`
- `AmbitionsTests/ScreenContractRegistryTests`
- `AmbitionsTests/ShellPreviewMatrixTests`
- `AmbitionsTests/StageMotionRoutingTests`
- `AmbitionsTests/ShellCommandRouterTests`

Focused UI shell proof:

```text
status: passed
tests: 6
summary: .codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175305Z-validate-21793-29850/validate-summary.json
```

Covered UI tests:

- `testPreviewBootstrapExposesCanonicalFourTabShellAndSecondarySurfaces`
- `testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable`
- `testUIQL002GoalDetailDrilldownHidesRootDock`
- `testUIQL002ActivatedCaptureSeamUsesOverlayKeyboardClearanceWithoutRootDock`
- `testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`
- `testLegacyMotionRouteDoesNotCreateRootDestination`

## Screenshot Review

Latest screenshot extraction:

```text
.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175710Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-23001-2283/extract/attachments
```

Reviewed artifacts:

- `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175710Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-23001-2283/extract/attachments/afri-005-shell-today_0_28BD7CD6-1AB8-46F6-A76E-027F06D9C2C8.png`
- `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175710Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-23001-2283/extract/attachments/afri-005-shell-goals_0_2513E1C4-AD0D-4C61-800E-5361317CF51C.png`
- `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175710Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-23001-2283/extract/attachments/afri-005-shell-time_0_E2ACBE2F-2CDE-40EB-A249-66C26F65F6FA.png`
- `.codex/xcode-summaries/DESIGN-TRUTH-REFRACTION-TRAIN-3/20260618T175710Z-AmbitionsUITests-AmbitionsUITests-testAFRI005ShellScreenshotBaselineCapturesCano-23001-2283/extract/attachments/afri-005-shell-you_0_A2DCE1CB-B243-4ACB-B541-97AEE5DBCD21.png`

Visual review result:

- Root dock shows exactly Today, Goals, Time, You.
- No Capture root destination appears.
- No Motion root destination appears.
- Dock is legible and inside the visible safe area.
- Today live rail copy is readable.
- You priority governance rows are readable.
- Drilldown and Capture overlay behavior are covered by UI tests rather than screenshot-only inference.

## Static Gates

Final static gates passed after the validation note was created:

- `python3 scripts/ambitions-design-truth-refraction-audit.py --write`
- `git diff --check`
- `python3 scripts/ambitions-design-truth-refraction-audit.py --check`
- `python3 scripts/ambitions-legacy-ia-route-lint.py`
- `python3 scripts/ambitions-surface-contract-lint.py`
- `python3 scripts/ambitions-copy-contract-lint.py --include-components`
- `python3 scripts/ambitions-visible-copy-drift-scan.py --strict`
- `python3 scripts/ambitions-vocabulary-drift-scan.py`
- `python3 scripts/ambitions-moat-drift-scan.py`
- `python3 scripts/ambitions-repo-authority-validate.py`

## No-Claim Boundary

This Train 3 proof does not make release, device, privacy/legal, Ambitions Account, R2, TestFlight, App Store, or public accessibility certification claims.
