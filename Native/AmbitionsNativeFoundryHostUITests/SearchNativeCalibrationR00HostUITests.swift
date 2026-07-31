import XCTest

@MainActor
final class SearchNativeCalibrationR00HostUITests: XCTestCase {
    private static let waitTimeout: TimeInterval = 15
    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testFullScreenEntryFocusKeyboardCancelAndExactReturn() {
        launch("snc-search-origin-dark")

        let origin = element("snc-origin-chrome")
        let trigger = element("snc-origin-search-trigger")
        assertExists([origin, trigger])
        trigger.tap()

        let presentation = element("snc-search-identity")
        let query = element("snc-search-query")
        let cancel = element("snc-search-cancel")
        let keyboard = app.keyboards.firstMatch
        assertExists([presentation, query, cancel, keyboard])

        XCTAssertFalse(element("snc-origin-chrome").isHittable)
        XCTAssertTrue(query.isHittable)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertLessThan(query.frame.maxY, keyboard.frame.minY)
        XCTAssertLessThan(cancel.frame.maxY, keyboard.frame.minY)

        cancel.tap()

        XCTAssertTrue(origin.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertFalse(presentation.exists)
        XCTAssertTrue(trigger.isHittable)
        XCTAssertEqual(trigger.value as? String, "Returned from Search")
    }

    func testRepresentativeResultsInspectUnderstandAndSelectedReturn() {
        launch("snc-search-results-dark")

        let query = element("snc-search-query")
        let event = element("snc-result-event.dentist-appointment")
        let movement = element("snc-result-movement.prepare-appointment-questions")
        assertExists([query, event, movement, app.keyboards.firstMatch])

        XCTAssertEqual(query.value as? String, "appointment")
        assertSemanticOrder(
            in: event,
            expected: [
                "Time",
                "Tomorrow · 9:30 AM",
                "Inspect"
            ]
        )
        assertSemanticOrder(
            in: movement,
            expected: [
                "Goals",
                "Current movement",
                "Why it appeared, Related appointment context",
                "Inspect"
            ]
        )
        XCTAssertLessThan(event.frame.minY, movement.frame.minY)

        event.tap()

        let identity = element("snc-inspect-identity")
        let current = element("snc-inspect-current")
        let match = element("snc-inspect-match")
        let understanding = element("snc-inspect-understand")
        assertExists([identity, current, match, understanding, element("snc-search-cancel")])
        assertVerticalOrder([identity, current, match, understanding])
        XCTAssertTrue(app.navigationBars["Details"].exists)
        XCTAssertFalse(app.buttons["Edit"].exists)
        XCTAssertFalse(element("snc-inspect-owner").exists)

        XCTAssertEqual(element("snc-inspect-identity").label, "Object")
        XCTAssertEqual(
            element("snc-inspect-identity").value as? String,
            "Dentist appointment. Event in Time"
        )
        XCTAssertEqual(element("snc-inspect-current").label, "When")
        XCTAssertEqual(
            element("snc-inspect-current").value as? String,
            "Tomorrow · 9:30 AM"
        )
        XCTAssertEqual(element("snc-inspect-match").label, "Why it appeared")
        XCTAssertEqual(
            element("snc-inspect-match").value as? String,
            "The title matches “appointment.”"
        )
        XCTAssertEqual(element("snc-inspect-understand").label, "About this result")
        XCTAssertEqual(
            element("snc-inspect-understand").value as? String,
            "Search can show this event and open it. Time handles any changes."
        )
        assertNoInternalProductTerminology()

        let back = app.navigationBars["Details"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()

        XCTAssertTrue(event.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertTrue((event.value as? String)?.contains("Selected result") == true)
    }

    func testOwnerHandoffPreparationCannotMutateAndCancellationRestoresContext() {
        launch("snc-search-owner-handoff-dark")

        let current = element("snc-handoff-current")
        let requested = element("snc-handoff-requested")
        let consequence = element("snc-handoff-consequence")
        let continueToTime = element("snc-handoff-continue")
        assertExists([
            element("snc-handoff-target"),
            current,
            requested,
            consequence,
            continueToTime,
            element("snc-search-cancel")
        ])
        assertVerticalOrder([
            element("snc-handoff-target"),
            current,
            requested,
            consequence,
            continueToTime
        ])

        XCTAssertTrue(app.navigationBars["Review in Time"].exists)
        XCTAssertEqual(element("snc-handoff-target").label, "Object")
        XCTAssertEqual(
            element("snc-handoff-target").value as? String,
            "Dentist appointment. Event in Time"
        )
        XCTAssertEqual(current.label, "Current time")
        XCTAssertTrue((current.value as? String)?.contains("Tomorrow · 9:30 AM") == true)
        XCTAssertTrue((current.value as? String)?.contains("Nothing has changed") == true)
        XCTAssertEqual(requested.label, "Requested time")
        XCTAssertTrue((requested.value as? String)?.contains("Tomorrow · 11:00 AM") == true)
        XCTAssertTrue((requested.value as? String)?.contains("90 minutes later") == true)
        XCTAssertEqual(consequence.label, "Before anything changes")
        XCTAssertEqual(
            consequence.value as? String,
            "Time will check availability and any calendar effects."
        )
        XCTAssertEqual(continueToTime.label, "Continue to Time")
        XCTAssertFalse(element("snc-handoff-cancel-request").exists)
        assertNoInternalProductTerminology()

        continueToTime.tap()
        XCTAssertTrue((current.value as? String)?.contains("Tomorrow · 9:30 AM") == true)

        let back = app.navigationBars["Review in Time"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()

        let query = element("snc-search-query")
        let review = element("snc-action-query-review")
        assertExists([query, review])
        XCTAssertEqual(query.value as? String, "move the dentist appointment to 11")
        XCTAssertTrue((review.value as? String)?.contains("Event in Time") == true)
        XCTAssertTrue((review.value as? String)?.contains("Current time") == true)
        XCTAssertFalse((review.value as? String)?.contains("Current accepted truth") == true)
        XCTAssertTrue((review.value as? String)?.contains("Tomorrow at 11:00 AM") == true)
    }

    func testNoResultsAndPrivacySuppressionRemainDistinctWithoutIdentityLeakage() {
        launch("snc-search-no-results-dark")

        XCTAssertEqual(element("snc-search-query").value as? String, "ceramics invoice")
        XCTAssertTrue(
            element("snc-search-no-results").waitForExistence(timeout: Self.waitTimeout)
        )
        XCTAssertFalse(element("snc-search-privacy-suppression").exists)

        app.terminate()
        launch("snc-search-privacy-degraded-dark")

        let suppression = element("snc-search-privacy-suppression")
        let visibleResult = element("snc-result-event.dentist-appointment")
        assertExists([suppression, visibleResult])
        XCTAssertEqual(suppression.label, "Some matching local content is hidden.")
        XCTAssertTrue(
            (suppression.value as? String)?.contains("Search cannot show protected matching content") == true
        )
        assertNoAccessibleText(containing: "Family medical follow-up")
        assertNoAccessibleText(containing: "privacy score")
        assertNoAccessibleText(containing: "security grade")
    }

    func testAccessibilityResultsPreserveOrderedStackingAndEssentialActions() {
        launch("snc-search-results-dark")
        let ordinaryEventHeight = element("snc-result-event.dentist-appointment").frame.height

        app.terminate()
        launch("snc-search-results-accessibility-dark")

        let query = element("snc-search-query")
        let cancel = element("snc-search-cancel")
        let resultsRegion = element("snc-search-results-region")
        let event = element("snc-result-event.dentist-appointment")
        let movement = element("snc-result-movement.prepare-appointment-questions")
        let keyboard = app.keyboards.firstMatch
        assertExists([query, cancel, resultsRegion, event, movement, keyboard])
        let initialMovementMaxY = movement.frame.maxY

        XCTAssertEqual(query.value as? String, "appointment")
        XCTAssertGreaterThanOrEqual(event.frame.height, 44)
        XCTAssertGreaterThanOrEqual(movement.frame.height, 44)
        XCTAssertGreaterThan(event.frame.height, ordinaryEventHeight)
        XCTAssertLessThan(event.frame.minY, movement.frame.minY)
        XCTAssertLessThan(query.frame.maxY, keyboard.frame.minY)
        XCTAssertLessThan(cancel.frame.maxY, keyboard.frame.minY)
        XCTAssertLessThanOrEqual(event.frame.maxY, keyboard.frame.minY)
        XCTAssertTrue(event.isHittable)
        assertSemanticOrder(
            in: event,
            expected: [
                "Time",
                "Tomorrow · 9:30 AM",
                "Inspect"
            ]
        )
        assertSemanticOrder(
            in: movement,
            expected: [
                "Goals",
                "Current movement",
                "Why it appeared, Related appointment context",
                "Inspect"
            ]
        )

        let scrollStart = event.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        let scrollEnd = resultsRegion.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.22))
        scrollStart.press(forDuration: 0.05, thenDragTo: scrollEnd)
        XCTAssertTrue(movement.isHittable)
        XCTAssertLessThan(movement.frame.maxY, initialMovementMaxY)
        XCTAssertTrue(cancel.isHittable)
    }

    func testCancelFromEveryRequiredSearchContextReturnsTheOriginFocusTarget() {
        let variants = [
            "snc-search-entry-focused-dark",
            "snc-search-results-dark",
            "snc-search-inspect-understand-dark",
            "snc-search-owner-handoff-dark",
            "snc-search-no-results-dark",
            "snc-search-privacy-degraded-dark"
        ]

        for variant in variants {
            app.terminate()
            launch(variant)

            let cancel = element("snc-search-cancel")
            XCTAssertTrue(
                cancel.waitForExistence(timeout: Self.waitTimeout),
                "Missing Cancel for \(variant)"
            )
            cancel.tap()

            let origin = element("snc-origin-chrome")
            let trigger = element("snc-origin-search-trigger")
            assertExists([origin, trigger])
            XCTAssertTrue(trigger.isHittable, "Search trigger did not regain focus for \(variant)")
            XCTAssertEqual(trigger.value as? String, "Returned from Search")
            XCTAssertFalse(element("snc-search-identity").exists)
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

    private func assertSemanticOrder(
        in element: XCUIElement,
        expected: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let value = element.value as? String else {
            XCTFail("Missing semantic value for \(element)", file: file, line: line)
            return
        }

        var priorIndex = value.startIndex
        for phrase in expected {
            guard let range = value.range(of: phrase, range: priorIndex..<value.endIndex) else {
                XCTFail("Missing ordered phrase \(phrase) in \(value)", file: file, line: line)
                return
            }
            priorIndex = range.upperBound
        }
    }

    private func assertNoAccessibleText(
        containing phrase: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(
            format: "label CONTAINS[c] %@ OR value CONTAINS[c] %@",
            phrase,
            phrase
        )
        XCTAssertEqual(
            app.descendants(matching: .any).matching(predicate).count,
            0,
            "Unexpected accessible content containing \(phrase)",
            file: file,
            line: line
        )
    }

    private func assertNoInternalProductTerminology(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let prohibitedPhrases = [
            "Canonical owner",
            "Current accepted truth",
            "Current truth",
            "Accepted local Event",
            "canonical object",
            "Time-owned Event",
            "Limit",
            "Prepared for Time review",
            "Cancel request",
            "architecture",
            "runtime",
            "fixture",
            "proof",
            "implementation",
            "mutation"
        ]

        for phrase in prohibitedPhrases {
            assertNoAccessibleText(containing: phrase, file: file, line: line)
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
