import XCTest

final class TodayFlagshipCalibrationHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testTodayOrientationOrderTargetsAndNativeStepEntry() {
        launch("tfcs-f01")

        let crown = todayCrown()
        let startHere = element("tfcs-start-here")
        let primaryAction = element("tfcs-open-start-here")
        let timeline = element("tfcs-timeline")
        let dock = app.buttons["Open global navigation"]

        assertExists([crown, startHere, primaryAction, timeline, dock])
        XCTAssertLessThan(crown.frame.minY, startHere.frame.minY)
        XCTAssertLessThan(startHere.frame.minY, timeline.frame.minY)
        assertMinimumTarget(primaryAction)
        assertMinimumTarget(dock)
        XCTAssertTrue(primaryAction.isHittable)

        primaryAction.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-step-identity").exists)
        XCTAssertTrue(element("tfcs-current-truth").exists)
    }

    func testDenseTodayScrollKeepsCrownAndDockOutsideContent() {
        launch("tfcs-f03")

        let crown = todayCrown()
        let dock = app.buttons["Open global navigation"]
        let crownY = crown.frame.minY

        app.swipeUp()

        XCTAssertEqual(crown.frame.minY, crownY, accuracy: 1)
        XCTAssertTrue(dock.exists)
        XCTAssertTrue(app.staticTexts["Family dinner"].isHittable)
    }

    func testPrimaryStillCountsJourneyAndCancellationRemainTruthful() {
        launch("tfcs-f06")

        let stillCounts = element("tfcs-select-still-counts")
        XCTAssertTrue(stillCounts.waitForExistence(timeout: 3))
        assertMinimumTarget(stillCounts)
        stillCounts.tap()

        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-review-current-truth").exists)
        XCTAssertTrue(element("tfcs-proposed-truth").exists)

        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.exists)
        cancel.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        element("tfcs-select-still-counts").tap()
        let commit = element("tfcs-commit-still-counts")
        XCTAssertTrue(commit.waitForExistence(timeout: 3))
        assertMinimumTarget(commit)
        commit.tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        XCTAssertTrue(element("tfcs-recorded-acknowledgment").exists)

        let returnToToday = element("tfcs-return-to-today")
        XCTAssertTrue(returnToToday.exists)
        assertMinimumTarget(returnToToday)
        returnToToday.tap()

        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-start-here").exists)
        XCTAssertTrue(app.buttons["Open global navigation"].exists)
    }

    func testAdaptiveNavigationAndRecoveryExposeDistinctValidActions() {
        launch("tfcs-f05")

        let commandIDs = [
            "today", "goals", "time", "you", "search", "capture"
        ]
        let commands = commandIDs.map { element("tfcs-navigation-\($0)") }
        assertExists(commands)
        for command in commands {
            assertMinimumTarget(command)
        }
        XCTAssertEqual(commands.map { $0.label }, [
            "Today", "Goals", "Time", "You", "Search", "Capture"
        ])
        XCTAssertLessThan(commands[3].frame.minY, commands[4].frame.minY)

        app.terminate()
        launch("tfcs-f10")
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 3))

        let continueChoice = element("recovery.continue-saved-progress")
        let keepChoice = element("recovery.keep-step")
        assertExists([continueChoice, keepChoice])
        assertMinimumTarget(continueChoice)
        assertMinimumTarget(keepChoice)
        XCTAssertNotEqual(continueChoice.label, keepChoice.label)

        continueChoice.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
        XCTAssertTrue(element("tfcs-journey-root").waitForExistence(timeout: 8))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func todayCrown() -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(
                format: "label CONTAINS %@",
                "Thursday · Home before dinner"
            ))
            .firstMatch
    }

    private func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 3),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
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
