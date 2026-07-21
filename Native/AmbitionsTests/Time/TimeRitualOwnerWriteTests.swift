import XCTest
@testable import Ambitions

final class TimeRitualOwnerWriteTests: XCTestCase {
    func testPreparationIsDeterministicAndDoesNotWriteRepositories() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Prepare one ritual action", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)
        let request = TimeRitualActionRequest(
            kind: .quickLog,
            target: TimeRitualActionTarget(goalID: created.goalID, stepID: created.stepID, draftID: nil),
            operationID: "time-ritual-operation-1"
        )
        let beforeGoal = try await repositories.goals.goal(id: created.goalID)

        let first = try await service.prepareDurableAction(request, now: fixedNow)
        let second = try await service.prepareDurableAction(request, now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: first.command))

        XCTAssertEqual(first.command.id, second.command.id)
        XCTAssertTrue(first.command.id.contains(request.operationID))
        XCTAssertEqual(plan, TimeRitualActionPlan.decode(command: second.command))
        XCTAssertEqual(plan.expectedGoalRevision, beforeGoal?.revision)
        XCTAssertEqual(plan.evidence.map(\.id), ["\(first.command.id).evidence"])
        let afterGoal = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(afterGoal, beforeGoal)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testAllSevenMutatingKindsPrepareOwnedPlansAndOpenDetailIsRejected() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Cover ritual actions", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)
        let kinds: [TimeRitualActionKind] = [
            .complete, .minimumVersion, .quickLog, .delay, .skip, .needsEasierVersion, .markNotRelevant
        ]

        for kind in kinds {
            let prepared = try await service.prepareDurableAction(
                request(kind, created: created, operationID: "operation-\(kind.rawValue)"),
                now: fixedNow
            )
            let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
            XCTAssertEqual(plan.actionKind, kind)
            XCTAssertEqual(plan.goalID, created.goalID)
            XCTAssertEqual(plan.stepID, created.stepID)
            XCTAssertEqual(prepared.command.source, .time)
            XCTAssertEqual(prepared.command.target.destination, .time)
            XCTAssertEqual(AmbitionsCommandValidator().validate(prepared.command), .valid)
            XCTAssertNotNil(prepared.response.proofArtifactID)
        }

        do {
            _ = try await service.prepareDurableAction(
                request(.openDetail, created: created, operationID: "route-only"),
                now: fixedNow
            )
            XCTFail("Open detail must remain outside durable mutation handling")
        } catch TimeRitualDurableActionError.unavailable {}
    }

    func testDistinctQuickLogInvocationsFromSameLoadedRowHaveDistinctAuthorityIdentity() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Log two ritual sessions", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)

        let first = try await service.prepareDurableAction(
            request(.quickLog, created: created, operationID: "tap-one"),
            now: fixedNow
        )
        let second = try await service.prepareDurableAction(
            request(.quickLog, created: created, operationID: "tap-two"),
            now: fixedNow
        )

        XCTAssertNotEqual(first.command.id, second.command.id)
        XCTAssertNotEqual(
            TimeRitualActionPlan.decode(command: first.command)?.evidence.first?.id,
            TimeRitualActionPlan.decode(command: second.command)?.evidence.first?.id
        )
    }

    func testDuplicateCompletionAtSameRevisionUsesOneCommandIdentity() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Deduplicate completion", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)

        let first = try await service.prepareDurableAction(
            request(.complete, created: created, operationID: "tap-one"),
            now: fixedNow
        )
        let second = try await service.prepareDurableAction(
            request(.complete, created: created, operationID: "tap-two"),
            now: fixedNow
        )

        XCTAssertEqual(first.command.id, second.command.id)
        XCTAssertFalse(first.command.id.contains("tap-one"))
        XCTAssertFalse(second.command.id.contains("tap-two"))
    }

    func testDeletedGoalRaceCannotInsertQuickLogEvidence() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Delete before materialization", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.quickLog, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        try await repositories.goals.deleteGoal(id: created.goalID)

        do {
            try await SwiftDataTimeRitualActionMaterializer(store: store).materialize(plan)
            XCTFail("Deleted Goal must block all derived artifacts")
        } catch TimeRitualDurableActionError.unavailable {}

        let goal = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertNil(goal)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testRemovedStepRaceCannotInsertArtifactsOrRestoreStep() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Remove before materialization", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.complete, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let loaded = try await repositories.goals.goal(id: created.goalID)
        let goal = try XCTUnwrap(loaded)
        try await repositories.goals.saveGoals([removingStep(from: goal, stepID: created.stepID)])

        do {
            try await SwiftDataTimeRitualActionMaterializer(store: store).materialize(plan)
            XCTFail("Removed Step must block all derived artifacts")
        } catch TimeRitualDurableActionError.unavailable {}

        let steps = try await repositories.goals.listSteps(goalID: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertFalse(steps.contains(where: { $0.id == created.stepID }))
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testStaleGoalBlocksBeforeAuthorityCommitAndDerivedWrites() async throws {
        let root = try temporaryRoot(named: "time-ritual-stale")
        defer { try? FileManager.default.removeItem(at: root) }
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Do current ritual", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.complete, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        try await repositories.goals.saveGoals([
            copy(plan.updatedGoal, revision: plan.updatedGoal.revision + 1, title: "Changed elsewhere")
        ])
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))

        let result = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            timeRitualActionMaterializer: SwiftDataTimeRitualActionMaterializer(store: store)
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertTrue(authority.isEmpty)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testAtomicFailureRollsBackGoalFeedbackAndEvidence() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Commit ritual atomically", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.complete, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let before = try await repositories.goals.goal(id: created.goalID)

        do {
            try await SwiftDataTimeRitualActionMaterializer(
                store: store,
                failurePoint: .afterEvidence
            ).materialize(plan)
            XCTFail("Expected injected transaction failure")
        } catch TimeRitualActionStorageError.injectedFailure(.afterEvidence) {}

        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testCompleteMinimumSkipAndNeedsEasierMaterializeTheirExactOwnedChanges() async throws {
        for kind in [TimeRitualActionKind.complete, .minimumVersion, .skip, .needsEasierVersion] {
            let store = try AmbitionsPersistenceStore(inMemory: true)
            let repositories = makeRepositories(store)
            let created = try await SimpleStepLifecycleService(repositories: repositories)
                .createSimpleStep(title: "Materialize \(kind.rawValue)", now: fixedNow)
            let beforeGoal = try await repositories.goals.goal(id: created.goalID)
            let beforeStep = try XCTUnwrap(
                beforeGoal?.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID })
            )
            let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
                .prepareDurableAction(request(kind, created: created), now: fixedNow)
            let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))

            try await SwiftDataTimeRitualActionMaterializer(store: store).materialize(plan)

            let afterGoal = try await repositories.goals.goal(id: created.goalID)
            let afterStep = try XCTUnwrap(
                afterGoal?.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID })
            )
            let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
            let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
            switch kind {
            case .complete:
                XCTAssertEqual(feedback.map(\.kind), [.completed])
                XCTAssertEqual(evidence.map(\.evidenceKind), [.ritualCompletion])
                XCTAssertNotEqual(afterStep.timing, beforeStep.timing)
            case .minimumVersion:
                XCTAssertEqual(evidence.map(\.evidenceKind), [.ritualMinimumVersion])
                XCTAssertNotEqual(afterStep.timing, beforeStep.timing)
            case .skip:
                XCTAssertEqual(feedback.map(\.kind), [.skipped])
                XCTAssertNotEqual(afterStep.timing, beforeStep.timing)
            case .needsEasierVersion:
                XCTAssertEqual(feedback.map(\.kind), [.askedForSmallerVersion])
                XCTAssertEqual(afterGoal, beforeGoal)
            default:
                XCTFail("Unexpected test action")
            }
        }
    }

    func testDelayPreservesDeadlineTargetAndWindowFields() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Preserve ritual timing", now: fixedNow)
        let loaded = try await repositories.goals.goal(id: created.goalID)
        let goal = try XCTUnwrap(loaded)
        let timing = GoalTiming(
            tempo: .ongoing,
            timingType: .suggestedNext,
            startsOn: "2026-04-20T09:00:00Z",
            dueAt: "2026-04-21T17:00:00Z",
            targetBy: "2026-04-22T17:00:00Z",
            windowStart: "2026-04-20T12:00:00Z",
            windowEnd: "2026-04-20T14:00:00Z",
            suggestedNextAt: "2026-04-20T10:00:00Z",
            repeatEveryDays: 2,
            progressReviewCadenceDays: 7
        )
        try await repositories.goals.saveGoals([
            replacingStepTiming(in: goal, stepID: created.stepID, timing: timing)
        ])

        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.delay, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let updatedStep = try XCTUnwrap(
            plan.updatedGoal.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID })
        )

        XCTAssertEqual(updatedStep.timing.dueAt, timing.dueAt)
        XCTAssertEqual(updatedStep.timing.targetBy, timing.targetBy)
        XCTAssertEqual(updatedStep.timing.windowStart, timing.windowStart)
        XCTAssertEqual(updatedStep.timing.windowEnd, timing.windowEnd)
        XCTAssertNotEqual(updatedStep.timing.suggestedNextAt, timing.suggestedNextAt)
    }

    func testAuthorityReplayAfterRestartMaterializesExactlyOnce() async throws {
        let root = try temporaryRoot(named: "time-ritual-replay")
        defer { try? FileManager.default.removeItem(at: root) }
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Replay ritual once", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.quickLog, created: created, operationID: "replay-once"), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let firstExecutor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            timeRitualActionMaterializer: SwiftDataTimeRitualActionMaterializer(store: store)
        )

        let first = await firstExecutor.execute(prepared.command, context: prepared.context)
        let restartedExecutor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            timeRitualActionMaterializer: SwiftDataTimeRitualActionMaterializer(store: store)
        )
        let replay = await restartedExecutor.execute(prepared.command, context: prepared.context)
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(first.metadata["timeRitualActionMaterialization"], "saved_post_authority")
        XCTAssertTrue(
            first.metadata["runtimeMaterializedProjectionCursorIDs", default: ""]
                .split(separator: ",")
                .contains(Substring(ProjectionID.time.rawValue))
        )
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        XCTAssertEqual(authority.count, 1)
        XCTAssertEqual(evidence.filter { $0.id == plan.evidence.first?.id }, plan.evidence)
        let semantic = try XCTUnwrap(authority.first)
        guard case let .domainMutation(record) = semantic.event.payload,
              case let .timeRitualActionApplied(eventPlan) = try record.decodedEvent() else {
            return XCTFail("Expected Time ritual semantic authority event")
        }
        XCTAssertEqual(eventPlan, plan)
    }

    func testConcurrentNewerGoalKeepsUnrelatedFieldsWhileApplyingOwnedStepTiming() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Preserve concurrent edits", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.delay, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let loadedCurrent = try await repositories.goals.goal(id: created.goalID)
        let current = try XCTUnwrap(loadedCurrent)
        let concurrent = copy(current, revision: current.revision + 1, title: "Concurrent title")
        try await repositories.goals.saveGoals([concurrent])

        try await SwiftDataTimeRitualActionMaterializer(store: store).materialize(plan)

        let loadedSaved = try await repositories.goals.goal(id: created.goalID)
        let saved = try XCTUnwrap(loadedSaved)
        let savedStep = try XCTUnwrap(saved.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID }))
        let plannedStep = try XCTUnwrap(plan.updatedGoal.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID }))
        XCTAssertEqual(saved.title, "Concurrent title")
        XCTAssertEqual(savedStep.timing, plannedStep.timing)
    }

    func testMarkNotRelevantPausesGoalWithoutReplacingConcurrentGoalFields() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Pause ritual safely", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.markNotRelevant, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let loadedCurrent = try await repositories.goals.goal(id: created.goalID)
        let current = try XCTUnwrap(loadedCurrent)
        try await repositories.goals.saveGoals([
            copy(current, revision: current.revision + 1, title: "Keep this title")
        ])

        try await SwiftDataTimeRitualActionMaterializer(store: store).materialize(plan)

        let loadedSaved = try await repositories.goals.goal(id: created.goalID)
        let saved = try XCTUnwrap(loadedSaved)
        XCTAssertEqual(saved.state, .paused)
        XCTAssertEqual(saved.title, "Keep this title")
    }

    func testLegacyServiceCannotWriteMutatingActionBeforeAuthority() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "No legacy writer", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)
        let before = try await repositories.goals.goal(id: created.goalID)

        do {
            _ = try await service.performAction(request(.complete, created: created), now: fixedNow)
            XCTFail("Mutating action must require the runtime authority path")
        } catch TimeRitualDurableActionError.unavailable {}

        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testRepositoryFallbackFailsClosedWithoutPartialWrites() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "No nonatomic fallback", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.complete, created: created), now: fixedNow)
        let plan = try XCTUnwrap(TimeRitualActionPlan.decode(command: prepared.command))
        let before = try await repositories.goals.goal(id: created.goalID)

        do {
            try await RepositoryTimeRitualActionMaterializer(repositories: repositories).materialize(plan)
            XCTFail("Non-transactional fallback must fail closed")
        } catch TimeRitualDurableActionError.materializerUnavailable {}

        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testJournalFailureProducesNoAuthorityOrDerivedWrites() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Journal before projection", now: fixedNow)
        let prepared = try await RepositoryBackedTimeRitualsService(repositories: repositories)
            .prepareDurableAction(request(.complete, created: created), now: fixedNow)
        let before = try await repositories.goals.goal(id: created.goalID)
        let events = InMemoryRuntimeEventStore()

        let result = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            commandJournal: TimeRitualFailingCommandJournal(),
            timeRitualActionMaterializer: SwiftDataTimeRitualActionMaterializer(store: store)
        ).execute(prepared.command, context: prepared.context)

        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertNotEqual(result.status, .succeeded)
        XCTAssertTrue(authority.isEmpty)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    @MainActor
    func testViewModelDoesNotPublishSuccessWhenMaterializationValidationFails() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "No false ritual success", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)
        let before = try await repositories.goals.goal(id: created.goalID)
        let viewModel = TimeRitualsViewModel()
        let action = TimeRitualActionState(
            kind: .complete,
            title: "Complete",
            systemImage: "checkmark",
            state: .success,
            target: TimeRitualActionTarget(
                goalID: created.goalID,
                stepID: created.stepID,
                draftID: nil
            )
        )
        let client = RuntimeCommandClient(
            execute: { command, _ in
                AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Authority accepted but projection failed",
                    route: .time,
                    target: command.target,
                    metadata: [
                        "runtimeReceiptID": "receipt-1",
                        "runtimeProjectionStoreStatus": "saved",
                        "timeRitualActionMaterialization": "needs_recovery"
                    ]
                )
            },
            projection: { request in throw RuntimeProjectionClientError.projectionUnavailable(request) }
        )

        await viewModel.perform(action, using: service, runtimeClient: client, now: fixedNow)

        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(viewModel.inlineMessage?.title, "Ritual action could not finish")
        XCTAssertTrue(viewModel.mutationProof?.runtimeMutation.hasSuffix(".failed") == true)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    @MainActor
    func testViewModelPublishesSuccessOnlyForMatchingMaterializedTimeCursor() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Validate Time cursor", now: fixedNow)
        let service = RepositoryBackedTimeRitualsService(repositories: repositories)
        let action = timeRitualAction(.quickLog, created: created)
        let matchingClient = cursorClient(projectionChecksum: "time-checksum")
        let mismatchedClient = cursorClient(projectionChecksum: "different-checksum")
        let successful = TimeRitualsViewModel()
        let rejected = TimeRitualsViewModel()

        await successful.perform(action, using: service, runtimeClient: matchingClient, now: fixedNow)
        await rejected.perform(action, using: service, runtimeClient: mismatchedClient, now: fixedNow)

        XCTAssertEqual(successful.inlineMessage?.title, "Signal captured")
        XCTAssertEqual(successful.mutationProof?.runtimeMutation, "time-rituals.quick_log")
        XCTAssertEqual(rejected.inlineMessage?.title, "Ritual action could not finish")
        XCTAssertTrue(rejected.mutationProof?.runtimeMutation.hasSuffix(".failed") == true)
    }

    private var fixedNow: Date { Date(timeIntervalSince1970: 1_777_113_600) }

    private func request(
        _ kind: TimeRitualActionKind,
        created: SimpleStepLifecycleResult,
        operationID: String = "operation-1"
    ) -> TimeRitualActionRequest {
        TimeRitualActionRequest(
            kind: kind,
            target: TimeRitualActionTarget(
                goalID: created.goalID,
                stepID: created.stepID,
                draftID: nil
            ),
            operationID: operationID
        )
    }

    private func timeRitualAction(
        _ kind: TimeRitualActionKind,
        created: SimpleStepLifecycleResult
    ) -> TimeRitualActionState {
        TimeRitualActionState(
            kind: kind,
            title: kind.rawValue,
            systemImage: "circle",
            state: .selected,
            target: TimeRitualActionTarget(
                goalID: created.goalID,
                stepID: created.stepID,
                draftID: nil
            )
        )
    }

    private func cursorClient(projectionChecksum: String) -> RuntimeCommandClient {
        RuntimeCommandClient(
            execute: { command, _ in
                AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Committed and materialized",
                    route: .time,
                    target: command.target,
                    metadata: [
                        "runtimeReceiptID": "receipt-time",
                        "runtimeProjectionStoreStatus": "saved",
                        "timeRitualActionMaterialization": "saved_post_authority",
                        "runtimeMaterializedProjectionCursorIDs": ProjectionID.time.rawValue,
                        "runtimeMaterializedProjectionCursorSequences": "9",
                        "runtimeMaterializedProjectionCursorChecksums": "time-checksum"
                    ]
                )
            },
            projection: { _ in
                RuntimeProjectionSnapshot(
                    projectionID: ProjectionID.time.rawValue,
                    payload: Data(),
                    eventSequence: 9,
                    cursorChecksum: projectionChecksum,
                    payloadChecksum: "payload",
                    materializedAt: "2026-04-20T12:00:00Z"
                )
            }
        )
    }

    private func temporaryRoot(named name: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name)-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    private func makeRepositories(_ store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }

    private func copy(_ goal: Goal, revision: Int, title: String) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: revision,
            createdAt: goal.createdAt, updatedAt: goal.updatedAt, state: goal.state, title: title,
            summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: goal.plan, lifeGraph: goal.lifeGraph
        )
    }

    private func removingStep(from goal: Goal, stepID: String) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.filter { $0.id != stepID }
            )
        }
        let plan = goal.plan.map {
            GoalPlan(
                id: $0.id,
                goalID: $0.goalID,
                version: $0.version,
                generatedAt: $0.generatedAt,
                summary: $0.summary,
                strategy: $0.strategy,
                sections: sections ?? $0.sections,
                assumptions: $0.assumptions,
                lint: $0.lint
            )
        }
        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: plan,
            lifeGraph: goal.lifeGraph
        )
    }

    private func replacingStepTiming(in goal: Goal, stepID: String, timing: GoalTiming) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { step in
                    guard step.id == stepID else { return step }
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: timing,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            )
        }
        let plan = goal.plan.map {
            GoalPlan(
                id: $0.id,
                goalID: $0.goalID,
                version: $0.version,
                generatedAt: $0.generatedAt,
                summary: $0.summary,
                strategy: $0.strategy,
                sections: sections ?? $0.sections,
                assumptions: $0.assumptions,
                lint: $0.lint
            )
        }
        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: plan,
            lifeGraph: goal.lifeGraph
        )
    }
}

private struct TimeRitualFailingCommandJournal: CommandJournal {
    struct Failure: Error {}

    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt {
        throw Failure()
    }

    func linkRuntimeCommit(
        commandID: String,
        runtimeEventID: String,
        runtimeReceiptID: String,
        linkedAt: String
    ) async throws -> CommandJournalRuntimeLinkReceipt {
        throw Failure()
    }

    func fetchEntries(
        matching query: CommandJournalQuery,
        limit: Int?
    ) async throws -> [CommandJournalEntry] { [] }

    func fetchEnvelopes(
        matching query: CommandJournalQuery,
        limit: Int?
    ) async throws -> [CommandEnvelope] { [] }
}
