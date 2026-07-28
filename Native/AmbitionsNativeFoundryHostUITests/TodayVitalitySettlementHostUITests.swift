import XCTest

final class TodayVitalitySettlementHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testR13SettlementLeadsWithChangedTruthAndSubordinateEvidence() {
        launch("tfcs-f08")

        let heading = element("tfcs-settlement-identity")
        let node = element("r13-settlement-resolved-node")
        let time = element("r13-settlement-time")
        let truth = element("tfcs-settled-truth")
        let pursuit = element("tfcs-settlement-parent-pursuit")
        let evidence = element("tfcs-recorded-acknowledgment")
        let history = element("tfcs-view-history")
        let returnToday = element("tfcs-return-to-today")

        assertExists([
            heading, node, time, truth, pursuit, evidence, history, returnToday
        ])
        XCTAssertTrue(heading.label.hasPrefix("Progress recorded"))
        XCTAssertTrue(heading.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(
            String(describing: truth.value)
                .contains("I primed the wall and tested the new color.")
        )
        XCTAssertLessThan(heading.frame.minY, truth.frame.minY)
        XCTAssertLessThan(truth.frame.minY, pursuit.frame.minY)
        XCTAssertLessThan(pursuit.frame.minY, evidence.frame.minY)
        XCTAssertLessThan(evidence.frame.minY, history.frame.minY)
        assertMinimumTarget(history)
        assertMinimumTarget(returnToday)
        XCTAssertTrue(returnToday.isHittable)
        XCTAssertFalse(element("r13-settlement-success-panel").exists)
        XCTAssertFalse(app.images["checkmark.seal.fill"].exists)
        XCTAssertFalse(app.navigationBars.buttons.firstMatch.exists)
    }

    func testR13HistoryRoundTripKeepsSettledTruthAndReturnAvailable() {
        launch("tfcs-f08")

        let truth = element("tfcs-settled-truth")
        let history = element("tfcs-view-history")
        let returnToday = element("tfcs-return-to-today")
        assertExists([truth, history, returnToday])

        history.tap()
        assertExists([
            element("r13-history-entry"),
            element("r13-history-entry-truth"),
            element("r13-supporting-done")
        ])
        element("r13-supporting-done").tap()
        XCTAssertTrue(
            String(describing: truth.value)
                .contains("I primed the wall and tested the new color.")
        )
        XCTAssertTrue(returnToday.exists)
        XCTAssertTrue(truth.exists)
        XCTAssertTrue(returnToday.isHittable)
    }

    func testR13ExplicitReturnPreservesUniqueObjectsAndContinuityFocus() {
        launch("tfcs-f08")

        let returnToday = element("tfcs-return-to-today")
        XCTAssertTrue(returnToday.waitForExistence(timeout: 4))
        returnToday.tap()

        let settledNursery = element("tfcs-returned-settled-step")
        let startHere = element("tfcs-start-here-object")
        assertExists([
            settledNursery,
            startHere,
            element("tfcs-today-heading"),
            element("tfcs-dock-shell-peek")
        ])
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )
        XCTAssertTrue(
            settledNursery.label.contains("Make the nursery ready for the crib")
        )
        XCTAssertTrue(
            settledNursery.label.contains("I primed the wall and tested the new color.")
        )
        XCTAssertFalse(element("tfcs-overview-row-step.send-launch-brief").exists)
        let continueLaunchBrief = element("tfcs-open-start-here")
        XCTAssertTrue(continueLaunchBrief.exists)
        XCTAssertEqual(continueLaunchBrief.label, "Continue")
        XCTAssertTrue(continueLaunchBrief.isHittable)
        continueLaunchBrief.tap()
        let launchIdentity = element("tfcs-focused-step-id-step.send-launch-brief")
        assertExists([launchIdentity, element("tfcs-focused-parent-pursuit")])
        XCTAssertTrue(launchIdentity.label.contains("Send the launch brief"))
        XCTAssertTrue(element("tfcs-focused-parent-pursuit").label.contains("Work Projects"))
        XCTAssertTrue(app.staticTexts["The brief is drafted and ready for review."].exists)
        XCTAssertTrue(
            app.staticTexts[
                "Sending it keeps the launch on track without entering protected family time."
            ].exists
        )
        XCTAssertTrue(app.staticTexts["Due today · 2:00 PM"].exists)
        XCTAssertFalse(element("tfcs-select-still-counts").exists)
        XCTAssertTrue(app.navigationBars.buttons["Today"].exists)
        app.navigationBars.buttons["Today"].tap()
        XCTAssertTrue(settledNursery.waitForExistence(timeout: 3))
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-returned-settled-step").count,
            1
        )
        XCTAssertLessThan(
            settledNursery.frame.minY,
            element("tfcs-overview-row-event.family-time").frame.minY
        )
        XCTAssertLessThan(
            element("tfcs-overview-row-event.family-time").frame.minY,
            element("tfcs-overview-row-lane.open-after-family").frame.minY
        )
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

    private func assertMinimumTarget(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }
}
