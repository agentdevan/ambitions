import AmbitionsDesignSystem
import Foundation

enum PreviewAppContainerFactory {
    @MainActor
    static var preview: AppContainer {
        preview(todayExperience: PreviewTodayScenarios.stable, habitsDashboard: PreviewHabitsScenarios.seeded)
    }

    @MainActor
    static func preview(
        todayExperience: TodayExperience = PreviewTodayScenarios.stable,
        habitsDashboard: HabitsDashboard = PreviewHabitsScenarios.seeded
    ) -> AppContainer {
        let fixtures = PreviewFixtures.default
        let navigation = AppNavigationModel(selectedTab: fixtures.preferences.preferredTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let todayService = StubTodayService(experience: todayExperience)
        let captureService = StubCaptureService(captures: fixtures.captures)
        let goalsService = StubGoalsService()
        let runtime = makePreviewRuntime()
        let commandRouter = DefaultShellCommandRouter(
            navigation: navigation,
            captureService: captureService
        )
        let memoryLensService = DefaultMemoryLensService(repositories: runtime.repositories)
        return AppContainer(
            session: AppSession(
                source: .preview,
                userDisplayName: fixtures.preferences.userDisplayName,
                initialTab: fixtures.preferences.preferredTab,
                appearancePreference: fixtures.preferences.appearancePreference,
                accentFamily: fixtures.preferences.accentFamily,
                launchedAt: .now,
                startupNote: "Preview bootstrap uses isolated in-memory fixtures.",
                shouldShowOnboarding: false
            ),
            runtime: runtime,
            appearancePreference: fixtures.preferences.appearancePreference,
            accentFamily: fixtures.preferences.accentFamily,
            navigation: navigation,
            todayService: todayService,
            captureService: captureService,
            goalsService: goalsService,
            habitsService: StubHabitsService(dashboard: habitsDashboard),
            planService: StubPlanService(
                dashboard: PreviewPlanScenarios.seeded,
                weeklyReviewDashboard: PreviewPlanScenarios.weeklyReview
            ),
            insightsService: StubInsightsService(fixtures: fixtures),
            profileService: StubProfileService(fixtures: fixtures),
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter,
            externalActionService: DefaultExternalActionCommandService(
                todayService: todayService,
                goalsService: goalsService,
                captureService: captureService,
                externalRouter: externalRouter
            ),
            commandRouter: commandRouter,
            memoryLensService: memoryLensService,
            onboardingService: RepositoryBackedOnboardingService(appStateRepository: runtime.repositories.appState)
        )
    }

    @MainActor
    private static func makePreviewRuntime() -> AmbitionsRuntime {
        let store = try! AmbitionsPersistenceStore(inMemory: true)
        let repositories = AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
        return AmbitionsRuntimeFactory.make(
            repositories: repositories,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService()
        )
    }
}
