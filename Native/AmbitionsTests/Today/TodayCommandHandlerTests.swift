import XCTest
@testable import Ambitions

final class TodayCommandHandlerTests: XCTestCase {
    func testP1ASimpleStepLifecycleCreatesRendersReschedulesCompletesAndRecoversLocally() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await makeRepositories(store: store)
        let reloadedRepositories = try await makeRepositories(store: store)
        let todayService = RepositoryBackedTodayService(repositories: repositories)
        let lifecycleService = SimpleStepLifecycleService(repositories: repositories)

        let created = try await lifecycleService.createSimpleStep(
            title: "Mail the library card form",
            now: fixedNow
        )

        let persistedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let persistedStep = try XCTUnwrap(persistedSteps.first(where: { $0.id == created.stepID }))
        XCTAssertEqual(persistedStep.title, "Mail the library card form")
        XCTAssertEqual(persistedStep.state, .planned)
        XCTAssertEqual(persistedStep.isRepeatable, false)
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)

        let renderedToday = try await todayService.loadTodayExperience(
            userDisplayName: "Local User",
            now: fixedNow
        )
        XCTAssertEqual(renderedToday.hero.primaryAction.action.target.goalID, created.goalID)
        XCTAssertEqual(renderedToday.hero.primaryAction.action.target.stepID, created.stepID)
        XCTAssertTrue(renderedToday.hero.primaryAction.title == "Start now" || renderedToday.hero.primaryAction.title == "Still counts")

        let rescheduleAction = TodayInlineAction(
            kind: .reschedule,
            title: "Move it",
            systemImage: "arrow.right.circle",
            state: .warning,
            target: TodayActionTarget(goalID: created.goalID, stepID: created.stepID)
        )
        let rescheduleResponse = try await todayService.performAction(
            rescheduleAction,
            now: fixedNow.addingTimeInterval(60)
        )
        let rescheduledSteps = try await repositories.goals.listSteps(goalID: created.goalID)
        let rescheduledStep = try XCTUnwrap(rescheduledSteps.first(where: { $0.id == created.stepID }))
        let rescheduleFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        XCTAssertEqual(rescheduleResponse.message?.title, "What changed?")
        XCTAssertTrue(rescheduleResponse.message?.body.contains("Move it") == true)
        XCTAssertTrue(rescheduleResponse.message?.body.contains("without blame") == true)
        XCTAssertEqual(rescheduledStep.state, .planned)
        XCTAssertEqual(rescheduledStep.timing.timingType, .suggestedNext)
        XCTAssertNotNil(rescheduledStep.timing.suggestedNextAt)
        XCTAssertTrue(rescheduleFeedback.contains {
            if case .delayed(let base, _, _) = $0, base.stepID == created.stepID { return true }
            return false
        })

        let replayedRescheduleResponse = try await todayService.performAction(
            rescheduleAction,
            now: fixedNow.addingTimeInterval(90)
        )
        let replayedRescheduleFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        XCTAssertEqual(replayedRescheduleResponse.message?.title, "What changed?")
        XCTAssertTrue(replayedRescheduleResponse.message?.body.contains("Move it") == true)
        XCTAssertTrue(replayedRescheduleResponse.message?.body.contains("replayed the existing receipt") == true)
        XCTAssertEqual(replayedRescheduleFeedback.count, rescheduleFeedback.count)

        let missedRecovery = try await lifecycleService.markMissedStepForRecovery(
            goalID: created.goalID,
            stepID: created.stepID,
            now: fixedNow.addingTimeInterval(120)
        )
        let recoveryFeedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        XCTAssertTrue(missedRecovery.asksWhatChanged)
        XCTAssertEqual(missedRecovery.primaryActionTitle, "Move it")
        XCTAssertTrue(missedRecovery.secondaryActionTitles.contains("Still counts"))
        XCTAssertTrue(missedRecovery.secondaryActionTitles.contains("Not needed"))
        XCTAssertEqual(missedRecovery.updatedStep.state, .planned)
        XCTAssertEqual(missedRecovery.feedbackEventCount, 2)
        XCTAssertGreaterThan(recoveryFeedback.count, rescheduleFeedback.count)

        let completeAction = TodayInlineAction(
            kind: .complete,
            title: "Still counts",
            systemImage: "checkmark.circle.fill",
            state: .success,
            target: TodayActionTarget(goalID: created.goalID, stepID: created.stepID)
        )
        let completionResponse = try await todayService.performAction(
            completeAction,
            now: fixedNow.addingTimeInterval(180)
        )
        let completedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let completedStep = try XCTUnwrap(completedSteps.first(where: { $0.id == created.stepID }))
        let completionEvidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let closureMutation = TodayClosureStageMutation(
            record: TodayClosureRecord(
                stepID: created.stepID,
                goalID: created.goalID,
                outcome: .completed,
                occurredAt: fixedNow.addingTimeInterval(180)
            ),
            stepTitle: completedStep.title,
            receiptSaved: true
        )

        XCTAssertEqual(completionResponse.message?.title, "Completion recorded")
        XCTAssertEqual(completedStep.state, .completed)
        XCTAssertTrue(completionEvidence.contains {
            $0.goalID == created.goalID && $0.stepID == created.stepID && $0.evidenceKind == .stepCompleted
        })
        XCTAssertEqual(closureMutation.userVisibleMutation.headline, "Done")
        XCTAssertTrue(closureMutation.stageMutation.receipt.saved)
        XCTAssertTrue(closureMutation.stageMutation.proofArtifact.localOnly)
        XCTAssertFalse(closureMutation.stageMutation.accessibilityAnnouncement.message.isEmpty)
    }

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
            recovery.primaryActionTitle,
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

    func testCompletedCommandWritesFeedbackAndCommandExecutionEvidence() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let runtimeEvents = try XCTUnwrap(repositories.runtimeEvents)
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
            title: "Still counts",
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
        XCTAssertEqual(record.result.metadata["stageActionPipelineTaxonomy"], StageActionTaxonomy.productRuntime.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineCommandValidation"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineRuntimeMutation"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineVisibleMutation"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineProofReceipt"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineFallbackUndo"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertFalse(record.result.metadata["stageActionPipelineAccessibilityAnnouncement"]?.isEmpty ?? true)
        XCTAssertEqual(record.result.metadata["runtimeTransactionDisposition"], RuntimeTransactionCommitDisposition.committed.rawValue)
        XCTAssertEqual(record.result.metadata["runtimeTransactionID"], "runtime.transaction.\(commandID)")
        XCTAssertEqual(record.result.metadata["runtimeReceiptID"], "runtime.receipt.\(commandID)")
        XCTAssertEqual(record.result.metadata["runtimeRollbackPlanID"], "runtime.rollback.\(commandID)")
        XCTAssertEqual(record.result.metadata["runtimeReplayTraceID"], "runtime.replay.\(commandID)")
        XCTAssertEqual(record.result.metadata["runtimeProjectionCursorCount"], String(ProjectionID.allCases.count))
        XCTAssertEqual(record.result.metadata["commandJournalRuntimeLinkStatus"], "linked")
        let runtimeEventEnvelopes = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let runtimeEvent = try XCTUnwrap(runtimeEventEnvelopes.first)
        XCTAssertEqual(runtimeEventEnvelopes.count, 1)
        XCTAssertEqual(runtimeEvent.id, record.result.metadata["runtimeEventID"])
        XCTAssertEqual(runtimeEvent.event.commandID, commandID)
        guard case let .commandExecution(payload) = runtimeEvent.event.payload else {
            XCTFail("Expected Today command execution runtime event")
            return
        }
        XCTAssertEqual(payload.commandRecordID, "command.execution.\(commandID)")
        XCTAssertEqual(
            payload.resultMetadata["stageActionPipelineRuntimeMutation"],
            StageActionPipelineRequirementState.satisfied.rawValue
        )
        XCTAssertNil(payload.resultMetadata["runtimeProjectionCursorCount"])
        let ledgerEntries = try await ledger.fetchRecent(limit: 30)
        XCTAssertTrue(
            Set(record.result.eventLedgerEntryIDs).isSubset(of: Set(ledgerEntries.map(\.id)))
        )
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .actionCompleted }))
        XCTAssertTrue(ledgerEntries.contains(where: { $0.kind == .actionCompleted && $0.goalID == goalID }))
    }

    func testSCG009CClosureMutatesTodayBeforeActionAfterWithProofReceipt() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let ledger = try XCTUnwrap(repositories.eventLedger as? InMemoryEventLedgerRepository)
        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Close one real Today step"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let beforeToday = try await todayService.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow
        )
        let primaryStepID = try XCTUnwrap(beforeToday.hero.primaryAction.action.target.stepID)
        let fetchedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first { $0.id == primaryStepID })
        let beforeFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let beforeEvidence = try await repositories.evidence.listEvidence(goalID: goalID)

        let action = TodayInlineAction(
            kind: .complete,
            title: "Still counts",
            systemImage: "checkmark.circle.fill",
            state: .success,
            target: TodayActionTarget(goalID: goalID, stepID: step.id)
        )
        let response = try await todayService.performAction(action, now: fixedNow.addingTimeInterval(30))

        let afterToday = try await todayService.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow.addingTimeInterval(60)
        )
        let fetchedAfterGoal = try await repositories.goals.goal(id: goalID)
        let afterGoal = try XCTUnwrap(fetchedAfterGoal)
        let afterStep = try XCTUnwrap(afterGoal.plan?.sections.flatMap(\.steps).first { $0.id == step.id })
        let afterFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let afterEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let fetchedRecord = try await commandRecordRepository.fetchRecord(commandID: "command.today2.\(action.id).complete_action")
        let record = try XCTUnwrap(fetchedRecord)
        let ledgerEntries = try await ledger.fetchRecent(limit: 30)

        XCTAssertEqual(beforeToday.hero.primaryAction.action.target.goalID, goalID)
        XCTAssertEqual(beforeToday.hero.primaryAction.action.target.stepID, step.id)
        XCTAssertEqual(response.message?.title, "Completion recorded")
        XCTAssertEqual(afterStep.state, .completed)
        XCTAssertEqual(afterFeedback.count, beforeFeedback.count + 1)
        XCTAssertEqual(afterEvidence.count, beforeEvidence.count + 1)
        XCTAssertTrue(afterEvidence.contains { $0.evidenceKind == .stepCompleted && $0.stepID == step.id })
        XCTAssertEqual(afterToday.hero.primaryAction.action.target.goalID, goalID)
        XCTAssertNotNil(afterToday.hero.primaryAction.action.target.stepID)
        XCTAssertEqual(record.result.status, .succeeded)
        XCTAssertFalse(record.result.eventLedgerEntryIDs.isEmpty)
        XCTAssertTrue(Set(record.result.eventLedgerEntryIDs).isSubset(of: Set(ledgerEntries.map(\.id))))
        XCTAssertEqual(record.result.metadata["stageActionPipelineRuntimeMutation"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineProofReceipt"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertEqual(record.result.metadata["stageActionPipelineFallbackUndo"], StageActionPipelineRequirementState.satisfied.rawValue)
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
            title: "Still counts",
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
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineTaxonomy"], StageActionTaxonomy.productRuntime.rawValue)
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineCommandValidation"], StageActionPipelineRequirementState.blocked.rawValue)
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineRuntimeMutation"], StageActionPipelineRequirementState.blocked.rawValue)
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineVisibleMutation"], StageActionPipelineRequirementState.blocked.rawValue)
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineProofReceipt"], StageActionPipelineRequirementState.unavailable.rawValue)
        XCTAssertEqual(blockedRecord.result.metadata["stageActionPipelineFallbackUndo"], StageActionPipelineRequirementState.satisfied.rawValue)
        XCTAssertTrue(blockedRecord.result.eventLedgerEntryIDs.isEmpty)
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

    func testAskWhyThisMattersCommandPreservesFeedbackShapeAndRecordsExecution() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let commandRecordRepository = try XCTUnwrap(repositories.commandExecutionRecords as? InMemoryAmbitionsCommandExecutionRecordRepository)
        let commandJournal = try XCTUnwrap(repositories.commandJournal as? InMemoryCommandJournal)
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
        XCTAssertEqual(execution.result.metadata["commandEnvelopePhase"], CommandEnvelopePhase.acceptedBeforeMutation.rawValue)
        XCTAssertEqual(execution.result.metadata["commandReceiptID"], "command.receipt.\(commandID)")
        XCTAssertEqual(execution.result.metadata["commandJournalSequence"], "1")
        let envelopes = try await commandJournal.fetchEnvelopes(matching: .commandID(commandID), limit: nil)
        XCTAssertEqual(envelopes.count, 1)
        XCTAssertEqual(envelopes.first?.phase, .acceptedBeforeMutation)
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
