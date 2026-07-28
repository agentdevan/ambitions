import XCTest

final class TodayVitalityAccessibilityHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testR13AccessibilityRootUsesAdaptivePassageAndKeepsMeaningReachable() {
        launch("r13-root-accessibility5")

        let passage = element("tfcs-adaptive-navigation-passage")
        let today = element("tfcs-navigation-today")
        let search = element("tfcs-navigation-search")
        let capture = element("tfcs-navigation-capture")
        assertExists([passage, today])
        assertMinimumTarget(today)
        let startHere = element("tfcs-start-here-object")
        scrollUntilHittable(startHere)
        assertExists([search, capture])
        assertMinimumTarget(search)
        assertMinimumTarget(capture)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)

        scrollUntilHittable(search)
        search.tap()
        scrollUntilHittable(capture)
        capture.tap()
        XCTAssertTrue(passage.exists)

        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-start-here-object").count,
            1
        )

        let focusProbe = XCTAttachment(
            string: "Simulator hasFocus probe: \(startHere.hasFocus). "
                + "VoiceOver spoken focus restoration remains direct-device proof."
        )
        focusProbe.name = "R13 Simulator accessibility focus probe"
        focusProbe.lifetime = .keepAlways
        add(focusProbe)
    }

    func testR13AccessibilityReviewKeepsCancelAndCommitReachable() {
        launch("r13-review-accessibility5")

        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")
        assertExists([current, proposed, cancel, commit])
        scrollUntilHittable(commit)
        XCTAssertTrue(cancel.isHittable)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
        XCTAssertLessThan(current.frame.minY, proposed.frame.minY)
    }

    func testR13ReduceTransparencyUsesOpaqueDockWithSeparatedCommands() {
        launch("r13-root-reduce-transparency")

        let peek = element("tfcs-dock-shell-peek-opaque")
        XCTAssertTrue(peek.waitForExistence(timeout: 4))
        assertMinimumTarget(peek)
        peek.tap()

        let roots = element("tfcs-dock-roots-group")
        let globals = element("tfcs-dock-global-actions-group")
        let today = element("tfcs-dock-today")
        let search = element("tfcs-dock-search")
        let capture = element("tfcs-dock-capture")
        assertExists([roots, globals, today, search, capture])
        assertMinimumTarget(today)
        assertMinimumTarget(search)
        assertMinimumTarget(capture)
        XCTAssertLessThan(roots.frame.minY, globals.frame.minY)
    }

    func testR13LongEnglishRootFocusedReviewAndRecoveryRetainActions() {
        launch("r13-root-long-english")
        let continueAction = element("tfcs-open-start-here")
        scrollUntilHittable(continueAction)
        assertMinimumTarget(continueAction)

        launch("r13-focused-long-english")
        let outcome = element("tfcs-select-still-counts")
        scrollUntilHittable(outcome)
        assertMinimumTarget(outcome)

        launch("r13-review-long-english")
        let commit = element("tfcs-commit-still-counts")
        scrollUntilHittable(commit)
        assertMinimumTarget(commit)

        launch("r13-recovery-long-english")
        let recovery = element("recovery.continue-saved-progress")
        scrollUntilHittable(recovery)
        assertMinimumTarget(recovery)
    }

    private func launch(_ variant: String) {
        if app.state != .notRunning {
            app.terminate()
        }
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
            XCTAssertTrue(candidate.waitForExistence(timeout: 4), file: file, line: line)
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

    private func scrollUntilExists(_ element: XCUIElement) {
        for _ in 0..<8 where element.exists == false {
            app.swipeUp()
        }
        XCTAssertTrue(element.waitForExistence(timeout: 3))
    }

    private func scrollUntilHittable(_ element: XCUIElement) {
        for _ in 0..<8 where element.isHittable == false {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
}
