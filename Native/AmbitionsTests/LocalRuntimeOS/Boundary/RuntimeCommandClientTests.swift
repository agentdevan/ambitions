import Foundation
import XCTest
@testable import Ambitions

final class RuntimeCommandClientTests: XCTestCase {
    func testSuppliedClientReplaysDuplicateCommandIDWithSameReceiptID() async {
        let fake = RecordingRuntimeCommandClient()
        let client = RuntimeCommandClient(
            execute: { command, context in
                await fake.execute(command, context: context)
            },
            projection: { request in
                try await fake.projection(request)
            }
        )
        let command = AmbitionsCommand(
            id: "command.runtime-client.duplicate",
            kind: .openDestination,
            source: .today,
            target: AmbitionsCommandTarget(destination: .today),
            createdAt: "2026-07-10T12:00:00Z"
        )
        let context = CommandExecutionContext(
            now: Date(timeIntervalSince1970: 1_783_684_800),
            sourceSurface: "today"
        )

        let first = await client.execute(command, context)
        let duplicate = await client.execute(command, context)
        let executionCount = await fake.executionCount

        XCTAssertEqual(first.metadata["commandReceiptID"], "command.receipt.command.runtime-client.duplicate")
        XCTAssertEqual(duplicate.metadata["commandReceiptID"], first.metadata["commandReceiptID"])
        XCTAssertEqual(executionCount, 2)
    }

    func testRuntimeCommandClientDeclaresNoProductionLiveDefault() throws {
        let source = try String(contentsOf: runtimeCommandClientSourceURL(), encoding: .utf8)

        XCTAssertFalse(source.contains("static let live"))
        XCTAssertFalse(source.contains("static var live"))
        XCTAssertFalse(source.contains("static func live"))
    }

    func testProductionExecutorRequiresDurableDependenciesExplicitly() throws {
        let source = try String(contentsOf: productionExecutorSourceURL(), encoding: .utf8)
        let requiredParameters = [
            "eventLedger",
            "commandExecutionRecords",
            "runtimeEvents",
            "projectionStore",
            "commandJournal",
            "runtimeTransactionIdempotencyStore",
            "receiptFactory",
        ]

        for parameter in requiredParameters {
            guard let line = source.split(separator: "\n").first(where: {
                $0.trimmingCharacters(in: .whitespaces).hasPrefix("\(parameter):")
            }) else {
                return XCTFail("Missing production dependency parameter: \(parameter)")
            }
            XCTAssertFalse(
                line.contains(" = "),
                "Production dependency \(parameter) must not construct a default: \(line)"
            )
        }
    }

    private func runtimeCommandClientSourceURL() -> URL {
        repositoryRoot().appendingPathComponent(
            "Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift"
        )
    }

    private func productionExecutorSourceURL() -> URL {
        repositoryRoot().appendingPathComponent(
            "Native/Ambitions/Core/LocalRuntimeOS/Commands/AmbitionsCommandExecutor.swift"
        )
    }

    private func repositoryRoot() -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.pathComponents.count > 1 {
            candidate.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private actor RecordingRuntimeCommandClient {
    private(set) var executionCount = 0
    private var resultsByCommandID: [String: AmbitionsCommandExecutionResult] = [:]

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) -> AmbitionsCommandExecutionResult {
        executionCount += 1
        if let replay = resultsByCommandID[command.id] {
            return replay
        }
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Supplied runtime client executed the command.",
            route: command.target.destination,
            target: command.target,
            metadata: [
                "commandReceiptID": "command.receipt.\(command.id)",
                "executedAt": DomainTimestamp.string(from: context.now),
            ]
        )
        resultsByCommandID[command.id] = result
        return result
    }

    func projection(_ request: RuntimeProjectionRequest) throws -> RuntimeProjectionSnapshot {
        throw RuntimeProjectionClientError.projectionUnavailable(request)
    }
}
