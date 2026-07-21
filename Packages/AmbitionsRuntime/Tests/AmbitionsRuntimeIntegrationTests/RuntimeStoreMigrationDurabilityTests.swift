import CryptoKit
import Foundation
import SQLite3
import XCTest
import AmbitionsRuntimeCore
@testable import AmbitionsRuntimeSQLite

final class RuntimeStoreMigrationDurabilityTests: XCTestCase {
    func testEveryControlConnectionUsesFullDurabilityPragmas() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )

        let settings = try await coordinator.controlDurabilitySettings()

        XCTAssertEqual(settings.journalMode, "wal")
        XCTAssertEqual(settings.synchronous, 2)
        XCTAssertEqual(settings.foreignKeys, 1)
    }

    func testCapturedSourceBackupIncludesUncheckpointedWALFrames() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.captured-wal"
        )
        let store = try RuntimeStoreSQLite(databaseURL: reservation.stagedStoreURL)
        var guardian: OpaquePointer?
        XCTAssertEqual(
            sqlite3_open_v2(
                reservation.stagedStoreURL.path,
                &guardian,
                SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
                nil
            ),
            SQLITE_OK
        )
        let openGuardian = try XCTUnwrap(guardian)
        XCTAssertEqual(
            sqlite3_exec(
                openGuardian,
                "PRAGMA journal_mode=WAL; PRAGMA wal_autocheckpoint=0;",
                nil,
                nil,
                nil
            ),
            SQLITE_OK
        )
        _ = try await store.commit(
            makeTransition(commandID: "command.captured-wal"),
            idempotencyKey: "captured-wal"
        )
        let expectations = try await makeExpectations(
            migrationIdentity: reservation.migrationIdentity,
            store: store
        )
        let snapshotDirectory = temporaryRootURL()
        try FileManager.default.createDirectory(
            at: snapshotDirectory,
            withIntermediateDirectories: true
        )
        for suffix in ["", "-wal", "-shm"] {
            try FileManager.default.copyItem(
                atPath: reservation.stagedStoreURL.path + suffix,
                toPath: snapshotDirectory
                    .appendingPathComponent("RuntimeStore.sqlite.next" + suffix)
                    .path
            )
        }
        XCTAssertEqual(sqlite3_close(openGuardian), SQLITE_OK)
        for suffix in ["", "-wal", "-shm"] {
            let stagedPath = reservation.stagedStoreURL.path + suffix
            if FileManager.default.fileExists(atPath: stagedPath) {
                try FileManager.default.removeItem(atPath: stagedPath)
            }
            try FileManager.default.moveItem(
                atPath: snapshotDirectory
                    .appendingPathComponent("RuntimeStore.sqlite.next" + suffix)
                    .path,
                toPath: stagedPath
            )
        }
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: reservation.stagedStoreURL.path + "-wal"
            )
        )

        let report = try await coordinator.verify(
            reservation: reservation,
            expectations: expectations
        )
        _ = try await coordinator.activate(
            reservation: reservation,
            verifiedReport: report,
            activatedAt: Date(timeIntervalSince1970: 12_000)
        )
        let activeURL = try await coordinator.resolveActiveStore()
        let activeStore = try RuntimeStoreSQLite(databaseURL: activeURL)
        let snapshot = try await activeStore.snapshot()

        XCTAssertEqual(snapshot.events.map(\.id), ["event.command.captured-wal"])
    }

    func testReplacedStagingDirectoryCannotEscapeRootOrMutateSourceStore() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )
        let reservation = try await coordinator.reserveStaging(
            migrationIdentity: "migration.symlink-swap"
        )
        let outsideDirectory = temporaryRootURL()
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
            .unsafeFilesystemEntry("migration.symlink-swap")
        ) {
            _ = try await coordinator.verify(
                reservation: reservation,
                expectations: expectations
            )
        }
        XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBefore)
    }

    func testReservationDoesNotCreateThroughStagingRootSymlink() async throws {
        let root = temporaryRootURL()
        let outsideDirectory = temporaryRootURL()
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: outsideDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createSymbolicLink(
            at: root.appendingPathComponent("MigrationStaging"),
            withDestinationURL: outsideDirectory
        )
        let coordinator = try RuntimeStoreMigrationCoordinator(rootDirectoryURL: root)

        await assertMigrationError(.unsafeFilesystemEntry("MigrationStaging")) {
            _ = try await coordinator.reserveStaging(
                migrationIdentity: "migration.preexisting-symlink"
            )
        }
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: outsideDirectory.appendingPathComponent(
                    "migration.preexisting-symlink"
                ).path
            )
        )
    }

    func testControlDatabaseReplacementCannotMutateOutsideAuthority() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )
        let controlURL = coordinator.rootDirectoryURL.appendingPathComponent(
            ".RuntimeStore.migration-control.sqlite"
        )
        let outsideURL = temporaryRootURL()
        try createControlDatabaseFixture(at: outsideURL)
        let outsideBefore = try fileDigest(outsideURL)
        try FileManager.default.removeItem(at: controlURL)
        try FileManager.default.createSymbolicLink(
            at: controlURL,
            withDestinationURL: outsideURL
        )

        do {
            _ = try await coordinator.reserveStaging(
                migrationIdentity: "migration.control-symlink"
            )
            XCTFail("Expected replaced control database to reject")
        } catch {
            XCTAssertTrue(error is RuntimeStoreMigrationError)
        }
        XCTAssertEqual(try fileDigest(outsideURL), outsideBefore)
    }

    func testCandidateBackupRejectsSymlinkDestination() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )
        let root = coordinator.rootDirectoryURL
        let sourceURL = root.appendingPathComponent("source.sqlite")
        let sourceStore = try RuntimeStoreSQLite(databaseURL: sourceURL)
        _ = try await sourceStore.commit(
            makeTransition(commandID: "command.backup-source"),
            idempotencyKey: "backup-source"
        )
        let outsideURL = temporaryRootURL()
        let outsideStore = try RuntimeStoreSQLite(databaseURL: outsideURL)
        _ = try await outsideStore.commit(
            makeTransition(commandID: "command.outside-candidate"),
            idempotencyKey: "outside-candidate"
        )
        let outsideBefore = try fileDigest(outsideURL)
        let candidateURL = root.appendingPathComponent("candidate.sqlite")
        try FileManager.default.createSymbolicLink(
            at: candidateURL,
            withDestinationURL: outsideURL
        )

        XCTAssertThrowsError(
            try RuntimeStoreMigrationFileSystem.backupSQLiteStore(
                sourceURL: sourceURL,
                destinationURL: candidateURL
            )
        )
        XCTAssertEqual(try fileDigest(outsideURL), outsideBefore)
    }

    func testCandidateCheckpointRejectsSymlink() async throws {
        let coordinator = try RuntimeStoreMigrationCoordinator(
            rootDirectoryURL: temporaryRootURL()
        )
        let root = coordinator.rootDirectoryURL
        let outsideURL = temporaryRootURL()
        let outsideStore = try RuntimeStoreSQLite(databaseURL: outsideURL)
        _ = try await outsideStore.commit(
            makeTransition(commandID: "command.outside-checkpoint"),
            idempotencyKey: "outside-checkpoint"
        )
        let outsideBefore = try fileDigest(outsideURL)
        let candidateURL = root.appendingPathComponent("candidate.sqlite")
        try FileManager.default.createSymbolicLink(
            at: candidateURL,
            withDestinationURL: outsideURL
        )

        XCTAssertThrowsError(
            try RuntimeStoreMigrationFileSystem.checkpointAndTruncateWAL(
                at: candidateURL
            )
        )
        XCTAssertEqual(try fileDigest(outsideURL), outsideBefore)
    }

    func testNoReplacePromotionPreservesOccupiedDestination() throws {
        let root = temporaryRootURL()
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true
        )
        let sourceURL = root.appendingPathComponent("source.sqlite")
        let destinationURL = root.appendingPathComponent("occupied.sqlite")
        let sourceBytes = Data("source".utf8)
        let destinationBytes = Data("occupied".utf8)
        try sourceBytes.write(to: sourceURL)
        try destinationBytes.write(to: destinationURL)
        let descriptor = try RuntimeStoreMigrationFileSystem.openDirectory(at: root)
        defer { RuntimeStoreMigrationFileSystem.close(descriptor) }

        XCTAssertThrowsError(
            try RuntimeStoreMigrationFileSystem.rename(
                sourceParentDescriptor: descriptor,
                sourceName: sourceURL.lastPathComponent,
                destinationParentDescriptor: descriptor,
                destinationName: destinationURL.lastPathComponent,
                operation: "promote without replacement"
            )
        )
        XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBytes)
        XCTAssertEqual(try Data(contentsOf: destinationURL), destinationBytes)
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

    private func makeTransition(commandID: String) -> RuntimeTransition {
        let aggregate = RuntimeAggregateReference(kind: "capture", id: commandID)
        let event = RuntimeEvent(
            id: "event.\(commandID)",
            kind: "capture.committed",
            aggregate: aggregate,
            aggregateRevision: 1,
            payload: Data("event.\(commandID)".utf8)
        )
        let projection = RuntimeProjectionChange(
            projection: "today.\(commandID)",
            cursor: "cursor.1",
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
                    expectedRevision: 0,
                    newRevision: 1,
                    value: Data("state.\(commandID)".utf8)
                )
            ],
            events: [event],
            projectionChanges: [projection],
            receipt: RuntimeReceipt(
                id: "receipt.\(commandID)",
                commandID: commandID,
                canonicalRevision: 1,
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

    private func fileDigest(_ url: URL) throws -> String {
        SHA256.hash(data: try Data(contentsOf: url, options: .mappedIfSafe))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func createControlDatabaseFixture(at url: URL) throws {
        var database: OpaquePointer?
        guard sqlite3_open_v2(
            url.path,
            &database,
            SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE,
            nil
        ) == SQLITE_OK, let database else {
            if let database { sqlite3_close(database) }
            throw RuntimeStoreError.sqlite("Unable to create control fixture")
        }
        defer { sqlite3_close(database) }
        let sql = """
        CREATE TABLE migration_reservations (
            reservation_identity TEXT PRIMARY KEY,
            migration_identity TEXT NOT NULL
        );
        """
        guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
            throw RuntimeStoreError.sqlite(String(cString: sqlite3_errmsg(database)))
        }
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
