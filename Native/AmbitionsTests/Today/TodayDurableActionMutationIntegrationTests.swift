import XCTest
@testable import Ambitions

final class TodayDurableActionMutationIntegrationTests: XCTestCase {
    func testLegacyFeedbackEntryCannotMutateDurableGoalStepActions() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "No alternate writer", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let before = try await repositories.goals.goal(id: created.goalID)

        _ = try await service.performFeedbackAction(
            makeAction(.defer, goalID: created.goalID, stepID: created.stepID),
            now: fixedNow
        )

        let after = try await repositories.goals.goal(id: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(after, before)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    func testLegacyFeedbackEntryCannotMutateQuickLog() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "No quick-log alternate writer", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)

        _ = try await service.performFeedbackAction(
            makeAction(.quickLog, goalID: created.goalID, stepID: created.stepID),
            now: fixedNow
        )

        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let captures = try await repositories.captures.listCaptures()
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
        XCTAssertTrue(captures.isEmpty)
    }

    func testQuickLogPlanCarriesExactDeterministicCaptureWithoutPreparingWrites() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Capture this session", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let action = makeAction(
            .quickLog,
            goalID: created.goalID,
            stepID: created.stepID,
            operationID: "quick-log-invocation-1"
        )

        let first = try await service.prepareDurableGoalStepAction(action, now: fixedNow)
        let second = try await service.prepareDurableGoalStepAction(action, now: fixedNow)
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: first.command))
        let capture = try XCTUnwrap(plan.capture)

        XCTAssertEqual(first.command.id, second.command.id)
        XCTAssertTrue(first.command.id.contains(action.operationID))
        XCTAssertEqual(plan, TodayGoalStepActionPlan.decode(command: second.command))
        XCTAssertEqual(first.command.operation, .quickCapture)
        XCTAssertEqual(capture.id, "capture.\(first.command.id)")
        XCTAssertEqual(capture.rawText, "Quick log for \"Capture this session\".")
        XCTAssertEqual(capture.sourceType, .todayQuickCapture)
        XCTAssertEqual(capture.status, .actionable)
        XCTAssertEqual(capture.route, .captureInbox)
        XCTAssertEqual(capture.triageStatus, .assumedRoute)
        XCTAssertEqual(capture.commitmentKind, .goalSupporting)
        XCTAssertEqual(capture.priorityHints.goalSupporting, true)
        XCTAssertEqual(capture.linkedGoalID, created.goalID)
        XCTAssertEqual(capture.goalRelationship, CaptureGoalRelationship(goalID: created.goalID, relationshipKind: .nextAction))
        XCTAssertEqual(plan.evidence.map(\.id), ["\(first.command.id).evidence"])
        XCTAssertEqual(plan.evidence.map(\.evidenceKind), [.sessionLogged])
        XCTAssertTrue(plan.feedbackEvents.isEmpty)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let captures = try await repositories.captures.listCaptures()
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
        XCTAssertTrue(captures.isEmpty)
    }

    func testDistinctQuickLogInvocationIDsCreateDistinctCommandIdentitiesAtSameRevision() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Log two sessions", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)

        let first = try await service.prepareDurableGoalStepAction(
            makeAction(.quickLog, goalID: created.goalID, stepID: created.stepID, operationID: "invocation-a"),
            now: fixedNow
        )
        let second = try await service.prepareDurableGoalStepAction(
            makeAction(.quickLog, goalID: created.goalID, stepID: created.stepID, operationID: "invocation-b"),
            now: fixedNow
        )

        XCTAssertNotEqual(first.command.id, second.command.id)
        XCTAssertNotEqual(
            TodayGoalStepActionPlan.decode(command: first.command)?.capture?.id,
            TodayGoalStepActionPlan.decode(command: second.command)?.capture?.id
        )
    }

    func testNonQuickLogIdentityRemainsRevisionBasedAcrossInvocationIDs() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Deduplicate one mutation", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)

        let first = try await service.prepareDurableGoalStepAction(
            makeAction(.complete, goalID: created.goalID, stepID: created.stepID, operationID: "invocation-a"),
            now: fixedNow
        )
        let second = try await service.prepareDurableGoalStepAction(
            makeAction(.complete, goalID: created.goalID, stepID: created.stepID, operationID: "invocation-b"),
            now: fixedNow
        )

        XCTAssertEqual(first.command.id, second.command.id)
        XCTAssertFalse(first.command.id.contains("invocation-a"))
        XCTAssertFalse(second.command.id.contains("invocation-b"))
    }

    func testLegacyPlanWithoutWritesGoalDefaultsToGoalWrite() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Decode legacy authority", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(
                makeAction(.complete, goalID: created.goalID, stepID: created.stepID),
                now: fixedNow
            )
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let encoded = try JSONEncoder().encode(plan)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        object.removeValue(forKey: "writesGoal")
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let legacy = try JSONDecoder().decode(TodayGoalStepActionPlan.self, from: legacyData)

        XCTAssertNil(legacy.writesGoal)
        XCTAssertTrue(legacy.shouldWriteGoal)
    }

    func testQuickLogRepositoryFallbackIsIdempotent() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Replay one log", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(
                makeAction(.quickLog, goalID: created.goalID, stepID: created.stepID, operationID: "replay-one"),
                now: fixedNow
            )
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let materializer = RepositoryTodayGoalStepActionMaterializer(repositories: repositories)

        try await materializer.materialize(plan)
        try await materializer.materialize(plan)

        let captures = try await repositories.captures.listCaptures()
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(captures, [try XCTUnwrap(plan.capture)])
        XCTAssertEqual(evidence, plan.evidence)
    }

    func testQuickLogAuthorityReplayPreservesConcurrentlyAdvancedGoal() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("today-quick-log-concurrency-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let lifecycle = SimpleStepLifecycleService(repositories: repositories)
        let created = try await lifecycle.createSimpleStep(
            title: "Preserve newer recovery",
            now: fixedNow
        )
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(
                makeAction(
                    .quickLog,
                    goalID: created.goalID,
                    stepID: created.stepID,
                    operationID: "concurrent-log"
                ),
                now: fixedNow
            )
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        XCTAssertFalse(plan.shouldWriteGoal)
        _ = try await lifecycle.markMissedStepForRecovery(
            goalID: created.goalID,
            stepID: created.stepID,
            now: fixedNow.addingTimeInterval(60)
        )
        let newerGoal = try await repositories.goals.goal(id: created.goalID)
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: ProjectionStoreSQLite(
                databaseURL: root.appendingPathComponent("ProjectionStore.sqlite")
            ),
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(
                repositories: repositories
            )
        )

        let first = await executor.execute(prepared.command, context: prepared.context)
        let replay = await executor.execute(prepared.command, context: prepared.context)
        let currentGoal = try await repositories.goals.goal(id: created.goalID)
        let captures = try await repositories.captures.listCaptures()
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        XCTAssertEqual(currentGoal, newerGoal)
        XCTAssertEqual(captures, [try XCTUnwrap(plan.capture)])
        XCTAssertEqual(evidence.filter { $0.id == plan.evidence.first?.id }, plan.evidence)
        XCTAssertEqual(authority.count, 1)
    }

    func testQuickLogUsesCompositeSemanticEventInsteadOfGenericCaptureEvent() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "One composite event", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(
                makeAction(.quickLog, goalID: created.goalID, stepID: created.stepID, operationID: "semantic-one"),
                now: fixedNow
            )
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Prepared",
            target: AmbitionsCommandTarget(
                goalID: created.goalID,
                captureID: plan.capture?.id,
                stepID: created.stepID,
                destination: .today
            )
        )

        let event = RuntimeDomainEvent.semanticEvent(
            command: prepared.command,
            result: result,
            occurredAt: DomainTimestamp.string(from: fixedNow)
        )

        XCTAssertEqual(event, .todayGoalStepActionApplied(plan))
    }

    func testContextualRescheduleDecisionIsCarriedIntoDeterministicPlan() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Move with context", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let loadedGoal = try await repositories.goals.goal(id: created.goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == created.stepID }))
        let history = [GoalFeedbackEvent.delayed(
            base: GoalFeedbackEventBase(id: "prior-delay", stepID: step.id, occurredAt: DomainTimestamp.string(from: fixedNow.addingTimeInterval(-3600)), note: "Reality changed."),
            timingAdjustment: .laterToday,
            date: nil
        )]
        try await repositories.feedback.saveEvents(history, goalID: goal.id)
        let expected = try XCTUnwrap(service.rescheduleDecision(for: .reschedule, goal: goal, step: step, history: history, now: fixedNow))

        let prepared = try await service.prepareDurableGoalStepAction(
            makeAction(.reschedule, goalID: goal.id, stepID: step.id),
            now: fixedNow
        )
        let plan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let updated = try XCTUnwrap(plan.updatedGoal.plan?.sections.flatMap(\.steps).first(where: { $0.id == step.id }))

        XCTAssertEqual(plan.feedbackEvents.last?.timingAdjustment, expected.timingAdjustment)
        XCTAssertEqual(plan.feedbackEvents.last?.adjustedDate, expected.suggestedTime)
        XCTAssertEqual(updated.summary, expected.recoverySummary ?? expected.smallerStep?.summary ?? step.summary)
    }

    func testConsecutiveDistinctActionsAdvanceRevisionAndRetainLineage() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("today-consecutive-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Act twice", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let executor = AmbitionsCommandExecutor.test(runtimeEvents: events, projectionStore: projections, todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: repositories))

        let deferCommand = try await service.prepareDurableGoalStepAction(makeAction(.defer, goalID: created.goalID, stepID: created.stepID), now: fixedNow)
        let deferred = await executor.execute(deferCommand.command, context: deferCommand.context)
        let splitCommand = try await service.prepareDurableGoalStepAction(makeAction(.split, goalID: created.goalID, stepID: created.stepID), now: fixedNow.addingTimeInterval(60))
        let split = await executor.execute(splitCommand.command, context: splitCommand.context)
        let splitReplay = await executor.execute(splitCommand.command, context: splitCommand.context)

        XCTAssertNotEqual(deferCommand.command.id, splitCommand.command.id)
        XCTAssertNotEqual(deferred.metadata["runtimeReceiptID"], split.metadata["runtimeReceiptID"])
        XCTAssertEqual(splitReplay.metadata["runtimeReceiptID"], split.metadata["runtimeReceiptID"])
        XCTAssertEqual(splitReplay.metadata["runtimeProjectionCursorChecksums"], split.metadata["runtimeProjectionCursorChecksums"])
        let plans = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(plans.count, 2)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        XCTAssertGreaterThanOrEqual(feedback.count, 2)
        XCTAssertTrue(feedback.contains { if case .delayed = $0 { true } else { false } })
        XCTAssertTrue(feedback.contains { if case .askedForSmallerVersion = $0 { true } else { false } })
        let finalGoal = try await repositories.goals.goal(id: created.goalID)
        XCTAssertEqual(finalGoal?.revision, 3)
    }

    func testMissingMaterializerReturnsTruthfulUnavailableRejection() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Reject truthfully", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(makeAction(.defer, goalID: created.goalID, stepID: created.stepID), now: fixedNow)

        let result = await AmbitionsCommandExecutor.test(todayActionMaterializer: nil)
            .execute(prepared.command, context: prepared.context)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "today_action_materializer_unavailable")
        XCTAssertNil(result.metadata["expectedRevision"])
        XCTAssertNil(result.metadata["actualRevision"])
        XCTAssertNil(result.metadata["runtimeReceiptID"])
    }

    func testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("today-action-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Send the form", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let action = TodayInlineAction(
            kind: .complete,
            title: "Still counts",
            systemImage: "checkmark.circle.fill",
            state: .success,
            target: TodayActionTarget(goalID: created.goalID, stepID: created.stepID)
        )
        let existingFeedback = GoalFeedbackEvent.confused(
            base: GoalFeedbackEventBase(
                id: "existing-feedback",
                stepID: created.stepID,
                occurredAt: DomainTimestamp.string(from: fixedNow),
                note: "Preserve this history."
            ),
            confusionType: .unclearAction
        )
        try await repositories.feedback.saveEvents([existingFeedback], goalID: created.goalID)
        let prepared = try await service.prepareDurableGoalStepAction(action, now: fixedNow)
        let preparedPlan = try XCTUnwrap(TodayGoalStepActionPlan.decode(command: prepared.command))
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: repositories)
        )

        let first = await executor.execute(prepared.command, context: prepared.context)
        let duplicate = await executor.execute(prepared.command, context: prepared.context)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(preparedPlan.feedbackEvents.count, 1, "The semantic event must carry only this command's feedback delta.")
        XCTAssertEqual(first.metadata["todayActionMaterialization"], "saved_post_authority")
        XCTAssertEqual(first.metadata["runtimeProjectionStoreStatus"], "saved")
        XCTAssertTrue(first.metadata["runtimeProjectionCursorIDs"]?.split(separator: ",").contains("today") == true)
        XCTAssertFalse(first.metadata["runtimeProjectionCursorChecksums"]?.isEmpty ?? true)
        XCTAssertEqual(duplicate.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        let semanticEvents = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
        let steps = try await repositories.goals.listSteps(goalID: created.goalID)
        XCTAssertEqual(semanticEvents.count, 1)
        XCTAssertEqual(feedback.count, 2)
        XCTAssertTrue(feedback.contains { $0.base.id == existingFeedback.base.id })
        XCTAssertEqual(evidence.count, 1)
        XCTAssertEqual(steps.first?.state, .completed)
    }

    func testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites() async throws {
        for kind in [TodayActionKind.complete, .defer, .reschedule, .markNotRelevant, .split, .askForHelp, .quickLog] {
            let store = try AmbitionsPersistenceStore(inMemory: true)
            let repositories = makeRepositories(store: store)
            let created = try await SimpleStepLifecycleService(repositories: repositories)
                .createSimpleStep(title: "Handle \(kind.rawValue)", now: fixedNow)
            let service = RepositoryBackedTodayService(repositories: repositories)
            let action = makeAction(kind, goalID: created.goalID, stepID: created.stepID)
            let beforeSteps = try await repositories.goals.listSteps(goalID: created.goalID)

            let first = try await service.prepareDurableGoalStepAction(action, now: fixedNow)
            let second = try await service.prepareDurableGoalStepAction(action, now: fixedNow)
            let afterSteps = try await repositories.goals.listSteps(goalID: created.goalID)
            let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
            let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)
            let captures = try await repositories.captures.listCaptures()

            XCTAssertEqual(first.command.id, second.command.id)
            XCTAssertEqual(first.command.typedPayload, second.command.typedPayload)
            XCTAssertEqual(afterSteps, beforeSteps)
            XCTAssertTrue(feedback.isEmpty)
            XCTAssertTrue(evidence.isEmpty)
            XCTAssertTrue(captures.isEmpty)
        }
    }

    func testEveryHandledKindReopensAndReplaysExactAuthorityOnce() async throws {
        for kind in [TodayActionKind.complete, .defer, .reschedule, .markNotRelevant, .split, .askForHelp, .quickLog] {
            let root = FileManager.default.temporaryDirectory
                .appendingPathComponent("today-action-restart-\(kind.rawValue)-\(UUID().uuidString)")
            defer { try? FileManager.default.removeItem(at: root) }
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            let sourceStore = try AmbitionsPersistenceStore(inMemory: true)
            let source = makeRepositories(store: sourceStore)
            let created = try await SimpleStepLifecycleService(repositories: source)
                .createSimpleStep(title: "Restart \(kind.rawValue)", now: fixedNow)
            let prepared = try await RepositoryBackedTodayService(repositories: source)
                .prepareDurableGoalStepAction(
                    makeAction(kind, goalID: created.goalID, stepID: created.stepID),
                    now: fixedNow
                )
            let eventURL = root.appendingPathComponent("EventStore.sqlite")
            let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
            let first = await AmbitionsCommandExecutor.test(
                runtimeEvents: EventStoreSQLite(databaseURL: eventURL),
                projectionStore: ProjectionStoreSQLite(databaseURL: projectionURL),
                todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: source)
            ).execute(prepared.command, context: prepared.context)

            let cleanStore = try AmbitionsPersistenceStore(inMemory: true)
            let clean = makeRepositories(store: cleanStore)
            let replay = await AmbitionsCommandExecutor.test(
                runtimeEvents: EventStoreSQLite(databaseURL: eventURL),
                projectionStore: ProjectionStoreSQLite(databaseURL: projectionURL),
                todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: clean)
            ).execute(prepared.command, context: prepared.context)
            let events = try await EventStoreSQLite(databaseURL: eventURL)
                .fetchEvents(matching: .kind(.domainMutation), limit: nil)
            let feedback = try await clean.feedback.listEvents(goalID: created.goalID)
            let evidence = try await clean.evidence.listEvidence(goalID: created.goalID)
            let captures = try await clean.captures.listCaptures()
            let step = try await clean.goals.listSteps(goalID: created.goalID).first

            XCTAssertEqual(first.status, .succeeded, kind.rawValue)
            XCTAssertEqual(replay.status, .succeeded, kind.rawValue)
            XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"], kind.rawValue)
            XCTAssertEqual(
                replay.metadata["runtimeProjectionCursorChecksums"],
                first.metadata["runtimeProjectionCursorChecksums"],
                kind.rawValue
            )
            XCTAssertEqual(events.count, 1, kind.rawValue)
            let expectedFeedbackCount: Int = switch kind {
            case .reschedule, .split: 2
            case .askForHelp: 3
            default: 1
            }
            XCTAssertEqual(feedback.count, kind == .quickLog ? 0 : expectedFeedbackCount, kind.rawValue)
            XCTAssertEqual(evidence.count, [.complete, .quickLog].contains(kind) ? 1 : 0, kind.rawValue)
            XCTAssertEqual(captures.count, kind == .quickLog ? 1 : 0, kind.rawValue)
            if kind == .quickLog {
                XCTAssertNil(step, "A no-Goal-write replay must not synthesize a Goal from its stale snapshot.")
            } else {
                XCTAssertEqual(
                    step?.state,
                    kind == .complete ? .completed : (kind == .markNotRelevant ? .cancelled : .planned),
                    kind.rawValue
                )
            }
        }
    }

    func testJournalFailureLeavesAllDerivedStoresUnchanged() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Do not mutate", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: repositories)
            .prepareDurableGoalStepAction(makeAction(.complete, goalID: created.goalID, stepID: created.stepID), now: fixedNow)

        let result = await AmbitionsCommandExecutor.test(
            commandJournal: TodayActionFailingCommandJournal(),
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: repositories)
        ).execute(prepared.command, context: prepared.context)
        let steps = try await repositories.goals.listSteps(goalID: created.goalID)
        let feedback = try await repositories.feedback.listEvents(goalID: created.goalID)
        let evidence = try await repositories.evidence.listEvidence(goalID: created.goalID)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        XCTAssertEqual(steps.first?.state, .planned)
        XCTAssertTrue(feedback.isEmpty)
        XCTAssertTrue(evidence.isEmpty)
    }

    @MainActor
    func testPostAuthorityMaterializationFailurePublishesWarningInsteadOfVisibleSuccess() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Do not show success", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let executor = AmbitionsCommandExecutor.test(
            todayActionMaterializer: TodayActionFailingMaterializer()
        )
        let runtimeClient = RuntimeCommandClient(
            execute: { command, context in await executor.execute(command, context: context) },
            projection: { request in throw RuntimeProjectionClientError.projectionUnavailable(request) }
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))

        await viewModel.handle(
            makeAction(.complete, goalID: created.goalID, stepID: created.stepID),
            using: service,
            runtimeClient: runtimeClient,
            userDisplayName: "",
            now: fixedNow,
            calendar: Calendar(identifier: .gregorian)
        )

        XCTAssertEqual(viewModel.transientMessage?.state, .warning)
        XCTAssertEqual(viewModel.transientMessage?.title, "Action could not finish")
        XCTAssertNotEqual(viewModel.transientMessage?.title, "Completion recorded")
    }

    @MainActor
    func testCommittedProjectionMismatchCannotPublishVisibleSuccess() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("today-projection-mismatch-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Verify projection", now: fixedNow)
        let service = RepositoryBackedTodayService(repositories: repositories)
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite")),
            projectionStore: projections,
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: repositories)
        )
        let runtimeClient = RuntimeCommandClient(
            execute: { command, context in await executor.execute(command, context: context) },
            projection: { _ in
                RuntimeProjectionSnapshot(
                    projectionID: ProjectionID.today.rawValue,
                    payload: Data(),
                    eventSequence: -1,
                    cursorChecksum: "stale-cursor",
                    payloadChecksum: "stale-payload",
                    materializedAt: "2027-02-20T00:00:00Z"
                )
            }
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))

        await viewModel.handle(
            makeAction(.complete, goalID: created.goalID, stepID: created.stepID),
            using: service,
            runtimeClient: runtimeClient,
            userDisplayName: "",
            now: fixedNow,
            calendar: Calendar(identifier: .gregorian)
        )

        XCTAssertEqual(viewModel.transientMessage?.state, .warning)
        XCTAssertEqual(viewModel.transientMessage?.title, "Action could not finish")
    }

    func testPostAuthorityFailureReturnsRecoveryAndReopenedStoreRepairsCleanRepositoriesOnce() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("today-repair-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let sourceStore = try AmbitionsPersistenceStore(inMemory: true)
        let source = makeRepositories(store: sourceStore)
        let created = try await SimpleStepLifecycleService(repositories: source)
            .createSimpleStep(title: "Repair me", now: fixedNow)
        let prepared = try await RepositoryBackedTodayService(repositories: source)
            .prepareDurableGoalStepAction(makeAction(.complete, goalID: created.goalID, stepID: created.stepID), now: fixedNow)
        let eventURL = root.appendingPathComponent("EventStore.sqlite")
        let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
        let first = await AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: eventURL),
            projectionStore: ProjectionStoreSQLite(databaseURL: projectionURL),
            todayActionMaterializer: TodayActionFailingMaterializer()
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(first.metadata["todayActionMaterialization"], "needs_recovery")
        XCTAssertNotNil(first.metadata["runtimeReceiptID"])

        let cleanStore = try AmbitionsPersistenceStore(inMemory: true)
        let clean = makeRepositories(store: cleanStore)
        let replay = await AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: eventURL),
            projectionStore: ProjectionStoreSQLite(databaseURL: projectionURL),
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: clean)
        ).execute(prepared.command, context: prepared.context)
        let duplicateReplay = await AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: eventURL),
            projectionStore: ProjectionStoreSQLite(databaseURL: projectionURL),
            todayActionMaterializer: RepositoryTodayGoalStepActionMaterializer(repositories: clean)
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        XCTAssertEqual(replay.metadata["todayActionMaterialization"], "saved_post_authority")
        XCTAssertEqual(duplicateReplay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        let replayedSteps = try await clean.goals.listSteps(goalID: created.goalID)
        let replayedFeedback = try await clean.feedback.listEvents(goalID: created.goalID)
        let replayedEvidence = try await clean.evidence.listEvidence(goalID: created.goalID)
        XCTAssertEqual(replayedSteps.first?.state, .completed)
        XCTAssertEqual(replayedFeedback.count, 1)
        XCTAssertEqual(replayedEvidence.count, 1)
        let semanticEvents = try await EventStoreSQLite(databaseURL: eventURL).fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(semanticEvents.count, 1)
    }

    private var fixedNow: Date { Date(timeIntervalSince1970: 1_777_113_600) }

    private func makeAction(
        _ kind: TodayActionKind,
        goalID: String,
        stepID: String,
        operationID: String = "today-test-invocation"
    ) -> TodayInlineAction {
        TodayInlineAction(
            operationID: operationID,
            kind: kind,
            title: kind.rawValue,
            systemImage: "circle",
            state: .selected,
            target: TodayActionTarget(goalID: goalID, stepID: stepID)
        )
    }

    private func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
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
}

private struct TodayActionFailingMaterializer: TodayGoalStepActionMaterializing {
    struct Failure: Error {}
    func materialize(_ plan: TodayGoalStepActionPlan) async throws { throw Failure() }
}

private struct TodayActionFailingCommandJournal: CommandJournal {
    struct Failure: Error {}
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt { throw Failure() }
    func linkRuntimeCommit(commandID: String, runtimeEventID: String, runtimeReceiptID: String, linkedAt: String) async throws -> CommandJournalRuntimeLinkReceipt { throw Failure() }
    func fetchEntries(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandJournalEntry] { [] }
    func fetchEnvelopes(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandEnvelope] { [] }
}
