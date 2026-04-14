import AmbitionsDesignSystem
import Foundation

enum PreviewAppContainerFactory {
    static var preview: AppContainer {
        preview(todayExperience: PreviewTodayScenarios.seeded, habitsDashboard: PreviewHabitsScenarios.seeded)
    }

    static func preview(
        todayExperience: TodayExperience,
        habitsDashboard: HabitsDashboard = PreviewHabitsScenarios.seeded
    ) -> AppContainer {
        let fixtures = PreviewFixtures.default
        let navigation = AppNavigationModel(selectedTab: fixtures.preferences.preferredTab)
        return AppContainer(
            session: AppSession(
                source: .preview,
                userDisplayName: fixtures.preferences.userDisplayName,
                initialTab: fixtures.preferences.preferredTab,
                launchedAt: .now,
                startupNote: "Preview bootstrap uses isolated in-memory fixtures."
            ),
            theme: .dark,
            navigation: navigation,
            todayService: StubTodayService(experience: todayExperience),
            goalsService: StubGoalsService(),
            habitsService: StubHabitsService(dashboard: habitsDashboard),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            actionRouter: DefaultAppActionRouter()
        )
    }
}
