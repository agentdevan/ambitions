import XCTest

@MainActor
final class GoalsNativeCalibrationScreenshotCaptureUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testGPN2F01GoalsRootDark() {
        launch("gnc-synthesis-root-dark")
        assertReady(["gnc-goals-heading", "gnc-life-area-life-area.home", "gnc-dock-peek"])
        attachScreenshot(named: "GPN2-F01-goals-root-dark")
    }

    func testGPN2F02HomeLifeAreaDark() {
        launch("gnc-synthesis-home-dark")
        assertReady([
            "gnc-home-life-area",
            "gnc-home-goal-goal.welcome-baby-home",
            "gnc-home-goal-goal.make-home-easier-to-run"
        ])
        attachScreenshot(named: "GPN2-F02-home-life-area-dark")
    }

    func testGPN2F03FocusedGoalDark() {
        launch("gnc-synthesis-focused-dark")
        assertReady([
            "gnc-focused-goal-title",
            "gnc-focused-current-truth",
            "gnc-current-movement-path",
            "gnc-future-disclosure"
        ])
        attachScreenshot(named: "GPN2-F03-focused-goal-dark")
    }

    func testGPN2F04GoalsRootLight() {
        launch("gnc-synthesis-root-light")
        assertReady(["gnc-goals-heading", "gnc-life-area-life-area.home", "gnc-dock-peek"])
        attachScreenshot(named: "GPN2-F04-goals-root-light")
    }

    func testGPN2F05HomeLifeAreaLight() {
        launch("gnc-synthesis-home-light")
        assertReady(["gnc-home-life-area", "gnc-home-goal-goal.welcome-baby-home"])
        attachScreenshot(named: "GPN2-F05-home-life-area-light")
    }

    func testGPN2F06FocusedGoalLight() {
        launch("gnc-synthesis-focused-light")
        assertReady(["gnc-focused-goal-title", "gnc-focused-current-truth"])
        attachScreenshot(named: "GPN2-F06-focused-goal-light")
    }

    func testGPN2S01FocusedGoalAccessibility() {
        launch("gnc-synthesis-focused-accessibility")
        assertReady([
            "gnc-focused-goal-title",
            "gnc-focused-current-truth",
            "gnc-focused-proof-disclosure"
        ])
        attachScreenshot(named: "GPN2-S01-focused-goal-accessibility")
    }

    func testGPN2S02FocusedGoalDisclosures() {
        launch("gnc-synthesis-focused-dark")
        let proof = element("gnc-focused-proof-disclosure")
        let future = element("gnc-future-disclosure")
        assertReady(["gnc-focused-proof-disclosure", "gnc-future-disclosure"])
        proof.tap()
        future.tap()
        assertReady(["gnc-focused-proof", "gnc-future-possible", "gnc-open-relationship"])
        attachScreenshot(named: "GPN2-S02-focused-goal-disclosures")
    }

    func testGPN2S03ReduceTransparencyRoot() {
        launch("gnc-synthesis-root-reduce-transparency")
        assertReady(["gnc-goals-heading", "gnc-life-area-life-area.home", "gnc-dock-peek"])
        attachScreenshot(named: "GPN2-S03-reduce-transparency-root")
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func assertReady(
        _ identifiers: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for identifier in identifiers {
            XCTAssertTrue(
                element(identifier).waitForExistence(timeout: 6),
                "Missing capture element \(identifier)",
                file: file,
                line: line
            )
        }
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
