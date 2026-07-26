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

        let heading = element("r13-settlement-heading")
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
        XCTAssertEqual(history.value as? String, "Collapsed")

        history.tap()
        XCTAssertEqual(history.value as? String, "Expanded")
        XCTAssertTrue(
            String(describing: truth.value)
                .contains("I primed the wall and tested the new color.")
        )
        XCTAssertTrue(returnToday.exists)

        history.tap()
        XCTAssertEqual(element("tfcs-view-history").value as? String, "Collapsed")
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
        XCTAssertFalse(element("tfcs-open-start-here").exists)
        XCTAssertLessThan(
            settledNursery.frame.minY,
            element("tfcs-overview-row-event.family-prenatal-walk").frame.minY
        )
        XCTAssertLessThan(
            element("tfcs-overview-row-event.family-prenatal-walk").frame.minY,
            element("tfcs-overview-row-window.open-after-family").frame.minY
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
