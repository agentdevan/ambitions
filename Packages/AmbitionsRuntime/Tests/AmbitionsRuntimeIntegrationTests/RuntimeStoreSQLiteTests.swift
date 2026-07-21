import Foundation
import XCTest
import AmbitionsRuntimeCore
@testable import AmbitionsRuntimeSQLite

final class RuntimeStoreSQLiteTests: XCTestCase {
    func testAtomicCommitPersistsCanonicalStoryAndSurvivesRestart() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let store = try RuntimeStoreSQLite(databaseURL: databaseURL)

        let firstReceipt = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let duplicateReceipt = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let firstSnapshot = try await store.snapshot()

        XCTAssertEqual(firstReceipt, transition.receipt)
        XCTAssertEqual(duplicateReceipt, firstReceipt)
        XCTAssertEqual(firstSnapshot.canonicalRevision, 1)
        XCTAssertEqual(firstSnapshot.stateChanges, transition.stateChanges)
        XCTAssertEqual(firstSnapshot.events, transition.events)
        XCTAssertEqual(firstSnapshot.projectionChanges, transition.projectionChanges)
        XCTAssertEqual(firstSnapshot.receipts, [transition.receipt])
        XCTAssertEqual(firstSnapshot.externalEffects, transition.externalEffects)

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let restartedSnapshot = try await restarted.snapshot()
        let restartedReceipt = try await restarted.receipt(
            forCommandID: transition.commandID
        )

        XCTAssertEqual(restartedSnapshot, firstSnapshot)
        XCTAssertEqual(restartedReceipt, firstReceipt)
    }

    func testInjectedInteriorFailureRollsBackEveryAuthorityTable() async throws {
        let store = try RuntimeStoreSQLite(
            databaseURL: temporaryDatabaseURL(),
            failurePoint: .afterEvents
        )

        do {
            _ = try await store.commit(
                makeTransition(),
                idempotencyKey: "capture.001.commit"
            )
            XCTFail("Expected injected failure")
        } catch let error as RuntimeStoreError {
            XCTAssertEqual(error, .injectedFailure(.afterEvents))
        }

        let snapshot = try await store.snapshot()
        XCTAssertEqual(snapshot, .empty)
    }

    func testStaleExpectedRevisionRejectsBeforeMutation() async throws {
        let store = try RuntimeStoreSQLite(databaseURL: temporaryDatabaseURL())
        _ = try await store.commit(
            makeTransition(),
            idempotencyKey: "capture.001.commit"
        )
        let stale = makeTransition(
            commandID: "command.capture.002",
            expectedRevision: 0,
            newRevision: 1
        )

        do {
            _ = try await store.commit(
                stale,
                idempotencyKey: "capture.002.commit"
            )
            XCTFail("Expected revision conflict")
        } catch let error as RuntimeStoreError {
            XCTAssertEqual(
                error,
                .revisionConflict(expected: 0, actual: 1)
            )
        }

        let snapshot = try await store.snapshot()
        XCTAssertEqual(snapshot.receipts.count, 1)
        XCTAssertEqual(snapshot.canonicalRevision, 1)
    }

    private func temporaryDatabaseURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("RuntimeStore.sqlite")
    }

    private func makeTransition(
        commandID: String = "command.capture.001",
        expectedRevision: Int64 = 0,
        newRevision: Int64 = 1
    ) -> RuntimeTransition {
        let aggregate = RuntimeAggregateReference(
            kind: "capture",
            id: "capture.001"
        )
        let event = RuntimeEvent(
            id: "event.\(commandID)",
            kind: "capture.committed",
            aggregate: aggregate,
            aggregateRevision: newRevision,
            payload: Data("event".utf8)
        )
        let projection = RuntimeProjectionChange(
            projection: "today",
            cursor: "cursor.\(newRevision)",
            payload: Data("projection".utf8)
        )
        let effect = RuntimeExternalEffectEnvelope(
            id: "effect.\(commandID)",
            kind: "extension.snapshot.refresh",
            idempotencyKey: "effect.\(commandID)",
            payload: Data("effect".utf8)
        )
        return RuntimeTransition(
            commandID: commandID,
            stateChanges: [
                RuntimeStateChange(
                    aggregate: aggregate,
                    expectedRevision: expectedRevision,
                    newRevision: newRevision,
                    value: Data("state".utf8)
                )
            ],
            events: [event],
            projectionChanges: [projection],
            receipt: RuntimeReceipt(
                id: "receipt.\(commandID)",
                commandID: commandID,
                canonicalRevision: newRevision,
                eventIDs: [event.id],
                projectionCursors: [projection.projection: projection.cursor],
                externalEffectIDs: [effect.id],
                semanticUndoEligible: false
            ),
            compensation: nil,
            externalEffects: [effect]
        )
    }
}
