import AmbitionsPresentationContracts
import Foundation
import XCTest
@testable import Ambitions

final class FlagshipRuntimeIntentAdapterTests: XCTestCase {
    func testQuickCaptureTranslatesTypedSourcePlacementPrivacyAndStableIdentity() async throws {
        let recorder = RuntimeCommandRecorder(result: .projectionReady)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)
        let intent = makeIntent(draftID: "draft.share.001")

        let first = await adapter.send(intent, idempotencyKey: "capture-save-attempt.001", expectedRevision: nil)
        let second = await adapter.send(intent, idempotencyKey: "capture-save-attempt.001", expectedRevision: nil)
        let commands = await recorder.commands()

        XCTAssertEqual(first.state, .committedProjectionReady)
        XCTAssertEqual(second.state, .committedProjectionReady)
        XCTAssertEqual(commands.count, 2)
        XCTAssertEqual(commands[0].id, commands[1].id)
        XCTAssertTrue(commands[0].id.hasPrefix("shell.capture.command-"))
        XCTAssertEqual(commands[0].source, .deepLink)
        XCTAssertEqual(commands[0].sourceSurface, "Share")
        XCTAssertEqual(commands[0].privacy, .privateUserText)
        XCTAssertTrue(commands[0].localOnly)
        XCTAssertEqual(commands[0].payload.rawText, "Book dentist")
        XCTAssertEqual(commands[0].payload.destinationRoute, CaptureRoute.timeSeed.rawValue)
        XCTAssertEqual(
            commands[0].payload.metadata[ExternalCreationCommandMetadataKey.sourceType],
            CaptureSourceType.shareExtensionText.rawValue
        )
        XCTAssertEqual(commands[0].payload.metadata["captureEntryPoint"], ShellCommandEntrySource.shareExtension.rawValue)
        XCTAssertEqual(commands[0].payload.metadata["captureRouteType"], SmartAttachmentRouteType.reminder.rawValue)
        XCTAssertEqual(commands[0].payload.metadata["captureCommandPath"], "shell_command_router")
        XCTAssertEqual(commands[0].payload.metadata["flagshipDraftID"], "draft.share.001")
    }

    func testSameTextWithDifferentDraftIdentityDoesNotDeduplicateLaterCapture() async {
        let recorder = RuntimeCommandRecorder(result: .projectionReady)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

        _ = await adapter.send(
            makeIntent(draftID: "draft.001"),
            idempotencyKey: "capture-save-attempt.001",
            expectedRevision: nil
        )
        _ = await adapter.send(
            makeIntent(draftID: "draft.002"),
            idempotencyKey: "capture-save-attempt.002",
            expectedRevision: nil
        )

        let commands = await recorder.commands()
        XCTAssertEqual(commands.count, 2)
        XCTAssertNotEqual(commands[0].id, commands[1].id)
        XCTAssertEqual(commands[0].payload.rawText, commands[1].payload.rawText)
    }

    func testEmptyQuickCaptureIsRejectedBeforeExecutorMutation() async {
        let recorder = RuntimeCommandRecorder(result: .projectionReady)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)
        let intent = makeIntent(draftID: "draft.empty", text: "   ")

        let result = await adapter.send(intent, idempotencyKey: "capture-save-attempt.empty", expectedRevision: nil)
        let commands = await recorder.commands()

        XCTAssertEqual(result.state, .rejectedBeforeMutation)
        XCTAssertTrue(commands.isEmpty)
    }

    func testExecutorFailurePreservesLegacySummaryWithoutMutationClaim() async {
        let recorder = RuntimeCommandRecorder(result: .failed)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

        let result = await adapter.send(
            makeIntent(draftID: "draft.failed"),
            idempotencyKey: "capture-save-attempt.failed",
            expectedRevision: nil
        )

        guard case let .rejectedBeforeMutation(code, recoveryAction) = result else {
            return XCTFail("Expected a pre-visible-mutation rejection")
        }
        XCTAssertEqual(code, "Capture persistence unavailable")
        XCTAssertEqual(recoveryAction, .refreshAndRetry)
    }

    func testProjectionReadySuccessIncludesReceiptCursorSummaryAndAffectedCapture() async throws {
        let recorder = RuntimeCommandRecorder(result: .projectionReady)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

        let result = await adapter.send(
            makeIntent(draftID: "draft.ready"),
            idempotencyKey: "capture-save-attempt.ready",
            expectedRevision: nil
        )

        guard case let .committedProjectionReady(receipt) = result else {
            return XCTFail("Expected projection-ready authority, got \(result.state.rawValue)")
        }
        XCTAssertEqual(receipt.id, "command.receipt.recorded")
        XCTAssertEqual(receipt.summary, "Saved through authority")
        XCTAssertEqual(receipt.projectionCursors, ["today": "12:cursor.today.12"])
        XCTAssertEqual(
            receipt.affectedObjects,
            [FlagshipObjectReference(kind: .capture, id: "capture.recorded")]
        )
        XCTAssertFalse(receipt.semanticUndoEligible)
    }

    func testNeedsRecoverySuccessMapsToCommittedCatchUpRequired() async {
        let recorder = RuntimeCommandRecorder(result: .needsRecovery)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

        let result = await adapter.send(
            makeIntent(draftID: "draft.recovery"),
            idempotencyKey: "capture-save-attempt.recovery",
            expectedRevision: nil
        )

        guard case let .committedCatchUpRequired(receipt) = result else {
            return XCTFail("Expected committed catch-up, got \(result.state.rawValue)")
        }
        XCTAssertEqual(receipt.recoveryAction, .waitForProjection)
        XCTAssertEqual(receipt.affectedObjects.first?.id, "capture.recorded")
    }

    func testDuplicateProjectionCursorIDsFailClosedAsCatchUpRequired() async {
        let recorder = RuntimeCommandRecorder(result: .duplicateProjectionCursorIDs)
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

        let result = await adapter.send(
            makeIntent(draftID: "draft.duplicate-cursors"),
            idempotencyKey: "capture-save-attempt.duplicate-cursors",
            expectedRevision: nil
        )

        guard case let .committedCatchUpRequired(receipt) = result else {
            return XCTFail("Duplicate cursor identifiers must not claim projection readiness")
        }
        XCTAssertTrue(receipt.projectionCursors.isEmpty)
        XCTAssertEqual(receipt.recoveryAction, .waitForProjection)
    }

    func testSuccessMissingReceiptOrCaptureIdentityIsNeverProjectionReady() async {
        for resultTemplate in [RecordedCommandResult.missingReceipt, .missingCapture] {
            let recorder = RuntimeCommandRecorder(result: resultTemplate)
            let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: recorder.client)

            let result = await adapter.send(
                makeIntent(draftID: "draft.missing"),
                idempotencyKey: "capture-save-attempt.missing",
                expectedRevision: nil
            )

            guard case let .committedCatchUpRequired(receipt) = result else {
                return XCTFail("Expected committed catch-up for incomplete returned evidence")
            }
            XCTAssertEqual(receipt.recoveryAction, .waitForProjection)
            if resultTemplate == .missingReceipt {
                XCTAssertTrue(receipt.id.hasPrefix("command.receipt.shell.capture.command-"))
                XCTAssertEqual(receipt.affectedObjects[0].id, "capture.recorded")
            } else {
                XCTAssertEqual(receipt.id, "command.receipt.recorded")
                XCTAssertTrue(receipt.affectedObjects[0].id.hasPrefix("capture.shell.capture.command-"))
            }
        }
    }

    func testRetryAgainstRealExecutorAppliesCaptureAndReceiptAuthorityOnce() async throws {
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "unused-fallback-id" })
        let records = InMemoryAmbitionsCommandExecutionRecordRepository()
        let journal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: records,
            commandJournal: journal
        )
        let client = RuntimeCommandClient(
            execute: { command, context in
                await executor.execute(command, context: context)
            },
            projection: { request in
                throw RuntimeProjectionClientError.projectionUnavailable(request)
            }
        )
        let adapter = FlagshipRuntimeIntentAdapter(runtimeCommandClient: client)
        let intent = makeIntent(draftID: "draft.real-retry")

        let first = await adapter.send(intent, idempotencyKey: "capture-save-attempt.real-retry", expectedRevision: nil)
        let retry = await adapter.send(intent, idempotencyKey: "capture-save-attempt.real-retry", expectedRevision: nil)
        let captures = try await repository.listCaptures()
        let commandEntries = try await journal.fetchEntries(matching: .all, limit: nil)
        let commandRecords = try await records.fetchRecent(limit: 10)

        XCTAssertEqual(captures.count, 1)
        XCTAssertEqual(commandEntries.count, 1)
        XCTAssertEqual(commandRecords.count, 1)
        XCTAssertEqual(first.receiptReference?.id, retry.receiptReference?.id)
        XCTAssertEqual(first.receiptReference?.affectedObjects, retry.receiptReference?.affectedObjects)
    }

    func testShellRouterSourceCannotConstructLegacyCommandOrCallExecutorDirectly() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/App/ShellCommandRouter.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(source.contains("AmbitionsCommand("))
        XCTAssertFalse(source.contains("commandExecutor.execute("))
        XCTAssertFalse(source.contains("private let commandExecutor"))
        XCTAssertTrue(source.contains("any FlagshipIntentSending"))
    }

    private func makeIntent(
        draftID: String,
        text: String = "Book dentist"
    ) -> FlagshipIntent {
        .quickCapture(
            draftID: draftID,
            text: text,
            placementID: CaptureRoute.timeSeed.rawValue,
            context: FlagshipQuickCaptureContext(
                entryPoint: .shareExtension,
                sourceType: .shareExtensionText,
                sourceSurface: "Share",
                route: .reminder,
                requestedAt: Date(timeIntervalSince1970: 1_712_692_800)
            )
        )
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(
                atPath: url.appendingPathComponent("Native/Ambitions/App/ShellCommandRouter.swift").path
            ) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private extension FlagshipIntentResult {
    var receiptReference: FlagshipReceiptReference? {
        switch self {
        case let .committedProjectionReady(receipt),
             let .committedCatchUpRequired(receipt),
             let .externalEffectPending(receipt, _),
             let .externalEffectReconciled(receipt, _),
             let .externalEffectFailed(receipt, _, _):
            return receipt
        case .rejectedBeforeMutation, .revisionConflict:
            return nil
        }
    }
}

private enum RecordedCommandResult: Equatable {
    case projectionReady
    case needsRecovery
    case duplicateProjectionCursorIDs
    case missingReceipt
    case missingCapture
    case failed

    var value: AmbitionsCommandExecutionResult {
        var metadata = [
            "commandReceiptID": "command.receipt.recorded",
            "captureMaterialization": "saved",
            "runtimeProjectionCursorCount": "1",
            "runtimeProjectionCursorIDs": "today",
            "runtimeProjectionCursorSequences": "12",
            "runtimeProjectionCursorChecksums": "cursor.today.12"
        ]
        if self == .needsRecovery {
            metadata["captureMaterialization"] = "needs_recovery"
        }
        if self == .duplicateProjectionCursorIDs {
            metadata["runtimeProjectionCursorCount"] = "2"
            metadata["runtimeProjectionCursorIDs"] = "today,today"
            metadata["runtimeProjectionCursorSequences"] = "12,13"
            metadata["runtimeProjectionCursorChecksums"] = "cursor.today.12,cursor.today.13"
        }
        if self == .missingReceipt {
            metadata.removeValue(forKey: "commandReceiptID")
        }
        return AmbitionsCommandExecutionResult(
            status: self == .failed ? .failed : .succeeded,
            summary: self == .failed ? "Capture persistence unavailable" : "Saved through authority",
            route: .captureInbox,
            target: self == .missingCapture ? nil : AmbitionsCommandTarget(
                captureID: "capture.recorded",
                destination: .captureInbox
            ),
            metadata: metadata
        )
    }
}

private actor RuntimeCommandRecorder {
    private var recordedCommands: [AmbitionsCommand] = []
    private let result: RecordedCommandResult

    init(result: RecordedCommandResult) {
        self.result = result
    }

    nonisolated var client: RuntimeCommandClient {
        RuntimeCommandClient(
            execute: { [self] command, _ in
                await record(command)
            },
            projection: { request in
                throw RuntimeProjectionClientError.projectionUnavailable(request)
            }
        )
    }

    private func record(_ command: AmbitionsCommand) -> AmbitionsCommandExecutionResult {
        recordedCommands.append(command)
        return result.value
    }

    func commands() -> [AmbitionsCommand] {
        recordedCommands
    }
}
