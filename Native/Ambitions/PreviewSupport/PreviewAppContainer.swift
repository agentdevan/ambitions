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
        let youService = StubYouService(fixtures: fixtures)
        let youPreferencesCommands = YouPreferencesCommandService(
            repositories: runtime.repositories,
            loadDashboard: { try await youService.loadYouDashboard() }
        )
        let commandExecutor = AmbitionsCommandExecutor(
                captureService: captureService,
                eventLedger: runtime.repositories.eventLedger,
                actionReceiptHistory: runtime.repositories.actionReceiptHistory,
                commandExecutionRecords: runtime.repositories.commandExecutionRecords,
                runtimeEvents: runtime.repositories.runtimeEvents,
                projectionStore: runtime.repositories.projectionStore,
                searchIndex: runtime.repositories.searchIndex,
                commandJournal: runtime.repositories.commandJournal,
                runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore(),
                receiptFactory: CommandReceiptFactory(),
                todayActionMaterializer: runtime.repositories.todayGoalStepActionMaterializer,
                timeRitualActionMaterializer: runtime.repositories.timeRitualActionMaterializer,
                captureGoalHandoffMaterializer: runtime.repositories.captureGoalHandoffMaterializer
        )
        let runtimeCommandClient = RuntimeCommandClient(
            execute: { command, context in
                await commandExecutor.execute(command, context: context)
            },
            projection: { request in
                guard let projectionStore = runtime.repositories.projectionStore,
                      let record = try await projectionStore.fetchRecord(id: request.projectionID) else {
                    throw RuntimeProjectionClientError.projectionUnavailable(request)
                }
                return RuntimeProjectionSnapshot(
                    projectionID: record.id.rawValue,
                    payload: record.payloadData,
                    eventSequence: record.cursor.sequence,
                    cursorChecksum: record.cursor.checksum,
                    payloadChecksum: record.payloadChecksum,
                    materializedAt: record.materializedAt
                )
            }
        )
        let todayReceiptCommands = TodayReceiptCommandService(
            repositories: runtime.repositories,
            runtimeCommandClient: runtimeCommandClient
        )
        let commandRouter = DefaultShellCommandRouter(
            navigation: navigation,
            intentSender: FlagshipRuntimeIntentAdapter(
                runtimeCommandClient: runtimeCommandClient
            )
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
            runtimeCommandClient: runtimeCommandClient,
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
            systemSettingsOpener: .unavailable,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter,
            externalActionService: AppExternalActionRoutingAdapter(
                coreService: DefaultExternalActionCommandService(
                    todayService: todayService,
                    goalsService: goalsService,
                    captureService: captureService
                ),
                externalRouter: externalRouter,
                appRouteForIntent: AppContainerFactory.appRoute
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
                    commandJournal: runtime.repositories.commandJournal,
                    runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore(),
                    receiptFactory: CommandReceiptFactory()
                )
            ),
            commandRouter: commandRouter,
            memoryLensService: memoryLensService,
            onboardingService: RepositoryBackedOnboardingService(appStateRepository: runtime.repositories.appState),
            captureGoalHandoffCommands: CaptureGoalHandoffService(
                repositories: runtime.repositories,
                runtimeClient: runtimeCommandClient
            )
        )
    }

    @MainActor
    private static func makePreviewRuntime(clock: any AmbitionsClock) -> AmbitionsRuntime {
        guard let store = try? AmbitionsPersistenceStore(inMemory: true) else {
            preconditionFailure("Preview persistence must remain available")
        }
        let repositories = PersistenceBootstrap.makeRepositories(store: store, configuration: .preview)
        return AmbitionsRuntimeFactory.make(
            repositories: repositories,
            clock: clock,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService()
        )
    }
}

#endif
import AmbitionsTimeFoundation
