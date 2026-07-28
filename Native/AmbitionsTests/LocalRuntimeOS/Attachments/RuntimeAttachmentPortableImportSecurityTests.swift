import Darwin
import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentPortableImportSecurityTests: XCTestCase {
    func testMalformedRawCleanupFilenameCannotBlockValidPendingCleanup() async throws {
        let root = try XCTAttachmentFixtures.directory("portable-raw-cleanup")
        let importer = try RuntimeAttachmentPortableImporter(
            cleanupCustody: FixedRuntimeAttachmentCleanupJobCustody(),
            importRoot: root,
            importToken: { "portable-cleanup-test" },
            clock: { XCTAttachmentFixtures.now }
        )
        try XCTAttachmentFixtures.createRawNamedFile(
            in: root,
            nameBytes: Array(".cleanup-!".utf8) + [0xff] + Array(".json.pending".utf8)
        )
        let pending = root.appendingPathComponent(".cleanup-valid.json.pending")
        try Data().write(to: pending)
        #if os(iOS)
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: pending.path
        )
        #endif

        let firstRecovered = try await importer.recoverInterruptedImports(limit: 1)

        XCTAssertEqual(firstRecovered, 0)
        XCTAssertTrue(FileManager.default.fileExists(atPath: pending.path))

        let recovered = try await importer.recoverInterruptedImports(limit: 1)

        XCTAssertEqual(recovered, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: pending.path))
    }

    func testPendingCleanupRejectsHardLinkedOwnedFile() async throws {
        let root = try XCTAttachmentFixtures.directory("portable-hardlink-cleanup")
        let importer = try RuntimeAttachmentPortableImporter(
            cleanupCustody: FixedRuntimeAttachmentCleanupJobCustody(),
            importRoot: root,
            importToken: { "portable-hardlink-test" },
            clock: { XCTAttachmentFixtures.now }
        )
        let pending = root.appendingPathComponent(".cleanup-linked.json.pending")
        let alias = root.appendingPathComponent("cleanup-hardlink-alias")
        try Data().write(to: pending)
        #if os(iOS)
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: pending.path
        )
        #endif
        guard Darwin.link(pending.path, alias.path) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }

        do {
            _ = try await importer.recoverInterruptedImports(limit: 10)
            XCTFail("Hard-linked plaintext cleanup authority must fail closed")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .pathAuthorityDenied)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: pending.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: alias.path))
    }

    func testFailingEarlyCleanupEntryCannotStarveLaterRawPage() async throws {
        let root = try XCTAttachmentFixtures.directory("portable-cleanup-starvation")
        let importer = try RuntimeAttachmentPortableImporter(
            cleanupCustody: FixedRuntimeAttachmentCleanupJobCustody(),
            importRoot: root,
            importToken: { "portable-starvation-test" },
            clock: { XCTAttachmentFixtures.now }
        )
        let failing = root.appendingPathComponent(".cleanup-a.json.pending")
        let alias = root.appendingPathComponent("cleanup-a-hardlink-alias")
        let later = root.appendingPathComponent(".cleanup-z.json.pending")
        try Data().write(to: failing)
        try Data().write(to: later)
        #if os(iOS)
        for candidate in [failing, later] {
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete], ofItemAtPath: candidate.path
            )
        }
        #endif
        guard Darwin.link(failing.path, alias.path) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }

        do {
            _ = try await importer.recoverInterruptedImports(limit: 1)
            XCTFail("The early hard-link must remain an explicit recovery failure")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .pathAuthorityDenied)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: failing.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: later.path))

        let recovered = try await importer.recoverInterruptedImports(limit: 1)

        XCTAssertEqual(recovered, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: later.path))
    }
}
