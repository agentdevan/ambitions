@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationPathProtectionTests: XCTestCase {
    func testShippingV8ArtifactsUseCompleteProtectionAtPrivatePaths() async throws {
        try await withRuntimeGenerationHarness(seed: 13_000) { harness in
            let activation = try await harness.installFirstGeneration()
            let store = try await harness.openActiveStore()
            _ = try await store.withReadTransaction { database in
                try database.query("SELECT singleton_id FROM runtime_store_metadata")
            }

            let databaseURL = harness.locations.databaseURL(for: activation.generationID)
            let requiredArtifacts = [
                harness.locations.rootURL,
                harness.locations.storesURL,
                harness.locations.controlURL,
                harness.locations.controlDatabaseURL,
                harness.locations.attachmentVaultURL,
                harness.locations.activeManifestURL,
                harness.locations.generationDirectoryURL(for: activation.generationID),
                databaseURL,
                harness.locations.generationDirectoryURL(for: activation.generationID)
                    .appendingPathComponent("Authority.json"),
            ]
            let sidecars = [
                URL(fileURLWithPath: databaseURL.path + "-wal"),
                URL(fileURLWithPath: databaseURL.path + "-shm"),
                URL(fileURLWithPath: harness.locations.controlDatabaseURL.path + "-wal"),
                URL(fileURLWithPath: harness.locations.controlDatabaseURL.path + "-shm"),
            ]

            for artifact in requiredArtifacts + sidecars {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: artifact.path),
                    artifact.path
                )
                try RuntimeStoreFileDurability.requireCompleteProtection(
                    at: artifact,
                    artifact: artifact.lastPathComponent
                )
            }
            try await store.close()
            return ()
        }
    }

    func testProtectedDataUnavailableFailsClosedWithoutPublishingFallbackAuthority() async throws {
        try await withRuntimeGenerationHarness(
            seed: 13_100,
            protectedDataChecker: RuntimeGenerationFixedProtectedDataChecker(
                isAvailable: false
            )
        ) { harness in
            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.installFirstGeneration(),
                equals: .protectedDataUnavailable
            )
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: harness.locations.activeManifestURL.path
                )
            )
            let unexpectedArtifacts = try FileManager.default.contentsOfDirectory(
                at: harness.locations.storesURL,
                includingPropertiesForKeys: nil
            ).filter { entry in
                entry.lastPathComponent != ".activation.lock"
            }
            XCTAssertTrue(unexpectedArtifacts.isEmpty)
            return ()
        }
    }

    func testMigrationBackupTreeUsesCompleteProtectionBeforeActivation() async throws {
        try await withRuntimeGenerationHarness(seed: 13_050) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "backup-protection-vault"
            )
            _ = try await harness.lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )

            var artifacts = [harness.locations.backupsURL]
            let enumerator = FileManager.default.enumerator(
                at: harness.locations.backupsURL,
                includingPropertiesForKeys: nil
            )
            while let artifact = enumerator?.nextObject() as? URL {
                artifacts.append(artifact)
            }
            XCTAssertTrue(
                artifacts.contains { $0.lastPathComponent == "Runtime.sqlite" }
            )
            for artifact in artifacts {
                try RuntimeStoreFileDurability.requireCompleteProtection(
                    at: artifact,
                    artifact: "backup_\(artifact.lastPathComponent)"
                )
            }
            try await source.close()
            return ()
        }
    }

    func testAppGroupAndSymbolicRootsAreRejectedAsCanonicalAuthority() throws {
        let fileManager = FileManager.default
        let scratch = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationPathBoundary-\(UUID().uuidString)",
            isDirectory: true
        )
        try fileManager.createDirectory(at: scratch, withIntermediateDirectories: true)
        defer { XCTAssertNoThrow(try fileManager.removeItem(at: scratch)) }

        let forbidden = scratch.appendingPathComponent(
            "group.example.ambitions",
            isDirectory: true
        )
        try fileManager.createDirectory(at: forbidden, withIntermediateDirectories: false)
        XCTAssertThrowsError(try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: forbidden
        )) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalPathAuthorityDenied
            )
        }

        let real = scratch.appendingPathComponent("private-root", isDirectory: true)
        let symbolic = scratch.appendingPathComponent("symbolic-root", isDirectory: true)
        try fileManager.createDirectory(at: real, withIntermediateDirectories: false)
        try fileManager.createSymbolicLink(at: symbolic, withDestinationURL: real)
        XCTAssertThrowsError(try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: symbolic
        )) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalPathAuthorityDenied
            )
        }
    }

    func testPinnedRootRejectsPathExchangeAfterAuthorityCreation() throws {
        let fileManager = FileManager.default
        let scratch = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationPinnedRoot-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = scratch.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        defer { XCTAssertNoThrow(try fileManager.removeItem(at: scratch)) }
        let authority = try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: applicationSupportURL
        )
        let displaced = scratch.appendingPathComponent(
            "Displaced Application Support",
            isDirectory: true
        )
        try fileManager.moveItem(at: applicationSupportURL, to: displaced)
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: false
        )

        XCTAssertThrowsError(try authority.revalidatePinnedRoot()) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalPathAuthorityDenied
            )
        }
    }

    func testMalformedFutureOversizedAndSymbolicSelectorsFailClosed() async throws {
        try await withRuntimeGenerationHarness(seed: 13_200) { harness in
            let activation = try await harness.installFirstGeneration()
            let selectorURL = harness.locations.activeManifestURL
            let original = try Data(contentsOf: selectorURL)

            let malformed = Data("{\"unexpected\":true}".utf8)
            try malformed.write(to: selectorURL, options: .atomic)
            do {
                _ = try await harness.resolveActive()
                XCTFail("Expected malformed selector rejection")
            } catch is DecodingError {
                XCTAssertEqual(try Data(contentsOf: selectorURL), malformed)
            } catch {
                XCTFail("Unexpected error: \(type(of: error))")
            }

            var futureObject = try XCTUnwrap(
                try JSONSerialization.jsonObject(with: original) as? [String: Any]
            )
            futureObject["format_version"] = runtimeGenerationActiveSelectorVersion + 1
            let future = try JSONSerialization.data(
                withJSONObject: futureObject,
                options: [.sortedKeys]
            )
            try future.write(to: selectorURL, options: .atomic)
            await XCTAssertThrowsRuntimeGenerationError(
                try await harness.resolveActive(),
                equals: .futureVersion(
                    maximumSupported: runtimeGenerationActiveSelectorVersion,
                    actual: runtimeGenerationActiveSelectorVersion + 1
                )
            )

            let oversized = Data(
                repeating: 0x61,
                count: RuntimeStoreManifestCodec.maximumByteCount + 1
            )
            try oversized.write(to: selectorURL, options: .atomic)
            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.resolveActive(),
                equals: .canonicalManifestMalformed
            )

            try FileManager.default.removeItem(at: selectorURL)
            try FileManager.default.createSymbolicLink(
                at: selectorURL,
                withDestinationURL: harness.locations.generationDirectoryURL(
                    for: activation.generationID
                ).appendingPathComponent("Authority.json")
            )
            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.resolveActive(),
                equals: .canonicalPathAuthorityDenied
            )
            return ()
        }
    }

    func testDatabaseSymbolicReplacementIsRejectedBeforeV8Open() async throws {
        try await withRuntimeGenerationHarness(seed: 13_300) { harness in
            let activation = try await harness.installFirstGeneration()
            let databaseURL = harness.locations.databaseURL(for: activation.generationID)
            let displacedURL = databaseURL.deletingLastPathComponent()
                .appendingPathComponent("Displaced.sqlite")
            let selectorBefore = try Data(contentsOf: harness.locations.activeManifestURL)
            try FileManager.default.moveItem(at: databaseURL, to: displacedURL)
            try FileManager.default.createSymbolicLink(
                at: databaseURL,
                withDestinationURL: displacedURL
            )

            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.resolveActive(),
                equals: .canonicalPathAuthorityDenied
            )
            XCTAssertEqual(
                try Data(contentsOf: harness.locations.activeManifestURL),
                selectorBefore
            )
            return ()
        }
    }
}
