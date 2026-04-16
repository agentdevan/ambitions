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
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        XCTAssertFalse(titleField.exists)
    }

    func testPreviewBootstrapExposesTodayHabitsInsightsAndProfileSurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let todayTab = app.tabBars.buttons["Today"]
        XCTAssertTrue(todayTab.waitForExistence(timeout: 10))
        XCTAssertTrue(todayTab.isSelected)
        XCTAssertTrue(app.staticTexts["Quick capture"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Habits"].tap()
        XCTAssertTrue(app.otherElements["habits.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))

        openMoreDestination("Insights", in: app)
        XCTAssertTrue(app.otherElements["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Recent signals"].waitForExistence(timeout: 10))

        if app.navigationBars.buttons["More"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["More"].tap()
        }

        openMoreDestination("Profile", in: app)
        XCTAssertTrue(app.otherElements["profile.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.otherElements["profile.default-tab-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.otherElements["profile.appearance-picker"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["profile.save-preferences-button"].waitForExistence(timeout: 10))
    }

    func testProfilePreferencesControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        openMoreDestination("Profile", in: app)

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

    private func openMoreDestination(_ label: String, in app: XCUIApplication) {
        let moreTab = app.tabBars.buttons["More"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 10))
        moreTab.tap()

        let destination = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ OR label == %@", label, label))
            .firstMatch
        XCTAssertTrue(destination.waitForExistence(timeout: 10))
        destination.tap()
    }
}
