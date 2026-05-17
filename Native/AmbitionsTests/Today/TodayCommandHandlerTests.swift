import XCTest
@testable import Ambitions

final class TodayCommandHandlerTests: XCTestCase {
    func testCompletedCommandWritesFeedbackAndCommandExecutionEvidence() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship the command boundary extraction"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let createdGoal = try await repositories.goals.goal(id: goalID)
        let stepID = try XCTUnwrap(createdGoal?.plan?.sections.first?.steps.first?.id)

        let baselineFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let baselineEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let command = TodayInlineAction(
            kind: .complete,
            title: "Complete",
            systemImage: "checkmark.circle.fill",
            state: .success,
            target: TodayActionTarget(goalID: goalID, stepID: stepID)
        )
        let commandID = "command.today2.\(command.id).complete_action"

        let response = try await todayService.performAction(command, now: fixedNow)

        XCTAssertNotNil(response.message)
        let updatedFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let updatedEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let updatedGoal = try await repositories.goals.goal(id: goalID)

        let completedFeedback = updatedFeedback.filter { event in
            if case .completed = event { return true } else { return false }
        }
        let completionEvents = updatedFeedback.filter {
            if case .completed(let base, _, _, _) = $0, base.stepID == stepID { return true }
            return false
        }
        let completionEvidence = updatedEvidence.filter {
            $0.evidenceKind == .stepCompleted && $0.goalID == goalID && $0.stepID == stepID
        }
        XCTAssertEqual(completedFeedback.count, baselineFeedback.count + 1)
        XCTAssertEqual(completionEvents.count, 1)
        XCTAssertEqual(completionEvidence.count, baselineEvidence.count + 1)
        let updatedStep = try XCTUnwrap(updatedGoal?.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }))
        XCTAssertEqual(updatedStep.state, .completed)
        XCTAssertEqual(response.message?.title, "Completion recorded")

        let commandRecord = try await commandRecordRepository.fetchRecord(commandID: commandID)
        let record = try XCTUnwrap(commandRecord)
        XCTAssertEqual(record.command.id, commandID)
        XCTAssertEqual(record.result.status, .succeeded)
        XCTAssertEqual(record.result.summary, "Today command completed.")
        XCTAssertEqual(record.result.target?.goalID, goalID)
        XCTAssertFalse(record.result.eventLedgerEntryIDs.isEmpty)
        let ledgerEntries = try await ledger.fetchRecent(limit: 30)
        XCTAssertTrue(
            Set(record.result.eventLedgerEntryIDs).isSubset(of: Set(ledgerEntries.map(\.id)))
        )
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .actionCompleted }))
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .actionCompleted && $0.goalID == goalID }))
    }

    func testQuickLogCommandWritesCaptureEvidenceAndCommandRecord() async throws {
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
        let commandID = "command.today2.\(action.id).\(AmbitionsCommandKind.quickCapture.rawValue)"

        let response = try await todayService.performAction(action, now: fixedNow)

        XCTAssertEqual(response.message?.title, "Signal saved")
        let captures = try await repositories.captures.listCaptures()
        let updatedEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        XCTAssertEqual(captures.count, baselineCaptures.count + 1)
        XCTAssertEqual(updatedEvidence.count, baselineEvidence.count + 1)
        let capture = try XCTUnwrap(captures.first(where: { $0.sourceType == .todayQuickCapture && $0.linkedGoalID == goalID }))
        XCTAssertEqual(capture.sourceType, .todayQuickCapture)
        XCTAssertEqual(capture.linkedGoalID, goalID)
        XCTAssertTrue(updatedEvidence.contains(where: { $0.evidenceKind == .sessionLogged && $0.stepID == stepID }))

        let commandRecord = try await commandRecordRepository.fetchRecord(commandID: commandID)
        let record = try XCTUnwrap(commandRecord)
        XCTAssertEqual(record.result.status, .succeeded)
        XCTAssertEqual(record.result.target?.goalID, goalID)
        XCTAssertEqual(record.result.target?.captureID, capture.id)
        XCTAssertFalse(record.result.eventLedgerEntryIDs.isEmpty)
        let ledgerEntries = try await ledger.fetchRecent(limit: 30)
        XCTAssertTrue(
            Set(record.result.eventLedgerEntryIDs).isSubset(of: Set(ledgerEntries.map(\.id)))
        )
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .captureCreated && $0.captureID == capture.id }))
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .goalUpdated || $0.kind == .actionCompleted }))
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

    func testMissingTargetActionFailsSafelyWithoutMutationsWhileBlockingCommandExecution() async throws {
        let repositories = try await makeRepositories()
        let todayService = RepositoryBackedTodayService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)

        let baselineFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let baselineEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let baselineCaptures = try await repositories.captures.listCaptures()

        let action = TodayInlineAction(
            kind: .complete,
            title: "Complete",
            systemImage: "checkmark.circle",
            state: .warning,
            target: TodayActionTarget()
        )
        let commandID = "command.today2.\(action.id).complete_action"
        let response = try await todayService.performAction(action, now: fixedNow)

        let updatedFeedback = try await repositories.feedback.listEvents(goalID: nil)
        let updatedEvidence = try await repositories.evidence.listEvidence(goalID: nil)
        let updatedCaptures = try await repositories.captures.listCaptures()
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(response.message?.title, "Action not available")
        XCTAssertEqual(response.message?.state, .warning)
        XCTAssertEqual(updatedFeedback.count, baselineFeedback.count)
        XCTAssertEqual(updatedEvidence.count, baselineEvidence.count)
        XCTAssertEqual(updatedCaptures.count, baselineCaptures.count)
        let record = try await commandRecordRepository.fetchRecord(commandID: commandID)
        let blockedRecord = try XCTUnwrap(record)
        XCTAssertEqual(blockedRecord.result.status, .blocked)
        XCTAssertEqual(blockedRecord.result.summary, "Command is missing the target needed for safe execution.")
        XCTAssertEqual(blockedRecord.result.target?.goalID, nil)
        XCTAssertTrue(blockedRecord.result.eventLedgerEntryIDs.isEmpty)
        XCTAssertEqual(ledgerEntries.count, 0)
    }

    func testAskWhyThisMattersCommandPreservesFeedbackShapeAndRecordsExecution() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Capture why this matters proof path"),
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
        let commandID = "command.today2.\(action.id).ask_why"
        let beforeFeedback = try await repositories.feedback.listEvents(goalID: goalID)

        let response = try await todayService.performAction(action, now: fixedNow)

        XCTAssertEqual(response.message?.title, "Why this matters")
        XCTAssertFalse(response.message?.body.isEmpty ?? true)
        let afterFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let beforeAskedWhyEvents = beforeFeedback.filter {
            if case .askedWhyThisMatters(let base) = $0, base.stepID == stepID { return true }
            return false
        }
        let askedWhyEvents = afterFeedback.filter {
            if case .askedWhyThisMatters(let base) = $0, base.stepID == stepID { return true }
            return false
        }
        XCTAssertEqual(askedWhyEvents.count, beforeAskedWhyEvents.count + 1)
        let record = try await commandRecordRepository.fetchRecord(commandID: commandID)
        let execution = try XCTUnwrap(record)
        XCTAssertEqual(execution.result.status, .succeeded)
        XCTAssertEqual(execution.result.target?.goalID, goalID)
        XCTAssertFalse(execution.result.eventLedgerEntryIDs.isEmpty)
        let ledgerEntries = try await ledger.fetchRecent(limit: 20)
        XCTAssertTrue(
            execution.result.eventLedgerEntryIDs.allSatisfy { id in
                ledgerEntries.contains(where: { $0.id == id })
            }
        )
    }
}

private extension TodayCommandHandlerTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_777_113_600)
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: InMemoryEventLedgerRepository(),
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
