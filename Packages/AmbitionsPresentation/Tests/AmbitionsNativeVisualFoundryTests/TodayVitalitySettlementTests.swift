import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalitySettlementTests: XCTestCase {
    private let content = TodayFlagshipCalibrationFixture.preparingForBaby

    func testSettlementAccessibilityIdentityRetainsStableStep() {
        XCTAssertEqual(
            content.settlementAccessibilityIdentity,
            "Progress recorded. Make the nursery ready for the crib"
        )
    }

    func testSettlementAndExplicitReturnPreserveExactTruthAndContinuityFocus() {
        var state = TodayFlagshipJourneyState.preview(content: content, phase: .settled)

        XCTAssertEqual(
            state.acceptedTruth,
            "I primed the wall and tested the new color."
        )
        XCTAssertEqual(state.focusAnchor, .settledTruth)
        XCTAssertEqual(state.navigationPath, [.step(id: content.primaryStep.id)])

        XCTAssertTrue(state.returnToToday())
        XCTAssertEqual(state.phase, .todayReturned)
        XCTAssertEqual(state.focusAnchor, .returnedSettledStep)
        XCTAssertEqual(
            state.visibleStartHereStepID,
            content.revealedStartHereStep.id
        )
        XCTAssertTrue(state.settledStepRemainsVisible)
    }

    func testHistoryDisclosureDoesNotMutateSettledTruth() {
        var state = TodayFlagshipJourneyState.preview(content: content, phase: .settled)
        let settledTruth = state.acceptedTruth

        XCTAssertTrue(state.openHistory())
        XCTAssertEqual(state.acceptedTruth, settledTruth)
        XCTAssertEqual(state.phase, .settled)

        XCTAssertTrue(state.closeHistory())
        XCTAssertEqual(state.acceptedTruth, settledTruth)
        XCTAssertEqual(state.phase, .settled)
    }
}
