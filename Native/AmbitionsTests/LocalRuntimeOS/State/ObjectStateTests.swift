@testable import Ambitions
import XCTest

final class ObjectStateTests: XCTestCase {
    func testObjectStateOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationContext.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateContracts.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/State/AppStateStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/State/YouPreferencesCommandService.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(removedRuntimeOwnerPath("ObjectState.swift")).path),
            "ObjectState must not be owned by the removed runtime owner."
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/ObjectState").path),
            "The old LocalRuntimeOS/ObjectState production owner must be removed after the State rename."
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/AmbitionsTests/LocalRuntimeOS/ObjectState").path),
            "The old LocalRuntimeOS/ObjectState test owner must be removed after the State rename."
        )
    }

    func testRuntimeMutationContextIsTransactionsOwnedAndRequiredByWriteStores() throws {
        let root = try repoRoot()
        let contextSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationContext.swift"),
            encoding: .utf8
        )
        let objectStateSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateCore.swift"),
            encoding: .utf8
        )
        let contractsSource = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/State/ObjectStateContracts.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(contextSource.contains("runtimeMutationContextSchemaVersion"))
        XCTAssertTrue(contextSource.contains("struct RuntimeMutationContext"))
        XCTAssertFalse(objectStateSource.contains("struct RuntimeObjectStateMutationContext"))
        XCTAssertTrue(contractsSource.contains("protocol ObjectStateReadableStore"))
        XCTAssertTrue(contractsSource.contains("protocol RuntimeObjectStateWritableStore"))
        XCTAssertTrue(contractsSource.contains("context: RuntimeMutationContext"))
        XCTAssertFalse(contractsSource.contains("context: RuntimeObjectStateMutationContext"))
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

        let unsanctionedContext = try decodedRuntimeMutationContext(
            commandID: "",
            rollbackPlanID: "rollback.app-state"
        )

        await XCTAssertObjectStateThrowsErrorAsync {
            _ = try await objectStore.save(state, context: unsanctionedContext)
        } assert: { error in
            XCTAssertEqual(error as? ObjectStateContractError, .missingCommand(.appState))
        }

        let missingRollbackContext = try decodedRuntimeMutationContext(
            commandID: "command.app-state",
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
            kind: .updateUserPreferences,
            source: .you,
            target: AmbitionsCommandTarget(destination: .you),
            payload: AmbitionsCommandPayload(title: "Save local app state"),
            createdAt: "2026-06-30T09:05:00Z",
            actor: .user,
            privacy: .standard
        )
        let eventStore = InMemoryRuntimeEventStore(deviceID: "object-state-test-device")
        let coordinator = RuntimeTransactionCoordinator(eventStore: eventStore)
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "App state saved locally.",
            target: command.target,
            eventLedgerEntryIDs: ["event-ledger.app-state"],
            metadata: ["objectStateFamily": ObjectStateFamily.appState.rawValue]
        )
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-06-30T09:05:01Z"))
        let outcome = try await coordinator.commit(
            command: command,
            beforeSnapshot: "app-state.before",
            afterSnapshot: "app-state.after",
            targetSurface: .you,
            executionResult: result,
            occurredAt: occurredAt
        )
        let context = try coordinator.issueMutationContext(
            family: .appState,
            projectionID: .privacy,
            from: outcome
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
        XCTAssertEqual(receipt.transactionID, outcome.receipt.transactionID)
        XCTAssertEqual(receipt.eventID, outcome.receipt.eventID)
        XCTAssertEqual(receipt.projectionID, .privacy)
        XCTAssertTrue(context.projectionPlan.contains(.privacy))
        XCTAssertEqual(Set(context.projectionPlan), Set(outcome.receipt.projectionCursors.map(\.projectionID)))
        XCTAssertEqual(receipt.receiptID, outcome.receipt.receiptID)
        XCTAssertEqual(receipt.replayTraceID, outcome.receipt.replayTraceID)
        XCTAssertEqual(receipt.rollbackPlanID, outcome.receipt.rollbackPlanID)
        XCTAssertTrue(receipt.localOnly)
        XCTAssertEqual(persistedEvents.map(\.id), [outcome.receipt.eventID])
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

    func decodedRuntimeMutationContext(
        commandID: String,
        rollbackPlanID: String,
        projectionPlan: [String] = ["privacy"]
    ) throws -> RuntimeMutationContext {
        let encodedProjectionPlan = projectionPlan.map { "\"\($0)\"" }.joined(separator: ",")
        let payload = """
        {
          "family": "app_state",
          "commandID": "\(commandID)",
          "transactionID": "transaction.app-state",
          "eventID": "runtime.event.app-state",
          "projectionID": "privacy",
          "projectionPlan": [\(encodedProjectionPlan)],
          "receiptID": "receipt.app-state",
          "replayTraceID": "replay.app-state",
          "actor": "user",
          "source": "you",
          "privacy": "standard",
          "occurredAt": "2026-06-30T09:00:00Z",
          "localOnly": true,
          "rollbackPlanID": "\(rollbackPlanID)"
        }
        """
        return try JSONDecoder().decode(RuntimeMutationContext.self, from: Data(payload.utf8))
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
