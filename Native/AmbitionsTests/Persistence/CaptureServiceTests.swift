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

    func testCapture2TaxonomyCoversCoreShapesAndRoutes() {
        XCTAssertEqual(
            CaptureKind.allCases.map(\.rawValue),
            [
                "raw",
                "one_time_commitment",
                "deadline_task",
                "goal_seed",
                "goal_supporting_task",
                "deliverable_seed",
                "waiting_item",
                "optional_someday",
                "archive_item"
            ]
        )
        XCTAssertEqual(
            CaptureRoute.allCases.map(\.rawValue),
            [
                "capture_inbox",
                "time_seed",
                "goal_seed",
                "goal_attachment",
                "deliverable_seed",
                "proof_item",
                "constraint_item",
                "waiting",
                "optional_someday",
                "archive"
            ]
        )
    }

    func testCreateCaptureTrimsTextAndDefaultsToNeedsTriageWhenRouteIsUnclear() async throws {
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
        XCTAssertEqual(created.status, .needsTriage)
        XCTAssertEqual(created.sourceType, .todayQuickCapture)
        XCTAssertNil(created.linkedGoalID)
        XCTAssertEqual(created.triage?.destination, .doSoon)
        XCTAssertEqual(created.kind, .raw)
        XCTAssertEqual(created.route, .captureInbox)
        XCTAssertEqual(created.triageStatus, .needsTriage)
        XCTAssertEqual(created.revisitAfter, "2026-04-22T09:00:00Z")
        XCTAssertEqual(all.count, 1)
    }

    func testCommitmentCaptureRepresentationIncludesDeadlineContextAndAssumption() async throws {
        let repository = PreviewCaptureRepository()
        let ledger = InMemoryEventLedgerRepository()
        let service = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-commitment" })

        let created = try await service.createCapture(
            CreateCaptureRequest(rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday", sourceType: .todayQuickCapture),
            now: fixedNow
        )
        let events = try await ledger.fetchRecent(limit: 10)

        XCTAssertEqual(created.status, .scheduled)
        XCTAssertEqual(created.kind, .oneTimeCommitment)
        XCTAssertEqual(created.route, .timeSeed)
        XCTAssertEqual(created.triageStatus, .assumedRoute)
        XCTAssertEqual(created.commitmentKind, .oneTime)
        XCTAssertEqual(created.deadlineText, "EOD Tuesday")
        XCTAssertEqual(created.deadlineKind, .hard)
        XCTAssertEqual(created.contextLensHint, .work)
        XCTAssertEqual(created.priorityHints.deadline, .high)
        XCTAssertEqual(created.priorityHints.urgency, .elevated)
        XCTAssertEqual(created.assumptionSummary, "I treated this as a one-time commitment.")
        XCTAssertTrue(created.correctionActions.contains(.changeRoute))
        XCTAssertTrue(events.contains { $0.kind == .captureCreated && $0.captureID == created.id })
        XCTAssertTrue(events.contains { $0.kind == .commitmentCaptured && $0.captureID == created.id })
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
        XCTAssertEqual(archived?.kind, .archiveItem)
        XCTAssertEqual(archived?.route, .archive)
        XCTAssertEqual(archived?.triageStatus, .archived)
    }

    func testRouteUpdatesCoverPlanWaitingOptionalDeliverableAndLedgerEvents() async throws {
        let repository = PreviewCaptureRepository()
        let ledger = InMemoryEventLedgerRepository()
        let timeService = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-route-plan" })
        let waitingService = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-route-waiting" })
        let optionalService = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-route-optional" })
        let deliverableService = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-route-deliverable" })
        let plan = try await timeService.createCapture(CreateCaptureRequest(rawText: "Plan this"), now: fixedNow)
        let waiting = try await waitingService.createCapture(CreateCaptureRequest(rawText: "Waiting on Kaylee"), now: fixedNow)
        let optional = try await optionalService.createCapture(CreateCaptureRequest(rawText: "Maybe learn piano someday"), now: fixedNow)
        let deliverable = try await deliverableService.createCapture(CreateCaptureRequest(rawText: "Add another song to the album"), now: fixedNow)

        let planSeed = try await timeService.routeToTimeSeed(id: plan.id, now: fixedNow.addingTimeInterval(60))
        let waitingItem = try await waitingService.markAsWaiting(
            id: waiting.id,
            waitingMetadata: CaptureWaitingMetadata(waitingOn: "Kaylee"),
            now: fixedNow.addingTimeInterval(120)
        )
        let optionalItem = try await optionalService.markAsOptionalSomeday(id: optional.id, now: fixedNow.addingTimeInterval(180))
        let deliverableSeed = try await deliverableService.markAsDeliverableSeed(id: deliverable.id, deliverableHint: "song", now: fixedNow.addingTimeInterval(240))
        let events = try await ledger.fetchRecent(limit: 40)

        XCTAssertEqual(planSeed?.kind, .oneTimeCommitment)
        XCTAssertEqual(planSeed?.route, .timeSeed)
        XCTAssertEqual(planSeed?.status, .scheduled)
        XCTAssertEqual(waitingItem?.kind, .waitingItem)
        XCTAssertEqual(waitingItem?.route, .waiting)
        XCTAssertEqual(waitingItem?.waitingMetadata?.waitingOn, "Kaylee")
        XCTAssertEqual(optionalItem?.kind, .optionalSomeday)
        XCTAssertEqual(optionalItem?.priorityHints.optionalSomeday, true)
        XCTAssertEqual(optionalItem?.priorityHints.passive, true)
        XCTAssertEqual(deliverableSeed?.kind, .deliverableSeed)
        XCTAssertEqual(deliverableSeed?.route, .deliverableSeed)
        XCTAssertTrue(events.contains { $0.kind == .captureTriaged && $0.captureID == plan.id })
        XCTAssertTrue(events.contains { $0.kind == .commitmentRouted && $0.captureID == plan.id })
        XCTAssertTrue(events.contains { $0.kind == .userCorrectionAdded && $0.captureID == waiting.id })
    }

    func testDeadlinePriorityUrgencyAndCorrectionEventsAreTruthful() async throws {
        let repository = PreviewCaptureRepository()
        let ledger = InMemoryEventLedgerRepository()
        let service = DefaultCaptureService(repository: repository, eventLedger: ledger, idProvider: { "capture-priority" })
        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Raw input"), now: fixedNow)

        let updated = try await service.updateCaptureState(
            CaptureStateUpdateRequest(
                id: "capture-priority",
                status: .actionable,
                kind: .deadlineTask,
                route: .timeSeed,
                triageStatus: .userCorrected,
                deadlineText: "Friday",
                deadlineKind: .hard,
                contextLensHint: .work,
                priorityHints: CapturePriorityHints(importance: .high, urgency: .elevated, deadline: .high)
            ),
            now: fixedNow.addingTimeInterval(60)
        )
        let events = try await ledger.fetchRecent(limit: 20)

        XCTAssertEqual(updated?.deadlineText, "Friday")
        XCTAssertEqual(updated?.contextLensHint, .work)
        XCTAssertEqual(updated?.priorityHints.importance, .high)
        XCTAssertEqual(updated?.priorityHints.urgency, .elevated)
        XCTAssertTrue(events.contains { $0.kind == .captureTriaged && $0.captureID == "capture-priority" })
        XCTAssertTrue(events.contains { $0.kind == .deadlineChanged && $0.captureID == "capture-priority" })
        XCTAssertTrue(events.contains { $0.kind == .priorityChanged && $0.captureID == "capture-priority" })
        XCTAssertTrue(events.contains { $0.kind == .urgencyChanged && $0.captureID == "capture-priority" })
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
        XCTAssertEqual(binding?.capture.kind, .goalSupportingTask)
        XCTAssertEqual(binding?.capture.route, .goalAttachment)
        XCTAssertEqual(binding?.capture.goalRelationship?.goalID, goal.id)
        XCTAssertEqual(binding?.capture.priorityHints.goalSupporting, true)
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

    func testBlockedGoalAttachmentDoesNotEmitMisleadingLedgerEvent() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let ledger = InMemoryEventLedgerRepository()
        let service = DefaultCaptureService(
            repository: repositories.captures,
            goalRepository: repositories.goals,
            eventLedger: ledger,
            idProvider: { "capture-missing-ledger" }
        )

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Attach this nowhere"), now: fixedNow)

        await XCTAssertThrowsErrorAsync(
            try await service.attachCaptureToGoal(
                AttachCaptureToGoalRequest(captureID: "capture-missing-ledger", goalID: "missing-goal"),
                now: fixedNow
            )
        ) { _ in }

        let events = try await ledger.fetchRecent(limit: 10)
        XCTAssertFalse(events.contains { $0.kind == .captureAttachedToGoal })
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
        XCTAssertEqual(binding?.capture.kind, .goalSeed)
        XCTAssertEqual(binding?.capture.route, .goalSeed)
        XCTAssertEqual(binding?.target.goalID, "goal-created")
        XCTAssertEqual(binding?.target.draftID, "draft-created")
    }

    func testTurnCaptureIntoGoalPersistsGoalDraftAndCaptureThroughUnitOfWork() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let service = DefaultCaptureService(
            repository: repositories.captures,
            goalsService: goalsService,
            goalCreationPreparer: goalsService,
            capturePromotionUnitOfWork: repositories.capturePromotionUnitOfWork,
            idProvider: { "capture-promotion" }
        )

        _ = try await service.createCapture(CreateCaptureRequest(rawText: "Launch my business"), now: fixedNow)
        let binding = try await service.turnCaptureIntoGoal(
            TurnCaptureIntoGoalRequest(captureID: "capture-promotion", mode: .project),
            now: fixedNow.addingTimeInterval(60)
        )

        let promoted = try XCTUnwrap(binding)
        let goalID = try XCTUnwrap(promoted.target.goalID)
        let draftID = try XCTUnwrap(promoted.target.draftID)
        let storedGoal = try await repositories.goals.goal(id: goalID)
        let storedDraft = try await repositories.drafts.draft(id: draftID)
        let storedCapture = try await repositories.captures.capture(id: "capture-promotion")

        XCTAssertEqual(promoted.unitOfWorkReceipt?.writeScope, .localSwiftDataSingleContext)
        XCTAssertEqual(promoted.unitOfWorkReceipt?.rollbackBehavior, AppUnitOfWorkReceipt.rollbackOnThrownError)
        XCTAssertEqual(promoted.unitOfWorkReceipt?.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)
        XCTAssertEqual(promoted.unitOfWorkReceipt?.didCommitChanges, true)
        XCTAssertEqual(storedGoal?.id, goalID)
        XCTAssertEqual(storedDraft?.plannedGoalID, goalID)
        XCTAssertEqual(storedCapture?.linkedGoalID, goalID)
        XCTAssertEqual(storedCapture?.status, .goalBound)
        XCTAssertEqual(storedCapture?.goalRelationship?.relationshipKind, .activeGoal)
    }

    func testAtomicCapturePromotionRollsBackGoalDraftAndKeepsOriginalCaptureWhenCaptureWriteFailsBeforeSave() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let setupRepositories = makeRepositories(store: store)
        let setupService = DefaultCaptureService(
            repository: setupRepositories.captures,
            idProvider: { "capture-promotion-fail" }
        )
        _ = try await setupService.createCapture(CreateCaptureRequest(rawText: "Launch my business"), now: fixedNow)

        let failingRepositories = makeRepositories(
            store: store,
            capturePromotionUnitOfWork: SwiftDataCapturePromotionUnitOfWork(
                store: store,
                failureInjection: .afterGoalDraftWriteBeforeCaptureWrite
            )
        )
        let goalsService = RepositoryBackedGoalsService(repositories: failingRepositories)
        let failingService = DefaultCaptureService(
            repository: failingRepositories.captures,
            goalsService: goalsService,
            goalCreationPreparer: goalsService,
            capturePromotionUnitOfWork: failingRepositories.capturePromotionUnitOfWork,
            idProvider: { "unused" }
        )

        await XCTAssertThrowsErrorAsync(
            try await failingService.turnCaptureIntoGoal(
                TurnCaptureIntoGoalRequest(captureID: "capture-promotion-fail", mode: .project),
                now: fixedNow.addingTimeInterval(60)
            )
        ) { error in
            XCTAssertEqual(error as? CapturePromotionUnitOfWorkProbeError, .afterGoalDraftWriteBeforeCaptureWrite)
        }

        let goals = try await failingRepositories.goals.listGoals()
        let drafts = try await failingRepositories.drafts.listDrafts()
        let capture = try await failingRepositories.captures.capture(id: "capture-promotion-fail")

        XCTAssertTrue(goals.isEmpty)
        XCTAssertTrue(drafts.isEmpty)
        XCTAssertEqual(capture?.status, .needsTriage)
        XCTAssertNil(capture?.linkedGoalID)
        XCTAssertNil(capture?.goalRelationship)
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

    func makeRepositories(
        store: AmbitionsPersistenceStore,
        capturePromotionUnitOfWork: SwiftDataCapturePromotionUnitOfWork? = nil
    ) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            goalCreationUnitOfWork: SwiftDataGoalCreationUnitOfWork(store: store),
            capturePromotionUnitOfWork: capturePromotionUnitOfWork ?? SwiftDataCapturePromotionUnitOfWork(store: store),
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
