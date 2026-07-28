import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class YouPreferencesCommandServiceTests: XCTestCase {
    func testMaterializesAfterAuthorityAndPreservesUnrelatedAppState() async throws {
        let runtimeEvents = InMemoryRuntimeEventStore()
        var initialState = AppStateSnapshot.default
        initialState.userDisplayName = "Private local name"
        initialState.hasCompletedBootstrap = true
        initialState.hasCompletedOnboarding = true
        initialState.lastOpenedGoalID = "goal-unrelated"
        initialState.goalPriorityOrder = ["goal-unrelated", "goal-second"]
        let appState = AuthorityCheckingAppStateRepository(
            state: initialState,
            runtimeEvents: runtimeEvents
        )
        let repositories = try await makeRepositories(
            appState: appState,
            runtimeEvents: runtimeEvents
        )

        _ = try await RepositoryBackedYouService(repositories: repositories).saveYouPreferences(
            YouPreferencesUpdate(
                preferredTab: .goals,
                appearancePreference: .light,
                accentFamily: .sand,
                reviewCadenceDays: 0,
                localOnlyModeEnabled: false
            )
        )

        let state = try await appState.loadState()
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let saveCount = await appState.saveCount
        XCTAssertEqual(saveCount, 1)
        XCTAssertEqual(events.count, 1)
        assertPreferences(state, tab: .goals, appearance: .light, accent: .sand, cadence: 1)
        XCTAssertEqual(state.userDisplayName, initialState.userDisplayName)
        XCTAssertEqual(state.hasCompletedBootstrap, initialState.hasCompletedBootstrap)
        XCTAssertEqual(state.hasCompletedOnboarding, initialState.hasCompletedOnboarding)
        XCTAssertEqual(state.lastOpenedGoalID, initialState.lastOpenedGoalID)
        XCTAssertEqual(state.goalPriorityOrder, initialState.goalPriorityOrder)
    }

    func testLeavesAppStateUnchangedWhenAuthorityFails() async throws {
        let runtimeEvents = FailingYouRuntimeEventStore()
        var initialState = AppStateSnapshot.default
        initialState.userDisplayName = "Keep me"
        initialState.goalPriorityOrder = ["goal-keep"]
        let appState = AuthorityCheckingAppStateRepository(
            state: initialState,
            runtimeEvents: runtimeEvents
        )
        let repositories = try await makeRepositories(
            appState: appState,
            runtimeEvents: runtimeEvents
        )
        let service = RepositoryBackedYouService(repositories: repositories)

        do {
            _ = try await service.saveYouPreferences(preferencesForFailure)
            XCTFail("Expected runtime authority failure to remain visible to the caller.")
        } catch {
            XCTAssertTrue(error is YouPreferencesCommandError)
        }

        let finalState = try await appState.loadState()
        let saveCount = await appState.saveCount
        XCTAssertEqual(finalState, initialState)
        XCTAssertEqual(saveCount, 0)
    }

    func testReplayRepairsRecoverableMaterializationWithStableCommand() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("YouPreferencesReplay-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: directory) }
        let runtimeEvents = EventStoreSQLite(
            databaseURL: directory.appendingPathComponent("EventStore.sqlite")
        )
        var initialState = AppStateSnapshot.default
        initialState.userDisplayName = "Preserved on replay"
        let appState = AuthorityCheckingAppStateRepository(
            state: initialState,
            runtimeEvents: runtimeEvents,
            failuresRemaining: 1
        )
        let repositories = try await makeRepositories(appState: appState, runtimeEvents: runtimeEvents)
        let commandID = "you-preferences-command-stable-recovery"
        let service = makeCommandService(repositories: repositories, commandID: commandID)

        await assertFirstAttemptNeedsRecovery(service: service)
        let recoverableRecord = try await repositories.commandExecutionRecords?.fetchRecord(commandID: commandID)
        XCTAssertEqual(recoverableRecord?.result?.status, .succeeded)
        XCTAssertTrue(recoverableRecord?.result.map(RuntimeTransactionCommitPolicy.hasCommittedEvidence) ?? false)
        XCTAssertEqual(recoverableRecord?.result?.metadata["appStateMaterialization"], "needs_recovery")

        _ = try await service.saveYouPreferences(preferencesForRecovery)

        let repairedState = try await appState.loadState()
        let repairedRecord = try await repositories.commandExecutionRecords?.fetchRecord(commandID: commandID)
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        assertPreferences(repairedState, tab: .time, appearance: .light, accent: .mutedGold, cadence: 4)
        XCTAssertEqual(repairedState.userDisplayName, initialState.userDisplayName)
        XCTAssertEqual(repairedRecord?.result?.metadata["appStateMaterialization"], "saved_post_authority")
        XCTAssertEqual(events.count, 1)
    }
}

private extension YouPreferencesCommandServiceTests {
    var preferencesForFailure: YouPreferencesUpdate {
        YouPreferencesUpdate(
            preferredTab: .time,
            appearancePreference: .dark,
            accentFamily: .copper,
            reviewCadenceDays: 2,
            localOnlyModeEnabled: false
        )
    }

    var preferencesForRecovery: YouPreferencesUpdate {
        YouPreferencesUpdate(
            preferredTab: .time,
            appearancePreference: .light,
            accentFamily: .mutedGold,
            reviewCadenceDays: 4,
            localOnlyModeEnabled: false
        )
    }

    func makeCommandService(
        repositories: AppRepositories,
        commandID: String
    ) -> YouPreferencesCommandService {
        let dashboardService = RepositoryBackedYouService(repositories: repositories)
        return YouPreferencesCommandService(
            repositories: repositories,
            loadDashboard: { try await dashboardService.loadYouDashboard() },
            commandIDProvider: { commandID }
        )
    }

    func assertFirstAttemptNeedsRecovery(service: YouPreferencesCommandService) async {
        do {
            _ = try await service.saveYouPreferences(preferencesForRecovery)
            XCTFail("Expected committed preferences to remain recoverable until materialization succeeds.")
        } catch {
            XCTAssertEqual(
                error as? YouPreferencesCommandError,
                .commandMaterializationNeedsRecovery("You preferences saved locally.")
            )
        }
    }

    func assertPreferences(
        _ state: AppStateSnapshot,
        tab: AmbitionsSurface,
        appearance: AppAppearancePreference,
        accent: AmbitionAccentFamily,
        cadence: Int
    ) {
        XCTAssertEqual(state.preferredTab, tab)
        XCTAssertEqual(state.appearancePreference, appearance)
        XCTAssertEqual(state.accentFamily, accent)
        XCTAssertEqual(state.reviewCadenceDays, cadence)
        XCTAssertTrue(state.localOnlyModeEnabled)
    }

    func makeRepositories(
        appState: any AppStateRepository,
        runtimeEvents: any RuntimeEventStore
    ) async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            commandExecutionRecords: SwiftDataAmbitionsCommandExecutionRecordRepository(store: store),
            runtimeEvents: runtimeEvents,
            lifeContext: SwiftDataLifeContextRepository(store: store),
            appState: appState
        )
    }
}

private enum YouPreferencesMaterializationTestError: Error {
    case authorityMissing
    case authorityUnavailable
}

private actor AuthorityCheckingAppStateRepository: AppStateRepository {
    private var state: AppStateSnapshot
    private let runtimeEvents: any RuntimeEventStore
    private(set) var saveCount = 0
    private var failuresRemaining: Int

    init(
        state: AppStateSnapshot,
        runtimeEvents: any RuntimeEventStore,
        failuresRemaining: Int = 0
    ) {
        self.state = state
        self.runtimeEvents = runtimeEvents
        self.failuresRemaining = failuresRemaining
    }

    func loadState() async throws -> AppStateSnapshot {
        state
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        guard events.isEmpty == false else {
            throw YouPreferencesMaterializationTestError.authorityMissing
        }
        if failuresRemaining > 0 {
            failuresRemaining -= 1
            throw YouPreferencesMaterializationTestError.authorityUnavailable
        }
        self.state = state
        saveCount += 1
    }
}

private actor FailingYouRuntimeEventStore: RuntimeEventStore {
    nonisolated var storeKind: RuntimeEventStoreKind { .inMemory }

    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        _ = event
        throw YouPreferencesMaterializationTestError.authorityUnavailable
    }

    func fetchEvents(
        matching query: RuntimeEventQuery,
        limit: Int?
    ) async throws -> [RuntimeEventEnvelope] {
        _ = query
        _ = limit
        return []
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        nil
    }
}
