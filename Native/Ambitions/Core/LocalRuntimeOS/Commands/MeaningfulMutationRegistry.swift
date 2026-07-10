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
    let executorOwner: String
    let durableStores: [String]
    let eventKind: String
    let projectionOwner: String
    let receiptOwner: String
    let replayTestID: String
    let proofTestIDs: [String]
    let status: MeaningfulMutationStatus
}

struct MeaningfulMutationWritePathDescriptor: Sendable, Hashable {
    let sourcePath: String
    let status: MeaningfulMutationStatus
    let proofTestID: String
}

enum MeaningfulMutationRegistry {
    private static let inventoryProof =
        "AmbitionsTests/MeaningfulMutationRegistryTests/testRegistryRowsHaveUniqueSemanticIdentityAndExecutableProofIDs"
    private static let unprovenReplayProof =
        "AmbitionsTests/MeaningfulMutationRegistryTests/testKnownSyntheticTimeMutationEntryPointsAreRegisteredAsUnproven"

    static let descriptors: [MeaningfulMutationDescriptor] = [
        mutation("time.life-shape", "TimeViewModel.performLifeShapeMutation", .placeStepInTime),
        mutation("time.protected-placement-approval", "TimeViewModel.approveProtectedPlacementReview", .protectTimeWindow),
        mutation("time.undo", "TimeViewModel.undoLastLifeShapeMutation", .correctTimeWindow),
        mutation("today.inline-action", "TodayCommandActionHandler.performAction", .completeAction),
        mutation("today.feature-action", "RepositoryBackedTodayService.performAction", .completeAction),
        mutation("today.recommendation-rejection", "RepositoryBackedTodayService.recordRecommendationRejection", .dismissRecommendation),
        mutation("today.action-closure", "RepositoryBackedTodayService.recordActionClosure", .completeAction),
        mutation("today.receipt-rejection", "TodayReceiptCommandService.recordRecommendationRejection", .dismissRecommendation),
        mutation("today.receipt-closure", "TodayReceiptCommandService.recordActionClosure", .completeAction),
        mutation("goals.create", "RepositoryBackedGoalsService.createGoal", .createGoal),
        mutation("goals.detail-action", "RepositoryBackedGoalsService.performAction", .updateGoal),
        mutation("goals.clarification", "GoalDetailViewModel.saveClarificationAnswer", .updateGoal),
        mutation("goals.mutation", "RepositoryBackedGoalsService.performMutation", .updateGoal),
        mutation("goals.creation-save", "RepositoryBackedGoalsService.saveGoalCreation", .createGoal),
        mutation("goals.clarification-save", "RepositoryBackedGoalsService.saveClarificationMaterialization", .updateGoal),
        mutation("goals.adaptive-recommendation", "RepositoryBackedGoalsService.applyAdaptiveRecommendation", .updateGoal),
        mutation("goals.adjust-priority", "RepositoryBackedGoalsService.adjustPriority", .setPriority),
        mutation("goals.materialize-draft", "RepositoryBackedGoalsService.materializeDraft", .updateGoal),
        mutation("goals.teaching-signal", "GoalTeachingSignalService.capture", .updateGoal),
        mutation("capture.quick-create", "CaptureViewModel.createQuickCapture", .quickCapture),
        mutation("capture.needs-place", "CaptureViewModel.saveToNeedsPlace", .routeCommitment),
        mutation("capture.archive", "CaptureViewModel.archive", .archiveItem),
        mutation("capture.route-time", "CaptureViewModel.routeToTime", .attachToGoal),
        mutation("capture.create", "DefaultCaptureService.createCapture", .quickCapture),
        mutation("capture.update-state", "DefaultCaptureService.updateCaptureState", .updateGoal),
        mutation("capture.update-route", "DefaultCaptureService.updateCaptureRoute", .routeCommitment),
        mutation("capture.one-time", "DefaultCaptureService.markAsOneTimeCommitment", .routeCommitment),
        mutation("capture.deadline", "DefaultCaptureService.markAsDeadlineTask", .setDeadline),
        mutation("capture.goal-seed", "DefaultCaptureService.markAsGoalSeed", .routeCommitment),
        mutation("capture.goal-support", "DefaultCaptureService.markAsGoalSupportingTask", .attachToGoal),
        mutation("capture.deliverable", "DefaultCaptureService.markAsDeliverableSeed", .addDeliverable),
        mutation("capture.waiting", "DefaultCaptureService.markAsWaiting", .markWaiting),
        mutation("capture.optional", "DefaultCaptureService.markAsOptionalSomeday", .delayAction),
        mutation("capture.plan-seed", "DefaultCaptureService.routeToPlanSeed", .routeCommitment),
        mutation("capture.time-seed", "DefaultCaptureService.routeToTimeSeed", .scheduleItem),
        mutation("capture.attach-goal", "DefaultCaptureService.attachCaptureToGoal", .attachToGoal),
        mutation("capture.turn-into-goal", "DefaultCaptureService.turnCaptureIntoGoal", .createGoal),
        mutation("capture.processed", "DefaultCaptureService.markCaptureProcessed", .completeAction),
        mutation("capture.archived", "DefaultCaptureService.markCaptureArchived", .archiveItem),
        mutation("you.preferences", "RepositoryBackedYouService.saveYouPreferences", .updateUserPreferences),
        mutation("you.preferences-command", "YouPreferencesCommandService.saveYouPreferences", .updateUserPreferences),
        mutation("onboarding.complete", "RepositoryBackedOnboardingService.complete", .updateUserPreferences),
        mutation("time.calendar-aware", "RepositoryBackedTimeService.makeTimeCalendarAware", .scheduleItem),
        mutation("time.ritual-action", "RepositoryBackedTimeRitualsService.performAction", .updateGoal),
        mutation("step.create", "SimpleStepLifecycleService.createSimpleStep", .addGoalScopeItem),
        mutation("step.place", "SimpleStepLifecycleService.placeStepInTime", .placeStepInTime),
        mutation("step.recover", "SimpleStepLifecycleService.markMissedStepForRecovery", .recoverAction),
        mutation("step.recurring-create", "SimpleStepLifecycleService.createRecurringStep", .addGoalScopeItem),
        mutation("step.recurring-complete", "SimpleStepLifecycleService.completeRecurringOccurrence", .completeAction),
        mutation("step.recurring-pause", "SimpleStepLifecycleService.pauseRecurrence", .delayAction),
        mutation("step.recurring-resume", "SimpleStepLifecycleService.resumeRecurrence", .recoverAction),
        mutation("notification.action", "AppBootstrapper.handleNotificationPayload", .openDestination, status: .adapter),
        mutation("widget.action", "AppBootstrapper.handleWidgetPayload", .openDestination, status: .adapter),
        mutation("app-intent.capture", "CreateAmbitionsCaptureIntent.perform", .quickCapture, status: .adapter),
        mutation("app-intent.goal-draft", "CreateAmbitionsGoalDraftIntent.perform", .createGoal, status: .adapter),
        mutation("share.intake", "ShareExtensionIntake.recordDurableIntake", .quickCapture, status: .adapter),
        mutation("eventkit.outbox", "EventKitOutbox.recordCalendarSideEffect", .scheduleItem, status: .adapter),
        mutation("widget.outbox", "WidgetRefreshOutbox.recordSnapshotRefresh", .openDestination, status: .adapter),
        mutation("repair.portable-snapshot", "PortableSnapshotService.importSnapshot", .updateGoal),
    ]

    static let writePaths: [MeaningfulMutationWritePathDescriptor] = [
        writePath("Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureAttachmentVault.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/CaptureRoutingFileStore.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor+ScheduleMutationIntent.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox+EventKitStoreClientLive.swift", .adapter),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/FileSideEffectLedgerRepository.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerSwiftDataRepository.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Inspection/ExecutionLedgerReplayInspectionSwiftDataRepository.swift", .projectionOnly),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Inspection/InspectionSwiftDataRepositories.swift", .projectionOnly),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Repair/StoreInvariantChecker.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LifeCalendarStore.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Scheduling/LocalScheduleBlockFileStore.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository+Storage.swift", .adapter),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackCacheFileRepository.swift", .adapter),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasPublicPackLifecycleRefreshService.swift", .adapter),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift", .projectionOnly),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/LocalRuntimeStorageCore.swift", .durable),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreAmbitionGraphProjectionRecordModel.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreCaptureRecord.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreEntityRevisionTombstoneRecord.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreLifeContextPersistence.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataModels.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataRepositories.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift", .projectionOnly),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift", .projectionOnly),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataAmbitionGraphProjectionRecordRepository.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataAppStateRepository.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataGoalPersistenceRepositories.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataReminderRepository.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryArrayHelpers.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMapping.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingApply.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingEntityRevisionTombstone.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingFeedbackRecord.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRepositoryMappingPersisted.swift", .unproven),
        writePath("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataRuntimeSnapshotLedgerRepository.swift", .unproven),
        writePath("Native/Ambitions/Core/Permissions/LocalNotificationFoundation.swift", .adapter),
        writePath("Native/Ambitions/PreviewSupport/PreviewAppContainer.swift", .previewOnly),
        writePath("Native/Ambitions/Projection/ExternalSnapshots/ExternalCreationContracts.swift", .adapter),
        writePath("Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift", .projectionOnly),
        writePath("Native/Ambitions/Projection/ExternalSnapshots/SharedExternalSnapshotStore.swift", .projectionOnly),
    ]

    private static func mutation(
        _ id: String,
        _ sourcePath: String,
        _ commandKind: AmbitionsCommandKind,
        status: MeaningfulMutationStatus = .unproven
    ) -> MeaningfulMutationDescriptor {
        MeaningfulMutationDescriptor(
            id: id,
            sourcePath: sourcePath,
            commandKind: commandKind,
            executorOwner: status == .unproven ? "unproven" : "AmbitionsCommandExecutor",
            durableStores: [],
            eventKind: status == .unproven ? "unproven" : "command_execution",
            projectionOwner: status == .unproven ? "unproven" : "registered adapter boundary",
            receiptOwner: status == .unproven ? "unproven" : "RuntimeCommitReceipt",
            replayTestID: unprovenReplayProof,
            proofTestIDs: [inventoryProof],
            status: status
        )
    }

    private static func writePath(
        _ sourcePath: String,
        _ status: MeaningfulMutationStatus
    ) -> MeaningfulMutationWritePathDescriptor {
        MeaningfulMutationWritePathDescriptor(
            sourcePath: sourcePath,
            status: status,
            proofTestID: inventoryProof
        )
    }
}
