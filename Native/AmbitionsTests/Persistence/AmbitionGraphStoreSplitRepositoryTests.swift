import Foundation
import SwiftData
import XCTest
@testable import Ambitions

final class AmbitionGraphStoreSplitRepositoryTests: XCTestCase {
    func testProjectionRepositoryReadsQueryableColumnsWhenSnapshotBlobIsCorrupt() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataAmbitionGraphProjectionRecordRepository(store: store)
        let snapshot = makeSnapshot()
        let projectionStore = AmbitionGraphProjectionStore(snapshots: [snapshot])
        let record = projectionStore.projectionRecord(
            for: .you,
            from: snapshot,
            generatedAt: "2026-05-12T08:00:00Z",
            id: "you-projection",
            receiptIDs: ["receipt-2", "receipt-1"],
            replayTraceIDs: ["trace-2", "trace-1"]
        )

        try await repository.save([record])

        try await store.write { context in
            guard let persisted = try context.fetch(FetchDescriptor<AmbitionGraphProjectionRecordModel>()).first else {
                return
            }
            persisted.snapshotData = Data([0x00, 0x13, 0x37])
        }

        let fetched = try await repository.fetchRecords(
            surface: .you,
            snapshotID: snapshot.id,
            limit: 10
        )

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, record.id)
        XCTAssertEqual(fetched.first?.surface, .you)
        XCTAssertEqual(fetched.first?.sourceSnapshotID, snapshot.id)
        XCTAssertEqual(fetched.first?.receiptIDs, ["receipt-1", "receipt-2"])
        XCTAssertEqual(fetched.first?.replayTraceIDs, ["trace-1", "trace-2"])
        XCTAssertEqual(fetched.first?.invalidationReason, .initialMaterialization)
        XCTAssertTrue(fetched.first?.checksum.hasPrefix("sha256:") == true)
    }

    func testProofRepositoryAppendsVersionedRecordsWithoutOverwritingOriginalProof() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataAmbitionGraphProofRecordRepository(store: store)
        let snapshot = makeSnapshot()
        let projectionStore = AmbitionGraphProjectionStore(snapshots: [snapshot])
        guard let proof = snapshot.proofs.first else {
            return XCTFail("Expected a proof in the sample snapshot")
        }

        let first = projectionStore.proofRecord(
            for: proof,
            sourceSnapshotID: snapshot.id,
            generatedAt: "2026-05-12T08:00:00Z",
            version: 1,
            localProjectionOnly: true,
            receiptIDs: ["receipt-proof"],
            replayTraceIDs: ["trace-proof"]
        )
        let second = first.versioned(nextVersion: 2, supersedesProofID: first.id)

        try await repository.append(first)
        try await repository.append(second)

        let fetched = try await repository.fetchRecords(proofID: proof.id, limit: 10)

        XCTAssertEqual(fetched.map(\.id), ["\(proof.id).v2", "\(proof.id).v1"])
        XCTAssertEqual(fetched.map(\.version), [2, 1])
        XCTAssertEqual(fetched.first?.supersedesProofID, first.id)
        XCTAssertNil(fetched.last?.supersedesProofID)
        XCTAssertNotEqual(fetched.first?.checksum, fetched.last?.checksum)
    }

    private func makeSnapshot() -> AmbitionGraphSnapshot {
        let ambition = Ambition(
            id: "ambition-graph-split",
            title: "Maintain a durable local graph",
            identityStatement: "Keep the graph inspectable.",
            privacyClass: .privateUserText,
            createdAt: "2026-05-12T07:00:00Z",
            updatedAt: "2026-05-12T07:00:00Z"
        )

        let proof = Proof(
            id: "proof-graph-split",
            ambitionID: ambition.id,
            commitmentID: "commitment-graph-split",
            proofType: .text,
            text: "Inspectability is preserved locally.",
            source: "graph split test",
            privacyClass: .privateProof,
            userConfirmed: true,
            createdAt: "2026-05-12T07:10:00Z"
        )

        return AmbitionGraphSnapshot(
            id: "snapshot-graph-split",
            ambition: ambition,
            proofs: [proof]
        )
    }
}
