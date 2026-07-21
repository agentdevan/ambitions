import Foundation

enum PersistenceBootstrap {
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

        let repositories = makeRepositories(store: store, configuration: configuration)
        try await applySeedPolicy(configuration.seedPolicy, to: repositories)
        return repositories
    }

    static func makeRepositories(
        store: AmbitionsPersistenceStore,
        configuration: AppBootstrapConfiguration
    ) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            reminders: SwiftDataReminderRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            eventLedger: SwiftDataEventLedgerRepository(store: store),
            sideEffectLedger: SwiftDataSideEffectLedgerRepository(store: store),
            actionReceiptHistory: SwiftDataActionReceiptHistoryRepository(store: store),
            entityRevisionTombstones: SwiftDataEntityRevisionTombstoneRepository(store: store),
            runtimeSnapshotLedger: SwiftDataRuntimeSnapshotLedgerRepository(store: store),
            commandExecutionRecords: SwiftDataAmbitionsCommandExecutionRecordRepository(store: store),
            runtimeEvents: runtimeEventStore(for: configuration),
            projectionStore: projectionStore(for: configuration),
            appGroupSnapshotStore: appGroupSnapshotStore(for: configuration),
            searchIndex: searchIndex(for: configuration),
            commandJournal: commandJournal(for: configuration),
            executionLedgerReplayInspection: SwiftDataExecutionLedgerReplayInspectionRepository(store: store),
            graphOperationalRecords: SwiftDataAmbitionGraphOperationalRecordRepository(store: store),
            graphProofRecords: SwiftDataAmbitionGraphProofRecordRepository(store: store),
            graphProjectionRecords: SwiftDataAmbitionGraphProjectionRecordRepository(store: store),
            lifeContext: SwiftDataLifeContextRepository(store: store),
            goalCreationUnitOfWork: SwiftDataGoalCreationUnitOfWork(store: store),
            capturePromotionUnitOfWork: SwiftDataCapturePromotionUnitOfWork(store: store),
            todayGoalStepActionMaterializer: SwiftDataTodayGoalStepActionMaterializer(store: store),
            timeRitualActionMaterializer: SwiftDataTimeRitualActionMaterializer(store: store),
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    static func runtimeEventStore(for configuration: AppBootstrapConfiguration) -> any RuntimeEventStore {
        if configuration.usesInMemoryStore {
            return InMemoryRuntimeEventStore()
        }
        return EventStoreSQLite.defaultLiveStore()
    }

    static func projectionStore(for configuration: AppBootstrapConfiguration) -> ProjectionStoreSQLite? {
        if configuration.usesInMemoryStore {
            return ProjectionStoreSQLite(
                databaseURL: FileManager.default.temporaryDirectory
                    .appendingPathComponent("AmbitionsPreviewProjectionStores", isDirectory: true)
                    .appendingPathComponent(UUID().uuidString, isDirectory: true)
                    .appendingPathComponent("ProjectionStore.sqlite", isDirectory: false)
            )
        }
        return ProjectionStoreSQLite.defaultLiveStore()
    }

    static func appGroupSnapshotStore(for configuration: AppBootstrapConfiguration) -> AppGroupSnapshotStore? {
        if configuration.usesInMemoryStore {
            return nil
        }
        return AppGroupSnapshotStore.defaultLiveStore()
    }

    static func searchIndex(for configuration: AppBootstrapConfiguration) -> FTSIndex? {
        if configuration.usesInMemoryStore {
            return nil
        }
        return FTSIndex(store: SearchStoreFTS.defaultLiveStore())
    }

    static func commandJournal(for configuration: AppBootstrapConfiguration) -> any CommandJournal {
        if configuration.usesInMemoryStore {
            return InMemoryCommandJournal()
        }
        return FileCommandJournal.defaultLiveStore()
    }

    private static func applySeedPolicy(_ seedPolicy: AppBootstrapConfiguration.SeedPolicy, to repositories: AppRepositories) async throws {
        switch seedPolicy {
        case .never:
            #if DEBUG
            try await applyPreviewCaptureSeedIfNeeded(to: repositories)
            try await DemoSeedPipeline(repositories: repositories).applyRenderedTimeFoundationSeedIfNeeded()
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
}
