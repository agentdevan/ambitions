import XCTest

final class TodayVitalityResilienceHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testOfflineLocalTruthRemainsAvailableWithoutSyntheticNetworkControl() {
        launch("r13-resilience-offline")
        XCTAssertTrue(element("tfcs-context-seam-offlineLocalTruth").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-start-here-object").exists)
        XCTAssertFalse(app.buttons["Retry"].exists)
    }

    func testStaleAndConflictSeamsDoNotInventUnsupportedControls() {
        launch("r13-resilience-stale")
        XCTAssertTrue(element("tfcs-context-seam-staleExternalContext").waitForExistence(timeout: 4))
        XCTAssertFalse(app.buttons["Review Changes"].exists)

        app.terminate()
        launch("r13-resilience-conflict")
        XCTAssertTrue(element("tfcs-context-seam-conflictTransfer").waitForExistence(timeout: 4))
        XCTAssertFalse(app.buttons["Open in Time"].exists)
    }

    func testFailedAndCancelledStatesKeepAcceptedTruth() {
        launch("r13-resilience-failed")
        XCTAssertTrue(element("tfcs-failed-settlement").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-review-current-truth").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        let retry = app.buttons["Try again"]
        XCTAssertTrue(retry.exists)
        assertMinimumTarget(retry)
        retry.tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))

        app.terminate()
        launch("r13-resilience-failed")
        let returnToStep = app.buttons["Return to Step"]
        XCTAssertTrue(returnToStep.waitForExistence(timeout: 4))
        assertMinimumTarget(returnToStep)
        returnToStep.tap()
        assertUnchangedFocusedTruth()

        app.terminate()
        launch("r13-resilience-cancelled")
        let notNow = element("tfcs-cancel-review")
        XCTAssertTrue(notNow.waitForExistence(timeout: 4))
        XCTAssertEqual(notNow.label, "Not now")
        assertMinimumTarget(notNow)
        notNow.tap()
        assertUnchangedFocusedTruth()
    }

    func testExactEligibleUndoCanBeKeptOrAppliedWithoutDeletingHistory() {
        launch("r13-resilience-undo")
        let keep = element("r13-undo-keep")
        let undo = element("r13-undo-commit")
        assertExists([
            element("r13-undo-review"),
            element("r13-undo-step-identity"),
            element("r13-undo-current-truth"),
            element("r13-undo-effect"),
            element("r13-undo-history-preserved"),
            keep,
            undo
        ])
        assertMinimumTarget(keep)
        assertMinimumTarget(undo)
        keep.tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 4))

        app.terminate()
        launch("r13-resilience-undo")
        let relaunchedUndo = element("r13-undo-commit")
        XCTAssertTrue(relaunchedUndo.waitForExistence(timeout: 4))
        relaunchedUndo.tap()
        assertUnchangedFocusedTruth()
        let identity = element("tfcs-focused-identity")
        let parent = element("r13-open-goal-detail")
        XCTAssertTrue(identity.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(parent.label.contains("Welcome our baby home"))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testDefaultFixtureDoesNotExposeUndo() {
        launch("r13-resilience-undo-unavailable")
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 4))
        XCTAssertFalse(app.buttons["Undo"].exists)
        XCTAssertFalse(element("r13-undo-review").exists)
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func assertExists(_ elements: [XCUIElement], file: StaticString = #filePath, line: UInt = #line) {
        for candidate in elements {
            XCTAssertTrue(candidate.waitForExistence(timeout: 4), file: file, line: line)
        }
    }

    private func assertMinimumTarget(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }

    private func assertUnchangedFocusedTruth(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4), file: file, line: line)
        XCTAssertTrue(element("tfcs-current-truth").exists, file: file, line: line)
        XCTAssertTrue(element("r13-open-goal-detail").exists, file: file, line: line)
        XCTAssertFalse(element("tfcs-proposed-truth").exists, file: file, line: line)
        XCTAssertFalse(element("tfcs-settled-truth").exists, file: file, line: line)
        XCTAssertFalse(element("tfcs-failed-settlement").exists, file: file, line: line)
        XCTAssertFalse(element("tfcs-interruption-seam").exists, file: file, line: line)
    }
}
