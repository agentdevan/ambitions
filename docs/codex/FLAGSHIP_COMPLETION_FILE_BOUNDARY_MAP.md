# Flagship Completion File Boundary Map
<!-- markdownlint-disable MD013 -->

Status: Active-scope planning truth for FCP01-FCP30.
Date: 2026-05-05

## Purpose

This map defines likely owner files, test files, preview files, dependencies, and boundary risks for FCP implementation. It is not permission to edit every listed file in one batch. Each FCP batch must select only the narrow files required for the selected object and must prove boundaries in its audit report.

## Universal Boundary Rules

- Do not edit production Swift in docs-only FCP batches.
- Do not edit route/raw-value/persistence/schema/import/export/widget/AppIntent files unless the selected batch explicitly allows it and CS gates pass.
- Do not edit dependencies, workflows, signing, entitlements, CI, or project generation config unless explicitly approved.
- Use `xcodegen generate` only when project generation may be affected.
- Prefer extraction before large feature-file growth.
- Files above 400 lines require review, above 700 lines require extraction plan, and above 1000 lines are Red unless a safer temporary boundary is proven.

## Cross-Surface Docs / Governance Owners

Likely files:

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/*fcp*report.md`

Forbidden in docs/planning batches:

- `Native/Ambitions/**/*.swift`
- `Sources/**/*.swift`
- `project.yml`
- `.github/workflows/**`
- persistence/schema files
- route/raw-value files
- entitlements/signing/config files

## Shared Design System Owners

Likely files:

- `Sources/Components/DynamicAdaptiveVisualPrimitives.swift`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Components/LoadingDegradedStatePrimitives.swift`
- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`
- `Sources/Previews/InteractionMotionHapticsPreviews.swift`
- `Sources/Previews/TopLevelSurfaceCompositionPreviews.swift`
- shared design-system tests under `Native/AmbitionsTests` or design-system test targets

Boundary risks:

- giant shared primitive files
- tint-only state changes instead of object anatomy
- preview-only success without product composition
- visual primitives claiming runtime AI/LDI behavior

Required evidence:

- focused design-system tests
- preview matrix
- Reduce Motion equivalents
- non-color meaning
- file-size review

## Today Owners

Likely files:

- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheetState.swift`
- `Native/Ambitions/Features/Today/TodayProofReceiptLedgerState.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`

FCP objects:

- Start Here Surface
- Reality Rail
- Step Detail
- Step Session
- Action Closure Diamond
- Recovery Loop
- Receipt Drawer integration

Boundary risks:

- Today becoming an agenda/task list
- Start Here remaining a card
- closure becoming shame/failure
- hidden plan mutation from Today
- file-size growth in Today panels

Required evidence:

- focused Today tests
- normal/tight/overloaded/private/stale/no-schedule/missing-duration/recovery/blocked previews
- VoiceOver summary tests where possible
- no route/raw-value breakage

## Goals Owners

Likely files:

- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- `Native/AmbitionsTests/Domain/ProofResourceGraphModelsTests.swift`

FCP objects:

- LifePath Thread
- MissionControlTimeSpine
- Proof Spine
- Goal alternate path / decision history
- Grow Into Goal integration

Boundary risks:

- Mission Control dashboard/grid
- LifePath card row
- proof as trophy/feed
- alternate path auto-reroute
- PM/OKR drift

Required evidence:

- focused Goals tests
- Mission Control spine preview states
- LifePath privacy/accessibility previews
- proof/source/freshness behavior

## Capture Owners

Likely files:

- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Domain/SmartAttachmentModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift`
- `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`

FCP objects:

- Capture Atmosphere Composer
- Capture Placement Shelf
- Placement Resolver / Correction Fold
- Grow Into Goal Seed Incubator
- Voice / motor capture accessibility

Boundary risks:

- Capture becoming inbox/feed/notes
- automatic goal creation
- hidden personalization/learning
- user-facing confidence percentages
- mic button claiming unsupported behavior

Required evidence:

- focused Capture tests
- empty/typed/ambiguous/private/error/corrected/decide-later previews
- route correction receipt behavior
- no hidden learning or auto-promotion copy

## Plan Owners

Likely files:

- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Features/Plan/PlanLifeShapeDrillDownPanel.swift`
- `Native/Ambitions/Features/Plan/PlanFoundationCards.swift`
- `Native/Ambitions/Domain/Planning/PlanningEvaluation.swift`
- `Native/Ambitions/Domain/Planning/DeterministicGoalPlanner.swift`
- `Native/Ambitions/Domain/Reschedule/RescheduleEngine.swift`
- Plan tests under `Native/AmbitionsTests`

FCP objects:

- LifeShape Contour Map
- Reflow Decision Fold
- Pressure Field
- Recovery Loop
- Availability Center integration

Boundary risks:

- calendar clone
- analytics chart/dashboard
- silent reflow/rearrangement
- protected time overwritten
- vacation/away treated as free time
- fake precision capacity math

Required evidence:

- focused Plan tests
- open/tight/overloaded/protected/vacation/late-start/no-calendar previews
- no calendar writes unless explicitly scoped and proved

## You / Profile Owners

Likely files:

- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- Profile view model/service files
- Profile tests under `Native/AmbitionsTests`
- You/Profile preview fixtures
- Memory / Trust / Personal Operating Constitution files where already present

FCP objects:

- Personal System Center
- Availability Center
- Memory Lens
- Appearance Studio
- Trust history / receipts
- Data / privacy controls

Boundary risks:

- generic settings dump
- diagnostics console
- ProfileScreen file-size growth
- unsupported memory/export/delete/sync/legal/privacy claims
- controls implying behavior not implemented

Required evidence:

- focused Profile tests
- setup incomplete/complete/private/denied/local-only/stale/unsaved-changes previews
- file extraction plan if large-file threshold hit
- trust/source/privacy copy scan

## Cross-Surface Proof / Review Owners

Likely files:

- Today receipt/proof files
- Goals proof/history files
- Capture receipt files
- Plan reflow receipt files
- You receipt history files
- shared TrustReceipt primitives
- shared proof/review projection helpers where created

FCP objects:

- Receipt Drawer
- Proof Spine
- Continuity Receipt Mesh
- Source Fold
- Review Required markers

Boundary risks:

- duplicated receipt islands
- activity feed dump
- analytics/log UI
- privacy leak across surfaces
- source stale state driving recommendations without review

Required evidence:

- tests for Capture to You receipt path
- Today to Goals proof path
- Plan to You reflow receipt path
- stale-source review path
- private proof redaction path

## Test Ownership Map

Each implementation batch must add/update tests in the closest owner target:

- Today: `Native/AmbitionsTests/Today/`
- Goals: `Native/AmbitionsTests/Goals/` and relevant domain tests
- Capture: `Native/AmbitionsTests/Captures/`, `Native/AmbitionsTests/Services/`
- Plan: Plan tests under `Native/AmbitionsTests/`
- You/Profile: Profile tests under `Native/AmbitionsTests/`
- Shared primitives: design-system/component tests or closest existing test target

## Preview Ownership Map

Every major object must have previews covering:

- normal
- loading
- empty
- degraded
- source stale
- private/sensitive
- blocked/waiting
- recovery
- overloaded/high pressure
- reduced motion
- accessibility Dynamic Type

Preview-only proof is Yellow unless focused tests also pass.

## Audit Report Ownership

Every FCP batch writes:

`docs/audits/fcpXX-<kebab-name>-report.md`

Each report must include:

- result
- selected batch
- files read
- files changed
- tests run
- validation result
- preview matrix status
- accessibility / reduced-motion status
- release-claim status
- drift scan status
- unresolved Yellow items
- rollback path
- next eligible batch
