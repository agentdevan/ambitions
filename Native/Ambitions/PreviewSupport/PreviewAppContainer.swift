import AmbitionsDesignSystem
import Foundation

enum PreviewAppContainerFactory {
    static let fixtures = PreviewFixtures.default

    static var preview: AppContainer {
        AppContainer(
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

    static func make(source: AppSession.BootstrapSource) async throws -> AppContainer {
        let preferencesStore = InMemoryAppPreferencesStore(preferences: fixtures.preferences)
        let startupService = DefaultStartupService(preferencesStore: preferencesStore)
        let session = try await startupService.prepareSession(source: source)

        return AppContainer(
            session: session,
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
