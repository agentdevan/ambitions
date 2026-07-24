import AmbitionsRuntimeSQLite
@testable import Ambitions
import XCTest

final class CanonicalRuntimeStoreGenerationTests: XCTestCase {
    func testExactPathManifestRoundTripAndGenerationIdentityAreImmutable() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let generationID = try RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)

        let manifest = try await manager.createAndActivateGeneration(
            id: generationID,
            activatedAt: Date(timeIntervalSince1970: 1_700_000_000)
        ).manifest
        let resolved = try await manager.resolveActiveGeneration()
        let locations = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        )

        XCTAssertEqual(
            resolved.databaseURL,
            applicationSupportURL
                .appendingPathComponent("LocalRuntimeOS/Stores", isDirectory: true)
                .appendingPathComponent(generationID.pathComponent, isDirectory: true)
                .appendingPathComponent("Runtime.sqlite", isDirectory: false)
        )
        XCTAssertEqual(
            locations.generationManifestURL(for: resolved.manifest.generationID),
            resolved.generationDirectoryURL.appendingPathComponent(
                "Generation.json",
                isDirectory: false
            )
        )
        XCTAssertEqual(
            manifest.relativeDatabasePath,
            "Stores/\(generationID.pathComponent)/Runtime.sqlite"
        )
        XCTAssertEqual(resolved.manifest, manifest)
        XCTAssertNil(manifest.priorGenerationID)
        XCTAssertNil(manifest.priorGenerationDigestSHA256)

        await XCTAssertThrowsErrorAsync(
            try await manager.createAndActivateGeneration(id: generationID)
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalGenerationAlreadyExists(id: generationID.pathComponent)
            )
        }
    }

    func testFirstInstallRecoversStagingAndQuarantinesGenerationOrphan() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let locations = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        )
        try FileManager.default.createDirectory(
            at: locations.storesURL,
            withIntermediateDirectories: true
        )
        let stagingURL = locations.storesURL.appendingPathComponent(
            ".staging-interrupted",
            isDirectory: true
        )
        let orphanURL = locations.storesURL.appendingPathComponent(
            "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: stagingURL, withIntermediateDirectories: false)
        try FileManager.default.createDirectory(at: orphanURL, withIntermediateDirectories: false)
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)

        _ = try await manager.createAndActivateGeneration()

        let entries = try FileManager.default.contentsOfDirectory(
            at: locations.storesURL,
            includingPropertiesForKeys: nil
        ).map(\.lastPathComponent)
        XCTAssertFalse(entries.contains(".staging-interrupted"))
        XCTAssertFalse(entries.contains(orphanURL.lastPathComponent))
        XCTAssertEqual(
            entries.filter { $0.hasPrefix(".inactive-recovery-") }.count,
            1
        )
    }

    func testInjectedActivationFailurePreservesPriorManifest() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let firstManager = try makeManager(
            applicationSupportURL: applicationSupportURL
        )
        let first = try await firstManager.createAndActivateGeneration().manifest
        let manifestURL = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        ).activeManifestURL
        let before = try Data(contentsOf: manifestURL)

        let failingManager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            manifestActivator: FailingManifestActivator(failure: .injected),
            seed: 200
        )
        await XCTAssertThrowsErrorAsync(
            try await failingManager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalActivationFailed
            )
        }

        let after = try Data(contentsOf: manifestURL)
        let stillActive = try await firstManager.resolveActiveGeneration()
        XCTAssertEqual(after, before)
        XCTAssertEqual(stillActive.manifest.generationID, first.generationID)
    }

    func testRealAtomicActivatorRestoresPriorManifestAtEveryPrecommitFaultPhase() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let firstManager = try makeManager(applicationSupportURL: applicationSupportURL)
        let first = try await firstManager.createAndActivateGeneration().manifest
        let manifestURL = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        ).activeManifestURL
        let originalManifestData = try Data(contentsOf: manifestURL)
        let phases: [RuntimeStoreManifestActivationFaultPhase] = [
            .temporaryDurable,
            .rollbackDurable,
            .manifestRenamed,
            .manifestDurable,
        ]

        for (offset, phase) in phases.enumerated() {
            let manager = try makeManager(
                applicationSupportURL: applicationSupportURL,
                manifestActivator: AtomicRuntimeStoreManifestActivator(
                    injectedFailurePhase: phase
                ),
                seed: UInt64(1_000 + offset)
            )
            await XCTAssertThrowsErrorAsync(
                try await manager.createAndActivateGeneration()
            )
            XCTAssertEqual(try Data(contentsOf: manifestURL), originalManifestData)
            let stillActive = try await firstManager.resolveActiveGeneration()
            XCTAssertEqual(stillActive.manifest.generationID, first.generationID)
        }
    }

    func testRealAtomicActivatorReportsCommittedCleanupFaultTruthfully() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let baselineManager = try makeManager(
            applicationSupportURL: applicationSupportURL
        )
        _ = try await baselineManager.createAndActivateGeneration()
        let manager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            manifestActivator: AtomicRuntimeStoreManifestActivator(
                injectedFailurePhase: .committedCleanup
            )
        )

        let outcome = try await manager.createAndActivateGeneration()

        guard case .activatedWithCleanupWarning = outcome else {
            return XCTFail("Expected committed activation with cleanup warning")
        }
        _ = try await manager.resolveActiveGeneration()
    }

    func testRealAtomicActivatorReturnsUnknownForUnexpectedPriorAuthority() throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manifestURL = applicationSupportURL.appendingPathComponent(
            "active-store.json",
            isDirectory: false
        )
        try Data("prior".utf8).write(to: manifestURL, options: [.withoutOverwriting])
        let replacement = Data("replacement".utf8)
        let state = AtomicRuntimeStoreManifestActivator().replaceActiveManifest(
            with: replacement,
            at: manifestURL,
            expectedPriorDigest: String(repeating: "0", count: 64),
            expectedNewDigest: LocalRuntimeStorageChecksum.sha256Hex(for: replacement),
            temporaryNameToken: "11111111-2222-4333-8444-555555555555",
            rollbackNameToken: "66666666-7777-4888-8999-aaaaaaaaaaaa"
        )

        XCTAssertEqual(state, .unknown)
        XCTAssertEqual(try Data(contentsOf: manifestURL), Data("prior".utf8))
    }

    func testFullDiskActivationMapsToTypedFailureAndLeavesActiveGenerationUnchanged() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let firstManager = try makeManager(
            applicationSupportURL: applicationSupportURL
        )
        let first = try await firstManager.createAndActivateGeneration().manifest
        let fullDiskManager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            manifestActivator: FailingManifestActivator(failure: .fullDisk),
            seed: 300
        )

        await XCTAssertThrowsErrorAsync(
            try await fullDiskManager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalStorageFull(operation: "activate_manifest")
            )
        }
        let stillActive = try await firstManager.resolveActiveGeneration()
        XCTAssertEqual(stillActive.manifest.generationID, first.generationID)
    }

    func testCommittedManifestWithCleanupWarningIsReportedAsSuccessful() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            manifestActivator: CommittedWarningManifestActivator()
        )
        let outcome = try await manager.createAndActivateGeneration()
        guard case let .activatedWithCleanupWarning(manifest) = outcome else {
            return XCTFail("Expected committed activation with cleanup warning")
        }
        let resolved = try await manager.resolveActiveGeneration()
        XCTAssertEqual(resolved.manifest, manifest)
    }

    func testSchemaHealthReportsWALForeignKeysFullSyncAndExactTables() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let manifest = try await manager.createAndActivateGeneration().manifest
        let store = try await CanonicalRuntimeStore.openActive(using: manager)
        let health = try await store.health()

        XCTAssertEqual(health.metadata.schemaVersion, canonicalRuntimeStoreSchemaVersion)
        XCTAssertEqual(health.metadata.generationID, manifest.generationID)
        XCTAssertEqual(
            health.schema.observedRuntimeTables,
            CanonicalRuntimeStore.expectedRuntimeTables
        )
        XCTAssertEqual(
            health.schema.observedRuntimeIndexes,
            CanonicalRuntimeStore.expectedRuntimeIndexes
        )
        XCTAssertTrue(health.foreignKeysEnabled)
        XCTAssertTrue(health.usesWriteAheadLogging)
        XCTAssertTrue(health.usesFullSynchronization)
        XCTAssertEqual(health.effectiveUserVersion, canonicalRuntimeStoreSchemaVersion)
        XCTAssertTrue(health.databaseIdentityVerified)
        XCTAssertTrue(health.isStructurallyHealthy)

    }

    func testStructuralConstraintsRejectNegativeAggregateRevision() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let database = try SQLiteDatabase(
            url: resolved.databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )

        do {
            try await database.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision,
                    payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text("goal"),
                    .text("goal-negative"),
                    .integer(-1),
                    .integer(1),
                    .blob(Data([0x01])),
                    .text(String(repeating: "a", count: 64)),
                ]
            )
            XCTFail("Expected the nonnegative revision constraint to reject the row")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.primaryCode, 19)
        } catch {
            XCTFail("Unexpected structural constraint error: \(type(of: error))")
        }
    }

    func testPinnedReadersAndBoundedKeysetPagesDoNotDuplicateOrSkip() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let firstManifest = try await manager.createAndActivateGeneration().manifest
        let firstStore = try await CanonicalRuntimeStore.openActive(using: manager)
        try await seedThreeEvents(
            at: RuntimeStoreLocations(applicationSupportURL: applicationSupportURL)
                .databaseURL(for: firstManifest.generationID)
        )

        let firstPage = try await firstStore.events(limit: 2)
        let secondPage = try await firstStore.events(
            after: try XCTUnwrap(firstPage.nextCursor),
            limit: 2
        )
        XCTAssertEqual(firstPage.items.map(\.eventID), ["event-1", "event-2"])
        XCTAssertEqual(secondPage.items.map(\.eventID), ["event-3"])
        XCTAssertEqual(
            Set((firstPage.items + secondPage.items).map(\.eventID)).count,
            3
        )
        XCTAssertEqual(CanonicalRuntimeStore.maximumPageLimit, 200)

        let secondManifest = try await manager.createAndActivateGeneration().manifest
        let secondStore = try await CanonicalRuntimeStore.openActive(using: manager)
        let firstHealthAfterActivation = try await firstStore.health()
        let secondHealth = try await secondStore.health()
        XCTAssertEqual(
            firstHealthAfterActivation.metadata.generationID,
            firstManifest.generationID
        )
        XCTAssertEqual(secondHealth.metadata.generationID, secondManifest.generationID)
        XCTAssertNotEqual(
            firstStore.pinnedGenerationDirectoryURL,
            secondStore.pinnedGenerationDirectoryURL
        )
    }

    func testCompleteProtectionCoversDirectoryDatabaseSidecarsAndManifest() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let store = try await CanonicalRuntimeStore.openActive(using: manager)
        _ = try await store.health()
        let locations = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        )
        let artifacts = [
            locations.rootURL,
            locations.storesURL,
            resolved.generationDirectoryURL,
            resolved.databaseURL,
            URL(fileURLWithPath: resolved.databaseURL.path + "-wal"),
            URL(fileURLWithPath: resolved.databaseURL.path + "-shm"),
            locations.activeManifestURL,
        ]

        for artifact in artifacts {
            XCTAssertTrue(FileManager.default.fileExists(atPath: artifact.path))
            let attributes = try FileManager.default.attributesOfItem(
                atPath: artifact.path
            )
            XCTAssertEqual(
                attributes[.protectionKey] as? FileProtectionType,
                .complete,
                artifact.lastPathComponent
            )
        }
    }

    func testMalformedFutureManifestAndFutureDatabaseSchemaFailClosed() async throws {
        let malformedApplicationSupportURL = try scratchApplicationSupportURL()
        let malformedManager = try makeManager(
            applicationSupportURL: malformedApplicationSupportURL
        )
        _ = try await malformedManager.createAndActivateGeneration()
        let malformedManifestURL = RuntimeStoreLocations(
            applicationSupportURL: malformedApplicationSupportURL
        ).activeManifestURL
        try writeProtectedManifest(
            Data("{\"unexpected\":true}".utf8),
            to: malformedManifestURL
        )
        await XCTAssertThrowsErrorAsync(
            try await malformedManager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalManifestMalformed
            )
        }

        let futureApplicationSupportURL = try scratchApplicationSupportURL()
        let futureManager = try makeManager(
            applicationSupportURL: futureApplicationSupportURL
        )
        _ = try await futureManager.createAndActivateGeneration()
        let futureManifestURL = RuntimeStoreLocations(
            applicationSupportURL: futureApplicationSupportURL
        ).activeManifestURL
        var object = try XCTUnwrap(
            try JSONSerialization.jsonObject(
                with: Data(contentsOf: futureManifestURL)
            ) as? [String: Any]
        )
        object["format_version"] = canonicalRuntimeStoreManifestFormatVersion + 1
        try writeProtectedManifest(
            try JSONSerialization.data(withJSONObject: object),
            to: futureManifestURL
        )
        await XCTAssertThrowsErrorAsync(
            try await futureManager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalFutureManifestSchema(
                    maximumSupported: canonicalRuntimeStoreManifestFormatVersion,
                    actual: canonicalRuntimeStoreManifestFormatVersion + 1
                )
            )
        }

        let futureDatabaseApplicationSupportURL = try scratchApplicationSupportURL()
        let futureDatabaseManager = try makeManager(
            applicationSupportURL: futureDatabaseApplicationSupportURL
        )
        let resolved = try await activatedGeneration(using: futureDatabaseManager)
        try overwriteSQLiteUserVersion(
            at: resolved.databaseURL,
            with: UInt32(canonicalRuntimeStoreSchemaVersion + 1)
        )
        let walURL = URL(fileURLWithPath: resolved.databaseURL.path + "-wal")
        let shmURL = URL(fileURLWithPath: resolved.databaseURL.path + "-shm")
        for sidecarURL in [walURL, shmURL]
        where FileManager.default.fileExists(atPath: sidecarURL.path) {
            try FileManager.default.removeItem(at: sidecarURL)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: walURL.path))
        await XCTAssertThrowsErrorAsync(
            try await futureDatabaseManager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalFutureDatabaseSchema(
                    maximumSupported: canonicalRuntimeStoreSchemaVersion,
                    actual: canonicalRuntimeStoreSchemaVersion + 1
                )
            )
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: walURL.path))
    }

    func testManifestDigestBindsInstalledDatabaseIdentityContent() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let database = try SQLiteDatabase(
            url: resolved.databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        try await database.execute(
            "DROP INDEX runtime_events_command_sequence_idx"
        )

        await XCTAssertThrowsErrorAsync(
            try await manager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalManifestUnverified
            )
        }
    }

    func testProtectedDataBlockAndAppGroupBoundaryDoNotFallback() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let environment = try XCTUnwrap(
            RuntimeEnvironment.deterministic(
                now: Date(timeIntervalSince1970: 1_700_000_000),
                seed: 400
            )
        )
        let manager = try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: try TestRuntimeStoreRootAuthority(applicationSupportURL),
            protectedDataChecker: FixedProtectedDataChecker(isAvailable: false)
        )
        await XCTAssertThrowsErrorAsync(
            try await manager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .protectedDataUnavailable
            )
        }

        let locations = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        )
        XCTAssertEqual(
            locations.rootURL.deletingLastPathComponent(),
            applicationSupportURL
        )
        XCTAssertFalse(locations.rootURL.path.contains("group."))
        let forbiddenRoot = applicationSupportURL.appendingPathComponent(
            "group.example.shared",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: forbiddenRoot, withIntermediateDirectories: true)
        XCTAssertThrowsError(
            try TestRuntimeStoreRootAuthority(forbiddenRoot)
        ) { error in
            XCTAssertEqual(error as? LocalRuntimeStorageError, .canonicalPathAuthorityDenied)
        }
        let realRoot = applicationSupportURL.appendingPathComponent("real-root")
        let symbolicRoot = applicationSupportURL.appendingPathComponent("symbolic-root")
        try FileManager.default.createDirectory(at: realRoot, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: symbolicRoot,
            withDestinationURL: realRoot
        )
        XCTAssertThrowsError(
            try TestRuntimeStoreRootAuthority(symbolicRoot)
        ) { error in
            XCTAssertEqual(error as? LocalRuntimeStorageError, .canonicalPathAuthorityDenied)
        }
    }

    func testPinnedRootRejectsPathExchangeAfterAuthorityCreation() throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let authority = try TestRuntimeStoreRootAuthority(applicationSupportURL)
        let displacedURL = applicationSupportURL
            .deletingLastPathComponent()
            .appendingPathComponent("displaced-application-support", isDirectory: true)
        try FileManager.default.moveItem(
            at: applicationSupportURL,
            to: displacedURL
        )
        try FileManager.default.createDirectory(
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

    func testDeterministicEnvironmentProducesIdenticalGenerationManifest() async throws {
        let firstApplicationSupportURL = try scratchApplicationSupportURL()
        let secondApplicationSupportURL = try scratchApplicationSupportURL()
        let firstManager = try makeManager(
            applicationSupportURL: firstApplicationSupportURL,
            seed: 500
        )
        let secondManager = try makeManager(
            applicationSupportURL: secondApplicationSupportURL,
            seed: 500
        )

        let first = try await firstManager.createAndActivateGeneration().manifest
        let second = try await secondManager.createAndActivateGeneration().manifest

        XCTAssertEqual(first, second)
        XCTAssertEqual(
            first.databaseIdentitySHA256,
            second.databaseIdentitySHA256
        )
        XCTAssertEqual(
            first.generationDigestSHA256,
            second.generationDigestSHA256
        )
    }

    func testDeterministicGenerationCollisionFailsBeforeStagingOrActivation() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let firstManager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            seed: 600
        )
        let collidingManager = try makeManager(
            applicationSupportURL: applicationSupportURL,
            seed: 600
        )
        let first = try await firstManager.createAndActivateGeneration().manifest
        let manifestURL = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        ).activeManifestURL
        let manifestBeforeCollision = try Data(contentsOf: manifestURL)

        await XCTAssertThrowsErrorAsync(
            try await collidingManager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalGenerationAlreadyExists(id: first.generationID.rawValue)
            )
        }

        let manifestAfterCollision = try Data(contentsOf: manifestURL)
        XCTAssertEqual(manifestAfterCollision, manifestBeforeCollision)
        let storesURL = RuntimeStoreLocations(
            applicationSupportURL: applicationSupportURL
        ).storesURL
        let storeEntries = try FileManager.default.contentsOfDirectory(
            at: storesURL,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(
            storeEntries.map(\.lastPathComponent).filter { $0 != ".activation.lock" },
            [first.generationID.rawValue]
        )
    }

    func testEffectiveOpenedUserVersionRejectsOlderSchemaEvenWhenHeaderPreflightPassed() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let fixtureDatabase = try fixtureDatabase(for: resolved)
        try await fixtureDatabase.execute("PRAGMA user_version = 0")

        await XCTAssertThrowsErrorAsync(
            try await manager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalUnsupportedDatabaseSchema(
                    expected: canonicalRuntimeStoreSchemaVersion,
                    actual: 0
                )
            )
        }
    }

    func testEffectiveFutureUserVersionResidentOnLiveConnectionFailsClosed() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let fixtureDatabase = try fixtureDatabase(for: resolved)
        try await fixtureDatabase.execute(
            "PRAGMA user_version = \(canonicalRuntimeStoreSchemaVersion + 1)"
        )
        await XCTAssertThrowsErrorAsync(
            try await manager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalFutureDatabaseSchema(
                    maximumSupported: canonicalRuntimeStoreSchemaVersion,
                    actual: canonicalRuntimeStoreSchemaVersion + 1
                )
            )
        }
    }

    func testManifestOversizeAndSymbolicReplacementFailClosed() async throws {
        let oversizedRoot = try scratchApplicationSupportURL()
        let oversizedManager = try makeManager(applicationSupportURL: oversizedRoot)
        _ = try await oversizedManager.createAndActivateGeneration()
        let oversizedURL = RuntimeStoreLocations(
            applicationSupportURL: oversizedRoot
        ).activeManifestURL
        try writeProtectedManifest(
            Data(repeating: 0x61, count: RuntimeStoreManifestCodec.maximumByteCount + 1),
            to: oversizedURL
        )
        await XCTAssertThrowsErrorAsync(
            try await oversizedManager.resolveActiveGeneration()
        ) { error in
            XCTAssertEqual(error as? LocalRuntimeStorageError, .canonicalManifestMalformed)
        }

        let symbolicRoot = try scratchApplicationSupportURL()
        let symbolicManager = try makeManager(applicationSupportURL: symbolicRoot)
        let resolved = try await activatedGeneration(using: symbolicManager)
        let locations = RuntimeStoreLocations(applicationSupportURL: symbolicRoot)
        try FileManager.default.removeItem(at: locations.activeManifestURL)
        try FileManager.default.createSymbolicLink(
            at: locations.activeManifestURL,
            withDestinationURL: locations.generationManifestURL(
                for: resolved.manifest.generationID
            )
        )
        await XCTAssertThrowsErrorAsync(
            try await symbolicManager.resolveActiveGeneration()
        )
    }

    func testDatabaseSymbolicReplacementIsRejectedBeforeOpen() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let displacedURL = resolved.generationDirectoryURL.appendingPathComponent(
            "displaced.sqlite"
        )
        try FileManager.default.moveItem(at: resolved.databaseURL, to: displacedURL)
        try FileManager.default.createSymbolicLink(
            at: resolved.databaseURL,
            withDestinationURL: displacedURL
        )
        await XCTAssertThrowsErrorAsync(
            try await CanonicalRuntimeStore.openActive(using: manager)
        )
    }

    func testGenerationDigestBindsPriorChainAndImmutableGenerationRecord() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let first = try await manager.createAndActivateGeneration().manifest
        let second = try await manager.createAndActivateGeneration().manifest
        XCTAssertEqual(second.priorGenerationID, first.generationID)
        XCTAssertEqual(
            second.priorGenerationDigestSHA256,
            first.generationDigestSHA256
        )

        let locations = RuntimeStoreLocations(applicationSupportURL: applicationSupportURL)
        try writeProtectedManifest(
            Data("{}".utf8),
            to: locations.generationManifestURL(for: first.generationID)
        )
        await XCTAssertThrowsErrorAsync(
            try await manager.resolveActiveGeneration()
        ) { error in
            XCTAssertTrue(
                error is LocalRuntimeStorageError,
                "predecessor tampering must fail closed"
            )
        }
    }

    func testEventCommandForeignKeyAndLowercaseSHAConstraintsAreInstalled() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let fixtureDatabase = try fixtureDatabase(for: resolved)
        let foreignKeys = try await fixtureDatabase.query(
            "PRAGMA foreign_key_list(runtime_events)"
        )
        XCTAssertTrue(foreignKeys.contains { row in
            row.value(named: "from") == .text("command_id") &&
                row.value(named: "table") == .text("runtime_command_idempotency")
        })

        await XCTAssertThrowsErrorAsync(
            try await fixtureDatabase.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision,
                    payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text("goal"), .text("uppercase-sha"), .integer(0),
                    .integer(1), .blob(Data()),
                    .text(String(repeating: "A", count: 64)),
                ]
            )
        ) { error in
            XCTAssertEqual((error as? SQLiteError)?.primaryCode, 19)
        }
    }

    func testCompiledSchemaRejectsSameNamedIndexWithDifferentDefinition() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        let store = try await CanonicalRuntimeStore.openActive(using: manager)
        let fixtureDatabase = try fixtureDatabase(for: resolved)
        try await fixtureDatabase.transaction(.immediate) { database in
            try database.execute("DROP INDEX runtime_events_command_sequence_idx")
            try database.execute(
                """
                CREATE INDEX runtime_events_command_sequence_idx
                ON runtime_events(aggregate_id, sequence)
                """
            )
        }

        await XCTAssertThrowsErrorAsync(try await store.events()) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalIntegrityFailure
            )
        }
    }

    func testSameManagerConcurrentActivationSerializesWithTypedBusyFailure() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let gate = ControlledProtectedDataChecker()
        let environment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: Date(timeIntervalSince1970: 1_700_000_000), seed: 700
        ))
        let manager = try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: try TestRuntimeStoreRootAuthority(applicationSupportURL),
            protectedDataChecker: gate
        )
        let first = Task { try await manager.createAndActivateGeneration() }
        await gate.waitUntilEntered()
        await XCTAssertThrowsErrorAsync(
            try await manager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(error as? LocalRuntimeStorageError, .canonicalActivationBusy)
        }
        await gate.release()
        _ = try await first.value
    }

    func testSeparateRootAuthoritiesSerializeThroughFileLock() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let firstAuthority = try TestRuntimeStoreRootAuthority(applicationSupportURL)
        let secondAuthority = try TestRuntimeStoreRootAuthority(applicationSupportURL)
        let gate = ControlledProtectedDataChecker()
        let firstEnvironment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: Date(timeIntervalSince1970: 1_700_000_000), seed: 701
        ))
        let secondEnvironment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: Date(timeIntervalSince1970: 1_700_000_001), seed: 702
        ))
        let firstManager = try RuntimeStoreGenerationManager(
            environment: firstEnvironment,
            rootAuthority: firstAuthority,
            protectedDataChecker: gate
        )
        let secondManager = try RuntimeStoreGenerationManager(
            environment: secondEnvironment,
            rootAuthority: secondAuthority,
            protectedDataChecker: FixedProtectedDataChecker(isAvailable: true)
        )
        let first = Task { try await firstManager.createAndActivateGeneration() }
        await gate.waitUntilEntered()
        await XCTAssertThrowsErrorAsync(
            try await secondManager.createAndActivateGeneration()
        ) { error in
            XCTAssertEqual(error as? LocalRuntimeStorageError, .canonicalActivationBusy)
        }
        await gate.release()
        _ = try await first.value
    }

    func testCancellationReleasesLeaseAndFileLock() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let gate = ControlledProtectedDataChecker()
        let environment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: Date(timeIntervalSince1970: 1_700_000_000), seed: 703
        ))
        let manager = try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: try TestRuntimeStoreRootAuthority(applicationSupportURL),
            protectedDataChecker: gate
        )
        let cancelled = Task { try await manager.createAndActivateGeneration() }
        await gate.waitUntilEntered()
        cancelled.cancel()
        await gate.release()
        do {
            _ = try await cancelled.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
        }
        _ = try await manager.createAndActivateGeneration()
    }

    func testTombstoneKeysetPaginationIsDeterministicAndPageBytesAreBounded() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        try await seedThreeEvents(at: resolved.databaseURL)
        try await seedTombstones(
            in: fixtureDatabase(for: resolved),
            count: 3,
            payloadByteCount: 1
        )
        let store = try await CanonicalRuntimeStore.openActive(using: manager)

        let first = try await store.tombstones(limit: 2)
        let second = try await store.tombstones(
            after: try XCTUnwrap(first.nextCursor),
            limit: 2
        )
        XCTAssertEqual(first.items.map(\.objectID.id), ["object-1", "object-2"])
        XCTAssertEqual(second.items.map(\.objectID.id), ["object-3"])
    }

    func testCumulativePageByteCeilingRejectsOtherwiseLegalValues() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        let resolved = try await activatedGeneration(using: manager)
        try await seedThreeEvents(at: resolved.databaseURL)
        try await seedTombstones(
            in: fixtureDatabase(for: resolved),
            count: 5,
            payloadByteCount: 1_048_000
        )
        let store = try await CanonicalRuntimeStore.openActive(using: manager)

        await XCTAssertThrowsErrorAsync(
            try await store.tombstones(limit: 5)
        ) { error in
            XCTAssertEqual(
                error as? LocalRuntimeStorageError,
                .canonicalReadPageTooLarge(
                    maximumBytes: CanonicalRuntimeStore.maximumReadPageBytes
                )
            )
        }

        // A decoded-byte budget abort finalizes its statement and leaves the
        // retained authority connection usable for subsequent bounded work.
        let health = try await store.health()
        XCTAssertTrue(health.isStructurallyHealthy)
    }

    func testExplicitFullMaintenanceAuditReportsHealthyActiveStore() async throws {
        let applicationSupportURL = try scratchApplicationSupportURL()
        let manager = try makeManager(applicationSupportURL: applicationSupportURL)
        _ = try await activatedGeneration(using: manager)
        let store = try await CanonicalRuntimeStore.openActive(using: manager)

        let audit = try await store.fullMaintenanceAudit()

        XCTAssertTrue(audit.integrity.isOK)
        XCTAssertTrue(audit.foreignKeyViolations.isEmpty)
        XCTAssertTrue(audit.databaseIdentityVerified)
        XCTAssertTrue(audit.isValid)
    }
}

private extension CanonicalRuntimeStoreGenerationTests {
    func makeManager(
        applicationSupportURL: URL,
        manifestActivator: any RuntimeStoreManifestActivating = AtomicRuntimeStoreManifestActivator(),
        seed: UInt64 = 100
    ) throws -> RuntimeStoreGenerationManager {
        let environment = try XCTUnwrap(
            RuntimeEnvironment.deterministic(
                now: Date(timeIntervalSince1970: 1_700_000_000),
                seed: seed
            )
        )
        return try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: try TestRuntimeStoreRootAuthority(applicationSupportURL),
            protectedDataChecker: FixedProtectedDataChecker(isAvailable: true),
            manifestActivator: manifestActivator
        )
    }

    func activatedGeneration(
        using manager: RuntimeStoreGenerationManager
    ) async throws -> ResolvedRuntimeStoreGeneration {
        _ = try await manager.createAndActivateGeneration()
        return try await manager.resolveActiveGeneration()
    }

    func fixtureDatabase(
        for generation: ResolvedRuntimeStoreGeneration
    ) throws -> SQLiteDatabase {
        try SQLiteDatabase(
            url: generation.databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(
                openMode: .existingOnly
            )
        )
    }

    func seedThreeEvents(at databaseURL: URL) async throws {
        let database = try SQLiteDatabase(
            url: databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        try await database.transaction(.immediate) { database in
            try database.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision,
                    payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text("goal"),
                    .text("goal-1"),
                    .integer(3),
                    .integer(1),
                    .blob(Data([0x01])),
                    .text(String(repeating: "a", count: 64)),
                ]
            )
            for index in 1...3 {
                try database.execute(
                    """
                    INSERT INTO runtime_command_idempotency(
                        scope, idempotency_key, command_id, command_fingerprint,
                        claim_version, claim_payload, claimed_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("test"),
                        .text("key-\(index)"),
                        .text("command-\(index)"),
                        .text(String(repeating: String(index), count: 64)),
                        .integer(1),
                        .blob(Data([UInt8(index)])),
                        .integer(Int64(index)),
                    ]
                )
                try database.execute(
                    """
                    INSERT INTO runtime_events(
                        event_id, command_id, aggregate_kind, aggregate_id,
                        correlation_id, causation_event_id, event_version,
                        payload, payload_checksum, previous_event_hash,
                        event_hash, recorded_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("event-\(index)"),
                        .text("command-\(index)"),
                        .text("goal"),
                        .text("goal-1"),
                        .text("correlation-1"),
                        index == 1 ? .null : .text("event-\(index - 1)"),
                        .integer(1),
                        .blob(Data([UInt8(index)])),
                        .text(String(repeating: "b", count: 64)),
                        index == 1
                            ? .null
                            : .text(String(repeating: String(index - 1), count: 64)),
                        .text(String(repeating: String(index), count: 64)),
                        .integer(Int64(index)),
                    ]
                )
            }
        }
    }

    func seedTombstones(
        in database: SQLiteDatabase,
        count: Int,
        payloadByteCount: Int
    ) async throws {
        try await database.transaction(.immediate) { database in
            for index in 1...count {
                try database.execute(
                    """
                    INSERT INTO runtime_tombstones(
                        object_kind, object_id, revision,
                        causal_event_sequence, tombstone_version,
                        payload, checksum, created_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("goal"),
                        .text("object-\(index)"),
                        .integer(Int64(index)),
                        .integer(Int64(min(index, 3))),
                        .integer(1),
                        .blob(Data(repeating: UInt8(index), count: payloadByteCount)),
                        .text(String(repeating: "c", count: 64)),
                        .integer(Int64(index)),
                    ]
                )
            }
        }
    }

    func writeProtectedManifest(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: [.atomic])
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: url,
            artifact: "test_manifest"
        )
    }

    func overwriteSQLiteUserVersion(at url: URL, with version: UInt32) throws {
        let handle = try FileHandle(forWritingTo: url)
        try handle.seek(toOffset: 60)
        try handle.write(contentsOf: Data([
            UInt8((version >> 24) & 0xff),
            UInt8((version >> 16) & 0xff),
            UInt8((version >> 8) & 0xff),
            UInt8(version & 0xff),
        ]))
        try handle.synchronize()
        try handle.close()
    }

    func scratchApplicationSupportURL() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "CanonicalRuntimeStoreGenerationTests-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = root.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        addTeardownBlock {
            if FileManager.default.fileExists(atPath: root.path) {
                try FileManager.default.removeItem(at: root)
            }
        }
        return applicationSupportURL
    }

}

/// A test-target-only root authority. Production code exposes no arbitrary
/// root constructor, including in Debug app configurations.
private struct TestRuntimeStoreRootAuthority: RuntimeStoreRootAuthorityProviding {
    let applicationSupportURL: URL
    let activationCoordinator = RuntimeStoreActivationCoordinator()
    private let directoryPin: RuntimeStoreDirectoryPin

    init(_ applicationSupportURL: URL) throws {
        let standardizedURL = applicationSupportURL.standardizedFileURL
        self.applicationSupportURL = standardizedURL
        directoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            standardizedURL,
            createFinalComponentIfMissing: false
        )
    }

    func revalidatePinnedRoot() throws {
        try directoryPin.revalidate()
    }
}

private struct FixedProtectedDataChecker: RuntimeStoreProtectedDataChecking {
    let isAvailable: Bool

    func isProtectedDataAvailable() async -> Bool {
        isAvailable
    }
}

private actor ControlledProtectedDataChecker: RuntimeStoreProtectedDataChecking {
    private var entered = false
    private var entryWaiters: [CheckedContinuation<Void, Never>] = []
    private var releaseContinuation: CheckedContinuation<Void, Never>?

    func isProtectedDataAvailable() async -> Bool {
        if entered { return true }
        entered = true
        entryWaiters.forEach { $0.resume() }
        entryWaiters.removeAll()
        await withCheckedContinuation { continuation in
            releaseContinuation = continuation
        }
        return true
    }

    func waitUntilEntered() async {
        if entered { return }
        await withCheckedContinuation { entryWaiters.append($0) }
    }

    func release() {
        releaseContinuation?.resume()
        releaseContinuation = nil
    }
}

private struct FailingManifestActivator: RuntimeStoreManifestActivating {
    let failure: ManifestActivationTestFailure

    func replaceActiveManifest(
        with data: Data,
        at manifestURL: URL,
        expectedPriorDigest: String?,
        expectedNewDigest: String,
        temporaryNameToken: String,
        rollbackNameToken: String
    ) -> RuntimeStoreManifestActivationState {
        _ = data
        _ = manifestURL
        _ = expectedPriorDigest
        _ = expectedNewDigest
        _ = temporaryNameToken
        _ = rollbackNameToken
        switch failure {
        case .injected:
            return .unchanged(.canonicalActivationFailed)
        case .fullDisk:
            return .unchanged(
                .canonicalStorageFull(operation: "activate_manifest")
            )
        }
    }
}

private struct CommittedWarningManifestActivator: RuntimeStoreManifestActivating {
    func replaceActiveManifest(
        with data: Data,
        at manifestURL: URL,
        expectedPriorDigest: String?,
        expectedNewDigest: String,
        temporaryNameToken: String,
        rollbackNameToken: String
    ) -> RuntimeStoreManifestActivationState {
        _ = expectedPriorDigest
        _ = temporaryNameToken
        _ = rollbackNameToken
        guard LocalRuntimeStorageChecksum.sha256Hex(for: data) == expectedNewDigest
        else { return .unchanged(.canonicalManifestUnverified) }
        do {
            try data.write(to: manifestURL, options: [.atomic])
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: manifestURL,
                artifact: "test_active_manifest"
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: manifestURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: manifestURL.deletingLastPathComponent()
            )
            return .committedWithCleanupWarning
        } catch {
            return .unchanged(
                RuntimeStoreFailureMapper.map(
                    error,
                    operation: "test_manifest_activation"
                )
            )
        }
    }
}

private enum ManifestActivationTestFailure: Sendable {
    case injected
    case fullDisk
}

private func captureActivationResult(
    _ manager: RuntimeStoreGenerationManager
) async -> Result<RuntimeStoreActivationOutcome, Error> {
    do {
        return .success(try await manager.createAndActivateGeneration())
    } catch {
        return .failure(error)
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void = { _ in },
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
