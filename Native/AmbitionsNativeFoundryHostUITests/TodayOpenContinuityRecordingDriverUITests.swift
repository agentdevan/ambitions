import XCTest

extension TodayFlagshipCalibrationHostUITests {
    func testB02SettlementAndReturnPreserveIdentityWithoutCeremony() {
        launch("b02-settlement-typical")

        let identity = element("tfcs-settlement-identity")
        let settledTruth = element("tfcs-settled-truth")
        let parent = element("tfcs-settlement-parent-pursuit")
        let evidence = element("tfcs-recorded-acknowledgment")
        let history = element("tfcs-view-history")
        let returnToday = element("tfcs-return-to-today")
        assertExists([identity, settledTruth, parent, evidence, history, returnToday])
        XCTAssertLessThan(identity.frame.minY, settledTruth.frame.minY)
        XCTAssertLessThan(settledTruth.frame.minY, evidence.frame.minY)
        XCTAssertTrue(
            settledTruth.label.contains("I primed the wall and tested the new color.")
        )
        XCTAssertTrue(parent.label.contains("Welcome our baby home"))
        XCTAssertFalse(app.images["checkmark.seal.fill"].exists)

        XCTAssertEqual(history.value as? String, "Collapsed")
        app.buttons["View history"].tap()
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        XCTAssertEqual(history.value as? String, "Expanded")
        XCTAssertTrue(element("tfcs-settled-truth").exists)
        app.buttons["View history"].tap()
        RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        XCTAssertEqual(element("tfcs-view-history").value as? String, "Collapsed")
        XCTAssertTrue(element("tfcs-settled-truth").exists)

        assertMinimumTarget(returnToday)
        returnToday.tap()

        let returnedSettledStep = element("tfcs-returned-settled-step")
        XCTAssertTrue(returnedSettledStep.waitForExistence(timeout: 4))
        XCTAssertTrue(returnedSettledStep.label.contains("Make the nursery ready for the crib"))
        XCTAssertTrue(
            returnedSettledStep.label.contains("I primed the wall and tested the new color.")
        )
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )
        XCTAssertFalse(element("tfcs-timeline-object-step.send-launch-brief").exists)
        XCTAssertTrue(element("tfcs-today-overview").exists)
        XCTAssertTrue(element("tfcs-dock-shell-peek").exists)
    }

    func testB02ReduceMotionKeepsReviewMeaningAndRequiredActions() {
        launch("b02-review-reduce-motion")

        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let transition = element("tfcs-review-transition-seam")
        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")
        assertExists([current, proposed, transition, cancel, commit])
        XCTAssertTrue(current.label.contains("Right now"))
        XCTAssertTrue(proposed.label.contains("Still counts"))
        XCTAssertNotEqual(current.label, proposed.label)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertTrue(commit.isHittable)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
    }

    func testB02J01SuccessfulJourneyRecordingDriver() {
        launch("b02-root-dark")
        pauseForEvidence(1)

        let openStep = element("tfcs-open-start-here")
        assertExists([openStep, element("tfcs-today-overview")])
        openStep.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        pauseForEvidence(1)

        element("tfcs-select-still-counts").tap()
        assertExists([
            element("tfcs-consequential-review"),
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth")
        ])
        pauseForEvidence(1)

        element("tfcs-commit-still-counts").tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        pauseForEvidence(1)

        let history = element("tfcs-view-history")
        history.tap()
        XCTAssertTrue(
            app.staticTexts["Meaningful nursery progress recorded"]
                .waitForExistence(timeout: 3)
        )
        pauseForEvidence(1)
        history.tap()

        element("tfcs-return-to-today").tap()
        let settledStep = element("tfcs-returned-settled-step")
        XCTAssertTrue(settledStep.waitForExistence(timeout: 4))
        XCTAssertEqual(
            app.staticTexts.matching(
                NSPredicate(format: "label == %@", "Send the launch brief")
            ).count,
            1
        )
        pauseForEvidence(1)

        element("tfcs-view-full-day").tap()
        assertExists([
            element("tfcs-full-day-root"),
            element("tfcs-full-day-now-step.send-launch-brief"),
            element("tfcs-full-day-settled-step.nursery-ready-for-crib")
        ])
        pauseForEvidence(1)
    }

    func testB02J02InterruptedRecoveryRecordingDriver() {
        launch("tfcs-j02-manual")
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 7))
        XCTAssertTrue(element("tfcs-interruption-seam").waitForExistence(timeout: 6))
        XCTAssertTrue(
            app.staticTexts["The corner is cleared and the paint sample is chosen."].exists
        )
        pauseForEvidence(1)

        app.buttons["Pick up where you left off"].tap()
        assertExists([
            element("tfcs-recovery-review"),
            element("tfcs-recovery-progress-field"),
            element("recovery.continue-saved-progress"),
            element("recovery.keep-step")
        ])
        pauseForEvidence(1)

        element("recovery.continue-saved-progress").tap()
        XCTAssertTrue(element("tfcs-recovered-progress").waitForExistence(timeout: 4))
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        pauseForEvidence(1)
    }

    func testB02J03AccessibilityJourneyRecordingDriver() {
        launch("b02-root-accessibility5")
        let openStep = element("tfcs-open-start-here")
        scrollUntilHittable(openStep)
        openStep.tap()
        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 4))
        pauseForEvidence(1)

        let outcome = element("tfcs-select-still-counts")
        scrollUntilHittable(outcome)
        outcome.tap()
        XCTAssertTrue(element("tfcs-consequential-review").waitForExistence(timeout: 4))
        pauseForEvidence(1)

        let commit = element("tfcs-commit-still-counts")
        scrollUntilHittable(commit)
        commit.tap()
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        pauseForEvidence(1)

        let returnToday = element("tfcs-return-to-today")
        scrollUntilHittable(returnToday)
        returnToday.tap()
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 4))
        pauseForEvidence(1)
    }

    func testB02J04DockAndNaturalScrollRecordingDriver() {
        launch("tfcs-f03")
        let peek = element("tfcs-dock-shell-peek")
        let startHere = element("tfcs-start-here-object")
        let overview = element("tfcs-today-overview")
        assertExists([peek, element("tfcs-today-heading"), startHere, overview])
        assertMinimumTarget(peek)
        peek.tap()

        assertExists([
            element("tfcs-dock-expanded"),
            element("tfcs-dock-roots-group"),
            element("tfcs-dock-global-actions-group")
        ])
        pauseForEvidence(1)
        app.buttons["Close navigation"].tap()
        XCTAssertTrue(peek.waitForExistence(timeout: 3))

        let startHereTitle = app.staticTexts["Make the nursery ready for the crib"]
        let startHereY = startHere.frame.minY
        let peekY = peek.frame.minY
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.68)).press(
            forDuration: 0.05,
            thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.645)),
            withVelocity: 100,
            thenHoldForDuration: 0.15
        )
        XCTAssertLessThan(startHere.frame.minY, startHereY - 5)
        XCTAssertTrue(startHereTitle.isHittable)
        XCTAssertTrue(overview.exists)
        XCTAssertTrue(app.staticTexts["Today’s Timeline"].isHittable)
        XCTAssertEqual(peek.frame.minY, peekY, accuracy: 1)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "B02-TFCS-F03-intentional-natural-scroll"
        attachment.lifetime = .keepAlways
        add(attachment)
        pauseForEvidence(1)

        let viewFullDay = element("tfcs-view-full-day")
        scrollUntilHittable(viewFullDay)
        viewFullDay.tap()
        assertExists([
            element("tfcs-full-day-root"),
            element("tfcs-scroll-to-now"),
            element("tfcs-full-day-timeline")
        ])
        pauseForEvidence(1)
    }

    func testB02J05ReduceMotionRecordingDriver() {
        launch("b02-review-reduce-motion")
        assertExists([
            element("tfcs-review-current-truth"),
            element("tfcs-proposed-truth"),
            element("tfcs-review-transition-seam")
        ])
        pauseForEvidence(1)

        element("tfcs-commit-still-counts").tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))
        XCTAssertTrue(element("tfcs-settled-truth").waitForExistence(timeout: 5))
        pauseForEvidence(1)

        element("tfcs-return-to-today").tap()
        XCTAssertTrue(element("tfcs-returned-settled-step").waitForExistence(timeout: 4))
        pauseForEvidence(1)
    }
}
