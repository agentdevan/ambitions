# IOS26-T04A-B04: You Controls and Receipts

Status: Accepted Yellow
Batch: IOS26-T04A-B04
Train: TRAIN_04A
Branch: main
Commit base: 33902cbdd4d0d75efe1f0711702c0e0228cd6479

## Scope
- Added Life Context fact-row modeling for You.
- Added Life Context receipt kinds and replayable changed-fact coverage.
- Added Today explanation summary support for used, needs review, and not used context summaries.
- Added external-surface privacy guard tests for sensitive Life Context content.

## Files changed
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Domain/YouModels.swift`
- `Native/Ambitions/Features/You/YouFeatureService.swift`
- `Native/Ambitions/Features/You/YouScreen.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift`
- `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift`
- `Native/AmbitionsTests/You/YouFeatureServiceTests.swift`

## What changed
- Replaced prompt-oriented Life Context rows with fact rows.
- Exposed source, freshness, runtime-use state, where-used, and edit/pause/delete/review/confirm controls in You.
- Added the requested Life Context receipt kinds to changed-fact modeling.
- Added Today explanation summaries for `Used`, `Needs review`, and `Not used`.
- Added privacy-sensitive assertions so widgets, Live Activities, and App Intents do not surface sensitive Life Context values by default.

## Validation
- Passed: `xcodegen generate`
- Passed: `scripts/build-local.sh`
- Passed: `make xcode-focused-test BATCH=IOS26-T04A-B04 TEST=AmbitionsTests`
- Passed: `make xcode-build-for-testing BATCH=IOS26-T04A-B04-REPAIR5`
- Passed: `make xcode-focused-test BATCH=IOS26-T04A-B04-REPAIR5 TEST=AmbitionsTests`
- Passed after repair: `make xcode-focused-test BATCH=IOS26-T04A-B04-REPAIR2 TEST=AmbitionsUITests/AmbitionsUITests/testDemoTimeWorkspaceShowsBatch49CoreModules`
- Failed: `make xcode-focused-test BATCH=IOS26-T04A-B04-REPAIR3 TEST=AmbitionsUITests/AmbitionsUITests/testCapturePromotionOpensComposerWithSeededText`
- Passed: `git diff --check`

## UI failure evidence
- `Native/AmbitionsUITests/AmbitionsUITests.swift:414` - `testCapturePromotionOpensComposerWithSeededText` still cannot find the preview seeded capture in the rebuilt UI bundle.
- `Native/AmbitionsUITests/AmbitionsUITests.swift:516` - `testDemoTimeWorkspaceShowsBatch49CoreModules` was repaired to open the existing `LifeShape Field depth` disclosure before asserting deep Time modules and now passes when focused.

## Claim boundaries
- Do not claim verified accessibility, production readiness, or full UI-suite green.
- Do not claim all Life Context UI flows are complete; the UI suite still shows regressions.
- The batch is accepted Yellow because the remaining failed UI smoke is outside the Life Context controls and receipts scope. Do not claim full UI-suite Green until the Capture seed smoke is repaired.
