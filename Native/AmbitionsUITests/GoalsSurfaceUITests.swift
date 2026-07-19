import XCTest

@MainActor
final class GoalsSurfaceUITests: AmbitionsUITestCase {
    func testDemoGoalsAtlasLoadsCoreModules() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))

        XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        XCTAssertTrue(app.staticTexts["Life Area Atlas"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Direction Atlas"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["goals.life-area-atlas.title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.life-area-atlas.object"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["goals.life-area.work"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["goals.life-area.open-field"].exists)
        XCTAssertTrue(app.buttons["goals.current-step.open"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["goals.capture-plus"].waitForExistence(timeout: 5))
    }

    func testAMB963GoalsReconstructionScreenshotMatrix() throws {
        struct GoalsMatrixItem {
            let name: String
            let bootstrap: String
            let renderState: String?
            let contentSizeCategory: String
            let requiredIdentifiers: [String]
            let requiredTexts: [String]
            let forbiddenTexts: [String]
        }

        let matrix: [GoalsMatrixItem] = [
            GoalsMatrixItem(
                name: "default",
                bootstrap: "demo",
                renderState: "default",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.life-area-atlas.title",
                    "goals.life-area-atlas.object",
                    "goals.life-area-atlas.state-ribbon",
                    "goals.life-area.work",
                    "goals.current-step.open",
                    "goals.capture-plus"
                ],
                requiredTexts: ["Life Area Atlas", "Recovery focus", "Start here", "Work", "Body"],
                forbiddenTexts: ["Quiet"]
            ),
            GoalsMatrixItem(
                name: "selected-life-area",
                bootstrap: "demo",
                renderState: "selected-life-area",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.life-area-atlas.title",
                    "goals.life-area-atlas.object",
                    "goals.life-area-atlas.state-ribbon",
                    "goals.life-area.work.selected-marker",
                    "goals.life-area.work",
                    "goals.life-area.body"
                ],
                requiredTexts: ["Life Area Atlas", "Selected area", "Work", "Body"],
                forbiddenTexts: ["Quiet"]
            ),
            GoalsMatrixItem(
                name: "proof-source-visible",
                bootstrap: "demo",
                renderState: "proof-available",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "goals.life-area-atlas.title",
                    "goals.life-area-atlas.object",
                    "goals.life-area-atlas.state-ribbon",
                    "goals.life-area.work.proof-marker",
                    "goals.life-area.future",
                    "goals.current-step.open"
                ],
                requiredTexts: ["Life Area Atlas", "Proof visible", "Future", "Start here"],
                forbiddenTexts: ["Quiet"]
            ),
            GoalsMatrixItem(
                name: "large-dynamic-type",
                bootstrap: "demo",
                renderState: "selected-life-area",
                contentSizeCategory: "UICTContentSizeCategoryXXXL",
                requiredIdentifiers: [
                    "goals.life-area-atlas.title",
                    "goals.life-area-atlas.object",
                    "goals.life-area-atlas.state-ribbon",
                    "goals.life-area.work.selected-marker",
                    "goals.current-step.open"
                ],
                requiredTexts: ["Life Area Atlas", "Selected area", "Start here", "People"],
                forbiddenTexts: ["Quiet"]
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
                XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10), "Goals surface should exist for \(item.name).")
                XCTAssertTrue(tapCanonicalDestination("Goals", in: app))
                if item.contentSizeCategory.contains("Accessibility") {
                    XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 20), "Goals screen should render for \(item.name).")
                } else {
                    XCTAssertTrue(waitForGoalsPrimaryObject(in: app), "Goals object should render for \(item.name).")
                }
            }

            XCTAssertTrue(app.descendants(matching: .any)["goals.screen"].waitForExistence(timeout: 10), "Goals screen should exist for \(item.name).")
            for identifier in item.requiredIdentifiers {
                XCTAssertTrue(
                    scrollUntilElementExists(identifier, in: app, maxAttempts: 8),
                    "\(identifier) should exist for \(item.name)."
                )
            }

            for text in item.requiredTexts {
                XCTAssertTrue(scrollUntilStaticTextExists(text, in: app, maxAttempts: 12), "\(text) should be visible for \(item.name).")
            }

            for text in item.forbiddenTexts {
                XCTAssertFalse(app.staticTexts[text].exists, "\(text) should not be repeated as root state noise for \(item.name).")
            }

            XCTAssertFalse(app.staticTexts["Direction Atlas"].exists, "Direction Atlas must not be visible for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Relationsh")).firstMatch.exists, "Relationship label must not truncate for \(item.name).")
            captureGoalsScreenshot(named: "amb-963-goals-\(item.name)", in: app)
        }
    }

    func testDemoGoalsAtlasPrimaryActionAndCardRouteToGoalDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))

        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        tapGoalsHeroPrimaryAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.profile"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.path-field"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.journal", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.trust-whisper", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.memory-narrative", in: app, maxAttempts: 24))
    }

    func testPacket34GoalDetailPathProofAndHandoffDepth() throws {
        let app = makeApp(bootstrapMode: "demo")
        openPacket34GoalDetailFromGoalsRoot(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.profile"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.handoff-strip"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.lane-spine"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["mission-control-time-spine"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.depth-lens"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.next-movement", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.path-field", in: app, maxAttempts: 10))
        captureGoalsRouteScreenshot(named: "packet-3.4-goal-detail-default", routeIdentifier: "goal-detail.screen", in: app)

        let reviewPath = scrollUntilButtonHittable("goal-detail.path.review-button", fallbackLabel: "Review path", in: app, maxAttempts: 10)
        XCTAssertTrue(reviewPath.waitForExistence(timeout: 10))
        reviewPath.tap()

        XCTAssertTrue(scrollUntilElementExists("goal-detail.path-builder", in: app, maxAttempts: 8))
        captureGoalsRouteScreenshot(named: "packet-3.4-goal-detail-path-depth", routeIdentifier: "goal-detail.screen", in: app)

        XCTAssertTrue(scrollUntilElementExists("goal-detail.life-path-thread", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilStaticTextExists("Goal path", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Future routes", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.decisions", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.proof-rail", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.review-trail", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.receipts", in: app, maxAttempts: 12))
        XCTAssertFalse(app.staticTexts["AlternateRouteFold"].exists)
        XCTAssertFalse(app.staticTexts["GoalPathSourceFold"].exists)
        XCTAssertFalse(app.staticTexts["Path Builder"].exists)
    }

    func testPacket34GoalDetailHandoffsRemainContextual() throws {
        let todayApp = makeApp(bootstrapMode: "demo")
        openPacket34GoalDetailFromGoalsRoot(in: todayApp)
        XCTAssertTrue(todayApp.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        todayApp.buttons["goal-detail.handoff.today"].tap()
        XCTAssertTrue(waitForSelectedSurface("Today", in: todayApp, timeout: 10))
        XCTAssertFalse(rootDestinationExists("Capture", in: todayApp))
        XCTAssertFalse(rootDestinationExists("Motion", in: todayApp))
        captureTodayScreenshot(named: "packet-3.4-goal-detail-handoff-today", in: todayApp)
        todayApp.terminate()

        let timeApp = makeApp(bootstrapMode: "demo")
        openPacket34GoalDetailFromGoalsRoot(in: timeApp)
        XCTAssertTrue(timeApp.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        timeApp.buttons["goal-detail.handoff.time"].tap()
        XCTAssertTrue(timeApp.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertFalse(rootDestinationExists("Motion", in: timeApp))
        captureGoalsRouteScreenshot(named: "packet-3.4-goal-detail-handoff-time", routeIdentifier: "weekly-review.screen", in: timeApp)
        timeApp.terminate()

        let captureApp = makeApp(bootstrapMode: "demo")
        openPacket34GoalDetailFromGoalsRoot(in: captureApp)
        XCTAssertTrue(captureApp.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        captureApp.buttons["goal-detail.handoff.capture"].tap()
        XCTAssertTrue(waitForCreateGoalComposer(in: captureApp, timeout: 10))
        XCTAssertFalse(rootDestinationExists("Capture", in: captureApp))
        captureAMB967Screenshot(named: "packet-3.4-goal-detail-handoff-capture", in: captureApp)
    }

    func testPacket34LifeAreaDetailAndContextualCaptureEntry() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))

        let workArea = app.descendants(matching: .any)["goals.life-area.work"]
        XCTAssertTrue(workArea.waitForExistence(timeout: 10))
        tapIfPossible(workArea)

        XCTAssertTrue(app.descendants(matching: .any)["goals.area-detail.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.area-detail.header"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["goals.area-detail.capture-actions"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goals.area-detail.goal.goal-launch-my-business", in: app, maxAttempts: 10))
        captureGoalsRouteScreenshot(named: "packet-3.4-life-area-detail", routeIdentifier: "goals.area-detail.screen", in: app)

        let goalSeed = scrollUntilButtonHittable("goals.area-detail.capture.goal_seed", fallbackLabel: "Goal", in: app, maxAttempts: 10)
        XCTAssertTrue(goalSeed.waitForExistence(timeout: 10))
        goalSeed.tap()
        XCTAssertTrue(waitForCreateGoalComposer(in: app, timeout: 10))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        captureAMB967Screenshot(named: "packet-3.4-life-area-capture-entry", in: app)
    }

    private func openPacket34GoalDetailFromGoalsRoot(in app: XCUIApplication) {
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))
        XCTAssertTrue(waitForGoalsPrimaryObject(in: app))
        XCTAssertTrue(scrollUntilElementExists("goals.current-step.open", in: app, maxAttempts: 10))
        let openStep = app.buttons["goals.current-step.open"].exists
            ? app.buttons["goals.current-step.open"]
            : app.descendants(matching: .any)["goals.current-step.open"]
        tapIfPossible(openStep)
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
    }

    func testPreviewRetiredInsightsTabRouteFallsBackToToday() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://tab/insights")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Insights", in: app))
        XCTAssertFalse(app.descendants(matching: .any)["insights.history.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(waitForSelectedSurface("Today", in: app, timeout: 10))
    }

    func testPreviewYouMonthlyReviewCanHandOffToTime() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://you/monthly-review")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.monthly-review.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("insights.review-constellation", in: app))
        XCTAssertTrue(scrollUntilStaticTextExists("Review shaping", in: app))
    }

    func testPreviewYouHistoryRouteCanHandOffToTime() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://you/history")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["insights.history.screen"].waitForExistence(timeout: 10))
        let timeButton = scrollUntilButtonHittable("insights.history.open-weekly-review", in: app)
        XCTAssertTrue(timeButton.waitForExistence(timeout: 10))
        timeButton.tap()

        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
    }

    func testMemoryLensCanOpenAndRouteToCanonicalWeekDestination() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://overlay/memory-lens?intent=open_week&q=week"
        )
        app.launch()

        let searchField = app.textFields["shell.memory-lens.search-field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))

        let result = app.buttons["shell.memory-lens.result.time-weekly-review"]
        XCTAssertTrue(result.waitForExistence(timeout: 10))
        result.tap()

        XCTAssertTrue(app.descendants(matching: .any)["weekly-review.screen"].waitForExistence(timeout: 10))
    }
}
