import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationPresentationTests: XCTestCase {
    func testRootPresentationKeepsShellOwnershipAndOneAttachedLens() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        var state = GoalsNativeCalibrationJourneyState(content: content)
        XCTAssertTrue(state.openLinkedLens())

        let presentation = GoalsNativeCalibrationPresentation(
            content: content,
            state: state
        )

        XCTAssertEqual(presentation.accessibilityScreenHeading, "Goals")
        XCTAssertEqual(presentation.selectedRootTitle, "Goals")
        XCTAssertEqual(presentation.rootOrder, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(presentation.globalActions, ["Search", "Capture"])
        XCTAssertEqual(presentation.expandedLifeAreaIDs, ["life-area.home"])
        XCTAssertEqual(presentation.selectedGoalIDs, ["goal.welcome-baby-home"])
        XCTAssertEqual(presentation.attachedLensGoalIDs, ["goal.welcome-baby-home"])
        XCTAssertEqual(presentation.primaryActionTitle, "Open Goal")
    }

    func testCollapsedRootDoesNotPretendTheLensIsVisible() {
        let content = GoalsNativeCalibrationFixture.preparingForBaby
        let state = GoalsNativeCalibrationJourneyState(content: content)

        let presentation = GoalsNativeCalibrationPresentation(
            content: content,
            state: state
        )

        XCTAssertTrue(presentation.attachedLensGoalIDs.isEmpty)
        XCTAssertEqual(presentation.primaryActionTitle, "Show Linked Goal Lens")
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
