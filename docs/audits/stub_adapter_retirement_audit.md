# Stub And Adapter Retirement Audit

Status: Train 1 generated audit artifact
Rule: preserve real boundary adapters; classify fake/no-op/placeholder/pass-through/ad hoc adapters for later hardening, replacement, fixture movement, or deletion.

## Search Summary

- Command used: `rg -n -i --glob !docs/audits/design_truth_readback.md --glob !docs/audits/design_truth_refraction_audit.md --glob !docs/audits/file_by_file_truth_ledger.md --glob !docs/audits/obsolete_architecture_audit.md --glob !docs/audits/large_swift_file_discipline_audit.md --glob !docs/audits/stub_adapter_retirement_audit.md --glob !docs/audits/forbidden_language_audit.md TODO|FIXME|stub|placeholder|mock|fake|sample|demo|noop|no\-op|fatalError|preconditionFailure|return\ \[\]|return\ nil|return\ \.empty|//\ temporary|//\ for\ now|preview\ only Native Sources AppUI docs prompts scripts tools Package.swift project.yml AGENTS.md README.md`
- Hit count: 2206
- File count: 455
- Raw output bytes: 319193
- Raw log replaced with summary: False

## Sample Findings

- AGENTS.md:81:- Avoid shame, fake urgency, streak pressure, score pressure, AI branding, and productivity-guilt framing.
- AppUI/Sources/WidgetFoundation.swift:110:    guard let handler else { return nil }
- AppUI/Sources/WidgetPreviews.swift:100:    static let empty = Self(snapshot: .init(metadata: WidgetFixtures.metadata(family: .profileSummary), state: .empty(.init(title: "No You summary", message: "Keep this driven by demo fixtures until preferences are wired.", icon: "person.crop.circle", actionTitle: "Open You"))))
- Native/Ambitions/App/AmbitionsRootView.swift:143:                    return nil
- Native/Ambitions/App/AppAppearancePreferencePresentation.swift:8:            return nil
- Native/Ambitions/App/AppBootstrapper.swift:123:        case .demo:
- Native/Ambitions/App/AppBootstrapper.swift:124:            return .demo
- Native/Ambitions/App/AppBootstrapper.swift:138:            return nil
- Native/Ambitions/App/AppBootstrapper.swift:146:        case "demo":
- Native/Ambitions/App/AppBootstrapper.swift:147:            return .demo
- Native/Ambitions/App/AppBootstrapper.swift:149:            return nil
- Native/Ambitions/App/AppBootstrapper.swift:193:            return nil
- Native/Ambitions/App/AppBootstrapper.swift:20:        case demo
- Native/Ambitions/App/AppBootstrapper.swift:254:        return nil
- Native/Ambitions/App/AppContainerFactory.swift:135:        case .demo:
- Native/Ambitions/App/AppContainerFactory.swift:137:            return .demo
- Native/Ambitions/App/AppContainerFactory.swift:152:            try await DemoSeedPipeline(repositories: repositories).seedIfNeeded(force: true)
- Native/Ambitions/App/AppContainerFactory.swift:197:            return nil
- Native/Ambitions/App/AppContainerFactory.swift:199:        return StubTodayService(experience: experience)
- Native/Ambitions/App/AppContainerFactory.swift:202:        return nil

## Top Hit Files

| File | Hits |
| --- | --- |
| tools/source-atlas/lakehouse-workbench/data/sample_raw_run.jsonl | 90 |
| Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift | 82 |
| scripts/ambitions-design-truth-refraction-audit.py | 61 |
| Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift | 49 |
| Native/Ambitions/Features/You/YouFeatureService.swift | 39 |
| Native/Ambitions/Features/Goals/GoalsFeatureService.swift | 36 |
| Native/AmbitionsTests/Domain/LifeGraphModelsTests.swift | 35 |
| Native/Ambitions/Features/Today/TodayFeatureService.swift | 33 |
| Native/AmbitionsTests/Domain/GoalIntentCompilerModelsTests.swift | 31 |
| Native/AmbitionsTests/Services/GoalResourceGraphServiceTests.swift | 29 |
| tools/source-atlas/lakehouse-workbench/app.py | 24 |
| docs/codex/existing-code-champion-coverage.yml | 23 |
| tools/source-atlas/lakehouse-workbench/generator.py | 22 |
| Native/AmbitionsUITests/AmbitionsUITests.swift | 21 |
| scripts/ambitions-linear-sync-dry-run.py | 21 |
| Native/AmbitionsTests/Domain/GoalResourceGraphModelsTests.swift | 20 |
| tools/source-atlas/coverage.py | 19 |
| Native/Ambitions/Domain/SmartAttachmentModels.swift | 18 |
| tools/mcp/ambitions_proof_mcp/tests/test_server_tools.py | 18 |
| scripts/validate_workbench.ps1 | 17 |

## Classified Stub/Adapter Candidates

| File | Classification | Current role | Recommendation | Proof needed | Status |
| --- | --- | --- | --- | --- | --- |
| Native/Ambitions/Domain/ActionClosureReceiptModels.swift | needs hardening | Core Domain file owned by Trust / release proof. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Features/Goals/GoalsFeatureService.swift | stub | Surface file owned by Goals. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Features/Today/TodayFeatureService.swift | stub | Surface file owned by Today. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Features/You/YouFeatureService.swift | stub | Surface file owned by You. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Persistence/SwiftDataRepositories.swift | needs hardening | Persistence file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| scripts/ambitions-codex-train.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| docs/audits/file_by_file_truth_ledger.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1058/focused-root-shell-tests.log | stub | Repo Support file owned by Source Atlas / R2. | replace | stub/adapter audit | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1061-focused-component-tests.log | stub | Repo Support file owned by Source Atlas / R2. | replace | stub/adapter audit | Yellow |
| docs/codex/existing-code-champion-coverage.yml | stub | Codex Governance file owned by Codex governance. | replace | stub/adapter audit | Yellow |
| Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift | stub | Runtime Services file owned by Broad repo. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| tools/source-atlas/coverage.py | stub | Repo automation or validation script. | replace | stub/adapter audit | Yellow |
| Sources/Accessibility/AccessibilityNutrition.swift | needs hardening | Repo Support file owned by Accessibility. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Services/AmbitionsCommandExecutor.swift | needs hardening | Runtime Services file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Services/ReviewsV1Projector.swift | needs hardening | Runtime Services file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Domain/ScreenContractModels.swift | needs hardening | Core Domain file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Runtime/AnyGoalRuntimeCoverage.swift | needs hardening | Runtime file owned by Goals. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Features/Time/TimeFeatureModels.swift | needs hardening | Surface file owned by Time. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| Native/Ambitions/Domain/SafeAutomationPolicyModels.swift | needs hardening | Core Domain file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Red |
| docs/audits/intelligence-consolidation/EXISTING_CODE_CHAMPION_COVERAGE.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/lakehouse-workbench/app.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/visual_final_form_common.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/GoalEngine/GoalEngineIntake.swift | needs hardening | Core Domain file owned by Goals. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Services/GoalClarificationService.swift | needs hardening | Runtime Services file owned by Goals. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Notifications/LocalNotificationFoundation.swift | stub | Repo Support file owned by Broad repo. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/AmbitionsCommandModels.swift | needs hardening | Core Domain file owned by Broad repo. | split | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/codex-os-v2/script-output/final-make-scripts-doctor.log | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/codex-os-v2/script-output/001-initial-make-scripts-doctor.log | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/step-quality/STEP_QUALITY_FIREWALL_FIXTURES.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| docs/audits/large_swift_file_discipline_audit.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1060/focused-design-token-tests.log | stub | Repo Support file owned by Source Atlas / R2. | replace | stub/adapter audit | Yellow |
| Native/Ambitions/Persistence/StorageInvariantChecker.swift | needs hardening | Persistence file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Services/AppServices.swift | stub | Runtime Services file owned by Broad repo. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Sources/Components/CaptureRoutingPrimitiveFamily.swift | needs hardening | Design System file owned by Capture. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift | needs hardening | Repo Support file owned by Trust / release proof. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Features/Capture/CaptureViewModel.swift | needs hardening | Composer file owned by Capture. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/lakehouse-workbench/generator.py | stub | Repo automation or validation script. | replace | stub/adapter audit | Yellow |
| .linear-sync/reports/latest-dry-run.md | needs hardening | Supporting Docs file owned by Broad repo. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/App/ShellCommandRouter.swift | needs hardening | App file owned by Stage shell. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Features/Today/TodayCommandActionHandler.swift | needs hardening | Surface file owned by Today. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/tests/test_ambitions_pack_hash_signature_revocation.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/SideEffectLedgerModels.swift | needs hardening | Core Domain file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions_signature_visual_instruments.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/App/AppBootstrapper.swift | needs hardening | App file owned by Stage shell. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/audits/stub_adapter_retirement_audit.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/codex-os/PROGRAM_REGISTRY.md | needs hardening | Codex Governance file owned by Source Atlas / R2. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/audits/forbidden_language_audit.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/architecture/AMB_SWIFT6_MODERNIZATION_REPORT.md | needs hardening | Supporting Docs file owned by Codex governance. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/lakehouse-workbench/publisher.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| docs/codex/ADHD_COGNITIVE_LOAD_UI_LAW.md | needs hardening | Codex Governance file owned by Codex governance. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Support/CoreSurfaceIntegrationScenarios.swift | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/codex/SOURCE_ATLAS_AUTHORITY_LAW.md | needs hardening | Codex Governance file owned by Source Atlas / R2. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift | needs hardening | Composer file owned by Capture. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Services/ExternalActionCommandService.swift | needs hardening | Runtime Services file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/ambitions-master-build/validation/AMB-1059/focused-search-routing-tests.log | stub | Repo Support file owned by Source Atlas / R2. | replace | stub/adapter audit | Yellow |
| Native/Ambitions/App/AppContainerFactory.swift | stub | App file owned by Stage shell. | replace | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/ambitions-pack-crypto.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Diagnostics/RepoTruthAuditLedger.swift | stub | Diagnostics file owned by Source Atlas / R2. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/AmbitionsShareExtension/ShareViewController.swift | needs hardening | Share Extension file owned by Share extension. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/UNSUPPORTED_UNSAFE_ROUTING_CONTRACT.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions-release-red-guard.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/HIGH_RISK_GUARDED_ROUTING_CONTRACT.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/ExternalSnapshots/ExternalSurfaceControlContracts.swift | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/SOURCE_NEEDED_LOCAL_SCAFFOLD.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Support/ReleaseDeviceQAReadinessReport.swift | needs hardening | Repo Support file owned by Trust / release proof. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/codex/ANY_GOAL_SOLUTION_LOOP_LAW.md | needs hardening | Codex Governance file owned by Goals. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions-surface-contract-lint.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| tools/mcp/ambitions_proof_mcp/tests/test_server_tools.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/COVERAGE_DEMAND_QUEUE_MODEL.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/FRESH_COVERAGE_ARRIVAL_DETECTION_CONTRACT.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/tests/test_ambitions_freshness_broker.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/CLARIFICATION_ENGINE_MODEL.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Persistence/CloudKitContinuityModels.swift | needs hardening | Persistence file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/GOAL_INTENT_GEOMETRY_MODEL.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/any-goal/ANY_GOAL_OPERATING_MODE_MODEL.md | needs hardening | Supporting Docs file owned by Goals. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Features/Goals/StubGoalsService.swift | stub | Surface file owned by Goals. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| AGENTS.md | needs hardening | Supporting Docs file owned by Source Atlas / R2. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/ambitions-master-build/reports/AMB-1058-root-navigation-five-surface-shell-proof.md | needs hardening | Supporting Docs file owned by Trust / release proof. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| docs/audits/design_truth_refraction_audit.md | stub | Audit/proof artifact. | replace | authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/lakehouse-workbench/schema.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/tests/test_ambitions_pack_crypto.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/source-atlas-factory/SOURCE_ATLAS_REUSABLE_SEED_TAXONOMY.md | needs hardening | Supporting Docs file owned by Source Atlas / R2. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions-runner-quote-self-check.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/AmbitionsShareExtension/ShareIntakeView.swift | needs hardening | Share Extension file owned by Share extension. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/object-stage-mega-train/AMB-AOM-06-schema-decision.md | needs hardening | Supporting Docs file owned by Source Atlas / R2. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift | needs hardening | Repo Support file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/release-recovery/IMPLEMENTATION_TRAIN_001.md | needs hardening | Supporting Docs file owned by Trust / release proof. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/source-atlas/ambitions-official-adapter-contract.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| docs/validation/train_1_5_validation_unblock.md | stub | Validation Docs file owned by Codex governance. | replace | forbidden language scan<br>stub/adapter audit | Yellow |
| fixtures/afep026/valid-policy.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/Services/PolicyGuardedCommandExecutor.swift | needs hardening | Runtime Services file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/Planning/LivingPlanFreshnessBroker.swift | needs hardening | Core Domain file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/Planning/LivingPlanContinuitySync.swift | needs hardening | Core Domain file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions-champion-scorecard.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/release_recovery/apply_batch_47_amb_aom_06_schema_review.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| fixtures/afep026/tombstone-recovery-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/Notifications/NextStepLiveActivityService.swift | stub | Repo Support file owned by Broad repo. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/Planning/LivingPlanMutationPermission.swift | needs hardening | Core Domain file owned by Broad repo. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/global-train-handoff-prompt.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| fixtures/afep026/delete-candidate-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| scripts/release-claim-safety-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| .agents/skills/ambitions-visual-product-quality/SKILL.md | needs hardening | Codex Governance file owned by Broad repo. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/GoalEngine/GoalEngineFixtures.swift | fixture | Core Domain file owned by Goals. | move to previews | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Green |
| artifacts/ambitions-master-build/validation/AMB-1112-parallel-guard-prompt.md | needs hardening | Supporting Docs file owned by Source Atlas / R2. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| fixtures/afep026/non-authority-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| tools/mcp/ambitions_visual_mcp/README.md | stub | Repo automation or validation script. | replace | forbidden language scan<br>stub/adapter audit | Yellow |
| fixtures/afep026/authority-precedence-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| scripts/cqs-prompt-built-smell-scan.sh | stub | Repo automation or validation script. | replace | stub/adapter audit | Yellow |
| fixtures/afep026/archive-traceability-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/Domain/CaptureRouteCommandMapping.swift | needs hardening | Core Domain file owned by Capture. | harden | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/no-fake-proof-gate.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Features/Today/StubTodayService.swift | stub | Surface file owned by Today. | replace | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Yellow |
| tools/mcp/ambitions_accessibility_mcp/README.md | stub | Repo automation or validation script. | replace | forbidden language scan<br>stub/adapter audit | Yellow |
| artifacts/object-stage-mega-train/reconciliation/AMB-AOM-06-schema-review.md | needs hardening | Supporting Docs file owned by Broad repo. | harden | architecture conformance scan<br>authority readback<br>forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/accessibility-cognitive-load-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/accessibility-ui-batch-readiness-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/capture-routing-readiness-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/generic-product-drift-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/memory-safety-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/memory-source-confidence-readiness-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/no-creepy-intelligence-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/no-duplicate-canon-check.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/no-existing-status-regression-check.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/no-unsupported-ai-claim-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/privacy-boundary-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/privacy-export-delete-readiness-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/skeletal-prompt-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/source-truth-duplicate-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| Native/Ambitions/Domain/GoalEngine/TypeScriptParityNotes.md | needs hardening | Core Domain file owned by Goals. | harden | architecture conformance scan<br>forbidden language scan<br>stub/adapter audit | Yellow |
| fixtures/afep024/expected-evidence-packet.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| scripts/sig-no-generic-drift-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| tools/mcp/ambitions_source_atlas_mcp/README.md | stub | Repo automation or validation script. | replace | forbidden language scan<br>stub/adapter audit | Yellow |
| tools/mcp/ambitions_release_truth_mcp/README.md | stub | Repo automation or validation script. | replace | forbidden language scan<br>stub/adapter audit | Yellow |
| scripts/ambitions-codex-os-print-install-notes.py | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| scripts/pxeq-visual-noise-scan.sh | needs hardening | Repo automation or validation script. | harden | architecture conformance scan<br>stub/adapter audit | Yellow |
| artifacts/personal-life-os/step-quality/STEP_SOURCE_PROOF_VALIDATOR_FIXTURES.json | fixture | Project Config file owned by Trust / release proof. | keep | stub/adapter audit | Green |
| scripts/codex/amb-master-repository-wiring-validate.py | real boundary adapter | Repo automation or validation script. | keep | not applicable | Green |
| Native/Ambitions/Runtime/AmbitionsRuntimeExperienceSnapshotAdapter.swift | real boundary adapter | Runtime file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan | Green |
| Native/Ambitions/Persistence/GoalIntentCompilerReceiptPersistenceAdapter.swift | real boundary adapter | Persistence file owned by Goals. | keep | build<br>focused tests<br>forbidden language scan | Green |
| Native/Ambitions/Services/LargeStoreFixtureGenerator.swift | fixture | Runtime Services file owned by Broad repo. | move to previews | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Green |
| artifacts/personal-life-os/step-quality/STEP_ACCESSIBILITY_VALIDATOR_FIXTURES.json | fixture | Project Config file owned by Accessibility. | keep | stub/adapter audit | Green |
| Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift | real boundary adapter | Runtime Services file owned by Capture. | keep | build<br>focused tests<br>forbidden language scan | Green |
| fixtures/afep024/evidence-packet-input.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/Services/RealityIntegrationAdapters.swift | real boundary adapter | Runtime Services file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan | Green |
| Native/Ambitions/Domain/SourceAtlasCoverageRuntimeFixtureModels.swift | fixture | Core Domain file owned by Source Atlas / R2. | move to previews | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Green |
| artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR_FIXTURES.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/top-level-plan.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/release-claim-without-proof.json | fixture | Project Config file owned by Trust / release proof. | keep | stub/adapter audit | Green |
| fixtures/afep025/analytics-sdk.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/cloudkit-source-of-truth.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/privacy-boundary-drift.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/hosted-backend-launch.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/required-core-llm.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/afep025/valid-manifest.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/Services/RecommendationExplanationAdapter.swift | real boundary adapter | Runtime Services file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan | Green |
| scripts/ambitions-fe11-generate-fixture-screenshots.py | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| Native/Ambitions/Services/LocalScheduleBlockRepository.swift | real boundary adapter | Runtime Services file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan | Green |
| artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER_FIXTURES.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| artifacts/ambitions-master-build/reports/AMB-1048-live-repository-wiring-quarantine-proof.md | real boundary adapter | Supporting Docs file owned by Trust / release proof. | keep | authority readback<br>forbidden language scan | Green |
| scripts/ambitions-domain-fixture-lint.py | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| Native/Ambitions/Features/Capture/CaptureAtmosphereComposerFlagshipAdapter.swift | real boundary adapter | Composer file owned by Capture. | keep | build<br>focused tests<br>forbidden language scan | Green |
| Packages/AmbitionsExperienceKernel/Sources/AmbitionsExperienceKernel/AmbitionsPreviewFixtures.swift | fixture | Repo Support file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan<br>stub/adapter audit | Green |
| Native/Ambitions/App/ShellChromeFlagshipAdapter.swift | real boundary adapter | App file owned by Stage shell. | keep | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan | Green |
| Native/Ambitions/Features/Today/TodayRealityMeridianFlagshipAdapter.swift | real boundary adapter | Surface file owned by Today. | keep | build<br>focused tests<br>forbidden language scan | Green |
| Native/Ambitions/Domain/AmbitionsOSIntegrationTailGate.swift | real boundary adapter | Core Domain file owned by Broad repo. | keep | build<br>focused tests<br>forbidden language scan | Green |
| scripts/dav-preview-fixture-check.sh | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| scripts/sa-projection-fixture-coverage-scan.sh | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| scripts/release_recovery/apply_batch_09_capture_flagship_adapter.py | real boundary adapter | Repo automation or validation script. | keep | not applicable | Green |
| scripts/release_recovery/apply_batch_08_today_flagship_adapter.py | real boundary adapter | Repo automation or validation script. | keep | not applicable | Green |
| docs/codex-os/PROGRAM_ADAPTER_STANDARD.md | real boundary adapter | Codex Governance file owned by Codex governance. | keep | forbidden language scan | Green |
| scripts/fixture-coverage-scan.sh | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| Native/Ambitions/Persistence/PreviewCaptureRepository.swift | real boundary adapter | Persistence file owned by Capture. | keep | build<br>focused tests<br>forbidden language scan | Green |
| tools/source-atlas/tests/test_ambitions_official_adapter_contract.py | real boundary adapter | Repo automation or validation script. | keep | not applicable | Green |
| scripts/sa-fixture-coverage-scan.sh | fixture | Repo automation or validation script. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/busy-new-job.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/creative-builder.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/long-term-drifter.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/manual-privacy-user.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/overloaded-mover.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/source-heavy-career-switcher.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| fixtures/ambitions-twins/travel-week-user.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| Native/Ambitions/App/AmbitionsExperienceKernelIntegration.swift | real boundary adapter | App file owned by Stage shell. | keep | architecture conformance scan<br>build<br>focused tests<br>forbidden language scan | Green |
| Packages/AmbitionsExperienceKernel/Docs/RepoIntegration.md | real boundary adapter | Supporting Docs file owned by Broad repo. | keep | authority readback<br>forbidden language scan | Green |
| source-atlas/fixtures/closure-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/closure-002.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/closure-003.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/freshness-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/freshness-002.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/freshness-003.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/privacy-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/privacy-002.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/privacy-003.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/reality-meridian-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/reality-meridian-002.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/reality-meridian-003.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/recovery-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/recovery-002.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/recovery-003.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
| source-atlas/fixtures/replay-001.json | fixture | Project Config file owned by Broad repo. | keep | stub/adapter audit | Green |
