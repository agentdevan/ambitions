import XCTest

@MainActor
final class YouSurfaceUITests: AmbitionsUITestCase {
    func testYouAppearanceStudioControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Appearance", in: app, maxAttempts: 8))
        let appearanceRow = youRow(named: "Appearance", in: app)
        XCTAssertTrue(appearanceRow.isHittable)
        appearanceRow.tap()
        XCTAssertTrue(app.staticTexts["Appearance Studio"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Accent family", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Live preview", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No unsaved changes", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Persist the curated setup for future launches.", in: app, maxAttempts: 8))
    }

    func testYouPersonalDefaultsRemainVisibleBeneathAppearanceStudio() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Session Defaults", in: app, maxAttempts: 8))
        let profileRow = youRow(named: "Session Defaults", in: app)
        profileRow.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.constitution-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("CONSTITUTION", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Personal Operating Constitution", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("The local rules Ambitions uses to stay useful without becoming pushy or silent.", in: app, maxAttempts: 8))
    }

    func testYouTrustSurfaceShowsConservativeExternalStatusLabels() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("You", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Your settings"].waitForExistence(timeout: 10))

        XCTAssertTrue(scrollUntilElementExists("you.settings.row.privacy", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilElementExists("you.settings.row.local-data-controls", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Privacy", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["you.trust-center-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipts, corrections, and explanations", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Recent trust receipts", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Claims locked", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipt drawer", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipt drawer keeps context freshness, privacy, correction, undo, and review paths visible.", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Proof trail", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Proof stays attached to context freshness, privacy, correction, and review state.", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Why this?", in: app))
    }

    func testYouPersonalRuntimeAndLocalDataControlsShowHonestStatusLabels() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "personal-runtime"
            ]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.personal-runtime-status-control-group"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("On device", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("user-owned", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Example", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Pending", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hidden automation", in: app, maxAttempts: 8))
        app.buttons["shell.you.back-button"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Your settings"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Local Data", in: app, maxAttempts: 10))
        XCTAssertTrue(tapYouRow(named: "Local Data", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.local-data-controls-control-group"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Privacy / Local Data Controls", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hosted account", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Policy receipt examples", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Export/import drill pending", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("On device", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Example", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Pending", in: app, maxAttempts: 8))
    }

    func testYouScreenshotProofLaunchStatesOpenRequiredDetailSheets() throws {
        let states = [
            ("trust-automation", "you.automation-trust-card"),
            ("personal-runtime", "you.personal-runtime-status-control-group"),
            ("receipts-history", "you.receipts-control-group")
        ]

        for state in states {
            let app = makeApp(
                bootstrapMode: "preview",
                extraEnvironment: [
                    "AmbitionsInitialSurface": "you",
                    "AmbitionsScreenshotMode": "YES",
                    "AmbitionsYouDetail": state.0
                ]
            )
            app.launch()

            XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
            if state.0 == "receipts-history" {
                XCTAssertTrue(app.staticTexts["Receipts & History"].waitForExistence(timeout: 10))
                XCTAssertTrue(scrollUntilElementExists(state.1, in: app, maxAttempts: 12))
            } else {
                XCTAssertTrue(app.descendants(matching: .any)[state.1].waitForExistence(timeout: 10))
            }

            app.terminate()
        }
    }

    func testAMB966YouReconstructionScreenshotMatrix() throws {
        struct MatrixItem {
            let name: String
            let detail: String?
            let requiredIdentifier: String?
            let contentSizeCategory: String
            let extraEnvironment: [String: String]
            let bottomInsetTarget: String?
        }

        let matrix = [
            MatrixItem(
                name: "amb-1198-you-root-default",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-appearance",
                detail: "appearance",
                requiredIdentifier: "you.appearance-studio-card",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-capture",
                detail: "capture",
                requiredIdentifier: "you.capture-preferences-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-life-areas",
                detail: "life-areas",
                requiredIdentifier: "you.life-areas-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-privacy",
                detail: "privacy",
                requiredIdentifier: "you.trust-center-card",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-local-data",
                detail: "local-data",
                requiredIdentifier: "you.local-data-status-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-sources",
                detail: "sources",
                requiredIdentifier: "you.source-settings-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-receipts-history",
                detail: "receipts-history",
                requiredIdentifier: "you.receipts-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-accessibility",
                detail: "accessibility",
                requiredIdentifier: "you.accessibility-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-about",
                detail: "about",
                requiredIdentifier: "you.about-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-large-dynamic-type",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-requested-increase-contrast",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["UIAccessibilityDarkerSystemColorsEnabled": "YES"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-1198-you-bottom-inset-local-data",
                detail: nil,
                requiredIdentifier: "you.settings.row.local-data-controls",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: "you.settings.row.local-data-controls"
            )
        ]

        for item in matrix {
            var environment = [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES"
            ]
            if let detail = item.detail {
                environment["AmbitionsYouDetail"] = detail
            }
            item.extraEnvironment.forEach { environment[$0.key] = $0.value }

            let app = makeApp(
                bootstrapMode: "preview",
                extraEnvironment: environment,
                contentSizeCategory: item.contentSizeCategory
            )
            app.launch()

            XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
            if item.detail == nil {
                XCTAssertTrue(app.staticTexts["Your settings"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.settings.row.appearance"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.settings.row.capture-preferences"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.settings.row.life-areas"].waitForExistence(timeout: 10))
                XCTAssertFalse(app.staticTexts["How Ambitions works for me"].exists)
            }
            if let target = item.bottomInsetTarget {
                XCTAssertTrue(scrollYouContentToVisible(identifier: target, in: app))
            }
            if let requiredIdentifier = item.requiredIdentifier {
                let requiredElement = app.descendants(matching: .any)[requiredIdentifier]
                if requiredElement.waitForExistence(timeout: 10) == false {
                    XCTAssertTrue(scrollUntilElementExists(requiredIdentifier, in: app, maxAttempts: 12))
                } else {
                    XCTAssertTrue(requiredElement.exists)
                }
            }

            captureYouScreenshot(named: item.name, in: app)
            app.terminate()
        }
    }

    func testYouLifeContextHeroCTAsExpandCatchUpAndReviewRoutes() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "local-context"
            ]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("you.life-context-card", in: app, maxAttempts: 16))
        XCTAssertTrue(app.buttons["you.life-context.catch-up-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["you.life-context.review-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Life Context", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Help Ambitions plan from your real life.", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Basics", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Schedule & Availability", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Travel & Access", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-review-needed", in: app, maxAttempts: 8))
    }

    func testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "local-context"
            ]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("you.life-context-card", in: app, maxAttempts: 16))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-runtime-factors", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-recommendation-inputs", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-why-this-changes-plans", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-rejected-factors", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-sensitive-context-usage", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-context-confidence", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-review-needed", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-disabled-factors", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-replay-receipts", in: app, maxAttempts: 12))
    }

    func testYouSourceAtlasGoalKnowledgeSurfaceShowsSourceReviewAndReplayReceipts() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "local-context"
            ]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("you.source-atlas-knowledge-card", in: app, maxAttempts: 16))
        XCTAssertTrue(scrollUntilStaticTextExists("Source Atlas & Goal Knowledge", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Goal Knowledge Sources", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Active Source Packs", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Needs Review", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Unsupported Goal Areas", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Recent Goal Compilations", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Path Sources", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Step Sources", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Corrections", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Replay Receipts", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Used to Plan", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Not Used", in: app, maxAttempts: 8))
    }
}
