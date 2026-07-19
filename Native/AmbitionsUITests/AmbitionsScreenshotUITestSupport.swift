import XCTest

@MainActor
extension AmbitionsUITestCase {
    func captureShellScreenshot(named tabName: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "afri-005-shell-\(tabName)"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(waitForShellReady(in: app, timeout: 5))
    }

    func captureTodayScreenshot(named name: String, in app: XCUIApplication) {
        XCTAssertTrue(todayRealityMeridianAnchorExists(in: app))
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func captureGoalsScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].exists)
    }

    func captureGoalsRouteScreenshot(named name: String, routeIdentifier: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)[routeIdentifier].exists)
    }

    func captureTimeScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].exists)
    }

    func captureYouScreenshot(named name: String, in app: XCUIApplication) {
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func captureAMB967Screenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(
            app.descendants(matching: .any)["shell.activated-capture-seam"].exists
                || app.descendants(matching: .any)["create-goal.hero-card"].exists
                || app.staticTexts["Shape the first path"].exists
        )
    }

    func waitForScreenshotCopy(_ label: String, in app: XCUIApplication, timeout: TimeInterval = 3) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if screenshotCopyExists(label, in: app) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return screenshotCopyExists(label, in: app)
    }

    func screenshotCopyExists(_ label: String, in app: XCUIApplication) -> Bool {
        let exactStaticText = app.staticTexts[label]
        let exactButton = app.buttons[label]
        let matchingStaticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch
        let matchingButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch
        return exactStaticText.exists || exactButton.exists || matchingStaticText.exists || matchingButton.exists
    }
}
