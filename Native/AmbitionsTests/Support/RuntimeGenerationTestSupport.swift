import AmbitionsRuntimeSQLite
@testable import Ambitions
import Darwin
import Foundation
import XCTest

struct RuntimeGenerationTestRootAuthority: RuntimeStoreRootAuthorityProviding {
    let applicationSupportURL: URL
    let activationCoordinator = RuntimeStoreActivationCoordinator()
    private let directoryPin: RuntimeStoreDirectoryPin

    init(applicationSupportURL: URL) throws {
        let standardized = applicationSupportURL.standardizedFileURL
        directoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            standardized,
            createFinalComponentIfMissing: false
        )
        self.applicationSupportURL = standardized
    }

    func revalidatePinnedRoot() throws {
        try directoryPin.revalidate()
    }
}

struct RuntimeGenerationArtifactSnapshot: Sendable, Equatable {
    let selectorBytes: Data?
    let selectorDigest: String?
    let relativeEntries: [String]

    static func capture(
        locations: RuntimeStoreLocations,
        fileManager: FileManager = .default
    ) throws -> Self {
        let selectorBytes = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: locations.activeManifestURL
        )
        let entries: [String]
        if fileManager.fileExists(atPath: locations.rootURL.path) {
            let enumerator = fileManager.enumerator(
                at: locations.rootURL,
                includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
                options: []
            )
            var discovered: [String] = []
            while let entry = enumerator?.nextObject() as? URL {
                discovered.append(
                    entry.path.replacingOccurrences(
                        of: locations.rootURL.path + "/",
                        with: ""
                    )
                )
            }
            entries = discovered.sorted()
        } else {
            entries = []
        }
        return Self(
            selectorBytes: selectorBytes,
            selectorDigest: selectorBytes.map(LocalRuntimeStorageChecksum.sha256Hex(for:)),
            relativeEntries: entries
        )
    }
}

struct RuntimeGenerationEmptyV8Fixture: Sendable {
    let rootURL: URL
    let applicationSupportURL: URL
    let locations: RuntimeStoreLocations
    let generationID: RuntimeStoreGenerationID
    let databaseURL: URL
    let database: SQLiteDatabase

    static func make(
        generationID suppliedGenerationID: RuntimeStoreGenerationID? = nil,
        createdAtMilliseconds: Int64 = 1_700_000_000_000,
        fileManager: FileManager = .default
    ) async throws -> Self {
        let generationID = try suppliedGenerationID ?? RuntimeStoreGenerationID(
            validating: "11111111-2222-4333-8444-555555555555"
        )
        let rootURL = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationEmptyV8-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = rootURL.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        let locations = RuntimeStoreLocations(applicationSupportURL: applicationSupportURL)
        try fileManager.createDirectory(
            at: locations.generationDirectoryURL(for: generationID),
            withIntermediateDirectories: true
        )
        let databaseURL = locations.databaseURL(for: generationID)
        let database = try await RuntimeGenerationDatabaseAuthority.installEmptyV8(
            at: databaseURL,
            generationID: generationID,
            createdAtMilliseconds: createdAtMilliseconds
        )
        return Self(
            rootURL: rootURL,
            applicationSupportURL: applicationSupportURL,
            locations: locations,
            generationID: generationID,
            databaseURL: databaseURL,
            database: database
        )
    }

    func closeAndRemove(fileManager: FileManager = .default) async throws {
        try await database.close()
        if fileManager.fileExists(atPath: rootURL.path) {
            try fileManager.removeItem(at: rootURL)
        }
    }
}

struct RuntimeGenerationTestHarness: Sendable {
    let rootURL: URL
    let rootAuthority: RuntimeGenerationTestRootAuthority
    let locations: RuntimeStoreLocations
    let environment: RuntimeEnvironment
    let generationManager: RuntimeStoreGenerationManager
    let controlStore: RuntimeGenerationControlStore
    let barrierAuthority: RuntimeGenerationBarrierAuthority
    let lifecycle: RuntimeGenerationLifecycleService

    static func make(
        seed: UInt64 = 10_000,
        now: Date = Date(timeIntervalSince1970: 1_700_000_000),
        protectedDataChecker: any RuntimeStoreProtectedDataChecking =
            RuntimeGenerationFixedProtectedDataChecker(isAvailable: true),
        manifestActivator: any RuntimeStoreManifestActivating =
            AtomicRuntimeStoreManifestActivator(),
        fileManager: FileManager = .default
    ) async throws -> Self {
        let rootURL = fileManager.temporaryDirectory.appendingPathComponent(
            "RuntimeGenerationV8-\(UUID().uuidString)",
            isDirectory: true
        )
        let applicationSupportURL = rootURL.appendingPathComponent(
            "Application Support",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )
        let rootAuthority = try RuntimeGenerationTestRootAuthority(
            applicationSupportURL: applicationSupportURL
        )
        let environment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: now,
            seed: seed
        ))
        let manager = try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: rootAuthority,
            fileManager: fileManager,
            protectedDataChecker: protectedDataChecker,
            manifestActivator: manifestActivator
        )
        let locations = await manager.locations
        let controlStore = try await RuntimeGenerationControlStore.open(
            rootAuthority: rootAuthority,
            environment: environment,
            fileManager: fileManager
        )
        let barrier = RuntimeGenerationBarrierAuthority(activeGenerationID: nil)
        return Self(
            rootURL: rootURL,
            rootAuthority: rootAuthority,
            locations: locations,
            environment: environment,
            generationManager: manager,
            controlStore: controlStore,
            barrierAuthority: barrier,
            lifecycle: RuntimeGenerationLifecycleService(
                controlStore: controlStore,
                generationManager: manager,
                barrierAuthority: barrier,
                environment: environment,
                fileManager: fileManager
            )
        )
    }

    func installFirstGeneration() async throws -> RuntimeGenerationActivationResult {
        try await lifecycle.installFirstGeneration(
            keyCustody: FixedRuntimeAttachmentKeyCustody()
        )
    }

    func resolver(environment override: RuntimeEnvironment? = nil) -> RuntimeGenerationResolver {
        RuntimeGenerationResolver(
            rootAuthority: rootAuthority,
            locations: locations,
            controlStore: controlStore,
            barrierAuthority: barrierAuthority,
            environment: override ?? environment
        )
    }

    func resolveActive() async throws -> ResolvedRuntimeGenerationV8 {
        try await resolver().resolveActive()
    }

    func openActiveStore() async throws -> CanonicalRuntimeStoreV8 {
        let resolved = try await resolveActive()
        try await CanonicalRuntimeStoreV8.open(
            resolved: resolved,
            environment: environment
        )
    }

    func freshLifecycle(seed: UInt64) throws -> RuntimeGenerationLifecycleService {
        let resetEnvironment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: environment.clock.now,
            seed: seed
        ))
        return RuntimeGenerationLifecycleService(
            controlStore: controlStore,
            generationManager: generationManager,
            barrierAuthority: barrierAuthority,
            environment: resetEnvironment
        )
    }

    func lifecycle(
        seed: UInt64,
        manifestActivator: any RuntimeStoreManifestActivating,
        protectedDataChecker: any RuntimeStoreProtectedDataChecking =
            RuntimeGenerationFixedProtectedDataChecker(isAvailable: true)
    ) throws -> RuntimeGenerationLifecycleService {
        let resetEnvironment = try XCTUnwrap(RuntimeEnvironment.deterministic(
            now: environment.clock.now,
            seed: seed
        ))
        let manager = try RuntimeStoreGenerationManager(
            environment: resetEnvironment,
            rootAuthority: rootAuthority,
            protectedDataChecker: protectedDataChecker,
            manifestActivator: manifestActivator
        )
        return RuntimeGenerationLifecycleService(
            controlStore: controlStore,
            generationManager: manager,
            barrierAuthority: barrierAuthority,
            environment: resetEnvironment
        )
    }

    func recoveryService() -> RuntimeGenerationRecoveryService {
        RuntimeGenerationRecoveryService(
            controlStore: controlStore,
            lifecycle: lifecycle,
            generationManager: generationManager,
            environment: environment
        )
    }

    func closeAndRemove(fileManager: FileManager = .default) async throws {
        try await controlStore.close()
        if fileManager.fileExists(atPath: rootURL.path) {
            try fileManager.removeItem(at: rootURL)
        }
    }
}

struct RuntimeGenerationFixedProtectedDataChecker: RuntimeStoreProtectedDataChecking {
    let isAvailable: Bool

    func isProtectedDataAvailable() async -> Bool {
        isAvailable
    }
}

actor RuntimeGenerationControlledProtectedDataChecker: RuntimeStoreProtectedDataChecking {
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

struct RuntimeGenerationFailingManifestActivator: RuntimeStoreManifestActivating {
    let state: RuntimeStoreManifestActivationState

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
        return state
    }
}

func withRuntimeGenerationHarness<Result: Sendable>(
    seed: UInt64 = 10_000,
    protectedDataChecker: any RuntimeStoreProtectedDataChecking =
        RuntimeGenerationFixedProtectedDataChecker(isAvailable: true),
    manifestActivator: any RuntimeStoreManifestActivating =
        AtomicRuntimeStoreManifestActivator(),
    operation: @Sendable (RuntimeGenerationTestHarness) async throws -> Result
) async throws -> Result {
    let harness = try await RuntimeGenerationTestHarness.make(
        seed: seed,
        protectedDataChecker: protectedDataChecker,
        manifestActivator: manifestActivator
    )
    do {
        let result = try await operation(harness)
        try await harness.closeAndRemove()
        return result
    } catch {
        let operationError = error
        do {
            try await harness.closeAndRemove()
        } catch {
            XCTFail("Runtime generation harness cleanup failed: \(error)")
        }
        throw operationError
    }
}

func withEmptyV8Database<Result: Sendable>(
    operation: @Sendable (RuntimeGenerationEmptyV8Fixture) async throws -> Result
) async throws -> Result {
    let fixture = try await RuntimeGenerationEmptyV8Fixture.make()
    do {
        let result = try await operation(fixture)
        try await fixture.closeAndRemove()
        return result
    } catch {
        let operationError = error
        do {
            try await fixture.closeAndRemove()
        } catch {
            XCTFail("Empty v8 fixture cleanup failed: \(error)")
        }
        throw operationError
    }
}

func XCTAssertThrowsRuntimeGenerationError<T>(
    _ expression: @autoclosure () async throws -> T,
    equals expected: RuntimeGenerationControlError,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected RuntimeGenerationControlError", file: file, line: line)
    } catch let error as RuntimeGenerationControlError {
        XCTAssertEqual(error, expected, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(type(of: error))", file: file, line: line)
    }
}

func XCTAssertThrowsLocalRuntimeStorageError<T>(
    _ expression: @autoclosure () async throws -> T,
    equals expected: LocalRuntimeStorageError,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected LocalRuntimeStorageError", file: file, line: line)
    } catch let error as LocalRuntimeStorageError {
        XCTAssertEqual(error, expected, file: file, line: line)
    } catch {
        XCTFail("Unexpected error: \(type(of: error))", file: file, line: line)
    }
}
