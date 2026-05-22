import XCTest
@testable import Ambitions

final class AmbitionsRuntimeBoundaryTests: XCTestCase {
    func testClientContextDefaultsToIPhoneAppOnly() {
        let context = AmbitionsRuntimeClientContext.iphoneApp

        XCTAssertEqual(context.kind, .iphoneApp)
        XCTAssertEqual(context.displayName, "iPhone app")
        XCTAssertFalse(context.isConstrainedPrototype)
    }

    func testBedsideRitualCompanionContextIsExplicitlyConstrained() {
        let context = AmbitionsRuntimeClientContext.bedsideRitualCompanion

        XCTAssertEqual(context.kind, .bedsideRitualCompanion)
        XCTAssertEqual(context.displayName, "Bedside ritual companion")
        XCTAssertTrue(context.isConstrainedPrototype)
    }

    func testRuntimeMemoryLoadsFromExistingRepositories() async throws {
        let repositories = try makeRepositories()
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        let capture = Capture(
            id: "capture-runtime",
            createdAt: GoalEngineFixtures.fixedNow,
            updatedAt: GoalEngineFixtures.fixedNow,
            rawText: "Remember this from the runtime boundary",
            sourceType: .todayQuickCapture,
            status: .seed,
            linkedGoalID: nil
        )

        try await repositories.goals.saveGoals([goal])
        try await repositories.captures.saveCaptures([capture])

        let memory = try await RepositoryBackedRuntimeMemoryService(repositories: repositories).loadMemory()

        XCTAssertEqual(memory.goals.map(\.id), [goal.id])
        XCTAssertEqual(memory.captures.map(\.id), ["capture-runtime"])
        XCTAssertEqual(memory.appState.id, AppStateSnapshot.default.id)
    }

    func testRuntimeContextUsesExistingSyncAndExternalSnapshotTruth() async throws {
        let repositories = try makeRepositories()
        let expectedSnapshot = ExternalSurfaceSnapshot(generatedAt: "2026-04-19T12:00:00Z", nextAction: nil)
        let knowledgeProvider = StaticKnowledgeProvider(
            descriptor: KnowledgeProviderDescriptor(id: "local-only", type: .systemFallback, displayName: "Local-only fallback"),
            statusValue: KnowledgeProviderStatus(
                provider: KnowledgeProviderDescriptor(id: "local-only", type: .systemFallback, displayName: "Local-only fallback"),
                availability: .localOnlyMode,
                detail: "Knowledge retrieval is unavailable while Ambitions remains local-only.",
                runtimeTrustPosture: .localOnly
            )
        )
        let contextService = RepositoryBackedRuntimeContextService(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            memoryService: RepositoryBackedRuntimeMemoryService(repositories: repositories),
            syncCapability: LocalOnlySyncCapability(),
            externalSnapshotReader: StaticRuntimeSnapshotReader(snapshot: expectedSnapshot),
            knowledgeProvider: knowledgeProvider
        )

        let context = try await contextService.loadContext(now: Date(timeIntervalSince1970: 1_776_600_000))
        let expectedKnowledgeStatus = await knowledgeProvider.status(now: Date(timeIntervalSince1970: 1_776_600_000))

        XCTAssertEqual(context.clientContext.kind, .iphoneApp)
        XCTAssertEqual(context.capabilities.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertTrue(context.capabilities.privateLifeRuntimeBoundary.isLocalOnly)
        XCTAssertEqual(context.capabilities.syncBackendKind, .localOnly)
        XCTAssertFalse(context.capabilities.hasRemoteIntelligenceBackend)
        XCTAssertEqual(context.syncStatus.detail, "Ambitions is running in explicit local-only mode.")
        XCTAssertEqual(context.externalSurfaceSnapshot, expectedSnapshot)
        XCTAssertEqual(context.knowledgeProviderStatuses, [expectedKnowledgeStatus])
        XCTAssertEqual(context.memorySummary.goalCount, 0)
        XCTAssertEqual(context.memorySummary.captureCount, 0)
    }

    @MainActor
    func testRuntimeActionExecutorOwnsCommandSemanticsWithoutDispatchingAppRoutes() async {
        let today = RecordingRuntimeTodayService()
        let executor = DefaultRuntimeActionCommandExecutor(todayService: today)

        let complete = await executor.execute(
            ExternalActionCommand(
                kind: .complete,
                target: ExternalActionTarget(goalID: "goal-1", stepID: "step-1"),
                source: .notification
            ),
            now: .now
        )
        let openGoal = await executor.execute(
            ExternalActionCommand(
                kind: .openGoal,
                target: ExternalActionTarget(goalID: "goal-1"),
                source: .widget
            ),
            now: .now
        )

        XCTAssertEqual(complete.outcome, .performed)
        XCTAssertNil(complete.routeRequest)
        XCTAssertEqual(today.performedActions.map(\.kind), [.complete])
        XCTAssertEqual(openGoal.outcome, .routed)
        XCTAssertEqual(openGoal.routeRequest, .openGoalDetail(goalID: "goal-1"))
    }

    @MainActor
    func testRuntimeFactoryComposesExistingServicesForIPhoneCompatibilityFacade() async throws {
        let repositories = try makeRepositories()
        let runtime = AmbitionsRuntimeFactory.make(
            repositories: repositories,
            clientContext: .iphoneApp,
            notificationService: StubNotificationService(),
            calendarRemindersService: StubCalendarRemindersService(),
            externalSnapshotReader: StaticRuntimeSnapshotReader(snapshot: nil)
        )

        XCTAssertEqual(runtime.clientContext.kind, .iphoneApp)
        XCTAssertEqual(runtime.capabilities.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertTrue(runtime.capabilities.privateLifeRuntimeBoundary.isLocalOnly)
        XCTAssertEqual(runtime.capabilities.syncBackendKind, .localOnly)
        XCTAssertEqual(runtime.privateLifeRuntimeKernel.boundary, .localOnly)
        XCTAssertTrue(runtime.privateLifeRuntimeKernel.boundary.isLocalOnly)
        XCTAssertNotNil(runtime.todayService as? NotificationSchedulingTodayService)
        XCTAssertNotNil(runtime.goalsService as? NotificationSchedulingGoalsService)
        XCTAssertNotNil(runtime.goalIntelligenceService as? RepositoryBackedRuntimeGoalIntelligenceService)
        XCTAssertTrue(runtime.captureService is DefaultCaptureService)
        let knowledgeStatus = await runtime.knowledgeProvider.status(now: .now)
        XCTAssertEqual(knowledgeStatus.availability, .localOnlyMode)
        _ = runtime.dedicatedDevicePrototypeRuntime
    }
}

private extension AmbitionsRuntimeBoundaryTests {
    func makeRepositories() throws -> AppRepositories {
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

    func goalFromFixture(id: String) -> Goal? {
        guard let fixture = GoalEngineFixtures.fixture(id: id) else {
            return nil
        }

        switch fixture.result {
        case let .planned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan,
                lifeGraph: result.draft.lifeGraph
            )
        case let .starterPlanned(result):
            return Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: result.plan.goalID,
                revision: 1,
                createdAt: GoalEngineFixtures.fixedNow,
                updatedAt: GoalEngineFixtures.fixedNow,
                state: .active,
                title: result.draft.title,
                summary: result.draft.summary,
                mode: result.draft.mode,
                relationshipKind: result.draft.relationshipKind,
                actor: result.draft.actor,
                parentGoalID: result.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: result.draft.tags,
                timing: result.draft.timing,
                planningStrategy: result.draft.planningStrategy,
                progressStrategy: result.draft.progressStrategy,
                plan: result.plan,
                lifeGraph: result.draft.lifeGraph
            )
        case .clarificationRequired, .blocked:
            return nil
        }
    }
}

private struct StaticRuntimeSnapshotReader: RuntimeExternalSurfaceSnapshotReading {
    let snapshot: ExternalSurfaceSnapshot?

    func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
        snapshot
    }
}

private struct StaticKnowledgeProvider: KnowledgeProviding {
    let descriptor: KnowledgeProviderDescriptor
    let statusValue: KnowledgeProviderStatus

    func status(now: Date) async -> KnowledgeProviderStatus {
        _ = now
        return statusValue
    }

    func fetch(query: KnowledgeQuery, now: Date) async throws -> KnowledgeProviderResponse {
        _ = query
        _ = now
        return KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: statusValue.detail),
            providerStatuses: [statusValue]
        )
    }
}

@MainActor
private final class RecordingRuntimeTodayService: TodayServicing {
    private(set) var performedActions: [TodayInlineAction] = []

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return PreviewTodayScenarios.empty
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = now
        performedActions.append(action)
        return TodayActionResponse(message: TodayInlineMessage(title: "Recorded", body: "Runtime command recorded.", state: .success))
    }
}
