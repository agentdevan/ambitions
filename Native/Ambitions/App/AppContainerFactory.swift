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
        let runtime = RuntimeBootstrap.makeRuntime(
            repositories: repositories,
            clock: clock,
            notificationService: platformServices.notificationService,
            calendarRemindersService: platformServices.calendarRemindersService
        )
        let session = try await SystemSurfaceBootstrap.prepareSession(
            configuration: configuration,
            repositories: repositories,
            clock: clock
        )
        let navigation = StageStore(selectedSurface: session.initialTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let surfaceServices = SystemSurfaceBootstrap.makeServices(
            repositories: repositories,
            runtime: runtime,
            navigation: navigation,
            externalRouter: externalRouter
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
            onboardingService: surfaceServices.onboardingService
        )
    }

    static func prepareRepositories(
        for configuration: AppBootstrapConfiguration,
        store overrideStore: AmbitionsPersistenceStore? = nil
    ) async throws -> AppRepositories {
        try await PersistenceBootstrap.prepareRepositories(for: configuration, store: overrideStore)
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
