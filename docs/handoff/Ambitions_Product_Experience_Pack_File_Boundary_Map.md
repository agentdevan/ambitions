# Ambitions Product Experience Pack File Boundary Map

Status: Batch 1A preliminary map hardened by Batch 1B/1C; planning-only
Date: 2026-05-04

## Purpose

This boundary map classifies files and directories for future Product
Experience Pack work. It is not an implementation permission slip. Product
Depth remains blocked until the exact approval phrase in the Product Depth
train manifest is satisfied.

## A. Green Inspect-Only Files

These files are safe to read for future planning. They should not be edited by
early Product Experience Pack batches unless a later prompt explicitly widens
scope and names the intended change.

- `README.md`
- `AGENTS.md`
- `docs/README.md`
- `docs/AGENTS.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/batch-trains/SI01_SI18_SIGNATURE_INTERFACE_IMPLEMENTATION_TRAIN.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/canon/PXOS_Copy_Language_And_Explanation_System.md`
- `docs/canon/PXOS_Accessibility_Cognitive_Load_And_Emotional_Safety.md`
- `docs/canon/PXOS_Today_Experience_Canon.md`
- `docs/canon/PXOS_Goals_Mission_Control_Canon.md`
- `docs/canon/PXOS_Capture_Experience_Canon.md`
- `docs/canon/PXOS_Plan_Life_Shape_Canon.md`
- `docs/canon/PXOS_You_Personal_System_Center_Canon.md`
- `docs/canon/PXOS_Trust_Proof_Receipts_Canon.md`
- `docs/canon/PXOS_Action_Closure_Recovery_Canon.md`
- `docs/canon/PXOS_User_Facing_AI_Trust_And_Recommendation_Expression.md`
- `docs/canon/PXOS_Release_Safe_Product_Messaging.md`
- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AppShellPresentationMode.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Sources/Theme/AmbitionTheme.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Features/Plan/PlanReflowDecisionCard.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Domain/**`

## B. Yellow Docs-Only Editable Files

These files are appropriate places for Batch 1-style planning, handoff, audit,
or source-truth boundary artifacts when the task stays docs-only.

- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`
- `docs/audits/ambitions-product-experience-pack-batch-1a-boundary-report.md`
- `docs/audits/ambitions-product-experience-pack-batch-1b-reconciliation-report.md`
- `docs/audits/ambitions-product-experience-pack-batch-1c-copy-boundary-scan.md`
- `docs/audits/*product-experience*report.md`
- `docs/codex/CONTEXT_INDEX.md` only if a later prompt asks to index the
  artifact.
- `docs/codex/BATCH_REGISTRY.md` only if a later prompt explicitly updates
  operational status.

## C. Yellow Approval-Gated Future Implementation Candidates

These are candidate owner files for future implementation only after Product
Depth or another explicit implementation train is approved and the relevant
gates pass. They are not implementation-ready from Batch 1B evidence.

- Today / Reality Rail:
  - `Native/Ambitions/Features/Today/TodayScreen.swift`
  - `Native/Ambitions/Features/Today/TodayPanels.swift`
  - `Native/Ambitions/Features/Today/TodayDayRailSignaturePrimitives.swift`
  - `Native/Ambitions/Features/Today/TodayHeroStepSignaturePrimitives.swift`
  - `Native/Ambitions/Features/Today/DayRailStepDetailState.swift`
  - `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
  - `Native/Ambitions/Features/Today/TodayViewModel.swift`
- Goals / LifePath / Mission Control:
  - `Native/Ambitions/Features/Goals/GoalsScreen.swift`
  - `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
  - `Native/Ambitions/Features/Goals/GoalLifePathSignaturePrimitives.swift`
  - `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
  - `Native/Ambitions/Features/Goals/GoalComponents.swift`
  - `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- Capture / composer / placement:
  - `Native/Ambitions/Features/Captures/CapturesScreen.swift`
  - `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
  - `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
  - `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
  - `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
  - `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- Plan / LifeShape / Reflow:
  - `Native/Ambitions/Features/Plan/PlanScreen.swift`
  - `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
  - `Native/Ambitions/Features/Plan/PlanLifeSuiteState.swift`
  - `Native/Ambitions/Features/Plan/PlanReflowDecisionCard.swift`
  - `Native/Ambitions/Features/Plan/PlanReflowDecisionState.swift`
  - `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- You / Personal System Center / Appearance Studio:
  - `Native/Ambitions/Features/Profile/ProfileScreen.swift`
  - `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
  - `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
  - `Native/Ambitions/Features/Profile/ProfileViewModel.swift`
- Shared UI marks and primitives:
  - `Sources/Components/PersonalSystemCenterPrimitives.swift`
  - `Sources/Components/TrustReceiptLayerPrimitives.swift`
  - `Sources/Components/LoadingDegradedStatePrimitives.swift`
  - `Sources/Components/IconographyStatusPrimitives.swift`
  - `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
  - `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`

## D. Red Forbidden Early Implementation Files

These files and directories should not be edited in early Product Experience
Pack planning or source-truth reconciliation batches.

- `Native/Ambitions/Persistence/SwiftDataModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/Ambitions/Persistence/SwiftDataStore.swift`
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/KnowledgeIngestionService.swift`
- `Native/Ambitions/Services/KnowledgeProviderBoundary.swift`
- `Native/Ambitions/Services/RecommendationExplanationAdapter.swift`
- `Native/Ambitions/Services/MemoryLensService.swift`
- `Native/Ambitions/Services/*Goal*Service.swift`
- `Native/Ambitions/AppIntents/**`
- `Native/AmbitionsWidgetExtension/**`
- `AppUI/Sources/**` unless a widget/shared UI batch explicitly scopes it.
- `Native/Ambitions/ExternalSnapshots/**`
- `Native/Ambitions/Resources/Assets.xcassets/**`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/Ambitions/Support/Info.plist`
- `Native/Ambitions/Features/**/__Snapshots__/**`
- `Native/AmbitionsTests/**` unless a later test-only batch explicitly scopes it.
- `Native/AmbitionsUITests/**` unless a later UI-test batch explicitly scopes it.
- Preview and fixture files unless the batch is explicitly a preview/fixture
  evidence batch.

## E. Red Generated / Config-Sensitive Files

These files are generated, generated-adjacent, or config-sensitive. Do not edit
casually.

- `Ambitions.xcodeproj/**`
- `output/**`
- `DerivedData/**`
- `*.xcresult`
- `.swiftpm/**`
- `.github/workflows/**`
- `project.yml`
- `Package.swift`
- `Brewfile`
- `skills-lock.json`
- `Native/Ambitions/Resources/Assets.xcassets/AppIcon.appiconset/**`
- `Native/Ambitions/Resources/Assets.xcassets/AccentColor.colorset/**`
- `Native/Ambitions/Support/Info.plist`
- `Native/Ambitions/Support/Ambitions.entitlements`

## F. Stop / User-Decision Files

These files may be legitimate future targets, but only with explicit scope,
owner gates, focused validation, and user decision when the change would affect
source truth, routing, persistence, config, or runtime behavior.

- Shell/navigation:
  - `Native/Ambitions/App/AmbitionsRootView.swift`
  - `Native/Ambitions/App/AppTab.swift`
  - `Native/Ambitions/App/AppNavigation.swift`
  - `Native/Ambitions/App/AppShellView.swift`
  - `Native/Ambitions/App/AppMeridianShell.swift`
  - `Native/Ambitions/App/AppShellPresentationMode.swift`
  - `Native/Ambitions/App/ShellCommandRouter.swift`
- Theme/accent:
  - `Sources/Theme/AmbitionTheme.swift`
  - `Native/Ambitions/Persistence/PersistenceContracts.swift`
  - `Native/Ambitions/Persistence/AppPreferencesStore.swift`
  - `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- Goals Mission Control:
  - `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
  - `Native/Ambitions/Features/Goals/GoalComponents.swift`
  - `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
  - `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- Capture placement:
  - `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
  - `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
  - `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
  - `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- Plan LifeShape:
  - `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
  - `Native/Ambitions/Features/Plan/PlanReflowDecisionCard.swift`
  - `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- You / Appearance Studio / trust:
  - `Native/Ambitions/Features/Profile/ProfileScreen.swift`
  - `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
  - `Native/Ambitions/Features/Profile/ProfileViewModel.swift`
- Routes, external surfaces, and compatibility:
  - `Native/Ambitions/App/AppExternalRouting.swift`
  - `Native/Ambitions/App/AppIntentLaunchRouter.swift`
  - `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
  - `Native/Ambitions/ExternalSnapshots/**`
  - `Native/Ambitions/Persistence/LegacyImportService.swift`
  - `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- Product Depth / global train state:
  - `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
  - `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
  - `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
  - `.codex/reports/current-run-state.md`
  - `.codex/reports/current-batch-train-state.md`
- Persistence / sync / auth / network / AI / LDI:
  - `Native/Ambitions/Persistence/**`
  - `Native/Ambitions/Services/**`
  - `Native/Ambitions/Runtime/**`
  - `Native/Ambitions/Domain/**` when changing contracts, source semantics, or
    model/runtime boundaries.
- CI/config/project:
  - `.github/workflows/**`
  - `project.yml`
  - `Package.swift`
- Tests/previews/fixtures:
  - `Native/AmbitionsTests/**`
  - `Native/AmbitionsUITests/**`
  - Preview and fixture files when edits would update asserted product truth.

## Copy-Boundary Categories

These categories come from Batch 1C and must be used before any future copy
remediation:

- Green allowed preservation:
  - Technical enum cases, raw values, route compatibility values, migration
    labels, validation pass/fail language, and historical audit truth.
- Yellow user-facing inventory candidates:
  - Strings in `Native/Ambitions/Features/**`, `Sources/Components/**`,
    `Native/Ambitions/ExternalSnapshots/**`, and source-derived UI models that
    may render visible copy or spoken labels.
- Yellow test/fixture/preview candidates:
  - `Native/Ambitions/PreviewSupport/**`, `Sources/Previews/**`,
    `Native/AmbitionsTests/**`, and `Native/AmbitionsUITests/**` when the string
    is used as screenshot, preview, UI, or accessibility evidence.
- Red forbidden bulk changes:
  - Broad renames of `AppTab` compatibility cases, `Profile` owner names,
    `Insights` routes, `Habits` routes/models, `.failed` async states, receipt
    raw values, stale/source states, confidence/score domain models, or external
    snapshot contracts without migration proof.
- Stop/user-decision copy files:
  - Navigation labels, tab labels, onboarding copy, receipts, source/privacy
    marks, external snapshot copy, VoiceOver labels, and trust/privacy copy when
    the change could alter source-truth semantics.

Future copy remediation must not treat internal naming as automatic copy debt.
Any source edit touching compatibility enums/routes/raw values requires explicit
scope, tests, and migration or compatibility evidence.

## Validation Scripts / Commands

Commands found in repo docs/scripts during Batch 0 and Batch 1A:

- Status and diff:
  - `git status --short`
  - `git diff --check`
- Docs and gate checks:
  - `scripts/run-doc-qa.sh || true`
  - `scripts/batch-train-gate-check.sh || true`
  - `scripts/changed-file-boundary-check.sh`
  - `scripts/release-claim-safety-scan.sh`
  - `scripts/canon-language-drift-scan.sh`
  - `scripts/no-unsupported-ai-claim-scan.sh`
- Product experience / SI / accessibility scans:
  - `scripts/pxeq-ui-batch-readiness-gate.sh`
  - `scripts/si-readiness-gate.sh`
  - `scripts/si-preview-coverage-scan.sh`
  - `scripts/si-accessibility-scan.sh`
  - `scripts/si-motion-reduce-motion-scan.sh`
  - `scripts/sig-no-generic-drift-scan.sh`
- Native build/test, not needed for this docs-only batch:
  - `xcodegen generate`
  - `scripts/build-local.sh`
  - `scripts/test-local.sh`
  - documented `xcodebuild` unit/UI/archive commands in
    `docs/native-build-and-release.md`.

No dedicated canonical formatting command was found beyond setup-installed
`swiftformat` / `swiftlint` tooling and docs QA. Do not invent a formatting
gate for Product Experience Pack work.

## Boundary Recommendation

The next safe docs action is Batch 1D source-truth packet assembly and
readiness gate. It should stay docs-only and assemble Batch 0 through Batch 1C
evidence without editing app code, theme tokens, navigation, persistence,
runtime, CI, tests, previews, fixtures, or generated files.
