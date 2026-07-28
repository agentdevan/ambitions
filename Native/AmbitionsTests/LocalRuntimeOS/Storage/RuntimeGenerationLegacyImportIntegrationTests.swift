import AmbitionsRuntimeSQLite
@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationLegacyImportIntegrationTests: XCTestCase {
    func testExactV1SQLiteStagesForReviewWithoutMutatingActiveV8() async throws {
        try await withRuntimeGenerationHarness(seed: 16_000) { harness in
            let active = try await harness.installFirstGeneration()
            let sourceURL = try await Self.makeExactV1Source(in: harness)
            let sourceBytesBefore = try Data(contentsOf: sourceURL)
            let orphanURL = harness.locations.importsURL.appendingPathComponent(
                "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee",
                isDirectory: true
            )
            try FileManager.default.createDirectory(
                at: orphanURL,
                withIntermediateDirectories: false
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: orphanURL,
                artifact: "unowned_import_fixture"
            )
            let orphanBytes = Data("preserve-unowned-import".utf8)
            let orphanFile = orphanURL.appendingPathComponent("Original.bin")
            try orphanBytes.write(to: orphanFile)
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: orphanFile,
                artifact: "unowned_import_fixture_bytes"
            )
            let importer = RuntimeGenerationLegacyImportService(
                controlStore: harness.controlStore,
                generationManager: harness.generationManager,
                environment: harness.environment
            )

            let staged = try await importer.stageCanonicalSQLiteV1(
                sourceURL: sourceURL
            )

            XCTAssertEqual(staged.source.sourceKind, .canonicalV1)
            XCTAssertEqual(staged.source.sourceSchema, "canonical.sqlite.v1")
            XCTAssertEqual(staged.manifest.importID, staged.source.importID)
            XCTAssertEqual(staged.manifest.itemCount, 0)
            XCTAssertNil(staged.quarantine)
            XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBytesBefore)
            XCTAssertFalse(FileManager.default.fileExists(atPath: orphanURL.path))
            let quarantineEntries = try FileManager.default.contentsOfDirectory(
                at: harness.locations.quarantineURL,
                includingPropertiesForKeys: nil
            )
            let preservedOrphan = try XCTUnwrap(quarantineEntries.first)
            XCTAssertEqual(
                try Data(contentsOf: preservedOrphan.appendingPathComponent("Original.bin")),
                orphanBytes
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: harness.locations.quarantineURL,
                artifact: "import_quarantine_root"
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: preservedOrphan,
                artifact: "import_quarantine_entry"
            )

            let resolved = try await harness.resolveActive()
            XCTAssertEqual(resolved.selector.generationID, active.generationID)
            let store = try await CanonicalRuntimeStoreV8.open(
                resolved: resolved,
                environment: harness.environment
            )
            let effectiveVersion = try await store.withReadTransaction { database in
                try database.query("PRAGMA user_version").first?.values.first
            }
            XCTAssertEqual(
                effectiveVersion,
                .integer(Int64(runtimeCanonicalAttachmentSchemaVersion))
            )
            try await store.close()
            return ()
        }
    }

    func testCancelledStartupReconciliationDoesNotPoisonImporterState() async throws {
        try await withRuntimeGenerationHarness(seed: 16_100) { harness in
            _ = try await harness.installFirstGeneration()
            let sourceURL = try await Self.makeExactV1Source(in: harness)
            let importer = RuntimeGenerationLegacyImportService(
                controlStore: harness.controlStore,
                generationManager: harness.generationManager,
                environment: harness.environment
            )
            let cancelledAttempt = Task { () -> ImportStartupAttempt in
                withUnsafeCurrentTask { $0?.cancel() }
                do {
                    _ = try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL)
                    return .unexpectedSuccess
                } catch is CancellationError {
                    return .cancelled
                } catch {
                    return .unexpectedError(String(reflecting: type(of: error)))
                }
            }

            let cancelledOutcome = await cancelledAttempt.value
            XCTAssertEqual(cancelledOutcome, .cancelled)
            let staged = try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL)
            XCTAssertEqual(staged.source.sourceKind, .canonicalV1)
            XCTAssertEqual(staged.source.sourceSchema, "canonical.sqlite.v1")
            return ()
        }
    }

    func testTransientStartupInventoryFailureDoesNotPoisonImporterState() async throws {
        try await withRuntimeGenerationHarness(seed: 16_200) { harness in
            _ = try await harness.installFirstGeneration()
            let sourceURL = try await Self.makeExactV1Source(in: harness)
            let invalidEntry = harness.locations.importsURL.appendingPathComponent(
                "transient-regular-file"
            )
            try Data("transient".utf8).write(
                to: invalidEntry,
                options: .withoutOverwriting
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: invalidEntry,
                artifact: "transient_import_inventory_entry"
            )
            let importer = RuntimeGenerationLegacyImportService(
                controlStore: harness.controlStore,
                generationManager: harness.generationManager,
                environment: harness.environment
            )

            await XCTAssertThrowsLocalRuntimeStorageError(
                try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL),
                equals: .canonicalPathAuthorityDenied
            )
            XCTAssertTrue(FileManager.default.fileExists(atPath: invalidEntry.path))
            try FileManager.default.removeItem(at: invalidEntry)
            let staged = try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL)
            XCTAssertEqual(staged.source.sourceKind, .canonicalV1)
            return ()
        }
    }

    func testEveryStartupAndPreservationFaultIsRetryableWithoutPoisoningImporter() async throws {
        for (offset, phase) in RuntimeLegacyImportFaultPhase.allCases.enumerated() {
            try await withRuntimeGenerationHarness(seed: 16_300 + offset) { harness in
                let active = try await harness.installFirstGeneration()
                let sourceURL = try await Self.makeExactV1Source(in: harness)
                let sourceBytes = try Data(contentsOf: sourceURL)
                let fault = RuntimeLegacyImportOneShotFault(phase: phase)
                let importer = RuntimeGenerationLegacyImportService(
                    controlStore: harness.controlStore,
                    generationManager: harness.generationManager,
                    environment: harness.environment,
                    faultHook: fault
                )

                do {
                    _ = try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL)
                    XCTFail("Expected injected fault at \(phase.rawValue)")
                } catch {
                    XCTAssertEqual(
                        error as? RuntimeLegacyImportInjectedFault,
                        RuntimeLegacyImportInjectedFault(phase: phase)
                    )
                }
                XCTAssertTrue(fault.didInject)
                XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBytes)

                let retry = try await importer.stageCanonicalSQLiteV1(sourceURL: sourceURL)
                XCTAssertEqual(retry.source.sourceKind, .canonicalV1)
                XCTAssertEqual(retry.source.sourceSchema, "canonical.sqlite.v1")
                XCTAssertEqual(retry.manifest.importID, retry.source.importID)
                XCTAssertEqual(try Data(contentsOf: sourceURL), sourceBytes)

                let resolved = try await harness.resolveActive()
                XCTAssertEqual(resolved.selector.generationID, active.generationID)
                return ()
            }
        }
    }
}

private enum ImportStartupAttempt: Sendable, Equatable {
    case cancelled
    case unexpectedSuccess
    case unexpectedError(String)
}

private struct RuntimeLegacyImportInjectedFault: Error, Sendable, Equatable {
    let phase: RuntimeLegacyImportFaultPhase
}

private final class RuntimeLegacyImportOneShotFault:
    RuntimeLegacyImportFaultChecking,
    @unchecked Sendable
{
    private let lock = NSLock()
    private let phase: RuntimeLegacyImportFaultPhase
    private var injectionPending = true

    init(phase: RuntimeLegacyImportFaultPhase) {
        self.phase = phase
    }

    var didInject: Bool {
        lock.lock()
        defer { lock.unlock() }
        return injectionPending == false
    }

    func check(_ observedPhase: RuntimeLegacyImportFaultPhase) throws {
        lock.lock()
        defer { lock.unlock() }
        guard injectionPending, observedPhase == phase else { return }
        injectionPending = false
        throw RuntimeLegacyImportInjectedFault(phase: phase)
    }
}

private extension RuntimeGenerationLegacyImportIntegrationTests {
    static func makeExactV1Source(
        in harness: RuntimeGenerationTestHarness
    ) async throws -> URL {
        try FileManager.default.createDirectory(
            at: harness.locations.importsURL,
            withIntermediateDirectories: false
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: harness.locations.importsURL,
            artifact: "v1_fixture_imports_root"
        )
        try FileManager.default.createDirectory(
            at: harness.locations.coordinatedLegacySourcesURL,
            withIntermediateDirectories: false
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: harness.locations.coordinatedLegacySourcesURL,
            artifact: "v1_fixture_coordinated_root"
        )
        let sourceURL = harness.locations.coordinatedLegacySourcesURL
            .appendingPathComponent("Canonical-v1.sqlite")
        let database = try SQLiteDatabase(
            url: sourceURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(
                openMode: .createOrOpen
            )
        )
        let generationID = try RuntimeStoreGenerationID(
            validating: "aaaaaaaa-bbbb-4ccc-8ddd-eeeeeeeeeeee"
        )
        do {
            try await CanonicalRuntimeStore.installSchema(
                in: database,
                generationID: generationID,
                createdAtMilliseconds: 1_600_000_000_000
            )
            let checkpoint = try await database.checkpoint(.truncate)
            XCTAssertEqual(checkpoint.logFrameCount, checkpoint.checkpointedFrameCount)
            try await database.close()
        } catch {
            let operationError = error
            do {
                try await database.close()
            } catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_exact_v1_import_fixture"
                )
            }
            throw operationError
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: sourceURL,
            artifact: "v1_fixture_database"
        )
        return sourceURL
    }
}
