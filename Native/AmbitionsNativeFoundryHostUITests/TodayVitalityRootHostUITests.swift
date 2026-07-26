import XCTest

@MainActor
extension TodayFlagshipCalibrationHostUITests {
    func testR13RootUsesExactEnglishFieldAndReturnedProjection() {
        launch("tfcs-f02")

        let startHere = element("tfcs-start-here-object")
        let action = element("tfcs-open-start-here")
        let fixed = element("tfcs-overview-row-step.send-launch-brief")
        let protected = element("tfcs-overview-row-event.family-time")
        let open = element("tfcs-overview-row-lane.open-after-family")
        let fullDay = element("tfcs-view-full-day")

        assertExists([startHere, action, fixed, protected, open])
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Start Here")
            ).count,
            1
        )
        XCTAssertTrue(
            app.staticTexts[
                "Moves the nursery forward while family time stays protected."
            ].exists
        )
        XCTAssertTrue(app.staticTexts["Available now · before 2:00 PM handoff"].exists)
        XCTAssertEqual(action.label, "Continue")
        assertMinimumTarget(action)
        XCTAssertTrue(action.isHittable)
        XCTAssertLessThan(fixed.frame.minY, protected.frame.minY)
        XCTAssertLessThan(protected.frame.minY, open.frame.minY)

        scrollUntilHittable(fullDay)
        XCTAssertLessThan(open.frame.minY, fullDay.frame.minY)

        app.terminate()
        launch("tfcs-f09")
        XCTAssertFalse(element("tfcs-open-start-here").exists)
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )
        XCTAssertFalse(element("tfcs-overview-row-step.send-launch-brief").exists)
    }
}
