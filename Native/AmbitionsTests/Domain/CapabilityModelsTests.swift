import XCTest
@testable import Ambitions

final class CapabilityModelsTests: XCTestCase {
    func testManualCapabilityHasStableIdentityAndIndependentClaimCeilings() throws {
        let record = CapabilityRecord(
            id: CapabilityID(" capability-writing "),
            createdAt: "2026-08-05T00:00:00Z",
            updatedAt: "2026-08-05T00:00:00Z",
            name: "Writing",
            meaning: "A useful method for explaining an idea clearly.",
            creationKind: .manual,
            evidenceRelationshipIDs: ["evidence-2", "evidence-1", "evidence-1"]
        )

        XCTAssertEqual(record.id.rawValue, "capability-writing")
        XCTAssertTrue(record.isWellFormed)
        XCTAssertEqual(record.evidenceRelationshipIDs, ["evidence-1", "evidence-2"])
        XCTAssertEqual(record.provenanceFacets(from: []), [.userStated])
        XCTAssertTrue(record.claimCeilings.contains(.noScore))
        XCTAssertTrue(record.claimCeilings.contains(.noCredentialAcceptance))
        XCTAssertFalse(record.canInfluenceFuturePlanning)

        let data = try JSONEncoder().encode(record)
        XCTAssertEqual(try JSONDecoder().decode(CapabilityRecord.self, from: data), record)
    }

    func testProvenanceFacetsCoexistWithoutTreatingProofAsTheCapability() {
        let id = CapabilityID("capability-gardening")
        let practiced = CapabilityEvidenceRelationship(
            id: "relationship-practiced",
            capabilityID: id,
            source: CapabilityEvidenceSourceReference(kind: .goal, stableID: "goal-garden", revision: 2, fingerprint: "goal-fingerprint"),
            relationKind: .practiced
        )
        let proof = CapabilityEvidenceRelationship(
            id: "relationship-proof",
            capabilityID: id,
            source: CapabilityEvidenceSourceReference(kind: .proof, stableID: "proof-garden", revision: 1, fingerprint: "proof-fingerprint"),
            relationKind: .proofLinked
        )
        let record = CapabilityRecord(
            id: id,
            createdAt: "2026-08-05T00:00:00Z",
            updatedAt: "2026-08-05T00:00:00Z",
            name: "Gardening",
            meaning: "Growing and caring for plants.",
            creationKind: .confirmedProposal
        )

        XCTAssertTrue(practiced.isWellFormed)
        XCTAssertTrue(proof.isWellFormed)
        XCTAssertEqual(record.provenanceFacets(from: [practiced, proof]), [.practiced, .proofLinked])
    }

    func testEvidenceEdgeRejectsProofLinkedRelationWithoutProofIdentity() {
        let relationship = CapabilityEvidenceRelationship(
            id: "relationship-invalid",
            capabilityID: CapabilityID("capability-cooking"),
            source: CapabilityEvidenceSourceReference(kind: .step, stableID: "step-cook", revision: 1, fingerprint: "step-fingerprint"),
            relationKind: .proofLinked,
            availability: .trashed,
            contradictionState: .needsReview
        )

        XCTAssertFalse(relationship.isWellFormed)
        XCTAssertFalse(relationship.availability.supportsNewProposal)
        XCTAssertEqual(relationship.provenanceFacet, .proofLinked)
    }

    func testProtectedCapabilityCannotEnableFutureUseAndTombstoneIsContentFree() {
        let id = CapabilityID("capability-private")
        let record = CapabilityRecord(
            id: id,
            createdAt: "2026-08-05T00:00:00Z",
            updatedAt: "2026-08-05T00:00:00Z",
            name: "Private capability",
            meaning: "A user-entered meaning.",
            privacyClassification: .protectedLocal,
            futureUseState: .eligible,
            creationKind: .manual
        )
        let tombstone = CapabilityDeletionTombstone(capabilityID: id, deletedAt: "2026-08-05T01:00:00Z", revision: 4)

        XCTAssertEqual(record.futureUseState, .lockedForProtectedContent)
        XCTAssertFalse(record.canInfluenceFuturePlanning)
        XCTAssertEqual(tombstone.capabilityID, id)
        XCTAssertFalse(Mirror(reflecting: tombstone).children.contains { $0.label == "name" || $0.label == "meaning" })
    }
}
