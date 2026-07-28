import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedTodayService: TodayServicing {
    let repositories: AppRepositories
    let adaptationService: GoalEngineAdaptationService
    let rescheduleEngine: any GoalRescheduling
    let captureService: any CaptureServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let externalEffectAuthorizer: RuntimeExternalEffectCommandAuthorizer
    let ritualService: RitualOrchestrationService
    let learningService: LearningAnticipationService
    let sharedLifeService: SharedLifeCoordinationService
    let selector: PlanningNextStepSelector
    let explainabilityProjector: any GoalExplainabilityProjecting
    let goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)?
    let derivedReadModelCache: TodayDerivedReadModelCache
    let clock: any AmbitionsClock
    let lifeCalendarStore: LifeCalendarStore?

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
        lifeCalendarStoreFileURL: URL? = nil,
        clock: any AmbitionsClock = SystemClock(),
        externalEffectAuthorizer: RuntimeExternalEffectCommandAuthorizer? = nil
    ) {
        self.repositories = repositories
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.captureService = captureService ?? DefaultCaptureService(repository: repositories.captures)
        self.calendarRemindersService = calendarRemindersService ?? StubCalendarRemindersService()
        self.externalEffectAuthorizer = externalEffectAuthorizer ??
            RuntimeExternalEffectCommandAuthorizer(repositories: repositories)
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
        self.lifeCalendarStore = lifeCalendarStoreFileURL.map { LifeCalendarStore(fileURL: $0) }
        self.clock = clock
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        let snapshot = try await loadSnapshot()
        return try await makeExperience(snapshot: snapshot, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        return TodayActionResponse(message: TodayInlineMessage(
            title: "Action needs the runtime",
            body: "Today does not apply this change until a typed, committed runtime command is available.",
            state: .warning
        )
        )
    }
}
import AmbitionsTimeFoundation
