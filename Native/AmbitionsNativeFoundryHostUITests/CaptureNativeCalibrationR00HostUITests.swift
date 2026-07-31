import XCTest

@MainActor
final class CaptureNativeCalibrationR00HostUITests: XCTestCase {
    private static let waitTimeout: TimeInterval = 15
    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testFullScreenEntryFocusKeyboardCancelAndExactReturn() {
        launch("cnc-capture-origin-dark")

        let origin = element("cnc-origin-chrome")
        let trigger = element("cnc-origin-capture-trigger")
        assertExists([origin, trigger])
        trigger.tap()

        let identity = element("cnc-capture-identity")
        let editor = element("cnc-capture-expression-editor")
        let cancel = element("cnc-capture-cancel")
        let keyboard = app.keyboards.firstMatch
        assertExists([identity, editor, cancel, keyboard])

        XCTAssertFalse(origin.isHittable)
        XCTAssertTrue(editor.isHittable)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertLessThan(editor.frame.minY, keyboard.frame.minY)
        XCTAssertLessThan(cancel.frame.maxY, keyboard.frame.minY)
        XCTAssertFalse(element("cnc-capture-expression-continue").exists)
        XCTAssertFalse(element("cnc-capture-action-region").exists)

        cancel.tap()

        XCTAssertTrue(origin.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertFalse(identity.exists)
        XCTAssertTrue(trigger.isHittable)
        XCTAssertEqual(trigger.value as? String, "Returned from Capture")
    }

    func testBoundedMeaningReviewBackChangeAndNonMutation() {
        launch("cnc-capture-bounded-meaning-dark")

        let original = element("cnc-meaning-original")
        let proposal = element("cnc-meaning-proposal")
        let review = element("cnc-meaning-review")
        let change = element("cnc-meaning-change")
        assertExists([original, proposal, review, change])
        assertVerticalOrder([original, proposal])
        XCTAssertEqual(original.label, "Your words")
        XCTAssertEqual(
            original.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
        XCTAssertEqual(proposal.label, "Proposed for Goals")
        XCTAssertTrue((proposal.value as? String)?.contains("Nothing has been added") == true)
        XCTAssertFalse(app.staticTexts["Destination"].exists)
        XCTAssertFalse(app.staticTexts["Proposed, not added"].exists)
        XCTAssertFalse(app.staticTexts["What this could mean"].exists)
        assertActionRegion(primary: review, secondary: change)

        review.tap()

        let reviewOriginal = element("cnc-review-original")
        let reviewProposal = element("cnc-review-proposal")
        let related = element("cnc-review-related")
        let current = element("cnc-review-current")
        let consequence = element("cnc-review-consequence")
        let continueToGoals = element("cnc-review-continue-goals")
        assertExists([
            reviewOriginal,
            reviewProposal,
            related,
            current,
            consequence,
            continueToGoals
        ])
        assertVerticalOrder([reviewProposal, reviewOriginal, related, current, consequence])
        XCTAssertTrue(app.navigationBars["Review"].exists)
        XCTAssertEqual(current.value as? String, "Nothing has changed yet.")
        XCTAssertEqual(
            consequence.value as? String,
            "Goals will review the proposal. The appointment stays at 9:30 AM."
        )
        XCTAssertFalse(app.staticTexts["Before anything changes"].exists)
        assertActionRegion(
            primary: continueToGoals,
            secondary: element("cnc-review-change")
        )

        continueToGoals.tap()
        XCTAssertEqual(current.value as? String, "Nothing has changed yet.")
        XCTAssertFalse(app.staticTexts["Goal created"].exists)
        XCTAssertFalse(app.staticTexts["Added"].exists)

        let back = app.navigationBars["Review"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()
        XCTAssertTrue(review.waitForExistence(timeout: Self.waitTimeout))

        review.tap()
        element("cnc-review-change").tap()
        let editor = element("cnc-capture-expression-editor")
        assertExists([editor, app.keyboards.firstMatch])
        XCTAssertEqual(
            editor.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
        assertNoExcludedRenderedTerminology()
    }

    func testExactlyOneClarificationRetainsWordsAndFocusedAnswer() {
        launch("cnc-capture-clarification-dark")

        let original = element("cnc-clarification-original")
        let question = element("cnc-clarification-question")
        let response = element("cnc-clarification-response")
        let continueButton = element("cnc-clarification-continue")
        let changeWords = element("cnc-clarification-change-words")
        let keyboard = app.keyboards.firstMatch
        assertExists([original, question, response, continueButton, changeWords, keyboard])
        assertVerticalOrder([original, question, response])
        XCTAssertTrue(app.navigationBars["Clarify"].exists)
        XCTAssertTrue(app.navigationBars["Clarify"].buttons.firstMatch.isHittable)
        XCTAssertEqual(original.value as? String, "Prepare for tomorrow’s appointment.")
        XCTAssertEqual(question.label, "What do you want to prepare?")
        XCTAssertEqual(response.value as? String, "Questions to ask the dentist")
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "What do you want to prepare?")
            ).count,
            1
        )
        XCTAssertLessThan(response.frame.maxY, keyboard.frame.minY)
        assertActionRegion(primary: continueButton, secondary: changeWords)
        XCTAssertTrue(app.buttons["Edit original words"].exists)

        continueButton.tap()
        assertExists([
            element("cnc-meaning-original"),
            element("cnc-meaning-proposal"),
            element("cnc-meaning-review")
        ])
        XCTAssertFalse(app.staticTexts["Assistant"].exists)
        XCTAssertFalse(app.otherElements["Conversation"].exists)
        assertNoExcludedRenderedTerminology()
    }

    func testNonemptyCloseDecisionKeepsOrDiscardsDraftTruthfully() {
        launch("cnc-capture-bounded-meaning-dark")

        element("cnc-capture-cancel").tap()
        let keepEditing = app.buttons["Keep Editing"]
        let discard = app.buttons["Discard and Close"]
        assertExists([keepEditing, discard])
        XCTAssertFalse(app.buttons["Save for Later"].exists)

        keepEditing.tap()
        let editor = element("cnc-capture-expression-editor")
        assertExists([editor, app.keyboards.firstMatch])
        XCTAssertEqual(
            editor.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )

        element("cnc-capture-cancel").tap()
        XCTAssertTrue(discard.waitForExistence(timeout: Self.waitTimeout))
        discard.tap()

        let origin = element("cnc-origin-chrome")
        let trigger = element("cnc-origin-capture-trigger")
        assertExists([origin, trigger])
        XCTAssertEqual(trigger.value as? String, "Returned from Capture")
        XCTAssertTrue(trigger.isHittable)
        XCTAssertFalse(element("cnc-capture-identity").exists)
    }

    func testRecoveryRetainsInSessionStateAndReturnsToReviewOrEditing() {
        launch("cnc-capture-recovery-dark")

        let message = element("cnc-recovery-message")
        let original = element("cnc-recovery-original")
        let proposal = element("cnc-recovery-proposal")
        let continueReview = element("cnc-recovery-continue")
        let keepEditing = element("cnc-recovery-keep-editing")
        assertExists([message, original, proposal, continueReview, keepEditing])
        assertVerticalOrder([message, original, proposal])
        XCTAssertTrue((message.label).contains("Your draft is still here"))
        XCTAssertEqual(
            original.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
        XCTAssertTrue((proposal.value as? String)?.contains("Dentist appointment") == true)
        XCTAssertTrue((proposal.value as? String)?.contains("Tomorrow · 9:30 AM") == true)
        assertActionRegion(primary: continueReview, secondary: keepEditing)

        continueReview.tap()
        XCTAssertTrue(element("cnc-capture-review").waitForExistence(timeout: Self.waitTimeout))
        let back = app.navigationBars["Review"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()
        XCTAssertTrue(message.waitForExistence(timeout: Self.waitTimeout))

        keepEditing.tap()
        let editor = element("cnc-capture-expression-editor")
        assertExists([editor, app.keyboards.firstMatch])
        XCTAssertEqual(
            editor.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
    }

    func testAccessibilityReviewPreservesOrderScrollingAndPrimaryAction() {
        launch("cnc-capture-review-dark")
        let ordinaryOriginalHeight = element("cnc-review-original").frame.height

        app.terminate()
        launch("cnc-capture-review-accessibility-top-dark")

        let original = element("cnc-review-original")
        let proposal = element("cnc-review-proposal")
        let related = element("cnc-review-related")
        let current = element("cnc-review-current")
        let consequence = element("cnc-review-consequence")
        let continueToGoals = element("cnc-review-continue-goals")
        let change = element("cnc-review-change")
        assertExists([original, proposal, related, current, consequence, continueToGoals, change])

        XCTAssertGreaterThan(original.frame.height, ordinaryOriginalHeight)
        assertVerticalOrder([proposal, original, related, current, consequence])
        XCTAssertTrue(app.navigationBars["Review"].exists)
        XCTAssertGreaterThanOrEqual(
            proposal.frame.minY,
            app.navigationBars["Review"].frame.maxY - 1
        )
        XCTAssertLessThan(original.frame.maxY, continueToGoals.frame.minY)
        XCTAssertEqual(current.value as? String, "Nothing has changed yet.")
        XCTAssertTrue((consequence.value as? String)?.contains("stays at 9:30 AM") == true)
        XCTAssertGreaterThanOrEqual(continueToGoals.frame.height, 44)
        attachScreenScreenshot(named: "06-capture-review-accessibility-top-dark")

        app.terminate()
        launch("cnc-capture-review-accessibility-action-dark")

        let actionCurrent = element("cnc-review-current")
        let actionConsequence = element("cnc-review-consequence")
        let actionPrimary = element("cnc-review-continue-goals")
        let actionSecondary = element("cnc-review-change")
        assertExists([
            actionCurrent,
            actionConsequence,
            actionPrimary,
            actionSecondary
        ])
        for _ in 0..<4 where actionConsequence.isHittable == false {
            element("cnc-capture-review").swipeUp()
        }
        XCTAssertTrue(actionConsequence.isHittable)
        XCTAssertLessThanOrEqual(
            actionConsequence.frame.maxY,
            actionPrimary.frame.minY + 1
        )
        XCTAssertTrue(actionPrimary.isHittable)
        XCTAssertTrue(actionSecondary.isHittable)
        XCTAssertGreaterThanOrEqual(actionPrimary.frame.minY, app.frame.minY)
        XCTAssertLessThanOrEqual(actionPrimary.frame.maxY, app.frame.maxY)
        XCTAssertGreaterThanOrEqual(actionSecondary.frame.minY, app.frame.minY)
        XCTAssertLessThanOrEqual(actionSecondary.frame.maxY, app.frame.maxY)
        XCTAssertTrue(element("cnc-capture-cancel").isHittable)
        assertActionRegion(primary: actionPrimary, secondary: actionSecondary)
        attachAppScreenshot(named: "07-capture-review-accessibility-action-dark")
        assertNoExcludedRenderedTerminology()
    }

    func testGlobalDismissalFromEveryNonemptyStateReturnsExactOriginFocus() {
        let variants = [
            "cnc-capture-bounded-meaning-dark",
            "cnc-capture-clarification-dark",
            "cnc-capture-review-dark",
            "cnc-capture-recovery-dark"
        ]

        for variant in variants {
            app.terminate()
            launch(variant)

            let cancel = element("cnc-capture-cancel")
            XCTAssertTrue(
                cancel.waitForExistence(timeout: Self.waitTimeout),
                "Missing Cancel for \(variant)"
            )
            cancel.tap()

            let discard = app.buttons["Discard and Close"]
            XCTAssertTrue(
                discard.waitForExistence(timeout: Self.waitTimeout),
                "Missing discard decision for \(variant)"
            )
            discard.tap()

            let trigger = element("cnc-origin-capture-trigger")
            XCTAssertTrue(
                trigger.waitForExistence(timeout: Self.waitTimeout),
                "Missing origin trigger after \(variant)"
            )
            XCTAssertEqual(trigger.value as? String, "Returned from Capture")
            XCTAssertTrue(trigger.isHittable)
        }
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func attachScreenScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func attachAppScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: Self.waitTimeout),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoExcludedRenderedTerminology(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let prohibitedPhrases = [
            "canonical owner",
            "parser",
            "confidence",
            "classification",
            "routing",
            "model reasoning",
            "fixture",
            "proof",
            "implementation",
            "mutation",
            "receipt",
            "undo",
            "settlement",
            "dictation",
            "microphone",
            "attachment"
        ]

        for phrase in prohibitedPhrases {
            let predicate = NSPredicate(
                format: "label CONTAINS[c] %@ OR value CONTAINS[c] %@",
                phrase,
                phrase
            )
            XCTAssertEqual(
                app.descendants(matching: .any).matching(predicate).count,
                0,
                "Unexpected rendered terminology: \(phrase)",
                file: file,
                line: line
            )
        }
    }

    private func assertActionRegion(
        primary: XCUIElement,
        secondary: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertExists([primary, secondary], file: file, line: line)
        XCTAssertTrue(primary.isHittable, file: file, line: line)
        XCTAssertTrue(secondary.isHittable, file: file, line: line)
        XCTAssertFalse(primary.frame.intersects(secondary.frame), file: file, line: line)
        XCTAssertGreaterThanOrEqual(primary.frame.height, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(secondary.frame.height, 44, file: file, line: line)
    }

    private func assertVerticalOrder(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for pair in zip(elements, elements.dropFirst()) {
            XCTAssertLessThan(pair.0.frame.minY, pair.1.frame.minY, file: file, line: line)
        }
    }
}
