import XCTest

@MainActor
extension TodayFlagshipCalibrationHostUITests {
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
