import XCTest

final class TodayVitalityRecoveryHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testR13InterruptedStepRetainsTruthAndOpensObjectScopedRecovery() {
        launch("r13-recovery-interrupted")

        let openRecovery = element("tfcs-open-recovery")
        assertExists([
            element("tfcs-interruption-seam"),
            element("tfcs-recovery-step-identity"),
            element("tfcs-recovery-current-truth"),
            element("tfcs-recovery-progress-field"),
            openRecovery
        ])
        assertMinimumTarget(openRecovery)
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        openRecovery.tap()
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 4))
    }

    func testR13RecoverySheetCommandsAreReachableAndDeferralDoesNotMutate() {
        launch("r13-recovery-sheet")

        let continueChoice = element("recovery.continue-saved-progress")
        let deferChoice = element("recovery.keep-step")
        assertExists([
            element("tfcs-recovery-review"),
            element("tfcs-recovery-sheet-progress"),
            continueChoice,
            deferChoice
        ])
        assertMinimumTarget(continueChoice)
        assertMinimumTarget(deferChoice)
        XCTAssertTrue(continueChoice.isHittable)
        XCTAssertTrue(deferChoice.isHittable)

        deferChoice.tap()
        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-recovery-current-truth").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testR13RecoveryCloseRestoresInterruptedTruthWithoutMutation() {
        launch("r13-recovery-sheet")

        let close = app.buttons["Close"]
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 4))
        XCTAssertTrue(close.waitForExistence(timeout: 4))
        assertMinimumTarget(close)
        XCTAssertTrue(close.isHittable)

        close.tap()

        assertExists([
            element("tfcs-interruption-seam"),
            element("tfcs-recovery-current-truth")
        ])
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testR13RecoveryContinuationRestoresSavedProgressWithoutSettlement() {
        launch("r13-recovery-sheet")

        let continueChoice = element("recovery.continue-saved-progress")
        XCTAssertTrue(continueChoice.waitForExistence(timeout: 4))
        continueChoice.tap()

        assertExists([
            element("tfcs-recovered-progress"),
            element("tfcs-current-truth"),
            element("tfcs-select-still-counts")
        ])
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testR13RecoveryAccessibilityKeepsActionsReachable() {
        launch("r13-recovery-accessibility5")

        let heading = element("tfcs-recovery-sheet-heading")
        let savedProgress = element("tfcs-recovery-sheet-progress")
        let continueChoice = element("recovery.continue-saved-progress")
        let deferChoice = element("recovery.keep-step")
        XCTAssertTrue(heading.waitForExistence(timeout: 4))
        XCTAssertTrue(savedProgress.exists)
        XCTAssertTrue(continueChoice.waitForExistence(timeout: 4))
        XCTAssertTrue(deferChoice.exists)
        XCTAssertGreaterThanOrEqual(heading.frame.height, 90)
        XCTAssertLessThan(heading.frame.minY, savedProgress.frame.minY)
        XCTAssertFalse(savedProgress.frame.intersects(continueChoice.frame))
        XCTAssertFalse(savedProgress.frame.intersects(deferChoice.frame))
        assertMinimumTarget(continueChoice)
        assertMinimumTarget(deferChoice)
        for _ in 0..<3 where continueChoice.isHittable == false || deferChoice.isHittable == false {
            app.swipeUp()
        }
        XCTAssertTrue(continueChoice.isHittable)
        XCTAssertTrue(deferChoice.isHittable)
        XCTAssertLessThanOrEqual(savedProgress.frame.maxY, continueChoice.frame.minY)
        XCTAssertLessThan(continueChoice.frame.maxY, deferChoice.frame.minY)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "R13 recovery AX action continuation"
        attachment.lifetime = .keepAlways
        add(attachment)
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
