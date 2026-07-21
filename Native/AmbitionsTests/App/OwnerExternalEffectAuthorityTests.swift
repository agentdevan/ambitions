import XCTest
@testable import Ambitions

final class OwnerExternalEffectAuthorityTests: XCTestCase {
    func testGoalReminderCommitsAuthorityBeforeEventKitAndReplayDoesNotDuplicate() async throws {
        let fixture = try await makeFixture(runtimeEvents: InMemoryRuntimeEventStore())
        let created = try await fixture.goals.createGoal(
            CreateGoalRequest(title: "Submit architecture proposal 2026-09-01"),
            now: fixture.now
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await fixture.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.last)
        let request = GoalDetailActionRequest(
            operationID: "9aa59011-76b2-49dc-a942-96946fd7efff",
            target: created.target,
            kind: .createReminder,
            stepID: step.id
        )

        let first = try await fixture.goals.performAction(request, now: fixture.now)
        let replay = try await fixture.goals.performAction(request, now: fixture.now.addingTimeInterval(90))

        XCTAssertEqual(first.message?.title, "Reminder created")
        XCTAssertEqual(replay.message?.title, "Reminder created")
        let reminderSaveCount = await fixture.eventKitStore.reminderSaveCount
        let authorityEvents = try await fixture.runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let succeededSideEffects = try await fixture.sideEffectLedger.fetchRecords(status: .succeeded)
        XCTAssertEqual(reminderSaveCount, 1)
        XCTAssertEqual(authorityEvents.count, 1)
        XCTAssertEqual(succeededSideEffects.count, 1)
    }

    func testGoalCalendarEventVaryingTimeRetryUsesStableOperationIdentity() async throws {
        let fixture = try await makeFixture(runtimeEvents: InMemoryRuntimeEventStore())
        let created = try await fixture.goals.createGoal(
            CreateGoalRequest(title: "Schedule architecture review 2026-09-01"),
            now: fixture.now
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let loadedGoal = try await fixture.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.last)
        let request = GoalDetailActionRequest(
            operationID: "bd64940a-0f74-41e2-803c-92d978807ae3",
            target: created.target,
            kind: .createCalendarEvent,
            stepID: step.id
        )

        _ = try await fixture.goals.performAction(request, now: fixture.now)
        _ = try await fixture.goals.performAction(request, now: fixture.now.addingTimeInterval(120))

        let eventSaveCount = await fixture.eventKitStore.eventSaveCount
        XCTAssertEqual(eventSaveCount, 1)
        let authorityEvents = try await fixture.runtimeEvents.fetchEvents(matching: .all, limit: nil)
        XCTAssertEqual(authorityEvents.count, 1)
    }

    func testTodayReminderAuthorityFailureNeverWritesEventKitOrSuccessReceipt() async throws {
        let fixture = try await makeFixture(
            runtimeEvents: FailingOwnerExternalEffectRuntimeStore(),
            authorizationState: .notDetermined
        )
        let created = try await fixture.goals.createGoal(
            CreateGoalRequest(title: "Protect external writes 2026-09-01"),
            now: fixture.now
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await fixture.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.last)

        do {
            _ = try await fixture.today.performAction(
                TodayInlineAction(
                    kind: .createReminder,
                    title: "Create reminder",
                    systemImage: "checklist",
                    state: .default,
                    target: TodayActionTarget(goalID: goalID, stepID: step.id)
                ),
                now: fixture.now
            )
            XCTFail("Expected authority failure to block the owner path.")
        } catch let error as RuntimeExternalEffectAuthorizationError {
            XCTAssertEqual(error, .authorityDidNotCommit)
        }

        let reminderSaveCount = await fixture.eventKitStore.reminderSaveCount
        let authorizationRequestCount = await fixture.eventKitStore.authorizationRequestCount
        let sideEffects = try await fixture.sideEffectLedger.fetchRecent(limit: 10)
        XCTAssertEqual(reminderSaveCount, 0)
        XCTAssertEqual(authorizationRequestCount, 0)
        XCTAssertTrue(sideEffects.isEmpty)
    }

    func testGoalReminderAuthorityFailureNeverRequestsPermission() async throws {
        let fixture = try await makeFixture(
            runtimeEvents: FailingOwnerExternalEffectRuntimeStore(),
            authorizationState: .notDetermined
        )
        let created = try await fixture.goals.createGoal(
            CreateGoalRequest(title: "Protect Goal reminder authority 2026-09-01"),
            now: fixture.now
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let loadedGoal = try await fixture.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.last)

        do {
            _ = try await fixture.goals.performAction(
                GoalDetailActionRequest(
                    operationID: "3e23be93-e0b9-4a47-a6cc-9a9197c5c53a",
                    target: created.target,
                    kind: .createReminder,
                    stepID: step.id
                ),
                now: fixture.now
            )
            XCTFail("Expected authority failure to block the Goal owner path.")
        } catch let error as RuntimeExternalEffectAuthorizationError {
            XCTAssertEqual(error, .authorityDidNotCommit)
        }

        let authorizationRequestCount = await fixture.eventKitStore.authorizationRequestCount
        let reminderSaveCount = await fixture.eventKitStore.reminderSaveCount
        XCTAssertEqual(authorizationRequestCount, 0)
        XCTAssertEqual(reminderSaveCount, 0)
    }

    func testFileBackedCalendarIdentityMatchesAcrossAuthorizerAndEventKitRetry() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("OwnerExternalEffectFileIdentity-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: directory) }
        let pendingStore = FilePendingEventKitOperationStore(
            fileURL: directory.appendingPathComponent("pending-operations.json")
        )
        let fixture = try await makeFixture(
            runtimeEvents: InMemoryRuntimeEventStore(),
            pendingOperationStore: pendingStore
        )
        let created = try await fixture.goals.createGoal(
            CreateGoalRequest(title: "Verify file-backed calendar identity 2026-09-01"),
            now: fixture.now
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let loadedGoal = try await fixture.repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.last)
        let request = GoalDetailActionRequest(
            operationID: "6e1b8201-80e5-4f3c-91c8-307153413322",
            target: created.target,
            kind: .createCalendarEvent,
            stepID: step.id
        )

        _ = try await fixture.goals.performAction(request, now: fixture.now)
        _ = try await fixture.goals.performAction(request, now: fixture.now.addingTimeInterval(60))

        let eventSaveCount = await fixture.eventKitStore.eventSaveCount
        let succeeded = try await fixture.sideEffectLedger.fetchRecords(status: .succeeded)
        XCTAssertEqual(eventSaveCount, 1)
        XCTAssertEqual(succeeded.count, 1)
    }
}

private extension OwnerExternalEffectAuthorityTests {
    struct Fixture {
        let now: Date
        let repositories: AppRepositories
        let runtimeEvents: any RuntimeEventStore
        let sideEffectLedger: InMemorySideEffectLedgerRepository
        let eventKitStore: OwnerExternalEffectEventKitStore
        let goals: RepositoryBackedGoalsService
        let today: RepositoryBackedTodayService
    }

    func makeFixture(
        runtimeEvents: any RuntimeEventStore,
        pendingOperationStore: (any PendingEventKitOperationStoring)? = nil,
        authorizationState: CalendarRemindersAuthorizationState = .fullAccess
    ) async throws -> Fixture {
        let now = Date(timeIntervalSince1970: 1_785_585_600)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let sideEffectLedger = InMemorySideEffectLedgerRepository()
        let repositories = AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            sideEffectLedger: sideEffectLedger,
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            runtimeEvents: runtimeEvents,
            commandJournal: InMemoryCommandJournal(),
            appState: SwiftDataAppStateRepository(store: store)
        )
        let resolvedPendingOperationStore: any PendingEventKitOperationStoring
        if let pendingOperationStore {
            resolvedPendingOperationStore = pendingOperationStore
        } else {
            resolvedPendingOperationStore = MemoryPendingEventKitOperationStore()
        }
        let eventKitStore = OwnerExternalEffectEventKitStore(authorizationState: authorizationState)
        let eventKit = EventKitIntegrationService(
            storeClient: eventKitStore,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger)),
            pendingOperationStore: resolvedPendingOperationStore
        )
        let externalEffectAuthorizer = RuntimeExternalEffectCommandAuthorizer(
            repositories: repositories,
            pendingOperationStore: resolvedPendingOperationStore
        )
        return Fixture(
            now: now,
            repositories: repositories,
            runtimeEvents: runtimeEvents,
            sideEffectLedger: sideEffectLedger,
            eventKitStore: eventKitStore,
            goals: RepositoryBackedGoalsService(
                repositories: repositories,
                calendarRemindersService: eventKit,
                externalEffectAuthorizer: externalEffectAuthorizer
            ),
            today: RepositoryBackedTodayService(
                repositories: repositories,
                calendarRemindersService: eventKit,
                externalEffectAuthorizer: externalEffectAuthorizer
            )
        )
    }
}

private actor OwnerExternalEffectEventKitStore: EventKitStoreClient {
    private var authorizationState: CalendarRemindersAuthorizationState
    private(set) var authorizationRequestCount = 0
    private(set) var reminderSaveCount = 0
    private(set) var eventSaveCount = 0

    init(authorizationState: CalendarRemindersAuthorizationState = .fullAccess) {
        self.authorizationState = authorizationState
    }

    func authorizationState(for scope: CalendarRemindersScope) -> CalendarRemindersAuthorizationState {
        _ = scope
        return authorizationState
    }

    func requestAuthorization(for scope: CalendarRemindersScope) -> CalendarRemindersAuthorizationState {
        _ = scope
        authorizationRequestCount += 1
        authorizationState = .denied
        return authorizationState
    }

    func requestWriteOnlyAuthorizationForEvents() -> CalendarRemindersAuthorizationState {
        authorizationRequestCount += 1
        return authorizationState
    }

    func saveReminder(_ payload: EventKitReminderPayload) -> String {
        _ = payload
        reminderSaveCount += 1
        return "reminder-\(reminderSaveCount)"
    }

    func saveEvent(_ payload: EventKitEventPayload) -> String {
        _ = payload
        eventSaveCount += 1
        return "event-\(eventSaveCount)"
    }

    func fetchEvents(in interval: DateInterval) -> [EventKitCalendarEventSnapshot] {
        _ = interval
        return []
    }
}

private struct FailingOwnerExternalEffectRuntimeStore: RuntimeEventStore {
    enum Failure: Error { case unavailable }

    var storeKind: RuntimeEventStoreKind { .inMemory }

    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        _ = event
        throw Failure.unavailable
    }

    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope] {
        _ = query
        _ = limit
        return []
    }

    func latestCursor() async throws -> RuntimeEventCursor? { nil }
}
