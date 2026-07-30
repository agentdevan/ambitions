import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TimeNativeCalibrationFixtureTests: XCTestCase {
    private let fixture = TimeNativeCalibrationFixture.flagship

    func testFixturePreservesCorrectedProtectedAndOpenBoundary() throws {
        let family = try XCTUnwrap(
            fixture.object(id: "placement.family-time.wed-1730")
        )
        let open = try XCTUnwrap(
            fixture.object(id: "opening.wed-after-1830")
        )

        XCTAssertEqual(family.startMinute, 17 * 60 + 30)
        XCTAssertEqual(family.endMinute, 18 * 60 + 30)
        XCTAssertEqual(family.timeLabel, "5:30–6:30 PM")
        XCTAssertEqual(family.truth, .acceptedProtected)
        XCTAssertEqual(family.meaning, "No work")
        XCTAssertEqual(open.startMinute, family.endMinute)
        XCTAssertEqual(open.timeLabel, "After 6:30 PM")
        XCTAssertEqual(open.meaning, "Personal usability unknown")
    }

    func testProposalAndExternalTruthNeverReceiveAcceptedState() throws {
        let prenatal = try XCTUnwrap(
            fixture.object(id: "external.prenatal-appointment.thu-0900")
        )
        let nursery = try XCTUnwrap(
            fixture.object(id: "proposal.paint-nursery-wall.thu-1030")
        )
        let launchReview = try XCTUnwrap(
            fixture.object(id: "proposal.launch-review.wed-1745")
        )

        XCTAssertEqual(prenatal.truth, .externalObservation)
        XCTAssertEqual(prenatal.source, "Apple Calendar observation")
        XCTAssertEqual(nursery.truth, .proposedPlacement)
        XCTAssertEqual(launchReview.truth, .proposedPlacement)
        XCTAssertEqual(
            launchReview.conflictParticipantIDs,
            [
                "proposal.launch-review.wed-1745",
                "placement.family-time.wed-1730"
            ]
        )
    }

    func testWeekOrientationAndChronologyAreStable() {
        XCTAssertEqual(fixture.selectedDayID, .wednesday)
        XCTAssertEqual(fixture.days.map(\.dayNumber), [27, 28, 29, 30, 31, 1, 2])
        XCTAssertEqual(fixture.nowMinute, 15 * 60 + 12)
        XCTAssertEqual(
            fixture.objects(on: .wednesday).map(\.id),
            [
                "placement.send-launch-brief.wed-1400",
                "placement.family-time.wed-1730",
                "proposal.launch-review.wed-1745",
                "opening.wed-after-1830"
            ]
        )
    }

    func testMeasuredScalePreservesExactDurationAndOverlap() {
        let scale = TimeNativeCalibrationScale(
            startMinute: 13 * 60 + 30,
            endMinute: 19 * 60 + 15,
            pointsPerHour: 88
        )

        XCTAssertEqual(scale.yOffset(for: 14 * 60), 44, accuracy: 0.001)
        XCTAssertEqual(scale.durationHeight(startMinute: 14 * 60, endMinute: 14 * 60 + 30), 44, accuracy: 0.001)
        XCTAssertEqual(scale.yOffset(for: 15 * 60 + 12), 149.6, accuracy: 0.001)
        XCTAssertEqual(scale.yOffset(for: 17 * 60 + 30), 352, accuracy: 0.001)
        XCTAssertEqual(scale.durationHeight(startMinute: 17 * 60 + 30, endMinute: 18 * 60 + 30), 88, accuracy: 0.001)
        XCTAssertEqual(scale.yOffset(for: 17 * 60 + 45), 374, accuracy: 0.001)
        XCTAssertEqual(scale.durationHeight(startMinute: 17 * 60 + 45, endMinute: 18 * 60 + 15), 44, accuracy: 0.001)
        XCTAssertEqual(scale.yOffset(for: 18 * 60 + 30), 440, accuracy: 0.001)
    }
}
