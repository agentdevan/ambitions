import XCTest
@testable import Ambitions

final class LocalRuntimeOSCommandSpineOwnershipTests: XCTestCase {
    func testRequiredCommandSpineFilesExistAtCanonicalPathsAndOldOwnersAreGone() {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommand.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandTaxonomy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandEnvelope.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandAuthorizer.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandIdempotencyKey.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandReducer.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandRouter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandResult.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandReceiptFactory.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandReplayAdapter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandValidation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommandExecutor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/PolicyGuardedCommandExecutor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/RuntimeValidator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/ExternalActionCommandService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/StageActionPipelineContract.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let retiredOwners = [
            "Native/Ambitions/Projection/Commands/AmbitionsCommand.swift",
            "Native/Ambitions/Projection/Commands/CommandRouter.swift",
            "Native/Ambitions/Projection/Commands/CommandResult.swift",
            "Native/Ambitions/Projection/Commands/CommandValidation.swift",
            "Native/Ambitions/Core/Runtime/AmbitionsCommandExecutor.swift",
            "Native/Ambitions/Core/Runtime/PolicyGuardedCommandExecutor.swift",
            "Native/Ambitions/Core/Runtime/RuntimeValidator.swift",
            "Native/Ambitions/Core/Runtime/ExternalActionCommandService.swift",
            "Native/Ambitions/Core/Domain/AmbitionsCommandModels.swift"
        ]

        for path in retiredOwners {
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testCommandRouterOwnsNowActionProjection() {
        let action = NowAction(
            id: "action-command-router",
            kind: .completeAction,
            state: .active,
            title: "Send the update",
            subtitle: "Today",
            reference: NowActionReference(goalID: "goal", stepID: "step"),
            eventLedgerEntryIDs: ["event-1"]
        )

        let route = CommandRouter().route(action)
        let command = AmbitionsCommand.fromNowAction(
            action,
            id: "command-router-proof",
            createdAt: "2026-06-20T12:00:00Z"
        )

        XCTAssertEqual(route.kind, .completeAction)
        XCTAssertNil(route.destination)
        XCTAssertEqual(command.kind, .completeAction)
        XCTAssertEqual(command.validationState, .valid)
        XCTAssertEqual(command.relations.eventLedgerEntryIDs, ["event-1"])
    }

    func testCommandValidationAndResultStayLocalAndStructured() {
        let command = AmbitionsCommand(
            id: "command-validation-proof",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Hold this locally"),
            createdAt: "2026-06-20T12:00:00Z",
            privacy: .privateUserText
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Captured locally.",
            route: .captureInbox,
            target: command.target,
            eventLedgerEntryIDs: ["event-2", "event-2"]
        )
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: "2026-06-20T12:00:01Z"
        )

        XCTAssertEqual(AmbitionsCommandValidator().validate(command), .valid)
        XCTAssertEqual(result.eventLedgerEntryIDs, ["event-2"])
        XCTAssertTrue(record.localOnly)
        XCTAssertEqual(record.privacy, .privateUserText)
    }

    func testCommandExecutorValidationRoutesThroughRuntimeValidator() {
        let executor = AmbitionsCommandExecutor()
        let command = AmbitionsCommand(
            id: "command-empty-capture",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "   "),
            createdAt: "2026-04-25T12:00:00Z"
        )

        XCTAssertEqual(executor.validate(command), .invalid)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/CommandSpine")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
