import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalitySupportingDepthTests: XCTestCase {
    private let content = TodayFlagshipCalibrationFixture.preparingForBaby

    func testGoalDetailRoundTripIsNonMutatingAndRestoresFocusedIdentity() {
        var state = TodayFlagshipJourneyState.preview(content: content, phase: .focusedCurrent)
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.openSupportingRoute(.goalDetail))
        XCTAssertEqual(state.focusAnchor, .goalDetail)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)

        XCTAssertTrue(state.closeSupportingRoute())
        XCTAssertEqual(state.focusAnchor, .focusedIdentity)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
    }

    func testConsequenceDetailsRoundTripPreservesProposalAndReview() {
        var state = TodayFlagshipJourneyState.preview(content: content, phase: .reviewingProposal)
        let acceptedTruth = state.acceptedTruth
        let proposedTruth = state.proposedTruth

        XCTAssertTrue(state.openSupportingRoute(.consequenceDetails))
        XCTAssertEqual(state.focusAnchor, .consequenceDetails)
        XCTAssertFalse(state.beginCommit())

        XCTAssertTrue(state.closeSupportingRoute())
        XCTAssertEqual(state.phase, .reviewingProposal)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)
        XCTAssertEqual(state.proposedTruth, proposedTruth)
        XCTAssertEqual(state.focusAnchor, .reviewCurrentTruth)
    }

    func testHistoryEntryAndFiltersAreLocalNonMutatingInspection() {
        var state = TodayFlagshipJourneyState.preview(content: content, phase: .settled)
        let acceptedTruth = state.acceptedTruth

        XCTAssertTrue(state.openSupportingRoute(.historyEntry))
        XCTAssertFalse(state.returnToToday())
        XCTAssertTrue(state.closeSupportingRoute())
        XCTAssertEqual(state.focusAnchor, .settledTruth)
        XCTAssertEqual(state.acceptedTruth, acceptedTruth)

        XCTAssertEqual(TodayVitalityHistoryFilter.allCases.map(\.visibleTitle), [
            "All",
            "Today",
            "Last 7 Days",
            "Current Goal",
            "Current Step"
        ])
    }

    func testTimeTransferRemainsHostOnlyReadOnlyAndUnavailableInProductRouteModel() {
        let transfer = content.supporting.timeTransfer

        XCTAssertTrue(transfer.isReadOnly)
        XCTAssertTrue(transfer.isHostEvaluationOnly)
        XCTAssertFalse(transfer.isProductRouteAvailable)
        XCTAssertFalse(
            TodayFlagshipSupportingRoute.allCases.map(\.rawValue).contains("time-transfer")
        )
        XCTAssertEqual(transfer.sourceOwner, "Today")
        XCTAssertEqual(transfer.destinationOwner, "Time")
    }

    func testConsequenceDetailsKeepsLocalHistoryBeforeProtectedBoundary() throws {
        let source = try String(
            contentsOf: supportingDepthSourceURL,
            encoding: .utf8
        )
        let history = try XCTUnwrap(source.range(of: "title: \"On this device\""))
        let protected = try XCTUnwrap(source.range(of: "title: \"Protected boundary\""))

        XCTAssertLessThan(history.lowerBound, protected.lowerBound)
    }

    func testSupportingDepthUsesExactFixtureRelationships() {
        XCTAssertEqual(content.supporting.goal.title, "Welcome our baby home")
        XCTAssertEqual(content.supporting.goal.nextStepID, content.primaryStep.id)
        XCTAssertEqual(
            content.supporting.history.recordedTruth,
            content.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertEqual(content.supporting.history.stepID, content.primaryStep.id)
        XCTAssertEqual(content.supporting.history.goalID, content.supporting.goal.id)
        XCTAssertTrue(content.supporting.history.isLocalOnly)
    }

    func testR14SupportingDepthUsesOpenPlaneIdentityAndVitalityRows() throws {
        let source = try String(contentsOf: supportingDepthSourceURL, encoding: .utf8)

        XCTAssertTrue(source.contains("TodayVitalitySupportingIdentity"))
        XCTAssertTrue(source.contains("r14-supporting-open-plane"))
        XCTAssertTrue(source.contains("TodayVitalityNode("))
        XCTAssertFalse(source.contains("Form {"))
    }

    private var supportingDepthSourceURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources")
            .appendingPathComponent("AmbitionsNativeVisualFoundry")
            .appendingPathComponent("TodayVitalitySupportingDepth.swift")
    }
}
