import XCTest
@testable import Ambitions

final class TimeCommandReplayTests: XCTestCase {
    func testUndoRequiresReceiptAndProjectionVersionAndCannotApplyTwice() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("time-undo-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let eventStore = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projectionStore = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: eventStore,
            projectionStore: projectionStore,
            scheduleStoreFileURL: scheduleURL
        )
        let placement = placementCommand()
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: placement.createdAt)))
        let placed = await executor.execute(placement, context: context)
        let placedProjection = try await projectionStore.fetchRecord(id: .time)
        let version = try XCTUnwrap(placedProjection?.cursor.sequence)
        let receiptID = try XCTUnwrap(placed.metadata["runtimeReceiptID"])

        let undo = undoCommand(id: "command.time.undo", receiptID: receiptID, expectedVersion: version)
        let undone = await executor.execute(undo, context: context)
        XCTAssertEqual(undone.status, .succeeded)
        XCTAssertEqual(undone.metadata["undoOriginalReceiptID"], receiptID)
        let store = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await store.loadFromDisk()
        let graphAfterUndo = await store.graph()
        XCTAssertTrue(graphAfterUndo.blocks.isEmpty)

        let restartedExecutor = AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite")),
            projectionStore: ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite")),
            scheduleStoreFileURL: scheduleURL
        )
        let replayedUndo = await restartedExecutor.execute(undo, context: context)
        XCTAssertEqual(replayedUndo.status, .succeeded)
        XCTAssertEqual(replayedUndo.metadata["runtimeReceiptID"], undone.metadata["runtimeReceiptID"])
        let restartedCalendar = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await restartedCalendar.loadFromDisk()
        let restartedGraph = await restartedCalendar.graph()
        XCTAssertTrue(restartedGraph.blocks.isEmpty)

        let duplicateUndo = undoCommand(id: "command.time.undo-again", receiptID: receiptID, expectedVersion: version)
        let rejected = await executor.execute(duplicateUndo, context: context)
        XCTAssertEqual(rejected.status, .blocked)
        XCTAssertEqual(rejected.metadata["rejectionType"], "time_undo_already_applied")
        XCTAssertNotNil(rejected.metadata["commandReceiptID"])
    }

    func testUndoRejectsStaleProjectionVersionWithoutChangingSchedule() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("time-undo-stale-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let eventStore = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projectionStore = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let executor = AmbitionsCommandExecutor.test(runtimeEvents: eventStore, projectionStore: projectionStore, scheduleStoreFileURL: scheduleURL)
        let placement = placementCommand()
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: placement.createdAt)))
        let placed = await executor.execute(placement, context: context)
        let receiptID = try XCTUnwrap(placed.metadata["runtimeReceiptID"])

        let stale = await executor.execute(
            undoCommand(id: "command.time.undo-stale", receiptID: receiptID, expectedVersion: 0),
            context: context
        )
        XCTAssertEqual(stale.status, .blocked)
        XCTAssertEqual(stale.metadata["rejectionType"], "time_undo_stale_projection")
        let store = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await store.loadFromDisk()
        let graphAfterRejection = await store.graph()
        XCTAssertEqual(graphAfterRejection.blocks.map(\.stepID), ["step.undo"])
    }

    private func placementCommand() -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command.time.place-for-undo", kind: .placeStepInTime, source: .time,
            target: AmbitionsCommandTarget(goalID: "goal.undo", timeID: "block.undo", stepID: "step.undo"),
            payload: AmbitionsCommandPayload(title: "Undoable", metadata: [
                "start": "2026-09-10T13:00:00Z", "end": "2026-09-10T13:30:00Z", "durationMinutes": "30",
            ]),
            createdAt: "2026-09-10T12:00:00Z"
        )
    }

    private func undoCommand(id: String, receiptID: String, expectedVersion: Int64) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id, kind: .correctTimeWindow, source: .time,
            target: AmbitionsCommandTarget(timeID: "block.undo"),
            payload: AmbitionsCommandPayload(title: "Undo", metadata: [
                "undoOriginalReceiptID": receiptID,
                "expectedProjectionVersion": String(expectedVersion),
                "start": "2026-09-10T13:00:00Z",
                "end": "2026-09-10T13:30:00Z",
            ]),
            createdAt: "2026-09-10T12:01:00Z"
        )
    }
}
