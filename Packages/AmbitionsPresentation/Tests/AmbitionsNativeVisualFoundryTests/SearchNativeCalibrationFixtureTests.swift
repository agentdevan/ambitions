import XCTest
@testable import AmbitionsNativeVisualFoundry

final class SearchNativeCalibrationFixtureTests: XCTestCase {
    private let fixture = SearchNativeCalibrationFixture.flagship

    func testFixtureIdentityAndRepresentativeResultOrderAreDeterministic() {
        XCTAssertEqual(
            SearchNativeCalibrationFixture.fixtureID,
            "search-flagship/owner-routed-semantic-passage/v1"
        )
        XCTAssertEqual(
            fixture.results(for: SearchNativeCalibrationFixture.representativeQuery).map(\.id),
            [
                "event.dentist-appointment",
                "movement.prepare-appointment-questions"
            ]
        )
    }

    func testRepresentativeRowsPreserveCanonicalSemanticOrder() throws {
        let event = try XCTUnwrap(fixture.result(id: "event.dentist-appointment"))
        let movement = try XCTUnwrap(
            fixture.result(id: "movement.prepare-appointment-questions")
        )

        XCTAssertEqual(
            event.semanticOrder,
            ["Dentist appointment", "Time", "Tomorrow · 9:30 AM", "Inspect"]
        )
        XCTAssertEqual(
            movement.semanticOrder,
            [
                "Prepare questions for the appointment",
                "Goals",
                "Current movement",
                "Related appointment context",
                "Inspect"
            ]
        )
    }

    func testNoResultsAndPrivacySuppressionRemainDistinct() {
        XCTAssertTrue(
            fixture.isNoResultsQuery(SearchNativeCalibrationFixture.noResultsQuery)
        )
        XCTAssertFalse(
            fixture.isPrivacyQuery(SearchNativeCalibrationFixture.noResultsQuery)
        )
        XCTAssertTrue(
            fixture.isPrivacyQuery(SearchNativeCalibrationFixture.privacyQuery)
        )
        XCTAssertEqual(
            fixture.results(for: SearchNativeCalibrationFixture.privacyQuery).map(\.id),
            ["event.dentist-appointment"]
        )
    }

    func testPrivacyVisibleProjectionDoesNotContainProtectedIdentity() {
        let visibleText = [
            fixture.privacy.message,
            fixture.privacy.limitation
        ] + fixture.results(for: fixture.privacy.query).flatMap(\.semanticOrder)

        XCTAssertFalse(visibleText.contains(fixture.privacy.hiddenIdentityProbe))
        XCTAssertEqual(fixture.privacy.suppressedMatchCount, 1)
    }

    func testOwnerHandoffKeepsAcceptedAndRequestedTruthDistinct() {
        XCTAssertEqual(fixture.handoff.targetIdentity, "Dentist appointment")
        XCTAssertEqual(fixture.handoff.currentAcceptedTruth, "Tomorrow · 9:30 AM")
        XCTAssertEqual(fixture.handoff.requestedChange, "Tomorrow · 11:00 AM")
        XCTAssertEqual(fixture.handoff.owner, .time)
        XCTAssertEqual(fixture.handoff.consequence, "90 minutes later")
        XCTAssertEqual(
            fixture.handoff.limitation,
            "Time will check availability and any calendar effects."
        )
        XCTAssertEqual(fixture.handoff.actionTitle, "Continue to Time")
        XCTAssertNotEqual(
            fixture.handoff.currentAcceptedTruth,
            fixture.handoff.requestedChange
        )
    }
}
