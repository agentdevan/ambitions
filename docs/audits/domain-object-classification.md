# AMB-1676 Domain Object Classification

Status: executable classification inventory, not AMB-1676 Green.

This artifact tags every current `Native/Ambitions/Core/Domain` Swift file with the AMB-1676 category set. It does not close the remaining split/rename/delete work.

## Summary

- Total Core/Domain Swift files: 166
- Mechanical suffix debt files: 0
- UI model debt files still in Domain: 0
- Obsolete/product-doctrine bucket files: 0
- Low-confidence default classifications: 0

## Category Counts

| category | count |
|---|---:|
| `adapter_dto` | 15 |
| `canonical_entity` | 10 |
| `command_payload` | 46 |
| `event_payload` | 26 |
| `projection_dto` | 35 |
| `value_object` | 34 |

## Entries

| path | category | loop role | migration action | reason | confidence |
|---|---|---|---|---|---|
| `Native/Ambitions/Core/Domain/ActionReceiptSourceDomain.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphConstraint.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/AmbitionGraphLineageModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/AmbitionGraphModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/AmbitionGraphOperationalRecord.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionRecord.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionStore.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphProjectionStoreProjector.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphRecommendationTrace.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/AmbitionGraphRecoveryThread.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/AmbitionGraphSnapshot.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/AmbitionGraphStoreSplitModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/CapacityShape.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/Capture.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureIntake.swift` | `canonical_entity` | Intent | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/CaptureModels.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRoute.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceipt.swift` | `event_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureRuntimeReceiptKind.swift` | `event_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureSemanticExtraction.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureSemanticExtractionGoalDomainHints.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/CaptureStagedInputProjection.swift` | `projection_dto` | Intent | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/ClosureOutcome.swift` | `canonical_entity` | Action | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/CommitmentWaitingModels.swift` | `projection_dto` | Time Fit | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/ConflictPolicyModels.swift` | `command_payload` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/CorrectionFoldModels.swift` | `event_payload` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/DomainFoundation.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/DomainPackageBoundaryModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/ExecutionResilienceModels.swift` | `projection_dto` | Action | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/FixedPoint.swift` | `value_object` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/FutureProofContextCandidate.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextClassifier.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextClassifierAccessConstraintTerms.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextClassifierCandidateOutput.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/FutureProofContextClassifierCaptureRuntimeFactoringCandidate.swift` | `event_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/GoalBelievabilityModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalClarificationModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalClarificationQuestionGenerator.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalCompiledPathCompilerCore.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalCompiledPathCompilerCoreCompile.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalCompiledPathCompilerCoreStageUncertaintyReasons.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalContradictionModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalDomainPackModels.swift` | `adapter_dto` | Path | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalDraft.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnergyFitModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnergyLearningModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineAdaptationService.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts+ProgressStorageCoding.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineContracts.swift` | `adapter_dto` | Path | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-adapter-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFeedback.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-source-file-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFeedbackAnalyzer.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineFixtures.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntake.swift` | `value_object` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntakeService.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntakeServiceBuildGoalDraft.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntakeServiceCreatePlanningStrategy.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineIntakeServiceInferMissingFields.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrationContextSnapshot.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineOrchestrator.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanSection.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlanner.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEnginePlannerLinter.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalEngineStepRewriter.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalFeedbackEventBase.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalFreshnessUpdateModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCapacityEnvelope.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentCompilerModels.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalIntentDayCompilerInput.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalOrchestrationResult.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalPathCompilerModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphBuilderCore.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphBuilderScoredResource.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalResourceGraphModels.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalTeachingModels.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/GoalUnderstandingModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalEngine/PathIntelligenceModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalRelevanceScan.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/GoalThread.swift` | `canonical_entity` | Path | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/HistoricalContextFact.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/KnowledgeBoundaryModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/KnowledgeIngestionModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LearningAnticipationModels.swift` | `projection_dto` | Learning | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/LifeArea.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/LifeAreaModels.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextBundle.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextBundleCodingAndLabels.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/LifeContextBundleConstraints.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextBundleIdentity.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextEnergyPattern.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | medium |
| `Native/Ambitions/Core/Domain/LifeContextFixtureCityWorkshopLaunchWithoutEquipment.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/LifeContextFixtureMakerResidencyApplicationPathway.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextFixtureProfiles.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/LifeContextFixtureTeenPortfolioLaunchWithGuardianTransport.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/LifeContextModels.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-adapter-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/LifeGraphDeltaReviewModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/LifeGraphEventLogModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/LifeGraphModels.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeGraphResolver.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/LifeGraphSourceDomain.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeCollection.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationCompatibilityAliases.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationModels.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationSchemaVersion.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOperationStore.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeOptionalStringCompatibility.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeSearchDocument.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeSearchFilters.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifeKnowledgeSearchStore.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/LifePathProgressionSummary.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeBucket.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeConfidence.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeCorrection.swift` | `value_object` | Reflow | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeDerivation.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeFallback.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeHorizon.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeInputRef.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeLayer.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/LifeShapeProjection.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeReading.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/LifeShapeRuleID.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/NorthStarModels.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/OneStepGoalModels.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/OneStepGoalReferenceHooks.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/OneStepGoalSummary.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/PersonalRuntimeLearningSignal.swift` | `event_payload` | Learning | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/PlanInsertionCandidate.swift` | `projection_dto` | Path | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/ProjectStepGoalThreadUpdate.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/ProjectStepOperationModels.swift` | `command_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/ProofEvent.swift` | `canonical_entity` | Proof | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/ProofMode/AppDrivingProofModeRouter.swift` | `event_payload` | Proof | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ProofResourceGraphModels.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ProofTrustReceipt.swift` | `event_payload` | Proof | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/ProtectedBoundary.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-pack-or-interoperability-marker | medium |
| `Native/Ambitions/Core/Domain/RealityWindow.swift` | `canonical_entity` | Context | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/RecommendationEvidenceBoundarySummary.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RecommendationExplanation.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/RecommendationExplanationModels.swift` | `projection_dto` | Context | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/RecommendationMutationLabModels.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/RecommendationTrace.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/RecommendationTraceCodingKeys.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/RecommendationTraceCounterfactualDiff.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/RecommendationTraceIdentity.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-declaration-evidence | medium |
| `Native/Ambitions/Core/Domain/RecommendationTraceReasonGraph.swift` | `value_object` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-extension-target-evidence | high |
| `Native/Ambitions/Core/Domain/RecommendationTrustSeamSectionState.swift` | `value_object` | Proof | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/RecoveryState.swift` | `canonical_entity` | Reflow | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/ReminderModels.swift` | `adapter_dto` | Time Fit | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-adapter-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/ReminderNaturalLanguageCaptureParser.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/Reschedule/RescheduleEngine.swift` | `command_payload` | Time Fit | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/RitualModels.swift` | `projection_dto` | Time Fit | `move-to-projection-or-feature-local-projection-when-touched` | projection-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerEnvelope.swift` | `projection_dto` | Proof | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerEnvelopeHashing.swift` | `projection_dto` | Proof | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/RuntimeSnapshotLedgerModels.swift` | `projection_dto` | Proof | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/SafeAutomationPolicyModels.swift` | `event_payload` | Action | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/SafeAutomationProposedAction.swift` | `command_payload` | Action | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentActionLabel.swift` | `command_payload` | Action | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentCaptureRuntimeDetectedSummary.swift` | `projection_dto` | Intent | `move-to-projection-or-feature-local-projection-when-touched` | projection-or-read-model-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentCaptureRuntimeReceiptBuilder.swift` | `event_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-history-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentCaptureRuntimeReplayTrace.swift` | `command_payload` | Intent | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-action-route-marker | medium |
| `Native/Ambitions/Core/Domain/SmartAttachmentModels.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | command-operation-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/SmartAttachmentPlacementPreview.swift` | `event_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/SmartAttachmentResult.swift` | `value_object` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-value-protocol-conformance-evidence | high |
| `Native/Ambitions/Core/Domain/Step.swift` | `canonical_entity` | Path | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
| `Native/Ambitions/Core/Domain/StepReallocationApprovedDecision.swift` | `event_payload` | Path | `review-for-semantic-file-name-or-keep-as-domain-value` | event-proof-receipt-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/TimeContextAvailabilityAndReflow.swift` | `command_payload` | Context | `review-for-semantic-file-name-or-keep-as-domain-value` | domain-behavior-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/TimeContextHierarchy.swift` | `adapter_dto` | Context | `move-to-boundary-sourceatlas-externalwrites-or-relevant-adapter-owner-when-touched` | boundary-source-adapter-declaration-evidence | high |
| `Native/Ambitions/Core/Domain/UserSystemProfile.swift` | `canonical_entity` | Learning | `keep-in-core-domain` | final-architecture-tree-core-domain-owner | high |
