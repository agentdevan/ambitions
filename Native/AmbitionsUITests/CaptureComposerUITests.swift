import XCTest

@MainActor
final class CaptureComposerUITests: AmbitionsUITestCase {
    func testLaunchURLCanOpenGlobalCaptureWithoutTopLevelCaptureTab() throws {
        let hiddenApp = makeApp(bootstrapMode: "preview")
        hiddenApp.launch()

        XCTAssertTrue(waitForShellReady(in: hiddenApp))
        XCTAssertFalse(hiddenApp.descendants(matching: .any)["shell.activated-capture-seam"].exists)
        XCTAssertFalse(rootDestinationExists("Capture", in: hiddenApp))
        hiddenApp.terminate()

        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertFalse(rootDestinationExists("Pulse", in: app))
        XCTAssertFalse(rootDestinationExists("Today", in: app))
        XCTAssertTrue(app.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        XCTAssertFalse(app.buttons["shell.activated-capture.dictation-button"].exists)

        let input = shellCaptureInput(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("build launch goal tomorrow")
        dismissKeyboardIfNeeded(in: app)

        XCTAssertFalse(app.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        let review = scrollUntilButtonHittable("shell.activated-capture.save-button", in: app, maxAttempts: 10)
        XCTAssertTrue(review.waitForExistence(timeout: 10))
        review.tap()
        XCTAssertTrue(app.descendants(matching: .any)["capture.proposal"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["capture.proposal.placement-choice.task"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["capture.proposal.placement-choice.goal"].waitForExistence(timeout: 10))

        let routeCorrection = scrollUntilButtonHittable("capture.proposal.placement-choice.task", in: app, maxAttempts: 10)
        XCTAssertTrue(routeCorrection.exists)
        routeCorrection.tap()

        let accept = scrollUntilButtonHittable("capture.proposal.accept", in: app, maxAttempts: 10)
        XCTAssertTrue(accept.waitForExistence(timeout: 10))
        accept.tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["shell.activated-capture.status"].waitForExistence(timeout: 10)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Saved")).firstMatch.waitForExistence(timeout: 10)
        )
        XCTAssertFalse(app.descendants(matching: .any)["capture.proposal"].exists)
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        app.terminate()

        let largeTextApp = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture",
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL"
        )
        largeTextApp.launch()

        XCTAssertTrue(waitForShellReady(in: largeTextApp))
        XCTAssertFalse(rootDestinationExists("Capture", in: largeTextApp))
        XCTAssertFalse(rootDestinationExists("Pulse", in: largeTextApp))
        XCTAssertFalse(rootDestinationExists("Today", in: largeTextApp))

        XCTAssertTrue(largeTextApp.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        let largeInput = shellCaptureInput(in: largeTextApp)
        XCTAssertTrue(largeInput.waitForExistence(timeout: 10))
        largeInput.tap()
        largeInput.typeText("build launch goal")
        dismissKeyboardIfNeeded(in: largeTextApp)
        XCTAssertTrue(largeTextApp.buttons["shell.activated-capture.save-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(largeTextApp.buttons["shell.activated-capture.dictation-button"].exists)
        largeTextApp.buttons["shell.activated-capture.save-button"].tap()
        XCTAssertTrue(largeTextApp.descendants(matching: .any)["capture.proposal"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.buttons["capture.proposal.placement-choice.task"].waitForExistence(timeout: 10))
        XCTAssertTrue(largeTextApp.buttons["capture.proposal.placement-choice.goal"].waitForExistence(timeout: 10))
    }

    func testAMB967CaptureCreateGoalScreenshotMatrix() throws {
        let activatedApp = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        activatedApp.launch()
        XCTAssertTrue(waitForShellReady(in: activatedApp))
        XCTAssertFalse(rootDestinationExists("Capture", in: activatedApp))
        XCTAssertTrue(activatedApp.descendants(matching: .any)["shell.activated-capture-seam"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.descendants(matching: .any)["shell.activated-capture.header"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Private field")).firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(activatedApp.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        captureAMB967Screenshot(named: "amb-967-capture-activated", in: activatedApp)

        let activatedInput = shellCaptureInput(in: activatedApp)
        XCTAssertTrue(activatedInput.waitForExistence(timeout: 10))
        activatedInput.tap()
        activatedInput.typeText("build launch goal tomorrow")
        captureAMB967Screenshot(named: "amb-967-capture-keyboard", in: activatedApp)
        dismissKeyboardIfNeeded(in: activatedApp)

        XCTAssertFalse(activatedApp.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        let activatedReview = scrollUntilButtonHittable("shell.activated-capture.save-button", in: activatedApp, maxAttempts: 10)
        XCTAssertTrue(activatedReview.waitForExistence(timeout: 10))
        activatedReview.tap()
        XCTAssertTrue(activatedApp.descendants(matching: .any)["capture.proposal"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["capture.proposal.placement-choice.task"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.buttons["capture.proposal.placement-choice.goal"].waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Placement review")).firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Review first")).firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(activatedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Capture draft")).firstMatch.waitForExistence(timeout: 10))
        for forbidden in ["Resolver", "Needs a Place", "Unplaced capture", "Unresolved start", "Unplaced item"] {
            XCTAssertFalse(
                activatedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", forbidden)).firstMatch.exists,
                "Capture proposal must not expose classifier or holding-bin language: \(forbidden)"
            )
        }
        captureAMB967Screenshot(named: "amb-967-capture-proposal", in: activatedApp)
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
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))

        let input = shellCaptureInput(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()
        input.typeText("play pickleball at 8 next Tuesday")
        dismissKeyboardIfNeeded(in: app)

        let review = scrollUntilButtonHittable("shell.activated-capture.save-button", in: app, maxAttempts: 10)
        XCTAssertTrue(review.waitForExistence(timeout: 10))
        XCTAssertFalse(app.descendants(matching: .any)["shell.activated-capture.route-reveal"].exists)
        review.tap()
        XCTAssertTrue(app.descendants(matching: .any)["capture.proposal"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["capture.proposal.change-destination"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["capture.proposal.accept"].waitForExistence(timeout: 10))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertFalse(rootDestinationExists("Pulse", in: app))
    }

    func testShellCommandSheetCanOpenAndNavigateToTime() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet?intent=open_week")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(app.buttons["shell.command.action.open_week"].waitForExistence(timeout: 10))
        app.buttons["shell.command.action.open_week"].tap()

        XCTAssertTrue(waitForRootDestination("Time", in: app, timeout: 10))
        XCTAssertTrue(waitForSelectedSurface("Time", in: app, timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 10))
    }

    func testShellCommandSheetSupportsQuickCaptureFlow() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))

        let quickCapture = app.buttons["shell.command.action.quick_capture"]
        XCTAssertTrue(quickCapture.waitForExistence(timeout: 10))
        quickCapture.tap()

        let field = shellCaptureInput(in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText("UI shell capture")
        dismissKeyboardIfNeeded(in: app)

        let submit = scrollUntilButtonHittable("shell.activated-capture.save-button", in: app, maxAttempts: 10)
        XCTAssertTrue(submit.waitForExistence(timeout: 10))
        submit.tap()
        XCTAssertTrue(app.descendants(matching: .any)["capture.proposal"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["capture.proposal.accept"].waitForExistence(timeout: 10))
        app.buttons["capture.proposal.accept"].tap()

        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertTrue(
            app.descendants(matching: .any)["shell.activated-capture.status"].waitForExistence(timeout: 10)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Saved locally")).firstMatch.waitForExistence(timeout: 10)
        )
    }

    func testShellOwnedCreateGoalFlowWorksFromCommandSheet() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))

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

        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.creation-message"].waitForExistence(timeout: 30) || scrollUntilStaticTextExists(shellGoalTitle, in: app, maxAttempts: 12))
    }
}
