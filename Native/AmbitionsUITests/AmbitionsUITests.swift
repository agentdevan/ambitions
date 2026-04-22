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
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Plan"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.open-captures-button"].tap()
        XCTAssertTrue(app.staticTexts["No captures yet"].waitForExistence(timeout: 10))

        app.buttons["shell.plan.back-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["plan.weekly-intent-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.goal-shaping-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.open-plan-habits-button", in: app))
        app.buttons["plan.open-plan-habits-button"].tap()
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.back-button"].tap()

        app.tabBars.buttons["Insights"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.posture-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.change-card"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
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

    func testLaunchURLCanLandOnPlanOwnedCapturesInbox() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetCanOpenAndNavigateToPlan() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let commandButton = app.buttons["shell.global-entry-button"]
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        XCTAssertTrue(app.buttons["shell.command.action.open_week"].waitForExistence(timeout: 10))
        app.buttons["shell.command.action.open_week"].tap()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetSupportsQuickCaptureFlow() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let commandButton = app.buttons["shell.global-entry-button"]
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let quickCapture = app.buttons["shell.command.action.quick_capture"]
        XCTAssertTrue(quickCapture.waitForExistence(timeout: 10))
        quickCapture.tap()

        let field = app.textFields["shell.command.capture-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("UI shell capture")
        dismissKeyboardIfNeeded(in: app)

        let submit = app.buttons["shell.command.submit-capture-button"]
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        submit.tap()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.staticTexts["UI shell capture"].waitForExistence(timeout: 10))
    }

    func testShellOwnedCreateGoalFlowWorksFromCommandSheet() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let commandButton = app.buttons["shell.global-entry-button"]
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let createAction = app.buttons["shell.command.action.new_goal"]
        XCTAssertTrue(createAction.waitForExistence(timeout: 10))
        createAction.tap()

        let titleField = app.textFields["create-goal.title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("Shell Goal")
        dismissKeyboardIfNeeded(in: app)

        let submitButton = scrollUntilButtonHittable("create-goal.submit-button", in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Goals"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30))
    }

    func testMemoryLensCanOpenAndRouteToCanonicalWeekDestination() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let memoryButton = app.buttons["shell.today.memory-lens-button"]
        XCTAssertTrue(memoryButton.waitForExistence(timeout: 10))
        memoryButton.tap()

        let searchField = app.textFields["shell.memory-lens.search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))

        let result = app.buttons["shell.memory-lens.result.memory-week"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
        result.tap()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
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
            app.buttons["shell.goals.create-button"],
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
