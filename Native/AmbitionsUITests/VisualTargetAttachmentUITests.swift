import XCTest

@MainActor
final class VisualTargetAttachmentUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimeVisualReviewRunAttachesActualScreenshot() throws {
        let app = AmbitionsVisualAcceptanceApp.launchTime()
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 30))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "time-lifeshape-field-actual-for-target-review"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testSourceInspectionYouSourcesAttachesRenderedProofScreenshots() throws {
        let darkApp = AmbitionsVisualAcceptanceApp.launchYouSources(appearance: "dark")
        _ = try XCTUnwrap(AmbitionsVisualAcceptanceApp.waitForVisibleSourceInspectionDetail(in: darkApp))

        let darkAttachment = XCTAttachment(screenshot: darkApp.screenshot())
        darkAttachment.name = "source-inspection-you-sources-dark-rendered-proof"
        darkAttachment.lifetime = .keepAlways
        add(darkAttachment)

        darkApp.terminate()

        let accessibilityApp = AmbitionsVisualAcceptanceApp.launchYouSources(
            appearance: "dark",
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        _ = try XCTUnwrap(AmbitionsVisualAcceptanceApp.waitForVisibleSourceInspectionDetail(in: accessibilityApp))

        let accessibilityAttachment = XCTAttachment(screenshot: accessibilityApp.screenshot())
        accessibilityAttachment.name = "source-inspection-you-sources-dark-accessibility-xl-rendered-proof"
        accessibilityAttachment.lifetime = .keepAlways
        add(accessibilityAttachment)
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
        let receiptDismiss = app.descendants(matching: .any)["action-closure-tray.dismiss-button"]
        if receiptDismiss.waitForExistence(timeout: 3) {
            receiptDismiss.tap()
        }
        return app
    }

    @MainActor
    static func launchYouSources(
        appearance: String = "dark",
        contentSizeCategory: String = "UICTContentSizeCategoryM"
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = "preview"
        app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = "ambitions://tab/you"
        app.launchEnvironment["AmbitionsScreenshotMode"] = "YES"
        app.launchEnvironment["AmbitionsYouDetail"] = "sources"
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", "preview"]
        app.launchArguments += ["-AMBITIONS_LAUNCH_URL", "ambitions://tab/you"]
        app.launchArguments += ["-AmbitionsScreenshotMode", "YES"]
        app.launchArguments += ["-AmbitionsYouDetail", "sources"]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        app.launchArguments += ["-uiuserinterfacestyle", appearance]
        app.launch()
        let receiptDismiss = app.descendants(matching: .any)["action-closure-tray.dismiss-button"]
        if receiptDismiss.waitForExistence(timeout: 3) {
            receiptDismiss.tap()
        }
        return app
    }

    @MainActor
    static func waitForVisibleSourceInspectionDetail(in app: XCUIApplication) -> XCUIElement? {
        let identifiers = [
            "trust.source.inspection-detail.current",
            "trust.source.inspection-detail.stale",
            "trust.source.inspection-detail.stale_critical",
            "trust.source.inspection-detail.unavailable",
            "trust.source.inspection-detail.conflicted",
            "trust.source.inspection-detail.revoked",
            "trust.source.inspection-detail.unsupported",
            "trust.source.inspection-detail.review_required",
        ]

        for _ in 0..<10 {
            for identifier in identifiers {
                let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
                if element.exists && isVisible(element, in: app) {
                    return element
                }
            }
            app.swipeUp()
        }

        return nil
    }

    @MainActor
    static func isVisible(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        let frame = element.frame
        guard frame.isEmpty == false else { return false }
        let visibleFrame = app.frame.insetBy(dx: 0, dy: 80)
        return visibleFrame.intersects(frame)
    }
}
