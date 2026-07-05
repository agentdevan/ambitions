import Foundation

@MainActor
struct SystemSurfacePlatformServices {
    let notificationService: any NotificationServicing
    let calendarRemindersService: any CalendarRemindersServicing
}

@MainActor
struct SystemSurfaceServices {
    let todayReceiptCommands: any TodayReceiptCommanding
    let youPreferencesCommands: any YouPreferencesCommanding
    let actionRouter: any AppActionRouting
    let externalActionService: any ExternalActionCommandExecuting
    let externalCreationImportService: any ExternalCreationImporting
    let sourceAtlasLifecycleRefreshService: any SourceAtlasPublicPackLifecycleRefreshing
    let commandRouter: any ShellCommandRouting
    let memoryLensService: any MemoryLensServicing
    let onboardingService: any OnboardingServicing
}

enum SystemSurfaceBootstrap {
    @MainActor
    static func makePlatformServices(repositories: AppRepositories) -> SystemSurfacePlatformServices {
        let sideEffectOutbox = repositories.sideEffectLedger.map { SideEffectOutbox(ledger: $0) }
        let notificationService = LocalNotificationFoundation(
            notificationOutbox: NotificationOutbox(recorder: sideEffectOutbox)
        )
        let calendarRemindersService = EventKitIntegrationService(
            eventKitOutbox: EventKitOutbox(recorder: sideEffectOutbox),
            reminderRepository: repositories.reminders
        )
        return SystemSurfacePlatformServices(
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService
        )
    }

    @MainActor
    static func prepareSession(
        configuration: AppBootstrapConfiguration,
        repositories: AppRepositories,
        clock: any AmbitionsClock
    ) async throws -> AppSession {
        let preferencesStore = RepositoryBackedAppPreferencesStore(appStateRepository: repositories.appState)
        let startupService = DefaultStartupService(
            preferencesStore: preferencesStore,
            appStateRepository: repositories.appState,
            clock: clock
        )
        return try await startupService.prepareSession(source: configuration.sessionSource)
    }

    @MainActor
    static func makeServices(
        repositories: AppRepositories,
        runtime: AmbitionsRuntime,
        navigation: StageStore,
        externalRouter: any AppExternalRouting
    ) -> SystemSurfaceServices {
        let todayReceiptCommands = TodayReceiptCommandService(repositories: repositories)
        let youPreferencesCommands = YouPreferencesCommandService(
            repositories: repositories,
            loadDashboard: { try await runtime.youService.loadYouDashboard() }
        )
        let externalActionService = DefaultExternalActionCommandService(
            runtimeExecutor: runtime.actionExecutor,
            externalRouter: externalRouter
        )
        let externalCreationCommandExecutor = AmbitionsCommandExecutor(
            captureService: runtime.captureService,
            eventLedger: repositories.eventLedger,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex,
            commandJournal: repositories.commandJournal
        )
        let externalCreationImportService = DefaultExternalCreationImportService(
            commandExecutor: externalCreationCommandExecutor,
            externalSurfaceSideEffectLedger: FileSideEffectLedgerRepository.defaultExternalSurfaceLedger(),
            appSideEffectLedger: repositories.sideEffectLedger
        )
        let sourceAtlasLifecycleRefreshService = SourceAtlasPublicPackLifecycleRefreshService(
            registry: SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.defaultAppRegistry(),
            transport: SourceAtlasURLSessionPublicPackRemoteTransport(
                endpoint: .sourceAtlasPublicGateway
            )
        )

        return SystemSurfaceServices(
            todayReceiptCommands: todayReceiptCommands,
            youPreferencesCommands: youPreferencesCommands,
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalActionService: externalActionService,
            externalCreationImportService: externalCreationImportService,
            sourceAtlasLifecycleRefreshService: sourceAtlasLifecycleRefreshService,
            commandRouter: DefaultShellCommandRouter(
                navigation: navigation,
                captureService: runtime.captureService
            ),
            memoryLensService: DefaultMemoryLensService(repositories: repositories),
            onboardingService: RepositoryBackedOnboardingService(appStateRepository: repositories.appState)
        )
    }

    @MainActor
    static func prepareLaunchEffects(
        runtime: AmbitionsRuntime,
        notificationService: any NotificationServicing,
        clock: any AmbitionsClock
    ) async {
        await notificationService.registerCategories()
        await runtime.snapshotWriter.refresh(now: clock.now)
        await notificationService.refreshSchedule(now: clock.now)
    }
}
