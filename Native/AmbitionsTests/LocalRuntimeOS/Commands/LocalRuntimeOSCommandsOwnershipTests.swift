import XCTest
@testable import Ambitions

final class LocalRuntimeOSCommandsOwnershipTests: XCTestCase {
    func testRequiredCommandsFilesExistAtCanonicalPathsAndOldOwnersAreGone() {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommand.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandTaxonomy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandEnvelope.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandCompiler.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandAuthorizer.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandIdempotencyKey.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandJournal.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandReducer.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandRouter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandResult.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandReceiptFactory.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandReplayAdapter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/CommandValidation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventCommandReplayAdapter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/PolicyGuardedCommandExecutor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/RuntimeValidator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/StageActionPipelineContract.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let retiredOwners = [
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/AmbitionsCommand.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/CommandJournal.swift",
            "Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/CommandSpineLeafTests.swift",
            "Native/AmbitionsTests/LocalRuntimeOS/CommandSpine/LocalRuntimeOSCommandSpineOwnershipTests.swift",
            "Native/Ambitions/Projection/Commands/AmbitionsCommand.swift",
            "Native/Ambitions/Projection/Commands/CommandRouter.swift",
            "Native/Ambitions/Projection/Commands/CommandResult.swift",
            "Native/Ambitions/Projection/Commands/CommandValidation.swift",
            removedRuntimeOwnerPath("AmbitionsCommandExecutor.swift"),
            removedRuntimeOwnerPath("PolicyGuardedCommandExecutor.swift"),
            removedRuntimeOwnerPath("RuntimeValidator.swift"),
            removedRuntimeOwnerPath("ExternalActionCommandService.swift"),
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

    func testExternalActionCoreBoundaryContainsNoAppPresentationAuthority() throws {
        let sourceURL = repoRoot().appendingPathComponent(
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/ExternalActionCommandService.swift"
        )
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        for forbiddenType in [
            "AppExternalRoute",
            "AppExternalRouting",
            "AppExternalRouteSource",
            "ShellOverlayState",
        ] {
            XCTAssertFalse(
                source.contains(forbiddenType),
                "Core external-action authority must not reference App presentation type \(forbiddenType)."
            )
        }
    }

    func testCommandExecutorValidationRoutesThroughRuntimeValidator() {
        let executor = AmbitionsCommandExecutor.test()
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
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Commands")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
