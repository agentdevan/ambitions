# IOS26-T04A-B05: You Life Context Premium Personalization Panel

Status: YELLOW
Batch: IOS26-T04A-B05
Train: TRAIN_04A
Branch: main
Commit base: 0a899e285e907c9c4f98d4d8bba4919113cbe3ba

## Scope
- Installed a first-class `You -> Life Context` panel with the requested hero copy, CTAs, grouped sections, and inspectable fact-row controls.
- Wired the You screen to expand/collapse the Life Context disclosure sections from the new hero CTAs.
- Extended the Life Context test fixture and UI test coverage for the new panel route and fact-row actions.

## Files changed
- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`

## What changed
- Updated the Life Context hero copy to the required premium panel language:
  - `Life Context`
  - `Help Ambitions plan from your real life.`
  - `Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.`
- Added the hero CTAs:
  - `Catch me up`
  - `Review what Ambitions knows`
- Reworked the panel into the required grouped sections:
  - Basics
  - Schedule & Availability
  - Travel & Access
  - Facilities & Equipment
  - Eligibility & Pathways
  - History
  - Constraints
  - Review Needed
- Exposed row-level inspectability with source/freshness/runtime-use/where-used badges and edit/pause/delete/review/confirm controls.
- Added focused UI coverage for the new Life Context route and hero CTA expansion behavior.

## Truth files inspected
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`

## Validation run
- Passed: `xcodegen generate`
- Passed: `scripts/build-local.sh`
- Passed: `make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsTests`
- Failed on inherited unrelated UI regressions: `make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsUITests`
- Passed: `make xcode-focused-test BATCH=IOS26-T04A-B05 TEST='AmbitionsUITests/AmbitionsUITests/testYouLifeContextHeroCTAsExpandCatchUpAndReviewRoutes'`
- Passed: `git diff --check`

## Evidence
- Unit test lane passed in `.codex/xcode-summaries/IOS26-T04A-B05/20260523T041943Z/validate-summary.json`
- Targeted Life Context UI lane passed in `.codex/xcode-summaries/IOS26-T04A-B05/20260523T044236Z/focused-test-summary.json`
- Broad AmbitionsUITests lane failed earlier in `.codex/xcode-summaries/IOS26-T04A-B05/20260523T042215Z/focused-test-summary.json` with unrelated inherited failures outside this patch

## Passes
- Life Context copy now matches the required hero language.
- The panel is presented as a premium grouped You surface instead of a dense admin wall.
- The focused Life Context UI test confirms the new route, CTAs, and disclosure expansion behavior.
- The unit-test lane is green.

## Failures
- The broader `AmbitionsUITests` focused lane still has unrelated inherited failures:
  - `testCapturePromotionOpensComposerWithSeededText`
  - `testDemoGoalsAtlasLoadsCoreModules`
  - `testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - `testTodayCanHandOffToGoalDetail`
  - `testTodayStartNowCanOpenBoundedStepSession`

## Skipped
- No top-level IA, backend, cloud, or dependency changes were made.
- No accessibility, device, TestFlight, App Store, or production-readiness claim is made beyond the proofs above.

## Unproven
- Full `AmbitionsUITests` green status.
- Any release, privacy, accessibility, or performance claim not directly supported by current proof.
- Any claim that unrelated inherited UI failures were fixed by this batch.

## Accessibility status
- Not fully verified in this batch.
- The UI exposes the required controls and section labels in the focused route, but this is not a full accessibility proof.

## Privacy/local-first status
- Preserved local-first behavior.
- No cloud AI, analytics, tracking SDK, or hosted personal-data dependency was added.

## Claims allowed
- A first-class You Life Context panel exists.
- The requested hero copy, CTAs, and section names are implemented.
- The targeted Life Context route and CTA behavior are proven by focused UI validation.
- Unit tests for the Life Context projection passed.

## Claims forbidden
- Full UI-suite green.
- Accessibility verified.
- Release-ready.
- App Store/TestFlight ready.
- Performance-proven.

## Release blockers
- Inherited unrelated `AmbitionsUITests` failures remain in the broader UI suite.

## Post-batch gates
- Re-run `git diff --check` after this report file lands.
- If the broader UI suite is to be repaired, address the unrelated failing test seams in a separate batch.

## Rollback
- Revert only the files touched by this batch:
  - `Native/Ambitions/Domain/YouModels.swift`
  - `Native/Ambitions/Features/You/YouFeatureService.swift`
  - `Native/Ambitions/Features/You/YouScreen.swift`
  - `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`
  - `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - `build/reports/life-context/you-life-context-premium-panel.md`
- Leave unrelated worktree changes untouched.

## Next eligible batch
- A separate UI-flake repair batch for the inherited `AmbitionsUITests` failures, if authorized.
