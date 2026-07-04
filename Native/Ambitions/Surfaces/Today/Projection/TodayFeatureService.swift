import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedTodayService: TodayServicing {
    let repositories: AppRepositories
    let adaptationService: GoalEngineAdaptationService
    let rescheduleEngine: any GoalRescheduling
    let captureService: any CaptureServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let ritualService: RitualOrchestrationService
    let learningService: LearningAnticipationService
    let sharedLifeService: SharedLifeCoordinationService
    let selector: PlanningNextStepSelector
    let explainabilityProjector: any GoalExplainabilityProjecting
    let goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)?
    let derivedReadModelCache: TodayDerivedReadModelCache
    let clock: any AmbitionsClock

    init(
        repositories: AppRepositories,
        adaptationService: GoalEngineAdaptationService = GoalEngineAdaptationService(),
        rescheduleEngine: any GoalRescheduling = RescheduleEngine(),
        captureService: (any CaptureServicing)? = nil,
        calendarRemindersService: (any CalendarRemindersServicing)? = nil,
        ritualService: RitualOrchestrationService = RitualOrchestrationService(),
        learningService: LearningAnticipationService = LearningAnticipationService(),
        sharedLifeService: SharedLifeCoordinationService = SharedLifeCoordinationService(),
        energyFitService: any GoalEnergyFitEvaluating = DefaultGoalEnergyFitService(),
        energyLearningService: any GoalEnergyLearning = DefaultGoalEnergyLearningService(),
        selector: PlanningNextStepSelector? = nil,
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)? = nil,
        derivedReadModelCache: TodayDerivedReadModelCache = TodayDerivedReadModelCache(),
        clock: any AmbitionsClock = SystemClock()
    ) {
        self.repositories = repositories
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.captureService = captureService ?? DefaultCaptureService(repository: repositories.captures)
        self.calendarRemindersService = calendarRemindersService ?? StubCalendarRemindersService()
        self.ritualService = ritualService
        self.learningService = learningService
        self.sharedLifeService = sharedLifeService
        self.selector = selector ?? PlanningNextStepSelector(
            learningService: learningService,
            sharedLifeService: sharedLifeService,
            energyFitService: energyFitService,
            energyLearningService: energyLearningService
        )
        self.explainabilityProjector = explainabilityProjector
        self.goalIntelligenceService = goalIntelligenceService
        self.derivedReadModelCache = derivedReadModelCache
        self.clock = clock
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        let snapshot = try await loadSnapshot()
        return try await makeExperience(snapshot: snapshot, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        let commandActionHandler = TodayCommandActionHandler(
            repositories: repositories,
            feedbackAction: { action, now in
                try await self.performFeedbackAction(action, now: now)
            }
        )
        let handler = TodayCommandHandler(
            feedbackActionHandler: { action, now in
                try await self.performFeedbackAction(action, now: now)
            },
            commandActionHandler: { action, command, now in
                try await commandActionHandler.performAction(action, command: command, now: now)
            }
        )
        return try await handler.performAction(action, now: now)
    }
}
