import XCTest

@MainActor
extension AmbitionsUITestCase {
    func scrollYouContentToVisible(identifier: String, in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["you.scroll"]
        let target = app.descendants(matching: .any)[identifier]
        let safeBand = CGRect(x: 0, y: 118, width: 1_000, height: 572)

        for _ in 0..<14 {
            if target.exists, target.frame.intersects(safeBand), target.frame.minY < 690 {
                return true
            }

            if scrollView.waitForExistence(timeout: 1) {
                scrollView.swipeUp()
            } else {
                app.swipeUp()
            }
        }

        return target.exists && target.frame.intersects(safeBand)
    }

    func youRow(named title: String, in app: XCUIApplication) -> XCUIElement {
        let identifier = youRowIdentifier(for: title)
        let settingsButton = app.buttons["you.settings.row.\(identifier)"]
        if settingsButton.exists {
            return settingsButton
        }

        let settingsAny = app.descendants(matching: .any)["you.settings.row.\(identifier)"]
        if settingsAny.exists {
            if settingsAny.elementType == .button {
                return settingsAny
            }

            if settingsAny.buttons.firstMatch.exists {
                return settingsAny.buttons.firstMatch
            }
        }

        let stableButton = app.buttons["you.row.\(identifier)"]
        if stableButton.exists {
            return stableButton
        }

        let stableAny = app.descendants(matching: .any)["you.row.\(identifier)"]
        if stableAny.exists {
            if stableAny.elementType == .button {
                return stableAny
            }

            if stableAny.buttons.firstMatch.exists {
                return stableAny.buttons.firstMatch
            }
        }

        let textMatch = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", title)).firstMatch
        if textMatch.elementType == .button {
            return textMatch
        }

        if textMatch.buttons.firstMatch.exists {
            return textMatch.buttons.firstMatch
        }

        return textMatch
    }

    func youRowIdentifier(for title: String) -> String {
        title
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    func scrollUntilYouRowExists(named title: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        for _ in 0..<maxAttempts {
            let row = youRow(named: title, in: app)
            if row.waitForExistence(timeout: 2), row.isHittable {
                return true
            }
            app.swipeUp()
        }

        let row = youRow(named: title, in: app)
        return row.exists && row.isHittable
    }

    func tapYouRow(named title: String, in app: XCUIApplication, maxAttempts: Int = 10) -> Bool {
        for _ in 0..<maxAttempts {
            let row = youRow(named: title, in: app)
            if row.waitForExistence(timeout: 2) {
                if row.isHittable {
                    row.tap()
                    return true
                } else {
                    app.swipeUp()
                }
            } else {
                app.swipeUp()
            }
        }

        return false
    }
}
