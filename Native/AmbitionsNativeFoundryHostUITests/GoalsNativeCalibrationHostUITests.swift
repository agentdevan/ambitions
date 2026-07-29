import XCTest

@MainActor
final class GoalsNativeCalibrationHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testGoalsRootKeepsIdentitySelectionAndShellOwnership() {
        launch("gnc-f01")

        let heading = element("gnc-goals-heading")
        let home = element("gnc-life-area-life-area.home")
        let selectedGoal = element("gnc-goal-goal.welcome-baby-home")
        let lensDisclosure = element("gnc-linked-lens-disclosure")
        let dock = element("gnc-dock-peek")

        assertExists([heading, home, selectedGoal, lensDisclosure, dock])
        XCTAssertEqual(heading.label, "Goals")
        XCTAssertEqual(selectedGoal.value as? String, "Selected")
        XCTAssertFalse(app.staticTexts["Start Here"].exists)
        XCTAssertFalse(app.staticTexts["Later Today"].exists)
        XCTAssertFalse(app.staticTexts["View Full Day"].exists)
        XCTAssertFalse(app.buttons["Search"].exists)
        XCTAssertFalse(app.buttons["Capture"].exists)
        XCTAssertGreaterThanOrEqual(lensDisclosure.frame.height, 44)
        XCTAssertGreaterThanOrEqual(dock.frame.height, 44)
    }

    func testLinkedGoalLensRemainsAttachedAndOpenGoalIsReachable() {
        launch("gnc-f04")

        let selectedGoal = element("gnc-goal-goal.welcome-baby-home")
        let lens = element("gnc-linked-lens-goal.welcome-baby-home")
        let currentTruth = element("gnc-lens-current-truth")
        let openGoal = element("gnc-open-goal")

        assertExists([selectedGoal, lens, currentTruth, openGoal])
        XCTAssertLessThan(selectedGoal.frame.minY, lens.frame.minY)
        XCTAssertEqual(
            currentTruth.label,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
        XCTAssertGreaterThanOrEqual(openGoal.frame.height, 44)
        XCTAssertTrue(openGoal.isHittable)
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
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 5),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }
}
