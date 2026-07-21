import AmbitionsDesignSystem
import Foundation

struct AppBootstrapConfiguration: Sendable, Equatable {
    enum PersistenceMode: Sendable, Equatable {
        case persistent
        case inMemory
    }

    enum SeedPolicy: Sendable, Equatable {
        case never
        case whenExplicit
    }

    let sessionSource: AppSession.BootstrapSource
    let persistenceMode: PersistenceMode
    let seedPolicy: SeedPolicy

    static let live = AppBootstrapConfiguration(
        sessionSource: .live,
        persistenceMode: .persistent,
        seedPolicy: .never
    )

    static let preview = AppBootstrapConfiguration(
        sessionSource: .preview,
        persistenceMode: .inMemory,
        seedPolicy: .never
    )

    #if DEBUG
    static let demo = AppBootstrapConfiguration(
        sessionSource: .demo,
        persistenceMode: .inMemory,
        seedPolicy: .whenExplicit
    )
    #endif

    var usesInMemoryStore: Bool {
        persistenceMode == .inMemory
    }
}

enum AppContainerFactory {
    @MainActor
    static func make(source: AppSession.BootstrapSource) async throws -> AppContainer {
        try await make(configuration: configuration(for: source))
    }

    @MainActor
    static func make(configuration: AppBootstrapConfiguration) async throws -> AppContainer {
        let repositories = try await prepareRepositories(for: configuration)
        let clock = RuntimeBootstrap.clock(for: configuration)
        let platformServices = SystemSurfaceBootstrap.makePlatformServices(repositories: repositories)
        let lifeCalendarURL = lifeCalendarStoreURL(for: configuration)
        let runtime = RuntimeBootstrap.makeRuntime(
            repositories: repositories,
            clock: clock,
            notificationService: platformServices.notificationService,
            calendarRemindersService: platformServices.calendarRemindersService,
            scheduleStoreFileURL: lifeCalendarURL
        )
        let session = try await SystemSurfaceBootstrap.prepareSession(
            configuration: configuration,
            repositories: repositories,
            clock: clock
        )
        let navigation = StageStore(selectedSurface: session.initialTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let runtimeCommandClient = makeRuntimeCommandClient(
            repositories: repositories,
            captureService: runtime.captureService,
            scheduleStoreFileURL: lifeCalendarURL
        )
        let surfaceServices = SystemSurfaceBootstrap.makeServices(
            repositories: repositories,
            runtime: runtime,
            navigation: navigation,
            externalRouter: externalRouter,
            runtimeCommandClient: runtimeCommandClient,
            appRouteForIntent: appRoute
        )
        let todayService = RuntimeBootstrap.todayService(for: configuration, runtime: runtime)
        let timeService = RuntimeBootstrap.timeService(runtime: runtime)
        await SystemSurfaceBootstrap.prepareLaunchEffects(
            runtime: runtime,
            notificationService: platformServices.notificationService,
            clock: clock
        )

        return AppContainer(
            bootstrapConfiguration: configuration,
            session: session,
            clock: clock,
            runtimeCommandClient: runtimeCommandClient,
            runtime: runtime,
            appearancePreference: session.appearancePreference,
            accentFamily: session.accentFamily,
            navigation: navigation,
            todayService: todayService,
            todayReceiptCommands: surfaceServices.todayReceiptCommands,
            captureService: runtime.captureService,
            goalsService: runtime.goalsService,
            timeRitualsService: runtime.timeRitualsService,
            timeService: timeService,
            insightsService: runtime.insightsService,
            youService: runtime.youService,
            youPreferencesCommands: surfaceServices.youPreferencesCommands,
            notificationService: platformServices.notificationService,
            calendarRemindersService: platformServices.calendarRemindersService,
            actionRouter: surfaceServices.actionRouter,
            externalRouter: externalRouter,
            externalActionService: surfaceServices.externalActionService,
            externalCreationImportService: surfaceServices.externalCreationImportService,
            sourceAtlasLifecycleRefreshService: surfaceServices.sourceAtlasLifecycleRefreshService,
            commandRouter: surfaceServices.commandRouter,
            memoryLensService: surfaceServices.memoryLensService,
            onboardingService: surfaceServices.onboardingService,
            captureGoalHandoffCommands: CaptureGoalHandoffService(
                repositories: repositories,
                runtimeClient: runtimeCommandClient
            )
        )
    }

    static func prepareRepositories(
        for configuration: AppBootstrapConfiguration,
        store overrideStore: AmbitionsPersistenceStore? = nil
    ) async throws -> AppRepositories {
        try await PersistenceBootstrap.prepareRepositories(for: configuration, store: overrideStore)
    }

    private static func makeRuntimeCommandClient(
        repositories: AppRepositories,
        captureService: any CaptureServicing,
        scheduleStoreFileURL: URL
    ) -> RuntimeCommandClient {
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: repositories.eventLedger,
            actionReceiptHistory: repositories.actionReceiptHistory,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex,
            commandJournal: repositories.commandJournal,
            // Durable idempotency is owned by EventStoreSQLite's authority transaction.
            // This actor is retained only for non-SQLite preview/test stores.
            runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore(),
            smartAttachmentService: DefaultSmartAttachmentService(),
            validator: AmbitionsCommandValidator(),
            runtimeValidator: nil,
            compiler: nil,
            receiptFactory: CommandReceiptFactory(),
            scheduleStoreFileURL: scheduleStoreFileURL,
            todayActionMaterializer: repositories.todayGoalStepActionMaterializer
                ?? RepositoryTodayGoalStepActionMaterializer(repositories: repositories),
            timeRitualActionMaterializer: repositories.timeRitualActionMaterializer
                ?? RepositoryTimeRitualActionMaterializer(repositories: repositories),
            captureGoalHandoffMaterializer: repositories.captureGoalHandoffMaterializer
                ?? RepositoryCaptureGoalHandoffMaterializer(repositories: repositories)
        )
        let projectionStore = repositories.projectionStore

        return RuntimeCommandClient(
            execute: { command, context in
                await executor.execute(command, context: context)
            },
            projection: { request in
                guard let projectionStore,
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
    }

    static func lifeCalendarStoreURL(
        for configuration: AppBootstrapConfiguration,
        isolatedStoreID: UUID = UUID()
    ) -> URL {
        let root: URL
        switch configuration.sessionSource {
        case .live:
            root = URL.applicationSupportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
        case .preview, .demo:
            root = URL.temporaryDirectory
                .appendingPathComponent("AmbitionsPreviewData", isDirectory: true)
                .appendingPathComponent(configuration.sessionSource.rawValue, isDirectory: true)
                .appendingPathComponent(isolatedStoreID.uuidString, isDirectory: true)
        }
        return root.appendingPathComponent("LifeCalendar.json", isDirectory: false)
    }

    static func appRoute(
        for intent: RuntimeRouteIntent,
        source: ExternalActionSource
    ) -> AppExternalRoute {
        switch intent {
        case let .openGoal(id):
            return .openGoalDetail(goalID: id)
        case let .openCapture(id):
            return .genericExternalEntry(kind: "capture", payload: ["captureID": id])
        case let .openReceipt(id):
            return .genericExternalEntry(kind: "receipt", payload: ["receiptID": id])
        case .returnToToday:
            return .openTab(.today)
        case .composeCapture:
            return .openCaptureComposer
        case .openMemoryLens:
            return .presentOverlay(.memoryLens(entrySource: entrySource(for: source)))
        }
    }

    private static func entrySource(for source: ExternalActionSource) -> ShellCommandEntrySource {
        switch source {
        case .deepLink: .deepLink
        case .notification: .notification
        case .widget: .widget
        case .appIntent: .appIntent
        case .futureExternalPayload: .external
        }
    }

    private static func configuration(for source: AppSession.BootstrapSource) -> AppBootstrapConfiguration {
        switch source {
        case .live:
            return .live
        case .preview:
            return .preview
        case .demo:
            #if DEBUG
            return .demo
            #else
            return .live
            #endif
        }
    }
}
