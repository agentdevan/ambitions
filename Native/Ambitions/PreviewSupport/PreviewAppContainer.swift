#if DEBUG

import AmbitionsDesignSystem
import Foundation

enum PreviewAppContainerFactory {
    @MainActor
    static var preview: AppContainer {
        preview(todayExperience: PreviewTodayScenarios.stable, timeRitualsDashboard: PreviewTimeRitualScenarios.seeded)
    }

    @MainActor
    static func preview(
        todayExperience: TodayExperience = PreviewTodayScenarios.stable,
        timeRitualsDashboard: TimeRitualsDashboard = PreviewTimeRitualScenarios.seeded
    ) -> AppContainer {
        let fixtures = PreviewFixtures.default
        let clock = PreviewClock.environmentOverride() ?? .default
        let navigation = StageStore(selectedSurface: fixtures.preferences.preferredTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let todayService = StubTodayService(experience: todayExperience)
        let captureService = StubCaptureService(captures: fixtures.captures)
        let runtime = makePreviewRuntime(clock: clock)
        let timeState = ProcessInfo.processInfo.environment["AMBITIONS_UI_PROTECTED_PLACEMENT_REVIEW"] == "1"
            ? PreviewTimeScenarios.protectedPlacementReviewSeeded
            : PreviewTimeScenarios.seeded
        let goalsService = runtime.goalsService
        let todayReceiptCommands = TodayReceiptCommandService(repositories: runtime.repositories)
        let youService = StubYouService(fixtures: fixtures)
        let youPreferencesCommands = YouPreferencesCommandService(
            repositories: runtime.repositories,
            loadDashboard: { try await youService.loadYouDashboard() }
        )
        let commandRouter = DefaultShellCommandRouter(
            navigation: navigation,
            captureService: captureService
        )
        let memoryLensService = DefaultMemoryLensService(repositories: runtime.repositories)
        return AppContainer(
            bootstrapConfiguration: .preview,
            session: AppSession(
                source: .preview,
                userDisplayName: fixtures.preferences.userDisplayName,
                initialTab: fixtures.preferences.preferredTab,
                appearancePreference: fixtures.preferences.appearancePreference,
                accentFamily: fixtures.preferences.accentFamily,
                launchedAt: clock.now,
                startupNote: "Preview bootstrap uses isolated in-memory fixtures.",
                shouldShowOnboarding: false
            ),
            clock: clock,
            runtime: runtime,
            appearancePreference: fixtures.preferences.appearancePreference,
            accentFamily: fixtures.preferences.accentFamily,
            navigation: navigation,
            todayService: todayService,
            todayReceiptCommands: todayReceiptCommands,
            captureService: captureService,
            goalsService: goalsService,
            timeRitualsService: PreviewTimeRitualsService(dashboard: timeRitualsDashboard),
            timeService: StubTimeService(
                timeState: timeState,
                weeklyReviewState: PreviewTimeScenarios.weeklyReview
            ),
            insightsService: StubInsightsService(fixtures: fixtures),
            youService: youService,
            youPreferencesCommands: youPreferencesCommands,
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
            externalCreationImportService: DefaultExternalCreationImportService(
                store: SharedExternalCreationStore(baseURL: FileManager.default.temporaryDirectory),
                commandExecutor: AmbitionsCommandExecutor(
                    captureService: captureService,
                    eventLedger: runtime.repositories.eventLedger,
                    commandExecutionRecords: runtime.repositories.commandExecutionRecords,
                    runtimeEvents: runtime.repositories.runtimeEvents,
                    projectionStore: runtime.repositories.projectionStore,
                    searchIndex: runtime.repositories.searchIndex,
                    commandJournal: runtime.repositories.commandJournal
                )
            ),
            commandRouter: commandRouter,
            memoryLensService: memoryLensService,
            onboardingService: RepositoryBackedOnboardingService(appStateRepository: runtime.repositories.appState)
        )
    }

    @MainActor
    private static func makePreviewRuntime(clock: any AmbitionsClock) -> AmbitionsRuntime {
        let store = try! AmbitionsPersistenceStore(inMemory: true)
        let repositories = AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            goalCreationUnitOfWork: SwiftDataGoalCreationUnitOfWork(store: store),
            capturePromotionUnitOfWork: SwiftDataCapturePromotionUnitOfWork(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
        return AmbitionsRuntimeFactory.make(
            repositories: repositories,
            clock: clock,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService()
        )
    }
}

#endif
