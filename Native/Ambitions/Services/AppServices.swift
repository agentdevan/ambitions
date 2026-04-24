import AmbitionsWidgetUI
import Foundation

protocol StartupServicing: Sendable {
    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession
}

protocol TodayServicing: Sendable {
    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience
    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse
}

extension TodayServicing {
    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        try await loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: .standard)
    }
}

protocol GoalsServicing: Sendable {
    func loadOverview() async throws -> GoalsOverview
    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation
    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState
    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse
    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse
    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse
    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse
}

extension GoalsServicing {
    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }
}

protocol HabitsServicing: Sendable {
    func loadDashboard(now: Date) async throws -> HabitsDashboard
    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse
}

protocol PlanServicing: Sendable {
    func loadPlanDashboard(now: Date) async throws -> PlanDashboard
    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard
}

protocol InsightsServicing: Sendable {
    func loadInsightsDashboard() async throws -> InsightsDashboard
}

protocol ProfileServicing: Sendable {
    func loadProfileDashboard() async throws -> ProfileDashboard
    func saveProfilePreferences(_ preferences: ProfilePreferencesUpdate) async throws -> ProfileDashboard
}

protocol CaptureServicing: Sendable {
    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture
    func listCaptures() async throws -> [Capture]
    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture?
    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding?
    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding?
    func markCaptureProcessed(id: String, now: Date) async throws -> Capture?
    func markCaptureArchived(id: String, now: Date) async throws -> Capture?
}

protocol MemoryLensServicing: Sendable {
    func search(query: String, seedIntent: ShellCommandIntent?) async -> [MemoryLensResult]
}

protocol AppActionRouting {
    func handle(_ action: WidgetAction) async
}

struct DefaultStartupService: StartupServicing {
    let preferencesStore: any AppPreferencesStore
    let appStateRepository: (any AppStateRepository)?

    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession {
        let preferences = try await preferencesStore.loadPreferences()
        let forceOnboarding = ProcessInfo.processInfo.environment["AMBITIONS_FORCE_ONBOARDING"] == "1"
        var shouldShowOnboarding = false
        if let appStateRepository {
            var state = try await appStateRepository.loadState()
            shouldShowOnboarding = forceOnboarding || (source == .live && state.hasCompletedOnboarding == false)
            state.hasCompletedBootstrap = true
            state.lastBootstrapSource = source
            state.lastBootstrapAt = ISO8601DateFormatter().string(from: .now)
            try await appStateRepository.saveState(state)
        }
        return AppSession(
            source: source,
            userDisplayName: preferences.userDisplayName,
            initialTab: preferences.preferredTab,
            appearancePreference: preferences.appearancePreference,
            accentFamily: preferences.accentFamily,
            launchedAt: Date(),
            startupNote: startupNote(for: source),
            shouldShowOnboarding: shouldShowOnboarding
        )
    }

    private func startupNote(for source: AppSession.BootstrapSource) -> String {
        switch source {
        case .preview:
            return "Preview bootstrap uses isolated in-memory fixtures."
        case .demo:
            return "Demo bootstrap uses isolated in-memory seeded data."
        case .live:
            return "Live bootstrap is persistence-backed and starts from the user's actual on-device data."
        }
    }
}

struct StubHabitsService: HabitsServicing {
    let dashboard: HabitsDashboard
    let actionResponse: HabitActionResponse?

    init(dashboard: HabitsDashboard, actionResponse: HabitActionResponse? = nil) {
        self.dashboard = dashboard
        self.actionResponse = actionResponse
    }

    func loadDashboard(now: Date) async throws -> HabitsDashboard {
        _ = now
        return dashboard
    }

    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse {
        _ = request
        _ = now
        return actionResponse ?? HabitActionResponse(message: nil)
    }
}

struct StubPlanService: PlanServicing {
    let dashboard: PlanDashboard
    let weeklyReviewDashboard: WeeklyReviewDashboard

    func loadPlanDashboard(now: Date) async throws -> PlanDashboard {
        _ = now
        return dashboard
    }

    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard {
        _ = now
        return weeklyReviewDashboard
    }
}

#if DEBUG
struct StubInsightsService: InsightsServicing {
    let fixtures: PreviewFixtures
    func loadInsightsDashboard() async throws -> InsightsDashboard { fixtures.insightsDashboard }
}

struct StubProfileService: ProfileServicing {
    let fixtures: PreviewFixtures
    func loadProfileDashboard() async throws -> ProfileDashboard { fixtures.profileDashboard }
    func saveProfilePreferences(_ preferences: ProfilePreferencesUpdate) async throws -> ProfileDashboard {
        _ = preferences
        return fixtures.profileDashboard
    }
}
#endif

struct StubCaptureService: CaptureServicing {
    let captures: [Capture]

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        Capture(
            id: "preview-capture-created",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: request.rawText,
            sourceType: request.sourceType,
            status: .actionable,
            linkedGoalID: request.linkedGoalID
        )
    }

    func listCaptures() async throws -> [Capture] {
        captures
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == request.id })
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = now
        guard let capture = captures.first(where: { $0.id == request.captureID }) else {
            return nil
        }
        return CaptureGoalBinding(capture: capture, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = now
        guard let capture = captures.first(where: { $0.id == request.captureID }) else {
            return nil
        }
        return CaptureGoalBinding(capture: capture, target: GoalRouteTarget(goalID: "preview-goal-created", draftID: "preview-draft-created"))
    }
}

@MainActor
struct DefaultAppActionRouter: AppActionRouting {
    let navigation: AppNavigationModel

    func handle(_ action: WidgetAction) async {
        switch action.identity.family {
        case .insightStats, .weeklyTrend, .recentActivity:
            navigation.selectTab(.insights)
        case .profileSummary, .settingsGroup:
            navigation.selectTab(.profile)
        case .habitSummary, .streak:
            navigation.openHabits()
        case .dailyTargets, .focusNow, .freeTime, .milestonePrompt, .goalsList, .celebration:
            navigation.selectTab(.today)
        }
    }
}
