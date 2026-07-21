import Foundation

enum MeaningfulMutationStatus: String, Sendable, Hashable {
    case durable
    case projectionOnly
    case adapter
    case previewOnly
    case unproven
}

struct MeaningfulMutationDescriptor: Sendable, Hashable {
    let id: String
    let sourcePath: String
    let commandKind: AmbitionsCommandKind
    let executorOwner: String?
    let durableStores: [String]
    let eventKind: String?
    let projectionOwner: String?
    let receiptOwner: String?
    let replayTestID: String?
    let proofTestIDs: [String]
    let status: MeaningfulMutationStatus
    let rationale: String
}

struct MeaningfulMutationWritePathDescriptor: Sendable, Hashable {
    let sourcePath: String
    let executorOwner: String?
    let eventKind: String?
    let projectionOwner: String?
    let receiptOwner: String?
    let replayTestID: String?
    let status: MeaningfulMutationStatus
    let proofTestIDs: [String]
    let rationale: String
}

enum MeaningfulMutationRegistry {
    static let declaredMutationRowCount = 120
    static let declaredWritePathRowCount = 55

    static let descriptors: [MeaningfulMutationDescriptor] = [
        mutation(
            id: "preview.runtime-command-client",
            sourcePath: "PreviewAppContainerFactory.preview",
            commandKind: .placeStepInTime,
            status: .previewOnly,
            rationale: "DEBUG-only preview composition installs an in-memory runtime command closure; it is not production mutation authority."
        ),
        mutation(
            id: "time.life-shape", sourcePath: "TimeViewModel.performLifeShapeMutation", commandKind: .placeStepInTime,
            status: .durable, rationale: "Time executes through the durable command journal and SQLite authority, then reloads the Life Calendar projection.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["FileCommandJournal", "EventStoreSQLite", "LifeCalendarStore"],
            eventKind: "ambitions.step.placed", projectionOwner: "RepositoryBackedTimeService", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeCommandReplayTests/testUndoRequiresReceiptAndProjectionVersionAndCannotApplyTwice",
            proofTestIDs: [
                "AmbitionsTests/TimeDurableMutationIntegrationTests/testPlaceStepSurvivesRuntimeRestartWithIdenticalProjectionReceiptAndSchedule",
                "AmbitionsTests/TimeDurableMutationIntegrationTests/testDuplicateCommandReturnsOneReceiptOneJournalEnvelopeAndOneScheduleBlock"
            ]
        ),
        mutation(
            id: "time.protected-placement-approval", sourcePath: "TimeViewModel.approveProtectedPlacementReview", commandKind: .placeStepInTime,
            status: .durable, rationale: "Explicit protected-placement approval executes the same durable Time command and reloads committed projection state.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["FileCommandJournal", "EventStoreSQLite", "LifeCalendarStore"],
            eventKind: "ambitions.step.placed", projectionOwner: "RepositoryBackedTimeService", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeDurableMutationIntegrationTests/testPlaceStepSurvivesRuntimeRestartWithIdenticalProjectionReceiptAndSchedule",
            proofTestIDs: ["AmbitionsTests/TimeProtectedPlacementReviewTests/testP2BBApproveProtectedReviewAppliesPlacementAfterExplicitAction"]
        ),
        mutation(
            id: "time.undo", sourcePath: "TimeViewModel.undoLastLifeShapeMutation", commandKind: .correctTimeWindow,
            status: .durable, rationale: "Undo requires the original committed receipt and expected projection version, emits a semantic undo, and reconstructs the schedule on replay.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["FileCommandJournal", "EventStoreSQLite", "LifeCalendarStore"],
            eventKind: "ambitions.mutation.undone", projectionOwner: "RepositoryBackedTimeService", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeCommandReplayTests/testUndoRequiresReceiptAndProjectionVersionAndCannotApplyTwice",
            proofTestIDs: [
                "AmbitionsTests/TimeCommandReplayTests/testUndoRejectsStaleProjectionVersionWithoutChangingSchedule",
                "AmbitionsTests/TimeCommandReplayTests/testUndoRequiresReceiptAndProjectionVersionAndCannotApplyTwice"
            ]
        ),
        mutation(id: "time.calendar-aware-view-model", sourcePath: "TimeViewModel.makeCalendarAware", commandKind: .scheduleItem, status: .unproven, rationale: "Time ViewModel calendar-aware action delegates to a legacy projection service."),
        mutation(id: "today.view-model-action", sourcePath: "TodayViewModel.handle", commandKind: .completeAction, status: .unproven, rationale: "Today ViewModel action has no row-specific restart and replay evidence."),
        mutation(
            id: "today.view-model-closure", sourcePath: "TodayViewModel.confirmActionClosure", commandKind: .completeAction,
            status: .durable, rationale: "Today closure confirmation delegates to the runtime receipt command, then refreshes committed projection-backed state without applying a synthetic stage mutation.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["EventStoreSQLite", "ProjectionStoreSQLite", "ActionReceiptHistoryRepository"],
            eventKind: "ambitions.today.receipt_recorded", projectionOwner: "TodayProjection", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testClosureRestartReplaysExactAuthorityReceiptAndReconstructsHistoryOnce",
            proofTestIDs: [
                "AmbitionsTests/TodayClosureRuntimeTests/testActionClosureRefreshIgnoresSyntheticStageMutationFromCommandResponse",
                "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testPostAuthorityHistoryFailureReturnsNoVisibleSuccessAndReplayRepairsMaterialization"
            ]
        ),
        mutation(id: "today.inline-action", sourcePath: "TodayCommandActionHandler.performAction", commandKind: .completeAction, status: .unproven, rationale: "Today handler lineage lacks row-specific atomic restart and replay proof."),
        mutation(
            id: "today.goal-step-action", sourcePath: "SwiftDataTodayGoalStepActionMaterializer.materialize", commandKind: .completeAction,
            status: .durable,
            rationale: "Seven Today goal-step actions validate revision, commit one semantic event and receipt, then idempotently materialize exact post-authority snapshots.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["EventStoreSQLite", "ProjectionStoreSQLite", "AmbitionsPersistenceStore"],
            eventKind: "ambitions.today.goal_step_action_applied", projectionOwner: "TodayProjection", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
            proofTestIDs: [
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testJournalFailureLeavesAllDerivedStoresUnchanged",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogPlanCarriesExactDeterministicCaptureWithoutPreparingWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogUsesCompositeSemanticEventInsteadOfGenericCaptureEvent",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testStaleRevisionBlocksBeforeAuthorityCommit",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testIntermediateFailureRollsBackAllDerivedWritesAndReplayRepairsOnce",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testQuickLogCaptureFailureRollsBackCaptureAndEvidenceTogether",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testRecurringCompletionPreservesStepAndAdvancesCadence"
            ]
        ),
        mutation(
            id: "today.goal-step-action.repository-materializer", sourcePath: "RepositoryTodayGoalStepActionMaterializer.materialize", commandKind: .completeAction,
            status: .projectionOnly,
            rationale: "The in-memory repository fallback has post-authority idempotency proof, but it does not own live SwiftData storage or mutation authority.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.today.goal_step_action_applied", projectionOwner: "TodayProjection", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
            proofTestIDs: [
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testJournalFailureLeavesAllDerivedStoresUnchanged",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogRepositoryFallbackIsIdempotent"
            ]
        ),
        mutation(id: "today.feature-action", sourcePath: "RepositoryBackedTodayService.performAction", commandKind: .completeAction, status: .unproven, rationale: "Repository-backed Today action still has legacy repository mutation paths."),
        mutation(id: "today.recommendation-rejection", sourcePath: "RepositoryBackedTodayService.recordRecommendationRejection", commandKind: .dismissRecommendation, status: .unproven, rationale: "Recommendation rejection lacks row-specific replay equivalence proof."),
        mutation(id: "today.action-closure", sourcePath: "RepositoryBackedTodayService.recordActionClosure", commandKind: .completeAction, status: .unproven, rationale: "Action closure lacks row-specific atomic persistence proof."),
        mutation(
            id: "today.receipt-rejection", sourcePath: "TodayReceiptCommandService.recordRecommendationRejection", commandKind: .dismissRecommendation,
            status: .durable, rationale: "Recommendation rejection commits an exact semantic receipt snapshot before idempotent ActionReceiptHistory materialization and verifies the committed Today projection cursor.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["EventStoreSQLite", "ProjectionStoreSQLite", "ActionReceiptHistoryRepository"],
            eventKind: "ambitions.today.receipt_recorded", projectionOwner: "TodayProjection", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testRecommendationRejectionRestartReconstructsSensitiveReceiptWithoutDoubleApply",
            proofTestIDs: ["AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testRecommendationRejectionRestartReconstructsSensitiveReceiptWithoutDoubleApply"]
        ),
        mutation(
            id: "today.receipt-closure", sourcePath: "TodayReceiptCommandService.recordActionClosure", commandKind: .completeAction,
            status: .durable, rationale: "Closure commits an exact semantic receipt snapshot before idempotent ActionReceiptHistory materialization; restart returns the same authority receipt and projection checksum.",
            executorOwner: "AmbitionsCommandExecutor", durableStores: ["EventStoreSQLite", "ProjectionStoreSQLite", "ActionReceiptHistoryRepository"],
            eventKind: "ambitions.today.receipt_recorded", projectionOwner: "TodayProjection", receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testClosureRestartReplaysExactAuthorityReceiptAndReconstructsHistoryOnce",
            proofTestIDs: [
                "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testAuthorityFailureLeavesHistoryAndProjectionEmpty",
                "AmbitionsTests/TodayDurableReceiptMutationIntegrationTests/testPostAuthorityHistoryFailureReturnsNoVisibleSuccessAndReplayRepairsMaterialization"
            ]
        ),
        mutation(id: "goals.view-model-action", sourcePath: "GoalDetailViewModel.perform", commandKind: .updateGoal, status: .unproven, rationale: "Goal Detail action delegates to legacy feature-service mutation."),
        mutation(id: "goals.view-model-clarification", sourcePath: "GoalDetailViewModel.saveClarificationAnswer", commandKind: .updateGoal, status: .unproven, rationale: "Clarification answer lacks durable event and replay proof."),
        mutation(id: "goals.view-model-correction", sourcePath: "GoalDetailViewModel.submitExplainabilityCorrection", commandKind: .updateGoal, status: .unproven, rationale: "Explainability correction lacks row-specific durable lineage proof."),
        mutation(id: "goals.view-model-create", sourcePath: "CreateGoalViewModel.submit", commandKind: .createGoal, status: .unproven, rationale: "Create Goal submit delegates to repository-backed creation without restart proof."),
        mutation(id: "goals.create", sourcePath: "RepositoryBackedGoalsService.createGoal", commandKind: .createGoal, status: .unproven, rationale: "Goal creation retains legacy repository writes outside proven atomic commit."),
        mutation(id: "goals.detail-action", sourcePath: "RepositoryBackedGoalsService.performAction", commandKind: .updateGoal, status: .unproven, rationale: "Goal action retains legacy repository mutation branches."),
        mutation(id: "goals.mutation", sourcePath: "RepositoryBackedGoalsService.performMutation", commandKind: .updateGoal, status: .unproven, rationale: "Goal mutation helper has no durable command replay proof."),
        mutation(id: "goals.creation-save", sourcePath: "RepositoryBackedGoalsService.saveGoalCreation", commandKind: .createGoal, status: .unproven, rationale: "Goal creation save is a legacy unit-of-work compatibility write."),
        mutation(id: "goals.clarification-save", sourcePath: "RepositoryBackedGoalsService.saveClarificationMaterialization", commandKind: .updateGoal, status: .unproven, rationale: "Clarification materialization lacks event-first reconstruction proof."),
        mutation(id: "goals.adaptive-recommendation", sourcePath: "RepositoryBackedGoalsService.applyAdaptiveRecommendation", commandKind: .updateGoal, status: .unproven, rationale: "Adaptive recommendation writes repositories without row-specific replay proof."),
        mutation(id: "goals.adjust-priority", sourcePath: "RepositoryBackedGoalsService.adjustPriority", commandKind: .setPriority, status: .unproven, rationale: "Priority adjustment lacks durable idempotency and replay evidence."),
        mutation(id: "goals.materialize-draft", sourcePath: "RepositoryBackedGoalsService.materializeDraft", commandKind: .updateGoal, status: .unproven, rationale: "Draft materialization lacks authoritative event reconstruction proof."),
        mutation(id: "goals.teaching-signal", sourcePath: "GoalTeachingSignalService.capture", commandKind: .updateGoal, status: .unproven, rationale: "Teaching signal persistence lacks row-specific receipt and replay tests."),
        mutation(id: "capture.quick-create", sourcePath: "CaptureViewModel.createQuickCapture", commandKind: .quickCapture, status: .unproven, rationale: "One Capture ViewModel overload still calls CaptureServicing directly."),
        mutation(id: "capture.needs-place", sourcePath: "CaptureViewModel.saveToNeedsPlace", commandKind: .routeCommitment, status: .unproven, rationale: "Needs Place action writes through legacy CaptureServicing."),
        mutation(id: "capture.archive", sourcePath: "CaptureViewModel.archive", commandKind: .archiveItem, status: .unproven, rationale: "Capture archive lacks row-specific durable replay evidence."),
        mutation(id: "capture.route-time", sourcePath: "CaptureViewModel.routeToTime", commandKind: .scheduleItem, status: .unproven, rationale: "Capture route-to-Time uses a legacy service mutation."),
        mutation(id: "capture.waiting-view-model", sourcePath: "CaptureViewModel.markWaiting", commandKind: .markWaiting, status: .unproven, rationale: "Capture Waiting action uses legacy CaptureServicing without durable lineage."),
        mutation(id: "capture.optional-view-model", sourcePath: "CaptureViewModel.markOptionalSomeday", commandKind: .delayAction, status: .unproven, rationale: "Capture optional action lacks restart and replay proof."),
        mutation(id: "capture.deliverable-view-model", sourcePath: "CaptureViewModel.markDeliverableSeed", commandKind: .addDeliverable, status: .unproven, rationale: "Capture deliverable seed lacks authoritative event proof."),
        mutation(id: "capture.attach-view-model", sourcePath: "CaptureViewModel.attachToGoal", commandKind: .attachToGoal, status: .unproven, rationale: "Capture attachment lacks atomic cross-object replay proof."),
        mutation(id: "capture.goal-view-model", sourcePath: "CaptureViewModel.turnIntoGoal", commandKind: .createGoal, status: .unproven, rationale: "Capture-to-Goal conversion lacks atomic restart proof."),
        mutation(id: "capture.create", sourcePath: "DefaultCaptureService.createCapture", commandKind: .quickCapture, status: .unproven, rationale: "Default Capture creation mutates legacy repositories before full lineage proof."),
        mutation(
            id: "capture.semantic-snapshot-materialization",
            sourcePath: "DefaultCaptureService.materializeCaptureSnapshot",
            commandKind: .quickCapture,
            status: .projectionOnly,
            rationale: "The Capture repository write materializes the exact full snapshot from the already committed ambitions.capture.created semantic event and is idempotently recovered on authority replay.",
            executorOwner: "EventStoreSQLite.commitAuthority",
            durableStores: ["EventStoreSQLite", "CaptureRepository"],
            eventKind: "ambitions.capture.created",
            projectionOwner: "DefaultCaptureService",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/RuntimeAtomicCommitTests/testCommittedCaptureMaterializationCatchesUpOnReplay",
            proofTestIDs: [
                "AmbitionsTests/RuntimeAtomicCommitTests/testQuickCaptureAuthorityFailureLeavesNoCaptureMaterialization",
                "AmbitionsTests/RuntimeAtomicCommitTests/testPublicExecutorRestartReplaysExactAuthorityReceiptAndOneSemanticTransition",
                "AmbitionsTests/RuntimeDomainEventReplayTests/testEmptyDerivedStoresReconstructFromPersistedSemanticJournal"
            ]
        ),
        mutation(id: "capture.update-state", sourcePath: "DefaultCaptureService.updateCaptureState", commandKind: .updateGoal, status: .unproven, rationale: "Capture state update lacks event-first reconstruction proof."),
        mutation(id: "capture.update-route", sourcePath: "DefaultCaptureService.updateCaptureRoute", commandKind: .routeCommitment, status: .unproven, rationale: "Capture route update lacks row-specific replay evidence."),
        mutation(id: "capture.one-time", sourcePath: "DefaultCaptureService.markAsOneTimeCommitment", commandKind: .routeCommitment, status: .unproven, rationale: "One-time commitment conversion lacks durable lineage proof."),
        mutation(id: "capture.deadline", sourcePath: "DefaultCaptureService.markAsDeadlineTask", commandKind: .setDeadline, status: .unproven, rationale: "Deadline conversion lacks durable event and replay proof."),
        mutation(id: "capture.goal-seed", sourcePath: "DefaultCaptureService.markAsGoalSeed", commandKind: .routeCommitment, status: .unproven, rationale: "Goal seed conversion lacks authoritative commit proof."),
        mutation(id: "capture.goal-support", sourcePath: "DefaultCaptureService.markAsGoalSupportingTask", commandKind: .attachToGoal, status: .unproven, rationale: "Goal-support conversion lacks atomic cross-object proof."),
        mutation(id: "capture.deliverable", sourcePath: "DefaultCaptureService.markAsDeliverableSeed", commandKind: .addDeliverable, status: .unproven, rationale: "Deliverable seed persistence lacks restart proof."),
        mutation(id: "capture.waiting", sourcePath: "DefaultCaptureService.markAsWaiting", commandKind: .markWaiting, status: .unproven, rationale: "Waiting persistence lacks durable receipt and replay proof."),
        mutation(id: "capture.optional", sourcePath: "DefaultCaptureService.markAsOptionalSomeday", commandKind: .delayAction, status: .unproven, rationale: "Optional-Someday persistence lacks replay proof."),
        mutation(id: "capture.plan-seed", sourcePath: "DefaultCaptureService.routeToPlanSeed", commandKind: .routeCommitment, status: .unproven, rationale: "Plan seed routing lacks authoritative event proof."),
        mutation(id: "capture.time-seed", sourcePath: "DefaultCaptureService.routeToTimeSeed", commandKind: .scheduleItem, status: .unproven, rationale: "Time seed routing lacks durable scheduling replay proof."),
        mutation(id: "capture.attach-goal", sourcePath: "DefaultCaptureService.attachCaptureToGoal", commandKind: .attachToGoal, status: .unproven, rationale: "Capture-to-Goal attachment lacks atomic replay proof."),
        mutation(id: "capture.turn-into-goal", sourcePath: "DefaultCaptureService.turnCaptureIntoGoal", commandKind: .createGoal, status: .unproven, rationale: "Capture-to-Goal creation lacks restart equivalence proof."),
        mutation(id: "capture.processed", sourcePath: "DefaultCaptureService.markCaptureProcessed", commandKind: .completeAction, status: .unproven, rationale: "Processed state lacks row-specific event replay proof."),
        mutation(id: "capture.archived", sourcePath: "DefaultCaptureService.markCaptureArchived", commandKind: .archiveItem, status: .unproven, rationale: "Archived state lacks row-specific durable lineage proof."),
        mutation(id: "you.view-model-preferences", sourcePath: "YouViewModel.commitPreferences", commandKind: .updateUserPreferences, status: .unproven, rationale: "You ViewModel preference commit lacks restart and replay proof."),
        mutation(id: "you.preferences", sourcePath: "RepositoryBackedYouService.saveYouPreferences", commandKind: .updateUserPreferences, status: .unproven, rationale: "Repository-backed preference save lacks authoritative replay proof."),
        mutation(id: "you.preferences-command", sourcePath: "YouPreferencesCommandService.saveYouPreferences", commandKind: .updateUserPreferences, status: .unproven, rationale: "Command service source presence lacks row-specific reconstruction proof."),
        mutation(id: "onboarding.complete", sourcePath: "RepositoryBackedOnboardingService.complete", commandKind: .updateUserPreferences, status: .unproven, rationale: "Onboarding completion writes app state through compatibility storage."),
        mutation(id: "time.calendar-aware", sourcePath: "RepositoryBackedTimeService.makeTimeCalendarAware", commandKind: .scheduleItem, status: .unproven, rationale: "Calendar-aware service appends a legacy projection ledger mirror."),
        mutation(
            id: "time.ritual-action",
            sourcePath: "SwiftDataTimeRitualActionMaterializer.materialize",
            commandKind: .updateGoal,
            status: .durable,
            rationale: "Seven Time ritual actions commit one semantic authority event before atomic, target-validated SwiftData materialization.",
            executorOwner: "AmbitionsCommandExecutor",
            durableStores: ["EventStoreSQLite", "ProjectionStoreSQLite", "AmbitionsPersistenceStore"],
            eventKind: "ambitions.time.ritual_action_applied",
            projectionOwner: "TimeProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeRitualOwnerWriteTests/testAuthorityReplayAfterRestartMaterializesExactlyOnce",
            proofTestIDs: [
                "AmbitionsTests/TimeRitualOwnerWriteTests/testPreparationIsDeterministicAndDoesNotWriteRepositories",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testDuplicateCompletionAtSameRevisionUsesOneCommandIdentity",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testDistinctQuickLogInvocationsFromSameLoadedRowHaveDistinctAuthorityIdentity",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testAuthorityReplayAfterRestartMaterializesExactlyOnce",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testAtomicFailureRollsBackGoalFeedbackAndEvidence",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testDeletedGoalRaceCannotInsertQuickLogEvidence",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testRemovedStepRaceCannotInsertArtifactsOrRestoreStep",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testCompleteMinimumSkipAndNeedsEasierMaterializeTheirExactOwnedChanges",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testJournalFailureProducesNoAuthorityOrDerivedWrites",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testViewModelPublishesSuccessOnlyForMatchingMaterializedTimeCursor"
            ]
        ),
        mutation(
            id: "time.ritual-action.repository-materializer",
            sourcePath: "RepositoryTimeRitualActionMaterializer.materialize",
            commandKind: .updateGoal,
            status: .projectionOnly,
            rationale: "The non-transactional repository fallback fails closed and never claims atomic materialization.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.time.ritual_action_applied",
            projectionOwner: "TimeProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeRitualOwnerWriteTests/testRepositoryFallbackFailsClosedWithoutPartialWrites",
            proofTestIDs: [
                "AmbitionsTests/TimeRitualOwnerWriteTests/testRepositoryFallbackFailsClosedWithoutPartialWrites"
            ]
        ),
        mutation(
            id: "time.ritual-view-model-adapter",
            sourcePath: "TimeRitualsViewModel.perform",
            commandKind: .updateGoal,
            status: .adapter,
            rationale: "The Time Ritual ViewModel executes the authority-owned command and requires its receipt, materialization, and exact Time projection cursor before success.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.time.ritual_action_applied",
            projectionOwner: "TimeProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeRitualOwnerWriteTests/testAuthorityReplayAfterRestartMaterializesExactlyOnce",
            proofTestIDs: [
                "AmbitionsTests/TimeRitualOwnerWriteTests/testViewModelPublishesSuccessOnlyForMatchingMaterializedTimeCursor"
            ]
        ),
        mutation(
            id: "time.command-view-model-adapter",
            sourcePath: "TimeViewModel.executeTimeCommand",
            commandKind: .placeStepInTime,
            status: .adapter,
            rationale: "The Time ViewModel delegates to the authority-owned runtime command and accepts visible success only for matching committed Time projection lineage.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.time.window_protected",
            projectionOwner: "TimeProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeDurableMutationIntegrationTests/testPlaceStepSurvivesRuntimeRestartWithIdenticalProjectionReceiptAndSchedule",
            proofTestIDs: [
                "AmbitionsTests/TimeDurableMutationIntegrationTests/testRealExecutorProjectionClientAndViewModelAcceptMatchingCursorLineage",
                "AmbitionsTests/TimeDurableMutationIntegrationTests/testStaleProjectionCannotBePresentedAsSuccessForNewReceipt"
            ]
        ),
        mutation(id: "step.create", sourcePath: "SimpleStepLifecycleService.createSimpleStep", commandKind: .addGoalScopeItem, status: .unproven, rationale: "Simple Step creation lacks row-specific atomic replay proof."),
        mutation(id: "step.place", sourcePath: "SimpleStepLifecycleService.placeStepInTime", commandKind: .placeStepInTime, status: .unproven, rationale: "Step placement lacks authoritative scheduling event proof."),
        mutation(id: "step.recover", sourcePath: "SimpleStepLifecycleService.markMissedStepForRecovery", commandKind: .recoverAction, status: .unproven, rationale: "Missed-step recovery lacks durable restart proof."),
        mutation(id: "step.recurring-create", sourcePath: "SimpleStepLifecycleService.createRecurringStep", commandKind: .addGoalScopeItem, status: .unproven, rationale: "Recurring Step creation lacks replay equivalence proof."),
        mutation(id: "step.recurring-complete", sourcePath: "SimpleStepLifecycleService.completeRecurringOccurrence", commandKind: .completeAction, status: .unproven, rationale: "Recurring occurrence completion lacks atomic lineage proof."),
        mutation(id: "step.recurring-pause", sourcePath: "SimpleStepLifecycleService.pauseRecurrence", commandKind: .delayAction, status: .unproven, rationale: "Recurrence pause lacks durable command replay proof."),
        mutation(id: "step.recurring-resume", sourcePath: "SimpleStepLifecycleService.resumeRecurrence", commandKind: .recoverAction, status: .unproven, rationale: "Recurrence resume lacks durable command replay proof."),
        mutation(id: "notification.action", sourcePath: "AppBootstrapper.handleNotificationPayload", commandKind: .openDestination, status: .unproven, rationale: "Notification payload handling lacks row-specific lifecycle and replay tests."),
        mutation(id: "widget.action", sourcePath: "AppBootstrapper.handleWidgetPayload", commandKind: .openDestination, status: .unproven, rationale: "Widget payload handling lacks row-specific lifecycle and replay tests."),
        mutation(id: "app-intent.capture", sourcePath: "CreateAmbitionsCaptureIntent.perform", commandKind: .quickCapture, status: .unproven, rationale: "App Intent capture handoff lacks terminated-app lineage proof."),
        mutation(id: "app-intent.goal-draft", sourcePath: "CreateAmbitionsGoalDraftIntent.perform", commandKind: .createGoal, status: .unproven, rationale: "App Intent goal draft handoff lacks terminated-app lineage proof."),
        mutation(id: "share.intake", sourcePath: "ShareExtensionIntake.recordDurableIntake", commandKind: .quickCapture, status: .unproven, rationale: "Share intake lacks row-specific extension lifecycle and replay proof."),
        mutation(id: "eventkit.outbox", sourcePath: "EventKitOutbox.recordCalendarSideEffect", commandKind: .scheduleItem, status: .unproven, rationale: "EventKit outbox path lacks row-specific end-to-end replay proof."),
        mutation(id: "eventkit.outbox-result", sourcePath: "EventKitOutbox.recordCalendarResult", commandKind: .scheduleItem, status: .unproven, rationale: "External result receipt mutation lacks row-specific replay and reconciliation proof."),
        mutation(
            id: "eventkit.outbox-result-strict",
            sourcePath: "EventKitOutbox.recordCalendarResultStrict",
            commandKind: .scheduleItem,
            status: .unproven,
            rationale: "Strict external result finalization has focused CAS and reconciliation tests but lacks device proof."
        ),
        mutation(id: "widget.outbox", sourcePath: "WidgetRefreshOutbox.recordSnapshotRefresh", commandKind: .openDestination, status: .unproven, rationale: "Widget refresh outbox lacks row-specific reconstruction proof."),
        mutation(id: "repair.portable-snapshot", sourcePath: "PortableSnapshotService.importSnapshot", commandKind: .updateGoal, status: .unproven, rationale: "Portable snapshot import lacks complete migration and replay proof."),
        mutation(id: "shell.activated-capture", sourcePath: "AppShellActivatedCaptureSeam.saveCapture", commandKind: .quickCapture, status: .unproven, rationale: "Global shell command execution lacks row-specific restart and replay proof."),
        mutation(id: "app-intent.bridge-enqueue", sourcePath: "AppIntentBridge.enqueueExternalCreation", commandKind: .quickCapture, status: .unproven, rationale: "App Intent bridge enqueue lacks row-specific terminated-app replay and reconciliation proof."),
        mutation(id: "app-intent.bridge-command", sourcePath: "AppIntentBridge.recordCommandBridge", commandKind: .quickCapture, status: .unproven, rationale: "App Intent command bridge lacks row-specific durable receipt and replay proof."),
        mutation(id: "external-creation.import", sourcePath: "DefaultExternalCreationImportService.importPendingCreations", commandKind: .quickCapture, status: .unproven, rationale: "External creation import lacks row-specific idempotent restart and reconciliation proof."),
        mutation(id: "shell.command-router", sourcePath: "DefaultShellCommandRouter.execute", commandKind: .openDestination, status: .unproven, rationale: "Shell command routing spans mutation kinds without row-specific durable replay proof."),
        mutation(id: "eventkit.integration-side-effect", sourcePath: "EventKitIntegrationService.recordCalendarSideEffect", commandKind: .scheduleItem, status: .unproven, rationale: "EventKit integration side-effect recording lacks row-specific device restart and replay proof."),
        mutation(id: "eventkit.integration-result", sourcePath: "EventKitIntegrationService.recordCalendarResult", commandKind: .scheduleItem, status: .unproven, rationale: "EventKit integration result recording lacks row-specific reconciliation and replay proof."),
        mutation(id: "notification.outbox-refresh", sourcePath: "NotificationOutbox.recordRefresh", commandKind: .openDestination, status: .unproven, rationale: "Notification refresh outbox mutation lacks row-specific restart and reconstruction proof."),
        mutation(id: "repair.portable-merge", sourcePath: "PortableSnapshotService.mergeWithConflictReport", commandKind: .updateGoal, status: .unproven, rationale: "Portable snapshot merge lacks complete conflict reconciliation and replay proof."),
        mutation(id: "repair.portable-replace", sourcePath: "PortableSnapshotService.replaceLocalStore", commandKind: .updateGoal, status: .unproven, rationale: "Portable snapshot replacement lacks complete rollback and replay proof."),
        mutation(id: "repair.receipt-history-save", sourcePath: "PortableSnapshotService.saveActionReceiptHistory", commandKind: .completeAction, status: .unproven, rationale: "Imported action receipt history lacks row-specific restart and replay equivalence proof."),
        mutation(id: "repair.tombstone-save", sourcePath: "PortableSnapshotService.saveEntityRevisionTombstones", commandKind: .updateGoal, status: .unproven, rationale: "Imported revision tombstones lack row-specific restart and replay equivalence proof."),
        mutation(id: "goals.detail-materialization", sourcePath: "RepositoryBackedGoalsService.makeDetail", commandKind: .updateGoal, status: .unproven, rationale: "Goal detail materialization may persist repository state without row-specific replay proof."),
        mutation(id: "today.feedback-action", sourcePath: "RepositoryBackedTodayService.performFeedbackAction", commandKind: .completeAction, status: .unproven, rationale: "Today feedback action mutates legacy repositories without row-specific atomic replay proof."),
        mutation(id: "repair.restore-rollback", sourcePath: "RestoreRollback.restoreSnapshotWithRollback", commandKind: .updateGoal, status: .unproven, rationale: "Restore rollback mutation lacks row-specific crash-boundary and replay proof."),
        mutation(id: "preview.capture-seed", sourcePath: "PersistenceBootstrap.applyPreviewCaptureSeedIfNeeded", commandKind: .quickCapture, status: .unproven, rationale: "Preview capture seeding lacks row-specific isolation and replay proof for its repository mutation."),
        mutation(id: "runtime.command-envelope", sourcePath: "AmbitionsCommandExecutor.appendCommandEnvelope", commandKind: .updateGoal, status: .unproven, rationale: "Command envelope append lacks row-specific atomic event, receipt, and replay proof."),
        mutation(id: "runtime.attach-goal", sourcePath: "AmbitionsCommandExecutor.executeAttachToGoal", commandKind: .attachToGoal, status: .unproven, rationale: "Attach-to-Goal execution lacks row-specific atomic restart and replay proof."),
        mutation(id: "runtime.calendar-write", sourcePath: "AmbitionsCommandExecutor.executeConfirmedCalendarWriteIntent", commandKind: .scheduleItem, status: .unproven, rationale: "Confirmed calendar write execution lacks row-specific device reconciliation and replay proof."),
        mutation(id: "runtime.plan-seed", sourcePath: "AmbitionsCommandExecutor.executePlanSeedRepresentation", commandKind: .routeCommitment, status: .unproven, rationale: "Plan-seed execution lacks row-specific durable reconstruction proof."),
        mutation(id: "runtime.quick-capture", sourcePath: "AmbitionsCommandExecutor.executeQuickCapture", commandKind: .quickCapture, status: .unproven, rationale: "Quick Capture execution lacks row-specific atomic restart and replay proof."),
        mutation(
            id: "runtime.quick-capture-materialization",
            sourcePath: "AmbitionsCommandExecutor.materializeQuickCapture",
            commandKind: .quickCapture,
            status: .projectionOnly,
            rationale: "Capture object persistence is a post-authority materialization recovered from the committed semantic event on replay.",
            executorOwner: "EventStoreSQLite.commitAuthority",
            durableStores: ["EventStoreSQLite", "CaptureRepository"],
            eventKind: "ambitions.capture.created",
            projectionOwner: "DefaultCaptureService",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/RuntimeAtomicCommitTests/testCommittedCaptureMaterializationCatchesUpOnReplay",
            proofTestIDs: [
                "AmbitionsTests/RuntimeAtomicCommitTests/testQuickCaptureAuthorityFailureLeavesNoCaptureMaterialization",
                "AmbitionsTests/RuntimeAtomicCommitTests/testCommittedCaptureMaterializationCatchesUpOnReplay"
            ]
        ),
        mutation(id: "runtime.route-commitment", sourcePath: "AmbitionsCommandExecutor.executeRouteCommitment", commandKind: .routeCommitment, status: .unproven, rationale: "Commitment routing execution lacks row-specific atomic replay proof."),
        mutation(
            id: "stage.capture-attachment",
            sourcePath: "CaptureGoalHandoffService.perform",
            commandKind: .attachToGoal,
            status: .durable,
            rationale: "Stage renders the typed result of an authority-first Capture-to-Goal handoff; the semantic event and atomic SwiftData materializer own replay and projection.",
            executorOwner: "AmbitionsCommandExecutor",
            durableStores: ["EventStoreSQLite", "CaptureRepository"],
            eventKind: "ambitions.capture.goal_handoff_applied",
            projectionOwner: "GoalsProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testDuplicateExecutionAndRestartReplayApplyTransitionOnce",
            proofTestIDs: [
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testAuthoritySuccessAtomicallyConnectsSeedCaptureAndCreatedGoalIDs",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testJournalFailureAndTypedOutcomePreventFalseStageSuccess",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testFreshServiceRetryAfterRestartIsLogicalSuccessAndDifferentGoalCannotRebind",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testPreviewContainerExecutesEndToEndWithRealProjectionAndMaterializer"
            ]
        ),
        mutation(
            id: "stage.capture-attachment-materialization",
            sourcePath: "SwiftDataCaptureGoalHandoffMaterializer.materialize",
            commandKind: .attachToGoal,
            status: .projectionOnly,
            rationale: "The atomic Capture transition materializes only after the semantic authority event commits and converges idempotently on replay.",
            executorOwner: "AmbitionsCommandExecutor",
            durableStores: ["CaptureRepository"],
            eventKind: "ambitions.capture.goal_handoff_applied",
            projectionOwner: "GoalsProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testDuplicateExecutionAndRestartReplayApplyTransitionOnce",
            proofTestIDs: [
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testInjectedMaterializerFailureRollsBackCaptureTransition",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testConcurrentGoalEditIsPreservedBecauseHandoffOwnsOnlyCaptureState",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testMissingOrRecreatedGoalBlocksInitialCommitBeforeIdempotentCaptureReturn"
            ]
        ),
        mutation(id: "prototype.runtime-perform", sourcePath: "DedicatedDevicePrototypeRuntime.perform", commandKind: .updateGoal, status: .unproven, rationale: "Prototype runtime mutation lacks production durable lineage and replay proof."),
        mutation(id: "capture.event-append", sourcePath: "DefaultCaptureService.appendCaptureEvent", commandKind: .quickCapture, status: .unproven, rationale: "Capture event append lacks row-specific projection, receipt, and replay proof."),
        mutation(id: "external-action.execute", sourcePath: "DefaultExternalActionCommandService.execute", commandKind: .completeAction, status: .unproven, rationale: "External action execution lacks row-specific durable reconciliation and replay proof."),
        mutation(id: "external-action.rejection", sourcePath: "DefaultExternalActionCommandService.recordRejectedExternalActionIfNeeded", commandKind: .dismissRecommendation, status: .unproven, rationale: "Rejected external action recording lacks row-specific restart and replay proof."),
        mutation(id: "goal.teaching-signal", sourcePath: "DefaultGoalTeachingSignalService.capture", commandKind: .updateGoal, status: .unproven, rationale: "Goal teaching-signal capture lacks row-specific receipt and replay proof."),
        mutation(id: "startup.prepare-session", sourcePath: "DefaultStartupService.prepareSession", commandKind: .updateGoal, status: .unproven, rationale: "Startup session preparation may commit runtime repair state without row-specific replay proof."),
        mutation(id: "demo.time-foundation-seed", sourcePath: "DemoSeedPipeline.applyRenderedTimeFoundationSeedIfNeeded", commandKind: .placeStepInTime, status: .unproven, rationale: "Rendered Time demo seeding lacks row-specific isolation and replay proof."),
        mutation(id: "demo.seed", sourcePath: "DemoSeedPipeline.seedIfNeeded", commandKind: .updateGoal, status: .unproven, rationale: "Demo seed pipeline mutation lacks row-specific isolation and replay proof."),
        mutation(id: "inspection.record", sourcePath: "InspectionRecorder.record", commandKind: .updateGoal, status: .unproven, rationale: "Inspection recording lacks row-specific projection-only and restart proof."),
        mutation(id: "preferences.repository-save", sourcePath: "RepositoryBackedAppPreferencesStore.savePreferences", commandKind: .updateUserPreferences, status: .unproven, rationale: "Repository-backed preference save lacks row-specific durable replay proof."),
        mutation(id: "runtime.committer", sourcePath: "RuntimeCommandMutationCommitter.commit", commandKind: .updateGoal, status: .unproven, rationale: "Runtime mutation commit lacks row-specific atomic event, projection, receipt, and replay proof."),
        mutation(id: "runtime.transaction-commit", sourcePath: "RuntimeTransactionCoordinator.commit", commandKind: .updateGoal, status: .unproven, rationale: "Runtime transaction commit lacks row-specific crash-boundary and replay proof."),
        mutation(id: "share.save", sourcePath: "ShareViewController.save", commandKind: .quickCapture, status: .unproven, rationale: "External durable enqueue lacks app-process replay proof."),
        mutation(id: "app-state.swiftdata-save", sourcePath: "SwiftDataAppStateStore.save", commandKind: .updateGoal, status: .unproven, rationale: "SwiftData app-state save lacks row-specific command, receipt, and replay proof."),
        mutation(id: "today.command-evidence", sourcePath: "TodayCommandActionHandler.emitTodayCommandEvidence", commandKind: .completeAction, status: .unproven, rationale: "Today command evidence append lacks row-specific durable receipt and replay proof.")
    ]

    static let writePaths: [MeaningfulMutationWritePathDescriptor] = [
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureAttachmentVault.swift", status: .unproven, rationale: "CaptureAttachmentVault file writes lack row-specific lifecycle proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureRoutingFileStore.swift", status: .unproven, rationale: "CaptureRoutingFileStore writes lack row-specific replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+ScheduleMutationIntent.swift", status: .unproven, rationale: "Schedule mutation intent file access lacks end-to-end durable lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift", status: .unproven, rationale: "CommandJournal storage presence alone does not prove a meaningful mutation lineage."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift", status: .unproven, rationale: "RuntimeEventStore persistence is not row-specific behavior replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox+EventKitStoreClientLive.swift", status: .unproven, rationale: "Live EventKit writes lack row-specific device and replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/FileSideEffectLedgerRepository.swift", status: .unproven, rationale: "File side-effect ledger writes lack row-specific lineage tests."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerSwiftDataRepository.swift", status: .unproven, rationale: "SwiftData side-effect ledger writes lack row-specific restart proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Inspection/ExecutionLedgerReplayInspectionSwiftDataRepository.swift", status: .unproven, rationale: "Execution inspection storage lacks row-specific projection-only proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Inspection/InspectionSwiftDataRepositories.swift", status: .unproven, rationale: "Inspection repositories lack row-specific projection lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift", status: .unproven, rationale: "Encrypted blob writes lack row-specific mutation lineage evidence."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift", status: .unproven, rationale: "Portable snapshot writes lack complete migration replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Repair/StoreInvariantChecker.swift", status: .unproven, rationale: "Store invariant access lacks row-specific repair execution proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift", status: .unproven, rationale: "Life Calendar writes lack durable scheduling lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LocalScheduleBlockFileStore.swift", status: .unproven, rationale: "Local schedule block writes lack restart and replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository+Storage.swift", status: .unproven, rationale: "Public-pack cache storage is inventory-only and lacks row-specific executable adapter proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository.swift", status: .unproven, rationale: "Public-pack cache repository is inventory-only and does not prove adapter lineage."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshService.swift", status: .unproven, rationale: "Public-pack refresh cache access is inventory-only without row-specific lineage tests."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift", status: .unproven, rationale: "App-group snapshot writes lack row-specific projection-only proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift", status: .unproven, rationale: "BackupStore writes lack complete restore and replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift", status: .unproven, rationale: "Blob file-system writes lack row-specific mutation lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift", status: .unproven, rationale: "EventStoreSQLite presence does not prove semantic event reconstruction."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/LocalRuntimeStorageCore.swift", status: .unproven, rationale: "SQLite transaction primitives do not prove meaningful mutation atomicity."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift", status: .unproven, rationale: "MigrationStore writes lack complete migration replay evidence."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreAmbitionGraphProjectionRecordModel.swift", status: .unproven, rationale: "Ambition graph projection model storage lacks row-specific lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreCaptureRecord.swift", status: .unproven, rationale: "Capture record storage lacks row-specific event reconstruction proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreEntityRevisionTombstoneRecord.swift", status: .unproven, rationale: "Tombstone storage lacks row-specific replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreLifeContextPersistence.swift", status: .unproven, rationale: "Life context persistence lacks row-specific mutation lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift", status: .unproven, rationale: "SwiftData object store writes lack complete atomic mutation proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift", status: .unproven, rationale: "Legacy SwiftData migration access lacks complete migration proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift", status: .unproven, rationale: "SwiftData model declarations do not prove mutation lineage."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataRepositories.swift", status: .unproven, rationale: "SwiftData repository construction does not prove command-only mutation."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift", status: .unproven, rationale: "ProjectionStoreSQLite writes lack row-specific projection lineage tests."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift", status: .unproven, rationale: "SearchStoreFTS writes lack row-specific derived-projection proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataAmbitionGraphProjectionRecordRepository.swift", status: .unproven, rationale: "Ambition graph repository writes lack row-specific replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataAppStateRepository.swift", status: .unproven, rationale: "App state repository writes lack command-only lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataGoalPersistenceRepositories.swift", status: .unproven, rationale: "Goal persistence writes lack row-specific event reconstruction proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift", status: .unproven, rationale: "Reminder mirror writes lack row-specific local-commit lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryArrayHelpers.swift", status: .unproven, rationale: "Repository array writes lack row-specific command and replay proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMapping.swift", status: .unproven, rationale: "Repository mapping code does not prove durable mutation lineage."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingApply.swift", status: .unproven, rationale: "Mapping apply code lacks row-specific replay evidence."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingEntityRevisionTombstone.swift", status: .unproven, rationale: "Tombstone mapping lacks row-specific mutation lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingFeedbackRecord.swift", status: .unproven, rationale: "Feedback mapping lacks row-specific mutation lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingPersisted.swift", status: .unproven, rationale: "Persisted mapping helpers do not prove command-only writes."),
        writePath(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRuntimeSnapshotLedgerRepository.swift", status: .unproven, rationale: "Runtime snapshot ledger writes lack row-specific replay equivalence proof."),
        writePath(
            sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/TodayGoalStepActionMaterializer.swift",
            status: .projectionOnly,
            rationale: "SwiftData materialization is a derived Today projection write path with row-specific authority, restart, replay, idempotency, and atomicity proof.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.today.goal_step_action_applied",
            projectionOwner: "TodayProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
            proofTestIDs: [
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testJournalFailureLeavesAllDerivedStoresUnchanged",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogPlanCarriesExactDeterministicCaptureWithoutPreparingWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogUsesCompositeSemanticEventInsteadOfGenericCaptureEvent",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testStaleRevisionBlocksBeforeAuthorityCommit",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testIntermediateFailureRollsBackAllDerivedWritesAndReplayRepairsOnce",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testQuickLogCaptureFailureRollsBackCaptureAndEvidenceTogether",
                "AmbitionsTests/TodayGoalStepActionAtomicityTests/testRecurringCompletionPreservesStepAndAdvancesCadence"
            ]
        ),
        writePath(
            sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/TimeRitualActionMaterializer.swift",
            status: .projectionOnly,
            rationale: "SwiftData materialization is a derived Time projection write path with authority, replay, atomicity, target-existence, and idempotency proof.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.time.ritual_action_applied",
            projectionOwner: "TimeProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/TimeRitualOwnerWriteTests/testAuthorityReplayAfterRestartMaterializesExactlyOnce",
            proofTestIDs: [
                "AmbitionsTests/TimeRitualOwnerWriteTests/testAuthorityReplayAfterRestartMaterializesExactlyOnce",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testDuplicateCompletionAtSameRevisionUsesOneCommandIdentity",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testAtomicFailureRollsBackGoalFeedbackAndEvidence",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testDeletedGoalRaceCannotInsertQuickLogEvidence",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testRemovedStepRaceCannotInsertArtifactsOrRestoreStep",
                "AmbitionsTests/TimeRitualOwnerWriteTests/testCompleteMinimumSkipAndNeedsEasierMaterializeTheirExactOwnedChanges"
            ]
        ),
        writePath(
            sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Storage/CaptureGoalHandoffMaterializer.swift",
            status: .projectionOnly,
            rationale: "The authority-owned Capture-to-Goal transition materializes atomically and advances the Goals projection cursor only after semantic commit.",
            executorOwner: "AmbitionsCommandExecutor",
            eventKind: "ambitions.capture.goal_handoff_applied",
            projectionOwner: "GoalsProjection",
            receiptOwner: "RuntimeCommitReceipt",
            replayTestID: "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testDuplicateExecutionAndRestartReplayApplyTransitionOnce",
            proofTestIDs: [
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testInjectedMaterializerFailureRollsBackCaptureTransition",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testConcurrentGoalEditIsPreservedBecauseHandoffOwnsOnlyCaptureState",
                "AmbitionsTests/CaptureGoalHandoffOwnerWriteTests/testMissingOrRecreatedGoalBlocksInitialCommitBeforeIdempotentCaptureReturn"
            ]
        ),
        writePath(sourcePath: "Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift", status: .unproven, rationale: "Notification support file access lacks row-specific adapter lifecycle proof."),
        writePath(
            sourcePath: "Native/Ambitions/Core/Permissions/CalendarReminders/EventKitPendingOperationIdentityStore.swift",
            status: .unproven,
            rationale: "Pending EventKit operation identity is durable adapter state, not meaningful user-state authority."
        ),
        writePath(
            sourcePath: "Native/Ambitions/App/Bootstrap/PersistenceBootstrap.swift",
            status: .previewOnly,
            rationale: "Preview and demo composition create UUID-isolated projection stores; production mutation authority remains in the runtime event journal."
        ),
        writePath(sourcePath: "Native/Ambitions/PreviewSupport/PreviewAppContainer.swift", status: .previewOnly, rationale: "DEBUG preview temporary storage is not production mutation authority."),
        writePath(sourcePath: "Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift", status: .unproven, rationale: "External creation handoff lacks row-specific terminated-app adapter proof."),
        writePath(sourcePath: "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift", status: .unproven, rationale: "External snapshot writes lack row-specific projection-only lineage proof."),
        writePath(sourcePath: "Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift", status: .unproven, rationale: "Shared snapshot storage lacks row-specific projection lifecycle proof.")
    ]

    private static func mutation(
        id: String,
        sourcePath: String,
        commandKind: AmbitionsCommandKind,
        status: MeaningfulMutationStatus,
        rationale: String,
        executorOwner: String? = nil,
        durableStores: [String] = [],
        eventKind: String? = nil,
        projectionOwner: String? = nil,
        receiptOwner: String? = nil,
        replayTestID: String? = nil,
        proofTestIDs: [String] = []
    ) -> MeaningfulMutationDescriptor {
        MeaningfulMutationDescriptor(
            id: id,
            sourcePath: sourcePath,
            commandKind: commandKind,
            executorOwner: executorOwner,
            durableStores: durableStores,
            eventKind: eventKind,
            projectionOwner: projectionOwner,
            receiptOwner: receiptOwner,
            replayTestID: replayTestID,
            proofTestIDs: proofTestIDs,
            status: status,
            rationale: rationale
        )
    }

    private static func writePath(
        sourcePath: String,
        status: MeaningfulMutationStatus,
        rationale: String,
        executorOwner: String? = nil,
        eventKind: String? = nil,
        projectionOwner: String? = nil,
        receiptOwner: String? = nil,
        replayTestID: String? = nil,
        proofTestIDs: [String] = []
    ) -> MeaningfulMutationWritePathDescriptor {
        MeaningfulMutationWritePathDescriptor(
            sourcePath: sourcePath,
            executorOwner: executorOwner,
            eventKind: eventKind,
            projectionOwner: projectionOwner,
            receiptOwner: receiptOwner,
            replayTestID: replayTestID,
            status: status,
            proofTestIDs: proofTestIDs,
            rationale: rationale
        )
    }
}
