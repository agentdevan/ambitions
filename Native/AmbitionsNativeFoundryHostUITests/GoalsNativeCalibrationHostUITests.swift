import XCTest

@MainActor
final class GoalsNativeCalibrationHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testGoalsRootIsStrictLifeAreaIndexAndHomeIsRowWideNavigation() {
        launch("gnc-synthesis-root-dark")

        let heading = element("gnc-goals-heading")
        let home = element("gnc-life-area-life-area.home")
        let relationships = element("gnc-life-area-life-area.relationships")
        let career = element("gnc-life-area-life-area.career")

        assertExists([heading, home, relationships, career, element("gnc-dock-peek")])
        XCTAssertEqual(heading.label, "Goals")
        XCTAssertFalse(app.staticTexts["Welcome our baby home"].exists)
        XCTAssertFalse(element("gnc-goal-goal.welcome-baby-home").exists)
        for passage in [home, relationships, career] {
            XCTAssertGreaterThanOrEqual(passage.frame.height, 44)
            XCTAssertTrue(passage.isHittable)
        }
        assertExists([
            element("gnc-life-area-posture-life-area.home"),
            element("gnc-life-area-posture-life-area.relationships"),
            element("gnc-life-area-posture-life-area.career")
        ])

        home.tap()
        XCTAssertTrue(element("gnc-home-life-area").waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Home"].exists)
    }

    func testHomeGoalOpensFocusedDepthAndInteractiveBackRestoresSelection() {
        launch("gnc-synthesis-home-dark")

        let primary = element("gnc-home-goal-goal.welcome-baby-home")
        let peerOne = element("gnc-home-goal-goal.make-home-easier-to-run")
        let peerTwo = element("gnc-home-goal-goal.finish-essential-move-in-work")
        assertExists([primary, peerOne, peerTwo])
        assertExists([
            element("gnc-goal-anchor-goal.welcome-baby-home"),
            element("gnc-goal-anchor-goal.make-home-easier-to-run"),
            element("gnc-goal-anchor-goal.finish-essential-move-in-work")
        ])
        XCTAssertTrue((primary.value as? String)?.contains("recorded support") == true)
        XCTAssertTrue((peerOne.value as? String)?.contains("Small systems are taking shape") == true)
        XCTAssertTrue((peerTwo.value as? String)?.contains("Only essential work remains") == true)
        XCTAssertGreaterThanOrEqual(primary.frame.height, 44)
        XCTAssertTrue(primary.isHittable)

        primary.tap()
        XCTAssertTrue(element("gnc-focused-goal").waitForExistence(timeout: 5))
        XCTAssertEqual(
            element("gnc-focused-goal-title").label,
            "Welcome our baby home"
        )

        app.swipeRight()
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        XCTAssertTrue((primary.value as? String)?.contains("Selected Goal") == true)
        XCTAssertTrue((primary.value as? String)?.contains("Current movement") == true)

        let back = app.navigationBars["Home"].buttons.firstMatch
        XCTAssertTrue(back.exists)
        back.tap()
        XCTAssertTrue(element("gnc-goals-root").waitForExistence(timeout: 5))
        XCTAssertTrue(element("gnc-life-area-life-area.home").exists)
    }

    func testPeerLifeAreaNavigationPreservesSelectedIdentity() {
        launch("gnc-synthesis-root-dark")

        let relationships = element("gnc-life-area-life-area.relationships")
        XCTAssertTrue(relationships.waitForExistence(timeout: 5))
        relationships.tap()
        XCTAssertTrue(
            element("gnc-life-area-detail-life-area.relationships")
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.navigationBars["Relationships"].exists)
        XCTAssertFalse(app.staticTexts["Welcome our baby home"].exists)

        app.navigationBars["Relationships"].buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-goals-root").waitForExistence(timeout: 5))
    }

    func testFocusedGoalExpandsProofFutureAndOpensGoalPath() {
        launch("gnc-synthesis-focused-dark")

        let truth = element("gnc-focused-current-truth")
        let proofDisclosure = element("gnc-focused-proof-disclosure")
        let futureDisclosure = element("gnc-future-disclosure")
        let movement = element("gnc-current-movement-path")
        let proofFoundation = element("gnc-proof-foundation")
        let pursuitAnchor = element("gnc-focused-pursuit-anchor")
        assertExists([
            truth,
            proofDisclosure,
            futureDisclosure,
            movement,
            proofFoundation,
            pursuitAnchor
        ])
        XCTAssertEqual(
            truth.label,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
        XCTAssertGreaterThanOrEqual(proofDisclosure.frame.height, 44)
        XCTAssertGreaterThanOrEqual(futureDisclosure.frame.height, 44)
        XCTAssertGreaterThanOrEqual(movement.frame.height, 44)
        XCTAssertTrue(proofFoundation.label.contains("Crib corner cleared"))
        XCTAssertEqual(movement.value as? String, "Primary operation")

        proofDisclosure.tap()
        let proof = element("gnc-focused-proof")
        XCTAssertTrue(proof.waitForExistence(timeout: 5))
        XCTAssertTrue(proof.label.contains("Crib corner cleared"))
        XCTAssertTrue(proof.label.contains("Paint color confirmed"))
        XCTAssertTrue(proof.label.contains("Wall primed"))

        futureDisclosure.tap()
        assertExists([
            element("gnc-future-possible"),
            element("gnc-future-conditional"),
            element("gnc-open-relationship")
        ])

        movement.tap()
        XCTAssertTrue(element("gnc-goal-path").waitForExistence(timeout: 5))
        XCTAssertEqual(
            element("gnc-path-node-goalpath-node.paint-wall").value as? String,
            "Current, selected"
        )
    }

    func testRelationshipInspectionReturnsToFocusedGoalWithoutMutation() {
        launch("gnc-synthesis-focused-dark")

        let futureDisclosure = element("gnc-future-disclosure")
        XCTAssertTrue(futureDisclosure.waitForExistence(timeout: 5))
        futureDisclosure.tap()

        let relationship = element("gnc-open-relationship")
        XCTAssertTrue(relationship.waitForExistence(timeout: 5))
        relationship.tap()
        XCTAssertTrue(element("gnc-relationship-primary-goal").waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-focused-goal").waitForExistence(timeout: 5))
        XCTAssertEqual(
            element("gnc-focused-current-truth").label,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
    }

    func testAccessibilityFocusedGoalRecomposesAndKeepsActionsReachable() {
        launch("gnc-synthesis-focused-accessibility")

        let title = element("gnc-focused-goal-title")
        let truth = element("gnc-focused-current-truth")
        let proof = element("gnc-focused-proof-disclosure")
        let movement = element("gnc-current-movement-path")
        let future = element("gnc-future-disclosure")

        assertExists([title, truth, proof])
        XCTAssertTrue(element("gnc-focused-pursuit-anchor").exists)
        for _ in 0 ..< 5 where movement.exists == false || future.exists == false {
            app.swipeUp()
        }
        assertExists([movement, future])
        XCTAssertGreaterThanOrEqual(proof.frame.height, 44)
        XCTAssertGreaterThanOrEqual(movement.frame.height, 44)
        XCTAssertGreaterThanOrEqual(future.frame.height, 44)
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.isHittable)
    }

    func testReduceMotionKeepsProofAndFutureMeaningAvailable() {
        launch("gnc-synthesis-focused-reduce-motion")

        let proof = element("gnc-focused-proof-disclosure")
        let future = element("gnc-future-disclosure")
        assertExists([proof, future])
        proof.tap()
        future.tap()
        assertExists([
            element("gnc-focused-proof"),
            element("gnc-future-possible"),
            element("gnc-future-conditional"),
            element("gnc-open-relationship")
        ])
    }

    func testReduceTransparencyKeepsOpaqueDockNavigationReachable() {
        launch("gnc-synthesis-root-reduce-transparency")

        let dock = element("gnc-dock-peek")
        let home = element("gnc-life-area-life-area.home")
        assertExists([dock, home])
        XCTAssertGreaterThanOrEqual(dock.frame.width, 44)
        XCTAssertGreaterThanOrEqual(dock.frame.height, 44)
        home.tap()
        XCTAssertTrue(element("gnc-home-life-area").waitForExistence(timeout: 5))
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
