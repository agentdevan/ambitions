import XCTest

@MainActor
final class TodayVitalitySupportingDepthHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testGoalDetailShowsBoundedPursuitContextAndDismissesToStep() {
        launch("r13-goal-detail")

        assertExists([
            element("r13-goal-detail"),
            element("r13-goal-detail-identity"),
            element("r13-goal-detail-why"),
            element("r13-goal-detail-posture"),
            element("r13-goal-detail-next-step")
        ])
        XCTAssertFalse(app.staticTexts["Progress score"].exists)

        element("r13-supporting-done").tap()
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-current-truth").exists)
    }

    func testConsequenceDetailsLeavesReviewTruthAndActionsUnchanged() {
        launch("r13-consequence-details")

        assertExists([
            element("r13-consequence-details"),
            element("r13-consequence-details-impact"),
            element("r13-consequence-details-pursuit"),
            element("r13-consequence-details-protected"),
            element("r13-consequence-details-history")
        ])

        element("r13-supporting-done").tap()
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-cancel-review"),
            element("tfcs-commit-still-counts")
        ])
    }

    func testHistoryEntryAndNativeFiltersRemainLocalAndNonMutating() {
        launch("r13-history-entry")

        assertExists([
            element("r13-history-entry"),
            element("r13-history-entry-truth"),
            element("r13-history-entry-time"),
            element("r13-history-entry-step"),
            element("r13-history-entry-goal"),
            element("r13-history-entry-local")
        ])

        element("r13-history-filter-open").tap()
        assertExists([
            element("r13-history-filters"),
            element("r13-history-filter-all"),
            element("r13-history-filter-today"),
            element("r13-history-filter-lastSevenDays"),
            element("r13-history-filter-currentGoal"),
            element("r13-history-filter-currentStep")
        ])
        element("r13-history-filter-currentGoal").tap()
        XCTAssertEqual(
            element("r13-history-filter-currentGoal").value as? String,
            "Selected"
        )
    }

    func testTimeTransferEvaluationIsTruthfullyUnavailableAndCancelable() {
        launch("r13-time-transfer-evaluation")

        let transfer = element("r13-time-transfer-evaluation")
        let cancel = element("r13-time-transfer-cancel")
        assertExists([transfer, cancel])
        XCTAssertTrue(app.staticTexts["Open in Time?"].exists)
        XCTAssertTrue(app.staticTexts["Today remains unchanged"].exists)
        XCTAssertFalse(app.buttons["Open in Time"].exists)
        XCTAssertTrue(cancel.isHittable)
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
            XCTAssertTrue(
                candidate.waitForExistence(timeout: 4),
                "Missing \(candidate)",
                file: file,
                line: line
            )
        }
    }
}
