import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationR03PathTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testPathPresentationSeparatesRecordedPresentNearOpenAndClosurePostures() {
        let presentation = GoalsNativeCalibrationPathPresentation(content: content)

        XCTAssertEqual(presentation.recordedSupport.map(\.id), [
            "pathnode.define-ready",
            "pathnode.clear-crib-corner",
            "pathnode.prime-wall-color"
        ])
        XCTAssertEqual(presentation.currentSeam.id, "pathnode.paint-wall")
        XCTAssertEqual(presentation.nearMovement.id, "pathnode.assemble-crib")
        XCTAssertEqual(presentation.openFuture.map(\.id), [
            "pathnode.changing-station",
            "pathnode.final-furniture"
        ])
        XCTAssertEqual(presentation.closurePosture.id, "pathnode.nursery-ready")
        XCTAssertFalse(presentation.usesContinuousConnector)
        XCTAssertTrue(presentation.usesCompactJumpMenu)
    }

    func testSelectedNodePresentationKeepsProofScopedToExactNode() throws {
        let presentation = GoalsNativeCalibrationPathPresentation(content: content)

        let settled = try XCTUnwrap(
            presentation.selectedNode(id: "pathnode.prime-wall-color")
        )
        XCTAssertEqual(settled.proofMomentIDs, [
            "proof.paint-color-confirmed",
            "proof.wall-primed"
        ])
        XCTAssertEqual(settled.proofMomentTitles, [
            "Paint color confirmed",
            "Wall primed"
        ])

        let current = try XCTUnwrap(
            presentation.selectedNode(id: "pathnode.paint-wall")
        )
        XCTAssertTrue(current.proofMomentIDs.isEmpty)
        XCTAssertTrue(current.proofMomentTitles.isEmpty)
    }

    func testPathEvidencePresentationPreservesGoalPathNodeAndProofIdentity() throws {
        let evidence = try XCTUnwrap(
            GoalsNativeCalibrationPathEvidencePresentation(
                content: content,
                nodeID: "pathnode.clear-crib-corner"
            )
        )

        XCTAssertEqual(evidence.goalID, "goal.welcome-baby-home")
        XCTAssertEqual(evidence.pathID, "goalpath.welcome-baby-home.v1")
        XCTAssertEqual(evidence.nodeID, "pathnode.clear-crib-corner")
        XCTAssertEqual(evidence.nodeTitle, "Clear the crib corner")
        XCTAssertEqual(evidence.proofMoments.map(\.id), ["proof.crib-corner-cleared"])
        XCTAssertEqual(evidence.proofMoments.map(\.title), ["Crib corner cleared"])
        XCTAssertTrue(evidence.isInspectionOnly)
    }

    func testAccessibilityEquivalentRetainsEveryOrderedIdentityAndJumpAction() {
        let presentation = GoalsNativeCalibrationPathPresentation(content: content)

        XCTAssertEqual(presentation.semanticNodeOrder, content.goalPath.nodes.map(\.id))
        XCTAssertEqual(presentation.jumpTitles, ["Start", "Now", "Next", "Finish"])
        XCTAssertEqual(presentation.accessibilityCurrentNodeID, content.goalPath.currentNodeID)
        XCTAssertEqual(presentation.accessibilityNextNodeID, content.goalPath.nextNodeID)
    }
}
