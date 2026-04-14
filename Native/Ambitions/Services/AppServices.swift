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

struct RepositoryBackedTodayService: TodayServicing {
    let goalRepository: any GoalRepository

    func loadTodayDashboard() async throws -> TodayDashboard {
        let goals = try await goalRepository.listGoals()
        let steps = try await goalRepository.listActionableSteps()
        let topSteps = Array(steps.prefix(3))
        let primaryGoal = goals.first
        let completion = goals.reduce(into: (done: 0, total: 0)) { partial, goal in
            let goalSteps = goal.plan?.sections.flatMap(\.steps) ?? []
            partial.total += goalSteps.count
            partial.done += goalSteps.filter { $0.state == .completed }.count
        }

        return TodayDashboard(
            title: primaryGoal?.title ?? "Today is ready",
            subtitle: "The widget shell is still placeholder UI, but it now reads from the real native store.",
            completionLabel: completion.total == 0 ? "No stored steps yet" : "\(Int((Double(completion.done) / Double(max(completion.total, 1))) * 100))% aligned",
            targets: topSteps.enumerated().map { index, step in
                DashboardProgressItem(
                    id: step.id,
                    title: step.title,
                    detail: step.summary,
                    progress: index == 0 ? 0.72 : 0.48,
                    trailingValue: step.timing.targetBy ?? step.timing.dueAt ?? step.timing.suggestedNextAt,
                    statusLabel: step.state.rawValue.capitalized
                )
            },
            focus: FocusSession(
                headline: topSteps.first?.title ?? "Persistence foundation in place",
                subtitle: primaryGoal?.title ?? "The next native Today implementation can now query real goals, plans, steps, evidence, and feedback.",
                reason: primaryGoal?.summary ?? "Storage now preserves starter-plan and blocked-draft state instead of relying on in-memory fixtures.",
                durationLabel: "25 min block",
                energyLabel: "Deliberate",
                progress: topSteps.isEmpty ? 0.0 : 0.64,
                supportSteps: topSteps.map(\.title).isEmpty ? ["Import or seed a goal to generate a real Today queue."] : topSteps.map(\.title)
            ),
            freeTime: FreeTimeSuggestion(
                title: "Storage is ready",
                subtitle: "Today can move from stubbed widgets to real plan selection next.",
                windowLabel: "Native query path",
                suggestionTitle: "Wire Today against actionable steps",
                suggestionDetail: "The repository now exposes persisted steps and goal state without depending on the Expo runtime."
            )
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
