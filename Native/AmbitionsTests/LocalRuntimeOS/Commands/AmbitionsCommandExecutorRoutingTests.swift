import XCTest
@testable import Ambitions

final class AmbitionsCommandExecutorRoutingTests: XCTestCase {
    func testOpenDestinationExecutesAsRouteResultWithoutExternalDependency() async {
        let executor = AmbitionsCommandExecutor.test()
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
        XCTAssertNil(result.metadata["runtimeTransactionID"])
        XCTAssertNil(result.metadata["runtimeEventID"])
    }

    func testQuickCaptureExecutesThroughCaptureServiceAndEmitsOneLedgerEvent() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-command" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
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
        XCTAssertEqual(result.metadata["runtimeTransactionDisposition"], RuntimeTransactionCommitDisposition.committed.rawValue)
        XCTAssertEqual(result.metadata["runtimeTransactionID"], "runtime.transaction.command-capture")
        XCTAssertNotNil(result.metadata["runtimeEventID"])
        XCTAssertEqual(result.metadata["runtimeReceiptID"], "runtime.receipt.command-capture")
        XCTAssertEqual(result.metadata["runtimeRollbackPlanID"], "runtime.rollback.command-capture")
        XCTAssertEqual(result.metadata["runtimeReplayTraceID"], "runtime.replay.command-capture")
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
        let proofExecutor = AmbitionsCommandExecutor.test(captureService: proofService)
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

        let proofCaptureRecord = try await proofRepository.capture(id: "capture-proof-route")
        let proofCapture = try XCTUnwrap(proofCaptureRecord)
        XCTAssertEqual(proofResult.status, .succeeded)
        XCTAssertEqual(proofCapture.route, .proofItem)
        XCTAssertEqual(proofCapture.kind, .raw)
        XCTAssertEqual(proofCapture.rawText, "Plain note")
        XCTAssertEqual(proofCapture.sourceType, .todayQuickCapture)

        let constraintRepository = PreviewCaptureRepository()
        let constraintService = DefaultCaptureService(repository: constraintRepository, idProvider: { "capture-constraint-route" })
        let constraintExecutor = AmbitionsCommandExecutor.test(captureService: constraintService)
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

        let constraintCaptureRecord = try await constraintRepository.capture(id: "capture-constraint-route")
        let constraintCapture = try XCTUnwrap(constraintCaptureRecord)
        XCTAssertEqual(constraintResult.status, .succeeded)
        XCTAssertEqual(constraintCapture.route, .constraintItem)
        XCTAssertEqual(constraintCapture.kind, .raw)
        XCTAssertEqual(constraintCapture.rawText, "Keep this constraint")
        XCTAssertEqual(constraintCapture.sourceType, .todayQuickCapture)
    }

}
