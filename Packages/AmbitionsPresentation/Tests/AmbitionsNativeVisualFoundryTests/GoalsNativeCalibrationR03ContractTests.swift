import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationR03ContractTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testProofMomentsHaveStableIdentityAndSubstantiateExactPathTruth() {
        XCTAssertEqual(content.proofMoments.map(\.id), [
            "proof.crib-corner-cleared",
            "proof.paint-color-confirmed",
            "proof.wall-primed"
        ])
        XCTAssertEqual(content.proofMoments.map(\.title), [
            "Crib corner cleared",
            "Paint color confirmed",
            "Wall primed"
        ])

        XCTAssertEqual(
            content.goalPath.node(id: "pathnode.clear-crib-corner")?.proofIDs,
            ["proof.crib-corner-cleared"]
        )
        XCTAssertEqual(
            content.goalPath.node(id: "pathnode.prime-wall-color")?.proofIDs,
            ["proof.paint-color-confirmed", "proof.wall-primed"]
        )
    }

    func testGoalPathUsesTheExactEightStableNodesOnce() {
        XCTAssertEqual(content.goalPath.id, "goalpath.welcome-baby-home.v1")
        XCTAssertEqual(content.goalPath.nodes.map(\.id), [
            "pathnode.define-ready",
            "pathnode.clear-crib-corner",
            "pathnode.prime-wall-color",
            "pathnode.paint-wall",
            "pathnode.assemble-crib",
            "pathnode.changing-station",
            "pathnode.final-furniture",
            "pathnode.nursery-ready"
        ])
        XCTAssertEqual(Set(content.goalPath.nodes.map(\.id)).count, 8)
        XCTAssertEqual(content.goalPath.currentNodeID, "pathnode.paint-wall")
        XCTAssertEqual(content.goalPath.nextNodeID, "pathnode.assemble-crib")
    }

    func testRelationshipIsConsequenceFirstAndKeepsBothOwnersExplicit() {
        XCTAssertEqual(
            content.relationship.id,
            "relationship.goal.welcome-baby-home.protect-first-weeks"
        )
        XCTAssertEqual(
            content.relationship.consequence,
            "A ready nursery lowers pressure during the first days at home."
        )
        XCTAssertEqual(
            content.relationship.protectedBoundary,
            "Home setup should support the family’s first-week plan rather than consume it."
        )
        XCTAssertEqual(content.relationship.primaryGoalID, "goal.welcome-baby-home")
        XCTAssertEqual(content.relationship.relatedGoalID, "goal.protect-first-weeks-together")
        XCTAssertEqual(content.relationship.ownerLifeAreaTitle, "Home")
        XCTAssertEqual(content.relationship.relatedLifeAreaTitle, "Relationships")
    }

    func testRecoveryRetainsAcceptedTruthProofAndUnchangedPath() {
        XCTAssertEqual(content.recovery.id, "recovery.goal.welcome-baby-home.paint-delay")
        XCTAssertEqual(
            content.recovery.interruptionFact,
            "The nursery paint is unavailable until Friday."
        )
        XCTAssertEqual(content.recovery.retainedAcceptedTruth, content.primaryGoal.currentAcceptedTruth)
        XCTAssertEqual(content.recovery.retainedProofIDs, content.proofMoments.map(\.id))
        XCTAssertEqual(content.recovery.interruptedPathNodeID, "pathnode.paint-wall")
        XCTAssertEqual(content.recovery.possibleNextPathNodeID, "pathnode.assemble-crib")
        XCTAssertEqual(
            content.recovery.unchangedPathStatement,
            "The current path is still intact. Nothing has changed yet."
        )
    }

    func testClosureDistinguishesOutcomeHistoryAndRemainingOpenWork() {
        XCTAssertEqual(content.closure.id, "closure.goal.welcome-baby-home.nursery-ready")
        XCTAssertEqual(content.closure.goalID, content.primaryGoal.id)
        XCTAssertEqual(content.closure.acceptedTruth, "The nursery is ready for the crib.")
        XCTAssertEqual(
            content.closure.relationshipResult,
            "The first weeks together remain protected."
        )
        XCTAssertEqual(content.closure.remainingOpenItem, "Arrange final furniture after delivery")
        XCTAssertEqual(content.closure.proofIDs, content.proofMoments.map(\.id))
        XCTAssertFalse(content.closure.history.isEmpty)
        XCTAssertTrue(content.closure.isOutcomeAchieved)
        XCTAssertTrue(content.closure.isGoalClosed)
    }

    func testR03ContentRemainsFixtureDrivenAndNonMutating() {
        XCTAssertTrue(content.isSynthetic)
        XCTAssertEqual(content.familyID, "goals-flagship/home/welcome-baby-home/v1")
        XCTAssertEqual(content.primaryGoal.id, "goal.welcome-baby-home")
        XCTAssertEqual(
            content.primaryGoal.currentAcceptedTruth,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
    }
}
