import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TimeNativeCalibrationJourneyStateTests: XCTestCase {
    private let fixture = TimeNativeCalibrationFixture.flagship

    func testWeekFocusDetailAndDismissRestoreExactObjectWithoutMutation() {
        var state = TimeNativeCalibrationJourneyState(fixture: fixture)

        XCTAssertTrue(state.openFocusedDay())
        XCTAssertEqual(state.currentRoute, .focusedDay(.wednesday))
        XCTAssertTrue(state.presentObject(id: "placement.send-launch-brief.wed-1400"))
        XCTAssertTrue(state.dismissObjectDetail())
        XCTAssertEqual(
            state.focusAnchor,
            .temporalObject("placement.send-launch-brief.wed-1400")
        )
        XCTAssertEqual(state.currentRoute, .focusedDay(.wednesday))
        XCTAssertFalse(state.hasMutation)
    }

    func testKeepCurrentReturnsToOriginatingDayAndProposalFocus() {
        var state = TimeNativeCalibrationJourneyState(fixture: fixture)
        XCTAssertTrue(state.openFocusedDay())
        XCTAssertTrue(
            state.openConflictReview(proposalID: "proposal.launch-review.wed-1745")
        )

        XCTAssertTrue(state.keepCurrent())
        XCTAssertEqual(state.currentRoute, .focusedDay(.wednesday))
        XCTAssertEqual(
            state.focusAnchor,
            .conflictProposal("proposal.launch-review.wed-1745")
        )
        XCTAssertFalse(state.hasMutation)
    }

    func testNativeBackPathRestoresProposalFocus() {
        var state = TimeNativeCalibrationJourneyState(fixture: fixture)
        XCTAssertTrue(
            state.openConflictReview(proposalID: "proposal.launch-review.wed-1745")
        )
        state.restoreNavigationPath([])

        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.selectedDayID, .wednesday)
        XCTAssertEqual(
            state.focusAnchor,
            .conflictProposal("proposal.launch-review.wed-1745")
        )
    }

    func testInvalidOrNonConflictingObjectCannotOpenConflictReview() {
        var state = TimeNativeCalibrationJourneyState(fixture: fixture)

        XCTAssertFalse(
            state.openConflictReview(proposalID: "placement.send-launch-brief.wed-1400")
        )
        XCTAssertFalse(state.openConflictReview(proposalID: "missing"))
        XCTAssertTrue(state.navigationPath.isEmpty)
    }

    func testDaySelectionRemainsRootLocal() {
        var state = TimeNativeCalibrationJourneyState(fixture: fixture)

        XCTAssertTrue(state.selectDay(.thursday))
        XCTAssertEqual(state.selectedDayID, .thursday)
        XCTAssertEqual(state.focusAnchor, .day(.thursday))
        XCTAssertTrue(state.navigationPath.isEmpty)

        XCTAssertTrue(state.openFocusedDay())
        XCTAssertFalse(state.selectDay(.wednesday))
        XCTAssertEqual(state.selectedDayID, .thursday)
    }
}
