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
        let notificationService = LocalNotificationFoundation()
        let calendarRemindersService = EventKitIntegrationService()
        let runtime = AmbitionsRuntimeFactory.make(
            repositories: repositories,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService
        )

        let preferencesStore = RepositoryBackedAppPreferencesStore(appStateRepository: repositories.appState)
        let startupService = DefaultStartupService(preferencesStore: preferencesStore, appStateRepository: repositories.appState)
        let session = try await startupService.prepareSession(source: configuration.sessionSource)
        let navigation = AppNavigationModel(selectedTab: session.initialTab)
        let externalRouter = DefaultAppExternalRouter(navigation: navigation)
        let todayService = previewTodayServiceOverride(for: configuration.sessionSource) ?? runtime.todayService
        let externalActionService = DefaultExternalActionCommandService(
            runtimeExecutor: runtime.actionExecutor,
            externalRouter: externalRouter
        )
        let commandRouter = DefaultShellCommandRouter(
            navigation: navigation,
            captureService: runtime.captureService
        )
        let memoryLensService = DefaultMemoryLensService(repositories: repositories)
        let onboardingService = RepositoryBackedOnboardingService(appStateRepository: repositories.appState)
        await notificationService.registerCategories()
        await runtime.snapshotWriter.refresh(now: .now)
        await notificationService.refreshSchedule(now: .now)

        return AppContainer(
            session: session,
            runtime: runtime,
            appearancePreference: session.appearancePreference,
            accentFamily: session.accentFamily,
            navigation: navigation,
            todayService: todayService,
            captureService: runtime.captureService,
            goalsService: runtime.goalsService,
            habitsService: runtime.habitsService,
            planService: runtime.planService,
            insightsService: runtime.insightsService,
            profileService: runtime.profileService,
            notificationService: notificationService,
            calendarRemindersService: calendarRemindersService,
            actionRouter: DefaultAppActionRouter(navigation: navigation),
            externalRouter: externalRouter,
            externalActionService: externalActionService,
            commandRouter: commandRouter,
            memoryLensService: memoryLensService,
            onboardingService: onboardingService
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
            #if DEBUG
            try await applyPreviewCaptureSeedIfNeeded(to: repositories)
            #endif
            return
        case .whenExplicit:
            try await DemoSeedPipeline(repositories: repositories).seedIfNeeded(force: true)
        }
    }

    #if DEBUG
    private static func applyPreviewCaptureSeedIfNeeded(to repositories: AppRepositories) async throws {
        guard ProcessInfo.processInfo.environment["AMBITIONS_UI_SEED_CAPTURES"] == "1" else {
            return
        }

        try await repositories.captures.saveCaptures(PreviewFixtures.default.captures)
    }
    #endif

    private static func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    private static func previewTodayServiceOverride(for source: AppSession.BootstrapSource) -> (any TodayServicing)? {
        #if DEBUG
        guard source == .preview,
              let scenarioName = ProcessInfo.processInfo.environment["AMBITIONS_PREVIEW_TODAY_SCENARIO"],
              let experience = PreviewTodayScenarios.named(scenarioName) else {
            return nil
        }
        return StubTodayService(experience: experience)
        #else
        _ = source
        return nil
        #endif
    }
}
