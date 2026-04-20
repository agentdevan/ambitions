import Foundation

enum AmbitionsRuntimeFactory {
    @MainActor
    static func make(
        repositories: AppRepositories,
        clientContext: AmbitionsRuntimeClientContext = .iphoneApp,
        capabilities: AmbitionsRuntimeCapabilities = .currentLocalRuntime,
        notificationService: any NotificationServicing,
        calendarRemindersService: any CalendarRemindersServicing,
        syncCapability: any SyncCapability = LocalOnlySyncCapability(),
        externalSnapshotReader: any RuntimeExternalSurfaceSnapshotReading = FileRuntimeExternalSurfaceSnapshotReader(),
        knowledgeProvider: any KnowledgeProviding = LocalOnlyKnowledgeProvider()
    ) -> AmbitionsRuntime {
        let snapshotWriter = ExternalSurfaceSnapshotWriter(repositories: repositories)
        let learningService = LearningAnticipationService()
        let energyFitService = DefaultGoalEnergyFitService()
        let goalOrchestrator = GoalEngineOrchestrator(energyFitService: energyFitService)
        let memoryService = RepositoryBackedRuntimeMemoryService(repositories: repositories)
        let contextService = RepositoryBackedRuntimeContextService(
            clientContext: clientContext,
            capabilities: capabilities,
            memoryService: memoryService,
            syncCapability: syncCapability,
            externalSnapshotReader: externalSnapshotReader,
            knowledgeProvider: knowledgeProvider
        )
        let snapshotTodayService = SnapshotRefreshingTodayService(
            base: RepositoryBackedTodayService(
                repositories: repositories,
                calendarRemindersService: calendarRemindersService,
                learningService: learningService,
                energyFitService: energyFitService
            ),
            snapshotWriter: snapshotWriter
        )
        let snapshotGoalsService = SnapshotRefreshingGoalsService(
            base: RepositoryBackedGoalsService(
                repositories: repositories,
                orchestrator: goalOrchestrator,
                calendarRemindersService: calendarRemindersService,
                learningService: learningService
            ),
            snapshotWriter: snapshotWriter
        )
        let todayService = NotificationSchedulingTodayService(
            base: snapshotTodayService,
            notificationService: notificationService
        )
        let goalsService = NotificationSchedulingGoalsService(
            base: snapshotGoalsService,
            notificationService: notificationService
        )
        let captureService = DefaultCaptureService(
            repository: repositories.captures,
            goalRepository: repositories.goals,
            goalsService: goalsService
        )
        let profileService = RepositoryBackedProfileService(
            repositories: repositories,
            syncCapability: syncCapability
        )
        let actionExecutor = DefaultRuntimeActionCommandExecutor(todayService: todayService)
        let dedicatedDevicePrototypeRuntime = DedicatedDevicePrototypeRuntime(
            contextService: contextService,
            actionExecutor: actionExecutor
        )

        return AmbitionsRuntime(
            clientContext: clientContext,
            capabilities: capabilities,
            repositories: repositories,
            knowledgeProvider: knowledgeProvider,
            memoryService: memoryService,
            contextService: contextService,
            actionExecutor: actionExecutor,
            syncCapability: syncCapability,
            snapshotWriter: snapshotWriter,
            todayService: todayService,
            goalsService: goalsService,
            captureService: captureService,
            habitsService: RepositoryBackedHabitsService(repositories: repositories),
            insightsService: RepositoryBackedInsightsService(repositories: repositories),
            profileService: profileService,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            dedicatedDevicePrototypeRuntime: dedicatedDevicePrototypeRuntime
        )
    }
}
