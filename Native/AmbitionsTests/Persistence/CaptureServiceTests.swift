import XCTest
@testable import Ambitions

final class CaptureServiceTests: XCTestCase {
    func testCaptureSourceTypeMatrixMatchesBatch01SurfaceSet() {
        XCTAssertEqual(
            CaptureSourceType.allCases.map(\.rawValue),
            [
                "today_quick_capture",
                "notification",
                "share_extension_text",
                "share_extension_url",
                "app_intent"
            ]
        )
        XCTAssertEqual(CaptureSourceType.todayQuickCapture.title, "Today quick capture")
        XCTAssertEqual(CaptureSourceType.notification.title, "Notification")
        XCTAssertEqual(CaptureSourceType.shareExtensionText.title, "Share extension text")
        XCTAssertEqual(CaptureSourceType.shareExtensionURL.title, "Share extension URL")
        XCTAssertEqual(CaptureSourceType.appIntent.title, "App Intent")
    }

    func testCreateCaptureTrimsTextAndDefaultsToActionable() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(
            repository: repository,
            idProvider: { "capture-1" }
        )
        let now = Date(timeIntervalSince1970: 1_712_692_800)

        let created = try await service.createCapture(
            CreateCaptureRequest(
                rawText: "  Capture this idea  ",
                sourceType: .todayQuickCapture,
                triage: CaptureTriageMetadata(destination: .doSoon),
                revisitAfter: "2026-04-22T09:00:00Z"
            ),
            now: now
        )
        let all = try await service.listCaptures()

        XCTAssertEqual(created.id, "capture-1")
        XCTAssertEqual(created.rawText, "Capture this idea")
        XCTAssertEqual(created.status, .actionable)
        XCTAssertEqual(created.sourceType, .todayQuickCapture)
        XCTAssertNil(created.linkedGoalID)
        XCTAssertEqual(created.triage?.destination, .doSoon)
        XCTAssertEqual(created.revisitAfter, "2026-04-22T09:00:00Z")
        XCTAssertEqual(all.count, 1)
    }

    func testCreateCaptureWithLinkedGoalStillDefaultsToActionable() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture-linked" })

        let created = try await service.createCapture(
            CreateCaptureRequest(rawText: "Quick log for a goal", sourceType: .todayQuickCapture, linkedGoalID: "goal-123"),
            now: fixedNow
        )

        XCTAssertEqual(created.status, .actionable)
        XCTAssertEqual(created.linkedGoalID, "goal-123")
    }

    func testCanonicalCaptureTransitionsAreAllowedAndRejected() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture-2" })
        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Save this for later"), now: fixedNow)

        let seed = try await service.updateCaptureState(
            CaptureStateUpdateRequest(
                id: "capture-2",
                status: .seed,
                triage: CaptureTriageMetadata(destination: .saveAsSeed)
            ),
            now: fixedNow.addingTimeInterval(60)
        )
        let actionable = try await service.updateCaptureState(
            CaptureStateUpdateRequest(id: "capture-2", status: .actionable),
            now: fixedNow.addingTimeInterval(120)
        )
        let archived = try await service.updateCaptureState(
            CaptureStateUpdateRequest(id: "capture-2", status: .archived),
            now: fixedNow.addingTimeInterval(180)
        )

        XCTAssertEqual(seed?.status, .seed)
        XCTAssertEqual(seed?.triage?.destination, .saveAsSeed)
        XCTAssertEqual(actionable?.status, .actionable)
        XCTAssertEqual(archived?.status, .archived)

        await XCTAssertThrowsErrorAsync(
            try await service.updateCaptureState(
                CaptureStateUpdateRequest(id: "capture-2", status: .seed),
                now: fixedNow.addingTimeInterval(240)
            )
        ) { error in
            XCTAssertTrue(error.localizedDescription.contains("Archived"))
            XCTAssertTrue(error.localizedDescription.contains("Seed"))
        }
    }

    func testMarkCaptureArchivedUsesCanonicalArchiveState() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture-archive" })

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Archive this"), now: fixedNow)
        let archived = try await service.markCaptureArchived(id: "capture-archive", now: fixedNow.addingTimeInterval(300))

        XCTAssertEqual(archived?.status, .archived)
    }

    func testAttachCaptureToGoalValidatesExistingGoal() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goal = try XCTUnwrap(goalFromFixture(id: "clear-timed-self-goal"))
        try await repositories.goals.saveGoals([goal])
        let service = DefaultCaptureService(
            repository: repositories.captures,
            goalRepository: repositories.goals,
            idProvider: { "capture-attach" }
        )

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Attach this to the existing goal"), now: fixedNow)
        let binding = try await service.attachCaptureToGoal(
            AttachCaptureToGoalRequest(captureID: "capture-attach", goalID: goal.id),
            now: fixedNow.addingTimeInterval(60)
        )

        XCTAssertEqual(binding?.capture.status, .goalBound)
        XCTAssertEqual(binding?.capture.linkedGoalID, goal.id)
        XCTAssertEqual(binding?.target.goalID, goal.id)
    }

    func testAttachCaptureToMissingGoalFailsCleanly() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let service = DefaultCaptureService(
            repository: repositories.captures,
            goalRepository: repositories.goals,
            idProvider: { "capture-missing-goal" }
        )

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Attach this nowhere"), now: fixedNow)

        await XCTAssertThrowsErrorAsync(
            try await service.attachCaptureToGoal(
                AttachCaptureToGoalRequest(captureID: "capture-missing-goal", goalID: "missing-goal"),
                now: fixedNow
            )
        ) { error in
            XCTAssertEqual((error as? CaptureServiceError)?.errorDescription, "The selected goal could not be found.")
        }
    }

    func testTurnCaptureIntoGoalUsesExistingGoalCreationService() async throws {
        let repository = PreviewCaptureRepository()
        let goalsService = RecordingGoalsService()
        let service = DefaultCaptureService(
            repository: repository,
            goalsService: goalsService,
            idProvider: { "capture-goal" }
        )

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "  Learn SwiftUI layout  "), now: fixedNow)
        let binding = try await service.turnCaptureIntoGoal(
            TurnCaptureIntoGoalRequest(captureID: "capture-goal", mode: .learning),
            now: fixedNow.addingTimeInterval(60)
        )
        let recordedRequest = await goalsService.recordedCreateRequest

        XCTAssertEqual(recordedRequest?.title, "Learn SwiftUI layout")
        XCTAssertEqual(recordedRequest?.mode, .learning)
        XCTAssertEqual(binding?.capture.status, .goalBound)
        XCTAssertEqual(binding?.capture.linkedGoalID, "goal-created")
        XCTAssertEqual(binding?.target.goalID, "goal-created")
        XCTAssertEqual(binding?.target.draftID, "draft-created")
    }

    func testCreateCaptureRejectsWhitespaceOnlyText() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture-3" })

        await XCTAssertThrowsErrorAsync(
            try await service.createCapture(CreateCaptureRequest(rawText: "   "), now: .now)
        ) { error in
            XCTAssertEqual((error as? CaptureServiceError)?.errorDescription, "Capture text cannot be empty.")
        }
    }

    func testCreateCaptureSupportsAllStableCaptureSourceTypes() async throws {
        let repository = PreviewCaptureRepository()
        let sources = CaptureSourceType.allCases

        for source in sources {
            let service = DefaultCaptureService(repository: repository, idProvider: { "capture-\(source.rawValue)" })
            let created = try await service.createCapture(
                CreateCaptureRequest(rawText: "Source \(source.rawValue)", sourceType: source),
                now: fixedNow
            )
            XCTAssertEqual(created.sourceType, source)
        }

        let storedSources = try await repository.listCaptures()
            .compactMap(\.sourceType)
            .map(\.rawValue)
            .sorted()
        XCTAssertEqual(storedSources, sources.map(\.rawValue).sorted())
    }
}

private extension CaptureServiceTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
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
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case let .starterPlanned(result):
            return Goal(schemaVersion: goalEngineSchemaVersion, id: result.plan.goalID, revision: 1, createdAt: GoalEngineFixtures.fixedNow, updatedAt: GoalEngineFixtures.fixedNow, state: .active, title: result.draft.title, summary: result.draft.summary, mode: result.draft.mode, relationshipKind: result.draft.relationshipKind, actor: result.draft.actor, parentGoalID: result.draft.parentGoalID, childGoalIDs: [], supportGoalIDs: [], tags: result.draft.tags, timing: result.draft.timing, planningStrategy: result.draft.planningStrategy, progressStrategy: result.draft.progressStrategy, plan: result.plan)
        case .clarificationRequired, .blocked:
            return nil
        }
    }

    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ errorHandler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown.")
        } catch {
            errorHandler(error)
        }
    }
}

private actor RecordingGoalsService: GoalsServicing {
    private(set) var recordedCreateRequest: CreateGoalRequest?

    func loadOverview() async throws -> GoalsOverview {
        fatalError("Not needed for CaptureServiceTests")
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for CaptureServiceTests")
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = now
        recordedCreateRequest = request
        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-created", draftID: "draft-created"),
            blueprint: GoalBlueprint(title: request.title, mode: request.mode ?? .project)
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CaptureServiceTests")
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CaptureServiceTests")
    }
}
