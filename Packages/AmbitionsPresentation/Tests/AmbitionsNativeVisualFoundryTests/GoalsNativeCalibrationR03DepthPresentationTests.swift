import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationR03DepthPresentationTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testRelationshipPresentsConsequenceBeforeProtectedBoundaryAndMetadata() {
        let presentation = GoalsNativeCalibrationRelationshipPresentation(content: content)

        XCTAssertEqual(presentation.relationshipID, "relationship.goal.welcome-baby-home.protect-first-weeks")
        XCTAssertEqual(
            presentation.consequence,
            "A ready nursery lowers pressure during the first days at home."
        )
        XCTAssertEqual(
            presentation.protectedBoundary,
            "Home setup should support the family’s first-week plan rather than consume it."
        )
        XCTAssertEqual(
            presentation.accessibilityReadingOrder,
            [
                "Welcome our baby home",
                "A ready nursery lowers pressure during the first days at home.",
                "Home setup should support the family’s first-week plan rather than consume it.",
                "Protect our first weeks together",
                "Home and Relationships"
            ]
        )
        XCTAssertTrue(presentation.isInspectionOnly)
    }

    func testRecoveryRetainsTruthProofAndCurrentPathWithoutMutationAction() {
        let presentation = GoalsNativeCalibrationRecoveryPresentation(content: content)

        XCTAssertEqual(presentation.recoveryID, "recovery.goal.welcome-baby-home.paint-delay")
        XCTAssertEqual(presentation.goalID, "goal.welcome-baby-home")
        XCTAssertEqual(presentation.goalTitle, "Welcome our baby home")
        XCTAssertEqual(presentation.lifeAreaTitle, "Home")
        XCTAssertEqual(presentation.retainedAcceptedTruth, content.primaryGoal.currentAcceptedTruth)
        XCTAssertEqual(
            presentation.proofMoments,
            ["Crib corner cleared", "Paint color confirmed", "Wall primed"]
        )
        XCTAssertEqual(presentation.interruptedMovement, "Paint the nursery wall")
        XCTAssertEqual(presentation.possibleNext, "Assemble the crib")
        XCTAssertEqual(
            presentation.actions,
            ["Review current Path", "Inspect possible next", "Keep unresolved"]
        )
        XCTAssertFalse(presentation.actions.contains("Apply"))
        XCTAssertFalse(presentation.actions.contains("Update Path"))
        XCTAssertTrue(presentation.isInspectionOnly)
    }

    func testClosureDistinguishesOutcomeClosureOpenWorkAndHistory() {
        let presentation = GoalsNativeCalibrationClosurePresentation(content: content)

        XCTAssertEqual(presentation.closureID, "closure.goal.welcome-baby-home.nursery-ready")
        XCTAssertEqual(presentation.goalID, "goal.welcome-baby-home")
        XCTAssertEqual(presentation.goalTitle, "Welcome our baby home")
        XCTAssertEqual(presentation.lifeAreaTitle, "Home")
        XCTAssertEqual(presentation.finalAcceptedTruth, "The nursery is ready for the crib.")
        XCTAssertEqual(
            presentation.proofMoments,
            ["Crib corner cleared", "Paint color confirmed", "Wall primed"]
        )
        XCTAssertEqual(
            presentation.relationshipResult,
            "The first weeks together remain protected."
        )
        XCTAssertEqual(
            presentation.remainingOpenItem,
            "Arrange final furniture after delivery"
        )
        XCTAssertTrue(presentation.isOutcomeAchieved)
        XCTAssertTrue(presentation.isGoalClosed)
        XCTAssertEqual(presentation.historyEntryCount, 2)
        XCTAssertTrue(presentation.isInspectionOnly)
    }

    func testClosureHistoryRetainsExactFixtureEvidence() {
        let presentation = GoalsNativeCalibrationClosureHistoryPresentation(content: content)

        XCTAssertEqual(presentation.closureID, content.closure.id)
        XCTAssertEqual(presentation.goalID, content.primaryGoal.id)
        XCTAssertEqual(
            presentation.entries.map(\.id),
            [
                "history.goal.welcome-baby-home.nursery-ready",
                "history.goal.welcome-baby-home.protected-first-weeks"
            ]
        )
        XCTAssertEqual(
            presentation.accessibilityReadingOrder,
            [
                "Welcome our baby home",
                "Nursery outcome accepted. The nursery is ready for the crib.",
                "Protected relationship retained. The first weeks together remain protected."
            ]
        )
    }
}
