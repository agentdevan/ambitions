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
        let request = GoalDetailActionRequest(target: created.target, kind: .createReminder, stepID: step.id)

        let first = try await fixture.goals.performAction(request, now: fixture.now)
        let replay = try await fixture.goals.performAction(request, now: fixture.now)

        XCTAssertEqual(first.message?.title, "Reminder created")
        XCTAssertEqual(replay.message?.title, "Reminder created")
        let reminderSaveCount = await fixture.eventKitStore.reminderSaveCount
        let authorityEvents = try await fixture.runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let succeededSideEffects = try await fixture.sideEffectLedger.fetchRecords(status: .succeeded)
        XCTAssertEqual(reminderSaveCount, 1)
        XCTAssertEqual(authorityEvents.count, 1)
        XCTAssertEqual(succeededSideEffects.count, 1)
    }

    func testTodayReminderAuthorityFailureNeverWritesEventKitOrSuccessReceipt() async throws {
        let fixture = try await makeFixture(runtimeEvents: FailingOwnerExternalEffectRuntimeStore())
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
        let sideEffects = try await fixture.sideEffectLedger.fetchRecent(limit: 10)
        XCTAssertEqual(reminderSaveCount, 0)
        XCTAssertTrue(sideEffects.isEmpty)
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

    func makeFixture(runtimeEvents: any RuntimeEventStore) async throws -> Fixture {
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
        let eventKitStore = OwnerExternalEffectEventKitStore()
        let eventKit = EventKitIntegrationService(
            storeClient: eventKitStore,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )
        return Fixture(
            now: now,
            repositories: repositories,
            runtimeEvents: runtimeEvents,
            sideEffectLedger: sideEffectLedger,
            eventKitStore: eventKitStore,
            goals: RepositoryBackedGoalsService(repositories: repositories, calendarRemindersService: eventKit),
            today: RepositoryBackedTodayService(repositories: repositories, calendarRemindersService: eventKit)
        )
    }
}

private actor OwnerExternalEffectEventKitStore: EventKitStoreClient {
    private(set) var reminderSaveCount = 0

    func authorizationState(for scope: CalendarRemindersScope) -> CalendarRemindersAuthorizationState {
        _ = scope
        return .fullAccess
    }

    func requestAuthorization(for scope: CalendarRemindersScope) -> CalendarRemindersAuthorizationState {
        _ = scope
        return .fullAccess
    }

    func requestWriteOnlyAuthorizationForEvents() -> CalendarRemindersAuthorizationState { .fullAccess }

    func saveReminder(_ payload: EventKitReminderPayload) -> String {
        _ = payload
        reminderSaveCount += 1
        return "reminder-\(reminderSaveCount)"
    }

    func saveEvent(_ payload: EventKitEventPayload) -> String {
        _ = payload
        return "event-1"
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
