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
    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse
}

protocol HabitsServicing: Sendable {
    func loadHabitsDashboard() async throws -> HabitsDashboard
}

protocol InsightsServicing: Sendable {
    func loadInsightsDashboard() async throws -> InsightsDashboard
}

protocol ProfileServicing: Sendable {
    func loadProfileDashboard() async throws -> ProfileDashboard
}

protocol AppActionRouting: Sendable {
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
                : "Live bootstrap is persistence-backed and seeded with native demo content until real user data replaces it."
        )
    }
}

struct StubHabitsService: HabitsServicing {
    let fixtures: PreviewFixtures
    func loadHabitsDashboard() async throws -> HabitsDashboard { fixtures.habitsDashboard }
}

struct StubInsightsService: InsightsServicing {
    let fixtures: PreviewFixtures
    func loadInsightsDashboard() async throws -> InsightsDashboard { fixtures.insightsDashboard }
}

struct StubProfileService: ProfileServicing {
    let fixtures: PreviewFixtures
    func loadProfileDashboard() async throws -> ProfileDashboard { fixtures.profileDashboard }
}

struct DefaultAppActionRouter: AppActionRouting {
    func handle(_ action: WidgetAction) async {
        _ = action
    }
}
