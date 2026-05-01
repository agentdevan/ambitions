import XCTest
@testable import Ambitions

final class AmbitionsCommandExecutorTests: XCTestCase {
    func testOpenDestinationExecutesAsRouteResultWithoutExternalDependency() async {
        let executor = AmbitionsCommandExecutor()
        let command = AmbitionsCommand(
            id: "command-open-plan",
            kind: .openDestination,
            source: .widget,
            target: AmbitionsCommandTarget(destination: .plan),
            createdAt: "2026-04-25T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.route, .plan)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
        XCTAssertEqual(result.summary, "Open destination command validated.")
    }

    func testQuickCaptureExecutesThroughCaptureServiceAndEmitsOneLedgerEvent() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-command" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(captureService: captureService, eventLedger: ledger)
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-capture",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(
                rawText: "  Create spreadsheet and send it to Kaylee by EOD Tuesday  ",
                deadlineText: "EOD Tuesday",
                contextLens: .work,
                commitmentKind: .oneTime,
                priorityHints: AmbitionsCommandPriorityHints(importance: .high, urgency: .high, deadline: .high)
            ),
            createdAt: DomainTimestamp.string(from: now),
            sourceSurface: "today"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now)
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.route, .captureInbox)
        XCTAssertEqual(result.target?.captureID, "capture-command")
        XCTAssertEqual(captures.map(\.rawText), ["Create spreadsheet and send it to Kaylee by EOD Tuesday"])
        XCTAssertEqual(captures.first?.sourceType, .todayQuickCapture)
        XCTAssertEqual(captures.first?.kind, .oneTimeCommitment)
        XCTAssertEqual(captures.first?.route, .planSeed)
        XCTAssertEqual(captures.first?.deadlineText, "EOD Tuesday")
        XCTAssertEqual(captures.first?.contextLensHint, .work)
        XCTAssertEqual(captures.first?.priorityHints.importance, .high)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "ledger.command.command-capture")
        XCTAssertEqual(events.first?.kind, .captureCreated)
        XCTAssertEqual(events.first?.source, .today)
        XCTAssertEqual(events.first?.captureID, "capture-command")
        XCTAssertEqual(events.first?.privacy, .privateUserText)
        XCTAssertEqual(result.eventLedgerEntryIDs, ["ledger.command.command-capture"])
    }

    func testQuickCaptureCanExecuteWithoutLedgerEmission() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-no-ledger" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(captureService: captureService, eventLedger: ledger)
        let command = AmbitionsCommand(
            id: "command-no-ledger",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Raw idea"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(
                now: Date(timeIntervalSince1970: 1_777_113_600),
                allowsEventLedgerEmission: false
            )
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(captures.count, 1)
        XCTAssertTrue(events.isEmpty)
    }

    func testUnsupportedFutureCommandsReturnUnsupportedAndDoNotEmitLedgerEvents() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "unused" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(captureService: captureService, eventLedger: ledger)
        let command = AmbitionsCommand(
            id: "command-schedule",
            kind: .scheduleItem,
            source: .plan,
            payload: AmbitionsCommandPayload(
                title: "Schedule work block",
                deadlineText: "Tuesday",
                contextLens: .work,
                commitmentKind: .oneTime
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(result.status, .unsupported)
        XCTAssertEqual(result.metadata["blockedBy"], "plan_2_not_implemented")
        let events = try await ledger.fetchRecent(limit: 10)
        let captures = try await captureRepository.listCaptures()
        XCTAssertTrue(events.isEmpty)
        XCTAssertTrue(captures.isEmpty)
    }

    func testPlanSeedCommandRepresentsExistingCaptureWithoutScheduling() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-plan-seed" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(captureService: captureService, eventLedger: ledger)
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        _ = try await captureService.createCapture(CreateCaptureRequest(rawText: "Create spreadsheet"), now: now)
        let command = AmbitionsCommand(
            id: "command-plan-seed",
            kind: .scheduleItem,
            source: .plan,
            target: AmbitionsCommandTarget(captureID: "capture-plan-seed"),
            payload: AmbitionsCommandPayload(deadlineText: "Tuesday", contextLens: .work),
            createdAt: DomainTimestamp.string(from: now)
        )

        let result = await executor.execute(command, context: CommandExecutionContext(now: now.addingTimeInterval(60)))
        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.summary, "Capture represented as a Plan idea. Scheduling is not implemented in this batch.")
        XCTAssertEqual(result.metadata["captureRoute"], CaptureRoute.planSeed.rawValue)
        XCTAssertEqual(captures.first?.kind, .oneTimeCommitment)
        XCTAssertEqual(captures.first?.route, .planSeed)
        XCTAssertTrue(events.isEmpty)
    }

    func testRouteCommitmentAndWaitingCommandsUseCaptureRouteModel() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-routes" })
        let executor = AmbitionsCommandExecutor(captureService: captureService)
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        _ = try await captureService.createCapture(CreateCaptureRequest(rawText: "Raw captured thought"), now: now)
        let commitment = AmbitionsCommand(
            id: "command-route-commitment",
            kind: .routeCommitment,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-routes"),
            payload: AmbitionsCommandPayload(deadlineText: "EOD Tuesday", contextLens: .work),
            createdAt: DomainTimestamp.string(from: now)
        )

        let commitmentResult = await executor.execute(commitment, context: CommandExecutionContext(now: now.addingTimeInterval(60)))
        let committedCapture = try await captureRepository.capture(id: "capture-routes")
        var stored = try XCTUnwrap(committedCapture)
        XCTAssertEqual(commitmentResult.status, .succeeded)
        XCTAssertEqual(stored.kind, .oneTimeCommitment)
        XCTAssertEqual(stored.route, .planSeed)
        XCTAssertEqual(stored.deadlineText, "EOD Tuesday")

        let waiting = AmbitionsCommand(
            id: "command-waiting",
            kind: .markWaiting,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-routes"),
            payload: AmbitionsCommandPayload(title: "Kaylee", notes: "blocked by reply"),
            createdAt: DomainTimestamp.string(from: now)
        )

        let waitingResult = await executor.execute(waiting, context: CommandExecutionContext(now: now.addingTimeInterval(120)))
        let waitingCapture = try await captureRepository.capture(id: "capture-routes")
        stored = try XCTUnwrap(waitingCapture)
        XCTAssertEqual(waitingResult.status, .succeeded)
        XCTAssertEqual(stored.kind, .waitingItem)
        XCTAssertEqual(stored.route, .waiting)
        XCTAssertEqual(stored.waitingMetadata?.waitingOn, "Kaylee")
    }

    func testMissingTargetAndInvalidPayloadBlockBeforeExecution() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "unused" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(captureService: captureService, eventLedger: ledger)
        let missingTarget = AmbitionsCommand(
            id: "command-complete-missing",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1"),
            createdAt: "2026-04-25T12:00:00Z"
        )
        let invalidCapture = AmbitionsCommand(
            id: "command-empty-capture",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: " "),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let missingResult = await executor.execute(
            missingTarget,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )
        let invalidResult = await executor.execute(
            invalidCapture,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(missingResult.status, .blocked)
        XCTAssertEqual(missingResult.metadata["validation"], AmbitionsCommandValidationState.needsMissingTarget.rawValue)
        XCTAssertEqual(invalidResult.status, .failed)
        XCTAssertEqual(invalidResult.metadata["validation"], AmbitionsCommandValidationState.invalid.rawValue)
        let events = try await ledger.fetchRecent(limit: 10)
        let captures = try await captureRepository.listCaptures()
        XCTAssertTrue(events.isEmpty)
        XCTAssertTrue(captures.isEmpty)
    }

    func testExecutorDoesNotDependOnCalendarOrExternalSurfaceRuntime() async {
        let executor = AmbitionsCommandExecutor()
        let command = AmbitionsCommand(
            id: "command-widget-capture",
            kind: .quickCapture,
            source: .widget,
            payload: AmbitionsCommandPayload(rawText: "Widget capture"),
            createdAt: "2026-04-25T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "missing_capture_service")
    }

    func testScheduleCalendarWriteIntentRequiresConfirmationAndDoesNotWrite() async {
        let executor = AmbitionsCommandExecutor()
        let unconfirmed = AmbitionsCommand(
            id: "command-calendar-write",
            kind: .scheduleItem,
            source: .plan,
            target: AmbitionsCommandTarget(planID: "plan-1"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: ["calendarWriteIntent": "true"]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        XCTAssertEqual(executor.validate(unconfirmed), .needsConfirmation)

        let confirmed = AmbitionsCommand(
            id: "command-calendar-write-confirmed",
            kind: .scheduleItem,
            source: .plan,
            target: AmbitionsCommandTarget(planID: "plan-1"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: ["calendarWriteIntent": "true", "userConfirmed": "true"]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            confirmed,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_714_000_000))
        )

        XCTAssertEqual(result.status, .unsupported)
        XCTAssertEqual(result.metadata["calendarWriteIntent"], "true")
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
    }
}
