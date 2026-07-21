import XCTest
@testable import Ambitions

final class CaptureGoalHandoffOwnerWriteTests: XCTestCase {
    func testSeedPreparationIsDeterministicAndDoesNotWriteBeforeAuthority() async throws {
        let fixture = try await makeFixture(status: .seed)
        let request = CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: fixture.goal.id)
        let before = try await fixture.repositories.captures.capture(id: fixture.capture.id)

        let first = try await CaptureGoalHandoffPlanner(repositories: fixture.repositories).prepare(request, now: fixedNow)
        let second = try await CaptureGoalHandoffPlanner(repositories: fixture.repositories).prepare(request, now: fixedNow)
        let plan = try XCTUnwrap(CaptureGoalHandoffPlan.decode(command: first.command))

        XCTAssertEqual(first.command.id, second.command.id)
        XCTAssertEqual(plan.expectedCapture.status, .seed)
        XCTAssertEqual(plan.updatedCapture.status, .goalBound)
        XCTAssertEqual(plan.updatedCapture.linkedGoalID, fixture.goal.id)
        let after = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(after, before)
    }

    func testAuthoritySuccessAtomicallyConnectsSeedCaptureAndCreatedGoalIDs() async throws {
        let fixture = try await makeFixture(status: .seed)
        let prepared = try await prepare(fixture)
        let events = InMemoryRuntimeEventStore()
        _ = try await events.append(RuntimeEvent(
            commandID: "capture-created-before-handoff",
            actor: .user,
            source: .capture,
            occurredAt: fixture.capture.createdAt,
            payload: .domainMutation(try RuntimeDomainEventRecord(
                .captureCreated(CaptureCreatedDomainEvent(capture: fixture.capture))
            ))
        ))

        let result = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        ).execute(prepared.command, context: prepared.context)

        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.target?.captureID, fixture.capture.id)
        XCTAssertEqual(result.target?.goalID, fixture.goal.id)
        XCTAssertEqual(result.metadata["captureGoalHandoffMaterialization"], "saved_post_authority")
        XCTAssertEqual(capture?.status, .goalBound)
        XCTAssertEqual(capture?.linkedGoalID, fixture.goal.id)
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        guard case let .domainMutation(record) = try XCTUnwrap(authority.last).event.payload,
              case let .captureGoalHandoffApplied(plan) = try record.decodedEvent() else {
            return XCTFail("Expected capture-to-goal semantic authority event")
        }
        XCTAssertEqual(plan.captureID, fixture.capture.id)
        XCTAssertEqual(plan.goalID, fixture.goal.id)
        let reconstructed = try await RuntimeDomainEventReplay(store: events).reconstruct()
        XCTAssertEqual(reconstructed.captures.first?.capture, plan.updatedCapture)
    }

    func testInjectedMaterializerFailureRollsBackCaptureTransition() async throws {
        let fixture = try await makeFixture(status: .seed)
        let prepared = try await prepare(fixture)
        let plan = try XCTUnwrap(CaptureGoalHandoffPlan.decode(command: prepared.command))

        do {
            try await SwiftDataCaptureGoalHandoffMaterializer(
                store: fixture.store,
                failurePoint: .afterCaptureWrite
            ).materialize(plan)
            XCTFail("Expected transaction failure")
        } catch CaptureGoalHandoffStorageError.injectedFailure(.afterCaptureWrite) {}

        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        let goal = try await fixture.repositories.goals.goal(id: fixture.goal.id)
        XCTAssertEqual(capture, fixture.capture)
        XCTAssertEqual(goal, fixture.goal)
    }

    func testDuplicateExecutionAndRestartReplayApplyTransitionOnce() async throws {
        let fixture = try await makeFixture(status: .actionable)
        let prepared = try await prepare(fixture)
        let eventURL = temporaryURL("capture-goal-handoff-events.sqlite")
        let events = EventStoreSQLite(databaseURL: eventURL, deviceID: "handoff-first")
        let firstExecutor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        )

        let first = await firstExecutor.execute(prepared.command, context: prepared.context)
        let restartedEvents = EventStoreSQLite(databaseURL: eventURL, deviceID: "handoff-restarted")
        let replay = await AmbitionsCommandExecutor.test(
            runtimeEvents: restartedEvents,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        ).execute(prepared.command, context: prepared.context)
        let authority = try await restartedEvents.fetchEvents(matching: .kind(.domainMutation), limit: nil)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        XCTAssertEqual(authority.count, 1)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(capture?.linkedGoalID, fixture.goal.id)
    }

    func testStaleCaptureBlocksAuthorityAndLeavesConcurrentStateUntouched() async throws {
        let fixture = try await makeFixture(status: .actionable)
        let prepared = try await prepare(fixture)
        let concurrent = copy(fixture.capture, status: .waiting, updatedAt: "2026-04-20T12:01:00Z")
        try await fixture.repositories.captures.saveCaptures([concurrent])
        let events = InMemoryRuntimeEventStore()

        let result = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(result.status, .blocked)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(capture, concurrent)
        XCTAssertTrue(authority.isEmpty)
    }

    func testConcurrentGoalEditIsPreservedBecauseHandoffOwnsOnlyCaptureState() async throws {
        let fixture = try await makeFixture(status: .actionable)
        let prepared = try await prepare(fixture)
        let concurrentGoal = copy(fixture.goal, revision: fixture.goal.revision + 1, title: "Concurrent title")
        try await fixture.repositories.goals.saveGoals([concurrentGoal])

        let result = await AmbitionsCommandExecutor.test(
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        ).execute(prepared.command, context: prepared.context)

        XCTAssertEqual(result.status, .succeeded)
        let goal = try await fixture.repositories.goals.goal(id: fixture.goal.id)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(goal, concurrentGoal)
        XCTAssertEqual(capture?.linkedGoalID, fixture.goal.id)
    }

    func testBlockedCommandDoesNotPoisonCorrectedStateRetryIdentity() async throws {
        let fixture = try await makeFixture(status: .actionable)
        let stale = try await prepare(fixture)
        let corrected = copy(
            fixture.capture,
            status: .actionable,
            updatedAt: fixture.capture.updatedAt,
            rawText: "Corrected without changing the timestamp"
        )
        try await fixture.repositories.captures.saveCaptures([corrected])
        let events = InMemoryRuntimeEventStore()
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        )

        let blocked = await executor.execute(stale.command, context: stale.context)
        let retry = try await prepare(fixture)
        let succeeded = await executor.execute(retry.command, context: retry.context)

        XCTAssertEqual(blocked.status, .blocked)
        XCTAssertNotEqual(retry.command.id, stale.command.id)
        XCTAssertEqual(succeeded.status, .succeeded)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(capture?.linkedGoalID, fixture.goal.id)
    }

    func testFreshServiceRetryAfterRestartIsLogicalSuccessAndDifferentGoalCannotRebind() async throws {
        let fixture = try await makeFixture(status: .seed)
        let secondCreated = try await SimpleStepLifecycleService(repositories: fixture.repositories)
            .createSimpleStep(title: "Different goal", now: fixedNow.addingTimeInterval(5))
        let events = InMemoryRuntimeEventStore()
        let projections = ProjectionStoreSQLite(
            databaseURL: temporaryURL("handoff-retry-projections.sqlite")
        )
        let firstClient = runtimeClient(
            events: events,
            projections: projections,
            store: fixture.store
        )
        let request = CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: fixture.goal.id)

        let first = await CaptureGoalHandoffService(
            repositories: fixture.repositories,
            runtimeClient: firstClient
        ).perform(request, now: fixedNow)
        let restartedClient = runtimeClient(
            events: events,
            projections: projections,
            store: fixture.store
        )
        let replay = await CaptureGoalHandoffService(
            repositories: fixture.repositories,
            runtimeClient: restartedClient
        ).perform(request, now: fixedNow.addingTimeInterval(30))
        let rebind = await CaptureGoalHandoffService(
            repositories: fixture.repositories,
            runtimeClient: restartedClient
        ).perform(
            CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: secondCreated.goalID),
            now: fixedNow.addingTimeInterval(60)
        )
        let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)

        XCTAssertTrue(first.isAttached)
        XCTAssertEqual(
            replay,
            .alreadyAttached(captureID: fixture.capture.id, goalID: fixture.goal.id)
        )
        XCTAssertFalse(rebind.isAttached)
        XCTAssertEqual(authority.count, 1)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(capture?.linkedGoalID, fixture.goal.id)
    }

    func testMissingOrRecreatedGoalBlocksInitialCommitBeforeIdempotentCaptureReturn() async throws {
        for recreate in [false, true] {
            let fixture = try await makeFixture(status: .actionable)
            let prepared = try await prepare(fixture)
            try await fixture.repositories.goals.deleteGoal(id: fixture.goal.id)
            if recreate {
                try await fixture.repositories.goals.saveGoals([
                    copy(fixture.goal, createdAt: "2026-04-20T12:09:00Z")
                ])
            }
            let events = InMemoryRuntimeEventStore()

            let result = await AmbitionsCommandExecutor.test(
                runtimeEvents: events,
                captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
            ).execute(prepared.command, context: prepared.context)

            XCTAssertEqual(result.status, .blocked)
            let authority = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
            XCTAssertTrue(authority.isEmpty)
            let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
            XCTAssertEqual(capture, fixture.capture)
        }
    }

    @MainActor
    func testPreviewContainerExecutesEndToEndWithRealProjectionAndMaterializer() async throws {
        let container = PreviewAppContainerFactory.preview
        let repositories = container.runtime.repositories
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Preview handoff", now: fixedNow)
        let loadedGoal = try await repositories.goals.goal(id: created.goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let capture = Capture(
            id: "preview-container-handoff",
            createdAt: DomainTimestamp.string(from: fixedNow),
            updatedAt: DomainTimestamp.string(from: fixedNow),
            rawText: "Preview capture",
            sourceType: .shellComposer,
            status: .seed,
            linkedGoalID: nil
        )
        try await repositories.captures.saveCaptures([capture])

        let outcome = await container.runtimeCapability.captureGoalHandoffCommands.perform(
            CaptureGoalHandoffRequest(captureID: capture.id, goalID: goal.id),
            now: fixedNow.addingTimeInterval(1)
        )
        let saved = try await repositories.captures.capture(id: capture.id)
        let projection = try await repositories.projectionStore?.fetchRecord(id: .goals)

        XCTAssertTrue(outcome.isAttached)
        XCTAssertEqual(saved?.linkedGoalID, goal.id)
        XCTAssertNotNil(projection)
    }

    func testJournalFailureAndTypedOutcomePreventFalseStageSuccess() async throws {
        let fixture = try await makeFixture(status: .seed)
        let prepared = try await prepare(fixture)
        let result = await AmbitionsCommandExecutor.test(
            commandJournal: FailingCaptureGoalHandoffJournal(),
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: fixture.store)
        ).execute(prepared.command, context: prepared.context)
        let falseSuccessClient = RuntimeCommandClient(
            execute: { command, _ in
                AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Authority committed but projection failed",
                    route: .goals,
                    target: command.target,
                    metadata: [
                        "runtimeReceiptID": "receipt-1",
                        "runtimeProjectionStoreStatus": "saved",
                        "runtimeMaterializedProjectionCursorIDs": ProjectionID.goals.rawValue,
                        "runtimeMaterializedProjectionCursorSequences": "9",
                        "runtimeMaterializedProjectionCursorChecksums": "authority-goals",
                        "captureGoalHandoffMaterialization": "saved_post_authority"
                    ]
                )
            },
            projection: { _ in
                RuntimeProjectionSnapshot(
                    projectionID: ProjectionID.goals.rawValue,
                    payload: Data(),
                    eventSequence: 9,
                    cursorChecksum: "stale-goals",
                    payloadChecksum: "payload",
                    materializedAt: "2026-04-20T12:00:00Z"
                )
            }
        )
        let outcome = await CaptureGoalHandoffService(
            repositories: fixture.repositories,
            runtimeClient: falseSuccessClient
        ).perform(
            CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: fixture.goal.id),
            now: fixedNow
        )
        let materializedClient = RuntimeCommandClient(
            execute: { command, _ in
                AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Committed and materialized",
                    route: .goals,
                    target: command.target,
                    metadata: [
                        "runtimeReceiptID": "receipt-2",
                        "runtimeProjectionStoreStatus": "saved",
                        "runtimeMaterializedProjectionCursorIDs": ProjectionID.goals.rawValue,
                        "runtimeMaterializedProjectionCursorSequences": "10",
                        "runtimeMaterializedProjectionCursorChecksums": "matching-goals",
                        "captureGoalHandoffMaterialization": "saved_post_authority"
                    ]
                )
            },
            projection: { _ in
                RuntimeProjectionSnapshot(
                    projectionID: ProjectionID.goals.rawValue,
                    payload: Data(),
                    eventSequence: 10,
                    cursorChecksum: "matching-goals",
                    payloadChecksum: "payload",
                    materializedAt: "2026-04-20T12:00:01Z"
                )
            }
        )
        let confirmed = await CaptureGoalHandoffService(
            repositories: fixture.repositories,
            runtimeClient: materializedClient
        ).perform(
            CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: fixture.goal.id),
            now: fixedNow
        )

        XCTAssertNotEqual(result.status, .succeeded)
        let capture = try await fixture.repositories.captures.capture(id: fixture.capture.id)
        XCTAssertEqual(capture, fixture.capture)
        XCTAssertFalse(outcome.isAttached)
        XCTAssertTrue(confirmed.isAttached)
    }

    private var fixedNow: Date { Date(timeIntervalSince1970: 1_777_113_600) }

    private struct Fixture {
        let store: AmbitionsPersistenceStore
        let repositories: AppRepositories
        let goal: Goal
        let capture: Capture
    }

    private func makeFixture(status: CaptureStatus) async throws -> Fixture {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store)
        let created = try await SimpleStepLifecycleService(repositories: repositories)
            .createSimpleStep(title: "Created goal", now: fixedNow)
        let loadedGoal = try await repositories.goals.goal(id: created.goalID)
        let goal = try XCTUnwrap(loadedGoal)
        let timestamp = DomainTimestamp.string(from: fixedNow.addingTimeInterval(-60))
        let capture = Capture(
            id: "capture-stage-handoff",
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: "Turn this capture into useful goal context",
            sourceType: .shellComposer,
            status: status,
            linkedGoalID: nil,
            triage: CaptureTriageMetadata(destination: .turnIntoGoal),
            kind: .raw,
            route: .captureInbox,
            triageStatus: .needsTriage
        )
        try await repositories.captures.saveCaptures([capture])
        return Fixture(store: store, repositories: repositories, goal: goal, capture: capture)
    }

    private func prepare(_ fixture: Fixture) async throws -> PreparedCaptureGoalHandoff {
        try await CaptureGoalHandoffPlanner(repositories: fixture.repositories).prepare(
            CaptureGoalHandoffRequest(captureID: fixture.capture.id, goalID: fixture.goal.id),
            now: fixedNow
        )
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

    private func copy(
        _ capture: Capture,
        status: CaptureStatus,
        updatedAt: String,
        rawText: String? = nil
    ) -> Capture {
        Capture(
            id: capture.id, createdAt: capture.createdAt, updatedAt: updatedAt,
            rawText: rawText ?? capture.rawText,
            sourceType: capture.sourceType, status: status, linkedGoalID: capture.linkedGoalID,
            triage: capture.triage, revisitAfter: capture.revisitAfter, kind: capture.kind, route: capture.route,
            triageStatus: capture.triageStatus, commitmentKind: capture.commitmentKind,
            deadlineText: capture.deadlineText, deadlineKind: capture.deadlineKind,
            contextLensHint: capture.contextLensHint, priorityHints: capture.priorityHints,
            goalRelationship: capture.goalRelationship, deliverableHint: capture.deliverableHint,
            scopeItemHint: capture.scopeItemHint, waitingMetadata: capture.waitingMetadata,
            assumptionSummary: capture.assumptionSummary, correctionActions: capture.correctionActions,
            recommendationExplanationIDs: capture.recommendationExplanationIDs,
            localOnly: capture.localOnly, privacy: capture.privacy
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

    private func copy(_ goal: Goal, createdAt: String) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision,
            createdAt: createdAt, updatedAt: goal.updatedAt, state: goal.state, title: goal.title,
            summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: goal.plan, lifeGraph: goal.lifeGraph
        )
    }

    private func runtimeClient(
        events: any RuntimeEventStore,
        projections: ProjectionStoreSQLite,
        store: AmbitionsPersistenceStore
    ) -> RuntimeCommandClient {
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            captureGoalHandoffMaterializer: SwiftDataCaptureGoalHandoffMaterializer(store: store)
        )
        return RuntimeCommandClient(
            execute: { command, context in await executor.execute(command, context: context) },
            projection: { request in
                guard let record = try await projections.fetchRecord(id: request.projectionID) else {
                    throw RuntimeProjectionClientError.projectionUnavailable(request)
                }
                return RuntimeProjectionSnapshot(
                    projectionID: record.id.rawValue,
                    payload: record.payloadData,
                    eventSequence: record.cursor.sequence,
                    cursorChecksum: record.cursor.checksum,
                    payloadChecksum: record.payloadChecksum,
                    materializedAt: record.materializedAt
                )
            }
        )
    }

    private func temporaryURL(_ name: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("capture-goal-handoff-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent(name, isDirectory: false)
    }
}

private struct FailingCaptureGoalHandoffJournal: CommandJournal {
    struct Failure: Error {}

    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt { throw Failure() }
    func linkRuntimeCommit(
        commandID: String,
        runtimeEventID: String,
        runtimeReceiptID: String,
        linkedAt: String
    ) async throws -> CommandJournalRuntimeLinkReceipt { throw Failure() }
    func fetchEntries(
        matching query: CommandJournalQuery,
        limit: Int?
    ) async throws -> [CommandJournalEntry] { [] }
    func fetchEnvelopes(
        matching query: CommandJournalQuery,
        limit: Int?
    ) async throws -> [CommandEnvelope] { [] }
}
