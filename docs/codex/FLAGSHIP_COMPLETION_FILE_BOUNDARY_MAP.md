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

## FCP03 Object Ownership / Boundary Matrix

This matrix is the preliminary implementation-planning boundary for all 25
flagship objects. It does not authorize editing every listed file. Each future
batch must choose the smallest owner set, prove dependencies, and stop before
route/raw-value, persistence/schema, workflow/CI, entitlement/signing,
dependency, generated project, or release/platform claim edits unless the
selected prompt explicitly scopes them.

| # | Object | Owner | Likely files | Tests / previews | Dependencies and risk owner |
| ---: | --- | --- | --- | --- | --- |
| 1 | Start Here Surface / Hero Step Panel | Today | `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`, `DayRailViewState.swift`, `DayRailProjection.swift`, `TodayExecutionProjector.swift`, `TodayHeroStepSignaturePrimitives.swift`, `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift` | `Native/AmbitionsTests/Today/TodayViewModelTests.swift`, `TodayFreshGoalVisibilityTests.swift`, `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift` | Depends on SI05, SI10, PD02-PD04. Risk owner: Today plus Trust; stop on card/poster drift, confidence copy, or missing Step Detail/Session handoff. |
| 2 | Reality Rail / DayTimelineRail | Today | `TodayScreen.swift`, `TodayDayRailPanels.swift`, `DayRailViewState.swift`, `DayRailProjection.swift`, `TodayProofReceiptLedgerState.swift`, `TodayActionClosureSheetState.swift` | Today tests, `PreviewTodayScenarios.swift`, `SignatureInterfaceVisualQAPreviews.swift` | Depends on SI04, PD02-PD04, FCP05/FCP06 for mature integration. Risk owner: Today; stop on agenda/calendar/task-list posture. |
| 3 | Ambition Meridian Shell | App / shell | `Native/Ambitions/App/AppShellView.swift`, `AppMeridianShell.swift`, `AppTab.swift`, `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`, `Sources/Previews/SI03ShellNavigationPreviews.swift` | `Native/AmbitionsTests/App/AppShellNavigationTests.swift`, `AppShellChromeTests.swift`, `TopLevelSurfaceCompositionTests.swift` | Depends on SI03, SI17, FCP04. Risk owner: shell/navigation; route/tab changes require explicit scope. |
| 4 | LifePath View | Goals | `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`, `GoalComponents.swift`, `GoalsFeatureModels.swift`, `GoalLifePathSignaturePrimitives.swift`, goal path domain/projector files if already owner-scoped | `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`, `GoalExplainabilityProjectionTests.swift`, `Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift` | Depends on SI06, PD06-PD08, FCP10. Risk owner: Goals; stop on roadmap board, generic path cards, or private-path leak. |
| 5 | MissionControlTimeSpine / Mission Control Lanes | Goals | `GoalDetailScreen.swift`, `GoalMissionControlLanePrimitives.swift`, `GoalsFeatureModels.swift`, `GoalComponents.swift` | `GoalDetailStrategicPresentationTests.swift`, `GoalsOverviewBoardTests.swift`, `PreviewGoalsScenarios.swift` | Depends on SI07, PD05-PD08, FCP06. Risk owner: Goals; preserve Completed / Now / Friction / Next / Horizon and stop on grid/dashboard/PM-board drift. |
| 6 | Capture Atmosphere Composer | Capture | `Native/Ambitions/Features/Capture/CaptureScreen.swift`, `CaptureAtmosphereComposer.swift`, `CaptureDraftRoutePreviewCard.swift`, `CaptureViewModel.swift` | `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`, `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` | Depends on SI09, PD09, FCP18. Risk owner: Capture; text-first rule and no inbox/feed/notes posture are hard gates. |
| 7 | Placement Resolver / Capture Correction | Capture | `CaptureDraftRoutePreviewCard.swift`, `CaptureViewModel.swift`, `Native/Ambitions/Domain/SmartAttachmentModels.swift`, `GoalEngine/GoalEngineIntake.swift` | `CapturePlacementReviewStateTests.swift`, `CaptureViewModelTests.swift`, `SmartAttachmentServiceTests.swift` | Depends on PD09-PD11, FCP18. Risk owner: Capture plus Goal intake; stop on hidden learning, auto-goal creation, or confidence percentages. |
| 8 | LifeShape Map | Plan | `Native/Ambitions/Features/Plan/PlanScreen.swift`, `PlanLifeShapeTimeCapacityMap.swift`, `PlanLifeShapeDrillDownPanel.swift`, `PlanFoundationCards.swift` | `Native/AmbitionsTests/Plan/PlanFeatureServiceTests.swift`, `Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift` | Depends on SI08, PD14, DAV05. Risk owner: Plan; stop on calendar grid, bar chart as primary object, or fake precision. |
| 9 | Reflow Decision | Plan | `PlanLifeShapeDrillDownPanel.swift`, `PlanFoundationCards.swift`, `Native/Ambitions/Domain/Planning/PlanningEvaluation.swift`, `Native/Ambitions/Domain/Reschedule/RescheduleEngine.swift` | `PlanFeatureServiceTests.swift`, `RescheduleEngineTests.swift`, `PreviewPlanScenarios.swift` | Depends on PD12, FCP14. Risk owner: Plan/domain; stop on silent rearrangement or unscoped calendar writes. |
| 10 | Pressure / Recovery Review | Plan / Today | Plan LifeShape files, Today closure/recovery files, `Native/Ambitions/Domain/ExecutionResilience*` service/model files if owner-scoped | `PlanFeatureServiceTests.swift`, `TodayViewModelTests.swift`, `ExecutionResilienceProjectorTests.swift` | Depends on PD13, PD04, FCP14-FCP15. Risk owner: Plan/Today; stop on shame, failure, productivity, or fake precision framing. |
| 11 | Trust Receipt Layer / EvidenceLabel / ProofPulse | Shared trust | `Sources/Components/TrustReceiptLayerPrimitives.swift`, `DynamicAdaptiveVisualPrimitives.swift`, Today/Goal/Plan/Capture receipt integration files as selected | `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`, `Sources/Previews/TrustReceiptLayerPreviews.swift` | Depends on SI10, DAV09, EB17/EB18. Risk owner: shared trust; stop on toast-only receipt or source-less claim. |
| 12 | Evidence Ledger / Proof Spine | Goals / shared trust | Goals proof/history files, `TodayProofReceiptLedgerState.swift`, shared TrustReceipt primitives, proof/resource domain tests when scoped | `ProofResourceGraphModelsTests.swift`, `GoalDetailStrategicPresentationTests.swift`, Trust receipt previews | Depends on FCP06, FCP10-FCP11, PD07. Risk owner: Goals/trust; stop on trophy/feed/analytics posture. |
| 13 | Action Closure Diamond | Today / shared closure | `TodayActionClosureSheet.swift`, `TodayActionClosureSheetState.swift`, `TodayDayRailPanels.swift`, Action Closure domain/receipt files if scoped | `TodayViewModelTests.swift`, `ActionClosureReceiptModelsTests.swift`, `PreviewTodayScenarios.swift` | Depends on PD04, FCP16, FCP06. Risk owner: Today/closure; stop on binary done/failed or silent reschedule. |
| 14 | Personal System Center | You / Profile | `Native/Ambitions/Features/Profile/ProfileScreen.swift`, `ProfileFeatureService.swift`, `ProfileTrustHistoryCenterCard.swift`, `ProfileTrustHistoryProjector.swift`, shared Personal System Center primitives | `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`, `Sources/Previews/PersonalSystemCenterPreviews.swift` | Depends on SI11, PD15, EB14-EB18. Risk owner: You/Profile; stop on settings dump, diagnostics console, or unsupported memory/export/delete/sync claims. |
| 15 | Appearance Studio | You / design system | Profile Appearance rows, `Sources/Theme/AmbitionTheme.swift` only with explicit design-token scope, PersonalSystemCenter previews, appearance tests | `Native/AmbitionsTests/App/AppearancePreferenceTests.swift`, `PersonalSystemCenterPreviews.swift` | Depends on FCP22 and design-token approval. Risk owner: You/design system; stop on full theming, custom picker, semantic recolor, or token edit without scope. |
| 16 | Loading / Empty / Degraded States | Shared design system | `Sources/Components/LoadingDegradedStatePrimitives.swift`, surface-specific empty/degraded owners, preview fixtures | `LoadingDegradedStateDesignSystemTests.swift`, `Sources/Previews/LoadingDegradedStatePreviews.swift` | Depends on SI13, FCP01-FCP04. Risk owner: shared UI; stop on generic error cards or fake progress. |
| 17 | Iconography / Status Grammar | Shared design system | `Sources/Components/IconographyStatus*` where present, `Sources/Previews/IconographyStatusPreviews.swift`, surface status rows as selected | `IconographyStatusDesignSystemTests.swift`, accessibility/adaptive tests | Depends on SI14, FCP25. Risk owner: shared UI/accessibility; stop on color-only meaning or arbitrary symbol drift. |
| 18 | Motion / Haptics System | Shared design system | `Sources/Components/InteractionMotionHaptics*` where present, `DynamicAdaptiveVisualPrimitives.swift`, motion previews | `InteractionMotionHapticsDesignSystemTests.swift`, `Sources/Previews/InteractionMotionHapticsPreviews.swift` | Depends on SI12, DAV10, FCP05-FCP08. Risk owner: shared UI; stop on decorative or motion-only meaning. |
| 19 | Dynamic Adaptive Visual Primitives | Shared design system | `Sources/Components/DynamicAdaptiveVisualPrimitives.swift`, `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`, object-specific integrations | Dynamic adaptive visual tests/previews, `SignatureInterfaceVisualQAFixtureTests.swift` | Depends on DAV01-DAV15, FCP09/FCP25/FCP26. Risk owner: design system; stop on tint-only state changes or ambience-as-product. |
| 20 | Memory Lens / External Brain visual layer | You / memory | Profile memory/trust files, Memory Lens service/report files, `Native/AmbitionsTests/App/MemoryLensServiceTests.swift` owners | `MemoryLensServiceTests.swift`, `ProfileFeatureServiceTests.swift`, Personal System Center previews | Depends on EB memory/trust evidence, FCP22. Risk owner: You/memory; stop on creepy/omniscient copy or unsupported durable memory/sync/export/delete claims. |
| 21 | Step Detail | Today | Today Step Detail/local detail files where present, `TodayDayRailPanels.swift`, `DayRailProjection.swift` | `TodayViewModelTests.swift`, `PreviewTodayScenarios.swift` | Depends on PD02, FCP05/FCP21. Risk owner: Today; stop on generic task-detail modal or unsupported Start now behavior. |
| 22 | Step Session | Today | Today Step Session/local session files where present, `TodayDayRailPanels.swift`, `DayRailViewState.swift` | `TodayViewModelTests.swift`, Step Session preview scenarios | Depends on PD03, FCP05/FCP21. Risk owner: Today; stop on Pomodoro/focus gamification or timer-first posture. |
| 23 | Grow into Goal | Capture / Goals | Capture placement/correction files, Goal creation/intake files, GoalEngine intake/domain files | `CaptureViewModelTests.swift`, `CreateGoalViewModelTests.swift`, `GoalEnginePlannerTests.swift` | Depends on PD11, FCP19. Risk owner: Capture/Goals; stop on automatic goal creation or project wizard posture. |
| 24 | Cross-surface proof/review integration | Shared trust / all surfaces | Today proof receipt, Goals proof/history, Capture receipt, Plan reflow receipt, You trust history, shared receipt/proof primitives | Today, Goals, Capture, Plan, Profile, TrustReceipt tests and continuity scenarios | Depends on PD17, FCP06/FCP12, all owning surfaces. Risk owner: shared trust; stop on activity feed, duplicated islands, or privacy leak. |
| 25 | Schedule / Availability / Defaults depth | You / Plan | Profile planning defaults/schedule files, Plan availability files, safe automation policy/domain files | `ProfileFeatureServiceTests.swift`, `PlanFeatureServiceTests.swift`, `SafeAutomationPolicyModelsTests.swift` | Depends on PD16, EB21/EB22, FCP17. Risk owner: You/Plan; stop on auto-scheduler black box, calendar clone, or vacation/free-time assumption. |

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

- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Capture/CaptureViewModel.swift`
- `Native/Ambitions/Domain/SmartAttachmentModels.swift`
- `Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
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
- Capture: `Native/AmbitionsTests/Capture/`, `Native/AmbitionsTests/Services/`
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
