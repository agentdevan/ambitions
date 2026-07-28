import XCTest

extension TodayFlagshipCalibrationHostUITests {
    func testR13ReviewShowsDecisionAndBothActionsBeforeScrolling() {
        launch("r13-review-typical")

        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let consequence = element("tfcs-review-consequence")
        let relationship = element("tfcs-review-relationship")
        let trust = element("tfcs-review-trust-cue")
        let details = element("tfcs-review-details")
        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")

        assertExists([
            current,
            proposed,
            consequence,
            relationship,
            trust,
            details,
            cancel,
            commit
        ])
        XCTAssertLessThan(current.frame.minY, proposed.frame.minY)
        XCTAssertLessThan(proposed.frame.minY, consequence.frame.minY)
        XCTAssertTrue(cancel.isHittable)
        XCTAssertTrue(commit.isHittable)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
        XCTAssertFalse(element("tfcs-review-detail-content").isHittable)
    }

    func testR13ReviewCancellationReturnsToUnchangedFocusedStep() {
        launch("r13-review-typical")

        let cancel = element("tfcs-cancel-review")
        XCTAssertTrue(cancel.waitForExistence(timeout: 3))
        cancel.tap()

        XCTAssertTrue(element("tfcs-focused-step").waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.staticTexts["The corner is cleared and the paint sample is chosen."].exists
        )
        XCTAssertFalse(element("tfcs-settled-truth").exists)
        XCTAssertFalse(app.staticTexts["Progress recorded"].exists)
    }

    func testR13SavingKeepsBothTruthsAndOffersNoDuplicateCommit() {
        launch("r13-review-saving")

        let current = element("tfcs-review-current-truth")
        let proposed = element("tfcs-proposed-truth")
        let saving = element("tfcs-saving-posture")
        assertExists([current, proposed, saving])

        XCTAssertTrue(String(describing: current.value).contains("The corner is cleared"))
        XCTAssertTrue(String(describing: proposed.value).contains("I primed the wall"))
        XCTAssertFalse(element("tfcs-commit-still-counts").exists)
        XCTAssertFalse(element("tfcs-cancel-review").exists)
        XCTAssertFalse(app.staticTexts["Progress recorded"].exists)
        assertMinimumTarget(saving)
    }

    func testR13RejectedCommitLeavesSavingForExplicitRecovery() {
        launch("r13-review-failure-callback")

        let commit = element("tfcs-commit-still-counts")
        XCTAssertTrue(commit.waitForExistence(timeout: 3))
        commit.tap()
        XCTAssertTrue(element("tfcs-saving-posture").waitForExistence(timeout: 2))

        let failure = element("tfcs-failed-settlement")
        XCTAssertTrue(failure.waitForExistence(timeout: 5))
        XCTAssertTrue(element("tfcs-review-current-truth").exists)
        XCTAssertTrue(element("tfcs-proposed-truth").exists)
        XCTAssertTrue(app.buttons["Try again"].exists)
        XCTAssertTrue(app.buttons["Return to Step"].exists)
        XCTAssertFalse(app.staticTexts["Progress recorded"].exists)
    }

    func testR13AccessibilityReviewActionsRemainReachableByNaturalScroll() {
        launch("r13-review-accessibility5")

        let cancel = element("tfcs-cancel-review")
        let commit = element("tfcs-commit-still-counts")
        XCTAssertTrue(cancel.waitForExistence(timeout: 3))
        XCTAssertTrue(commit.exists)

        for _ in 0..<8 where commit.isHittable == false {
            app.swipeUp()
        }

        XCTAssertTrue(cancel.isHittable)
        XCTAssertTrue(commit.isHittable)
        assertAccessibilityOrder(cancel, before: commit)
        assertMinimumTarget(cancel)
        assertMinimumTarget(commit)
    }

    func testR13ReviewStressVariantsKeepExplicitTruthAndActions() {
        for variant in [
            "r13-review-increased-contrast",
            "r13-review-differentiate-without-color",
            "r13-review-reduce-motion"
        ] {
            launch(variant)

            XCTAssertTrue(element("tfcs-review-current-truth").waitForExistence(timeout: 3))
            XCTAssertTrue(element("tfcs-proposed-truth").exists)
            XCTAssertTrue(element("tfcs-cancel-review").isHittable)
            XCTAssertTrue(element("tfcs-commit-still-counts").isHittable)
            XCTAssertFalse(app.staticTexts["Progress recorded"].exists)
            app.terminate()
        }
    }
}
