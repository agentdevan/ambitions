import XCTest

@MainActor
final class DeterministicScreenshotLaneUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAMB1815TimeRootLightMScreenshotLane() throws {
        let lane = DeterministicScreenshotLane.timeRootLightM
        let app = lane.launchApplication()

        XCTAssertTrue(
            app.descendants(matching: .any)[lane.requiredElementIdentifier].waitForExistence(timeout: 30),
            "\(lane.requiredElementIdentifier) must exist before screenshot capture."
        )

        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = lane.screenshotAttachmentName
        screenshot.lifetime = .keepAlways
        add(screenshot)

        let metadata = XCTAttachment(string: lane.metadataJSON)
        metadata.name = lane.metadataAttachmentName
        metadata.lifetime = .keepAlways
        add(metadata)
    }
}

private struct DeterministicScreenshotLane {
    let id: String
    let surface: String
    let appearance: String
    let contentSizeCategory: String
    let launchURL: String
    let initialSurface: String
    let requiredElementIdentifier: String
    let screenshotAttachmentName: String
    let metadataAttachmentName: String
    let proofScope: String

    static let timeRootLightM = DeterministicScreenshotLane(
        id: "amb-1815-time-root-light-m",
        surface: "Time",
        appearance: "light",
        contentSizeCategory: "UICTContentSizeCategoryM",
        launchURL: "ambitions://tab/time",
        initialSurface: "time",
        requiredElementIdentifier: "time.life-shape-field",
        screenshotAttachmentName: "amb-1815-time-root-light-m-screenshot",
        metadataAttachmentName: "amb-1815-time-root-light-m-metadata",
        proofScope: "deterministic simulator screenshot lane; not Visual Green"
    )

    @MainActor
    func launchApplication() -> XCUIApplication {
        let app = XCUIApplication()
        let keyValues = [
            "AMBITIONS_BOOTSTRAP_MODE": "preview",
            "AMBITIONS_LAUNCH_URL": launchURL,
            "AmbitionsInitialSurface": initialSurface,
            "AmbitionsScreenshotMode": "YES",
            "AmbitionsTimeRenderState": "manual-only",
            "UIPreferredContentSizeCategoryName": contentSizeCategory,
            "uiuserinterfacestyle": appearance,
            "AppleLocale": "en_US",
            "AppleLanguages": "(en)",
        ]

        for keyValue in keyValues.sorted(by: { $0.key < $1.key }) {
            app.launchEnvironment[keyValue.key] = keyValue.value
            app.launchArguments += ["-\(keyValue.key)", keyValue.value]
        }

        app.launch()
        dismissTransientReceiptIfPresent(in: app)
        return app
    }

    var metadataJSON: String {
        """
        {
          "lane_id": "\(id)",
          "surface": "\(surface)",
          "appearance": "\(appearance)",
          "content_size_category": "\(contentSizeCategory)",
          "launch_url": "\(launchURL)",
          "required_element_identifier": "\(requiredElementIdentifier)",
          "screenshot_attachment_name": "\(screenshotAttachmentName)",
          "proof_scope": "\(proofScope)"
        }
        """
    }

    @MainActor
    private func dismissTransientReceiptIfPresent(in app: XCUIApplication) {
        let receiptDismiss = app.descendants(matching: .any)["action-closure-tray.dismiss-button"]
        if receiptDismiss.waitForExistence(timeout: 3) {
            receiptDismiss.tap()
        }
    }
}
