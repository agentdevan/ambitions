import XCTest
@testable import Ambitions

final class CommandsCanonicalOwnershipTests: XCTestCase {
    func testRequiredCommandFilesExistAtCanonicalPathsAndOldOwnerIsGone() {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Projection/Commands/AmbitionsCommand.swift",
            "Native/Ambitions/Projection/Commands/CommandRouter.swift",
            "Native/Ambitions/Projection/Commands/CommandResult.swift",
            "Native/Ambitions/Projection/Commands/CommandValidation.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/AmbitionsCommandModels.swift").path
            )
        )
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

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
