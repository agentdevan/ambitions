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
    static func make(source: AppSession.BootstrapSource) async throws -> AppContainer {
        try await make(configuration: configuration(for: source))
    }

    static func make(configuration: AppBootstrapConfiguration) async throws -> AppContainer {
        let repositories = try await prepareRepositories(for: configuration)
        let snapshotWriter = ExternalSurfaceSnapshotWriter(repositories: repositories)
        let notificationService = LocalNotificationFoundation()
        let calendarRemindersService = EventKitIntegrationService()
        let snapshotTodayService = SnapshotRefreshingTodayService(
            base: RepositoryBackedTodayService(
                repositories: repositories,
                calendarRemindersService: calendarRemindersService
            ),
            snapshotWriter: snapshotWriter
        )
        let snapshotGoalsService = SnapshotRefreshingGoalsService(
            base: RepositoryBackedGoalsService(
                repositories: repositories,
                calendarRemindersService: calendarRemindersService
            ),
            snapshotWriter: snapshotWriter
        )
        let captureService = DefaultCaptureService(repository: repositories.captures)
        let todayService = NotificationSchedulingTodayService(
            base: snapshotTodayService,
            notificationService: notificationService
        )
        let goalsService = NotificationSchedulingGoalsService(
            base: snapshotGoalsService,
            notificationService: notificationService
        )

        let preferencesStore = RepositoryBackedAppPreferencesStore(appStateRepository: repositories.appState)
        let startupService = DefaultStartupService(preferencesStore: preferencesStore, appStateRepository: repositories.appState)
        let session = try await startupService.prepareSession(source: configuration.sessionSource)
        let navigation = AppNavigationModel(selectedTab: session.initialTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        await notificationService.registerCategories()
        await snapshotWriter.refresh(now: .now)
        await notificationService.refreshSchedule(now: .now)

        return AppContainer(
            session: session,
            appearancePreference: session.appearancePreference,
            navigation: navigation,
            todayService: todayService,
            captureService: captureService,
            goalsService: goalsService,
            habitsService: RepositoryBackedHabitsService(repositories: repositories),
            insightsService: RepositoryBackedInsightsService(repositories: repositories),
            profileService: RepositoryBackedProfileService(repositories: repositories),
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter
        )
    }

    static func prepareRepositories(
        for configuration: AppBootstrapConfiguration,
        store overrideStore: AmbitionsPersistenceStore? = nil
    ) async throws -> AppRepositories {
        let store: AmbitionsPersistenceStore
        if let overrideStore {
            store = overrideStore
        } else {
            store = try AmbitionsPersistenceStore(inMemory: configuration.usesInMemoryStore)
        }

        let repositories = makeRepositories(store: store)
        try await applySeedPolicy(configuration.seedPolicy, to: repositories)
        return repositories
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

    private static func applySeedPolicy(_ seedPolicy: AppBootstrapConfiguration.SeedPolicy, to repositories: AppRepositories) async throws {
        switch seedPolicy {
        case .never:
            return
        case .whenExplicit:
            try await DemoSeedPipeline(repositories: repositories).seedIfNeeded(force: true)
        }
    }

    private static func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
