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
                requiredIdentifier: "you.privacy-control.review.export",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["AmbitionsYouPrivacyControlReview": "export"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "packet-3-8-you-local-data-controls-reset-review",
                detail: "local-data",
                requiredIdentifier: "you.privacy-control.review.reset",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["AmbitionsYouPrivacyControlReview": "reset"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "packet-3-8-you-local-data-controls-delete-review",
                detail: "local-data",
                requiredIdentifier: "you.privacy-control.review.delete",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["AmbitionsYouPrivacyControlReview": "delete"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "packet-3-8-you-local-data-controls-account-review",
                detail: "local-data",
                requiredIdentifier: "you.privacy-control.review.account",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["AmbitionsYouPrivacyControlReview": "account"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "packet-3-8-you-local-data-controls-source-review",
                detail: "local-data",
                requiredIdentifier: "you.privacy-control.review.sources",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["AmbitionsYouPrivacyControlReview": "sources"],
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

        try capturePacket37YouNativeSettingsMaturityScreenshots()
        try capturePacket38YouPrivacyControlsScreenshots()
    }

    private func capturePacket37YouNativeSettingsMaturityScreenshots() throws {
        let rootApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        rootApp.launch()

        XCTAssertTrue(rootApp.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(rootApp.staticTexts["Your settings"].waitForExistence(timeout: 10))
        XCTAssertTrue(rootApp.staticTexts["On this iPhone"].waitForExistence(timeout: 10))
        XCTAssertTrue(rootApp.descendants(matching: .any)["you.settings.row.personal-system"].waitForExistence(timeout: 10))
        XCTAssertTrue(rootApp.descendants(matching: .any)["you.settings.row.local-data-controls"].waitForExistence(timeout: 10))
        XCTAssertTrue(rootApp.descendants(matching: .any)["you.settings.row.privacy"].waitForExistence(timeout: 10))
        XCTAssertFalse(rootApp.staticTexts["Open Field"].exists)
        captureYouScreenshot(named: "packet-3.7-you-native-settings-root", in: rootApp)
        XCTAssertTrue(scrollUntilElementExists("you.settings.row.capture-preferences", in: rootApp, maxAttempts: 8))
        rootApp.terminate()

        let largeTypeApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES"
            ],
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        largeTypeApp.launch()

        XCTAssertTrue(largeTypeApp.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTypeApp.staticTexts["On this iPhone"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTypeApp.descendants(matching: .any)["you.settings.row.personal-system"].waitForExistence(timeout: 10))
        captureYouScreenshot(named: "packet-3.7-you-native-settings-large-dynamic-type", in: largeTypeApp)
        XCTAssertTrue(scrollYouContentToVisible(identifier: "you.settings.row.capture-preferences", in: largeTypeApp))
        largeTypeApp.terminate()

        let localDataApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "local-data"
            ]
        )
        localDataApp.launch()

        XCTAssertTrue(localDataApp.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(localDataApp.descendants(matching: .any)["you.local-data-control-center"].waitForExistence(timeout: 10))
        XCTAssertTrue(localDataApp.descendants(matching: .any)["you.privacy-control-review-surface"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Privacy / Local Data Controls", in: localDataApp, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Local app state", in: localDataApp, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hosted account", in: localDataApp, maxAttempts: 8))
        localDataApp.terminate()

        let privacyApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "privacy"
            ]
        )
        privacyApp.launch()

        XCTAssertTrue(privacyApp.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(privacyApp.descendants(matching: .any)["you.trust-center-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipts, corrections, and explanations", in: privacyApp, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Why this?", in: privacyApp, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.7-you-privacy-detail", in: privacyApp)
        privacyApp.terminate()

        let capturePreferencesApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "capture"
            ]
        )
        capturePreferencesApp.launch()

        XCTAssertTrue(capturePreferencesApp.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(capturePreferencesApp.descendants(matching: .any)["you.capture-preferences-control-group"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Capture preferences", in: capturePreferencesApp, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Capture remains a global composer", in: capturePreferencesApp, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.7-you-capture-preferences-detail", in: capturePreferencesApp)
        capturePreferencesApp.terminate()
    }

    private func capturePacket38YouPrivacyControlsScreenshots() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AmbitionsInitialSurface": "you",
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsYouDetail": "local-data"
            ]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.local-data-control-center"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("you.privacy-control-review-surface", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.privacy-control.review.export"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Review before anything changes", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Export summary", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("This panel does not create a file", in: app, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.8-you-local-data-controls-export-review", in: app)

        let resetButton = scrollUntilButtonHittable("you.privacy-control.reset-button", in: app, maxAttempts: 10)
        XCTAssertTrue(resetButton.exists)
        resetButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.privacy-control.review.reset"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Reset learned corrections", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("does not erase goals", in: app, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.8-you-local-data-controls-reset-review", in: app)

        let deleteButton = scrollUntilButtonHittable("you.privacy-control.delete-button", in: app, maxAttempts: 10)
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.privacy-control.review.delete"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Delete local data", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("cannot erase goals", in: app, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.8-you-local-data-controls-delete-review", in: app)

        let accountButton = scrollUntilButtonHittable("you.privacy-control.account-button", in: app, maxAttempts: 10)
        XCTAssertTrue(accountButton.exists)
        accountButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.privacy-control.review.account"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("No account is required", in: app, maxAttempts: 8))
        XCTAssertTrue(
            scrollUntilButtonHittable(
                "you.privacy-control.account.handoff-button",
                fallbackLabel: "Open About",
                in: app,
                maxAttempts: 10
            ).exists
        )
        captureYouScreenshot(named: "packet-3.8-you-local-data-controls-account-review", in: app)

        let sourcesButton = scrollUntilButtonHittable("you.privacy-control.sources-button", in: app, maxAttempts: 10)
        XCTAssertTrue(sourcesButton.exists)
        sourcesButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.privacy-control.review.sources"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Source Atlas remains public-reference", in: app, maxAttempts: 8))
        let handoffButton = scrollUntilButtonHittable(
            "you.privacy-control.sources.handoff-button",
            fallbackLabel: "Open Sources",
            in: app,
            maxAttempts: 10
        )
        XCTAssertTrue(handoffButton.exists)
        handoffButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.source-settings-control-group"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Sources", in: app, maxAttempts: 8))
        captureYouScreenshot(named: "packet-3.8-you-local-data-controls-source-handoff", in: app)
        app.terminate()
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
