import XCTest

@MainActor
class AmbitionsUITestCase: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func makeApp(
        bootstrapMode: String,
        launchURL: String? = nil,
        extraEnvironment: [String: String] = [:],
        contentSizeCategory: String = "UICTContentSizeCategoryM"
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", bootstrapMode]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        if let launchURL {
            app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = launchURL
            app.launchArguments += ["-AMBITIONS_LAUNCH_URL", launchURL]
        }
        for (key, value) in extraEnvironment {
            app.launchEnvironment[key] = value
            app.launchArguments += ["-\(key)", value]
        }
        return app
    }

    func accessibilityText(for element: XCUIElement) -> String {
        var parts = [element.label]
        if let value = element.value as? String {
            parts.append(value)
        }
        if let placeholderValue = element.placeholderValue, placeholderValue.isEmpty == false {
            parts.append(placeholderValue)
        }
        return parts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
    }

    func dismissKeyboardIfNeeded(in app: XCUIApplication) {
        let keyboard = app.keyboards.element
        guard keyboard.exists else { return }

        let dismissButtons = [
            app.buttons["capture.keyboard.done"],
            app.toolbars.buttons["Done"],
            keyboard.buttons["Return"],
            keyboard.buttons["Done"],
            keyboard.buttons["Hide keyboard"]
        ]

        if let button = dismissButtons.first(where: { $0.waitForExistence(timeout: 1) && $0.isHittable }) {
            button.tap()
            _ = keyboard.waitForNonExistence(timeout: 5)
            return
        }

        app.swipeUp()
        _ = keyboard.waitForNonExistence(timeout: 5)
    }

    func tapFirstHittableButton(identifier: String? = nil, named label: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let controls: [XCUIElement]
            if let identifier {
                controls = app.descendants(matching: .any).matching(identifier: identifier).allElementsBoundByIndex
                    + app.buttons.matching(identifier: identifier).allElementsBoundByIndex
                    + app.buttons.matching(NSPredicate(format: "label == %@", label)).allElementsBoundByIndex
            } else {
                controls = app.buttons.matching(NSPredicate(format: "label == %@", label)).allElementsBoundByIndex
            }
            if let control = controls.first(where: { $0.waitForExistence(timeout: 1) && $0.isEnabled && $0.isHittable }) {
                control.tap()
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find hittable button named \(label).")
    }

    func assertFrame(_ frame: CGRect, isInside container: CGRect, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(frame.minX, container.minX, "\(name) extends past the leading safe boundary.", file: file, line: line)
        XCTAssertGreaterThanOrEqual(frame.minY, container.minY, "\(name) extends above the top safe boundary.", file: file, line: line)
        XCTAssertLessThanOrEqual(frame.maxX, container.maxX, "\(name) extends past the trailing safe boundary.", file: file, line: line)
        XCTAssertLessThanOrEqual(frame.maxY, container.maxY, "\(name) extends below the bottom safe boundary.", file: file, line: line)
    }

    func tapIfPossible(_ element: XCUIElement) {
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    func waitForContinuityReceiptToDisappear(_ receipt: XCUIElement) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: receipt
        )
        _ = XCTWaiter.wait(for: [expectation], timeout: 2)
    }
}
