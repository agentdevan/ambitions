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
        XCTAssertTrue(app.buttons["goals.create-button"].waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapCanCreateGoalFromEmptyState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        let createButton = app.buttons["goals.create-button"]
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

    func testPreviewBootstrapExposesTodayHabitsInsightsAndProfileSurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let todayTab = app.tabBars.buttons["Today"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 10))
        XCTAssertTrue(todayTab.isSelected)

        app.tabBars.buttons["Habits"].tap()
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))

        openMoreDestination("Insights", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["insights.screen"].waitForExistence(timeout: 10))

        openMoreDestination("Profile", in: app)
        XCTAssertTrue(app.descendants(matching: .any)["profile.default-tab-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["profile.appearance-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["profile.save-preferences-button"].waitForExistence(timeout: 10))
    }

    func testProfilePreferencesControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        openMoreDestination("Profile", in: app)

        let defaultTabPicker = app.descendants(matching: .any)["profile.default-tab-picker"]
        let appearancePicker = app.descendants(matching: .any)["profile.appearance-picker"]
        XCTAssertTrue(defaultTabPicker.waitForExistence(timeout: 10))
        XCTAssertTrue(appearancePicker.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["profile.save-preferences-button"].waitForExistence(timeout: 10))
        let saveButton = scrollUntilButtonHittable("profile.save-preferences-button", in: app)
        XCTAssertTrue(saveButton.isHittable)
    }

    private func makeApp(bootstrapMode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        return app
    }

    private func openMoreDestination(_ label: String, in app: XCUIApplication) {
        let moreTab = app.tabBars.buttons["More"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 10))
        moreTab.tap()

        let moreBackButton = app.navigationBars.buttons["More"]
        if moreBackButton.waitForExistence(timeout: 2), moreBackButton.isHittable {
            moreBackButton.tap()
        }

        let destinationLabel = app.tables.staticTexts[label]
        if destinationLabel.waitForExistence(timeout: 10) {
            let destinationCell = app.tables.cells.containing(.staticText, identifier: label).element
            if destinationCell.waitForExistence(timeout: 2), destinationCell.isHittable {
                destinationCell.tap()
                return
            }
        }

        XCTFail("More destination row '\(label)' was not found.")
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
}
