import XCTest

@MainActor
final class GoalsNativeCalibrationR03HostUITests: XCTestCase {
    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testGoalPathUsesExactNodesCompactJumpAndNonMutatingSelection() {
        launch("gnc-r03-path-dark")

        let path = element("gnc-r03-path")
        let current = element("gnc-r03-path-node-pathnode.paint-wall")
        let future = element("gnc-r03-path-node-pathnode.assemble-crib")
        let jump = element("gnc-r03-path-jump-menu")
        assertExists([path, current, jump])
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Paint the nursery wall")
        XCTAssertGreaterThanOrEqual(jump.frame.height, 43.9)

        jump.tap()
        let next = app.buttons["Next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        next.tap()
        XCTAssertTrue(future.waitForExistence(timeout: 5))
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Assemble the crib")
        XCTAssertEqual(
            element("gnc-r03-path-current-truth").label,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
    }

    func testPathEvidenceReturnsToTheSameSelectedNodeAndBackToCurrentMovement() {
        launch("gnc-r03-path-evidence")

        let selected = element("gnc-r03-path-node-pathnode.prime-wall-color")
        assertExists([selected, element("gnc-r03-path-evidence-action")])
        element("gnc-r03-path-evidence-action").tap()
        XCTAssertTrue(element("gnc-r03-path-evidence").waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(selected.waitForExistence(timeout: 5))
        XCTAssertEqual(
            element("gnc-r03-path-selected-node").label,
            "Prime the wall and confirm the color"
        )

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-current-movement-path").waitForExistence(timeout: 5))
        XCTAssertEqual(element("gnc-current-movement-path").value as? String, "Primary operation")
    }

    func testRelationshipLeadsWithConsequenceAndReturnsToItsEntry() {
        launch("gnc-r03-relationship")

        let consequence = element("gnc-r03-relationship-consequence")
        let boundary = element("gnc-r03-relationship-boundary")
        assertExists([
            element("gnc-r03-relationship"),
            consequence,
            boundary,
            element("gnc-relationship-primary-goal"),
            element("gnc-relationship-related-goal"),
            element("gnc-relationship-primary-owner"),
            element("gnc-relationship-related-owner")
        ])
        XCTAssertTrue(
            consequence.label.contains(
                "A ready nursery lowers pressure during the first days at home."
            )
        )

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-open-relationship").waitForExistence(timeout: 5))
    }

    func testRecoveryRetainsTruthAndKeepsThePossibleAlternativeUnaccepted() {
        launch("gnc-r03-recovery")

        let truth = element("gnc-r03-recovery-truth")
        let interruption = element("gnc-r03-recovery-interruption")
        let review = element("gnc-r03-recovery-review-path")
        let possible = element("gnc-r03-recovery-possible")
        let keep = element("gnc-r03-recovery-keep")
        assertExists([truth, interruption, review, possible, keep])
        XCTAssertTrue(
            truth.label.contains(
                "The wall is primed, the color is confirmed, and the crib corner is clear."
            )
        )

        possible.tap()
        let alternative = element("gnc-r03-path-node-pathnode.assemble-crib")
        XCTAssertTrue(alternative.waitForExistence(timeout: 5))
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Assemble the crib")
        XCTAssertEqual(
            element("gnc-r03-path-node-pathnode.paint-wall").label,
            "Paint the nursery wall"
        )

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(keep.waitForExistence(timeout: 5))
        XCTAssertEqual(keep.label, "Keep unresolved")
    }

    func testClosureKeepsGoalProofOpenWorkAndHistoryWithoutAutoDismissal() {
        launch("gnc-r03-closure")

        assertExists([
            element("gnc-r03-closure"),
            element("gnc-r03-closure-truth"),
            element("gnc-r03-closure-proof"),
            element("gnc-r03-closure-relationship"),
            element("gnc-r03-closure-remaining"),
            element("gnc-r03-closure-history-action")
        ])
        XCTAssertTrue(
            element("gnc-r03-closure-truth").label.contains("The nursery is ready for the crib.")
        )

        element("gnc-r03-closure-history-action").tap()
        XCTAssertTrue(element("gnc-r03-closure-history").waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("gnc-r03-closure").waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["100%"].exists)
    }

    func testAccessibilityPathUsesOrderedSemanticEquivalentAndKeepsJumpReachable() {
        launch("gnc-r03-path-accessibility")

        let foundation = element("gnc-r03-path-accessibility-foundation")
        let list = element("gnc-r03-path-accessibility-list")
        let jump = element("gnc-r03-path-jump-menu")
        assertExists([
            foundation,
            element("gnc-r03-path-accessibility-truth"),
            element("gnc-r03-path-accessibility-current"),
            element("gnc-r03-path-accessibility-proof"),
            element("gnc-r03-path-accessibility-next"),
            element("gnc-r03-path-accessibility-possible"),
            element("gnc-r03-path-accessibility-conditional")
        ])
        XCTAssertLessThan(foundation.frame.minY, list.frame.minY)
        XCTAssertFalse(element("gnc-r03-path-horizontal").exists)
        for nodeID in [
            "pathnode.define-ready",
            "pathnode.clear-crib-corner",
            "pathnode.prime-wall-color",
            "pathnode.paint-wall",
            "pathnode.assemble-crib",
            "pathnode.changing-station",
            "pathnode.final-furniture",
            "pathnode.nursery-ready"
        ] {
            let node = element("gnc-r03-path-node-\(nodeID)")
            var attempts = 0
            while node.exists == false, attempts < 12 {
                app.swipeUp()
                attempts += 1
            }
            XCTAssertTrue(node.exists, "Ordered Path node was not reachable: \(nodeID)")
        }
        let detail = element("gnc-r03-path-selected-node")
        scrollUntilExists(detail)
        scrollUntilExists(jump)
        XCTAssertLessThan(detail.frame.minY, jump.frame.minY)
        XCTAssertGreaterThanOrEqual(jump.frame.height, 43.9)
    }

    func testReduceMotionPreservesPathMeaningAndSelection() {
        launch("gnc-r03-path-reduce-motion")
        assertExists([
            element("gnc-r03-path"),
            element("gnc-r03-path-current-truth"),
            element("gnc-r03-path-node-pathnode.paint-wall"),
            element("gnc-r03-path-jump-menu")
        ])
        XCTAssertEqual(element("gnc-r03-path-selected-node").label, "Paint the nursery wall")
    }

    func testAccessibilityRecoveryAndClosureKeepActionsReachable() {
        launch("gnc-r03-recovery-accessibility")
        for identifier in [
            "gnc-r03-recovery-review-path",
            "gnc-r03-recovery-possible",
            "gnc-r03-recovery-keep"
        ] {
            scrollUntilExists(element(identifier))
        }

        launch("gnc-r03-closure-accessibility")
        for identifier in [
            "gnc-r03-closure-history-action",
            "gnc-r03-closure-return"
        ] {
            scrollUntilExists(element(identifier))
        }
    }

    func testAcceptedR02SurfacesRemainCanonicalAndDoNotExposeR03DepthEntries() {
        launch("gnc-synthesis-root-dark")
        assertExists([
            element("gnc-goals-heading"),
            element("gnc-life-area-life-area.home"),
            element("gnc-life-area-life-area.relationships"),
            element("gnc-life-area-life-area.career")
        ])
        XCTAssertFalse(app.staticTexts["Welcome our baby home"].exists)

        launch("gnc-synthesis-focused-dark")
        assertExists([
            element("gnc-focused-current-truth"),
            element("gnc-current-movement-path"),
            element("gnc-future-disclosure")
        ])
        XCTAssertFalse(element("gnc-r03-recovery-entry").exists)
        XCTAssertFalse(element("gnc-r03-closure-entry").exists)
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
                element.waitForExistence(timeout: 6),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    private func scrollUntilExists(_ target: XCUIElement, attempts: Int = 14) {
        var remaining = attempts
        while target.exists == false, remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
        XCTAssertTrue(target.exists, "Element did not become reachable: \(target)")
    }
}
