import AmbitionsRuntimeSQLite
@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationIdentityIntegrationTests: XCTestCase {
    func testV8ActivationUsesExactPrivatePathsAndRoundTripsSelectorAuthority() async throws {
        try await withRuntimeGenerationHarness { harness in
            let activation = try await harness.installFirstGeneration()
            let resolved = try await harness.resolveActive()

            XCTAssertEqual(resolved.selector.generationID, activation.generationID)
            XCTAssertEqual(
                resolved.databaseURL,
                harness.locations.databaseURL(for: activation.generationID)
            )
            XCTAssertEqual(
                resolved.generationDirectoryURL,
                harness.locations.generationDirectoryURL(for: activation.generationID)
            )
            XCTAssertEqual(
                resolved.selector.relativeDatabasePath,
                "Stores/\(activation.generationID.pathComponent)/Runtime.sqlite"
            )
            let selectorBytes = try XCTUnwrap(
                RuntimeStoreManifestDescriptorReader.readIfPresent(
                    at: harness.locations.activeManifestURL
                )
            )
            XCTAssertEqual(
                try RuntimeGenerationActiveSelectorCodec.decode(selectorBytes),
                resolved.selector
            )
            XCTAssertEqual(
                LocalRuntimeStorageChecksum.sha256Hex(for: selectorBytes),
                activation.selectorFileSHA256
            )
            return ()
        }
    }

    func testGenerationIdentityCannotBeReusedOrMutated() async throws {
        try await withRuntimeGenerationHarness(seed: 10_101) { harness in
            let first = try await harness.installFirstGeneration()
            let before = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )
            let collidingLifecycle = try harness.freshLifecycle(seed: 10_101)

            do {
                _ = try await collidingLifecycle.installFirstGeneration(
                    keyCustody: FixedRuntimeAttachmentKeyCustody()
                )
                XCTFail("Expected deterministic generation identity collision")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }

            let after = try RuntimeGenerationArtifactSnapshot.capture(
                locations: harness.locations
            )
            XCTAssertEqual(after.selectorBytes, before.selectorBytes)
            XCTAssertEqual(
                try await harness.resolveActive().selector.generationID,
                first.generationID
            )
            return ()
        }
    }

    func testDeterministicInputsProduceStableSelectorAuthorityAndReportDigests() async throws {
        let first = try await captureDeterministicIdentity(seed: 10_202)
        let second = try await captureDeterministicIdentity(seed: 10_202)

        XCTAssertEqual(first.generationID, second.generationID)
        XCTAssertEqual(first.authorityDigest, second.authorityDigest)
        XCTAssertEqual(first.selectorDigest, second.selectorDigest)
        XCTAssertEqual(first.verificationID, second.verificationID)
    }

    func testDatabaseIdentityTamperBlocksResolutionAndPreservesSelector() async throws {
        try await withRuntimeGenerationHarness(seed: 10_303) { harness in
            _ = try await harness.installFirstGeneration()
            let resolved = try await harness.resolveActive()
            let selectorBefore = try Data(contentsOf: harness.locations.activeManifestURL)
            let database = try SQLiteDatabase(
                url: resolved.databaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
            )
            try await database.execute("DROP INDEX runtime_events_command_sequence_idx")
            try await database.close()

            do {
                _ = try await harness.resolveActive()
                XCTFail("Expected target identity verification to fail")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }
            XCTAssertEqual(
                try Data(contentsOf: harness.locations.activeManifestURL),
                selectorBefore
            )
            return ()
        }
    }

    func testTargetSelectorBindsImmutableSourceGenerationAndDigestChain() async throws {
        try await withRuntimeGenerationHarness(seed: 10_404) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "migration-vault-token"
            )
            let target = try await harness.lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )
            let resolved = try await harness.resolveActive()

            XCTAssertEqual(resolved.selector.generationID, target.generationID)
            XCTAssertEqual(
                resolved.selector.priorGenerationID,
                source.resolved.selector.generationID
            )
            XCTAssertEqual(
                resolved.selector.priorAuthorityManifestDigest,
                source.resolved.candidate.authorityManifest.manifestDigest
            )
            try await source.close()
            return ()
        }
    }

    func testPredecessorAuthorityTamperInvalidatesDescendantResolution() async throws {
        try await withRuntimeGenerationHarness(seed: 10_505) { harness in
            let sourceActivation = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "predecessor-tamper-vault"
            )
            _ = try await harness.lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )
            try await source.close()
            let predecessorAuthorityURL = harness.locations.generationDirectoryURL(
                for: sourceActivation.generationID
            ).appendingPathComponent("Authority.json")
            try Data("{}".utf8).write(to: predecessorAuthorityURL, options: .atomic)
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: predecessorAuthorityURL,
                artifact: "tampered_predecessor_authority"
            )

            do {
                _ = try await harness.resolveActive()
                XCTFail("A descendant cannot remain valid after predecessor tamper")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }
            return ()
        }
    }

    private func captureDeterministicIdentity(
        seed: UInt64
    ) async throws -> (
        generationID: RuntimeStoreGenerationID,
        authorityDigest: String,
        selectorDigest: String,
        verificationID: String
    ) {
        try await withRuntimeGenerationHarness(seed: seed) { harness in
            let result = try await harness.installFirstGeneration()
            return (
                result.generationID,
                result.authorityManifestDigest,
                result.selectorFileSHA256,
                result.verificationID
            )
        }
    }
}
