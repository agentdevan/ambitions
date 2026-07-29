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

    func testFocusedGoalPreservesIdentityTruthMovementAndNativeBack() {
        launch("gnc-f05")

        let title = element("gnc-focused-goal-title")
        let lifeArea = element("gnc-focused-goal-life-area")
        let direction = element("gnc-focused-current-direction")
        let truth = element("gnc-focused-current-truth")
        let thread = element("gnc-focused-active-thread")
        let movement = element("gnc-focused-next-movement")
        let proof = element("gnc-focused-proof")
        let scheduleFit = element("gnc-focused-schedule-fit")
        let relationship = element("gnc-open-relationship")
        let path = element("gnc-view-goal-path")

        assertExists([
            title, lifeArea, direction, truth, thread, movement, proof,
            scheduleFit, relationship, path
        ])
        XCTAssertEqual(title.label, "Welcome our baby home")
        XCTAssertEqual(lifeArea.label, "Home")
        XCTAssertEqual(thread.label, "Finish the nursery.")
        XCTAssertEqual(movement.label, "Paint the nursery wall.")
        XCTAssertTrue(proof.label.contains("Crib corner cleared"))
        XCTAssertTrue(proof.label.contains("Paint color confirmed"))
        XCTAssertTrue(proof.label.contains("Wall primed"))
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.isHittable)
        XCTAssertGreaterThanOrEqual(relationship.frame.height, 44)
        XCTAssertGreaterThanOrEqual(path.frame.height, 44)
    }

    func testRelationshipContainsBothGoalsOwnersAndReturnsToFocusedGoal() {
        launch("gnc-f06")

        let primaryGoal = element("gnc-relationship-primary-goal")
        let primaryOwner = element("gnc-relationship-primary-owner")
        let relatedGoal = element("gnc-relationship-related-goal")
        let relatedOwner = element("gnc-relationship-related-owner")
        let meaning = element("gnc-relationship-meaning")
        let consequence = element("gnc-relationship-consequence")
        let ownership = element("gnc-relationship-ownership")

        assertExists([
            primaryGoal, primaryOwner, relatedGoal, relatedOwner,
            meaning, consequence, ownership
        ])
        XCTAssertEqual(primaryGoal.label, "Welcome our baby home")
        XCTAssertEqual(primaryOwner.label, "Home")
        XCTAssertEqual(relatedGoal.label, "Protect our first weeks together")
        XCTAssertEqual(relatedOwner.label, "Relationships")
        XCTAssertEqual(
            meaning.label,
            "A ready nursery lowers pressure during the first days at home."
        )
        XCTAssertEqual(
            consequence.label,
            "Home setup should support the family’s first-week plan rather than consume it."
        )
        XCTAssertEqual(ownership.label, "Home owns this setup decision.")

        let back = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(back.exists)
        back.tap()
        XCTAssertTrue(element("gnc-focused-goal-title").waitForExistence(timeout: 5))
        XCTAssertEqual(element("gnc-focused-goal-title").label, "Welcome our baby home")
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
