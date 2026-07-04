import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedGoalsService: GoalsServicing, GoalCreationPreparing {
    let repositories: AppRepositories

    let planner: DeterministicGoalPlanner

    let adaptationService: GoalEngineAdaptationService

    let rescheduleEngine: any GoalRescheduling

    let orchestrator: any GoalOrchestrating

    let calendarRemindersService: any CalendarRemindersServicing

    let learningService: LearningAnticipationService

    let explainabilityProjector: any GoalExplainabilityProjecting

    let teachingService: any GoalTeachingSignalReading & GoalTeachingSignalCapturing

    let goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)?

    init(
        repositories: AppRepositories,
        planner: DeterministicGoalPlanner = DeterministicGoalPlanner(),
        adaptationService: GoalEngineAdaptationService = GoalEngineAdaptationService(),
        rescheduleEngine: any GoalRescheduling = RescheduleEngine(),
        orchestrator: any GoalOrchestrating = GoalEngineOrchestrator(),
        calendarRemindersService: (any CalendarRemindersServicing)? = nil,
        learningService: LearningAnticipationService = LearningAnticipationService(),
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        teachingService: (any GoalTeachingSignalReading & GoalTeachingSignalCapturing)? = nil,
        goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)? = nil
    ) {
        let compatibilityTeachingService = DefaultGoalTeachingSignalService(repository: repositories.teaching)
        self.repositories = repositories
        self.planner = planner
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.orchestrator = orchestrator
        self.calendarRemindersService = calendarRemindersService ?? StubCalendarRemindersService()
        self.learningService = learningService
        self.explainabilityProjector = explainabilityProjector
        self.teachingService = teachingService ?? compatibilityTeachingService
        self.goalIntelligenceService = goalIntelligenceService
    }
}

extension GoalsServicing {
    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState {
        if let repository = self as? RepositoryBackedGoalsService {
            return try await repository.previewCreateGoal(request, now: now)
        }

        if let snapshotRefreshing = self as? SnapshotRefreshingGoalsService {
            return try await snapshotRefreshing.base.previewCreateGoal(request, now: now)
        }

        #if DEBUG
            if let stub = self as? StubGoalsService {
                return try await stub.previewCreateGoal(request, now: now)
            }
        #endif

        let planner = DeterministicGoalPlanner()
        let seed = planner.plan(for: request.title, preferredMode: request.mode)
        return CreateGoalPreviewState(
            normalizedTitle: seed.blueprint.title,
            summary: seed.blueprint.summary ?? "Ambitions shaped a lightweight local preview.",
            modeLabel: seed.blueprint.mode.displayTitle,
            resultKind: .planned,
            renderState: .active,
            selectedPace: request.preferredPace,
            paceOptions: [
                StrategyComposerPaceOptionState(choice: .conservative, title: "Conservative", subtitle: "Preserve room.", badgeTitle: "Room", state: request.preferredPace == .conservative ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .balanced, title: "Balanced", subtitle: "Stay believable.", badgeTitle: "Believable", state: request.preferredPace == .balanced ? .selected : .default),
                StrategyComposerPaceOptionState(choice: .aggressive, title: "Aggressive", subtitle: "Accept more pressure.", badgeTitle: "Tighter", state: request.preferredPace == .aggressive ? .selected : .default)
            ],
            feasibility: nil,
            deadlineGuidance: nil,
            pathStages: [],
            milestonePreview: [],
            clarification: nil,
            blocked: nil,
            trust: StrategyComposerTrustState(
                title: "Trust framing",
                lines: ["This fallback preview keeps the composer readable when a specialized preview seam is unavailable."],
                badgeTitle: "Local fallback",
                state: .default
            ),
            planningEvaluation: nil
        )
    }
}

enum GoalsFeatureError: LocalizedError {
    case notFound
    case missingStep
    case notActionable
    case invalidTitle

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested goal could not be found in native persistence."
        case .missingStep:
            return "This goal does not currently expose an actionable step."
        case .notActionable:
            return "That action is not available for the current goal state."
        case .invalidTitle:
            return "A goal title is required before a native plan can be created."
        }
    }
}
