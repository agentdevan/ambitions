import XCTest

/// Deterministic fixture-host journeys used only while native evidence recording is active.
@MainActor
final class GoalsNativeCalibrationR03RecordingUITests: XCTestCase {
    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testRecordPathAndRelationshipJourney() {
        launch("gnc-r03-returned-focused")
        hold()
        capture("J01-01-focused-goal")

        let movement = element("gnc-current-movement-path")
        XCTAssertTrue(movement.waitForExistence(timeout: 6))
        movement.tap()
        XCTAssertTrue(element("gnc-r03-path").waitForExistence(timeout: 6))
        hold()
        capture("J01-02-path-current")

        element("gnc-r03-path-jump-menu").tap()
        let next = app.buttons["Next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        next.tap()
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Assemble the crib")
        hold()
        capture("J01-03-path-next")

        let evidence = element("gnc-r03-path-evidence-action")
        scrollUntilHittable(evidence)
        evidence.tap()
        XCTAssertTrue(element("gnc-r03-path-evidence").waitForExistence(timeout: 6))
        hold()
        capture("J01-04-proof-history")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Assemble the crib")
        hold()
        capture("J01-05-returned-same-node")

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(movement.waitForExistence(timeout: 6))
        hold()
        capture("J01-06-returned-focused-goal")

        let relationship = element("gnc-open-relationship")
        scrollUntilHittable(relationship)
        relationship.tap()
        XCTAssertTrue(element("gnc-r03-relationship").waitForExistence(timeout: 6))
        hold()
        capture("J01-07-relationship")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-open-relationship").waitForExistence(timeout: 6))
        hold()
        capture("J01-08-returned-relationship-entry")
    }

    func testRecordRecoveryAndClosureJourney() {
        launch("gnc-r03-recovery-entry")
        hold()
        capture("J02-01-recovery-entry")

        let recoveryEntry = element("gnc-r03-recovery-entry")
        scrollUntilHittable(recoveryEntry)
        recoveryEntry.tap()
        XCTAssertTrue(element("gnc-r03-recovery").waitForExistence(timeout: 6))
        hold()
        capture("J02-02-recovery")

        let path = element("gnc-r03-recovery-review-path")
        scrollUntilHittable(path)
        path.tap()
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Paint the nursery wall")
        hold()
        capture("J02-03-interrupted-current-node")
        app.navigationBars.buttons.firstMatch.tap()
        hold()
        capture("J02-04-returned-recovery")

        let keep = element("gnc-r03-recovery-keep")
        scrollUntilHittable(keep)
        keep.tap()
        hold()
        capture("J02-05-returned-unchanged")

        launch("gnc-r03-closure-entry")
        hold()
        capture("J02-06-closure-entry")
        let closureEntry = element("gnc-r03-closure-entry")
        scrollUntilHittable(closureEntry)
        closureEntry.tap()
        XCTAssertTrue(element("gnc-r03-closure").waitForExistence(timeout: 6))
        hold()
        capture("J02-07-closure")

        let history = element("gnc-r03-closure-history-action")
        scrollUntilHittable(history)
        history.tap()
        XCTAssertTrue(element("gnc-r03-closure-history").waitForExistence(timeout: 6))
        hold()
        capture("J02-08-closure-history")
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-r03-closure").waitForExistence(timeout: 6))
        hold()
        capture("J02-09-returned-closure")
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func scrollUntilHittable(_ target: XCUIElement, attempts: Int = 10) {
        var remaining = attempts
        while target.isHittable == false, remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
        XCTAssertTrue(target.isHittable, "Element did not become hittable: \(target)")
    }

    private func hold(_ seconds: TimeInterval = 1.2) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
