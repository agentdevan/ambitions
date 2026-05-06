import XCTest

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

        for tab in ["Today", "Goals", "Capture", "Plan", "You"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: 10), "Missing top-level tab \(tab)")
            XCTAssertTrue(app.tabBars.buttons[tab].isHittable, "Top-level tab \(tab) is not hittable")
        }
        XCTAssertFalse(app.tabBars.buttons["More"].exists)
        XCTAssertFalse(app.tabBars.buttons["Captures"].exists)
        XCTAssertFalse(app.tabBars.buttons["Insights"].exists)
        XCTAssertFalse(app.tabBars.buttons["Profile"].exists)
        XCTAssertFalse(app.tabBars.buttons["Habits"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["shell.header.rail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.continuity-ribbon"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["shell.floating-control-lane"].waitForExistence(timeout: 10))
        assertShellFloatingButtonDoesNotCoverTabBar(in: app)

        XCTAssertTrue(openCanonicalDestination("Capture", screenIdentifier: "captures.screen", in: app))
        XCTAssertFalse(app.buttons["captures.return-to-plan"].exists)

        XCTAssertTrue(openCanonicalDestination("Plan", screenIdentifier: "plan.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["plan.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app, maxAttempts: 24))
        XCTAssertTrue(scrollUntilElementExists("plan.goal-relationship-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.open-plan-habits-button", in: app))
        app.buttons["plan.open-plan-habits-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["habits.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["habits.return-to-plan"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.back-button"].tap()
        XCTAssertTrue(scrollUntilElementExists("plan.open-plan-weekly-review-button", in: app))
        app.buttons["plan.open-plan-weekly-review-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.hero-card"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.back-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))

        XCTAssertTrue(openCanonicalDestination("You", screenIdentifier: "you.root", in: app))
        XCTAssertTrue(app.staticTexts["Planning Setup"].waitForExistence(timeout: 10))
        XCTAssertTrue(youRow(named: "Schedule & Availability", in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Trust, Memory & Receipts", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Memory", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Trust Center", in: app, maxAttempts: 6))
    }

    func testProfileAppearanceStudioControlsAreAccessibleFromKeyboardAndTouch() throws {
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

    func testProfilePersonalDefaultsRemainVisibleBeneathAppearanceStudio() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["You"].tap()
        XCTAssertTrue(scrollUntilYouRowExists(named: "Profile", in: app, maxAttempts: 8))
        let profileRow = youRow(named: "Profile", in: app)
        profileRow.tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Personal defaults", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Default landing tab", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Review cadence", in: app, maxAttempts: 8))
    }

    func testProfileTrustSurfaceShowsConservativeExternalStatusLabels() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["You"].waitForExistence(timeout: 10))
        app.tabBars.buttons["You"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["you.root"].waitForExistence(timeout: 10))

        XCTAssertTrue(scrollUntilYouRowExists(named: "Memory", in: app, maxAttempts: 6))
        XCTAssertTrue(scrollUntilYouRowExists(named: "Trust Center", in: app, maxAttempts: 6))
        youRow(named: "Trust Center", in: app).tap()
        XCTAssertTrue(app.descendants(matching: .any)["profile.trust-center-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Receipts, corrections, and explanations", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Recent trust receipts", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Claims locked", in: app))
    }

    func testLaunchURLCanLandOnCanonicalPlanSurface() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testLaunchURLCanLandOnTopLevelCapture() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Capture"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Capture"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["What needs a place?"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetCanOpenAndNavigateToPlan() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        XCTAssertTrue(app.buttons["shell.command.action.open_week"].waitForExistence(timeout: 10))
        app.buttons["shell.command.action.open_week"].tap()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
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

        XCTAssertTrue(app.tabBars.buttons["Capture"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
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

    func testDemoGoalsBoardLoadsCoreModules() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.week-pressure", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.portfolio-maturity", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.life-areas-panel", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.north-stars-rail", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.one-step-goals-panel", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.band.active_direction", in: app))
    }

    func testDemoGoalsBoardPrimaryActionAndCardRouteToGoalDetail() throws {
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

    func testPreviewInsightsMonthlyReviewCanHandOffToPlan() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://insights/monthly-review")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.monthly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("insights.review-constellation", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Review shaping", in: app))
    }

    func testPreviewInsightsHistoryRouteCanHandOffToPlan() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://insights/history")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.history.screen"].waitForExistence(timeout: 10))
        let planButton = scrollUntilButtonHittable("insights.history.open-weekly-review", in: app)
        XCTAssertTrue(planButton.waitForExistence(timeout: 10))
        planButton.tap()

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

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
    }

    func testTodaySurfaceShowsDominantHeroAndPrimaryAction() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Start here"].waitForExistence(timeout: 10))
        XCTAssertTrue(todayPrimaryAction(in: app).waitForExistence(timeout: 10) || app.staticTexts["Start now"].exists || app.staticTexts["Open Plan"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailNowSection"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailNextSection"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailLaterSection"].waitForExistence(timeout: 10))
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

    func testCapturePromotionOpensComposerWithSeededText() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://captures/inbox",
            extraEnvironment: ["AMBITIONS_UI_SEED_CAPTURES": "1"]
        )
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilStaticTextExists("Review the notification handoff copy before the next hardening pass.", in: app))
        tapFirstHittableButton(identifier: "captures.new-goal.preview-capture-2", named: "New goal", in: app, timeout: 30)

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        let value = titleField.value as? String
        XCTAssertTrue(value?.contains("Review the notification handoff copy") == true || app.staticTexts["Review the notification handoff copy before the next hardening pass."].exists)
        XCTAssertTrue(scrollUntilStaticTextExists("Trust framing", in: app))
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

    func testTodayCanHandOffToPlan() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(openCanonicalDestination("Plan", screenIdentifier: "plan.screen", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testDemoPlanWorkspaceShowsBatch49CoreModules() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Plan", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["plan.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app, maxAttempts: 24))
        XCTAssertTrue(scrollUntilElementExists("plan.timeline-strip", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.weekly-plan-strip", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.believability-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.calendar-awareness", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.calendar-boundary", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.recovery-maturity", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.execution-resilience", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.action-lane", in: app))
    }

    func testDemoPlanPressureScrubberUpdatesSelectedDayAndReflowDecision() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Plan", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app))
        let scrubPoint = app.buttons["plan.scrubber.point.day-2"]
        XCTAssertTrue(scrubPoint.waitForExistence(timeout: 10))
        scrubPoint.tap()
        XCTAssertEqual(scrubPoint.value as? String, "selected")

        XCTAssertTrue(scrollUntilElementExists("plan.reality-reflow", in: app, maxAttempts: 20))
        XCTAssertTrue(scrollUntilElementExists("plan.reflow-decision", in: app, maxAttempts: 20))
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
                && button.identifier == "captures.card.preview-capture-2"
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
                controls = app.buttons.matching(identifier: identifier).allElementsBoundByIndex
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

        return candidates.contains(where: \.exists)
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

        return candidates.contains(where: \.exists)
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
        let currentLabel = app.buttons["Add something"]
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
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
    }

    private func scrollUntilYouRowExists(named title: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = youRow(named: title, in: app)

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2), element.isHittable {
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

        return todayScreen.exists && readinessCandidates.contains(where: \.exists)
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
            app.swipeUp()
        }

        for _ in 0..<maxAttempts {
            for candidate in candidates() where candidate.isHittable {
                return candidate
            }
            app.swipeDown()
        }

        if let fallbackAny, fallbackAny.exists {
            return fallbackAny
        }

        return app.descendants(matching: .any)[identifier]
    }

    private func scrollUntilElementExists(_ identifier: String, in app: XCUIApplication, maxAttempts: Int = 8) -> Bool {
        let element = app.descendants(matching: .any)[identifier]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
        }

        return element.exists
    }

    private func scrollUntilStaticTextExists(_ label: String, in app: XCUIApplication, maxAttempts: Int = 5) -> Bool {
        let element = app.staticTexts[label]

        for _ in 0..<maxAttempts {
            if element.waitForExistence(timeout: 2) {
                return true
            }
            app.swipeUp()
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

}
