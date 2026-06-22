import XCTest

@MainActor
final class VisualTargetAttachmentUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimeVisualReviewRunAttachesActualScreenshot() throws {
        let app = AmbitionsVisualAcceptanceApp.launchTime()
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-object"].waitForExistence(timeout: 15))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "time-lifeshape-field-actual-for-target-review"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

enum AmbitionsVisualAcceptanceApp {
    @MainActor
    static func launchTime(contentSizeCategory: String = "UICTContentSizeCategoryM") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = "preview"
        app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = "ambitions://tab/time"
        app.launchEnvironment["AmbitionsScreenshotMode"] = "YES"
        app.launchEnvironment["AmbitionsTimeRenderState"] = "manual-only"
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", "preview"]
        app.launchArguments += ["-AMBITIONS_LAUNCH_URL", "ambitions://tab/time"]
        app.launchArguments += ["-AmbitionsScreenshotMode", "YES"]
        app.launchArguments += ["-AmbitionsTimeRenderState", "manual-only"]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        app.launch()
        return app
    }
}
