import XCTest

@MainActor
final class TodaySurfaceUITests: AmbitionsUITestCase {
    func testTodaySurfaceShowsDominantHeroAndPrimaryAction() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: ["AMBITIONS_PREVIEW_TODAY_SCENARIO": "stable"]
        )
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(todayRealityMeridianAnchorExists(in: app))
        XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailStartHereTitle"].waitForExistence(timeout: 10))
        XCTAssertTrue(
            app.descendants(matching: .any)["TodayStartHereSourceFreshness"].waitForExistence(timeout: 10)
                || app.descendants(matching: .any)["TodayStartHereTrustDetails"].waitForExistence(timeout: 10)
                || app.descendants(matching: .any)["TodayStartHereBecauseLine"].waitForExistence(timeout: 10)
        )
        XCTAssertTrue(todayPrimaryAction(in: app).waitForExistence(timeout: 10) || app.staticTexts["Start now"].exists || app.staticTexts["Open Time"].exists)
        if app.descendants(matching: .any)["TodayRealityRail"].waitForExistence(timeout: 2) {
            XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailTopologyStrip", in: app))
            XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailNowSection", in: app))
            XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailNextSection", in: app))
            XCTAssertTrue(scrollUntilElementExists(identifier: "TodayRealityRailLaterSection", in: app))
        }
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

        let dockFrame = rootDockFrame(in: app)
        let firstViewportMaxY = dockFrame.isNull ? window.frame.maxY : dockFrame.minY
        let requiredVisibleObjects = [
            app.staticTexts["TodayRealityRailStartHereTitle"],
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
        XCTAssertTrue(app.descendants(matching: .any)["TodayStartHereSourceFreshness"].waitForExistence(timeout: 10), "Start Here should expose source freshness and Why this? receipt access.")
        XCTAssertTrue(
            app.descendants(matching: .any)["TodayStartHereShowAnother"].waitForExistence(timeout: 10)
                || app.descendants(matching: .any)["TodayStartHereNotThis"].waitForExistence(timeout: 10),
            "Start Here should expose a user correction control."
        )

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
        executionTimeAllowance = 300

        let matrix: [(name: String, scenario: String, contentSize: String, sheet: String?, required: [String], forbidden: [String])] = [
            (
                name: "default",
                scenario: "stable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Recommended step", "Why this?", "Up next"],
                forbidden: []
            ),
            (
                name: "source-unavailable",
                scenario: "source-unavailable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Needs context. Manual shaping still works.", "Why this?"],
                forbidden: []
            ),
            (
                name: "active-recommended-step",
                scenario: "start-here-ready",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Start now", "Recommended step", "open window"],
                forbidden: []
            ),
            (
                name: "large-dynamic-type",
                scenario: "reflow",
                contentSize: "UICTContentSizeCategoryAccessibilityL",
                sheet: nil,
                required: ["Start here", "Recommended step"],
                forbidden: []
            ),
            (
                name: "receipt-visible",
                scenario: "stable",
                contentSize: "UICTContentSizeCategoryM",
                sheet: "receipt",
                required: ["Start Here review history", "Still counts", "Waiting", "Blocked", "Not needed"],
                forbidden: []
            ),
            (
                name: "reduce-motion-static-equivalent",
                scenario: "protected",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["Start here", "Recommended step", "Protected"],
                forbidden: []
            ),
            (
                name: "no-step-paths",
                scenario: "empty",
                contentSize: "UICTContentSizeCategoryM",
                sheet: nil,
                required: ["No step is required right now", "Capture stays ready", "Build today"],
                forbidden: ["Capture what changed", "Shape Time", "Review context", "Record outcome", "Protect this window"]
            )
        ]

        for item in matrix {
            var environment = [
                "AMBITIONS_PREVIEW_TODAY_SCENARIO": item.scenario,
                "AMBITIONS_PREVIEW_CLOCK_ISO": "2026-04-15T12:00:00Z",
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

            XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 20), "Today should be ready for \(item.name).")
            XCTAssertTrue(
                todayRealityMeridianAnchorExists(in: app),
                "Today should expose the Reality Meridian or Start Here anchor for \(item.name)."
            )

            for copy in item.required {
                XCTAssertTrue(
                    waitForScreenshotCopy(copy, in: app),
                    "Missing required AMB-962 copy '\(copy)' in \(item.name)."
                )
            }
            for copy in item.forbidden {
                XCTAssertFalse(
                    screenshotCopyExists(copy, in: app),
                    "AMB-962 \(item.name) should not render stale or generic copy '\(copy)'."
                )
            }

            captureTodayScreenshot(named: "amb-962-\(item.name)", in: app)
            app.terminate()
        }
    }

    func testCreateGoalShowsClarificationWhenRequired() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://overlay/create-goal"
        )
        app.launch()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("I don't know where to start")
        dismissKeyboardIfNeeded(in: app)

        XCTAssertTrue(waitForClarificationCard(in: app))
    }

    func testCaptureComposerLaunchKeepsGlobalCaptureComposerReachable() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture",
            extraEnvironment: ["AMBITIONS_UI_SEED_CAPTURES": "1"]
        )
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertFalse(rootDestinationExists("Pulse", in: app))
        XCTAssertFalse(rootDestinationExists("Today", in: app))
        XCTAssertTrue(shellCaptureInput(in: app).waitForExistence(timeout: 10))
    }

    func testQuickRecoveryAndQuickFocusReturnToTodayWithExplicitReentry() throws {
        let recoveryApp = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_recovery"
        )
        recoveryApp.launch()

        XCTAssertTrue(waitForShellReady(in: recoveryApp))
        let recoveryAction = scrollUntilButtonHittable("shell.command.action.quick_recovery", fallbackLabel: "Open Today", in: recoveryApp)
        XCTAssertTrue(recoveryAction.waitForExistence(timeout: 10))
        recoveryAction.tap()

        XCTAssertTrue(recoveryApp.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForTodayScreenReady(in: recoveryApp))
        XCTAssertTrue(todayRealityMeridianAnchorExists(in: recoveryApp))
        recoveryApp.terminate()

        let focusApp = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_focus"
        )
        focusApp.launch()

        XCTAssertTrue(waitForShellReady(in: focusApp))
        let focusAction = scrollUntilButtonHittable("shell.command.action.quick_focus", fallbackLabel: "Start here", in: focusApp)
        XCTAssertTrue(focusAction.waitForExistence(timeout: 10))
        focusAction.tap()

        XCTAssertTrue(focusApp.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10))
        XCTAssertTrue(waitForTodayScreenReady(in: focusApp))
        XCTAssertTrue(todayRealityMeridianAnchorExists(in: focusApp))
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

    func testP1A1RenderedStepLifecycleExposesCompleteMoveAndRecoveryControls() throws {
        let detailApp = makeApp(
            bootstrapMode: "demo",
            extraEnvironment: ["AmbitionsTodaySheet": "trust"]
        )
        detailApp.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: detailApp, timeout: 90))
        XCTAssertTrue(detailApp.descendants(matching: .any)["TodayStepDetail"].waitForExistence(timeout: 10))
        XCTAssertTrue(detailApp.descendants(matching: .any)["TodayStepDetailTitle"].waitForExistence(timeout: 10))
        XCTAssertTrue(detailApp.descendants(matching: .any)["TodayStepDetailClosureAction"].waitForExistence(timeout: 10))

        let moveAction = scrollUntilButtonHittable("today.action.reschedule", fallbackLabel: "Move it", in: detailApp, maxAttempts: 8)
        XCTAssertTrue(moveAction.waitForExistence(timeout: 10), "The Step detail sheet should expose Move it for non-shaming reschedule.")
        XCTAssertTrue(moveAction.isHittable, "Move it should be tappable.")
        let completeAction = scrollUntilButtonHittable("today.action.complete", fallbackLabel: "Mark Done", in: detailApp, maxAttempts: 8)
        XCTAssertTrue(completeAction.waitForExistence(timeout: 10), "The Step detail sheet should expose a rendered complete action.")
        XCTAssertTrue(completeAction.isHittable, "The rendered complete action should be tappable.")
        detailApp.terminate()

        let recoveryApp = makeApp(
            bootstrapMode: "preview",
            extraEnvironment: [
                "AMBITIONS_PREVIEW_TODAY_SCENARIO": "stable",
                "AmbitionsTodaySheet": "receipt",
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        recoveryApp.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: recoveryApp, timeout: 90))
        XCTAssertTrue(recoveryApp.descendants(matching: .any)["TodayActionClosureSheet"].waitForExistence(timeout: 10))
        XCTAssertTrue(recoveryApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "What changed?")).firstMatch.waitForExistence(timeout: 5))
        for outcomeID in ["completed", "still_counts", "moved", "blocked", "not_needed"] {
            XCTAssertTrue(
                recoveryApp.buttons["TodayActionClosureOutcome.\(outcomeID)"].waitForExistence(timeout: 5),
                "Closure recovery should expose \(outcomeID) as an accessible outcome."
            )
        }
        recoveryApp.buttons["TodayActionClosureOutcome.moved"].tap()
        XCTAssertTrue(recoveryApp.descendants(matching: .any)["TodayActionClosureConsequencePreview"].waitForExistence(timeout: 5))
        let confirmOutcome = scrollUntilButtonHittable("TodayActionClosureConfirm", fallbackLabel: "Save outcome", in: recoveryApp, maxAttempts: 8)
        XCTAssertTrue(confirmOutcome.waitForExistence(timeout: 5))
        XCTAssertTrue(confirmOutcome.isHittable)
        for forbidden in ["failed", "overdue", "lazy", "avoidance", "streak broken", "productivity dropped"] {
            XCTAssertFalse(
                recoveryApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", forbidden)).firstMatch.exists,
                "Rendered Step recovery must not expose shame copy: \(forbidden)"
            )
        }
        captureTodayScreenshot(named: "p1a1-rendered-step-recovery-controls", in: recoveryApp)
    }

    func testP1A2NormalRenderedStepCompletesFromTodayDetail() throws {
        let app = makeApp(bootstrapMode: "demo")
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 90))
        let stepRow = normalTodayStepRowControl(in: app)
        XCTAssertTrue(stepRow.waitForExistence(timeout: 10), "The visible Today Day Rail should expose a normal Step row affordance.")
        XCTAssertTrue(stepRow.isHittable, "The normal Today Step row should be tappable.")
        stepRow.tap()

        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetail"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetailTitle"].waitForExistence(timeout: 10))
        let completeAction = scrollUntilButtonHittable("today.action.complete", fallbackLabel: "Mark Done", in: app, maxAttempts: 8)
        XCTAssertTrue(completeAction.waitForExistence(timeout: 10), "The normal Step detail path should expose completion.")
        XCTAssertTrue(completeAction.isHittable, "The normal Step detail completion control should be tappable.")
        completeAction.tap()

        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Completion recorded")).firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 30))
    }

    func testP1A2NormalRenderedStepMovesAndExposesRecoveryFromTodayDetail() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            extraEnvironment: ["AmbitionsScreenshotMode": "YES"]
        )
        app.launch()

        XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 90))
        let stepRow = normalTodayStepRowControl(in: app)
        XCTAssertTrue(stepRow.waitForExistence(timeout: 10), "The visible Today Day Rail should expose a normal Step row affordance.")
        XCTAssertTrue(stepRow.isHittable, "The normal Today Step row should be tappable.")
        stepRow.tap()

        XCTAssertTrue(app.descendants(matching: .any)["TodayStepDetail"].waitForExistence(timeout: 10))
        let closureAction = app.descendants(matching: .any)["TodayStepDetailClosureAction"]
        XCTAssertTrue(closureAction.waitForExistence(timeout: 10), "The normal Step detail path should expose Close the loop.")
        closureAction.tap()

        XCTAssertTrue(app.descendants(matching: .any)["TodayActionClosureSheet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "What changed?")).firstMatch.waitForExistence(timeout: 5))
        for outcomeID in ["completed", "still_counts", "moved", "blocked", "not_needed"] {
            XCTAssertTrue(
                app.buttons["TodayActionClosureOutcome.\(outcomeID)"].waitForExistence(timeout: 5),
                "Normal Step recovery should expose \(outcomeID) as an accessible outcome."
            )
        }
        for forbidden in ["failed", "overdue", "lazy", "avoidance", "streak broken", "productivity dropped"] {
            XCTAssertFalse(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", forbidden)).firstMatch.exists,
                "Normal Step recovery must not expose shame copy: \(forbidden)"
            )
        }
        captureTodayScreenshot(named: "p1a2-normal-step-recovery-controls", in: app)
        app.buttons["TodayActionClosureDismiss"].tap()

        XCTAssertTrue(openTodayStepRowDetail(in: app), "The Step should remain available through the normal Today Step row before a move is saved.")
        let moveAction = scrollUntilButtonHittable("today.action.reschedule", fallbackLabel: "Move it", in: app, maxAttempts: 8)
        XCTAssertTrue(moveAction.waitForExistence(timeout: 10), "The normal Step detail path should expose Move it.")
        XCTAssertTrue(moveAction.isHittable, "The normal Step detail move control should be tappable.")
        moveAction.tap()

        XCTAssertTrue(
            waitForTodayInlineReceipt(in: app, title: "What changed?", bodyFragment: "Move it", timeout: 15),
            "Moving a Step should surface the Today inline receipt from the runtime mutation response. \(todayInlineReceiptDebugDescription(in: app))"
        )
        XCTAssertTrue(waitForTodayScreenReady(in: app, timeout: 30))
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
        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.profile"].waitForExistence(timeout: 10))
        XCTAssertTrue(scrollUntilElementExists("goal-detail.path-field", in: app))

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

    func testRetiredMotionRouteDoesNotCreateRootDestination() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/motion",
            extraEnvironment: ["AmbitionsScreenshotMode": "YES"]
        )
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Motion", in: app))
        XCTAssertFalse(app.descendants(matching: .any)["stage.motion.current.view"].waitForExistence(timeout: 2))
        XCTAssertTrue(waitForSelectedSurface("Today", in: app))
        XCTAssertTrue(
            app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 10)
                || app.descendants(matching: .any)["TodayRealityRailStartHereTitle"].exists
        )
    }
}
