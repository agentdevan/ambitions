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
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))

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

        XCTAssertTrue(waitForRootDestination("Time", in: app, timeout: 10))
        XCTAssertTrue(waitForSelectedSurface("Time", in: app, timeout: 10))
    }
}
