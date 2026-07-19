import XCTest
@testable import Ambitions

final class AppGroupSnapshotWriterInventoryTests: XCTestCase {
    func testInventoryNamesCurrentAppGroupSnapshotWriterChainAndConstants() throws {
        let inventory = AppGroupSnapshotWriterInventory.current
        let writer = try XCTUnwrap(inventory.writer(for: .nextStepExternalSurface))

        XCTAssertEqual(inventory.schemaVersion, appGroupSnapshotWriterInventorySchemaVersion)
        XCTAssertEqual(inventory.writers.map(\.family), AppGroupSnapshotWriterFamily.allCases)
        XCTAssertEqual(writer.writerTypeName, "ExternalSurfaceSnapshotWriter")
        XCTAssertEqual(writer.storeTypeName, "AppGroupSnapshotStore")
        XCTAssertEqual(writer.appGroupIdentifier, SharedExternalSnapshotStore.appGroupIdentifier)
        XCTAssertEqual(writer.appGroupIdentifier, AppGroupSnapshotStore.appGroupIdentifier)
        XCTAssertEqual(writer.appGroupRelativeDirectory, SharedExternalSnapshotStore.relativeDirectory)
        XCTAssertEqual(writer.appGroupRelativeDirectory, AppGroupSnapshotStore.relativeDirectory)
        XCTAssertEqual(writer.recordID, SharedExternalSnapshotStore.snapshotRecordID)
        XCTAssertEqual(writer.recordFileName, "\(SharedExternalSnapshotStore.snapshotRecordID).snapshot.json")
        XCTAssertEqual(writer.snapshotKind, SharedExternalSnapshotStore.snapshotKind)
        XCTAssertEqual(writer.recordSchemaVersion, appGroupSnapshotStoreSchemaVersion)
        XCTAssertEqual(writer.payloadSchemaVersion, ExternalSurfaceSnapshot.schemaVersion)
        XCTAssertEqual(writer.fileProtectionPolicy, AppGroupSnapshotStore.snapshotFileProtectionPolicy)
    }

    func testWriterChainStaysProjectionOnlyRedactedVersionedAndStaleAware() throws {
        let writer = try XCTUnwrap(AppGroupSnapshotWriterInventory.current.writer(for: .nextStepExternalSurface))

        XCTAssertEqual(writer.sourceProjectionIDs, ["widget", "privacy"])
        XCTAssertTrue(writer.projectionOnly)
        XCTAssertFalse(writer.rawRuntimeRepositoryReadAllowed)
        XCTAssertFalse(writer.containsPrivateRuntimeDataAllowed)
        XCTAssertEqual(
            writer.allowedPrivacyClassRawValues,
            [
                EventLedgerPrivacyClassification.calendarDerived.rawValue,
                EventLedgerPrivacyClassification.standard.rawValue,
                EventLedgerPrivacyClassification.syncMetadata.rawValue
            ]
        )
        XCTAssertEqual(
            writer.blockedPrivacyClassRawValues,
            [
                EventLedgerPrivacyClassification.privateUserText.rawValue,
                EventLedgerPrivacyClassification.sensitive.rawValue
            ]
        )
        XCTAssertEqual(writer.redactionGate, "PrivacyExternalBoundaryGate.evaluateExternalSnapshot")
        XCTAssertTrue(writer.checksumRequired)
        XCTAssertTrue(writer.staleAwareFields.contains("continuity.lease.status"))
        XCTAssertTrue(writer.staleAwareFields.contains("continuity.lease.staleActionLabel"))
        XCTAssertTrue(writer.staleAwareFields.contains("continuity.syncHealth.state"))
        XCTAssertTrue(writer.staleAwareFields.contains("continuity.lifecycle.sourceState"))
    }

    func testSourceScanKeepsOnlyOneCurrentAppGroupSnapshotWriteCallsite() throws {
        let root = try repoRoot()
        let writeCallsites = try swiftFiles(in: [
            "Native/Ambitions",
            "Native/AmbitionsWidgetExtension",
            "Native/AmbitionsShareExtension"
        ], root: root)
            .filter { try fileContents(root.appendingPathComponent($0)).contains("appGroupSnapshotStore.write(record)") }

        XCTAssertEqual(writeCallsites, [
            "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift"
        ])
    }

    func testInventoryDistinguishesSnapshotWritersFromOtherAppGroupAccessors() throws {
        let writer = try XCTUnwrap(AppGroupSnapshotWriterInventory.current.writer(for: .nextStepExternalSurface))

        XCTAssertTrue(writer.readerTypeNames.contains("ExtensionExternalSurfaceSnapshotReader"))
        XCTAssertTrue(writer.readerTypeNames.contains("FileExternalSurfaceSnapshotReader"))
        XCTAssertTrue(writer.nonSnapshotAppGroupAccessors.contains("SharedExternalCreationStore"))
        XCTAssertTrue(writer.nonSnapshotAppGroupAccessors.contains("ObjectStoreSwiftDataLegacyMigration"))
        XCTAssertFalse(writer.nonSnapshotAppGroupAccessors.contains(writer.writerTypeName))
    }

    private func repoRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
        }
        throw NSError(domain: "AppGroupSnapshotWriterInventoryTests", code: 1)
    }

    private func swiftFiles(in directories: [String], root: URL) throws -> [String] {
        try directories.flatMap { directory -> [String] in
            let rootURL = root.appendingPathComponent(directory, isDirectory: true)
            guard let enumerator = FileManager.default.enumerator(
                at: rootURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            ) else {
                return []
            }

            return try enumerator.compactMap { item -> String? in
                guard let url = item as? URL, url.pathExtension == "swift" else {
                    return nil
                }
                let values = try url.resourceValues(forKeys: [.isRegularFileKey])
                guard values.isRegularFile == true else { return nil }
                return String(url.path.dropFirst(root.path.count + 1))
            }
        }
        .sorted()
    }

    private func fileContents(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}
