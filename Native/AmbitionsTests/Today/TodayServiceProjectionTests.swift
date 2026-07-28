@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

final class TodayServiceProjectionTests: TodayViewModelTestCase {
    func testRepositoryBackedServiceUsesNeutralGreetingForBlankName() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)

        let now = try XCTUnwrap(Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 13)))
        let experience = try await service.loadTodayExperience(userDisplayName: "   ", now: now)

        XCTAssertEqual(experience.mode, .empty)
        XCTAssertEqual(experience.hero.truth.greeting, "Good afternoon")
    }

    func testRepositoryBackedServiceUsesSharedNextStepSelectorForFocus() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let soon = makeGoal(id: "goal-soon", stepID: "step-soon", stepTitle: "Soon shared step", dueAt: "2026-04-16T12:00:00Z")
        let later = makeGoal(id: "goal-later", stepID: "step-later", stepTitle: "Later shared step", dueAt: "2026-05-01T12:00:00Z")
        try await repositories.goals.saveGoals([later, soon])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let expected = PlanningNextStepSelector().bestSelection(goals: [later, soon], now: now)

        XCTAssertEqual(experience.hero.truth.nowTitle, expected?.step.title)
        XCTAssertEqual(experience.support.fixedCommitments.items.first?.id, expected?.step.id)
    }

    func testRepositoryBackedServiceIncludesComputedRitualState() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-ritual", stepID: "step-ritual", stepTitle: "Ritual-backed step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.hero.truth.posture, .stable)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .startStepSession)
        XCTAssertEqual(experience.hero.primaryAction.action.target.goalID, "goal-ritual")
        XCTAssertTrue(experience.hero.truth.contextPills.contains(where: { $0.title.contains("1 active goal") }))
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
        XCTAssertNil(experience.support.recoveryBloom)
    }

    func testRepositoryBackedServiceTurnsRejectionReceiptsIntoLocalFeedbackHistory() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let goal = makeGoal(id: "goal-rejection", stepID: "step-rejection", stepTitle: "Draft launch note", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let receipt = ActionReceipt.stepRejectedReceipt(
            id: "receipt-rejection",
            candidateID: "candidate-rejection",
            sourceStepID: "step-rejection",
            sourceCandidateID: "candidate-source-rejection",
            reason: StepCandidateRejectionReason(code: .tooLong),
            contextFingerprint: "context-fingerprint-rejection",
            recordedAt: "2026-04-21T09:00:00Z",
            skippedReason: true
        )
        if let historyRepository = repositories.actionReceiptHistory {
            try await historyRepository.save([
                ActionReceiptHistoryRecord(receipt: receipt, privacyLevel: .safeToShow, localOnly: true)
            ])
        }

        let snapshot = try await service.loadSnapshot()

        XCTAssertTrue(snapshot.feedback.contains(where: { event in
            event.kind == .skipped && event.stepID == "step-rejection"
        }))
    }

    func testRepositoryBackedServiceTurnsCompletedReceiptsIntoAccomplishmentFeedbackHistory() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let goal = makeGoal(id: "goal-completion", stepID: "step-completed", stepTitle: "Close the loop", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let step = LifeGraphObjectReference(kind: .step, id: "step-completed", label: "Recommended step", sourceDomain: .today)
        let receipt = ActionReceipt(
            id: "receipt-completed",
            resultState: .completed,
            title: "Completed",
            summary: "Completed step · receipt saved",
            sourceDomain: .today,
            occurredAt: "2026-04-21T09:15:00Z",
            affectedObjects: [step],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt-completed.completed",
                    kind: .completedAction,
                    object: step,
                    summary: "The local step was completed."
                )
            ],
            sourceObject: step
        )
        if let historyRepository = repositories.actionReceiptHistory {
            try await historyRepository.save([
                ActionReceiptHistoryRecord(receipt: receipt, privacyLevel: .safeToShow, localOnly: true)
            ])
        }

        let snapshot = try await service.loadSnapshot()

        XCTAssertTrue(snapshot.feedback.contains(where: { event in
            guard case let .completed(base, actualDuration, effortLevel, confidenceDelta) = event else { return false }
            return base.stepID == "step-completed" &&
                base.occurredAt == "2026-04-21T09:15:00Z" &&
                base.note == "Completed step · receipt saved" &&
                actualDuration == nil &&
                effortLevel == .medium &&
                confidenceDelta == nil
        }))
    }

    func testToday2StableHeroShowsContextLensBestMoveExplanationAndCommands() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-work",
            stepID: "step-work",
            stepTitle: "Send the client spreadsheet",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.hero.kind, .nextAction)
        XCTAssertEqual(experience.execution.activeLens.title, "Work")
        XCTAssertEqual(experience.execution.hero.smallestUsefulNextStep, "Send the client spreadsheet")
        XCTAssertEqual(experience.execution.protectedMustDo.title, "Keep this")
        XCTAssertEqual(experience.execution.recommendedStep.subtitle, "Send the client spreadsheet")
        XCTAssertEqual(experience.execution.recommendedStep.title, "Recommended step")
        XCTAssertEqual(experience.execution.notToday.title, "Not today")
        XCTAssertEqual(experience.execution.recoveryFallback.title, "Fallback")
        XCTAssertEqual(experience.execution.whyThisMatters.title, "Why this matters")
        XCTAssertEqual(experience.execution.actionClosureEntry.value, "Needs a quick check")
        XCTAssertEqual(experience.execution.dayState, .steady)
        XCTAssertEqual(experience.execution.frictionSignal.kind, .friction)
        XCTAssertEqual(experience.execution.supportingPanels.count, 2)
        XCTAssertEqual(experience.execution.todayTimeLayer.title, "Today schedule")
        XCTAssertFalse(experience.execution.todayTimeLayer.items.isEmpty)
        XCTAssertEqual(experience.execution.todayTimeLayer.calendarSourceLabel, "Based on your Time")
        XCTAssertFalse(experience.execution.todayTimeLayer.openWindowLabel.isEmpty)
        XCTAssertNotNil(experience.execution.hero.explanation)
        XCTAssertNotNil(experience.execution.saveTheDayAction)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .startStepSession && $0.commandPayload.diagnosticCase == "startSession" })
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .askWhyThisMatters && $0.commandPayload.diagnosticCase == "askWhy" })
    }

    func testF01DayRailFoundationProjectsStartHereRowsAndFutureSlots() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let first = makeGoal(id: "goal-first", stepID: "step-first", stepTitle: "Send the client spreadsheet", dueAt: "2026-05-15T20:00:00Z", domain: .career)
        let second = makeGoal(id: "goal-second", stepID: "step-second", stepTitle: "Draft PM transition notes", dueAt: "2026-05-16T20:00:00Z", domain: .career)
        let third = makeGoal(id: "goal-third", stepID: "step-third", stepTitle: "Review the budget note", dueAt: "2026-05-17T20:00:00Z", domain: .finance)
        try await repositories.goals.saveGoals([third, second, first])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let rail = experience.execution.dayRail
        let heroStep = try XCTUnwrap(rail.heroStep)

        XCTAssertEqual(rail.mode, .recovery)
        XCTAssertEqual(heroStep.title, experience.execution.hero.title)
        XCTAssertEqual(heroStep.primaryAction.title, "Start now")
        XCTAssertEqual(heroStep.duration.source, .suggested)
        XCTAssertEqual(rail.durationSource, .suggested)
        XCTAssertEqual(rail.primaryAction?.kind, .startStepSession)
        XCTAssertEqual(rail.rowTapDetailTargetPlaceholder?.kind, .stepDetail)
        XCTAssertEqual(rail.rowTapDetailTargetPlaceholder?.placeholderLabel, "Open Step Detail.")
        XCTAssertEqual(rail.rows.map(\.slot), [.now, .next, .later])
        XCTAssertTrue(rail.contextLabels.contains { $0.label == "Based on your Time" })
        XCTAssertTrue(rail.contextLabels.contains { $0.label == "Stored on this device" })
        XCTAssertTrue(rail.closureSlot.reservedForActionClosureSheet)
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertTrue(rail.proofSlot.noSilentChanges)
        XCTAssertEqual(rail.continuity.markers.map(\.title), ["Start here", "Now", "Next", "Later", "Closure knot", "Proof marker", "Pressure"])
        XCTAssertEqual(heroStep.contextEdge.title, "Context edge")
        XCTAssertEqual(heroStep.timeFitProof.title, "Time fit")
        XCTAssertEqual(heroStep.goalThread.title, "Goal thread")
        XCTAssertEqual(heroStep.receiptItem.title, "Start here review history")
        XCTAssertEqual(heroStep.receiptLabel, "Start here review history")
        XCTAssertEqual(heroStep.proofLabel, "No change has been made yet.")
        XCTAssertEqual(heroStep.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(heroStep.replayTraceLabel, "Review path stays inspectable")
        XCTAssertTrue(heroStep.replayInspectionLabel.contains("Source record stays local"))
        XCTAssertTrue(heroStep.replayInspectionLabel.contains("Review path stays inspectable"))
        XCTAssertTrue(heroStep.startHereReplayCoverage.isGreen)
        XCTAssertTrue(heroStep.startHereReplayCoverage.isInsideRealityMeridian)
        XCTAssertTrue(heroStep.startHereReplayCoverage.hasStartHereDecisionLayer)
        XCTAssertTrue(heroStep.startHereReplayCoverage.hasSourceRecord)
        XCTAssertTrue(heroStep.startHereReplayCoverage.hasReceipt)
        XCTAssertTrue(heroStep.startHereReplayCoverage.hasReplayTrace)
        XCTAssertTrue(heroStep.startHereReplayCoverage.isInspectableFromYou)
    }

    func testF01DayRailPrivacyProjectionRedactsSensitiveTitles() {
        let privateProjection = DayRailPrivacyProjectionState(classification: .privateUserText)
        let sensitiveProjection = DayRailPrivacyProjectionState(classification: .sensitive)
        let standardProjection = DayRailPrivacyProjectionState(classification: .standard)

        XCTAssertTrue(privateProjection.isSensitiveProjection)
        XCTAssertTrue(sensitiveProjection.isSensitiveProjection)
        XCTAssertEqual(privateProjection.visibleTitle("Therapy appointment"), "Private item")
        XCTAssertEqual(privateProjection.visibleSubtitle("Discuss personal details"), "Details stay private on Today.")
        XCTAssertEqual(sensitiveProjection.sourceLabel, "Private source")
        XCTAssertFalse(standardProjection.isSensitiveProjection)
        XCTAssertEqual(standardProjection.visibleTitle("Draft PM transition notes"), "Draft PM transition notes")
    }

    func testF01DayRailFoundationAvoidsForbiddenRecommendationCopy() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-copy",
            stepID: "step-copy",
            stepTitle: "Draft PM transition notes",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let rail = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail
        let visibleCopy = [
            rail.dateTitle,
            rail.contextSummary,
            rail.heroStep?.title,
            rail.heroStep?.subtitle,
            rail.heroStep?.fitLabel,
            rail.heroStep?.whySummary,
            rail.heroStep?.sourceQualityLabel,
            rail.heroStep?.becauseLine,
            rail.heroStep?.contextEdge.summary,
            rail.heroStep?.timeFitProof.detail,
            rail.heroStep?.goalThread.summary,
            rail.heroStep?.receiptItem.accessibilitySummary,
            rail.heroStep?.primaryAction.title,
            rail.heroStep?.secondaryAction?.title,
            rail.closureSlot.title,
            rail.closureSlot.subtitle,
            rail.proofSlot.title,
            rail.proofSlot.subtitle
        ].compactMap { $0 }.joined(separator: " ")

        let forbidden = [
            forbiddenCopyTerm("AI", "confidence"),
            "model reasoning",
            forbiddenCopyTerm("productivity", "score"),
            forbiddenCopyTerm("best", "next", "move"),
            forbiddenCopyTerm("next", "best", "move"),
            "overdue",
            "failed",
            "missed"
        ]
        for term in forbidden {
            XCTAssertFalse(
                visibleCopy.localizedCaseInsensitiveContains(term),
                "Day Rail visible copy should not contain forbidden term: \(term)"
            )
        }
    }

    func testF02RealityRailVisibleProjectionUsesStartHereAndStartNowCopy() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-visible-rail",
            stepID: "step-visible-rail",
            stepTitle: "Draft PM transition notes",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let rail = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)

        XCTAssertEqual(hero.primaryAction.title, "Start now")
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Start here"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Start now"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Now"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Next"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Later"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Reality Meridian continuity"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Changes stay reviewable"))
    }

    func testFCP05StartHereSurfaceCarriesSourceTimeGoalAndReceiptSeam() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-fcp05",
            stepID: "step-fcp05",
            stepTitle: "Draft PM transition notes",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let rail = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let copy = f02VisibleRailCopy(rail)

        XCTAssertTrue(copy.contains("Context edge"))
        XCTAssertTrue(copy.contains("Time fit"))
        XCTAssertTrue(copy.contains("Goal thread"))
        XCTAssertTrue(copy.contains("Start here review history"))
        XCTAssertTrue(copy.contains("No change has been made yet."))
        XCTAssertTrue(copy.contains("Source record stays local"))
        XCTAssertTrue(copy.contains("Review path stays inspectable"))
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertFalse(copy.localizedCaseInsensitiveContains(forbiddenCopyTerm("AI", "confidence")))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains(forbiddenCopyTerm("productivity", "score")))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("notification feed"))
        XCTAssertEqual(hero.receiptItem.kind, .needsReview)
        XCTAssertEqual(hero.receiptItem.changeLabel, "Starting opens the current step; closing keeps review history visible.")
    }

    func testFCP07RealityRailContinuityConnectsStartHereClosureProofAndPressure() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-fcp07",
            stepID: "step-fcp07",
            stepTitle: "Draft PM transition notes",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let rail = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail
        let copy = f02VisibleRailCopy(rail)

        XCTAssertEqual(rail.continuity.title, "Reality Meridian continuity")
        XCTAssertTrue(copy.contains("Start here emerges from the active Meridian node"))
        XCTAssertTrue(copy.contains("Now, Next, Later, closure, proof, and pressure stay connected."))
        XCTAssertTrue(copy.contains("Closure knot"))
        XCTAssertTrue(copy.contains("Close the loop"))
        XCTAssertTrue(copy.contains("Proof marker"))
        XCTAssertTrue(copy.contains("Proof saved"))
        XCTAssertTrue(copy.contains("Pressure"))
        XCTAssertTrue(copy.contains("Changes stay reviewable."))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("agenda"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("dashboard"))
    }

    func testAFI06RealityMeridianConnectsStartHereWhyThisClosureAndProof() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-afi06",
            stepID: "step-afi06",
            stepTitle: "Draft PM transition notes",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let rail = try await service.loadTodayExperience(userDisplayName: "", now: now).execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let copy = f02VisibleRailCopy(rail)

        XCTAssertEqual(rail.continuity.title, "Reality Meridian continuity")
        XCTAssertTrue(copy.contains("Start here emerges from the active Meridian node"))
        XCTAssertTrue(copy.contains("Now"))
        XCTAssertTrue(copy.contains("Next"))
        XCTAssertTrue(copy.contains("Later"))
        XCTAssertEqual(hero.contextEdge.title, "Context edge")
        XCTAssertEqual(hero.timeFitProof.title, "Time fit")
        XCTAssertEqual(hero.goalThread.title, "Goal thread")
        XCTAssertEqual(hero.receiptItem.title, "Start here review history")
        XCTAssertEqual(hero.receiptItem.summary, "No change has been made yet.")
        XCTAssertEqual(hero.receiptLabel, "Start here review history")
        XCTAssertEqual(hero.proofLabel, "No change has been made yet.")
        XCTAssertEqual(hero.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(hero.replayTraceLabel, "Review path stays inspectable")
        XCTAssertTrue(try XCTUnwrap(hero.receiptItem.changeLabel).contains("closing keeps review history visible"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("overdue"))
    }

}
