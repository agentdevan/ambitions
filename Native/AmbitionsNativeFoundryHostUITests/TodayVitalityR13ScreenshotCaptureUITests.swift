import XCTest

@MainActor
extension TodayFlagshipCalibrationHostUITests {
    func testR13A01CapturesAccessibleRootMeaningAfterPassage() {
        launch("r13-root-accessibility5")
        let startHere = element("tfcs-start-here-object")
        scrollUntilHittable(startHere)
        assertExists([
            startHere,
            element("tfcs-open-start-here")
        ])
        attachR13Screenshot(named: "R13-A01-accessibility-root")
    }

    func testR13A02CapturesAccessibilityReviewRecomposition() {
        launch("r13-root-accessibility5")
        let continueAction = element("tfcs-open-start-here")
        scrollUntilHittable(continueAction)
        continueAction.tap()
        let outcome = element("tfcs-select-still-counts")
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        scrollUntilHittable(outcome)
        outcome.tap()
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth")
        ])
        attachR13Screenshot(named: "R13-A02-accessibility-review")
    }

    func testR13A03CapturesIncreasedContrastReview() {
        launch("r13-review-increased-contrast")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-commit-still-counts")
        ])
        attachR13Screenshot(named: "R13-A03-increased-contrast")
    }

    func testR13A04CapturesDifferentiateWithoutColorReview() {
        launch("r13-review-differentiate-without-color")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-commit-still-counts")
        ])
        attachR13Screenshot(named: "R13-A04-differentiate-without-color")
    }

    func testR13F03CapturesIntentionalNaturalScroll() {
        launch("r13-root-dark")
        let startHere = element("tfcs-start-here-object")
        let overview = element("tfcs-today-overview")
        assertExists([startHere, overview, element("tfcs-dock-shell-peek")])

        for _ in 0..<3 {
            app.swipeUp(velocity: .slow)
        }
        XCTAssertTrue(overview.exists)
        XCTAssertTrue(element("tfcs-view-full-day").isHittable)
        attachR13Screenshot(named: "R13-F03-natural-scroll")
    }

    func testR13F04CapturesExpandedDock() {
        launch("r13-root-dark")
        element("tfcs-dock-shell-peek").tap()
        assertExists([
            element("tfcs-dock-roots-group"),
            element("tfcs-dock-global-actions-group"),
            element("tfcs-dock-today"),
            element("tfcs-dock-goals"),
            element("tfcs-dock-time"),
            element("tfcs-dock-you"),
            element("tfcs-dock-search"),
            element("tfcs-dock-capture")
        ])
        attachR13Screenshot(named: "R13-F04-dock-expanded")
    }

    func testR13F07CapturesConsequentialReview() {
        launch("r13-root-dark")
        element("tfcs-open-start-here").tap()
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        element("tfcs-select-still-counts").tap()

        assertExists([
            element("tfcs-consequential-review"),
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-cancel-review"),
            element("tfcs-commit-still-counts")
        ])
        attachR13Screenshot(named: "R13-F07-consequential-review")
    }

    func testR13F08CapturesSavingWithAcceptedTruthRetained() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let proposedTruth = "I primed the wall and tested the new color."
        launch("r13-review-saving")

        assertExists([
            element("tfcs-saving-posture"),
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth")
        ])
        XCTAssertEqual(element("tfcs-review-current-truth").value as? String, acceptedTruth)
        XCTAssertEqual(element("tfcs-proposed-truth").value as? String, proposedTruth)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        attachR13Screenshot(named: "R13-F08-saving")
    }

    func testR13D11CapturesCancelledUnchangedState() {
        launch("r13-root-dark")
        element("tfcs-open-start-here").tap()
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        element("tfcs-select-still-counts").tap()
        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 4))
        element("tfcs-cancel-review").tap()

        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-current-truth"),
            element("tfcs-select-still-counts")
        ])
        XCTAssertFalse(element("tfcs-proposed-truth").exists)
        XCTAssertFalse(element("tfcs-saving-posture").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        attachR13Screenshot(named: "R13-D11-cancelled-unchanged")
    }

    private func attachR13Screenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
