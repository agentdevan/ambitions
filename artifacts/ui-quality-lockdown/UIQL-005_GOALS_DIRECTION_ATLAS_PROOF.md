# UIQL-005 Goals / Direction Quality Gate Proof

Status: Scoped Green with documented Yellow tooling limits
Issue: UIQL-005
Program: UIQL
Branch: `main`
Created: 2026-06-11

## Claim

Goals root now presents the active Goals object as `Your Direction`, keeps Life Areas equal-weight, exposes a `Thread Focus` inspection path, and avoids visible stale `Direction Atlas`, `Constellation Atlas`, and `Orbital Lens` labels in the first-screen Goals experience.

## What Changed

- Reframed Goals root hero copy from atlas/lens language to `Your Direction` and direction-object language.
- Reframed `Orbital Lens` visible title to `Thread Focus` while preserving existing source identifiers for compatibility.
- Repaired Goals loading/degraded copy so the loading state no longer exposes `Constellation Atlas` or project-board language.
- Updated Goals screen contract first-screen content to `Your Direction` and `Thread Focus`.
- Reduced the Goals first viewport so lower object detail is not painted under the shell dock.
- Added proof-mode Thread Focus rendering that shows Proof, Source, and Why rows without hiding them behind the dock.
- Added UI test assertions that Goals root shows `Your Direction`, does not show stale atlas/lens labels, opens `Thread Focus`, and exposes proof/source/why elements.

## Touched Files

- `Native/Ambitions/Domain/ScreenContractModels.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `artifacts/ui-quality-lockdown/screenshots/UIQL-005-goals-your-direction-final.png`

## Valid Green Evidence

- `git diff --check`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: `0`
- `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-005`
  - Exit code: `0`
  - Final log: `artifacts/ui-quality-lockdown/script-output/UIQL-005-build-for-testing-after-proof-mode-fit-repair-20260611T091550Z.log`
  - Note: Xcode reported `Test Build Succeeded`; wrapper reported missing `.xcresult` bundle as Yellow.
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-005 --only-testing AmbitionsTests/GoalsOverviewAtlasTests/testAFI07GoalsConstellationAtlasKeepsThreadsConnectedToTodayWithoutTopLevelMissionControl`
  - Exit code: `0`
  - Executed tests: `1`
  - Final log: `artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-overview-afi07-focused-test-after-loading-repair-serial-20260611T085157Z.log`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-005 --only-testing AmbitionsTests/GoalsOverviewAtlasTests/testAFRI024GoalsConstellationAtlasExposesInspectableLocalSourceReceiptAndReplayBasis`
  - Exit code: `0`
  - Executed tests: `1`
  - Final log: `artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-overview-afri024-focused-test-after-loading-repair-serial-20260611T085322Z.log`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-005 --only-testing AmbitionsTests/ScreenContractRegistryTests/testD20ScreenContractsUseHumanStateLanguage`
  - Exit code: `0`
  - Executed tests: `1`
  - Final log: `artifacts/ui-quality-lockdown/script-output/UIQL-005-screen-contract-human-language-focused-test-20260611T085445Z.log`
- `AMBITIONS_SIM_UDID=8ACCD665-4807-4102-B526-5A1AE20686A8 scripts/ambitions-xcode-test-focused.sh --batch UIQL-005 --only-testing AmbitionsUITests/AmbitionsUITests/testDemoGoalsAtlasLoadsCoreModules`
  - Exit code: `0`
  - Executed tests: `1`
  - Final log: `artifacts/ui-quality-lockdown/script-output/UIQL-005-goals-atlas-ui-test-after-proof-mode-fit-repair-20260611T091732Z.log`

## Visual Evaluation

Screenshot inspected:

- `artifacts/ui-quality-lockdown/screenshots/UIQL-005-goals-your-direction-final.png`

Observed:

- Header remains canonical: `GOALS · Direction · Focus`.
- Root object title is `Your Direction`.
- Subtitle frames life areas, proof, source, and Today connection as one direction object.
- Life Areas are equal-weight and same-sized.
- Proof-mode `Thread Focus` is expanded and visible.
- Proof, Source, and Why rows are visible and readable.
- No visible `Direction Atlas`, `Constellation Atlas`, or `Orbital Lens` labels in the inspected screenshot.
- No source/proof/why text is hidden under the dock in the proof-mode screenshot.

## Yellow Items

- Linear issue `UIQL-005` was not found by the available Linear connector; manual closeout text is below.
- The Xcode wrapper reports missing `.xcresult` bundles after successful build/test execution. The logs still include `Test Build Succeeded`, `Test Execute Succeeded`, `FAILURE_CLASS=passed`, and executed-test counts where applicable.
- A broad `ScreenContractRegistryTests` run exposes existing unrelated Capture/Motion drift in `testD10TopLevelContractsMatchCanonicalFiveTabShell`; UIQL-005 did not widen into that repair.
- Earlier selector/noisy logs and invalid/stale screenshots are retained as repair evidence only; they are not Green proof.

## Non-Claims

- No full accessibility certification is claimed.
- No VoiceOver audit is claimed.
- No Dynamic Type certification is claimed beyond the scoped tested/default proof state.
- No Reduce Motion or Increase Contrast certification is claimed.
- No physical-device proof is claimed.
- No performance proof is claimed.
- No privacy/legal approval is claimed.
- No owner approval is claimed.
- No TestFlight, App Store, release, or readiness claim is made.
- No PLOS runtime completeness is claimed.

## Manual Linear Closeout Text

Codex UIQL-005 Closeout

- Pushed to main: pending at artifact creation
- Commit: pending
- Scope: Goals / Direction quality gate
- App source changed: yes, scoped to Goals UI/model/service/shared loading copy/tests
- Product claim: Goals root now uses `Your Direction`, keeps equal-weight Life Areas visible, exposes `Thread Focus`, and removes visible stale atlas/lens labels from the scoped first-screen proof path.
- Validation:
  - `git diff --check`: pass
  - `uiql-scan-banned-copy.sh`: pass
  - `uiql-scan-card-anatomy.sh`: pass
  - `uiql-mini-regression.sh`: pass
  - `scripts/ambitions-xcode-build-for-testing.sh --batch UIQL-005`: Test Build Succeeded; wrapper `.xcresult` Yellow
  - Focused Goals model/projection tests: pass
  - Focused screen-contract language test: pass
  - Focused Goals UI test: pass
  - Current screenshot visually inspected: pass for scoped proof
- Red blockers: none for UIQL-005 scope
- Yellow: Linear issue unavailable; Xcode wrapper result-bundle warning; unrelated broad screen-contract Capture/Motion drift
- Owner approval claimed: no
- Release readiness claimed: no
