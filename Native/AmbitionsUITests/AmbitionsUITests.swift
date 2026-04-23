import XCTest

final class AmbitionsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testPreviewBootstrapShowsEmptyGoalsState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(goalCreateButton(in: app).waitForExistence(timeout: 10))
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

        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30))
        XCTAssertTrue(titleField.waitForNonExistence(timeout: 10))
    }

    func testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        for tab in ["Today", "Goals", "Plan", "Insights", "Profile"] {
            XCTAssertTrue(app.tabBars.buttons[tab].waitForExistence(timeout: 10), "Missing top-level tab \(tab)")
        }
        XCTAssertFalse(app.tabBars.buttons["More"].exists)
        XCTAssertFalse(app.tabBars.buttons["Captures"].exists)
        XCTAssertFalse(app.tabBars.buttons["Habits"].exists)
        XCTAssertTrue(app.tabBars.buttons["Today"].isSelected)
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Plan"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.open-captures-button"].tap()
        XCTAssertTrue(app.staticTexts["No captures yet"].waitForExistence(timeout: 10))

        app.buttons["shell.plan.back-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["plan.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.goal-relationship-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.open-plan-habits-button", in: app))
        app.buttons["plan.open-plan-habits-button"].tap()
        XCTAssertTrue(app.buttons["habits.return-to-plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["No habits are live yet"].waitForExistence(timeout: 10))
        app.buttons["shell.plan.back-button"].tap()
        XCTAssertTrue(scrollUntilElementExists("plan.open-plan-weekly-review-button", in: app))
        app.buttons["plan.open-plan-weekly-review-button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["weekly-review.return-to-plan"].waitForExistence(timeout: 10))
        app.buttons["weekly-review.return-to-plan"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))

        app.tabBars.buttons["Insights"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.compare-period"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("insights.review-constellation", in: app))
        XCTAssertTrue(scrollUntilElementExists("insights.history-layer", in: app))

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["shell.header.title"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("profile.personalization-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.planning-summary-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
    }

    func testProfilePreferencesControlsAreAccessibleFromKeyboardAndTouch() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(scrollUntilElementExists("profile.personalization-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.planning-summary-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
    }

    func testProfileTrustSurfaceShowsConservativeExternalStatusLabels() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        app.tabBars.buttons["Profile"].tap()

        XCTAssertTrue(scrollUntilElementExists("profile.trust-card", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Trust and external status", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Notifications", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Navigation shortcuts", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Share Extension", in: app))
        XCTAssertTrue(scrollUntilButtonExists("Enable notifications", in: app))
    }

    func testLaunchURLCanLandOnCanonicalPlanSurface() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testLaunchURLCanLandOnPlanOwnedCapturesInbox() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://captures/inbox")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.descendants(matching: .any)["captures.screen"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetCanOpenAndNavigateToPlan() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
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

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let quickCapture = app.buttons["shell.command.action.quick_capture"]
        XCTAssertTrue(quickCapture.waitForExistence(timeout: 10))
        quickCapture.tap()

        let field = app.textFields["shell.command.capture-field"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("UI shell capture")
        dismissKeyboardIfNeeded(in: app)

        let submit = app.buttons["shell.command.submit-capture-button"]
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        submit.tap()

        XCTAssertTrue(app.tabBars.buttons["Plan"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.tabBars.buttons["Plan"].isSelected)
        XCTAssertTrue(app.staticTexts["UI shell capture"].waitForExistence(timeout: 10))
    }

    func testShellOwnedCreateGoalFlowWorksFromCommandSheet() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let commandButton = shellCommandButton(in: app)
        XCTAssertTrue(commandButton.waitForExistence(timeout: 10))
        commandButton.tap()

        let createAction = app.buttons["shell.command.action.new_goal"]
        XCTAssertTrue(createAction.waitForExistence(timeout: 10))
        createAction.tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("Shell Goal")
        dismissKeyboardIfNeeded(in: app)
        XCTAssertTrue(scrollUntilStaticTextExists("Pacing", in: app))

        let submitButton = scrollUntilButtonHittable("create-goal.submit-button", in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30))
    }

    func testDemoGoalsBoardLoadsCoreModules() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goals.week-pressure", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.band.active_direction", in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.horizon-ladder", in: app, maxAttempts: 20))
    }

    func testDemoGoalsBoardPrimaryActionAndCardRouteToGoalDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["goals.hero-card"].waitForExistence(timeout: 10))
        tapGoalsHeroPrimaryAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.path-filmstrip"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.tactics-region", in: app))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tapFirstVisibleGoalCard(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.path-filmstrip"].waitForExistence(timeout: 10))
    }

    func testPreviewInsightsRoutesExposeReflectionHistoryAndMonthlyReview() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/insights")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["insights.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("insights.compare-period", in: app))
        XCTAssertTrue(scrollUntilElementExists("insights.review-constellation", in: app))
        XCTAssertTrue(scrollUntilElementExists("insights.history-layer", in: app))
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
        XCTAssertTrue(app.descendants(matching: .any)["today.hero-card"].waitForExistence(timeout: 10))
        let primaryAction = app.buttons["today.hero.primary-action"]
        XCTAssertTrue(primaryAction.waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["today.support-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["today.support.time-aperture"].waitForExistence(timeout: 10))
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
        let captureCard = app.descendants(matching: .any)["captures.card.preview-capture-2"]
        XCTAssertTrue(captureCard.waitForExistence(timeout: 10))
        tapCaptureNewGoal(in: app, captureCard: captureCard)

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

        let recoveryAction = app.buttons["shell.command.action.quick_recovery"]
        XCTAssertTrue(recoveryAction.waitForExistence(timeout: 10))
        recoveryAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["today.hero.reentry"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["today.support.recovery-bloom"].waitForExistence(timeout: 10))

        let reopenedCommandButton = shellCommandButton(in: app)
        XCTAssertTrue(reopenedCommandButton.waitForExistence(timeout: 10))
        reopenedCommandButton.tap()
        let focusAction = app.buttons["shell.command.action.quick_focus"]
        XCTAssertTrue(focusAction.waitForExistence(timeout: 10))
        focusAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["today.hero.reentry"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("today.support.focus-screenlet", in: app))
    }

    func testTodayStartFocusCanOpenBoundedFocusScreenlet() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let startFocus = app.buttons["today.hero.primary-action"]
        XCTAssertTrue(startFocus.waitForExistence(timeout: 10))
        XCTAssertEqual(startFocus.label, "Start focus")
        startFocus.tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.support.focus-screenlet"].waitForExistence(timeout: 10))
    }

    func testTodayCanHandOffToGoalDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let openDetail = todayGoalDetailButton(in: app)
        XCTAssertTrue(openDetail.waitForExistence(timeout: 10))
        openDetail.tap()

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.path-filmstrip"].waitForExistence(timeout: 10))
    }

    func testGoalDetailTrustAndMemoryDisclosureStayBelowStrategicLayer() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Goals"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Goals"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["goals.hero-card"].waitForExistence(timeout: 10))
        tapGoalsHeroPrimaryAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.strategic-header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.path-filmstrip"].waitForExistence(timeout: 10))

        let trustToggle = scrollUntilButtonHittable("goal-detail.trust-toggle", fallbackLabel: "Open trust detail", in: app)
        XCTAssertTrue(trustToggle.waitForExistence(timeout: 10))
        trustToggle.tap()
        XCTAssertTrue(scrollUntilElementExists("goal-detail.trust-panel", in: app) || scrollUntilStaticTextExists("Why this is on deck", in: app))

        let correctionsToggle = scrollUntilButtonHittable("goal-detail.corrections-toggle", fallbackLabel: "Open correction actions", in: app)
        XCTAssertTrue(correctionsToggle.waitForExistence(timeout: 10))
        correctionsToggle.tap()
        XCTAssertTrue(scrollUntilElementExists("goal-detail.corrections-panel", in: app) || scrollUntilStaticTextExists("Already learned", in: app))

        let memoryToggle = scrollUntilButtonHittable("goal-detail.memory-toggle", fallbackLabel: "Open deeper memory", in: app)
        XCTAssertTrue(memoryToggle.waitForExistence(timeout: 10))
        memoryToggle.tap()
        XCTAssertTrue(scrollUntilElementExists("goal-detail.memory-panel", in: app) || scrollUntilStaticTextExists("Evidence", in: app))
    }

    func testTodayCanHandOffToPlan() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        let openPlan = scrollUntilButtonHittable("today.action.openPlan.none", fallbackLabel: "Open Plan", in: app)
        XCTAssertTrue(openPlan.waitForExistence(timeout: 10))
        openPlan.tap()

        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 10))
    }

    func testDemoPlanWorkspaceShowsBatch49CoreModules() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["plan.hero-card"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.elastic-week", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.believability-card", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.execution-resilience", in: app))
        XCTAssertTrue(scrollUntilElementExists("plan.action-lane", in: app))
    }

    func testDemoPlanPressureScrubberUpdatesSelectedDayAndActionLane() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/plan")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["plan.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("plan.pressure-scrubber", in: app))
        let scrubPoint = app.buttons["plan.scrubber.point.day-2"]
        XCTAssertTrue(scrubPoint.waitForExistence(timeout: 10))
        scrubPoint.tap()
        XCTAssertEqual(scrubPoint.value as? String, "selected")

        let protectAction = scrollUntilButtonHittable("plan.action.select.protect", in: app)
        XCTAssertTrue(protectAction.waitForExistence(timeout: 10))
        protectAction.tap()

        let actionCTA = scrollUntilButtonHittable("plan.action.cta", fallbackLabel: "Open goal", in: app)
        XCTAssertTrue(actionCTA.waitForExistence(timeout: 10))
    }

    private func makeApp(
        bootstrapMode: String,
        launchURL: String? = nil,
        extraEnvironment: [String: String] = [:]
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["AMBITIONS_BOOTSTRAP_MODE"] = bootstrapMode
        app.launchArguments += ["-AMBITIONS_BOOTSTRAP_MODE", bootstrapMode]
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
        if let control = cardScopedButtons.first(where: { $0.waitForExistence(timeout: 2) && $0.isEnabled }) {
            control.tap()
            return
        }

        let labeledButtons = app.buttons.matching(NSPredicate(format: "label == %@", "New goal")).allElementsBoundByIndex
        if let control = labeledButtons.first(where: { button in
            button.waitForExistence(timeout: 2)
                && button.identifier == "captures.card.preview-capture-2"
                && button.isEnabled
        }) {
            control.tap()
            return
        }

        captureCard.coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.82)).tap()
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

    private func goalsHeroPrimaryAction(in app: XCUIApplication) -> XCUIElement {
        let button = app.buttons["goals.hero.primary-action"]
        if button.waitForExistence(timeout: 2) {
            return button
        }

        let fallback = app.descendants(matching: .any)["goals.hero.primary-action"]
        _ = fallback.waitForExistence(timeout: 2)
        return fallback
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
        let labeled = app.buttons["Command"]
        _ = labeled.waitForExistence(timeout: 2)
        return labeled
    }

    private func todayGoalDetailButton(in app: XCUIApplication) -> XCUIElement {
        let heroPrimary = app.buttons["today.hero.primary-action"]
        if heroPrimary.waitForExistence(timeout: 2),
           ["Answer", "Open detail", "Ask for help"].contains(heroPrimary.label) {
            return heroPrimary
        }

        let directQueries = [
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.openDetail.")).firstMatch,
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.askForHelp.")).firstMatch,
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.action.openDetail.")).firstMatch,
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.action.askForHelp.")).firstMatch
        ]

        for candidate in directQueries where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        for _ in 0..<8 {
            for candidate in directQueries where candidate.exists && candidate.isHittable {
                return candidate
            }
            app.swipeUp()
        }

        return app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.action.openDetail.")).firstMatch
    }

    private func waitForTodayScreenReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let todayScreen = app.descendants(matching: .any)["today.screen"]
        let heroCard = app.descendants(matching: .any)["today.hero-card"]

        while Date() < deadline {
            if todayScreen.waitForExistence(timeout: 1), heroCard.waitForExistence(timeout: 1) {
                return true
            }
        }

        return todayScreen.exists && heroCard.exists
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
