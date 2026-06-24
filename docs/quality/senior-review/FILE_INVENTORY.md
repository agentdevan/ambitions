# File Inventory and Ownership Map

Status: SCG-003 inventory artifact only. This is not senior-readiness proof, file-by-file senior review, flow tracing, production repair, runtime proof, visual proof, accessibility proof, privacy approval, TestFlight readiness, App Store readiness, or release readiness.

## Scope

- Issue: AMB-1286 / SCG-003
- Branch: `main`
- Last reviewed SHA: `4667d01eb004a7457df5bd92130b0b6dc3f2cb18`
- Production behavior changed: No
- SCG-004 started: No
- File-by-file senior review started: No
- Flow tracing started: No
- Repair trains started: No

## Evidence Sources
- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`
- `docs/quality/senior-review/BUILD_GRAPH_INVENTORY.json`
- `docs/quality/senior-review/BUILD_GRAPH_INVENTORY.md`
- `project.yml`
- `Package.swift`
- `Packages/AmbitionsExperienceKernel/Package.swift`
- `git ls-files`
- `repo source tree, tests, scripts, docs, tracked generated/support files`

## Summary

- Inventory entries: 2134
- Existing tracked files at generation start: 2131
- SCG-003 generated output entries included: 3
- Active production entries with expected owner: 1286 / 1286
- Active test entries with expected owner: 367 / 367
- Unknown ownership/layer count: 117
- Red findings: 0
- Yellow findings: 299
- SCG-BG-001: preserved as resolved by package-relative SwiftPM audit

## Risk Counts

| Risk | Count |
|---|---:|
| Green | 1835 |
| Yellow | 299 |
| Red | 0 |

## Layer Counts

| Layer | Count |
|---|---:|
| `App` | 69 |
| `Stage` | 39 |
| `Stage/Chrome` | 9 |
| `Stage/Motion` | 9 |
| `Core/Domain` | 301 |
| `Core/Runtime` | 261 |
| `Core/Time` | 8 |
| `Core/Persistence` | 51 |
| `Core/Permissions` | 14 |
| `Projection` | 195 |
| `Language` | 9 |
| `Trust` | 14 |
| `Interaction` | 7 |
| `Rendering` | 10 |
| `DesignSystem` | 227 |
| `Surfaces/Today` | 9 |
| `Surfaces/Goals` | 17 |
| `Surfaces/Time` | 10 |
| `Surfaces/You` | 25 |
| `Composer/Capture` | 17 |
| `Scenarios` | 47 |
| `Diagnostics` | 6 |
| `Quality` | 59 |
| `Tests` | 367 |
| `Scripts` | 50 |
| `Docs` | 187 |
| `Legacy/Unknown` | 117 |

## Status Counts

| Status | Count |
|---|---:|
| `classified` | 1851 |
| `unknown_or_legacy_owner` | 112 |
| `source_path_without_target_membership` | 96 |
| `preview_target_membership_review_required` | 43 |
| `fixture_target_membership_review_required` | 18 |
| `generated_source_proof_missing` | 8 |
| `legacy_classification` | 4 |
| `unknown_classification` | 2 |

## Carried-Forward SCG-002 Yellow Classifications

- Preview-only files with target membership require later SCG review before senior-readiness can be claimed.
- Fixture-named files with production target membership require later SCG review before senior-readiness can be claimed.
- Generated Swift files without a retained generator/source proof are flagged for follow-up; no repair was started.
- Tracked legacy/unknown support files are classified, not repaired, in SCG-003.
- `SCG-BG-001` remains resolved; no package manifest/resource repair was made in SCG-003.

## Yellow Finding Groups

- `unknown_or_legacy_owner`: 112
- `source_path_without_target_membership`: 96
- `preview_target_membership_review_required`: 43
- `fixture_target_membership_review_required`: 18
- `generated_source_proof_missing`: 8
- `legacy_classification`: 4
- `unknown_classification`: 2

## Unknown / Legacy Ownership Samples

- `Brewfile` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `Packages/AmbitionsExperienceKernel/.gitignore` -> current_owner `Nested package support`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `assets/adaptive-icon.png` -> current_owner `Legacy root assets`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `assets/favicon.png` -> current_owner `Legacy root assets`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `assets/icon.png` -> current_owner `Legacy root assets`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `assets/splash-icon.png` -> current_owner `Legacy root assets`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep024/evidence-packet-input.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep024/expected-evidence-packet.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/analytics-sdk.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/cloudkit-source-of-truth.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/hosted-backend-launch.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/privacy-boundary-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/release-claim-without-proof.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/required-core-llm.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/top-level-plan.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep025/valid-manifest.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/archive-traceability-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/authority-precedence-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/delete-candidate-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/non-authority-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/tombstone-recovery-drift.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/afep026/valid-policy.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/busy-new-job.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/creative-builder.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/long-term-drifter.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/manual-privacy-user.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/overloaded-mover.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/source-heavy-career-switcher.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `fixtures/ambitions-twins/travel-week-user.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `frontend/visual-encyclopedia/trace/DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `frontend/visual-encyclopedia/trace/DESIGN_TO_SOURCE_TRACEABILITY.yaml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `frontend/visual-encyclopedia/trace/LOCAL_FIRST_RUNTIME_TRUST_MATRIX.yaml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.yaml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `frontend/visual-encyclopedia/trace/SOURCE_PROOF_RECEIPT_COVERAGE_MATRIX.yaml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/closure-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/closure-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/closure-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/freshness-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/freshness-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/freshness-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/privacy-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/privacy-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/privacy-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/reality-meridian-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/reality-meridian-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/reality-meridian-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/recovery-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/recovery-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/recovery-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/replay-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/replay-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/replay-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/runtime-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/runtime-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/runtime-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/runtime-004.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/start-here-001.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/start-here-002.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `source-atlas/fixtures/start-here-003.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_proof_mcp/server.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_proof_mcp/tests/test_server_tools.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_repo_mcp/autonomy_tools.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_repo_mcp/pyproject.toml` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_repo_mcp/server.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/mcp/ambitions_repo_mcp/tests/test_server_tools.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/batch_report/classify_batch_result.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/batch_report/summarize_batch_report.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/config/ambitions_openai_build_policy.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/config/codex_agent_roles.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/config/redaction_rules.json` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/evals/datasets/batch_quality.jsonl` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/evals/datasets/claim_safety.jsonl` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/evals/datasets/visual_canon.jsonl` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/evals/run_evals.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/evals/score_reports.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/launch_docs/generate_launch_packet.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/prompt_repair/repair_batch_prompt.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/repo_brain/build_repo_manifest.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/repo_brain/query_repo_brain.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`
- `tools/openai/visual_critique/critique_visual_packet.py` -> current_owner `Unknown`, expected_owner `Legacy/Unknown`, risk `Yellow`

## Generated Files Without Retained Generator/Source Proof

- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsColorToken.generated.swift`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsGeneratedAssetNames.swift`
- `Sources/Theme/AmbitionObjectTokens.generated.swift`
- `Sources/Theme/AmbitionStateTokens.generated.swift`
- `Sources/Theme/AmbitionTokens.generated.swift`
- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`
- `Sources/Theme/AmbitionsRecipeID.generated.swift`
- `Sources/Theme/AmbitionsSurfaceID.generated.swift`

## Preview / Fixture Target-Membership Risk

- Count: 66
- `AppUI/Sources/WidgetPreviews.swift`
- `Native/Ambitions/Composer/Capture/CaptureRoutingPreview.swift`
- `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift`
- `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+02-teenPortfolioLaunchWithGuardianTransport.swift`
- `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+03-makerResidencyApplicationPathway.swift`
- `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+04-cityWorkshopLaunchWithoutEquipment.swift`
- `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles.swift`
- `Native/Ambitions/Core/Domain/SmartAttachmentPlacementPreview.swift`
- `Native/Ambitions/Core/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift`
- `Native/Ambitions/Core/Persistence/PreviewCaptureRepository.swift`
- `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift`
- `Native/Ambitions/Core/Time/PreviewClock.swift`
- `Native/Ambitions/PreviewSupport/AppDeepLinkPreviewRouter.swift`
- `Native/Ambitions/PreviewSupport/CaptureAtmosphereComposerPreviews.swift`
- `Native/Ambitions/PreviewSupport/CaptureComposerPreviews.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Native/Ambitions/PreviewSupport/PreviewTimeRitualScenarios.swift`
- `Native/Ambitions/PreviewSupport/StubGoalsService.swift`
- `Native/Ambitions/PreviewSupport/StubTodayService.swift`
- `Native/Ambitions/PreviewSupport/ToolbarPreviewCatalog.swift`
- `Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureService+06-makeAtlasPreview.swift`
- `Native/Ambitions/Quality/LifeShapeFixtureAudit.swift`
- `Native/Ambitions/Quality/ShellPreviewMatrix.swift`
- `Native/Ambitions/Surfaces/You/YouScreen+09-YouPreviewSwatchSurface.swift`
- `Native/AmbitionsTests/App/ShellPreviewMatrixTests.swift`
- `Packages/AmbitionsExperienceKernel/.gitignore`
- `Packages/AmbitionsExperienceKernel/Makefile`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsColorToken.generated.swift`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsGeneratedAssetNames.swift`
- `Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsPreviewFixtures.swift`
- `Sources/Previews/AFI13VisualQACatalog.swift`
- `Sources/Previews/AccessibilityAdaptiveInterfacePreviews.swift`
- `Sources/Previews/AmbitionsCanonPreviewFixtureCatalog.swift`
- `Sources/Previews/ComponentPreviewGallery+Density.swift`
- `Sources/Previews/ComponentPreviewGallery+RichPanels.swift`
- `Sources/Previews/ComponentPreviewModels.swift`
- `Sources/Previews/ComponentPreviews.swift`
- `Sources/Previews/CoreReusableInteractionPrimitivePreviews.swift`
- `Sources/Previews/DesignSystemPreviewGalleryPreviews.swift`
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`
- `Sources/Previews/FE09ComponentSystemPreviewMatrix.swift`
- `Sources/Previews/IconographyStatusPreviews.swift`
- `Sources/Previews/InteractionMotionHapticsPreviews.swift`
- `Sources/Previews/LoadingDegradedStatePreviews.swift`
- `Sources/Previews/PersonalSystemCenterPreviews.swift`
- `Sources/Previews/RealityMeridianRichnessPreviews.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Sources/Previews/RootDestinationIdentityPreviews.swift`
- `Sources/Previews/SI03ShellNavigationPreviews.swift`
- `Sources/Previews/SI16PreviewFixtureCatalog.swift`
- `Sources/Previews/SI16PreviewSurfaceCoverageRow.swift`
- `Sources/Previews/SI16VisualQAFixture.swift`
- `Sources/Previews/SI16VisualQAFixtureSnapshotCard.swift`
- `Sources/Previews/SI16VisualQAStateFamily.swift`
- `Sources/Previews/SemanticDesignTokenGallery.swift`
- `Sources/Previews/ShellChromeTrustPreviews.swift`
- `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift`
- `Sources/Previews/TopLevelSurfaceCompositionPreviews.swift`
- `Sources/Previews/TrustReceiptLayerPreviews.swift`
- `Sources/Theme/AmbitionObjectTokens.generated.swift`
- `Sources/Theme/AmbitionStateTokens.generated.swift`
- `Sources/Theme/AmbitionTokens.generated.swift`
- `Sources/Theme/AmbitionsFrontendAuthority.generated.swift`
- `Sources/Theme/AmbitionsRecipeID.generated.swift`
- `Sources/Theme/AmbitionsSurfaceID.generated.swift`

## Acceptance Gate Mapping

- Every existing tracked file classified or explicitly marked Legacy/Unknown: yes.
- Every active production file has expected owner: yes, by canonical layer or mapped compatibility owner; no active production entry has expected owner `Legacy/Unknown`.
- Every active test file has expected owner: yes, `Tests`.
- Unknown layer/owner surfaced: yes, Yellow in inventory and Markdown summary.
- SCG-002 Yellow classifications carried forward: yes, preview/fixture/generator/legacy categories are retained as Yellow inventory risks.
- Production behavior changes: none; generated artifacts are docs/quality governance only.
- Senior-readiness claimed: no.

## Machine-Readable Artifacts

- `docs/quality/senior-review/FILE_INVENTORY.json`
- `docs/quality/senior-review/OWNERSHIP_MAP.yaml`
- `docs/quality/senior-review/schemas/file_inventory.schema.json`
