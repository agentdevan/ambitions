import XCTest
@testable import Ambitions

final class CapabilityStateStoreTests: XCTestCase {
    func testRevisionCASIdempotencyBackupAndReplay() async throws {
        let store = CapabilityStateStore()
        let record = Self.record(id: "capability-writing")

        let first = try await store.append(.create(record), expectedRevision: 0, idempotencyKey: "create-writing")
        let duplicate = try await store.append(.create(record), expectedRevision: 0, idempotencyKey: "create-writing")

        XCTAssertEqual(first.revision, 1)
        XCTAssertTrue(duplicate.wasDuplicate)
        XCTAssertEqual(duplicate.revision, first.revision)
        await XCTAssertThrowsErrorAsync {
            try await store.append(.archive(capabilityID: record.id), expectedRevision: 0, idempotencyKey: "stale")
        }

        let backup = await store.backup()
        XCTAssertEqual(backup.snapshot.records, [record])
        let replayed = try await store.replay()
        let current = await store.currentSnapshot()
        XCTAssertEqual(replayed, current)
    }

    func testArchiveTrashRestoreRedactionAndPermanentDeletionRemainExplicit() async throws {
        let store = CapabilityStateStore()
        let record = Self.record(id: "capability-gardening")
        let relationship = CapabilityEvidenceRelationship(
            id: "evidence-gardening",
            capabilityID: record.id,
            source: CapabilityEvidenceSourceReference(kind: .goal, stableID: "goal-garden", revision: 1, fingerprint: "fingerprint"),
            relationKind: .practiced,
            userApprovedContext: "Observed during a local goal."
        )

        _ = try await store.append(.create(record), expectedRevision: 0, idempotencyKey: "create")
        _ = try await store.append(.attachEvidence(relationship), expectedRevision: 1, idempotencyKey: "attach")
        _ = try await store.append(.redactEvidence(relationshipID: relationship.id), expectedRevision: 2, idempotencyKey: "redact")
        _ = try await store.append(.trash(capabilityID: record.id), expectedRevision: 3, idempotencyKey: "trash")

        let trashed = await store.currentSnapshot()
        XCTAssertEqual(trashed.records.first?.lifecycle, .trashed)
        XCTAssertEqual(trashed.evidenceRelationships.first?.availability, .redacted)
        XCTAssertNil(trashed.evidenceRelationships.first?.userApprovedContext)

        _ = try await store.append(
            .permanentlyDelete(CapabilityDeletionTombstone(capabilityID: record.id, deletedAt: "2026-08-06T00:00:00Z", revision: 5)),
            expectedRevision: 4,
            idempotencyKey: "delete"
        )
        let deleted = await store.currentSnapshot()
        XCTAssertTrue(deleted.records.isEmpty)
        XCTAssertTrue(deleted.evidenceRelationships.isEmpty)
        XCTAssertEqual(deleted.deletionTombstones.map(\.capabilityID), [record.id])
        let replayed = try await store.replay()
        XCTAssertEqual(replayed, deleted)
    }

    private static func record(id: String) -> CapabilityRecord {
        CapabilityRecord(
            id: CapabilityID(id),
            createdAt: "2026-08-06T00:00:00Z",
            updatedAt: "2026-08-06T00:00:00Z",
            name: "Writing",
            meaning: "Explain an idea clearly.",
            creationKind: .manual
        )
    }
}

private func XCTAssertThrowsErrorAsync(
    _ expression: @escaping () async throws -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail("Expected an error", file: file, line: line)
    } catch {
        // Expected.
    }
}
