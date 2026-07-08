import XCTest

@MainActor
final class TimeCalendarGradeUITests: AmbitionsUITestCase {
    func testPacket35TimeRootReadsAsCalendarGradeLifeCalendar() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "default-week"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.visual-stage"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-stage"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-week-frame"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.now"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.fixedPoint"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.openWindow"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.scheduledStep"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.protectedWindow"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.calendar-row.pressure"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-action"].exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "productivity score")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "AI recommends")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "dashboard")).firstMatch.exists)
        captureTimeScreenshot(named: "packet-3.5-time-calendar-grade-root", in: app)
    }
}
