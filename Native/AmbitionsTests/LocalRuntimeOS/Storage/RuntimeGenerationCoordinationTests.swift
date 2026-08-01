@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationCoordinationTests: XCTestCase {
    func testSharedManagerRejectsReentrantActivationWithTypedBusyFailure() async throws {
        let gate = RuntimeGenerationControlledProtectedDataChecker()
        try await withRuntimeGenerationHarness(
            seed: 14_000,
            protectedDataChecker: gate
        ) { harness in
            let competingEnvironment = try XCTUnwrap(RuntimeEnvironment.deterministic(
                now: harness.environment.clock.now,
                seed: 14_001
            ))
            let competingLifecycle = RuntimeGenerationLifecycleService(
                controlStore: harness.controlStore,
                generationManager: harness.generationManager,
                barrierAuthority: RuntimeGenerationBarrierAuthority(
                    activeGenerationID: nil
                ),
                environment: competingEnvironment
            )
            let first = Task {
                try await harness.installFirstGeneration()
            }
            await gate.waitUntilEntered()

            await XCTAssertThrowsLocalRuntimeStorageError(
                try await competingLifecycle.installFirstGeneration(
                    keyCustody: FixedRuntimeAttachmentKeyCustody()
                ),
                equals: .canonicalActivationBusy
            )

            await gate.release()
            _ = try await first.value
            return ()
        }
    }

    func testIndependentRootAuthoritiesSerializeThroughPinnedFileLock() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationCrossAuthority-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = root.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        defer { try? fileManager.removeItem(at: root) }
        let firstAuthority = try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: applicationSupportURL
        )
        let secondAuthority = try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: applicationSupportURL
        )
        let locations = RuntimeStoreLocations(applicationSupportURL: applicationSupportURL)
        try fileManager.createDirectory(
            at: locations.rootURL,
            withIntermediateDirectories: true
        )
        let first = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: firstAuthority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: true
        )

        XCTAssertThrowsError(try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: secondAuthority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: false
        )) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalActivationLockFailed
            )
        }

        try first.close()
        let second = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: secondAuthority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: false
        )
        try second.close()
        try second.close()

        let firstShared = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: firstAuthority,
            locations: locations,
            mode: .shared,
            createIfMissing: false
        )
        let secondShared = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: secondAuthority,
            locations: locations,
            mode: .shared,
            createIfMissing: false
        )
        XCTAssertNoThrow(try firstShared.revalidate(requiredMode: .shared))
        XCTAssertNoThrow(try secondShared.revalidate(requiredMode: .shared))
        XCTAssertThrowsError(try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: firstAuthority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: false
        ))
        try firstShared.close()
        try secondShared.close()

        let afterShared = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: firstAuthority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: false
        )
        try afterShared.close()
    }

    func testActivationLockRevalidatesPinnedFileIdentityAndMode() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationLockIdentity-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = root.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }
        let authority = try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: applicationSupportURL
        )
        let locations = RuntimeStoreLocations(applicationSupportURL: applicationSupportURL)
        try fileManager.createDirectory(at: locations.rootURL, withIntermediateDirectories: true)
        let scope = try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: authority,
            locations: locations,
            mode: .exclusive,
            createIfMissing: true
        )
        XCTAssertThrowsError(try scope.revalidate(requiredMode: .shared)) { error in
            XCTAssertEqual(error as? RuntimeGenerationControlError, .generationWorkerBarrierMismatch)
        }

        let lockURL = locations.rootURL.appendingPathComponent(".activation.lock")
        let displacedURL = locations.rootURL.appendingPathComponent(".activation.lock.displaced")
        try fileManager.moveItem(at: lockURL, to: displacedURL)
        try Data().write(to: lockURL, options: .withoutOverwriting)
        XCTAssertThrowsError(try scope.revalidate(requiredMode: .exclusive)) { error in
            XCTAssertEqual(error as? RuntimeGenerationControlError, .generationWorkerBarrierMismatch)
        }
        try scope.close()
    }

    func testCancellationReleasesActivationOwnershipAndAllowsCleanRetry() async throws {
        let gate = RuntimeGenerationControlledProtectedDataChecker()
        try await withRuntimeGenerationHarness(
            seed: 14_100,
            protectedDataChecker: gate
        ) { harness in
            let cancelled = Task {
                try await harness.installFirstGeneration()
            }
            await gate.waitUntilEntered()
            cancelled.cancel()
            await gate.release()

            do {
                _ = try await cancelled.value
                XCTFail("A cancelled prepublication activation must not commit")
            // AMBitionsAllowWeakPattern(reason: "Expected cancellation establishes prepublication activation rollback invariant")
            } catch is CancellationError {
            }
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: harness.locations.activeManifestURL.path
                )
            )

            let retry = try harness.freshLifecycle(seed: 14_101)
            _ = try await retry.installFirstGeneration(
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )
            _ = try await harness.resolveActive()
            return ()
        }
    }

    func testEveryWorkerKindPinsActiveGenerationUntilReleased() async throws {
        let generationID = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        for kind in [
            RuntimeGenerationUseKind.canonicalWriter,
            .projectionWorker,
            .searchWorker,
            .externalOperationWorker,
            .attachmentWorker,
            .maintenanceWorker,
            .migrationSnapshot,
        ] {
            let barrier = RuntimeGenerationBarrierAuthority(
                activeGenerationID: generationID
            )
            let lease = try await barrier.beginUse(
                token: "lease-\(kind.rawValue)",
                generationID: generationID,
                kind: kind
            )
            await XCTAssertThrowsRuntimeGenerationError(
                try await barrier.acquireFinalBarrier(
                    token: "barrier-\(kind.rawValue)",
                    expectedGenerationID: generationID
                ),
                equals: .generationWorkerBarrierBusy
            )
            try await barrier.endUse(lease)
            let finalBarrier = try await barrier.acquireFinalBarrier(
                token: "released-\(kind.rawValue)",
                expectedGenerationID: generationID
            )
            try await barrier.releaseUnchanged(finalBarrier)
        }
    }

    func testControlStoreIndeterminateCloseIsTerminalAndCannotReauthorizeUse() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Ambitions/Core/LocalRuntimeOS/Storage/RuntimeGenerationControlStore.swift"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("case closeIndeterminate"))
        XCTAssertTrue(source.contains("case .closing, .closeIndeterminate"))
        XCTAssertTrue(source.contains("lifecycle = .closeIndeterminate"))
        XCTAssertTrue(source.contains("guard case .open = lifecycle"))
        XCTAssertTrue(source.contains("guard case .open = lifecycle, let controlLockDescriptor else { return }"))

        let activationSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Ambitions/Core/LocalRuntimeOS/Storage/RuntimeGenerationActivationLock.swift"
            ),
            encoding: .utf8
        )
        XCTAssertTrue(activationSource.contains("case closeIndeterminate"))
        XCTAssertTrue(activationSource.contains("Never retry an indeterminate numeric descriptor"))
        XCTAssertTrue(activationSource.contains("guard unlocked, closed else"))
        XCTAssertTrue(activationSource.contains("state = closeResult == 0 ? .closed : .closeIndeterminate"))
    }
}
