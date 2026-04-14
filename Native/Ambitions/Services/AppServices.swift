import AmbitionsWidgetUI
import Foundation

protocol StartupServicing: Sendable {
    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession
}

protocol TodayServicing: Sendable {
    func loadTodayDashboard() async throws -> TodayDashboard
}

protocol GoalsServicing: Sendable {
    func loadGoalsDashboard() async throws -> GoalsDashboard
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

    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession {
        let preferences = try await preferencesStore.loadPreferences()
        return AppSession(
            source: source,
            userDisplayName: preferences.userDisplayName,
            initialTab: preferences.preferredTab,
            launchedAt: Date(),
            startupNote: source == .preview
                ? "Preview bootstrap uses isolated in-memory fixtures."
                : "Live bootstrap is wired for native SwiftUI and still backed by placeholder services."
        )
    }
}

struct StubTodayService: TodayServicing {
    let fixtures: PreviewFixtures
    func loadTodayDashboard() async throws -> TodayDashboard { fixtures.todayDashboard }
}

struct StubGoalsService: GoalsServicing {
    let fixtures: PreviewFixtures
    func loadGoalsDashboard() async throws -> GoalsDashboard { fixtures.goalsDashboard }
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
