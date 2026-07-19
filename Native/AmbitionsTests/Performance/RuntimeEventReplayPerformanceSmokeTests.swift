@testable import Ambitions
import Dispatch
import Foundation
import XCTest

final class RuntimeEventReplayPerformanceSmokeTests: XCTestCase {
    func testRuntimeEventReplayAppendAndLookupSmokeStaysUnderBudget() async throws {
        let observation = try await measureAppendAndReplaySmoke()

        XCTAssertEqual(observation.operationID, RuntimeEventReplaySmokeBudget.operationID)
        XCTAssertEqual(observation.storeKind, .inMemory)
        XCTAssertEqual(observation.eventCount, RuntimeEventReplaySmokeBudget.eventCount)
        XCTAssertEqual(observation.replayLookupCount, RuntimeEventReplaySmokeBudget.replayLookupCount)
        XCTAssertLessThanOrEqual(
            observation.elapsedMilliseconds,
            RuntimeEventReplaySmokeBudget.maximumElapsedMilliseconds,
            observation.failureSummary
        )
    }

    func testRuntimeEventReplaySmokeMetadataRecordsEnvironmentAndThreshold() async throws {
        let observation = try await measureAppendAndReplaySmoke()

        XCTAssertEqual(observation.maximumElapsedMilliseconds, RuntimeEventReplaySmokeBudget.maximumElapsedMilliseconds)
        XCTAssertFalse(observation.environment.operatingSystemVersion.isEmpty)
        XCTAssertFalse(observation.environment.processName.isEmpty)
        XCTAssertGreaterThanOrEqual(observation.environment.activeProcessorCount, 1)
        XCTAssertTrue(observation.environment.proofScope.contains("simulator-or-local-host-smoke"))
    }
}

private extension RuntimeEventReplayPerformanceSmokeTests {
    func measureAppendAndReplaySmoke() async throws -> RuntimeEventReplaySmokeObservation {
        let store = InMemoryRuntimeEventStore(deviceID: "amb-1816-performance-smoke")
        let replay = RuntimeEventReplay(store: store)
        let start = DispatchTime.now().uptimeNanoseconds

        for index in 0..<RuntimeEventReplaySmokeBudget.eventCount {
            try await store.append(makeCommandExecutionEvent(index: index))
        }

        for index in 0..<RuntimeEventReplaySmokeBudget.replayLookupCount {
            let commandID = "command.performance.\(index % RuntimeEventReplaySmokeBudget.eventCount)"
            let projection = try await replay.replay(commandID: commandID)
            XCTAssertEqual(projection?.commandID, commandID)
            XCTAssertEqual(projection?.resultStatus, .succeeded)
        }

        let end = DispatchTime.now().uptimeNanoseconds
        let elapsedMilliseconds = Double(end - start) / 1_000_000
        return RuntimeEventReplaySmokeObservation(
            elapsedMilliseconds: elapsedMilliseconds,
            storeKind: store.storeKind,
            environment: RuntimeEventReplaySmokeEnvironment.current()
        )
    }

    func makeCommandExecutionEvent(index: Int) -> RuntimeEvent {
        let commandID = "command.performance.\(index)"
        let captureID = "capture.performance.\(index)"
        let command = AmbitionsCommand(
            id: commandID,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Performance smoke capture \(index)"),
            createdAt: "2026-07-05T18:45:\(String(format: "%02d", index % 60))Z",
            sourceSurface: "performance-smoke"
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Performance smoke capture persisted.",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.performance.\(index)"],
            recommendationExplanationIDs: ["explanation.performance.\(index)"],
            metadata: [
                "captureID": captureID,
                "performanceSmoke": RuntimeEventReplaySmokeBudget.operationID,
            ]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-07-05T18:45:\(String(format: "%02d", index % 60))Z",
            commandRecordID: "command.execution.performance.\(index)"
        )
    }
}

private enum RuntimeEventReplaySmokeBudget {
    static let operationID = "runtime.event_replay.append_lookup"
    static let eventCount = 160
    static let replayLookupCount = 160
    static let maximumElapsedMilliseconds = 1_500.0
}

private struct RuntimeEventReplaySmokeObservation {
    let operationID = RuntimeEventReplaySmokeBudget.operationID
    let elapsedMilliseconds: Double
    let maximumElapsedMilliseconds = RuntimeEventReplaySmokeBudget.maximumElapsedMilliseconds
    let eventCount = RuntimeEventReplaySmokeBudget.eventCount
    let replayLookupCount = RuntimeEventReplaySmokeBudget.replayLookupCount
    let storeKind: RuntimeEventStoreKind
    let environment: RuntimeEventReplaySmokeEnvironment

    var failureSummary: String {
        [
            "operation=\(operationID)",
            "elapsed_ms=\(String(format: "%.3f", elapsedMilliseconds))",
            "maximum_ms=\(String(format: "%.3f", maximumElapsedMilliseconds))",
            "event_count=\(eventCount)",
            "replay_lookup_count=\(replayLookupCount)",
            "store_kind=\(storeKind.rawValue)",
            "os=\(environment.operatingSystemVersion)",
            "process=\(environment.processName)",
            "active_processors=\(environment.activeProcessorCount)",
            "thermal_state=\(environment.thermalState)",
            "proof_scope=\(environment.proofScope)",
        ].joined(separator: " ")
    }
}

private struct RuntimeEventReplaySmokeEnvironment {
    let operatingSystemVersion: String
    let processName: String
    let activeProcessorCount: Int
    let thermalState: String
    let isRunningUnderXCTest: Bool
    let proofScope: String

    static func current(processInfo: ProcessInfo = .processInfo) -> RuntimeEventReplaySmokeEnvironment {
        RuntimeEventReplaySmokeEnvironment(
            operatingSystemVersion: processInfo.operatingSystemVersionString,
            processName: processInfo.processName,
            activeProcessorCount: processInfo.activeProcessorCount,
            thermalState: String(describing: processInfo.thermalState),
            isRunningUnderXCTest: processInfo.environment["XCTestConfigurationFilePath"] != nil,
            proofScope: "simulator-or-local-host-smoke; not device performance readiness"
        )
    }
}
