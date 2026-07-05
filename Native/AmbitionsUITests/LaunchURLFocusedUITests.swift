import XCTest

@MainActor
final class LaunchURLFocusedUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchURLCanLandOnCanonicalTimeSurface() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/time")
        app.launch()

        XCTAssertTrue(waitForRootDestination("Time", in: app, timeout: 10))
        XCTAssertTrue(waitForSelectedSurface("Time", in: app, timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 10))
    }

    private func makeApp(
        bootstrapMode: String,
        launchURL: String,
        contentSizeCategory: String = "UICTContentSizeCategoryM"
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = launchURL
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", bootstrapMode]
        app.launchArguments += ["-AMBITIONS_LAUNCH_URL", launchURL]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        return app
    }

    private func waitForSelectedSurface(
        _ title: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 30
    ) -> Bool {
        let button = rootDestinationButton(title, in: app)
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if button.waitForExistence(timeout: 1), button.isSelected || button.value as? String == "Selected" {
                return true
            }
        }

        return button.exists && (button.isSelected || button.value as? String == "Selected")
    }

    private func rootDestinationButton(_ title: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)["shell.meridian.destination.\(title.lowercased())"]
    }

    private func waitForRootDestination(
        _ title: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 10
    ) -> Bool {
        rootDestinationButton(title, in: app).waitForExistence(timeout: timeout)
    }
}
