@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationActivationAtomicityTests: XCTestCase {
    func testInjectedUnchangedActivationNeverPublishesCandidate() async throws {
        try await withRuntimeGenerationHarness(
            seed: 10_900,
            manifestActivator: RuntimeGenerationFailingManifestActivator(
                state: .unchanged(.canonicalActivationFailed)
            )
        ) { harness in
            await XCTAssertThrowsLocalRuntimeStorageError(
                try await harness.installFirstGeneration(),
                equals: .canonicalActivationFailed
            )
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: harness.locations.activeManifestURL.path
                )
            )
            return ()
        }
    }

    func testEveryPrecommitFailureLeavesSourceAndSelectorByteForByteUnchanged() async throws {
        try await withRuntimeGenerationHarness(seed: 11_000) { harness in
            let sourceActivation = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let before = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )

            let phases: [RuntimeStoreManifestActivationFaultPhase] = [
                .temporaryDurable, .rollbackDurable, .manifestRenamed, .manifestDurable,
            ]
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "atomicity-vault"
            )
            for (offset, phase) in phases.enumerated() {
                let lifecycle = try harness.lifecycle(
                    seed: UInt64(11_100 + offset),
                    manifestActivator: AtomicRuntimeStoreManifestActivator(
                        injectedFailurePhase: phase
                    )
                )
                do {
                    _ = try await lifecycle.migrateActiveGeneration(
                        source: source,
                        vault: vault,
                        keyCustody: FixedRuntimeAttachmentKeyCustody()
                    )
                    XCTFail("Expected activation failure after \(phase.rawValue)")
                } catch {
                    let after = try RuntimeGenerationArtifactSnapshot.capture(
                        locations: harness.locations
                    )
                    XCTAssertEqual(after.selectorBytes, before.selectorBytes)
                    XCTAssertEqual(
                        try await harness.resolveActive().selector.generationID,
                        sourceActivation.generationID
                    )
                }
            }
            try await source.close()
            return ()
        }
    }

    func testStorageFullLeavesSelectedSourceUnchanged() async throws {
        try await withRuntimeGenerationHarness(seed: 11_200) { harness in
            let sourceActivation = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let before = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )
            let lifecycle = try harness.lifecycle(
                seed: 11_201,
                manifestActivator: RuntimeGenerationFailingManifestActivator(
                    state: .unchanged(.canonicalStorageFull(operation: "activate_manifest"))
                )
            )
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "storage-full-vault"
            )

            await XCTAssertThrowsLocalRuntimeStorageError(
                try await lifecycle.migrateActiveGeneration(
                    source: source,
                    vault: vault,
                    keyCustody: FixedRuntimeAttachmentKeyCustody()
                ),
                equals: .canonicalStorageFull(operation: "activate_manifest")
            )
            XCTAssertEqual(
                try RuntimeGenerationArtifactSnapshot.capture(locations: harness.locations)
                    .selectorBytes,
                before.selectorBytes
            )
            XCTAssertEqual(
                try await harness.resolveActive().selector.generationID,
                sourceActivation.generationID
            )
            try await source.close()
            return ()
        }
    }

    func testUnexpectedPriorSelectorProducesUnknownOutcomeWithoutOverwrite() async throws {
        try await withRuntimeGenerationHarness(seed: 11_300) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let selectorBefore = try Data(contentsOf: harness.locations.activeManifestURL)
            let lifecycle = try harness.lifecycle(
                seed: 11_301,
                manifestActivator: RuntimeGenerationFailingManifestActivator(state: .unknown)
            )
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "unknown-activation-vault"
            )

            do {
                _ = try await lifecycle.migrateActiveGeneration(
                    source: source,
                    vault: vault,
                    keyCustody: FixedRuntimeAttachmentKeyCustody()
                )
                XCTFail("Expected indeterminate activation")
            } catch {
                XCTAssertEqual(
                    try Data(contentsOf: harness.locations.activeManifestURL),
                    selectorBefore
                )
            }
            try await source.close()
            return ()
        }
    }

    func testPostcommitCleanupFailureReportsCommittedWarningAndReopensTarget() async throws {
        try await withRuntimeGenerationHarness(seed: 11_400) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let lifecycle = try harness.lifecycle(
                seed: 11_401,
                manifestActivator: AtomicRuntimeStoreManifestActivator(
                    injectedFailurePhase: .committedCleanup
                )
            )
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "cleanup-warning-vault"
            )
            let result = try await lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )

            XCTAssertTrue(result.committedWithCleanupWarning)
            XCTAssertEqual(
                try await harness.resolveActive().selector.generationID,
                result.generationID
            )
            try await source.close()
            return ()
        }
    }

    func testRetryAfterCommittedWarningDoesNotDuplicateTargetActivation() async throws {
        try await withRuntimeGenerationHarness(seed: 11_500) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let lifecycle = try harness.lifecycle(
                seed: 11_501,
                manifestActivator: AtomicRuntimeStoreManifestActivator(
                    injectedFailurePhase: .committedCleanup
                )
            )
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "cleanup-retry-vault"
            )
            let first = try await lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )
            do {
                _ = try await lifecycle.migrateActiveGeneration(
                    source: source,
                    vault: vault,
                    keyCustody: FixedRuntimeAttachmentKeyCustody()
                )
                XCTFail("A stale source cannot activate a second descendant")
            } catch {
                XCTAssertEqual(
                    try await harness.resolveActive().selector.generationID,
                    first.generationID
                )
            }
            try await source.close()
            return ()
        }
    }
}
