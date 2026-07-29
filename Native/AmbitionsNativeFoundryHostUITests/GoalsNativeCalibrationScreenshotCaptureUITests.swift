import XCTest

@MainActor
final class GoalsNativeCalibrationScreenshotCaptureUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testGNCF01GoalsRootLight() {
        launch("gnc-f01")
        assertReady(["gnc-goals-heading", "gnc-goal-goal.welcome-baby-home", "gnc-dock-peek"])
        attachScreenshot(named: "GNC-F01-goals-root-light")
    }

    func testGNCF02GoalsRootDark() {
        launch("gnc-f02")
        assertReady(["gnc-goals-heading", "gnc-goal-goal.welcome-baby-home", "gnc-dock-peek"])
        attachScreenshot(named: "GNC-F02-goals-root-dark")
    }

    func testGNCF03SelectedLifeAreaAndGoal() {
        launch("gnc-f03")
        assertReady([
            "gnc-life-area-life-area.home",
            "gnc-goal-goal.welcome-baby-home",
            "gnc-linked-lens-disclosure"
        ])
        attachScreenshot(named: "GNC-F03-selected-life-area-and-goal")
    }

    func testGNCF04LinkedGoalLens() {
        launch("gnc-f04")
        assertReady([
            "gnc-goal-goal.welcome-baby-home",
            "gnc-linked-lens-goal.welcome-baby-home",
            "gnc-open-goal"
        ])
        attachScreenshot(named: "GNC-F04-linked-goal-lens")
    }

    func testGNCF05FocusedGoalDepth() {
        launch("gnc-f05")
        assertReady([
            "gnc-focused-goal-title",
            "gnc-focused-current-truth",
            "gnc-focused-next-movement"
        ])
        attachScreenshot(named: "GNC-F05-focused-goal-depth")
    }

    func testGNCF06ConsequentialRelationship() {
        launch("gnc-f06")
        assertReady([
            "gnc-relationship-primary-goal",
            "gnc-relationship-related-goal",
            "gnc-relationship-consequence"
        ])
        attachScreenshot(named: "GNC-F06-consequential-relationship")
    }

    func testGNCF07GoalPathHistory() {
        launch("gnc-f07")
        assertReady([
            "gnc-goal-path",
            "gnc-path-node-goalpath-node.paint-wall",
            "gnc-path-proof-history"
        ])
        attachScreenshot(named: "GNC-F07-goal-path-history")
    }

    func testGNCF08AccessibilityDynamicType() {
        launch("gnc-f08")
        assertReady([
            "gnc-life-area-life-area.home",
            "gnc-goal-goal.welcome-baby-home",
            "gnc-linked-lens-goal.welcome-baby-home"
        ])

        let action = element("gnc-open-goal")
        for _ in 0 ..< 4 where action.isHittable == false {
            app.swipeUp()
        }
        XCTAssertTrue(action.isHittable)
        XCTAssertTrue(element("gnc-adaptive-navigation").exists)
        attachScreenshot(named: "GNC-F08-accessibility-dynamic-type")
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
