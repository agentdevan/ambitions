# AMB-1676 Domain Object Classification

Status: executable classification inventory, not AMB-1676 Green.

This artifact tags every current `Native/Ambitions/Core/Domain` Swift file with the AMB-1676 category set. It does not close the remaining split/rename/delete work.

## Summary

- Total Core/Domain Swift files: 217
- Mechanical suffix debt files: 77
- UI model debt files still in Domain: 8
- Obsolete/product-doctrine bucket files: 40
- Low-confidence default classifications: 97

## Category Counts

| category | count |
|---|---:|
| `adapter_dto` | 7 |
| `canonical_entity` | 10 |
| `command_payload` | 23 |
| `event_payload` | 15 |
| `obsolete` | 40 |
| `projection_dto` | 17 |
| `ui_model` | 8 |
| `value_object` | 97 |

## Entries

| path | category | loop role | migration action | reason | confidence |
|---|---|---|---|---|---|
| `Native/Ambitions/Core/Domain/AmbitionGraphLineageModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionGraphModels+02-Constraint.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionGraphModels+03-RecoveryThread.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionGraphModels+04-AmbitionGraphRecommendationTrace.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionGraphModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionStore+02-AmbitionGraphProjectionStore.swift` | `projection_dto` | Path | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionStore+03-AmbitionGraphSnapshot.swift` | `projection_dto` | Path | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionStore.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphStoreSplitModels+02-AmbitionGraphProjectionRecord.swift` | `projection_dto` | Path | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphStoreSplitModels+03-AmbitionGraphOperationalRecord.swift` | `command_payload` | Path | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphStoreSplitModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/AmbitionsOSAdaptationModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSAlternatePathModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSCloseoutTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSCommitmentTimeModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSControlPlaneModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSEvaluationModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSEvaluationTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSExperienceModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSExperienceTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSGoalPathCompilerModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSHandoffTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSIntegrationTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSInteroperabilityModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift` | `obsolete` | Context | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamEligibilityDeadlineModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamHandlingModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamNorthStarModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamPackRegistryModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamPackSupplyChainSecurityModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamRequirementGraphModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamSafetyTriageModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift` | `obsolete` | Context | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift` | `obsolete` | Intent | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLivingDreamTrustReceiptModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLocalGoalPackModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLocalLanguageModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSLongevityModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSOptionValueModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSPerformanceEnergyModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSPrivacySafetyModels.swift` | `obsolete` | Context | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSPrivacySafetyTailGate.swift` | `obsolete` | Context | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSProofTrustModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSRealityDriftModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSRecommendationStartHereModels.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSRuntimeTailGate.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSSourceTruthModels.swift` | `obsolete` | Context | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsOSStartingPositionModels.swift` | `obsolete` | Intent | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AmbitionsProductCanonV2Models.swift` | `obsolete` | Path | `split-rename-or-delete-before-amb-1676-green` | product-doctrine-or-tail-gate-bucket | medium |
| `Native/Ambitions/Core/Domain/AppSession.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/CanonicalNowStateModels.swift` | `ui_model` | Context | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/CapacityShape.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/CaptureIntake.swift` | `canonical_entity` | Intent | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/CaptureModels+02-CaptureStagedInputProjection.swift` | `projection_dto` | Intent | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureModels+03-CaptureRoute.swift` | `command_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureModels+04-Capture.swift` | `command_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureModels.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt+02-SmartAttachmentResult.swift` | `event_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt+03-SmartAttachmentResult+03-captureRuntimeDetectedSummary.swift` | `projection_dto` | Intent | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt+03-SmartAttachmentResult.swift` | `event_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt+04-CaptureRuntimeReceiptKind.swift` | `event_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt.swift` | `event_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ClosureOutcome.swift` | `canonical_entity` | Action | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/CommitmentWaitingModels.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/ConflictPolicyModels.swift` | `value_object` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` | `value_object` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/DomainFoundation.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/DomainPackageBoundaryModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/ExecutionResilienceModels.swift` | `value_object` | Action | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/FixedPoint.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate+02-FutureProofContextClassifier+02-captureRuntimeFactoringCandidate.swift` | `event_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate+02-FutureProofContextClassifier+03-futureProofContextCandidate.swift` | `event_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate+02-FutureProofContextClassifier+04-accessConstraintTerms.swift` | `event_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate+02-FutureProofContextClassifier.swift` | `event_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/GoalBelievabilityModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalClarificationModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalContradictionModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalDomainPackModels.swift` | `adapter_dto` | Path | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnergyFitModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnergyLearningModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineAdaptationService.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+02-PlanSection.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+03-GoalFeedbackEventBase.swift` | `event_payload` | Path | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+04-GoalEngineOrchestrationContextSnapshot.swift` | `projection_dto` | Context | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+05-GoalOrchestrationResult.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+ProgressStorageCoding.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFeedback.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFeedbackAnalyzer.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake+02-GoalEngineIntakeService+02-buildGoalDraft.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake+02-GoalEngineIntakeService+03-inferMissingFields.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake+02-GoalEngineIntakeService+04-createPlanningStrategy.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake+02-GoalEngineIntakeService.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake+03-GoalClarificationQuestionGenerator.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake.swift` | `value_object` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrator.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanner.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlannerLinter.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineStepRewriter.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalFreshnessUpdateModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCompilerModels+02-GoalIntentCapacityEnvelope.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCompilerModels+03-GoalDraft.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCompilerModels+04-GoalIntentDayCompilerInput.swift` | `value_object` | Intent | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCompilerModels.swift` | `value_object` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels+02-GoalCompiledPathCompilerCore+02-compile.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels+02-GoalCompiledPathCompilerCore+03-stageUncertaintyReasons.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels+02-GoalCompiledPathCompilerCore.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels+02-GoalResourceGraphBuilderCore+03-ScoredResource.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels+02-GoalResourceGraphBuilderCore.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalTeachingModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalUnderstandingModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalEngine/PathIntelligenceModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalRelevanceScan.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/GoalThread.swift` | `canonical_entity` | Path | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/GoalsModels.swift` | `ui_model` | Path | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/InsightsModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/KnowledgeBoundaryModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/KnowledgeIngestionModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LearningAnticipationModels.swift` | `value_object` | Learning | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeArea.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/LifeAreaModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeAreaSummary.swift` | `ui_model` | Context | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/LifeContextModels+02-HistoricalContextFact.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+03-LifeContextBundle+02-id.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+03-LifeContextBundle+03-deriveConstraints.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+03-LifeContextBundle.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+04-LifeContextBundle.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+02-teenPortfolioLaunchWithGuardianTransport.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+03-makerResidencyApplicationPathway.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles+04-cityWorkshopLaunchWithoutEquipment.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+05-LifeContextFixtureProfiles.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels+06-LifeContextEnergyPattern.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeContextModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeGraphDeltaReviewModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeGraphEventLogModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/LifeGraphModels+02-LifeGraphSourceDomain.swift` | `adapter_dto` | Context | `rename-mechanical-suffix-to-semantic-owner` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeGraphModels+03-LifePathProgressionSummary.swift` | `projection_dto` | Path | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeGraphModels+04-LifeGraphResolver.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeGraphModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationCompatibilityAliases.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+02-LifeKnowledgeOperationModels.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+02-schemaVersion.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+03-Collection.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+03-LifeKnowledgeOperationModels.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+04-Store.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels+05-SearchFilters.swift` | `command_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOptionalStringCompatibility.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeBucket.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeConfidence.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeCorrection.swift` | `value_object` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeDerivation.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeFallback.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeHorizon.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeInputRef.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeLayer.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/LifeShapeProjection.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeReading.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeRuleID.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/NorthStarModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/OneStepGoalModels+02-OneStepGoalReferenceHooks.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/OneStepGoalModels+03-OneStepGoalSummary.swift` | `projection_dto` | Path | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/OneStepGoalModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/PlanInsertionCandidate.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/ProjectStepOperationModels+02-ProjectStepGoalThreadUpdate.swift` | `command_payload` | Path | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ProjectStepOperationModels+03-PersonalRuntimeLearningSignal.swift` | `command_payload` | Path | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ProjectStepOperationModels+04-StepReallocationApprovedDecision.swift` | `command_payload` | Path | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ProjectStepOperationModels.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ProofEvent.swift` | `canonical_entity` | Proof | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/ProofMode/AppDrivingProofModeRouter.swift` | `event_payload` | Proof | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ProtectedBoundary.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/RealityModels.swift` | `ui_model` | Context | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/RealityWindow.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+02-RecommendationEvidenceBoundarySummary.swift` | `projection_dto` | Context | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+03-RecommendationTraceCounterfactualDiff.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+04-RecommendationTrace+02-CodingKeys.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+04-RecommendationTrace+03-id.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+04-RecommendationTrace+04-reasonGraph.swift` | `value_object` | Path | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+04-RecommendationTrace.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+05-RecommendationTrustSeamSectionState.swift` | `value_object` | Proof | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels+06-RecommendationExplanation.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RecommendationMutationLabModels.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/RecoveryState.swift` | `canonical_entity` | Reflow | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/ReminderModels.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/ReminderNaturalLanguageCaptureParser.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift` | `command_payload` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ReviewsModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RitualModels.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerModels+02-RuntimeSnapshotLedgerEnvelope.swift` | `projection_dto` | Proof | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerModels+03-RuntimeSnapshotLedgerEnvelope.swift` | `projection_dto` | Proof | `rename-mechanical-suffix-to-semantic-owner` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerModels.swift` | `projection_dto` | Proof | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/SafeAutomationPolicyModels+02-SafeAutomationProposedAction.swift` | `command_payload` | Action | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SafeAutomationPolicyModels+03-ActionReceiptSourceDomain.swift` | `event_payload` | Context | `rename-mechanical-suffix-to-semantic-owner` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/SafeAutomationPolicyModels.swift` | `value_object` | Action | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels+02-SmartAttachmentActionLabel.swift` | `command_payload` | Action | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels+03-SmartAttachmentResult.swift` | `value_object` | Context | `rename-mechanical-suffix-to-semantic-owner` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels+04-CaptureSemanticExtraction+03-goalDomainHints.swift` | `command_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels+04-CaptureSemanticExtraction.swift` | `command_payload` | Intent | `rename-mechanical-suffix-to-semantic-owner` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/SmartAttachmentPlacementPreview.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/Step.swift` | `canonical_entity` | Path | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/TimeRitualModels.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
| `Native/Ambitions/Core/Domain/TodayModels.swift` | `ui_model` | Context | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/UserSystemProfile.swift` | `canonical_entity` | Learning | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/YouCrossSurfaceProofReviewModels.swift` | `event_payload` | Proof | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/YouModels+02-YouMemoryControlState.swift` | `ui_model` | Context | `rename-mechanical-suffix-to-semantic-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/YouModels+03-YouPersonalVaultRow.swift` | `ui_model` | Context | `rename-mechanical-suffix-to-semantic-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/YouModels.swift` | `ui_model` | Context | `move-out-of-core-domain-to-surface-quality-or-projection-owner` | surface-or-screen-state-marker | medium |
| `Native/Ambitions/Core/Domain/YouPlanningDefaultsModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-default-no-special-marker | low |
