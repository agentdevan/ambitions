import XCTest
@testable import Ambitions

final class TodayCommandHandlerTests: XCTestCase {
    func testP1HMissedStepRecoveryPersistsThroughReloadWithoutShameCopy() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await makeRepositories(store: store)
        let lifecycleService = SimpleStepLifecycleService(repositories: repositories)
        let created = try await lifecycleService.createSimpleStep(
            title: "Send the insurance form",
            now: fixedNow
        )
        let recoveryTime = fixedNow.addingTimeInterval(3_600)

        let recovery = try await lifecycleService.markMissedStepForRecovery(
            goalID: created.goalID,
            stepID: created.stepID,
            now: recoveryTime
        )

        XCTAssertTrue(recovery.asksWhatChanged)
        XCTAssertEqual(recovery.primaryActionTitle, "Move it")
        XCTAssertEqual(recovery.secondaryActionTitles, ["Still counts", "Blocked", "Waiting", "Not needed"])
        XCTAssertEqual(recovery.updatedStep.state, .planned)
        XCTAssertEqual(recovery.feedbackEventCount, 2)
        assertNoShameOrPressureCopy(in: [
            recovery.promptTitle,
            recovery.promptBody,
            recovery.primaryActionTitle
        ] + recovery.secondaryActionTitles)

        let reloadedRepositories = try await makeRepositories(store: store)
        let reloadedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let reloadedStep = try XCTUnwrap(reloadedSteps.first(where: { $0.id == created.stepID }))
        let reloadedFeedback = try await reloadedRepositories.feedback.listEvents(goalID: created.goalID)
        let notes = reloadedFeedback.compactMap(feedbackNote)
        let reloadedToday = try await RepositoryBackedTodayService(repositories: reloadedRepositories)
            .loadTodayExperience(userDisplayName: "Local User", now: recoveryTime)

        XCTAssertEqual(reloadedStep.state, .planned)
        XCTAssertEqual(reloadedStep.summary, recovery.updatedStep.summary)
        XCTAssertNotNil(reloadedStep.timing.suggestedNextAt)
        XCTAssertTrue(reloadedFeedback.contains {
            if case .skipped(let base, _) = $0, base.stepID == created.stepID { return true }
            return false
        })
        XCTAssertTrue(reloadedFeedback.contains {
            if case .delayed(let base, _, _) = $0, base.stepID == created.stepID { return true }
            return false
        })
        assertNoShameOrPressureCopy(in: notes)
        XCTAssertEqual(reloadedToday.hero.primaryAction.action.target.goalID, created.goalID)
        XCTAssertEqual(reloadedToday.hero.primaryAction.action.target.stepID, created.stepID)
        XCTAssertTrue(reloadedToday.hero.primaryAction.title == "Start now" || reloadedToday.hero.primaryAction.title == "Still counts")
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }

    func testQuickLogLegacyServiceEntryRequiresRuntimeAndWritesNothing() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Record a quick-log today capture"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let goal = try await repositories.goals.goal(id: goalID)
        let stepID = try XCTUnwrap(goal?.plan?.sections.first?.steps.first?.id)
        let baselineCaptures = try await repositories.captures.listCaptures()
        let baselineEvidence = try await repositories.evidence.listEvidence(goalID: goalID)

        let action = TodayInlineAction(
            kind: .quickLog,
            title: "Quick log",
            systemImage: "plus.bubble",
            state: .success,
            target: TodayActionTarget(goalID: goalID, stepID: stepID)
        )
        let response = try await todayService.performAction(action, now: fixedNow)

        XCTAssertEqual(response.message?.title, "Action needs the runtime")
        let captures = try await repositories.captures.listCaptures()
        let updatedEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        XCTAssertEqual(captures, baselineCaptures)
        XCTAssertEqual(updatedEvidence, baselineEvidence)
        let commandRecords = try await commandRecordRepository.fetchRecent(limit: 10)
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(commandRecords.isEmpty)
        XCTAssertTrue(ledgerEntries.isEmpty)
    }

    func testNavigationOnlyActionMutatesNothingAndDoesNotEmitCommandEvidence() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let todayService = RepositoryBackedTodayService(repositories: repositories)
        let baselineFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let baselineEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let baselineCaptures = try await repositories.captures.listCaptures()

        _ = try await goalsService.createGoal(CreateGoalRequest(title: "Keep navigation non-mutating"), now: fixedNow)
        let action = TodayInlineAction(
            kind: .openTime,
            title: "Open Time",
            systemImage: "calendar",
            state: .default,
            target: TodayActionTarget()
        )

        let response = try await todayService.performAction(action, now: fixedNow)

        let updatedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let updatedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let updatedCaptures = try await repositories.captures.listCaptures()
        let commandRecords = try await commandRecordRepository.fetchRecent(limit: 10)
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertNil(response.message)
        XCTAssertEqual(updatedFeedback.count, baselineFeedback.count)
        XCTAssertEqual(updatedEvidence.count, baselineEvidence.count)
        XCTAssertEqual(updatedCaptures.count, baselineCaptures.count)
        XCTAssertEqual(commandRecords.count, 0)
        XCTAssertEqual(ledgerEntries.count, 0)
    }

    func testInvalidRuntimeCommandDoesNotBypassValidationIntoFeedbackHandler() async throws {
        let repositories = try await makeRepositories()
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let commandJournal = try XCTUnwrap(repositories.commandJournal as? InMemoryCommandJournal)
        let handler = TodayCommandActionHandler(
            repositories: repositories,
            feedbackAction: { _, _ in
                XCTFail("Invalid runtime command bypassed validation and reached feedback mutation handler.")
                return TodayActionResponse(message: nil)
            }
        )
        let action = TodayInlineAction(
            kind: .complete,
            title: "Still counts",
            systemImage: "checkmark.circle",
            state: .warning,
            target: TodayActionTarget()
        )
        let command = AmbitionsCommand(
            id: "command.invalid-runtime-pipeline",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(),
            createdAt: DomainTimestamp.string(from: fixedNow),
            sourceSurface: "today"
        )

        let response = try await handler.performAction(action, command: command, now: fixedNow)

        XCTAssertEqual(response.message?.title, "Action not available")
        let fetchedRecord = try await commandRecordRepository.fetchRecord(commandID: command.id)
        let record = try XCTUnwrap(fetchedRecord)
        XCTAssertEqual(record.result.status, .blocked)
        XCTAssertEqual(record.result.metadata["stageActionPipelineCommandValidation"], StageActionPipelineRequirementState.blocked.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineRuntimeMutation"], StageActionPipelineRequirementState.blocked.rawValue)
        XCTAssertEqual(record.result.metadata["commandEnvelopePhase"], CommandEnvelopePhase.rejectedBeforeMutation.rawValue)
        XCTAssertEqual(record.result.metadata["commandJournalSequence"], "1")
        XCTAssertEqual(record.result.metadata["commandReceiptID"], "command.receipt.command.invalid-runtime-pipeline")
        XCTAssertTrue(record.result.eventLedgerEntryIDs.isEmpty)
        let envelopes = try await commandJournal.fetchEnvelopes(matching: .commandID(command.id), limit: nil)
        XCTAssertEqual(envelopes.count, 1)
        XCTAssertEqual(envelopes.first?.phase, .rejectedBeforeMutation)
    }

    func testAskWhyThisMattersIsRepeatableReadOnlyInspection() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let commandJournal = try XCTUnwrap(repositories.commandJournal as? InMemoryCommandJournal)
        let runtimeEvents = try XCTUnwrap(repositories.runtimeEvents as? InMemoryRuntimeEventStore)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Learn SwiftUI layout"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let goal = try await repositories.goals.goal(id: goalID)
        let stepID = try XCTUnwrap(goal?.plan?.sections.first?.steps.first?.id)
        let action = TodayInlineAction(
            kind: .askWhyThisMatters,
            title: "Why this matters",
            systemImage: "questionmark.circle",
            state: .default,
            target: TodayActionTarget(goalID: goalID, stepID: stepID)
        )
        let beforeFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let beforeEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let beforeCaptures = try await repositories.captures.listCaptures()
        let beforeGoal = try await repositories.goals.goal(id: goalID)

        let first = try await todayService.performAction(action, now: fixedNow)
        let second = try await todayService.performAction(action, now: fixedNow)

        XCTAssertEqual(first.message?.title, "Why this matters")
        XCTAssertEqual(second.message?.title, first.message?.title)
        XCTAssertEqual(second.message?.body, first.message?.body)
        XCTAssertFalse(first.message?.body.isEmpty ?? true)
        let afterFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let afterEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let afterCaptures = try await repositories.captures.listCaptures()
        let commandRecords = try await commandRecordRepository.fetchRecent(limit: 10)
        let commandEnvelopes = try await commandJournal.fetchEnvelopes(matching: .all, limit: nil)
        let ledgerEntries = try await ledger.fetchRecent(limit: 20)
        let runtimeEventEntries = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let afterGoal = try await repositories.goals.goal(id: goalID)
        XCTAssertEqual(afterFeedback, beforeFeedback)
        XCTAssertEqual(afterEvidence, beforeEvidence)
        XCTAssertEqual(afterCaptures, beforeCaptures)
        XCTAssertEqual(afterGoal, beforeGoal)
        XCTAssertTrue(commandRecords.isEmpty)
        XCTAssertTrue(commandEnvelopes.isEmpty)
        XCTAssertTrue(ledgerEntries.isEmpty)
        XCTAssertTrue(runtimeEventEntries.isEmpty)
    }
}

private extension TodayCommandHandlerTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_777_113_600)
    }

    func makeRepositories() async throws -> AppRepositories {
        try await makeRepositories(store: AmbitionsPersistenceStore(inMemory: true))
    }

    func makeRepositories(store: AmbitionsPersistenceStore) async throws -> AppRepositories {
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: InMemoryEventLedgerRepository(),
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            runtimeEvents: InMemoryRuntimeEventStore(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    func feedbackNote(_ event: GoalFeedbackEvent) -> String? {
        event.base.note
    }

    func assertNoShameOrPressureCopy(in values: [String], file: StaticString = #filePath, line: UInt = #line) {
        let copy = values.joined(separator: " ")
        for forbidden in ["shame", "overdue", "failed", "lazy", "streak", "score", "productivity"] {
            XCTAssertFalse(
                copy.localizedCaseInsensitiveContains(forbidden),
                "Unexpected recovery pressure term: \(forbidden)",
                file: file,
                line: line
            )
        }
    }
}
