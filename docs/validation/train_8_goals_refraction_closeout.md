# Train 8 - Goals Refraction Closeout

Status: Yellow  
Branch: main  
Base SHA: `004ed9affabac5ed6bfa5c1ae4c07c6cb7e97127`  
Remote main at start: `004ed9affabac5ed6bfa5c1ae4c07c6cb7e97127`

## Summary

Train 8 moved Goals toward the canon architecture tree by extracting the first-viewport Constellation Atlas into `DesignSystem/ProductObjects`, adding explicit Goals projection/stage-scene source files, and replacing deleted primitive-registry test authority with current architecture/source-lens tests.

This closeout is Yellow, not Green, because strict tree enforcement still has known residual debt: Constellation-specific projection copy remains partly in `GoalsFeatureModels`, internal `MissionControlTimeSpine` type names remain as implementation names, and this train did not fully split all large Goals owner files.

## Files Changed

Created:

- `Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView.swift`
- `Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift`
- `Native/Ambitions/Projection/SurfaceLenses/GoalsLens.swift`
- `docs/validation/train_8_goals_refraction_closeout.md`

Modified:

- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Domain/OneStepGoalModels.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Services/OneStepGoalProjector.swift`
- `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- `Native/AmbitionsTests/Goals/GoalsConstellationAtlasReconstructionTests.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`

Deleted:

- `GoalsConstellationAtlasStage` implementation was removed from `GoalComponents.swift` and replaced by `ConstellationAtlasView`.

## Mutation Proof

- `GoalsScreen` now composes `ConstellationAtlasView` for loaded Goals state.
- `ConstellationAtlasView` uses `GoalsLens.makeStageScene(for:)` while exposing plain VoiceOver copy through `overview.constellationAtlasAccessibilityValue`.
- `GoalsLens` and `GoalsStageScene` encode Constellation Atlas, Today relationship, Source/Proof/Receipt order, and inspection summary checks.
- User-facing/accessibility Goals copy no longer says standalone Task for One-Step Goals.
- Dynamic Type shell header now wraps the Goals product object name instead of truncating it.

## Validation

- `xcodebuild -version`: Xcode 26.6, build 17F113.
- `xcodegen generate`: passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch TRAIN_08_GOALS_FINAL_BUILD`: passed, `Test Build Succeeded`.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_XCODE266_COPY_FIX_TESTS --test AmbitionsTests/GoalsOverviewAtlasTests`: passed, 17 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_XCODE266_COPY_FIX_TESTS --test AmbitionsTests/GoalDetailStrategicPresentationTests`: passed, 22 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_XCODE266_COPY_FIX_TESTS --test AmbitionsTests/OneStepGoalProjectorTests`: passed, 5 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_XCODE266_COPY_FIX_TESTS --test AmbitionsTests/GoalsObjectStagePrimitiveTests`: passed, 4 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_XCODE266_COPY_FIX_TESTS --test AmbitionsTests/GoalsConstellationAtlasReconstructionTests`: passed, 3 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_HEADER_WRAP_TESTS --test AmbitionsTests/AppShellChromeTests`: passed, 11 tests.
- `scripts/ambitions-xcode-test-focused.sh --batch TRAIN_08_GOALS_HEADER_WRAP_SCREENSHOTS --test AmbitionsUITests/AmbitionsUITests/testAMB963GoalsReconstructionScreenshotMatrix`: passed, 1 UI test.
- `git diff --check`: passed.

## Screenshot Review

Visually reviewed:

- `.codex/xcode-summaries/TRAIN_08_GOALS_HEADER_WRAP_SCREENSHOTS/20260619T040100Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-54400-6567/extract/screenshots/amb-963-goals-default_0_B09E774D-EF6A-45E8-90B2-B3DFE7352871.png`
- `.codex/xcode-summaries/TRAIN_08_GOALS_HEADER_WRAP_SCREENSHOTS/20260619T040100Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-54400-6567/extract/screenshots/amb-963-goals-selected-life-area_0_3DEA9ED4-E395-4302-ACA2-892622B34DD1.png`
- `.codex/xcode-summaries/TRAIN_08_GOALS_HEADER_WRAP_SCREENSHOTS/20260619T040100Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-54400-6567/extract/screenshots/amb-963-goals-proof-source-visible_0_9A47D201-2DEC-4951-A435-82F980FA3EC5.png`
- `.codex/xcode-summaries/TRAIN_08_GOALS_HEADER_WRAP_SCREENSHOTS/20260619T040100Z-AmbitionsUITests-AmbitionsUITests-testAMB963GoalsReconstructionScreenshotMatrix-54400-6567/extract/screenshots/amb-963-goals-large-dynamic-type_0_05F364BF-9688-4824-BD3E-1F0B6866F2C3.png`

Result: default, selected Life Area, proof/source visible, and large Dynamic Type states render without the original atlas-body truncation. The large Dynamic Type shell header wraps `Constellation Atlas` instead of ellipsizing it.

## Accessibility Notes

- Stage accessibility value uses plain Goals/Direction copy instead of internal architecture language.
- One-Step Goals accessibility copy avoids generic Task framing.
- Goal-detail lane hints no longer expose `MissionControlTimeSpine` to VoiceOver.
- Dynamic Type screenshot was visually reviewed after repair.

## Forbidden-Language Result

Focused scan over Train 8 files for Task/Mission Control/dashboard/debug/shame/AI-wrapper language found only internal type/test names and explicit absence assertions:

- `MissionControlTimeSpine` remains as an internal implementation type and test fixture name.
- `dashboard metrics grid` appears only in a negative assertion.

No remaining user-facing/accessibility Train 8 copy uses standalone Task, Goal Mission Control, dashboard, best next move, or Begin Focus.

## Known Risks

- Yellow: Constellation projection copy is still partly owned by `GoalsFeatureModels`; a later repair/subtrain should move more Constellation-specific projection text into `Projection/SurfaceLenses`.
- Yellow: internal `MissionControlTimeSpine` type names remain and should be renamed in a future Goals/detail architecture cleanup if strict tree enforcement requires no internal Mission Control vocabulary.
- Yellow: large Goals source files remain; this train extracted the first-viewport object but did not complete a full Goals file-size refactor.
- The build wrapper prints `FAILURE_CLASS=unknown` after successful build-for-testing runs; the decisive Xcode output was `Test Build Succeeded`.

## Rollback Plan

Revert the Train 8 commit. This restores `GoalsConstellationAtlasStage` in `GoalComponents.swift`, removes `GoalsLens`/`GoalsStageScene`/`ConstellationAtlasView`, and returns shell header wrapping and One-Step Goal copy to the prior state.
