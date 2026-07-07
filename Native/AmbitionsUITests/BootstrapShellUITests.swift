import XCTest

@MainActor
final class BootstrapShellUITests: AmbitionsUITestCase {
    func testPreviewBootstrapShowsEmptyGoalsState() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertFalse(app.descendants(matching: .any)["onboarding.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))

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
        XCTAssertTrue(todayStepTitleElement(in: app).waitForExistence(timeout: 10))
        let originalTitle = todayStepTitleText(in: app)

        let showAnotherButton = scrollUntilButtonHittable("TodayStartHereShowAnother", fallbackLabel: "Show another", in: app)
        XCTAssertTrue(showAnotherButton.exists)
        showAnotherButton.tap()

        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementSheet"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementOriginalRecommendation"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementAlternatives"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementImpact"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["TodayStepReplacementReceiptPreview"].waitForExistence(timeout: 10))
        let shorterAlternative = app.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@ AND value CONTAINS[c] %@", "TodayStepReplacementAlternative.", "First 15 minutes"))
            .firstMatch
        XCTAssertTrue(shorterAlternative.waitForExistence(timeout: 10))
        shorterAlternative.tap()
        XCTAssertTrue(app.buttons["TodayStepReplacementApprove"].waitForExistence(timeout: 10))
        app.buttons["TodayStepReplacementApprove"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["today.inline-message"].waitForExistence(timeout: 10))
        XCTAssertTrue(todayStepTitleElement(in: app).waitForExistence(timeout: 10))
        let updatedTitle = todayStepTitleText(in: app)

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

    func testPreviewBootstrapOpensGoalsTypedCaptureFromAtlas() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForRootDestination("Goals", in: app, timeout: 10))
        XCTAssertTrue(tapCanonicalDestination("Goals", in: app))

        let createButton = goalCreateButton(in: app)
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        XCTAssertTrue(waitForCreateGoalComposer(in: app))
        let titleField = goalTitleInput(in: app)
        XCTAssertTrue(titleField.waitForExistence(timeout: 10))
        titleField.tap()
        titleField.typeText("UI Smoke Goal")
        dismissKeyboardIfNeeded(in: app)

        let submitButton = goalsTypedCaptureSubmitButton(in: app)
        XCTAssertTrue(submitButton.waitForExistence(timeout: 10))
        submitButton.tap()

        XCTAssertTrue(waitForGoalsTypedCaptureProposal(in: app))
    }

    private func goalsTypedCaptureSubmitButton(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["shell.activated-capture.save-button"],
            app.buttons["capture.quick-submit"],
            app.buttons["create-goal.submit-button"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons["shell.activated-capture.save-button"]
    }

    private func waitForGoalsTypedCaptureProposal(in app: XCUIApplication, timeout: TimeInterval = 12) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["shell.activated-capture.placement-preview"],
            app.descendants(matching: .any)["shell.activated-capture.placement-choice.goal_seed"],
            app.descendants(matching: .any)["capture.placement-preview"],
            app.descendants(matching: .any)["capture.placement-choice.goal_seed"],
            app.descendants(matching: .any)["capture.proposal.placement-choice.goal_seed"],
            app.descendants(matching: .any)["capture.proposal"]
        ]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return candidates.contains(where: { $0.exists })
    }

    func testPreviewBootstrapExposesCanonicalFourTabShellAndSecondarySurfaces() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        for tab in ["Today", "Goals", "Time", "You"] {
            let destination = rootDestinationButton(tab, in: app)
            XCTAssertTrue(destination.waitForExistence(timeout: 10), "Missing top-level surface \(tab)")
            XCTAssertTrue(destination.isHittable, "Top-level surface \(tab) is not hittable")
        }
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertFalse(rootDestinationExists("Motion", in: app))
        XCTAssertFalse(rootDestinationExists("More", in: app))
        XCTAssertFalse(rootDestinationExists("Insights", in: app))
        XCTAssertFalse(rootDestinationExists("Profile", in: app))
        XCTAssertFalse(rootDestinationExists("Habits", in: app))
        XCTAssertTrue(waitForSelectedSurface("Today", in: app, timeout: 10))
        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(app.descendants(matching: .any)["shell.continuity-ribbon"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["shell.today.capture-button"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["shell.today.memory-lens-button"].waitForExistence(timeout: 1))

        for tab in ["Time", "You", "Goals"] {
            XCTAssertTrue(openCanonicalDestination(tab, screenIdentifier: screenIdentifier(forTab: tab), in: app))
            XCTAssertTrue(waitForSelectedSurface(tab, in: app, timeout: 10))
            for rootTab in ["Today", "Goals", "Time", "You"] {
                XCTAssertTrue(rootDestinationExists(rootTab, in: app), "Root dock should stay visible on \(tab) root surface.")
            }
            XCTAssertFalse(rootDestinationExists("Capture", in: app))
            XCTAssertFalse(rootDestinationExists("Motion", in: app))
        }
    }

    func testUIQL002ShellGeometryKeepsChromeInsideSafeAreasAndDockHittable() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))

        var visibleDockFrame = CGRect.null
        for tab in ["Today", "Goals", "Time", "You"] {
            let element = rootDestinationButton(tab, in: app)
            XCTAssertTrue(element.waitForExistence(timeout: 10), "Missing top-level surface \(tab)")
            assertFrame(element.frame, isInside: window.frame, named: "\(tab) dock button")
            visibleDockFrame = visibleDockFrame.isNull ? element.frame : visibleDockFrame.union(element.frame)
            XCTAssertGreaterThanOrEqual(element.frame.width, 44, "\(tab) dock button is narrower than the minimum hit target.")
            XCTAssertGreaterThanOrEqual(element.frame.height, 44, "\(tab) dock button is shorter than the minimum hit target.")
        }
        XCTAssertFalse(visibleDockFrame.isNull, "The visible shell dock must expose top-level destination buttons.")
        XCTAssertGreaterThan(visibleDockFrame.minY, window.frame.midY, "The visible shell dock must remain in the lower root chrome zone.")
        XCTAssertLessThanOrEqual(visibleDockFrame.maxY, window.frame.maxY, "The visible shell dock must remain inside the app window.")

        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        XCTAssertFalse(rootDestinationExists("Pulse", in: app))
        XCTAssertFalse(rootDestinationExists("Plan", in: app))
    }

    func testUIQL002GoalDetailDrilldownHidesRootDock() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://goal/goal-native")
        app.launch()

        XCTAssertTrue(app.descendants(matching: .any)["goal-detail.screen"].waitForExistence(timeout: 10))
        for tab in ["Today", "Goals", "Time", "You"] {
            XCTAssertFalse(rootDestinationExists(tab, in: app), "Focused drilldown should hide root dock destination \(tab).")
        }
    }

    func testUIQL002TimeDrilldownHidesRootDock() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://time/weekly-review")
        app.launch()

        XCTAssertTrue(app.buttons["shell.time.back-button"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Weekly Review"].waitForExistence(timeout: 10))
        for tab in ["Today", "Goals", "Time", "You"] {
            XCTAssertFalse(rootDestinationExists(tab, in: app), "Time drilldown should hide root dock destination \(tab).")
        }
    }

    func testUIQL002ActivatedCaptureSeamUsesOverlayKeyboardClearanceWithoutRootDock() throws {
        let app = makeApp(bootstrapMode: "preview", launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        XCTAssertFalse(rootDestinationExists("Capture", in: app))
        let seam = app.descendants(matching: .any)["shell.activated-capture-seam"]
        XCTAssertTrue(seam.waitForExistence(timeout: 10))
        let input = shellCaptureInput(in: app)
        XCTAssertTrue(input.waitForExistence(timeout: 10))
        input.tap()

        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10))
        let keyboard = app.keyboards.element
        XCTAssertTrue(keyboard.waitForExistence(timeout: 10))
        for tab in ["Today", "Goals", "Time", "You"] {
            XCTAssertFalse(rootDestinationExists(tab, in: app), "Activated Capture should own foreground chrome instead of showing \(tab).")
        }

        assertFrame(seam.frame, isInside: window.frame, named: "activated Capture seam with keyboard")
        XCTAssertGreaterThanOrEqual(seam.frame.height, window.frame.height * 0.62, "Activated Capture should take over the Stage instead of behaving like a sheet.")

        dismissKeyboardIfNeeded(in: app)
        XCTAssertTrue(keyboard.waitForNonExistence(timeout: 5), "Keyboard should dismiss before validating restored full-screen Capture geometry.")
        XCTAssertTrue(
            waitForElement(seam, heightAtLeast: window.frame.height * 0.86, timeout: 5),
            "Activated Capture should recover full-screen height after keyboard dismissal."
        )

        assertFrame(seam.frame, isInside: window.frame, named: "activated Capture seam")
        XCTAssertGreaterThanOrEqual(seam.frame.height, window.frame.height * 0.86, "Activated Capture should remain full-screen after keyboard dismissal.")
        XCTAssertTrue(app.buttons["shell.activated-capture.save-button"].waitForExistence(timeout: 10))
    }

    private func waitForElement(_ element: XCUIElement, heightAtLeast minimumHeight: CGFloat, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists, element.frame.height >= minimumHeight {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return element.exists && element.frame.height >= minimumHeight
    }

    func testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs() throws {
        let app = makeApp(bootstrapMode: "preview")
        app.launch()

        XCTAssertTrue(waitForShellReady(in: app))
        captureShellScreenshot(named: "today", in: app)

        for tab in ["Goals", "Time", "You"] {
            XCTAssertTrue(openCanonicalDestination(tab, screenIdentifier: screenIdentifier(forTab: tab), in: app))
            captureShellScreenshot(named: tab.lowercased(), in: app)
        }
    }
}
