import XCTest

final class TodayFlagshipCalibrationHostUITests: XCTestCase {
    var app: XCUIApplication!

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
        let dock = element("tfcs-dock-shell-peek")

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
        let dock = element("tfcs-dock-shell-peek")
        let crownFrame = crown.frame
        let dockFrame = dock.frame
        let startHere = element("tfcs-start-here-object")
        let startHereY = startHere.frame.minY
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.68))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.60))

        start.press(
            forDuration: 0.05,
            thenDragTo: end,
            withVelocity: 100,
            thenHoldForDuration: 0.15
        )

        XCTAssertEqual(crown.label, "Today")
        assertElementSettles(crown) { element in
            element.frame.height < crownFrame.height
                || element.frame.maxY < crownFrame.maxY - 2
        }
        XCTAssertTrue(dock.exists)
        XCTAssertEqual(dock.frame.minY, dockFrame.minY, accuracy: 1)
        XCTAssertLessThan(startHere.frame.minY, startHereY - 5)
        XCTAssertTrue(app.staticTexts["Make the nursery ready for the crib"].isHittable)
        let timelineTitle = app.staticTexts["Today’s Timeline"]
        XCTAssertTrue(timelineTitle.isHittable)

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
        let historySummary = app.staticTexts["Meaningful nursery progress recorded"]
        XCTAssertTrue(historySummary.waitForExistence(timeout: 3))
        XCTAssertEqual(element("tfcs-view-history").value as? String, "Expanded")
        history.tap()
        XCTAssertEqual(element("tfcs-view-history").value as? String, "Collapsed")
        XCTAssertTrue(element("tfcs-settled-truth").exists)

        let returnToToday = element("tfcs-return-to-today")
        XCTAssertTrue(returnToToday.exists)
        assertMinimumTarget(returnToToday)
        returnToToday.tap()

        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-start-here-object").exists)
        XCTAssertTrue(element("tfcs-dock-shell-peek").exists)
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

    func testB02RecoveryRetainsIdentityTruthProgressAndExactCommands() {
        launch("b02-recovery-typical")

        let recovery = element("tfcs-recovery-review")
        let identity = element("tfcs-recovery-step-identity")
        let currentTruth = element("tfcs-recovery-current-truth")
        let savedProgress = element("tfcs-recovery-progress-field")
        let continueChoice = element("recovery.continue-saved-progress")
        let deferChoice = element("recovery.keep-step")

        assertExists([
            recovery,
            identity,
            currentTruth,
            savedProgress,
            continueChoice,
            deferChoice
        ])
        assertMinimumTargetAfterSettling(continueChoice)
        assertMinimumTargetAfterSettling(deferChoice)
        XCTAssertTrue(continueChoice.isHittable)
        XCTAssertTrue(deferChoice.isHittable)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(app.buttons["Undo"].exists)

        deferChoice.tap()
        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-recovery-current-truth").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testB02RecoveryAndResilienceStayObjectScoped() {
        launch("b02-recovery-typical")
        let recovery = element("tfcs-recovery-review")
        XCTAssertTrue(recovery.waitForExistence(timeout: 3))
        XCTAssertGreaterThan(recovery.frame.minY, app.frame.minY + 100)
        XCTAssertTrue(element("recovery.continue-saved-progress").isHittable)
        XCTAssertTrue(element("recovery.keep-step").isHittable)

        app.terminate()
        launch("b02-offline-local")
        let startHere = element("tfcs-start-here-object")
        let offline = element("tfcs-context-seam-offlineLocalTruth")
        let timeline = element("tfcs-today-overview")
        assertExists([startHere, offline, timeline])
        XCTAssertGreaterThanOrEqual(offline.frame.minY, startHere.frame.maxY)
        XCTAssertLessThan(offline.frame.maxY, timeline.frame.maxY)

        app.terminate()
        launch("b02-stale-external")
        let stale = element("tfcs-context-seam-staleExternalContext")
        let affectedRow = element("tfcs-overview-row-step.send-launch-brief")
        assertExists([stale, affectedRow])
        XCTAssertGreaterThanOrEqual(stale.frame.minY, affectedRow.frame.minY)

        app.terminate()
        launch("b02-conflict-transfer")
        let conflict = element("tfcs-context-seam-conflictTransfer")
        XCTAssertTrue(conflict.waitForExistence(timeout: 3))
        XCTAssertTrue(conflict.label.contains("nursery Step"))
        XCTAssertTrue(conflict.label.contains("placement review belongs in Time"))
        XCTAssertFalse(element("tfcs-refresh-external-context").exists)
        XCTAssertFalse(element("tfcs-open-in-time").exists)
        XCTAssertFalse(app.buttons["Undo"].exists)
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
        assertMinimumTargetAfterSettling(continueChoice)
        assertMinimumTargetAfterSettling(keepChoice)
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
        let firstTimelineRow = element("tfcs-overview-row-step.nursery-paint-sample")
        let dockPeek = element("tfcs-dock-shell-peek")

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
        let focusedIdentity = element("tfcs-focused-identity")
        let parentPursuit = element("tfcs-focused-parent-pursuit")
        assertExists([
            focusedField,
            focusedIdentity,
            parentPursuit,
            element("tfcs-current-truth")
        ])
        XCTAssertTrue(focusedIdentity.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(parentPursuit.label.contains("Welcome our baby home"))
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
            element("tfcs-settlement-identity"),
            element("tfcs-settled-truth"),
            element("tfcs-settlement-parent-pursuit"),
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

    func testB01SuccessfulJourneyRecordingDriver() {
        launch("tfcs-f02")
        pauseForEvidence(3)

        element("tfcs-open-start-here").tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        pauseForEvidence(2)

        element("tfcs-select-still-counts").tap()
        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 4))
        pauseForEvidence(2)

        element("tfcs-commit-still-counts").tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        pauseForEvidence(2)

        app.buttons["View history"].tap()
        XCTAssertTrue(
            app.staticTexts["Meaningful nursery progress recorded"]
                .waitForExistence(timeout: 3)
        )
        pauseForEvidence(2)
        app.buttons["View history"].tap()
        pauseForEvidence(1)

        element("tfcs-return-to-today").tap()
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 4))
        pauseForEvidence(3)
    }

    func testB01InterruptedJourneyRecordingDriver() {
        launch("tfcs-j02-manual")
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 7))
        pauseForEvidence(1)
        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 6))
        pauseForEvidence(2)

        app.buttons["Pick up where you left off"].tap()
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 4))
        pauseForEvidence(2)

        element("recovery.continue-saved-progress").tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        let recoveredProgress = element("tfcs-recovered-progress")
        let acceptedTruth = element("tfcs-current-truth")
        assertExists([recoveredProgress, acceptedTruth])
        XCTAssertTrue(
            recoveredProgress.label.contains(
                "Cleared the crib corner and kept the paint sample decision."
            )
        )
        XCTAssertTrue(
            acceptedTruth.label.contains(
                "The corner is cleared and the paint sample is chosen."
            )
        )
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        pauseForEvidence(3)
    }

    func testB01AccessibilityJourneyRecordingDriver() {
        launch("tfcs-j03-manual")
        pauseForEvidence(3)

        let openStep = element("tfcs-open-start-here")
        scrollUntilHittable(openStep)
        openStep.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        pauseForEvidence(2)

        let stillCounts = element("tfcs-select-still-counts")
        scrollUntilHittable(stillCounts)
        stillCounts.tap()
        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 4))
        pauseForEvidence(2)

        let commit = element("tfcs-commit-still-counts")
        scrollUntilHittable(commit)
        commit.tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        pauseForEvidence(2)

        let returnToday = element("tfcs-return-to-today")
        scrollUntilHittable(returnToday)
        returnToday.tap()
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 4))
        pauseForEvidence(3)
    }

    func testB02CrownIsRootOnlyAndDockKeepsLockedGroups() {
        launch("tfcs-f01")

        let heading = element("tfcs-today-heading")
        assertExists([heading])
        XCTAssertEqual(heading.label, "Today")
        XCTAssertEqual(
            heading.value as? String,
            "Ambitions, Thursday · Home before dinner"
        )
        XCTAssertFalse(app.staticTexts["Navigate"].exists)

        app.terminate()
        launch("tfcs-f04")

        let rootsGroup = element("tfcs-dock-roots-group")
        let globalActionsGroup = element("tfcs-dock-global-actions-group")
        let rootCommands = ["today", "goals", "time", "you"].map {
            element("tfcs-dock-\($0)")
        }
        let globalCommands = ["search", "capture"].map {
            element("tfcs-dock-\($0)")
        }
        assertExists([rootsGroup, globalActionsGroup] + rootCommands + globalCommands)
        XCTAssertEqual(
            element("tfcs-dock-expanded").frame.maxX,
            app.frame.maxX,
            accuracy: 1
        )
        XCTAssertLessThan(rootCommands[3].frame.maxY, globalCommands[0].frame.minY)
        XCTAssertEqual(rootCommands.map { $0.label }, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(globalCommands.map { $0.label }, ["Search", "Capture"])
        XCTAssertEqual(rootCommands[0].value as? String, "Selected root")
        XCTAssertTrue(rootCommands[0].isSelected)

        app.terminate()
        launch("tfcs-f05")
        let adaptiveRootsHeading = element("tfcs-adaptive-roots-heading")
        let adaptiveGlobalActionsHeading = element("tfcs-adaptive-global-actions-heading")
        assertExists([adaptiveRootsHeading, adaptiveGlobalActionsHeading])
        XCTAssertEqual(adaptiveRootsHeading.label, "Roots")
        XCTAssertEqual(adaptiveGlobalActionsHeading.label, "Global actions")

        app.terminate()
        launch("tfcs-f06")
        XCTAssertFalse(element("tfcs-today-heading").exists)
    }

    func testB02DockPeekHasIntentionalMinimumTarget() throws {
        launch("tfcs-f01")

        let peek = app.buttons["Open navigation"]
        XCTAssertTrue(peek.waitForExistence(timeout: 3))
        XCTAssertEqual(peek.frame.width, 44, accuracy: 1)
        XCTAssertEqual(peek.frame.height, 64, accuracy: 1)
        assertMinimumTarget(peek)
        XCTAssertTrue(peek.isHittable)

        let shellSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        XCTAssertTrue(shellSource.contains(".frame(width: 14, height: 52)"))
        XCTAssertTrue(shellSource.contains("Image(systemName: \"sun.max.fill\")"))
        XCTAssertTrue(shellSource.contains(".frame(width: 44, height: 64)"))
    }

    func testB02RootUsesOneStartHereAndThreeTruthfulOverviewAnchors() {
        launch("tfcs-f01")

        let startHere = element("tfcs-start-here-object")
        let action = element("tfcs-open-start-here")
        let overview = element("tfcs-today-overview")
        let firstAnchor = element("tfcs-overview-row-step.nursery-paint-sample")
        let dock = element("tfcs-dock-shell-peek")

        assertExists([startHere, action, overview, firstAnchor, dock])
        XCTAssertEqual(
            app.descendants(matching: .any)
                .matching(identifier: "tfcs-start-here-object").count,
            1
        )
        XCTAssertTrue(startHere.value as? String == "Now")
        XCTAssertTrue(action.isHittable)
        XCTAssertTrue(firstAnchor.isHittable)
        assertMinimumTarget(action)
        assertMinimumTarget(dock)

        let overviewRows = overview.descendants(matching: .any)
            .allElementsBoundByIndex
            .filter { $0.identifier.hasPrefix("tfcs-overview-row-") }
        XCTAssertEqual(overviewRows.count, 3)
        XCTAssertFalse(
            overviewRows.contains {
                $0.identifier.contains("step.nursery-ready-for-crib")
            }
        )
        XCTAssertLessThan(startHere.frame.minY, firstAnchor.frame.minY)
        XCTAssertFalse(app.buttons["Search"].exists)
        XCTAssertFalse(app.buttons["Capture"].exists)
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testB02OwnedJourneyViewsUseFixtureCopyInsteadOfLiteralProductStrings() throws {
        let rootSource = try foundrySource(named: "TodayFlagshipCalibrationView.swift")
        let chromeSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        let ownedSources = [rootSource, chromeSource].joined(separator: "\n")
        let literalArgumentPatterns = [
            #"Text\(\s*\""#,
            #"Label\(\s*\""#,
            #"navigationTitle\(\s*\""#,
            #"accessibilityLabel\(\s*\""#,
            #"accessibilityHint\(\s*\""#,
            #"accessibilityValue\(\s*\""#
        ]
        for pattern in literalArgumentPatterns {
            XCTAssertNil(
                ownedSources.range(of: pattern, options: .regularExpression),
                "Task 02 view source still owns a literal product or accessibility argument: \(pattern)"
            )
        }
        for prohibitedLiteral in [
            "\"Roots\"",
            "\"Global actions\"",
            "\"Navigate\"",
            "\"Selected root\"",
            "\"Open global navigation\"",
            "\"Close global navigation\"",
            "\"Your day, in context\"",
            "\"That object is no longer here. Today remains available.\""
        ] {
            XCTAssertFalse(
                ownedSources.contains(prohibitedLiteral),
                "Task 02 view source still owns product copy: \(prohibitedLiteral)"
            )
        }
        XCTAssertTrue(rootSource.contains(".padding(.trailing, isDockExpanded ? 0 : 2)"))
        XCTAssertTrue(rootSource.contains(".accessibilityValue(crownAccessibilityValue)"))
        XCTAssertTrue(chromeSource.contains("shape: UnevenRoundedRectangle("))
        XCTAssertTrue(chromeSource.contains("bottomTrailingRadius: 0"))
        XCTAssertTrue(chromeSource.contains("topTrailingRadius: 0"))
        XCTAssertFalse(chromeSource.contains("TodayFlagshipSectionLabel(title, palette: palette)"))
        XCTAssertTrue(chromeSource.contains("tfcs-adaptive-roots-heading"))
        XCTAssertTrue(chromeSource.contains("tfcs-adaptive-global-actions-heading"))
    }

    func testB02ArabicRootAndDockLabelTreeContainsNoUnapprovedEnglish() {
        launch("tfcs-stress-long-rtl")

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(element("tfcs-today-root").waitForExistence(timeout: 3))

        let heading = element("tfcs-today-heading")
        assertExists([heading])
        XCTAssertEqual(heading.label, "اليوم")
        let headingValue = heading.value as? String
        XCTAssertTrue(headingValue?.hasPrefix("Ambitions S10, ") == true)
        XCTAssertTrue(headingValue?.contains("في المنزل قبل العشاء") == true)
        assertArabicOnlyLabels(in: element("tfcs-today-root"))

        let openNavigation = app.buttons["فتح التنقل"]
        XCTAssertTrue(openNavigation.exists)
        openNavigation.tap()
        let expandedDock = element("tfcs-dock-expanded")
        XCTAssertTrue(expandedDock.waitForExistence(timeout: 3))
        let commands = ["today", "goals", "time", "you", "search", "capture"].map {
            element("tfcs-dock-\($0)")
        }
        assertExists(commands)
        XCTAssertEqual(
            commands.map { $0.label },
            ["اليوم", "الأهداف", "الوقت", "أنت", "البحث", "التقاط"]
        )
        assertArabicOnlyLabels(in: expandedDock)
    }

    func testB02FullDayIsReadOnlyCompleteAndKeepsNativeBackDepth() throws {
        launch("tfcs-f01")
        let viewFullDay = element("tfcs-view-full-day")
        XCTAssertTrue(viewFullDay.waitForExistence(timeout: 3))
        assertMinimumTarget(viewFullDay)
        viewFullDay.tap()

        let now = element("tfcs-full-day-now-step.nursery-ready-for-crib")
        let scrollToNow = element("tfcs-scroll-to-now")
        let timeline = element("tfcs-full-day-timeline")
        assertExists([now, scrollToNow, timeline])
        XCTAssertTrue(
            now.label.contains("The corner is cleared and the paint sample is chosen.")
        )
        XCTAssertEqual(
            timeline.descendants(matching: .any)
                .matching(identifier: "tfcs-full-day-row-step.nursery-paint-sample").count,
            1
        )
        XCTAssertEqual(
            timeline.descendants(matching: .any)
                .matching(identifier: "tfcs-full-day-row-step.send-launch-brief").count,
            1
        )
        XCTAssertEqual(
            timeline.descendants(matching: .any)
                .matching(identifier: "tfcs-full-day-row-event.family-prenatal-walk").count,
            1
        )
        XCTAssertTrue(scrollToNow.isHittable)
        XCTAssertFalse(app.buttons["Edit"].exists)
        XCTAssertFalse(app.buttons["Open in Time"].exists)

        now.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("tfcs-full-day-root").waitForExistence(timeout: 3))
        XCTAssertTrue(now.isHittable)

        let source = try foundrySource(named: "TodayOpenContinuityFullDayView.swift")
        XCTAssertFalse(source.contains("DatePicker"))
        XCTAssertFalse(source.contains("Grid"))
        XCTAssertFalse(source.contains("Open in Time"))
        XCTAssertFalse(source.contains("onMove"))
    }

    func testB02ReturnedFullDayUsesRevealedNowAndKeepsNurserySettledReadOnly() {
        launch("tfcs-f09")
        let viewFullDay = element("tfcs-view-full-day")
        XCTAssertTrue(viewFullDay.waitForExistence(timeout: 3))
        viewFullDay.tap()

        let revealedNow = element("tfcs-full-day-now-step.send-launch-brief")
        let settledNursery = element("tfcs-full-day-settled-step.nursery-ready-for-crib")
        assertExists([revealedNow, settledNursery, element("tfcs-full-day-timeline")])
        XCTAssertTrue(
            revealedNow.label.contains("The brief is drafted and waiting for one final read.")
        )
        XCTAssertEqual(
            app.buttons.matching(
                NSPredicate(
                    format: "identifier == %@",
                    "tfcs-full-day-now-step.send-launch-brief"
                )
            ).count,
            0
        )
        XCTAssertTrue(settledNursery.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(settledNursery.label.contains("Progress recorded"))
        XCTAssertFalse(element("tfcs-full-day-row-step.send-launch-brief").exists)
        XCTAssertFalse(element("tfcs-select-still-counts").exists)

        let settledTruth = "The cleared corner and paint sample now count toward the nursery."
        XCTAssertTrue(settledNursery.label.contains(settledTruth))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("tfcs-today-root").waitForExistence(timeout: 3))
        XCTAssertTrue(element("tfcs-returned-settled-step").exists)
        XCTAssertTrue(app.staticTexts[settledTruth].exists)
    }

    func testB02FocusedStepUsesOneNaturalDepthAndOneOutcome() {
        launch("b02-focused-typical")

        let identity = element("tfcs-focused-identity")
        let parent = element("tfcs-focused-parent-pursuit")
        let current = element("tfcs-focused-current-truth")
        let currentTruth = element("tfcs-current-truth")
        let whyNow = element("tfcs-focused-why-now")
        let protectedConsequence = element("tfcs-focused-protected-consequence")
        let temporal = element("tfcs-focused-temporal-anchor")
        let stillCounts = element("tfcs-select-still-counts")

        assertExists([
            identity,
            parent,
            current,
            currentTruth,
            whyNow,
            protectedConsequence,
            temporal,
            stillCounts
        ])
        XCTAssertTrue(identity.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(parent.label.contains("Welcome our baby home"))
        XCTAssertTrue(
            currentTruth.label.contains("The corner is cleared and the paint sample is chosen.")
        )
        XCTAssertLessThan(identity.frame.minY, parent.frame.minY, "\(identity.frame) then \(parent.frame)")
        XCTAssertLessThan(parent.frame.minY, current.frame.minY, "\(parent.frame) then \(current.frame)")
        XCTAssertLessThan(current.frame.minY, whyNow.frame.minY, "\(current.frame) then \(whyNow.frame)")
        XCTAssertLessThan(
            whyNow.frame.minY,
            protectedConsequence.frame.minY,
            "\(whyNow.frame) then \(protectedConsequence.frame)"
        )
        XCTAssertLessThan(
            protectedConsequence.frame.minY,
            temporal.frame.minY,
            "\(protectedConsequence.frame) then \(temporal.frame)"
        )
        XCTAssertEqual(app.buttons.matching(identifier: "tfcs-select-still-counts").count, 1)
        XCTAssertTrue(stillCounts.isHittable)
        assertMinimumTarget(stillCounts)
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
        XCTAssertFalse(app.navigationBars.staticTexts["Start Here"].exists)
        XCTAssertFalse(app.staticTexts["Done · Move it · Waiting · Blocked · Not needed"].exists)
        XCTAssertFalse(app.buttons["Other outcomes"].exists)
    }

    func testB02FocusedStepAccessibilityKeepsOutcomeReachableByNaturalScroll() {
        launch("b02-focused-accessibility5")

        let identity = element("tfcs-focused-identity")
        let stillCounts = element("tfcs-select-still-counts")
        XCTAssertTrue(identity.waitForExistence(timeout: 3))

        for _ in 0..<6 where stillCounts.isHittable == false {
            app.swipeUp()
        }

        XCTAssertTrue(stillCounts.exists)
        XCTAssertTrue(stillCounts.isHittable)
        assertMinimumTarget(stillCounts)
    }

    func testB02ReviewUsesSpatialComparisonAndAnchoredActionsAtStandardSize() {
        launch("b02-review-typical")

        let identity = element("tfcs-step-identity")
        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let transition = element("tfcs-review-transition-seam")
        let consequence = element("tfcs-review-consequence")
        let relationship = element("tfcs-review-relationship")
        let details = element("tfcs-review-details")
        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")

        assertExists([
            identity,
            current,
            proposed,
            transition,
            consequence,
            relationship,
            details,
            cancel,
            commit
        ])
        XCTAssertLessThan(identity.frame.minY, current.frame.minY)
        XCTAssertLessThan(current.frame.minY, proposed.frame.minY)
        XCTAssertLessThan(proposed.frame.minY, consequence.frame.minY)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertTrue(commit.isHittable)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
        XCTAssertFalse(element("tfcs-review-detail-content").isHittable)
    }

    func testB02SavingKeepsTruthComparisonAndPreventsDuplicateCommit() {
        launch("b02-review-saving")

        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let saving = element("tfcs-saving-posture")
        let commit = element("tfcs-commit-still-counts")
        let cancel = element("tfcs-cancel-review")

        assertExists([current, proposed, saving, commit, cancel])
        XCTAssertTrue(current.label.contains("The corner is cleared"))
        XCTAssertTrue(proposed.label.contains("Record the cleared corner"))
        XCTAssertFalse(commit.isEnabled)
        XCTAssertFalse(cancel.isEnabled)
        XCTAssertFalse(app.staticTexts["Progress recorded"].exists)
    }

    func testB02ReviewAccessibilityKeepsVerticalActionsReachable() {
        launch("b02-review-accessibility5")

        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")
        XCTAssertTrue(cancel.waitForExistence(timeout: 3))
        XCTAssertTrue(commit.exists)

        for _ in 0..<6 where commit.isHittable == false {
            app.swipeUp()
        }

        XCTAssertTrue(cancel.isHittable)
        XCTAssertTrue(commit.isHittable)
        XCTAssertLessThan(cancel.frame.minY, commit.frame.minY)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
    }

}

extension TodayFlagshipCalibrationHostUITests {
    func testB02AccessibilityAndAdaptivityMatrix() throws {
        launch("b02-review-accessibility5")

        let accessibilityReview = element("tfcs-consequential-review")
        let accessibilityCancel = element("tfcs-cancel-review")
        let accessibilityCommit = element("tfcs-commit-still-counts")
        assertExists([accessibilityReview, accessibilityCancel, accessibilityCommit])
        scrollUntilHittable(accessibilityCommit)
        XCTAssertTrue(accessibilityCancel.isHittable)
        XCTAssertLessThan(accessibilityCancel.frame.minY, accessibilityCommit.frame.minY)
        assertMinimumTarget(accessibilityCancel)
        assertMinimumTarget(accessibilityCommit)
        assertEveryVisibleButtonHasMinimumTargetAndDistinctName()

        app.terminate()
        launch("b02-root-accessibility5")
        let passage = element("tfcs-adaptive-navigation-passage")
        let passageCommands = ["today", "goals", "time", "you", "search", "capture"].map {
            element("tfcs-navigation-\($0)")
        }
        assertExists([passage])
        for command in passageCommands {
            scrollUntilHittable(command)
            assertMinimumTarget(command)
        }

        let chromeSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        XCTAssertTrue(chromeSource.contains("@Environment(\\.dynamicTypeSize)"))
        XCTAssertTrue(
            chromeSource.contains(".lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)")
        )

        app.terminate()
        launch("b02-root-reduce-transparency")
        let opaqueRoot = element("tfcs-today-root")
        let opaqueDock = element("tfcs-dock-shell-peek-opaque")
        assertExists([opaqueRoot, opaqueDock])
        assertMinimumTarget(opaqueDock)
        assertEveryVisibleButtonHasMinimumTargetAndDistinctName()

        app.terminate()
        launch("b02-root-rtl")
        let rtlCrown = element("tfcs-today-heading")
        let rtlRootStartHere = element("tfcs-start-here-object")
        assertExists([rtlCrown, rtlRootStartHere])
        XCTAssertGreaterThan(rtlCrown.frame.height, 30)
        XCTAssertLessThan(rtlCrown.frame.maxY, rtlRootStartHere.frame.minY)
        XCTAssertTrue((rtlCrown.value as? String)?.contains("في المنزل قبل العشاء") == true)

        app.terminate()
        launch("b02-full-day-rtl")
        let rtlFullDay = element("tfcs-full-day-root")
        let rtlFullDayNow = element("tfcs-full-day-now-step.nursery-ready-for-crib")
        assertExists([rtlFullDay, rtlFullDayNow, element("tfcs-full-day-timeline")])
        XCTAssertTrue(rtlFullDayNow.label.contains("جهّز زاوية سرير الطفل"))
        assertArabicOnlyLabels(in: rtlFullDay)

        app.terminate()
        launch("b02-focused-rtl")
        let rtlIdentity = element("tfcs-focused-identity")
        let rtlParent = element("tfcs-focused-parent-pursuit")
        let rtlCurrent = element("tfcs-focused-current-truth")
        assertExists([rtlIdentity, rtlParent, rtlCurrent])
        XCTAssertTrue(rtlIdentity.label.contains("جهّز زاوية سرير الطفل"))
        XCTAssertTrue(rtlParent.label.contains("نستقبل طفلنا في منزلنا"))
        XCTAssertLessThan(rtlIdentity.frame.minY, rtlParent.frame.minY)
        XCTAssertLessThan(rtlParent.frame.minY, rtlCurrent.frame.minY)
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.exists)
        assertArabicOnlyLabels(in: element("tfcs-focused-step"))

        app.terminate()
        launch("b02-review-rtl")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-commit-still-counts"),
            element("tfcs-cancel-review")
        ])
        assertArabicOnlyLabels(in: element("tfcs-consequential-review"))

        app.terminate()
        launch("b02-review-saving-rtl")
        assertExists([element("tfcs-saving-posture"), element("tfcs-consequential-review")])
        assertArabicOnlyLabels(in: element("tfcs-consequential-review"))

        app.terminate()
        launch("b02-settlement-rtl")
        assertExists([
            element("tfcs-settled-truth"),
            element("tfcs-view-history"),
            element("tfcs-return-to-today")
        ])
        assertArabicOnlyLabels(in: element("tfcs-focused-step"))

        app.terminate()
        launch("b02-returned-rtl")
        assertExists([
            element("tfcs-returned-settled-step"),
            element("tfcs-start-here-object"),
            element("tfcs-today-overview")
        ])
        assertArabicOnlyLabels(in: element("tfcs-today-root"))

        app.terminate()
        launch("b02-recovery-rtl")
        let recoveryReview = element("tfcs-recovery-review")
        assertExists([
            recoveryReview,
            element("recovery.continue-saved-progress"),
            element("recovery.keep-step")
        ])
        assertArabicOnlyLabels(in: recoveryReview)
        app.swipeDown()
        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-focused-step").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        app.terminate()
        launch("b02-focused-long-ltr")
        let longIdentity = element("tfcs-focused-identity")
        let longOutcome = element("tfcs-select-still-counts")
        XCTAssertTrue(longIdentity.waitForExistence(timeout: 3))
        XCTAssertTrue(longIdentity.label.contains("Make the nursery ready for the crib"))
        scrollUntilHittable(longOutcome)
        assertMinimumTarget(longOutcome)

        app.terminate()
        launch("b02-review-no-color")
        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let seam = element("tfcs-review-transition-seam")
        assertExists([current, proposed, seam])
        XCTAssertNotEqual(current.label, proposed.label)
        XCTAssertTrue(current.label.contains("Right now"))
        XCTAssertTrue(proposed.label.contains("Still counts"))

        app.terminate()
        launch("b02-review-contrast")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-commit-still-counts"),
            element("tfcs-cancel-review")
        ])

        app.terminate()
        launch("b02-root-dark")
        let overview = element("tfcs-today-overview")
        let dock = element("tfcs-dock-shell-peek")
        let overviewRows = overview.descendants(matching: .any)
            .allElementsBoundByIndex
            .filter { $0.identifier.hasPrefix("tfcs-overview-row-") }
        XCTAssertEqual(overviewRows.count, 3)
        let rootScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(rootScrollView.exists)
        rootScrollView.swipeUp(velocity: .slow)
        let scrollIndicator = app.otherElements.matching(
            NSPredicate(format: "label BEGINSWITH %@", "Vertical scroll bar")
        ).firstMatch
        XCTAssertTrue(scrollIndicator.waitForExistence(timeout: 2))
        XCTAssertFalse(scrollIndicator.frame.intersects(dock.frame))

        let activeScrollEvidence = XCTAttachment(screenshot: app.screenshot())
        activeScrollEvidence.name = "B02-T10-active-scroll-indicator-dock-clear"
        activeScrollEvidence.lifetime = .keepAlways
        add(activeScrollEvidence)

        let rootSource = try foundrySource(named: "TodayOpenContinuityRoot.swift")
        XCTAssertTrue(rootSource.contains("for: .scrollIndicators"))
        XCTAssertTrue(rootSource.contains("accessibilityFocused"))
        XCTAssertTrue(chromeSource.contains("accessibilityInputLabels"))

    }

    func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
        XCTAssertTrue(element("tfcs-journey-root").waitForExistence(timeout: 8))
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func todayCrown() -> XCUIElement {
        element("tfcs-today-heading")
    }

    private func foundrySource(named filename: String) throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = repositoryRoot
            .appendingPathComponent("Packages/AmbitionsPresentation/Sources")
            .appendingPathComponent("AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)
        return try String(contentsOf: source, encoding: .utf8)
    }

    private func assertArabicOnlyLabels(
        in container: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let elements = container.descendants(matching: .any).allElementsBoundByIndex.filter {
            $0.elementType == .button || $0.elementType == .staticText
        }
        let labels = elements.map { $0.label }.filter { $0.isEmpty == false }
        XCTAssertFalse(labels.isEmpty, file: file, line: line)

        for label in labels {
            let approvedIdentityRemoved = label.replacingOccurrences(of: "Ambitions S10", with: "")
            XCTAssertNil(
                approvedIdentityRemoved.range(of: "[A-Za-z]", options: .regularExpression),
                "Arabic evaluation label contains unapproved Latin text: \(label)",
                file: file,
                line: line
            )
        }
    }

    func assertExists(
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

    func assertMinimumTarget(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44, file: file, line: line)
    }

    private func assertMinimumTargetAfterSettling(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertElementSettles(element, file: file, line: line) {
            $0.isHittable && $0.frame.width >= 44 && $0.frame.height >= 44
        }
        assertMinimumTarget(element, file: file, line: line)
    }

    private func assertElementSettles(
        _ element: XCUIElement,
        timeout: TimeInterval = 3,
        file: StaticString = #filePath,
        line: UInt = #line,
        predicate: @escaping (XCUIElement) -> Bool
    ) {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { candidate, _ in
                guard let candidate = candidate as? XCUIElement else { return false }
                return predicate(candidate)
            },
            object: element
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [expectation], timeout: timeout),
            .completed,
            "Element did not reach its settled layout: \(element)",
            file: file,
            line: line
        )
    }

    private func assertEveryVisibleButtonHasMinimumTargetAndDistinctName(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let buttons = app.buttons.allElementsBoundByIndex.filter { $0.isHittable }
        let names = buttons.map { $0.label }
        XCTAssertFalse(names.contains(where: \.isEmpty), file: file, line: line)
        XCTAssertEqual(Set(names).count, names.count, file: file, line: line)
        for button in buttons {
            assertMinimumTarget(button, file: file, line: line)
        }
    }

    func scrollUntilHittable(
        _ element: XCUIElement,
        maxSwipes: Int = 8
    ) {
        var attempts = 0
        while element.isHittable == false && attempts < maxSwipes {
            app.swipeUp(velocity: .slow)
            attempts += 1
        }
        XCTAssertTrue(element.isHittable)
    }

    func pauseForEvidence(_ seconds: TimeInterval) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
