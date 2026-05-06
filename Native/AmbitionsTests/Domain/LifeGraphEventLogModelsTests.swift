import XCTest
@testable import Ambitions

final class LifeGraphEventLogModelsTests: XCTestCase {
    func testNodeCarriesAOS02RequiredStateFields() {
        let node = HumanProgressGraphNode(
            id: " requirement-1 ",
            family: .requirement,
            title: "Scholarship deadline",
            privacyClass: .sensitive,
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsSourceReview,
            createdAt: "2026-05-06T14:45:00Z",
            receiptIDs: ["receipt-2", "receipt-1", "receipt-1"],
            sourceReferenceIDs: ["source-1"]
        )

        XCTAssertEqual(node.id, "requirement-1")
        XCTAssertEqual(node.schemaVersion, humanProgressGraphSchemaVersion)
        XCTAssertEqual(node.privacyClass, .sensitive)
        XCTAssertEqual(node.sourceState, .sourceNeeded)
        XCTAssertEqual(node.freshnessState, .staleCritical)
        XCTAssertEqual(node.reviewState, .needsSourceReview)
        XCTAssertEqual(node.receiptIDs, ["receipt-1", "receipt-2"])
        XCTAssertFalse(node.canDriveSourceSensitiveRecommendation)
    }

    func testEdgeRejectsSelfRelationshipAndBlocksAutomaticMutationWithoutSourceProof() {
        let selfEdge = HumanProgressGraphEdge(
            family: .dependsOn,
            sourceNodeID: "goal-1",
            targetNodeID: "goal-1",
            createdAt: "2026-05-06T14:45:00Z"
        )
        let sourceNeeded = HumanProgressGraphEdge(
            family: .dependsOn,
            sourceNodeID: "goal-1",
            targetNodeID: "requirement-1",
            sourceState: .sourceNeeded,
            freshnessState: .unknown,
            reviewState: .needsSourceReview,
            createdAt: "2026-05-06T14:45:00Z"
        )

        XCTAssertFalse(selfEdge.isWellFormed)
        XCTAssertTrue(sourceNeeded.isWellFormed)
        XCTAssertTrue(sourceNeeded.blocksAutomaticMutation)
        XCTAssertEqual(sourceNeeded.id, "hpg:goal-1:depends_on:requirement-1")
    }

    func testKernelProposalEventStaysLocalOnlyAndReviewGated() {
        let event = LifeGraphEventLogEntry(
            id: "event-1",
            kind: .graphDeltaProposed,
            occurredAt: "2026-05-06T14:45:00Z",
            actor: .kernelProposal,
            scope: .goals,
            affectedNodeIDs: ["node-b", "node-a", "node-a"],
            privacyClass: .privateLife,
            sourceState: .userStated,
            freshnessState: .notApplicable,
            reviewState: .needsUserReview,
            summary: "Propose a path requirement link."
        )

        XCTAssertEqual(event.schemaVersion, lifeGraphEventLogSchemaVersion)
        XCTAssertTrue(event.localOnly)
        XCTAssertEqual(event.affectedNodeIDs, ["node-a", "node-b"])
        XCTAssertTrue(event.requiresReviewBeforeMutation)
        XCTAssertTrue(event.isProposalOnly)
    }

    func testDeltaDeduplicatesAndRequiresReviewBeforeMutation() {
        let node = HumanProgressGraphNode(
            id: "goal-path-1",
            family: .goalPath,
            title: "Nursing school path",
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            createdAt: "2026-05-06T14:45:00Z"
        )
        let edge = HumanProgressGraphEdge(
            family: .supports,
            sourceNodeID: "goal-path-1",
            targetNodeID: "commitment-1",
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            createdAt: "2026-05-06T14:45:00Z"
        )
        let event = LifeGraphEventLogEntry(
            id: "event-1",
            kind: .graphDeltaProposed,
            occurredAt: "2026-05-06T14:45:00Z",
            actor: .kernelProposal,
            scope: .goals,
            affectedNodeIDs: [node.id],
            affectedEdgeIDs: [edge.id],
            sourceState: .userConfirmed,
            freshnessState: .current,
            reviewState: .ready,
            summary: "Propose support edge."
        )

        let delta = HumanProgressGraphDelta(
            id: "delta-1",
            proposedAt: "2026-05-06T14:45:00Z",
            nodesToUpsert: [node, node],
            edgesToUpsert: [edge, edge],
            event: event,
            rollbackHint: "Reject the proposed delta before it is applied."
        )

        XCTAssertTrue(delta.isWellFormed)
        XCTAssertEqual(delta.nodesToUpsert.map(\.id), ["goal-path-1"])
        XCTAssertEqual(delta.edgesToUpsert.map(\.id), [edge.id])
        XCTAssertTrue(delta.requiresReviewBeforeMutation)
    }
}
