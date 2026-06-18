# Forbidden Language Audit

Status: Train 1 generated audit artifact
Scope: Classifies first-pass language risk. Terms in truth docs, audit docs, tests, prompts, and historical context are review triggers, not automatic product UI failures.

## Search Summary

- Command used: `rg -n -i --glob !docs/audits/design_truth_readback.md --glob !docs/audits/design_truth_refraction_audit.md --glob !docs/audits/file_by_file_truth_ledger.md --glob !docs/audits/obsolete_architecture_audit.md --glob !docs/audits/large_swift_file_discipline_audit.md --glob !docs/audits/stub_adapter_retirement_audit.md --glob !docs/audits/forbidden_language_audit.md Source\ unavailable|receipt\ before\ save|route\ reveal|runtime\-backed|fixture\-only|proof\ seam|Close\ Today|Motion\ Current|Capture\ Anything|blocked\-pending\-model|local\ projection|receipt\ path|review\ before\ reflow|No\ silent\ changes|Open\ seam|Re\-enter\ thread|best\ next\ move|next\ best\ move|Begin\ Focus|productivity\ score|life\ score|habit\ score|streak\ broken Native Sources AppUI docs prompts scripts tools Package.swift project.yml AGENTS.md README.md`
- Hit count: 544
- File count: 149
- Raw output bytes: 71594
- Raw log replaced with summary: False

## Sample Findings

- Native/Ambitions/App/AppShellView.swift:1748:            saveState = .saved("Captured locally as \(routeAtSave.title). Receipt path stays inspectable.")
- Native/Ambitions/Copy/ProductCopy.swift:66:        static let objectTitle = "Motion Current"
- Native/Ambitions/Domain/ActionReceiptProofLedgerModels.swift:122:        "No silent changes"
- Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift:426:            "productivity score",
- Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift:456:            "productivity score",
- Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift:196:            "productivity score",
- Native/Ambitions/Domain/ScreenContractModels.swift:534:        requiredFirstScreenContent: ["Capture Anything", "Atmosphere Composer", "Needs a Place", "Ready to Place", "Grow into Goal", "Changeable route receipt"],
- Native/Ambitions/Features/Capture/CaptureViewModel.swift:12:                "Capture Anything",
- Native/Ambitions/Features/Capture/CaptureViewModel.swift:33:                "Capture Anything",
- Native/Ambitions/Features/Capture/CaptureViewModel.swift:35:                "Capture anything",
- Native/Ambitions/Features/Goals/CreateGoalScreen.swift:223:                Text("First read: clarity, timing, source, local save, and the receipt path stay visible before activation.")
- Native/Ambitions/Features/Motion/MotionCurrentAction.swift:43:        case "re-enter thread":
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:1029:                control: "Inspect source, open the future receipt path, or wait for closure."
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:20:        productObject: "Motion Current",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:21:        firstViewportStructure: "Full-bleed Motion Current object stage with what changed, where to re-enter, what needs recovery, and inspectable proof relationships.",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:23:            "rounded Motion Current field panel",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:307:                        title: "Re-enter thread",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:328:                        title: "Re-enter thread",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:36:            "VoiceOver names Motion Current before proof, recovery, re-entry, context, history, and review relationships",
- Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:830:            title: "Motion Current",

## Top Hit Files

| File | Hits |
| --- | --- |
| docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md | 46 |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | 46 |
| scripts/ambitions-design-truth-refraction-audit.py | 26 |
| scripts/release_recovery/apply_batch_15_report_surface_language.py | 21 |
| scripts/release_recovery/apply_batch_29_native_interaction_sweep.py | 17 |
| scripts/ambitions-canon-collapse-red-rewrite.py | 16 |
| scripts/ambitions-actual-canon-content-hygiene-rewrite.py | 12 |
| scripts/ambitions-canon-hygiene-second-pass-repair.py | 12 |
| docs/codex/ambitions_primitive_invention_registry.md | 11 |
| scripts/release_recovery/apply_batch_01_guard_cleanup.py | 11 |
| Native/Ambitions/Features/Motion/MotionCurrentScreen.swift | 9 |
| docs/audits/screenshots/AMB-520/AMB-520-proof-matrix.md | 9 |
| Native/AmbitionsTests/Today/TodayViewModelTests.swift | 8 |
| scripts/release_recovery/apply_batch_02_copy_contract.py | 8 |
| scripts/release_recovery/apply_batch_16_report_closure_gate.py | 8 |
| scripts/release_recovery/apply_batch_20_capture_open_field.py | 8 |
| scripts/ambitions-vocabulary-drift-scan.py | 7 |
| scripts/release_recovery/apply_batch_05_capture_composer_copy.py | 7 |
| Native/Ambitions/PreviewSupport/PreviewTimeScenarios.swift | 6 |
| docs/truth/PRODUCT_MOAT_TRUTH.md | 6 |

## Classified Language Risk

| File | Language risk | Layer | Owner | Status |
| --- | --- | --- | --- | --- |
| scripts/ambitions-design-truth-refraction-audit.py | Source unavailable<br>receipt before save<br>route reveal<br>runtime-backed<br>fixture-only<br>proof seam<br>Close Today<br>Motion Current | scripts | Source Atlas / R2 | Green |
| scripts/release_recovery/apply_batch_15_report_surface_language.py | Source unavailable<br>runtime-backed<br>fixture-only<br>Close Today<br>blocked-pending-model<br>receipt path<br>review before reflow<br>No silent changes | scripts | Trust / release proof | Green |
| scripts/release_recovery/apply_batch_29_native_interaction_sweep.py | Source unavailable<br>route reveal<br>runtime-backed<br>fixture-only<br>Close Today<br>blocked-pending-model<br>Open seam<br>next best move | scripts | Trust / release proof | Green |
| scripts/ambitions-vocabulary-drift-scan.py | best next move<br>next best move<br>Begin Focus<br>productivity score<br>life score<br>habit score<br>streak broken | scripts | Codex governance | Green |
| scripts/ambitions-release-red-guard.py | Source unavailable<br>receipt before save<br>route reveal<br>runtime-backed<br>fixture-only<br>blocked-pending-model | scripts | Trust / release proof | Yellow |
| scripts/release_recovery/apply_batch_16_report_closure_gate.py | Source unavailable<br>runtime-backed<br>fixture-only<br>blocked-pending-model<br>review before reflow<br>No silent changes | scripts | Trust / release proof | Green |
| docs/codex/PERSONAL_LIFE_OS_RUNTIME_LAW.md | best next move<br>next best move<br>Begin Focus<br>productivity score<br>life score | codex governance | Source Atlas / R2 | Green |
| docs/codex/uiql-issue-template.md | Source unavailable<br>receipt path<br>best next move<br>next best move<br>Begin Focus | codex governance | Codex governance | Green |
| scripts/ambitions-batch-ledger-touchpoint-detect.py | Motion Current<br>best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Account | Green |
| scripts/ambitions-copy-contract-lint.py | route reveal<br>runtime-backed<br>fixture-only<br>blocked-pending-model<br>No silent changes | scripts | Codex governance | Green |
| scripts/ambitions-ui-decision-final-gate.py | best next move<br>next best move<br>Begin Focus<br>productivity score<br>streak broken | scripts | Codex governance | Green |
| scripts/codex-forbidden-claim-scan.sh | best next move<br>next best move<br>productivity score<br>life score<br>streak broken | scripts | Source Atlas / R2 | Green |
| scripts/release_recovery/apply_batch_01_guard_cleanup.py | Source unavailable<br>route reveal<br>runtime-backed<br>fixture-only<br>blocked-pending-model | scripts | Trust / release proof | Green |
| scripts/release_recovery/apply_batch_02_copy_contract.py | route reveal<br>runtime-backed<br>fixture-only<br>blocked-pending-model<br>No silent changes | scripts | Trust / release proof | Green |
| .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh | best next move<br>next best move<br>Begin Focus<br>streak broken | codex governance | Broad repo | Green |
| Native/Ambitions/Features/Motion/MotionCurrentScreen.swift | proof seam<br>Motion Current<br>receipt path<br>Re-enter thread | surface | Motion | Red |
| docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md | best next move<br>next best move<br>Begin Focus<br>productivity score | codex governance | Codex governance | Yellow |
| scripts/ambitions-actual-canon-content-hygiene-rewrite.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-batch-ledger-conflict-report.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-batch-ledger-inventory.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-canon-collapse-red-rewrite.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-canon-hygiene-second-pass-repair.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-change-impact-check.py | best next move<br>next best move<br>Begin Focus<br>productivity score | scripts | Codex governance | Green |
| scripts/ambitions-visible-copy-drift-scan.py | best next move<br>next best move<br>Begin Focus<br>streak broken | scripts | Codex governance | Green |
| scripts/ios26-review-sweep.py | best next move<br>next best move<br>Begin Focus<br>streak broken | scripts | Codex governance | Green |
| Native/AmbitionsTests/Domain/AmbitionLifecycleGoldenScenarioTests.swift | best next move<br>productivity score<br>streak broken | tests | Broad repo | Split |
| Sources/Components/StartHereProductPrimitives.swift | best next move<br>productivity score<br>streak broken | design system | Design system | Yellow |
| Sources/Theme/SemanticDesignTokenCatalog.swift | route reveal<br>Motion Current<br>receipt path | design system | Design system | Split |
| artifacts/proof-ledger/PROOF_LEDGER.md | Motion Current<br>receipt path<br>Re-enter thread | supporting docs | Source Atlas / R2 | Green |
| artifacts/proof-ledger/proof-index.json | Motion Current<br>receipt path<br>Re-enter thread | project config | Source Atlas / R2 | Green |
| docs/codex/parallel-guard-concept-registry.yml | Motion Current<br>best next move<br>next best move | codex governance | Codex governance | Green |
| scripts/ambitions-moat-drift-scan.py | best next move<br>next best move<br>Begin Focus | scripts | Codex governance | Green |
| scripts/ambitions-parallel-implementation-guard.py | Motion Current<br>best next move<br>next best move | scripts | Codex governance | Green |
| scripts/ambitions-visual-100-vocabulary-full-corpus-check.py | best next move<br>next best move<br>Begin Focus | scripts | Codex governance | Green |
| scripts/ambitions-visual-vocabulary-boundary-check.py | best next move<br>next best move<br>Begin Focus | scripts | Codex governance | Green |
| scripts/canon-language-drift-scan.sh | best next move<br>next best move<br>productivity score | scripts | Codex governance | Green |
| scripts/release_recovery/apply_batch_05_capture_composer_copy.py | receipt before save<br>route reveal<br>Capture Anything | scripts | Capture | Green |
| scripts/release_recovery/apply_batch_20_capture_open_field.py | receipt before save<br>route reveal<br>Capture Anything | scripts | Capture | Green |
| scripts/run-doc-qa.sh | best next move<br>next best move<br>productivity score | scripts | Codex governance | Green |
| .agents/skills/ambitions-visual-product-quality/SKILL.md | next best move<br>Begin Focus | codex governance | Broad repo | Yellow |
| Native/AmbitionsTests/DesignSystem/SemanticDesignTokenCatalogTests.swift | Motion Current<br>receipt path | tests | Broad repo | Test-only |
| Native/AmbitionsUITests/AmbitionsUITests.swift | Motion Current<br>Re-enter thread | tests | Broad repo | Red |
| Sources/Components/TopLevelSurfaceCompositionPrimitives.swift | Motion Current<br>Capture Anything | design system | Design system | Yellow |
| Sources/Previews/SignatureInterfaceVisualQAFixtures.swift | Motion Current<br>life score | preview support | Design system | Red |
| artifacts/release-recovery/IMPLEMENTATION_TRAIN_001.md | runtime-backed<br>Motion Current | supporting docs | Trust / release proof | Yellow |
| artifacts/source-atlas-factory/r2/R2_PATHING_DATA_DOWNLOAD_LANGUAGE.md | best next move<br>Begin Focus | supporting docs | Source Atlas / R2 | Green |
| docs/codex/TRUST_UI_DISCLOSURE_LAW.md | receipt path<br>productivity score | codex governance | Trust / release proof | Green |
| docs/codex/ambitions_no_card_replacement_taxonomy.md | route reveal<br>Motion Current | codex governance | Codex governance | Green |
| docs/codex/ambitions_primitive_invention_registry.md | Motion Current<br>receipt path | codex governance | Codex governance | Green |
| docs/codex/canonical-owner-map.yml | Motion Current<br>productivity score | codex governance | Codex governance | Green |
| docs/codex/chatgpt-pro-ui-canon-conflicts.md | Motion Current<br>best next move | codex governance | Codex governance | Green |
| docs/codex/chatgpt-pro-ui-development-context-pack.md | Motion Current<br>best next move | codex governance | Codex governance | Green |
| scripts/ai/acx_repair.py | best next move<br>next best move | scripts | Source Atlas / R2 | Green |
| scripts/ambitions-codex-train.sh | best next move<br>next best move | scripts | Codex governance | Yellow |
| scripts/ambitions-parallel-implementation-scan.py | best next move<br>next best move | scripts | Codex governance | Green |
| scripts/ambitions-ui-decision-check.py | best next move<br>streak broken | scripts | Codex governance | Green |
| scripts/ambitions-visual-100-upgrade-p0-recipes.py | proof seam<br>receipt path | scripts | Codex governance | Green |
| scripts/ambitions_design_system_15_common.py | route reveal<br>receipt path | scripts | Codex governance | Green |
| scripts/harness/ambitions-finish-pre-app-source-harness.sh | next best move<br>Begin Focus | scripts | Codex governance | Green |
| scripts/harness/ambitions-product-language-gate.py | next best move<br>Begin Focus | scripts | Codex governance | Green |
| scripts/release_recovery/apply_batch_04_today_meridian_copy.py | Close Today<br>No silent changes | scripts | Today | Green |
| scripts/release_recovery/apply_batch_06_shell_chrome_copy.py | route reveal<br>Capture Anything | scripts | Trust / release proof | Green |
| scripts/release_recovery/apply_batch_23_motion_current_functional.py | Motion Current<br>Re-enter thread | scripts | Motion | Green |
| tools/mcp/ambitions_repo_mcp/autonomy_tools.py | best next move<br>next best move | scripts | Codex governance | Green |
| tools/source-atlas/coverage.py | best next move<br>streak broken | scripts | Codex governance | Yellow |
| DesignTokens/objects/atmosphere-composer.tokens.json | route reveal | project config | Broad repo | Green |
| DesignTokens/semantic.tokens.json | route reveal | project config | Broad repo | Green |
| Native/Ambitions/App/AppShellView.swift | receipt path | app | Stage shell | Red |
| Native/Ambitions/Copy/ProductCopy.swift | Motion Current | repo support | Broad repo | Yellow |
| Native/Ambitions/Domain/ActionReceiptProofLedgerModels.swift | No silent changes | core domain | Trust / release proof | Yellow |
| Native/Ambitions/Domain/AmbitionsOSAdaptationModels.swift | productivity score | core domain | Broad repo | Split |
| Native/Ambitions/Domain/AmbitionsOSExperienceModels.swift | productivity score | core domain | Broad repo | Split |
| Native/Ambitions/Domain/AmbitionsOSInteroperabilityModels.swift | productivity score | core domain | Broad repo | Yellow |
| Native/Ambitions/Domain/ScreenContractModels.swift | Capture Anything | core domain | Broad repo | Red |
| Native/Ambitions/Features/Capture/CaptureViewModel.swift | Capture Anything | composer | Capture | Yellow |
| Native/Ambitions/Features/Goals/CreateGoalScreen.swift | receipt path | surface | Goals | Red |
| Native/Ambitions/Features/Motion/MotionCurrentAction.swift | Re-enter thread | surface | Motion | Red |
| Native/Ambitions/Features/Shared/ActivationContract.swift | Capture Anything | surface | Share extension | Yellow |
| Native/Ambitions/Features/You/YouRootSurface.swift | receipt path | surface | You | Red |
| Native/Ambitions/PreviewSupport/PreviewTimeScenarios.swift | No silent changes | preview support | Broad repo | Red |
| Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift | proof seam | preview support | Today | Red |
| Native/Ambitions/Runtime/PersonalizationFactorLedgerBuilder.swift | proof seam | runtime | Broad repo | Red |
| Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift | local projection | repo support | Trust / release proof | Yellow |
| Native/Ambitions/Support/ReleasePrivacyProtectedStorageReport.swift | local projection | repo support | Trust / release proof | Split |
| Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift | Motion Current | tests | Accessibility | Split |
| Native/AmbitionsTests/App/ActivationContractTests.swift | Capture Anything | tests | Broad repo | Test-only |
| Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift | receipt path | tests | Capture | Test-only |
| Native/AmbitionsTests/App/DailyLoopAlphaQATests.swift | Capture Anything | tests | Broad repo | Test-only |
| Native/AmbitionsTests/App/OnboardingAndDegradedStateTests.swift | Capture Anything | tests | Broad repo | Test-only |
| Native/AmbitionsTests/App/PersonalSystemCenterDesignSystemTests.swift | No silent changes | tests | Broad repo | Test-only |
| Native/AmbitionsTests/App/TopLevelSurfaceCompositionTests.swift | Capture Anything | tests | Broad repo | Test-only |
| Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift | receipt path | tests | Trust / release proof | Test-only |
| Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift | receipt path | tests | Capture | Test-only |
| Native/AmbitionsTests/DesignSystem/StartHereProductKernelTests.swift | best next move | tests | Broad repo | Test-only |
| Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift | No silent changes | tests | Trust / release proof | Red |
| Native/AmbitionsTests/Domain/AmbitionsOSAdaptationModelsTests.swift | productivity score | tests | Broad repo | Test-only |
| Native/AmbitionsTests/Domain/AmbitionsOSEvaluationModelsTests.swift | productivity score | tests | Broad repo | Test-only |
| Native/AmbitionsTests/Domain/AmbitionsOSExperienceModelsTests.swift | productivity score | tests | Broad repo | Test-only |
| Native/AmbitionsTests/Motion/MotionCurrentScreenTests.swift | Motion Current | tests | Motion | Test-only |
| Native/AmbitionsTests/Time/HorizonCapacityPrimitiveFamilyTests.swift | review before reflow | tests | Time | Test-only |
| Native/AmbitionsTests/Time/TimeFeatureServiceTests.swift | No silent changes | tests | Time | Red |
| Native/AmbitionsTests/Today/TodayViewModelTests.swift | No silent changes | tests | Today | Red |
| Packages/AmbitionsExperienceKernel/Codex/Inventions/02_startHereProofSeam.md | proof seam | supporting docs | Trust / release proof | Green |
| Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/Resources/Manifests/inventions.json | proof seam | project config | Broad repo | Green |
| Sources/Accessibility/AccessibilityNutrition.swift | Motion Current | repo support | Accessibility | Red |
| Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift | Motion Current | design system | Accessibility | Red |
| Sources/Components/CaptureRoutingPrimitiveFamily.swift | receipt path | design system | Capture | Yellow |
| Sources/Components/CoreReusableInteractionPrimitives.swift | Motion Current | design system | Design system | Split |
| Sources/Components/FlagshipObjectStagePrimitives.swift | Motion Current | design system | Design system | Yellow |
| Sources/Components/ProofRelationshipTracePrimitiveFamily.swift | receipt path | design system | Trust / release proof | Yellow |
| Sources/Components/TrustReceiptLayerPrimitives.swift | receipt path | design system | Trust / release proof | Red |
| Sources/Previews/DynamicAdaptiveVisualPreviews.swift | Capture Anything | preview support | Design system | Yellow |
| Sources/Previews/PersonalSystemCenterPreviews.swift | No silent changes | preview support | Design system | Yellow |
| Sources/Theme/AmbitionObjectTokens.generated.swift | route reveal | design system | Design system | Yellow |
| Sources/Theme/AmbitionTheme.swift | receipt path | design system | Design system | Red |
| Sources/Theme/AmbitionTokens.generated.swift | route reveal | design system | Design system | Yellow |
| artifacts/ambitions-master-build/AMB_MASTER_PHASE_GATES.md | Motion Current | supporting docs | Source Atlas / R2 | Green |
| artifacts/ambitions-master-build/validation/AMB-1060-validation.json | Motion Current | project config | Broad repo | Green |
| artifacts/ambitions-master-build/validation/AMB-1061-component-inventory.md | Motion Current | supporting docs | Broad repo | Green |
| artifacts/object-stage-mega-train/AMB-AOM-10-report.md | productivity score | supporting docs | Broad repo | Green |
| artifacts/object-stage-mega-train/AOM-00-risk-register.md | receipt path | supporting docs | Broad repo | Green |
| artifacts/object-stage-mega-train/reconciliation/AMB-AOM-10-time-reconstruction.md | productivity score | supporting docs | Broad repo | Green |
| docs/architecture/dependencies/PERSISTENCE_CLIENT.md | receipt path | supporting docs | Codex governance | Green |
| docs/architecture/feature-services/CAPTURE_FEATURE_SERVICE.md | route reveal | supporting docs | Capture | Green |
| docs/architecture/state-machines/CAPTURE_ROUTE_STATE_MACHINE.md | route reveal | supporting docs | Capture | Green |
| docs/audits/design_truth_readback.md | restricted terms present in authority/audit context: best next move, next best move, Begin Focus | audit docs | Source Atlas / R2 | Green |
| docs/audits/file_by_file_truth_ledger.md | restricted terms present in authority/audit context: Source unavailable, receipt before save, route reveal, runtime-backed, fixture-only | audit docs | Source Atlas / R2 | Yellow |
| docs/audits/forbidden_language_audit.md | restricted terms present in authority/audit context: Source unavailable, receipt before save, route reveal, runtime-backed, fixture-only | audit docs | Source Atlas / R2 | Yellow |
| docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md | restricted terms present in authority/audit context: Motion Current, productivity score | audit docs | Codex governance | Green |
| docs/audits/large_swift_file_discipline_audit.md | restricted terms present in authority/audit context: Motion Current | audit docs | Source Atlas / R2 | Yellow |
| docs/audits/screenshots/AMB-520/AMB-520-proof-matrix.md | restricted terms present in authority/audit context: Source unavailable, Motion Current | audit docs | Trust / release proof | Green |
| docs/codex/LIFE_CONSEQUENCE_REFLOW_LAW.md | productivity score | codex governance | Codex governance | Green |
| docs/codex/chatgpt-pro-ui-development-quick-brief.md | Motion Current | codex governance | Codex governance | Green |
| docs/codex/reports/AMB-506-restore-runner-guard-inputs.md | Motion Current | codex governance | Account | Green |
| docs/codex/ui-quality-firewall.md | receipt path | codex governance | Codex governance | Green |
| docs/truth/HISTORICAL_POLICY.md | restricted terms present in authority/audit context: Motion Current, best next move | truth docs | Account | Delete |
| docs/truth/IMPLEMENTATION_TRUTH.md | restricted terms present in authority/audit context: productivity score | truth docs | Source Atlas / R2 | Green |
| docs/truth/NATIVE_INTERACTION_TRUTH.md | restricted terms present in authority/audit context: Source unavailable, runtime-backed, fixture-only, Motion Current, blocked-pending-model | truth docs | Codex governance | Green |
| docs/truth/PRODUCT_DESIGN_TRUTH.format-backup-20260616T220228.md | restricted terms present in authority/audit context: Source unavailable, receipt before save, route reveal, runtime-backed, fixture-only | truth docs | Source Atlas / R2 | Delete |
| docs/truth/PRODUCT_DESIGN_TRUTH.md | restricted terms present in authority/audit context: Source unavailable, receipt before save, route reveal, runtime-backed, fixture-only | truth docs | Source Atlas / R2 | Red |
| docs/truth/PRODUCT_MOAT_TRUTH.md | restricted terms present in authority/audit context: receipt path, best next move, productivity score, life score, habit score | truth docs | Source Atlas / R2 | Green |
| docs/validation/train_1_5_validation_unblock.md | streak broken | validation docs | Codex governance | Yellow |
| docs/validation/train_1_6_test_scanner_authority_stabilization.md | streak broken | validation docs | Codex governance | Green |
| frontend/visual-encyclopedia/trace/DESIGN_TOKEN_COMPLETENESS_MATRIX.yaml | route reveal | project config | Broad repo | Green |
| frontend/visual-encyclopedia/trace/PREVIEW_MATRIX.md | route reveal | supporting docs | Broad repo | Green |
| prompts/object-stage-mega-train/AMB-AOM-10.md | restricted terms present in authority/audit context: productivity score | codex governance | Codex governance | Green |
| scripts/ai/acx.py | productivity score | scripts | Codex governance | Green |
| scripts/ambitions-champion-coverage-check.py | Motion Current | scripts | Codex governance | Green |
| scripts/ambitions-fe11-preview-visual-qa-report.py | proof seam | scripts | Codex governance | Green |
| scripts/ambitions-linear-sync-dry-run.py | best next move | scripts | Codex governance | Green |
| scripts/ambitions-surface-recipe-inventory-check.py | route reveal | scripts | Codex governance | Green |
| scripts/ambitions-surface-recipe-specificity-check.py | route reveal | scripts | Codex governance | Green |
| scripts/ambitions-visual-100-object-depth-check.py | proof seam | scripts | Codex governance | Green |
| scripts/ambitions_validate_proof_receipts.py | fixture-only | scripts | Trust / release proof | Green |
| scripts/ambitions_visual_design_lock_repair_05_common.py | route reveal | scripts | Codex governance | Green |
| scripts/codex/step-quality-firewall-validate.py | streak broken | scripts | Codex governance | Green |
| scripts/cqs-product-drift-scan.sh | productivity score | scripts | Codex governance | Green |
| scripts/cqs-prompt-built-smell-scan.sh | productivity score | scripts | Codex governance | Yellow |
| scripts/fet-copy-density-scan.sh | No silent changes | scripts | Codex governance | Green |
| scripts/harness/ambitions-failure-classifier.py | next best move | scripts | Codex governance | Green |
| scripts/harness/ambitions_harness_slice_runner.py | next best move | scripts | Codex governance | Green |
| scripts/harness/ambitions_install_proofmode_001.py | proof seam | scripts | Trust / release proof | Green |
| scripts/release_recovery/apply_batch_41_motion_reentry_visual_rebuild.py | Motion Current | scripts | Motion | Green |
| scripts/release_recovery/apply_batch_56_amb_aom_10_time_reconstruction.py | productivity score | scripts | Trust / release proof | Green |
| scripts/sig-no-generic-drift-scan.sh | productivity score | scripts | Codex governance | Yellow |
| tools/mcp/ambitions_repo_mcp/server.py | productivity score | scripts | Account | Green |
| tools/source-atlas/lakehouse-workbench/README.md | streak broken | scripts | Source Atlas / R2 | Green |
| tools/source-atlas/lakehouse-workbench/duckdb_qa.py | streak broken | scripts | Codex governance | Green |
| tools/source-atlas/lakehouse-workbench/generator.py | streak broken | scripts | Codex governance | Yellow |
| tools/source-atlas/lakehouse-workbench/schema.py | streak broken | scripts | Codex governance | Yellow |
| tools/source-atlas/lakehouse-workbench/tests/test_workbench.py | streak broken | scripts | Codex governance | Green |
