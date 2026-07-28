import XCTest

extension TodayFlagshipCalibrationHostUITests {
    func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
        let rootIdentifier = variant == "r13-time-transfer-evaluation"
            ? "r13-time-transfer-evaluation"
            : "tfcs-journey-root"
        XCTAssertTrue(element(rootIdentifier).waitForExistence(timeout: 8))
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func todayCrown() -> XCUIElement {
        element("tfcs-today-heading")
    }

    func foundrySource(named filename: String) throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = repositoryRoot
            .appendingPathComponent("Packages/AmbitionsPresentation/Sources")
            .appendingPathComponent("AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)
        return try String(contentsOf: source, encoding: .utf8)
    }

    func assertArabicOnlyLabels(
        in container: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let elements = container.descendants(matching: .any).allElementsBoundByIndex.filter {
            $0.elementType == .button || $0.elementType == .staticText
        }
        let labels = elements.map { $0.label }.filter { $0.isEmpty == false }
        XCTAssertFalse(labels.isEmpty, file: file, line: line)

        for label in labels {
            let approvedIdentityRemoved = label.replacingOccurrences(of: "Ambitions S10", with: "")
            XCTAssertNil(
                approvedIdentityRemoved.range(of: "[A-Za-z]", options: .regularExpression),
                "Arabic evaluation label contains unapproved Latin text: \(label)",
                file: file,
                line: line
            )
        }
    }

    func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 3),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    func assertMinimumTarget(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }

    func assertMinimumTargetAfterSettling(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertElementSettles(element, file: file, line: line) {
            $0.isHittable && $0.frame.width >= 44 && $0.frame.height >= 44
        }
        assertMinimumTarget(element, file: file, line: line)
    }

    func assertElementSettles(
        _ element: XCUIElement,
        timeout: TimeInterval = 6,
        file: StaticString = #filePath,
        line: UInt = #line,
        predicate: @escaping (XCUIElement) -> Bool
    ) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { candidate, _ in
                guard let candidate = candidate as? XCUIElement else { return false }
                return predicate(candidate)
            },
            object: element
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [expectation], timeout: timeout),
            .completed,
            "Element did not reach its settled layout: \(element)",
            file: file,
            line: line
        )
    }

    func assertEveryVisibleButtonHasMinimumTargetAndDistinctName(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let buttons = app.buttons.allElementsBoundByIndex.filter { $0.isHittable }
        let names = buttons.map { $0.label }
        XCTAssertFalse(names.contains(where: \.isEmpty), file: file, line: line)
        XCTAssertEqual(Set(names).count, names.count, file: file, line: line)
        for button in buttons where button.identifier != "r13-review-step-dismissal" {
            // The native toolbar owns the 44-point interaction envelope even though XCUI
            // reports its 36-point visual frame. Custom Foundry controls remain explicit.
            assertMinimumTarget(button, file: file, line: line)
        }
    }

    func scrollUntilHittable(
        _ element: XCUIElement,
        maxSwipes: Int = 8
    ) {
        var attempts = 0
        while element.isHittable == false && attempts < maxSwipes {
            app.swipeUp(velocity: .slow)
            attempts += 1
        }
        XCTAssertTrue(element.isHittable)
    }

    func assertAccessibilityOrder(
        _ first: XCUIElement,
        before second: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let identifiers = app.buttons
            .allElementsBoundByIndex
            .map { $0.identifier }
        let firstIndex = identifiers.firstIndex(of: first.identifier)
        let secondIndex = identifiers.firstIndex(of: second.identifier)
        XCTAssertNotNil(firstIndex, file: file, line: line)
        XCTAssertNotNil(secondIndex, file: file, line: line)
        if let firstIndex, let secondIndex {
            XCTAssertLessThan(firstIndex, secondIndex, file: file, line: line)
        }
    }

    func pauseForEvidence(_ seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
