@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationRecoveryIntegrationTests: XCTestCase {
    /// Target recovery contract. `recoverStaleUncommittedArtifacts()` currently
    /// removes stale staging bytes after a quarantine rename; production must
    /// preserve those bytes before this source case can pass.
    func testFirstInstallPreservesStagingEvidenceAndQuarantinesOrphanWithoutLoss() async throws {
        try await withRuntimeGenerationHarness(seed: 12_000) { harness in
            try FileManager.default.createDirectory(
                at: harness.locations.storesURL,
                withIntermediateDirectories: true
            )
            let staging = harness.locations.storesURL.appendingPathComponent(
                ".staging-11111111-2222-4333-8444-555555555555-interrupted",
                isDirectory: true
            )
            let orphan = harness.locations.storesURL.appendingPathComponent(
                "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee",
                isDirectory: true
            )
            try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: false)
            try FileManager.default.createDirectory(at: orphan, withIntermediateDirectories: false)
            try Data("staged-original".utf8).write(
                to: staging.appendingPathComponent("original.bin")
            )
            try Data("orphan-original".utf8).write(
                to: orphan.appendingPathComponent("original.bin")
            )

            _ = try await harness.installFirstGeneration()

            let entries = try FileManager.default.contentsOfDirectory(
                at: harness.locations.storesURL,
                includingPropertiesForKeys: nil
            )
            XCTAssertTrue(entries.contains(staging))
            XCTAssertFalse(entries.contains(orphan))
            XCTAssertEqual(
                try Data(contentsOf: staging.appendingPathComponent("original.bin")),
                Data("staged-original".utf8)
            )
            let quarantined = entries.filter {
                $0.lastPathComponent.hasPrefix(".inactive-recovery-")
            }
            XCTAssertEqual(quarantined.count, 1)
            let preservedOrphan = try XCTUnwrap(quarantined.first)
            XCTAssertEqual(
                try Data(contentsOf: preservedOrphan.appendingPathComponent("original.bin")),
                Data("orphan-original".utf8)
            )
            return ()
        }
    }

    func testRecoveryIsIdempotentAcrossRepeatedResolution() async throws {
        try await withRuntimeGenerationHarness(seed: 12_100) { harness in
            let activation = try await harness.installFirstGeneration()
            let first = try await harness.resolveActive()
            let inventoryBefore = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )
            let second = try await harness.resolveActive()
            let inventoryAfter = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )

            XCTAssertEqual(first.selector.generationID, activation.generationID)
            XCTAssertEqual(second.selector, first.selector)
            XCTAssertEqual(inventoryAfter, inventoryBefore)
            return ()
        }
    }

    func testMissingSelectorFailsClosedWithoutSelectingAnOrphan() async throws {
        try await withRuntimeGenerationHarness(seed: 12_200) { harness in
            let activation = try await harness.installFirstGeneration()
            let activeDirectory = harness.locations.generationDirectoryURL(
                for: activation.generationID
            )
            try FileManager.default.removeItem(at: harness.locations.activeManifestURL)

            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.resolveActive(),
                equals: .canonicalManifestMissing
            )
            XCTAssertTrue(FileManager.default.fileExists(atPath: activeDirectory.path))
            return ()
        }
    }

    func testCorruptSelectorRemainsAvailableForForensicPreservation() async throws {
        try await withRuntimeGenerationHarness(seed: 12_300) { harness in
            _ = try await harness.installFirstGeneration()
            let corrupt = Data("{\"unexpected\":true}".utf8)
            try corrupt.write(to: harness.locations.activeManifestURL, options: .atomic)

            do {
                _ = try await harness.resolveActive()
                XCTFail("Expected corrupt selector to fail closed")
            } catch is DecodingError {
                XCTAssertEqual(
                    try Data(contentsOf: harness.locations.activeManifestURL),
                    corrupt
                )
            } catch {
                XCTFail("Unexpected error: \(type(of: error))")
            }
            return ()
        }
    }

    func testSplitAuthorityNeverOffersResetWithoutExplicitAuthorization() {
        let disposition = RuntimeGenerationRecoveryService.testOnlyQuarantineDisposition(
            for: .splitAuthority
        )
        XCTAssertTrue(disposition.actions.contains(.inspectReadOnly))
        XCTAssertTrue(disposition.actions.contains(.exportOriginal))
        XCTAssertFalse(disposition.actions.contains(.explicitlyAuthorizedReset))
    }

    func testMissingOrCorruptAuthorityOffersResetOnlyAsExplicitAction() {
        let evidence = RuntimeGenerationCrashByteEvidence(
            sha256: String(repeating: "a", count: 64),
            byteCount: 42
        )
        for classification in [
            RuntimeGenerationActivationCrashClassification.selectorCorrupt(evidence),
            .targetAuthorityMissing,
            .targetDatabaseMissing,
            .targetDatabaseCorrupt,
        ] {
            let disposition = RuntimeGenerationRecoveryService.testOnlyQuarantineDisposition(
                for: classification
            )
            XCTAssertTrue(disposition.actions.contains(.inspectReadOnly))
            XCTAssertTrue(disposition.actions.contains(.exportOriginal))
            XCTAssertTrue(disposition.actions.contains(.explicitlyAuthorizedReset))
        }
    }
}
