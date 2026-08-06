import XCTest

@MainActor
final class PublicReferenceInspectionUITests: AmbitionsUITestCase {
    func testYouSourcesRendersPublicReferenceInspectionWithAuthorityAndNonClaim() {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://tab/you",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "sources",
                "AMBITIONS_UI_PUBLIC_REFERENCE_FIXTURE": "1"
            ]
        )
        app.launch()
        defer { app.terminate() }

        let inspection = app.descendants(matching: .any)[
            "trust.public-reference-inspection.public-reference-inspection-onet-30.3-30.3"
        ]
        XCTAssertTrue(inspection.waitForExistence(timeout: 30))
        XCTAssertTrue(app.staticTexts["O*NET 30.3 — Software Developers (15-1252.00), United States"].exists)
        XCTAssertTrue(app.staticTexts["Not approved for recommendation use"].exists)

        dismissContinuityReceiptIfNeeded(in: app)
        let taskClaim = scrollUntilButtonHittable(
            "trust.public-reference.claim.onet-task-1",
            in: app
        )
        XCTAssertTrue(taskClaim.isHittable)
        XCTAssertFalse(app.staticTexts["CLAIM INSPECTION"].exists)
        taskClaim.tap()

        XCTAssertTrue(scrollUntilHittable(app.staticTexts["CLAIM INSPECTION"], in: app))
        XCTAssertTrue(app.staticTexts["What this source can claim"].exists)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "amb-2052-public-reference-inspection-rendered"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testYouSourcesPublicReferenceInspectionSupportsAccessibilityTextSize() {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://tab/you",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "sources",
                "AMBITIONS_UI_PUBLIC_REFERENCE_FIXTURE": "1"
            ],
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        app.launch()
        defer { app.terminate() }

        XCTAssertTrue(app.staticTexts["Public reference sources"].waitForExistence(timeout: 30))
        XCTAssertTrue(app.staticTexts["Not approved for recommendation use"].exists)

        dismissContinuityReceiptIfNeeded(in: app)
        let taskClaim = scrollUntilButtonHittable(
            "trust.public-reference.claim.onet-task-1",
            in: app,
            maxAttempts: 12
        )
        XCTAssertTrue(taskClaim.isHittable)
        taskClaim.tap()

        XCTAssertTrue(scrollUntilHittable(app.staticTexts["CLAIM INSPECTION"], in: app, maxAttempts: 12))
        XCTAssertTrue(app.staticTexts["What this source can claim"].exists)
    }

    private func dismissContinuityReceiptIfNeeded(in app: XCUIApplication) {
        let dismissReceipt = app.buttons["shell.continuity-receipt.dismiss-button"]
        if dismissReceipt.waitForExistence(timeout: 2), dismissReceipt.isHittable {
            dismissReceipt.tap()
        }
    }

    private func scrollUntilHittable(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxAttempts: Int = 8
    ) -> Bool {
        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 1), element.isHittable {
                return true
            }
            app.swipeUp()
        }
        return element.exists && element.isHittable
    }
}
