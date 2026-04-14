import Foundation

enum PreviewAppContainerFactory {
    static var preview: AppContainer {
        let fixtures = PreviewFixtures.default
        return AppContainer(
            session: AppSession(
                source: .preview,
                userDisplayName: fixtures.preferences.userDisplayName,
                initialTab: fixtures.preferences.preferredTab,
                launchedAt: .now,
                startupNote: "Preview bootstrap uses isolated in-memory fixtures."
            ),
            theme: .dark,
            todayService: StubTodayService(fixtures: fixtures),
            goalsService: StubGoalsService(fixtures: fixtures),
            habitsService: StubHabitsService(fixtures: fixtures),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            actionRouter: DefaultAppActionRouter()
        )
    }
}
