import XCTest
@testable import Ambitions

final class TodayDurableReceiptMutationIntegrationTests: XCTestCase {
    func testClosureRestartReplaysExactAuthorityReceiptAndReconstructsHistoryOnce() async throws {
        let root = try makeRoot("closure-restart")
        defer { try? FileManager.default.removeItem(at: root) }
        let eventURL = root.appendingPathComponent("EventStore.sqlite")
        let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
        let firstHistory = InMemoryActionReceiptHistoryRepository()
        let firstExecutor = makeExecutor(
            events: EventStoreSQLite(databaseURL: eventURL),
            projections: ProjectionStoreSQLite(databaseURL: projectionURL),
            history: firstHistory
        )
        let firstService = TodayReceiptCommandService(
            actionReceiptHistory: firstHistory,
            runtimeCommandClient: client(firstExecutor, ProjectionStoreSQLite(databaseURL: projectionURL))
        )
        let fixture = closureFixture()

        let first = try await firstService.recordActionClosure(
            fixture.closure,
            outcome: fixture.outcome,
            now: fixture.now
        )
        let firstRecords = try await firstHistory.listRecords()
        let storedProjectionBefore = try await ProjectionStoreSQLite(databaseURL: projectionURL).fetchRecord(id: .today)
        let projectionBefore = try XCTUnwrap(storedProjectionBefore)

        XCTAssertEqual(first.message?.title, "Proof saved")
        XCTAssertNil(first.stageMutation, "Visible state must come from the refreshed committed read model.")
        XCTAssertEqual(firstRecords.count, 1)
        XCTAssertTrue(firstRecords[0].runtimeLineage?.hasCompleteTrustTrace == true)

        let restartedHistory = InMemoryActionReceiptHistoryRepository()
        let restartedProjections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let restartedExecutor = makeExecutor(
            events: EventStoreSQLite(databaseURL: eventURL),
            projections: restartedProjections,
            history: restartedHistory
        )
        let replay = try await TodayReceiptCommandService(
            actionReceiptHistory: restartedHistory,
            runtimeCommandClient: client(restartedExecutor, restartedProjections)
        ).recordActionClosure(fixture.closure, outcome: fixture.outcome, now: fixture.now)
        let replayRecords = try await restartedHistory.listRecords()
        let storedProjectionAfter = try await restartedProjections.fetchRecord(id: .today)
        let projectionAfter = try XCTUnwrap(storedProjectionAfter)

        XCTAssertEqual(replay.message?.title, "Proof saved")
        XCTAssertEqual(replayRecords, firstRecords)
        XCTAssertEqual(replayRecords.count, 1)
        XCTAssertEqual(projectionAfter.payloadChecksum, projectionBefore.payloadChecksum)
        XCTAssertEqual(
            replayRecords[0].runtimeLineage?.runtimeReceiptID,
            firstRecords[0].runtimeLineage?.runtimeReceiptID
        )
        let semanticEvents = try await EventStoreSQLite(databaseURL: eventURL)
            .fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(semanticEvents.count, 1)
    }

    func testRecommendationRejectionRestartReconstructsSensitiveReceiptWithoutDoubleApply() async throws {
        let root = try makeRoot("rejection-restart")
        defer { try? FileManager.default.removeItem(at: root) }
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let history = InMemoryActionReceiptHistoryRepository()
        let executor = makeExecutor(events: events, projections: projections, history: history)
        let service = TodayReceiptCommandService(
            actionReceiptHistory: history,
            runtimeCommandClient: client(executor, projections)
        )
        let input = TodayRecommendationRejectionInput(
            candidateID: "candidate-1",
            sourceCandidateID: "source-candidate-1",
            sourceStepID: "step-1",
            contextFingerprint: "context-1",
            reason: StepCandidateRejectionReason(code: .emotionallyNotReady),
            skippedReason: false,
            customText: "Not safe today",
            recordedAt: "2027-02-20T09:00:00Z"
        )

        let first = try await service.recordRecommendationRejection(input)
        let duplicate = try await service.recordRecommendationRejection(input)
        let records = try await history.listRecords()

        XCTAssertEqual(first.message?.title, "Reason saved")
        XCTAssertEqual(duplicate.message?.title, "Reason saved")
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].privacyLevel, .sensitive)
        XCTAssertTrue(records[0].runtimeLineage?.hasCompleteTrustTrace == true)
        let semanticEvents = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(semanticEvents.count, 1)
    }

    func testAuthorityFailureLeavesHistoryAndProjectionEmpty() async throws {
        let history = InMemoryActionReceiptHistoryRepository()
        let projections = ProjectionStoreSQLite(databaseURL: temporaryURL("projection-failure"))
        let executor = AmbitionsCommandExecutor.test(
            actionReceiptHistory: history,
            runtimeEvents: TodayFailingRuntimeEventStore(),
            projectionStore: projections
        )
        let fixture = closureFixture()

        let response = try await TodayReceiptCommandService(
            actionReceiptHistory: history,
            runtimeCommandClient: client(executor, projections)
        ).recordActionClosure(fixture.closure, outcome: fixture.outcome, now: fixture.now)

        XCTAssertEqual(response.message?.title, "Closure receipt not saved")
        XCTAssertNil(response.stageMutation)
        let records = try await history.listRecords()
        let projection = try await projections.fetchRecord(id: .today)
        XCTAssertTrue(records.isEmpty)
        XCTAssertNil(projection)
    }

    func testPostAuthorityHistoryFailureReturnsNoVisibleSuccessAndReplayRepairsMaterialization() async throws {
        let root = try makeRoot("history-recovery")
        defer { try? FileManager.default.removeItem(at: root) }
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let failingHistory = TodayFailingActionReceiptHistoryRepository()
        let firstExecutor = makeExecutor(events: events, projections: projections, history: failingHistory)
        let fixture = closureFixture()

        let failedMaterialization = try await TodayReceiptCommandService(
            actionReceiptHistory: failingHistory,
            runtimeCommandClient: client(firstExecutor, projections)
        ).recordActionClosure(fixture.closure, outcome: fixture.outcome, now: fixture.now)

        XCTAssertEqual(failedMaterialization.message?.title, "Closure saved; history needs recovery")
        XCTAssertNil(failedMaterialization.stageMutation)
        let authorityReceipt = try await events.authorityReceipt(commandID: closureCommandID(fixture))
        let committedProjection = try await projections.fetchRecord(id: .today)
        XCTAssertNotNil(authorityReceipt)
        XCTAssertNotNil(committedProjection)

        let repairedHistory = InMemoryActionReceiptHistoryRepository()
        let replayExecutor = makeExecutor(events: events, projections: projections, history: repairedHistory)
        let replay = try await TodayReceiptCommandService(
            actionReceiptHistory: repairedHistory,
            runtimeCommandClient: client(replayExecutor, projections)
        ).recordActionClosure(fixture.closure, outcome: fixture.outcome, now: fixture.now)

        XCTAssertEqual(replay.message?.title, "Proof saved")
        let repairedRecords = try await repairedHistory.listRecords()
        XCTAssertEqual(repairedRecords.count, 1)
    }

    private func makeExecutor(
        events: any RuntimeEventStore,
        projections: ProjectionStoreSQLite,
        history: any ActionReceiptHistoryRepository
    ) -> AmbitionsCommandExecutor {
        AmbitionsCommandExecutor.test(
            actionReceiptHistory: history,
            runtimeEvents: events,
            projectionStore: projections
        )
    }

    private func client(
        _ executor: AmbitionsCommandExecutor,
        _ projections: ProjectionStoreSQLite
    ) -> RuntimeCommandClient {
        RuntimeCommandClient(
            execute: { command, context in await executor.execute(command, context: context) },
            projection: { request in
                guard let record = try await projections.fetchRecord(id: request.projectionID) else {
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

    private func closureFixture() -> (closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date) {
        let closure = TodayActionClosureSheetState.step(
            title: "Write the launch notes",
            context: "Start here",
            target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
        )
        return (
            closure,
            closure.outcomes.first { $0.closureState == .stillCounts }!,
            DomainTimestamp.date(from: "2027-02-20T08:00:00Z")!
        )
    }

    private func closureCommandID(
        _ fixture: (closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date)
    ) -> String {
        "today.closure.command.\(fixture.closure.id).\(fixture.outcome.id).2027-02-20t08-00-00-000z"
    }

    private func makeRoot(_ name: String) throws -> URL {
        let url = temporaryURL(name)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func temporaryURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("TodayDurableReceiptMutationIntegrationTests-\(name)-\(UUID().uuidString)")
    }
}

private struct TodayFailingActionReceiptHistoryRepository: ActionReceiptHistoryRepository {
    struct Failure: Error {}

    func save(_ records: [ActionReceiptHistoryRecord]) async throws { throw Failure() }
    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection { throw Failure() }
    func listRecords() async throws -> [ActionReceiptHistoryRecord] { [] }
}

private struct TodayFailingRuntimeEventStore: RuntimeEventStore {
    struct Failure: Error {}

    var storeKind: RuntimeEventStoreKind { .inMemory }

    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope { throw Failure() }
    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope] { [] }
    func latestCursor() async throws -> RuntimeEventCursor? { nil }
}
