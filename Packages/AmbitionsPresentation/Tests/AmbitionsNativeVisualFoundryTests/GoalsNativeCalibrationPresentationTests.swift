import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationPresentationTests: XCTestCase {
    func testRootPresentationContainsOnlyLifeAreaIdentityAndShellOwnership() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        let presentation = GoalsNativeCalibrationRootPresentation(content: content)

        XCTAssertEqual(presentation.accessibilityScreenHeading, "Goals")
        XCTAssertEqual(presentation.selectedRootTitle, "Goals")
        XCTAssertEqual(presentation.rootOrder, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(presentation.globalActions, ["Search", "Capture"])
        XCTAssertEqual(
            presentation.lifeAreaIDs,
            ["life-area.home", "life-area.relationships", "life-area.career"]
        )
        XCTAssertFalse(presentation.visibleText.contains(content.primaryGoal.title))
        XCTAssertFalse(presentation.visibleText.contains(content.primaryGoal.nextMeaningfulMovement))
    }

    func testHomePresentationContainsEachHomeGoalExactlyOnce() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        let presentation = GoalsNativeCalibrationHomePresentation(content: content)

        XCTAssertEqual(presentation.lifeAreaID, "life-area.home")
        XCTAssertEqual(presentation.lifeAreaTitle, "Home")
        XCTAssertEqual(
            presentation.goalIDs,
            [
                "goal.welcome-baby-home",
                "goal.make-home-easier-to-run",
                "goal.finish-essential-move-in-work"
            ]
        )
        XCTAssertEqual(
            presentation.goalIDs.filter { $0 == "goal.welcome-baby-home" }.count,
            1
        )
        XCTAssertEqual(presentation.supportedFocusedGoalIDs, ["goal.welcome-baby-home"])
    }

    func testFocusedGoalPresentationPreservesPursuitContinuity() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        let presentation = GoalsNativeCalibrationFocusedGoalPresentation(content: content)

        XCTAssertEqual(presentation.goalID, "goal.welcome-baby-home")
        XCTAssertEqual(presentation.goalTitle, "Welcome our baby home")
        XCTAssertEqual(presentation.lifeAreaID, "life-area.home")
        XCTAssertEqual(presentation.lifeAreaTitle, "Home")
        XCTAssertEqual(
            presentation.currentDirection,
            "Make the home ready for the baby without consuming the time and energy the family needs now."
        )
        XCTAssertEqual(
            presentation.currentTruth,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
        XCTAssertEqual(presentation.activeThread, "Finish the nursery.")
        XCTAssertEqual(presentation.nextMovement, "Paint the nursery wall.")
        XCTAssertEqual(
            presentation.proofMoments,
            ["Crib corner cleared", "Paint color confirmed", "Wall primed"]
        )
        XCTAssertEqual(
            presentation.scheduleFit,
            "The next movement currently fits before protected family time."
        )
        XCTAssertEqual(presentation.pathActionTitle, "View Goal Path")
        XCTAssertEqual(presentation.proofDisclosureTitle, "3 recorded moments")
        XCTAssertEqual(
            presentation.futurePostures.map(\.certainty),
            [.possible, .conditional]
        )
        XCTAssertEqual(
            presentation.futurePostures.map(\.title),
            ["Assemble the crib.", "Arrange final furniture after delivery"]
        )
        XCTAssertEqual(
            presentation.protectedRelationshipTitle,
            "Protect our first weeks together"
        )
    }

    func testRelationshipPresentationKeepsBothOwnersAndExactConsequence() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        let presentation = GoalsNativeCalibrationRelationshipPresentation(content: content)

        XCTAssertEqual(presentation.primaryGoalID, "goal.welcome-baby-home")
        XCTAssertEqual(presentation.primaryGoalTitle, "Welcome our baby home")
        XCTAssertEqual(presentation.primaryLifeAreaTitle, "Home")
        XCTAssertEqual(presentation.relatedGoalID, "goal.protect-first-weeks-together")
        XCTAssertEqual(presentation.relatedGoalTitle, "Protect our first weeks together")
        XCTAssertEqual(presentation.relatedLifeAreaTitle, "Relationships")
        XCTAssertEqual(
            presentation.meaning,
            "A ready nursery lowers pressure during the first days at home."
        )
        XCTAssertEqual(
            presentation.practicalConsequence,
            "Home setup should support the family’s first-week plan rather than consume it."
        )
        XCTAssertEqual(presentation.ownershipStatement, "Home owns this setup decision.")
    }
}
