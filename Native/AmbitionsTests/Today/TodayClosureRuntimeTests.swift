@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

final class TodayClosureRuntimeTests: TodayViewModelTestCase {
    func testLegacyRepositoryClosureEntryPointDoesNotMutateWithoutRuntimeClient() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let target = TodayActionTarget(goalID: "goal-afri022", stepID: "step-afri022")
        let closure = TodayActionClosureSheetState.step(
            title: "Write the launch notes",
            context: "Start here",
            target: target
        )
        let stillCounts = try XCTUnwrap(closure.outcomes.first { $0.closureState == .stillCounts })
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-02T09:30:00Z"))

        let response = try await service.recordActionClosure(closure, outcome: stillCounts, now: now)

        XCTAssertEqual(response.message?.title, "Closure receipt not saved")
        XCTAssertNil(response.stageMutation)
        let records = try await XCTUnwrap(repositories.actionReceiptHistory).listRecords()
        XCTAssertTrue(records.isEmpty)
    }

    @MainActor
    func testActionClosureRefreshIgnoresSyntheticStageMutationFromCommandResponse() async throws {
        let baseExperience = PreviewTodayScenarios.stable
        let heroStep = try XCTUnwrap(baseExperience.execution.dayRail.heroStep)
        let target = heroStep.primaryAction.target
        let closure = TodayActionClosureSheetState.step(
            title: heroStep.title,
            context: baseExperience.execution.dayRail.contextSummary,
            target: target
        )
        let outcome = try XCTUnwrap(closure.outcomes.first { $0.closureState == .stillCounts })
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-05-02T09:30:00Z"))
        let mutation = TodayClosureStageMutation(
            record: TodayClosureRecord(
                stepID: target.stepID,
                goalID: target.goalID,
                outcome: outcome.closureState,
                occurredAt: now
            ),
            stepTitle: closure.objectTitle,
            receiptSaved: true
        )
        let service = TodayViewModelServiceRecorder(
            experience: baseExperience,
            actionResponse: TodayActionResponse(message: nil)
        )
        let receiptCommands = TodayViewModelReceiptCommandRecorder(
            actionResponse: TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Proof saved",
                    body: "The closure receipt is saved locally.",
                    state: .success
                ),
                stageMutation: mutation
            )
        )
        let viewModel = TodayViewModel(state: .loaded(baseExperience))

        await viewModel.confirmActionClosure(
            closure,
            outcome: outcome,
            using: receiptCommands,
            refreshService: service,
            userDisplayName: "",
            now: now,
            calendar: Calendar(identifier: .gregorian)
        )

        guard case let .loaded(updatedExperience) = viewModel.state else {
            return XCTFail("Expected loaded Today experience after closure confirmation.")
        }

        XCTAssertEqual(updatedExperience.execution.dayRail.closureSlot.title, baseExperience.execution.dayRail.closureSlot.title)
        XCTAssertEqual(updatedExperience.execution.dayRail.proofSlot.title, baseExperience.execution.dayRail.proofSlot.title)
        XCTAssertTrue(mutation.stageMutation.isCanonComplete)
        XCTAssertEqual(mutation.stageMutation.targetSurface, .today)
        XCTAssertTrue(mutation.userVisibleMutation.detail.contains("Progress is saved"))
        XCTAssertEqual(updatedExperience.execution.dayRail.continuity.markers, baseExperience.execution.dayRail.continuity.markers)
        XCTAssertEqual(viewModel.transientMessage?.title, "Proof saved")
    }

    func testF03StepDetailSupportsMissingDurationFallback() {
        let detail = PreviewTodayScenarios.missingDurationStepDetail

        XCTAssertEqual(detail.durationLabel, "Duration not set")
        XCTAssertEqual(detail.durationSourceLabel, "Duration source: Unset")
        XCTAssertEqual(detail.timingBucket, "Later")
        XCTAssertTrue(detail.sourceLabel.contains("Based on your goal path"))
    }

    func testTodayStepReplacementSheetKeepsOriginalRecommendationInspectableAndCappedToFiveAlternatives() {
        let sheet = PreviewTodayScenarios.stepReplacementSheet

        XCTAssertEqual(sheet.title, "Show another")
        XCTAssertEqual(sheet.alternatives.count, 5)
        XCTAssertEqual(sheet.alternatives.map(\.label), [
            "Keep goal on track",
            "Make original Step lighter",
            "Continue this Step",
            "Use this time elsewhere",
            "Ride momentum"
        ])
        XCTAssertTrue(sheet.visibleCopy.contains("Original recommendation"))
        XCTAssertTrue(sheet.visibleCopy.contains("Changes stay reviewable"))
        XCTAssertTrue(sheet.visibleCopy.contains("Show impact"))
        XCTAssertTrue(sheet.visibleCopy.contains("Move original Step"))
        XCTAssertTrue(sheet.originalRecommendation.visibleCopy.contains(sheet.originalHero.title))
        XCTAssertEqual(sheet.receiptPreviewTitle, "Move original Step")
        XCTAssertEqual(sheet.impactSectionTitle, "Show impact")

        let shorter = try! XCTUnwrap(sheet.alternatives.first(where: { $0.label == "Continue this Step" }))
        XCTAssertEqual(shorter.deadlineImpactLabel, "Keeps deadline")
        XCTAssertFalse(shorter.timelineImpactLabel.isEmpty)
        XCTAssertTrue(sheet.approvalReceiptPreview(for: shorter).contains("Alternatives shown"))
        XCTAssertEqual(sheet.approvalReceiptMessage(for: shorter).title, "Alternative approved")
    }

    func testTodayStepReplacementApprovalSwapsInSelectedAlternativeWithoutChangingContinuity() {
        let sheet = PreviewTodayScenarios.stepReplacementSheet
        let sourceRail = PreviewTodayScenarios.stable.execution.dayRail
        let shorter = try! XCTUnwrap(sheet.alternatives.first(where: { $0.label == "Continue this Step" }))

        let approvedRail = sheet.approvedRail(from: sourceRail, selectedOption: shorter)

        XCTAssertEqual(approvedRail.contextSummary, sourceRail.contextSummary)
        XCTAssertEqual(approvedRail.continuity.title, sourceRail.continuity.title)
        XCTAssertEqual(approvedRail.heroStep?.title, shorter.heroStep.title)
        XCTAssertEqual(approvedRail.heroStep?.primaryAction.title, sourceRail.heroStep?.primaryAction.title)
        XCTAssertEqual(approvedRail.primaryAction?.title, sourceRail.primaryAction?.title)
        XCTAssertTrue(approvedRail.continuity.markers.contains(where: { $0.title == "Proof marker" }))
    }

    func testPK17ReadModelProjectorKeepsRealityMeridianContinuity() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goal = makeGoal(
            id: "goal-pk17-meridian",
            stepID: "step-pk17-meridian",
            stepTitle: "Draft launch summary",
            dueAt: "2026-04-15T20:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let rail = experience.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)

        XCTAssertEqual(rail.continuity.title, "Reality Meridian continuity")
        XCTAssertTrue(rail.continuity.markers.contains(where: { $0.title == "Closure knot" }))
        XCTAssertEqual(rail.continuity.markers.contains(where: { $0.title == "Proof marker" }), true)
        XCTAssertEqual(hero.receiptItem.title, "Start here review history")
        XCTAssertEqual(rail.proofSlot.noSilentChanges, true)
        XCTAssertEqual(rail.continuity.noSilentChangesLabel, "Changes stay reviewable.")
    }

    func testPK17ReadModelProjectorPreservesStartHereProjection() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-16T09:00:00Z"))
        let goal = makeGoal(
            id: "goal-pk17-start-here",
            stepID: "step-pk17-start-here",
            stepTitle: "Draft launch summary",
            dueAt: "2026-04-16T18:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let hero = experience.execution.hero
        let execution = experience.execution

        XCTAssertEqual(execution.hero.kind, .nextAction)
        XCTAssertEqual(execution.commandMappings.contains { $0.actionKind == .startStepSession }, true)
        XCTAssertEqual(execution.commandMappings.contains { $0.actionKind == .openTime }, true)
        XCTAssertFalse(execution.timeRequestsCalendarPermission)
        XCTAssertFalse(execution.dayRail.contextSummary.contains("calendar"))
        XCTAssertEqual(hero.title, "Draft launch summary")
        XCTAssertNotNil(execution.dayRail.heroStep)
    }

    func testPK17ReadModelProjectorReceiptsAndCommandMappings() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-17T11:00:00Z"))
        let goal = makeGoal(
            id: "goal-pk17-commands",
            stepID: "step-pk17-commands",
            stepTitle: "Close first launch loop",
            dueAt: "2026-04-17T18:00:00Z",
            domain: .career
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let mappings = experience.execution.commandMappings

        var hasPlanDestinationMapping = false
        var hasStartStepSessionMapping = false
        var hasAskWhyMapping = false

        for mapping in mappings {
            if mapping.actionKind == .openTime && mapping.destination == .time && mapping.commandPayload.diagnosticCase == "openDestination" {
                hasPlanDestinationMapping = true
            }
            if mapping.actionKind == .startStepSession && mapping.commandPayload.diagnosticCase == "startSession" {
                hasStartStepSessionMapping = true
            }
            if mapping.actionKind == .askWhyThisMatters && mapping.commandPayload.diagnosticCase == "askWhy" {
                hasAskWhyMapping = true
            }
        }

        XCTAssertTrue(hasPlanDestinationMapping)
        XCTAssertTrue(hasStartStepSessionMapping)
        XCTAssertTrue(hasAskWhyMapping)
        XCTAssertEqual(experience.execution.dayRail.proofSlot.noSilentChanges, true)
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
                route: .timeSeed,
                triageStatus: .assumedRoute,
                commitmentKind: .oneTime
            )
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertEqual(experience.execution.oneStepGoalsPanel.title, "One-Step Goals")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.value, "1 open")
        XCTAssertEqual(experience.execution.oneStepGoalsPanel.previews.first?.title, "Book dentist")
        XCTAssertEqual(ScreenContractValidator.canonicalTopLevelTabs, ["Today", "Goals", "Time", "You"])
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
            Capture(id: "capture-1", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil, kind: .oneTimeCommitment, route: .timeSeed, triageStatus: .assumedRoute, commitmentKind: .oneTime, deadlineText: "EOD Tuesday", deadlineKind: .hard, contextLensHint: .work),
            Capture(id: "capture-2", createdAt: DomainTimestamp.string(from: now), updatedAt: DomainTimestamp.string(from: now), rawText: "Book dentist", sourceType: .todayQuickCapture, status: .actionable, linkedGoalID: nil),
        ])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let capturePanel = try XCTUnwrap(experience.execution.supportingPanels.first { $0.kind == .capture })

        XCTAssertNotEqual(capturePanel.value, "No pressure")
        XCTAssertFalse(experience.execution.timeRequestsCalendarPermission)
        XCTAssertTrue(experience.execution.commandMappings.contains { $0.actionKind == .openTime && $0.destination == .time })
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
        XCTAssertFalse(experience.execution.timeRequestsCalendarPermission)
    }

}
