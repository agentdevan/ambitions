@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

final class TodayViewModelTests: XCTestCase {
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
        XCTAssertEqual(experience.execution.todayPlanLayer.title, "Today Plan")
        XCTAssertFalse(experience.execution.todayPlanLayer.items.isEmpty)
        XCTAssertEqual(experience.execution.todayPlanLayer.calendarSourceLabel, "Based on your plan")
        XCTAssertFalse(experience.execution.todayPlanLayer.openWindowLabel.isEmpty)
        XCTAssertNotNil(experience.execution.hero.explanation)
        XCTAssertNotNil(experience.execution.saveTheDayAction)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .startStepSession && $0.commandKind == .startStepSession })
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .askWhyThisMatters && $0.commandKind == .askWhy })
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
        XCTAssertTrue(rail.contextLabels.contains { $0.label == "Based on your plan" })
        XCTAssertTrue(rail.contextLabels.contains { $0.label == "Stored on this device" })
        XCTAssertTrue(rail.closureSlot.reservedForActionClosureSheet)
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertTrue(rail.proofSlot.noSilentChanges)
        XCTAssertEqual(rail.continuity.markers.map(\.title), ["Start Here", "Now", "Next", "Later", "Closure knot", "Proof marker", "Pressure"])
        XCTAssertEqual(heroStep.contextEdge.title, "Context edge")
        XCTAssertEqual(heroStep.timeFitProof.title, "Time fit")
        XCTAssertEqual(heroStep.goalThread.title, "Goal thread")
        XCTAssertEqual(heroStep.receiptItem.title, "Start Here receipt seam")
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
            "AI confidence",
            "model reasoning",
            "productivity score",
            "best next move",
            "next best move",
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
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("Reality Rail continuity"))
        XCTAssertTrue(f02VisibleRailCopy(rail).contains("No silent changes"))
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
        XCTAssertTrue(copy.contains("Start Here receipt seam"))
        XCTAssertTrue(copy.contains("No change has been made yet."))
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("productivity score"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("notification feed"))
        XCTAssertEqual(hero.receiptItem.kind, .needsReview)
        XCTAssertEqual(hero.receiptItem.changeLabel, "Starting opens the current step; closing writes the receipt later.")
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

        XCTAssertEqual(rail.continuity.title, "Reality Rail continuity")
        XCTAssertTrue(copy.contains("Start Here, Now, Next, Later, closure, proof, and pressure stay connected."))
        XCTAssertTrue(copy.contains("Closure knot"))
        XCTAssertTrue(copy.contains("Close the loop"))
        XCTAssertTrue(copy.contains("Proof marker"))
        XCTAssertTrue(copy.contains("Proof saved"))
        XCTAssertTrue(copy.contains("Pressure"))
        XCTAssertTrue(copy.contains("No silent changes."))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("agenda"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("task list"))
        XCTAssertFalse(copy.localizedCaseInsensitiveContains("dashboard"))
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

    func testSI05HeroStepPanelSignalRowCoversActionStatesAndPrivacy() throws {
        let rails = [
            PreviewTodayScenarios.stable.execution.dayRail,
            PreviewTodayScenarios.recovery.execution.dayRail,
            PreviewTodayScenarios.privateRail.execution.dayRail,
            PreviewTodayScenarios.heroLoading.execution.dayRail,
            PreviewTodayScenarios.heroDisabled.execution.dayRail
        ]
        let heroes = try rails.map { try XCTUnwrap($0.heroStep) }

        for (hero, rail) in zip(heroes, rails) {
            _ = HeroStepPanelSignalRow(
                action: hero.primaryAction,
                reason: hero.whySummary,
                sourceSummary: rail.privacyProjection.sourceSummary(from: hero.sourceLabels),
                isPrivateProjection: rail.privacyProjection.isSensitiveProjection
            )
        }

        XCTAssertEqual(
            Set(heroes.map(\.primaryAction.state)),
            [.success, .selected, .loading, .disabled]
        )
        XCTAssertTrue(rails.contains { $0.privacyProjection.isSensitiveProjection })
        XCTAssertTrue(PreviewTodayScenarios.heroDisabled.execution.dayRail.heroStep?.fitLabel == "Needs review")
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
            "best next move",
            "next best move",
            "AI confidence",
            "productivity score",
            "profile tab",
            "insights tab",
            "habits tab",
            "overdue",
            "failed",
            "missed"
        ]

        for rail in rails {
            let copy = f02VisibleRailCopy(rail)
            for term in forbidden {
                XCTAssertFalse(
                    copy.localizedCaseInsensitiveContains(term),
                    "Reality Rail visible copy should not contain forbidden term: \(term)"
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
        XCTAssertTrue(renderedReservationCopy.contains("No silent changes."))
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
        XCTAssertEqual(heroDetail.stepSessionLabel, "Step Session opens for this one step.")
        XCTAssertEqual(heroDetail.detailTarget.kind, .stepDetail)
        XCTAssertEqual(rowDetail.timingBucket, "Now")
        XCTAssertEqual(rowDetail.title, row.title)
        XCTAssertTrue(rowDetail.goalLinkLabel.contains(row.title))
        XCTAssertEqual(rowDetail.detailTarget.kind, .stepDetail)
    }

    func testF03StepDetailShowsCompliantDeterministicExplanationLabels() throws {
        let detail = try XCTUnwrap(PreviewTodayScenarios.stepDetailStartHere)
        let copy = detail.visibleCopy

        XCTAssertTrue(copy.contains("Why this?"))
        XCTAssertTrue(copy.contains("Recommended because"))
        XCTAssertTrue(copy.contains("Based on your plan"))
        XCTAssertTrue(copy.contains("Duration source: Suggested duration"))
        XCTAssertTrue(copy.contains("Start now"))
        XCTAssertTrue(copy.contains("Close the loop"))
        XCTAssertTrue(copy.contains("Adjust plan"))
        XCTAssertTrue(copy.contains("Review later"))
        XCTAssertTrue(copy.contains("Proof and receipts stay attached to this step"))
        XCTAssertTrue(copy.contains("No silent changes"))
        XCTAssertFalse(detail.whyBullets.isEmpty)
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
            "best next move",
            "next best move",
            "AI confidence",
            "productivity score",
            "profile tab",
            "insights tab",
            "habits tab",
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

    func testF04StartNowUsesStepSessionActionAndClosureProofStayUnimplemented() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let detail = try XCTUnwrap(PreviewTodayScenarios.stepDetailStartHere)

        XCTAssertEqual(detail.primaryAction.title, "Start now")
        XCTAssertEqual(detail.primaryAction.kind, .startStepSession)
        XCTAssertEqual(detail.closureAction.kind, .closeActionClosure)
        XCTAssertEqual(detail.closureAction.title, "Close the loop")
        XCTAssertEqual(detail.secondaryActions.map(\.title), ["Adjust plan", "Review later"])
        XCTAssertTrue(rail.closureSlot.reservedForActionClosureSheet)
        XCTAssertFalse(rail.proofSlot.reservedForReceiptPeek)
        XCTAssertTrue(f02RenderedReservationCopy(rail).contains("Closure knot"))
    }

    func testF05ActionClosureSheetSupportsStillCountsWithoutProofLedger() throws {
        let target = TodayActionTarget(goalID: "goal-f05", stepID: "step-f05")
        let sheet = TodayActionClosureSheetState.step(
            title: "Write the launch notes",
            context: "Start here",
            target: target
        )

        XCTAssertEqual(sheet.prompt, "What happened with this step?")
        XCTAssertEqual(sheet.primaryOutcomes.map(\.closureState), [.completed, .stillCounts, .moved, .notNeeded])
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .blocked })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .waiting })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .needsRecovery })
        XCTAssertTrue(sheet.outcomes.contains { $0.closureState == .needsReview })
        XCTAssertTrue(sheet.outcomes.contains { $0.title == "Review later" })
        XCTAssertEqual(sheet.outcomes.first { $0.closureState == .stillCounts }?.receiptPreview, "Still Counts · saved as proof")
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
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
    }

    func testFCP13AActionClosureDiamondExplainsOutcomeConsequenceProofAndRecoveryWithoutSilentMutation() throws {
        let target = TodayActionTarget(goalID: "goal-fcp13a", stepID: "step-fcp13a")
        let sheet = TodayActionClosureSheetState.step(
            title: "Send the launch note",
            context: "Start Here",
            target: target
        )

        XCTAssertEqual(sheet.diamond.title, "Closure diamond")
        XCTAssertEqual(sheet.diamond.centerLabel, "Close the loop")
        XCTAssertEqual(sheet.diamond.facets.map(\.title), ["Outcome", "Consequence", "Proof", "Recovery"])
        XCTAssertTrue(sheet.diamond.visibleCopy.contains("Evidence only when it is true."))
        XCTAssertTrue(sheet.diamond.visibleCopy.contains("No silent changes"))
        XCTAssertTrue(sheet.diamond.accessibilityValue.contains("Recovery: A smaller path if reality changed."))
        XCTAssertTrue(sheet.visibleCopy.contains("Choose the honest outcome"))
        XCTAssertFalse(sheet.visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
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
        XCTAssertTrue(session.receiptGenerationLabel.contains("receipt preview"))
        XCTAssertTrue(session.exitBoundaryLabel.contains("without changing proof or plan"))
    }

    func testF06ActionClosureProjectsProofReceiptPeekWithoutPersistence() {
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
        XCTAssertTrue(proofPeek.subtitle.contains("Still Counts"))
        XCTAssertEqual(proofPeek.proofLabel, "Added to proof")
        XCTAssertEqual(proofPeek.privacyLabel, "Stored on this device")
        XCTAssertEqual(proofPeek.noSilentChangesLabel, "No silent changes")
        XCTAssertEqual(reviewPeek.title, "Needs confirmation")
        XCTAssertEqual(reviewPeek.proofLabel, "Needs confirmation")
        XCTAssertEqual(waitingPeek.proofLabel, "Needs confirmation")
        XCTAssertTrue(waitingPeek.subtitle.contains("Waiting"))
    }

    func testF03StepDetailSupportsMissingDurationFallback() {
        let detail = PreviewTodayScenarios.missingDurationStepDetail

        XCTAssertEqual(detail.durationLabel, "Duration not set")
        XCTAssertEqual(detail.durationSourceLabel, "Duration source: Unset")
        XCTAssertEqual(detail.timingBucket, "Later")
        XCTAssertTrue(detail.sourceLabel.contains("Based on your goal path"))
    }

    func testTodayD11ScreenContractSnapshotSatisfiesImplementationGate() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-contract",
            stepID: "step-contract",
            stepTitle: "Protect the launch review",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let contract = ScreenContractRegistry.contract(for: .today)
        let issues = ScreenContractValidator.validate(
            snapshot: experience.execution.screenContractSnapshot(),
            against: contract
        )

        XCTAssertTrue(issues.isEmpty, issues.map(\.message).joined(separator: "\n"))
    }

    func testTodayD11OneStepGoalsSurfaceStandaloneCaptureWithoutTasksTab() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        try await repositories.captures.saveCaptures([
            Capture(
                id: "capture-task",
                createdAt: DomainTimestamp.string(from: now),
                updatedAt: DomainTimestamp.string(from: now),
                rawText: "Book dentist",
                sourceType: .todayQuickCapture,
                status: .actionable,
                linkedGoalID: nil,
                kind: .oneTimeCommitment,
                route: .planSeed,
                triageStatus: .assumedRoute,
                commitmentKind: .oneTime
            )
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.oneStepGoalsPanel.title, "One-Step Goals")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.value, "1 open")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.previews.first?.title, "Book dentist")
        XCTAssertEqual(ScreenContractValidator.canonicalTopLevelTabs, ["Today", "Goals", "Capture", "Plan", "You"])
        XCTAssertFalse(ScreenContractValidator.canonicalTopLevelTabs.contains("Tasks"))
    }

    func testToday2RecoveryHeroProtectsHighConsequenceDeadlineAndDefersPassiveWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let crib = makeGoal(
            id: "goal-crib",
            stepID: "step-crib",
            stepTitle: "Build the baby crib",
            dueAt: "2026-04-15T14:00:00Z",
            domain: .home
        )
        let piano = makeGoal(
            id: "goal-piano",
            stepID: "step-piano",
            stepTitle: "Practice piano",
            dueAt: "2026-06-01T12:00:00Z",
            state: .paused,
            mode: .learning,
            domain: .creativity
        )
        let skipped = EventLedgerEntry(
            id: "ledger-skipped",
            kind: .actionSkipped,
            occurredAt: DomainTimestamp.string(from: now),
            source: .today,
            goalID: crib.id,
            title: "Skipped"
        )
        try await repositories.goals.saveGoals([piano, crib])
        try await repositories.eventLedger.append(skipped)

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.hero.kind, .recovery)
        XCTAssertEqual(experience.execution.recoveryFallback.value, "Recovery ready")
        XCTAssertEqual(experience.execution.notToday.value, "Parked")
        XCTAssertEqual(experience.execution.frictionSignal.value, "Needs recovery")
        XCTAssertEqual(experience.execution.saveTheDayAction?.title, "Save the day")
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.title == "Kept in view" })
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.title == "Can wait" })
        XCTAssertFalse(experience.execution.supportingPanels.contains { $0.value.localizedCaseInsensitiveContains("piano") })
    }

    func testToday2OutsideLensAndWaitingStaySummarized() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let personal = makeGoal(
            id: "goal-personal",
            stepID: "step-personal",
            stepTitle: "Clean personal notes",
            dueAt: "2026-04-30T12:00:00Z",
            domain: .personalGrowth
        )
        let work = makeGoal(
            id: "goal-work",
            stepID: "step-work",
            stepTitle: "Send the client sheet",
            dueAt: "2026-04-15T13:00:00Z",
            domain: .career
        )
        let waiting = Capture(
            id: "capture-waiting",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Waiting on Kaylee",
            sourceType: .todayQuickCapture,
            status: .waiting,
            linkedGoalID: nil,
            kind: .waitingItem,
            route: .waiting,
            triageStatus: .waiting,
            commitmentKind: .waiting,
            contextLensHint: .personal
        )
        try await repositories.goals.saveGoals([personal, work])
        try await repositories.captures.saveCaptures([waiting])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.activeLens.title, "Personal")
        XCTAssertTrue(experience.execution.supportingPanels.contains { $0.kind == .contextLens && $0.value == "1 item" })
        XCTAssertTrue(experience.execution.deeperSections.flatMap(\.rows).contains { $0.kind == .waiting && $0.value.contains("waiting") })
    }

    func testToday2CaptureUrgencyAndPlanGuidanceStayRouteOnly() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        try await repositories.captures.saveCaptures([
            Capture(id: "capture-1", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil, kind: .oneTimeCommitment, route: .planSeed, triageStatus: .assumedRoute, commitmentKind: .oneTime, deadlineText: "EOD Tuesday", deadlineKind: .hard, contextLensHint: .work),
            Capture(id: "capture-2", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Book dentist", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil),
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let capturePanel = try XCTUnwrap(experience.execution.supportingPanels.first { $0.kind == .capture })

        XCTAssertNotEqual(capturePanel.value, "No pressure")
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .openPlan && $0.destination == .plan })
    }

    func testToday2EmptyStateDoesNotBecomeBlankDashboard() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.mode, .empty)
        XCTAssertEqual(experience.execution.hero.kind, .empty)
        XCTAssertEqual(experience.execution.protectedMustDo.value, "No must-do yet")
        XCTAssertEqual(experience.execution.notToday.value, "Nothing heavy")
        XCTAssertEqual(experience.execution.actionClosureEntry.value, "Needs a quick check")
        XCTAssertNil(experience.execution.saveTheDayAction)
        XCTAssertNotNil(experience.execution.emptyGuidance)
        XCTAssertFalse(experience.execution.supportingPanels.isEmpty)
        XCTAssertFalse(experience.execution.planRequestsCalendarPermission)
    }

    func testRepositoryBackedServiceCanSurfaceSharedResponsibilityRitualThesis() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T09:00:00Z"))
        var goal = makeGoal(id: "goal-home", stepID: "step-home", stepTitle: "Home shared step", dueAt: "2026-04-21T16:00:00Z")
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: .support,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: goal.plan,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .home)],
                roles: [LifeRole(kind: .supporting, title: "Partner support")],
                path: nil,
                stages: [],
                prerequisites: [],
                milestones: [],
                sharedLife: SharedLifeContext(
                    participants: [SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")],
                    responsibilities: [SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner")]
                )
            )
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertTrue(experience.hero.truth.supportingText.localizedCaseInsensitiveContains("shared"))
    }

    func testSharedNextStepSelectorDeprioritizesBlockedDependencyWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let blocked = makeGoal(
            id: "goal-blocked",
            stepID: "step-blocked",
            stepTitle: "Blocked dependency step",
            dueAt: "2026-04-16T12:00:00Z",
            stepState: .blocked,
            dependencyStepIDs: ["step-prereq"]
        )
        let clean = makeGoal(
            id: "goal-clean",
            stepID: "step-clean",
            stepTitle: "Clean recovery-safe step",
            dueAt: "2026-04-17T12:00:00Z"
        )
        try await repositories.goals.saveGoals([blocked, clean])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let expected = PlanningNextStepSelector().bestSelection(goals: [blocked, clean], now: now)

        XCTAssertEqual(expected?.goal.id, "goal-clean")
        XCTAssertEqual(experience.hero.truth.nowTitle, expected?.step.title)
        XCTAssertEqual(experience.support.fixedCommitments.items.first?.id, expected?.step.id)
        XCTAssertNil(experience.support.recoveryBloom)
        XCTAssertEqual(experience.support.timeAperture.bestUseTitle, "Next 45 minutes")
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
    }

    func testStepSessionEntryContextSurfacesBoundedStepSession() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-step-session", stepID: "step-session-step", stepTitle: "Step Session-backed step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(
            userDisplayName: "",
            now: now,
            entryContext: .stepSession
        )

        XCTAssertEqual(experience.hero.truth.posture, .stable)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .complete)
        XCTAssertEqual(experience.support.stepSession?.title, "Step Session-backed step")
        XCTAssertTrue(experience.support.stepSession?.detail.contains("Step Session") == true)
        XCTAssertEqual(experience.support.stepSession?.primaryAction.kind, .complete)
        XCTAssertEqual(experience.support.stepSession?.contextReminderLabel, "One step is in focus. The rest of Today stays available behind it.")
        XCTAssertEqual(experience.support.stepSession?.goalConnectionLabel, "Goal context stays attached while this step is in session.")
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains("AI confidence") == true)
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains("overdue") == true)
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains("streak") == true)
    }

    @MainActor
    func testHandlePublishesTransientMessageAfterActionResponse() async {
        let expectedMessage = TodayInlineMessage(
            title: "Captured",
            body: "Progress was saved.",
            state: .success
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))
        let service = RecordingTodayService(experience: PreviewTodayScenarios.empty, actionResponse: TodayActionResponse(message: expectedMessage))

        await viewModel.handle(
            TodayInlineAction(
                kind: .quickLog,
                title: "Quick log",
                systemImage: "plus.bubble",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            using: service,
            userDisplayName: ""
        )

        let transientMessage = viewModel.transientMessage
        XCTAssertEqual(transientMessage?.title, expectedMessage.title)
        XCTAssertEqual(transientMessage?.body, expectedMessage.body)
        let actionCount = await service.performedActionCount()
        XCTAssertEqual(actionCount, 1)
    }

    @MainActor
    func testRefreshFailureMovesStateToFailed() async {
        let viewModel = TodayViewModel()
        await viewModel.refresh(using: FailingTodayService(), userDisplayName: "")

        let state = viewModel.state
        guard case let .failed(message) = state else {
            return XCTFail("Expected Today refresh to end in a failed state.")
        }

        XCTAssertTrue(message.contains("Unable to load Today"))
    }
}

private extension TodayViewModelTests {
    func f02VisibleRailCopy(_ rail: AmbitionsDayRailViewState) -> String {
        var copy = [
            rail.dateTitle,
            rail.contextSummary,
            rail.contextLabels.map(\.label).joined(separator: " "),
            rail.heroStep == nil ? "Start here Nothing needs you right now." : "Start here",
            rail.heroStep?.title,
            rail.heroStep?.subtitle,
            rail.heroStep?.duration.label,
            rail.heroStep?.fitLabel,
            rail.heroStep?.sourceQualityLabel,
            rail.heroStep?.becauseLine,
            rail.heroStep?.contextEdge.title,
            rail.heroStep?.contextEdge.summary,
            rail.heroStep?.timeFitProof.title,
            rail.heroStep?.timeFitProof.detail,
            rail.heroStep?.goalThread.title,
            rail.heroStep?.goalThread.summary,
            rail.heroStep?.receiptItem.accessibilitySummary,
            rail.heroStep?.primaryAction.title,
            rail.heroStep?.secondaryAction?.title,
            "Now",
            "Next",
            "Later",
            rail.rows.map { "\($0.slot.rawValue) \($0.title) \($0.subtitle) \($0.duration.label)" }.joined(separator: " "),
            rail.continuity.title,
            rail.continuity.summary,
            rail.continuity.markers.map { "\($0.title) \($0.summary) \($0.detail)" }.joined(separator: " "),
            rail.continuity.pressureLabel,
            rail.continuity.noSilentChangesLabel,
            f02RenderedReservationCopy(rail)
        ].compactMap { $0 }

        if rail.privacyProjection.isSensitiveProjection {
            copy.append(rail.privacyProjection.sourceLabel)
        }

        return copy.joined(separator: " ")
    }

    func f02RenderedReservationCopy(_ rail: AmbitionsDayRailViewState) -> String {
        (rail.continuity.markers.map { "\($0.title) \($0.summary) \($0.detail)" } + [
            rail.continuity.noSilentChangesLabel
        ]).joined(separator: " ")
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func makeGoal(
        id: String,
        stepID: String,
        stepTitle: String,
        dueAt: String,
        state: GoalLifecycleState = .active,
        mode: GoalMode = .project,
        domain: LifeDomainKey? = nil,
        stepState: StepLifecycleState = .planned,
        dependencyStepIDs: [String] = []
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: stepTitle, summary: nil, type: .actionUnit, state: stepState, owner: actor, timing: timing, dependencyStepIDs: dependencyStepIDs, isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: "2026-04-15T12:00:00Z",
            updatedAt: "2026-04-15T12:00:00Z",
            state: state,
            title: id,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: domain.map { LifeGraphContext(domains: [LifeDomainAssignment(domain: $0)]) }
        )
    }
}

private actor RecordingTodayService: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse
    private(set) var performedActions: [TodayInlineAction] = []

    init(experience: TodayExperience, actionResponse: TodayActionResponse) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return actionResponse
    }

    func performedActionCount() -> Int {
        performedActions.count
    }
}

private struct FailingTodayService: TodayServicing {
    struct Failure: LocalizedError {
        var errorDescription: String? {
            "Today failed on purpose."
        }
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        throw Failure()
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        throw Failure()
    }
}
