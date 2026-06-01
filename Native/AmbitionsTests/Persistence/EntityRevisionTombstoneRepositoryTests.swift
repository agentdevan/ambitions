import XCTest
@testable import Ambitions

final class EntityRevisionTombstoneRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryAppendsAndFetchesRecentNewestFirst() async throws {
        let repository = try await makeRepository()
        let older = tombstone(
            id: "revision-old",
            entityID: "goal-1",
            revisionMarker: "rev-1",
            recordedAt: "2026-05-12T10:00:00Z"
        )
        let newer = tombstone(
            id: "revision-new",
            entityID: "goal-2",
            revisionMarker: "rev-2",
            recordedAt: "2026-05-12T11:00:00Z"
        )

        try await repository.append(older)
        try await repository.append(newer)

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["revision-new", "revision-old"])
    }

    func testSwiftDataRepositoryFetchesByEntityIDInRecentOrder() async throws {
        let repository = try await makeRepository()
        try await repository.append(tombstone(id: "goal1-old", entityID: "goal-1", revisionMarker: "rev-1", recordedAt: "2026-05-12T10:00:00Z"))
        try await repository.append(tombstone(id: "other-goal", entityID: "goal-2", revisionMarker: "rev-2", recordedAt: "2026-05-12T11:00:00Z"))
        try await repository.append(tombstone(id: "goal1-new", entityID: "goal-1", revisionMarker: "rev-3", recordedAt: "2026-05-12T12:00:00Z"))

        let forGoal = try await repository.fetch(for: "goal-1")

        XCTAssertEqual(forGoal.map(\.id), ["goal1-new", "goal1-old"])
    }

    func testSwiftDataRepositoryReplacesEntriesWithSameIDAndSkipsMalformed() async throws {
        let repository = try await makeRepository()
        let stable = tombstone(id: "goal-1", entityID: "goal-1", revisionMarker: "rev-1", reason: .superseded, recordedAt: "2026-05-12T10:00:00Z")
        let replacement = tombstone(id: "goal-1", entityID: "goal-1", revisionMarker: "rev-2", reason: .replaced, recordedAt: "2026-05-12T10:05:00Z")

        try await repository.append(stable)
        try await repository.append(replacement)
        try await repository.append(
            EntityRevisionTombstone(
                id: "malformed",
                entityKind: .goal,
                entityID: "goal-3",
                revisionMarker: "rev-3",
                reason: .unknown,
                recordedAt: "2026-05-12T12:00:00Z",
                schemaVersion: "bad.version"
            )
        )

        let recent = try await repository.fetchRecent(limit: 10)

        XCTAssertEqual(recent.count, 1)
        XCTAssertEqual(recent[0].revisionMarker, "rev-2")
        XCTAssertEqual(recent[0].id, "goal-1")
    }

    func testSwiftDataRepositoryUsesDeterministicIDTieBreakOrdering() async throws {
        let repository = try await makeRepository()

        try await repository.append(tombstone(id: "same-time-a", entityID: "goal-1", revisionMarker: "same", recordedAt: "2026-05-12T10:00:00Z"))
        try await repository.append(tombstone(id: "same-time-b", entityID: "goal-1", revisionMarker: "same", recordedAt: "2026-05-12T10:00:00Z"))

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["same-time-b", "same-time-a"])
    }

    func testSwiftDataRepositoryTracksLineageAncestryAndLifecycleBuckets() async throws {
        let repository = try await makeRepository()
        let recoverable = tombstone(
            id: "goal-1-recoverable",
            entityID: "goal-1",
            revisionMarker: "rev-1",
            reason: .deleted,
            recordedAt: "2026-05-12T10:00:00Z"
        )
        let finalized = tombstone(
            id: "goal-1-finalized",
            entityID: "goal-1",
            revisionMarker: "rev-2",
            reason: .replaced,
            recordedAt: "2026-05-12T11:00:00Z",
            lifecycleState: .finalized,
            privacyClass: .sharedReceipt,
            ancestryLineageIDs: [recoverable.lineageID],
            sourceRecordID: "SourceRecord.goal.1",
            receiptID: "Receipt.goal.1",
            replayTraceID: "ReplayTrace.goal.1"
        )

        try await repository.append(recoverable)
        try await repository.append(finalized)

        let fetchedByLineage = try await repository.fetch(lineageID: recoverable.lineageID)
        let recoverableOnly = try await repository.fetchRecoverable(limit: 10)
        let finalizedOnly = try await repository.fetchFinalized(limit: 10)

        XCTAssertEqual(fetchedByLineage.map(\.id), ["goal-1-finalized", "goal-1-recoverable"])
        XCTAssertEqual(recoverableOnly.map(\.id), ["goal-1-recoverable"])
        XCTAssertEqual(finalizedOnly.map(\.id), ["goal-1-finalized"])
        XCTAssertEqual(recoverable.exportSafeLineageView.entityID, nil)
        XCTAssertEqual(recoverable.exportSafeLineageView.sourceRecordID, nil)
        XCTAssertTrue(recoverable.exportSafeLineageView.isRecoverable)
        XCTAssertTrue(finalized.exportSafeLineageView.isFinalized)
        XCTAssertEqual(finalized.exportSafeLineageView.receiptID, "Receipt.goal.1")
        XCTAssertEqual(finalized.exportSafeLineageView.ancestryLineageIDs, [recoverable.lineageID])
    }

    private func makeRepository() async throws -> SwiftDataEntityRevisionTombstoneRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataEntityRevisionTombstoneRepository(store: store)
    }

    private func tombstone(
        id: String,
        entityID: String,
        revisionMarker: String,
        reason: EntityRevisionTombstoneReason = .deleted,
        recordedAt: String,
        lifecycleState: EntityRevisionTombstoneLifecycleState? = nil,
        privacyClass: AmbitionPrivacyClass = .privateUserText,
        ancestryLineageIDs: [String] = [],
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil
    ) -> EntityRevisionTombstone {
        EntityRevisionTombstone(
            id: id,
            entityKind: .goal,
            entityID: entityID,
            revisionMarker: revisionMarker,
            reason: reason,
            recordedAt: recordedAt,
            ancestryLineageIDs: ancestryLineageIDs,
            lifecycleState: lifecycleState,
            privacyClass: privacyClass,
            sourceRecordID: sourceRecordID,
            receiptID: receiptID,
            replayTraceID: replayTraceID
        )
    }
}
