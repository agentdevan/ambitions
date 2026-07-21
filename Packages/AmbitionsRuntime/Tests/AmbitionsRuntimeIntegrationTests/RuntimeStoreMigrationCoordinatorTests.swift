import CryptoKit
import Foundation
import XCTest
import AmbitionsRuntimeCore
import AmbitionsRuntimeSQLite

final class RuntimeStoreMigrationCoordinatorTests: XCTestCase {
    func testInitialActivationVerifiesAndResolvesDurableStore() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.initial"
        )
        XCTAssertEqual(reservation.schemaVersion, 1)
        XCTAssertEqual(reservation.migrationIdentity, "migration.initial")
        XCTAssertEqual(
            reservation.stagedStoreURL.lastPathComponent,
            "RuntimeStore.sqlite.next"
        )
        XCTAssertEqual(
            reservation.stagedStoreURL.deletingLastPathComponent(),
            reservation.stagingDirectoryURL
        )

        let store = try RuntimeStoreSQLite(databaseURL: reservation.stagedStoreURL)
        _ = try await store.commit(
            makeTransition(commandID: "command.initial"),
            idempotencyKey: "migration.initial"
        )
        let expectations = try await makeExpectations(
            migrationIdentity: reservation.migrationIdentity,
            store: store
        )

        let report = try await coordinator.verify(
            reservation: reservation,
            expectations: expectations
        )
        XCTAssertEqual(report.schemaVersion, 1)
        XCTAssertEqual(report.counts, expectations.counts)
        XCTAssertEqual(report.checksums, expectations.checksums)
        XCTAssertEqual(report.sqliteIntegrityResult, "ok")
        XCTAssertTrue(report.restartEquivalent)

        let activatedAt = Date(timeIntervalSince1970: 10_000)
        let pointer = try await coordinator.activate(
            reservation: reservation,
            verifiedReport: report,
            activatedAt: activatedAt
        )
        let resolved = try await coordinator.resolveActiveStore()

        XCTAssertEqual(pointer.schemaVersion, 1)
        XCTAssertEqual(pointer.migrationIdentity, "migration.initial")
        XCTAssertEqual(pointer.activatedAt, activatedAt)
        XCTAssertNil(pointer.previousStore)
        XCTAssertEqual(resolved.lastPathComponent, pointer.currentStore.filename)
        XCTAssertNotEqual(resolved.lastPathComponent, "RuntimeStore.sqlite.next")
        XCTAssertTrue(FileManager.default.fileExists(atPath: resolved.path))
        XCTAssertEqual(try fileDigest(resolved), pointer.currentStore.digest)
        let restarted = try RuntimeStoreSQLite(databaseURL: resolved)
        let restartedSnapshot = try await restarted.snapshot()
        XCTAssertEqual(restartedSnapshot.canonicalRevision, 1)
    }

    func testSecondActivationRetainsPriorStoreWithoutMutation() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let first = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.first",
            commandID: "command.first",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let firstURL = root.appendingPathComponent(first.currentStore.filename)
        let firstData = try Data(contentsOf: firstURL)

        let second = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.second",
            commandID: "command.second",
            revision: 2,
            activatedAt: Date(timeIntervalSince1970: 2_000)
        )

        XCTAssertEqual(second.previousStore, first.currentStore)
        XCTAssertEqual(try Data(contentsOf: firstURL), firstData)
        XCTAssertEqual(try fileDigest(firstURL), first.currentStore.digest)
        XCTAssertTrue(FileManager.default.fileExists(atPath: firstURL.path))
    }

    func testExactVerificationMismatchRejectsWithoutChangingActivePointer() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let active = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.active",
            commandID: "command.active",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let pointerData = try Data(contentsOf: activePointerURL(root: root))
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.mismatch"
        )
        let store = try RuntimeStoreSQLite(databaseURL: reservation.stagedStoreURL)
        _ = try await store.commit(
            makeTransition(commandID: "command.mismatch"),
            idempotencyKey: "migration.mismatch"
        )
        let observed = try await makeExpectations(
            migrationIdentity: reservation.migrationIdentity,
            store: store
        )
        let mismatched = RuntimeStoreVerificationExpectations(
            migrationIdentity: observed.migrationIdentity,
            canonicalRevision: observed.canonicalRevision,
            counts: RuntimeStoreVerificationCounts(
                stateCount: observed.counts.stateCount,
                eventCount: observed.counts.eventCount + 1,
                projectionCount: observed.counts.projectionCount,
                receiptCount: observed.counts.receiptCount,
                outboxCount: observed.counts.outboxCount
            ),
            checksums: observed.checksums
        )

        do {
            _ = try await coordinator.verify(
                reservation: reservation,
                expectations: mismatched
            )
            XCTFail("Expected exact verification mismatch")
        } catch let error as RuntimeStoreMigrationError {
            XCTAssertEqual(
                error,
                .verificationMismatch(field: "eventCount", expected: "2", actual: "1")
            )
        }

        XCTAssertEqual(try Data(contentsOf: activePointerURL(root: root)), pointerData)
        let resolved = try await coordinator.resolveActiveStore()
        XCTAssertEqual(resolved.lastPathComponent, active.currentStore.filename)
    }

    func testBeforePointerRenameFailureLeavesOldPointerActiveAfterRestart() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let old = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.old",
            commandID: "command.old",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let prepared = try await prepareStore(
            coordinator: coordinator,
            migrationIdentity: "migration.before-failure",
            commandID: "command.before-failure",
            revision: 2
        )

        do {
            _ = try await coordinator.activate(
                reservation: prepared.reservation,
                verifiedReport: prepared.report,
                activatedAt: Date(timeIntervalSince1970: 2_000),
                failurePoint: .beforePointerRename
            )
            XCTFail("Expected injected failure")
        } catch let error as RuntimeStoreMigrationError {
            XCTAssertEqual(error, .injectedFailure(.beforePointerRename))
        }

        let restarted = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let resolved = try await restarted.resolveActiveStore()
        XCTAssertEqual(resolved.lastPathComponent, old.currentStore.filename)
    }

    func testAfterPointerRenameFailureResolvesCompleteNewStoreAfterRestart() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let old = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.old",
            commandID: "command.old",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let prepared = try await prepareStore(
            coordinator: coordinator,
            migrationIdentity: "migration.after-failure",
            commandID: "command.after-failure",
            revision: 2
        )

        do {
            _ = try await coordinator.activate(
                reservation: prepared.reservation,
                verifiedReport: prepared.report,
                activatedAt: Date(timeIntervalSince1970: 2_000),
                failurePoint: .afterPointerRename
            )
            XCTFail("Expected injected failure")
        } catch let error as RuntimeStoreMigrationError {
            XCTAssertEqual(error, .injectedFailure(.afterPointerRename))
        }

        let restarted = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let resolved = try await restarted.resolveActiveStore()
        let pointer = try decodePointer(root: root)
        XCTAssertEqual(resolved.lastPathComponent, pointer.currentStore.filename)
        XCTAssertEqual(pointer.migrationIdentity, "migration.after-failure")
        XCTAssertEqual(pointer.previousStore, old.currentStore)
        XCTAssertEqual(try fileDigest(resolved), pointer.currentStore.digest)
        let store = try RuntimeStoreSQLite(databaseURL: resolved)
        let restartedSnapshot = try await store.snapshot()
        XCTAssertEqual(restartedSnapshot.canonicalRevision, 2)
    }

    func testUnsafeUnknownAndSymlinkPointersFailVisibly() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let active = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.safe",
            commandID: "command.safe",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )

        let pointerData = try Data(contentsOf: activePointerURL(root: root))
        var encoded = try JSONSerialization.jsonObject(
            with: pointerData
        ) as? [String: Any]
        try writeJSONObject(
            ["schemaVersion": 99],
            to: activePointerURL(root: root)
        )
        await assertMigrationError(.unsupportedPointerSchemaVersion(99)) {
            _ = try await coordinator.resolveActiveStore()
        }

        var current = encoded?["currentStore"] as? [String: Any]
        current?["filename"] = "../outside.sqlite"
        encoded?["currentStore"] = current
        try writeJSONObject(encoded, to: activePointerURL(root: root))
        await assertMigrationError(.unsafeStoreFilename("../outside.sqlite")) {
            _ = try await coordinator.resolveActiveStore()
        }

        let actualURL = root.appendingPathComponent(active.currentStore.filename)
        let symlinkName = "RuntimeStore.symlink.sqlite"
        let symlinkURL = root.appendingPathComponent(symlinkName)
        try FileManager.default.createSymbolicLink(at: symlinkURL, withDestinationURL: actualURL)
        let symlinkPointer = RuntimeStoreActivePointer(
            currentStore: RuntimeStoreFileIdentity(
                filename: symlinkName,
                digest: active.currentStore.digest,
                migrationIdentity: active.currentStore.migrationIdentity
            ),
            previousStore: nil,
            migrationIdentity: active.migrationIdentity,
            activatedAt: active.activatedAt
        )
        try JSONEncoder().encode(symlinkPointer).write(
            to: activePointerURL(root: root),
            options: .atomic
        )
        await assertMigrationError(.storeIsNotRegularFile(symlinkName)) {
            _ = try await coordinator.resolveActiveStore()
        }
    }

    func testDigestMismatchRejectsTamperedActiveStore() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let active = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.tamper",
            commandID: "command.tamper",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let storeURL = root.appendingPathComponent(active.currentStore.filename)
        let handle = try FileHandle(forWritingTo: storeURL)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("tamper".utf8))
        try handle.close()

        let actualDigest = try fileDigest(storeURL)
        await assertMigrationError(
            .digestMismatch(
                filename: active.currentStore.filename,
                expected: active.currentStore.digest,
                actual: actualDigest
            )
        ) {
            _ = try await coordinator.resolveActiveStore()
        }
    }

    func testRollbackAtomicallySwapsCurrentAndPreviousStores() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let first = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.first",
            commandID: "command.first",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let second = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.second",
            commandID: "command.second",
            revision: 2,
            activatedAt: Date(timeIntervalSince1970: 2_000)
        )

        let rolledBack = try await coordinator.rollback(
            activatedAt: Date(timeIntervalSince1970: 3_000)
        )

        XCTAssertEqual(rolledBack.currentStore, first.currentStore)
        XCTAssertEqual(rolledBack.previousStore, second.currentStore)
        XCTAssertEqual(rolledBack.migrationIdentity, "migration.first")
        let resolved = try await coordinator.resolveActiveStore()
        XCTAssertEqual(
            resolved.lastPathComponent,
            first.currentStore.filename
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent(second.currentStore.filename).path
            )
        )
    }

    func testRollbackWithoutValidPreviousStoreRejectsWithoutChangingPointer() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        _ = try await activateStore(
            coordinator: coordinator,
            migrationIdentity: "migration.only",
            commandID: "command.only",
            revision: 1,
            activatedAt: Date(timeIntervalSince1970: 1_000)
        )
        let before = try Data(contentsOf: activePointerURL(root: root))

        await assertMigrationError(.noPreviousStore) {
            _ = try await coordinator.rollback(
                activatedAt: Date(timeIntervalSince1970: 2_000)
            )
        }

        XCTAssertEqual(try Data(contentsOf: activePointerURL(root: root)), before)
    }

    func testMismatchedIdentityAndOutsideRootReservationRejectWithTypedErrors() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.expected"
        )
        let store = try RuntimeStoreSQLite(databaseURL: reservation.stagedStoreURL)
        let expectations = try await makeExpectations(
            migrationIdentity: "migration.other",
            store: store
        )
        await assertMigrationError(
            .mismatchedMigrationIdentity(
                expected: "migration.expected",
                actual: "migration.other"
            )
        ) {
            _ = try await coordinator.verify(
                reservation: reservation,
                expectations: expectations
            )
        }

        let outsideURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("RuntimeStore.sqlite.next")
        let forged = RuntimeStoreMigrationReservation(
            migrationIdentity: reservation.migrationIdentity,
            stagingDirectoryURL: outsideURL.deletingLastPathComponent(),
            stagedStoreURL: outsideURL
        )
        let matching = try await makeExpectations(
            migrationIdentity: reservation.migrationIdentity,
            store: store
        )
        await assertMigrationError(
            .reservationPathMismatch(
                expected: reservation.stagedStoreURL,
                actual: outsideURL
            )
        ) {
            _ = try await coordinator.verify(
                reservation: forged,
                expectations: matching
            )
        }
    }

    func testReplacedStagingDirectoryCannotEscapeRootOrMutateSourceStore() async throws {
        let root = temporaryRootURL()
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.symlink-swap"
        )
        let outsideDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceURL = outsideDirectory.appendingPathComponent(
            "RuntimeStore.sqlite.next"
        )
        let sourceStore = try RuntimeStoreSQLite(databaseURL: sourceURL)
        _ = try await sourceStore.commit(
            makeTransition(commandID: "command.source"),
            idempotencyKey: "source"
        )
        let expectations = try await makeExpectations(
            migrationIdentity: reservation.migrationIdentity,
            store: sourceStore
        )
        let sourceBefore = try Data(contentsOf: sourceURL)
        try FileManager.default.removeItem(at: reservation.stagingDirectoryURL)
        try FileManager.default.createSymbolicLink(
            at: reservation.stagingDirectoryURL,
            withDestinationURL: outsideDirectory
        )

        await assertMigrationError(
            .reservationPathMismatch(
                expected: reservation.stagingDirectoryURL,
                actual: outsideDirectory
            )
        ) {
            _ = try await coordinator.verify(
                reservation: reservation,
                expectations: expectations
            )
        }
        XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBefore)
    }

    private func activateStore(
        coordinator: RuntimeStoreMigrationCoordinator,
        migrationIdentity: String,
        commandID: String,
        revision: Int64,
        activatedAt: Date
    ) async throws -> RuntimeStoreActivePointer {
        let prepared = try await prepareStore(
            coordinator: coordinator,
            migrationIdentity: migrationIdentity,
            commandID: commandID,
            revision: revision
        )
        return try await coordinator.activate(
            reservation: prepared.reservation,
            verifiedReport: prepared.report,
            activatedAt: activatedAt
        )
    }

    private func prepareStore(
        coordinator: RuntimeStoreMigrationCoordinator,
        migrationIdentity: String,
        commandID: String,
        revision: Int64
    ) async throws -> (
        reservation: RuntimeStoreMigrationReservation,
        report: RuntimeStoreVerificationReport
    ) {
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: migrationIdentity
        )
        let store = try RuntimeStoreSQLite(databaseURL: reservation.stagedStoreURL)
        for currentRevision in 1...revision {
            let revisionCommandID = currentRevision == revision
                ? commandID
                : "\(commandID).seed.\(currentRevision)"
            _ = try await store.commit(
                makeTransition(
                    commandID: revisionCommandID,
                    aggregateID: migrationIdentity,
                    expectedRevision: currentRevision - 1,
                    newRevision: currentRevision
                ),
                idempotencyKey: "\(migrationIdentity).\(currentRevision)"
            )
        }
        let expectations = try await makeExpectations(
            migrationIdentity: migrationIdentity,
            store: store
        )
        let report = try await coordinator.verify(
            reservation: reservation,
            expectations: expectations
        )
        return (reservation, report)
    }

    private func makeExpectations(
        migrationIdentity: String,
        store: RuntimeStoreSQLite
    ) async throws -> RuntimeStoreVerificationExpectations {
        let snapshot = try await store.snapshot()
        let outbox = try await store.externalEffectRecords()
        return try RuntimeStoreVerificationExpectations(
            migrationIdentity: migrationIdentity,
            canonicalRevision: snapshot.canonicalRevision,
            counts: RuntimeStoreVerificationCounts(
                stateCount: snapshot.stateChanges.count,
                eventCount: snapshot.events.count,
                projectionCount: snapshot.projectionChanges.count,
                receiptCount: snapshot.receipts.count,
                outboxCount: outbox.count
            ),
            checksums: RuntimeStoreStableChecksums(
                snapshot: snapshot,
                outbox: outbox
            )
        )
    }

    private func makeTransition(
        commandID: String,
        aggregateID: String? = nil,
        expectedRevision: Int64 = 0,
        newRevision: Int64 = 1
    ) -> RuntimeTransition {
        let aggregate = RuntimeAggregateReference(
            kind: "capture",
            id: aggregateID ?? commandID
        )
        let event = RuntimeEvent(
            id: "event.\(commandID)",
            kind: "capture.committed",
            aggregate: aggregate,
            aggregateRevision: newRevision,
            payload: Data("event.\(commandID)".utf8)
        )
        let projection = RuntimeProjectionChange(
            projection: "today.\(commandID)",
            cursor: "cursor.\(newRevision)",
            payload: Data("projection.\(commandID)".utf8)
        )
        let effect = RuntimeExternalEffectEnvelope(
            id: "effect.\(commandID)",
            kind: "extension.snapshot.refresh",
            idempotencyKey: "effect.\(commandID)",
            payload: Data("effect.\(commandID)".utf8)
        )
        return RuntimeTransition(
            commandID: commandID,
            stateChanges: [
                RuntimeStateChange(
                    aggregate: aggregate,
                    expectedRevision: expectedRevision,
                    newRevision: newRevision,
                    value: Data("state.\(commandID)".utf8)
                )
            ],
            events: [event],
            projectionChanges: [projection],
            receipt: RuntimeReceipt(
                id: "receipt.\(commandID)",
                commandID: commandID,
                canonicalRevision: newRevision,
                eventIDs: [event.id],
                projectionCursors: [projection.projection: projection.cursor],
                externalEffectIDs: [effect.id],
                semanticUndoEligible: false
            ),
            compensation: nil,
            externalEffects: [effect]
        )
    }

    private func temporaryRootURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private func activePointerURL(root: URL) -> URL {
        root.appendingPathComponent("RuntimeStore.active.json")
    }

    private func decodePointer(root: URL) throws -> RuntimeStoreActivePointer {
        try JSONDecoder().decode(
            RuntimeStoreActivePointer.self,
            from: Data(contentsOf: activePointerURL(root: root))
        )
    }

    private func fileDigest(_ url: URL) throws -> String {
        SHA256.hash(data: try Data(contentsOf: url, options: .mappedIfSafe))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func writeJSONObject(_ object: [String: Any]?, to url: URL) throws {
        let value = try XCTUnwrap(object)
        try JSONSerialization.data(withJSONObject: value).write(to: url, options: .atomic)
    }

    private func assertMigrationError(
        _ expected: RuntimeStoreMigrationError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected \(expected)")
        } catch let error as RuntimeStoreMigrationError {
            XCTAssertEqual(error, expected)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
