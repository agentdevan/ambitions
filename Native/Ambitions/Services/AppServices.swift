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

struct RepositoryBackedGoalsService: GoalsServicing {
    let goalRepository: any GoalRepository

    func loadGoalsDashboard() async throws -> GoalsDashboard {
        let goals = try await goalRepository.listGoals()
        let summaries = goals.map { goal in
            let stepCount = goal.plan?.sections.flatMap(\.steps).count ?? 0
            let completedCount = goal.plan?.sections.flatMap(\.steps).filter { $0.state == .completed }.count ?? 0
            return GoalSummary(
                id: goal.id,
                title: goal.title,
                subtitle: goal.summary ?? goal.mode.rawValue.replacingOccurrences(of: "_", with: " "),
                progressLabel: stepCount == 0 ? "Draft" : "\(completedCount)/\(stepCount) steps",
                statusLabel: goal.state.rawValue.capitalized
            )
        }

        let milestoneGoal = goals.first
        return GoalsDashboard(
            title: "Active ambitions",
            subtitle: "Native persistence is now the source of truth for goal records and plan state.",
            goals: summaries,
            milestone: MilestonePrompt(
                title: milestoneGoal?.title ?? "No goals yet",
                subtitle: milestoneGoal?.summary ?? "The store is ready for the first real Today/Goals vertical slice.",
                prompt: milestoneGoal?.plan?.sections.first?.steps.first?.title ?? "Seed or import a goal to populate the first native detail flow.",
                confidenceLabel: milestoneGoal == nil ? "Ready for import" : "Persistence-backed"
            )
        )
    }
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
