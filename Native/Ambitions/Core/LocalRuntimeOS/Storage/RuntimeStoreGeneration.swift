import AmbitionsRuntimeSQLite
import Darwin
import Foundation
import UIKit

let canonicalRuntimeStoreSchemaVersion = 1
let canonicalRuntimeStoreManifestFormatVersion = 1

extension RuntimeStoreGenerationID {
    var pathComponent: String {
        rawValue
    }
}

actor RuntimeStoreActivationCoordinator {
    private var holderToken: String?

    func acquire(token: String) throws {
        guard holderToken == nil else {
            throw LocalRuntimeStorageError.canonicalActivationBusy
        }
        holderToken = token
    }

    func release(token: String) throws {
        guard holderToken == token else {
            throw LocalRuntimeStorageError.canonicalActivationStateUnknown
        }
        holderToken = nil
    }
}

protocol RuntimeStoreRootAuthorityProviding: Sendable {
    var applicationSupportURL: URL { get }
    var activationCoordinator: RuntimeStoreActivationCoordinator { get }
    func revalidatePinnedRoot() throws
}

actor RuntimeStoreDirectoryPin {
    nonisolated let descriptor: Int32
    nonisolated let identity: RuntimeStoreFileIdentity
    nonisolated let pathURL: URL

    init(
        descriptor: Int32,
        identity: RuntimeStoreFileIdentity,
        pathURL: URL
    ) {
        self.descriptor = descriptor
        self.identity = identity
        self.pathURL = pathURL
    }

    deinit {
        _ = Darwin.close(descriptor)
    }

    nonisolated func revalidate() throws {
        var descriptorStatus = stat()
        var pathStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFDIR,
              lstat(pathURL.path, &pathStatus) == 0,
              pathStatus.st_mode & S_IFMT == S_IFDIR,
              pathStatus.st_mode & S_IFMT != S_IFLNK,
              RuntimeStoreFileIdentity(
                  device: UInt64(descriptorStatus.st_dev),
                  inode: UInt64(descriptorStatus.st_ino)
              ) == identity,
              RuntimeStoreFileIdentity(
                  device: UInt64(pathStatus.st_dev),
                  inode: UInt64(pathStatus.st_ino)
              ) == identity
        else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }
}

struct RuntimeStoreRootAuthority: RuntimeStoreRootAuthorityProviding {
    let applicationSupportURL: URL
    let activationCoordinator: RuntimeStoreActivationCoordinator
    private let directoryPin: RuntimeStoreDirectoryPin

    private init(
        applicationSupportURL: URL,
        directoryPin: RuntimeStoreDirectoryPin
    ) throws {
        let standardizedURL = applicationSupportURL.standardizedFileURL
        try directoryPin.revalidate()
        self.applicationSupportURL = standardizedURL
        self.directoryPin = directoryPin
        activationCoordinator = RuntimeStoreActivationCoordinator()
    }

    static func appPrivate(fileManager: FileManager = .default) throws -> Self {
        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let standardizedURL = applicationSupportURL.standardizedFileURL
        let pin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            standardizedURL,
            createFinalComponentIfMissing: true
        )
        return try Self(
            applicationSupportURL: standardizedURL,
            directoryPin: pin
        )
    }

    func revalidatePinnedRoot() throws {
        try directoryPin.revalidate()
    }
}

struct RuntimeStoreLocations: Sendable, Equatable {
    let applicationSupportURL: URL

    init(applicationSupportURL: URL) {
        self.applicationSupportURL = applicationSupportURL.standardizedFileURL
    }

    var rootURL: URL {
        applicationSupportURL.appendingPathComponent("LocalRuntimeOS", isDirectory: true)
    }

    var storesURL: URL {
        rootURL.appendingPathComponent("Stores", isDirectory: true)
    }

    var activeManifestURL: URL {
        rootURL.appendingPathComponent("active-store.json", isDirectory: false)
    }

    func generationDirectoryURL(for id: RuntimeStoreGenerationID) -> URL {
        storesURL.appendingPathComponent(id.pathComponent, isDirectory: true)
    }

    func databaseURL(for id: RuntimeStoreGenerationID) -> URL {
        generationDirectoryURL(for: id)
            .appendingPathComponent("Runtime.sqlite", isDirectory: false)
    }

    func generationManifestURL(for id: RuntimeStoreGenerationID) -> URL {
        generationDirectoryURL(for: id)
            .appendingPathComponent("Generation.json", isDirectory: false)
    }

    func relativeDatabasePath(for id: RuntimeStoreGenerationID) -> String {
        "Stores/\(id.pathComponent)/Runtime.sqlite"
    }

    func stagingDirectoryURL(
        for id: RuntimeStoreGenerationID,
        token: String
    ) -> URL {
        storesURL.appendingPathComponent(
            ".staging-\(id.pathComponent)-\(token)",
            isDirectory: true
        )
    }
}

struct ActiveRuntimeStoreManifest: Codable, Sendable, Equatable {
    let formatVersion: Int
    let generationID: RuntimeStoreGenerationID
    let relativeDatabasePath: String
    let schemaVersion: Int
    let activatedAt: Date
    let databaseIdentitySHA256: String
    let generationDigestSHA256: String
    let priorGenerationID: RuntimeStoreGenerationID?
    let priorGenerationDigestSHA256: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case formatVersion = "format_version"
        case generationID = "generation_id"
        case relativeDatabasePath = "relative_database_path"
        case schemaVersion = "schema_version"
        case activatedAt = "activated_at"
        case databaseIdentitySHA256 = "database_identity_sha256"
        case generationDigestSHA256 = "generation_digest_sha256"
        case priorGenerationID = "prior_generation_id"
        case priorGenerationDigestSHA256 = "prior_generation_digest_sha256"
    }
}

struct ResolvedRuntimeStoreGeneration: Sendable {
    let manifest: ActiveRuntimeStoreManifest
    let generationDirectoryURL: URL
    let databaseURL: URL
    let pinnedFiles: RuntimeStorePinnedFileSet
    let verifiedDatabase: SQLiteDatabase

    fileprivate init(
        manifest: ActiveRuntimeStoreManifest,
        generationDirectoryURL: URL,
        databaseURL: URL,
        pinnedFiles: RuntimeStorePinnedFileSet,
        verifiedDatabase: SQLiteDatabase
    ) {
        self.manifest = manifest
        self.generationDirectoryURL = generationDirectoryURL
        self.databaseURL = databaseURL
        self.pinnedFiles = pinnedFiles
        self.verifiedDatabase = verifiedDatabase
    }
}

enum RuntimeStoreActivationOutcome: Sendable, Equatable {
    case activated(ActiveRuntimeStoreManifest)
    case activatedWithCleanupWarning(ActiveRuntimeStoreManifest)

    var manifest: ActiveRuntimeStoreManifest {
        switch self {
        case let .activated(manifest),
             let .activatedWithCleanupWarning(manifest):
            manifest
        }
    }
}

protocol RuntimeStoreProtectedDataChecking: Sendable {
    func isProtectedDataAvailable() async -> Bool
}

struct ApplicationRuntimeStoreProtectedDataChecker: RuntimeStoreProtectedDataChecking {
    func isProtectedDataAvailable() async -> Bool {
        await MainActor.run { UIApplication.shared.isProtectedDataAvailable }
    }
}

protocol RuntimeStoreManifestActivating: Sendable {
    func replaceActiveManifest(
        with data: Data,
        at manifestURL: URL,
        expectedPriorDigest: String?,
        expectedNewDigest: String,
        temporaryNameToken: String,
        rollbackNameToken: String
    ) -> RuntimeStoreManifestActivationState
}

enum RuntimeStoreManifestActivationState: Sendable, Equatable {
    case committed
    case committedWithCleanupWarning
    case unchanged(LocalRuntimeStorageError)
    case unknown
}

enum RuntimeStoreManifestActivationFaultPhase: String, Sendable, CaseIterable {
    case temporaryDurable
    case rollbackDurable
    case manifestRenamed
    case manifestDurable
    case committedCleanup
}

struct AtomicRuntimeStoreManifestActivator: RuntimeStoreManifestActivating {
    private let injectedFailurePhase: RuntimeStoreManifestActivationFaultPhase?

    init(
        injectedFailurePhase: RuntimeStoreManifestActivationFaultPhase? = nil
    ) {
        self.injectedFailurePhase = injectedFailurePhase
    }

    func replaceActiveManifest(
        with data: Data,
        at manifestURL: URL,
        expectedPriorDigest: String?,
        expectedNewDigest: String,
        temporaryNameToken: String,
        rollbackNameToken: String
    ) -> RuntimeStoreManifestActivationState {
        do {
            try RuntimeStorePathValidation.requireSafeComponent(
                temporaryNameToken
            )
            try RuntimeStorePathValidation.requireSafeComponent(
                rollbackNameToken
            )
        } catch let error as LocalRuntimeStorageError {
            return .unchanged(error)
        } catch {
            return .unchanged(.canonicalActivationFailed)
        }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: data) == expectedNewDigest
        else {
            return .unchanged(.canonicalManifestUnverified)
        }
        let fileManager = FileManager.default
        let directoryURL = manifestURL.deletingLastPathComponent()
        let temporaryURL = manifestURL.deletingLastPathComponent().appendingPathComponent(
            ".active-store-\(temporaryNameToken).tmp",
            isDirectory: false
        )
        let rollbackURL = manifestURL.deletingLastPathComponent().appendingPathComponent(
            ".active-store-\(rollbackNameToken).rollback",
            isDirectory: false
        )
        let priorData: Data?
        do {
            priorData = try RuntimeStoreManifestDescriptorReader.readIfPresent(
                at: manifestURL
            )
            let observedPriorDigest = priorData.map {
                LocalRuntimeStorageChecksum.sha256Hex(for: $0)
            }
            guard observedPriorDigest == expectedPriorDigest else {
                return .unknown
            }
            try data.write(to: temporaryURL, options: [.withoutOverwriting])
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: temporaryURL,
                artifact: "active_manifest_temporary"
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: temporaryURL)
            try injectFailure(at: .temporaryDurable)
            if let priorData {
                try priorData.write(
                    to: rollbackURL,
                    options: [.withoutOverwriting]
                )
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    at: rollbackURL,
                    artifact: "active_manifest_rollback"
                )
                try RuntimeStoreFileDurability.synchronizeFile(at: rollbackURL)
                try injectFailure(at: .rollbackDurable)
            }
        } catch {
            let cleaned = cleanupDefinitelyInactiveArtifacts(
                temporaryURL: temporaryURL,
                rollbackURL: rollbackURL
            )
            return .unchanged(
                cleaned
                    ? RuntimeStoreFailureMapper.map(
                        error,
                        operation: "prepare_manifest_activation"
                    )
                    : .canonicalStagingCleanupFailed
            )
        }

        let renameResult = Darwin.rename(temporaryURL.path, manifestURL.path)
        let renameFailure = renameResult == 0
            ? nil
            : RuntimeStoreErrnoMapper.storageError(
                operation: "rename_active_manifest",
                fallback: .canonicalActivationFailed
            )
        let observedState = observedManifestState(
            at: manifestURL,
            oldDigest: expectedPriorDigest,
            newDigest: expectedNewDigest
        )
        switch observedState {
        case .new:
            do {
                try injectFailure(at: .manifestRenamed)
                try RuntimeStoreFileDurability.requireCompleteProtection(
                    at: manifestURL,
                    artifact: "active_manifest"
                )
                try RuntimeStoreFileDurability.synchronizeFile(at: manifestURL)
                try RuntimeStoreFileDurability.synchronizeDirectory(
                    at: directoryURL
                )
                try injectFailure(at: .manifestDurable)
            } catch {
                return restorePriorState(
                    priorData: priorData,
                    manifestURL: manifestURL,
                    temporaryURL: temporaryURL,
                    rollbackURL: rollbackURL,
                    directoryURL: directoryURL,
                    mayRemoveVerifiedAttemptedManifest: true,
                    expectedAttemptedDigest: expectedNewDigest,
                    failure: RuntimeStoreFailureMapper.map(
                        error,
                        operation: "synchronize_active_manifest"
                    )
                )
            }
            if injectedFailurePhase == .committedCleanup {
                return .committedWithCleanupWarning
            }
            return cleanupAfterCommittedActivation(
                rollbackURL: rollbackURL
            )
        case .old:
            let cleaned = cleanupDefinitelyInactiveArtifacts(
                temporaryURL: temporaryURL,
                rollbackURL: rollbackURL
            )
            return .unchanged(
                cleaned
                    ? (renameFailure ?? .canonicalActivationFailed)
                    : .canonicalStagingCleanupFailed
            )
        case .other, .unreadable:
            return .unknown
        case .missing:
            guard priorData != nil else {
                let cleaned = cleanupDefinitelyInactiveArtifacts(
                    temporaryURL: temporaryURL,
                    rollbackURL: rollbackURL
                )
                return .unchanged(
                    cleaned
                        ? (renameFailure ?? .canonicalActivationFailed)
                        : .canonicalStagingCleanupFailed
                )
            }
            return restorePriorState(
                priorData: priorData,
                manifestURL: manifestURL,
                temporaryURL: temporaryURL,
                rollbackURL: rollbackURL,
                directoryURL: directoryURL,
                mayRemoveVerifiedAttemptedManifest: false,
                expectedAttemptedDigest: expectedNewDigest,
                failure: renameFailure ?? .canonicalActivationStateUnknown
            )
        }
    }
}

private extension AtomicRuntimeStoreManifestActivator {
    enum ObservedManifestState: Equatable {
        case old
        case new
        case missing
        case other
        case unreadable
    }

    func injectFailure(
        at phase: RuntimeStoreManifestActivationFaultPhase
    ) throws {
        guard injectedFailurePhase == phase else { return }
        throw LocalRuntimeStorageError.canonicalActivationFailed
    }

    func observedManifestState(
        at manifestURL: URL,
        oldDigest: String?,
        newDigest: String
    ) -> ObservedManifestState {
        do {
            guard let data = try RuntimeStoreManifestDescriptorReader
                .readIfPresent(at: manifestURL) else {
                return .missing
            }
            let digest = LocalRuntimeStorageChecksum.sha256Hex(for: data)
            if digest == newDigest { return .new }
            if digest == oldDigest { return .old }
            return .other
        } catch {
            return .unreadable
        }
    }

    func restorePriorState(
        priorData: Data?,
        manifestURL: URL,
        temporaryURL: URL,
        rollbackURL: URL,
        directoryURL: URL,
        mayRemoveVerifiedAttemptedManifest: Bool,
        expectedAttemptedDigest: String,
        failure: LocalRuntimeStorageError
    ) -> RuntimeStoreManifestActivationState {
        do {
            if priorData != nil {
                guard FileManager.default.fileExists(atPath: rollbackURL.path)
                else { return .unknown }
                guard Darwin.rename(rollbackURL.path, manifestURL.path) == 0
                else { return .unknown }
            } else if mayRemoveVerifiedAttemptedManifest,
                      let currentData = try RuntimeStoreManifestDescriptorReader
                        .readIfPresent(at: manifestURL),
                      LocalRuntimeStorageChecksum.sha256Hex(for: currentData) ==
                        expectedAttemptedDigest {
                try FileManager.default.removeItem(at: manifestURL)
            } else if priorData == nil {
                return .unknown
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(at: directoryURL)
            let expectedOldDigest = priorData.map {
                LocalRuntimeStorageChecksum.sha256Hex(for: $0)
            }
            let restored = observedManifestState(
                at: manifestURL,
                oldDigest: expectedOldDigest,
                newDigest: ""
            )
            guard (priorData == nil && restored == .missing) || restored == .old
            else { return .unknown }
            guard cleanupDefinitelyInactiveArtifacts(
                temporaryURL: temporaryURL,
                rollbackURL: rollbackURL
            ) else {
                return .unchanged(.canonicalStagingCleanupFailed)
            }
            return .unchanged(failure)
        } catch {
            return .unknown
        }
    }

    func cleanupAfterCommittedActivation(
        rollbackURL: URL
    ) -> RuntimeStoreManifestActivationState {
        guard FileManager.default.fileExists(atPath: rollbackURL.path) else {
            return .committed
        }
        do {
            try FileManager.default.removeItem(at: rollbackURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: rollbackURL.deletingLastPathComponent()
            )
            return .committed
        } catch {
            return .committedWithCleanupWarning
        }
    }

    func cleanupDefinitelyInactiveArtifacts(
        temporaryURL: URL,
        rollbackURL: URL
    ) -> Bool {
        var cleaned = true
        for url in [temporaryURL, rollbackURL]
        where FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                cleaned = false
            }
        }
        if cleaned {
            do {
                try RuntimeStoreFileDurability.synchronizeDirectory(
                    at: temporaryURL.deletingLastPathComponent()
                )
            } catch {
                cleaned = false
            }
        }
        return cleaned
    }
}

actor RuntimeStoreGenerationManager {
    let locations: RuntimeStoreLocations

    private let rootAuthority: any RuntimeStoreRootAuthorityProviding
    private let fileManager: FileManager
    private let protectedDataChecker: any RuntimeStoreProtectedDataChecking
    private let manifestActivator: any RuntimeStoreManifestActivating
    private var environment: RuntimeEnvironment
    private var activationInProgress = false
    private var activationLockDescriptor: Int32?

    init(
        environment: RuntimeEnvironment,
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        fileManager: FileManager = .default,
        protectedDataChecker: any RuntimeStoreProtectedDataChecking =
            ApplicationRuntimeStoreProtectedDataChecker(),
        manifestActivator: any RuntimeStoreManifestActivating = AtomicRuntimeStoreManifestActivator()
    ) throws {
        try rootAuthority.revalidatePinnedRoot()
        self.rootAuthority = rootAuthority
        locations = RuntimeStoreLocations(
            applicationSupportURL: rootAuthority.applicationSupportURL
        )
        try RuntimeStorePathValidation.requireContained(
            locations.rootURL,
            in: rootAuthority.applicationSupportURL
        )
        try RuntimeStorePathValidation.requireContained(
            locations.storesURL,
            in: locations.rootURL
        )
        self.fileManager = fileManager
        self.protectedDataChecker = protectedDataChecker
        self.manifestActivator = manifestActivator
        self.environment = environment
    }

    func createAndActivateGeneration(
        id requestedID: RuntimeStoreGenerationID? = nil,
        activatedAt requestedActivationDate: Date? = nil
    ) async throws -> RuntimeStoreActivationOutcome {
        guard activationInProgress == false else {
            throw LocalRuntimeStorageError.canonicalActivationBusy
        }
        activationInProgress = true
        defer { activationInProgress = false }

        let leaseToken = environment.uuid.nextUUID().uuidString.lowercased()
        try await rootAuthority.activationCoordinator.acquire(token: leaseToken)
        do {
            try rootAuthority.revalidatePinnedRoot()
            try prepareCanonicalRoot()
            try acquireActivationFileLock()
            try recoverStaleUncommittedArtifacts()
            let outcome = try await performCreateAndActivateGeneration(
                id: requestedID,
                activatedAt: requestedActivationDate
            )
            try rootAuthority.revalidatePinnedRoot()
            try releaseActivationFileLock()
            try await rootAuthority.activationCoordinator.release(
                token: leaseToken
            )
            return outcome
        } catch {
            let operationError = error
            do {
                try releaseActivationFileLock()
                try await rootAuthority.activationCoordinator.release(
                    token: leaseToken
                )
            } catch {
                throw LocalRuntimeStorageError.canonicalActivationStateUnknown
            }
            throw operationError
        }
    }

    private func performCreateAndActivateGeneration(
        id requestedID: RuntimeStoreGenerationID?,
        activatedAt requestedActivationDate: Date?
    ) async throws -> RuntimeStoreActivationOutcome {
        try await requireProtectedData()
        try Task.checkCancellation()

        let id: RuntimeStoreGenerationID
        if let requestedID {
            id = requestedID
        } else {
            id = try RuntimeStoreGenerationID(
                validating: environment.uuid.nextUUID().uuidString.lowercased()
            )
        }
        let activatedAt = requestedActivationDate ?? environment.clock.now
        try RuntimeStorePathValidation.requireSafeComponent(id.pathComponent)
        _ = try Self.millisecondsSince1970(activatedAt)
        try prepareCanonicalRoot()
        let stagingNameToken = environment.uuid.nextUUID().uuidString.lowercased()

        let finalDirectoryURL = locations.generationDirectoryURL(for: id)
        guard fileManager.fileExists(atPath: finalDirectoryURL.path) == false else {
            throw LocalRuntimeStorageError.canonicalGenerationAlreadyExists(
                id: id.pathComponent
            )
        }

        let priorManifest = try await loadPriorManifestForActivation()
        let stagingDirectoryURL = locations.stagingDirectoryURL(
            for: id,
            token: stagingNameToken
        )
        let stagingDatabaseURL = stagingDirectoryURL.appendingPathComponent(
            "Runtime.sqlite",
            isDirectory: false
        )
        var finalDirectoryMoved = false
        var activationCommitted = false
        var attemptedManifestDigest: String?
        var priorActiveManifestDigest: String?

        do {
            try fileManager.createDirectory(
                at: stagingDirectoryURL,
                withIntermediateDirectories: false
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: stagingDirectoryURL,
                artifact: "staging_generation_directory"
            )

            let activationMilliseconds = try Self.millisecondsSince1970(
                activatedAt
            )
            let databaseIdentitySHA256: String

            do {
                try createExclusiveDatabaseFile(at: stagingDatabaseURL)
                let database = try SQLiteDatabase(
                    url: stagingDatabaseURL,
                    configuration: CanonicalRuntimeStore.sqliteConfiguration(
                        openMode: .existingOnly
                    )
                )
                try await CanonicalRuntimeStore.installSchema(
                    in: database,
                    generationID: id,
                    createdAtMilliseconds: activationMilliseconds
                )
                let checkpoint = try await database.checkpoint(.truncate)
                guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                let integrity = try await database.integrityCheck()
                guard integrity.isOK else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                guard (try await database.foreignKeyCheck()).isEmpty else {
                    throw LocalRuntimeStorageError.canonicalForeignKeyFailure
                }
                databaseIdentitySHA256 = try await CanonicalRuntimeStore
                    .databaseIdentitySHA256(in: database)

                try protectAndSynchronizeSQLiteArtifacts(
                    databaseURL: stagingDatabaseURL,
                    generationDirectoryURL: stagingDirectoryURL
                )
            }
            try protectAndSynchronizeSQLiteArtifacts(
                databaseURL: stagingDatabaseURL,
                generationDirectoryURL: stagingDirectoryURL
            )

            let digest = RuntimeStoreManifestCodec.generationDigest(
                formatVersion: canonicalRuntimeStoreManifestFormatVersion,
                generationID: id,
                relativeDatabasePath: locations.relativeDatabasePath(for: id),
                schemaVersion: canonicalRuntimeStoreSchemaVersion,
                activatedAtMilliseconds: activationMilliseconds,
                databaseIdentitySHA256: databaseIdentitySHA256,
                priorGenerationID: priorManifest?.generationID,
                priorGenerationDigestSHA256: priorManifest?.generationDigestSHA256
            )

            let manifest = ActiveRuntimeStoreManifest(
                formatVersion: canonicalRuntimeStoreManifestFormatVersion,
                generationID: id,
                relativeDatabasePath: locations.relativeDatabasePath(for: id),
                schemaVersion: canonicalRuntimeStoreSchemaVersion,
                activatedAt: Date(timeIntervalSince1970: Double(activationMilliseconds) / 1_000),
                databaseIdentitySHA256: databaseIdentitySHA256,
                generationDigestSHA256: digest,
                priorGenerationID: priorManifest?.generationID,
                priorGenerationDigestSHA256: priorManifest?.generationDigestSHA256
            )
            let manifestData = try RuntimeStoreManifestCodec.encode(manifest)
            let generationManifestURL = stagingDirectoryURL.appendingPathComponent(
                "Generation.json",
                isDirectory: false
            )
            try manifestData.write(
                to: generationManifestURL,
                options: [.atomic, .withoutOverwriting]
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: generationManifestURL,
                artifact: "generation_manifest"
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: generationManifestURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(at: stagingDirectoryURL)
            let expectedPriorManifestDigest = try activeManifestFileDigestIfPresent()
            let expectedNewManifestDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: manifestData
            )
            priorActiveManifestDigest = expectedPriorManifestDigest
            attemptedManifestDigest = expectedNewManifestDigest
            try fileManager.moveItem(
                at: stagingDirectoryURL,
                to: finalDirectoryURL
            )
            finalDirectoryMoved = true
            try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.storesURL)
            let manifestTemporaryNameToken = environment.uuid
                .nextUUID().uuidString.lowercased()
            let manifestRollbackNameToken = environment.uuid
                .nextUUID().uuidString.lowercased()
            let activationState = manifestActivator.replaceActiveManifest(
                with: manifestData,
                at: locations.activeManifestURL,
                expectedPriorDigest: expectedPriorManifestDigest,
                expectedNewDigest: expectedNewManifestDigest,
                temporaryNameToken: manifestTemporaryNameToken,
                rollbackNameToken: manifestRollbackNameToken
            )
            switch activationState {
            case .committed:
                activationCommitted = true
                return .activated(manifest)
            case .committedWithCleanupWarning:
                activationCommitted = true
                return .activatedWithCleanupWarning(manifest)
            case let .unchanged(error):
                try removeDefinitelyInactiveGeneration(
                    finalDirectoryURL,
                    token: manifestRollbackNameToken
                )
                throw error
            case .unknown:
                throw LocalRuntimeStorageError.canonicalActivationStateUnknown
            }
        } catch {
            if fileManager.fileExists(atPath: stagingDirectoryURL.path) {
                do {
                    try fileManager.removeItem(at: stagingDirectoryURL)
                } catch {
                    throw LocalRuntimeStorageError.canonicalStagingCleanupFailed
                }
            }
            if finalDirectoryMoved, activationCommitted == false {
                let observedDigest = try? activeManifestFileDigestIfPresent()
                if observedDigest == attemptedManifestDigest {
                    throw LocalRuntimeStorageError.canonicalActivationStateUnknown
                }
                if observedDigest == nil || observedDigest == priorActiveManifestDigest {
                    try removeDefinitelyInactiveGeneration(
                        finalDirectoryURL,
                        token: stagingNameToken
                    )
                } else {
                    throw LocalRuntimeStorageError.canonicalActivationStateUnknown
                }
            }
            throw Self.mapFailure(error, operation: "create_generation")
        }
    }

    func resolveActiveGeneration() async throws -> ResolvedRuntimeStoreGeneration {
        try rootAuthority.revalidatePinnedRoot()
        try await requireProtectedData()
        guard fileManager.fileExists(atPath: locations.activeManifestURL.path) else {
            throw LocalRuntimeStorageError.canonicalManifestMissing
        }
        for (url, artifact) in [
            (locations.rootURL, "canonical_root"),
            (locations.storesURL, "canonical_stores_root"),
        ] {
            try RuntimeStoreFileDurability.requireDirectory(
                at: url,
                artifact: artifact
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: url,
                artifact: artifact
            )
        }
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: locations.activeManifestURL,
            artifact: "active_manifest"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: locations.activeManifestURL,
            artifact: "active_manifest"
        )
        let manifestData = try readBoundedManifestData()
        let manifest = try RuntimeStoreManifestCodec.decode(manifestData)
        try validate(manifest)

        let immutableManifestURL = locations.generationManifestURL(
            for: manifest.generationID
        )
        guard let immutableManifestData = try RuntimeStoreManifestDescriptorReader
            .readIfPresent(at: immutableManifestURL),
              immutableManifestData == manifestData,
              try RuntimeStoreManifestCodec.decode(immutableManifestData) == manifest
        else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: immutableManifestURL,
            artifact: "generation_manifest"
        )
        try await verifyPredecessor(of: manifest)

        let generationDirectoryURL = locations.generationDirectoryURL(
            for: manifest.generationID
        )
        let databaseURL = locations.databaseURL(for: manifest.generationID)
        try RuntimeStorePathValidation.requireContained(
            generationDirectoryURL,
            in: locations.storesURL
        )
        try RuntimeStorePathValidation.requireContained(
            databaseURL,
            in: generationDirectoryURL
        )
        guard fileManager.fileExists(atPath: generationDirectoryURL.path),
              fileManager.fileExists(atPath: databaseURL.path)
        else {
            throw LocalRuntimeStorageError.canonicalGenerationMissing(
                id: manifest.generationID.pathComponent
            )
        }
        try RuntimeStoreFileDurability.requireDirectory(
            at: generationDirectoryURL,
            artifact: "active_generation_directory"
        )
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: databaseURL,
            artifact: "active_database"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: generationDirectoryURL,
            artifact: "active_generation_directory"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: databaseURL,
            artifact: "active_database"
        )

        let databaseSchemaVersion = try RuntimeStoreSQLiteHeader.schemaVersion(
            at: databaseURL
        )
        guard databaseSchemaVersion <= canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                maximumSupported: canonicalRuntimeStoreSchemaVersion,
                actual: databaseSchemaVersion
            )
        }
        guard databaseSchemaVersion == canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalUnsupportedDatabaseSchema(
                expected: canonicalRuntimeStoreSchemaVersion,
                actual: databaseSchemaVersion
            )
        }

        let preOpenFiles = try RuntimeStorePinnedFileSet.capture(
            databaseURL: databaseURL
        )
        let observedDatabaseIdentitySHA256: String
        let openedDatabase: SQLiteDatabase
        let pinnedFiles: RuntimeStorePinnedFileSet
        do {
            openedDatabase = try SQLiteDatabase(
                url: databaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(
                    openMode: .existingOnly
                )
            )
            let effectiveUserVersion = try await CanonicalRuntimeStore
                .effectiveUserVersion(in: openedDatabase)
            guard effectiveUserVersion <= canonicalRuntimeStoreSchemaVersion else {
                throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                    maximumSupported: canonicalRuntimeStoreSchemaVersion,
                    actual: effectiveUserVersion
                )
            }
            guard effectiveUserVersion == canonicalRuntimeStoreSchemaVersion,
                  effectiveUserVersion == manifest.schemaVersion
            else {
                throw LocalRuntimeStorageError.canonicalUnsupportedDatabaseSchema(
                    expected: canonicalRuntimeStoreSchemaVersion,
                    actual: effectiveUserVersion
                )
            }
            observedDatabaseIdentitySHA256 = try await CanonicalRuntimeStore
                .databaseIdentitySHA256(in: openedDatabase)
            try protectAndSynchronizeSQLiteArtifacts(
                databaseURL: databaseURL,
                generationDirectoryURL: generationDirectoryURL
            )
            pinnedFiles = try RuntimeStorePinnedFileSet.capture(
                databaseURL: databaseURL
            )
            try pinnedFiles.requireCompatiblePreOpenIdentity(preOpenFiles)
        } catch {
            throw Self.mapFailure(
                error,
                operation: "verify_database_identity"
            )
        }
        guard observedDatabaseIdentitySHA256 == manifest.databaseIdentitySHA256 else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
        try rootAuthority.revalidatePinnedRoot()

        return ResolvedRuntimeStoreGeneration(
            manifest: manifest,
            generationDirectoryURL: generationDirectoryURL,
            databaseURL: databaseURL,
            pinnedFiles: pinnedFiles,
            // Retaining the exact connection used for manifest verification
            // pins SQLite's database inode and its WAL lifecycle across the
            // resolver-to-store handoff. The shipping store adopts this actor;
            // it never reopens an authority selected only by pathname.
            verifiedDatabase: openedDatabase
        )
    }
}

private extension RuntimeStoreGenerationManager {
    func createExclusiveDatabaseFile(at url: URL) throws {
        let descriptor = Darwin.open(
            url.path,
            O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC | O_NOFOLLOW,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "create_staging_database"
            )
        }
        let closeResult = Darwin.close(descriptor)
        guard closeResult == 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "close_staging_database"
            )
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: url,
            artifact: "staging_database"
        )
    }

    func recoverStaleUncommittedArtifacts() throws {
        let entries = try fileManager.contentsOfDirectory(
            at: locations.storesURL,
            includingPropertiesForKeys: nil,
            options: []
        )
        let hasActiveManifest = try activeManifestFileDigestIfPresent() != nil
        for entry in entries {
            let name = entry.lastPathComponent
            let isStaging = name.hasPrefix(".staging-")
            let isFirstInstallOrphan = hasActiveManifest == false &&
                UUID(uuidString: name)?.uuidString.lowercased() == name
            guard isStaging || isFirstInstallOrphan else { continue }
            let quarantineURL = locations.storesURL.appendingPathComponent(
                ".inactive-recovery-\(environment.uuid.nextUUID().uuidString.lowercased())",
                isDirectory: true
            )
            guard Darwin.rename(entry.path, quarantineURL.path) == 0 else {
                throw RuntimeStoreErrnoMapper.storageError(
                    operation: "quarantine_stale_generation"
                )
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.storesURL)
            if isStaging {
                try fileManager.removeItem(at: quarantineURL)
                try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.storesURL)
            }
        }
    }

    func activeManifestFileDigestIfPresent() throws -> String? {
        try RuntimeStoreManifestDescriptorReader
            .readIfPresent(at: locations.activeManifestURL)
            .map { LocalRuntimeStorageChecksum.sha256Hex(for: $0) }
    }

    func removeDefinitelyInactiveGeneration(
        _ finalDirectoryURL: URL,
        token: String
    ) throws {
        guard fileManager.fileExists(atPath: finalDirectoryURL.path) else {
            return
        }
        let inactiveURL = locations.storesURL.appendingPathComponent(
            ".inactive-\(token)",
            isDirectory: true
        )
        guard Darwin.rename(finalDirectoryURL.path, inactiveURL.path) == 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "quarantine_inactive_generation"
            )
        }
        try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.storesURL)
        do {
            try fileManager.removeItem(at: inactiveURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(
                at: locations.storesURL
            )
        } catch {
            throw Self.mapFailure(
                error,
                operation: "remove_inactive_generation"
            )
        }
    }

    func acquireActivationFileLock() throws {
        guard activationLockDescriptor == nil else {
            throw LocalRuntimeStorageError.canonicalActivationBusy
        }
        let lockURL = locations.rootURL.appendingPathComponent(
            ".activation.lock",
            isDirectory: false
        )
        let descriptor = Darwin.open(
            lockURL.path,
            O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "open_activation_lock",
                fallback: .canonicalActivationLockFailed
            )
        }
        guard Darwin.flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            let lockError = errno == EWOULDBLOCK
                ? LocalRuntimeStorageError.canonicalActivationBusy
                : RuntimeStoreErrnoMapper.storageError(
                    operation: "acquire_activation_lock",
                    fallback: .canonicalActivationLockFailed
                )
            _ = Darwin.close(descriptor)
            throw lockError
        }
        var status = stat()
        guard fstat(descriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFREG
        else {
            _ = Darwin.flock(descriptor, LOCK_UN)
            _ = Darwin.close(descriptor)
            throw LocalRuntimeStorageError.canonicalActivationLockFailed
        }
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: lockURL,
                artifact: "activation_lock"
            )
            var pathStatus = stat()
            guard lstat(lockURL.path, &pathStatus) == 0,
                  status.st_dev == pathStatus.st_dev,
                  status.st_ino == pathStatus.st_ino,
                  pathStatus.st_mode & S_IFMT == S_IFREG
            else {
                throw LocalRuntimeStorageError.canonicalActivationLockFailed
            }
        } catch {
            _ = Darwin.flock(descriptor, LOCK_UN)
            _ = Darwin.close(descriptor)
            throw error
        }
        activationLockDescriptor = descriptor
    }

    func releaseActivationFileLock() throws {
        guard let descriptor = activationLockDescriptor else { return }
        activationLockDescriptor = nil
        let unlockResult = Darwin.flock(descriptor, LOCK_UN)
        let closeResult = Darwin.close(descriptor)
        guard unlockResult == 0, closeResult == 0 else {
            throw LocalRuntimeStorageError.canonicalActivationLockFailed
        }
    }

    func requireProtectedData() async throws {
        guard await protectedDataChecker.isProtectedDataAvailable() else {
            throw LocalRuntimeStorageError.protectedDataUnavailable
        }
    }

    func prepareCanonicalRoot() throws {
        for (url, artifact) in [
            (locations.rootURL, "canonical_root"),
            (locations.storesURL, "canonical_stores_root"),
        ] {
            if fileManager.fileExists(atPath: url.path) {
                try RuntimeStoreFileDurability.requireDirectory(
                    at: url,
                    artifact: artifact
                )
            } else {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true
                )
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: url,
                artifact: artifact
            )
        }
        try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.rootURL)
    }

    func loadPriorManifestForActivation() async throws -> ActiveRuntimeStoreManifest? {
        guard fileManager.fileExists(atPath: locations.activeManifestURL.path) else {
            let contents = try fileManager.contentsOfDirectory(
                at: locations.storesURL,
                includingPropertiesForKeys: nil,
                options: []
            )
            let authoritativeContents = contents.filter {
                $0.lastPathComponent.hasPrefix(".inactive-") == false &&
                    $0.lastPathComponent.hasPrefix(".staging-") == false
            }
            guard authoritativeContents.isEmpty else {
                throw LocalRuntimeStorageError.canonicalManifestMissing
            }
            return nil
        }
        return (try await resolveActiveGeneration()).manifest
    }

    func readBoundedManifestData() throws -> Data {
        guard let data = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: locations.activeManifestURL
        ) else {
            throw LocalRuntimeStorageError.canonicalManifestMissing
        }
        return data
    }

    func validate(_ manifest: ActiveRuntimeStoreManifest) throws {
        try RuntimeStorePathValidation.requireSafeComponent(
            manifest.generationID.pathComponent
        )
        guard manifest.formatVersion <= canonicalRuntimeStoreManifestFormatVersion else {
            throw LocalRuntimeStorageError.canonicalFutureManifestSchema(
                maximumSupported: canonicalRuntimeStoreManifestFormatVersion,
                actual: manifest.formatVersion
            )
        }
        guard manifest.formatVersion == canonicalRuntimeStoreManifestFormatVersion else {
            throw LocalRuntimeStorageError.canonicalUnsupportedManifestSchema(
                expected: canonicalRuntimeStoreManifestFormatVersion,
                actual: manifest.formatVersion
            )
        }
        guard manifest.schemaVersion <= canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                maximumSupported: canonicalRuntimeStoreSchemaVersion,
                actual: manifest.schemaVersion
            )
        }
        guard manifest.schemaVersion == canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalUnsupportedDatabaseSchema(
                expected: canonicalRuntimeStoreSchemaVersion,
                actual: manifest.schemaVersion
            )
        }
        guard manifest.relativeDatabasePath == locations.relativeDatabasePath(
            for: manifest.generationID
        ) else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: "relative_database_path"
            )
        }
        guard (manifest.priorGenerationID == nil) == (manifest.priorGenerationDigestSHA256 == nil) else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        if let priorDigest = manifest.priorGenerationDigestSHA256 {
            guard RuntimeStoreManifestCodec.isSHA256Hex(priorDigest) else {
                throw LocalRuntimeStorageError.canonicalManifestMalformed
            }
        }
        if let priorGenerationID = manifest.priorGenerationID {
            try RuntimeStorePathValidation.requireSafeComponent(
                priorGenerationID.pathComponent
            )
            guard priorGenerationID != manifest.generationID else {
                throw LocalRuntimeStorageError.canonicalManifestMalformed
            }
        }
        guard RuntimeStoreManifestCodec.isSHA256Hex(
            manifest.databaseIdentitySHA256
        ) else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        let activatedAtMilliseconds = try Self.millisecondsSince1970(
            manifest.activatedAt
        )
        let expectedDigest = RuntimeStoreManifestCodec.generationDigest(
            formatVersion: manifest.formatVersion,
            generationID: manifest.generationID,
            relativeDatabasePath: manifest.relativeDatabasePath,
            schemaVersion: manifest.schemaVersion,
            activatedAtMilliseconds: activatedAtMilliseconds,
            databaseIdentitySHA256: manifest.databaseIdentitySHA256,
            priorGenerationID: manifest.priorGenerationID,
            priorGenerationDigestSHA256: manifest.priorGenerationDigestSHA256
        )
        guard manifest.generationDigestSHA256 == expectedDigest else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
    }


    func verifyPredecessor(of manifest: ActiveRuntimeStoreManifest) async throws {
        guard let priorID = manifest.priorGenerationID,
              let priorDigest = manifest.priorGenerationDigestSHA256
        else { return }
        let predecessorURL = locations.generationManifestURL(for: priorID)
        guard let data = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: predecessorURL
        ) else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
        let predecessor = try RuntimeStoreManifestCodec.decode(data)
        try validate(predecessor)
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: predecessorURL,
            artifact: "predecessor_generation_manifest"
        )
        let predecessorDatabaseURL = locations.databaseURL(for: priorID)
        guard predecessor.generationID == priorID,
              predecessor.generationDigestSHA256 == priorDigest
        else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: predecessorDatabaseURL,
            artifact: "predecessor_database"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: predecessorDatabaseURL,
            artifact: "predecessor_database"
        )
        let preOpenFiles = try RuntimeStorePinnedFileSet.capture(
            databaseURL: predecessorDatabaseURL
        )
        let database = try SQLiteDatabase(
            url: predecessorDatabaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(
                openMode: .existingOnly
            )
        )
        let identity = try await CanonicalRuntimeStore.databaseIdentitySHA256(
            in: database
        )
        let postOpenFiles = try RuntimeStorePinnedFileSet.capture(
            databaseURL: predecessorDatabaseURL
        )
        try postOpenFiles.requireCompatiblePreOpenIdentity(preOpenFiles)
        guard identity == predecessor.databaseIdentitySHA256 else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
    }

    func protectAndSynchronizeSQLiteArtifacts(
        databaseURL: URL,
        generationDirectoryURL: URL
    ) throws {
        for (url, artifact) in [
            (databaseURL, "database"),
            (URL(fileURLWithPath: databaseURL.path + "-wal"), "database_wal"),
            (URL(fileURLWithPath: databaseURL.path + "-shm"), "database_shm"),
        ] where fileManager.fileExists(atPath: url.path) {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: url,
                artifact: artifact
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: url)
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: generationDirectoryURL,
            artifact: "generation_directory"
        )
        try RuntimeStoreFileDurability.synchronizeDirectory(
            at: generationDirectoryURL
        )
    }

    static func millisecondsSince1970(_ date: Date) throws -> Int64 {
        let milliseconds = (date.timeIntervalSince1970 * 1_000).rounded()
        guard milliseconds.isFinite,
              milliseconds >= 0,
              milliseconds < Double(Int64.max)
        else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        return Int64(milliseconds)
    }

    static func mapFailure(
        _ error: Error,
        operation: String
    ) -> LocalRuntimeStorageError {
        RuntimeStoreFailureMapper.map(error, operation: operation)
    }
}

enum RuntimeStoreFailureMapper {
    static func map(
        _ error: Error,
        operation: String
    ) -> LocalRuntimeStorageError {
        if let error = error as? LocalRuntimeStorageError {
            return error
        }
        if let error = error as? SQLiteError {
            switch error.primaryCode {
            case 13:
                return .canonicalStorageFull(operation: operation)
            case 8, 10, 14:
                return .canonicalIOFailure(operation: operation)
            default:
                return .canonicalSQLiteFailure(
                    operation: operation,
                    code: error.primaryCode,
                    extendedCode: error.extendedCode
                )
            }
        }
        let cocoaError = error as NSError
        if cocoaError.domain == NSCocoaErrorDomain,
           cocoaError.code == NSFileWriteOutOfSpaceError {
            return .canonicalStorageFull(operation: operation)
        }
        if cocoaError.domain == NSPOSIXErrorDomain,
           (cocoaError.code == Int(ENOSPC) || cocoaError.code == Int(EDQUOT)) {
            return .canonicalStorageFull(operation: operation)
        }
        if operation == "activate_manifest" {
            return .canonicalActivationFailed
        }
        return .canonicalIOFailure(operation: operation)
    }
}

enum RuntimeStoreManifestCodec {
    static let maximumByteCount = 64 * 1_024

    private struct VersionEnvelope: Decodable {
        let formatVersion: Int
        let schemaVersion: Int

        enum CodingKeys: String, CodingKey {
            case formatVersion = "format_version"
            case schemaVersion = "schema_version"
        }
    }

    static func encode(_ manifest: ActiveRuntimeStoreManifest) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(manifest)
    }

    static func decode(_ data: Data) throws -> ActiveRuntimeStoreManifest {
        guard data.isEmpty == false, data.count <= maximumByteCount else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let versions: VersionEnvelope
        do {
            versions = try decoder.decode(VersionEnvelope.self, from: data)
        } catch {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        guard versions.formatVersion <= canonicalRuntimeStoreManifestFormatVersion else {
            throw LocalRuntimeStorageError.canonicalFutureManifestSchema(
                maximumSupported: canonicalRuntimeStoreManifestFormatVersion,
                actual: versions.formatVersion
            )
        }
        guard versions.schemaVersion <= canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                maximumSupported: canonicalRuntimeStoreSchemaVersion,
                actual: versions.schemaVersion
            )
        }

        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        guard let dictionary = object as? [String: Any] else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        let allowedKeys = Set(ActiveRuntimeStoreManifest.CodingKeys.allCases.map(\.rawValue))
        let requiredKeys: Set<String> = [
            ActiveRuntimeStoreManifest.CodingKeys.formatVersion.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.generationID.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.relativeDatabasePath.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.schemaVersion.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.activatedAt.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.databaseIdentitySHA256.rawValue,
            ActiveRuntimeStoreManifest.CodingKeys.generationDigestSHA256.rawValue,
        ]
        guard Set(dictionary.keys).isSubset(of: allowedKeys),
              requiredKeys.isSubset(of: Set(dictionary.keys))
        else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        do {
            return try decoder.decode(ActiveRuntimeStoreManifest.self, from: data)
        } catch {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
    }

    static func generationDigest(
        formatVersion: Int,
        generationID: RuntimeStoreGenerationID,
        relativeDatabasePath: String,
        schemaVersion: Int,
        activatedAtMilliseconds: Int64,
        databaseIdentitySHA256: String,
        priorGenerationID: RuntimeStoreGenerationID?,
        priorGenerationDigestSHA256: String?
    ) -> String {
        let identity = [
            "runtime-store-generation-v1",
            String(formatVersion),
            generationID.pathComponent,
            relativeDatabasePath,
            String(schemaVersion),
            String(activatedAtMilliseconds),
            databaseIdentitySHA256,
            priorGenerationID?.pathComponent ?? "",
            priorGenerationDigestSHA256 ?? "",
        ].joined(separator: "\n")
        return LocalRuntimeStorageChecksum.sha256Hex(for: identity)
    }

    static func isSHA256Hex(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy { byte in
            (48...57).contains(byte) || (97...102).contains(byte)
        }
    }
}

enum RuntimeStorePathValidation {
    static func requireSafeComponent(_ value: String) throws {
        guard let uuid = UUID(uuidString: value),
              uuid.uuidString.lowercased() == value
        else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
    }

    static func openPinnedAppPrivateRoot(
        _ url: URL,
        createFinalComponentIfMissing: Bool
    ) throws -> RuntimeStoreDirectoryPin {
        let standardizedURL = url.standardizedFileURL
        let components = standardizedURL.pathComponents
        guard components.contains(where: {
            $0 == "AppGroup" || $0.hasPrefix("group.")
        }) == false else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        guard components.first == "/" else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }

        var parentDescriptor = Darwin.open(
            "/",
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
        )
        guard parentDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }

        for (offset, component) in components.dropFirst().enumerated() {
            let isFinal = offset == components.count - 2
            var childDescriptor = Darwin.openat(
                parentDescriptor,
                component,
                O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
            )
            if childDescriptor < 0,
               errno == ENOENT,
               isFinal,
               createFinalComponentIfMissing {
                guard Darwin.mkdirat(
                    parentDescriptor,
                    component,
                    S_IRWXU
                ) == 0 || errno == EEXIST else {
                    _ = Darwin.close(parentDescriptor)
                    throw RuntimeStoreErrnoMapper.storageError(
                        operation: "create_application_support"
                    )
                }
                childDescriptor = Darwin.openat(
                    parentDescriptor,
                    component,
                    O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
                )
            }
            guard childDescriptor >= 0 else {
                _ = Darwin.close(parentDescriptor)
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            guard Darwin.close(parentDescriptor) == 0 else {
                _ = Darwin.close(childDescriptor)
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            parentDescriptor = childDescriptor
        }

        var status = stat()
        guard fstat(parentDescriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFDIR
        else {
            _ = Darwin.close(parentDescriptor)
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        return RuntimeStoreDirectoryPin(
            descriptor: parentDescriptor,
            identity: RuntimeStoreFileIdentity(
                device: UInt64(status.st_dev),
                inode: UInt64(status.st_ino)
            ),
            pathURL: standardizedURL
        )
    }

    static func requireContained(_ child: URL, in root: URL) throws {
        let rootComponents = root.standardizedFileURL.pathComponents
        let childComponents = child.standardizedFileURL.pathComponents
        guard childComponents.count > rootComponents.count,
              Array(childComponents.prefix(rootComponents.count)) == rootComponents
        else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }
}

struct RuntimeStoreFileIdentity: Sendable, Equatable {
    let device: UInt64
    let inode: UInt64
}

struct RuntimeStorePinnedFileSet: Sendable, Equatable {
    let database: RuntimeStoreFileIdentity
    let writeAheadLog: RuntimeStoreFileIdentity?
    let sharedMemory: RuntimeStoreFileIdentity?

    static func capture(databaseURL: URL) throws -> Self {
        guard let database = try RuntimeStoreFileInspector.identity(
            at: databaseURL,
            required: true,
            artifact: "database"
        ) else {
            throw LocalRuntimeStorageError.canonicalGenerationMissing(
                id: "database"
            )
        }
        return RuntimeStorePinnedFileSet(
            database: database,
            writeAheadLog: try RuntimeStoreFileInspector.identity(
                at: URL(fileURLWithPath: databaseURL.path + "-wal"),
                required: false,
                artifact: "database_wal"
            ),
            sharedMemory: try RuntimeStoreFileInspector.identity(
                at: URL(fileURLWithPath: databaseURL.path + "-shm"),
                required: false,
                artifact: "database_shm"
            )
        )
    }

    func validate(databaseURL: URL) throws {
        let current = try Self.capture(databaseURL: databaseURL)
        guard current == self else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "sqlite_artifacts"
            )
        }
    }

    func requireCompatiblePreOpenIdentity(
        _ preOpen: RuntimeStorePinnedFileSet
    ) throws {
        guard database == preOpen.database,
              (preOpen.writeAheadLog == nil ||
                  preOpen.writeAheadLog == writeAheadLog),
              (preOpen.sharedMemory == nil ||
                  preOpen.sharedMemory == sharedMemory)
        else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "sqlite_open"
            )
        }
    }
}

enum RuntimeStoreFileInspector {
    static func identity(
        at url: URL,
        required: Bool,
        artifact: String
    ) throws -> RuntimeStoreFileIdentity? {
        var status = stat()
        guard lstat(url.path, &status) == 0 else {
            if errno == ENOENT, required == false {
                return nil
            }
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "inspect_\(artifact)",
                fallback: .canonicalGenerationMissing(id: artifact)
            )
        }
        guard status.st_mode & S_IFMT == S_IFREG,
              status.st_mode & S_IFMT != S_IFLNK
        else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: artifact
            )
        }
        return RuntimeStoreFileIdentity(
            device: UInt64(status.st_dev),
            inode: UInt64(status.st_ino)
        )
    }
}

enum RuntimeStoreErrnoMapper {
    static func storageError(
        operation: String,
        fallback: LocalRuntimeStorageError? = nil
    ) -> LocalRuntimeStorageError {
        if errno == ENOSPC || errno == EDQUOT {
            return .canonicalStorageFull(operation: operation)
        }
        return fallback ?? .canonicalIOFailure(operation: operation)
    }
}

enum RuntimeStoreSQLiteHeader {
    static func schemaVersion(at databaseURL: URL) throws -> Int {
        let descriptor = Darwin.open(
            databaseURL.path,
            O_RDONLY | O_CLOEXEC | O_NOFOLLOW
        )
        guard descriptor >= 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "open_database_header"
            )
        }
        var status = stat()
        guard fstat(descriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFREG
        else {
            _ = Darwin.close(descriptor)
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        var bytes = [UInt8](repeating: 0, count: 100)
        let count = bytes.withUnsafeMutableBytes {
            Darwin.pread(descriptor, $0.baseAddress, $0.count, 0)
        }
        let readErrno = errno
        let closeResult = Darwin.close(descriptor)
        guard count >= 64, closeResult == 0 else {
            errno = readErrno
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "read_database_header"
            )
        }
        let header = Data(bytes.prefix(count))
        let signature = Data("SQLite format 3\0".utf8)
        guard header.count >= 64,
              header.prefix(signature.count) == signature
        else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let version = header[60..<64].reduce(UInt32.zero) { partial, byte in
            (partial << 8) | UInt32(byte)
        }
        return Int(version)
    }
}

enum RuntimeStoreManifestDescriptorReader {
    static func readIfPresent(at url: URL) throws -> Data? {
        let descriptor = Darwin.open(
            url.path,
            O_RDONLY | O_CLOEXEC | O_NOFOLLOW
        )
        guard descriptor >= 0 else {
            if errno == ENOENT { return nil }
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "open_manifest_no_follow",
                fallback: .canonicalManifestMalformed
            )
        }
        var initialStatus = stat()
        let maximumManifestBytes = off_t(RuntimeStoreManifestCodec.maximumByteCount)
        guard fstat(descriptor, &initialStatus) == 0,
              initialStatus.st_mode & S_IFMT == S_IFREG,
              initialStatus.st_size >= 0,
              initialStatus.st_size <= maximumManifestBytes
        else {
            _ = Darwin.close(descriptor)
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }

        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4_096)
        while true {
            let readCount = buffer.withUnsafeMutableBytes { bytes in
                Darwin.read(descriptor, bytes.baseAddress, bytes.count)
            }
            if readCount < 0, errno == EINTR { continue }
            guard readCount >= 0 else {
                _ = Darwin.close(descriptor)
                throw RuntimeStoreErrnoMapper.storageError(
                    operation: "read_manifest_descriptor",
                    fallback: .canonicalManifestMalformed
                )
            }
            if readCount == 0 { break }
            data.append(contentsOf: buffer.prefix(readCount))
            guard data.count <= RuntimeStoreManifestCodec.maximumByteCount else {
                _ = Darwin.close(descriptor)
                throw LocalRuntimeStorageError.canonicalManifestMalformed
            }
        }

        var finalStatus = stat()
        var pathStatus = stat()
        let finalStatusResult = fstat(descriptor, &finalStatus)
        let closeResult = Darwin.close(descriptor)
        guard finalStatusResult == 0,
              closeResult == 0,
              lstat(url.path, &pathStatus) == 0,
              initialStatus.st_dev == finalStatus.st_dev,
              initialStatus.st_ino == finalStatus.st_ino,
              initialStatus.st_dev == pathStatus.st_dev,
              initialStatus.st_ino == pathStatus.st_ino,
              pathStatus.st_mode & S_IFMT == S_IFREG,
              data.isEmpty == false
        else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "active_manifest"
            )
        }
        return data
    }
}

enum RuntimeStoreFileDurability {
    static func applyCompleteProtection(
        at url: URL,
        artifact: String
    ) throws {
        do {
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
            try requireCompleteProtection(at: url, artifact: artifact)
        } catch let error as LocalRuntimeStorageError {
            throw error
        } catch {
            let mapped = RuntimeStoreFailureMapper.map(
                error,
                operation: "protect_\(artifact)"
            )
            if case .canonicalStorageFull = mapped {
                throw mapped
            }
            throw LocalRuntimeStorageError.canonicalFileProtectionFailure(
                artifact: artifact
            )
        }
    }

    static func requireCompleteProtection(
        at url: URL,
        artifact: String
    ) throws {
        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try FileManager.default.attributesOfItem(
                atPath: url.path
            )
        } catch {
            throw RuntimeStoreFailureMapper.map(
                error,
                operation: "inspect_protection_\(artifact)"
            )
        }
        let protection = attributes[.protectionKey] as? FileProtectionType
        guard protection == .complete else {
            throw LocalRuntimeStorageError.canonicalFileProtectionFailure(
                artifact: artifact
            )
        }
    }

    static func requireDirectory(at url: URL, artifact: String) throws {
        let values: URLResourceValues
        do {
            values = try url.resourceValues(
                forKeys: [.isDirectoryKey, .isSymbolicLinkKey]
            )
        } catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_\(artifact)"
            )
        }
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: artifact
            )
        }
    }

    static func requireRegularNonSymbolicFile(
        at url: URL,
        artifact: String
    ) throws {
        let values: URLResourceValues
        do {
            values = try url.resourceValues(
                forKeys: [.isRegularFileKey, .isSymbolicLinkKey]
            )
        } catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_\(artifact)"
            )
        }
        guard values.isRegularFile == true, values.isSymbolicLink != true else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: artifact
            )
        }
    }

    static func synchronizeFile(at url: URL) throws {
        let descriptor = Darwin.open(
            url.path,
            O_RDONLY | O_CLOEXEC | O_NOFOLLOW
        )
        guard descriptor >= 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "open_file_for_synchronization"
            )
        }
        var status = stat()
        let statusResult = fstat(descriptor, &status)
        let syncResult = statusResult == 0 ? Darwin.fsync(descriptor) : -1
        let savedErrno = errno
        let closeResult = Darwin.close(descriptor)
        guard statusResult == 0,
              status.st_mode & S_IFMT == S_IFREG,
              syncResult == 0,
              closeResult == 0
        else {
            errno = savedErrno
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "synchronize_file"
            )
        }
    }

    static func synchronizeDirectory(at url: URL) throws {
        let descriptor = Darwin.open(url.path, O_RDONLY)
        guard descriptor >= 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "open_directory_for_synchronization"
            )
        }
        let synchronizationResult = Darwin.fsync(descriptor)
        let synchronizationErrno = errno
        let closeResult = Darwin.close(descriptor)
        if synchronizationResult != 0 {
            errno = synchronizationErrno
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "synchronize_directory"
            )
        }
        guard closeResult == 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "close_synchronized_directory"
            )
        }
    }
}
