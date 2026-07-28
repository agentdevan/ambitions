import XCTest

@MainActor
extension TodayFlagshipCalibrationHostUITests {
    func testR13FocusedStepPreservesTruthHierarchyAndNativeTodayProvenance() {
        launch("b02-focused-typical")

        let identity = element("tfcs-focused-identity")
        let parent = element("tfcs-focused-parent-pursuit")
        let current = element("tfcs-current-truth")
        let consequence = element("tfcs-focused-protected-consequence")
        let time = element("tfcs-focused-temporal-anchor")
        let outcome = element("r13-focused-outcome")
        let openReview = element("tfcs-select-still-counts")

        assertExists([identity, parent, current, consequence, time, outcome, openReview])
        XCTAssertTrue(identity.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(parent.label.contains("Welcome our baby home"))
        XCTAssertTrue(
            current.label.contains("The corner is cleared and the paint sample is chosen.")
        )
        XCTAssertTrue(
            consequence.label.contains(
                "It keeps the room moving without taking over the evening."
            )
        )
        XCTAssertTrue(time.label.contains("Available now · before 2:00 PM handoff"))
        XCTAssertEqual(outcome.label, "Still counts")
        XCTAssertEqual(app.buttons.matching(identifier: "tfcs-select-still-counts").count, 1)
        XCTAssertTrue(openReview.isHittable)
        assertMinimumTarget(openReview)

        XCTAssertTrue(app.navigationBars.buttons["Today"].exists)
        XCTAssertFalse(element("tfcs-today-heading").exists)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)
        XCTAssertFalse(element("tfcs-dock-expanded").exists)
        XCTAssertFalse(app.buttons["Other outcomes"].exists)
        XCTAssertFalse(app.buttons["Choose another outcome"].exists)
    }

    func testR13FocusedAccessibilityKeepsReviewActionReachableByNaturalScroll() {
        launch("b02-focused-accessibility5")

        let identity = element("tfcs-focused-identity")
        let outcome = element("r13-focused-outcome")
        let openReview = element("tfcs-select-still-counts")
        XCTAssertTrue(identity.waitForExistence(timeout: 3))
        XCTAssertTrue(outcome.exists)
        XCTAssertTrue(element("r13-focused-flowing-action").exists)
        XCTAssertLessThanOrEqual(outcome.frame.maxY, openReview.frame.minY)

        scrollUntilHittable(openReview)
        app.swipeUp()

        XCTAssertTrue(openReview.exists)
        XCTAssertTrue(openReview.isHittable)
        assertMinimumTarget(openReview)
        XCTAssertLessThanOrEqual(openReview.frame.maxY, app.frame.maxY - 16)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)

        let evidence = XCTAttachment(screenshot: app.screenshot())
        evidence.name = "R13-focused-accessibility-flowing-action"
        evidence.lifetime = .keepAlways
        add(evidence)
    }
}
