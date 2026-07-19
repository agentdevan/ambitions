import XCTest

@MainActor
extension AmbitionsUITestCase {
    func scrollUntilButtonHittable(_ identifier: String, fallbackLabel: String? = nil, in app: XCUIApplication, maxAttempts: Int = 8) -> XCUIElement {
        let fallbackButton = fallbackLabel.map {
            app.buttons.matching(NSPredicate(format: "label == %@", $0)).firstMatch
        }
        let fallbackAny = fallbackLabel.map {
            app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", $0)).firstMatch
        }

        func candidates() -> [XCUIElement] {
            var results: [XCUIElement] = [
                app.buttons[identifier],
                app.descendants(matching: .any)[identifier]
            ]

            if let fallbackButton {
                results.append(fallbackButton)
            }
            if let fallbackAny {
                results.append(fallbackAny)
            }

            return results
        }

        for _ in 0..<maxAttempts {
            for candidate in candidates() where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
                return candidate
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            for candidate in candidates() where candidate.isHittable {
                return candidate
            }
            scrollPageDown(in: app)
        }

        if let fallbackAny, fallbackAny.exists {
            return fallbackAny
        }

        return app.descendants(matching: .any)[identifier]
    }

    func scrollUntilElementExists(identifier: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    func scrollUntilElementExists(_ identifier: String, in app: XCUIApplication, maxAttempts: Int = 8) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.exists || element.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            if element.exists || element.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageDown(in: app)
        }

        return element.exists
    }

    func scrollUntilStaticTextExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let exactStaticText = app.staticTexts[label]
        let exactButton = app.buttons[label]
        let matchingStaticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch
        let matchingButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch

        for _ in 0..<maxAttempts {
            if exactStaticText.exists || exactStaticText.waitForExistence(timeout: 0.25) ||
                exactButton.exists || exactButton.waitForExistence(timeout: 0.25) ||
                matchingStaticText.exists || matchingStaticText.waitForExistence(timeout: 0.25) ||
                matchingButton.exists || matchingButton.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            if exactStaticText.exists || exactStaticText.waitForExistence(timeout: 0.25) ||
                exactButton.exists || exactButton.waitForExistence(timeout: 0.25) ||
                matchingStaticText.exists || matchingStaticText.waitForExistence(timeout: 0.25) ||
                matchingButton.exists || matchingButton.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageDown(in: app)
        }

        return exactStaticText.exists || exactButton.exists || matchingStaticText.exists || matchingButton.exists
    }

    func scrollUntilButtonExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.buttons[label]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    func scrollPageUp(in app: XCUIApplication) {
        app.swipeUp(velocity: .fast)
    }

    func scrollPageDown(in app: XCUIApplication) {
        app.swipeDown(velocity: .fast)
    }
}
