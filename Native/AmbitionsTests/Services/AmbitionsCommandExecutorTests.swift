import XCTest
@testable import Ambitions

final class AmbitionsCommandExecutorTests: XCTestCase {
    func testOpenDestinationExecutesAsRouteResultWithoutExternalDependency() async {
        let executor = AmbitionsCommandExecutor()
        let command = AmbitionsCommand(
            id: "command-open-time",
            kind: .openDestination,
            source: .widget,
            target: AmbitionsCommandTarget(destination: .time),
            createdAt: "2026-04-25T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.route, .time)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
        XCTAssertEqual(result.summary, "Open destination command validated.")
    }

    func testQuickCaptureExecutesThroughCaptureServiceAndEmitsOneLedgerEvent() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-command" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
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
        XCTAssertEqual(captures.first?.route, .timeSeed)
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

        let records = try await commandRecordRepository.fetchRecent(limit: 10)
        let record = try XCTUnwrap(records.first)
        XCTAssertEqual(record.command.id, "command-capture")
        XCTAssertEqual(record.result.status, .succeeded)
        XCTAssertEqual(record.result.eventLedgerEntryIDs, ["ledger.command.command-capture"])
        XCTAssertEqual(record.localOnly, command.localOnly)
        XCTAssertEqual(record.privacy, command.privacy)
        XCTAssertEqual(record.schemaVersion, ambitionsCommandExecutionRecordSchemaVersion)
    }

    func testQuickCaptureUsesCanonicalDestinationRouteMappingForProofAndConstraintRoutes() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)

        let proofRepository = PreviewCaptureRepository()
        let proofService = DefaultCaptureService(repository: proofRepository, idProvider: { "capture-proof-route" })
        let proofExecutor = AmbitionsCommandExecutor(captureService: proofService)
        let proofCommand = AmbitionsCommand(
            id: "command-proof-route",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(
                rawText: "Plain note",
                destinationRoute: CaptureRoute.proofItem.rawValue
            ),
            createdAt: DomainTimestamp.string(from: now)
        )
        let proofResult = await proofExecutor.execute(
            proofCommand,
            context: CommandExecutionContext(now: now, allowsEventLedgerEmission: false)
        )

        let proofCapture = try XCTUnwrap(try await proofRepository.capture(id: "capture-proof-route"))
        XCTAssertEqual(proofResult.status, .succeeded)
        XCTAssertEqual(proofCapture.route, .proofItem)
        XCTAssertEqual(proofCapture.kind, .raw)
        XCTAssertEqual(proofCapture.rawText, "Plain note")
        XCTAssertEqual(proofCapture.sourceType, .capture)

        let constraintRepository = PreviewCaptureRepository()
        let constraintService = DefaultCaptureService(repository: constraintRepository, idProvider: { "capture-constraint-route" })
        let constraintExecutor = AmbitionsCommandExecutor(captureService: constraintService)
        let constraintCommand = AmbitionsCommand(
            id: "command-constraint-route",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(
                rawText: "Keep this constraint",
                destinationRoute: CaptureRoute.constraintItem.rawValue
            ),
            createdAt: DomainTimestamp.string(from: now.addingTimeInterval(60))
        )
        let constraintResult = await constraintExecutor.execute(
            constraintCommand,
            context: CommandExecutionContext(now: now.addingTimeInterval(60), allowsEventLedgerEmission: false)
        )

        let constraintCapture = try XCTUnwrap(try await constraintRepository.capture(id: "capture-constraint-route"))
        XCTAssertEqual(constraintResult.status, .succeeded)
        XCTAssertEqual(constraintCapture.route, .constraintItem)
        XCTAssertEqual(constraintCapture.kind, .raw)
        XCTAssertEqual(constraintCapture.rawText, "Keep this constraint")
        XCTAssertEqual(constraintCapture.sourceType, .capture)
    }

    func testCommandReplayReturnsExistingReceiptWithoutDoubleApplyingMutation() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-replay" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-replay",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Replay me once"),
            createdAt: DomainTimestamp.string(from: now)
        )
        let storedResult = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved to Needs a Place",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture-replay", destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.command.command-replay"],
            recommendationExplanationIDs: ["explanation-replay"],
            metadata: ["captureID": "capture-replay"]
        )
        let storedRecord = AmbitionsCommandExecutionRecord(
            command: command,
            result: storedResult,
            recordedAt: "2026-04-25T12:01:00Z"
        )

        try await commandRecordRepository.append(storedRecord)

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        let fetchedReplayRecord = try await commandRecordRepository.fetchRecord(commandID: command.id)
        let replayedRecord = try XCTUnwrap(fetchedReplayRecord)

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.summary, "Replayed existing command receipt: Saved to Needs a Place")
        XCTAssertEqual(result.route, .captureInbox)
        XCTAssertEqual(result.target?.captureID, "capture-replay")
        XCTAssertEqual(result.eventLedgerEntryIDs, ["ledger.command.command-replay"])
        XCTAssertEqual(result.recommendationExplanationIDs, ["explanation-replay"])
        XCTAssertEqual(result.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.receipt.rawValue)
        XCTAssertEqual(result.metadata["replayDecision"], LedgerReplayDecision.replayExistingReceipt.rawValue)
        XCTAssertEqual(result.metadata["idempotencyKey"], command.id)
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue)
        XCTAssertEqual(result.metadata["replayedReceiptSummary"], "Saved to Needs a Place")
        XCTAssertEqual(result.metadata["captureID"], "capture-replay")
        XCTAssertEqual(captures.count, 0)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(replayedRecord.recordedAt, "2026-04-25T12:01:00Z")
    }

    func testReplayLookupFailureBlocksMutationInsteadOfDoubleApplying() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-should-not-write" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = ThrowingFetchCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let command = AmbitionsCommand(
            id: "command-replay-fetch-failure",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Do not double apply"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        let appendedRecords = await commandRecordRepository.appendedRecordCount

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(
            result.summary,
            "Command replay lookup could not be verified, so Ambitions skipped the mutation to avoid double apply."
        )
        XCTAssertEqual(result.metadata["replayDecision"], LedgerReplayDecision.lookupUnavailable.rawValue)
        XCTAssertEqual(result.metadata["idempotencyKey"], "command-replay-fetch-failure")
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue)
        XCTAssertEqual(result.metadata["blockedBy"], "command_replay_lookup_unavailable")
        XCTAssertTrue(captures.isEmpty)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(appendedRecords, 0)
    }

    func testQuickCapturePersistsExecutionRecordWhenEmissionDisabled() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-no-ledger" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-record-no-ledger",
            kind: .quickCapture,
            source: .widget,
            payload: AmbitionsCommandPayload(rawText: "No ledger capture"),
            createdAt: "2026-04-25T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now, allowsEventLedgerEmission: false)
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)

        let records = try await commandRecordRepository.fetchRecent(limit: 10)
        let record = try XCTUnwrap(records.first)
        XCTAssertEqual(record.result.summary, "Saved to Needs a Place")
        XCTAssertEqual(record.result.eventLedgerEntryIDs, [])
        XCTAssertEqual(record.command.actor, .externalSurface)
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

    func testUnsupportedFutureCommandsArePersistedWithoutEventLedgerEmission() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "unused" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let command = AmbitionsCommand(
            id: "command-unsupported",
            kind: .scheduleItem,
            source: .time,
            payload: AmbitionsCommandPayload(
                title: "Schedule work block",
                destinationRoute: "plan"
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        XCTAssertEqual(result.status, .unsupported)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)

        let record = try await commandRecordRepository.fetchRecord(commandID: "command-unsupported")
        let fetched = try XCTUnwrap(record)
        XCTAssertEqual(fetched.result.status, .unsupported)
        XCTAssertEqual(fetched.result.metadata["blockedBy"], "plan_2_not_implemented")
        XCTAssertEqual(fetched.command.id, "command-unsupported")

        let events = try await ledger.fetchRecent(limit: 10)
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
            source: .time,
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
            source: .time,
            target: AmbitionsCommandTarget(captureID: "capture-plan-seed"),
            payload: AmbitionsCommandPayload(deadlineText: "Tuesday", contextLens: .work),
            createdAt: DomainTimestamp.string(from: now)
        )

        let result = await executor.execute(command, context: CommandExecutionContext(now: now.addingTimeInterval(60)))
        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.summary, "Capture represented as a Time-owned planning idea. Scheduling is not implemented in this build.")
        XCTAssertEqual(result.metadata["captureRoute"], CaptureRoute.timeSeed.rawValue)
        XCTAssertEqual(captures.first?.kind, .oneTimeCommitment)
        XCTAssertEqual(captures.first?.route, .timeSeed)
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
        XCTAssertEqual(stored.route, .timeSeed)
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
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
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

        let records = try await commandRecordRepository.fetchRecent(limit: 10)
        XCTAssertEqual(records.map(\.command.id), ["command-empty-capture", "command-complete-missing"])
        XCTAssertEqual(records.map(\.result.status), [.failed, .blocked])
        XCTAssertEqual(records.first?.result.metadata["validation"], AmbitionsCommandValidationState.invalid.rawValue)
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

    func testScheduleCalendarWriteIntentRequiresConfirmationBeforeSuccess() async {
        let executor = AmbitionsCommandExecutor()
        let unconfirmed = AmbitionsCommand(
            id: "command-calendar-write",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-1"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: ["calendarWriteIntent": "true"]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        XCTAssertEqual(executor.validate(unconfirmed), .needsConfirmation)
        let unconfirmedResult = await executor.execute(
            unconfirmed,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_714_000_000))
        )
        XCTAssertEqual(unconfirmedResult.status, .requiresConfirmation)
    }

    func testScheduleCalendarWriteIntentWritesAndReceiptsAreRecordedAfterUserConfirmation() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-calendar-write-tests-\(UUID().uuidString)")
        let fileURL = root.appendingPathComponent("local-schedule-blocks.json")
        defer { try? FileManager.default.removeItem(at: root) }

        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(
            eventLedger: ledger,
            scheduleStoreFileURL: fileURL
        )
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let confirmed = AmbitionsCommand(
            id: "command-calendar-write-confirmed",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(
                timeID: "time-block-preview",
                stepID: "step-active"
            ),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: [
                    "calendarWriteIntent": "true",
                    "userConfirmed": "true",
                    "scheduleBlockID": "schedule-block-1",
                    "approvedDurationMinutes": "15",
                    "startAt": DomainTimestamp.string(from: now),
                    "endAt": DomainTimestamp.string(from: now.addingTimeInterval(1_200)),
                    "relatedGoalID": "goal-active",
                    "relatedCaptureID": "capture-active",
                    "destinationStepID": "step-active",
                    "destinationStepTitle": "Write outline",
                    "displacedDisposition": "held",
                    "destinationStepPressure": "6/10",
                    "originStepPressure": "4/10",
                    "lifeshapeImpact": "pressure-shifts-protected"
                ]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            confirmed,
            context: CommandExecutionContext(now: now, sourceSurface: "time")
        )

        let blocks = try loadLocalScheduleBlocks(from: fileURL)
        let events = try await ledger.fetchRecent(limit: 10)

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.summary, "Schedule mutation was written locally after confirmation.")
        XCTAssertEqual(result.target?.timeID, "schedule-block-1")
        XCTAssertEqual(result.target?.destination, .time)
        XCTAssertEqual(result.eventLedgerEntryIDs, ["ledger.schedule.mutation.command-calendar-write-confirmed"])
        XCTAssertEqual(result.metadata["approvalState"], "confirmed")
        XCTAssertEqual(result.metadata["sourceRecordID"], "SourceRecord.local-schedule.schedule-block-1")
        XCTAssertEqual(result.metadata["receiptID"], "Receipt.local-schedule.schedule-block-1.save")
        XCTAssertEqual(result.metadata["replayTraceID"], "ReplayTrace.local-schedule.schedule-block-1.save")
        XCTAssertEqual(result.metadata["approvedDurationMinutes"], "15")
        XCTAssertEqual(result.metadata["originalBlockID"], "time-block-preview")
        XCTAssertEqual(result.metadata["destinationStepID"], "step-active")
        XCTAssertEqual(result.metadata["destinationStepTitle"], "Write outline")
        XCTAssertEqual(result.metadata["displacedDisposition"], "held")
        XCTAssertEqual(result.metadata["destinationStepPressure"], "6/10")
        XCTAssertEqual(result.metadata["originStepPressure"], "4/10")
        XCTAssertEqual(result.metadata["lifeshapeImpact"], "pressure-shifts-protected")

        XCTAssertEqual(blocks.count, 1)
        XCTAssertEqual(blocks.first?.id, "schedule-block-1")
        XCTAssertEqual(blocks.first?.title, "Draft proposal")
        XCTAssertEqual(blocks.first?.relatedGoalID, "goal-active")
        XCTAssertEqual(blocks.first?.relatedCaptureID, "capture-active")
        XCTAssertEqual(blocks.first?.isUserConfirmed, true)
        XCTAssertEqual(blocks.first?.start, now)
        XCTAssertEqual(blocks.first?.end, now.addingTimeInterval(1_200))
        XCTAssertEqual(blocks.first?.contextLens, .all)
        XCTAssertEqual(blocks.first?.localScheduleSourceRecordID, "SourceRecord.local-schedule.schedule-block-1")
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "ledger.schedule.mutation.command-calendar-write-confirmed")
        XCTAssertEqual(events.first?.kind, .planScheduled)

        let missingMetadata = AmbitionsCommand(
            id: "command-calendar-write-confirmed-missing",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-block-preview"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: ["calendarWriteIntent": "true", "userConfirmed": "true"]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )
        let missingMetadataResult = await executor.execute(
            missingMetadata,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        )
        XCTAssertEqual(missingMetadataResult.status, .blocked)
        XCTAssertEqual(missingMetadataResult.metadata["blockedBy"], "calendar_write_metadata_missing")
        XCTAssertEqual(missingMetadataResult.metadata["calendarWriteIntent"], "true")
        XCTAssertTrue(missingMetadataResult.eventLedgerEntryIDs.isEmpty)
    }

    func testScheduleCalendarWriteIntentSuccessWithDurationFallsBackToApprovedMinutesWhenEndMissing() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-calendar-write-tests-duration-\(UUID().uuidString)")
        let fileURL = root.appendingPathComponent("local-schedule-blocks.json")
        defer { try? FileManager.default.removeItem(at: root) }

        let start = Date(timeIntervalSince1970: 1_714_000_000)
        let confirmed = AmbitionsCommand(
            id: "command-calendar-write-confirmed",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-block-preview"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: [
                    "calendarWriteIntent": "true",
                    "userConfirmed": "true",
                    "approvedDurationMinutes": "25",
                    "startAt": DomainTimestamp.string(from: start)
                ]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )
        let executor = AmbitionsCommandExecutor(scheduleStoreFileURL: fileURL)
        let result = await executor.execute(
            confirmed,
            context: CommandExecutionContext(now: start)
        )

        let blocks = try loadLocalScheduleBlocks(from: fileURL)
        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.metadata["approvedDurationMinutes"], "25")
        XCTAssertEqual(blocks.first?.end, start.addingTimeInterval(1_500))
        XCTAssertEqual(blocks.count, 1)
    }

    func testDataControlCommandsRemainInPolicyDomainWithoutExecution() async {
        let executor = AmbitionsCommandExecutor()
        let commands = [
            AmbitionsCommand(
                id: "command-prepare-export",
                kind: .prepareExport,
                source: .you,
                createdAt: "2026-05-12T12:00:00Z"
            ),
            AmbitionsCommand(
                id: "command-perform-export",
                kind: .performExport,
                source: .you,
                createdAt: "2026-05-12T12:00:00Z"
            ),
            AmbitionsCommand(
                id: "command-delete-object",
                kind: .deleteObject,
                source: .capture,
                target: AmbitionsCommandTarget(goalID: "goal-1"),
                createdAt: "2026-05-12T12:00:00Z"
            ),
            AmbitionsCommand(
                id: "command-forget-memory",
                kind: .forgetMemory,
                source: .you,
                target: AmbitionsCommandTarget(reviewID: "memory-1"),
                createdAt: "2026-05-12T12:00:00Z"
            )
        ]

        for command in commands {
            let result = await executor.execute(
                command,
                context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_100_000))
            )
            XCTAssertEqual(result.status, .unsupported)
            XCTAssertEqual(result.target?.goalID, command.target.goalID)
            XCTAssertEqual(result.target?.reviewID, command.target.reviewID)
            XCTAssertEqual(result.metadata["blockedBy"], "owning_system_not_implemented")
        }
    }
}

private enum CommandExecutionRecordTestError: Error {
    case fetchUnavailable
}

private actor ThrowingFetchCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    private var appendedRecords: [AmbitionsCommandExecutionRecord] = []

    var appendedRecordCount: Int {
        appendedRecords.count
    }

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        appendedRecords.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        Array(appendedRecords.prefix(max(0, limit)))
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        throw CommandExecutionRecordTestError.fetchUnavailable
    }
}
