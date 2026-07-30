import XCTest

@MainActor
final class TimeNativeCalibrationD07HostUITests: XCTestCase {
    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testWeekRootPreservesOrientationTruthAndMeasuredGeometry() {
        launch("tnc-d07-week-root-dark")

        assertExists([
            element("tnc-d07-week-root"),
            element("tnc-d07-week-range"),
            element("tnc-d07-week-orientation"),
            element("tnc-d07-day-wednesday"),
            element("tnc-d07-now"),
            element("tnc-d07-object-placement.send-launch-brief.wed-1400"),
            element("tnc-d07-object-placement.family-time.wed-1730"),
            element("tnc-d07-object-proposal.launch-review.wed-1745"),
            element("tnc-d07-open-capacity"),
            element("tnc-d07-adjacent-thursday")
        ])

        let family = element("tnc-d07-object-placement.family-time.wed-1730")
        let proposal = element("tnc-d07-object-proposal.launch-review.wed-1745")
        let open = element("tnc-d07-open-capacity")
        XCTAssertEqual(family.frame.height, proposal.frame.height * 2, accuracy: 2)
        XCTAssertTrue(family.frame.intersects(proposal.frame))
        XCTAssertEqual(open.frame.minY, family.frame.maxY, accuracy: 3)
        XCTAssertTrue(proposal.label.contains("Proposed · Not scheduled"))
        XCTAssertTrue(open.label.contains("Personal usability unknown"))
    }

    func testFocusedWednesdayObjectDetailDismissalReturnsToSameObject() {
        launch("tnc-d07-focused-wednesday")
        let launchBrief = element("tnc-d07-object-placement.send-launch-brief.wed-1400")
        assertExists([element("tnc-d07-focused-wednesday"), launchBrief])

        launchBrief.tap()
        assertExists([
            element("tnc-d07-object-detail"),
            element("tnc-d07-detail-identity"),
            element("tnc-d07-detail-done")
        ])
        XCTAssertTrue(element("tnc-d07-detail-identity").label.contains("2:00–2:30 PM"))

        element("tnc-d07-detail-done").tap()
        XCTAssertTrue(launchBrief.waitForExistence(timeout: 5))
        XCTAssertTrue(element("tnc-d07-focused-wednesday").exists)
    }

    func testConflictReviewSeparatesTruthAndKeepCurrentReturnsUnchanged() {
        launch("tnc-d07-week-root-dark")
        let proposal = element("tnc-d07-object-proposal.launch-review.wed-1745")
        assertExists([proposal])
        proposal.tap()

        assertExists([
            element("tnc-d07-review-current"),
            element("tnc-d07-review-proposed"),
            element("tnc-d07-review-consequence"),
            element("tnc-d07-review-keep-current"),
            element("tnc-d07-review-cancel")
        ])
        XCTAssertTrue(element("tnc-d07-review-current").label.contains("Accepted · Protected"))
        XCTAssertTrue(element("tnc-d07-review-proposed").label.contains("Proposed · Not scheduled"))

        element("tnc-d07-review-keep-current").tap()
        let family = element("tnc-d07-object-placement.family-time.wed-1730")
        XCTAssertTrue(family.waitForExistence(timeout: 5))
        XCTAssertTrue(family.label.contains("5:30–6:30 PM"))
        XCTAssertTrue(proposal.exists)
    }

    func testAccessibilitySizeUsesOrderedChronologyInsteadOfSpatialTimeline() {
        launch("tnc-d07-accessibility-chronology")

        assertExists([
            element("tnc-d07-chronological-equivalent"),
            element("tnc-d07-accessibility-heading"),
            element("tnc-d07-list-placement.send-launch-brief.wed-1400"),
            element("tnc-d07-list-now")
        ])
        XCTAssertFalse(element("tnc-d07-timeline-wednesday").exists)

        for identifier in [
            "tnc-d07-list-placement.family-time.wed-1730",
            "tnc-d07-list-proposal.launch-review.wed-1745",
            "tnc-d07-list-opening.wed-after-1830",
            "tnc-d07-list-external.prenatal-appointment.thu-0900",
            "tnc-d07-list-proposal.paint-nursery-wall.thu-1030"
        ] {
            scrollUntilExists(element(identifier))
        }

        let fixed = element("tnc-d07-list-placement.send-launch-brief.wed-1400")
        let now = element("tnc-d07-list-now")
        let protected = element("tnc-d07-list-placement.family-time.wed-1730")
        XCTAssertLessThan(fixed.frame.minY, now.frame.minY)
        XCTAssertLessThan(now.frame.minY, protected.frame.minY)
    }

    func testThursdayContextRetainsExternalAndProposedSourceDistinction() {
        launch("tnc-d07-week-root-dark")
        element("tnc-d07-adjacent-thursday").tap()

        let external = element("tnc-d07-object-external.prenatal-appointment.thu-0900")
        let proposal = element("tnc-d07-object-proposal.paint-nursery-wall.thu-1030")
        assertExists([external, proposal])
        XCTAssertTrue(external.label.contains("Apple Calendar observation"))
        XCTAssertTrue(external.label.contains("External observation"))
        XCTAssertTrue(proposal.label.contains("Proposed · Not scheduled"))
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 6),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    private func scrollUntilExists(_ target: XCUIElement, attempts: Int = 16) {
        var remaining = attempts
        while target.exists == false, remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
        XCTAssertTrue(target.exists, "Element did not become reachable: \(target)")
    }
}
