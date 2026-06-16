import XCTest

@MainActor
final class AmbitionsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPreviewBootstrapShowsEmptyGoalsState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertFalse(app.descendants(matching: .any)["onboarding.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        XCTAssertTrue(goalCreateButton(in: app).waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapTodayStartHereNotThisOpensReasonSheet() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_PREVIEW_TODAY_SCENARIO": "stable"]
        )
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let notThisButton = scrollUntilButtonHittable("TodayStartHereNotThis", fallbackLabel: "Not this", in: app)
        XCTAssertTrue(notThisButton.exists)
        notThisButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["TodayRejectionReasonSheet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["TodayRejectionReasonConfirm"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["TodayRejectionReasonSkip"].waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapTodayShowAnotherOpensReplacementSheetAndAppliesSelection() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_PREVIEW_TODAY_SCENARIO": "stable"]
        )
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.staticTexts["TodayRealityRailStepTitle"].waitForExistence(timeout: 10))
        let originalTitle = app.staticTexts["TodayRealityRailStepTitle"].label

        let showAnotherButton = scrollUntilButtonHittable("TodayStartHereShowAnother", fallbackLabel: "Show another", in: app)
        XCTAssertTrue(showAnotherButton.exists)
        showAnotherButton.tap()

        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementSheet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementOriginalRecommendation"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementAlternatives"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementImpact"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementReceiptPreview"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Shorter"].waitForExistence(timeout: 10))
        app.buttons["Shorter"].tap()
        XCTAssertTrue(app.buttons["TodayStepReplacementApprove"].waitForExistence(timeout: 10))
        app.buttons["TodayStepReplacementApprove"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.inline-message"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["TodayRealityRailStepTitle"].waitForExistence(timeout: 10))
        let updatedTitle = app.staticTexts["TodayRealityRailStepTitle"].label

        XCTAssertNotEqual(updatedTitle, originalTitle)
        XCTAssertTrue(updatedTitle.contains("First 15 minutes"))
        XCTAssertTrue(app.staticTexts["Alternative approved"].waitForExistence(timeout: 10))
    }

    func testForcedOnboardingCreateFirstGoalPathOpensComposer() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_FORCE_ONBOARDING": "1"]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["onboarding.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["onboarding.next-button"].waitForExistence(timeout: 10))
        app.buttons["onboarding.next-button"].tap()
        XCTAssertTrue(app.buttons["onboarding.choice.create_first_goal"].waitForExistence(timeout: 10))
        app.buttons["onboarding.choice.create_first_goal"].tap()
        app.buttons["onboarding.next-button"].tap()
        XCTAssertTrue(app.staticTexts["No account required"].waitForExistence(timeout: 10))
        app.buttons["onboarding.start-button"].tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        XCTAssertTrue(goalTitleInput(in: app).waitForExistence(timeout: 10))
    }

    func testForcedOnboardingCaptureFirstPathOpensQuickCapture() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_FORCE_ONBOARDING": "1"]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["onboarding.screen"].waitForExistence(timeout: 10))
        app.buttons["onboarding.next-button"].tap()
        let captureChoice = app.buttons["onboarding.choice.capture_first"]
        if captureChoice.waitForExistence(timeout: 2) == false {
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.72))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.52))
            start.press(forDuration: 0.01, thenDragTo: end)
        }
        XCTAssertTrue(captureChoice.waitForExistence(timeout: 10))
        captureChoice.tap()
        app.buttons["onboarding.next-button"].tap()
        XCTAssertTrue(app.staticTexts["Starts locally"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Manual first"].waitForExistence(timeout: 10))
        app.buttons["onboarding.start-button"].tap()

        XCTAssertTrue(shellCaptureInput(in: app).waitForExistence(timeout: 10))
    }

    func testPreviewBootstrapCanCreateGoalFromEmptyState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        let createButton = goalCreateButton(in: app)
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("UI Smoke Goal")
        dismissKeyboardIfNeeded(in: app)
        XCTAssertTrue(scrollUntilStaticTextExists("Trust framing", in: app))

        let submitButton = scrollUntilButtonHittable("create-goal.submit-button", in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(waitForCreatedGoalAcknowledgement(title: "UI Smoke Goal", in: app))
        XCTAssertTrue(titleField.waitForNonExistence(timeout: 10))
    }

    func testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        for tab in ["Today", "Goals", "Time", "Motion", "You"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: 10), "Missing top-level tab \(tab)")
            XCTAssertTrue(app.tabBars.buttons[tab].isHittable, "Top-level tab \(tab) is not hittable")
        }
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["More"].exists)
        XCTAssertFalse(app.tabBars.buttons["Insights"].exists)
        XCTAssertFalse(app.tabBars.buttons["Profile"].exists)
        XCTAssertFalse(app.tabBars.buttons["Habits"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["shell.header.rail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.header.context-crown"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["shell.continuity-ribbon"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["shell.today.capture-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["shell.today.memory-lens-button"].waitForExistence(timeout: 1))

        XCTAssertTrue(openCanonicalDestination("Motion", screenIdentifier: "motion.current.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["motion.current.field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["motion.current.fact.source"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["motion.current.fact.proof"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["motion.current.fact.receipt"].waitForExistence(timeout: 10))

        XCTAssertTrue(openCanonicalDestination("Time", screenIdentifier: "time.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.reflow-trust-seam"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.decline"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.edit"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.accept"].waitForExistence(timeout: 10))

        XCTAssertTrue(openCanonicalDestination("You", screenIdentifier: "you.screen", in: app))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))
        XCTAssertTrue(youRow(named: "Schedule & Availability", in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Receipts & History", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Proof", in: app, maxAttempts: 6))

        XCTAssertTrue(openCanonicalDestination("Goals", screenIdentifier: "goals.screen", in: app))
        XCTAssertFalse(app.buttons["shell.goals.create-button"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["shell.goals.capture-button"].waitForExistence(timeout: 10))
    }

    func testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))

        let header = app.descendants(matching: .any)["shell.header.rail"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
        XCTAssertLessThanOrEqual(header.frame.maxY, window.frame.maxY, "Shell header rail must not extend below the app window.")
        let crown = app.descendants(matching: .any)["shell.header.context-crown"]
        XCTAssertTrue(crown.waitForExistence(timeout: 10))
        XCTAssertLessThanOrEqual(crown.frame.maxY, window.frame.maxY, "Shell header context crown must not extend below the app window.")
        var visibleDockFrame = CGRect.null
        for tab in ["Today", "Goals", "Time", "Motion", "You"] {
            let identifiedElement = app.descendants(matching: .any)["shell.meridian.destination.\(tab.lowercased())"]
            let element = identifiedElement.waitForExistence(timeout: 2) ? identifiedElement : app.buttons[tab]
            XCTAssertTrue(element.waitForExistence(timeout: 10), "Missing top-level tab \(tab)")
            assertFrame(element.frame, isInside: window.frame, named: "\(tab) dock button")
            visibleDockFrame = visibleDockFrame.isNull ? element.frame : visibleDockFrame.union(element.frame)
            XCTAssertGreaterThanOrEqual(element.frame.width, 44, "\(tab) tab button is narrower than the minimum hit target.")
            XCTAssertGreaterThanOrEqual(element.frame.height, 44, "\(tab) tab button is shorter than the minimum hit target.")
        }
        XCTAssertFalse(visibleDockFrame.isNull, "The visible shell dock must expose top-level destination buttons.")
        XCTAssertGreaterThan(visibleDockFrame.minY, header.frame.maxY, "The visible shell dock must remain below the shell header.")
        XCTAssertLessThanOrEqual(visibleDockFrame.maxY, window.frame.maxY, "The visible shell dock must remain inside the app window.")

        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)
        XCTAssertFalse(app.tabBars.buttons["Plan"].exists)
    }

    func testUIQL002ActivatedCaptureSeamStaysAboveNativeDockAfterKeyboardDismissal() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        let seam = app.descendants(matching: .any)["shell.activated-capture-seam"]
        XCTAssertTrue(seam.waitForExistence(timeout: 10))
        dismissKeyboardIfNeeded(in: app)

        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        var visibleDockFrame = CGRect.null
        for tab in ["Today", "Goals", "Time", "Motion", "You"] {
            let identifiedElement = app.descendants(matching: .any)["shell.meridian.destination.\(tab.lowercased())"]
            let element = identifiedElement.waitForExistence(timeout: 2) ? identifiedElement : app.buttons[tab]
            XCTAssertTrue(element.waitForExistence(timeout: 10), "Missing visible dock destination \(tab)")
            visibleDockFrame = visibleDockFrame.isNull ? element.frame : visibleDockFrame.union(element.frame)
        }
        XCTAssertFalse(visibleDockFrame.isNull, "The visible shell dock must expose top-level destination buttons.")

        assertFrame(seam.frame, isInside: window.frame, named: "activated Capture seam")
        XCTAssertLessThanOrEqual(
            seam.frame.maxY,
            visibleDockFrame.minY,
            "Activated Capture seam must not cover the visible shell dock after keyboard dismissal."
        )
        XCTAssertTrue(shellCaptureInput(in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shell.activated-capture.save-button"].waitForExistence(timeout: 10))
    }

    func testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        captureShellScreenshot(named: "today", in: app)

        for tab in ["Goals", "Time", "Motion", "You"] {
            XCTAssertTrue(openCanonicalDestination(tab, screenIdentifier: screenIdentifier(forTab: tab), in: app))
            captureShellScreenshot(named: tab.lowercased(), in: app)
        }
    }

    func testYouAppearanceStudioControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["You"].tap()
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

        app.tabBars.buttons["You"].tap()
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

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))

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

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))

        XCTAssertTrue(scrollUntilYouRowExists(named: "Personal system", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Personal system", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.personal-runtime-status-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("local", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("preview", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("needs setup", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("No hidden automation", in: app, maxAttempts: 8))
        app.buttons["Done"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))
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
                name: "amb-966-you-default",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-trust-automation",
                detail: "trust-automation",
                requiredIdentifier: "you.automation-trust-card",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-personal-runtime",
                detail: "personal-runtime",
                requiredIdentifier: "you.personal-runtime-status-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-receipts-history",
                detail: "receipts-history",
                requiredIdentifier: "you.receipts-control-group",
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-large-dynamic-type",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL",
                extraEnvironment: [:],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-requested-increase-contrast",
                detail: nil,
                requiredIdentifier: nil,
                contentSizeCategory: "UICTContentSizeCategoryM",
                extraEnvironment: ["UIAccessibilityDarkerSystemColorsEnabled": "YES"],
                bottomInsetTarget: nil
            ),
            MatrixItem(
                name: "amb-966-you-bottom-inset-local-data-controls",
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
                XCTAssertTrue(app.staticTexts["Personal system / User System Profile"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.staticTexts["How Ambitions works for me"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.priority-node.trust-automation"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.priority-node.personal-runtime"].waitForExistence(timeout: 10))
                XCTAssertTrue(app.descendants(matching: .any)["you.priority-node.receipts-history"].waitForExistence(timeout: 10))
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

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
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

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
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

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
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

    func testLaunchURLCanLandOnCanonicalTimeSurface() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Time"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Time"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 10))
    }

    func testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab() throws {
        let hiddenApp = makeApp(bootstrapMode: "preview")
        hiddenApp.launch()

        XCTAssertTrue(waitForShellReady(in: hiddenApp))
        XCTAssertFalse(hiddenApp.descendants(matching: .any)["shell.activated-capture-seam"].exists)
        XCTAssertFalse(hiddenApp.tabBars.buttons["Capture"].exists)
        hiddenApp.terminate()

        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.activated"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.keyboard"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.dictation"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.local-classification"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)

        let input = shellCaptureInput(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("build launch goal tomorrow")
        dismissKeyboardIfNeeded(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.typing"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.route-reveal"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.route.ready-after-review"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shell.activated-capture.route.ready-to-place.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shell.activated-capture.route.grow-into-goal.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["shell.activated-capture.route.held-for-review.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.source-trust"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.reduce-motion"].waitForExistence(timeout: 10))

        let routeCorrection = scrollUntilButtonHittable("shell.activated-capture.route.ready-to-place.correction", in: app, maxAttempts: 10)
        XCTAssertTrue(routeCorrection.exists)
        routeCorrection.tap()
        XCTAssertTrue(scrollUntilElementExists("shell.activated-capture.correction-receipt", in: app, maxAttempts: 6))

        let dictation = scrollUntilButtonHittable("shell.activated-capture.dictation-button", in: app, maxAttempts: 10)
        XCTAssertTrue(dictation.waitForExistence(timeout: 10))
        dictation.tap()

        let save = scrollUntilButtonHittable("shell.activated-capture.save-button", in: app, maxAttempts: 10)
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        save.tap()
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.state.captured-locally"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture.status"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        app.terminate()

        let largeTextApp = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://captures/inbox",
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        largeTextApp.launch()

        XCTAssertTrue(waitForShellReady(in: largeTextApp))
        XCTAssertFalse(largeTextApp.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(largeTextApp.tabBars.buttons["Pulse"].exists)
        XCTAssertTrue(largeTextApp.tabBars.buttons["Today"].isSelected)

        XCTAssertTrue(largeTextApp.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        let largeInput = shellCaptureInput(in: largeTextApp)
        XCTAssertTrue(largeInput.waitForExistence(timeout: 10))
        largeInput.tap()
        largeInput.typeText("build launch goal")
        dismissKeyboardIfNeeded(in: largeTextApp)
        XCTAssertTrue(largeTextApp.buttons["shell.activated-capture.save-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.buttons["shell.activated-capture.make-goal-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.buttons["shell.activated-capture.dictation-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.descendants(matching: .any)["shell.activated-capture.route-reveal"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.descendants(matching: .any)["shell.activated-capture.source-trust"].waitForExistence(timeout: 10))
    }

    func testAMB967CaptureCreateGoalScreenshotMatrix() throws {
        let activatedApp = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        activatedApp.launch()
        XCTAssertTrue(waitForShellReady(in: activatedApp))
        XCTAssertFalse(activatedApp.tabBars.buttons["Capture"].exists)
        XCTAssertTrue(activatedApp.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        XCTAssertFalse(activatedApp.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        captureAMB967Screenshot(named: "amb-967-capture-activated", in: activatedApp)

        let activatedInput = shellCaptureInput(in: activatedApp)
        XCTAssertTrue(activatedInput.waitForExistence(timeout: 10))
        activatedInput.tap()
        activatedInput.typeText("build launch goal tomorrow")
        captureAMB967Screenshot(named: "amb-967-capture-keyboard", in: activatedApp)
        dismissKeyboardIfNeeded(in: activatedApp)

        XCTAssertTrue(activatedApp.descendants(matching: .any)["shell.activated-capture.route-reveal"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["shell.activated-capture.route.needs-place.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["shell.activated-capture.route.ready-to-place.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["shell.activated-capture.route.grow-into-goal.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["shell.activated-capture.route.held-for-review.correction"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.descendants(matching: .any)["shell.activated-capture.source-trust"].waitForExistence(timeout: 10))
        captureAMB967Screenshot(named: "amb-967-capture-route-reveal", in: activatedApp)
        activatedApp.terminate()

        let createApp = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/create-goal")
        createApp.launch()
        XCTAssertTrue(waitForCreateGoalComposer(in: createApp))
        XCTAssertTrue(createApp.staticTexts["Shape the first path"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Balanced path", in: createApp, maxAttempts: 8))
        captureAMB967Screenshot(named: "amb-967-create-goal-default", in: createApp)

        let titleField = goalTitleInput(in: createApp)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("Launch a calmer morning routine")
        dismissKeyboardIfNeeded(in: createApp)
        XCTAssertTrue(scrollUntilStaticTextExists("Goal to path", in: createApp, maxAttempts: 12))
        XCTAssertTrue(scrollUntilStaticTextExists("local save", in: createApp, maxAttempts: 12))
        XCTAssertFalse(createApp.staticTexts[["Auto", "detect"].joined(separator: "-")].exists)
        captureAMB967Screenshot(named: "amb-967-create-goal-first-path-preview", in: createApp)
        createApp.terminate()

        let largeTextCreateApp = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://overlay/create-goal",
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        largeTextCreateApp.launch()
        XCTAssertTrue(waitForCreateGoalComposer(in: largeTextCreateApp))
        XCTAssertTrue(goalTitleInput(in: largeTextCreateApp).waitForExistence(timeout: 10))
        captureAMB967Screenshot(named: "amb-967-create-goal-large-dynamic-type", in: largeTextCreateApp)
    }

    func testPreviewBootstrapGlobalCaptureComposerSurfacesPlacementApprovalAndFallback() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let quickCapture = app.buttons["shell.command.action.quick_capture"]
        XCTAssertTrue(quickCapture.waitForExistence(timeout: 10))
        quickCapture.tap()

        let input = shellCaptureInput(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("play pickleball at 8 next Tuesday")
        dismissKeyboardIfNeeded(in: app)

        XCTAssertTrue(app.buttons["shell.command.submit-capture-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)
    }

    func testShellCommandSheetCanOpenAndNavigateToTime() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        XCTAssertTrue(app.buttons["shell.command.action.open_week"].waitForExistence(timeout: 10))
        app.buttons["shell.command.action.open_week"].tap()

        XCTAssertTrue(app.tabBars.buttons["Time"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Time"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetSupportsQuickCaptureFlow() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let quickCapture = app.buttons["shell.command.action.quick_capture"]
        XCTAssertTrue(quickCapture.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Quick action Sheet"].waitForExistence(timeout: 10))
        quickCapture.tap()

        let field = app.textFields["shell.command.capture-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("UI shell capture")
        dismissKeyboardIfNeeded(in: app)

        let submit = app.buttons["shell.command.submit-capture-button"]
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        submit.tap()

        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.staticTexts["Saved as Idea"].waitForExistence(timeout: 10))
    }

    func testShellOwnedCreateGoalFlowWorksFromCommandSheet() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let createAction = scrollUntilButtonHittable("shell.command.action.new_goal", fallbackLabel: "New goal", in: app)
        XCTAssertTrue(createAction.waitForExistence(timeout: 10))
        createAction.tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        let shellGoalTitle = "Shell Goal \(Int(Date().timeIntervalSince1970))"
        titleField.tap()
        titleField.typeText(shellGoalTitle)
        dismissKeyboardIfNeeded(in: app)
        XCTAssertTrue(scrollUntilStaticTextExists("Pacing", in: app))

        let submitButton = scrollUntilButtonHittable("create-goal.submit-button", in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30) || scrollUntilStaticTextExists(shellGoalTitle, in: app, maxAttempts: 12))
    }

    func testDemoGoalsAtlasLoadsCoreModules() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        XCTAssertTrue(app.staticTexts["Your Direction"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Direction Atlas"].exists)
        XCTAssertTrue(app.staticTexts["Thread Focus"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.life-areas.equal-weight-band"].waitForExistence(timeout: 5))
        XCTAssertTrue(openGoalsOrbitalLens(in: app))
        XCTAssertTrue(app.staticTexts["Thread Focus"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.orbital-lens.proof"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.orbital-lens.source"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.orbital-lens.why"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["goals.orbital-lens.open-thread"].waitForExistence(timeout: 5))
        XCTAssertTrue(openGoalsDirectionDepth(in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.week-pressure", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.portfolio-maturity", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.life-areas-panel", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.life-areas.controls", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.north-stars-rail", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.one-step-goals-panel", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.band.active_direction", in: app))
    }

    func testAMB963GoalsReconstructionScreenshotMatrix() throws {
        struct GoalsMatrixItem {
            let name: String
            let bootstrap: String
            let renderState: String?
            let contentSizeCategory: String
            let requiredIdentifiers: [String]
            let requiredTexts: [String]
        }

        let matrix: [GoalsMatrixItem] = [
            GoalsMatrixItem(
                name: "default",
                bootstrap: "demo",
                renderState: "default",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.constellation-atlas.stage",
                    "goals.constellation-atlas.object",
                    "goals.life-areas.equal-weight-band",
                    "goals.orbital-lens.collapsed",
                    "goals.source-proof-trust"
                ],
                requiredTexts: ["Your Direction", "Thread Focus", "Source", "Today link"]
            ),
            GoalsMatrixItem(
                name: "selected-life-area",
                bootstrap: "demo",
                renderState: "selected-life-area",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.life-areas.equal-weight-band",
                    "goals.orbital-lens.collapsed",
                    "goals.constellation-atlas.object"
                ],
                requiredTexts: ["Career", "Thread Focus"]
            ),
            GoalsMatrixItem(
                name: "proof-source-visible",
                bootstrap: "demo",
                renderState: "proof-available",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.orbital-lens.expanded",
                    "goals.orbital-lens.proof",
                    "goals.orbital-lens.source",
                    "goals.orbital-lens.why"
                ],
                requiredTexts: ["Proof available", "Source", "Why this?"]
            ),
            GoalsMatrixItem(
                name: "large-dynamic-type",
                bootstrap: "demo",
                renderState: "selected-life-area",
                contentSizeCategory: "UICTContentSizeCategoryXXXL",
                requiredIdentifiers: [
                    "goals.constellation-atlas.stage",
                    "goals.life-areas.equal-weight-band",
                    "goals.orbital-lens.collapsed"
                ],
                requiredTexts: ["Your Direction", "Thread Focus", "Relations"]
            )
        ]

        for item in matrix {
            let app = makeApp(
                bootstrapMode: item.bootstrap,
                extraEnvironment: item.renderState.map { ["AmbitionsGoalsRenderState": $0] } ?? [:],
                contentSizeCategory: item.contentSizeCategory
            )
            app.launch()

            if item.bootstrap == "demo" {
                XCTAssertTrue(waitForShellReady(in: app), "Shell should be ready for \(item.name).")
                XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10), "Goals tab should exist for \(item.name).")
                app.tabBars.buttons["Goals"].tap()
                if item.contentSizeCategory.contains("Accessibility") {
                    XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 20), "Goals screen should render for \(item.name).")
                } else {
                    XCTAssertTrue(waitForGoalsPrimaryObject(in: app), "Goals object should render for \(item.name).")
                }
            }

            XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10), "Goals screen should exist for \(item.name).")
            for identifier in item.requiredIdentifiers {
                XCTAssertTrue(
                    app.descendants(matching: .any)[identifier].waitForExistence(timeout: 10),
                    "\(identifier) should exist for \(item.name)."
                )
            }

            for text in item.requiredTexts {
                XCTAssertTrue(scrollUntilStaticTextExists(text, in: app, maxAttempts: 12), "\(text) should be visible for \(item.name).")
            }

            XCTAssertFalse(app.staticTexts["Direction Atlas"].exists, "Direction Atlas must not be visible for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Relationsh")).firstMatch.exists, "Relationship label must not truncate for \(item.name).")
            if item.name == "proof-source-visible" {
                XCTAssertTrue(app.staticTexts["Proof available"].isHittable, "Proof/source state should visibly expose proof before screenshot capture.")
            }
            captureGoalsScreenshot(named: "amb-963-goals-\(item.name)", in: app)
        }
    }

    func testDemoGoalsAtlasPrimaryActionAndCardRouteToGoalDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        tapGoalsHeroPrimaryAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.mission-control"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.lane.overview", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.lane.steps", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.lane.decisions", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.lane.risks", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.lane.archive", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.decisions", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.risks", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.archive", in: app))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.path-builder", in: app, maxAttempts: 20))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.tactics-region", in: app))
    }

    func testPreviewLegacyInsightsTabRouteLandsUnderYouHistory() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/insights")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["You"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["insights.history.screen"].waitForExistence(timeout: 10))
    }

    func testPreviewInsightsMonthlyReviewCanHandOffToTime() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://insights/monthly-review")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.monthly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("insights.review-constellation", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Review shaping", in: app))
    }

    func testPreviewInsightsHistoryRouteCanHandOffToTime() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://insights/history")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.history.screen"].waitForExistence(timeout: 10))
        let timeButton = scrollUntilButtonHittable("insights.history.open-weekly-review", in: app)
        XCTAssertTrue(timeButton.waitForExistence(timeout: 10))
        timeButton.tap()

        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
    }

    func testMemoryLensCanOpenAndRouteToCanonicalWeekDestination() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        let memoryButton = app.buttons["shell.today.memory-lens-button"]
        XCTAssertTrue(memoryButton.waitForExistence(timeout: 10))
        memoryButton.tap()

        let searchField = app.textFields["shell.memory-lens.search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))

        let result = app.buttons["shell.memory-lens.result.memory-week"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
        result.tap()

        XCTAssertTrue(app.tabBars.buttons["Time"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Time"].isSelected)
    }

    func testTodaySurfaceShowsDominantHeroAndPrimaryAction() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityMeridianFusedRail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailStartHereTitle"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStartHereSourceFreshness"].waitForExistence(timeout: 10))
        XCTAssertTrue(todayPrimaryAction(in: app).waitForExistence(timeout: 10) || app.staticTexts["Start now"].exists || app.staticTexts["Open Time"].exists)
        XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailTopologyStrip", in: app))
        XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailNowSection", in: app))
        XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailNextSection", in: app))
        XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailLaterSection", in: app))
    }

    func testUIQL003TodayRealityMeridianOwnsFirstViewportWithoutGenericTaskAnatomy() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_PREVIEW_TODAY_SCENARIO": "stable"]
        )
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 90))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))

        let tabBar = app.tabBars.firstMatch
        _ = tabBar.waitForExistence(timeout: 2)

        let firstViewportMaxY = tabBar.exists ? tabBar.frame.minY : window.frame.maxY
        let requiredVisibleObjects = [
            app.staticTexts["Start here"],
            app.staticTexts["On-device"],
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Up next")).firstMatch
        ]

        for element in requiredVisibleObjects {
            XCTAssertTrue(element.waitForExistence(timeout: 10), "\(element) should be visible in the Today object stage.")
            XCTAssertLessThanOrEqual(element.frame.midY, firstViewportMaxY, "\(element) should be visible before the native dock.")
        }

        let headlineCandidates = [
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Draft the talk outline")).firstMatch,
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "No step is required")).firstMatch
        ]
        let visibleHeadline = headlineCandidates.first { $0.waitForExistence(timeout: 3) }
        XCTAssertNotNil(visibleHeadline, "Today should render either the preview recommendation or the empty Start here fallback.")
        if let visibleHeadline {
            XCTAssertLessThanOrEqual(visibleHeadline.frame.midY, firstViewportMaxY, "Today headline should be visible before the native dock.")
        }

        let forbiddenVisibleCopy = [
            "Recommended next move",
            ["next", "best", "move"].joined(separator: " "),
            ["Begin", "Focus"].joined(separator: " "),
            "task list",
            "No recommended step fits right now.",
            "Standalone tasks stay small.",
            "No blank dashboard"
        ]
        for copy in forbiddenVisibleCopy {
            XCTAssertFalse(app.staticTexts[copy].exists, "Today should not render stale or generic copy: \(copy)")
        }

        let recommendationMeta = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "Recommended step"))
            .firstMatch
        XCTAssertTrue(recommendationMeta.waitForExistence(timeout: 10), "Start Here should explicitly frame the object as a Recommended step.")
        XCTAssertTrue(todayPrimaryAction(in: app).waitForExistence(timeout: 10), "Start Here should expose the primary action.")
        XCTAssertTrue(app.descendants(matching: .any)["TodayMFPWhyThis"].waitForExistence(timeout: 10), "Start Here should expose a Why this? receipt control.")
        XCTAssertTrue(app.descendants(matching: .any)["TodayMFPAdjust"].waitForExistence(timeout: 10), "Start Here should expose an adjustment control.")

        XCTAssertTrue(openTodayStepDetail(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetail"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailTitle", in: app), "Step detail should preserve the selected recommendation title.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailDurationLabel", in: app), "Step detail should expose time-fit evidence.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailSourceLabel", in: app), "Step detail should expose source evidence.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailContextLabel", in: app), "Step detail should expose context evidence.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailGoalLinkLabel", in: app), "Step detail should expose goal binding.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailWhyThis", in: app), "Step detail should expose Why this? reasoning.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailProofReceiptAccess", in: app), "Step detail should expose proof and receipt access.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailPrimaryAction", in: app), "Step detail should expose the primary Start Here action.")
        XCTAssertTrue(scrollUntilElementExists("TodayStepDetailClosureAction", in: app), "Step detail should expose closure/recovery access.")
    }

    func testAMB962TodayReconstructionScreenshotMatrix() throws {
        let matrix: [(name: String, scenario: String, contentSize: String, sheet: String?, required: [String])] = [
            (
                name: "default",
                scenario: "stable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Recommended step", "Why this?", "Up next"]
            ),
            (
                name: "source-unavailable",
                scenario: "source-unavailable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Needs context. Manual planning still works.", "Why this?"]
            ),
            (
                name: "active-recommended-step",
                scenario: "start-here-ready",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Start now", "Recommended step"]
            ),
            (
                name: "large-dynamic-type",
                scenario: "reflow",
                contentSize: "UICTContentSizeCategoryAccessibilityL",
                sheet: nil,
                required: ["Start here", "Recommended step"]
            ),
            (
                name: "receipt-visible",
                scenario: "stable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: "receipt",
                required: ["Start Here receipt seam", "Still counts", "Waiting", "Blocked", "Not needed"]
            ),
            (
                name: "reduce-motion-static-equivalent",
                scenario: "protected",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Recommended step", "Protected"]
            ),
            (
                name: "no-step-paths",
                scenario: "empty",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["No step is required right now", "Capture what changed", "Shape Time", "Review context", "Record outcome", "Protect this window"]
            )
        ]

        for item in matrix {
            var environment = [
                "AMBITIONS_PREVIEW_TODAY_SCENARIO": item.scenario,
                "AmbitionsInitialSurface": "today",
                "AmbitionsScreenshotMode": "YES"
            ]
            if let sheet = item.sheet {
                environment["AmbitionsTodaySheet"] = sheet
            }

            let app = makeApp(
                bootstrapMode: "preview",
                extraEnvironment: environment,
                contentSizeCategory: item.contentSize
            )
            app.launch()

            XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 90), "Today should be ready for \(item.name).")
            XCTAssertTrue(
                todayRealityMeridianAnchorExists(in: app),
                "Today should expose the Reality Meridian or Start Here anchor for \(item.name)."
            )

            for copy in item.required {
                XCTAssertTrue(
                    scrollUntilStaticTextExists(copy, in: app, maxAttempts: 8),
                    "Missing required AMB-962 copy '\(copy)' in \(item.name)."
                )
            }

            captureTodayScreenshot(named: "amb-962-\(item.name)", in: app)
            app.terminate()
        }
    }

    func testCreateGoalShowsClarificationWhenRequired() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        let createButton = goalCreateButton(in: app)
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("I don't know where to start")
        dismissKeyboardIfNeeded(in: app)

        XCTAssertTrue(waitForClarificationCard(in: app))
    }

    func testLegacyCapturesInboxLaunchKeepsGlobalCaptureComposerReachable() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://captures/inbox",
            extraEnvironment: ["AMBITIONS_UI_SEED_CAPTURES": "1"]
        )
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(shellCaptureInput(in: app).waitForExistence(timeout: 10))
    }

    func testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let recoveryAction = scrollUntilButtonHittable("shell.command.action.quick_recovery", fallbackLabel: "Recover", in: app)
        XCTAssertTrue(recoveryAction.waitForExistence(timeout: 10))
        recoveryAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRail"].exists)

        let reopenedCommandButton = shellCommandButton(in: app)
        XCTAssertTrue(reopenedCommandButton.waitForExistence(timeout: 10))
        reopenedCommandButton.tap()
        let focusAction = scrollUntilButtonHittable("shell.command.action.quick_focus", fallbackLabel: "Focus", in: app)
        XCTAssertTrue(focusAction.waitForExistence(timeout: 10))
        focusAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["today.hero.reentry"].exists || app.descendants(matching: .any)["TodayRealityRail"].exists)
    }

    func testTodayStartNowCanOpenBoundedStepSession() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(openTodayStepDetail(in: app))
        let primaryAction = app.descendants(matching: .any)["TodayStepDetailPrimaryAction"]
        XCTAssertTrue(primaryAction.waitForExistence(timeout: 10))
        XCTAssertTrue(primaryAction.label == "Start now" || app.staticTexts["Start now"].exists)
    }

    func testTodayCanHandOffToGoalDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(openTodayStepDetail(in: app))

        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetailWhyThis"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetailPrimaryAction"].waitForExistence(timeout: 10))
    }

    func testGoalDetailTrustAndMemoryDisclosureStayBelowStrategicLayer() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(openCanonicalDestination("Goals", screenIdentifier: "goals.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        tapGoalsHeroPrimaryAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.path-filmstrip", in: app))

        XCTAssertTrue(scrollUntilElementExists("goal-detail.trust-whisper", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.memory-narrative", in: app, maxAttempts: 24))
    }

    func testTodayCanHandOffToTime() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(openCanonicalDestination("Time", screenIdentifier: "time.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 10))
    }

    func testAMB965MotionReconstructionScreenshotMatrix() throws {
        struct MotionMatrixItem {
            let name: String
            let renderState: String?
            let contentSizeCategory: String
            let requiredIdentifiers: [String]
            let requiredTexts: [String]
            let scrollTargetIdentifier: String?
        }

        let matrix: [MotionMatrixItem] = [
            MotionMatrixItem(
                name: "default",
                renderState: nil,
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "motion.current.field",
                    "motion.current.fact.source",
                    "motion.current.fact.proof",
                    "motion.current.fact.receipt",
                    "motion.current.action.reenter-thread"
                ],
                requiredTexts: ["Motion Current", "Proof available", "Inspect proof", "Re-enter thread"],
                scrollTargetIdentifier: nil
            ),
            MotionMatrixItem(
                name: "empty",
                renderState: "empty",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "motion.current.field",
                    "motion.current.action.inspect-proof"
                ],
                requiredTexts: ["No proof yet", "Empty proof state", "Open receipt"],
                scrollTargetIdentifier: nil
            ),
            MotionMatrixItem(
                name: "proof-recovery-reentry",
                renderState: "reentry",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "motion.current.action.reenter-thread",
                    "motion.current.rhythm-spine"
                ],
                requiredTexts: ["Re-entry available", "Last honest point", "Start again"],
                scrollTargetIdentifier: nil
            ),
            MotionMatrixItem(
                name: "receipt-dock-clearance",
                renderState: "recovery",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "motion.current.source-proof-receipt",
                    "motion.current.continuity-dock"
                ],
                requiredTexts: ["Recovery active", "Why this?", "Open Trust"],
                scrollTargetIdentifier: "motion.current.continuity-dock"
            ),
            MotionMatrixItem(
                name: "large-dynamic-type",
                renderState: "proof",
                contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL",
                requiredIdentifiers: [
                    "motion.current.field",
                    "motion.current.action-strip"
                ],
                requiredTexts: ["Proof available", "Closure source", "Re-enter thread"],
                scrollTargetIdentifier: nil
            )
        ]

        for item in matrix {
            var environment = [
                "AmbitionsScreenshotMode": "YES"
            ]
            if let renderState = item.renderState {
                environment["AmbitionsMotionRenderState"] = renderState
            }

            let app = makeApp(
                bootstrapMode: "demo",
                launchURL: "ambitions://tab/motion",
                extraEnvironment: environment,
                contentSizeCategory: item.contentSizeCategory
            )
            app.launch()

            XCTAssertTrue(waitForSelectedTab("Motion", in: app), "Motion should be selected for \(item.name).")
            dismissContinuityReceiptIfPresent(in: app)
            XCTAssertTrue(app.descendants(matching: .any)["motion.current.screen"].waitForExistence(timeout: 20), "Motion screen should exist for \(item.name).")
            XCTAssertTrue(app.descendants(matching: .any)["motion.current.field"].waitForExistence(timeout: 10), "Motion Current field should exist for \(item.name).")

            for identifier in item.requiredIdentifiers {
                XCTAssertTrue(
                    scrollUntilElementExists(identifier, in: app, maxAttempts: 10),
                    "\(identifier) should exist for \(item.name)."
                )
            }

            for text in item.requiredTexts {
                XCTAssertTrue(
                    scrollUntilStaticTextExists(text, in: app, maxAttempts: 10),
                    "Missing required AMB-965 copy '\(text)' in \(item.name)."
                )
            }

            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "analytics")).firstMatch.exists, "Motion must not read as analytics for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "dashboard")).firstMatch.exists, "Motion must not read as a dashboard for \(item.name).")
            XCTAssertTrue(app.tabBars.element.waitForExistence(timeout: 5), "Motion bottom dock should remain visible for \(item.name).")

            if let scrollTargetIdentifier = item.scrollTargetIdentifier {
                XCTAssertTrue(
                    scrollMotionContentToVisible(identifier: scrollTargetIdentifier, in: app),
                    "\(scrollTargetIdentifier) should be visible for \(item.name)."
                )
            }
            if item.name == "large-dynamic-type" {
                XCTAssertTrue(
                    scrollMotionContentToVisible(identifier: "motion.current.action-strip", in: app),
                    "Motion action strip should be visible for large Dynamic Type."
                )
            }

            captureMotionScreenshot(named: "amb-965-motion-\(item.name)", in: app)
            app.terminate()
        }
    }

    func testDemoTimeWorkspaceShowsBatch49CoreModules() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["LifeShape Field"].waitForExistence(timeout: 10))
    }

    func testAMB964TimeReconstructionScreenshotMatrix() throws {
        struct TimeMatrixItem {
            let name: String
            let renderState: String
            let contentSizeCategory: String
            let requiredIdentifiers: [String]
            let requiredTexts: [String]
        }

        let matrix: [TimeMatrixItem] = [
            TimeMatrixItem(
                name: "default-week",
                renderState: "default-week",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field",
                    "time.life-shape-field.capacity-statement",
                    "time.life-shape-field.action.shape-week"
                ],
                requiredTexts: ["LifeShape Field", "This week can hold", "Shape week"]
            ),
            TimeMatrixItem(
                name: "pressure-protected",
                renderState: "pressure-cluster",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field.action.review-pressure",
                    "time.life-shape-field.action.protect-block",
                    "time.life-shape-field.pressure-canvas-engine"
                ],
                requiredTexts: ["Review pressure", "Protect this block", "Pressure"]
            ),
            TimeMatrixItem(
                name: "source-unavailable-manual",
                renderState: "manual-only",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field.action.adjust-plan"
                ],
                requiredTexts: ["Manual Time source", "Adjust plan", "No external calendar source is required"]
            ),
            TimeMatrixItem(
                name: "static-equivalent",
                renderState: "calendar-denied",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field.capacity-statement"
                ],
                requiredTexts: ["This week can hold", "Calendar denied", "User choice"]
            ),
            TimeMatrixItem(
                name: "large-dynamic-type",
                renderState: "pressure-cluster",
                contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL",
                requiredIdentifiers: [
                    "time.life-shape-field",
                    "time.life-shape-field.capacity-statement"
                ],
                requiredTexts: ["This week can hold", "focused block", "light step", "protected recovery window"]
            )
        ]

        for item in matrix {
            let app = makeApp(
                bootstrapMode: "demo",
                launchURL: "ambitions://tab/plan",
                extraEnvironment: [
                    "AmbitionsTimeRenderState": item.renderState,
                    "AmbitionsScreenshotMode": "YES"
                ],
                contentSizeCategory: item.contentSizeCategory
            )
            app.launch()

            XCTAssertTrue(waitForSelectedTab("Time", in: app), "Time should be selected for \(item.name).")
            dismissContinuityReceiptIfPresent(in: app)
            XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 20), "Time screen should exist for \(item.name).")
            XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10), "LifeShape Field should exist for \(item.name).")

            for identifier in item.requiredIdentifiers {
                XCTAssertTrue(
                    scrollUntilElementExists(identifier, in: app, maxAttempts: 10),
                    "\(identifier) should exist for \(item.name)."
                )
            }

            for text in item.requiredTexts {
                XCTAssertTrue(
                    scrollUntilStaticTextExists(text, in: app, maxAttempts: 10),
                    "Missing required AMB-964 copy '\(text)' in \(item.name)."
                )
            }

            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "KPI")).firstMatch.exists, "Time must not read as KPI dashboard for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "capacity")).firstMatch.exists, "Time must not use capacity semantics for \(item.name).")
            if item.name == "large-dynamic-type" {
                scrollTimeContentToCapacityProof(in: app)
            }
            captureTimeScreenshot(named: "amb-964-time-\(item.name)", in: app)
            app.terminate()
        }
    }

    func testDemoTimePressureScrubberUpdatesSelectedDayAndReflowDecision() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(openTimeShapeDepth(in: app))
        XCTAssertTrue(scrollUntilElementExists("time.pressure-scrubber", in: app, maxAttempts: 40))
        let scrubPoint = app.buttons["time.scrubber.point.day-2"]
        XCTAssertTrue(scrubPoint.waitForExistence(timeout: 10))
        scrubPoint.tap()
        XCTAssertEqual(scrubPoint.value as? String, "selected")

        XCTAssertTrue(scrollUntilElementExists("time.reality-reflow", in: app, maxAttempts: 20))
        XCTAssertTrue(scrollUntilElementExists("time.reflow-decision", in: app, maxAttempts: 20))
    }

    private func makeApp(
        bootstrapMode: String,
        launchURL: String? = nil,
        extraEnvironment: [String: String] = [:],
        contentSizeCategory: String = "UICTContentSizeCategoryM"
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        app.launchEnvironment["AMBITIONS_SHELL_PRESENTATION"] = "native"
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", bootstrapMode]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSizeCategory]
        app.launchArguments += ["--ambitions-shell", "native"]
        if let launchURL {
            app.launchEnvironment["AMBITIONS_LAUNCH_URL"] = launchURL
            app.launchArguments += ["-AMBITIONS_LAUNCH_URL", launchURL]
        }
        for (key, value) in extraEnvironment {
            app.launchEnvironment[key] = value
            app.launchArguments += ["-\(key)", value]
        }
        return app
    }

    private func dismissKeyboardIfNeeded(in app: XCUIApplication) {
        let keyboard = app.keyboards.element
        guard keyboard.exists else { return }

        let dismissButtons = [
            keyboard.buttons["Return"],
            keyboard.buttons["Done"],
            keyboard.buttons["Hide keyboard"],
            app.toolbars.buttons["Done"]
        ]

        if let button = dismissButtons.first(where: { $0.waitForExistence(timeout: 1) && $0.isHittable }) {
            button.tap()
            return
        }

        app.swipeUp()
    }

    private func goalCreateButton(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            goalsHeroPrimaryAction(in: app),
            app.buttons["goals.empty.create-goal"],
            app.buttons["goals.create-button"],
            app.buttons["shell.goals.create-button"],
            app.navigationBars.buttons["goals.create-button"],
            app.buttons["Create your first goal"],
            app.buttons["Create Goal"],
            app.navigationBars.buttons["Create Goal"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons["goals.create-button"]
    }

    private func goalTitleInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["create-goal.title-field"],
            app.textViews["create-goal.title-field"],
            app.textFields["What do you want to make real?"],
            app.textViews["What do you want to make real?"],
            app.textFields.element(boundBy: 0),
            app.textViews.element(boundBy: 0)
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["create-goal.title-field"]
    }

    private func shellCaptureInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["shell.activated-capture.input"],
            app.textViews["shell.activated-capture.input"],
            app.textFields["shell.command.capture-field"],
            app.textViews["shell.command.capture-field"],
            app.textFields["shell.overlay.quick-capture-field"],
            app.textViews["shell.overlay.quick-capture-field"],
            app.textFields["What needs to be remembered?"],
            app.textViews["What needs to be remembered?"],
            app.textFields.element(boundBy: 0),
            app.textViews.element(boundBy: 0)
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["shell.command.capture-field"]
    }

    private func captureQuickInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["capture.quick-input"],
            app.textViews["capture.quick-input"],
            app.textFields["What needs a place?"],
            app.textViews["What needs a place?"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["capture.quick-input"]
    }

    private func tapCaptureNewGoal(in app: XCUIApplication, captureCard: XCUIElement) {
        let cardScopedButtons = captureCard.descendants(matching: .button)
            .matching(NSPredicate(format: "label == %@", "New goal"))
            .allElementsBoundByIndex
        if let control = cardScopedButtons.first(where: { $0.waitForExistence(timeout: 2) && $0.isEnabled && $0.isHittable }) {
            control.tap()
            return
        }

        let labeledButtons = app.buttons.matching(NSPredicate(format: "label == %@", "New goal")).allElementsBoundByIndex
        if let control = labeledButtons.first(where: { button in
            button.waitForExistence(timeout: 2)
                && button.identifier == "capture.new-goal.preview-capture-2"
                && button.isEnabled
                && button.isHittable
        }) {
            control.tap()
            return
        }

        captureCard.coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.82)).tap()
    }

    private func tapFirstHittableButton(identifier: String? = nil, named label: String, in app: XCUIApplication, timeout: TimeInterval = 10) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let controls: [XCUIElement]
            if let identifier {
                controls = app.descendants(matching: .any).matching(identifier: identifier).allElementsBoundByIndex
                    + app.buttons.matching(identifier: identifier).allElementsBoundByIndex
                    + app.buttons.matching(NSPredicate(format: "label == %@", label)).allElementsBoundByIndex
            } else {
                controls = app.buttons.matching(NSPredicate(format: "label == %@", label)).allElementsBoundByIndex
            }
            if let control = controls.first(where: { $0.waitForExistence(timeout: 1) && $0.isEnabled && $0.isHittable }) {
                control.tap()
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find hittable button named \(label).")
    }

    private func waitForClarificationCard(in app: XCUIApplication, timeout: TimeInterval = 12) -> Bool {
        let clarificationCard = app.descendants(matching: .any)["create-goal.clarification-card"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if clarificationCard.waitForExistence(timeout: 1) {
                return true
            }
            app.swipeUp()
        }

        return clarificationCard.exists
    }

    private func waitForCreateGoalComposer(in app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["create-goal.hero-card"],
            app.navigationBars["Create Goal"],
            app.staticTexts["Strategy Composer"],
            app.textFields["create-goal.title-field"],
            app.textFields["What do you want to make real?"],
            app.buttons["Cancel"]
        ]

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return candidates.contains(where: { $0.exists })
    }

    private func waitForCreatedGoalAcknowledgement(title: String, in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let message = app.descendants(matching: .any)["goals.creation-message"]
        let titleText = app.staticTexts[title]
        let goalsScreen = app.descendants(matching: .any)["goals.screen"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if message.waitForExistence(timeout: 1) || titleText.exists {
                return true
            }
            if goalsScreen.exists {
                app.swipeUp()
            }
        }

        return message.exists || titleText.exists
    }

    private func goalsHeroPrimaryAction(in app: XCUIApplication) -> XCUIElement {
        let button = app.buttons["goals.hero.primary-action"]
        if button.waitForExistence(timeout: 2) {
            return button
        }

        let fallback = app.descendants(matching: .any)["goals.hero.primary-action"]
        _ = fallback.waitForExistence(timeout: 2)
        return fallback
    }

    private func waitForGoalsPrimaryObject(in app: XCUIApplication, timeout: TimeInterval = 20) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["goals.constellation-atlas.stage"],
            app.descendants(matching: .any)["goals.constellation-atlas.object"],
            app.descendants(matching: .any)["goals.mission-control-lanes"],
            app.descendants(matching: .any)["goals.life-path"],
            app.descendants(matching: .any)["goals.hero-card"]
        ]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return candidates.contains(where: { $0.exists })
    }

    private func openGoalsDirectionDepth(in app: XCUIApplication) -> Bool {
        if app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 1) {
            return true
        }

        let toggle = app.buttons["goals.direction-depth-toggle"]
        if toggle.waitForExistence(timeout: 2) {
            toggle.tap()
            return app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 5)
        }

        let title = app.staticTexts["Direction depth"]
        for _ in 0..<8 {
            if title.exists || title.waitForExistence(timeout: 0.25) {
                title.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                return app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 5)
            }
            scrollPageUp(in: app)
        }

        return false
    }

    private func openGoalsOrbitalLens(in app: XCUIApplication) -> Bool {
        if app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 1) {
            return true
        }

        let toggle = app.buttons["goals.orbital-lens.toggle"]
        if toggle.waitForExistence(timeout: 2) {
            toggle.tap()
            return app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 5)
        }

        let lens = app.descendants(matching: .any)["goals.orbital-lens.collapsed"]
        if lens.waitForExistence(timeout: 2) {
            lens.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()
            return app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 5)
        }

        return false
    }

    private func tapGoalsHeroPrimaryAction(in app: XCUIApplication) {
        let direct = goalsHeroPrimaryAction(in: app)
        if direct.exists && direct.isHittable {
            direct.tap()
            return
        }

        let heroButton = app.buttons["goals.hero-card"]
        if heroButton.waitForExistence(timeout: 10) {
            heroButton.tap()
            return
        }

        let heroCard = app.descendants(matching: .any)["goals.hero-card"].firstMatch
        XCTAssertTrue(heroCard.waitForExistence(timeout: 10))
        heroCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82)).tap()
    }

    private func tapFirstVisibleGoalCard(in app: XCUIApplication) {
        app.swipeUp()
        app.swipeUp()
        let cardCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
        cardCoordinate.tap()
    }

    private func shellCommandButton(in app: XCUIApplication) -> XCUIElement {
        let identified = app.buttons["shell.global-entry-button"]
        if identified.waitForExistence(timeout: 2) {
            return identified
        }
        let currentLabel = app.buttons["Capture"]
        if currentLabel.waitForExistence(timeout: 2) {
            return currentLabel
        }
        let labeled = app.buttons["Quick action Sheet"]
        _ = labeled.waitForExistence(timeout: 2)
        return labeled
    }

    private func openCanonicalDestination(_ title: String, screenIdentifier: String, in app: XCUIApplication, timeout: TimeInterval = 20) -> Bool {
        let screen = app.descendants(matching: .any)[screenIdentifier]
        if screen.waitForExistence(timeout: 1) {
            return true
        }

        guard tapCanonicalDestination(title, in: app) else {
            return false
        }

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if screen.waitForExistence(timeout: 1) {
                return true
            }
        }

        if title != "Today", tapCanonicalDestination("Today", in: app), tapCanonicalDestination(title, in: app) {
            let retryDeadline = Date().addingTimeInterval(timeout)
            while Date() < retryDeadline {
                if screen.waitForExistence(timeout: 1) {
                    return true
                }
            }
        }

        return screen.exists
    }

    private func screenIdentifier(forTab title: String) -> String {
        switch title {
        case "Today": "today.screen"
        case "Goals": "goals.screen"
        case "Time": "time.screen"
        case "Motion": "motion.current.screen"
        case "You": "you.screen"
        default: "\(title.lowercased()).screen"
        }
    }

    private func captureShellScreenshot(named tabName: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "afri-005-shell-\(tabName)"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.tabBars.element.waitForExistence(timeout: 5))
    }

    private func captureTodayScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(todayRealityMeridianAnchorExists(in: app))
    }

    private func captureGoalsScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].exists)
    }

    private func captureTimeScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].exists)
    }

    private func captureMotionScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["motion.current.screen"].exists)
    }

    private func captureYouScreenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(app.descendants(matching: .any)["you.screen"].exists)
    }

    private func captureAMB967Screenshot(named name: String, in app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertTrue(
            app.descendants(matching: .any)["shell.activated-capture-seam"].exists
                || app.descendants(matching: .any)["create-goal.hero-card"].exists
                || app.staticTexts["Shape the first path"].exists
        )
    }

    private func scrollYouContentToVisible(identifier: String, in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["you.scroll"]
        let target = app.descendants(matching: .any)[identifier]
        let safeBand = CGRect(x: 0, y: 118, width: 1_000, height: 572)

        for _ in 0..<14 {
            if target.exists, target.frame.intersects(safeBand), target.frame.minY < 690 {
                return true
            }

            if scrollView.waitForExistence(timeout: 1) {
                scrollView.swipeUp()
            } else {
                app.swipeUp()
            }
        }

        return target.exists && target.frame.intersects(safeBand)
    }

    private func scrollMotionContentToVisible(identifier: String, in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["motion.current.scroll"]
        let target = app.descendants(matching: .any)[identifier]

        for _ in 0..<14 {
            if target.exists, target.frame.minY > 118, target.frame.maxY < 690 {
                return true
            }
            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }

        return target.exists && target.frame.maxY < 760
    }

    private func scrollTimeContentToCapacityProof(in app: XCUIApplication) {
        let scrollView = app.scrollViews["time.content-scroll"]
        let target = app.descendants(matching: .any)["time.life-shape-field.capacity-statement"]

        for _ in 0..<12 {
            if target.exists, target.frame.minY > 120, target.frame.maxY < 620 {
                return
            }
            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }
    }

    private func assertFrame(_ frame: CGRect, isInside container: CGRect, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(frame.minX, container.minX, "\(name) extends past the leading safe boundary.", file: file, line: line)
        XCTAssertGreaterThanOrEqual(frame.minY, container.minY, "\(name) extends above the top safe boundary.", file: file, line: line)
        XCTAssertLessThanOrEqual(frame.maxX, container.maxX, "\(name) extends past the trailing safe boundary.", file: file, line: line)
        XCTAssertLessThanOrEqual(frame.maxY, container.maxY, "\(name) extends below the bottom safe boundary.", file: file, line: line)
    }

    private func tapCanonicalDestination(_ title: String, in app: XCUIApplication) -> Bool {
        let dockButton = app.descendants(matching: .any)["shell.meridian.destination.\(title.lowercased())"]
        if dockButton.waitForExistence(timeout: 5) {
            if dockButton.isHittable {
                dockButton.tap()
            } else {
                dockButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }

        let labeledDockButton = app.buttons[title]
        if labeledDockButton.waitForExistence(timeout: 2) {
            if labeledDockButton.isHittable {
                labeledDockButton.tap()
            } else {
                labeledDockButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }

        let tabButton = app.tabBars.buttons[title]
        if tabButton.waitForExistence(timeout: 5) {
            if tabButton.isHittable {
                tabButton.tap()
            } else {
                tabButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }

        let meridianButton = app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
        guard meridianButton.waitForExistence(timeout: 5) else {
            return false
        }
        meridianButton.tap()
        return true
    }

    private func assertShellFloatingButtonDoesNotCoverTabBar(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let tabBar = app.tabBars.firstMatch
        let button = shellCommandButton(in: app)
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertTrue(button.waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertFalse(tabBar.frame.intersects(button.frame), "Global add button overlaps the tab bar.", file: file, line: line)
    }

    private func youRow(named title: String, in app: XCUIApplication) -> XCUIElement {
        let identifier = youRowIdentifier(for: title)
        let stableButton = app.buttons["you.row.\(identifier)"]
        if stableButton.exists {
            return stableButton
        }

        let stableAny = app.descendants(matching: .any)["you.row.\(identifier)"]
        if stableAny.exists {
            if stableAny.elementType == .button {
                return stableAny
            }

            if stableAny.buttons.firstMatch.exists {
                return stableAny.buttons.firstMatch
            }
        }

        let textMatch = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", title)).firstMatch
        if textMatch.elementType == .button {
            return textMatch
        }

        if textMatch.buttons.firstMatch.exists {
            return textMatch.buttons.firstMatch
        }

        return textMatch
    }

    private func youRowIdentifier(for title: String) -> String {
        title
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }

    private func scrollUntilYouRowExists(named title: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        for _ in 0..<maxAttempts {
            let row = youRow(named: title, in: app)
            if row.waitForExistence(timeout: 2), row.isHittable {
                return true
            }
            app.swipeUp()
        }

        let row = youRow(named: title, in: app)
        return row.exists && row.isHittable
    }

    private func tapYouRow(named title: String, in app: XCUIApplication, maxAttempts: Int = 10) -> Bool {
        for _ in 0..<maxAttempts {
            let row = youRow(named: title, in: app)
            if row.waitForExistence(timeout: 2) {
                if row.isHittable {
                    row.tap()
                    return true
                } else {
                    app.swipeUp()
                }
            } else {
                app.swipeUp()
            }
        }

        return false
    }

    private func scrollUntilElementExists(identifier: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    private func openTodayStepDetail(in app: XCUIApplication) -> Bool {
        let existingDetail = app.descendants(matching: .any)["TodayStepDetail"]
        if existingDetail.waitForExistence(timeout: 1) {
            return true
        }

        let startHere = app.staticTexts["Start here"]
        if startHere.waitForExistence(timeout: 5) {
            startHere.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let rail = app.descendants(matching: .any)["TodayRealityRail"]
        guard rail.waitForExistence(timeout: 5) else {
            return false
        }
        rail.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.24)).tap()
        return existingDetail.waitForExistence(timeout: 10)
    }

    private func todayPrimaryAction(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["TodayRealityRailPrimaryAction"],
            app.buttons["today.hero.primary-action"],
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.")).firstMatch,
            app.descendants(matching: .any)["TodayRealityRailPrimaryAction"],
            app.descendants(matching: .any)["today.hero.primary-action"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.")).firstMatch
    }

    private func todayRealityMeridianAnchorExists(in app: XCUIApplication) -> Bool {
        let anchors = [
            app.descendants(matching: .any)["TodayRealityRail"],
            app.descendants(matching: .any)["TodayRealityRailStartHereTitle"],
            app.staticTexts["Start here"]
        ]

        return anchors.contains { $0.waitForExistence(timeout: 5) }
    }

    private func waitForTodayScreenReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let todayScreen = app.descendants(matching: .any)["today.screen"]
        let readinessCandidates = [
            app.descendants(matching: .any)["TodayRealityRail"],
            app.staticTexts["Start here"],
            app.staticTexts["On-device"]
        ]

        while Date() < deadline {
            let hasTodayContainer = todayScreen.waitForExistence(timeout: 1) || app.staticTexts["Start here"].exists
            if hasTodayContainer,
               readinessCandidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return (todayScreen.exists || app.staticTexts["Start here"].exists) && readinessCandidates.contains(where: { $0.exists })
    }

    private func waitForShellReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        app.tabBars.firstMatch.waitForExistence(timeout: timeout)
    }

    private func waitForSelectedTab(_ title: String, in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let button = app.tabBars.buttons[title]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if button.waitForExistence(timeout: 1), button.isSelected {
                return true
            }
        }

        return button.exists && button.isSelected
    }

    private func scrollUntilButtonHittable(_ identifier: String, fallbackLabel: String? = nil, in app: XCUIApplication, maxAttempts: Int = 8) -> XCUIElement {
        let fallbackButton = fallbackLabel.map {
            app.buttons.matching(NSPredicate(format: "label == %@", $0)).firstMatch
        }
        let fallbackAny = fallbackLabel.map {
            app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", $0)).firstMatch
        }

        func candidates() -> [XCUIElement] {
            var results: [XCUIElement] = [
                app.buttons[identifier],
                app.descendants(matching: .any)[identifier]
            ]

            if let fallbackButton {
                results.append(fallbackButton)
            }
            if let fallbackAny {
                results.append(fallbackAny)
            }

            return results
        }

        for _ in 0..<maxAttempts {
            for candidate in candidates() where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
                return candidate
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            for candidate in candidates() where candidate.isHittable {
                return candidate
            }
            scrollPageDown(in: app)
        }

        if let fallbackAny, fallbackAny.exists {
            return fallbackAny
        }

        return app.descendants(matching: .any)[identifier]
    }

    private func scrollUntilElementExists(_ identifier: String, in app: XCUIApplication, maxAttempts: Int = 8) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.exists || element.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            if element.exists || element.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageDown(in: app)
        }

        return element.exists
    }

    private func openTimeShapeDepth(in app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let expandedAnchor = app.descendants(matching: .any)["time.life-shape-field.drill-down"]
        let legacyExpandedAnchor = app.descendants(matching: .any)["time.timeline-strip"]
        if expandedAnchor.waitForExistence(timeout: 1) || legacyExpandedAnchor.waitForExistence(timeout: 1) {
            return true
        }

        let disclosure = app.descendants(matching: .any)["time.lifeshape-depth"]
        let title = app.staticTexts["LifeShape Field depth"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if disclosure.waitForExistence(timeout: 1), disclosure.isHittable {
                disclosure.tap()
                return expandedAnchor.waitForExistence(timeout: 5) || legacyExpandedAnchor.waitForExistence(timeout: 1)
            }

            if title.waitForExistence(timeout: 1), title.isHittable {
                title.tap()
                return expandedAnchor.waitForExistence(timeout: 5) || legacyExpandedAnchor.waitForExistence(timeout: 1)
            }

            scrollPageUp(in: app)
        }

        return expandedAnchor.exists || legacyExpandedAnchor.exists
    }

    private func scrollUntilStaticTextExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let exactStaticText = app.staticTexts[label]
        let exactButton = app.buttons[label]
        let matchingStaticText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch
        let matchingButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch

        for _ in 0..<maxAttempts {
            if exactStaticText.exists || exactStaticText.waitForExistence(timeout: 0.25) ||
                exactButton.exists || exactButton.waitForExistence(timeout: 0.25) ||
                matchingStaticText.exists || matchingStaticText.waitForExistence(timeout: 0.25) ||
                matchingButton.exists || matchingButton.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageUp(in: app)
        }

        for _ in 0..<maxAttempts {
            if exactStaticText.exists || exactStaticText.waitForExistence(timeout: 0.25) ||
                exactButton.exists || exactButton.waitForExistence(timeout: 0.25) ||
                matchingStaticText.exists || matchingStaticText.waitForExistence(timeout: 0.25) ||
                matchingButton.exists || matchingButton.waitForExistence(timeout: 0.25) {
                return true
            }
            scrollPageDown(in: app)
        }

        return exactStaticText.exists || exactButton.exists || matchingStaticText.exists || matchingButton.exists
    }

    private func scrollUntilButtonExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.buttons[label]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    private func scrollPageUp(in app: XCUIApplication) {
        app.swipeUp(velocity: .fast)
    }

    private func scrollPageDown(in app: XCUIApplication) {
        app.swipeDown(velocity: .fast)
    }

    private func dismissContinuityReceiptIfPresent(in app: XCUIApplication, timeout: TimeInterval = 4) {
        let shellDismissButton = app.buttons["action-closure-tray.dismiss-button"]
        if shellDismissButton.waitForExistence(timeout: timeout), shellDismissButton.isHittable {
            shellDismissButton.tap()
            return
        }

        let identifiedButton = app.buttons["trust.receipt-toast.dismiss-button"]
        if identifiedButton.waitForExistence(timeout: 0.5), identifiedButton.isHittable {
            identifiedButton.tap()
            return
        }

        let shellLabeledButton = app.buttons["Dismiss result"]
        if shellLabeledButton.waitForExistence(timeout: 0.5), shellLabeledButton.isHittable {
            shellLabeledButton.tap()
            return
        }

        let labeledButton = app.buttons["Dismiss receipt"]
        if labeledButton.waitForExistence(timeout: 0.5), labeledButton.isHittable {
            labeledButton.tap()
        }
    }

}
