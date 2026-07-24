import XCTest

final class TodayFlagshipCalibrationHostUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testTodayOrientationOrderTargetsAndNativeStepEntry() {
        launch("tfcs-f01")

        let crown = todayCrown()
        let startHere = element("tfcs-start-here-object")
        let primaryAction = element("tfcs-open-start-here")
        let timeline = element("tfcs-timeline")
        let dock = app.buttons["Open global navigation"]

        assertExists([crown, startHere, primaryAction, timeline, dock])
        XCTAssertLessThan(crown.frame.minY, startHere.frame.minY)
        XCTAssertLessThan(startHere.frame.minY, timeline.frame.minY)
        assertMinimumTarget(primaryAction)
        assertMinimumTarget(dock)
        XCTAssertTrue(primaryAction.isHittable)

        primaryAction.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-focused-object-field").exists)
        XCTAssertTrue(element("tfcs-current-truth").exists)
    }

    func testDenseTodayScrollKeepsCrownAndDockOutsideContent() {
        launch("tfcs-f03")

        let crown = todayCrown()
        let dock = app.buttons["Open global navigation"]
        let crownY = crown.frame.minY
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.68))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.30))

        start.press(
            forDuration: 0.05,
            thenDragTo: end,
            withVelocity: 100,
            thenHoldForDuration: 0.15
        )

        XCTAssertEqual(crown.frame.minY, crownY, accuracy: 1)
        XCTAssertTrue(dock.exists)
        XCTAssertTrue(app.staticTexts["Make the nursery ready for the crib"].isHittable)
        let timelineTitle = app.staticTexts["Today’s Timeline"]
        XCTAssertTrue(timelineTitle.isHittable)
        XCTAssertTrue(app.staticTexts["Bring appointment notes"].isHittable)

        let evidence = XCTAttachment(screenshot: app.screenshot())
        evidence.name = "TFCS-F03-intentional-scrolled-today-dark"
        evidence.lifetime = .keepAlways
        add(evidence)
    }

    func testPrimaryStillCountsJourneyAndCancellationRemainTruthful() {
        launch("tfcs-f06")

        let stillCounts = element("tfcs-select-still-counts")
        XCTAssertTrue(stillCounts.waitForExistence(timeout: 3))
        assertMinimumTarget(stillCounts)
        stillCounts.tap()

        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-review-current-truth").exists)
        XCTAssertTrue(element("tfcs-proposed-truth").exists)

        let cancel = app.buttons["Not now"]
        XCTAssertTrue(cancel.exists)
        XCTAssertTrue(cancel.isHittable)
        cancel.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        element("tfcs-select-still-counts").tap()
        let commit = element("tfcs-commit-still-counts")
        XCTAssertTrue(commit.waitForExistence(timeout: 3))
        assertMinimumTarget(commit)
        commit.tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        XCTAssertTrue(element("tfcs-recorded-acknowledgment").exists)

        let history = app.buttons["View history"]
        XCTAssertTrue(history.exists)
        history.tap()
        XCTAssertTrue(app.staticTexts["Meaningful nursery progress recorded"].isHittable)
        app.buttons["View history"].tap()
        XCTAssertFalse(app.staticTexts["Meaningful nursery progress recorded"].isHittable)
        XCTAssertTrue(element("tfcs-settled-truth").exists)

        let returnToToday = element("tfcs-return-to-today")
        XCTAssertTrue(returnToToday.exists)
        assertMinimumTarget(returnToToday)
        returnToToday.tap()

        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-start-here-object").exists)
        XCTAssertTrue(app.buttons["Open global navigation"].exists)
    }

    func testReviewFirstViewportContainsDecisionWithoutScrolling() {
        launch("tfcs-f07")

        let requiredElements = [
            element("tfcs-step-identity"),
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-review-consequence"),
            element("tfcs-review-relationship"),
            element("tfcs-review-trust-cue"),
            element("tfcs-review-details"),
            element("tfcs-commit-still-counts")
        ]
        assertExists(requiredElements)
        for element in requiredElements {
            XCTAssertTrue(element.isHittable, "Review element begins outside the first viewport: \(element)")
        }

        let commit = element("tfcs-commit-still-counts")
        let cancel = app.buttons["Not now"]
        assertMinimumTarget(commit)
        assertMinimumTarget(cancel)
        XCTAssertTrue(commit.isHittable)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertFalse(app.staticTexts["Done · Move it · Waiting · Blocked · Not needed"].exists)
        XCTAssertFalse(app.buttons["Other outcomes"].exists)
        XCTAssertFalse(app.buttons["Choose another outcome"].exists)
    }

    func testReturnedTodayPromotedStepAppearsOnceAndSettledStepRemainsVisible() {
        launch("tfcs-f09")

        let promotedIdentity = app.staticTexts.matching(
            NSPredicate(format: "label == %@", "Send the launch brief")
        )
        XCTAssertEqual(promotedIdentity.count, 1)
        XCTAssertFalse(element("tfcs-timeline-object-step.send-launch-brief").exists)
        XCTAssertTrue(element("tfcs-returned-settled-step").exists)
        XCTAssertTrue(app.staticTexts["Make the nursery ready for the crib"].exists)
        XCTAssertTrue(element("tfcs-returned-start-here-time").exists)
    }

    func testAccessibilityReviewKeepsCommitAndCancelReachable() {
        launch("tfcs-review-accessibility")

        let commit = element("tfcs-commit-still-counts")
        let cancel = app.buttons["Not now"]
        XCTAssertTrue(commit.waitForExistence(timeout: 3))
        XCTAssertTrue(cancel.exists)
        assertMinimumTarget(commit)
        assertMinimumTarget(cancel)

        if commit.isHittable == false {
            app.swipeUp()
        }
        XCTAssertTrue(commit.isHittable)
        XCTAssertTrue(cancel.isHittable)
    }

    func testArabicSaudiFixtureRendersGenuineRTLAndLocalizedReviewCopy() {
        launch("tfcs-stress-long-rtl")

        XCTAssertTrue(app.staticTexts["جهّز زاوية سرير الطفل في Ambitions S10"].exists)
        XCTAssertTrue(app.staticTexts["نستقبل طفلنا في منزلنا"].exists)
        XCTAssertTrue(app.staticTexts["الآن"].exists)
        XCTAssertTrue(app.staticTexts["قبل وقت العائلة"].exists)

        let stillCounts = app.buttons["ما زال يُحتسب"]
        XCTAssertTrue(stillCounts.exists)
        stillCounts.tap()

        XCTAssertTrue(app.navigationBars["هل تريد تسجيل هذا التقدّم؟"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["ما الذي سيتغيّر"].exists)
        XCTAssertTrue(app.staticTexts["يحدّث أيضًا"].exists)
        XCTAssertTrue(app.buttons["سجّل التقدّم"].exists)
        XCTAssertTrue(app.buttons["ليس الآن"].exists)
    }

    func testRecoveryContinuationAndDeferralKeepFixtureSemantics() {
        launch("tfcs-f10")

        let deferChoice = element("recovery.keep-step")
        XCTAssertEqual(deferChoice.label, "Leave this for later")
        deferChoice.tap()

        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Your saved progress is still here."].exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testAdaptiveNavigationAndRecoveryExposeDistinctValidActions() {
        launch("tfcs-f05")

        let commandIDs = [
            "today", "goals", "time", "you", "search", "capture"
        ]
        let commands = commandIDs.map { element("tfcs-navigation-\($0)") }
        assertExists(commands)
        for command in commands {
            assertMinimumTarget(command)
        }
        XCTAssertEqual(commands.map { $0.label }, [
            "Today", "Goals", "Time", "You", "Search", "Capture"
        ])
        XCTAssertLessThan(commands[3].frame.minY, commands[4].frame.minY)

        app.terminate()
        launch("tfcs-f10")
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 3))

        let continueChoice = element("recovery.continue-saved-progress")
        let keepChoice = element("recovery.keep-step")
        assertExists([continueChoice, keepChoice])
        assertMinimumTarget(continueChoice)
        assertMinimumTarget(keepChoice)
        XCTAssertNotEqual(continueChoice.label, keepChoice.label)

        continueChoice.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testB01RootExposesOneArticulatedStartHereTimelineAndIntentionalShellPeek() {
        launch("tfcs-f01")

        let startHereObject = element("tfcs-start-here-object")
        let action = element("tfcs-open-start-here")
        let timeline = element("tfcs-timeline")
        let firstTimelineRow = element("tfcs-timeline-row-step.nursery-paint-sample")
        let dockPeek = app.buttons["Open global navigation"]

        assertExists([startHereObject, action, timeline, firstTimelineRow, dockPeek])
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-start-here-object").count,
            1
        )
        XCTAssertLessThan(startHereObject.frame.minY, firstTimelineRow.frame.minY)
        XCTAssertTrue(action.isHittable)
        assertMinimumTarget(action)
        assertMinimumTarget(dockPeek)
        XCTAssertTrue(firstTimelineRow.label.contains("Paint the nursery sample"))
        XCTAssertTrue(firstTimelineRow.label.contains("10:30 AM"))
        XCTAssertTrue(firstTimelineRow.label.contains("Ready now"))
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testB01FocusedReviewSettlementAndRecoveryExposeSharedObjectGrammar() {
        launch("tfcs-f06")

        let focusedField = element("tfcs-focused-object-field")
        assertExists([focusedField, element("tfcs-current-truth")])
        XCTAssertTrue(focusedField.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(focusedField.label.contains("Welcome our baby home"))
        XCTAssertEqual(app.buttons.matching(identifier: "tfcs-select-still-counts").count, 1)

        element("tfcs-select-still-counts").tap()
        let comparison = element("tfcs-review-comparison")
        assertExists([
            comparison,
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-commit-still-counts")
        ])
        XCTAssertNotEqual(
            element("tfcs-review-current-truth").label,
            element("tfcs-proposed-truth").label
        )

        app.terminate()
        launch("tfcs-f08")
        assertExists([
            element("tfcs-settlement-field"),
            element("tfcs-recorded-acknowledgment"),
            element("tfcs-return-to-today")
        ])

        app.terminate()
        launch("tfcs-f10")
        let recoveryField = element("tfcs-recovery-progress-field")
        assertExists([
            recoveryField,
            element("recovery.continue-saved-progress"),
            element("recovery.keep-step")
        ])
        XCTAssertTrue(
            app.staticTexts[
                "Cleared the crib corner and kept the paint sample decision."
            ].exists
        )
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
        XCTAssertTrue(element("tfcs-journey-root").waitForExistence(timeout: 8))
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func todayCrown() -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(
                format: "label CONTAINS %@",
                "Thursday · Home before dinner"
            ))
            .firstMatch
    }

    private func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 3),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    private func assertMinimumTarget(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }
}
