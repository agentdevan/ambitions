import XCTest

@MainActor
extension TodayFlagshipCalibrationHostUITests {
    func testR13SuccessfulJourneyPreservesAcceptedProposedSavingSettledAndReturnTruth() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let proposedTruthValue = "I primed the wall and tested the new color."
        launch("r13-root-dark")

        assertUniqueR13("tfcs-start-here-object")
        let overviewAnchors = [
            element("tfcs-overview-row-step.send-launch-brief"),
            element("tfcs-overview-row-event.family-time"),
            element("tfcs-overview-row-lane.open-after-family")
        ]
        assertExists(overviewAnchors + [
            element("tfcs-open-start-here"),
            element("tfcs-dock-shell-peek")
        ])
        XCTAssertLessThan(overviewAnchors[0].frame.minY, overviewAnchors[1].frame.minY)
        XCTAssertLessThan(overviewAnchors[1].frame.minY, overviewAnchors[2].frame.minY)

        element("tfcs-open-start-here").tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-focused-parent-pursuit"),
            element("tfcs-current-truth")
        ])
        element("tfcs-select-still-counts").tap()

        let currentTruth = element("tfcs-review-current-truth")
        let proposedTruth = element("tfcs-proposed-truth")
        assertExists([currentTruth, proposedTruth])
        XCTAssertEqual(currentTruth.value as? String, acceptedTruth)
        XCTAssertEqual(proposedTruth.value as? String, proposedTruthValue)

        element("tfcs-commit-still-counts").tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 4))
        XCTAssertEqual(currentTruth.value as? String, acceptedTruth)
        XCTAssertEqual(proposedTruth.value as? String, proposedTruthValue)
        XCTAssertTrue(element("tfcs-commit-still-counts").waitForNonExistence(timeout: 1))
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        XCTAssertEqual(element("tfcs-settled-truth").value as? String, proposedTruthValue)
        XCTAssertFalse(app.images["checkmark.seal.fill"].exists)

        element("tfcs-view-history").tap()
        assertExists([
            element("r13-history-entry"),
            element("r13-history-entry-truth"),
            element("r13-supporting-done")
        ])
        element("r13-supporting-done").tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 4))
        XCTAssertEqual(element("tfcs-settled-truth").value as? String, proposedTruthValue)

        element("tfcs-return-to-today").tap()
        assertExists([
            element("tfcs-returned-settled-step"),
            element("tfcs-start-here-object"),
            element("tfcs-overview-row-event.family-time"),
            element("tfcs-overview-row-lane.open-after-family")
        ])
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )

        let viewFullDay = element("tfcs-view-full-day")
        scrollUntilHittable(viewFullDay)
        viewFullDay.tap()
        assertUniqueR13("tfcs-full-day-now-step.send-launch-brief")
        assertUniqueR13("tfcs-full-day-settled-step.nursery-ready-for-crib")
        let back = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 4))
        back.tap()
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 4))
    }

    func testR13ReviewCancellationReturnsToExactUnchangedFocusedTruth() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let proposedTruth = "I primed the wall and tested the new color."
        launch("r13-root-dark")
        element("tfcs-open-start-here").tap()
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        element("tfcs-select-still-counts").tap()
        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 4))
        XCTAssertEqual(element("tfcs-review-current-truth").value as? String, acceptedTruth)
        XCTAssertEqual(element("tfcs-proposed-truth").value as? String, proposedTruth)

        element("tfcs-cancel-review").tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-current-truth"),
            element("tfcs-select-still-counts")
        ])
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)
        XCTAssertFalse(element("tfcs-proposed-truth").exists)
        XCTAssertFalse(element("tfcs-saving-posture").exists)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(element("tfcs-view-history").exists)
        XCTAssertFalse(app.staticTexts["Cancelled"].exists)
    }

    func testR13InterruptedContinuationRestoresSavedProgressWithoutSettlement() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let savedTruth = "I primed the wall and tested the new color."
        launch("r13-recovery-interrupted")
        let accepted = element("tfcs-recovery-current-truth")
        let saved = element("tfcs-recovery-progress-field")
        assertExists([
            element("tfcs-recovery-step-identity"),
            accepted,
            saved,
            element("tfcs-interruption-seam"),
            element("tfcs-open-recovery")
        ])
        XCTAssertEqual(accepted.value as? String, acceptedTruth)
        XCTAssertEqual(saved.value as? String, savedTruth)
        element("tfcs-open-recovery").tap()
        assertExists([
            element("tfcs-recovery-review"),
            element("tfcs-recovery-sheet-progress"),
            element("recovery.continue-saved-progress"),
            element("recovery.keep-step")
        ])
        XCTAssertTrue(
            String(describing: element("tfcs-recovery-sheet-progress").value).contains(savedTruth)
        )

        element("recovery.continue-saved-progress").tap()
        let recovered = element("tfcs-recovered-progress")
        XCTAssertTrue(recovered.waitForExistence(timeout: 4))
        XCTAssertEqual(recovered.value as? String, savedTruth)
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
    }

    func testR13RecoveryDismissalAndDeferralPreserveInterruptedStep() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let savedTruth = "I primed the wall and tested the new color."
        launch("r13-recovery-sheet")
        XCTAssertTrue(element("tfcs-recovery-review").waitForExistence(timeout: 4))
        XCTAssertTrue(
            String(describing: element("tfcs-recovery-sheet-progress").value).contains(savedTruth)
        )
        app.buttons["Close"].tap()
        let dismissedAccepted = element("tfcs-recovery-current-truth")
        let dismissedSaved = element("tfcs-recovery-progress-field")
        assertExists([element("tfcs-interruption-seam"), dismissedAccepted, dismissedSaved])
        XCTAssertEqual(dismissedAccepted.value as? String, acceptedTruth)
        XCTAssertEqual(dismissedSaved.value as? String, savedTruth)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(element("tfcs-recorded-acknowledgment").exists)

        relaunchR13("r13-recovery-sheet")
        XCTAssertTrue(
            String(describing: element("tfcs-recovery-sheet-progress").value).contains(savedTruth)
        )
        element("recovery.keep-step").tap()
        let deferredAccepted = element("tfcs-recovery-current-truth")
        let deferredSaved = element("tfcs-recovery-progress-field")
        assertExists([element("tfcs-interruption-seam"), deferredAccepted, deferredSaved])
        XCTAssertEqual(deferredAccepted.value as? String, acceptedTruth)
        XCTAssertEqual(deferredSaved.value as? String, savedTruth)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(element("tfcs-recorded-acknowledgment").exists)
    }

    func testR13SupportingDepthRoundTripsRemainNonMutating() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let proposedTruth = "I primed the wall and tested the new color."
        launch("r13-focused-typical")
        let focusedTruthBefore = element("tfcs-current-truth").label
        let focusedOutcomeBefore = element("tfcs-select-still-counts").label
        XCTAssertEqual(focusedTruthBefore, acceptedTruth)
        XCTAssertEqual(focusedOutcomeBefore, "Still counts")
        element("tfcs-focused-parent-pursuit").tap()
        XCTAssertTrue(element("r13-goal-detail").waitForExistence(timeout: 4))
        element("r13-supporting-done").tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-current-truth"),
            element("tfcs-select-still-counts")
        ])
        XCTAssertEqual(element("tfcs-current-truth").label, focusedTruthBefore)
        XCTAssertEqual(element("tfcs-select-still-counts").label, focusedOutcomeBefore)

        relaunchR13("r13-review-typical")
        let reviewCurrentBefore = element("tfcs-review-current-truth").value as? String
        let reviewProposedBefore = element("tfcs-proposed-truth").value as? String
        XCTAssertEqual(reviewCurrentBefore, acceptedTruth)
        XCTAssertEqual(reviewProposedBefore, proposedTruth)
        element("tfcs-review-details").tap()
        XCTAssertTrue(element("r13-consequence-details").waitForExistence(timeout: 4))
        element("r13-supporting-done").tap()
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-cancel-review"),
            element("tfcs-commit-still-counts")
        ])
        XCTAssertEqual(element("tfcs-review-current-truth").value as? String, reviewCurrentBefore)
        XCTAssertEqual(element("tfcs-proposed-truth").value as? String, reviewProposedBefore)

        relaunchR13("r13-settlement-typical")
        let settledTruthBefore = element("tfcs-settled-truth").value as? String
        XCTAssertEqual(settledTruthBefore, proposedTruth)
        element("tfcs-view-history").tap()
        XCTAssertTrue(element("r13-history-entry").waitForExistence(timeout: 4))
        element("r13-history-filter-open").tap()
        XCTAssertTrue(element("r13-history-filters").waitForExistence(timeout: 4))
        app.navigationBars["Filters"].buttons["History"].tap()
        XCTAssertTrue(element("r13-history-entry-truth").waitForExistence(timeout: 4))
        element("r13-supporting-done").tap()
        assertExists([
            element("tfcs-settled-truth"),
            element("tfcs-view-history"),
            element("tfcs-return-to-today")
        ])
        XCTAssertEqual(element("tfcs-settled-truth").value as? String, settledTruthBefore)

        relaunchR13("r13-time-transfer-evaluation")
        assertExists([
            element("r13-time-transfer-evaluation"),
            element("r13-time-transfer-cancel")
        ])
        XCTAssertTrue(app.staticTexts["Today → Time"].exists)
        XCTAssertTrue(app.staticTexts["Today remains unchanged"].exists)
        XCTAssertFalse(app.buttons["Open in Time"].exists)
        element("r13-time-transfer-cancel").tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-current-truth"),
            element("tfcs-select-still-counts")
        ])
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)
        XCTAssertEqual(element("tfcs-select-still-counts").label, "Still counts")
    }

    func testR13ResilienceSeamsStayNarrowAndLocalTruthRemainsAvailable() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        launch("r13-offline-local")
        assertExists([
            element("tfcs-context-seam-offlineLocalTruth"),
            element("tfcs-start-here-object"),
            element("tfcs-open-start-here")
        ])
        XCTAssertTrue(element("tfcs-root-current-truth").label.contains(acceptedTruth))
        XCTAssertFalse(app.buttons["Retry"].exists)
        element("tfcs-open-start-here").tap()
        assertExists([element("tfcs-current-truth"), element("tfcs-select-still-counts")])
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)
        XCTAssertEqual(element("tfcs-select-still-counts").label, "Still counts")

        relaunchR13("r13-stale-context")
        assertExists([
            element("tfcs-context-seam-staleExternalContext"),
            element("tfcs-overview-row-step.send-launch-brief"),
            element("tfcs-start-here-object")
        ])
        XCTAssertTrue(element("tfcs-start-here-object").label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(element("tfcs-root-current-truth").label.contains(acceptedTruth))
        XCTAssertTrue(
            element("tfcs-overview-row-step.send-launch-brief").label.contains("Send the launch brief")
        )
        XCTAssertFalse(app.buttons["Review Changes"].exists)

        relaunchR13("r13-conflict-transfer")
        let conflict = element("tfcs-context-seam-conflictTransfer")
        XCTAssertTrue(conflict.waitForExistence(timeout: 4))
        XCTAssertTrue(conflict.label.contains("Time"))
        XCTAssertTrue(element("tfcs-start-here-object").label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(element("tfcs-root-current-truth").label.contains(acceptedTruth))
        XCTAssertFalse(app.buttons["Open in Time"].exists)
        XCTAssertFalse(app.buttons["Undo"].exists)
    }

    func testR13FailedSettlementAndExactUndoUseOnlySupportedRecovery() {
        let acceptedTruth = "The corner is cleared and the paint sample is chosen."
        let settledTruth = "I primed the wall and tested the new color."
        launch("r13-failed-settlement")
        assertExists([
            element("tfcs-failed-settlement"),
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth")
        ])
        let retry = app.buttons["Try again"]
        let returnToStep = app.buttons["Return to Step"]
        assertMinimumTarget(retry)
        assertMinimumTarget(returnToStep)
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(element("tfcs-view-history").exists)
        retry.tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))
        XCTAssertEqual(element("tfcs-review-current-truth").value as? String, acceptedTruth)
        XCTAssertEqual(element("tfcs-proposed-truth").value as? String, settledTruth)

        relaunchR13("r13-failed-settlement")
        let returnToStepAfterRelaunch = app.buttons["Return to Step"]
        XCTAssertTrue(returnToStepAfterRelaunch.waitForExistence(timeout: 4))
        returnToStepAfterRelaunch.tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-current-truth")
        ])
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)

        relaunchR13("r13-undo-available")
        XCTAssertTrue(app.staticTexts[settledTruth].exists)
        XCTAssertTrue(
            element("r13-undo-history-preserved").label.contains("history will remain available")
        )
        element("r13-undo-keep").tap()
        let keptTruth = element("tfcs-settled-truth")
        XCTAssertTrue(keptTruth.waitForExistence(timeout: 4))
        XCTAssertEqual(keptTruth.value as? String, settledTruth)

        relaunchR13("r13-undo-available")
        element("r13-undo-commit").tap()
        assertExists([
            element("tfcs-focused-identity"),
            element("tfcs-focused-parent-pursuit"),
            element("tfcs-current-truth")
        ])
        XCTAssertEqual(element("tfcs-current-truth").label, acceptedTruth)
        XCTAssertFalse(element("tfcs-settled-truth").exists)

        relaunchR13("r13-history-entry")
        XCTAssertTrue(element("r13-history-entry").waitForExistence(timeout: 4))
        XCTAssertEqual(element("r13-history-entry-truth").label, settledTruth)

        relaunchR13("r13-settlement-typical")
        XCTAssertFalse(app.buttons["Undo"].exists)
        XCTAssertFalse(element("r13-undo-review").exists)
        XCTAssertFalse(app.buttons["Blocked consequence"].exists)
    }

    func testR13DockNaturalScrollAndFullDayKeepLockedOwnership() {
        launch("r13-root-dark")
        let startHere = element("tfcs-start-here-object")
        let peek = element("tfcs-dock-shell-peek")
        let initialStartHereY = startHere.frame.minY
        assertMinimumTarget(peek)
        app.swipeUp(velocity: .slow)
        XCTAssertLessThan(startHere.frame.minY, initialStartHereY)
        XCTAssertTrue(peek.exists)

        peek.tap()
        let rootCommands = ["today", "goals", "time", "you"].map {
            element("tfcs-dock-\($0)")
        }
        let globals = ["search", "capture"].map { element("tfcs-dock-\($0)") }
        assertExists(rootCommands + globals)
        XCTAssertEqual(rootCommands.map(\.label), ["Today", "Goals", "Time", "You"])
        XCTAssertLessThan(rootCommands.last!.frame.maxY, globals.first!.frame.minY)
        app.buttons["Close navigation"].tap()
        XCTAssertTrue(peek.waitForExistence(timeout: 4))

        let fullDay = element("tfcs-view-full-day")
        scrollUntilHittable(fullDay)
        fullDay.tap()
        assertExists([
            element("tfcs-full-day-root"),
            element("tfcs-full-day-timeline"),
            element("tfcs-scroll-to-now")
        ])
        let orderedIDs = [
            "tfcs-full-day-row-event.deep-work",
            "tfcs-full-day-now-step.nursery-ready-for-crib",
            "tfcs-full-day-row-step.send-launch-brief",
            "tfcs-full-day-row-lane.open-afternoon",
            "tfcs-full-day-row-event.family-time",
            "tfcs-full-day-row-lane.open-after-family"
        ]
        let fullDayElements = orderedIDs.map(element)
        assertExists(fullDayElements)
        let traversal = element("tfcs-full-day-timeline")
            .descendants(matching: .any)
            .allElementsBoundByIndex
            .map(\.identifier)
        let indices = orderedIDs.compactMap { traversal.firstIndex(of: $0) }
        XCTAssertEqual(indices.count, orderedIDs.count)
        for pair in zip(indices, indices.dropFirst()) {
            XCTAssertLessThan(pair.0, pair.1)
        }
        XCTAssertFalse(app.buttons["Open in Time"].exists)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(element("tfcs-today-root").waitForExistence(timeout: 4))
    }

    func testR13EnglishAccessibilityJourneyKeepsMeaningActionsAndFocusTargets() {
        launch("r13-root-accessibility5")
        assertUniqueR13("tfcs-start-here-object")
        let passage = element("tfcs-adaptive-navigation-passage")
        let continueAction = element("tfcs-open-start-here")
        assertExists([passage, continueAction])
        scrollUntilHittable(continueAction)
        assertMinimumTarget(continueAction)
        continueAction.tap()

        let outcome = element("tfcs-select-still-counts")
        XCTAssertTrue(element("tfcs-focused-identity").waitForExistence(timeout: 4))
        scrollUntilHittable(outcome)
        assertMinimumTarget(outcome)
        outcome.tap()

        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            cancel,
            commit
        ])
        scrollUntilHittable(commit)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
        commit.tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 4))
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))

        let history = element("tfcs-view-history")
        scrollUntilHittable(history)
        assertMinimumTarget(history)
        history.tap()
        XCTAssertTrue(element("r13-history-entry").waitForExistence(timeout: 4))
        element("r13-supporting-done").tap()

        let returnToday = element("tfcs-return-to-today")
        scrollUntilHittable(returnToday)
        assertMinimumTarget(returnToday)
        returnToday.tap()
        assertExists([
            element("tfcs-returned-settled-step"),
            element("tfcs-start-here-object")
        ])
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )
    }

    func relaunchR13(_ variant: String) {
        app.terminate()
        launch(variant)
    }

    func assertUniqueR13(
        _ identifier: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: identifier).count,
            1,
            file: file,
            line: line
        )
    }
}
