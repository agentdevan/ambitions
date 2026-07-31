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
                "Owner, Time",
                "Current truth, Tomorrow · 9:30 AM",
                "Action, Inspect"
            ]
        )
        assertSemanticOrder(
            in: movement,
            expected: [
                "Owner, Goals",
                "Current truth, Current movement",
                "Match reason, Related appointment context",
                "Action, Inspect"
            ]
        )
        XCTAssertLessThan(event.frame.minY, movement.frame.minY)

        event.tap()

        assertExists([
            element("snc-inspect-identity"),
            element("snc-inspect-owner"),
            element("snc-inspect-current"),
            element("snc-inspect-match"),
            element("snc-inspect-understand")
        ])
        XCTAssertTrue(app.navigationBars["Inspect"].exists)
        XCTAssertFalse(app.buttons["Edit"].exists)

        let back = app.navigationBars["Inspect"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()

        XCTAssertTrue(event.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertTrue((event.value as? String)?.contains("Selected result") == true)
    }

    func testOwnerHandoffPreparationCannotMutateAndCancellationRestoresContext() {
        launch("snc-search-owner-handoff-dark")

        let current = element("snc-handoff-current")
        let requested = element("snc-handoff-requested")
        let limit = element("snc-handoff-limit")
        let continueInTime = element("snc-handoff-continue")
        let cancelRequest = element("snc-handoff-cancel-request")
        assertExists([current, requested, limit, continueInTime, cancelRequest])

        XCTAssertTrue((current.value as? String)?.contains("Tomorrow · 9:30 AM") == true)
        XCTAssertTrue((current.value as? String)?.contains("remains unchanged") == true)
        XCTAssertTrue((requested.value as? String)?.contains("Tomorrow · 11:00 AM") == true)
        XCTAssertTrue((limit.value as? String)?.contains("Time must review") == true)

        continueInTime.tap()
        let prepared = element("snc-handoff-prepared-status")
        XCTAssertTrue(prepared.waitForExistence(timeout: Self.waitTimeout))
        XCTAssertEqual(prepared.label, "Prepared for Time. Nothing changed.")
        XCTAssertTrue((current.value as? String)?.contains("Tomorrow · 9:30 AM") == true)

        cancelRequest.tap()

        let query = element("snc-search-query")
        let review = element("snc-action-query-review")
        assertExists([query, review])
        XCTAssertEqual(query.value as? String, "move the dentist appointment to 11")
        XCTAssertTrue((review.value as? String)?.contains("Current accepted truth") == true)
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
        let event = element("snc-result-event.dentist-appointment")
        let movement = element("snc-result-movement.prepare-appointment-questions")
        assertExists([query, cancel, event, movement, app.keyboards.firstMatch])

        XCTAssertEqual(query.value as? String, "appointment")
        XCTAssertGreaterThanOrEqual(event.frame.height, 44)
        XCTAssertGreaterThanOrEqual(movement.frame.height, 44)
        XCTAssertGreaterThan(event.frame.height, ordinaryEventHeight)
        XCTAssertLessThan(event.frame.minY, movement.frame.minY)
        assertSemanticOrder(
            in: event,
            expected: [
                "Owner, Time",
                "Current truth, Tomorrow · 9:30 AM",
                "Action, Inspect"
            ]
        )
        assertSemanticOrder(
            in: movement,
            expected: [
                "Owner, Goals",
                "Current truth, Current movement",
                "Match reason, Related appointment context",
                "Action, Inspect"
            ]
        )
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
}
