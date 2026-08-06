import XCTest
@testable import Ambitions

final class CapabilityCommandServiceTests: XCTestCase {
    func testCreateConfirmEvidenceLifecycleAndReplaySettleAtomically() async throws {
        let store = CapabilityStateStore()
        let service = CapabilityCommandService(store: store)
        let manual = Self.record("swift", creationKind: .manual)

        let create = try await service.execute(Self.command("create", revision: 0, operation: .create(manual)))
        let duplicate = try await service.execute(Self.command("create", revision: 0, operation: .create(manual)))
        XCTAssertFalse(create.receipt.wasDuplicate)
        XCTAssertTrue(duplicate.receipt.wasDuplicate)
        XCTAssertEqual(create.event, duplicate.event)

        let evidence = Self.relationship(capabilityID: manual.id)
        _ = try await service.execute(Self.command("attach", revision: 1, operation: .attachEvidence(evidence)))
        _ = try await service.execute(Self.command("permission", revision: 2, operation: .setFutureUse(capabilityID: manual.id, state: .eligible)))
        _ = try await service.execute(Self.command("archive", revision: 3, operation: .archive(capabilityID: manual.id)))
        _ = try await service.execute(Self.command("trash", revision: 4, operation: .trash(capabilityID: manual.id)))
        _ = try await service.execute(Self.command("restore", revision: 5, operation: .restore(capabilityID: manual.id)))
        _ = try await service.execute(Self.command("detach", revision: 6, operation: .detachEvidence(relationshipID: evidence.id)))

        let snapshot = await store.currentSnapshot()
        let replay = try await store.replay()
        XCTAssertEqual(snapshot, replay)
        XCTAssertEqual(snapshot.records.first?.futureUseState, .eligible)
        XCTAssertEqual(snapshot.records.first?.lifecycle, .active)
        XCTAssertTrue(snapshot.evidenceRelationships.isEmpty)
    }

    func testConfirmationRequiresConfirmedProposalRecordAndDeleteRequiresTrash() async throws {
        let store = CapabilityStateStore()
        let service = CapabilityCommandService(store: store)
        let invalid = Self.record("bad", creationKind: .manual)
        do {
            _ = try await service.execute(Self.command("invalid-confirm", revision: 0, operation: .confirm(proposalID: "proposal", record: invalid)))
            XCTFail("Expected invalid confirmation")
        } catch let error as CapabilityCommandServiceError {
            XCTAssertEqual(error, .invalidConfirmation)
        }

        let confirmed = Self.record("good", creationKind: .confirmedProposal)
        _ = try await service.execute(Self.command("confirm", revision: 0, operation: .confirm(proposalID: "proposal", record: confirmed)))
        _ = try await service.execute(Self.command("trash", revision: 1, operation: .trash(capabilityID: confirmed.id)))
        let tombstone = CapabilityDeletionTombstone(
            capabilityID: confirmed.id,
            deletedAt: "2026-08-06T00:00:00Z",
            revision: 1
        )
        _ = try await service.execute(
            Self.command("delete", revision: 2, operation: .permanentlyDelete(tombstone))
        )
        let snapshot = await store.currentSnapshot()
        XCTAssertTrue(snapshot.records.isEmpty)
    }

    private static func command(_ key: String, revision: Int, operation: CapabilityCommandOperation) -> CapabilityCommand {
        CapabilityCommand(id: "command-\(key)", expectedRevision: revision, idempotencyKey: "capability-\(key)", occurredAt: "2026-08-06T00:00:00Z", operation: operation)
    }

    private static func record(_ id: String, creationKind: CapabilityCreationKind) -> CapabilityRecord {
        CapabilityRecord(id: CapabilityID(id), createdAt: "2026-08-06T00:00:00Z", updatedAt: "2026-08-06T00:00:00Z", name: id, meaning: "Can use \(id)", creationKind: creationKind)
    }

    private static func relationship(capabilityID: CapabilityID) -> CapabilityEvidenceRelationship {
        CapabilityEvidenceRelationship(
            id: "evidence-\(capabilityID.rawValue)", capabilityID: capabilityID,
            source: CapabilityEvidenceSourceReference(
                kind: .proof, stableID: "proof-1", revision: 1, fingerprint: "proof-a"
            ),
            relationKind: .proofLinked
        )
    }
}
