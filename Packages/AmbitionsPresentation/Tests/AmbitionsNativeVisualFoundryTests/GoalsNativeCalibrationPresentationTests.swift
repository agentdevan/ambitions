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
}
