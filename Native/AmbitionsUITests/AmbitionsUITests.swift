import XCTest

final class AmbitionsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPreviewBootstrapShowsEmptyGoalsState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.staticTexts["No goals yet"].waitForExistence(timeout: 10))
        XCTAssertTrue(goalCreateButton(in: app).waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapCanCreateGoalFromEmptyState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        let createButton = goalCreateButton(in: app)
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let titleField = app.textFields["create-goal.title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("UI Smoke Goal")
        dismissKeyboardIfNeeded(in: app)

        let submitButton = scrollUntilButtonHittable("create-goal.submit-button", in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30))
        XCTAssertTrue(titleField.waitForNonExistence(timeout: 10))
    }

    func testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        for tab in ["Today", "Goals", "Plan", "Insights", "Profile"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: 10), "Missing top-level tab \(tab)")
        }
        XCTAssertFalse(app.tabBars.buttons["More"].exists)
        XCTAssertFalse(app.tabBars.buttons["Captures"].exists)
        XCTAssertFalse(app.tabBars.buttons["Habits"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)

        app.buttons["today.open-captures-button"].tap()
        XCTAssertTrue(app.staticTexts["No captures yet"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Plan"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["plan.weekly-intent-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.goal-shaping-card", in: app))
        app.buttons["plan.open-habits-button"].tap()
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Insights"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.posture-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.change-card"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(scrollUntilElementExists("profile.personalization-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.planning-summary-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
    }

    func testProfilePreferencesControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(scrollUntilElementExists("profile.personalization-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.planning-summary-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
    }

    func testProfileTrustSurfaceShowsConservativeExternalStatusLabels() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["Profile"].tap()

        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Trust and external status", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Notifications", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Navigation shortcuts", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Share Extension", in: app))
        XCTAssertTrue(scrollUntilButtonExists("Enable notifications", in: app))
    }

    func testLaunchURLCanLandOnCanonicalPlanSurface() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testLaunchURLCanLandOnTodayOwnedCapturesInbox() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
    }

    private func makeApp(bootstrapMode: String, launchURL: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        if let launchURL {
            app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = launchURL
        }
        return app
    }

    private func dismissKeyboardIfNeeded(in app: XCUIApplication) {
        let keyboard = app.keyboards.element
        guard keyboard.exists else { return }

        let dismissButtons = [
            keyboard.buttons["Return"],
            keyboard.buttons["Done"],
            keyboard.buttons["Hide keyboard"],
            app.toolbars.buttons["Done"]
        ]

        if let button = dismissButtons.first(where: { $0.waitForExistence(timeout: 1) && $0.isHittable }) {
            button.tap()
            return
        }

        app.swipeUp()
    }

    private func goalCreateButton(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["goals.create-button"],
            app.navigationBars.buttons["goals.create-button"],
            app.buttons["Create Goal"],
            app.navigationBars.buttons["Create Goal"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons["goals.create-button"]
    }

    private func scrollUntilButtonHittable(_ identifier: String, in app: XCUIApplication, maxAttempts: Int = 5) -> XCUIElement {
        let button = app.buttons[identifier]

        for _ in 0..<maxAttempts {
            if button.waitForExistence(timeout: 2), button.isHittable {
                return button
            }
            app.swipeUp()
        }

        for _ in 0..<maxAttempts {
            if button.isHittable {
                return button
            }
            app.swipeDown()
        }

        for _ in 0..<maxAttempts {
            let button = app.buttons[identifier]
            if button.isHittable {
                return button
            }
            app.swipeUp()
        }

        return button
    }

    private func scrollUntilElementExists(_ identifier: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    private func scrollUntilStaticTextExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.staticTexts[label]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    private func scrollUntilButtonExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.buttons[label]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

}
