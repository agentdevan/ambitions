import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentRecoveryTests: XCTestCase {
    func testTemporaryDirectoriesAreEnumeratedDeterministicallyAndOnlyOwnedFilesCanBeRemoved() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-temporary")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        _ = try await vault.ownedTemporaryDirectories(limit: 10)
        let first = root.appendingPathComponent(".staging-b", isDirectory: true)
        let second = root.appendingPathComponent(".staging-a", isDirectory: true)
        try FileManager.default.createDirectory(at: first, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: second, withIntermediateDirectories: true)
        try Data([1]).write(to: first.appendingPathComponent("manifest.json"))
        try Data([2]).write(to: second.appendingPathComponent("payload.aead"))
        let temporary = try await vault.ownedTemporaryDirectories(limit: 10)
        XCTAssertEqual(temporary.entries.compactMap {
            if case let .owned(_, url) = $0 { url.lastPathComponent } else { nil }
        }, [".staging-a", ".staging-b"])
        try await vault.removeOwnedTemporaryDirectory(second)
        try await vault.removeOwnedTemporaryDirectory(first)
        let after = try await vault.ownedTemporaryDirectories(limit: 10)
        XCTAssertTrue(after.entries.isEmpty)
    }

    func testTemporaryCleanupRefusesUnexpectedContentAndSymlinkAuthority() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-temp-denied")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        _ = try await vault.ownedTemporaryDirectories(limit: 10)
        let temporary = root.appendingPathComponent(".staging-denied", isDirectory: true)
        try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
        try Data([1]).write(to: temporary.appendingPathComponent("private-user-file"))
        await assertAttachmentError(.pathAuthorityDenied) {
            try await vault.removeOwnedTemporaryDirectory(temporary)
        }
        try FileManager.default.removeItem(at: temporary)
        let destination = root.appendingPathComponent("outside", isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: temporary, withDestinationURL: destination)
        let malformed = try await vault.ownedTemporaryDirectories(limit: 10)
        XCTAssertTrue(malformed.entries.contains {
            if case let .malformed(finding) = $0 {
                return finding.error == .pathAuthorityDenied
            }
            return false
        })
    }

    func testManifestInspectionAuthenticatesCanonicalBytesAndRelativeDirectory() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-manifest")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        let directories = try await vault.ownedManifestDirectories(limit: 10)
        let directory = try XCTUnwrap(directories.entries.compactMap {
            if case let .owned(_, url) = $0 { url } else { nil }
        }.first)
        let inspection = try await vault.inspectOwnedManifestDirectory(directory)
        XCTAssertEqual(inspection.manifest, bundle.manifest)
        XCTAssertEqual(inspection.manifestDigest, bundle.revision.manifestDigest)
    }

    func testMalformedOrTamperedManifestIsNeverConvertedIntoEmptyAuthority() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-tampered-manifest")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        let directory = root.appendingPathComponent(bundle.manifest.opaqueRelativeDirectory)
        let manifest = directory.appendingPathComponent("manifest.json")
        var bytes = try Data(contentsOf: manifest)
        bytes[bytes.startIndex] ^= 0xff
        try bytes.write(to: manifest)
        await assertAnyError {
            _ = try await vault.inspectOwnedManifestDirectory(directory)
        }
    }

    func testMissingCiphertextRemainsDistinguishableFromManifestWithoutDatabaseRow() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-missing")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        let directory = root.appendingPathComponent(bundle.manifest.opaqueRelativeDirectory)
        let inspection = try await vault.inspectOwnedManifestDirectory(directory)
        XCTAssertEqual(inspection.manifest.blobID, bundle.manifest.blobID)
        try FileManager.default.removeItem(at: directory.appendingPathComponent("payload.aead"))
        let exists = try await vault.ownedBlobExists(bundle.manifest)
        XCTAssertFalse(exists)
        await assertAnyError {
            try await vault.verifyAuthenticatedBlob(XCTAttachmentFixtures.graph(bundle))
        }
    }

    func testPayloadTamperIsClassifiedByAuthenticatedVerificationNotByExistenceOnly() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-payload-tamper")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root)
        let payload = XCTAttachmentFixtures.payloadURL(root: root, manifest: bundle.manifest)
        var bytes = try Data(contentsOf: payload)
        bytes[bytes.index(before: bytes.endIndex)] ^= 0xff
        try bytes.write(to: payload)
        let exists = try await vault.ownedBlobExists(bundle.manifest)
        XCTAssertTrue(exists)
        await assertAnyError {
            try await vault.verifyAuthenticatedBlob(XCTAttachmentFixtures.graph(bundle))
        }
    }

    func testOwnedManifestAndTemporaryPaginationRejectsUnboundedRecoveryScans() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-limits")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        await assertAttachmentError(.invalidRecord) {
            _ = try await vault.ownedManifestDirectories(limit: 0)
        }
        await assertAttachmentError(.invalidRecord) {
            _ = try await vault.ownedTemporaryDirectories(limit: RuntimeAttachmentLimits.maximumPageSize + 1)
        }
    }

    func testRawByteKeysetEventuallyPagesBeyond4096AndIncludesMalformedEntries() async throws {
        let root = try XCTAttachmentFixtures.directory("recovery-keyset-over-4096")
        let vault = try XCTAttachmentFixtures.vault(root: root)
        _ = try await vault.ownedTemporaryDirectories(limit: 1)
        for index in 0..<4_100 {
            try FileManager.default.createDirectory(
                at: root.appendingPathComponent(
                    String(format: ".staging-%05d", index), isDirectory: true
                ),
                withIntermediateDirectories: false
            )
        }
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent(".staging-!malformed", isDirectory: true),
            withIntermediateDirectories: false
        )

        var cursor: String?
        var ownedCount = 0
        var malformedCount = 0
        repeat {
            let page = try await vault.ownedTemporaryDirectories(
                limit: 257, afterCursorKey: cursor
            )
            for entry in page.entries {
                switch entry {
                case .owned: ownedCount += 1
                case .malformed: malformedCount += 1
                }
            }
            if page.exhausted {
                cursor = nil
                break
            }
            let next = try XCTUnwrap(page.nextCursorKey)
            if let cursor { XCTAssertGreaterThan(next, cursor) }
            cursor = next
        } while cursor != nil

        XCTAssertEqual(ownedCount, 4_100)
        XCTAssertEqual(malformedCount, 1)
    }

    private func assertAttachmentError(
        _ expected: RuntimeCanonicalAttachmentError,
        operation: () async throws -> Void
    ) async {
        do { try await operation(); XCTFail("Expected \(expected)") }
        catch let actual as RuntimeCanonicalAttachmentError { XCTAssertEqual(actual, expected) }
        catch { XCTFail("Unexpected error: \(error)") }
    }

    private func assertAnyError(operation: () async throws -> Void) async {
        do { try await operation(); XCTFail("Expected recovery authority rejection") }
        catch { XCTAssertTrue(true) }
    }
}
