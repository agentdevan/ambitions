import XCTest
@testable import AmbitionsNativeVisualFoundry

final class SearchNativeCalibrationJourneyStateTests: XCTestCase {
    func testPresentationPreservesOriginAndHidesOriginChrome() {
        var state = SearchNativeCalibrationJourneyState()

        XCTAssertTrue(state.originChromeVisible)
        XCTAssertTrue(state.presentSearch())

        XCTAssertTrue(state.isPresented)
        XCTAssertFalse(state.originChromeVisible)
        XCTAssertEqual(state.origin.rootIdentity, "Today")
        XCTAssertEqual(state.origin.initiatingControl, "Search")
        XCTAssertEqual(state.origin.presentationKind, .globalFullScreenTemporary)
        XCTAssertEqual(state.focusAnchor, .query)
    }

    func testDismissalRecordsSafeContextAndRestoresOriginFocus() {
        var state = SearchNativeCalibrationJourneyState()
        XCTAssertTrue(state.presentSearch(query: "appointment"))
        XCTAssertTrue(state.openInspect(resultID: "event.dentist-appointment"))

        state.dismissSearch()

        XCTAssertFalse(state.isPresented)
        XCTAssertTrue(state.originChromeVisible)
        XCTAssertEqual(state.focusAnchor, .originSearchTrigger)
        XCTAssertEqual(state.lastDismissedContext?.query, "appointment")
        XCTAssertEqual(
            state.lastDismissedContext?.route,
            .inspect(resultID: "event.dentist-appointment")
        )
        XCTAssertEqual(
            state.lastDismissedContext?.selectedResultID,
            "event.dentist-appointment"
        )
    }

    func testFrameworkBackRestoresSelectedResultFocus() {
        var state = SearchNativeCalibrationJourneyState(
            isPresented: true,
            query: "appointment",
            focusAnchor: .query
        )

        XCTAssertTrue(state.openInspect(resultID: "event.dentist-appointment"))
        state.restoreNavigationPath([])

        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.selectedResultID, "event.dentist-appointment")
        XCTAssertEqual(
            state.focusAnchor,
            .result("event.dentist-appointment")
        )
    }

    func testFixtureHandoffCannotMutateAcceptedEventTruth() {
        var state = SearchNativeCalibrationJourneyState(
            isPresented: true,
            query: SearchNativeCalibrationFixture.actionQuery,
            focusAnchor: .query
        )
        let originalTruth = state.currentEventTruth

        XCTAssertTrue(state.openOwnerHandoff())
        state.recordFixtureOnlyHandoff()

        XCTAssertTrue(state.fixtureHandoffPrepared)
        XCTAssertEqual(state.currentEventTruth, originalTruth)
        XCTAssertEqual(state.canonicalMutationCount, 0)
    }

    func testOwnerHandoffCancellationPreservesQueryAndSearchContext() {
        var state = SearchNativeCalibrationJourneyState(
            isPresented: true,
            query: SearchNativeCalibrationFixture.actionQuery,
            focusAnchor: .query
        )

        XCTAssertTrue(state.openOwnerHandoff())
        state.cancelOwnerHandoff()

        XCTAssertTrue(state.isPresented)
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.query, SearchNativeCalibrationFixture.actionQuery)
        XCTAssertEqual(state.selectedResultID, "event.dentist-appointment")
        XCTAssertEqual(state.focusAnchor, .handoffPreparation)
        XCTAssertEqual(state.canonicalMutationCount, 0)
    }

    func testQueryCorrectionClearsDepthWithoutCreatingMutation() {
        var state = SearchNativeCalibrationJourneyState(
            isPresented: true,
            query: "appointment",
            navigationPath: [.inspect(resultID: "event.dentist-appointment")],
            focusAnchor: .result("event.dentist-appointment"),
            selectedResultID: "event.dentist-appointment"
        )

        state.updateQuery(SearchNativeCalibrationFixture.noResultsQuery)

        XCTAssertEqual(state.query, SearchNativeCalibrationFixture.noResultsQuery)
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertNil(state.selectedResultID)
        XCTAssertEqual(state.focusAnchor, .query)
        XCTAssertEqual(state.canonicalMutationCount, 0)
    }
}
