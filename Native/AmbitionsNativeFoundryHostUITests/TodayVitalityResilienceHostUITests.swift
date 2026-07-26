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

        app.terminate()
        launch("r13-resilience-cancelled")
        XCTAssertTrue(element("tfcs-current-truth").waitForExistence(timeout: 4))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
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
        XCTAssertTrue(element("tfcs-current-truth").waitForExistence(timeout: 4))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
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
}
