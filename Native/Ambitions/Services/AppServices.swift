import AmbitionsWidgetUI
import Foundation

protocol StartupServicing: Sendable {
    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession
}

protocol TodayServicing: Sendable {
    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience
    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse
}

protocol GoalsServicing: Sendable {
    func loadOverview() async throws -> GoalsOverview
    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation
    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse
    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse
    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse
}

protocol HabitsServicing: Sendable {
    func loadDashboard(now: Date) async throws -> HabitsDashboard
    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse
}

protocol InsightsServicing: Sendable {
    func loadInsightsDashboard() async throws -> InsightsDashboard
}

protocol ProfileServicing: Sendable {
    func loadProfileDashboard() async throws -> ProfileDashboard
    func saveProfilePreferences(_ preferences: ProfilePreferencesUpdate) async throws -> ProfileDashboard
}

protocol AppActionRouting {
    func handle(_ action: WidgetAction) async
}

struct DefaultStartupService: StartupServicing {
    let preferencesStore: any AppPreferencesStore
    let appStateRepository: (any AppStateRepository)?

    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession {
        let preferences = try await preferencesStore.loadPreferences()
        if let appStateRepository {
            var state = try await appStateRepository.loadState()
            state.hasCompletedBootstrap = true
            state.lastBootstrapSource = source
            state.lastBootstrapAt = ISO8601DateFormatter().string(from: .now)
            try await appStateRepository.saveState(state)
        }
        return AppSession(
            source: source,
            userDisplayName: preferences.userDisplayName,
            initialTab: preferences.preferredTab,
            launchedAt: Date(),
            startupNote: source == .preview
                ? "Preview bootstrap uses isolated in-memory fixtures."
                : "Live bootstrap is persistence-backed and ready to transition from starter data into personal planning history."
        )
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

@MainActor
struct DefaultAppActionRouter: AppActionRouting {
    let navigation: AppNavigationModel

    func handle(_ action: WidgetAction) async {
        switch action.identity.family {
        case .insightStats, .weeklyTrend, .recentActivity:
            navigation.selectedTab = .insights
        case .profileSummary, .settingsGroup:
            navigation.selectedTab = .profile
        case .habitSummary, .streak:
            navigation.selectedTab = .habits
        case .dailyTargets, .focusNow, .freeTime, .milestonePrompt, .goalsList, .celebration:
            navigation.selectedTab = .today
        }
    }
}
