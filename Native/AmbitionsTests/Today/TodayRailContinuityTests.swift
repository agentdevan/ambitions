@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

final class TodayRailContinuityTests: TodayViewModelTestCase {
    func testAFEP008RealityMeridianContinuityProjectionKeepsReplayAndAccessibilitySeams() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-18T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-afep008-continuity",
            stepID: "step-afep008-continuity",
            stepTitle: "Draft the launch note",
            dueAt: "2026-04-18T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let execution = try await service.loadTodayExperience(userDisplayName: "", now: now).execution
        let continuity = execution.realityMeridianContinuity
        let replayed = makeRealityMeridianContinuityProjection(from: execution)

        XCTAssertEqual(continuity.primaryObjectTitle, "Reality Meridian")
        XCTAssertEqual(continuity.recommendationTitle, execution.recommendedStep.title)
        XCTAssertEqual(continuity.recommendationSubtitle, execution.recommendedStep.subtitle)
        XCTAssertEqual(continuity.timeRealityLabel, execution.todayTimeLayer.openWindowLabel)
        XCTAssertEqual(continuity.sourceRecordLabel, execution.dayRail.heroStep?.sourceRecordLabel)
        XCTAssertEqual(continuity.receiptLabel, execution.dayRail.heroStep?.receiptLabel)
        XCTAssertFalse(continuity.replayTraceLabel.isEmpty)
        XCTAssertFalse(continuity.youInspectionLabel.isEmpty)
        XCTAssertFalse(continuity.reducedMotionSummary.isEmpty)
        XCTAssertFalse(continuity.differentiateWithoutColorSummary.isEmpty)
        XCTAssertFalse(continuity.dynamicTypeSummary.isEmpty)
        XCTAssertEqual(continuity.voiceOverOrder.prefix(3), ["Reality Meridian", "Start here", execution.recommendedStep.title])
        XCTAssertEqual(replayed, continuity)
    }

    func testAFEP008RealityMeridianContinuityPreservesRecommendationAcrossRecoveryContinuation() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-19T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-afep008-recovery",
            stepID: "step-afep008-recovery",
            stepTitle: "Finish the launch note",
            dueAt: "2026-04-19T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let execution = try await service.loadTodayExperience(userDisplayName: "", now: now).execution
        let baseline = execution.realityMeridianContinuity
        let continued = makeRealityMeridianContinuityProjection(
            from: execution,
            recoveryLabel: "Recovery stays visible while the recommendation remains fixed."
        )

        XCTAssertEqual(continued.recommendationTitle, baseline.recommendationTitle)
        XCTAssertEqual(continued.recommendationSubtitle, baseline.recommendationSubtitle)
        XCTAssertNotEqual(continued.recoveryLabel, baseline.recoveryLabel)
        XCTAssertEqual(continued.restorationIdentity, continued.continuationIdentity)
        XCTAssertTrue(continued.voiceOverOrder.contains(continued.receiptLabel))
    }


    func testF02RealityRailRowsStayDeterministicallyOrdered() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let first = makeGoal(id: "goal-a", stepID: "step-a", stepTitle: "Send the client spreadsheet", dueAt: "2026-04-15T20:00:00Z", domain: .career)
        let second = makeGoal(id: "goal-b", stepID: "step-b", stepTitle: "Draft PM transition notes", dueAt: "2026-04-16T20:00:00Z", domain: .career)
        let third = makeGoal(id: "goal-c", stepID: "step-c", stepTitle: "Review the budget note", dueAt: "2026-04-17T20:00:00Z", domain: .finance)
        try await repositories.goals.saveGoals([third, first, second])

        let rows = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail.rows

        XCTAssertEqual(rows.map(\.slot), [.now, .next, .later])
        XCTAssertEqual(rows.map(\.title), [
            "Send the client spreadsheet",
            "Draft PM transition notes",
            "Review the budget note"
        ])
    }

    func testF02RealityRailPrivateProjectionDoesNotExposeSensitiveDetails() {
        let rail = PreviewTodayScenarios.privateRail.execution.dayRail
        let copy = f02VisibleRailCopy(rail)

        XCTAssertTrue(rail.privacyProjection.isSensitiveProjection)
        XCTAssertTrue(copy.contains("Private item"))
        XCTAssertTrue(copy.contains("Details stay private on Today."))
        XCTAssertFalse(copy.contains("Draft the talk outline"))
        XCTAssertFalse(copy.contains("Submit my conference talk proposal"))
        XCTAssertFalse(copy.contains("Record one rough vocal pass"))
    }

    func testSI04DayRailRhythmStripCompilesForRequiredPreviewStates() {
        let rails = [
            PreviewTodayScenarios.stable.execution.dayRail,
            PreviewTodayScenarios.privateRail.execution.dayRail,
            PreviewTodayScenarios.overloaded.execution.dayRail,
            PreviewTodayScenarios.empty.execution.dayRail
        ]

        for rail in rails {
            _ = DayRailRhythmStrip(state: rail, semanticState: .focus)
        }

        XCTAssertEqual(rails.map(\.mode), [.normal, .normal, .normal, .empty])
        XCTAssertEqual(DayRailRowSlot.allCases.map(\.title), ["Now", "Next", "Later"])
        XCTAssertTrue(rails.contains { $0.heroStep == nil })
        XCTAssertTrue(rails.contains { $0.privacyProjection.isSensitiveProjection })
    }

    func testF02RealityRailVisibleCopyAvoidsForbiddenTerms() {
        let rails = [
            PreviewTodayScenarios.stable.execution.dayRail,
            PreviewTodayScenarios.privateRail.execution.dayRail,
            PreviewTodayScenarios.empty.execution.dayRail
        ]
        let forbidden = [
            "Start Focus",
            "Focus Session",
            forbiddenCopyTerm("best", "next", "move"),
            forbiddenCopyTerm("next", "best", "move"),
            forbiddenCopyTerm("AI", "confidence"),
            forbiddenCopyTerm("productivity", "score"),
            forbiddenCopyTerm("profile", "tab"),
            forbiddenCopyTerm("insights", "tab"),
            forbiddenCopyTerm("habits", "tab"),
            "overdue",
            "failed",
            "missed"
        ]

        for rail in rails {
            let copy = f02VisibleRailCopy(rail)
            for term in forbidden {
                XCTAssertFalse(
                    copy.localizedCaseInsensitiveContains(term),
                    "Reality Meridian visible copy should not contain forbidden term: \(term)"
                )
            }
        }
    }

    func testF02RealityRailContinuityDoesNotClaimHiddenClosureOrProofMutation() {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let renderedReservationCopy = f02RenderedReservationCopy(rail)

        XCTAssertTrue(rail.closureSlot.reservedForActionClosureSheet)
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertTrue(renderedReservationCopy.contains("Closure knot"))
        XCTAssertTrue(renderedReservationCopy.contains("Proof marker"))
        XCTAssertTrue(renderedReservationCopy.contains("Changes stay reviewable."))
        XCTAssertFalse(renderedReservationCopy.localizedCaseInsensitiveContains("auto-complete"))
        XCTAssertFalse(renderedReservationCopy.localizedCaseInsensitiveContains("rearrange"))
    }

    func testF03RealityRailHeroAndRowProduceStepDetailState() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let row = try XCTUnwrap(rail.rows.first)

        let heroDetail = hero.stepDetail(privacy: rail.privacyProjection, contextLabel: rail.contextSummary)
        let rowDetail = row.stepDetail(privacy: rail.privacyProjection, contextLabel: rail.contextSummary)

        XCTAssertEqual(heroDetail.timingBucket, "Start here")
        XCTAssertEqual(heroDetail.title, hero.title)
        XCTAssertEqual(heroDetail.primaryAction.title, "Start now")
        XCTAssertEqual(heroDetail.closureAction.title, "Close the loop")
        XCTAssertEqual(heroDetail.stepSessionLabel, "Step session opens for this one step.")
        XCTAssertEqual(heroDetail.detailTarget.kind, .stepDetail)
        XCTAssertEqual(rowDetail.timingBucket, "Now")
        XCTAssertEqual(rowDetail.title, row.title)
        XCTAssertTrue(rowDetail.goalLinkLabel.contains(row.title))
        XCTAssertEqual(rowDetail.detailTarget.kind, .stepDetail)
    }

    func testF03StepDetailShowsCompliantDeterministicExplanationLabels() throws {
        let detail = try XCTUnwrap(PreviewTodayScenarios.stepDetailStartHere)
        let copy = detail.visibleCopy

        XCTAssertTrue(copy.contains("Open step"))
        XCTAssertTrue(copy.contains("Recommended because"))
        XCTAssertTrue(copy.contains("Based on your Time"))
        XCTAssertTrue(copy.contains("Duration source: Suggested duration"))
        XCTAssertTrue(copy.contains("Start now"))
        XCTAssertTrue(copy.contains("Close the loop"))
        XCTAssertTrue(copy.contains("Move it"))
        XCTAssertTrue(copy.contains("Review later"))
        XCTAssertTrue(copy.contains("Proof and receipts stay attached to this step"))
        XCTAssertTrue(copy.contains("Changes stay reviewable"))
        XCTAssertFalse(detail.whyBullets.isEmpty)
    }

    func testUIQL004StartHereKernelProjectionBindsRecommendationObjectProof() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let kernel = hero.startHereProductKernel(privacy: rail.privacyProjection)
        let summary = kernel.accessibilitySummary

        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).isEmpty)
        XCTAssertEqual(kernel.label, "Start here")
        XCTAssertEqual(kernel.primaryActionTitle, "Start now")
        XCTAssertEqual(kernel.secondaryActionTitle, "Move this")
        XCTAssertTrue(summary.contains(hero.title))
        XCTAssertTrue(summary.contains(hero.becauseLine))
        XCTAssertTrue(summary.contains(hero.fitLabel))
        XCTAssertTrue(summary.contains(hero.sourceQualityLabel))
        XCTAssertTrue(summary.contains(hero.contextEdge.title))
        XCTAssertTrue(summary.contains(hero.timeFitProof.title))
        XCTAssertTrue(summary.contains(hero.goalThread.title))
        XCTAssertTrue(summary.contains("Start here review history"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("recommendation card"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(summary.localizedCaseInsensitiveContains("task list"))
    }

    func testUIQL004PrivateStartHereKernelKeepsRecommendationProofRedacted() throws {
        let rail = PreviewTodayScenarios.privateRail.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let kernel = hero.startHereProductKernel(privacy: rail.privacyProjection)
        let summary = kernel.accessibilitySummary

        XCTAssertTrue(StartHereProductKernelAudit.failures(for: kernel).isEmpty)
        XCTAssertEqual(kernel.title, "Private step")
        XCTAssertEqual(kernel.subtitle, "Details stay private on Today.")
        XCTAssertEqual(kernel.becauseLine, "Private source")
        XCTAssertTrue(summary.contains("Private source"))
        XCTAssertFalse(summary.contains("Draft the talk outline"))
        XCTAssertFalse(summary.contains("Submit my conference talk proposal"))
    }

    func testF03PrivateStepDetailRedactsSensitiveTitleAndExplanation() throws {
        let detail = try XCTUnwrap(PreviewTodayScenarios.privateStepDetail)
        let copy = detail.visibleCopy

        XCTAssertTrue(detail.isPrivateProjection)
        XCTAssertEqual(detail.title, "Private step")
        XCTAssertEqual(detail.privacyStateLabel, "Details hidden here")
        XCTAssertEqual(detail.goalLinkLabel, "Goal link hidden here")
        XCTAssertTrue(detail.proofReceiptLabel.contains("stay private"))
        XCTAssertTrue(copy.contains("Private source"))
        XCTAssertTrue(copy.contains("Details hidden here"))
        XCTAssertFalse(copy.contains("Draft the talk outline"))
        XCTAssertFalse(copy.contains("Submit my conference talk proposal"))
        XCTAssertFalse(copy.contains("Record one rough vocal pass"))
    }

    func testF03StepDetailCopyAvoidsForbiddenTerms() throws {
        let details = [
            try XCTUnwrap(PreviewTodayScenarios.stepDetailStartHere),
            try XCTUnwrap(PreviewTodayScenarios.stepDetailRow),
            try XCTUnwrap(PreviewTodayScenarios.privateStepDetail),
            PreviewTodayScenarios.missingDurationStepDetail
        ]
        let forbidden = [
            "Start Focus",
            "Focus Session",
            forbiddenCopyTerm("best", "next", "move"),
            forbiddenCopyTerm("next", "best", "move"),
            forbiddenCopyTerm("AI", "confidence"),
            forbiddenCopyTerm("productivity", "score"),
            forbiddenCopyTerm("profile", "tab"),
            forbiddenCopyTerm("insights", "tab"),
            forbiddenCopyTerm("habits", "tab"),
            "overdue",
            "failed",
            "missed"
        ]

        for detail in details {
            for term in forbidden {
                XCTAssertFalse(
                    detail.visibleCopy.localizedCaseInsensitiveContains(term),
                    "Step Detail visible copy should not contain forbidden term: \(term)"
                )
            }
        }
    }

    func testF04StartNowUsesStepSessionActionAndClosureSheetReservation() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let detail = try XCTUnwrap(PreviewTodayScenarios.stepDetailStartHere)

        XCTAssertEqual(detail.primaryAction.title, "Start now")
        XCTAssertEqual(detail.primaryAction.kind, .startStepSession)
        XCTAssertEqual(detail.closureAction.kind, .closeActionClosure)
        XCTAssertEqual(detail.closureAction.title, "Close the loop")
        XCTAssertEqual(detail.secondaryActions.map(\.title), ["Mark Done", "Move it", "Review later"])
        XCTAssertTrue(rail.closureSlot.reservedForActionClosureSheet)
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertTrue(f02RenderedReservationCopy(rail).contains("Closure knot"))
    }

    func testF05ActionClosureSheetSupportsStillCountsWithReceiptPreview() throws {
        let target = TodayActionTarget(goalID: "goal-f05", stepID: "step-f05")
        let sheet = TodayActionClosureSheetState.step(
            title: "Write the launch notes",
            context: "Start here",
            target: target
        )

        XCTAssertEqual(sheet.prompt, "What changed?")
        XCTAssertEqual(sheet.primaryOutcomes.map(\.closureState), [.completed, .stillCounts, .moved, .waiting, .blocked, .notNeeded])
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .blocked })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .waiting })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .needsRecovery })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .needsReview })
        XCTAssertTrue(sheet.outcomes.contains { $0.title == "Review later" })
        XCTAssertEqual(sheet.outcomes.first { $0.closureState == .stillCounts }?.receiptPreview, "Still counts · saved as proof")
        XCTAssertEqual(
            sheet.outcomes.first { $0.closureState == .stillCounts }?.consequenceLabel,
            "Saves the real progress as proof without pretending the original ask happened."
        )
        XCTAssertEqual(
            sheet.outcomes.first { $0.closureState == .blocked }?.recoveryPrompt,
            "Reduce the ask or move the step before trying again."
        )
        XCTAssertTrue(sheet.recoveryReceiptLabel.contains("does not rearrange the day"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("failed"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("overdue"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains(forbiddenCopyTerm("AI", "confidence")))
    }

    func testTrain6ActionClosureSheetExplainsOutcomeConsequenceReceiptAndUndoWithoutSilentMutation() throws {
        let target = TodayActionTarget(goalID: "goal-fcp13a", stepID: "step-fcp13a")
        let sheet = TodayActionClosureSheetState.step(
            title: "Send the launch note",
            context: "Start here",
            target: target
        )

        let stillCounts = try XCTUnwrap(sheet.outcomes.first { $0.closureState == .stillCounts })
        let blocked = try XCTUnwrap(sheet.outcomes.first { $0.closureState == .blocked })

        XCTAssertEqual(sheet.diamond.title, "What changes")
        XCTAssertEqual(sheet.diamond.centerLabel, "Save outcome")
        XCTAssertFalse(sheet.visibleCopy.contains("Outcome map"))
        XCTAssertTrue(sheet.visibleCopy.contains("Choose the closest honest outcome"))
        XCTAssertTrue(sheet.visibleCopy.contains("does not rearrange the day silently"))
        XCTAssertTrue(stillCounts.undoPreviewLabel.contains("Undo remains available"))
        XCTAssertTrue(blocked.recoveryPrompt.contains("Reduce the ask"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains(forbiddenCopyTerm("AI", "confidence")))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("failed"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("overdue"))
    }

    func testF05StepSessionSurfacesCloseTheLoopWithoutAutoCompleting() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-f05-session", stepID: "step-f05-session", stepTitle: "Closeable step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(
            userDisplayName: "",
            now: now,
            entryContext: .stepSession
        )

        let session = try XCTUnwrap(experience.support.stepSession)
        XCTAssertEqual(session.sessionControlActions.map(\.kind), [.pauseStepSession, .stopStepSession, .closeActionClosure])
        XCTAssertEqual(session.sessionControlActions.map(\.title), ["Pause", "Stop session", "Close the loop"])
        XCTAssertNotEqual(session.primaryAction.kind, .closeActionClosure)
        XCTAssertEqual(session.timerLabel, "Timer optional")
        XCTAssertTrue(session.receiptGenerationLabel.contains("review preview"))
        XCTAssertTrue(session.exitBoundaryLabel.contains("without changing proof or plan"))
    }

    func testActionClosureBuildsLocalReceiptPreviewBeforePersistence() {
        let target = TodayActionTarget(goalID: "goal-f06", stepID: "step-f06")
        let sheet = TodayActionClosureSheetState.step(
            title: "Write the launch notes",
            context: "Start here",
            target: target
        )
        let stillCounts = try! XCTUnwrap(sheet.outcomes.first { $0.closureState == .stillCounts })
        let reviewLater = try! XCTUnwrap(sheet.outcomes.first { $0.closureState == .needsReview })
        let waiting = try! XCTUnwrap(sheet.outcomes.first { $0.closureState == .waiting })

        let proofPeek = sheet.proofReceiptPeek(for: stillCounts, occurredAt: "2026-05-01T12:00:00Z")
        let reviewPeek = sheet.proofReceiptPeek(for: reviewLater, occurredAt: "2026-05-01T12:05:00Z")
        let waitingPeek = sheet.proofReceiptPeek(for: waiting, occurredAt: "2026-05-01T12:10:00Z")

        XCTAssertEqual(proofPeek.title, "Proof saved")
        XCTAssertTrue(proofPeek.subtitle.contains("Still counts"))
        XCTAssertEqual(proofPeek.proofLabel, "Added to proof")
        XCTAssertEqual(proofPeek.privacyLabel, "Stored on this device")
        XCTAssertEqual(proofPeek.noSilentChangesLabel, "Changes stay reviewable")
        XCTAssertEqual(reviewPeek.title, "Needs confirmation")
        XCTAssertEqual(reviewPeek.proofLabel, "Needs confirmation")
        XCTAssertEqual(waitingPeek.proofLabel, "Needs confirmation")
        XCTAssertTrue(waitingPeek.subtitle.contains("Waiting"))
    }

}
