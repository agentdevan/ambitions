import AmbitionsDesignSystem
import Foundation

enum AppContainerFactory {
    static func make(source: AppSession.BootstrapSource) async throws -> AppContainer {
        let store = try AmbitionsPersistenceStore(inMemory: source == .preview)
        let repositories = makeRepositories(store: store)
        try await DemoSeedPipeline(repositories: repositories).seedIfNeeded(force: source == .preview)

        let preferencesStore = RepositoryBackedAppPreferencesStore(appStateRepository: repositories.appState)
        let startupService = DefaultStartupService(preferencesStore: preferencesStore, appStateRepository: repositories.appState)
        let session = try await startupService.prepareSession(source: source)
        let fixtures = PreviewFixtures.default
        let navigation = AppNavigationModel(selectedTab: session.initialTab)

        return AppContainer(
            session: session,
            theme: .dark,
            navigation: navigation,
            todayService: RepositoryBackedTodayService(repositories: repositories),
            goalsService: RepositoryBackedGoalsService(repositories: repositories),
            habitsService: StubHabitsService(fixtures: fixtures),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            actionRouter: DefaultAppActionRouter()
        )
    }

    private static func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
