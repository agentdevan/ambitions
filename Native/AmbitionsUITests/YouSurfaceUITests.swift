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
        XCTAssertTrue(app.staticTexts["Planning defaults"].waitForExistence(timeout: 10))

        XCTAssertTrue(scrollUntilYouRowExists(named: "Receipts & History", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Privacy", in: app, maxAttempts: 6))
        XCTAssertTrue(tapYouRow(named: "Privacy", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["you.trust-center-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipts, corrections, and explanations", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Recent trust receipts", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Claims locked", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipt drawer", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipt drawer keeps source freshness, privacy, correction, undo, and review paths visible.", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Proof trail", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Proof stays attached to source freshness, privacy, correction, and review state.", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Why this?", in: app))
    }

    func testYouPersonalRuntimeAndLocalDataControlsShowHonestStatusLabels() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("You", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Planning defaults"].waitForExistence(timeout: 10))

        XCTAssertTrue(scrollUntilYouRowExists(named: "Personal system", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Personal system", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.personal-runtime-status-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("local", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("preview", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("needs setup", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hidden automation", in: app, maxAttempts: 8))
        app.buttons["Done"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Planning defaults"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Local Data Controls", in: app, maxAttempts: 10))
        XCTAssertTrue(tapYouRow(named: "Local Data Controls", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.local-data-controls-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Privacy / Local Data Controls", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hosted account", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Policy receipt examples", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Export/import drill pending", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("needs setup", in: app, maxAttempts: 8))
    }

    func testYouScreenshotProofLaunchStatesOpenRequiredDetailSheets() throws {
        let states = [
            ("trust-automation", "you.automation-trust-card"),
            ("personal-runtime", "you.personal-runtime-status-card"),
            ("receipts-history", "you.receipts-card")
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
                requiredIdentifier: "you.row.local-data-controls",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: "you.row.local-data-controls"
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
                XCTAssertTrue(app.staticTexts["Local profile"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.row.appearance"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.row.capture-preferences"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.row.life-areas"].waitForExistence(timeout: 10))
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
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("You", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Local Context Controls", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Local Context Controls", in: app, maxAttempts: 10))

        XCTAssertTrue(scrollUntilElementExists("you.life-context-card", in: app, maxAttempts: 16))
        let catchUpButton = scrollUntilButtonHittable("you.life-context.catch-up-button", fallbackLabel: "Catch me up", in: app, maxAttempts: 16)
        let reviewButton = scrollUntilButtonHittable("you.life-context.review-button", fallbackLabel: "Review what Ambitions knows", in: app, maxAttempts: 16)
        XCTAssertTrue(catchUpButton.waitForExistence(timeout: 1))
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 1))

        reviewButton.tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Needs Review", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Older context that may need review", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilElementExists("you.life-context.section.life-context-review-needed", in: app, maxAttempts: 8))

        catchUpButton.tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Basics", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Schedule & Availability", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Travel & Access", in: app, maxAttempts: 8))
        XCTAssertTrue(app.buttons["you.life-context.fact.life-context-age.edit"].waitForExistence(timeout: 10))
    }

    func testYouLifeContextLedgerInspectionShowsRuntimeFactorsAndReplayReceipts() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("You", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Local Context Controls", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Local Context Controls", in: app, maxAttempts: 10))

        XCTAssertTrue(scrollUntilElementExists("you.life-context-card", in: app, maxAttempts: 16))
        let reviewButton = scrollUntilButtonHittable("you.life-context.review-button", fallbackLabel: "Review what Ambitions knows", in: app, maxAttempts: 16)
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 1))
        reviewButton.tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Runtime Factors", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Recommendation Inputs", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Why This Changes Plans", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Rejected Factors", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Sensitive Context Usage", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Context Confidence", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Needs Review", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Disabled Factors", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Replay & Receipts", in: app, maxAttempts: 8))
    }

    func testYouSourceAtlasGoalKnowledgeSurfaceShowsSourceReviewAndReplayReceipts() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("You", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("You", in: app))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Local Context Controls", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Local Context Controls", in: app, maxAttempts: 10))

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
