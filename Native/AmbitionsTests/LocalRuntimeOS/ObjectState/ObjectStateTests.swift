@testable import Ambitions
import XCTest

final class ObjectStateTests: XCTestCase {
    func testObjectStateOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/ObjectStateCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/ObjectStateContracts.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ObjectState/AppStateStore.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Runtime/ObjectState.swift").path),
            "ObjectState must not be owned by the legacy Core/Runtime owner."
        )
    }

    func testObjectStateRegistryTracksAllFamiliesAndDoesNotPromoteSwiftDataAsMutationAuthority() {
        let manifest = ObjectStateRegistry.current

        XCTAssertEqual(Set(manifest.requiredFamilies), Set(ObjectStateFamily.allCases))
        XCTAssertEqual(Set(manifest.descriptors.map(\.id)), Set(ObjectStateFamily.allCases))
        XCTAssertTrue(manifest.commandEventProjectionReceiptReplayRequired)
        XCTAssertFalse(manifest.swiftDataIsMutationAuthority)
        XCTAssertEqual(manifest.migratedFamilies, [.appState])
        XCTAssertEqual(manifest.descriptor(for: .appState)?.adapterOwner, "SwiftDataAppStateStore")
        XCTAssertEqual(manifest.descriptor(for: .appState)?.privacyClass, .systemOwned)
        XCTAssertEqual(manifest.descriptor(for: .appState)?.supersessionPolicy, .replaceCurrentSnapshot)
        XCTAssertTrue(manifest.remainingTrackedFamilies.contains(.goalThread))
        XCTAssertTrue(manifest.remainingTrackedFamilies.contains(.capture))
        XCTAssertTrue(manifest.descriptors.filter { $0.id != .appState }.allSatisfy { $0.remainingDirectWriteDebt?.isEmpty == false })
    }

    func testAppStateStoreRejectsWritesWithoutSanctionedRuntimeContext() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let objectStore = SwiftDataAppStateStore(store: store)
        var state = AppStateSnapshot.default
        state.userDisplayName = "Blocked"

        let unsanctionedContext = RuntimeObjectStateMutationContext(
            family: .appState,
            commandID: "",
            transactionID: "transaction.app-state",
            eventID: "runtime.event.app-state",
            projectionID: .privacy,
            receiptID: "receipt.app-state",
            replayTraceID: "replay.app-state",
            actor: .user,
            source: .you,
            privacy: .standard,
            occurredAt: "2026-06-30T09:00:00Z",
            rollbackPlanID: "rollback.app-state"
        )

        await XCTAssertObjectStateThrowsErrorAsync {
            _ = try await objectStore.save(state, context: unsanctionedContext)
        } assert: { error in
            XCTAssertEqual(error as? ObjectStateContractError, .missingCommand(.appState))
        }

        let missingRollbackContext = RuntimeObjectStateMutationContext(
            family: .appState,
            commandID: "command.app-state",
            transactionID: "transaction.app-state",
            eventID: "runtime.event.app-state",
            projectionID: .privacy,
            receiptID: "receipt.app-state",
            replayTraceID: "replay.app-state",
            actor: .user,
            source: .you,
            privacy: .standard,
            occurredAt: "2026-06-30T09:00:00Z",
            rollbackPlanID: ""
        )

        await XCTAssertObjectStateThrowsErrorAsync {
            _ = try await objectStore.save(state, context: missingRollbackContext)
        } assert: { error in
            XCTAssertEqual(error as? ObjectStateContractError, .missingRollback(.appState))
        }

        let loaded = try await objectStore.loadState()
        XCTAssertEqual(loaded.userDisplayName, "")
    }

    func testAppStateStoreWritesOnlyAfterCommandEventProjectionReceiptReplayContext() async throws {
        let persistenceStore = try AmbitionsPersistenceStore(inMemory: true)
        let objectStore = SwiftDataAppStateStore(store: persistenceStore)
        let command = AmbitionsCommand(
            id: "command.app-state.preferences",
            kind: .updateGoal,
            source: .you,
            target: AmbitionsCommandTarget(goalID: "goal-for-last-opened"),
            payload: AmbitionsCommandPayload(title: "Save local app state"),
            createdAt: "2026-06-30T09:05:00Z",
            actor: .user,
            privacy: .standard
        )
        let eventStore = InMemoryRuntimeEventStore(deviceID: "object-state-test-device")
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "App state saved locally.",
            target: command.target,
            eventLedgerEntryIDs: ["event-ledger.app-state"],
            metadata: ["objectStateFamily": ObjectStateFamily.appState.rawValue]
        )
        let eventEnvelope = try await eventStore.append(
            RuntimeEvent.commandExecution(
                command: command,
                result: result,
                recordedAt: "2026-06-30T09:05:01Z",
                commandRecordID: "command.execution.app-state"
            )
        )
        let context = RuntimeObjectStateMutationContext(
            family: .appState,
            command: command,
            transactionID: "runtime.transaction.app-state",
            eventEnvelope: eventEnvelope,
            projectionID: .privacy,
            receiptID: "runtime.receipt.command.app-state.preferences",
            replayTraceID: "runtime.replay.command.app-state.preferences",
            rollbackPlanID: "runtime.rollback.command.app-state.preferences"
        )
        var state = AppStateSnapshot.default
        state.userDisplayName = "Object State"
        state.preferredTab = .you
        state.lastOpenedGoalID = "goal-for-last-opened"

        let receipt = try await objectStore.save(state, context: context)
        let loaded = try await objectStore.loadState()
        let persistedEvents = try await eventStore.fetchEvents(matching: .commandID(command.id), limit: nil)

        XCTAssertEqual(loaded.userDisplayName, "Object State")
        XCTAssertEqual(loaded.preferredTab, .you)
        XCTAssertEqual(loaded.lastOpenedGoalID, "goal-for-last-opened")
        XCTAssertEqual(receipt.identity.family, .appState)
        XCTAssertEqual(receipt.identity.id, AppStateSnapshot.default.id)
        XCTAssertEqual(receipt.commandID, command.id)
        XCTAssertEqual(receipt.transactionID, "runtime.transaction.app-state")
        XCTAssertEqual(receipt.eventID, eventEnvelope.id)
        XCTAssertEqual(receipt.projectionID, .privacy)
        XCTAssertEqual(receipt.receiptID, "runtime.receipt.command.app-state.preferences")
        XCTAssertEqual(receipt.replayTraceID, "runtime.replay.command.app-state.preferences")
        XCTAssertEqual(receipt.rollbackPlanID, "runtime.rollback.command.app-state.preferences")
        XCTAssertTrue(receipt.localOnly)
        XCTAssertEqual(persistedEvents.map(\.id), [eventEnvelope.id])
    }
}

private extension ObjectStateTests {
    func repoRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
        }
        throw NSError(domain: "ObjectStateTests", code: 1)
    }
}

private func XCTAssertObjectStateThrowsErrorAsync<T>(
    _ expression: () async throws -> T,
    assert errorHandler: (Error) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
