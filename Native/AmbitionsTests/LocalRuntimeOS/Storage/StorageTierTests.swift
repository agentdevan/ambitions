@testable import Ambitions
import CryptoKit
import XCTest

final class StorageTierTests: XCTestCase {
    func testStorageOwnerFilesExistUnderCanonicalTreeAndOldLocalStoreOwnerIsRemoved() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/LocalRuntimeStorageCore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/EventStoreSQLite.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/SearchStoreFTS.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/BlobStoreFileSystem.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/BackupStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/MigrationStore.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Persistence/LocalStore.swift").path),
            "SwiftData object-store source must not remain owned by Core/Persistence/LocalStore.swift"
        )
    }

    func testStorageManifestAndSwiftDataObjectStoreDeclareAuthorityBoundaries() {
        let manifest = LocalRuntimeStorageManifest.current
        XCTAssertEqual(Set(manifest.tiers.map(\.id)), Set(LocalRuntimeStorageTier.allCases))
        XCTAssertTrue(manifest.commandEventProjectionReceiptReplayRequired)
        XCTAssertTrue(manifest.swiftDataIsOnlyObjectStore)

        let objectManifest = ObjectStoreSwiftData.objectStoreManifest
        XCTAssertEqual(objectManifest.storageTier, .objectStoreSwiftData)
        XCTAssertFalse(objectManifest.swiftDataIsCanonicalBackend)
        XCTAssertTrue(objectManifest.storedModelNames.contains("GoalRecord"))
        XCTAssertTrue(objectManifest.families.contains { $0.id == .goalThread })
        XCTAssertTrue(objectManifest.families.flatMap(\.fieldRules).contains {
            $0.storedTypeName == "GoalRecord" &&
                $0.fieldName == "snapshotData" &&
                $0.authority == .snapshotFallback
        })
    }

    func testEventStoreSQLiteAppendsQueriesAndPreservesChecksumChain() async throws {
        let store = EventStoreSQLite(databaseURL: try scratchDirectory().appendingPathComponent("events.sqlite"), deviceID: "storage-test-device")
        let first = try await store.append(makeCommandEvent(id: "command-storage-first", captureID: "capture-storage-first"))
        let second = try await store.append(makeProofEvent(id: "proof-storage", goalID: "goal-storage"))

        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertEqual(second.previousChecksum, first.checksum)
        let latestCursor = try await store.latestCursor()
        let eventsAfterFirst = try await store.fetchEvents(matching: .after(first.cursor), limit: nil).map(\.id)
        let proofEvents = try await store.fetchEvents(matching: .kind(.proofAttached), limit: nil).map(\.id)
        XCTAssertEqual(latestCursor, second.cursor)
        XCTAssertEqual(eventsAfterFirst, [second.id])
        XCTAssertEqual(proofEvents, [second.id])

        let health = try await store.health()
        XCTAssertEqual(health.eventCount, 2)
        XCTAssertEqual(health.checksumHead, second.checksum)
        XCTAssertEqual(health.storageTier, .eventStoreSQLite)
    }

    func testProjectionStoreSQLitePersistsProjectionPayloadsAndCursors() async throws {
        let eventStore = InMemoryRuntimeEventStore(deviceID: "projection-storage-test")
        _ = try await eventStore.append(makeCommandEvent(id: "command-projection-storage", captureID: "capture-projection-storage"))
        _ = try await eventStore.append(makeProofEvent(id: "proof-projection-storage", goalID: "goal-projection-storage"))
        let batch = try await ProjectionMaterializer(store: eventStore).materializeAll(materializedAt: "2026-06-30T07:00:00Z")

        let projectionStore = ProjectionStoreSQLite(databaseURL: try scratchDirectory().appendingPathComponent("projections.sqlite"))
        try await projectionStore.save(batch: batch, updatedAt: "2026-06-30T07:01:00Z")

        let todayRecord = try await projectionStore.fetchRecord(id: .today)
        let searchRecord = try await projectionStore.fetchRecord(id: .search)
        let health = try await projectionStore.health()

        XCTAssertEqual(todayRecord?.cursor, batch.today.cursor)
        XCTAssertEqual(searchRecord?.cursor, batch.search.cursor)
        XCTAssertEqual(health.projectionCount, ProjectionID.allCases.count)
        XCTAssertEqual(Set(health.storedProjectionIDs), Set(ProjectionID.allCases))
        let privacyCursor = try await projectionStore.fetchCursor(id: .privacy)
        XCTAssertEqual(privacyCursor, batch.privacy.cursor)
    }

    func testSearchStoreFTSRebuildsFromSearchProjectionAndFiltersPrivacy() async throws {
        let eventStore = InMemoryRuntimeEventStore(deviceID: "search-storage-test")
        _ = try await eventStore.append(makeCommandEvent(id: "command-public-search", captureID: "capture-public-search", summary: "Captured public appointment"))
        _ = try await eventStore.append(makePrivateCommandEvent())
        let batch = try await ProjectionMaterializer(store: eventStore).materializeAll(materializedAt: "2026-06-30T07:05:00Z")

        let searchStore = SearchStoreFTS(databaseURL: try scratchDirectory().appendingPathComponent("search.sqlite"))
        try await searchStore.rebuild(from: batch.search, updatedAt: "2026-06-30T07:06:00Z")

        let allMatches = try await searchStore.search(SearchStoreFTSQuery(rawText: "Captured", limit: 10))
        let publicOnly = try await searchStore.search(SearchStoreFTSQuery(rawText: "private", allowedPrivacy: [.standard], limit: 10))

        XCTAssertTrue(allMatches.contains { $0.eventID == "runtime.event.1" })
        XCTAssertFalse(publicOnly.contains { $0.privacy == .privateUserText })
        let searchHealth = try await searchStore.health()
        XCTAssertEqual(searchHealth.indexedRecordCount, batch.search.results.count)
    }

    func testBlobAppGroupBackupAndMigrationStoresEnforceStorageBoundaries() async throws {
        let directory = try scratchDirectory()

        let blobStore = BlobStoreFileSystem(rootDirectory: directory.appendingPathComponent("blobs", isDirectory: true))
        let blobRecord = try await blobStore.write(
            id: "proof-attachment",
            data: Data("attachment".utf8),
            contentType: "text/plain",
            protectionClass: .completeUntilFirstUserAuthentication,
            createdAt: "2026-06-30T07:10:00Z"
        )
        let storedBlobData = try await blobStore.read(id: blobRecord.id)
        let blobHealth = try await blobStore.health()
        XCTAssertEqual(storedBlobData, Data("attachment".utf8))
        XCTAssertEqual(blobHealth.blobCount, 1)

        let appGroupStore = AppGroupSnapshotStore(rootDirectory: directory.appendingPathComponent("snapshots", isDirectory: true))
        let safeSnapshot = AppGroupSnapshotRecord(
            id: "widget-safe",
            snapshotKind: "widget",
            createdAt: "2026-06-30T07:11:00Z",
            privacyClasses: [.standard],
            containsPrivateRuntimeData: false,
            payloadData: Data(#"{"title":"Start here"}"#.utf8)
        )
        try await appGroupStore.write(safeSnapshot)
        let storedSnapshot = try await appGroupStore.read(id: "widget-safe")
        XCTAssertEqual(storedSnapshot, safeSnapshot)
        let unsafeSnapshot = AppGroupSnapshotRecord(
            id: "widget-unsafe",
            snapshotKind: "widget",
            createdAt: "2026-06-30T07:11:30Z",
            privacyClasses: [.privateUserText],
            containsPrivateRuntimeData: true,
            payloadData: Data("private".utf8)
        )
        await XCTAssertThrowsErrorAsync {
            try await appGroupStore.write(unsafeSnapshot)
        }

        let backupStore = BackupStore(rootDirectory: directory.appendingPathComponent("backups", isDirectory: true))
        let key = SymmetricKey(size: .bits256)
        let backupRecord = try await backupStore.saveEncryptedPackage(
            id: "backup-pre-migration",
            kind: .preMigration,
            plaintext: Data("portable snapshot".utf8),
            key: key,
            keyID: "user-key-1",
            createdAt: "2026-06-30T07:12:00Z"
        )
        let encryptedPackage = try await backupStore.loadEncryptedPackage(id: backupRecord.id)
        let decryptedPackage = try await backupStore.decryptPackage(id: backupRecord.id, key: key)
        XCTAssertNotEqual(encryptedPackage.encryptedData, Data("portable snapshot".utf8))
        XCTAssertEqual(decryptedPackage, Data("portable snapshot".utf8))

        let migrationStore = MigrationStore(databaseURL: directory.appendingPathComponent("migration.sqlite"))
        let plan = MigrationPlanner().plan(from: SchemaLedger.current, to: SchemaLedger.current)
        let migrationRecord = try await migrationStore.recordDryRun(
            id: "dry-run-current",
            plan: plan,
            relatedBackupID: backupRecord.id,
            createdAt: "2026-06-30T07:13:00Z"
        )
        XCTAssertFalse(migrationRecord.migrationExecutionAllowed)
        let storedMigration = try await migrationStore.fetch(id: "dry-run-current")
        let migrationHealth = try await migrationStore.health()
        XCTAssertEqual(storedMigration?.relatedBackupID, backupRecord.id)
        XCTAssertEqual(migrationHealth.executionAllowedRecordCount, 0)
    }
}

private extension StorageTierTests {
    func makeCommandEvent(
        id: String,
        captureID: String,
        summary: String = "Captured storage note"
    ) -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            payload: AmbitionsCommandPayload(rawText: summary),
            createdAt: "2026-06-30T07:00:00Z"
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: captureID, destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.\(id)"],
            metadata: ["captureID": captureID]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-06-30T07:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }

    func makePrivateCommandEvent() -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: "command-private-search",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-private-search", destination: .captureInbox),
            payload: AmbitionsCommandPayload(rawText: "private medical note"),
            createdAt: "2026-06-30T07:00:30Z",
            privacy: .privateUserText
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "private medical note",
            route: .captureInbox,
            target: command.target,
            eventLedgerEntryIDs: ["ledger.command-private-search"],
            metadata: ["captureID": "capture-private-search"]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-06-30T07:00:30Z",
            commandRecordID: "command.execution.command-private-search"
        )
    }

    func makeProofEvent(id: String, goalID: String) -> RuntimeEvent {
        RuntimeEvent(
            commandID: "command-\(id)",
            actor: .system,
            source: .you,
            target: AmbitionsCommandTarget(goalID: goalID, destination: .you),
            privacy: .standard,
            occurredAt: "2026-06-30T07:00:45Z",
            payload: .proofAttached(
                RuntimeProofAttachmentEventPayload(
                    proofID: id,
                    objectID: goalID,
                    sourceRecordIDs: ["source.\(id)"]
                )
            )
        )
    }

    func scratchDirectory() throws -> URL {
        let directory = URL(fileURLWithPath: "/tmp", isDirectory: true)
            .appendingPathComponent("ambitions-storage-tier-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "StorageTierTests", code: 1)
    }
}

private func XCTAssertThrowsErrorAsync(
    _ expression: () async throws -> Void,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {}
}
