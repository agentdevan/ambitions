# Build Graph Inventory

Status: SCG-002 inventory artifact only. This is not senior-readiness proof, build proof, runtime proof, visual proof, accessibility proof, privacy approval, release readiness, file review, or production repair.

## Scope

- Issue: AMB-1285 / SCG-002
- Branch: `main`
- Commit: `6e93e9cdb680334dca344326d179d9a44a8b5299`
- Production behavior changed: No
- Production repair started: No
- SCG-003 / SCG-004 started: No

## Evidence Sources

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
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `project.yml`
- `Package.swift`
- `Packages/AmbitionsExperienceKernel/Package.swift`
- `Ambitions.xcodeproj/project.pbxproj (generated local file, inspected only)`
- `git ls-files`
- `filesystem generated-state inspection`

## Target Model

| Target | Source authority | Classification role |
|---|---|---|
| Ambitions | project.yml sources/resources/settings | app target / active production and app resources |
| AmbitionsWidgetExtension | project.yml sources/settings | widget extension active production |
| AmbitionsShareExtension | project.yml sources/settings | share extension active production |
| AmbitionsTests | project.yml sources | active test |
| AmbitionsUITests | project.yml sources | active test |
| AmbitionsDesignSystem | Package.swift path: Sources | package active production, with preview/generated flags where applicable |
| AmbitionsWidgetUI | Package.swift path: AppUI/Sources | package active production, with preview flags where applicable |
| AmbitionsExperienceKernel | Packages/AmbitionsExperienceKernel/Package.swift | nested package active production |
| AmbitionsExperienceKernelTests | Packages/AmbitionsExperienceKernel/Package.swift | nested package active test |

## Summary

- Inventory entries: 4950
- Target-included/declaration entries represented: 1662
- Classification counts: `{'active production': 1222, 'active test': 362, 'doc': 158, 'excluded': 138, 'fixture': 72, 'generated': 2827, 'legacy': 4, 'preview-only': 44, 'script': 121, 'unknown': 2}`
- Risk counts: `{'Green': 2050, 'Yellow': 2900}`
- Generated Xcode project present: `True`; tracked: `False`

## Target Membership Counts

| Membership source | Entry count |
|---|---:|
| `Ambitions resources` | 22 |
| `Ambitions source/config` | 1121 |
| `Ambitions target config` | 2 |
| `AmbitionsDesignSystem package target` | 112 |
| `AmbitionsExperienceKernel package target` | 15 |
| `AmbitionsExperienceKernel processed resource` | 7 |
| `AmbitionsExperienceKernelTests package target` | 1 |
| `AmbitionsShareExtension shared source` | 6 |
| `AmbitionsShareExtension source/config` | 2 |
| `AmbitionsShareExtension target config` | 2 |
| `AmbitionsTests source/config` | 361 |
| `AmbitionsUITests source/config` | 5 |
| `AmbitionsWidgetExtension shared source` | 8 |
| `AmbitionsWidgetExtension source/config` | 3 |
| `AmbitionsWidgetExtension target config` | 2 |
| `AmbitionsWidgetUI package target` | 7 |

## Flagged Inventory Findings

### Red

No remaining Red build-graph inventory findings after SCG-002A.

Resolved finding `SCG-BG-001`: `Packages/AmbitionsExperienceKernel/Package.swift` declares `Resources/Tokens`, `Resources/Manifests`, and excludes `Resources/AmbitionsExperienceTokens.xcassets`. SwiftPM resolves those paths relative to target path `Sources/AmbitionsExperienceKernel`, not the package root. `swift package describe --type json` verified `Resources/Tokens/tokens.json` and `Resources/Manifests/*.json` as processed resources, and filesystem inspection verified `Sources/AmbitionsExperienceKernel/Resources/AmbitionsExperienceTokens.xcassets` exists and is excluded.

### Yellow

- Preview-only files with target membership require later SCG review before senior-readiness can be claimed.
- Fixture-named files with production target membership require later SCG review before senior-readiness can be claimed.
- Generated Swift files without a retained generator/source proof are flagged for follow-up; no repair was started.
- Root `assets/` files and nested package Codex/report material are tracked but not target-included; classified as legacy/doc/generated-support depending on path.

## Preview / Fixture / Generated Target-Included Paths

- Preview-only target-included count: 42
  - `AppUI/Sources/WidgetPreviews.swift` -> AmbitionsWidgetUI package target (Package.swift path: AppUI/Sources)
  - `Native/Ambitions/Composer/Capture/CaptureRoutingPreview.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/SmartAttachmentPlacementPreview.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Persistence/PreviewCaptureRepository.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Time/PreviewClock.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/AppDeepLinkPreviewRouter.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/CaptureAtmosphereComposerPreviews.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/CaptureComposerPreviews.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/PreviewTimeRitualScenarios.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/StubGoalsService.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/StubTodayService.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+06-makeAtlasPreview.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Quality/ShellPreviewMatrix.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Surfaces/You/YouScreen+09-YouPreviewSwatchSurface.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift` -> AmbitionsTests source/config (project.yml sources: Native/AmbitionsTests)
  - `Sources/Previews/AFI13VisualQACatalog.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/ComponentPreviewGallery+Density.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/ComponentPreviewGallery+RichPanels.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/ComponentPreviewModels.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/ComponentPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/CoreReusableInteractionPrimitivePreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/DesignSystemPreviewGalleryPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/DynamicAdaptiveVisualPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/FE09ComponentSystemPreviewMatrix.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/IconographyStatusPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/InteractionMotionHapticsPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/LoadingDegradedStatePreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/PersonalSystemCenterPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/RealityMeridianRichnessPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/RealityMeridianTemporalPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/RootDestinationIdentityPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI03ShellNavigationPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI16PreviewSurfaceCoverageRow.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI16VisualQAStateFamily.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SemanticDesignTokenGallery.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/ShellChromeTrustPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/TopLevelSurfaceCompositionPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/TrustReceiptLayerPreviews.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
- Fixture target-included count: 18
  - `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+02-teenPortfolioLaunchWithGuardianTransport.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+03-makerResidencyApplicationPathway.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+04-cityWorkshopLaunchWithoutEquipment.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/Ambitions/Quality/LifeShapeFixtureAudit.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions)
  - `Native/AmbitionsTests/App/ExternalBrainPreviewFixturesTests.swift` -> AmbitionsTests source/config (project.yml sources: Native/AmbitionsTests)
  - `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift` -> AmbitionsTests source/config (project.yml sources: Native/AmbitionsTests)
  - `Native/AmbitionsTests/Domain/SourceAtlasCoverageRuntimeFixtureModelsTests.swift` -> AmbitionsTests source/config (project.yml sources: Native/AmbitionsTests)
  - `Native/AmbitionsTests/Services/LargeStoreFixtureGeneratorTests.swift` -> AmbitionsTests source/config (project.yml sources: Native/AmbitionsTests)
  - `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsPreviewFixtures.swift` -> AmbitionsExperienceKernel package target (Packages/AmbitionsExperienceKernel/Package.swift)
  - `Sources/Previews/AmbitionsCanonPreviewFixtureCatalog.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI16PreviewFixtureCatalog.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI16VisualQAFixture.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
  - `Sources/Previews/SI16VisualQAFixtureSnapshotCard.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources)
- Generated target-included count: 8
  - `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsColorToken.generated.swift` -> AmbitionsExperienceKernel package target (Packages/AmbitionsExperienceKernel/Package.swift); source: Kernel token source/generator not found during SCG-002 inspection.
  - `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsGeneratedAssetNames.swift` -> AmbitionsExperienceKernel package target (Packages/AmbitionsExperienceKernel/Package.swift); source: Kernel asset/resource generation source not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionObjectTokens.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens/objects/*.tokens.json source inferred; retained generator script not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionStateTokens.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens/states/*.tokens.json source inferred; retained generator script not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionTokens.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens/*.tokens.json source inferred; retained generator script not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionsFrontendAuthority.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens and semantic authority source inferred; retained generator script not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionsRecipeID.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens and semantic authority source inferred; retained generator script not found during SCG-002 inspection.
  - `Sources/Theme/AmbitionsSurfaceID.generated.swift` -> AmbitionsDesignSystem package target (Package.swift path: Sources); source: DesignTokens and semantic authority source inferred; retained generator script not found during SCG-002 inspection.

## Shared Multi-Target Files

- Count: 9
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalObjectReopeningProjector.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceActionPayloads.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceContractModels.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceControlContracts.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/NextStepActivityAttributes.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsWidgetExtension shared source (project.yml explicit file)
- `Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift` -> Ambitions source/config (project.yml sources: Native/Ambitions), AmbitionsShareExtension shared source (project.yml explicit file), AmbitionsWidgetExtension shared source (project.yml explicit file)

## Excluded-But-Important Rationale

- `DesignTokens/accessibility.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/component.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/foundations.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/haptics.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/motion.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/objects/atmosphere-composer.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/objects/constellation-atlas.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/objects/lifeshape-field.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/objects/reality-meridian.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/objects/user-system-profile.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/semantic.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/states/closure.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/states/proof.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/states/protected-time.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/states/recovery.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `DesignTokens/states/source-freshness.tokens.json`: Input/source data for generated theme/token Swift; not compiled directly.
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`: Build graph authority or tooling input, not product runtime source.
- `Native/Ambitions/Support/Ambitions.entitlements`: Build graph authority or tooling input, not product runtime source.
- `Native/Ambitions/Support/Info.plist`: Build graph authority or tooling input, not product runtime source.
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`: Build graph authority or tooling input, not product runtime source.
- `Native/AmbitionsShareExtension/Info.plist`: Build graph authority or tooling input, not product runtime source.
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`: Build graph authority or tooling input, not product runtime source.
- `Native/AmbitionsWidgetExtension/Info.plist`: Build graph authority or tooling input, not product runtime source.
- `Package.swift`: Build graph authority or tooling input, not product runtime source.
- `Packages/AmbitionsExperienceKernel/Package.swift`: Build graph authority or tooling input, not product runtime source.
- `project.yml`: Build graph authority or tooling input, not product runtime source.

## Acceptance Gate Mapping

- Every target-included file represented: yes, by `entries[]` with non-empty `target_membership`; absent declared paths are also represented with `exists: false`.
- Every unknown target membership flagged Yellow/Red: yes, see `summary.unknown_or_flagged_membership_count` and `unknowns.unknown_or_flagged_target_membership_paths`.
- Every generated file has generator/source or is flagged: yes, see `generator_or_source` and `unknowns.generated_without_confirmed_generator_or_source`.
- Every excluded-but-important file has rationale: yes, see `excluded_rationale` where applicable and the JSON entries.
- JSON parse validation required: run separately after generation.
- No production repair begins: yes; this artifact only classifies current graph state.

## JSON Artifact

The exhaustive per-file inventory is `docs/quality/senior-review/BUILD_GRAPH_INVENTORY.json`.
