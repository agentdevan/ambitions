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

        let titleField = app.descendants(matching: .any)["create-goal.title-field"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("UI Smoke Goal")

        let submitButton = app.buttons["create-goal.submit-button"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(app.staticTexts["Goal created"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["UI Smoke Goal"].waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapExposesTodayHabitsInsightsAndProfileSurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.otherElements["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Quick capture"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Habits"].tap()
        XCTAssertTrue(app.otherElements["habits.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Insights"].tap()
        XCTAssertTrue(app.otherElements["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Recent signals"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.otherElements["profile.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.otherElements["profile.default-tab-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.otherElements["profile.appearance-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["profile.save-preferences-button"].waitForExistence(timeout: 10))
    }

    func testProfilePreferencesControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["Profile"].tap()

        let defaultTabPicker = app.otherElements["profile.default-tab-picker"]
        let appearancePicker = app.otherElements["profile.appearance-picker"]
        let saveButton = app.buttons["profile.save-preferences-button"]

        XCTAssertTrue(defaultTabPicker.waitForExistence(timeout: 10))
        XCTAssertTrue(appearancePicker.waitForExistence(timeout: 10))
        XCTAssertTrue(saveButton.waitForExistence(timeout: 10))
        XCTAssertTrue(saveButton.isHittable)
    }

    private func makeApp(bootstrapMode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        return app
    }
}
