import XCTest

@MainActor
extension AmbitionsUITestCase {
    func shellCommandButton(in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons["shell.global-entry-button"]
        if identified.waitForExistence(timeout: 2) {
            return identified
        }
        let currentLabel = app.buttons["Capture"]
        if currentLabel.waitForExistence(timeout: 2) {
            return currentLabel
        }
        let labeled = app.buttons["Quick action Sheet"]
        _ = labeled.waitForExistence(timeout: 2)
        return labeled
    }

    func openCanonicalDestination(_ title: String, screenIdentifier: String, in app: XCUIApplication, timeout: TimeInterval = 20) -> Bool {
        let screen = app.descendants(matching: .any)[screenIdentifier]
        if screen.waitForExistence(timeout: 1) {
            return true
        }

        guard tapCanonicalDestination(title, in: app) else {
            return false
        }

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if screen.waitForExistence(timeout: 1) {
                return true
            }
        }

        if title != "Today", tapCanonicalDestination("Today", in: app), tapCanonicalDestination(title, in: app) {
            let retryDeadline = Date().addingTimeInterval(timeout)
            while Date() < retryDeadline {
                if screen.waitForExistence(timeout: 1) {
                    return true
                }
            }
        }

        return screen.exists
    }

    func screenIdentifier(forTab title: String) -> String {
        switch title {
        case "Today": "today.screen"
        case "Goals": "goals.screen"
        case "Time": "time.screen"
        case "You": "you.screen"
        default: "\(title.lowercased()).screen"
        }
    }

    func tapCanonicalDestination(_ title: String, in app: XCUIApplication) -> Bool {
        let dockButton = rootDestinationButton(title, in: app)
        if dockButton.waitForExistence(timeout: 5) {
            if dockButton.isHittable {
                dockButton.tap()
            } else {
                dockButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }

        let labeledDockButton = app.buttons[title]
        if labeledDockButton.waitForExistence(timeout: 2) {
            if labeledDockButton.isHittable {
                labeledDockButton.tap()
            } else {
                labeledDockButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }

        let meridianButton = app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
        guard meridianButton.waitForExistence(timeout: 5) else {
            return false
        }
        meridianButton.tap()
        return true
    }

    func assertShellFloatingButtonDoesNotCoverRootDock(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let dockFrame = rootDockFrame(in: app)
        let button = shellCommandButton(in: app)
        XCTAssertFalse(dockFrame.isNull, file: file, line: line)
        XCTAssertTrue(button.waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertFalse(dockFrame.intersects(button.frame), "Global add button overlaps the root Stage dock.", file: file, line: line)
    }

    func waitForShellReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let stageHost = app.descendants(matching: .any)["shell.stage.host"]
        let overlayForegrounds = [
            app.descendants(matching: .any)["shell.activated-capture-seam"],
            app.descendants(matching: .any)["create-goal.hero-card"],
            app.descendants(matching: .any)["shell.command.sheet"]
        ]

        while Date() < deadline {
            let hasStage = stageHost.waitForExistence(timeout: 1)
            let hasDock = ["Today", "Goals", "Time", "You"].allSatisfy { rootDestinationButton($0, in: app).exists }
            let hasOverlay = overlayForegrounds.contains { $0.exists }
            if hasDock || hasOverlay || hasStage {
                return true
            }
        }

        return stageHost.exists
            || ["Today", "Goals", "Time", "You"].allSatisfy { rootDestinationButton($0, in: app).exists }
            || overlayForegrounds.contains { $0.exists }
    }

    func waitForSelectedTab(_ title: String, in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        waitForSelectedSurface(title, in: app, timeout: timeout)
    }

    func waitForSelectedSurface(_ title: String, in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let button = rootDestinationButton(title, in: app)
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if button.waitForExistence(timeout: 1), button.isSelected || button.value as? String == "Selected" {
                return true
            }
        }

        return button.exists && (button.isSelected || button.value as? String == "Selected")
    }

    func rootDestinationButton(_ title: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["shell.meridian.destination.\(title.lowercased())"]
    }

    func waitForRootDestination(_ title: String, in app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        rootDestinationButton(title, in: app).waitForExistence(timeout: timeout)
    }

    func rootDestinationExists(_ title: String, in app: XCUIApplication) -> Bool {
        let identifier = "shell.meridian.destination.\(title.lowercased())"
        return app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", identifier))
            .count > 0
    }

    func rootDockFrame(in app: XCUIApplication) -> CGRect {
        var frame = CGRect.null
        for title in ["Today", "Goals", "Time", "You"] {
            let button = rootDestinationButton(title, in: app)
            if button.waitForExistence(timeout: 1) {
                frame = frame.isNull ? button.frame : frame.union(button.frame)
            }
        }
        return frame
    }

    func dismissContinuityReceiptIfPresent(in app: XCUIApplication, timeout: TimeInterval = 4) {
        let receipt = app.descendants(matching: .any)["shell.continuity-receipt"]
        guard receipt.waitForExistence(timeout: timeout) else { return }

        let shellDismissButton = app.buttons["action-closure-tray.dismiss-button"]
        if shellDismissButton.waitForExistence(timeout: 0.5) {
            tapIfPossible(shellDismissButton)
            waitForContinuityReceiptToDisappear(receipt)
            return
        }

        let identifiedButton = app.buttons["trust.receipt-toast.dismiss-button"]
        if identifiedButton.waitForExistence(timeout: 0.5) {
            tapIfPossible(identifiedButton)
            waitForContinuityReceiptToDisappear(receipt)
            return
        }

        let shellLabeledButton = app.buttons["Dismiss result"]
        if shellLabeledButton.waitForExistence(timeout: 0.5) {
            tapIfPossible(shellLabeledButton)
            waitForContinuityReceiptToDisappear(receipt)
            return
        }

        let labeledButton = app.buttons["Dismiss receipt"]
        if labeledButton.waitForExistence(timeout: 0.5) {
            tapIfPossible(labeledButton)
            waitForContinuityReceiptToDisappear(receipt)
        }
    }
}
