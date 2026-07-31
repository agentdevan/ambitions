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
        let destination = element("cnc-meaning-destination")
        let review = element("cnc-meaning-review")
        let change = element("cnc-meaning-change")
        assertExists([original, proposal, destination, review, change])
        assertVerticalOrder([original, proposal, destination, review])
        XCTAssertEqual(original.label, "Your words")
        XCTAssertEqual(
            original.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
        XCTAssertEqual(destination.label, "Destination")
        XCTAssertTrue((destination.value as? String)?.contains("Goals") == true)
        XCTAssertTrue((destination.value as? String)?.contains("Proposed, not added") == true)

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
        assertVerticalOrder([
            reviewOriginal,
            reviewProposal,
            related,
            current,
            consequence,
            continueToGoals
        ])
        XCTAssertTrue(app.navigationBars["Review"].exists)
        XCTAssertEqual(current.value as? String, "Nothing has changed.")
        XCTAssertEqual(
            consequence.value as? String,
            "Goals will review this proposal. The appointment time remains unchanged."
        )

        continueToGoals.tap()
        XCTAssertEqual(current.value as? String, "Nothing has changed.")
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
        assertVerticalOrder([original, question, response, continueButton, changeWords])
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
        assertVerticalOrder([message, original, proposal, continueReview, keepEditing])
        XCTAssertTrue((message.label).contains("Your draft is still here"))
        XCTAssertEqual(
            original.value as? String,
            "I need to prepare questions for tomorrow’s dentist appointment."
        )
        XCTAssertTrue((proposal.value as? String)?.contains("Dentist appointment") == true)
        XCTAssertTrue((proposal.value as? String)?.contains("Tomorrow · 9:30 AM") == true)

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
        launch("cnc-capture-review-accessibility-dark")

        let original = element("cnc-review-original")
        let proposal = element("cnc-review-proposal")
        let related = element("cnc-review-related")
        let current = element("cnc-review-current")
        let consequence = element("cnc-review-consequence")
        let continueToGoals = element("cnc-review-continue-goals")
        let change = element("cnc-review-change")
        assertExists([original, proposal, related, current, consequence, continueToGoals, change])

        XCTAssertGreaterThan(original.frame.height, ordinaryOriginalHeight)
        assertVerticalOrder([original, proposal, related, current, consequence, continueToGoals])
        XCTAssertEqual(current.value as? String, "Nothing has changed.")
        XCTAssertTrue((consequence.value as? String)?.contains("appointment time remains unchanged") == true)
        XCTAssertGreaterThanOrEqual(continueToGoals.frame.height, 44)

        if continueToGoals.isHittable == false {
            element("cnc-capture-review").swipeUp()
        }
        XCTAssertTrue(continueToGoals.isHittable)
        XCTAssertTrue(change.exists)
        XCTAssertTrue(element("cnc-capture-cancel").isHittable)
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
