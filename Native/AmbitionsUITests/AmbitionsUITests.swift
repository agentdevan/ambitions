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
        XCTAssertFalse(app.descendants(matching: .any)["shell.continuity-ribbon"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["shell.today.capture-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["shell.today.memory-lens-button"].waitForExistence(timeout: 1))

        XCTAssertTrue(openCanonicalDestination("Motion", screenIdentifier: "motion.current.screen", in: app))

        XCTAssertTrue(openCanonicalDestination("Time", screenIdentifier: "time.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.reflow-trust-seam"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.decline"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.edit"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["time.life-shape-field.reflow.accept"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["time.hero-card"].waitForExistence(timeout: 1))

        XCTAssertTrue(openCanonicalDestination("You", screenIdentifier: "you.screen", in: app))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))
        XCTAssertTrue(youRow(named: "Schedule & Availability", in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Receipts & History", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Proof", in: app, maxAttempts: 6))

        XCTAssertTrue(openCanonicalDestination("Goals", screenIdentifier: "goals.screen", in: app))
        XCTAssertFalse(app.buttons["shell.goals.create-button"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["shell.goals.capture-button"].waitForExistence(timeout: 10))
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

        XCTAssertTrue(scrollUntilYouRowExists(named: "Personal Runtime", in: app, maxAttempts: 8))
        XCTAssertTrue(tapYouRow(named: "Personal Runtime", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["you.personal-runtime-status-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("runtime-backed", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("fixture-only", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("blocked-pending-model", in: app, maxAttempts: 8))
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
        XCTAssertTrue(scrollUntilStaticTextExists("blocked-pending-model", in: app, maxAttempts: 8))
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
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.tabBars.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.buttons["Pulse"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(shellCaptureInput(in: app).waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.staticTexts["Quiet Command Sheet"].waitForExistence(timeout: 10))
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
        XCTAssertTrue(app.descendants(matching: .any)["goals.life-areas.equal-weight-band"].waitForExistence(timeout: 5))
        XCTAssertTrue(openGoalsOrbitalLens(in: app))
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

    func testDemoTimeWorkspaceShowsBatch49CoreModules() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(openTimeShapeDepth(in: app))
        XCTAssertTrue(scrollUntilElementExists("time.timeline-strip", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.weekly-shaping-strip", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.believability-card", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.calendar-awareness", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.calendar-boundary", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.recovery-maturity", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.execution-resilience", in: app, maxAttempts: 40))
        XCTAssertTrue(scrollUntilElementExists("time.action-lane", in: app, maxAttempts: 40))
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
        extraEnvironment: [String: String] = [:]
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        app.launchEnvironment["AMBITIONS_SHELL_PRESENTATION"] = "native"
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", bootstrapMode]
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryM"]
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
            app.textFields["shell.command.capture-field"],
            app.textViews["shell.command.capture-field"],
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
        let labeled = app.buttons["Quiet Command Sheet"]
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

    private func tapCanonicalDestination(_ title: String, in app: XCUIApplication) -> Bool {
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

    private func waitForTodayScreenReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let todayScreen = app.descendants(matching: .any)["today.screen"]
        let readinessCandidates = [
            app.descendants(matching: .any)["TodayRealityRail"],
            app.descendants(matching: .any)["TodayRealityRailHeroCard"],
            app.descendants(matching: .any)["today.hero-card"]
        ]

        while Date() < deadline {
            if todayScreen.waitForExistence(timeout: 1),
               readinessCandidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return todayScreen.exists && readinessCandidates.contains(where: { $0.exists })
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
        let expandedAnchor = app.descendants(matching: .any)["time.timeline-strip"]
        if expandedAnchor.waitForExistence(timeout: 1) {
            return true
        }

        let disclosure = app.descendants(matching: .any)["time.lifeshape-depth"]
        let title = app.staticTexts["LifeShape Field depth"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if disclosure.waitForExistence(timeout: 1), disclosure.isHittable {
                disclosure.tap()
                return expandedAnchor.waitForExistence(timeout: 5)
            }

            if title.waitForExistence(timeout: 1), title.isHittable {
                title.tap()
                return expandedAnchor.waitForExistence(timeout: 5)
            }

            scrollPageUp(in: app)
        }

        return expandedAnchor.exists
    }

    private func scrollUntilStaticTextExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.staticTexts[label]

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
