import XCTest
@testable import Ambitions

final class RecurringStepLifecycleServiceTests: XCTestCase {
    func testP1BRecurringStepCreationPersistsRuleAndGeneratesScheduledOccurrencesLocally() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let service = SimpleStepLifecycleService(repositories: repositories)

        let created = try await service.createRecurringStep(
            title: "Review tomorrow's commitments",
            repeatEveryDays: 3,
            now: fixedNow
        )

        let reloadedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let reloadedStep = try XCTUnwrap(reloadedSteps.first(where: { $0.id == created.stepID }))
        let occurrences = try await service.scheduledOccurrences(
            goalID: created.goalID,
            stepID: created.stepID,
            from: fixedNow,
            limit: 3
        )

        XCTAssertEqual(reloadedStep.title, "Review tomorrow's commitments")
        XCTAssertEqual(reloadedStep.type, .recurringRoutine)
        XCTAssertEqual(reloadedStep.state, .planned)
        XCTAssertTrue(reloadedStep.isRepeatable)
        XCTAssertEqual(reloadedStep.timing.tempo, .ongoing)
        XCTAssertEqual(reloadedStep.timing.timingType, .repeatWithinWindow)
        XCTAssertEqual(reloadedStep.timing.repeatEveryDays, 3)
        XCTAssertEqual(occurrences.count, 3)
        XCTAssertEqual(occurrences.first, created.nextOccurrence)
        XCTAssertTrue(occurrences.allSatisfy { $0.goalID == created.goalID && $0.stepID == created.stepID })
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }

    func testP1BCompletingOneRecurringOccurrencePreservesFutureRecurrenceAndPersistsNextOccurrence() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let service = SimpleStepLifecycleService(repositories: repositories)

        let created = try await service.createRecurringStep(
            title: "Water the balcony plants",
            repeatEveryDays: 2,
            now: fixedNow
        )
        let initialOccurrences = try await service.scheduledOccurrences(
            goalID: created.goalID,
            stepID: created.stepID,
            from: fixedNow,
            limit: 1
        )
        let firstOccurrence = try XCTUnwrap(initialOccurrences.first)
        let completionTime = fixedNow.addingTimeInterval(24 * 60 * 60)

        let completion = try await service.completeRecurringOccurrence(
            goalID: created.goalID,
            stepID: created.stepID,
            occurrenceID: firstOccurrence.id,
            now: completionTime
        )
        let reloadedSteps = try await reloadedRepositories.goals.listSteps(goalID: created.goalID)
        let reloadedStep = try XCTUnwrap(reloadedSteps.first(where: { $0.id == created.stepID }))
        let feedback = try await reloadedRepositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await reloadedRepositories.evidence.listEvidence(goalID: created.goalID)

        XCTAssertEqual(completion.completedOccurrenceID, firstOccurrence.id)
        XCTAssertTrue(completion.preservesRecurrence)
        XCTAssertEqual(completion.feedbackEventCount, 1)
        XCTAssertEqual(completion.evidenceCount, 1)
        XCTAssertEqual(reloadedStep.state, .planned)
        XCTAssertTrue(reloadedStep.isRepeatable)
        XCTAssertEqual(reloadedStep.timing.repeatEveryDays, 2)
        XCTAssertNotEqual(reloadedStep.timing.suggestedNextAt, firstOccurrence.scheduledAt)
        XCTAssertEqual(completion.nextOccurrence?.scheduledAt, reloadedStep.timing.suggestedNextAt)
        XCTAssertTrue(feedback.contains {
            if case .completed(let base, _, _, _) = $0, base.stepID == created.stepID {
                return base.note == "Recurring Step occurrence completed locally."
            }
            return false
        })
        XCTAssertTrue(evidence.contains {
            $0.goalID == created.goalID &&
                $0.stepID == created.stepID &&
                $0.evidenceKind == .ritualCompletion &&
                $0.note == "Completed one recurring Step occurrence without ending the recurrence."
        })
    }

    func testP1BPausingRecurringStepPersistsStateAndPreventsGeneratedOccurrencesUntilResume() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let reloadedRepositories = makeRepositories(store: store)
        let service = SimpleStepLifecycleService(repositories: repositories)
        let reloadedService = SimpleStepLifecycleService(repositories: reloadedRepositories)

        let created = try await service.createRecurringStep(
            title: "Weekly home reset",
            repeatEveryDays: 7,
            now: fixedNow
        )

        let pause = try await service.pauseRecurrence(
            goalID: created.goalID,
            stepID: created.stepID,
            now: fixedNow.addingTimeInterval(60)
        )
        let pausedGoal = try await reloadedRepositories.goals.goal(id: created.goalID)
        let reloadedPausedGoal = try XCTUnwrap(pausedGoal)
        let pausedOccurrences = try await reloadedService.scheduledOccurrences(
            goalID: created.goalID,
            stepID: created.stepID,
            from: fixedNow,
            limit: 2
        )

        XCTAssertTrue(pause.isPaused)
        XCTAssertTrue(pause.generatedOccurrences.isEmpty)
        XCTAssertEqual(reloadedPausedGoal.state, .paused)
        XCTAssertTrue(pausedOccurrences.isEmpty)

        let resume = try await reloadedService.resumeRecurrence(
            goalID: created.goalID,
            stepID: created.stepID,
            now: fixedNow.addingTimeInterval(120)
        )
        let resumedGoal = try await reloadedRepositories.goals.goal(id: created.goalID)
        let reloadedResumedGoal = try XCTUnwrap(resumedGoal)

        XCTAssertFalse(resume.isPaused)
        XCTAssertEqual(reloadedResumedGoal.state, .active)
        XCTAssertEqual(resume.generatedOccurrences.count, 1)
        XCTAssertEqual(resume.generatedOccurrences.first?.stepID, created.stepID)
    }
}

private extension RecurringStepLifecycleServiceTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_777_113_600)
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
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
