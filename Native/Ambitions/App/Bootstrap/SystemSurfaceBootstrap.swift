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
        let eventKitSideEffectOutbox = SideEffectOutbox(
            ledger: FileSideEffectLedgerRepository.defaultEventKitLedger()
        )
        let calendarRemindersService = EventKitIntegrationService(
            eventKitOutbox: EventKitOutbox(recorder: eventKitSideEffectOutbox),
            reminderRepository: repositories.reminders,
            pendingOperationStore: FilePendingEventKitOperationStore.defaultStore()
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
    // swiftlint:disable:next function_parameter_count
    static func makeServices(
        repositories: AppRepositories,
        runtime: AmbitionsRuntime,
        navigation: StageStore,
        externalRouter: any AppExternalRouting,
        runtimeCommandClient: RuntimeCommandClient,
        appRouteForIntent: @escaping (RuntimeRouteIntent, ExternalActionSource) -> AppExternalRoute
    ) -> SystemSurfaceServices {
        let todayReceiptCommands = TodayReceiptCommandService(
            repositories: repositories,
            runtimeCommandClient: runtimeCommandClient
        )
        let youPreferencesCommands = YouPreferencesCommandService(
            repositories: repositories,
            loadDashboard: { try await runtime.youService.loadYouDashboard() }
        )
        let externalActionService = AppExternalActionRoutingAdapter(
            coreService: DefaultExternalActionCommandService(
                runtimeExecutor: runtime.actionExecutor
            ),
            externalRouter: externalRouter,
            appRouteForIntent: appRouteForIntent
        )
        let externalCreationImportService = DefaultExternalCreationImportService(
            commandExecutor: runtimeCommandClient,
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
                intentSender: FlagshipRuntimeIntentAdapter(
                    runtimeCommandClient: runtimeCommandClient
                )
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
import AmbitionsTimeFoundation
