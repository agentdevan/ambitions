import XCTest

@MainActor
final class TodayVitalityFullDayHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testR14FullDayShowsOrderedReadOnlyFieldAndOmitsScrollToNowAtNow() {
        launch("r13-full-day-typical")

        let timeline = element("tfcs-full-day-timeline")
        let deepWork = element("tfcs-full-day-row-event.deep-work")
        let nursery = element("tfcs-full-day-now-step.nursery-ready-for-crib")
        let launch = element("tfcs-full-day-row-step.send-launch-brief")
        let scrollToNow = element("tfcs-scroll-to-now")

        assertExists([timeline, deepWork, nursery, launch])
        XCTAssertTrue(deepWork.label.contains("9:00 AM"))
        XCTAssertTrue(nursery.label.contains("Now · 10:30 AM"))
        XCTAssertTrue(launch.label.contains("2:00 PM"))
        XCTAssertLessThan(deepWork.frame.minY, nursery.frame.minY)
        XCTAssertLessThan(nursery.frame.minY, launch.frame.minY)
        assertMinimumTarget(nursery)
        XCTAssertTrue(nursery.isHittable)
        XCTAssertFalse(scrollToNow.exists)
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
        XCTAssertFalse(app.buttons["Open in Time"].exists)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)

    }

    func testR13FullDayInspectsInitialStepWithoutMutationAndNativeBackRestoresDepth() {
        launch("r13-full-day-typical")

        let nursery = element("tfcs-full-day-now-step.nursery-ready-for-crib")
        XCTAssertTrue(nursery.waitForExistence(timeout: 4))
        nursery.tap()

        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        let back = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(back.exists)
        back.tap()

        XCTAssertTrue(element("tfcs-full-day-root").waitForExistence(timeout: 4))
        XCTAssertTrue(nursery.exists)
        XCTAssertTrue(nursery.isHittable)
    }

    func testR13ReturnedFullDayIsReadOnlyAndKeepsUniqueTruthfulObjects() {
        launch("r13-full-day-returned")

        let launch = element("tfcs-full-day-now-step.send-launch-brief")
        let settled = element("tfcs-full-day-settled-step.nursery-ready-for-crib")
        assertExists([launch, settled])
        XCTAssertFalse(element("tfcs-scroll-to-now").exists)
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-full-day-now-step.send-launch-brief").count,
            1
        )
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-full-day-settled-step.nursery-ready-for-crib").count,
            1
        )
        XCTAssertEqual(
            app.buttons.matching(identifier: "tfcs-full-day-now-step.send-launch-brief").count,
            0
        )
        XCTAssertEqual(
            app.buttons.matching(
                identifier: "tfcs-full-day-settled-step.nursery-ready-for-crib"
            ).count,
            0
        )
        XCTAssertFalse(app.buttons["Still counts"].exists)
        XCTAssertFalse(app.buttons["Open in Time"].exists)
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
        for candidate in elements {
            XCTAssertTrue(candidate.waitForExistence(timeout: 4), file: file, line: line)
        }
    }

    private func assertMinimumTarget(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }
}
