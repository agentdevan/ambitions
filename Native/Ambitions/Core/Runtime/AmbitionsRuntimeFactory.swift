import Foundation

enum AmbitionsRuntimeFactory {
    @MainActor
    static func make(
        repositories: AppRepositories,
        clock: any AmbitionsClock = SystemClock(),
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
        let sharedLifeService = SharedLifeCoordinationService()
        let energyFitService = DefaultGoalEnergyFitService()
        let energyLearningService = DefaultGoalEnergyLearningService()
        let selector = PlanningNextStepSelector(
            learningService: learningService,
            sharedLifeService: sharedLifeService,
            energyFitService: energyFitService,
            energyLearningService: energyLearningService
        )
        let explainabilityProjector = DefaultGoalExplainabilityProjector()
        let teachingService = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        let ritualService = RitualOrchestrationService(selector: selector)
        let goalOrchestrator = GoalEngineOrchestrator(energyFitService: energyFitService)
        let goalIntelligenceService = RepositoryBackedRuntimeGoalIntelligenceService(
            repositories: repositories,
            explainabilityProjector: explainabilityProjector,
            teachingReader: teachingService,
            teachingCaptureService: teachingService,
            learningService: learningService
        )
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
                ritualService: ritualService,
                learningService: learningService,
                sharedLifeService: sharedLifeService,
                energyFitService: energyFitService,
                energyLearningService: energyLearningService,
                selector: selector,
                goalIntelligenceService: goalIntelligenceService,
                clock: clock
            ),
            snapshotWriter: snapshotWriter
        )
        let snapshotGoalsService = SnapshotRefreshingGoalsService(
            base: RepositoryBackedGoalsService(
                repositories: repositories,
                orchestrator: goalOrchestrator,
                calendarRemindersService: calendarRemindersService,
                learningService: learningService,
                explainabilityProjector: explainabilityProjector,
                teachingService: teachingService,
                goalIntelligenceService: goalIntelligenceService
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
            goalsService: goalsService,
            goalCreationPreparer: goalsService,
            capturePromotionUnitOfWork: repositories.capturePromotionUnitOfWork,
            eventLedger: repositories.eventLedger,
            simpleStepLifecycleService: SimpleStepLifecycleService(repositories: repositories)
        )
        let youService = RepositoryBackedYouService(
            repositories: repositories,
            syncCapability: syncCapability,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService
        )
        let privateLifeRuntimeKernel = PrivateLifeRuntimeKernel()
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
            goalIntelligenceService: goalIntelligenceService,
            syncCapability: syncCapability,
            snapshotWriter: snapshotWriter,
            todayService: todayService,
            goalsService: goalsService,
            captureService: captureService,
            timeRitualsService: RepositoryBackedTimeRitualsService(repositories: repositories),
            timeService: RepositoryBackedTimeService(
                repositories: repositories,
                calendarRealityService: calendarRemindersService as? any CalendarRealityServicing,
                clock: clock
            ),
            insightsService: RepositoryBackedInsightsService(repositories: repositories),
            youService: youService,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            privateLifeRuntimeKernel: privateLifeRuntimeKernel,
            dedicatedDevicePrototypeRuntime: dedicatedDevicePrototypeRuntime
        )
    }
}
