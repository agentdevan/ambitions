import AmbitionsRuntimeSQLite
import Darwin
import Foundation

/// Decoding-only shape of the shipped control-schema v1 consumption payload.
/// It is never accepted by the v2 store and exists solely to create a fully
/// authenticated staged upgrade.
private struct RuntimeGenerationBackupPreparationConsumptionV1: Codable {
    let preparationID: String
    let backupID: String
    let finalDirectoryDevice: UInt64
    let finalDirectoryInode: UInt64
    let consumedAtMilliseconds: Int64
    let consumptionDigest: String
}

/// A small, immutable file-system journal for the only two destructive names
/// in a versioned control-store activation. It intentionally carries local
/// device/inode observations as well as content digests: the observations are
/// not portable authority, but prevent a stale or replaced directory entry
/// from being promoted during crash recovery.
private struct RuntimeGenerationControlUpgradeArtifact: Codable, Equatable {
    let basename: String
    let identity: RuntimeStoreFileIdentity
    let byteCount: Int64
    let sha256: String
}

private struct RuntimeGenerationControlUpgradeJournal: Codable, Equatable {
    let token: String
    let sourceSchemaVersion: Int
    let source: RuntimeGenerationControlUpgradeArtifact
    let staging: RuntimeGenerationControlUpgradeArtifact
    let rollbackBasename: String
    let journalDigest: String
}

/// A stable, opaque-in-practice continuation for bounded recovery scans. The
/// control store owns ordering by its immutable preparation creation stamp and
/// identifier; callers may only resume after the returned boundary.
struct RuntimeGenerationPreparationPageCursor: Sendable, Equatable {
    let createdAtMilliseconds: Int64
    let preparationID: String
}

struct RuntimeGenerationPendingBackupPreparation: Sendable {
    let preparation: RuntimeGenerationBackupPreparationRecord
    let completion: RuntimeGenerationBackupPreparationCompletion?
}

struct RuntimeGenerationPendingBackupPreparationPage: Sendable {
    let entries: [RuntimeGenerationPendingBackupPreparation]
    let nextCursor: RuntimeGenerationPreparationPageCursor?
}

struct RuntimeGenerationPendingCandidatePreparation: Sendable {
    let preparation: RuntimeGenerationCandidatePreparationRecord
    let completion: RuntimeGenerationCandidatePreparationCompletion?
    /// A projection-rebuild commitment is a terminal authority fact even
    /// before a later activation disposition exists. Reconciliation must
    /// authenticate this exact record rather than treating its preparation as
    /// abandoned solely because it has no disposition row.
    let committedAuthority: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment?
}

struct RuntimeGenerationPendingCandidatePreparationPage: Sendable {
    let entries: [RuntimeGenerationPendingCandidatePreparation]
    let nextCursor: RuntimeGenerationPreparationPageCursor?
}

/// Complete, immutable input to the all-or-nothing projection-rebuild
/// admission boundary. It contains only control facts; candidate bytes are
/// created later by the executor under the admitted lease.
struct RuntimeGenerationProjectionRebuildAdmissionRequest: Sendable, Equatable {
    let plan: RuntimeGenerationRecoveryOperationPlan
    let claim: RuntimeGenerationRecoveryOperationExecutionClaim
    let quarantine: RuntimeGenerationQuarantineRecord
    let authorization: RuntimeGenerationRecoveryAuthorization
    let sourceSafetyBackup: RuntimeGenerationBackupRecord
    let reservation: RuntimeGenerationReservation
    let operationLease: RuntimeGenerationOperationLease
    let candidatePreparation: RuntimeGenerationCandidatePreparationRecord
    let migrationRun: RuntimeGenerationMigrationRun
    let admittedTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
    /// Optional only to preserve source compatibility for callers that have
    /// not yet been migrated. Admission rejects nil at runtime; no projection
    /// rebuild can enter the v10 authority path without this stage-one fact.
    let candidateAuthorityReservation: RuntimeGenerationProjectionRebuildCandidateReservation? = nil
}

struct RuntimeGenerationProjectionRebuildAdmissionRecords: Sendable, Equatable {
    let reservation: RuntimeGenerationReservation
    let operationLease: RuntimeGenerationOperationLease
    let candidatePreparation: RuntimeGenerationCandidatePreparationRecord
    let migrationRun: RuntimeGenerationMigrationRun
    let admittedTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
    let candidateAuthorityReservation: RuntimeGenerationProjectionRebuildCandidateReservation
}

/// Immutable derived-work evidence plus the live execution fence required to
/// certify a recovery-authorized projection rebuild. The control store owns
/// the admission decision; callers cannot split the terminal lifecycle fact
/// from the relational rebuild certificate.
struct RuntimeGenerationProjectionRebuildCertificationRequest: Sendable, Equatable {
    let rebuild: RuntimeGenerationRebuildRecord
    let currentOperationLease: RuntimeGenerationOperationLease
}

/// The no-selector-publication commitment boundary. The caller supplies exact
/// in-memory file bytes observed from the still-staged candidate; this store
/// authenticates them against the normal candidate record before making any
/// candidate metadata durable.
struct RuntimeGenerationProjectionRebuildCandidateCommitmentRequest: Sendable, Equatable {
    let commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    let currentOperationLease: RuntimeGenerationOperationLease
}

/// Durable, privacy-minimized control authority for immutable runtime-store
/// generations. This database never contains user objects or private text; it
/// contains only opaque identifiers, cryptographic digests, bounded counts,
/// lifecycle facts, and canonical encoded control records.
actor RuntimeGenerationControlStore {
    private enum Lifecycle {
        case open
        case closing
        case closeIndeterminate
        case closed
    }

    static let maximumControlReadBytes = 4 * 1_024 * 1_024

    private static func sqliteConfiguration(
        openMode: SQLiteOpenMode
    ) -> SQLiteConfiguration {
        SQLiteConfiguration(
            synchronousPolicy: .extra,
            openMode: openMode,
            journalMode: .delete,
            maximumValueBytes: CanonicalRuntimeStore.maximumSQLiteValueBytes
        )
    }

    let databaseURL: URL
    private let rootAuthority: any RuntimeStoreRootAuthorityProviding
    private let controlDirectoryPin: RuntimeStoreDirectoryPin
    private var controlLockDescriptor: Int32?
    private let database: SQLiteDatabase
    private let pinnedFiles: RuntimeStorePinnedFileSet
    private let environment: RuntimeEnvironment
    private var lifecycle: Lifecycle = .open

    private init(
        databaseURL: URL,
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        controlDirectoryPin: RuntimeStoreDirectoryPin,
        controlLockDescriptor: Int32,
        database: SQLiteDatabase,
        pinnedFiles: RuntimeStorePinnedFileSet,
        environment: RuntimeEnvironment
    ) {
        self.databaseURL = databaseURL
        self.rootAuthority = rootAuthority
        self.controlDirectoryPin = controlDirectoryPin
        self.controlLockDescriptor = controlLockDescriptor
        self.database = database
        self.pinnedFiles = pinnedFiles
        self.environment = environment
    }

    static func open(
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        environment: RuntimeEnvironment = .live,
        fileManager: FileManager = .default
    ) async throws -> RuntimeGenerationControlStore {
        try rootAuthority.revalidatePinnedRoot()
        let locations = RuntimeStoreLocations(
            applicationSupportURL: rootAuthority.applicationSupportURL
        )
        try RuntimeStorePathValidation.requireContained(
            locations.controlURL,
            in: locations.rootURL
        )
        if fileManager.fileExists(atPath: locations.controlURL.path) {
            try RuntimeStoreFileDurability.requireDirectory(
                at: locations.controlURL,
                artifact: "generation_control_directory"
            )
        } else {
            try fileManager.createDirectory(
                at: locations.controlURL,
                withIntermediateDirectories: true
            )
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: locations.controlURL,
            artifact: "generation_control_directory"
        )
        let controlDirectoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.controlURL,
            createFinalComponentIfMissing: false
        )
        try controlDirectoryPin.revalidate()
        let lockURL = locations.controlURL.appendingPathComponent(
            ".control.lock",
            isDirectory: false
        )
        let createdLockDescriptor = Darwin.open(
            lockURL.path,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        if createdLockDescriptor >= 0 {
            guard Darwin.close(createdLockDescriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: lockURL,
                artifact: "generation_control_lock"
            )
            try RuntimeStoreFileDurability.synchronizeDirectory(at: locations.controlURL)
        } else if errno != EEXIST {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let controlLockDescriptor = Darwin.open(
            lockURL.path,
            O_RDWR | O_NOFOLLOW | O_CLOEXEC
        )
        guard controlLockDescriptor >= 0,
              Darwin.flock(controlLockDescriptor, LOCK_EX | LOCK_NB) == 0 else {
            if controlLockDescriptor >= 0 { _ = Darwin.close(controlLockDescriptor) }
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var lockStatus = stat()
        guard fstat(controlLockDescriptor, &lockStatus) == 0,
              lockStatus.st_mode & S_IFMT == S_IFREG,
              lockStatus.st_nlink == 1 else {
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let databaseURL = locations.controlDatabaseURL
        do {
            try await ensurePublishedControlDatabase(
                finalURL: databaseURL,
                controlDirectoryURL: locations.controlURL,
                environment: environment,
                fileManager: fileManager
            )
        } catch {
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw error
        }
        try await preflightExactExistingControlDatabase(at: databaseURL)
        let preOpenFiles = try RuntimeStorePinnedFileSet.capture(
            databaseURL: databaseURL
        )
        let database: SQLiteDatabase
        do {
            database = try SQLiteDatabase(
                url: databaseURL,
                configuration: Self.sqliteConfiguration(
                    openMode: .existingOnly
                )
            )
        } catch {
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw error
        }
        do {
            try await requireExactSchema(in: database)
        } catch {
            let precedingError = error
            do { try await database.close() }
            catch {
                _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
                _ = Darwin.close(controlLockDescriptor)
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw precedingError
        }
        let pinnedFiles: RuntimeStorePinnedFileSet
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: databaseURL,
                artifact: "generation_control_database"
            )
            for suffix in ["-wal", "-shm"] {
                let url = URL(fileURLWithPath: databaseURL.path + suffix)
                if fileManager.fileExists(atPath: url.path) {
                    try RuntimeStoreFileDurability.applyCompleteProtection(
                        at: url,
                        artifact: "generation_control_sqlite_sidecar"
                    )
                }
            }
            pinnedFiles = try RuntimeStorePinnedFileSet.capture(
                databaseURL: databaseURL
            )
            try pinnedFiles.requireCompatiblePreOpenIdentity(preOpenFiles)
            try controlDirectoryPin.revalidate()
            try rootAuthority.revalidatePinnedRoot()
        } catch {
            do { try await database.close() }
            catch {
                _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
                _ = Darwin.close(controlLockDescriptor)
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw error
        }
        guard Darwin.flock(controlLockDescriptor, LOCK_SH | LOCK_NB) == 0 else {
            do { try await database.close() }
            catch {
                _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
                _ = Darwin.close(controlLockDescriptor)
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
            _ = Darwin.close(controlLockDescriptor)
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        return RuntimeGenerationControlStore(
            databaseURL: databaseURL,
            rootAuthority: rootAuthority,
            controlDirectoryPin: controlDirectoryPin,
            controlLockDescriptor: controlLockDescriptor,
            database: database,
            pinnedFiles: pinnedFiles,
            environment: environment
        )
    }

    deinit {
        guard case .open = lifecycle, let controlLockDescriptor else { return }
        _ = Darwin.flock(controlLockDescriptor, LOCK_UN)
        _ = Darwin.close(controlLockDescriptor)
    }

    /// Idempotent explicit retirement. New authority work is rejected as soon
    /// as closing begins; a failed descriptor close is terminal and is never
    /// retried using an indeterminate numeric descriptor.
    func close() async throws {
        switch lifecycle {
        case .closed:
            return
        case .open:
            lifecycle = .closing
        case .closing, .closeIndeterminate:
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }

        do {
            try await database.close()
        } catch {
            lifecycle = .closeIndeterminate
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }

        if let descriptor = controlLockDescriptor {
            controlLockDescriptor = nil
            let unlocked = Darwin.flock(descriptor, LOCK_UN) == 0
            let closed = Darwin.close(descriptor) == 0
            guard unlocked && closed else {
                lifecycle = .closeIndeterminate
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
        }
        lifecycle = .closed
    }

    private static func ensurePublishedControlDatabase(
        finalURL: URL,
        controlDirectoryURL: URL,
        environment: RuntimeEnvironment,
        fileManager: FileManager
    ) async throws {
        var identifierSource = environment.uuid
        if fileManager.fileExists(atPath: finalURL.path) {
            var finalStatus = stat()
            guard lstat(finalURL.path, &finalStatus) == 0,
                  finalStatus.st_mode & S_IFMT == S_IFREG else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            if finalStatus.st_nlink == 2 {
                let linkedCandidates = try fileManager.contentsOfDirectory(
                    at: controlDirectoryURL,
                    includingPropertiesForKeys: nil,
                    options: []
                ).filter { candidate in
                    guard candidate.lastPathComponent.hasPrefix(
                        ".RuntimeGenerationControl.installing"
                    ) else { return false }
                    var candidateStatus = stat()
                    return lstat(candidate.path, &candidateStatus) == 0 &&
                        candidateStatus.st_mode & S_IFMT == S_IFREG &&
                        candidateStatus.st_dev == finalStatus.st_dev &&
                        candidateStatus.st_ino == finalStatus.st_ino
                }
                guard linkedCandidates.count == 1,
                      Darwin.unlink(linkedCandidates[0].path) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                try RuntimeStoreFileDurability.synchronizeDirectory(
                    at: controlDirectoryURL
                )
            } else if finalStatus.st_nlink != 1 {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
                at: finalURL,
                artifact: "generation_control_database"
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: finalURL,
                artifact: "generation_control_database"
            )
            try await upgradeLegacyV1ControlDatabaseIfNeeded(
                finalURL: finalURL,
                controlDirectoryURL: controlDirectoryURL,
                environment: environment,
                fileManager: fileManager
            )
            return
        }
        // Crash recovery promotes only a journal-bound pair. Filename counting
        // is not authority: old staging and rollback files can coexist after
        // interrupted attempts and must remain preserved rather than guessed.
        if try await recoverJournaledV1UpgradeIfPresent(
            finalURL: finalURL,
            controlDirectoryURL: controlDirectoryURL
        ) {
            return
        }
        let fixedStagingURL = controlDirectoryURL.appendingPathComponent(
            ".RuntimeGenerationControl.installing.sqlite",
            isDirectory: false
        )
        let strandedNames = try fileManager.contentsOfDirectory(
            atPath: controlDirectoryURL.path
        ).filter {
            $0.hasPrefix(".RuntimeGenerationControl.installing-") &&
                ($0.hasSuffix(".sqlite") || $0.hasSuffix(".sqlite-wal") ||
                    $0.hasSuffix(".sqlite-shm"))
        }
        let strandedBases = Set(strandedNames.map { name -> String in
            if name.hasSuffix("-wal") { return String(name.dropLast(4)) }
            if name.hasSuffix("-shm") { return String(name.dropLast(4)) }
            return name
        })
        for base in strandedBases.sorted() {
            try preserveStrandedControlInstall(
                databaseURL: controlDirectoryURL.appendingPathComponent(
                    base, isDirectory: false
                ),
                controlDirectoryURL: controlDirectoryURL,
                token: identifierSource.nextUUID().uuidString.lowercased(),
                fileManager: fileManager
            )
        }
        let fixedArtifactsExist = ["", "-wal", "-shm"].contains {
            fileManager.fileExists(atPath: fixedStagingURL.path + $0)
        }
        var reuseVerifiedStaging = false
        if fixedArtifactsExist,
           fileManager.fileExists(atPath: fixedStagingURL.path),
           fileManager.fileExists(atPath: fixedStagingURL.path + "-wal") == false,
           fileManager.fileExists(atPath: fixedStagingURL.path + "-shm") == false {
            do {
                try await preflightExactExistingControlDatabase(at: fixedStagingURL)
                reuseVerifiedStaging = true
            } catch {
                reuseVerifiedStaging = false
            }
        }
        if fixedArtifactsExist && reuseVerifiedStaging == false {
            try preserveStrandedControlInstall(
                databaseURL: fixedStagingURL,
                controlDirectoryURL: controlDirectoryURL,
                token: identifierSource.nextUUID().uuidString.lowercased(),
                fileManager: fileManager
            )
        }
        let stagingURL = reuseVerifiedStaging
            ? fixedStagingURL
            : controlDirectoryURL.appendingPathComponent(
                ".RuntimeGenerationControl.installing-\(identifierSource.nextUUID().uuidString.lowercased()).sqlite",
                isDirectory: false
            )
        if reuseVerifiedStaging == false {
            let descriptor = Darwin.open(
                stagingURL.path,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                S_IRUSR | S_IWUSR
            )
            guard descriptor >= 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            guard Darwin.close(descriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: stagingURL,
                artifact: "generation_control_staging_database"
            )
            let staging = try SQLiteDatabase(
                url: stagingURL,
                configuration: Self.sqliteConfiguration(
                    openMode: .existingOnly
                )
            )
            do {
                try await installSchema(in: staging)
                try await requireExactSchema(in: staging)
                _ = try await staging.checkpoint(.truncate)
            } catch {
                do { try await staging.close() }
                catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
                throw error
            }
            do { try await staging.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            guard fileManager.fileExists(atPath: stagingURL.path + "-wal") == false,
                  fileManager.fileExists(atPath: stagingURL.path + "-shm") == false else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: stagingURL,
                artifact: "generation_control_staging_database"
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: stagingURL)
            try RuntimeStoreFileDurability.synchronizeDirectory(at: controlDirectoryURL)
        }
        guard Darwin.link(stagingURL.path, finalURL.path) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        do {
            try RuntimeStoreFileDurability.synchronizeDirectory(at: controlDirectoryURL)
            guard Darwin.unlink(stagingURL.path) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.synchronizeDirectory(at: controlDirectoryURL)
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: finalURL,
                artifact: "generation_control_database"
            )
        } catch {
            // The hard-linked final is a byte-identical, exactly verified
            // publication. Ambiguous cleanup is preserved and reported.
            throw error
        }
    }

    private static func preserveStrandedControlInstall(
        databaseURL: URL,
        controlDirectoryURL: URL,
        token: String,
        fileManager: FileManager
    ) throws {
        try RuntimeStorePathValidation.requireSafeComponent(token)
        let evidenceDirectoryURL = controlDirectoryURL.appendingPathComponent(
            ".control-install-forensic-\(token)",
            isDirectory: true
        )
        try fileManager.createDirectory(
            at: evidenceDirectoryURL,
            withIntermediateDirectories: false
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: evidenceDirectoryURL,
            artifact: "control_install_forensic_directory"
        )
        let sources = [
            ("database", databaseURL),
            ("wal", URL(fileURLWithPath: databaseURL.path + "-wal")),
            ("shm", URL(fileURLWithPath: databaseURL.path + "-shm")),
        ]
        var references: [RuntimeGenerationForensicArtifactReference] = []
        for (logicalName, sourceURL) in sources {
            var status = stat()
            if lstat(sourceURL.path, &status) != 0 {
                guard errno == ENOENT else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                references.append(RuntimeGenerationForensicArtifactReference(
                    logicalName: logicalName,
                    sourceLocationDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: sourceURL.standardizedFileURL.path
                    ),
                    byteCount: 0,
                    fileIdentity: nil,
                    preservation: .absent,
                    copiedArtifact: nil,
                    failureFingerprint: nil
                ))
                continue
            }
            guard status.st_mode & S_IFMT == S_IFREG,
                  status.st_nlink == 1,
                  status.st_size >= 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            let destinationURL = evidenceDirectoryURL.appendingPathComponent(
                "Original-\(logicalName)",
                isDirectory: false
            )
            guard Darwin.rename(sourceURL.path, destinationURL.path) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: destinationURL,
                artifact: "control_install_forensic_\(logicalName)"
            )
            try RuntimeStoreFileDurability.synchronizeFile(at: destinationURL)
            let artifact = try RuntimeGenerationDatabaseAuthority.artifact(
                at: destinationURL,
                relativePath: "Control/\(evidenceDirectoryURL.lastPathComponent)/Original-\(logicalName)"
            )
            references.append(RuntimeGenerationForensicArtifactReference(
                logicalName: logicalName,
                sourceLocationDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: sourceURL.standardizedFileURL.path
                ),
                byteCount: artifact.byteCount,
                fileIdentity: artifact.fileIdentity,
                preservation: .copied,
                copiedArtifact: artifact.semantic,
                failureFingerprint: nil
            ))
        }
        let evidenceData = try RuntimeGenerationControlCodec.encode(references)
        try writeExclusiveControlEvidence(
            evidenceData,
            to: evidenceDirectoryURL.appendingPathComponent(
                "Evidence.json", isDirectory: false
            )
        )
        try RuntimeStoreFileDurability.synchronizeDirectory(at: evidenceDirectoryURL)
        try RuntimeStoreFileDurability.synchronizeDirectory(at: controlDirectoryURL)
    }

    private static func writeExclusiveControlEvidence(
        _ data: Data,
        to url: URL
    ) throws {
        let descriptor = Darwin.open(
            url.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var isOpen = true
        defer { if isOpen { _ = Darwin.close(descriptor) } }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: url,
            artifact: "control_install_forensic_evidence"
        )
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let written = Darwin.write(
                    descriptor,
                    bytes.baseAddress?.advanced(by: offset),
                    bytes.count - offset
                )
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0,
              Darwin.close(descriptor) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        isOpen = false
    }

    private static func preflightExactExistingControlDatabase(
        at databaseURL: URL
    ) async throws {
        let preflight = try SQLiteDatabase(
            url: databaseURL,
            configuration: Self.sqliteConfiguration(
                openMode: .readOnlyExisting
            )
        )
        do {
            try await requireExactSchema(in: preflight)
        } catch {
            let precedingError = error
            do { try await preflight.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw precedingError
        }
        do { try await preflight.close() }
        // AMBitionsAllowWeakPattern(reason: "Control database close failure is converted to authority unavailable")
        catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
    }

    /// Upgrades only the precisely recognized v1 control schema. The source
    /// file is opened read-only, copied by SQLite into a protected staging
    /// file, transformed there, then schema/integrity/FK checked before a
    /// same-directory rename activation. The prior file is retained as an
    /// immutable rollback artifact; unknown and future schemas fail closed.
    private static func upgradeLegacyV1ControlDatabaseIfNeeded(
        finalURL: URL,
        controlDirectoryURL: URL,
        environment: RuntimeEnvironment,
        fileManager: FileManager
    ) async throws {
        let source = try SQLiteDatabase(
            url: finalURL,
            configuration: Self.sqliteConfiguration(openMode: .readOnlyExisting)
        )
        let legacyVersion: Int?
        do {
            if try await isExactLegacyV1Schema(in: source) {
                legacyVersion = 1
            } else if try await isExactLegacyV2Schema(in: source) {
                legacyVersion = 2
            } else if try await isExactLegacyV3Schema(in: source) {
                legacyVersion = 3
            } else if try await isExactLegacyV4Schema(in: source) {
                legacyVersion = 4
            } else if try await isExactLegacyV5Schema(in: source) {
                legacyVersion = 5
            } else if try await isExactLegacyV6Schema(in: source) {
                legacyVersion = 6
            } else if try await isExactLegacyV7Schema(in: source) {
                legacyVersion = 7
            } else if try await isExactLegacyV8Schema(in: source) {
                legacyVersion = 8
            } else if try await isExactLegacyV9Schema(in: source) {
                legacyVersion = 9
            } else {
                legacyVersion = nil
                try await requireExactSchema(in: source)
            }
            try await source.close()
        } catch {
            do { try await source.close() } catch {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw error
        }
        guard let legacyVersion else { return }

        let token = environment.uuid.nextUUID().uuidString.lowercased()
        let stagingURL = controlDirectoryURL.appendingPathComponent(
            ".RuntimeGenerationControl.upgrading-\(token).sqlite", isDirectory: false
        )
        let rollbackURL = controlDirectoryURL.appendingPathComponent(
            ".RuntimeGenerationControl.rollback-v\(legacyVersion)-\(token).sqlite", isDirectory: false
        )
        let descriptor = Darwin.open(
            stagingURL.path, O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0, Darwin.close(descriptor) == 0 else {
            if descriptor >= 0 { _ = Darwin.close(descriptor) }
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: stagingURL, artifact: "generation_control_upgrade_staging"
        )
        let copySource = try SQLiteDatabase(
            url: finalURL,
            configuration: Self.sqliteConfiguration(openMode: .readOnlyExisting)
        )
        do {
            _ = try await copySource.backup(to: stagingURL)
            try await copySource.close()
        } catch {
            do {
                try await copySource.close()
            } catch {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw error
        }
        let staging = try SQLiteDatabase(
            url: stagingURL,
            configuration: Self.sqliteConfiguration(openMode: .existingOnly)
        )
        do {
            if legacyVersion == 1 {
                try await migrateExactLegacyV1Schema(in: staging)
            }
            if legacyVersion <= 2 {
                try await migrateExactLegacyV2Schema(in: staging)
            }
            if legacyVersion <= 3 {
                try await migrateExactLegacyV3Schema(in: staging)
            }
            if legacyVersion <= 4 {
                try await migrateExactLegacyV4Schema(in: staging)
            }
            if legacyVersion <= 5 {
                try await migrateExactLegacyV5Schema(in: staging)
            }
            if legacyVersion <= 6 { try await migrateExactLegacyV6Schema(in: staging) }
            if legacyVersion <= 7 { try await migrateExactLegacyV7Schema(in: staging) }
            if legacyVersion <= 8 { try await migrateExactLegacyV8Schema(in: staging) }
            if legacyVersion <= 9 { try await migrateExactLegacyV9Schema(in: staging) }
            try await requireExactSchema(in: staging)
            let integrity = try await staging.query("PRAGMA integrity_check")
            let foreignKeys = try await staging.query("PRAGMA foreign_key_check")
            guard integrity.count == 1, integrity[0].values.first == .text("ok"),
                  foreignKeys.isEmpty else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_upgrade", id: "verification")
            }
            _ = try await staging.checkpoint(.truncate)
            try await staging.close()
        } catch {
            do {
                try await staging.close()
            } catch {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw error
        }
        guard fileManager.fileExists(atPath: stagingURL.path + "-wal") == false,
              fileManager.fileExists(atPath: stagingURL.path + "-shm") == false else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try RuntimeStoreFileDurability.synchronizeFile(at: stagingURL)
        try RuntimeStoreFileDurability.synchronizeDirectory(at: controlDirectoryURL)
        let parent = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            controlDirectoryURL, createFinalComponentIfMissing: false
        )
        try parent.revalidate()
        let sourceArtifact = try descriptorRelativeControlArtifact(
            parent: parent, basename: finalURL.lastPathComponent
        )
        let stagedArtifact = try descriptorRelativeControlArtifact(
            parent: parent, basename: stagingURL.lastPathComponent
        )
        let journal = try makeUpgradeJournal(
            token: token,
            sourceSchemaVersion: legacyVersion,
            source: sourceArtifact,
            staging: stagedArtifact,
            rollbackBasename: rollbackURL.lastPathComponent
        )
        try writeUpgradeJournal(journal, parent: parent)
        try renameControlEntry(
            parent: parent,
            source: sourceArtifact,
            destinationBasename: rollbackURL.lastPathComponent
        )
        let rollbackArtifact = try descriptorRelativeControlArtifact(
            parent: parent, basename: rollbackURL.lastPathComponent
        )
        guard rollbackArtifact.identity == sourceArtifact.identity,
              rollbackArtifact.byteCount == sourceArtifact.byteCount,
              rollbackArtifact.sha256 == sourceArtifact.sha256 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try renameControlEntry(
            parent: parent,
            source: stagedArtifact,
            destinationBasename: finalURL.lastPathComponent
        )
        let publishedArtifact = try descriptorRelativeControlArtifact(
            parent: parent, basename: finalURL.lastPathComponent
        )
        guard publishedArtifact.identity == stagedArtifact.identity,
              publishedArtifact.byteCount == stagedArtifact.byteCount,
              publishedArtifact.sha256 == stagedArtifact.sha256 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: finalURL, artifact: "generation_control_database"
        )
    }

    private static let maximumUpgradeArtifactBytes: Int64 = 64 * 1_024 * 1_024

    private static func descriptorRelativeControlArtifact(
        parent: RuntimeStoreDirectoryPin,
        basename: String
    ) throws -> RuntimeGenerationControlUpgradeArtifact {
        guard basename.isEmpty == false,
              basename.contains("/") == false else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try parent.revalidate()
        let descriptor = Darwin.openat(
            parent.descriptor, basename, O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var isOpen = true
        defer { if isOpen { _ = Darwin.close(descriptor) } }
        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & S_IFMT == S_IFREG,
              before.st_nlink == 1,
              before.st_size >= 0,
              before.st_size <= maximumUpgradeArtifactBytes else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var pathStatus = stat()
        guard fstatat(parent.descriptor, basename, &pathStatus, AT_SYMLINK_NOFOLLOW) == 0,
              pathStatus.st_mode & S_IFMT == S_IFREG,
              RuntimeStoreFileIdentity(
                device: UInt64(pathStatus.st_dev), inode: UInt64(pathStatus.st_ino)
              ) == RuntimeStoreFileIdentity(
                device: UInt64(before.st_dev), inode: UInt64(before.st_ino)
              ) else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var bytes = Data()
        bytes.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
        while true {
            let count = Darwin.read(descriptor, &buffer, buffer.count)
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            if count == 0 { break }
            guard bytes.count <= Int(maximumUpgradeArtifactBytes) - count else {
                throw RuntimeGenerationControlError.readBudgetExceeded(
                    maximumBytes: Int(maximumUpgradeArtifactBytes)
                )
            }
            bytes.append(contentsOf: buffer[0..<count])
        }
        var after = stat()
        var afterPath = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              fstatat(parent.descriptor, basename, &afterPath, AT_SYMLINK_NOFOLLOW) == 0,
              RuntimeStoreFileIdentity(
                device: UInt64(afterPath.st_dev), inode: UInt64(afterPath.st_ino)
              ) == RuntimeStoreFileIdentity(
                device: UInt64(before.st_dev), inode: UInt64(before.st_ino)
              ),
              Darwin.close(descriptor) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        isOpen = false
        try parent.revalidate()
        return RuntimeGenerationControlUpgradeArtifact(
            basename: basename,
            identity: RuntimeStoreFileIdentity(
                device: UInt64(before.st_dev), inode: UInt64(before.st_ino)
            ),
            byteCount: Int64(bytes.count),
            sha256: LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        )
    }

    private static func descriptorRelativeControlEntryData(
        parent: RuntimeStoreDirectoryPin,
        basename: String,
        maximumBytes: Int
    ) throws -> Data {
        guard maximumBytes > 0, basename.isEmpty == false, basename.contains("/") == false else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try parent.revalidate()
        let descriptor = Darwin.openat(
            parent.descriptor, basename, O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var isOpen = true
        defer { if isOpen { _ = Darwin.close(descriptor) } }
        var before = stat()
        guard fstat(descriptor, &before) == 0,
              before.st_mode & S_IFMT == S_IFREG,
              before.st_size >= 0, before.st_size <= maximumBytes else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
        while true {
            let count = Darwin.read(descriptor, &buffer, buffer.count)
            if count < 0, errno == EINTR { continue }
            guard count >= 0 else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            if count == 0 { break }
            guard data.count <= maximumBytes - count else {
                throw RuntimeGenerationControlError.readBudgetExceeded(maximumBytes: maximumBytes)
            }
            data.append(contentsOf: buffer[0..<count])
        }
        var after = stat()
        var afterPath = stat()
        guard fstat(descriptor, &after) == 0,
              before.st_dev == after.st_dev, before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              fstatat(parent.descriptor, basename, &afterPath, AT_SYMLINK_NOFOLLOW) == 0,
              RuntimeStoreFileIdentity(
                device: UInt64(afterPath.st_dev), inode: UInt64(afterPath.st_ino)
              ) == RuntimeStoreFileIdentity(
                device: UInt64(before.st_dev), inode: UInt64(before.st_ino)
              ), Darwin.close(descriptor) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        isOpen = false
        try parent.revalidate()
        return data
    }

    private static func upgradeJournalDigest(
        _ journal: RuntimeGenerationControlUpgradeJournal
    ) throws -> String {
        let bytes = try RuntimeGenerationControlCodec.encode(journal)
        guard var object = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              object.removeValue(forKey: "journalDigest") != nil else {
            throw RuntimeGenerationControlError.malformed(field: "upgrade_journal")
        }
        let canonical = try JSONSerialization.data(
            withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]
        )
        return LocalRuntimeStorageChecksum.sha256Hex(for: canonical)
    }

    private static func makeUpgradeJournal(
        token: String,
        sourceSchemaVersion: Int,
        source: RuntimeGenerationControlUpgradeArtifact,
        staging: RuntimeGenerationControlUpgradeArtifact,
        rollbackBasename: String
    ) throws -> RuntimeGenerationControlUpgradeJournal {
        try RuntimeStorePathValidation.requireSafeComponent(token)
        guard (1...9).contains(sourceSchemaVersion),
              source.basename == "RuntimeGenerationControl.sqlite",
              staging.basename == ".RuntimeGenerationControl.upgrading-\(token).sqlite",
              rollbackBasename == ".RuntimeGenerationControl.rollback-v\(sourceSchemaVersion)-\(token).sqlite" else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let draft = RuntimeGenerationControlUpgradeJournal(
            token: token, sourceSchemaVersion: sourceSchemaVersion, source: source, staging: staging,
            rollbackBasename: rollbackBasename, journalDigest: ""
        )
        return RuntimeGenerationControlUpgradeJournal(
            token: draft.token, sourceSchemaVersion: draft.sourceSchemaVersion,
            source: draft.source, staging: draft.staging,
            rollbackBasename: draft.rollbackBasename,
            journalDigest: try upgradeJournalDigest(draft)
        )
    }

    private static func upgradeJournalBasename(token: String) -> String {
        ".RuntimeGenerationControl.upgrade-journal-\(token).json"
    }

    private static func writeUpgradeJournal(
        _ journal: RuntimeGenerationControlUpgradeJournal,
        parent: RuntimeStoreDirectoryPin
    ) throws {
        let basename = upgradeJournalBasename(token: journal.token)
        let bytes = try RuntimeGenerationControlCodec.encode(journal)
        try parent.revalidate()
        let descriptor = Darwin.openat(
            parent.descriptor, basename,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var isOpen = true
        defer { if isOpen { _ = Darwin.close(descriptor) } }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            toOpenFileDescriptor: descriptor, artifact: "generation_control_upgrade_journal"
        )
        try bytes.withUnsafeBytes { rawBuffer in
            var offset = 0
            while offset < bytes.count {
                let written = Darwin.write(
                    descriptor, rawBuffer.baseAddress?.advanced(by: offset), bytes.count - offset
                )
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                offset += written
            }
        }
        guard Darwin.fsync(descriptor) == 0, Darwin.close(descriptor) == 0,
              Darwin.fsync(parent.descriptor) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        isOpen = false
        try parent.revalidate()
    }

    private static func renameControlEntry(
        parent: RuntimeStoreDirectoryPin,
        source: RuntimeGenerationControlUpgradeArtifact,
        destinationBasename: String
    ) throws {
        try parent.revalidate()
        let observed = try descriptorRelativeControlArtifact(parent: parent, basename: source.basename)
        guard observed == source else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        guard Darwin.renameatx_np(
            parent.descriptor, source.basename, parent.descriptor, destinationBasename,
            UInt32(RENAME_EXCL)
        ) == 0, Darwin.fsync(parent.descriptor) == 0 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let moved = try descriptorRelativeControlArtifact(parent: parent, basename: destinationBasename)
        guard moved.identity == source.identity,
              moved.byteCount == source.byteCount,
              moved.sha256 == source.sha256 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
    }

    private static func recoverJournaledV1UpgradeIfPresent(
        finalURL: URL,
        controlDirectoryURL: URL
    ) async throws -> Bool {
        let journalURLs = try FileManager.default.contentsOfDirectory(
            at: controlDirectoryURL, includingPropertiesForKeys: nil, options: []
        ).filter { $0.lastPathComponent.hasPrefix(".RuntimeGenerationControl.upgrade-journal-") &&
            $0.pathExtension == "json" }
        if journalURLs.isEmpty {
            let residues = try FileManager.default.contentsOfDirectory(
                at: controlDirectoryURL, includingPropertiesForKeys: nil, options: []
            ).filter {
                $0.lastPathComponent.hasPrefix(".RuntimeGenerationControl.upgrading-") ||
                $0.lastPathComponent.hasPrefix(".RuntimeGenerationControl.rollback-v")
            }
            guard residues.isEmpty else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            return false
        }
        // Multiple journals are evidence of distinct interrupted operations;
        // none may be selected heuristically.
        guard journalURLs.count == 1 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let parent = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            controlDirectoryURL, createFinalComponentIfMissing: false
        )
        let journalArtifact = try descriptorRelativeControlArtifact(
            parent: parent, basename: journalURLs[0].lastPathComponent
        )
        guard journalArtifact.byteCount <= Int64(RuntimeGenerationControlCodec.maximumRecordBytes) else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let journalData = try descriptorRelativeControlEntryData(
            parent: parent,
            basename: journalURLs[0].lastPathComponent,
            maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
        )
        let journal = try RuntimeGenerationControlCodec.decode(
            RuntimeGenerationControlUpgradeJournal.self, from: journalData
        )
        guard journal.journalDigest == try upgradeJournalDigest(
            RuntimeGenerationControlUpgradeJournal(
                token: journal.token, sourceSchemaVersion: journal.sourceSchemaVersion,
                source: journal.source, staging: journal.staging,
                rollbackBasename: journal.rollbackBasename, journalDigest: ""
            )
        ), journalURLs[0].lastPathComponent == upgradeJournalBasename(token: journal.token),
           journal.source.basename == finalURL.lastPathComponent,
           (1...9).contains(journal.sourceSchemaVersion),
           journal.staging.basename == ".RuntimeGenerationControl.upgrading-\(journal.token).sqlite",
           journal.rollbackBasename == ".RuntimeGenerationControl.rollback-v\(journal.sourceSchemaVersion)-\(journal.token).sqlite" else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let staging = try descriptorRelativeControlArtifact(parent: parent, basename: journal.staging.basename)
        let rollback = try descriptorRelativeControlArtifact(parent: parent, basename: journal.rollbackBasename)
        guard staging == journal.staging,
              rollback.identity == journal.source.identity,
              rollback.byteCount == journal.source.byteCount,
              rollback.sha256 == journal.source.sha256 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try await preflightExactExistingControlDatabase(
            at: controlDirectoryURL.appendingPathComponent(journal.staging.basename)
        )
        guard try descriptorRelativeControlArtifact(
            parent: parent, basename: journal.staging.basename
        ) == journal.staging else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        let rollbackDatabase = try SQLiteDatabase(
            url: controlDirectoryURL.appendingPathComponent(journal.rollbackBasename),
            configuration: Self.sqliteConfiguration(openMode: .readOnlyExisting)
        )
        do {
            let rollbackMatchesJournal: Bool
            switch journal.sourceSchemaVersion {
            case 1:
                rollbackMatchesJournal = try await isExactLegacyV1Schema(in: rollbackDatabase)
            case 2:
                rollbackMatchesJournal = try await isExactLegacyV2Schema(in: rollbackDatabase)
            case 3:
                rollbackMatchesJournal = try await isExactLegacyV3Schema(in: rollbackDatabase)
            case 4:
                rollbackMatchesJournal = try await isExactLegacyV4Schema(in: rollbackDatabase)
            case 5:
                rollbackMatchesJournal = try await isExactLegacyV5Schema(in: rollbackDatabase)
            case 6:
                rollbackMatchesJournal = try await isExactLegacyV6Schema(in: rollbackDatabase)
            case 7:
                rollbackMatchesJournal = try await isExactLegacyV7Schema(in: rollbackDatabase)
            case 8:
                rollbackMatchesJournal = try await isExactLegacyV8Schema(in: rollbackDatabase)
            case 9:
                rollbackMatchesJournal = try await isExactLegacyV9Schema(in: rollbackDatabase)
            default:
                rollbackMatchesJournal = false
            }
            guard rollbackMatchesJournal else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try await rollbackDatabase.close()
        } catch {
            do {
                try await rollbackDatabase.close()
            } catch {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw error
        }
        let verifiedRollback = try descriptorRelativeControlArtifact(
            parent: parent, basename: journal.rollbackBasename
        )
        guard verifiedRollback.identity == journal.source.identity,
              verifiedRollback.byteCount == journal.source.byteCount,
              verifiedRollback.sha256 == journal.source.sha256 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try renameControlEntry(
            parent: parent, source: staging, destinationBasename: finalURL.lastPathComponent
        )
        return true
    }

    func recordGeneration(_ record: RuntimeGenerationCandidateRecord) async throws {
        try record.validate()
        let manifest = record.authorityManifest
        // Projection rebuilds have a stronger, all-or-nothing candidate
        // commitment path. The general generation writer would otherwise let
        // a staged candidate escape its recovery claim before completion and
        // rebuild evidence are jointly authenticated.
        if manifest.operationKind == .projectionRebuild {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_records"],
                reading: [
                    "runtime_generation_records",
                    "runtime_generation_reservations",
                    "runtime_generation_migration_runs",
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_replay_audits",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: manifest.reservationID,
                database: database
            )
            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: manifest.migrationRunID,
                database: database
            )
            let auditRows = try database.query(
                "SELECT * FROM runtime_generation_candidate_replay_audits WHERE candidate_generation_id = ? LIMIT 2",
                bindings: [.text(manifest.generationID.rawValue)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard auditRows.count == 1 else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            let audit = try Self.decodePayload(
                RuntimeGenerationCandidateReplayAuditRecord.self, row: auditRows[0]
            )
            let preparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id", id: audit.preparationID, database: database
            )
            let auditLease = try Self.loadPayload(
                RuntimeGenerationOperationLease.self,
                table: "runtime_generation_operation_leases",
                idColumn: "lease_id", id: audit.operationLeaseID, database: database
            )
            guard reservation.candidateGenerationID == manifest.generationID,
                  run.candidateGenerationID == manifest.generationID,
                  run.reservationID == reservation.reservationID,
                  run.operationKind == manifest.operationKind,
                  reservation.operationKind == manifest.operationKind,
                  reservation.sourceGenerationID == manifest.sourceGenerationID,
                  reservation.sourceGenerationDigest == manifest.sourceGenerationDigest,
                  audit.outcome == .complete,
                  audit.preparationID == preparation.preparationID,
                  audit.reservationID == reservation.reservationID,
                  audit.candidateGenerationID == manifest.generationID,
                  auditLease.reservationID == reservation.reservationID,
                  auditLease.leaseEpoch == audit.operationLeaseEpoch,
                  auditLease.fencingToken == audit.operationFencingToken,
                  audit.reconstructionDigest != nil,
                  manifest.createdAtMilliseconds >= run.completedAtMilliseconds
            else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: manifest.generationID.rawValue,
                columns: [
                    ("schema_version", .integer(Int64(manifest.schemaVersion))),
                    ("manifest_digest", .text(manifest.manifestDigest)),
                    ("authority_manifest_file_sha256", .text(record.authorityManifestFileSHA256)),
                    ("selector_file_sha256", .text(record.selectorFileSHA256)),
                    ("record_digest", .text(record.recordDigest)),
                    ("reservation_id", .text(manifest.reservationID)),
                    ("migration_run_id", .text(manifest.migrationRunID)),
                    ("source_generation_id", manifest.sourceGenerationID.map { .text($0.rawValue) } ?? .null),
                    ("retention_class", .text(manifest.retentionClass.rawValue)),
                    ("created_at_ms", .integer(manifest.createdAtMilliseconds)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func recordBackupPreparationCompletion(
        _ record: RuntimeGenerationBackupPreparationCompletion,
        currentLease: RuntimeGenerationOperationLease
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlRecordFactory.validate(currentLease)
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_backup_preparation_completions"],
                reading: [
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_completions",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let preparation = try Self.loadPayload(
                RuntimeGenerationBackupPreparationRecord.self,
                table: "runtime_generation_backup_preparations",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            )
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationBackupPreparationCompletion.self,
                table: "runtime_generation_backup_preparation_completions",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "backup_preparation_completion",
                        id: record.preparationID
                    )
                }
                return
            }
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(preparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latest = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestRow
            )
            guard latest == currentLease,
                  // Completion is a producer action, not a recovery action:
                  // bytes may only become durable-complete under the original
                  // admission fence. A successor can publish an already
                  // completed preparation, but cannot manufacture completion.
                  latest.fencingToken == preparation.operationFencingToken,
                  record.backup.backupID == preparation.backupID,
                  record.backup.sourceGenerationID == preparation.sourceGenerationID,
                  record.backup.sourceGenerationDigest == preparation.sourceGenerationDigest,
                  record.completedAtMilliseconds >= preparation.createdAtMilliseconds,
                  record.completedAtMilliseconds >= latest.issuedAtMilliseconds,
                  record.completedAtMilliseconds < latest.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_backup_preparation_completions",
                idColumn: "preparation_id",
                id: record.preparationID,
                columns: [
                    ("backup_id", .text(record.backup.backupID)),
                    ("backup_digest", .text(record.backup.backupDigest)),
                    ("directory_device", .integer(Int64(bitPattern: record.directoryDevice))),
                    ("directory_inode", .integer(Int64(bitPattern: record.directoryInode))),
                    ("interior_artifact_count", .integer(record.interiorArtifactCount)),
                    ("interior_byte_count", .integer(record.interiorByteCount)),
                    ("interior_inventory_digest", .text(record.interiorInventoryDigest)),
                    ("durability_witness_digest", .text(record.durabilityWitnessDigest)),
                    ("completed_at_ms", .integer(record.completedAtMilliseconds)),
                    ("completion_digest", .text(record.completionDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func consumeCompletedBackupPreparation(
        preparationID: String,
        currentLease: RuntimeGenerationOperationLease,
        finalDirectoryDevice: UInt64,
        finalDirectoryInode: UInt64,
        consumedAtMilliseconds: Int64
    ) async throws -> RuntimeGenerationBackupRecord {
        try revalidateAuthority()
        return try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [
                    "runtime_generation_backups",
                    "runtime_generation_backup_preparation_consumptions",
                ],
                reading: [
                    "runtime_generation_backups",
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_completions",
                    "runtime_generation_backup_preparation_consumptions",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let preparation = try Self.loadPayload(
                RuntimeGenerationBackupPreparationRecord.self,
                table: "runtime_generation_backup_preparations",
                idColumn: "preparation_id",
                id: preparationID,
                database: database
            )
            let completion = try Self.loadPayload(
                RuntimeGenerationBackupPreparationCompletion.self,
                table: "runtime_generation_backup_preparation_completions",
                idColumn: "preparation_id",
                id: preparationID,
                database: database
            )
            if let existingConsumption = try Self.loadOptionalPayload(
                RuntimeGenerationBackupPreparationConsumption.self,
                table: "runtime_generation_backup_preparation_consumptions",
                idColumn: "preparation_id",
                id: preparationID,
                database: database
            ) {
                let expected = try RuntimeGenerationControlRecordFactory
                    .backupPreparationConsumption(
                        preparationID: preparationID,
                        backupID: completion.backup.backupID,
                        operationLease: currentLease,
                        finalDirectoryDevice: finalDirectoryDevice,
                        finalDirectoryInode: finalDirectoryInode,
                        consumedAtMilliseconds: consumedAtMilliseconds
                    )
                guard existingConsumption == expected else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "backup_preparation_consumption",
                        id: preparationID
                    )
                }
                let existingBackup = try Self.loadEligibleBackup(
                    id: completion.backup.backupID,
                    database: database
                )
                guard existingBackup == completion.backup else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "eligible_backup",
                        id: completion.backup.backupID
                    )
                }
                return existingBackup
            }
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(preparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latestLease = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestRow
            )
            let backup = completion.backup
            guard backup.backupID == preparation.backupID,
                  latestLease == currentLease,
                  // Consumption may be performed by a fenced successor after
                  // the original owner crashed between durable completion and
                  // hidden-to-final publication.
                  latestLease.fencingToken >= preparation.operationFencingToken,
                  consumedAtMilliseconds >= latestLease.issuedAtMilliseconds,
                  consumedAtMilliseconds < latestLease.expiresAtMilliseconds,
                  finalDirectoryDevice == completion.directoryDevice,
                  finalDirectoryInode == completion.directoryInode,
                  consumedAtMilliseconds >= completion.completedAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let backupPayload = try RuntimeGenerationControlCodec.encode(backup)
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_backups",
                idColumn: "backup_id",
                id: backup.backupID,
                columns: [
                    ("preparation_id", .text(preparationID)),
                    ("source_generation_id", .text(backup.sourceGenerationID.rawValue)),
                    ("source_generation_digest", .text(backup.sourceGenerationDigest)),
                    ("source_fence_digest", .text(backup.sourceFence.fenceDigest)),
                    ("authority_fence_token_digest", .text(backup.authorityFenceToken.tokenDigest)),
                    ("backup_digest", .text(backup.backupDigest)),
                    ("created_at_ms", .integer(backup.createdAtMilliseconds)),
                ],
                payload: backupPayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: backupPayload)
            )
            let consumption = try RuntimeGenerationControlRecordFactory
                .backupPreparationConsumption(
                    preparationID: preparationID,
                    backupID: backup.backupID,
                    operationLease: currentLease,
                    finalDirectoryDevice: finalDirectoryDevice,
                    finalDirectoryInode: finalDirectoryInode,
                    consumedAtMilliseconds: consumedAtMilliseconds
                )
            let consumptionPayload = try RuntimeGenerationControlCodec.encode(consumption)
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_backup_preparation_consumptions",
                idColumn: "preparation_id",
                id: preparationID,
                columns: [
                    ("backup_id", .text(backup.backupID)),
                    ("operation_lease_id", .text(consumption.operationLeaseID)),
                    ("operation_fencing_token", .integer(consumption.operationFencingToken)),
                    ("final_directory_device", .integer(Int64(bitPattern: finalDirectoryDevice))),
                    ("final_directory_inode", .integer(Int64(bitPattern: finalDirectoryInode))),
                    ("consumed_at_ms", .integer(consumedAtMilliseconds)),
                    ("consumption_digest", .text(consumption.consumptionDigest)),
                ],
                payload: consumptionPayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: consumptionPayload)
            )
            return backup
        }
    }

    func unconsumedBackupPreparationsPage(
        after cursor: RuntimeGenerationPreparationPageCursor?,
        limit: Int
    ) async throws -> RuntimeGenerationPendingBackupPreparationPage {
        guard limit > 0, limit < Int.max else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                """
                SELECT preparation.*
                FROM runtime_generation_backup_preparations AS preparation
                LEFT JOIN runtime_generation_backup_preparation_consumptions AS consumption
                  ON consumption.preparation_id = preparation.preparation_id
                LEFT JOIN runtime_generation_backup_preparation_recoveries AS recovery
                  ON recovery.preparation_id = preparation.preparation_id
                WHERE consumption.preparation_id IS NULL
                  AND recovery.preparation_id IS NULL
                  AND (
                    ? IS NULL OR preparation.created_at_ms > ? OR
                    (preparation.created_at_ms = ? AND preparation.preparation_id > ?)
                  )
                ORDER BY preparation.created_at_ms, preparation.preparation_id
                LIMIT ?
                """,
                bindings: [
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .text($0.preparationID) } ?? .null,
                    .integer(Int64(limit + 1)),
                ],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let pageRows = rows.prefix(limit)
            let entries = try pageRows.map { row in
                let preparation = try Self.decodePayload(
                    RuntimeGenerationBackupPreparationRecord.self, row: row
                )
                let completionRows = try database.query(
                    "SELECT * FROM runtime_generation_backup_preparation_completions WHERE preparation_id = ? LIMIT 2",
                    bindings: [.text(preparation.preparationID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard completionRows.count <= 1 else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "backup_preparation_completion",
                        id: preparation.preparationID
                    )
                }
                let completion = try completionRows.first.map {
                    try Self.decodePayload(
                        RuntimeGenerationBackupPreparationCompletion.self, row: $0
                    )
                }
                return RuntimeGenerationPendingBackupPreparation(
                    preparation: preparation,
                    completion: completion
                )
            }
            return RuntimeGenerationPendingBackupPreparationPage(
                entries: entries,
                nextCursor: rows.count > limit ? entries.last.map {
                    RuntimeGenerationPreparationPageCursor(
                        createdAtMilliseconds: $0.preparation.createdAtMilliseconds,
                        preparationID: $0.preparation.preparationID
                    )
                } : nil
            )
        }
    }

    func recordBackupPreparationRecovery(
        _ record: RuntimeGenerationBackupPreparationRecovery,
        currentLease: RuntimeGenerationOperationLease
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlRecordFactory.validate(currentLease)
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_backup_preparation_recoveries"],
                reading: [
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_recoveries",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let preparation = try Self.loadPayload(
                RuntimeGenerationBackupPreparationRecord.self,
                table: "runtime_generation_backup_preparations",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            )
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationBackupPreparationRecovery.self,
                table: "runtime_generation_backup_preparation_recoveries",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "backup_preparation_recovery",
                        id: record.preparationID
                    )
                }
                return
            }
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(preparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latest = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestRow
            )
            guard latest == currentLease,
                  record.operationLeaseID == latest.leaseID,
                  record.operationFencingToken == latest.fencingToken,
                  record.recoveredAtMilliseconds >= latest.issuedAtMilliseconds,
                  record.recoveredAtMilliseconds < latest.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_backup_preparation_recoveries",
                idColumn: "preparation_id",
                id: record.preparationID,
                columns: [
                    ("operation_lease_id", .text(record.operationLeaseID)),
                    ("operation_fencing_token", .integer(record.operationFencingToken)),
                    ("classification", .text(record.classification.rawValue)),
                    ("recovered_at_ms", .integer(record.recoveredAtMilliseconds)),
                    ("recovery_digest", .text(record.recoveryDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordCandidatePreparationCompletion(
        _ record: RuntimeGenerationCandidatePreparationCompletion,
        currentLease: RuntimeGenerationOperationLease
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlRecordFactory.validate(currentLease)
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_candidate_preparation_completions"],
                reading: [
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_preparation_completions",
                    "runtime_generation_records",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let preparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            )
            if preparation.operationKind == .projectionRebuild {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let candidate = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: preparation.candidateGenerationID.rawValue,
                database: database
            )
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationCandidatePreparationCompletion.self,
                table: "runtime_generation_candidate_preparation_completions",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "candidate_preparation_completion",
                        id: record.preparationID
                    )
                }
                return
            }
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(preparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latest = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestRow
            )
            guard latest == currentLease,
                  // A successor may preserve an orphaned candidate but cannot
                  // manufacture its durable-completion proof.
                  latest.fencingToken == preparation.operationFencingToken,
                  record.candidateRecordDigest == candidate.recordDigest,
                  record.completedAtMilliseconds >= latest.issuedAtMilliseconds,
                  record.completedAtMilliseconds < latest.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_candidate_preparation_completions",
                idColumn: "preparation_id",
                id: record.preparationID,
                columns: [
                    ("candidate_record_digest", .text(record.candidateRecordDigest)),
                    ("directory_device", .integer(Int64(bitPattern: record.directoryDevice))),
                    ("directory_inode", .integer(Int64(bitPattern: record.directoryInode))),
                    ("interior_artifact_count", .integer(record.interiorArtifactCount)),
                    ("interior_byte_count", .integer(record.interiorByteCount)),
                    ("interior_inventory_digest", .text(record.interiorInventoryDigest)),
                    ("durability_witness_digest", .text(record.durabilityWitnessDigest)),
                    ("completed_at_ms", .integer(record.completedAtMilliseconds)),
                    ("completion_digest", .text(record.completionDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordCandidatePreparationDisposition(
        _ record: RuntimeGenerationCandidatePreparationDisposition,
        currentLease: RuntimeGenerationOperationLease
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlRecordFactory.validate(currentLease)
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_candidate_preparation_dispositions"],
                reading: [
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_preparation_dispositions",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let preparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            )
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationCandidatePreparationDisposition.self,
                table: "runtime_generation_candidate_preparation_dispositions",
                idColumn: "preparation_id",
                id: record.preparationID,
                database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "candidate_preparation_disposition",
                        id: record.preparationID
                    )
                }
                return
            }
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(preparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latest = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestRow
            )
            guard latest == currentLease,
                  record.operationLeaseID == latest.leaseID,
                  record.operationFencingToken == latest.fencingToken,
                  record.disposedAtMilliseconds >= latest.issuedAtMilliseconds,
                  record.disposedAtMilliseconds < latest.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_candidate_preparation_dispositions",
                idColumn: "preparation_id",
                id: record.preparationID,
                columns: [
                    ("operation_lease_id", .text(record.operationLeaseID)),
                    ("operation_fencing_token", .integer(record.operationFencingToken)),
                    ("kind", .text(record.kind.rawValue)),
                    ("failure_classification", record.failureClassification.map { .text($0.rawValue) } ?? .null),
                    ("authority_digest", .text(record.authorityDigest)),
                    ("disposed_at_ms", .integer(record.disposedAtMilliseconds)),
                    ("disposition_digest", .text(record.dispositionDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func unresolvedCandidatePreparationsPage(
        after cursor: RuntimeGenerationPreparationPageCursor?,
        limit: Int
    ) async throws -> RuntimeGenerationPendingCandidatePreparationPage {
        guard limit > 0, limit < Int.max else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                """
                SELECT preparation.*
                FROM runtime_generation_candidate_preparations AS preparation
                LEFT JOIN runtime_generation_candidate_preparation_dispositions AS disposition
                  ON disposition.preparation_id = preparation.preparation_id
                WHERE disposition.preparation_id IS NULL
                  AND (
                    ? IS NULL OR preparation.created_at_ms > ? OR
                    (preparation.created_at_ms = ? AND preparation.preparation_id > ?)
                  )
                ORDER BY preparation.created_at_ms, preparation.preparation_id
                LIMIT ?
                """,
                bindings: [
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .integer($0.createdAtMilliseconds) } ?? .null,
                    cursor.map { .text($0.preparationID) } ?? .null,
                    .integer(Int64(limit + 1)),
                ],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let pageRows = rows.prefix(limit)
            let entries = try pageRows.map { row in
                let preparation = try Self.decodePayload(
                    RuntimeGenerationCandidatePreparationRecord.self, row: row
                )
                let completionRows = try database.query(
                    "SELECT * FROM runtime_generation_candidate_preparation_completions WHERE preparation_id = ? LIMIT 2",
                    bindings: [.text(preparation.preparationID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard completionRows.count <= 1 else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "candidate_preparation_completion",
                        id: preparation.preparationID
                    )
                }
                let commitmentRows = try database.query(
                    "SELECT * FROM runtime_generation_projection_rebuild_candidate_authority_commitments WHERE candidate_preparation_id = ? LIMIT 2",
                    bindings: [.text(preparation.preparationID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard commitmentRows.count <= 1 else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "projection_rebuild_candidate_commitment",
                        id: preparation.preparationID
                    )
                }
                return RuntimeGenerationPendingCandidatePreparation(
                    preparation: preparation,
                    completion: try completionRows.first.map {
                        try Self.decodePayload(
                            RuntimeGenerationCandidatePreparationCompletion.self,
                            row: $0
                        )
                    },
                    committedAuthority: try commitmentRows.first.map {
                        try Self.decodePayload(
                            RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                            row: $0
                        )
                    }
                )
            }
            return RuntimeGenerationPendingCandidatePreparationPage(
                entries: entries,
                nextCursor: rows.count > limit ? entries.last.map {
                    RuntimeGenerationPreparationPageCursor(
                        createdAtMilliseconds: $0.preparation.createdAtMilliseconds,
                        preparationID: $0.preparation.preparationID
                    )
                } : nil
            )
        }
    }

    func candidatePreparation(
        generationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationCandidatePreparationRecord {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT * FROM runtime_generation_candidate_preparations WHERE candidate_generation_id = ? LIMIT 2",
            bindings: [.text(generationID.rawValue)],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        guard rows.count == 1 else {
            throw RuntimeGenerationControlError.recordMissing(
                kind: "candidate_preparation",
                id: generationID.rawValue
            )
        }
        return try Self.decodePayload(
            RuntimeGenerationCandidatePreparationRecord.self, row: rows[0]
        )
    }

    func candidatePreparationAuthority(
        generationID: RuntimeStoreGenerationID
    ) async throws -> (
        RuntimeGenerationCandidatePreparationRecord,
        RuntimeGenerationCandidatePreparationCompletion
    ) {
        let preparation = try await candidatePreparation(generationID: generationID)
        return (
            preparation,
            try await load(
                RuntimeGenerationCandidatePreparationCompletion.self,
                table: "runtime_generation_candidate_preparation_completions",
                idColumn: "preparation_id",
                id: preparation.preparationID
            )
        )
    }

    func recordReservation(_ record: RuntimeGenerationReservation) async throws {
        try validateReservation(record)
        try await insertImmutable(
            table: "runtime_generation_reservations",
            idColumn: "reservation_id",
            id: record.reservationID,
            columns: [
                ("operation_kind", .text(record.operationKind.rawValue)),
                ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                ("source_generation_id", record.sourceGenerationID.map { .text($0.rawValue) } ?? .null),
                ("source_generation_digest", record.sourceGenerationDigest.map(SQLiteBinding.text) ?? .null),
                ("expected_active_manifest_digest", record.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null),
                ("target_schema_version", .integer(Int64(record.targetSchemaVersion))),
                ("created_at_ms", .integer(record.createdAtMilliseconds)),
                ("reservation_digest", .text(record.reservationDigest)),
            ],
            payload: record
        )
    }

    func recordReservationAndInitialOperationLease(
        reservation: RuntimeGenerationReservation,
        lease: RuntimeGenerationOperationLease,
        backupPreparation: RuntimeGenerationBackupPreparationRecord? = nil,
        candidatePreparation: RuntimeGenerationCandidatePreparationRecord? = nil
    ) async throws {
        try validateReservation(reservation)
        try RuntimeGenerationControlRecordFactory.validate(lease)
        if let backupPreparation {
            try RuntimeGenerationControlRecordFactory.validate(backupPreparation)
        }
        if let candidatePreparation {
            try RuntimeGenerationControlRecordFactory.validate(candidatePreparation)
        }
        let authorityNow = try authorityNowMilliseconds()
        guard lease.reservationID == reservation.reservationID,
              lease.leaseEpoch == 1,
              lease.fencingToken == 1,
              lease.priorLeaseDigest == nil,
              lease.issuedAtMilliseconds >= reservation.createdAtMilliseconds,
              lease.issuedAtMilliseconds <= authorityNow,
              authorityNow - lease.issuedAtMilliseconds <= 5_000 else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        if let backupPreparation {
            guard backupPreparation.reservationID == reservation.reservationID,
                  backupPreparation.backupID == backupPreparation.finalDirectoryName,
                  backupPreparation.operationLeaseID == lease.leaseID,
                  backupPreparation.operationFencingToken == lease.fencingToken,
                  backupPreparation.sourceGenerationID == reservation.sourceGenerationID,
                  backupPreparation.sourceGenerationDigest == reservation.sourceGenerationDigest,
                  backupPreparation.expectedActiveManifestDigest ==
                    reservation.expectedActiveManifestDigest,
                  backupPreparation.createdAtMilliseconds ==
                    reservation.createdAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
        }
        if let candidatePreparation {
            guard candidatePreparation.reservationID == reservation.reservationID,
                  candidatePreparation.operationLeaseID == lease.leaseID,
                  candidatePreparation.operationFencingToken == lease.fencingToken,
                  candidatePreparation.operationKind == reservation.operationKind,
                  candidatePreparation.candidateGenerationID ==
                    reservation.candidateGenerationID,
                  candidatePreparation.sourceGenerationID == reservation.sourceGenerationID,
                  candidatePreparation.sourceGenerationDigest ==
                    reservation.sourceGenerationDigest,
                  candidatePreparation.expectedActiveManifestDigest ==
                    reservation.expectedActiveManifestDigest,
                  candidatePreparation.createdAtMilliseconds ==
                    reservation.createdAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
        }
        let reservationPayload = try RuntimeGenerationControlCodec.encode(reservation)
        let leasePayload = try RuntimeGenerationControlCodec.encode(lease)
        let preparationPayload: Data?
        if let backupPreparation {
            preparationPayload = try RuntimeGenerationControlCodec.encode(backupPreparation)
        } else {
            preparationPayload = nil
        }
        let candidatePreparationPayload: Data?
        if let candidatePreparation {
            candidatePreparationPayload = try RuntimeGenerationControlCodec.encode(
                candidatePreparation
            )
        } else {
            candidatePreparationPayload = nil
        }
        try revalidateAuthority()
        var writeTables: Set<String> = [
            "runtime_generation_reservations",
            "runtime_generation_operation_leases",
        ]
        if backupPreparation != nil {
            writeTables.insert("runtime_generation_backup_preparations")
        }
        if candidatePreparation != nil {
            writeTables.insert("runtime_generation_candidate_preparations")
        }
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: writeTables,
                reading: writeTables
            )
        ) { database in
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: reservation.reservationID,
                columns: [
                    ("operation_kind", .text(reservation.operationKind.rawValue)),
                    ("candidate_generation_id", .text(reservation.candidateGenerationID.rawValue)),
                    ("source_generation_id", reservation.sourceGenerationID.map { .text($0.rawValue) } ?? .null),
                    ("source_generation_digest", reservation.sourceGenerationDigest.map(SQLiteBinding.text) ?? .null),
                    ("expected_active_manifest_digest", reservation.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null),
                    ("target_schema_version", .integer(Int64(reservation.targetSchemaVersion))),
                    ("created_at_ms", .integer(reservation.createdAtMilliseconds)),
                    ("reservation_digest", .text(reservation.reservationDigest)),
                ],
                payload: reservationPayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: reservationPayload)
            )
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_operation_leases",
                idColumn: "lease_id",
                id: lease.leaseID,
                columns: [
                    ("reservation_id", .text(lease.reservationID)),
                    ("owner_instance_id", .text(lease.ownerInstanceID)),
                    ("lease_epoch", .integer(lease.leaseEpoch)),
                    ("fencing_token", .integer(lease.fencingToken)),
                    ("prior_lease_digest", .null),
                    ("issued_at_ms", .integer(lease.issuedAtMilliseconds)),
                    ("expires_at_ms", .integer(lease.expiresAtMilliseconds)),
                    ("lease_digest", .text(lease.leaseDigest)),
                ],
                payload: leasePayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: leasePayload)
            )
            if let backupPreparation, let preparationPayload {
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_backup_preparations",
                    idColumn: "preparation_id",
                    id: backupPreparation.preparationID,
                    columns: [
                        ("backup_id", .text(backupPreparation.backupID)),
                        ("reservation_id", .text(backupPreparation.reservationID)),
                        ("operation_lease_id", .text(backupPreparation.operationLeaseID)),
                        ("operation_fencing_token", .integer(backupPreparation.operationFencingToken)),
                        ("source_generation_id", .text(backupPreparation.sourceGenerationID.rawValue)),
                        ("source_generation_digest", .text(backupPreparation.sourceGenerationDigest)),
                        ("expected_active_manifest_digest", .text(backupPreparation.expectedActiveManifestDigest)),
                        ("hidden_directory_name", .text(backupPreparation.hiddenDirectoryName)),
                        ("final_directory_name", .text(backupPreparation.finalDirectoryName)),
                        ("created_at_ms", .integer(backupPreparation.createdAtMilliseconds)),
                        ("preparation_digest", .text(backupPreparation.preparationDigest)),
                    ],
                    payload: preparationPayload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: preparationPayload)
                )
            }
            if let candidatePreparation, let candidatePreparationPayload {
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_candidate_preparations",
                    idColumn: "preparation_id",
                    id: candidatePreparation.preparationID,
                    columns: [
                        ("reservation_id", .text(candidatePreparation.reservationID)),
                        ("operation_lease_id", .text(candidatePreparation.operationLeaseID)),
                        ("operation_fencing_token", .integer(candidatePreparation.operationFencingToken)),
                        ("operation_kind", .text(candidatePreparation.operationKind.rawValue)),
                        ("candidate_generation_id", .text(candidatePreparation.candidateGenerationID.rawValue)),
                        ("source_generation_id", candidatePreparation.sourceGenerationID.map { .text($0.rawValue) } ?? .null),
                        ("source_generation_digest", candidatePreparation.sourceGenerationDigest.map(SQLiteBinding.text) ?? .null),
                        ("expected_active_manifest_digest", candidatePreparation.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null),
                        ("staging_directory_name", .text(candidatePreparation.stagingDirectoryName)),
                        ("created_at_ms", .integer(candidatePreparation.createdAtMilliseconds)),
                        ("preparation_digest", .text(candidatePreparation.preparationDigest)),
                    ],
                    payload: candidatePreparationPayload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: candidatePreparationPayload
                    )
                )
            }
        }
    }

    func recordOperationLease(_ record: RuntimeGenerationOperationLease) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        let authorityNow = try authorityNowMilliseconds()
        guard record.issuedAtMilliseconds <= authorityNow,
              authorityNow - record.issuedAtMilliseconds <= 5_000 else {
            throw RuntimeGenerationControlError.reservationExpired
        }
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_operation_leases"],
                reading: [
                    "runtime_generation_reservations",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: record.reservationID,
                database: database
            )
            guard record.issuedAtMilliseconds >= reservation.createdAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let priorRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(record.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if let row = priorRows.first {
                let prior = try Self.decodePayload(
                    RuntimeGenerationOperationLease.self, row: row
                )
                guard record.leaseEpoch == prior.leaseEpoch + 1,
                      record.priorLeaseDigest == prior.leaseDigest,
                      record.issuedAtMilliseconds >= prior.issuedAtMilliseconds else {
                    throw RuntimeGenerationControlError.reservationExpired
                }
                if record.ownerInstanceID == prior.ownerInstanceID {
                    guard record.fencingToken == prior.fencingToken,
                          record.issuedAtMilliseconds < prior.expiresAtMilliseconds else {
                        throw RuntimeGenerationControlError.reservationExpired
                    }
                } else {
                    guard prior.fencingToken < Int64.max,
                          record.fencingToken == prior.fencingToken + 1,
                          record.issuedAtMilliseconds >= prior.expiresAtMilliseconds else {
                        throw RuntimeGenerationControlError.reservationExpired
                    }
                }
            } else {
                guard record.leaseEpoch == 1,
                      record.fencingToken == 1,
                      record.priorLeaseDigest == nil else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_operation_leases",
                idColumn: "lease_id",
                id: record.leaseID,
                columns: [
                    ("reservation_id", .text(record.reservationID)),
                    ("owner_instance_id", .text(record.ownerInstanceID)),
                    ("lease_epoch", .integer(record.leaseEpoch)),
                    ("fencing_token", .integer(record.fencingToken)),
                    ("prior_lease_digest", record.priorLeaseDigest.map(SQLiteBinding.text) ?? .null),
                    ("issued_at_ms", .integer(record.issuedAtMilliseconds)),
                    ("expires_at_ms", .integer(record.expiresAtMilliseconds)),
                    ("lease_digest", .text(record.leaseDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func currentOperationLease(
        reservationID: String
    ) async throws -> RuntimeGenerationOperationLease? {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
            bindings: [.text(reservationID)],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        return try rows.first.map {
            let lease = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: $0
            )
            try RuntimeGenerationControlRecordFactory.validate(lease)
            return lease
        }
    }

    func requireCurrentOperationLease(
        reservationID: String,
        ownerInstanceID: String,
        observedAtMilliseconds: Int64
    ) async throws -> RuntimeGenerationOperationLease {
        guard let lease = try await currentOperationLease(
            reservationID: reservationID
        ), lease.ownerInstanceID == ownerInstanceID,
           observedAtMilliseconds >= lease.issuedAtMilliseconds,
           observedAtMilliseconds < lease.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.reservationExpired
        }
        return lease
    }

    func recordMigrationRun(_ record: RuntimeGenerationMigrationRun) async throws {
        try validateMigrationRun(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        var readTables: Set<String> = [
            "runtime_generation_reservations",
            "runtime_generation_operation_leases",
            "runtime_generation_migration_runs",
        ]
        if record.operationKind != .install {
            readTables.insert("runtime_generation_backups")
        }
        if record.operationKind == .restore || record.operationKind == .rollback {
            readTables.formUnion([
                "runtime_generation_backup_preparations",
                "runtime_generation_backup_preparation_completions",
                "runtime_generation_backup_preparation_consumptions",
                "runtime_generation_recovery_authorizations",
                "runtime_generation_recovery_authorization_consumptions",
            ])
        }
        if record.operationKind == .rollback {
            readTables.formUnion([
                "runtime_generation_rollbacks",
                "runtime_generation_restore_baselines",
            ])
        }
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_migration_runs"],
                reading: readTables
            )
        ) { database in
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: record.reservationID,
                database: database
            )
            guard reservation.candidateGenerationID == record.candidateGenerationID,
                  reservation.operationKind == record.operationKind,
                  reservation.targetSchemaVersion == record.targetSchemaVersion,
                  record.startedAtMilliseconds >= reservation.createdAtMilliseconds
            else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let leaseRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(record.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let leaseRow = leaseRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let lease = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: leaseRow
            )
            try RuntimeGenerationControlRecordFactory.validate(lease)
            guard lease.ownerInstanceID == record.executorInstanceID,
                  lease.leaseID == record.operationLeaseID,
                  lease.leaseEpoch == record.operationLeaseEpoch,
                  lease.fencingToken == record.operationFencingToken,
                  record.completedAtMilliseconds >= lease.issuedAtMilliseconds,
                  record.completedAtMilliseconds < lease.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            if record.operationKind == .install {
                guard record.sourceSafetyBackupID == nil,
                      record.backupID == nil else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            } else {
                guard let sourceSafetyBackupID = record.sourceSafetyBackupID,
                      let backupID = record.backupID else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
                let sourceSafetyBackup = try Self.loadEligibleBackup(
                    id: sourceSafetyBackupID,
                    database: database
                )
                guard sourceSafetyBackup.sourceGenerationID == reservation.sourceGenerationID,
                      sourceSafetyBackup.sourceGenerationDigest == reservation.sourceGenerationDigest,
                      sourceSafetyBackup.createdAtMilliseconds <= record.startedAtMilliseconds else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                let inputBackup = try Self.loadEligibleBackup(
                    id: backupID,
                    database: database
                )
                guard inputBackup.createdAtMilliseconds <= record.startedAtMilliseconds,
                      record.operationKind == .restore ||
                        record.operationKind == .rollback ||
                        inputBackup.backupID == sourceSafetyBackup.backupID else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                if record.operationKind == .restore || record.operationKind == .rollback {
                    guard let authorizationID = record.recoveryAuthorizationID,
                          let authorizationDigest = record.recoveryAuthorizationDigest else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                    let authorization = try Self.loadPayload(
                        RuntimeGenerationRecoveryAuthorization.self,
                        table: "runtime_generation_recovery_authorizations",
                        idColumn: "authorization_id",
                        id: authorizationID,
                        database: database
                    )
                    let consumptions = try database.query(
                        "SELECT authorization_id FROM runtime_generation_recovery_authorization_consumptions WHERE authorization_id = ? LIMIT 1",
                        bindings: [.text(authorizationID)],
                        maximumDecodedBytes: maximumControlReadBytes
                    )
                    let targetMatches: Bool
                    if record.operationKind == .restore {
                        targetMatches =
                            authorization.action == .restoreVerifiedBackup &&
                            authorization.targetDigest == inputBackup.backupDigest
                    } else {
                        let rollbackRows = try database.query(
                            "SELECT * FROM runtime_generation_rollbacks WHERE rollback_digest = ? LIMIT 2",
                            bindings: [.text(authorization.targetDigest)],
                            maximumDecodedBytes: maximumControlReadBytes
                        )
                        guard rollbackRows.count == 1 else {
                            throw RuntimeGenerationControlError.rollbackUnsafe
                        }
                        let rollback = try Self.decodePayload(
                            RuntimeGenerationRollbackRecord.self,
                            row: rollbackRows[0]
                        )
                        let baselinePlan = try Self.loadPayload(
                            RuntimeGenerationRestoreBaselinePlan.self,
                            table: "runtime_generation_restore_baselines",
                            idColumn: "plan_id",
                            id: rollback.restoreBaselinePlanID,
                            database: database
                        )
                        targetMatches =
                            authorization.action == .rollbackToSafetyBackup &&
                            rollback.targetGenerationID == reservation.sourceGenerationID &&
                            rollback.targetObservedFence == sourceSafetyBackup.sourceFence &&
                            baselinePlan.sourceSafetyBackupID == inputBackup.backupID
                    }
                    guard authorization.authorizationDigest == authorizationDigest,
                          targetMatches,
                          record.startedAtMilliseconds >= authorization.authorizedAtMilliseconds,
                          record.startedAtMilliseconds < authorization.expiresAtMilliseconds,
                          consumptions.isEmpty else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                } else if record.recoveryAuthorizationID != nil ||
                    record.recoveryAuthorizationDigest != nil {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: record.migrationRunID,
                columns: [
                ("reservation_id", .text(record.reservationID)),
                ("executor_instance_id", .text(record.executorInstanceID)),
                ("operation_lease_id", .text(record.operationLeaseID)),
                ("operation_lease_epoch", .integer(record.operationLeaseEpoch)),
                ("operation_fencing_token", .integer(record.operationFencingToken)),
                ("source_safety_backup_id", record.sourceSafetyBackupID.map(SQLiteBinding.text) ?? .null),
                ("backup_id", record.backupID.map(SQLiteBinding.text) ?? .null),
                ("recovery_authorization_id", record.recoveryAuthorizationID.map(SQLiteBinding.text) ?? .null),
                ("recovery_authorization_digest", record.recoveryAuthorizationDigest.map(SQLiteBinding.text) ?? .null),
                ("recovery_execution_plan_id", record.recoveryExecutionPlanID.map(SQLiteBinding.text) ?? .null),
                ("recovery_execution_claim_id", record.recoveryExecutionClaimID.map(SQLiteBinding.text) ?? .null),
                ("recovery_execution_claim_epoch", record.recoveryExecutionClaimEpoch.map { .integer($0) } ?? .null),
                ("operation_kind", .text(record.operationKind.rawValue)),
                ("source_schema_version", record.sourceSchemaVersion.map { .integer(Int64($0)) } ?? .null),
                ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                ("target_schema_version", .integer(Int64(record.targetSchemaVersion))),
                ("transformation_version", .integer(Int64(record.transformationVersion))),
                ("provenance_digest", .text(record.provenanceDigest)),
                ("started_at_ms", .integer(record.startedAtMilliseconds)),
                ("completed_at_ms", .integer(record.completedAtMilliseconds)),
                ("run_digest", .text(record.runDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func recordCandidateReplayAudit(
        _ record: RuntimeGenerationCandidateReplayAuditRecord,
        currentLease: RuntimeGenerationOperationLease
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlRecordFactory.validate(currentLease)
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_candidate_replay_audits"],
                reading: [
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_replay_audits",
                    "runtime_generation_reservations",
                    "runtime_generation_operation_leases",
                ]
            )
        ) { database in
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationCandidateReplayAuditRecord.self,
                table: "runtime_generation_candidate_replay_audits",
                idColumn: "audit_id", id: record.auditID, database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "candidate_replay_audit", id: record.auditID
                    )
                }
                return
            }
            let preparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id", id: record.preparationID, database: database
            )
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id", id: record.reservationID, database: database
            )
            let latestRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(record.reservationID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestRow = latestRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latest = try Self.decodePayload(RuntimeGenerationOperationLease.self, row: latestRow)
            guard preparation.reservationID == record.reservationID,
                  preparation.candidateGenerationID == record.candidateGenerationID,
                  reservation.candidateGenerationID == record.candidateGenerationID,
                  latest == currentLease,
                  record.operationLeaseID == latest.leaseID,
                  record.operationLeaseEpoch == latest.leaseEpoch,
                  record.operationFencingToken == latest.fencingToken,
                  record.auditedAtMilliseconds >= latest.issuedAtMilliseconds,
                  record.auditedAtMilliseconds < latest.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_candidate_replay_audits",
                idColumn: "audit_id", id: record.auditID,
                columns: [
                    ("preparation_id", .text(record.preparationID)),
                    ("reservation_id", .text(record.reservationID)),
                    ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                    ("operation_lease_id", .text(record.operationLeaseID)),
                    ("operation_lease_epoch", .integer(record.operationLeaseEpoch)),
                    ("operation_fencing_token", .integer(record.operationFencingToken)),
                    ("outcome", .text(record.outcome.rawValue)),
                    ("blocked_invariant", record.blockedInvariant.map { .text($0.rawValue) } ?? .null),
                    ("replay_checkpoint_digest", record.replayCheckpointDigest.map(SQLiteBinding.text) ?? .null),
                    ("replay_certificate_digest", record.replayCertificateDigest.map(SQLiteBinding.text) ?? .null),
                    ("reconstruction_digest", record.reconstructionDigest.map(SQLiteBinding.text) ?? .null),
                    ("audited_at_ms", .integer(record.auditedAtMilliseconds)),
                    ("audit_digest", .text(record.auditDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordVerification(_ record: RuntimeGenerationVerificationReport) async throws {
        try validateVerification(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_verifications"],
                reading: [
                    "runtime_generation_reservations",
                    "runtime_generation_migration_runs",
                    "runtime_generation_records",
                    "runtime_generation_verifications",
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_replay_audits",
                    "runtime_generation_operation_leases",
                    "runtime_generation_projection_rebuild_candidate_reservations",
                    "runtime_generation_projection_rebuild_candidate_authority_commitments",
                ]
            )
        ) { database in
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: record.reservationID,
                database: database
            )
            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: record.migrationRunID,
                database: database
            )
            let candidate = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.candidateGenerationID.rawValue,
                database: database
            )
            let projectionCandidateReservation = try Self.loadOptionalPayload(
                RuntimeGenerationProjectionRebuildCandidateReservation.self,
                table: "runtime_generation_projection_rebuild_candidate_reservations",
                idColumn: "reservation_id", id: record.reservationID, database: database
            )
            let projectionCommitment = try projectionCandidateReservation.map {
                try Self.loadPayload(
                    RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                    table: "runtime_generation_projection_rebuild_candidate_authority_commitments",
                    idColumn: "candidate_reservation_id", id: $0.candidateReservationID, database: database
                )
            }
            let manifest = candidate.authorityManifest
            let auditRows = try database.query(
                "SELECT * FROM runtime_generation_candidate_replay_audits WHERE candidate_generation_id = ? LIMIT 2",
                bindings: [.text(record.candidateGenerationID.rawValue)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard auditRows.count == 1 else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            let audit = try Self.decodePayload(
                RuntimeGenerationCandidateReplayAuditRecord.self, row: auditRows[0]
            )
            let preparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id", id: audit.preparationID, database: database
            )
            let auditLease = try Self.loadPayload(
                RuntimeGenerationOperationLease.self,
                table: "runtime_generation_operation_leases",
                idColumn: "lease_id", id: audit.operationLeaseID, database: database
            )
            guard reservation.candidateGenerationID == record.candidateGenerationID,
                  run.candidateGenerationID == record.candidateGenerationID,
                  run.reservationID == record.reservationID,
                  run.migrationRunID == record.migrationRunID,
                  run.operationKind == reservation.operationKind,
                  run.executorInstanceID != record.verifierInstanceID,
                  reservation.targetSchemaVersion == record.expectedSchemaVersion,
                  record.candidateAuthorityManifestDigest == manifest.manifestDigest,
                  record.candidateAuthorityManifestFileSHA256 == candidate.authorityManifestFileSHA256,
                  record.candidateSelectorFileSHA256 == candidate.selectorFileSHA256,
                  record.sourceGenerationID == reservation.sourceGenerationID,
                  record.sourceGenerationDigest == reservation.sourceGenerationDigest,
                  record.sourceFenceDigest == manifest.sourceFence?.fenceDigest,
                  record.expectedActiveManifestDigest == reservation.expectedActiveManifestDigest,
                  audit.outcome == .complete,
                  audit.preparationID == preparation.preparationID,
                  audit.reservationID == record.reservationID,
                  audit.candidateGenerationID == record.candidateGenerationID,
                  auditLease.reservationID == record.reservationID,
                  auditLease.leaseEpoch == audit.operationLeaseEpoch,
                  auditLease.fencingToken == audit.operationFencingToken,
                  audit.reconstructionDigest != nil,
                  (reservation.operationKind != .projectionRebuild ||
                    (projectionCandidateReservation != nil &&
                     projectionCommitment != nil &&
                     projectionCandidateReservation!.expectedVerificationID == record.verificationID &&
                     projectionCommitment!.expectedVerificationID == record.verificationID &&
                     projectionCommitment!.candidateRecord == candidate &&
                     projectionCommitment!.replayAuditID == audit.auditID)),
                  record.verifiedAtMilliseconds >= manifest.createdAtMilliseconds,
                  record.verifiedAtMilliseconds >= run.completedAtMilliseconds
            else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: record.verificationID,
                columns: [
                    ("reservation_id", .text(record.reservationID)),
                    ("migration_run_id", .text(record.migrationRunID)),
                    ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                    ("candidate_authority_manifest_digest", .text(record.candidateAuthorityManifestDigest)),
                    ("candidate_authority_manifest_file_sha256", .text(record.candidateAuthorityManifestFileSHA256)),
                    ("candidate_selector_file_sha256", .text(record.candidateSelectorFileSHA256)),
                    ("source_fence_digest", record.sourceFenceDigest.map(SQLiteBinding.text) ?? .null),
                    ("expected_active_manifest_digest", record.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null),
                    ("accepted", .integer(record.accepted ? 1 : 0)),
                    ("verified_at_ms", .integer(record.verifiedAtMilliseconds)),
                    ("report_digest", .text(record.reportDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func recordActivationIntent(_ record: RuntimeGenerationActivationIntent) async throws {
        try validateActivationIntent(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_activation_intents"],
                reading: [
                    "runtime_generation_verifications",
                    "runtime_generation_reservations",
                    "runtime_generation_activation_intents",
                    "runtime_generation_projection_rebuild_candidate_reservations",
                    "runtime_generation_projection_rebuild_candidate_authority_commitments",
                ]
            )
        ) { database in
            let report = try Self.loadPayload(
                RuntimeGenerationVerificationReport.self,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: record.verificationID,
                database: database
            )
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: record.reservationID,
                database: database
            )
            let projectionCandidateReservation = try Self.loadOptionalPayload(
                RuntimeGenerationProjectionRebuildCandidateReservation.self,
                table: "runtime_generation_projection_rebuild_candidate_reservations",
                idColumn: "reservation_id", id: record.reservationID, database: database
            )
            let projectionCommitment = try projectionCandidateReservation.map {
                try Self.loadPayload(
                    RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                    table: "runtime_generation_projection_rebuild_candidate_authority_commitments",
                    idColumn: "candidate_reservation_id", id: $0.candidateReservationID, database: database
                )
            }
            guard report.hasCompleteEvidence,
                  report.reservationID == record.reservationID,
                  report.candidateGenerationID == record.candidateGenerationID,
                  report.candidateAuthorityManifestDigest == record.candidateAuthorityManifestDigest,
                  report.candidateAuthorityManifestFileSHA256 == record.candidateAuthorityManifestFileSHA256,
                  report.candidateSelectorFileSHA256 == record.candidateSelectorFileSHA256,
                  report.sourceFenceDigest == record.expectedSourceFenceDigest,
                  report.expectedActiveManifestDigest == record.expectedActiveManifestDigest,
                  reservation.reservationID == report.reservationID,
                  reservation.candidateGenerationID == record.candidateGenerationID,
                  reservation.sourceGenerationID == record.expectedSourceGenerationID,
                  reservation.sourceGenerationDigest == record.expectedSourceGenerationDigest,
                  reservation.expectedActiveManifestDigest == record.expectedActiveManifestDigest,
                  (reservation.operationKind != .projectionRebuild ||
                    (projectionCandidateReservation != nil &&
                     projectionCommitment != nil &&
                     projectionCandidateReservation!.expectedVerificationID == report.verificationID &&
                     projectionCandidateReservation!.expectedActivationIntentID == record.intentID &&
                     projectionCommitment!.expectedVerificationID == report.verificationID &&
                     projectionCommitment!.expectedActivationIntentID == record.intentID)),
                  record.createdAtMilliseconds >= report.verifiedAtMilliseconds,
                  record.expiresAtMilliseconds > record.createdAtMilliseconds
            else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_activation_intents",
                idColumn: "intent_id",
                id: record.intentID,
                columns: [
                    ("reservation_id", .text(record.reservationID)),
                    ("verification_id", .text(record.verificationID)),
                    ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                    ("candidate_authority_manifest_digest", .text(record.candidateAuthorityManifestDigest)),
                    ("candidate_authority_manifest_file_sha256", .text(record.candidateAuthorityManifestFileSHA256)),
                    ("candidate_selector_file_sha256", .text(record.candidateSelectorFileSHA256)),
                    ("expected_active_manifest_digest", record.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null),
                    ("created_at_ms", .integer(record.createdAtMilliseconds)),
                    ("expires_at_ms", .integer(record.expiresAtMilliseconds)),
                    ("intent_digest", .text(record.intentDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    /// Records the single immutable consumption after the active manifest is
    /// observed at the exact installed digest. A resolver may safely call this
    /// after a crash between manifest fsync and control-journal insertion; the
    /// unique intent key makes reconciliation idempotent and single-use.
    func consumeActivation(
        _ consumption: RuntimeGenerationActivationConsumption,
        observedIntent: RuntimeGenerationActivationIntent,
        observedVerification: RuntimeGenerationVerificationReport,
        nowMilliseconds: Int64
    ) async throws {
        try validateConsumption(consumption)
        // Expiry gates the pre-commit activation decision, never recovery of
        // an exact selector already durably installed. Rejecting this record
        // after expiry would strand a committed selector in false uncertainty.
        guard nowMilliseconds >= observedIntent.createdAtMilliseconds,
              observedIntent.intentID == consumption.intentID,
              observedVerification.verificationID == observedIntent.verificationID,
              observedVerification.hasCompleteEvidence,
              observedVerification.candidateAuthorityManifestDigest ==
                observedIntent.candidateAuthorityManifestDigest,
              observedVerification.candidateAuthorityManifestFileSHA256 ==
                observedIntent.candidateAuthorityManifestFileSHA256,
              observedVerification.candidateSelectorFileSHA256 ==
                observedIntent.candidateSelectorFileSHA256
        else {
            throw RuntimeGenerationControlError.activationIntentExpired
        }
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(consumption)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_activation_consumptions"],
                reading: [
                    "runtime_generation_activation_intents",
                    "runtime_generation_verifications",
                    "runtime_generation_activation_consumptions",
                ]
            )
        ) { database in
            let durableIntent = try Self.loadPayload(
                RuntimeGenerationActivationIntent.self,
                table: "runtime_generation_activation_intents",
                idColumn: "intent_id",
                id: consumption.intentID,
                database: database
            )
            let durableReport = try Self.loadPayload(
                RuntimeGenerationVerificationReport.self,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: durableIntent.verificationID,
                database: database
            )
            guard durableIntent == observedIntent,
                  durableReport == observedVerification,
                  consumption.installedSelectorFileSHA256 ==
                    durableIntent.candidateSelectorFileSHA256
            else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let existing = try database.query(
                "SELECT * FROM runtime_generation_activation_consumptions WHERE intent_id = ? LIMIT 2",
                bindings: [.text(consumption.intentID)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            if existing.isEmpty == false {
                guard existing.count == 1,
                      try Self.decodePayload(
                          RuntimeGenerationActivationConsumption.self,
                          row: existing[0]
                      ) == consumption
                else {
                    throw RuntimeGenerationControlError.activationIntentConsumed
                }
                return
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_activation_consumptions",
                idColumn: "intent_id",
                id: consumption.intentID,
                columns: [
                    ("consumed_at_ms", .integer(consumption.consumedAtMilliseconds)),
                    ("installed_selector_file_sha256", .text(consumption.installedSelectorFileSHA256)),
                    ("prior_generation_id", consumption.priorGenerationID.map { .text($0.rawValue) } ?? .null),
                    ("prior_generation_digest", consumption.priorGenerationDigest.map(SQLiteBinding.text) ?? .null),
                    ("consumption_digest", .text(consumption.consumptionDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    /// Atomically completes the control-plane side of an already durable
    /// selector commit. Consumption, active retention, and optional destructive
    /// recovery consumption can never be partially journaled.
    func finalizeCommittedActivation(
        consumption: RuntimeGenerationActivationConsumption,
        retentionTransition: RuntimeGenerationRetentionTransition,
        predecessorRetentionTransition: RuntimeGenerationRetentionTransition?,
        recoveryConsumption: RuntimeGenerationRecoveryAuthorizationConsumption?,
        candidateDisposition: RuntimeGenerationCandidatePreparationDisposition,
        observedIntent: RuntimeGenerationActivationIntent,
        observedVerification: RuntimeGenerationVerificationReport,
        nowMilliseconds: Int64
    ) async throws {
        try validateConsumption(consumption)
        try RuntimeGenerationControlRecordFactory.validate(retentionTransition)
        try predecessorRetentionTransition.map {
            try RuntimeGenerationControlRecordFactory.validate($0)
        }
        try recoveryConsumption?.validate()
        try RuntimeGenerationControlRecordFactory.validate(candidateDisposition)
        guard let retentionFromClass = retentionTransition.fromClass,
              retentionTransition.generationID == observedIntent.candidateGenerationID,
              retentionFromClass == .freshConnectionVerified,
              retentionTransition.toClass == .active,
              retentionTransition.authorityDigest == consumption.consumptionDigest,
              consumption.intentID == observedIntent.intentID,
              consumption.installedSelectorFileSHA256 ==
                observedIntent.candidateSelectorFileSHA256,
              observedVerification.verificationID == observedIntent.verificationID,
              candidateDisposition.kind == .activated,
              candidateDisposition.authorityDigest == consumption.consumptionDigest,
              candidateDisposition.disposedAtMilliseconds >= nowMilliseconds,
              observedVerification.hasCompleteEvidence,
              nowMilliseconds >= observedIntent.createdAtMilliseconds,
              consumption.consumedAtMilliseconds == nowMilliseconds,
              nowMilliseconds < Int64.max,
              retentionTransition.occurredAtMilliseconds >= nowMilliseconds,
              retentionTransition.occurredAtMilliseconds <= nowMilliseconds + 1,
              (consumption.priorGenerationID == nil) ==
                (predecessorRetentionTransition == nil) else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        if let predecessorRetentionTransition,
           let priorGenerationID = consumption.priorGenerationID {
            guard predecessorRetentionTransition.generationID == priorGenerationID,
                  predecessorRetentionTransition.fromClass == .active,
                  predecessorRetentionTransition.toClass == .verifiedRollback,
                  predecessorRetentionTransition.authorityDigest ==
                    consumption.consumptionDigest,
                  predecessorRetentionTransition.occurredAtMilliseconds >=
                    nowMilliseconds,
                  predecessorRetentionTransition.occurredAtMilliseconds <=
                    nowMilliseconds + 1 else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
        }
        try revalidateAuthority()
        let consumptionPayload = try RuntimeGenerationControlCodec.encode(consumption)
        let recoveryPayload = try recoveryConsumption.map {
            try RuntimeGenerationControlCodec.encode($0)
        }
        let dispositionPayload = try RuntimeGenerationControlCodec.encode(
            candidateDisposition
        )
        var writeTables: Set<String> = [
            "runtime_generation_activation_consumptions",
            "runtime_generation_retention_transitions",
            "runtime_generation_active_authority",
            "runtime_generation_candidate_preparation_dispositions",
        ]
        var readTables: Set<String> = [
            "runtime_generation_activation_intents",
            "runtime_generation_verifications",
            "runtime_generation_records",
            "runtime_generation_migration_runs",
            "runtime_generation_candidate_preparations",
            "runtime_generation_candidate_preparation_completions",
            "runtime_generation_operation_leases",
            "runtime_generation_active_authority",
            "runtime_generation_activation_consumptions",
            "runtime_generation_retention_transitions",
            "runtime_generation_candidate_preparation_dispositions",
        ]
        if recoveryConsumption != nil {
            writeTables.insert("runtime_generation_recovery_authorization_consumptions")
            readTables.formUnion([
                "runtime_generation_recovery_authorizations",
                "runtime_generation_restore_baselines",
                "runtime_generation_recovery_precommit_witnesses",
                "runtime_generation_recovery_authorization_consumptions",
            ])
        }
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: writeTables,
                reading: readTables
            )
        ) { database in
            let durableIntent = try Self.loadPayload(
                RuntimeGenerationActivationIntent.self,
                table: "runtime_generation_activation_intents",
                idColumn: "intent_id",
                id: consumption.intentID,
                database: database
            )
            let durableVerification = try Self.loadPayload(
                RuntimeGenerationVerificationReport.self,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: durableIntent.verificationID,
                database: database
            )
            guard durableIntent == observedIntent,
                  durableVerification == observedVerification else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let durableCandidate = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: observedIntent.candidateGenerationID.rawValue,
                database: database
            )
            let durableRun = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: durableCandidate.authorityManifest.migrationRunID,
                database: database
            )
            let candidatePreparation = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationRecord.self,
                table: "runtime_generation_candidate_preparations",
                idColumn: "preparation_id",
                id: candidateDisposition.preparationID,
                database: database
            )
            let candidateCompletion = try Self.loadPayload(
                RuntimeGenerationCandidatePreparationCompletion.self,
                table: "runtime_generation_candidate_preparation_completions",
                idColumn: "preparation_id",
                id: candidateDisposition.preparationID,
                database: database
            )
            let latestLeaseRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1",
                bindings: [.text(candidatePreparation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestLeaseRow = latestLeaseRows.first else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let latestLease = try Self.decodePayload(
                RuntimeGenerationOperationLease.self, row: latestLeaseRow
            )
            let replayActiveRows = try database.query(
                "SELECT * FROM runtime_generation_active_authority WHERE singleton_id = 1 LIMIT 2",
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard replayActiveRows.count <= 1 else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let isExactCommittedReplay: Bool
            if let row = replayActiveRows.first {
                let active = try Self.decodePayload(
                    RuntimeGenerationActiveAuthority.self, row: row
                )
                try RuntimeGenerationControlRecordFactory.validate(active)
                isExactCommittedReplay =
                    active.generationID == observedIntent.candidateGenerationID &&
                    active.authorityManifestDigest ==
                        durableCandidate.authorityManifest.manifestDigest &&
                    active.selectorFileSHA256 == consumption.installedSelectorFileSHA256 &&
                    active.activationIntentID == consumption.intentID &&
                    active.activationConsumptionDigest == consumption.consumptionDigest
            } else {
                isExactCommittedReplay = false
            }
            guard candidatePreparation.candidateGenerationID ==
                    durableCandidate.authorityManifest.generationID,
                  candidatePreparation.reservationID == durableRun.reservationID,
                  candidateCompletion.candidateRecordDigest ==
                    durableCandidate.recordDigest,
                  candidateCompletion.completedAtMilliseconds >=
                    candidatePreparation.createdAtMilliseconds,
                  candidateCompletion.directoryDevice > 0,
                  candidateCompletion.directoryInode > 0,
                  candidateCompletion.interiorArtifactCount == 2,
                  (isExactCommittedReplay ||
                    (candidateDisposition.operationLeaseID == latestLease.leaseID &&
                     candidateDisposition.operationFencingToken == latestLease.fencingToken &&
                     candidateDisposition.disposedAtMilliseconds >=
                        latestLease.issuedAtMilliseconds &&
                     candidateDisposition.disposedAtMilliseconds <
                        latestLease.expiresAtMilliseconds)) else {
                throw RuntimeGenerationControlError.reservationExpired
            }
            let requiresRecoveryConsumption = durableRun.operationKind == .restore ||
                durableRun.operationKind == .rollback
            guard requiresRecoveryConsumption == (recoveryConsumption != nil) else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let existingConsumption = try database.query(
                "SELECT * FROM runtime_generation_activation_consumptions WHERE intent_id = ? LIMIT 2",
                bindings: [.text(consumption.intentID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if let row = existingConsumption.first {
                guard existingConsumption.count == 1,
                      try Self.decodePayload(
                        RuntimeGenerationActivationConsumption.self, row: row
                      ) == consumption else {
                    throw RuntimeGenerationControlError.activationIntentConsumed
                }
            } else {
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_activation_consumptions",
                    idColumn: "intent_id",
                    id: consumption.intentID,
                    columns: [
                        ("consumed_at_ms", .integer(consumption.consumedAtMilliseconds)),
                        ("installed_selector_file_sha256", .text(consumption.installedSelectorFileSHA256)),
                        ("prior_generation_id", consumption.priorGenerationID.map { .text($0.rawValue) } ?? .null),
                        ("prior_generation_digest", consumption.priorGenerationDigest.map(SQLiteBinding.text) ?? .null),
                        ("consumption_digest", .text(consumption.consumptionDigest)),
                    ],
                    payload: consumptionPayload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: consumptionPayload)
                )
            }

            let activeRows = try database.query(
                "SELECT * FROM runtime_generation_active_authority WHERE singleton_id = 1 LIMIT 2",
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard activeRows.count <= 1 else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let currentActive = try activeRows.first.map {
                try Self.decodePayload(RuntimeGenerationActiveAuthority.self, row: $0)
            }
            try currentActive.map { try RuntimeGenerationControlRecordFactory.validate($0) }
            if let currentActive,
               currentActive.generationID == observedIntent.candidateGenerationID,
               currentActive.authorityManifestDigest ==
                durableCandidate.authorityManifest.manifestDigest,
               currentActive.selectorFileSHA256 ==
                consumption.installedSelectorFileSHA256,
               currentActive.activationIntentID == consumption.intentID,
               currentActive.activationConsumptionDigest ==
                consumption.consumptionDigest {
                let targetRows = try database.query(
                    "SELECT * FROM runtime_generation_retention_transitions WHERE transition_id = ? LIMIT 2",
                    bindings: [.text(retentionTransition.transitionID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard targetRows.count == 1,
                      try Self.decodePayload(
                        RuntimeGenerationRetentionTransition.self,
                        row: targetRows[0]
                      ) == retentionTransition else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                if let predecessorRetentionTransition {
                    let predecessorRows = try database.query(
                        "SELECT * FROM runtime_generation_retention_transitions WHERE transition_id = ? LIMIT 2",
                        bindings: [.text(predecessorRetentionTransition.transitionID)],
                        maximumDecodedBytes: Self.maximumControlReadBytes
                    )
                    guard predecessorRows.count == 1,
                          try Self.decodePayload(
                            RuntimeGenerationRetentionTransition.self,
                            row: predecessorRows[0]
                          ) == predecessorRetentionTransition else {
                        throw RuntimeGenerationControlError.activationAuthorityMismatch
                    }
                }
                if let recoveryConsumption {
                    let recoveryRows = try database.query(
                        "SELECT * FROM runtime_generation_recovery_authorization_consumptions WHERE authorization_id = ? LIMIT 2",
                        bindings: [.text(recoveryConsumption.authorizationID)],
                        maximumDecodedBytes: Self.maximumControlReadBytes
                    )
                    guard recoveryRows.count == 1,
                          try Self.decodePayload(
                            RuntimeGenerationRecoveryAuthorizationConsumption.self,
                            row: recoveryRows[0]
                          ) == recoveryConsumption else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                }
                let dispositionRows = try database.query(
                    "SELECT * FROM runtime_generation_candidate_preparation_dispositions WHERE preparation_id = ? LIMIT 2",
                    bindings: [.text(candidateDisposition.preparationID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard dispositionRows.count == 1,
                      try Self.decodePayload(
                        RuntimeGenerationCandidatePreparationDisposition.self,
                        row: dispositionRows[0]
                      ) == candidateDisposition else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                // The entire immediate transaction is authenticated and exact.
                return
            }
            let nextEpoch: Int64
            if let currentActive {
                guard currentActive.activationEpoch < Int64.max,
                      currentActive.generationID == consumption.priorGenerationID,
                      currentActive.authorityManifestDigest ==
                        consumption.priorGenerationDigest,
                      let predecessorRetentionTransition else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                nextEpoch = currentActive.activationEpoch + 1
                try Self.insertRetentionTransition(
                    predecessorRetentionTransition,
                    database: database
                )
            } else {
                guard consumption.priorGenerationID == nil,
                      predecessorRetentionTransition == nil else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                nextEpoch = 1
            }
            try Self.insertRetentionTransition(retentionTransition, database: database)

            let activeAuthority = try RuntimeGenerationControlRecordFactory.activeAuthority(
                activationEpoch: nextEpoch,
                generationID: durableCandidate.authorityManifest.generationID,
                authorityManifestDigest: durableCandidate.authorityManifest.manifestDigest,
                selectorFileSHA256: consumption.installedSelectorFileSHA256,
                activationIntentID: consumption.intentID,
                activationConsumptionDigest: consumption.consumptionDigest,
                priorGenerationID: consumption.priorGenerationID,
                priorGenerationDigest: consumption.priorGenerationDigest,
                activatedAtMilliseconds: consumption.consumedAtMilliseconds
            )
            let activePayload = try RuntimeGenerationControlCodec.encode(activeAuthority)
            let activeUpdate = try database.execute(
                """
                INSERT INTO runtime_generation_active_authority(
                    singleton_id, activation_epoch, generation_id,
                    authority_manifest_digest, selector_file_sha256,
                    activation_intent_id, activation_consumption_digest,
                    prior_generation_id, prior_generation_digest, activated_at_ms,
                    authority_digest, payload, payload_digest
                ) VALUES(1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(singleton_id) DO UPDATE SET
                    activation_epoch = excluded.activation_epoch,
                    generation_id = excluded.generation_id,
                    authority_manifest_digest = excluded.authority_manifest_digest,
                    selector_file_sha256 = excluded.selector_file_sha256,
                    activation_intent_id = excluded.activation_intent_id,
                    activation_consumption_digest = excluded.activation_consumption_digest,
                    prior_generation_id = excluded.prior_generation_id,
                    prior_generation_digest = excluded.prior_generation_digest,
                    activated_at_ms = excluded.activated_at_ms,
                    authority_digest = excluded.authority_digest,
                    payload = excluded.payload,
                    payload_digest = excluded.payload_digest
                """,
                bindings: [
                    .integer(activeAuthority.activationEpoch),
                    .text(activeAuthority.generationID.rawValue),
                    .text(activeAuthority.authorityManifestDigest),
                    .text(activeAuthority.selectorFileSHA256),
                    .text(activeAuthority.activationIntentID),
                    .text(activeAuthority.activationConsumptionDigest),
                    activeAuthority.priorGenerationID.map { .text($0.rawValue) } ?? .null,
                    activeAuthority.priorGenerationDigest.map(SQLiteBinding.text) ?? .null,
                    .integer(activeAuthority.activatedAtMilliseconds),
                    .text(activeAuthority.authorityDigest),
                    .blob(activePayload),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: activePayload)),
                ]
            )
            guard activeUpdate.changedRowCount == 1 else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }

            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_candidate_preparation_dispositions",
                idColumn: "preparation_id",
                id: candidateDisposition.preparationID,
                columns: [
                    ("operation_lease_id", .text(candidateDisposition.operationLeaseID)),
                    ("operation_fencing_token", .integer(candidateDisposition.operationFencingToken)),
                    ("kind", .text(candidateDisposition.kind.rawValue)),
                    ("failure_classification", candidateDisposition.failureClassification.map { .text($0.rawValue) } ?? .null),
                    ("authority_digest", .text(candidateDisposition.authorityDigest)),
                    ("disposed_at_ms", .integer(candidateDisposition.disposedAtMilliseconds)),
                    ("disposition_digest", .text(candidateDisposition.dispositionDigest)),
                ],
                payload: dispositionPayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: dispositionPayload)
            )

            if let recoveryConsumption, let recoveryPayload {
                let authorization = try Self.loadPayload(
                    RuntimeGenerationRecoveryAuthorization.self,
                    table: "runtime_generation_recovery_authorizations",
                    idColumn: "authorization_id",
                    id: recoveryConsumption.authorizationID,
                    database: database
                )
                let committedPlans = try database.query(
                    "SELECT * FROM runtime_generation_restore_baselines WHERE plan_digest = ? LIMIT 2",
                    bindings: [.text(recoveryConsumption.resultDigest)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard committedPlans.count == 1 else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let committedPlan = try Self.decodePayload(
                    RuntimeGenerationRestoreBaselinePlan.self,
                    row: committedPlans[0]
                )
                guard authorization.action == recoveryConsumption.action,
                      authorization.targetDigest == recoveryConsumption.targetDigest,
                      durableRun.recoveryAuthorizationID == authorization.authorizationID,
                      durableRun.recoveryAuthorizationDigest == authorization.authorizationDigest,
                      committedPlan.targetGenerationID ==
                        observedIntent.candidateGenerationID,
                      committedPlan.recoveryAuthorizationID == authorization.authorizationID,
                      committedPlan.recoveryAuthorizationDigest ==
                        authorization.authorizationDigest,
                      recoveryConsumption.resultDigest == committedPlan.planDigest,
                      recoveryConsumption.consumedAtMilliseconds == nowMilliseconds,
                      nowMilliseconds >= authorization.authorizedAtMilliseconds else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let witness = try Self.loadPayload(
                    RuntimeGenerationRecoveryPrecommitWitness.self,
                    table: "runtime_generation_recovery_precommit_witnesses",
                    idColumn: "witness_id",
                    id: observedIntent.intentID,
                    database: database
                )
                guard witness.activationIntentID == observedIntent.intentID,
                      witness.migrationRunID == durableRun.migrationRunID,
                      witness.candidateGenerationID == observedIntent.candidateGenerationID,
                      witness.candidateSelectorFileSHA256 ==
                        observedIntent.candidateSelectorFileSHA256,
                      witness.recoveryAuthorizationID == authorization.authorizationID,
                      witness.recoveryAuthorizationDigest == authorization.authorizationDigest,
                      witness.recoveryTargetDigest == authorization.targetDigest,
                      witness.resultDigest == committedPlan.planDigest,
                      witness.observedAtMilliseconds >= authorization.authorizedAtMilliseconds,
                      witness.observedAtMilliseconds < authorization.expiresAtMilliseconds,
                      authorization.expiresAtMilliseconds - witness.observedAtMilliseconds >=
                        witness.minimumRemainingValidityMilliseconds else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let existing = try database.query(
                    "SELECT * FROM runtime_generation_recovery_authorization_consumptions WHERE authorization_id = ? LIMIT 2",
                    bindings: [.text(recoveryConsumption.authorizationID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                if let row = existing.first {
                    guard existing.count == 1,
                          try Self.decodePayload(
                            RuntimeGenerationRecoveryAuthorizationConsumption.self,
                            row: row
                          ) == recoveryConsumption else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                } else {
                    try Self.executeImmutableInsert(
                        database: database,
                        table: "runtime_generation_recovery_authorization_consumptions",
                        idColumn: "authorization_id",
                        id: recoveryConsumption.authorizationID,
                        columns: [
                            ("action", .text(recoveryConsumption.action.rawValue)),
                            ("target_digest", .text(recoveryConsumption.targetDigest)),
                            ("result_digest", .text(recoveryConsumption.resultDigest)),
                            ("consumed_at_ms", .integer(recoveryConsumption.consumedAtMilliseconds)),
                            ("consumption_digest", .text(recoveryConsumption.consumptionDigest)),
                        ],
                        payload: recoveryPayload,
                        payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: recoveryPayload)
                    )
                }
            }
        }
    }

    func recordRestoreBaselinePlan(
        _ record: RuntimeGenerationRestoreBaselinePlan
    ) async throws {
        try record.validate()
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_restore_baselines"],
                reading: [
                    "runtime_generation_records",
                    "runtime_generation_backups",
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_completions",
                    "runtime_generation_backup_preparation_consumptions",
                    "runtime_generation_operation_leases",
                    "runtime_generation_verifications",
                    "runtime_generation_migration_runs",
                    "runtime_generation_recovery_authorizations",
                    "runtime_generation_rollbacks",
                    "runtime_generation_restore_baselines",
                ]
            )
        ) { database in
            let source = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.sourceGenerationID.rawValue,
                database: database
            )
            let safetyBackup = try Self.loadEligibleBackup(
                id: record.sourceSafetyBackupID,
                database: database
            )
            let target = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.targetGenerationID.rawValue,
                database: database
            )
            let verification = try Self.loadPayload(
                RuntimeGenerationVerificationReport.self,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: record.targetVerificationID,
                database: database
            )
            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: target.authorityManifest.migrationRunID,
                database: database
            )
            let authorization = try Self.loadPayload(
                RuntimeGenerationRecoveryAuthorization.self,
                table: "runtime_generation_recovery_authorizations",
                idColumn: "authorization_id",
                id: record.recoveryAuthorizationID,
                database: database
            )
            guard let restorationBackupID = run.backupID else {
                throw RuntimeGenerationControlError.rollbackUnsafe
            }
            let restorationBackup = try Self.loadEligibleBackup(
                id: restorationBackupID,
                database: database
            )
            let recoveryTargetMatches: Bool
            if run.operationKind == .restore {
                recoveryTargetMatches =
                    authorization.action == .restoreVerifiedBackup &&
                    authorization.targetDigest == restorationBackup.backupDigest
            } else if run.operationKind == .rollback {
                let rollbackRows = try database.query(
                    "SELECT * FROM runtime_generation_rollbacks WHERE rollback_digest = ? LIMIT 2",
                    bindings: [.text(authorization.targetDigest)],
                    maximumDecodedBytes: maximumControlReadBytes
                )
                guard rollbackRows.count == 1 else {
                    throw RuntimeGenerationControlError.rollbackUnsafe
                }
                let rollback = try Self.decodePayload(
                    RuntimeGenerationRollbackRecord.self,
                    row: rollbackRows[0]
                )
                let priorPlan = try Self.loadPayload(
                    RuntimeGenerationRestoreBaselinePlan.self,
                    table: "runtime_generation_restore_baselines",
                    idColumn: "plan_id",
                    id: rollback.restoreBaselinePlanID,
                    database: database
                )
                recoveryTargetMatches =
                    authorization.action == .rollbackToSafetyBackup &&
                    rollback.targetGenerationID == record.sourceGenerationID &&
                    rollback.targetObservedFence == safetyBackup.sourceFence &&
                    priorPlan.sourceSafetyBackupID == restorationBackup.backupID
            } else {
                recoveryTargetMatches = false
            }
            guard source.authorityManifest.manifestDigest == record.sourceGenerationDigest,
                  safetyBackup.sourceGenerationID == record.sourceGenerationID,
                  safetyBackup.sourceGenerationDigest == record.sourceGenerationDigest,
                  safetyBackup.sourceFence.fenceDigest == record.sourceSafetyFenceDigest,
                  target.authorityManifest.sourceGenerationID == record.sourceGenerationID,
                  target.authorityManifest.sourceGenerationDigest == record.sourceGenerationDigest,
                  target.authorityManifest.sourceFence == safetyBackup.sourceFence,
                  target.authorityManifest.activationBaseline.baselineDigest ==
                    record.targetActivationBaselineDigest,
                  verification.candidateGenerationID == record.targetGenerationID,
                  verification.verificationID == record.targetVerificationID,
                  verification.hasCompleteEvidence,
                  (run.operationKind == .restore || run.operationKind == .rollback),
                  run.sourceSafetyBackupID == record.sourceSafetyBackupID,
                  run.recoveryAuthorizationID == record.recoveryAuthorizationID,
                  run.recoveryAuthorizationDigest == record.recoveryAuthorizationDigest,
                  recoveryTargetMatches,
                  authorization.authorizationDigest == record.recoveryAuthorizationDigest,
                  record.preparedAtMilliseconds >= verification.verifiedAtMilliseconds,
                  record.preparedAtMilliseconds < authorization.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.rollbackUnsafe
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_restore_baselines",
                idColumn: "plan_id",
                id: record.planID,
                columns: [
                    ("source_generation_id", .text(record.sourceGenerationID.rawValue)),
                    ("source_generation_digest", .text(record.sourceGenerationDigest)),
                    ("source_safety_backup_id", .text(record.sourceSafetyBackupID)),
                    ("source_safety_fence_digest", .text(record.sourceSafetyFenceDigest)),
                    ("target_generation_id", .text(record.targetGenerationID.rawValue)),
                    ("target_verification_id", .text(record.targetVerificationID)),
                    ("target_activation_baseline_digest", .text(record.targetActivationBaselineDigest)),
                    ("recovery_authorization_id", .text(record.recoveryAuthorizationID)),
                    ("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest)),
                    ("prepared_at_ms", .integer(record.preparedAtMilliseconds)),
                    ("plan_digest", .text(record.planDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordRollback(_ record: RuntimeGenerationRollbackRecord) async throws {
        try validateRollback(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_rollbacks"],
                reading: [
                    "runtime_generation_records",
                    "runtime_generation_verifications",
                    "runtime_generation_migration_runs",
                    "runtime_generation_restore_baselines",
                    "runtime_generation_backups",
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_completions",
                    "runtime_generation_backup_preparation_consumptions",
                    "runtime_generation_operation_leases",
                    "runtime_generation_rollbacks",
                ]
            )
        ) { database in
            let target = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.targetGenerationID.rawValue,
                database: database
            )
            let verification = try Self.loadPayload(
                RuntimeGenerationVerificationReport.self,
                table: "runtime_generation_verifications",
                idColumn: "verification_id",
                id: record.targetVerificationID,
                database: database
            )
            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: target.authorityManifest.migrationRunID,
                database: database
            )
            guard (run.operationKind == .restore || run.operationKind == .rollback),
                  let safetyBackupID = run.sourceSafetyBackupID else {
                throw RuntimeGenerationControlError.rollbackUnsafe
            }
            let plan = try Self.loadPayload(
                RuntimeGenerationRestoreBaselinePlan.self,
                table: "runtime_generation_restore_baselines",
                idColumn: "plan_id",
                id: record.restoreBaselinePlanID,
                database: database
            )
            let safetyBackup = try Self.loadEligibleBackup(
                id: safetyBackupID,
                database: database
            )
            let baseline = target.authorityManifest.activationBaseline.revisionFence
            let observed = record.targetObservedFence
            guard verification.candidateGenerationID == record.targetGenerationID,
                  verification.candidateAuthorityManifestDigest ==
                    target.authorityManifest.manifestDigest,
                  verification.hasCompleteEvidence,
                  plan.sourceGenerationID == record.sourceGenerationID,
                  plan.sourceSafetyBackupID == safetyBackupID,
                  plan.sourceSafetyFenceDigest == record.sourceSafetyFenceDigest,
                  safetyBackup.sourceFence.fenceDigest == record.sourceSafetyFenceDigest,
                  plan.targetGenerationID == record.targetGenerationID,
                  plan.targetVerificationID == record.targetVerificationID,
                  plan.targetActivationBaselineDigest ==
                    target.authorityManifest.activationBaseline.baselineDigest,
                  target.authorityManifest.sourceFence == safetyBackup.sourceFence,
                  observed.generationDigest == target.authorityManifest.manifestDigest,
                  observed.eventSequence == baseline.eventSequence,
                  observed.eventID == baseline.eventID,
                  observed.eventHash == baseline.eventHash,
                  observed.commandCount == baseline.commandCount,
                  observed.receiptCount == baseline.receiptCount,
                  observed.externalOperationStatusVersionSum ==
                    baseline.externalOperationStatusVersionSum,
                  observed.attachmentLifecycleVersionSum ==
                    baseline.attachmentLifecycleVersionSum,
                  observed.canonicalStateDigest == baseline.canonicalStateDigest,
                  observed.receiptAuthorityDigest == baseline.receiptAuthorityDigest,
                  observed.externalOperationAuthorityDigest ==
                    baseline.externalOperationAuthorityDigest,
                  observed.attachmentAuthorityDigest == baseline.attachmentAuthorityDigest,
                  record.postActivationEventCount == 0,
                  record.postActivationCommandCount == 0,
                  record.postActivationReceiptCount == 0,
                  record.postActivationExternalEffectCount == 0,
                  record.postActivationAttachmentLifecycleCount == 0,
                  record.activatedAtMilliseconds >= verification.verifiedAtMilliseconds else {
                throw RuntimeGenerationControlError.rollbackUnsafe
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_rollbacks",
                idColumn: "rollback_id",
                id: record.rollbackID,
                columns: [
                ("restore_baseline_plan_id", .text(record.restoreBaselinePlanID)),
                ("source_generation_id", .text(record.sourceGenerationID.rawValue)),
                ("source_safety_fence_digest", .text(record.sourceSafetyFenceDigest)),
                ("target_generation_id", .text(record.targetGenerationID.rawValue)),
                ("target_verification_id", .text(record.targetVerificationID)),
                ("target_observed_fence_digest", .text(record.targetObservedFence.fenceDigest)),
                ("post_activation_event_count", .integer(record.postActivationEventCount)),
                ("post_activation_command_count", .integer(record.postActivationCommandCount)),
                ("post_activation_receipt_count", .integer(record.postActivationReceiptCount)),
                ("post_activation_external_effect_count", .integer(record.postActivationExternalEffectCount)),
                ("post_activation_attachment_lifecycle_count", .integer(
                    record.postActivationAttachmentLifecycleCount
                )),
                ("activated_at_ms", .integer(record.activatedAtMilliseconds)),
                ("rollback_digest", .text(record.rollbackDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func recordQuarantine(_ record: RuntimeGenerationQuarantineRecord) async throws {
        try validateQuarantine(record)
        try await insertImmutable(
            table: "runtime_generation_quarantines",
            idColumn: "quarantine_id",
            id: record.quarantineID,
            columns: [
                ("reason", .text(record.reason.rawValue)),
                ("original_generation_id", record.originalGenerationID.map { .text($0.rawValue) } ?? .null),
                ("original_manifest_digest", record.originalManifestDigest.map(SQLiteBinding.text) ?? .null),
                ("diagnostic_fingerprint", .text(record.diagnosticFingerprint)),
                ("quarantined_at_ms", .integer(record.quarantinedAtMilliseconds)),
                ("quarantine_digest", .text(record.quarantineDigest)),
            ],
            payload: record
        )
    }

    /// The sole write boundary that turns a ready-for-certification derived
    /// rebuild into durable, relationally bound control evidence. It is
    /// deliberately independent of selector publication and receipt
    /// consumption: neither can be implied by a derived-state certificate.
    func certifyProjectionRebuild(
        _ request: RuntimeGenerationProjectionRebuildCertificationRequest
    ) async throws -> RuntimeGenerationRebuildRecord {
        let record = request.rebuild
        try validateRebuild(record)
        try RuntimeGenerationControlRecordFactory.validate(request.currentOperationLease)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        return try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_rebuilds"],
                reading: [
                    "runtime_generation_rebuilds",
                    "runtime_generation_migration_runs",
                    "runtime_generation_reservations",
                    "runtime_generation_operation_leases",
                    "runtime_generation_projection_rebuild_lifecycle_transitions",
                    "runtime_generation_recovery_operation_plans",
                    "runtime_generation_recovery_operation_execution_claims",
                    "runtime_generation_recovery_authorizations",
                    "runtime_generation_recovery_operation_execution_receipts",
                    "runtime_generation_recovery_operation_consumptions",
                    "runtime_generation_recovery_operation_plan_dispositions",
                    "runtime_generation_records",
                ]
            )
        ) { database in
            let now = try authorityNowMilliseconds()
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationRebuildRecord.self,
                table: "runtime_generation_rebuilds",
                idColumn: "rebuild_id",
                id: record.rebuildID,
                database: database
            ) {
                guard existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "projection_rebuild_certificate", id: record.rebuildID
                    )
                }
                return existing
            }
            let lineageCollisions = try database.query(
                "SELECT * FROM runtime_generation_rebuilds WHERE migration_run_id = ? OR candidate_generation_id = ? OR ready_transition_digest = ? LIMIT 2",
                bindings: [
                    .text(record.migrationRunID),
                    .text(record.candidateGenerationID.rawValue),
                    .text(record.readyTransitionDigest),
                ],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if let collision = lineageCollisions.first {
                let existing = try Self.decodePayload(
                    RuntimeGenerationRebuildRecord.self, row: collision
                )
                guard lineageCollisions.count == 1, existing == record else {
                    throw RuntimeGenerationControlError.recordConflict(
                        kind: "projection_rebuild_certificate_lineage",
                        id: record.migrationRunID
                    )
                }
                return existing
            }

            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: record.migrationRunID,
                database: database
            )
            let reservation = try Self.loadPayload(
                RuntimeGenerationReservation.self,
                table: "runtime_generation_reservations",
                idColumn: "reservation_id",
                id: run.reservationID,
                database: database
            )
            let plan = try Self.loadPayload(
                RuntimeGenerationRecoveryOperationPlan.self,
                table: "runtime_generation_recovery_operation_plans",
                idColumn: "plan_id",
                id: record.recoveryExecutionPlanID,
                database: database
            )
            let claim = try Self.loadPayload(
                RuntimeGenerationRecoveryOperationExecutionClaim.self,
                table: "runtime_generation_recovery_operation_execution_claims",
                idColumn: "claim_id",
                id: record.recoveryExecutionClaimID,
                database: database
            )
            let authorization = try Self.loadPayload(
                RuntimeGenerationRecoveryAuthorization.self,
                table: "runtime_generation_recovery_authorizations",
                idColumn: "authorization_id",
                id: plan.recoveryAuthorizationID,
                database: database
            )
            _ = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.candidateGenerationID.rawValue,
                database: database
            )
            _ = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: record.sourceGenerationID.rawValue,
                database: database
            )
            let transitionRows = try database.query(
                "SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2",
                bindings: [.text(run.migrationRunID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard transitionRows.count == 1 || transitionRows.count == 2,
                  let latestTransitionRow = transitionRows.first else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let latestTransition = try Self.decodePayload(
                RuntimeGenerationProjectionRebuildLifecycleTransition.self,
                row: latestTransitionRow
            )
            let leaseRows = try database.query(
                "SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch ASC",
                bindings: [.text(reservation.reservationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let leases = try leaseRows.map {
                try Self.decodePayload(RuntimeGenerationOperationLease.self, row: $0)
            }
            let latestClaimRows = try database.query(
                "SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1",
                bindings: [.text(plan.planID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let dispositions = try database.query(
                "SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 1",
                bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let consumptions = try database.query(
                "SELECT plan_id FROM runtime_generation_recovery_operation_consumptions WHERE plan_id = ? LIMIT 1",
                bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let receipts = try database.query(
                "SELECT plan_id FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 1",
                bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard let latestLease = leases.last,
                  let admissionIndex = leases.firstIndex(where: {
                      $0.leaseID == run.operationLeaseID &&
                      $0.leaseEpoch == run.operationLeaseEpoch &&
                      $0.fencingToken == run.operationFencingToken
                  }),
                  latestLease == request.currentOperationLease,
                  latestLease.ownerInstanceID == run.executorInstanceID,
                  latestLease.leaseEpoch >= run.operationLeaseEpoch,
                  latestLease.fencingToken >= run.operationFencingToken,
                  leases[admissionIndex].ownerInstanceID == claim.executorInstanceID,
                  zip(leases.dropFirst(admissionIndex), leases.dropFirst(admissionIndex + 1)).allSatisfy {
                      previous, successor in
                      successor.leaseEpoch == previous.leaseEpoch + 1 &&
                          successor.priorLeaseDigest == previous.leaseDigest &&
                          successor.fencingToken >= previous.fencingToken
                  },
                  latestTransition.migrationRunID == run.migrationRunID,
                  latestTransition.phase == .readyForCertification,
                  latestTransition.transitionDigest == record.readyTransitionDigest,
                  latestTransition.recoveryExecutionPlanID == plan.planID,
                  latestTransition.recoveryExecutionClaimID == claim.claimID,
                  latestTransition.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  run.operationKind == .projectionRebuild,
                  run.reservationID == reservation.reservationID,
                  run.candidateGenerationID == record.candidateGenerationID,
                  run.recoveryExecutionPlanID == plan.planID,
                  run.recoveryExecutionClaimID == claim.claimID,
                  run.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  reservation.operationKind == .projectionRebuild,
                  reservation.candidateGenerationID == record.candidateGenerationID,
                  reservation.sourceGenerationID == record.sourceGenerationID,
                  claim.planID == plan.planID,
                  claim.claimEpoch == record.recoveryExecutionClaimEpoch,
                  latestClaimRows.count == 1,
                  try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestClaimRows[0]) == claim,
                  plan.action == .rebuildDerivedState,
                  authorization.action == .rebuildDerivedState,
                  authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
                  now >= plan.preparedAtMilliseconds,
                  now < plan.expiresAtMilliseconds,
                  now >= authorization.authorizedAtMilliseconds,
                  now < authorization.expiresAtMilliseconds,
                  now >= claim.claimedAtMilliseconds,
                  now < claim.expiresAtMilliseconds,
                  now >= latestLease.issuedAtMilliseconds,
                  now < latestLease.expiresAtMilliseconds,
                  record.publishedAtMilliseconds >= latestTransition.occurredAtMilliseconds,
                  record.publishedAtMilliseconds <= now,
                  dispositions.isEmpty,
                  consumptions.isEmpty,
                  receipts.isEmpty else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_rebuilds",
                idColumn: "rebuild_id",
                id: record.rebuildID,
                columns: [
                    ("migration_run_id", .text(record.migrationRunID)),
                    ("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID)),
                    ("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID)),
                    ("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch)),
                    ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)),
                    ("ready_transition_digest", .text(record.readyTransitionDigest)),
                    ("source_generation_id", .text(record.sourceGenerationID.rawValue)),
                    ("source_fence_digest", .text(record.sourceFenceDigest)),
                    ("equivalence_digest", .text(record.equivalenceDigest)),
                    ("published_at_ms", .integer(record.publishedAtMilliseconds)),
                    ("rebuild_digest", .text(record.rebuildDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
            return record
        }
    }

    /// Persists the projection-rebuild candidate only after the immutable
    /// admission lineage, ready transition, replay audit, exact staged bytes,
    /// rebuild certificate, and preparation durability witness agree. It never
    /// writes a selector, activation intent, consumption, or recovery receipt.
    func commitProjectionRebuildCandidateAuthority(
        _ request: RuntimeGenerationProjectionRebuildCandidateCommitmentRequest
    ) async throws -> RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment {
        let commitment = request.commitment
        try RuntimeGenerationControlRecordFactory.validate(commitment)
        let stagedSelector = try RuntimeGenerationControlRecordFactory
            .projectionRebuildCandidateSelector(commitment)
        try RuntimeGenerationControlRecordFactory.validate(request.currentOperationLease)
        try revalidateAuthority()
        let candidatePayload = try RuntimeGenerationControlCodec.encode(commitment.candidateRecord)
        let completionPayload = try RuntimeGenerationControlCodec.encode(commitment.candidatePreparationCompletion)
        let rebuildPayload = try RuntimeGenerationControlCodec.encode(commitment.rebuild)
        let commitmentPayload = try RuntimeGenerationControlCodec.encode(commitment)
        return try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [
                    "runtime_generation_records",
                    "runtime_generation_candidate_preparation_completions",
                    "runtime_generation_rebuilds",
                    "runtime_generation_projection_rebuild_candidate_authority_commitments",
                ],
                reading: [
                    "runtime_generation_projection_rebuild_candidate_reservations",
                    "runtime_generation_recovery_operation_plans",
                    "runtime_generation_recovery_operation_execution_claims",
                    "runtime_generation_recovery_operation_execution_receipts",
                    "runtime_generation_recovery_operation_consumptions",
                    "runtime_generation_recovery_operation_plan_dispositions",
                    "runtime_generation_recovery_authorizations",
                    "runtime_generation_migration_runs",
                    "runtime_generation_reservations",
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_candidate_preparation_completions",
                    "runtime_generation_candidate_replay_audits",
                    "runtime_generation_projection_rebuild_lifecycle_transitions",
                    "runtime_generation_operation_leases",
                    "runtime_generation_records",
                    "runtime_generation_rebuilds",
                    "runtime_generation_projection_rebuild_candidate_authority_commitments",
                ]
            )
        ) { database in
            let now = try authorityNowMilliseconds()
            if let existing = try Self.loadOptionalPayload(
                RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                table: "runtime_generation_projection_rebuild_candidate_authority_commitments",
                idColumn: "commitment_id", id: commitment.commitmentID, database: database
            ) {
                guard existing == commitment else {
                    throw RuntimeGenerationControlError.recordConflict(kind: "projection_rebuild_candidate_commitment", id: commitment.commitmentID)
                }
                return existing
            }
            let stageOne = try Self.loadPayload(
                RuntimeGenerationProjectionRebuildCandidateReservation.self,
                table: "runtime_generation_projection_rebuild_candidate_reservations",
                idColumn: "candidate_reservation_id", id: commitment.candidateReservationID,
                database: database
            )
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: stageOne.recoveryExecutionPlanID, database: database)
            let claim = try Self.loadPayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: stageOne.recoveryExecutionClaimID, database: database)
            let run = try Self.loadPayload(RuntimeGenerationMigrationRun.self, table: "runtime_generation_migration_runs", idColumn: "migration_run_id", id: stageOne.migrationRunID, database: database)
            let reservation = try Self.loadPayload(RuntimeGenerationReservation.self, table: "runtime_generation_reservations", idColumn: "reservation_id", id: stageOne.reservationID, database: database)
            let preparation = try Self.loadPayload(RuntimeGenerationCandidatePreparationRecord.self, table: "runtime_generation_candidate_preparations", idColumn: "preparation_id", id: stageOne.candidatePreparationID, database: database)
            let audit = try Self.loadPayload(RuntimeGenerationCandidateReplayAuditRecord.self, table: "runtime_generation_candidate_replay_audits", idColumn: "audit_id", id: commitment.replayAuditID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: plan.recoveryAuthorizationID, database: database)
            let source = try Self.loadPayload(RuntimeGenerationCandidateRecord.self, table: "runtime_generation_records", idColumn: "generation_id", id: commitment.rebuild.sourceGenerationID.rawValue, database: database)
            let transitions = try database.query("SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2", bindings: [.text(run.migrationRunID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let leaseRows = try database.query("SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch DESC LIMIT 1", bindings: [.text(reservation.reservationID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let latestClaimRows = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let dispositions = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let consumptions = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_consumptions WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let receipts = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard transitions.count >= 1, let transitionRow = transitions.first,
                  let latestLeaseRow = leaseRows.first,
                  latestClaimRows.count == 1 else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let ready = try Self.decodePayload(RuntimeGenerationProjectionRebuildLifecycleTransition.self, row: transitionRow)
            let latestLease = try Self.decodePayload(RuntimeGenerationOperationLease.self, row: latestLeaseRow)
            let latestClaim = try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestClaimRows[0])
            let candidate = commitment.candidateRecord
            let completion = commitment.candidatePreparationCompletion
            let rebuild = commitment.rebuild
            let manifest = candidate.authorityManifest
            guard stageOne.recoveryExecutionPlanID == commitment.recoveryExecutionPlanID,
                  stageOne.recoveryExecutionClaimID == commitment.recoveryExecutionClaimID,
                  stageOne.recoveryExecutionClaimEpoch == commitment.recoveryExecutionClaimEpoch,
                  stageOne.migrationRunID == commitment.migrationRunID,
                  stageOne.reservationID == commitment.reservationID,
                  stageOne.candidatePreparationID == commitment.candidatePreparationID,
                  stageOne.candidateGenerationID == commitment.candidateGenerationID,
                  stageOne.expectedVerificationID == commitment.expectedVerificationID,
                  stageOne.expectedActivationIntentID == commitment.expectedActivationIntentID,
                  stagedSelector.verificationID == stageOne.expectedVerificationID,
                  stagedSelector.activationIntentID == stageOne.expectedActivationIntentID,
                  stagedSelector.preparedAtMilliseconds == run.completedAtMilliseconds,
                  stagedSelector.preparedAtMilliseconds >= stageOne.reservedAtMilliseconds,
                  stagedSelector.preparedAtMilliseconds <= commitment.committedAtMilliseconds,
                  plan.action == .rebuildDerivedState,
                  authorization.action == .rebuildDerivedState,
                  authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
                  claim.planID == plan.planID,
                  claim.claimEpoch == stageOne.recoveryExecutionClaimEpoch,
                  latestClaim == claim,
                  now >= plan.preparedAtMilliseconds, now < plan.expiresAtMilliseconds,
                  now >= authorization.authorizedAtMilliseconds, now < authorization.expiresAtMilliseconds,
                  now >= claim.claimedAtMilliseconds, now < claim.expiresAtMilliseconds,
                  dispositions.isEmpty, consumptions.isEmpty, receipts.isEmpty,
                  latestLease == request.currentOperationLease,
                  latestLease.ownerInstanceID == claim.executorInstanceID,
                  now >= latestLease.issuedAtMilliseconds, now < latestLease.expiresAtMilliseconds,
                  run.operationKind == .projectionRebuild,
                  run.reservationID == reservation.reservationID,
                  run.candidateGenerationID == stageOne.candidateGenerationID,
                  run.recoveryExecutionPlanID == plan.planID,
                  run.recoveryExecutionClaimID == claim.claimID,
                  run.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  preparation.reservationID == reservation.reservationID,
                  preparation.operationKind == .projectionRebuild,
                  preparation.candidateGenerationID == stageOne.candidateGenerationID,
                  audit.outcome == .complete,
                  audit.preparationID == preparation.preparationID,
                  audit.reservationID == reservation.reservationID,
                  audit.candidateGenerationID == stageOne.candidateGenerationID,
                  audit.operationLeaseID == latestLease.leaseID,
                  audit.operationLeaseEpoch == latestLease.leaseEpoch,
                  audit.operationFencingToken == latestLease.fencingToken,
                  audit.auditDigest == commitment.replayAuditDigest,
                  audit.reconstructionDigest == commitment.replayReconstructionDigest,
                  ready.phase == .readyForCertification,
                  ready.transitionDigest == rebuild.readyTransitionDigest,
                  ready.recoveryExecutionPlanID == plan.planID,
                  ready.recoveryExecutionClaimID == claim.claimID,
                  ready.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  manifest.generationID == stageOne.candidateGenerationID,
                  manifest.reservationID == reservation.reservationID,
                  manifest.migrationRunID == run.migrationRunID,
                  manifest.operationKind == .projectionRebuild,
                  candidate.recordDigest == completion.candidateRecordDigest,
                  completion.preparationID == preparation.preparationID,
                  completion.completedAtMilliseconds >= latestLease.issuedAtMilliseconds,
                  completion.completedAtMilliseconds < latestLease.expiresAtMilliseconds,
                  rebuild.migrationRunID == run.migrationRunID,
                  rebuild.candidateGenerationID == manifest.generationID,
                  rebuild.sourceGenerationID == reservation.sourceGenerationID,
                  rebuild.recoveryExecutionPlanID == plan.planID,
                  rebuild.recoveryExecutionClaimID == claim.claimID,
                  rebuild.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  rebuild.publishedAtMilliseconds >= ready.occurredAtMilliseconds,
                  rebuild.publishedAtMilliseconds <= now,
                  source.authorityManifest.generationID == rebuild.sourceGenerationID,
                  commitment.committedAtMilliseconds >= rebuild.publishedAtMilliseconds,
                  commitment.committedAtMilliseconds <= now else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let existingCandidate = try Self.loadOptionalPayload(RuntimeGenerationCandidateRecord.self, table: "runtime_generation_records", idColumn: "generation_id", id: manifest.generationID.rawValue, database: database)
            let existingCompletion = try Self.loadOptionalPayload(RuntimeGenerationCandidatePreparationCompletion.self, table: "runtime_generation_candidate_preparation_completions", idColumn: "preparation_id", id: preparation.preparationID, database: database)
            let existingRebuild = try Self.loadOptionalPayload(RuntimeGenerationRebuildRecord.self, table: "runtime_generation_rebuilds", idColumn: "rebuild_id", id: rebuild.rebuildID, database: database)
            guard existingCandidate == nil, existingCompletion == nil, existingRebuild == nil else {
                throw RuntimeGenerationControlError.recordConflict(kind: "projection_rebuild_candidate_commitment_lineage", id: stageOne.candidateReservationID)
            }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_records", idColumn: "generation_id", id: manifest.generationID.rawValue, columns: [("schema_version", .integer(Int64(manifest.schemaVersion))), ("manifest_digest", .text(manifest.manifestDigest)), ("authority_manifest_file_sha256", .text(candidate.authorityManifestFileSHA256)), ("selector_file_sha256", .text(candidate.selectorFileSHA256)), ("record_digest", .text(candidate.recordDigest)), ("reservation_id", .text(manifest.reservationID)), ("migration_run_id", .text(manifest.migrationRunID)), ("source_generation_id", manifest.sourceGenerationID.map { .text($0.rawValue) } ?? .null), ("retention_class", .text(manifest.retentionClass.rawValue)), ("created_at_ms", .integer(manifest.createdAtMilliseconds))], payload: candidatePayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: candidatePayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_candidate_preparation_completions", idColumn: "preparation_id", id: completion.preparationID, columns: [("candidate_record_digest", .text(completion.candidateRecordDigest)), ("directory_device", .integer(Int64(bitPattern: completion.directoryDevice))), ("directory_inode", .integer(Int64(bitPattern: completion.directoryInode))), ("interior_artifact_count", .integer(completion.interiorArtifactCount)), ("interior_byte_count", .integer(completion.interiorByteCount)), ("interior_inventory_digest", .text(completion.interiorInventoryDigest)), ("durability_witness_digest", .text(completion.durabilityWitnessDigest)), ("completed_at_ms", .integer(completion.completedAtMilliseconds)), ("completion_digest", .text(completion.completionDigest))], payload: completionPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: completionPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_rebuilds", idColumn: "rebuild_id", id: rebuild.rebuildID, columns: [("migration_run_id", .text(rebuild.migrationRunID)), ("recovery_execution_plan_id", .text(rebuild.recoveryExecutionPlanID)), ("recovery_execution_claim_id", .text(rebuild.recoveryExecutionClaimID)), ("recovery_execution_claim_epoch", .integer(rebuild.recoveryExecutionClaimEpoch)), ("candidate_generation_id", .text(rebuild.candidateGenerationID.rawValue)), ("ready_transition_digest", .text(rebuild.readyTransitionDigest)), ("source_generation_id", .text(rebuild.sourceGenerationID.rawValue)), ("source_fence_digest", .text(rebuild.sourceFenceDigest)), ("equivalence_digest", .text(rebuild.equivalenceDigest)), ("published_at_ms", .integer(rebuild.publishedAtMilliseconds)), ("rebuild_digest", .text(rebuild.rebuildDigest))], payload: rebuildPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: rebuildPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_projection_rebuild_candidate_authority_commitments", idColumn: "commitment_id", id: commitment.commitmentID, columns: [("candidate_reservation_id", .text(stageOne.candidateReservationID)), ("recovery_execution_plan_id", .text(plan.planID)), ("recovery_execution_claim_id", .text(claim.claimID)), ("recovery_execution_claim_epoch", .integer(claim.claimEpoch)), ("migration_run_id", .text(run.migrationRunID)), ("reservation_id", .text(reservation.reservationID)), ("candidate_preparation_id", .text(preparation.preparationID)), ("candidate_generation_id", .text(manifest.generationID.rawValue)), ("expected_verification_id", .text(stageOne.expectedVerificationID)), ("expected_activation_intent_id", .text(stageOne.expectedActivationIntentID)), ("candidate_record_digest", .text(candidate.recordDigest)), ("candidate_preparation_completion_digest", .text(completion.completionDigest)), ("authority_manifest_digest", .text(manifest.manifestDigest)), ("authority_manifest_file_sha256", .text(candidate.authorityManifestFileSHA256)), ("authority_manifest_bytes_sha256", .text(commitment.authorityManifestBytesSHA256)), ("authority_manifest_byte_count", .integer(Int64(commitment.authorityManifestBytes.count))), ("selector_file_sha256", .text(candidate.selectorFileSHA256)), ("selector_bytes_sha256", .text(commitment.selectorBytesSHA256)), ("selector_byte_count", .integer(Int64(commitment.selectorBytes.count))), ("replay_audit_id", .text(audit.auditID)), ("replay_audit_digest", .text(audit.auditDigest)), ("replay_reconstruction_digest", .text(commitment.replayReconstructionDigest)), ("rebuild_id", .text(rebuild.rebuildID)), ("rebuild_digest", .text(rebuild.rebuildDigest)), ("equivalence_digest", .text(rebuild.equivalenceDigest)), ("committed_at_ms", .integer(commitment.committedAtMilliseconds)), ("commitment_digest", .text(commitment.commitmentDigest))], payload: commitmentPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: commitmentPayload))
            return commitment
        }
    }

    func recordRetentionTransition(
        _ record: RuntimeGenerationRetentionTransition
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        // The general API is deliberately non-destructive. Active demotion is
        // legal only inside finalizeCommittedActivation, atomically with the
        // replacement singleton and selector consumption. Pruning/quarantine
        // requires a separate durable authorization workflow.
        guard record.fromClass == .staged,
              record.toClass == .freshConnectionVerified else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try revalidateAuthority()
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_retention_transitions"],
                reading: [
                    "runtime_generation_records",
                    "runtime_generation_retention_transitions",
                ]
            )
        ) { database in
            try Self.insertRetentionTransition(record, database: database)
        }
    }

    func currentRetentionClass(
        generationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationRetentionClass {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let candidate = try Self.loadPayload(
                RuntimeGenerationCandidateRecord.self,
                table: "runtime_generation_records",
                idColumn: "generation_id",
                id: generationID.rawValue,
                database: database
            )
            let rows = try database.query(
                "SELECT * FROM runtime_generation_retention_transitions WHERE generation_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2",
                bindings: [.text(generationID.rawValue)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                // LIMIT 2 intentionally makes an equal timestamp/identity
                // ambiguity visible instead of silently choosing a winner.
                let first = try Self.decodePayload(
                    RuntimeGenerationRetentionTransition.self,
                    row: rows[0]
                )
                let second = try Self.decodePayload(
                    RuntimeGenerationRetentionTransition.self,
                    row: rows[1]
                )
                guard first.occurredAtMilliseconds > second.occurredAtMilliseconds
                    || first.transitionID > second.transitionID else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "retention_transition",
                        id: generationID.rawValue
                    )
                }
                return first.toClass
            }
            if let row = rows.first {
                return try Self.decodePayload(
                    RuntimeGenerationRetentionTransition.self,
                    row: row
                ).toClass
            }
            return candidate.authorityManifest.retentionClass
        }
    }

    func activeAuthority() async throws -> RuntimeGenerationActiveAuthority? {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT * FROM runtime_generation_active_authority WHERE singleton_id = 1 LIMIT 2",
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "active_authority", id: "1"
            )
        }
        return try rows.first.map {
            let authority = try Self.decodePayload(
                RuntimeGenerationActiveAuthority.self, row: $0
            )
            try RuntimeGenerationControlRecordFactory.validate(authority)
            return authority
        }
    }

    func recordImportSourceAndInitialCheckpoint(
        source: RuntimeLegacyImportSource,
        checkpoint: RuntimeLegacyImportCheckpoint
    ) async throws {
        try validateImportSource(source)
        try RuntimeGenerationControlRecordFactory.validate(checkpoint)
        guard checkpoint.importID == source.importID,
              checkpoint.sequence == 0,
              checkpoint.phase == .sourcePreserved,
              checkpoint.priorCheckpointDigest == nil,
              checkpoint.sourceArtifactSHA256 == source.sourceArtifact.sha256,
              checkpoint.artifactSetDigest == source.sourceArtifact.sha256,
              checkpoint.processedItemCount == 0,
              checkpoint.lastSourceRecordID == nil,
              checkpoint.evidence == .sourcePreserved(
                sourceDigest: source.sourceDigest
              ) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try revalidateAuthority()
        let sourcePayload = try RuntimeGenerationControlCodec.encode(source)
        let checkpointPayload = try RuntimeGenerationControlCodec.encode(checkpoint)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [
                    "runtime_generation_imports",
                    "runtime_generation_import_checkpoints",
                ],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_checkpoints",
                ]
            )
        ) { database in
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_imports",
                idColumn: "import_id",
                id: source.importID,
                columns: [
                    ("source_kind", .text(source.sourceKind.rawValue)),
                    ("source_identity_digest", .text(source.sourceIdentityDigest)),
                    ("source_schema", .text(source.sourceSchema)),
                    ("source_digest", .text(source.sourceDigest)),
                    ("discovered_at_ms", .integer(source.discoveredAtMilliseconds)),
                ],
                payload: sourcePayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: sourcePayload)
            )
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_checkpoints",
                idColumn: "checkpoint_id",
                id: checkpoint.checkpointID,
                columns: [
                    ("import_id", .text(checkpoint.importID)),
                    ("sequence", .integer(0)),
                    ("phase", .text(checkpoint.phase.rawValue)),
                    ("prior_checkpoint_digest", .null),
                    ("artifact_set_digest", .text(checkpoint.artifactSetDigest)),
                    ("processed_item_count", .integer(0)),
                    ("checkpoint_digest", .text(checkpoint.checkpointDigest)),
                ],
                payload: checkpointPayload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: checkpointPayload
                )
            )
        }
    }

    func importSourcesPage(
        afterImportID: String?,
        limit: Int
    ) async throws -> [RuntimeLegacyImportSource] {
        guard limit > 0, limit <= RuntimeGenerationLegacyImportService.pageSize else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                """
                SELECT * FROM runtime_generation_imports
                WHERE (? IS NULL OR import_id > ?)
                ORDER BY import_id LIMIT ?
                """,
                bindings: [
                    afterImportID.map(SQLiteBinding.text) ?? .null,
                    afterImportID.map(SQLiteBinding.text) ?? .null,
                    .integer(Int64(limit)),
                ],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            return try rows.map {
                try Self.decodePayload(RuntimeLegacyImportSource.self, row: $0)
            }
        }
    }

    func recordImportOrphanQuarantine(
        _ record: RuntimeLegacyImportOrphanQuarantine
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_orphan_quarantines"],
                reading: [
                    "runtime_generation_import_orphan_quarantine_plans",
                    "runtime_generation_import_orphan_quarantines",
                ]
            )
        ) { database in
            let plan = try Self.loadPayload(
                RuntimeLegacyImportOrphanQuarantinePlan.self,
                table: "runtime_generation_import_orphan_quarantine_plans",
                idColumn: "quarantine_id",
                id: record.quarantineID,
                database: database
            )
            guard plan.originalEntryName == record.originalEntryName,
                  plan.originalEntryIdentity == record.originalEntryIdentity,
                  plan.destinationEntryName == record.preservedRelativePath,
                  record.fileCount <= plan.maximumInventoryFileCount,
                  record.totalByteCount <= plan.maximumInventoryByteCount,
                  record.quarantinedAtMilliseconds >= plan.plannedAtMilliseconds else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_orphan_quarantines",
                idColumn: "quarantine_id",
                id: record.quarantineID,
                columns: [
                    ("original_entry_name", .text(record.originalEntryName)),
                    ("preserved_relative_path", .text(record.preservedRelativePath)),
                    ("inventory_digest", .text(record.inventoryDigest)),
                    ("file_count", .integer(Int64(record.fileCount))),
                    ("total_byte_count", .integer(record.totalByteCount)),
                    ("quarantine_digest", .text(record.quarantineDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordImportOrphanQuarantinePlan(
        _ record: RuntimeLegacyImportOrphanQuarantinePlan
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try await insertImmutable(
            table: "runtime_generation_import_orphan_quarantine_plans",
            idColumn: "quarantine_id",
            id: record.quarantineID,
            columns: [
                ("original_entry_name", .text(record.originalEntryName)),
                ("destination_entry_name", .text(record.destinationEntryName)),
                ("planned_at_ms", .integer(record.plannedAtMilliseconds)),
                ("plan_digest", .text(record.planDigest)),
            ],
            payload: record
        )
    }

    func importOrphanQuarantinePlansPage(
        afterQuarantineID: String?,
        limit: Int
    ) async throws -> [RuntimeLegacyImportOrphanQuarantinePlan] {
        guard limit > 0, limit <= RuntimeGenerationLegacyImportService.pageSize else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try revalidateAuthority()
        let rows = try await database.query(
            """
            SELECT plan.*
            FROM runtime_generation_import_orphan_quarantine_plans AS plan
            LEFT JOIN runtime_generation_import_orphan_quarantines AS completed
              ON completed.quarantine_id = plan.quarantine_id
            WHERE completed.quarantine_id IS NULL
              AND (? IS NULL OR plan.quarantine_id > ?)
            ORDER BY plan.quarantine_id LIMIT ?
            """,
            bindings: [
                afterQuarantineID.map(SQLiteBinding.text) ?? .null,
                afterQuarantineID.map(SQLiteBinding.text) ?? .null,
                .integer(Int64(limit)),
            ],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        return try rows.map {
            try Self.decodePayload(RuntimeLegacyImportOrphanQuarantinePlan.self, row: $0)
        }
    }

    func importOrphanQuarantine(
        id: String
    ) async throws -> RuntimeLegacyImportOrphanQuarantine? {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT * FROM runtime_generation_import_orphan_quarantines WHERE quarantine_id = ? LIMIT 2",
            bindings: [.text(id)],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "import_orphan_quarantine",
                id: id
            )
        }
        return try rows.first.map {
            try Self.decodePayload(RuntimeLegacyImportOrphanQuarantine.self, row: $0)
        }
    }

    func importSource(
        identityDigest: String,
        schema: String
    ) async throws -> RuntimeLegacyImportSource? {
        try RuntimeGenerationControlValidation.requireDigest(
            identityDigest, field: "source_identity_digest"
        )
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_imports WHERE source_identity_digest = ? AND source_schema = ? LIMIT 2",
                bindings: [.text(identityDigest), .text(schema)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "import_source_identity", id: identityDigest
                )
            }
            return try rows.first.map {
                try Self.decodePayload(RuntimeLegacyImportSource.self, row: $0)
            }
        }
    }

    func importSource(importID: String) async throws -> RuntimeLegacyImportSource? {
        try RuntimeGenerationControlValidation.requireIdentifier(importID, field: "import_id")
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT * FROM runtime_generation_imports WHERE import_id = ? LIMIT 2",
            bindings: [.text(importID)],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "import_source", id: importID
            )
        }
        return try rows.first.map {
            try Self.decodePayload(RuntimeLegacyImportSource.self, row: $0)
        }
    }

    func recordImportCheckpoint(_ record: RuntimeLegacyImportCheckpoint) async throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        var readTables: Set<String> = [
            "runtime_generation_imports",
            "runtime_generation_import_checkpoints",
        ]
        switch record.evidence {
        case .sourcePreserved, .decoding, .abandoned:
            break
        case .mapped:
            readTables.insert("runtime_generation_import_manifests")
        case .reviewPlanned:
            readTables.insert("runtime_generation_import_disposition_intents")
        case .reviewAuthorized:
            readTables.insert("runtime_generation_import_review_authorizations")
        case .reviewConsumed:
            readTables.formUnion([
                "runtime_generation_import_reviews",
                "runtime_generation_import_review_authorization_consumptions",
                "runtime_generation_import_review_authorizations",
            ])
        case .completedNoActivation:
            readTables.formUnion([
                "runtime_generation_import_reviews",
                "runtime_generation_import_review_authorization_consumptions",
                "runtime_generation_import_review_authorizations",
                "runtime_generation_import_disposition_intents",
            ])
        case .quarantined:
            readTables.insert("runtime_generation_quarantines")
        }
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_checkpoints"],
                reading: readTables
            )
        ) { database in
            let source = try Self.loadPayload(
                RuntimeLegacyImportSource.self, table: "runtime_generation_imports",
                idColumn: "import_id", id: record.importID, database: database
            )
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_checkpoints WHERE import_id = ? ORDER BY sequence DESC LIMIT 1",
                bindings: [.text(record.importID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let prior = try rows.first.map {
                try Self.decodePayload(RuntimeLegacyImportCheckpoint.self, row: $0)
            }
            let expectedSequence: Int
            if let prior {
                let increment = prior.sequence.addingReportingOverflow(1)
                guard increment.overflow == false,
                      Self.isLegalImportTransition(from: prior.phase, to: record.phase),
                      Self.hasLegalImportProgress(from: prior, to: record),
                      record.occurredAtMilliseconds >= prior.occurredAtMilliseconds else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                expectedSequence = increment.partialValue
            } else {
                guard record.phase == .sourcePreserved else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                expectedSequence = 0
            }
            guard source.sourceArtifact.sha256 == record.sourceArtifactSHA256,
                  record.sequence == expectedSequence,
                  record.priorCheckpointDigest == prior?.checkpointDigest else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try Self.requireImportCheckpointEvidenceBindings(
                record, source: source, database: database
            )
            try Self.executeImmutableInsert(
                database: database, table: "runtime_generation_import_checkpoints",
                idColumn: "checkpoint_id", id: record.checkpointID,
                columns: [
                    ("import_id", .text(record.importID)),
                    ("sequence", .integer(Int64(record.sequence))),
                    ("phase", .text(record.phase.rawValue)),
                    ("prior_checkpoint_digest", record.priorCheckpointDigest.map(SQLiteBinding.text) ?? .null),
                    ("artifact_set_digest", .text(record.artifactSetDigest)),
                    ("processed_item_count", .integer(Int64(record.processedItemCount))),
                    ("checkpoint_digest", .text(record.checkpointDigest)),
                ], payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    nonisolated static func isLegalImportTransition(
        from: RuntimeLegacyImportPhase,
        to: RuntimeLegacyImportPhase
    ) -> Bool {
        switch (from, to) {
        case (.sourcePreserved, .decoding), (.decoding, .decoding),
             (.decoding, .mapped), (.mapped, .reviewPlanned),
             (.reviewPlanned, .reviewAuthorized),
             (.reviewAuthorized, .reviewAuthorized),
             (.reviewAuthorized, .reviewConsumed),
             (.reviewConsumed, .completedNoActivation):
            return true
        case (_, .abandoned), (_, .quarantined):
            return from != .completedNoActivation &&
                from != .abandoned && from != .quarantined
        default:
            return false
        }
    }

    nonisolated static func hasLegalImportProgress(
        from prior: RuntimeLegacyImportCheckpoint,
        to next: RuntimeLegacyImportCheckpoint
    ) -> Bool {
        guard next.processedItemCount >= prior.processedItemCount else { return false }
        switch (prior.phase, next.phase) {
        case (.decoding, .decoding):
            return next.processedItemCount > prior.processedItemCount &&
                next.lastSourceRecordID != prior.lastSourceRecordID &&
                next.occurredAtMilliseconds > prior.occurredAtMilliseconds
        case (.reviewAuthorized, .reviewAuthorized):
            return next.evidence != prior.evidence &&
                next.occurredAtMilliseconds > prior.occurredAtMilliseconds
        default:
            return true
        }
    }

    static func requireImportCheckpointEvidenceBindings(
        _ record: RuntimeLegacyImportCheckpoint,
        source: RuntimeLegacyImportSource,
        database: isolated SQLiteDatabase
    ) throws {
        let prior: RuntimeLegacyImportCheckpoint?
        if let priorDigest = record.priorCheckpointDigest {
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_checkpoints WHERE checkpoint_digest = ? LIMIT 2",
                bindings: [.text(priorDigest)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            prior = try decodePayload(RuntimeLegacyImportCheckpoint.self, row: rows[0])
            guard prior?.importID == record.importID else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        } else {
            prior = nil
        }
        switch record.evidence {
        case let .sourcePreserved(sourceDigest):
            guard sourceDigest == source.sourceDigest,
                  record.artifactSetDigest == source.sourceArtifact.sha256,
                  record.processedItemCount == 0,
                  record.lastSourceRecordID == nil else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .decoding(cursorDigest):
            guard cursorDigest == record.lastSourceRecordID.map({
                LocalRuntimeStorageChecksum.sha256Hex(for: $0)
            }),
            (record.processedItemCount == 0) == (record.lastSourceRecordID == nil) else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .mapped(manifestDigest, mappedArtifactSetDigest):
            let manifest = try loadPayload(
                RuntimeLegacyImportManifest.self,
                table: "runtime_generation_import_manifests", idColumn: "import_id",
                id: record.importID, database: database
            )
            guard manifest.manifestDigest == manifestDigest,
                  record.artifactSetDigest == mappedArtifactSetDigest,
                  manifest.itemCount == record.processedItemCount else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .reviewPlanned(digest):
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_disposition_intents WHERE intent_digest = ? LIMIT 2",
                bindings: [.text(digest)], maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let intent = try decodePayload(RuntimeLegacyImportDispositionIntent.self, row: rows[0])
            guard intent.importID == record.importID,
                  intent.itemCount == record.processedItemCount,
                  intent.orderedItemSetDigest == record.artifactSetDigest else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .reviewAuthorized(digest):
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_review_authorizations WHERE authorization_digest = ? LIMIT 2",
                bindings: [.text(digest)], maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let authorization = try decodePayload(
                RuntimeLegacyImportReviewAuthorization.self,
                row: rows[0]
            )
            guard authorization.importID == record.importID,
                  authorization.itemCount == record.processedItemCount,
                  authorization.orderedItemSetDigest == record.artifactSetDigest else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .reviewConsumed(reviewDigest, authorizationDigest),
             let .completedNoActivation(_, reviewDigest, authorizationDigest):
            let rows = try database.query(
                "SELECT r.payload AS review_payload, a.payload AS authorization_payload FROM runtime_generation_import_reviews r JOIN runtime_generation_import_review_authorization_consumptions c ON c.review_id = r.review_id JOIN runtime_generation_import_review_authorizations a ON a.authorization_id = c.authorization_id WHERE r.review_digest = ? AND a.authorization_digest = ? LIMIT 2",
                bindings: [.text(reviewDigest), .text(authorizationDigest)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1,
                  case let .blob(reviewPayload)? = rows[0].value(named: "review_payload"),
                  case let .blob(authorizationPayload)? = rows[0].value(named: "authorization_payload") else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let review = try RuntimeGenerationControlCodec.decode(
                RuntimeLegacyImportReview.self,
                from: reviewPayload
            )
            let authorization = try RuntimeGenerationControlCodec.decode(
                RuntimeLegacyImportReviewAuthorization.self,
                from: authorizationPayload
            )
            guard review.importID == record.importID,
                  authorization.importID == record.importID,
                  review.itemCount == record.processedItemCount,
                  authorization.itemCount == record.processedItemCount,
                  review.orderedDecisionSetDigest == authorization.orderedDecisionSetDigest,
                  record.artifactSetDigest == review.orderedItemSetDigest else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            if case let .completedNoActivation(intentDigest, _, _) = record.evidence {
                let intentRows = try database.query(
                    "SELECT * FROM runtime_generation_import_disposition_intents WHERE intent_digest = ? LIMIT 2",
                    bindings: [.text(intentDigest)],
                    maximumDecodedBytes: maximumControlReadBytes
                )
                guard intentRows.count == 1 else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                let intent = try decodePayload(
                    RuntimeLegacyImportDispositionIntent.self,
                    row: intentRows[0]
                )
                guard intent.importID == record.importID,
                      intent.disposition == .noActivationAllRejected ||
                        intent.disposition == .noActivationReviewOnly,
                      intent.intentDigest == authorization.dispositionIntentDigest,
                      intent.orderedItemSetDigest == record.artifactSetDigest,
                      review.retainedForFutureMigrationItemCount ==
                        intent.retainedForFutureMigrationItemCount,
                      review.retainedLossyForFutureMigrationItemCount ==
                        intent.retainedLossyForFutureMigrationItemCount,
                      review.rejectedItemCount == intent.rejectedItemCount else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
            }
        case .abandoned:
            break
        case let .quarantined(quarantineDigest, _):
            let rows = try database.query(
                "SELECT * FROM runtime_generation_quarantines WHERE quarantine_digest = ? LIMIT 2",
                bindings: [.text(quarantineDigest)], maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let quarantine = try decodePayload(RuntimeGenerationQuarantineRecord.self, row: rows[0])
            guard quarantine.reason == .ambiguousImport,
                  quarantine.quarantineDigest == record.artifactSetDigest,
                  {
                    if case let .quarantined(_, actions) = record.evidence {
                        return actions == quarantine.allowedActions
                    }
                    return false
                  }() else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        }
    }

    func latestImportCheckpoint(importID: String) async throws -> RuntimeLegacyImportCheckpoint? {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_checkpoints WHERE import_id = ? ORDER BY sequence DESC LIMIT 2",
                bindings: [.text(importID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "import_checkpoint", id: importID)
            }
            return try rows.first.map {
                try Self.decodePayload(RuntimeLegacyImportCheckpoint.self, row: $0)
            }
        }
    }

    func recordImportDispositionIntent(
        _ intent: RuntimeLegacyImportDispositionIntent
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(intent)
        guard intent.disposition == .noActivationAllRejected ||
                intent.disposition == .noActivationReviewOnly else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(intent)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_disposition_intents"],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_manifests",
                    "runtime_generation_import_disposition_intents",
                ]
            )
        ) { database in
            let source = try Self.loadPayload(
                RuntimeLegacyImportSource.self, table: "runtime_generation_imports",
                idColumn: "import_id", id: intent.importID, database: database
            )
            let manifest = try Self.loadPayload(
                RuntimeLegacyImportManifest.self, table: "runtime_generation_import_manifests",
                idColumn: "import_id", id: intent.importID, database: database
            )
            guard source.sourceDigest == intent.sourceDigest,
                  manifest.manifestDigest == intent.manifestDigest,
                  manifest.orderedItemSetDigest == intent.orderedItemSetDigest,
                  manifest.itemCount == intent.itemCount else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try Self.executeImmutableInsert(
                database: database, table: "runtime_generation_import_disposition_intents",
                idColumn: "intent_id", id: intent.intentID,
                columns: [
                    ("import_id", .text(intent.importID)),
                    ("intent_digest", .text(intent.intentDigest)),
                    ("disposition", .text(intent.disposition.rawValue)),
                    ("planned_at_ms", .integer(intent.plannedAtMilliseconds)),
                ], payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func importDispositionIntent(
        digest: String
    ) async throws -> RuntimeLegacyImportDispositionIntent {
        try RuntimeGenerationControlValidation.requireDigest(digest, field: "disposition_intent_digest")
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_disposition_intents WHERE intent_digest = ? LIMIT 2",
                bindings: [.text(digest)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            return try Self.decodePayload(RuntimeLegacyImportDispositionIntent.self, row: rows[0])
        }
    }

    func recordImportItem(_ record: RuntimeLegacyImportItem) async throws {
        try validateImportItem(record)
        let itemKey = LocalRuntimeStorageChecksum.sha256Hex(
            for: "\(record.importID)\n\(record.sourceRecordID)"
        )
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_items"],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_manifests",
                    "runtime_generation_import_items",
                ]
            )
        ) { database in
            _ = try Self.loadPayload(
                RuntimeLegacyImportSource.self,
                table: "runtime_generation_imports",
                idColumn: "import_id",
                id: record.importID,
                database: database
            )
            let completed = try database.query(
                "SELECT 1 FROM runtime_generation_import_manifests WHERE import_id = ? LIMIT 1",
                bindings: [.text(record.importID)]
            )
            guard completed.isEmpty else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_items",
                idColumn: "item_key",
                id: itemKey,
                columns: [
                    ("import_id", .text(record.importID)),
                    ("source_record_id", .text(record.sourceRecordID)),
                    ("source_record_digest", .text(record.sourceRecordDigest)),
                    ("canonical_family", record.canonicalFamily.map(SQLiteBinding.text) ?? .null),
                    ("canonical_id", record.canonicalID.map(SQLiteBinding.text) ?? .null),
                    ("canonical_payload_digest", record.canonicalPayloadDigest.map(SQLiteBinding.text) ?? .null),
                    ("mapped_artifact_binding_digest", record.mappedArtifact.map { .text($0.bindingDigest) } ?? .null),
                    ("disposition", .text(record.disposition.rawValue)),
                    ("lossiness", .text(record.lossiness.rawValue)),
                    ("item_digest", .text(record.itemDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func importContainsSourceRecordDigest(
        importID: String,
        sourceRecordDigest: String
    ) async throws -> Bool {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT 1 FROM runtime_generation_import_items WHERE import_id = ? AND source_record_digest = ? LIMIT 1",
            bindings: [.text(importID), .text(sourceRecordDigest)]
        )
        return rows.isEmpty == false
    }

    func importContainsCanonicalPayloadDigest(
        importID: String,
        canonicalPayloadDigest: String
    ) async throws -> Bool {
        try RuntimeGenerationControlValidation.requireDigest(
            canonicalPayloadDigest, field: "canonical_payload_digest"
        )
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT 1 FROM runtime_generation_import_items WHERE import_id = ? AND canonical_payload_digest = ? LIMIT 1",
            bindings: [.text(importID), .text(canonicalPayloadDigest)]
        )
        return rows.isEmpty == false
    }

    func importItemsPage(
        importID: String,
        afterSourceRecordID: String?,
        limit: Int
    ) async throws -> [RuntimeLegacyImportItem] {
        guard limit > 0, limit <= RuntimeGenerationLegacyImportService.pageSize else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try revalidateAuthority()
        let rows = try await database.query(
            """
            SELECT * FROM runtime_generation_import_items
            WHERE import_id = ? AND (? IS NULL OR source_record_id > ?)
            ORDER BY source_record_id
            LIMIT ?
            """,
            bindings: [
                .text(importID),
                afterSourceRecordID.map(SQLiteBinding.text) ?? .null,
                afterSourceRecordID.map(SQLiteBinding.text) ?? .null,
                .integer(Int64(limit)),
            ],
            maximumDecodedBytes: Self.maximumControlReadBytes
        )
        return try rows.map { try Self.decodePayload(RuntimeLegacyImportItem.self, row: $0) }
    }

    func importManifestIfPresent(
        importID: String
    ) async throws -> RuntimeLegacyImportManifest? {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_import_manifests WHERE import_id = ? LIMIT 2",
                bindings: [.text(importID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "import_manifest", id: importID)
            }
            return try rows.first.map {
                try Self.decodePayload(RuntimeLegacyImportManifest.self, row: $0)
            }
        }
    }

    func recordImportManifest(_ record: RuntimeLegacyImportManifest) async throws {
        try record.validate()
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_manifests"],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_items",
                    "runtime_generation_import_manifests",
                ]
            )
        ) { database in
            _ = try Self.loadPayload(
                RuntimeLegacyImportSource.self,
                table: "runtime_generation_imports",
                idColumn: "import_id",
                id: record.importID,
                database: database
            )
            var cursor: String?
            var count = 0
            var digest = LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.import.items.v2\n\(record.importID)"
            )
            repeat {
                let rows = try database.query(
                    """
                    SELECT * FROM runtime_generation_import_items
                    WHERE import_id = ? AND (? IS NULL OR source_record_id > ?)
                    ORDER BY source_record_id LIMIT ?
                    """,
                    bindings: [
                        .text(record.importID),
                        cursor.map(SQLiteBinding.text) ?? .null,
                        cursor.map(SQLiteBinding.text) ?? .null,
                        .integer(Int64(RuntimeGenerationLegacyImportService.pageSize)),
                    ],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                for row in rows {
                    let item = try Self.decodePayload(RuntimeLegacyImportItem.self, row: row)
                    digest = LocalRuntimeStorageChecksum.sha256Hex(
                        for: "\(digest)\n\(item.sourceRecordID)\n\(item.itemDigest)"
                    )
                    count += 1
                    cursor = item.sourceRecordID
                }
                if rows.count < RuntimeGenerationLegacyImportService.pageSize { break }
            } while true
            guard count == record.itemCount,
                  digest == record.orderedItemSetDigest else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_manifests",
                idColumn: "import_id",
                id: record.importID,
                columns: [
                    ("item_count", .integer(Int64(record.itemCount))),
                    ("ordered_item_set_digest", .text(record.orderedItemSetDigest)),
                    ("completed_at_ms", .integer(record.completedAtMilliseconds)),
                    ("manifest_digest", .text(record.manifestDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func recordImportReviewPage(_ record: RuntimeLegacyImportReviewPage) async throws {
        try record.validate()
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        let payloadDigest = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_review_pages"],
                reading: [
                    "runtime_generation_import_manifests",
                    "runtime_generation_import_review_pages",
                    "runtime_generation_import_items",
                ]
            )
        ) { database in
            _ = try Self.loadPayload(
                RuntimeLegacyImportManifest.self,
                table: "runtime_generation_import_manifests",
                idColumn: "import_id",
                id: record.importID,
                database: database
            )
            let priorRows = try database.query(
                "SELECT * FROM runtime_generation_import_review_pages WHERE review_id = ? ORDER BY page_index DESC LIMIT 1",
                bindings: [.text(record.reviewID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if let priorRow = priorRows.first {
                let prior = try Self.decodePayload(
                    RuntimeLegacyImportReviewPage.self, row: priorRow
                )
                guard record.pageIndex == prior.pageIndex + 1,
                      record.afterSourceRecordID == prior.lastSourceRecordID,
                      record.importID == prior.importID else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
            } else {
                guard record.pageIndex == 0, record.afterSourceRecordID == nil else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
            }
            let itemRows = try database.query(
                """
                SELECT * FROM runtime_generation_import_items
                WHERE import_id = ? AND (? IS NULL OR source_record_id > ?)
                ORDER BY source_record_id LIMIT ?
                """,
                bindings: [
                    .text(record.importID),
                    record.afterSourceRecordID.map(SQLiteBinding.text) ?? .null,
                    record.afterSourceRecordID.map(SQLiteBinding.text) ?? .null,
                    .integer(Int64(RuntimeGenerationLegacyImportService.pageSize)),
                ],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let items = try itemRows.map {
                try Self.decodePayload(RuntimeLegacyImportItem.self, row: $0)
            }
            guard items.count == record.entries.count,
                  items.last?.sourceRecordID == record.lastSourceRecordID else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            for (item, entry) in zip(items, record.entries) {
                guard item.itemDigest == entry.itemDigest,
                      Self.reviewDecision(entry.decision, isValidFor: item) else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_review_pages",
                idColumn: "page_id",
                id: record.pageID,
                columns: [
                    ("review_id", .text(record.reviewID)),
                    ("import_id", .text(record.importID)),
                    ("page_index", .integer(Int64(record.pageIndex))),
                    ("after_source_record_id", record.afterSourceRecordID.map(SQLiteBinding.text) ?? .null),
                    ("last_source_record_id", .text(record.lastSourceRecordID)),
                    ("page_digest", .text(record.pageDigest)),
                ],
                payload: payload,
                payloadDigest: payloadDigest
            )
        }
    }

    func finalizeImportReview(
        reviewID: String,
        importID: String,
        authorization: RuntimeLegacyImportReviewAuthorization,
        reviewedAtMilliseconds: Int64
    ) async throws -> RuntimeLegacyImportReview {
        try RuntimeGenerationControlRecordFactory.validate(authorization)
        try revalidateAuthority()
        return try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [
                    "runtime_generation_import_reviews",
                    "runtime_generation_import_review_authorization_consumptions",
                ],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_manifests",
                    "runtime_generation_import_review_authorizations",
                    "runtime_generation_import_review_authorization_consumptions",
                    "runtime_generation_import_disposition_intents",
                    "runtime_generation_import_review_pages",
                    "runtime_generation_import_items",
                    "runtime_generation_import_reviews",
                ]
            )
        ) { database in
            let source = try Self.loadPayload(
                RuntimeLegacyImportSource.self,
                table: "runtime_generation_imports",
                idColumn: "import_id",
                id: importID,
                database: database
            )
            let manifest = try Self.loadPayload(
                RuntimeLegacyImportManifest.self,
                table: "runtime_generation_import_manifests",
                idColumn: "import_id",
                id: importID,
                database: database
            )
            let durableAuthorization = try Self.loadPayload(
                RuntimeLegacyImportReviewAuthorization.self,
                table: "runtime_generation_import_review_authorizations",
                idColumn: "authorization_id",
                id: authorization.authorizationID,
                database: database
            )
            let priorConsumption = try database.query(
                "SELECT authorization_id FROM runtime_generation_import_review_authorization_consumptions WHERE authorization_id = ? LIMIT 2",
                bindings: [.text(authorization.authorizationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard durableAuthorization == authorization, priorConsumption.isEmpty else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            let intentRows = try database.query(
                "SELECT * FROM runtime_generation_import_disposition_intents WHERE intent_digest = ? LIMIT 2",
                bindings: [.text(authorization.dispositionIntentDigest)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard intentRows.count == 1 else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            let dispositionIntent = try Self.decodePayload(
                RuntimeLegacyImportDispositionIntent.self, row: intentRows[0]
            )
            var expectedCursor: String?
            var pageCount = 0
            var retainedForFutureMigration = 0
            var retainedLossyForFutureMigration = 0
            var rejected = 0
            var itemCount = 0
            var decisionDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.import.decisions.v2\n\(reviewID)\n\(importID)"
            )
            while true {
                try Task.checkCancellation()
                let pageRows = try database.query(
                    "SELECT * FROM runtime_generation_import_review_pages WHERE review_id = ? AND page_index >= ? ORDER BY page_index LIMIT 1",
                    bindings: [.text(reviewID), .integer(Int64(pageCount))],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                guard let row = pageRows.first else { break }
                let page = try Self.decodePayload(
                    RuntimeLegacyImportReviewPage.self, row: row
                )
                guard page.importID == importID,
                      page.pageIndex == pageCount,
                      page.afterSourceRecordID == expectedCursor else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                let itemRows = try database.query(
                    """
                    SELECT * FROM runtime_generation_import_items
                    WHERE import_id = ? AND (? IS NULL OR source_record_id > ?)
                    ORDER BY source_record_id LIMIT ?
                    """,
                    bindings: [
                        .text(importID),
                        expectedCursor.map(SQLiteBinding.text) ?? .null,
                        expectedCursor.map(SQLiteBinding.text) ?? .null,
                        .integer(Int64(RuntimeGenerationLegacyImportService.pageSize)),
                    ],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                let items = try itemRows.map {
                    try Self.decodePayload(RuntimeLegacyImportItem.self, row: $0)
                }
                guard items.count == page.entries.count,
                      items.last?.sourceRecordID == page.lastSourceRecordID else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                for (item, entry) in zip(items, page.entries) {
                    guard item.itemDigest == entry.itemDigest,
                          Self.reviewDecision(entry.decision, isValidFor: item) else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                    switch entry.decision {
                    case .retainForFutureMigration:
                        retainedForFutureMigration = try Self.checkedIncrement(
                            retainedForFutureMigration
                        )
                    case .retainLossyForFutureMigration:
                        retainedLossyForFutureMigration = try Self.checkedIncrement(
                            retainedLossyForFutureMigration
                        )
                    case .reject:
                        rejected = try Self.checkedIncrement(rejected)
                    }
                    decisionDigest = LocalRuntimeStorageChecksum.sha256Hex(
                        for: "\(decisionDigest)\n\(item.sourceRecordID)\n\(item.itemDigest)\n\(entry.decision.rawValue)"
                    )
                    itemCount = try Self.checkedIncrement(itemCount)
                }
                expectedCursor = page.lastSourceRecordID
                pageCount = try Self.checkedIncrement(pageCount)
            }
            guard itemCount == manifest.itemCount else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            guard authorization.importID == importID,
                  authorization.sourceDigest == source.sourceDigest,
                  authorization.manifestDigest == manifest.manifestDigest,
                  authorization.itemCount == itemCount,
                  authorization.retainedForFutureMigrationItemCount ==
                    retainedForFutureMigration,
                  authorization.retainedLossyForFutureMigrationItemCount ==
                    retainedLossyForFutureMigration,
                  authorization.rejectedItemCount == rejected,
                  authorization.orderedItemSetDigest == manifest.orderedItemSetDigest,
                  authorization.orderedDecisionSetDigest == decisionDigest,
                  dispositionIntent.importID == importID,
                  dispositionIntent.sourceDigest == source.sourceDigest,
                  dispositionIntent.manifestDigest == manifest.manifestDigest,
                  dispositionIntent.orderedDecisionSetDigest == decisionDigest,
                  dispositionIntent.retainedForFutureMigrationItemCount ==
                    retainedForFutureMigration,
                  dispositionIntent.retainedLossyForFutureMigrationItemCount ==
                    retainedLossyForFutureMigration,
                  dispositionIntent.rejectedItemCount == rejected,
                  reviewedAtMilliseconds >= authorization.authorizedAtMilliseconds,
                  reviewedAtMilliseconds < authorization.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            let review = try RuntimeGenerationControlRecordFactory.importReview(
                id: reviewID,
                importID: importID,
                sourceDigest: source.sourceDigest,
                itemCount: itemCount,
                retainedForFutureMigrationItemCount: retainedForFutureMigration,
                retainedLossyForFutureMigrationItemCount:
                    retainedLossyForFutureMigration,
                rejectedItemCount: rejected,
                pageCount: pageCount,
                orderedItemSetDigest: manifest.orderedItemSetDigest,
                orderedDecisionSetDigest: decisionDigest,
                reviewerConfirmationDigest: authorization.authorizationDigest,
                reviewedAtMilliseconds: reviewedAtMilliseconds
            )
            try review.validate()
            let payload = try RuntimeGenerationControlCodec.encode(review)
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_reviews",
                idColumn: "review_id",
                id: review.reviewID,
                columns: [
                    ("import_id", .text(review.importID)),
                    ("source_digest", .text(review.sourceDigest)),
                    ("item_count", .integer(Int64(review.itemCount))),
                    ("page_count", .integer(Int64(review.pageCount))),
                    ("ordered_item_set_digest", .text(review.orderedItemSetDigest)),
                    ("ordered_decision_set_digest", .text(review.orderedDecisionSetDigest)),
                    ("review_authorization_digest", .text(review.reviewerConfirmationDigest)),
                    ("reviewed_at_ms", .integer(review.reviewedAtMilliseconds)),
                    ("review_digest", .text(review.reviewDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
            try database.execute(
                "INSERT INTO runtime_generation_import_review_authorization_consumptions(authorization_id, review_id, review_digest, consumed_at_ms) VALUES(?, ?, ?, ?)",
                bindings: [
                    .text(authorization.authorizationID), .text(review.reviewID),
                    .text(review.reviewDigest), .integer(reviewedAtMilliseconds),
                ]
            )
            return review
        }
    }

    func recordImportReviewAuthorization(
        _ authorization: RuntimeLegacyImportReviewAuthorization
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(authorization)
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(authorization)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_import_review_authorizations"],
                reading: [
                    "runtime_generation_imports",
                    "runtime_generation_import_manifests",
                    "runtime_generation_import_disposition_intents",
                    "runtime_generation_import_review_authorizations",
                ]
            )
        ) { database in
            let source = try Self.loadPayload(
                RuntimeLegacyImportSource.self, table: "runtime_generation_imports",
                idColumn: "import_id", id: authorization.importID, database: database
            )
            let manifest = try Self.loadPayload(
                RuntimeLegacyImportManifest.self,
                table: "runtime_generation_import_manifests", idColumn: "import_id",
                id: authorization.importID, database: database
            )
            guard source.sourceDigest == authorization.sourceDigest,
                  manifest.manifestDigest == authorization.manifestDigest,
                  manifest.itemCount == authorization.itemCount,
                  manifest.orderedItemSetDigest == authorization.orderedItemSetDigest else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            let intents = try database.query(
                "SELECT * FROM runtime_generation_import_disposition_intents WHERE intent_digest = ? LIMIT 2",
                bindings: [.text(authorization.dispositionIntentDigest)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard intents.count == 1 else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            let intent = try Self.decodePayload(
                RuntimeLegacyImportDispositionIntent.self, row: intents[0]
            )
            guard intent.importID == authorization.importID,
                  intent.sourceDigest == authorization.sourceDigest,
                  intent.manifestDigest == authorization.manifestDigest,
                  intent.itemCount == authorization.itemCount,
                  intent.retainedForFutureMigrationItemCount ==
                    authorization.retainedForFutureMigrationItemCount,
                  intent.retainedLossyForFutureMigrationItemCount ==
                    authorization.retainedLossyForFutureMigrationItemCount,
                  intent.rejectedItemCount == authorization.rejectedItemCount,
                  intent.orderedItemSetDigest == authorization.orderedItemSetDigest,
                  intent.orderedDecisionSetDigest == authorization.orderedDecisionSetDigest,
                  intent.lossinessConsequenceDigest == authorization.lossinessConsequenceDigest else {
                throw RuntimeGenerationControlError.importLossNotAccepted
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_import_review_authorizations",
                idColumn: "authorization_id", id: authorization.authorizationID,
                columns: [
                    ("import_id", .text(authorization.importID)),
                    ("manifest_digest", .text(authorization.manifestDigest)),
                    ("disposition_intent_digest", .text(authorization.dispositionIntentDigest)),
                    ("expires_at_ms", .integer(authorization.expiresAtMilliseconds)),
                    ("authorization_digest", .text(authorization.authorizationDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func recordRecoveryAuthorization(
        _ record: RuntimeGenerationRecoveryAuthorization
    ) async throws {
        try validateRecoveryAuthorization(record)
        try await insertImmutable(
            table: "runtime_generation_recovery_authorizations",
            idColumn: "authorization_id",
            id: record.authorizationID,
            columns: [
                ("action", .text(record.action.rawValue)),
                ("target_digest", .text(record.targetDigest)),
                ("authorized_at_ms", .integer(record.authorizedAtMilliseconds)),
                ("expires_at_ms", .integer(record.expiresAtMilliseconds)),
                ("authorization_digest", .text(record.authorizationDigest)),
            ],
            payload: record
        )
    }

    func recordRecoveryOperationPlan(
        _ record: RuntimeGenerationRecoveryOperationPlan,
        supersedingPlanID: String? = nil
    ) async throws {
        try record.validate()
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(
            writing: ["runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_plan_successions"],
            reading: ["runtime_generation_quarantines", "runtime_generation_recovery_authorizations", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_recovery_operation_plan_successions"]
        )) { database in
            let controlNowMilliseconds = try authorityNowMilliseconds()
            let quarantine = try Self.loadPayload(RuntimeGenerationQuarantineRecord.self, table: "runtime_generation_quarantines", idColumn: "quarantine_id", id: record.quarantineID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: record.recoveryAuthorizationID, database: database)
            guard quarantine.allowedActions.contains(record.action),
                  record.targetDigest == quarantine.quarantineDigest,
                  authorization.action == record.action,
                  authorization.targetDigest == record.targetDigest,
                  authorization.authorizationDigest == record.recoveryAuthorizationDigest,
                  record.preparedAtMilliseconds >= authorization.authorizedAtMilliseconds,
                  record.preparedAtMilliseconds < authorization.expiresAtMilliseconds,
                  record.expiresAtMilliseconds <= authorization.expiresAtMilliseconds,
                  record.preparedAtMilliseconds <= controlNowMilliseconds,
                  controlNowMilliseconds >= authorization.authorizedAtMilliseconds,
                  controlNowMilliseconds < authorization.expiresAtMilliseconds,
                  controlNowMilliseconds < record.expiresAtMilliseconds else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            let predecessors = try database.query("SELECT p.* FROM runtime_generation_recovery_operation_plans AS p LEFT JOIN runtime_generation_recovery_operation_plan_successions AS s ON s.predecessor_plan_id = p.plan_id WHERE p.quarantine_id = ? AND p.action = ? AND s.predecessor_plan_id IS NULL ORDER BY p.prepared_at_ms DESC, p.plan_id DESC LIMIT 2", bindings: [.text(record.quarantineID), .text(record.action.rawValue)], maximumDecodedBytes: Self.maximumControlReadBytes)
            if let supersedingPlanID {
                guard predecessors.count == 1 else { throw RuntimeGenerationControlError.recordConflict(kind: "recovery_operation_predecessor", id: supersedingPlanID) }
                let predecessor = try Self.decodePayload(RuntimeGenerationRecoveryOperationPlan.self, row: predecessors[0])
                guard predecessor.planID == supersedingPlanID else { throw RuntimeGenerationControlError.recordConflict(kind: "recovery_operation_predecessor", id: supersedingPlanID) }
                let disposition = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlanDisposition.self, table: "runtime_generation_recovery_operation_plan_dispositions", idColumn: "plan_id", id: predecessor.planID, database: database)
                let consumed = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_consumptions WHERE plan_id = ? LIMIT 1", bindings: [.text(predecessor.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
                let receipt = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 1", bindings: [.text(predecessor.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
                guard consumed.isEmpty, receipt.isEmpty else { throw RuntimeGenerationControlError.recordConflict(kind: "recovery_operation_predecessor", id: predecessor.planID) }
                let succession = try RuntimeGenerationControlRecordFactory.recoveryOperationPlanSuccession(successor: record, predecessor: predecessor, disposition: disposition, recordedAtMilliseconds: controlNowMilliseconds)
                let successionPayload = try RuntimeGenerationControlCodec.encode(succession)
                try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_plan_successions", idColumn: "successor_plan_id", id: succession.successorPlanID, columns: [("predecessor_plan_id", .text(succession.predecessorPlanID)), ("quarantine_id", .text(succession.quarantineID)), ("action", .text(succession.action.rawValue)), ("predecessor_disposition_digest", .text(succession.predecessorDispositionDigest)), ("recorded_at_ms", .integer(succession.recordedAtMilliseconds)), ("succession_digest", .text(succession.successionDigest))], payload: successionPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: successionPayload))
            } else {
                guard predecessors.isEmpty else { throw RuntimeGenerationControlError.recordConflict(kind: "recovery_operation_plan", id: record.quarantineID) }
            }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: record.planID,
                columns: [("quarantine_id", .text(record.quarantineID)), ("action", .text(record.action.rawValue)), ("target_digest", .text(record.targetDigest)), ("recovery_authorization_id", .text(record.recoveryAuthorizationID)), ("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest)), ("prepared_at_ms", .integer(record.preparedAtMilliseconds)), ("expires_at_ms", .integer(record.expiresAtMilliseconds)), ("plan_digest", .text(record.planDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
        }
    }

    func recordRecoveryOperationPlanDisposition(_ record: RuntimeGenerationRecoveryOperationPlanDisposition) async throws {
        try record.validate(); try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(writing: ["runtime_generation_recovery_operation_plan_dispositions"], reading: ["runtime_generation_recovery_operation_plans", "runtime_generation_recovery_authorizations", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_plan_dispositions"])) { database in
            let now = try authorityNowMilliseconds()
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: record.planID, database: database)
            let consumption = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_consumptions WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let receipt = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard consumption.isEmpty, receipt.isEmpty, record.disposedAtMilliseconds <= now else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            switch record.kind {
            case .expiredWithoutReceipt:
                guard now >= plan.expiresAtMilliseconds, record.disposedAtMilliseconds >= plan.expiresAtMilliseconds else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            case .explicitlyCancelled:
                let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: record.recoveryAuthorizationID!, database: database)
                guard authorization.action == plan.action, authorization.targetDigest == plan.targetDigest, authorization.authorizationDigest == record.recoveryAuthorizationDigest, record.disposedAtMilliseconds >= authorization.authorizedAtMilliseconds, record.disposedAtMilliseconds < authorization.expiresAtMilliseconds else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_plan_dispositions", idColumn: "plan_id", id: record.planID, columns: [("kind", .text(record.kind.rawValue)), ("recovery_authorization_id", record.recoveryAuthorizationID.map { .text($0) } ?? .null), ("recovery_authorization_digest", record.recoveryAuthorizationDigest.map { .text($0) } ?? .null), ("disposed_at_ms", .integer(record.disposedAtMilliseconds)), ("disposition_digest", .text(record.dispositionDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
        }
    }

    func consumeRecoveryOperationPlan(_ record: RuntimeGenerationRecoveryOperationConsumption) async throws {
        try record.validate()
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(
            writing: ["runtime_generation_recovery_operation_consumptions"],
            reading: ["runtime_generation_recovery_operation_plans", "runtime_generation_recovery_authorizations", "runtime_generation_recovery_operation_consumptions"]
        )) { database in
            let controlNowMilliseconds = try authorityNowMilliseconds()
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: record.planID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: record.recoveryAuthorizationID, database: database)
            guard record.recoveryAuthorizationID == plan.recoveryAuthorizationID,
                  record.action == plan.action, record.targetDigest == plan.targetDigest,
                  authorization.action == plan.action, authorization.targetDigest == plan.targetDigest,
                  authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
                  record.consumedAtMilliseconds >= plan.preparedAtMilliseconds,
                  record.consumedAtMilliseconds < plan.expiresAtMilliseconds,
                  record.consumedAtMilliseconds < authorization.expiresAtMilliseconds,
                  record.consumedAtMilliseconds <= controlNowMilliseconds,
                  controlNowMilliseconds >= authorization.authorizedAtMilliseconds,
                  controlNowMilliseconds < authorization.expiresAtMilliseconds,
                  controlNowMilliseconds < plan.expiresAtMilliseconds else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_consumptions", idColumn: "plan_id", id: record.planID,
                columns: [("recovery_authorization_id", .text(record.recoveryAuthorizationID)), ("action", .text(record.action.rawValue)), ("target_digest", .text(record.targetDigest)), ("result_digest", .text(record.resultDigest)), ("consumed_at_ms", .integer(record.consumedAtMilliseconds)), ("consumption_digest", .text(record.consumptionDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
        }
    }

    /// Acquires a durable, epoch-fenced execution claim before a recovery
    /// executor inspects or mutates any runtime artifact. A completed plan is
    /// idempotent: its existing typed receipt is returned rather than issuing
    /// a second execution claim. An unexpired claim is never stolen.
    func claimRecoveryOperationExecution(
        planID: String,
        claimID: String,
        executorInstanceID: String,
        expiresAtMilliseconds: Int64
    ) async throws -> RuntimeGenerationRecoveryOperationExecutionClaimResult {
        try RuntimeGenerationControlValidation.requireIdentifier(planID, field: "recovery_execution_plan_id")
        try RuntimeGenerationControlValidation.requireIdentifier(claimID, field: "recovery_execution_claim_id")
        try RuntimeGenerationControlValidation.requireIdentifier(executorInstanceID, field: "recovery_execution_executor_id")
        try revalidateAuthority()
        return try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(
            writing: ["runtime_generation_recovery_operation_execution_claims"],
            reading: [
                "runtime_generation_recovery_operation_plans",
                "runtime_generation_recovery_authorizations",
                "runtime_generation_recovery_operation_execution_claims",
                "runtime_generation_recovery_operation_execution_receipts",
                "runtime_generation_recovery_operation_plan_dispositions",
            ]
        )) { database in
            let receiptRows = try database.query(
                "SELECT * FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 2",
                bindings: [.text(planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if receiptRows.count == 1 {
                return .completed(try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionReceipt.self, row: receiptRows[0]))
            }
            guard receiptRows.isEmpty else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "recovery_execution_receipt", id: planID)
            }
            let dispositions = try database.query(
                "SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 2",
                bindings: [.text(planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard dispositions.isEmpty else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let controlNowMilliseconds = try authorityNowMilliseconds()
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: planID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: plan.recoveryAuthorizationID, database: database)
            guard controlNowMilliseconds >= plan.preparedAtMilliseconds,
                  controlNowMilliseconds < plan.expiresAtMilliseconds,
                  controlNowMilliseconds >= authorization.authorizedAtMilliseconds,
                  controlNowMilliseconds < authorization.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let claims = try database.query(
                "SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 2",
                bindings: [.text(planID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            if let latestRow = claims.first {
                let latest = try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestRow)
                if latest.expiresAtMilliseconds > controlNowMilliseconds {
                    return .held(latest)
                }
                guard latest.claimEpoch < Int64.max else {
                    throw RuntimeGenerationControlError.resourcePolicyExceeded(
                        resource: "recovery_execution_claim_epoch", maximum: Int64.max
                    )
                }
                let claim = try RuntimeGenerationControlRecordFactory.recoveryOperationExecutionClaim(
                    id: claimID, planID: planID, executorInstanceID: executorInstanceID,
                    claimEpoch: latest.claimEpoch + 1,
                    claimedAtMilliseconds: controlNowMilliseconds,
                    expiresAtMilliseconds: expiresAtMilliseconds
                )
                guard claim.expiresAtMilliseconds <= plan.expiresAtMilliseconds,
                      claim.expiresAtMilliseconds <= authorization.expiresAtMilliseconds else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let payload = try RuntimeGenerationControlCodec.encode(claim)
                try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: claim.claimID,
                    columns: [("plan_id", .text(claim.planID)), ("executor_instance_id", .text(claim.executorInstanceID)), ("claim_epoch", .integer(claim.claimEpoch)), ("claimed_at_ms", .integer(claim.claimedAtMilliseconds)), ("expires_at_ms", .integer(claim.expiresAtMilliseconds)), ("claim_digest", .text(claim.claimDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
                return .acquired(claim)
            }
            let claim = try RuntimeGenerationControlRecordFactory.recoveryOperationExecutionClaim(
                id: claimID, planID: planID, executorInstanceID: executorInstanceID,
                claimEpoch: 1, claimedAtMilliseconds: controlNowMilliseconds,
                expiresAtMilliseconds: expiresAtMilliseconds
            )
            guard claim.expiresAtMilliseconds <= plan.expiresAtMilliseconds,
                  claim.expiresAtMilliseconds <= authorization.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let payload = try RuntimeGenerationControlCodec.encode(claim)
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: claim.claimID,
                columns: [("plan_id", .text(claim.planID)), ("executor_instance_id", .text(claim.executorInstanceID)), ("claim_epoch", .integer(claim.claimEpoch)), ("claimed_at_ms", .integer(claim.claimedAtMilliseconds)), ("expires_at_ms", .integer(claim.expiresAtMilliseconds)), ("claim_digest", .text(claim.claimDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
            return .acquired(claim)
        }
    }

    func recoveryOperationExecutionReceipt(
        planID: String
    ) async throws -> RuntimeGenerationRecoveryOperationExecutionReceipt? {
        try RuntimeGenerationControlValidation.requireIdentifier(planID, field: "recovery_execution_receipt_plan_id")
        let rows = try await database.transaction(.deferred) { database in
            try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 2", bindings: [.text(planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
        }
        guard rows.count <= 1 else { throw RuntimeGenerationControlError.recordCorrupt(kind: "recovery_execution_receipt", id: planID) }
        return try rows.first.map { try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionReceipt.self, row: $0) }
    }

    func recordRecoveryOperationVerificationBinding(_ record: RuntimeGenerationRecoveryOperationVerificationBinding) async throws {
        try record.validate(); try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(writing: ["runtime_generation_recovery_operation_verification_bindings"], reading: ["runtime_generation_verifications", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_recovery_operation_verification_bindings"])) { database in
            let now = try authorityNowMilliseconds()
            let verification = try Self.loadPayload(RuntimeGenerationVerificationReport.self, table: "runtime_generation_verifications", idColumn: "verification_id", id: record.verificationID, database: database)
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: record.planID, database: database)
            let claim = try Self.loadPayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: record.claimID, database: database)
            let dispositions = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 2", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard dispositions.isEmpty, verification.reportDigest == record.verificationReportDigest, verification.candidateGenerationID == record.candidateGenerationID, claim.planID == plan.planID, claim.claimEpoch == record.claimEpoch, verification.verifiedAtMilliseconds >= claim.claimedAtMilliseconds, verification.verifiedAtMilliseconds < claim.expiresAtMilliseconds, record.observedAtMilliseconds >= claim.claimedAtMilliseconds, record.observedAtMilliseconds >= verification.verifiedAtMilliseconds, record.observedAtMilliseconds <= now, record.observedAtMilliseconds < claim.expiresAtMilliseconds, now < claim.expiresAtMilliseconds else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_verification_bindings", idColumn: "verification_id", id: record.verificationID, columns: [("verification_report_digest", .text(record.verificationReportDigest)), ("plan_id", .text(record.planID)), ("claim_id", .text(record.claimID)), ("claim_epoch", .integer(record.claimEpoch)), ("candidate_generation_id", .text(record.candidateGenerationID.rawValue)), ("observed_at_ms", .integer(record.observedAtMilliseconds)), ("binding_digest", .text(record.bindingDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
        }
    }

    func recordProjectionRebuildLifecycleTransition(
        _ record: RuntimeGenerationProjectionRebuildLifecycleTransition,
        currentOperationLease: RuntimeGenerationOperationLease? = nil
    ) async throws {
        try record.validate(); try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(record)
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(writing: ["runtime_generation_projection_rebuild_lifecycle_transitions"], reading: ["runtime_generation_migration_runs", "runtime_generation_operation_leases", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_authorizations", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_projection_rebuild_lifecycle_transitions"])) { database in
            let now = try authorityNowMilliseconds()
            let run = try Self.loadPayload(RuntimeGenerationMigrationRun.self, table: "runtime_generation_migration_runs", idColumn: "migration_run_id", id: record.migrationRunID, database: database)
            let claim = try Self.loadPayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: record.recoveryExecutionClaimID, database: database)
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: record.recoveryExecutionPlanID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: plan.recoveryAuthorizationID, database: database)
            let disposed = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 1", bindings: [.text(record.recoveryExecutionPlanID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard run.operationKind == .projectionRebuild, run.recoveryExecutionPlanID == record.recoveryExecutionPlanID, run.recoveryExecutionClaimID == record.recoveryExecutionClaimID, run.recoveryExecutionClaimEpoch == record.recoveryExecutionClaimEpoch, claim.planID == record.recoveryExecutionPlanID, claim.claimEpoch == record.recoveryExecutionClaimEpoch, disposed.isEmpty, record.occurredAtMilliseconds <= now else { throw RuntimeGenerationControlError.recoveryAuthorizationRequired }
            let prior = try database.query("SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2", bindings: [.text(run.migrationRunID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            if let row = prior.first {
                let previous = try Self.decodePayload(RuntimeGenerationProjectionRebuildLifecycleTransition.self, row: row)
                guard record.priorTransitionDigest == previous.transitionDigest,
                      record.occurredAtMilliseconds >= previous.occurredAtMilliseconds,
                      Self.allowsProjectionRebuildTransition(from: previous.phase, to: record.phase) else { throw RuntimeGenerationControlError.activationAuthorityMismatch }
                guard let currentOperationLease else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                let leaseRows = try database.query("SELECT * FROM runtime_generation_operation_leases WHERE reservation_id = ? ORDER BY lease_epoch ASC", bindings: [.text(run.reservationID)], maximumDecodedBytes: Self.maximumControlReadBytes)
                let leases = try leaseRows.map { try Self.decodePayload(RuntimeGenerationOperationLease.self, row: $0) }
                guard let latestLease = leases.last,
                      latestLease == currentOperationLease,
                      let admissionIndex = leases.firstIndex(where: { $0.leaseID == run.operationLeaseID && $0.leaseEpoch == run.operationLeaseEpoch && $0.fencingToken == run.operationFencingToken }),
                      leases[admissionIndex].ownerInstanceID == run.executorInstanceID,
                      zip(leases.dropFirst(admissionIndex), leases.dropFirst(admissionIndex + 1)).allSatisfy { prior, successor in successor.leaseEpoch == prior.leaseEpoch + 1 && successor.priorLeaseDigest == prior.leaseDigest && successor.fencingToken >= prior.fencingToken },
                      currentOperationLease.ownerInstanceID == run.executorInstanceID,
                      currentOperationLease.leaseEpoch >= run.operationLeaseEpoch,
                      currentOperationLease.fencingToken >= run.operationFencingToken,
                      now >= currentOperationLease.issuedAtMilliseconds,
                      now < currentOperationLease.expiresAtMilliseconds,
                      now >= claim.claimedAtMilliseconds,
                      now < claim.expiresAtMilliseconds,
                      now >= plan.preparedAtMilliseconds,
                      now < plan.expiresAtMilliseconds,
                      now >= authorization.authorizedAtMilliseconds,
                      now < authorization.expiresAtMilliseconds else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let latestClaimRows = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
                guard let latestClaimRow = latestClaimRows.first,
                      try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestClaimRow) == claim else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            } else {
                guard record.phase == .admitted, record.priorTransitionDigest == nil else { throw RuntimeGenerationControlError.activationAuthorityMismatch }
            }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_projection_rebuild_lifecycle_transitions", idColumn: "transition_id", id: record.transitionID, columns: [("migration_run_id", .text(record.migrationRunID)), ("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID)), ("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID)), ("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch)), ("phase", .text(record.phase.rawValue)), ("prior_transition_digest", record.priorTransitionDigest.map { .text($0) } ?? .null), ("reason_digest", .text(record.reasonDigest)), ("occurred_at_ms", .integer(record.occurredAtMilliseconds)), ("transition_digest", .text(record.transitionDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload))
        }
    }

    /// The only admission write for a recovery-authorized projection rebuild.
    /// It is intentionally all-or-nothing: a restart sees either the complete
    /// reservation/lease/preparation/run/admitted chain or none of it.
    func admitProjectionRebuild(
        _ request: RuntimeGenerationProjectionRebuildAdmissionRequest
    ) async throws -> RuntimeGenerationProjectionRebuildAdmissionRecords {
        guard let candidateAuthorityReservation = request.candidateAuthorityReservation else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try validateReservation(request.reservation)
        try RuntimeGenerationControlRecordFactory.validate(request.operationLease)
        try RuntimeGenerationControlRecordFactory.validate(request.candidatePreparation)
        try validateMigrationRun(request.migrationRun)
        try RuntimeGenerationControlRecordFactory.validate(request.admittedTransition)
        try RuntimeGenerationControlRecordFactory.validate(candidateAuthorityReservation)
        try RuntimeGenerationControlRecordFactory.validate(request.plan)
        try RuntimeGenerationControlRecordFactory.validate(request.claim)
        try validateQuarantine(request.quarantine)
        try RuntimeGenerationControlRecordFactory.validate(request.authorization)
        try validateBackup(request.sourceSafetyBackup)
        try revalidateAuthority()

        let reservationPayload = try RuntimeGenerationControlCodec.encode(request.reservation)
        let leasePayload = try RuntimeGenerationControlCodec.encode(request.operationLease)
        let preparationPayload = try RuntimeGenerationControlCodec.encode(request.candidatePreparation)
        let runPayload = try RuntimeGenerationControlCodec.encode(request.migrationRun)
        let transitionPayload = try RuntimeGenerationControlCodec.encode(request.admittedTransition)
        let candidateReservationPayload = try RuntimeGenerationControlCodec.encode(candidateAuthorityReservation)
        return try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [
                    "runtime_generation_reservations",
                    "runtime_generation_operation_leases",
                    "runtime_generation_candidate_preparations",
                    "runtime_generation_migration_runs",
                    "runtime_generation_projection_rebuild_lifecycle_transitions",
                    "runtime_generation_projection_rebuild_candidate_reservations",
                ],
                reading: [
                    "runtime_generation_recovery_operation_plans",
                    "runtime_generation_recovery_operation_execution_claims",
                    "runtime_generation_recovery_operation_execution_receipts",
                    "runtime_generation_recovery_operation_consumptions",
                    "runtime_generation_recovery_operation_plan_dispositions",
                    "runtime_generation_recovery_authorizations",
                    "runtime_generation_quarantines",
                    "runtime_generation_backups",
                    "runtime_generation_backup_preparations",
                    "runtime_generation_backup_preparation_completions",
                    "runtime_generation_backup_preparation_consumptions",
                ]
            )
        ) { database in
            let now = try authorityNowMilliseconds()
            let existingReservation = try Self.loadOptionalPayload(RuntimeGenerationReservation.self, table: "runtime_generation_reservations", idColumn: "reservation_id", id: request.reservation.reservationID, database: database)
            let existingLease = try Self.loadOptionalPayload(RuntimeGenerationOperationLease.self, table: "runtime_generation_operation_leases", idColumn: "lease_id", id: request.operationLease.leaseID, database: database)
            let existingPreparation = try Self.loadOptionalPayload(RuntimeGenerationCandidatePreparationRecord.self, table: "runtime_generation_candidate_preparations", idColumn: "preparation_id", id: request.candidatePreparation.preparationID, database: database)
            let existingRun = try Self.loadOptionalPayload(RuntimeGenerationMigrationRun.self, table: "runtime_generation_migration_runs", idColumn: "migration_run_id", id: request.migrationRun.migrationRunID, database: database)
            let existingTransition = try Self.loadOptionalPayload(RuntimeGenerationProjectionRebuildLifecycleTransition.self, table: "runtime_generation_projection_rebuild_lifecycle_transitions", idColumn: "transition_id", id: request.admittedTransition.transitionID, database: database)
            let existingCandidateAuthorityReservation = try Self.loadOptionalPayload(RuntimeGenerationProjectionRebuildCandidateReservation.self, table: "runtime_generation_projection_rebuild_candidate_reservations", idColumn: "candidate_reservation_id", id: candidateAuthorityReservation.candidateReservationID, database: database)
            if existingReservation != nil || existingLease != nil || existingPreparation != nil || existingRun != nil || existingTransition != nil || existingCandidateAuthorityReservation != nil {
                guard existingReservation == request.reservation,
                      existingLease == request.operationLease,
                      existingPreparation == request.candidatePreparation,
                      existingRun == request.migrationRun,
                      existingTransition == request.admittedTransition,
                      existingCandidateAuthorityReservation == candidateAuthorityReservation else {
                    throw RuntimeGenerationControlError.recordConflict(kind: "projection_rebuild_admission", id: request.migrationRun.migrationRunID)
                }
                return RuntimeGenerationProjectionRebuildAdmissionRecords(reservation: request.reservation, operationLease: request.operationLease, candidatePreparation: request.candidatePreparation, migrationRun: request.migrationRun, admittedTransition: request.admittedTransition, candidateAuthorityReservation: candidateAuthorityReservation)
            }
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: request.plan.planID, database: database)
            let claim = try Self.loadPayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: request.claim.claimID, database: database)
            let quarantine = try Self.loadPayload(RuntimeGenerationQuarantineRecord.self, table: "runtime_generation_quarantines", idColumn: "quarantine_id", id: request.quarantine.quarantineID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: request.authorization.authorizationID, database: database)
            let dispositions = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let consumptions = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_consumptions WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let receipts = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let latestClaims = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            let latestClaim = try latestClaims.first.map { try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: $0) }
            let safetyBackup = try Self.loadEligibleBackup(id: request.sourceSafetyBackup.backupID, database: database)
            guard plan == request.plan,
                  claim == request.claim,
                  quarantine == request.quarantine,
                  authorization == request.authorization,
                  safetyBackup == request.sourceSafetyBackup,
                  latestClaim == claim,
                  plan.action == .rebuildDerivedState,
                  plan.quarantineID == quarantine.quarantineID,
                  plan.targetDigest == quarantine.quarantineDigest,
                  plan.recoveryAuthorizationID == authorization.authorizationID,
                  plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
                  claim.planID == plan.planID,
                  now >= plan.preparedAtMilliseconds,
                  now < plan.expiresAtMilliseconds,
                  now >= authorization.authorizedAtMilliseconds,
                  now < authorization.expiresAtMilliseconds,
                  now >= claim.claimedAtMilliseconds,
                  now < claim.expiresAtMilliseconds,
                  dispositions.isEmpty, consumptions.isEmpty, receipts.isEmpty,
                  quarantine.allowedActions.contains(.rebuildDerivedState),
                  authorization.action == .rebuildDerivedState,
                  authorization.targetDigest == quarantine.quarantineDigest,
                  authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
                  request.reservation.operationKind == .projectionRebuild,
                  request.reservation.sourceGenerationID == quarantine.originalGenerationID,
                  request.reservation.sourceGenerationDigest == quarantine.originalManifestDigest,
                  request.reservation.sourceGenerationID != nil,
                  request.reservation.expectedActiveManifestDigest != nil,
                  request.operationLease.reservationID == request.reservation.reservationID,
                  request.operationLease.leaseEpoch == 1,
                  request.operationLease.fencingToken == 1,
                  request.operationLease.priorLeaseDigest == nil,
                  request.operationLease.ownerInstanceID == claim.executorInstanceID,
                  request.operationLease.issuedAtMilliseconds >= request.reservation.createdAtMilliseconds,
                  request.operationLease.issuedAtMilliseconds <= now,
                  request.operationLease.expiresAtMilliseconds <= claim.expiresAtMilliseconds,
                  request.candidatePreparation.reservationID == request.reservation.reservationID,
                  request.candidatePreparation.operationLeaseID == request.operationLease.leaseID,
                  request.candidatePreparation.operationFencingToken == request.operationLease.fencingToken,
                  request.candidatePreparation.operationKind == .projectionRebuild,
                  request.candidatePreparation.candidateGenerationID == request.reservation.candidateGenerationID,
                  request.candidatePreparation.sourceGenerationID == request.reservation.sourceGenerationID,
                  request.candidatePreparation.sourceGenerationDigest == request.reservation.sourceGenerationDigest,
                  request.candidatePreparation.expectedActiveManifestDigest == request.reservation.expectedActiveManifestDigest,
                  request.candidatePreparation.recoveryExecutionPlanID == plan.planID,
                  request.candidatePreparation.recoveryExecutionClaimID == claim.claimID,
                  request.candidatePreparation.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  request.candidatePreparation.createdAtMilliseconds == request.reservation.createdAtMilliseconds,
                  request.migrationRun.reservationID == request.reservation.reservationID,
                  request.migrationRun.operationLeaseID == request.operationLease.leaseID,
                  request.migrationRun.operationLeaseEpoch == request.operationLease.leaseEpoch,
                  request.migrationRun.operationFencingToken == request.operationLease.fencingToken,
                  request.migrationRun.executorInstanceID == claim.executorInstanceID,
                  request.migrationRun.operationKind == .projectionRebuild,
                  request.migrationRun.candidateGenerationID == request.reservation.candidateGenerationID,
                  request.migrationRun.sourceSafetyBackupID == safetyBackup.backupID,
                  request.migrationRun.backupID == safetyBackup.backupID,
                  request.migrationRun.recoveryAuthorizationID == nil,
                  request.migrationRun.recoveryAuthorizationDigest == nil,
                  request.migrationRun.recoveryExecutionPlanID == plan.planID,
                  request.migrationRun.recoveryExecutionClaimID == claim.claimID,
                  request.migrationRun.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  request.migrationRun.startedAtMilliseconds >= request.reservation.createdAtMilliseconds,
                  request.migrationRun.completedAtMilliseconds == request.migrationRun.startedAtMilliseconds,
                  request.migrationRun.completedAtMilliseconds >= request.operationLease.issuedAtMilliseconds,
                  request.migrationRun.completedAtMilliseconds < request.operationLease.expiresAtMilliseconds,
                  safetyBackup.sourceGenerationID == request.reservation.sourceGenerationID,
                  safetyBackup.sourceGenerationDigest == request.reservation.sourceGenerationDigest,
                  safetyBackup.createdAtMilliseconds <= request.migrationRun.startedAtMilliseconds,
                  request.admittedTransition.migrationRunID == request.migrationRun.migrationRunID,
                  request.admittedTransition.recoveryExecutionPlanID == plan.planID,
                  request.admittedTransition.recoveryExecutionClaimID == claim.claimID,
                  request.admittedTransition.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  request.admittedTransition.phase == .admitted,
                  request.admittedTransition.priorTransitionDigest == nil,
                  request.admittedTransition.occurredAtMilliseconds >= request.operationLease.issuedAtMilliseconds,
                  request.admittedTransition.occurredAtMilliseconds < request.operationLease.expiresAtMilliseconds,
                  request.admittedTransition.occurredAtMilliseconds <= now,
                  candidateAuthorityReservation.recoveryExecutionPlanID == plan.planID,
                  candidateAuthorityReservation.recoveryExecutionClaimID == claim.claimID,
                  candidateAuthorityReservation.recoveryExecutionClaimEpoch == claim.claimEpoch,
                  candidateAuthorityReservation.migrationRunID == request.migrationRun.migrationRunID,
                  candidateAuthorityReservation.reservationID == request.reservation.reservationID,
                  candidateAuthorityReservation.candidatePreparationID == request.candidatePreparation.preparationID,
                  candidateAuthorityReservation.candidateGenerationID == request.reservation.candidateGenerationID,
                  candidateAuthorityReservation.reservedAtMilliseconds >= request.operationLease.issuedAtMilliseconds,
                  candidateAuthorityReservation.reservedAtMilliseconds < request.operationLease.expiresAtMilliseconds,
                  candidateAuthorityReservation.reservedAtMilliseconds <= now else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }

            try Self.executeImmutableInsert(database: database, table: "runtime_generation_reservations", idColumn: "reservation_id", id: request.reservation.reservationID, columns: [("operation_kind", .text(request.reservation.operationKind.rawValue)), ("candidate_generation_id", .text(request.reservation.candidateGenerationID.rawValue)), ("source_generation_id", request.reservation.sourceGenerationID.map { .text($0.rawValue) } ?? .null), ("source_generation_digest", request.reservation.sourceGenerationDigest.map(SQLiteBinding.text) ?? .null), ("expected_active_manifest_digest", request.reservation.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null), ("target_schema_version", .integer(Int64(request.reservation.targetSchemaVersion))), ("created_at_ms", .integer(request.reservation.createdAtMilliseconds)), ("reservation_digest", .text(request.reservation.reservationDigest))], payload: reservationPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: reservationPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_operation_leases", idColumn: "lease_id", id: request.operationLease.leaseID, columns: [("reservation_id", .text(request.operationLease.reservationID)), ("owner_instance_id", .text(request.operationLease.ownerInstanceID)), ("lease_epoch", .integer(request.operationLease.leaseEpoch)), ("fencing_token", .integer(request.operationLease.fencingToken)), ("prior_lease_digest", .null), ("issued_at_ms", .integer(request.operationLease.issuedAtMilliseconds)), ("expires_at_ms", .integer(request.operationLease.expiresAtMilliseconds)), ("lease_digest", .text(request.operationLease.leaseDigest))], payload: leasePayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: leasePayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_candidate_preparations", idColumn: "preparation_id", id: request.candidatePreparation.preparationID, columns: [("reservation_id", .text(request.candidatePreparation.reservationID)), ("operation_lease_id", .text(request.candidatePreparation.operationLeaseID)), ("operation_fencing_token", .integer(request.candidatePreparation.operationFencingToken)), ("operation_kind", .text(request.candidatePreparation.operationKind.rawValue)), ("candidate_generation_id", .text(request.candidatePreparation.candidateGenerationID.rawValue)), ("source_generation_id", request.candidatePreparation.sourceGenerationID.map { .text($0.rawValue) } ?? .null), ("source_generation_digest", request.candidatePreparation.sourceGenerationDigest.map(SQLiteBinding.text) ?? .null), ("expected_active_manifest_digest", request.candidatePreparation.expectedActiveManifestDigest.map(SQLiteBinding.text) ?? .null), ("staging_directory_name", .text(request.candidatePreparation.stagingDirectoryName)), ("created_at_ms", .integer(request.candidatePreparation.createdAtMilliseconds)), ("preparation_digest", .text(request.candidatePreparation.preparationDigest))], payload: preparationPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: preparationPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_migration_runs", idColumn: "migration_run_id", id: request.migrationRun.migrationRunID, columns: [("reservation_id", .text(request.migrationRun.reservationID)), ("executor_instance_id", .text(request.migrationRun.executorInstanceID)), ("operation_lease_id", .text(request.migrationRun.operationLeaseID)), ("operation_lease_epoch", .integer(request.migrationRun.operationLeaseEpoch)), ("operation_fencing_token", .integer(request.migrationRun.operationFencingToken)), ("source_safety_backup_id", request.migrationRun.sourceSafetyBackupID.map(SQLiteBinding.text) ?? .null), ("backup_id", request.migrationRun.backupID.map(SQLiteBinding.text) ?? .null), ("recovery_authorization_id", request.migrationRun.recoveryAuthorizationID.map(SQLiteBinding.text) ?? .null), ("recovery_authorization_digest", request.migrationRun.recoveryAuthorizationDigest.map(SQLiteBinding.text) ?? .null), ("recovery_execution_plan_id", request.migrationRun.recoveryExecutionPlanID.map(SQLiteBinding.text) ?? .null), ("recovery_execution_claim_id", request.migrationRun.recoveryExecutionClaimID.map(SQLiteBinding.text) ?? .null), ("recovery_execution_claim_epoch", request.migrationRun.recoveryExecutionClaimEpoch.map { .integer($0) } ?? .null), ("operation_kind", .text(request.migrationRun.operationKind.rawValue)), ("source_schema_version", request.migrationRun.sourceSchemaVersion.map { .integer(Int64($0)) } ?? .null), ("candidate_generation_id", .text(request.migrationRun.candidateGenerationID.rawValue)), ("target_schema_version", .integer(Int64(request.migrationRun.targetSchemaVersion))), ("transformation_version", .integer(Int64(request.migrationRun.transformationVersion))), ("provenance_digest", .text(request.migrationRun.provenanceDigest)), ("started_at_ms", .integer(request.migrationRun.startedAtMilliseconds)), ("completed_at_ms", .integer(request.migrationRun.completedAtMilliseconds)), ("run_digest", .text(request.migrationRun.runDigest))], payload: runPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: runPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_projection_rebuild_lifecycle_transitions", idColumn: "transition_id", id: request.admittedTransition.transitionID, columns: [("migration_run_id", .text(request.admittedTransition.migrationRunID)), ("recovery_execution_plan_id", .text(request.admittedTransition.recoveryExecutionPlanID)), ("recovery_execution_claim_id", .text(request.admittedTransition.recoveryExecutionClaimID)), ("recovery_execution_claim_epoch", .integer(request.admittedTransition.recoveryExecutionClaimEpoch)), ("phase", .text(request.admittedTransition.phase.rawValue)), ("prior_transition_digest", .null), ("reason_digest", .text(request.admittedTransition.reasonDigest)), ("occurred_at_ms", .integer(request.admittedTransition.occurredAtMilliseconds)), ("transition_digest", .text(request.admittedTransition.transitionDigest))], payload: transitionPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: transitionPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_projection_rebuild_candidate_reservations", idColumn: "candidate_reservation_id", id: candidateAuthorityReservation.candidateReservationID, columns: [("recovery_execution_plan_id", .text(plan.planID)), ("recovery_execution_claim_id", .text(claim.claimID)), ("recovery_execution_claim_epoch", .integer(claim.claimEpoch)), ("migration_run_id", .text(request.migrationRun.migrationRunID)), ("reservation_id", .text(request.reservation.reservationID)), ("candidate_preparation_id", .text(request.candidatePreparation.preparationID)), ("candidate_generation_id", .text(request.reservation.candidateGenerationID.rawValue)), ("expected_verification_id", .text(candidateAuthorityReservation.expectedVerificationID)), ("expected_activation_intent_id", .text(candidateAuthorityReservation.expectedActivationIntentID)), ("reserved_at_ms", .integer(candidateAuthorityReservation.reservedAtMilliseconds)), ("reservation_digest", .text(candidateAuthorityReservation.reservationDigest))], payload: candidateReservationPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: candidateReservationPayload))
            return RuntimeGenerationProjectionRebuildAdmissionRecords(reservation: request.reservation, operationLease: request.operationLease, candidatePreparation: request.candidatePreparation, migrationRun: request.migrationRun, admittedTransition: request.admittedTransition, candidateAuthorityReservation: candidateAuthorityReservation)
        }
    }

    private static func allowsProjectionRebuildTransition(from: RuntimeGenerationProjectionRebuildPhase, to: RuntimeGenerationProjectionRebuildPhase) -> Bool {
        switch (from, to) {
        case (.admitted, .running), (.admitted, .blockedRetryable), (.admitted, .failedTerminal), (.running, .blockedRetryable), (.running, .readyForCertification), (.running, .failedTerminal), (.blockedRetryable, .running), (.blockedRetryable, .failedTerminal), (.readyForCertification, .completed), (.readyForCertification, .failedTerminal): return true
        default: return false
        }
    }

    func latestProjectionRebuildLifecycleTransition(
        migrationRunID: String
    ) async throws -> RuntimeGenerationProjectionRebuildLifecycleTransition? {
        try RuntimeGenerationControlValidation.requireIdentifier(
            migrationRunID, field: "projection_rebuild_transition_run_id"
        )
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2",
                bindings: [.text(migrationRunID)], maximumDecodedBytes: Self.maximumControlReadBytes
            )
            return try rows.first.map {
                try Self.decodePayload(
                    RuntimeGenerationProjectionRebuildLifecycleTransition.self, row: $0
                )
            }
        }
    }

    /// Returns the one immutable, post-certification candidate commitment for
    /// a rebuild run. Absence is an explicit pending state; callers must not
    /// infer candidate authority from preparation records alone.
    func projectionRebuildCandidateAuthorityCommitment(
        migrationRunID: String
    ) async throws -> RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment? {
        try RuntimeGenerationControlValidation.requireIdentifier(
            migrationRunID, field: "projection_rebuild_candidate_commitment_run_id"
        )
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_projection_rebuild_candidate_authority_commitments WHERE migration_run_id = ? LIMIT 2",
                bindings: [.text(migrationRunID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "projection_rebuild_candidate_commitment",
                    id: migrationRunID
                )
            }
            return try rows.first.map {
                try Self.decodePayload(
                    RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                    row: $0
                )
            }
        }
    }

    func projectionRebuildCandidateAuthorityCommitment(
        recoveryExecutionPlanID: String
    ) async throws -> RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment? {
        try RuntimeGenerationControlValidation.requireIdentifier(
            recoveryExecutionPlanID,
            field: "projection_rebuild_candidate_commitment_plan_id"
        )
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_projection_rebuild_candidate_authority_commitments WHERE recovery_execution_plan_id = ? LIMIT 2",
                bindings: [.text(recoveryExecutionPlanID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "projection_rebuild_candidate_commitment",
                    id: recoveryExecutionPlanID
                )
            }
            return try rows.first.map {
                try Self.decodePayload(
                    RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment.self,
                    row: $0
                )
            }
        }
    }

    /// Atomically records the typed execution outcome and consumes the
    /// one-shot recovery plan. The receipt is the result authority; callers
    /// must not use the older opaque consumption API for new execution paths.
    func finalizeRecoveryOperationExecution(
        receipt: RuntimeGenerationRecoveryOperationExecutionReceipt,
        consumption: RuntimeGenerationRecoveryOperationConsumption,
        completedProjectionRebuildTransition: RuntimeGenerationProjectionRebuildLifecycleTransition? = nil
    ) async throws {
        try receipt.validate()
        try consumption.validate()
        try completedProjectionRebuildTransition?.validate()
        try revalidateAuthority()
        let receiptPayload = try RuntimeGenerationControlCodec.encode(receipt)
        let consumptionPayload = try RuntimeGenerationControlCodec.encode(consumption)
        let completedTransitionPayload = try completedProjectionRebuildTransition.map {
            try RuntimeGenerationControlCodec.encode($0)
        }
        try await database.transaction(.immediate, writeAuthorization: try Self.mutationAuthorization(
            writing: ["runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_consumptions", "runtime_generation_projection_rebuild_lifecycle_transitions"],
            reading: [
                "runtime_generation_recovery_operation_plans",
                "runtime_generation_recovery_operation_execution_claims",
                "runtime_generation_recovery_operation_execution_receipts",
                "runtime_generation_recovery_operation_consumptions",
                "runtime_generation_recovery_operation_plan_dispositions",
                "runtime_generation_recovery_authorizations",
                "runtime_generation_quarantines",
                "runtime_generation_verifications",
                "runtime_generation_recovery_operation_verification_bindings",
                "runtime_generation_rebuilds",
                "runtime_generation_migration_runs",
                "runtime_generation_projection_rebuild_lifecycle_transitions",
            ]
        )) { database in
            let controlNowMilliseconds = try authorityNowMilliseconds()
            let plan = try Self.loadPayload(RuntimeGenerationRecoveryOperationPlan.self, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: receipt.planID, database: database)
            let dispositionRows = try database.query("SELECT plan_id FROM runtime_generation_recovery_operation_plan_dispositions WHERE plan_id = ? LIMIT 2", bindings: [.text(receipt.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard dispositionRows.isEmpty else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let claim = try Self.loadPayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: receipt.claimID, database: database)
            let quarantine = try Self.loadPayload(RuntimeGenerationQuarantineRecord.self, table: "runtime_generation_quarantines", idColumn: "quarantine_id", id: receipt.quarantineID, database: database)
            let authorization = try Self.loadPayload(RuntimeGenerationRecoveryAuthorization.self, table: "runtime_generation_recovery_authorizations", idColumn: "authorization_id", id: receipt.recoveryAuthorizationID, database: database)
            let latestClaims = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard latestClaims.count == 1,
                  try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestClaims[0]) == claim,
                  receipt.planID == plan.planID,
                  receipt.claimEpoch == claim.claimEpoch,
                  claim.planID == plan.planID,
                  receipt.quarantineID == plan.quarantineID,
                  receipt.recoveryAuthorizationID == plan.recoveryAuthorizationID,
                  receipt.recoveryAuthorizationDigest == plan.recoveryAuthorizationDigest,
                  receipt.action == plan.action,
                  receipt.targetDigest == plan.targetDigest,
                  consumption.planID == plan.planID,
                  consumption.recoveryAuthorizationID == plan.recoveryAuthorizationID,
                  consumption.action == plan.action,
                  consumption.targetDigest == plan.targetDigest,
                  consumption.resultDigest == receipt.receiptDigest,
                  receipt.executedAtMilliseconds >= claim.claimedAtMilliseconds,
                  receipt.executedAtMilliseconds <= controlNowMilliseconds,
                  receipt.executedAtMilliseconds < claim.expiresAtMilliseconds,
                  controlNowMilliseconds < claim.expiresAtMilliseconds,
                  controlNowMilliseconds < plan.expiresAtMilliseconds,
                  controlNowMilliseconds < authorization.expiresAtMilliseconds,
                  consumption.consumedAtMilliseconds >= receipt.executedAtMilliseconds,
                  consumption.consumedAtMilliseconds <= controlNowMilliseconds,
                  quarantine.quarantineDigest == plan.targetDigest,
                  quarantine.allowedActions.contains(plan.action),
                  authorization.action == plan.action,
                  authorization.targetDigest == plan.targetDigest,
                  authorization.authorizationDigest == plan.recoveryAuthorizationDigest else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            if let candidateGenerationID = receipt.candidateGenerationID {
                if plan.action == .rebuildDerivedState {
                    guard let rebuildID = receipt.rebuildID,
                          let rebuild = try? Self.loadPayload(
                            RuntimeGenerationRebuildRecord.self,
                            table: "runtime_generation_rebuilds",
                            idColumn: "rebuild_id", id: rebuildID, database: database
                          ),
                          candidateGenerationID == rebuild.candidateGenerationID else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                } else {
                    guard candidateGenerationID == quarantine.originalGenerationID else {
                        throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                    }
                }
            }
            if let verificationID = receipt.verificationID {
                let verification = try Self.loadPayload(RuntimeGenerationVerificationReport.self, table: "runtime_generation_verifications", idColumn: "verification_id", id: verificationID, database: database)
                let binding = try Self.loadPayload(RuntimeGenerationRecoveryOperationVerificationBinding.self, table: "runtime_generation_recovery_operation_verification_bindings", idColumn: "verification_id", id: verificationID, database: database)
                guard receipt.verificationReportDigest == verification.reportDigest,
                      receipt.verificationAccepted == verification.accepted,
                      receipt.candidateGenerationID == verification.candidateGenerationID,
                      binding.verificationReportDigest == verification.reportDigest,
                      binding.planID == plan.planID,
                      binding.claimID == claim.claimID,
                      binding.claimEpoch == claim.claimEpoch,
                      binding.candidateGenerationID == verification.candidateGenerationID,
                      binding.observedAtMilliseconds <= receipt.executedAtMilliseconds else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
            }
            if let rebuildID = receipt.rebuildID {
                let rebuild = try Self.loadPayload(RuntimeGenerationRebuildRecord.self, table: "runtime_generation_rebuilds", idColumn: "rebuild_id", id: rebuildID, database: database)
                guard receipt.rebuildDigest == rebuild.rebuildDigest,
                      receipt.candidateGenerationID == rebuild.candidateGenerationID else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
            }
            if let completed = completedProjectionRebuildTransition {
                guard let rebuildID = receipt.rebuildID,
                      let rebuildDigest = receipt.rebuildDigest else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
                let rebuild = try Self.loadPayload(
                    RuntimeGenerationRebuildRecord.self,
                    table: "runtime_generation_rebuilds",
                    idColumn: "rebuild_id", id: rebuildID, database: database
                )
                let transitions = try database.query(
                    "SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 2",
                    bindings: [.text(rebuild.migrationRunID)],
                    maximumDecodedBytes: Self.maximumControlReadBytes
                )
                let latest = try transitions.first.map {
                    try Self.decodePayload(
                        RuntimeGenerationProjectionRebuildLifecycleTransition.self,
                        row: $0
                    )
                }
                guard transitions.count == 1,
                      let latest,
                      rebuild.rebuildDigest == rebuildDigest,
                      completed.migrationRunID == rebuild.migrationRunID,
                      completed.recoveryExecutionPlanID == receipt.planID,
                      completed.recoveryExecutionClaimID == receipt.claimID,
                      completed.recoveryExecutionClaimEpoch == receipt.claimEpoch,
                      completed.phase == .completed,
                      latest.phase == .readyForCertification,
                      completed.priorTransitionDigest == latest.transitionDigest,
                      completed.occurredAtMilliseconds >= receipt.executedAtMilliseconds,
                      completed.transitionID != latest.transitionID else {
                    throw RuntimeGenerationControlError.recoveryAuthorizationRequired
                }
            }
            let existingReceipt = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_receipts WHERE plan_id = ? LIMIT 2", bindings: [.text(plan.planID)], maximumDecodedBytes: Self.maximumControlReadBytes)
            guard existingReceipt.isEmpty else { throw RuntimeGenerationControlError.recordConflict(kind: "recovery_execution_receipt", id: plan.planID) }
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_execution_receipts", idColumn: "receipt_id", id: receipt.receiptID,
                columns: [("plan_id", .text(receipt.planID)), ("claim_id", .text(receipt.claimID)), ("claim_epoch", .integer(receipt.claimEpoch)), ("quarantine_id", .text(receipt.quarantineID)), ("candidate_generation_id", receipt.candidateGenerationID.map { .text($0.rawValue) } ?? .null), ("recovery_authorization_id", .text(receipt.recoveryAuthorizationID)), ("recovery_authorization_digest", .text(receipt.recoveryAuthorizationDigest)), ("action", .text(receipt.action.rawValue)), ("target_digest", .text(receipt.targetDigest)), ("verification_id", receipt.verificationID.map { .text($0) } ?? .null), ("verification_report_digest", receipt.verificationReportDigest.map { .text($0) } ?? .null), ("verification_accepted", receipt.verificationAccepted.map { .integer($0 ? 1 : 0) } ?? .null), ("authority_classification", .text(receipt.authorityClassification.rawValue)), ("rebuild_id", receipt.rebuildID.map { .text($0) } ?? .null), ("rebuild_digest", receipt.rebuildDigest.map { .text($0) } ?? .null), ("outcome_evidence_digest", .text(receipt.outcomeEvidenceDigest)), ("executed_at_ms", .integer(receipt.executedAtMilliseconds)), ("receipt_digest", .text(receipt.receiptDigest))], payload: receiptPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: receiptPayload))
            try Self.executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_consumptions", idColumn: "plan_id", id: consumption.planID,
                columns: [("recovery_authorization_id", .text(consumption.recoveryAuthorizationID)), ("action", .text(consumption.action.rawValue)), ("target_digest", .text(consumption.targetDigest)), ("result_digest", .text(consumption.resultDigest)), ("consumed_at_ms", .integer(consumption.consumedAtMilliseconds)), ("consumption_digest", .text(consumption.consumptionDigest))], payload: consumptionPayload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: consumptionPayload))
            if let completed = completedProjectionRebuildTransition,
               let completedTransitionPayload {
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_projection_rebuild_lifecycle_transitions",
                    idColumn: "transition_id", id: completed.transitionID,
                    columns: [
                        ("migration_run_id", .text(completed.migrationRunID)),
                        ("recovery_execution_plan_id", .text(completed.recoveryExecutionPlanID)),
                        ("recovery_execution_claim_id", .text(completed.recoveryExecutionClaimID)),
                        ("recovery_execution_claim_epoch", .integer(completed.recoveryExecutionClaimEpoch)),
                        ("phase", .text(completed.phase.rawValue)),
                        ("prior_transition_digest", completed.priorTransitionDigest.map(SQLiteBinding.text) ?? .null),
                        ("reason_digest", .text(completed.reasonDigest)),
                        ("occurred_at_ms", .integer(completed.occurredAtMilliseconds)),
                        ("transition_digest", .text(completed.transitionDigest)),
                    ],
                    payload: completedTransitionPayload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: completedTransitionPayload)
                )
            }
        }
    }

    /// Persists the single exact authorization observation used for selector
    /// publication. Recording is permitted only while authorization is live,
    /// unconsumed, and has the required remaining validity margin.
    func recordRecoveryPrecommitWitness(
        _ witness: RuntimeGenerationRecoveryPrecommitWitness,
        expectedAuthorization: RuntimeGenerationRecoveryAuthorization
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(witness)
        try expectedAuthorization.validate()
        guard witness.minimumRemainingValidityMilliseconds > 0,
              witness.observedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try revalidateAuthority()
        let payload = try RuntimeGenerationControlCodec.encode(witness)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: ["runtime_generation_recovery_precommit_witnesses"],
                reading: [
                    "runtime_generation_activation_intents",
                    "runtime_generation_migration_runs",
                    "runtime_generation_recovery_authorizations",
                    "runtime_generation_restore_baselines",
                    "runtime_generation_recovery_authorization_consumptions",
                    "runtime_generation_recovery_precommit_witnesses",
                ]
            )
        ) { database in
            let intent = try Self.loadPayload(
                RuntimeGenerationActivationIntent.self,
                table: "runtime_generation_activation_intents",
                idColumn: "intent_id",
                id: witness.activationIntentID,
                database: database
            )
            let run = try Self.loadPayload(
                RuntimeGenerationMigrationRun.self,
                table: "runtime_generation_migration_runs",
                idColumn: "migration_run_id",
                id: witness.migrationRunID,
                database: database
            )
            let authorization = try Self.loadPayload(
                RuntimeGenerationRecoveryAuthorization.self,
                table: "runtime_generation_recovery_authorizations",
                idColumn: "authorization_id",
                id: witness.recoveryAuthorizationID,
                database: database
            )
            let plans = try database.query(
                "SELECT * FROM runtime_generation_restore_baselines WHERE plan_digest = ? LIMIT 2",
                bindings: [.text(witness.resultDigest)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            let consumptions = try database.query(
                "SELECT authorization_id FROM runtime_generation_recovery_authorization_consumptions WHERE authorization_id = ? LIMIT 2",
                bindings: [.text(witness.recoveryAuthorizationID)],
                maximumDecodedBytes: Self.maximumControlReadBytes
            )
            guard authorization == expectedAuthorization,
                  plans.count == 1,
                  consumptions.isEmpty,
                  intent.intentID == witness.witnessID,
                  intent.candidateGenerationID == witness.candidateGenerationID,
                  intent.candidateSelectorFileSHA256 == witness.candidateSelectorFileSHA256,
                  run.candidateGenerationID == witness.candidateGenerationID,
                  run.recoveryAuthorizationID == witness.recoveryAuthorizationID,
                  run.recoveryAuthorizationDigest == witness.recoveryAuthorizationDigest,
                  authorization.authorizationDigest == witness.recoveryAuthorizationDigest,
                  authorization.targetDigest == witness.recoveryTargetDigest,
                  witness.observedAtMilliseconds >= authorization.authorizedAtMilliseconds,
                  witness.observedAtMilliseconds < authorization.expiresAtMilliseconds,
                  authorization.expiresAtMilliseconds - witness.observedAtMilliseconds >=
                    witness.minimumRemainingValidityMilliseconds,
                  try Self.decodePayload(
                    RuntimeGenerationRestoreBaselinePlan.self, row: plans[0]
                  ).targetGenerationID == witness.candidateGenerationID else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            try Self.executeImmutableInsert(
                database: database,
                table: "runtime_generation_recovery_precommit_witnesses",
                idColumn: "witness_id",
                id: witness.witnessID,
                columns: [
                    ("activation_intent_id", .text(witness.activationIntentID)),
                    ("migration_run_id", .text(witness.migrationRunID)),
                    ("candidate_generation_id", .text(witness.candidateGenerationID.rawValue)),
                    ("candidate_selector_file_sha256", .text(witness.candidateSelectorFileSHA256)),
                    ("recovery_authorization_id", .text(witness.recoveryAuthorizationID)),
                    ("recovery_authorization_digest", .text(witness.recoveryAuthorizationDigest)),
                    ("recovery_target_digest", .text(witness.recoveryTargetDigest)),
                    ("result_digest", .text(witness.resultDigest)),
                    ("observed_at_ms", .integer(witness.observedAtMilliseconds)),
                    ("minimum_remaining_validity_ms", .integer(witness.minimumRemainingValidityMilliseconds)),
                    ("witness_digest", .text(witness.witnessDigest)),
                ],
                payload: payload,
                payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
            )
        }
    }

    func generation(
        id: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationAuthorityManifest {
        (try await generationRecord(id: id)).authorityManifest
    }

    func generationRecord(
        id: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationCandidateRecord {
        try await load(
            RuntimeGenerationCandidateRecord.self,
            table: "runtime_generation_records",
            idColumn: "generation_id",
            id: id.rawValue
        )
    }

    func migrationRun(id: String) async throws -> RuntimeGenerationMigrationRun {
        try await load(
            RuntimeGenerationMigrationRun.self,
            table: "runtime_generation_migration_runs",
            idColumn: "migration_run_id",
            id: id
        )
    }

    func backup(id: String) async throws -> RuntimeGenerationBackupRecord {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            try Self.loadEligibleBackup(id: id, database: database)
        }
    }

    /// Selects the newest *eligible* safety backup for one exact source
    /// generation lineage. Selection remains in the control authority; callers
    /// cannot nominate an arbitrary backup for recovery admission.
    func latestEligibleBackup(
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceGenerationDigest: String
    ) async throws -> RuntimeGenerationBackupRecord {
        try RuntimeGenerationControlValidation.requireDigest(
            sourceGenerationDigest,
            field: "latest_eligible_backup_source_digest"
        )
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let pageSize = 64
            let maximumPages = 1_024
            let maximumCandidates = 65_536
            let maximumDecodedIndexBytes = Self.maximumControlReadBytes
            var cursor: (createdAt: Int64, backupID: String)?
            var pageCount = 0
            var candidateCount = 0
            var decodedIndexBytes = 0
            while true {
                try Task.checkCancellation()
                var bindings: [SQLiteBinding] = [
                    .text(sourceGenerationID.rawValue), .text(sourceGenerationDigest),
                ]
                let predicate: String
                if let cursor {
                    predicate = "AND (created_at_ms < ? OR (created_at_ms = ? AND backup_id < ?))"
                    bindings += [.integer(cursor.createdAt), .integer(cursor.createdAt), .text(cursor.backupID)]
                } else { predicate = "" }
                bindings.append(.integer(Int64(pageSize)))
                let rows = try database.query(
                    "SELECT backup_id, created_at_ms FROM runtime_generation_backups WHERE source_generation_id = ? AND source_generation_digest = ? \(predicate) ORDER BY created_at_ms DESC, backup_id DESC LIMIT ?",
                    bindings: bindings, maximumDecodedBytes: Self.maximumControlReadBytes
                )
                pageCount += 1
                guard rows.isEmpty == false else { break }
                guard pageCount <= maximumPages else {
                    throw RuntimeGenerationControlError.resourcePolicyExceeded(
                        resource: "latest_eligible_backup_pages", maximum: Int64(maximumPages)
                    )
                }
                for row in rows {
                    try Task.checkCancellation()
                    guard case let .text(backupID)? = row.value(named: "backup_id"),
                          case let .integer(createdAt)? = row.value(named: "created_at_ms") else {
                        throw RuntimeGenerationControlError.recordCorrupt(kind: "backup_index", id: sourceGenerationID.rawValue)
                    }
                    candidateCount += 1
                    decodedIndexBytes += backupID.utf8.count + MemoryLayout<Int64>.size
                    guard candidateCount <= maximumCandidates else {
                        throw RuntimeGenerationControlError.resourcePolicyExceeded(resource: "latest_eligible_backup_candidates", maximum: Int64(maximumCandidates))
                    }
                    guard decodedIndexBytes <= maximumDecodedIndexBytes else {
                        throw RuntimeGenerationControlError.resourcePolicyExceeded(resource: "latest_eligible_backup_decoded_index_bytes", maximum: Int64(maximumDecodedIndexBytes))
                    }
                    cursor = (createdAt, backupID)
                    do { return try Self.loadEligibleBackup(id: backupID, database: database) }
                    // AMBitionsAllowWeakPattern(reason: "Missing backup row advances bounded eligibility scan without false success")
                    catch RuntimeGenerationControlError.recordMissing(_, _) { continue }
                }
            }
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
    }

    func recoveryAuthorization(
        id: String
    ) async throws -> RuntimeGenerationRecoveryAuthorization {
        try await load(
            RuntimeGenerationRecoveryAuthorization.self,
            table: "runtime_generation_recovery_authorizations",
            idColumn: "authorization_id",
            id: id
        )
    }

    func restoreBaselinePlan(
        targetGenerationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationRestoreBaselinePlan {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_restore_baselines WHERE target_generation_id = ? LIMIT 2",
                bindings: [.text(targetGenerationID.rawValue)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.recordMissing(
                    kind: "restore_baseline_for_target",
                    id: targetGenerationID.rawValue
                )
            }
            return try Self.decodePayload(
                RuntimeGenerationRestoreBaselinePlan.self, row: rows[0]
            )
        }
    }

    func restoreBaselinePlan(
        id: String
    ) async throws -> RuntimeGenerationRestoreBaselinePlan {
        try await load(
            RuntimeGenerationRestoreBaselinePlan.self,
            table: "runtime_generation_restore_baselines",
            idColumn: "plan_id",
            id: id
        )
    }

    func rollback(id: String) async throws -> RuntimeGenerationRollbackRecord {
        try await load(
            RuntimeGenerationRollbackRecord.self,
            table: "runtime_generation_rollbacks",
            idColumn: "rollback_id",
            id: id
        )
    }

    func recoveryAuthorizationWasConsumed(id: String) async throws -> Bool {
        try revalidateAuthority()
        let rows = try await database.query(
            "SELECT authorization_id FROM runtime_generation_recovery_authorization_consumptions WHERE authorization_id = ? LIMIT 2",
            bindings: [.text(id)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "recovery_authorization_consumption", id: id
            )
        }
        return rows.isEmpty == false
    }

    func quarantine(id: String) async throws -> RuntimeGenerationQuarantineRecord {
        try await load(
            RuntimeGenerationQuarantineRecord.self,
            table: "runtime_generation_quarantines",
            idColumn: "quarantine_id",
            id: id
        )
    }

    func createForensicSnapshot(
        at destinationURL: URL,
        relativePath: String
    ) async throws -> RuntimeGenerationObservedArtifact {
        try revalidateAuthority()
        _ = try await database.backup(
            to: destinationURL,
            prepareReservedDestination: { _, _, descriptor in
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    toOpenFileDescriptor: descriptor,
                    artifact: "generation_control_forensic_snapshot_reserved"
                )
            }
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: destinationURL,
            artifact: "generation_control_forensic_snapshot"
        )
        try RuntimeStoreFileDurability.synchronizeFile(at: destinationURL)
        return try RuntimeGenerationDatabaseAuthority.artifact(
            at: destinationURL,
            relativePath: relativePath
        )
    }

    func reservation(id: String) async throws -> RuntimeGenerationReservation {
        try await load(
            RuntimeGenerationReservation.self,
            table: "runtime_generation_reservations",
            idColumn: "reservation_id",
            id: id
        )
    }

    func verification(id: String) async throws -> RuntimeGenerationVerificationReport {
        try await load(
            RuntimeGenerationVerificationReport.self,
            table: "runtime_generation_verifications",
            idColumn: "verification_id",
            id: id
        )
    }

    func activationIntent(id: String) async throws -> RuntimeGenerationActivationIntent {
        try await load(
            RuntimeGenerationActivationIntent.self,
            table: "runtime_generation_activation_intents",
            idColumn: "intent_id",
            id: id
        )
    }

    func activationIntent(
        candidateGenerationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationActivationIntent {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_activation_intents WHERE candidate_generation_id = ? LIMIT 2",
                bindings: [.text(candidateGenerationID.rawValue)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count == 1 else {
                throw RuntimeGenerationControlError.recordMissing(
                    kind: "activation_intent_for_candidate",
                    id: candidateGenerationID.rawValue
                )
            }
            return try Self.decodePayload(
                RuntimeGenerationActivationIntent.self,
                row: rows[0]
            )
        }
    }

    func activationConsumption(
        intentID: String
    ) async throws -> RuntimeGenerationActivationConsumption? {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT * FROM runtime_generation_activation_consumptions WHERE intent_id = ? LIMIT 2",
                bindings: [.text(intentID)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            guard rows.count <= 1 else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "activation_consumption",
                    id: intentID
                )
            }
            return try rows.first.map {
                try Self.decodePayload(
                    RuntimeGenerationActivationConsumption.self,
                    row: $0
                )
            }
        }
    }
}

private extension RuntimeGenerationControlStore {
    nonisolated static func checkedIncrement(_ value: Int) throws -> Int {
        let result = value.addingReportingOverflow(1)
        guard result.overflow == false else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        return result.partialValue
    }

    static func reviewDecision(
        _ decision: RuntimeLegacyImportReviewDecision,
        isValidFor item: RuntimeLegacyImportItem
    ) -> Bool {
        switch decision {
        case .retainForFutureMigration:
            item.disposition == .reviewableDiscovery && item.lossiness == .none
        case .retainLossyForFutureMigration:
            item.disposition == .reviewableDiscovery && item.lossiness != .none
        case .reject:
            true
        }
    }

    func revalidateAuthority() throws {
        guard case .open = lifecycle,
              let controlLockDescriptor else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        try rootAuthority.revalidatePinnedRoot()
        try controlDirectoryPin.revalidate()
        try pinnedFiles.validate(databaseURL: databaseURL)
        var status = stat()
        guard fstat(controlLockDescriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFREG,
              status.st_nlink == 1 else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
    }

    func authorityNowMilliseconds() throws -> Int64 {
        let value = environment.clock.now.timeIntervalSince1970 * 1_000
        guard value.isFinite, value >= 0, value <= Double(Int64.max) else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        return Int64(value.rounded(.towardZero))
    }

    static let tableStatements: [String] = [
        """
        CREATE TABLE runtime_generation_control_metadata (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            schema_version INTEGER NOT NULL CHECK (schema_version = 10),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        )
        """,
        """
        CREATE TABLE runtime_generation_reservations (
            reservation_id TEXT PRIMARY KEY,
            operation_kind TEXT NOT NULL,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            source_generation_id TEXT,
            source_generation_digest TEXT,
            expected_active_manifest_digest TEXT,
            target_schema_version INTEGER NOT NULL CHECK (target_schema_version = 8),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            reservation_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            CHECK ((source_generation_id IS NULL) = (source_generation_digest IS NULL))
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_operation_leases (
            lease_id TEXT PRIMARY KEY,
            reservation_id TEXT NOT NULL,
            owner_instance_id TEXT NOT NULL,
            lease_epoch INTEGER NOT NULL CHECK (lease_epoch > 0),
            fencing_token INTEGER NOT NULL CHECK (fencing_token > 0),
            prior_lease_digest TEXT,
            issued_at_ms INTEGER NOT NULL CHECK (issued_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > issued_at_ms),
            lease_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE (reservation_id, lease_epoch),
            UNIQUE (reservation_id, fencing_token, owner_instance_id, lease_epoch),
            FOREIGN KEY (reservation_id)
              REFERENCES runtime_generation_reservations(reservation_id),
            CHECK ((lease_epoch = 1) = (prior_lease_digest IS NULL))
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_backup_preparations (
            preparation_id TEXT PRIMARY KEY,
            backup_id TEXT NOT NULL UNIQUE,
            reservation_id TEXT NOT NULL UNIQUE,
            operation_lease_id TEXT NOT NULL UNIQUE,
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            source_generation_id TEXT NOT NULL,
            source_generation_digest TEXT NOT NULL,
            expected_active_manifest_digest TEXT NOT NULL,
            hidden_directory_name TEXT NOT NULL UNIQUE,
            final_directory_name TEXT NOT NULL UNIQUE,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            preparation_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_backup_preparation_completions (
            preparation_id TEXT PRIMARY KEY,
            backup_id TEXT NOT NULL UNIQUE,
            backup_digest TEXT NOT NULL UNIQUE,
            directory_device INTEGER NOT NULL,
            directory_inode INTEGER NOT NULL,
            interior_artifact_count INTEGER NOT NULL CHECK (interior_artifact_count > 0),
            interior_byte_count INTEGER NOT NULL CHECK (interior_byte_count >= 0),
            interior_inventory_digest TEXT NOT NULL,
            durability_witness_digest TEXT NOT NULL,
            completed_at_ms INTEGER NOT NULL CHECK (completed_at_ms >= 0),
            completion_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_backup_preparations(preparation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_backups (
            backup_id TEXT PRIMARY KEY,
            preparation_id TEXT NOT NULL UNIQUE,
            source_generation_id TEXT NOT NULL,
            source_generation_digest TEXT NOT NULL,
            source_fence_digest TEXT NOT NULL,
            authority_fence_token_digest TEXT NOT NULL,
            backup_digest TEXT NOT NULL UNIQUE,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_backup_preparations(preparation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_backup_preparation_consumptions (
            preparation_id TEXT PRIMARY KEY,
            backup_id TEXT NOT NULL UNIQUE,
            operation_lease_id TEXT NOT NULL,
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            final_directory_device INTEGER NOT NULL,
            final_directory_inode INTEGER NOT NULL,
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            consumption_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_backup_preparations(preparation_id),
            FOREIGN KEY (backup_id) REFERENCES runtime_generation_backups(backup_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_backup_preparation_recoveries (
            preparation_id TEXT PRIMARY KEY,
            operation_lease_id TEXT NOT NULL,
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            classification TEXT NOT NULL,
            recovered_at_ms INTEGER NOT NULL CHECK (recovered_at_ms >= 0),
            recovery_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_backup_preparations(preparation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_candidate_preparations (
            preparation_id TEXT PRIMARY KEY,
            reservation_id TEXT NOT NULL UNIQUE,
            operation_lease_id TEXT NOT NULL UNIQUE,
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            operation_kind TEXT NOT NULL,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            source_generation_id TEXT,
            source_generation_digest TEXT,
            expected_active_manifest_digest TEXT,
            staging_directory_name TEXT NOT NULL UNIQUE,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            preparation_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id),
            CHECK ((source_generation_id IS NULL) = (source_generation_digest IS NULL))
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_candidate_preparation_completions (
            preparation_id TEXT PRIMARY KEY,
            candidate_record_digest TEXT NOT NULL UNIQUE,
            directory_device INTEGER NOT NULL,
            directory_inode INTEGER NOT NULL,
            interior_artifact_count INTEGER NOT NULL CHECK (interior_artifact_count = 2),
            interior_byte_count INTEGER NOT NULL CHECK (interior_byte_count >= 0),
            interior_inventory_digest TEXT NOT NULL,
            durability_witness_digest TEXT NOT NULL,
            completed_at_ms INTEGER NOT NULL CHECK (completed_at_ms >= 0),
            completion_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_candidate_preparations(preparation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_candidate_preparation_dispositions (
            preparation_id TEXT PRIMARY KEY,
            operation_lease_id TEXT NOT NULL,
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            kind TEXT NOT NULL,
            failure_classification TEXT,
            authority_digest TEXT NOT NULL,
            disposed_at_ms INTEGER NOT NULL CHECK (disposed_at_ms >= 0),
            disposition_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_candidate_preparations(preparation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_candidate_replay_audits (
            audit_id TEXT PRIMARY KEY,
            preparation_id TEXT NOT NULL UNIQUE,
            reservation_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            operation_lease_id TEXT NOT NULL,
            operation_lease_epoch INTEGER NOT NULL CHECK (operation_lease_epoch > 0),
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            outcome TEXT NOT NULL,
            blocked_invariant TEXT,
            replay_checkpoint_digest TEXT,
            replay_certificate_digest TEXT,
            reconstruction_digest TEXT,
            audited_at_ms INTEGER NOT NULL CHECK (audited_at_ms >= 0),
            audit_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (preparation_id) REFERENCES runtime_generation_candidate_preparations(preparation_id),
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_migration_runs (
            migration_run_id TEXT PRIMARY KEY,
            executor_instance_id TEXT NOT NULL,
            reservation_id TEXT NOT NULL UNIQUE,
            operation_lease_id TEXT NOT NULL UNIQUE,
            operation_lease_epoch INTEGER NOT NULL CHECK (operation_lease_epoch > 0),
            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),
            source_safety_backup_id TEXT,
            backup_id TEXT,
            recovery_authorization_id TEXT UNIQUE,
            recovery_authorization_digest TEXT UNIQUE,
            recovery_execution_plan_id TEXT,
            recovery_execution_claim_id TEXT,
            recovery_execution_claim_epoch INTEGER,
            operation_kind TEXT NOT NULL,
            source_schema_version INTEGER,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            target_schema_version INTEGER NOT NULL CHECK (target_schema_version = 8),
            transformation_version INTEGER NOT NULL CHECK (transformation_version > 0),
            provenance_digest TEXT NOT NULL UNIQUE,
            started_at_ms INTEGER NOT NULL CHECK (started_at_ms >= 0),
            completed_at_ms INTEGER NOT NULL CHECK (completed_at_ms >= 0),
            run_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            CHECK ((recovery_authorization_id IS NULL) = (recovery_authorization_digest IS NULL)),
            CHECK (
                (recovery_execution_plan_id IS NULL) =
                    (recovery_execution_claim_id IS NULL) AND
                (recovery_execution_plan_id IS NULL) =
                    (recovery_execution_claim_epoch IS NULL)
            ),
            CHECK (
                operation_kind <> 'projection_rebuild' OR
                    (source_safety_backup_id IS NOT NULL AND
                     backup_id IS NOT NULL AND
                     recovery_execution_plan_id IS NOT NULL AND
                     recovery_execution_claim_id IS NOT NULL AND
                     recovery_execution_claim_epoch > 0)
            ),
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id),
            FOREIGN KEY (source_safety_backup_id) REFERENCES runtime_generation_backups(backup_id),
            FOREIGN KEY (backup_id) REFERENCES runtime_generation_backups(backup_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id),
            FOREIGN KEY (
                recovery_execution_plan_id,
                recovery_execution_claim_id,
                recovery_execution_claim_epoch
            ) REFERENCES runtime_generation_recovery_operation_execution_claims(
                plan_id,
                claim_id,
                claim_epoch
            )
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_records (
            generation_id TEXT PRIMARY KEY,
            schema_version INTEGER NOT NULL CHECK (schema_version = 8),
            manifest_digest TEXT NOT NULL UNIQUE,
            authority_manifest_file_sha256 TEXT NOT NULL UNIQUE,
            selector_file_sha256 TEXT NOT NULL UNIQUE,
            record_digest TEXT NOT NULL UNIQUE,
            reservation_id TEXT NOT NULL UNIQUE,
            migration_run_id TEXT NOT NULL UNIQUE,
            source_generation_id TEXT,
            retention_class TEXT NOT NULL,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_verifications (
            verification_id TEXT PRIMARY KEY,
            reservation_id TEXT NOT NULL UNIQUE,
            migration_run_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            candidate_authority_manifest_digest TEXT NOT NULL UNIQUE,
            candidate_authority_manifest_file_sha256 TEXT NOT NULL UNIQUE,
            candidate_selector_file_sha256 TEXT NOT NULL UNIQUE,
            source_fence_digest TEXT,
            expected_active_manifest_digest TEXT,
            accepted INTEGER NOT NULL CHECK (accepted = 1),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0),
            report_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_retention_transitions (
            transition_id TEXT PRIMARY KEY,
            generation_id TEXT NOT NULL,
            from_class TEXT NOT NULL,
            to_class TEXT NOT NULL,
            authority_digest TEXT NOT NULL,
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            transition_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            CHECK (from_class <> to_class),
            UNIQUE (generation_id, occurred_at_ms),
            FOREIGN KEY (generation_id) REFERENCES runtime_generation_records(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_activation_intents (
            intent_id TEXT PRIMARY KEY,
            reservation_id TEXT NOT NULL UNIQUE,
            verification_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            candidate_authority_manifest_digest TEXT NOT NULL UNIQUE,
            candidate_authority_manifest_file_sha256 TEXT NOT NULL UNIQUE,
            candidate_selector_file_sha256 TEXT NOT NULL UNIQUE,
            expected_active_manifest_digest TEXT,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > created_at_ms),
            intent_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (verification_id) REFERENCES runtime_generation_verifications(verification_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_activation_consumptions (
            intent_id TEXT PRIMARY KEY,
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            installed_selector_file_sha256 TEXT NOT NULL UNIQUE,
            prior_generation_id TEXT,
            prior_generation_digest TEXT,
            consumption_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            CHECK ((prior_generation_id IS NULL) = (prior_generation_digest IS NULL)),
            FOREIGN KEY (intent_id) REFERENCES runtime_generation_activation_intents(intent_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_active_authority (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            activation_epoch INTEGER NOT NULL CHECK (activation_epoch > 0),
            generation_id TEXT NOT NULL UNIQUE,
            authority_manifest_digest TEXT NOT NULL UNIQUE,
            selector_file_sha256 TEXT NOT NULL UNIQUE,
            activation_intent_id TEXT NOT NULL UNIQUE,
            activation_consumption_digest TEXT NOT NULL UNIQUE,
            prior_generation_id TEXT,
            prior_generation_digest TEXT,
            activated_at_ms INTEGER NOT NULL CHECK (activated_at_ms >= 0),
            authority_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            CHECK ((prior_generation_id IS NULL) = (prior_generation_digest IS NULL)),
            FOREIGN KEY (generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (activation_intent_id)
              REFERENCES runtime_generation_activation_consumptions(intent_id)
        )
        """,
        """
        CREATE TABLE runtime_generation_restore_baselines (
            plan_id TEXT PRIMARY KEY,
            source_generation_id TEXT NOT NULL,
            source_generation_digest TEXT NOT NULL,
            source_safety_backup_id TEXT NOT NULL UNIQUE,
            source_safety_fence_digest TEXT NOT NULL,
            target_generation_id TEXT NOT NULL UNIQUE,
            target_verification_id TEXT NOT NULL UNIQUE,
            target_activation_baseline_digest TEXT NOT NULL,
            recovery_authorization_id TEXT NOT NULL UNIQUE,
            recovery_authorization_digest TEXT NOT NULL UNIQUE,
            prepared_at_ms INTEGER NOT NULL CHECK (prepared_at_ms >= 0),
            plan_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (source_safety_backup_id) REFERENCES runtime_generation_backups(backup_id),
            FOREIGN KEY (target_generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (target_verification_id) REFERENCES runtime_generation_verifications(verification_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_rollbacks (
            rollback_id TEXT PRIMARY KEY,
            restore_baseline_plan_id TEXT NOT NULL UNIQUE,
            source_generation_id TEXT NOT NULL,
            source_safety_fence_digest TEXT NOT NULL,
            target_generation_id TEXT NOT NULL,
            target_verification_id TEXT NOT NULL,
            target_observed_fence_digest TEXT NOT NULL UNIQUE,
            post_activation_event_count INTEGER NOT NULL CHECK (post_activation_event_count = 0),
            post_activation_command_count INTEGER NOT NULL CHECK (post_activation_command_count = 0),
            post_activation_receipt_count INTEGER NOT NULL CHECK (post_activation_receipt_count = 0),
            post_activation_external_effect_count INTEGER NOT NULL CHECK (post_activation_external_effect_count = 0),
            post_activation_attachment_lifecycle_count INTEGER NOT NULL CHECK (post_activation_attachment_lifecycle_count = 0),
            activated_at_ms INTEGER NOT NULL CHECK (activated_at_ms >= 0),
            rollback_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (target_verification_id) REFERENCES runtime_generation_verifications(verification_id),
            FOREIGN KEY (restore_baseline_plan_id) REFERENCES runtime_generation_restore_baselines(plan_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_quarantines (
            quarantine_id TEXT PRIMARY KEY,
            reason TEXT NOT NULL,
            original_generation_id TEXT,
            original_manifest_digest TEXT,
            diagnostic_fingerprint TEXT NOT NULL,
            quarantined_at_ms INTEGER NOT NULL CHECK (quarantined_at_ms >= 0),
            quarantine_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_rebuilds (
            rebuild_id TEXT PRIMARY KEY,
            migration_run_id TEXT NOT NULL UNIQUE,
            recovery_execution_plan_id TEXT NOT NULL,
            recovery_execution_claim_id TEXT NOT NULL,
            recovery_execution_claim_epoch INTEGER NOT NULL CHECK (recovery_execution_claim_epoch > 0),
            candidate_generation_id TEXT NOT NULL UNIQUE,
            ready_transition_digest TEXT NOT NULL UNIQUE,
            source_generation_id TEXT NOT NULL,
            source_fence_digest TEXT NOT NULL,
            equivalence_digest TEXT NOT NULL UNIQUE,
            published_at_ms INTEGER NOT NULL CHECK (published_at_ms >= 0),
            rebuild_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (
                recovery_execution_plan_id,
                recovery_execution_claim_id,
                recovery_execution_claim_epoch
            ) REFERENCES runtime_generation_recovery_operation_execution_claims(
                plan_id,
                claim_id,
                claim_epoch
            ),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (source_generation_id) REFERENCES runtime_generation_records(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_imports (
            import_id TEXT PRIMARY KEY,
            source_kind TEXT NOT NULL,
            source_identity_digest TEXT NOT NULL,
            source_schema TEXT NOT NULL,
            source_digest TEXT NOT NULL UNIQUE,
            discovered_at_ms INTEGER NOT NULL CHECK (discovered_at_ms >= 0),
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE (source_identity_digest, source_schema)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_checkpoints (
            checkpoint_id TEXT PRIMARY KEY,
            import_id TEXT NOT NULL,
            sequence INTEGER NOT NULL CHECK (sequence >= 0),
            phase TEXT NOT NULL,
            prior_checkpoint_digest TEXT,
            artifact_set_digest TEXT NOT NULL,
            processed_item_count INTEGER NOT NULL CHECK (processed_item_count >= 0),
            checkpoint_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE (import_id, sequence),
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_orphan_quarantine_plans (
            quarantine_id TEXT PRIMARY KEY,
            original_entry_name TEXT NOT NULL,
            destination_entry_name TEXT NOT NULL UNIQUE,
            planned_at_ms INTEGER NOT NULL CHECK (planned_at_ms >= 0),
            plan_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_orphan_quarantines (
            quarantine_id TEXT PRIMARY KEY,
            original_entry_name TEXT NOT NULL,
            preserved_relative_path TEXT NOT NULL UNIQUE,
            inventory_digest TEXT NOT NULL,
            file_count INTEGER NOT NULL CHECK (file_count >= 0),
            total_byte_count INTEGER NOT NULL CHECK (total_byte_count >= 0),
            quarantine_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (quarantine_id)
                REFERENCES runtime_generation_import_orphan_quarantine_plans(quarantine_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_items (
            item_key TEXT PRIMARY KEY,
            import_id TEXT NOT NULL,
            source_record_id TEXT NOT NULL,
            source_record_digest TEXT NOT NULL,
            canonical_family TEXT,
            canonical_id TEXT,
            canonical_payload_digest TEXT,
            mapped_artifact_binding_digest TEXT,
            disposition TEXT NOT NULL,
            lossiness TEXT NOT NULL,
            item_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE (import_id, source_record_id),
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_disposition_intents (
            intent_id TEXT PRIMARY KEY,
            import_id TEXT NOT NULL,
            intent_digest TEXT NOT NULL UNIQUE,
            disposition TEXT NOT NULL,
            planned_at_ms INTEGER NOT NULL CHECK (planned_at_ms >= 0),
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_manifests (
            import_id TEXT PRIMARY KEY,
            item_count INTEGER NOT NULL CHECK (item_count >= 0),
            ordered_item_set_digest TEXT NOT NULL UNIQUE,
            completed_at_ms INTEGER NOT NULL CHECK (completed_at_ms >= 0),
            manifest_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_review_pages (
            page_id TEXT PRIMARY KEY,
            review_id TEXT NOT NULL,
            import_id TEXT NOT NULL,
            page_index INTEGER NOT NULL CHECK (page_index >= 0),
            after_source_record_id TEXT,
            last_source_record_id TEXT NOT NULL,
            page_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE (review_id, page_index),
            UNIQUE (review_id, last_source_record_id),
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_reviews (
            review_id TEXT PRIMARY KEY,
            import_id TEXT NOT NULL UNIQUE,
            source_digest TEXT NOT NULL,
            item_count INTEGER NOT NULL CHECK (item_count >= 0),
            page_count INTEGER NOT NULL CHECK (page_count >= 0),
            ordered_item_set_digest TEXT NOT NULL,
            ordered_decision_set_digest TEXT NOT NULL UNIQUE,
            review_authorization_digest TEXT NOT NULL UNIQUE,
            reviewed_at_ms INTEGER NOT NULL CHECK (reviewed_at_ms >= 0),
            review_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_review_authorizations (
            authorization_id TEXT PRIMARY KEY,
            import_id TEXT NOT NULL,
            manifest_digest TEXT NOT NULL,
            disposition_intent_digest TEXT NOT NULL,
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms >= 0),
            authorization_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (import_id) REFERENCES runtime_generation_imports(import_id),
            FOREIGN KEY (disposition_intent_digest)
                REFERENCES runtime_generation_import_disposition_intents(intent_digest)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_import_review_authorization_consumptions (
            authorization_id TEXT PRIMARY KEY,
            review_id TEXT NOT NULL UNIQUE,
            review_digest TEXT NOT NULL UNIQUE,
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            FOREIGN KEY (authorization_id) REFERENCES runtime_generation_import_review_authorizations(authorization_id),
            FOREIGN KEY (review_id) REFERENCES runtime_generation_import_reviews(review_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_authorizations (
            authorization_id TEXT PRIMARY KEY,
            action TEXT NOT NULL,
            target_digest TEXT NOT NULL,
            authorized_at_ms INTEGER NOT NULL CHECK (authorized_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > authorized_at_ms),
            authorization_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_precommit_witnesses (
            witness_id TEXT PRIMARY KEY,
            activation_intent_id TEXT NOT NULL UNIQUE,
            migration_run_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            candidate_selector_file_sha256 TEXT NOT NULL UNIQUE,
            recovery_authorization_id TEXT NOT NULL UNIQUE,
            recovery_authorization_digest TEXT NOT NULL UNIQUE,
            recovery_target_digest TEXT NOT NULL,
            result_digest TEXT NOT NULL UNIQUE,
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            minimum_remaining_validity_ms INTEGER NOT NULL CHECK (minimum_remaining_validity_ms > 0),
            witness_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (activation_intent_id) REFERENCES runtime_generation_activation_intents(intent_id),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_authorization_consumptions (
            authorization_id TEXT PRIMARY KEY,
            action TEXT NOT NULL,
            target_digest TEXT NOT NULL,
            result_digest TEXT NOT NULL,
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            consumption_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_plans (
            plan_id TEXT PRIMARY KEY,
            quarantine_id TEXT NOT NULL,
            action TEXT NOT NULL,
            target_digest TEXT NOT NULL,
            recovery_authorization_id TEXT NOT NULL UNIQUE,
            recovery_authorization_digest TEXT NOT NULL UNIQUE,
            prepared_at_ms INTEGER NOT NULL CHECK (prepared_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > prepared_at_ms),
            plan_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (quarantine_id) REFERENCES runtime_generation_quarantines(quarantine_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_consumptions (
            plan_id TEXT PRIMARY KEY,
            recovery_authorization_id TEXT NOT NULL UNIQUE,
            action TEXT NOT NULL,
            target_digest TEXT NOT NULL,
            result_digest TEXT NOT NULL UNIQUE,
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            consumption_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_execution_claims (
            claim_id TEXT PRIMARY KEY,
            plan_id TEXT NOT NULL,
            executor_instance_id TEXT NOT NULL,
            claim_epoch INTEGER NOT NULL CHECK (claim_epoch > 0),
            claimed_at_ms INTEGER NOT NULL CHECK (claimed_at_ms >= 0),
            expires_at_ms INTEGER NOT NULL CHECK (expires_at_ms > claimed_at_ms),
            claim_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE(plan_id, claim_epoch),
            FOREIGN KEY (plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_execution_receipts (
            receipt_id TEXT PRIMARY KEY,
            plan_id TEXT NOT NULL UNIQUE,
            claim_id TEXT NOT NULL UNIQUE,
            claim_epoch INTEGER NOT NULL CHECK (claim_epoch > 0),
            quarantine_id TEXT NOT NULL,
            candidate_generation_id TEXT,
            recovery_authorization_id TEXT NOT NULL UNIQUE,
            recovery_authorization_digest TEXT NOT NULL UNIQUE,
            action TEXT NOT NULL,
            target_digest TEXT NOT NULL,
            verification_id TEXT UNIQUE,
            verification_report_digest TEXT UNIQUE,
            verification_accepted INTEGER,
            authority_classification TEXT NOT NULL,
            rebuild_id TEXT UNIQUE,
            rebuild_digest TEXT UNIQUE,
            outcome_evidence_digest TEXT NOT NULL UNIQUE,
            executed_at_ms INTEGER NOT NULL CHECK (executed_at_ms >= 0),
            receipt_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (claim_id) REFERENCES runtime_generation_recovery_operation_execution_claims(claim_id),
            FOREIGN KEY (quarantine_id) REFERENCES runtime_generation_quarantines(quarantine_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id),
            FOREIGN KEY (verification_id) REFERENCES runtime_generation_verifications(verification_id),
            FOREIGN KEY (rebuild_id) REFERENCES runtime_generation_rebuilds(rebuild_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_plan_dispositions (
            plan_id TEXT PRIMARY KEY,
            kind TEXT NOT NULL,
            recovery_authorization_id TEXT UNIQUE,
            recovery_authorization_digest TEXT UNIQUE,
            disposed_at_ms INTEGER NOT NULL CHECK (disposed_at_ms >= 0),
            disposition_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_plan_successions (
            successor_plan_id TEXT PRIMARY KEY,
            predecessor_plan_id TEXT NOT NULL UNIQUE,
            quarantine_id TEXT NOT NULL,
            action TEXT NOT NULL,
            predecessor_disposition_digest TEXT NOT NULL,
            recorded_at_ms INTEGER NOT NULL CHECK (recorded_at_ms >= 0),
            succession_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (predecessor_plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_recovery_operation_verification_bindings (
            verification_id TEXT PRIMARY KEY,
            verification_report_digest TEXT NOT NULL UNIQUE,
            plan_id TEXT NOT NULL,
            claim_id TEXT NOT NULL UNIQUE,
            claim_epoch INTEGER NOT NULL CHECK (claim_epoch > 0),
            candidate_generation_id TEXT NOT NULL,
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            binding_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (verification_id) REFERENCES runtime_generation_verifications(verification_id),
            FOREIGN KEY (plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (claim_id) REFERENCES runtime_generation_recovery_operation_execution_claims(claim_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_projection_rebuild_lifecycle_transitions (
            transition_id TEXT PRIMARY KEY,
            migration_run_id TEXT NOT NULL,
            recovery_execution_plan_id TEXT NOT NULL,
            recovery_execution_claim_id TEXT NOT NULL,
            recovery_execution_claim_epoch INTEGER NOT NULL CHECK (recovery_execution_claim_epoch > 0),
            phase TEXT NOT NULL,
            prior_transition_digest TEXT,
            reason_digest TEXT NOT NULL,
            occurred_at_ms INTEGER NOT NULL CHECK (occurred_at_ms >= 0),
            transition_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            UNIQUE(migration_run_id, transition_digest),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (recovery_execution_plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (recovery_execution_claim_id) REFERENCES runtime_generation_recovery_operation_execution_claims(claim_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_projection_rebuild_candidate_reservations (
            candidate_reservation_id TEXT PRIMARY KEY,
            recovery_execution_plan_id TEXT NOT NULL,
            recovery_execution_claim_id TEXT NOT NULL,
            recovery_execution_claim_epoch INTEGER NOT NULL CHECK (recovery_execution_claim_epoch > 0),
            migration_run_id TEXT NOT NULL UNIQUE,
            reservation_id TEXT NOT NULL UNIQUE,
            candidate_preparation_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            expected_verification_id TEXT NOT NULL UNIQUE,
            expected_activation_intent_id TEXT NOT NULL UNIQUE,
            reserved_at_ms INTEGER NOT NULL CHECK (reserved_at_ms >= 0),
            reservation_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (recovery_execution_plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (recovery_execution_claim_id) REFERENCES runtime_generation_recovery_operation_execution_claims(claim_id),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (candidate_preparation_id) REFERENCES runtime_generation_candidate_preparations(preparation_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_generation_projection_rebuild_candidate_authority_commitments (
            commitment_id TEXT PRIMARY KEY,
            candidate_reservation_id TEXT NOT NULL UNIQUE,
            recovery_execution_plan_id TEXT NOT NULL,
            recovery_execution_claim_id TEXT NOT NULL,
            recovery_execution_claim_epoch INTEGER NOT NULL CHECK (recovery_execution_claim_epoch > 0),
            migration_run_id TEXT NOT NULL UNIQUE,
            reservation_id TEXT NOT NULL UNIQUE,
            candidate_preparation_id TEXT NOT NULL UNIQUE,
            candidate_generation_id TEXT NOT NULL UNIQUE,
            expected_verification_id TEXT NOT NULL UNIQUE,
            expected_activation_intent_id TEXT NOT NULL UNIQUE,
            candidate_record_digest TEXT NOT NULL UNIQUE,
            candidate_preparation_completion_digest TEXT NOT NULL UNIQUE,
            authority_manifest_digest TEXT NOT NULL UNIQUE,
            authority_manifest_file_sha256 TEXT NOT NULL UNIQUE,
            authority_manifest_bytes_sha256 TEXT NOT NULL UNIQUE,
            authority_manifest_byte_count INTEGER NOT NULL CHECK (authority_manifest_byte_count > 0),
            selector_file_sha256 TEXT NOT NULL UNIQUE,
            selector_bytes_sha256 TEXT NOT NULL UNIQUE,
            selector_byte_count INTEGER NOT NULL CHECK (selector_byte_count > 0),
            replay_audit_id TEXT NOT NULL UNIQUE,
            replay_audit_digest TEXT NOT NULL UNIQUE,
            replay_reconstruction_digest TEXT NOT NULL UNIQUE,
            rebuild_id TEXT NOT NULL UNIQUE,
            rebuild_digest TEXT NOT NULL UNIQUE,
            equivalence_digest TEXT NOT NULL UNIQUE,
            committed_at_ms INTEGER NOT NULL CHECK (committed_at_ms >= 0),
            commitment_digest TEXT NOT NULL UNIQUE,
            payload BLOB NOT NULL,
            payload_digest TEXT NOT NULL UNIQUE,
            FOREIGN KEY (candidate_reservation_id) REFERENCES runtime_generation_projection_rebuild_candidate_reservations(candidate_reservation_id),
            FOREIGN KEY (recovery_execution_plan_id) REFERENCES runtime_generation_recovery_operation_plans(plan_id),
            FOREIGN KEY (recovery_execution_claim_id) REFERENCES runtime_generation_recovery_operation_execution_claims(claim_id),
            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),
            FOREIGN KEY (reservation_id) REFERENCES runtime_generation_reservations(reservation_id),
            FOREIGN KEY (candidate_preparation_id) REFERENCES runtime_generation_candidate_preparations(preparation_id),
            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id),
            FOREIGN KEY (replay_audit_id) REFERENCES runtime_generation_candidate_replay_audits(audit_id),
            FOREIGN KEY (rebuild_id) REFERENCES runtime_generation_rebuilds(rebuild_id)
        ) WITHOUT ROWID
        """,
    ]

    static let indexStatements: [String] = [
        "CREATE INDEX runtime_generation_backup_preparations_source_idx ON runtime_generation_backup_preparations(source_generation_id, created_at_ms, preparation_id)",
        "CREATE INDEX runtime_generation_candidate_preparations_source_idx ON runtime_generation_candidate_preparations(source_generation_id, created_at_ms, preparation_id)",
        "CREATE INDEX runtime_generation_backups_source_idx ON runtime_generation_backups(source_generation_id, created_at_ms, backup_id)",
        "CREATE INDEX runtime_generation_backups_fence_idx ON runtime_generation_backups(source_generation_id, authority_fence_token_digest, created_at_ms, backup_id)",
        "CREATE INDEX runtime_generation_quarantines_generation_idx ON runtime_generation_quarantines(original_generation_id, quarantined_at_ms, quarantine_id)",
        "CREATE INDEX runtime_generation_import_items_review_idx ON runtime_generation_import_items(import_id, disposition, lossiness, source_record_id)",
        "CREATE INDEX runtime_generation_import_items_source_digest_idx ON runtime_generation_import_items(import_id, source_record_digest)",
        "CREATE INDEX runtime_generation_import_items_payload_digest_idx ON runtime_generation_import_items(import_id, canonical_payload_digest)",
        "CREATE INDEX runtime_generation_import_review_pages_order_idx ON runtime_generation_import_review_pages(review_id, page_index)",
        "CREATE INDEX runtime_generation_retention_current_idx ON runtime_generation_retention_transitions(generation_id, occurred_at_ms DESC, transition_id DESC)",
        "CREATE INDEX runtime_generation_migration_runs_source_safety_backup_idx ON runtime_generation_migration_runs(source_safety_backup_id, started_at_ms, migration_run_id)",
        "CREATE INDEX runtime_generation_migration_runs_recovery_execution_idx ON runtime_generation_migration_runs(recovery_execution_plan_id, recovery_execution_claim_id, recovery_execution_claim_epoch)",
        "CREATE INDEX runtime_generation_rebuilds_recovery_execution_idx ON runtime_generation_rebuilds(recovery_execution_plan_id, recovery_execution_claim_id, recovery_execution_claim_epoch)",
        "CREATE INDEX runtime_generation_projection_rebuild_candidate_reservations_claim_idx ON runtime_generation_projection_rebuild_candidate_reservations(recovery_execution_plan_id, recovery_execution_claim_id, recovery_execution_claim_epoch)",
        "CREATE UNIQUE INDEX runtime_generation_recovery_execution_claims_plan_claim_epoch_uq ON runtime_generation_recovery_operation_execution_claims(plan_id, claim_id, claim_epoch)",
    ]

    static let triggerStatements: [String] = [
        immutableTrigger(table: "runtime_generation_reservations"),
        immutableTrigger(table: "runtime_generation_operation_leases"),
        immutableTrigger(table: "runtime_generation_backup_preparations"),
        immutableTrigger(table: "runtime_generation_backup_preparation_completions"),
        immutableTrigger(table: "runtime_generation_backups"),
        immutableTrigger(table: "runtime_generation_backup_preparation_consumptions"),
        immutableTrigger(table: "runtime_generation_backup_preparation_recoveries"),
        immutableTrigger(table: "runtime_generation_candidate_preparations"),
        immutableTrigger(table: "runtime_generation_candidate_preparation_completions"),
        immutableTrigger(table: "runtime_generation_candidate_preparation_dispositions"),
        immutableTrigger(table: "runtime_generation_candidate_replay_audits"),
        immutableTrigger(table: "runtime_generation_migration_runs"),
        immutableTrigger(table: "runtime_generation_records"),
        immutableTrigger(table: "runtime_generation_verifications"),
        immutableTrigger(table: "runtime_generation_retention_transitions"),
        immutableTrigger(table: "runtime_generation_activation_intents"),
        immutableTrigger(table: "runtime_generation_activation_consumptions"),
        immutableTrigger(table: "runtime_generation_restore_baselines"),
        immutableTrigger(table: "runtime_generation_rollbacks"),
        immutableTrigger(table: "runtime_generation_quarantines"),
        immutableTrigger(table: "runtime_generation_rebuilds"),
        immutableTrigger(table: "runtime_generation_imports"),
        immutableTrigger(table: "runtime_generation_import_checkpoints"),
        immutableTrigger(table: "runtime_generation_import_orphan_quarantine_plans"),
        immutableTrigger(table: "runtime_generation_import_orphan_quarantines"),
        immutableTrigger(table: "runtime_generation_import_items"),
        immutableTrigger(table: "runtime_generation_import_disposition_intents"),
        immutableTrigger(table: "runtime_generation_import_manifests"),
        immutableTrigger(table: "runtime_generation_import_review_pages"),
        immutableTrigger(table: "runtime_generation_import_reviews"),
        immutableTrigger(table: "runtime_generation_import_review_authorizations"),
        immutableTrigger(table: "runtime_generation_import_review_authorization_consumptions"),
        immutableTrigger(table: "runtime_generation_recovery_authorizations"),
        immutableTrigger(table: "runtime_generation_recovery_precommit_witnesses"),
        immutableTrigger(table: "runtime_generation_recovery_authorization_consumptions"),
        immutableTrigger(table: "runtime_generation_recovery_operation_plans"),
        immutableTrigger(table: "runtime_generation_recovery_operation_consumptions"),
        immutableTrigger(table: "runtime_generation_recovery_operation_execution_claims"),
        immutableTrigger(table: "runtime_generation_recovery_operation_execution_receipts"),
        immutableTrigger(table: "runtime_generation_recovery_operation_plan_dispositions"),
        immutableTrigger(table: "runtime_generation_recovery_operation_plan_successions"),
        immutableTrigger(table: "runtime_generation_recovery_operation_verification_bindings"),
        immutableTrigger(table: "runtime_generation_projection_rebuild_lifecycle_transitions"),
        immutableTrigger(table: "runtime_generation_projection_rebuild_candidate_reservations"),
        immutableTrigger(table: "runtime_generation_projection_rebuild_candidate_authority_commitments"),
        immutableTrigger(table: "runtime_generation_control_metadata"),
    ].flatMap { $0 }

    static var allStatements: [String] {
        tableStatements + indexStatements + triggerStatements
    }

    static func immutableTrigger(table: String) -> [String] {
        [
            "CREATE TRIGGER \(table)_immutable_update BEFORE UPDATE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable generation control record'); END",
            "CREATE TRIGGER \(table)_immutable_delete BEFORE DELETE ON \(table) BEGIN SELECT RAISE(ABORT, 'immutable generation control record'); END",
        ]
    }

    static func installSchema(in database: SQLiteDatabase) async throws {
        let authorization = try schemaBootstrapAuthorization()
        try await database.bootstrapTransaction(.exclusive, authorization: authorization) { database in
            for statement in allStatements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_generation_control_metadata(singleton_id, schema_version, created_at_ms) VALUES(1, ?, 0)",
                bindings: [.integer(Int64(runtimeGenerationControlSchemaVersion))]
            )
            try database.execute(
                "PRAGMA user_version = \(runtimeGenerationControlSchemaVersion)"
            )
        }
    }

    static func schemaBootstrapAuthorization() throws -> SQLiteBootstrapAuthorization {
        let names = Set(try schemaCatalog(allStatements).keys.compactMap { key in
            key.split(separator: ":", maxSplits: 1).last.map(String.init)
        })
        return try SQLiteBootstrapAuthorization(allowedSchemaObjects: names)
    }

    static func requireExactSchema(in database: SQLiteDatabase) async throws {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1,
                  case let .integer(actualVersion)? = version[0].values.first,
                  actualVersion >= 0 else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "control_metadata",
                    id: "user_version"
                )
            }
            guard actualVersion == Int64(runtimeGenerationControlSchemaVersion) else {
                if actualVersion > Int64(runtimeGenerationControlSchemaVersion) {
                    throw RuntimeGenerationControlError.futureVersion(
                        maximumSupported: runtimeGenerationControlSchemaVersion,
                        actual: Int(actualVersion)
                    )
                }
                throw RuntimeGenerationControlError.unsupportedVersion(
                    expected: runtimeGenerationControlSchemaVersion,
                    actual: Int(actualVersion)
                )
            }
            let metadata = try database.query(
                "SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2"
            )
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") ==
                    .integer(Int64(runtimeGenerationControlSchemaVersion)),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "control_metadata",
                    id: "singleton"
                )
            }
            let rows = try database.query(
                "SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name",
                maximumDecodedBytes: maximumControlReadBytes
            )
            let expected = try schemaCatalog(allStatements)
            let observed = try schemaCatalog(rows: rows)
            guard observed == expected else {
                throw RuntimeGenerationControlError.recordCorrupt(
                    kind: "control_schema",
                    id: "v\(runtimeGenerationControlSchemaVersion)"
                )
            }
        }
    }

    static func isExactLegacyV1Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1,
                  case let .integer(value)? = version[0].values.first,
                  value >= 0 else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(
                    maximumSupported: runtimeGenerationControlSchemaVersion,
                    actual: Int(value)
                )
            }
            guard value == 1 else { return false }
            let metadata = try database.query(
                "SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2"
            )
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(1),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v1_singleton")
            }
            let rows = try database.query(
                "SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name",
                maximumDecodedBytes: maximumControlReadBytes
            )
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV1Statements)
        }
    }

    static func isExactLegacyV2Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1,
                  case let .integer(value)? = version[0].values.first,
                  value >= 0 else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(
                    maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value)
                )
            }
            guard value == 2 else { return false }
            let metadata = try database.query(
                "SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2"
            )
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(2),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v2_singleton")
            }
            let rows = try database.query(
                "SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name",
                maximumDecodedBytes: maximumControlReadBytes
            )
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV2Statements)
        }
    }

    static func isExactLegacyV3Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value))
            }
            guard value == 3 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(3),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v3_singleton")
            }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV3Statements)
        }
    }

    static func isExactLegacyV4Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value))
            }
            guard value == 4 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(4),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v4_singleton")
            }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV4Statements)
        }
    }

    static func isExactLegacyV5Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else { throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version") }
            if value > Int64(runtimeGenerationControlSchemaVersion) { throw RuntimeGenerationControlError.futureVersion(maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value)) }
            guard value == 5 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1, metadata[0].value(named: "singleton_id") == .integer(1), metadata[0].value(named: "schema_version") == .integer(5), metadata[0].value(named: "created_at_ms") == .integer(0) else { throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v5_singleton") }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV5Statements)
        }
    }

    static var legacyV7Statements: [String] {
        legacyV8Statements.filter { statement in
            statement.contains("runtime_generation_migration_runs_source_safety_backup_idx") == false &&
                statement.contains("runtime_generation_migration_runs_recovery_execution_idx") == false &&
                statement.contains("runtime_generation_recovery_execution_claims_plan_claim_epoch_uq") == false
        }.map { statement in
            let versioned = statement.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 8)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 7)"
            )
            guard versioned.contains("CREATE TABLE runtime_generation_migration_runs (") else {
                return versioned
            }
            return versioned
                .replacingOccurrences(of: "            source_safety_backup_id TEXT,\n", with: "")
                .replacingOccurrences(of: "            recovery_execution_plan_id TEXT,\n", with: "")
                .replacingOccurrences(of: "            recovery_execution_claim_id TEXT,\n", with: "")
                .replacingOccurrences(of: "            recovery_execution_claim_epoch INTEGER,\n", with: "")
                .replacingOccurrences(
                    of: "            CHECK (\n                (recovery_execution_plan_id IS NULL) =\n                    (recovery_execution_claim_id IS NULL) AND\n                (recovery_execution_plan_id IS NULL) =\n                    (recovery_execution_claim_epoch IS NULL)\n            ),\n            CHECK (\n                operation_kind <> 'projection_rebuild' OR\n                    (source_safety_backup_id IS NOT NULL AND\n                     backup_id IS NOT NULL AND\n                     recovery_execution_plan_id IS NOT NULL AND\n                     recovery_execution_claim_id IS NOT NULL AND\n                     recovery_execution_claim_epoch > 0)\n            ),\n",
                    with: ""
                )
                .replacingOccurrences(of: "            FOREIGN KEY (source_safety_backup_id) REFERENCES runtime_generation_backups(backup_id),\n", with: "")
                .replacingOccurrences(
                    of: "            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id),\n            FOREIGN KEY (\n                recovery_execution_plan_id,\n                recovery_execution_claim_id,\n                recovery_execution_claim_epoch\n            ) REFERENCES runtime_generation_recovery_operation_execution_claims(\n                plan_id,\n                claim_id,\n                claim_epoch\n            )",
                    with: "            FOREIGN KEY (recovery_authorization_id) REFERENCES runtime_generation_recovery_authorizations(authorization_id)"
                )
        }
    }

    static var legacyV6Statements: [String] {
        legacyV7Statements.filter { $0.contains("runtime_generation_projection_rebuild_lifecycle_transitions") == false }
            .map { $0.replacingOccurrences(of: "schema_version INTEGER NOT NULL CHECK (schema_version = 7)", with: "schema_version INTEGER NOT NULL CHECK (schema_version = 6)") }
    }

    static func isExactLegacyV7Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value))
            }
            guard value == 7 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(7),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v7_singleton")
            }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV7Statements)
        }
    }

    /// Exact shipped v9 schema. v10 adds the two-stage candidate authority
    /// tables without rewriting legacy payloads; a v9 source is accepted only
    /// when its complete schema catalog is exact.
    static var legacyV9Statements: [String] {
        allStatements.filter { statement in
            statement.contains("runtime_generation_projection_rebuild_candidate_reservations") == false &&
                statement.contains("runtime_generation_projection_rebuild_candidate_authority_commitments") == false
        }.map { $0.replacingOccurrences(
            of: "schema_version INTEGER NOT NULL CHECK (schema_version = 10)",
            with: "schema_version INTEGER NOT NULL CHECK (schema_version = 9)"
        ) }
    }

    static func isExactLegacyV9Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value))
            }
            guard value == 9 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(9),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v9_singleton")
            }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV9Statements)
        }
    }

    /// Exact shipped v8 schema. v8 already encoded the complete rebuild
    /// certificate in its canonical payload, but its relational projection
    /// omitted the certificate lineage. v9 is intentionally a strict
    /// lossless upgrade, not an opportunistic repair of arbitrary rows.
    static var legacyV8Statements: [String] {
        legacyV9Statements.filter {
            $0.contains("runtime_generation_rebuilds_recovery_execution_idx") == false
        }.map { statement in
            let versioned = statement.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 9)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 8)"
            )
            guard versioned.contains("CREATE TABLE runtime_generation_rebuilds (") else {
                return versioned
            }
            return versioned
                .replacingOccurrences(
                    of: "            migration_run_id TEXT NOT NULL UNIQUE,\n            recovery_execution_plan_id TEXT NOT NULL,\n            recovery_execution_claim_id TEXT NOT NULL,\n            recovery_execution_claim_epoch INTEGER NOT NULL CHECK (recovery_execution_claim_epoch > 0),\n            candidate_generation_id TEXT NOT NULL UNIQUE,\n            ready_transition_digest TEXT NOT NULL UNIQUE,\n",
                    with: ""
                )
                .replacingOccurrences(
                    of: "            FOREIGN KEY (migration_run_id) REFERENCES runtime_generation_migration_runs(migration_run_id),\n            FOREIGN KEY (\n                recovery_execution_plan_id,\n                recovery_execution_claim_id,\n                recovery_execution_claim_epoch\n            ) REFERENCES runtime_generation_recovery_operation_execution_claims(\n                plan_id,\n                claim_id,\n                claim_epoch\n            ),\n            FOREIGN KEY (candidate_generation_id) REFERENCES runtime_generation_records(generation_id),\n            FOREIGN KEY (source_generation_id) REFERENCES runtime_generation_records(generation_id)\n",
                    with: ""
                )
                .replacingOccurrences(
                    of: "            payload_digest TEXT NOT NULL UNIQUE,\n        ) WITHOUT ROWID",
                    with: "            payload_digest TEXT NOT NULL UNIQUE\n        ) WITHOUT ROWID"
                )
        }
    }

    static func isExactLegacyV8Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version")
            }
            if value > Int64(runtimeGenerationControlSchemaVersion) {
                throw RuntimeGenerationControlError.futureVersion(
                    maximumSupported: runtimeGenerationControlSchemaVersion, actual: Int(value)
                )
            }
            guard value == 8 else { return false }
            let metadata = try database.query(
                "SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2"
            )
            guard metadata.count == 1,
                  metadata[0].value(named: "singleton_id") == .integer(1),
                  metadata[0].value(named: "schema_version") == .integer(8),
                  metadata[0].value(named: "created_at_ms") == .integer(0) else {
                throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v8_singleton")
            }
            let rows = try database.query(
                "SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name",
                maximumDecodedBytes: maximumControlReadBytes
            )
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV8Statements)
        }
    }

    static func isExactLegacyV6Schema(in database: SQLiteDatabase) async throws -> Bool {
        try await database.transaction(.deferred) { database in
            let version = try database.query("PRAGMA user_version")
            guard version.count == 1, case let .integer(value)? = version[0].values.first else { throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "user_version") }
            guard value == 6 else { return false }
            let metadata = try database.query("SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2")
            guard metadata.count == 1, metadata[0].value(named: "singleton_id") == .integer(1), metadata[0].value(named: "schema_version") == .integer(6), metadata[0].value(named: "created_at_ms") == .integer(0) else { throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "v6_singleton") }
            let rows = try database.query("SELECT type, name, sql FROM sqlite_schema WHERE name NOT LIKE 'sqlite_%' AND type IN ('table','index','trigger') ORDER BY type, name", maximumDecodedBytes: maximumControlReadBytes)
            return try schemaCatalog(rows: rows) == schemaCatalog(legacyV6Statements)
        }
    }

    static var legacyV5Statements: [String] {
        legacyV6Statements.filter { statement in
            statement.contains("runtime_generation_recovery_operation_plan_dispositions") == false &&
                statement.contains("runtime_generation_recovery_operation_plan_successions") == false &&
                statement.contains("runtime_generation_recovery_operation_verification_bindings") == false
        }.map { statement in
            let versioned = statement.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 6)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 5)"
            )
            guard versioned.contains("CREATE TABLE runtime_generation_recovery_operation_plans (") else {
                return versioned
            }
            return versioned.replacingOccurrences(
                of: "            FOREIGN KEY (quarantine_id) REFERENCES runtime_generation_quarantines(quarantine_id),",
                with: "            UNIQUE(quarantine_id, action),\n            FOREIGN KEY (quarantine_id) REFERENCES runtime_generation_quarantines(quarantine_id),"
            )
        }
    }

    static var legacyV4Statements: [String] {
        legacyV5Statements.filter { statement in
            statement.contains("runtime_generation_recovery_operation_execution_claims") == false &&
                statement.contains("runtime_generation_recovery_operation_execution_receipts") == false
        }.map {
            $0.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 5)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 4)"
            )
        }
    }

    static var legacyV3Statements: [String] {
        legacyV4Statements.filter { statement in
            statement.contains("runtime_generation_recovery_operation_plans") == false &&
                statement.contains("runtime_generation_recovery_operation_consumptions") == false
        }.map {
            $0.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 4)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 3)"
            )
        }
    }

    static var legacyV2Statements: [String] {
        legacyV3Statements.filter { $0.contains("runtime_generation_candidate_replay_audits") == false }
            .map { $0.replacingOccurrences(of: "schema_version INTEGER NOT NULL CHECK (schema_version = 3)", with: "schema_version INTEGER NOT NULL CHECK (schema_version = 2)") }
    }

    static var legacyV1Statements: [String] {
        legacyV2Statements.map { statement in
            let metadata = statement.replacingOccurrences(
                of: "schema_version INTEGER NOT NULL CHECK (schema_version = 2)",
                with: "schema_version INTEGER NOT NULL CHECK (schema_version = 1)"
            )
            guard metadata.contains(
                "CREATE TABLE runtime_generation_backup_preparation_consumptions ("
            ) else { return metadata }
            return metadata
                .replacingOccurrences(of: "            operation_lease_id TEXT NOT NULL,\n", with: "")
                .replacingOccurrences(of: "            operation_fencing_token INTEGER NOT NULL CHECK (operation_fencing_token > 0),\n", with: "")
                .replacingOccurrences(of: ",\n            FOREIGN KEY (operation_lease_id) REFERENCES runtime_generation_operation_leases(lease_id)", with: "")
        }
    }

    static func validateLegacyV1Consumption(
        _ record: RuntimeGenerationBackupPreparationConsumptionV1,
        row: SQLiteRow
    ) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.preparationID, field: "legacy_backup_consumption_preparation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.backupID, field: "legacy_backup_consumption_backup_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.consumptionDigest, field: "legacy_backup_consumption_digest"
        )
        guard record.finalDirectoryDevice > 0,
              record.finalDirectoryInode > 0,
              record.consumedAtMilliseconds >= 0,
              row.value(named: "preparation_id") == .text(record.preparationID),
              row.value(named: "backup_id") == .text(record.backupID),
              row.value(named: "final_directory_device") ==
                .integer(Int64(bitPattern: record.finalDirectoryDevice)),
              row.value(named: "final_directory_inode") ==
                .integer(Int64(bitPattern: record.finalDirectoryInode)),
              row.value(named: "consumed_at_ms") == .integer(record.consumedAtMilliseconds),
              row.value(named: "consumption_digest") == .text(record.consumptionDigest) else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "legacy_backup_consumption", id: record.preparationID
            )
        }
        let encoded = try RuntimeGenerationControlCodec.encode(record)
        guard var object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any],
              object.removeValue(forKey: "consumptionDigest") != nil else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "legacy_backup_consumption", id: record.preparationID
            )
        }
        let canonical = try JSONSerialization.data(
            withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]
        )
        guard LocalRuntimeStorageChecksum.sha256Hex(for: canonical) ==
                record.consumptionDigest else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "legacy_backup_consumption", id: record.preparationID
            )
        }
    }

    static func migrateExactLegacyV1Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV1Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 1, actual: 2)
        }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV1ToV2MigrationAuthorization()
        ) { database in
            let legacyRows = try database.query(
                "SELECT * FROM runtime_generation_backup_preparation_consumptions ORDER BY preparation_id",
                maximumDecodedBytes: maximumControlReadBytes
            )
            try database.execute("DROP TRIGGER runtime_generation_backup_preparation_consumptions_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_backup_preparation_consumptions_immutable_delete")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(
                in: database,
                targetVersion: 2,
                upgradeTableName: "runtime_generation_control_metadata_upgrade_v2"
            )
            let upgradedName = "runtime_generation_backup_preparation_consumptions_upgrade"
            guard let statement = tableStatements.first(where: {
                $0.contains("CREATE TABLE runtime_generation_backup_preparation_consumptions (")
            }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            try database.execute(statement.replacingOccurrences(
                of: "CREATE TABLE runtime_generation_backup_preparation_consumptions (",
                with: "CREATE TABLE \(upgradedName) ("
            ))
            for row in legacyRows {
                guard case let .blob(payload)? = row.value(named: "payload"),
                      case let .text(payloadDigest)? = row.value(named: "payload_digest"),
                      payload.count <= maximumControlReadBytes,
                      LocalRuntimeStorageChecksum.sha256Hex(for: payload) == payloadDigest else {
                    throw RuntimeGenerationControlError.recordCorrupt(kind: "legacy_backup_consumption", id: "payload")
                }
                let legacy = try RuntimeGenerationControlCodec.decode(
                    RuntimeGenerationBackupPreparationConsumptionV1.self, from: payload
                )
                try validateLegacyV1Consumption(legacy, row: row)
                let preparation = try loadPayload(
                    RuntimeGenerationBackupPreparationRecord.self,
                    table: "runtime_generation_backup_preparations",
                    idColumn: "preparation_id", id: legacy.preparationID, database: database
                )
                let admissionLease = try loadPayload(
                    RuntimeGenerationOperationLease.self,
                    table: "runtime_generation_operation_leases",
                    idColumn: "lease_id", id: preparation.operationLeaseID, database: database
                )
                let completion = try loadPayload(
                    RuntimeGenerationBackupPreparationCompletion.self,
                    table: "runtime_generation_backup_preparation_completions",
                    idColumn: "preparation_id", id: legacy.preparationID, database: database
                )
                let backup = try loadPayload(
                    RuntimeGenerationBackupRecord.self,
                    table: "runtime_generation_backups",
                    idColumn: "backup_id", id: legacy.backupID, database: database
                )
                guard preparation.backupID == legacy.backupID,
                      admissionLease.reservationID == preparation.reservationID,
                      admissionLease.fencingToken == preparation.operationFencingToken,
                      completion.backup == backup,
                      completion.backup.backupID == legacy.backupID,
                      legacy.finalDirectoryDevice == completion.directoryDevice,
                      legacy.finalDirectoryInode == completion.directoryInode,
                      legacy.consumedAtMilliseconds >= completion.completedAtMilliseconds else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_backup_consumption", id: legacy.preparationID
                    )
                }
                let upgraded = try RuntimeGenerationControlRecordFactory.backupPreparationConsumption(
                    preparationID: legacy.preparationID, backupID: legacy.backupID,
                    operationLease: admissionLease,
                    finalDirectoryDevice: legacy.finalDirectoryDevice,
                    finalDirectoryInode: legacy.finalDirectoryInode,
                    consumedAtMilliseconds: legacy.consumedAtMilliseconds
                )
                let bytes = try RuntimeGenerationControlCodec.encode(upgraded)
                try database.execute(
                    "INSERT INTO \(upgradedName)(preparation_id, backup_id, operation_lease_id, operation_fencing_token, final_directory_device, final_directory_inode, consumed_at_ms, consumption_digest, payload, payload_digest) VALUES(?,?,?,?,?,?,?,?,?,?)",
                    bindings: [.text(upgraded.preparationID), .text(upgraded.backupID), .text(upgraded.operationLeaseID), .integer(upgraded.operationFencingToken), .integer(Int64(bitPattern: upgraded.finalDirectoryDevice)), .integer(Int64(bitPattern: upgraded.finalDirectoryInode)), .integer(upgraded.consumedAtMilliseconds), .text(upgraded.consumptionDigest), .blob(bytes), .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes))]
                )
            }
            try database.execute("DROP TABLE runtime_generation_backup_preparation_consumptions")
            // Recreate from the canonical v2 SQL rather than ALTER RENAME so
            // the exact-schema verifier also authenticates the activated DDL.
            try database.execute(statement)
            try database.execute(
                "INSERT INTO runtime_generation_backup_preparation_consumptions SELECT * FROM \(upgradedName)"
            )
            try database.execute("DROP TABLE \(upgradedName)")
            try database.execute("PRAGMA user_version = 2")
            for statement in immutableTrigger(table: "runtime_generation_backup_preparation_consumptions") +
                immutableTrigger(table: "runtime_generation_control_metadata") {
                try database.execute(statement)
            }
        }
    }

    static func legacyV1ToV2MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: [
                "runtime_generation_backup_preparation_consumptions",
                "runtime_generation_backup_preparation_consumptions_upgrade",
                "runtime_generation_backup_preparation_consumptions_immutable_update",
                "runtime_generation_backup_preparation_consumptions_immutable_delete",
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v2",
                "runtime_generation_control_metadata_immutable_update",
                "runtime_generation_control_metadata_immutable_delete",
            ],
            allowedTables: [
                "runtime_generation_backup_preparation_consumptions",
                "runtime_generation_backup_preparation_consumptions_upgrade",
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v2",
            ],
            allowedReadTables: [
                "runtime_generation_backup_preparation_consumptions",
                "runtime_generation_backup_preparation_consumptions_upgrade",
                "runtime_generation_backup_preparations",
                "runtime_generation_backup_preparation_completions",
                "runtime_generation_backups",
                "runtime_generation_operation_leases",
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v2",
                "sqlite_master",
                "sqlite_schema",
            ]
        )
    }

    static func migrateExactLegacyV2Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV2Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 2, actual: 3)
        }
        guard let table = tableStatements.first(where: {
            $0.contains("CREATE TABLE runtime_generation_candidate_replay_audits (")
        }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV2ToV3MigrationAuthorization()
        ) { database in
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(
                in: database,
                targetVersion: 3,
                upgradeTableName: "runtime_generation_control_metadata_upgrade_v3"
            )
            try database.execute(table)
            for statement in immutableTrigger(table: "runtime_generation_candidate_replay_audits") {
                try database.execute(statement)
            }
            for statement in immutableTrigger(table: "runtime_generation_control_metadata") {
                try database.execute(statement)
            }
            try database.execute("PRAGMA user_version = 3")
        }
    }

    /// Copies the one authenticated metadata singleton into a version-specific
    /// table, replaces the immutable source table, then restores the exact
    /// singleton with its original creation instant. Callers have already
    /// removed only the metadata's immutable triggers inside their dedicated
    /// schema-migration capability.
    static func rebuildControlMetadata(
        in database: isolated SQLiteDatabase,
        targetVersion: Int,
        upgradeTableName: String
    ) throws {
        guard (2...9).contains(targetVersion) else {
            throw RuntimeGenerationControlError.unsupportedVersion(
                expected: runtimeGenerationControlSchemaVersion, actual: targetVersion
            )
        }
        let rows = try database.query(
            "SELECT singleton_id, schema_version, created_at_ms FROM runtime_generation_control_metadata LIMIT 2",
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count == 1,
              rows[0].value(named: "singleton_id") == .integer(1),
              case let .integer(createdAt)? = rows[0].value(named: "created_at_ms"),
              createdAt >= 0,
              let canonical = tableStatements.first(where: {
                  $0.contains("CREATE TABLE runtime_generation_control_metadata (")
              }) else {
            throw RuntimeGenerationControlError.recordCorrupt(kind: "control_metadata", id: "singleton")
        }
        let target = canonical.replacingOccurrences(
            of: "schema_version INTEGER NOT NULL CHECK (schema_version = 9)",
            with: "schema_version INTEGER NOT NULL CHECK (schema_version = \(targetVersion))"
        )
        try database.execute(target.replacingOccurrences(
            of: "CREATE TABLE runtime_generation_control_metadata (",
            with: "CREATE TABLE \(upgradeTableName) ("
        ))
        try database.execute(
            "INSERT INTO \(upgradeTableName)(singleton_id, schema_version, created_at_ms) VALUES(1, ?, ?)",
            bindings: [.integer(Int64(targetVersion)), .integer(createdAt)]
        )
        try database.execute("DROP TABLE runtime_generation_control_metadata")
        try database.execute(target)
        try database.execute(
            "INSERT INTO runtime_generation_control_metadata SELECT * FROM \(upgradeTableName)"
        )
        try database.execute("DROP TABLE \(upgradeTableName)")
    }

    static func legacyV2ToV3MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: [
                "runtime_generation_candidate_replay_audits",
                "runtime_generation_candidate_replay_audits_immutable_update",
                "runtime_generation_candidate_replay_audits_immutable_delete",
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v3",
            ],
            allowedTables: [
                "runtime_generation_candidate_replay_audits",
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v3",
            ],
            allowedReadTables: [
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v3",
                "sqlite_master",
                "sqlite_schema",
            ]
        )
    }

    static func migrateExactLegacyV3Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV3Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 3, actual: 4)
        }
        let additions = tableStatements.filter {
            $0.contains("CREATE TABLE runtime_generation_recovery_operation_")
        }
        guard additions.count == 2 else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV3ToV4MigrationAuthorization()
        ) { database in
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(in: database, targetVersion: 4, upgradeTableName: "runtime_generation_control_metadata_upgrade_v4")
            for statement in additions { try database.execute(statement) }
            for statement in immutableTrigger(table: "runtime_generation_recovery_operation_plans") +
                immutableTrigger(table: "runtime_generation_recovery_operation_consumptions") +
                immutableTrigger(table: "runtime_generation_control_metadata") {
                try database.execute(statement)
            }
            try database.execute("PRAGMA user_version = 4")
        }
    }

    static func legacyV3ToV4MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v4", "runtime_generation_control_metadata_immutable_update", "runtime_generation_control_metadata_immutable_delete", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_plans_immutable_update", "runtime_generation_recovery_operation_plans_immutable_delete", "runtime_generation_recovery_operation_consumptions_immutable_update", "runtime_generation_recovery_operation_consumptions_immutable_delete"],
            allowedTables: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v4", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_consumptions"],
            allowedReadTables: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v4", "sqlite_master", "sqlite_schema"]
        )
    }

    static func migrateExactLegacyV4Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV4Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 4, actual: 5)
        }
        let additions = tableStatements.filter {
            $0.contains("CREATE TABLE runtime_generation_recovery_operation_execution_")
        }
        guard additions.count == 2 else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV4ToV5MigrationAuthorization()
        ) { database in
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(in: database, targetVersion: 5, upgradeTableName: "runtime_generation_control_metadata_upgrade_v5")
            for statement in additions { try database.execute(statement) }
            for statement in immutableTrigger(table: "runtime_generation_recovery_operation_execution_claims") +
                immutableTrigger(table: "runtime_generation_recovery_operation_execution_receipts") +
                immutableTrigger(table: "runtime_generation_control_metadata") {
                try database.execute(statement)
            }
            try database.execute("PRAGMA user_version = 5")
        }
    }

    static func legacyV4ToV5MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: [
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v5",
                "runtime_generation_control_metadata_immutable_update",
                "runtime_generation_control_metadata_immutable_delete",
                "runtime_generation_recovery_operation_execution_claims",
                "runtime_generation_recovery_operation_execution_receipts",
                "runtime_generation_recovery_operation_execution_claims_immutable_update",
                "runtime_generation_recovery_operation_execution_claims_immutable_delete",
                "runtime_generation_recovery_operation_execution_receipts_immutable_update",
                "runtime_generation_recovery_operation_execution_receipts_immutable_delete",
            ],
            allowedTables: [
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v5",
                "runtime_generation_recovery_operation_execution_claims",
                "runtime_generation_recovery_operation_execution_receipts",
            ],
            allowedReadTables: [
                "runtime_generation_control_metadata",
                "runtime_generation_control_metadata_upgrade_v5",
                "sqlite_master",
                "sqlite_schema",
            ]
        )
    }

    static func migrateExactLegacyV5Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV5Schema(in: database) else { throw RuntimeGenerationControlError.unsupportedVersion(expected: 5, actual: 6) }
        try await database.schemaMigrationTransaction(.exclusive, authorization: try legacyV5ToV6MigrationAuthorization()) { database in
            let plans = try database.query("SELECT * FROM runtime_generation_recovery_operation_plans ORDER BY plan_id", maximumDecodedBytes: maximumControlReadBytes).map { try decodePayload(RuntimeGenerationRecoveryOperationPlan.self, row: $0) }
            let consumptions = try database.query("SELECT * FROM runtime_generation_recovery_operation_consumptions ORDER BY plan_id", maximumDecodedBytes: maximumControlReadBytes).map { try decodePayload(RuntimeGenerationRecoveryOperationConsumption.self, row: $0) }
            let claims = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_claims ORDER BY claim_id", maximumDecodedBytes: maximumControlReadBytes).map { try decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: $0) }
            let receipts = try database.query("SELECT * FROM runtime_generation_recovery_operation_execution_receipts ORDER BY receipt_id", maximumDecodedBytes: maximumControlReadBytes).map { try decodePayload(RuntimeGenerationRecoveryOperationExecutionReceipt.self, row: $0) }
            for table in ["runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_plans"] { try database.execute("DROP TABLE \(table)") }
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(in: database, targetVersion: 6, upgradeTableName: "runtime_generation_control_metadata_upgrade_v6")
            func table(_ name: String) throws -> String { guard let statement = tableStatements.first(where: { $0.contains("CREATE TABLE \(name) (") }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }; return statement }
            for name in ["runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_recovery_operation_plan_successions", "runtime_generation_recovery_operation_verification_bindings"] { try database.execute(try table(name)) }
            for plan in plans { let payload = try RuntimeGenerationControlCodec.encode(plan); try executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_plans", idColumn: "plan_id", id: plan.planID, columns: [("quarantine_id", .text(plan.quarantineID)), ("action", .text(plan.action.rawValue)), ("target_digest", .text(plan.targetDigest)), ("recovery_authorization_id", .text(plan.recoveryAuthorizationID)), ("recovery_authorization_digest", .text(plan.recoveryAuthorizationDigest)), ("prepared_at_ms", .integer(plan.preparedAtMilliseconds)), ("expires_at_ms", .integer(plan.expiresAtMilliseconds)), ("plan_digest", .text(plan.planDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)) }
            for claim in claims { let payload = try RuntimeGenerationControlCodec.encode(claim); try executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_execution_claims", idColumn: "claim_id", id: claim.claimID, columns: [("plan_id", .text(claim.planID)), ("executor_instance_id", .text(claim.executorInstanceID)), ("claim_epoch", .integer(claim.claimEpoch)), ("claimed_at_ms", .integer(claim.claimedAtMilliseconds)), ("expires_at_ms", .integer(claim.expiresAtMilliseconds)), ("claim_digest", .text(claim.claimDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)) }
            for receipt in receipts { let payload = try RuntimeGenerationControlCodec.encode(receipt); try executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_execution_receipts", idColumn: "receipt_id", id: receipt.receiptID, columns: [("plan_id", .text(receipt.planID)), ("claim_id", .text(receipt.claimID)), ("claim_epoch", .integer(receipt.claimEpoch)), ("quarantine_id", .text(receipt.quarantineID)), ("candidate_generation_id", receipt.candidateGenerationID.map { .text($0.rawValue) } ?? .null), ("recovery_authorization_id", .text(receipt.recoveryAuthorizationID)), ("recovery_authorization_digest", .text(receipt.recoveryAuthorizationDigest)), ("action", .text(receipt.action.rawValue)), ("target_digest", .text(receipt.targetDigest)), ("verification_id", receipt.verificationID.map { .text($0) } ?? .null), ("verification_report_digest", receipt.verificationReportDigest.map { .text($0) } ?? .null), ("verification_accepted", receipt.verificationAccepted.map { .integer($0 ? 1 : 0) } ?? .null), ("authority_classification", .text(receipt.authorityClassification.rawValue)), ("rebuild_id", receipt.rebuildID.map { .text($0) } ?? .null), ("rebuild_digest", receipt.rebuildDigest.map { .text($0) } ?? .null), ("outcome_evidence_digest", .text(receipt.outcomeEvidenceDigest)), ("executed_at_ms", .integer(receipt.executedAtMilliseconds)), ("receipt_digest", .text(receipt.receiptDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)) }
            for consumption in consumptions { let payload = try RuntimeGenerationControlCodec.encode(consumption); try executeImmutableInsert(database: database, table: "runtime_generation_recovery_operation_consumptions", idColumn: "plan_id", id: consumption.planID, columns: [("recovery_authorization_id", .text(consumption.recoveryAuthorizationID)), ("action", .text(consumption.action.rawValue)), ("target_digest", .text(consumption.targetDigest)), ("result_digest", .text(consumption.resultDigest)), ("consumed_at_ms", .integer(consumption.consumedAtMilliseconds)), ("consumption_digest", .text(consumption.consumptionDigest))], payload: payload, payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)) }
            for name in ["runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_recovery_operation_plan_successions", "runtime_generation_recovery_operation_verification_bindings", "runtime_generation_control_metadata"] { for statement in immutableTrigger(table: name) { try database.execute(statement) } }
            try database.execute("PRAGMA user_version = 6")
        }
    }

    static func legacyV5ToV6MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        let tables = ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v6", "runtime_generation_recovery_operation_plans", "runtime_generation_recovery_operation_consumptions", "runtime_generation_recovery_operation_execution_claims", "runtime_generation_recovery_operation_execution_receipts", "runtime_generation_recovery_operation_plan_dispositions", "runtime_generation_recovery_operation_plan_successions", "runtime_generation_recovery_operation_verification_bindings"]
        let triggers = tables.flatMap { immutableTrigger(table: $0) }.compactMap { $0.split(separator: " ").dropFirst(2).first.map(String.init) }
        return try SQLiteSchemaMigrationAuthorization(allowedSchemaObjects: tables + triggers, allowedTables: tables, allowedReadTables: tables + ["runtime_generation_recovery_authorizations", "runtime_generation_quarantines", "runtime_generation_verifications", "runtime_generation_rebuilds", "runtime_generation_records", "sqlite_master", "sqlite_schema"])
    }

    static func migrateExactLegacyV6Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV6Schema(in: database),
              let table = tableStatements.first(where: { $0.contains("CREATE TABLE runtime_generation_projection_rebuild_lifecycle_transitions (") }) else { throw RuntimeGenerationControlError.unsupportedVersion(expected: 6, actual: 7) }
        try await database.schemaMigrationTransaction(.exclusive, authorization: try legacyV6ToV7MigrationAuthorization()) { database in
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_update")
            try database.execute("DROP TRIGGER runtime_generation_control_metadata_immutable_delete")
            try rebuildControlMetadata(in: database, targetVersion: 7, upgradeTableName: "runtime_generation_control_metadata_upgrade_v7")
            try database.execute(table)
            for statement in immutableTrigger(table: "runtime_generation_projection_rebuild_lifecycle_transitions") + immutableTrigger(table: "runtime_generation_control_metadata") { try database.execute(statement) }
            try database.execute("PRAGMA user_version = 7")
        }
    }

    static func legacyV6ToV7MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        try SQLiteSchemaMigrationAuthorization(allowedSchemaObjects: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v7", "runtime_generation_control_metadata_immutable_update", "runtime_generation_control_metadata_immutable_delete", "runtime_generation_projection_rebuild_lifecycle_transitions", "runtime_generation_projection_rebuild_lifecycle_transitions_immutable_update", "runtime_generation_projection_rebuild_lifecycle_transitions_immutable_delete"], allowedTables: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v7", "runtime_generation_projection_rebuild_lifecycle_transitions"], allowedReadTables: ["runtime_generation_control_metadata", "runtime_generation_control_metadata_upgrade_v7", "sqlite_master", "sqlite_schema"])
    }

    /// v8 persists the recovery execution claim that admitted a projection
    /// rebuild directly on its migration run. The migration reconstructs the
    /// affected FK closure rather than mutating sqlite_master or disabling
    /// foreign keys: every legacy payload is copied byte-for-byte, while only
    /// the newly introduced linkage columns are initialized to NULL.
    static func migrateExactLegacyV7Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV7Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 7, actual: 8)
        }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV7ToV8MigrationAuthorization()
        ) { database in
            let rebuiltTables = [
                "runtime_generation_migration_runs",
                "runtime_generation_records",
                "runtime_generation_verifications",
                "runtime_generation_retention_transitions",
                "runtime_generation_activation_intents",
                "runtime_generation_activation_consumptions",
                "runtime_generation_active_authority",
                "runtime_generation_restore_baselines",
                "runtime_generation_rollbacks",
                "runtime_generation_recovery_precommit_witnesses",
                "runtime_generation_recovery_operation_execution_receipts",
                "runtime_generation_recovery_operation_verification_bindings",
                "runtime_generation_projection_rebuild_lifecycle_transitions",
            ]
            let allRebuiltTables = rebuiltTables + ["runtime_generation_control_metadata"]
            func tableStatement(_ name: String) throws -> String {
                guard let statement = tableStatements.first(where: {
                    $0.contains("CREATE TABLE \(name) (")
                }) else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                return statement
            }
            func indexStatement(_ name: String) throws -> String {
                guard let statement = indexStatements.first(where: {
                    $0.contains("CREATE ") && $0.contains(" \(name) ")
                }) else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                return statement
            }
            func upgradedName(_ name: String) -> String { "\(name)_upgrade_v8" }

            // Trigger names do not follow a table rename. Remove each exact
            // immutable trigger first so canonical names are available after
            // the target tables are installed.
            for name in allRebuiltTables {
                for trigger in immutableTrigger(table: name) {
                    let parts = trigger.split(separator: " ")
                    guard parts.count >= 3 else {
                        throw RuntimeGenerationControlError.controlAuthorityUnavailable
                    }
                    try database.execute("DROP TRIGGER \(parts[2])")
                }
            }

            for name in rebuiltTables {
                try database.execute("ALTER TABLE \(name) RENAME TO \(upgradedName(name))")
            }

            // A composite FK on the replacement run table requires an
            // independently unique parent key before rows are inserted.
            try database.execute(
                try indexStatement(
                    "runtime_generation_recovery_execution_claims_plan_claim_epoch_uq"
                )
            )
            try database.execute(try tableStatement("runtime_generation_migration_runs"))
            for name in rebuiltTables.dropFirst() {
                try database.execute(try tableStatement(name))
            }

            let legacyRuns = upgradedName("runtime_generation_migration_runs")
            try database.execute(
                """
                INSERT INTO runtime_generation_migration_runs(
                    migration_run_id, executor_instance_id, reservation_id,
                    operation_lease_id, operation_lease_epoch,
                    operation_fencing_token, source_safety_backup_id,
                    backup_id, recovery_authorization_id,
                    recovery_authorization_digest, recovery_execution_plan_id,
                    recovery_execution_claim_id, recovery_execution_claim_epoch,
                    operation_kind, source_schema_version,
                    candidate_generation_id, target_schema_version,
                    transformation_version, provenance_digest, started_at_ms,
                    completed_at_ms, run_digest, payload, payload_digest
                )
                SELECT
                    migration_run_id, executor_instance_id, reservation_id,
                    operation_lease_id, operation_lease_epoch,
                    operation_fencing_token, NULL, backup_id,
                    recovery_authorization_id, recovery_authorization_digest,
                    NULL, NULL, NULL, operation_kind, source_schema_version,
                    candidate_generation_id, target_schema_version,
                    transformation_version, provenance_digest, started_at_ms,
                    completed_at_ms, run_digest, payload, payload_digest
                FROM \(legacyRuns)
                WHERE operation_kind <> 'projection_rebuild'
                """
            )
            let projectionRows = try database.query(
                "SELECT * FROM \(legacyRuns) WHERE operation_kind = ? ORDER BY migration_run_id",
                bindings: [.text(RuntimeGenerationOperationKind.projectionRebuild.rawValue)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            for row in projectionRows {
                guard case let .blob(legacyPayload)? = row.value(named: "payload"),
                      case let .text(legacyPayloadDigest)? = row.value(named: "payload_digest"),
                      legacyPayload.count <= maximumControlReadBytes,
                      LocalRuntimeStorageChecksum.sha256Hex(for: legacyPayload) == legacyPayloadDigest else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_run", id: "payload"
                    )
                }
                let legacy = try RuntimeGenerationControlCodec.decode(
                    RuntimeGenerationMigrationRun.self, from: legacyPayload
                )
                try legacy.validate()
                func optionalText(_ value: String?) -> SQLiteValue {
                    value.map(SQLiteValue.text) ?? .null
                }
                guard row.value(named: "migration_run_id") == .text(legacy.migrationRunID),
                      row.value(named: "executor_instance_id") == .text(legacy.executorInstanceID),
                      row.value(named: "reservation_id") == .text(legacy.reservationID),
                      row.value(named: "operation_lease_id") == .text(legacy.operationLeaseID),
                      row.value(named: "operation_lease_epoch") == .integer(legacy.operationLeaseEpoch),
                      row.value(named: "operation_fencing_token") == .integer(legacy.operationFencingToken),
                      row.value(named: "backup_id") == optionalText(legacy.backupID),
                      row.value(named: "recovery_authorization_id") == optionalText(legacy.recoveryAuthorizationID),
                      row.value(named: "recovery_authorization_digest") == optionalText(legacy.recoveryAuthorizationDigest),
                      row.value(named: "operation_kind") == .text(RuntimeGenerationOperationKind.projectionRebuild.rawValue),
                      row.value(named: "source_schema_version") == legacy.sourceSchemaVersion.map { .integer(Int64($0)) } ?? .null,
                      row.value(named: "candidate_generation_id") == .text(legacy.candidateGenerationID.rawValue),
                      row.value(named: "target_schema_version") == .integer(Int64(legacy.targetSchemaVersion)),
                      row.value(named: "transformation_version") == .integer(Int64(legacy.transformationVersion)),
                      row.value(named: "provenance_digest") == .text(legacy.provenanceDigest),
                      row.value(named: "started_at_ms") == .integer(legacy.startedAtMilliseconds),
                      row.value(named: "completed_at_ms") == .integer(legacy.completedAtMilliseconds),
                      row.value(named: "run_digest") == .text(legacy.runDigest),
                      legacy.operationKind == .projectionRebuild,
                      let legacyBackupID = legacy.backupID else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_run", id: legacy.migrationRunID
                    )
                }

                let transitionRows = try database.query(
                    "SELECT * FROM \(upgradedName(\"runtime_generation_projection_rebuild_lifecycle_transitions\")) WHERE migration_run_id = ? ORDER BY occurred_at_ms, transition_id",
                    bindings: [.text(legacy.migrationRunID)],
                    maximumDecodedBytes: maximumControlReadBytes
                )
                guard let firstTransitionRow = transitionRows.first else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_transition", id: legacy.migrationRunID
                    )
                }
                let firstTransition = try Self.decodePayload(
                    RuntimeGenerationProjectionRebuildLifecycleTransition.self,
                    row: firstTransitionRow
                )
                let transitions = try transitionRows.map {
                    try Self.decodePayload(
                        RuntimeGenerationProjectionRebuildLifecycleTransition.self,
                        row: $0
                    )
                }
                guard transitions.allSatisfy({ transition in
                    transition.migrationRunID == legacy.migrationRunID &&
                        transition.recoveryExecutionPlanID == firstTransition.recoveryExecutionPlanID &&
                        transition.recoveryExecutionClaimID == firstTransition.recoveryExecutionClaimID &&
                        transition.recoveryExecutionClaimEpoch == firstTransition.recoveryExecutionClaimEpoch
                }) else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_transition", id: legacy.migrationRunID
                    )
                }
                let plan = try Self.loadPayload(
                    RuntimeGenerationRecoveryOperationPlan.self,
                    table: "runtime_generation_recovery_operation_plans",
                    idColumn: "plan_id",
                    id: firstTransition.recoveryExecutionPlanID,
                    database: database
                )
                let claim = try Self.loadPayload(
                    RuntimeGenerationRecoveryOperationExecutionClaim.self,
                    table: "runtime_generation_recovery_operation_execution_claims",
                    idColumn: "claim_id",
                    id: firstTransition.recoveryExecutionClaimID,
                    database: database
                )
                let reservation = try Self.loadPayload(
                    RuntimeGenerationReservation.self,
                    table: "runtime_generation_reservations",
                    idColumn: "reservation_id",
                    id: legacy.reservationID,
                    database: database
                )
                let safetyBackup = try Self.loadEligibleBackup(
                    id: legacyBackupID,
                    database: database
                )
                guard plan.action == .rebuildDerivedState,
                      claim.planID == plan.planID,
                      claim.claimEpoch == firstTransition.recoveryExecutionClaimEpoch,
                      firstTransition.phase == .admitted,
                      firstTransition.priorTransitionDigest == nil,
                      transitions.allSatisfy {
                          $0.occurredAtMilliseconds >= claim.claimedAtMilliseconds &&
                              $0.occurredAtMilliseconds < claim.expiresAtMilliseconds
                      },
                      zip(transitions, transitions.dropFirst()).allSatisfy {
                          previous, current in
                          current.priorTransitionDigest == previous.transitionDigest &&
                              current.occurredAtMilliseconds >=
                                previous.occurredAtMilliseconds &&
                              Self.allowsProjectionRebuildTransition(
                                from: previous.phase,
                                to: current.phase
                              )
                      },
                      reservation.operationKind == .projectionRebuild,
                      reservation.candidateGenerationID == legacy.candidateGenerationID,
                      safetyBackup.sourceGenerationID == reservation.sourceGenerationID,
                      safetyBackup.sourceGenerationDigest == reservation.sourceGenerationDigest,
                      safetyBackup.createdAtMilliseconds <= legacy.startedAtMilliseconds,
                      (legacy.sourceSafetyBackupID == nil ||
                        legacy.sourceSafetyBackupID == safetyBackup.backupID),
                      (legacy.recoveryExecutionPlanID == nil ||
                        legacy.recoveryExecutionPlanID == plan.planID),
                      (legacy.recoveryExecutionClaimID == nil ||
                        legacy.recoveryExecutionClaimID == claim.claimID),
                      (legacy.recoveryExecutionClaimEpoch == nil ||
                        legacy.recoveryExecutionClaimEpoch == claim.claimEpoch) else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_run", id: legacy.migrationRunID
                    )
                }
                let rebuilt = try RuntimeGenerationControlRecordFactory.migrationRun(
                    id: legacy.migrationRunID,
                    executorInstanceID: legacy.executorInstanceID,
                    reservationID: legacy.reservationID,
                    operationLeaseID: legacy.operationLeaseID,
                    operationLeaseEpoch: legacy.operationLeaseEpoch,
                    operationFencingToken: legacy.operationFencingToken,
                    sourceSafetyBackupID: safetyBackup.backupID,
                    backupID: legacyBackupID,
                    recoveryAuthorizationID: legacy.recoveryAuthorizationID,
                    recoveryAuthorizationDigest: legacy.recoveryAuthorizationDigest,
                    recoveryExecutionPlanID: plan.planID,
                    recoveryExecutionClaimID: claim.claimID,
                    recoveryExecutionClaimEpoch: claim.claimEpoch,
                    operationKind: .projectionRebuild,
                    sourceSchemaVersion: legacy.sourceSchemaVersion,
                    candidateGenerationID: legacy.candidateGenerationID,
                    transformationVersion: legacy.transformationVersion,
                    provenanceDigest: legacy.provenanceDigest,
                    startedAtMilliseconds: legacy.startedAtMilliseconds,
                    completedAtMilliseconds: legacy.completedAtMilliseconds
                )
                guard rebuilt.targetSchemaVersion == legacy.targetSchemaVersion else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_run", id: legacy.migrationRunID
                    )
                }
                let rebuiltPayload = try RuntimeGenerationControlCodec.encode(rebuilt)
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_migration_runs",
                    idColumn: "migration_run_id",
                    id: rebuilt.migrationRunID,
                    columns: [
                        ("executor_instance_id", .text(rebuilt.executorInstanceID)),
                        ("reservation_id", .text(rebuilt.reservationID)),
                        ("operation_lease_id", .text(rebuilt.operationLeaseID)),
                        ("operation_lease_epoch", .integer(rebuilt.operationLeaseEpoch)),
                        ("operation_fencing_token", .integer(rebuilt.operationFencingToken)),
                        ("source_safety_backup_id", .text(safetyBackup.backupID)),
                        ("backup_id", .text(legacyBackupID)),
                        ("recovery_authorization_id", rebuilt.recoveryAuthorizationID.map(SQLiteBinding.text) ?? .null),
                        ("recovery_authorization_digest", rebuilt.recoveryAuthorizationDigest.map(SQLiteBinding.text) ?? .null),
                        ("recovery_execution_plan_id", .text(plan.planID)),
                        ("recovery_execution_claim_id", .text(claim.claimID)),
                        ("recovery_execution_claim_epoch", .integer(claim.claimEpoch)),
                        ("operation_kind", .text(rebuilt.operationKind.rawValue)),
                        ("source_schema_version", rebuilt.sourceSchemaVersion.map { .integer(Int64($0)) } ?? .null),
                        ("candidate_generation_id", .text(rebuilt.candidateGenerationID.rawValue)),
                        ("target_schema_version", .integer(Int64(rebuilt.targetSchemaVersion))),
                        ("transformation_version", .integer(Int64(rebuilt.transformationVersion))),
                        ("provenance_digest", .text(rebuilt.provenanceDigest)),
                        ("started_at_ms", .integer(rebuilt.startedAtMilliseconds)),
                        ("completed_at_ms", .integer(rebuilt.completedAtMilliseconds)),
                        ("run_digest", .text(rebuilt.runDigest)),
                    ],
                    payload: rebuiltPayload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: rebuiltPayload)
                )
            }
            for name in rebuiltTables.dropFirst() {
                let legacy = upgradedName(name)
                try database.execute("INSERT INTO \(name) SELECT * FROM \(legacy)")
            }

            // Drop staged children before their staged parents. Existing
            // payloads and their original values remain untouched above.
            for name in rebuiltTables.reversed() {
                try database.execute("DROP TABLE \(upgradedName(name))")
            }

            try rebuildControlMetadata(
                in: database,
                targetVersion: 8,
                upgradeTableName: "runtime_generation_control_metadata_upgrade_v8"
            )
            try database.execute(
                try indexStatement("runtime_generation_retention_current_idx")
            )
            try database.execute(
                try indexStatement("runtime_generation_migration_runs_source_safety_backup_idx")
            )
            try database.execute(
                try indexStatement("runtime_generation_migration_runs_recovery_execution_idx")
            )
            for name in allRebuiltTables {
                for trigger in immutableTrigger(table: name) {
                    try database.execute(trigger)
                }
            }
            try database.execute("PRAGMA user_version = 8")
        }
    }

    static func legacyV7ToV8MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        let rebuiltTables = [
            "runtime_generation_migration_runs",
            "runtime_generation_records",
            "runtime_generation_verifications",
            "runtime_generation_retention_transitions",
            "runtime_generation_activation_intents",
            "runtime_generation_activation_consumptions",
            "runtime_generation_active_authority",
            "runtime_generation_restore_baselines",
            "runtime_generation_rollbacks",
            "runtime_generation_recovery_precommit_witnesses",
            "runtime_generation_recovery_operation_execution_receipts",
            "runtime_generation_recovery_operation_verification_bindings",
            "runtime_generation_projection_rebuild_lifecycle_transitions",
            "runtime_generation_control_metadata",
        ]
        let upgradeTables = rebuiltTables.map { "\($0)_upgrade_v8" }
        let triggerNames = rebuiltTables.flatMap { table in
            immutableTrigger(table: table).compactMap { statement in
                statement.split(separator: " ").dropFirst(2).first.map(String.init)
            }
        }
        let indexes = [
            "runtime_generation_retention_current_idx",
            "runtime_generation_migration_runs_source_safety_backup_idx",
            "runtime_generation_migration_runs_recovery_execution_idx",
            "runtime_generation_recovery_execution_claims_plan_claim_epoch_uq",
        ]
        return try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: rebuiltTables + upgradeTables + triggerNames + indexes + [
                "runtime_generation_recovery_operation_execution_claims",
            ],
            allowedTables: rebuiltTables + upgradeTables + [
                "runtime_generation_recovery_operation_execution_claims",
            ],
            allowedReadTables: rebuiltTables + upgradeTables + [
                "runtime_generation_reservations",
                "runtime_generation_backups",
                "runtime_generation_backup_preparations",
                "runtime_generation_backup_preparation_completions",
                "runtime_generation_backup_preparation_consumptions",
                "runtime_generation_operation_leases",
                "runtime_generation_recovery_operation_plans",
                "runtime_generation_recovery_operation_execution_claims",
                "sqlite_master",
                "sqlite_schema",
            ]
        )
    }

    /// Rebuilds the v8 certificate table and its receipt child as one staged
    /// FK-preserving operation. A v8 row is accepted only when its canonical
    /// payload can be authenticated and every relational certificate edge can
    /// be reconstructed from immutable run, claim, transition, and generation
    /// evidence. Rows which merely look like rebuilds cannot survive upgrade.
    static func migrateExactLegacyV8Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV8Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 8, actual: 9)
        }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV8ToV9MigrationAuthorization()
        ) { database in
            let rebuiltTables = [
                "runtime_generation_rebuilds",
                "runtime_generation_recovery_operation_execution_receipts",
            ]
            let allRebuiltTables = rebuiltTables + ["runtime_generation_control_metadata"]
            func tableStatement(_ name: String) throws -> String {
                guard let statement = tableStatements.first(where: {
                    $0.contains("CREATE TABLE \(name) (")
                }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
                return statement
            }
            func upgradedName(_ name: String) -> String { "\(name)_upgrade_v9" }
            for name in allRebuiltTables {
                for trigger in immutableTrigger(table: name) {
                    let parts = trigger.split(separator: " ")
                    guard parts.count >= 3 else {
                        throw RuntimeGenerationControlError.controlAuthorityUnavailable
                    }
                    try database.execute("DROP TRIGGER \(parts[2])")
                }
            }
            // Rename child first, then its parent. The replacement child is
            // installed only after the new parent exists, preserving FK shape.
            try database.execute(
                "ALTER TABLE runtime_generation_recovery_operation_execution_receipts RENAME TO \(upgradedName(\"runtime_generation_recovery_operation_execution_receipts\"))"
            )
            try database.execute(
                "ALTER TABLE runtime_generation_rebuilds RENAME TO \(upgradedName(\"runtime_generation_rebuilds\"))"
            )
            try database.execute(try tableStatement("runtime_generation_rebuilds"))
            try database.execute(try tableStatement("runtime_generation_recovery_operation_execution_receipts"))

            let legacyRebuilds = upgradedName("runtime_generation_rebuilds")
            let rows = try database.query(
                "SELECT * FROM \(legacyRebuilds) ORDER BY rebuild_id",
                maximumDecodedBytes: maximumControlReadBytes
            )
            for row in rows {
                let legacy = try Self.decodePayload(
                    RuntimeGenerationRebuildRecord.self, row: row
                )
                try RuntimeGenerationControlRecordFactory.validate(legacy)
                guard row.value(named: "rebuild_id") == .text(legacy.rebuildID),
                      row.value(named: "source_generation_id") == .text(legacy.sourceGenerationID.rawValue),
                      row.value(named: "source_fence_digest") == .text(legacy.sourceFenceDigest),
                      row.value(named: "equivalence_digest") == .text(legacy.equivalenceDigest),
                      row.value(named: "published_at_ms") == .integer(legacy.publishedAtMilliseconds),
                      row.value(named: "rebuild_digest") == .text(legacy.rebuildDigest) else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild", id: legacy.rebuildID
                    )
                }
                let run = try Self.loadPayload(
                    RuntimeGenerationMigrationRun.self,
                    table: "runtime_generation_migration_runs",
                    idColumn: "migration_run_id", id: legacy.migrationRunID,
                    database: database
                )
                let reservation = try Self.loadPayload(
                    RuntimeGenerationReservation.self,
                    table: "runtime_generation_reservations",
                    idColumn: "reservation_id", id: run.reservationID,
                    database: database
                )
                let plan = try Self.loadPayload(
                    RuntimeGenerationRecoveryOperationPlan.self,
                    table: "runtime_generation_recovery_operation_plans",
                    idColumn: "plan_id", id: legacy.recoveryExecutionPlanID,
                    database: database
                )
                let claim = try Self.loadPayload(
                    RuntimeGenerationRecoveryOperationExecutionClaim.self,
                    table: "runtime_generation_recovery_operation_execution_claims",
                    idColumn: "claim_id", id: legacy.recoveryExecutionClaimID,
                    database: database
                )
                _ = try Self.loadPayload(
                    RuntimeGenerationCandidateRecord.self,
                    table: "runtime_generation_records",
                    idColumn: "generation_id", id: legacy.candidateGenerationID.rawValue,
                    database: database
                )
                _ = try Self.loadPayload(
                    RuntimeGenerationCandidateRecord.self,
                    table: "runtime_generation_records",
                    idColumn: "generation_id", id: legacy.sourceGenerationID.rawValue,
                    database: database
                )
                let transitionRows = try database.query(
                    "SELECT * FROM runtime_generation_projection_rebuild_lifecycle_transitions WHERE migration_run_id = ? AND transition_digest = ? AND phase = ? LIMIT 2",
                    bindings: [
                        .text(run.migrationRunID),
                        .text(legacy.readyTransitionDigest),
                        .text(RuntimeGenerationProjectionRebuildPhase.readyForCertification.rawValue),
                    ],
                    maximumDecodedBytes: maximumControlReadBytes
                )
                guard transitionRows.count == 1, let transitionRow = transitionRows.first else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild_transition", id: legacy.rebuildID
                    )
                }
                let ready = try Self.decodePayload(
                    RuntimeGenerationProjectionRebuildLifecycleTransition.self,
                    row: transitionRow
                )
                let latestClaimRows = try database.query(
                    "SELECT * FROM runtime_generation_recovery_operation_execution_claims WHERE plan_id = ? ORDER BY claim_epoch DESC LIMIT 1",
                    bindings: [.text(plan.planID)],
                    maximumDecodedBytes: maximumControlReadBytes
                )
                guard run.operationKind == .projectionRebuild,
                      run.reservationID == reservation.reservationID,
                      run.candidateGenerationID == legacy.candidateGenerationID,
                      run.recoveryExecutionPlanID == plan.planID,
                      run.recoveryExecutionClaimID == claim.claimID,
                      run.recoveryExecutionClaimEpoch == claim.claimEpoch,
                      reservation.operationKind == .projectionRebuild,
                      reservation.candidateGenerationID == legacy.candidateGenerationID,
                      reservation.sourceGenerationID == legacy.sourceGenerationID,
                      plan.action == .rebuildDerivedState,
                      claim.planID == plan.planID,
                      claim.claimEpoch == legacy.recoveryExecutionClaimEpoch,
                      latestClaimRows.count == 1,
                      try Self.decodePayload(RuntimeGenerationRecoveryOperationExecutionClaim.self, row: latestClaimRows[0]) == claim,
                      ready.phase == .readyForCertification,
                      ready.transitionDigest == legacy.readyTransitionDigest,
                      ready.recoveryExecutionPlanID == plan.planID,
                      ready.recoveryExecutionClaimID == claim.claimID,
                      ready.recoveryExecutionClaimEpoch == claim.claimEpoch,
                      legacy.publishedAtMilliseconds >= ready.occurredAtMilliseconds else {
                    throw RuntimeGenerationControlError.recordCorrupt(
                        kind: "legacy_projection_rebuild", id: legacy.rebuildID
                    )
                }
                let payload = try RuntimeGenerationControlCodec.encode(legacy)
                try Self.executeImmutableInsert(
                    database: database,
                    table: "runtime_generation_rebuilds",
                    idColumn: "rebuild_id", id: legacy.rebuildID,
                    columns: [
                        ("migration_run_id", .text(legacy.migrationRunID)),
                        ("recovery_execution_plan_id", .text(legacy.recoveryExecutionPlanID)),
                        ("recovery_execution_claim_id", .text(legacy.recoveryExecutionClaimID)),
                        ("recovery_execution_claim_epoch", .integer(legacy.recoveryExecutionClaimEpoch)),
                        ("candidate_generation_id", .text(legacy.candidateGenerationID.rawValue)),
                        ("ready_transition_digest", .text(legacy.readyTransitionDigest)),
                        ("source_generation_id", .text(legacy.sourceGenerationID.rawValue)),
                        ("source_fence_digest", .text(legacy.sourceFenceDigest)),
                        ("equivalence_digest", .text(legacy.equivalenceDigest)),
                        ("published_at_ms", .integer(legacy.publishedAtMilliseconds)),
                        ("rebuild_digest", .text(legacy.rebuildDigest)),
                    ],
                    payload: payload,
                    payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
                )
            }
            let legacyReceipts = upgradedName(
                "runtime_generation_recovery_operation_execution_receipts"
            )
            try database.execute(
                "INSERT INTO runtime_generation_recovery_operation_execution_receipts SELECT * FROM \(legacyReceipts)"
            )
            try database.execute("DROP TABLE \(legacyReceipts)")
            try database.execute("DROP TABLE \(legacyRebuilds)")
            try rebuildControlMetadata(
                in: database, targetVersion: 9,
                upgradeTableName: "runtime_generation_control_metadata_upgrade_v9"
            )
            for name in allRebuiltTables {
                for trigger in immutableTrigger(table: name) { try database.execute(trigger) }
            }
            guard let index = indexStatements.first(where: {
                $0.contains("runtime_generation_rebuilds_recovery_execution_idx")
            }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            try database.execute(index)
            try database.execute("PRAGMA user_version = 9")
        }
    }

    static func legacyV8ToV9MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        let rebuiltTables = [
            "runtime_generation_rebuilds",
            "runtime_generation_recovery_operation_execution_receipts",
            "runtime_generation_control_metadata",
        ]
        let upgradedTables = rebuiltTables.map { "\($0)_upgrade_v9" }
        let triggerNames = rebuiltTables.flatMap { table in
            immutableTrigger(table: table).compactMap { statement in
                statement.split(separator: " ").dropFirst(2).first.map(String.init)
            }
        }
        return try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: rebuiltTables + upgradedTables + triggerNames + [
                "runtime_generation_rebuilds_recovery_execution_idx",
            ],
            allowedTables: rebuiltTables + upgradedTables,
            allowedReadTables: rebuiltTables + upgradedTables + [
                "runtime_generation_migration_runs",
                "runtime_generation_reservations",
                "runtime_generation_records",
                "runtime_generation_recovery_operation_plans",
                "runtime_generation_recovery_operation_execution_claims",
                "runtime_generation_projection_rebuild_lifecycle_transitions",
                "sqlite_master",
                "sqlite_schema",
            ]
        )
    }

    /// v9→v10 is an additive authority upgrade plus a metadata-table rebuild
    /// (the immutable metadata DDL carries a version CHECK). No legacy v9
    /// candidate can be retroactively assigned stage-one identifiers, so the
    /// new tables start empty rather than manufacturing commitments.
    static func migrateExactLegacyV9Schema(in database: SQLiteDatabase) async throws {
        guard try await isExactLegacyV9Schema(in: database) else {
            throw RuntimeGenerationControlError.unsupportedVersion(expected: 9, actual: 10)
        }
        try await database.schemaMigrationTransaction(
            .exclusive,
            authorization: try legacyV9ToV10MigrationAuthorization()
        ) { database in
            let metadata = "runtime_generation_control_metadata"
            let upgradedMetadata = "runtime_generation_control_metadata_upgrade_v10"
            for trigger in immutableTrigger(table: metadata) {
                let parts = trigger.split(separator: " ")
                guard parts.count >= 3 else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
                try database.execute("DROP TRIGGER \(parts[2])")
            }
            try database.execute("ALTER TABLE \(metadata) RENAME TO \(upgradedMetadata)")
            guard let metadataDDL = tableStatements.first(where: {
                $0.contains("CREATE TABLE runtime_generation_control_metadata (")
            }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            try database.execute(metadataDDL)
            try database.execute("INSERT INTO runtime_generation_control_metadata(singleton_id, schema_version, created_at_ms) VALUES(1, 10, 0)")
            try database.execute("DROP TABLE \(upgradedMetadata)")
            for table in [
                "runtime_generation_projection_rebuild_candidate_reservations",
                "runtime_generation_projection_rebuild_candidate_authority_commitments",
            ] {
                guard let ddl = tableStatements.first(where: { $0.contains("CREATE TABLE \(table) (") }) else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                try database.execute(ddl)
                for trigger in immutableTrigger(table: table) { try database.execute(trigger) }
            }
            guard let index = indexStatements.first(where: {
                $0.contains("runtime_generation_projection_rebuild_candidate_reservations_claim_idx")
            }) else { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            try database.execute(index)
            for trigger in immutableTrigger(table: metadata) { try database.execute(trigger) }
            try database.execute("PRAGMA user_version = 10")
        }
    }

    static func legacyV9ToV10MigrationAuthorization() throws -> SQLiteSchemaMigrationAuthorization {
        let metadata = "runtime_generation_control_metadata"
        let upgradedMetadata = "runtime_generation_control_metadata_upgrade_v10"
        let tables = [
            metadata,
            upgradedMetadata,
            "runtime_generation_projection_rebuild_candidate_reservations",
            "runtime_generation_projection_rebuild_candidate_authority_commitments",
        ]
        let triggers = tables.flatMap { table in
            immutableTrigger(table: table).compactMap { statement in
                statement.split(separator: " ").dropFirst(2).first.map(String.init)
            }
        }
        return try SQLiteSchemaMigrationAuthorization(
            allowedSchemaObjects: tables + triggers + [
                "runtime_generation_projection_rebuild_candidate_reservations_claim_idx",
            ],
            allowedTables: tables,
            allowedReadTables: [metadata, upgradedMetadata, "sqlite_master", "sqlite_schema"]
        )
    }

    static func schemaCatalog(_ statements: [String]) throws -> [String: String] {
        var catalog: [String: String] = [:]
        for statement in statements {
            let tokens = statement.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            guard tokens.count >= 3, tokens[0] == "CREATE" else {
                throw RuntimeGenerationControlError.malformed(field: "control_schema")
            }
            let kind: String
            let name: String
            if tokens[1] == "TABLE" || tokens[1] == "TRIGGER" {
                kind = tokens[1].lowercased(); name = tokens[2]
            } else if tokens[1] == "INDEX" {
                kind = "index"; name = tokens[2]
            } else {
                throw RuntimeGenerationControlError.malformed(field: "control_schema")
            }
            guard catalog.updateValue(normalizeSQL(statement), forKey: "\(kind):\(name)") == nil else {
                throw RuntimeGenerationControlError.malformed(field: "duplicate_control_schema")
            }
        }
        return catalog
    }

    static func schemaCatalog(rows: [SQLiteRow]) throws -> [String: String] {
        var catalog: [String: String] = [:]
        for row in rows {
            guard case let .text(kind)? = row.value(named: "type"),
                  case let .text(name)? = row.value(named: "name"),
                  case let .text(sql)? = row.value(named: "sql"),
                  catalog.updateValue(normalizeSQL(sql), forKey: "\(kind):\(name)") == nil
            else {
                throw RuntimeGenerationControlError.malformed(field: "control_schema")
            }
        }
        return catalog
    }

    static func normalizeSQL(_ value: String) -> String {
        value.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    func insertImmutable<Value: Codable & Sendable>(
        table: String,
        idColumn: String,
        id: String,
        columns: [(String, SQLiteBinding)],
        payload: Value
    ) async throws {
        try revalidateAuthority()
        let bytes = try RuntimeGenerationControlCodec.encode(payload)
        let digest = LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        try await database.transaction(
            .immediate,
            writeAuthorization: try Self.mutationAuthorization(
                writing: [table], reading: [table]
            )
        ) { database in
            try Self.executeImmutableInsert(
                database: database,
                table: table,
                idColumn: idColumn,
                id: id,
                columns: columns,
                payload: bytes,
                payloadDigest: digest
            )
        }
    }

    static func mutationAuthorization(
        writing: Set<String>,
        reading: Set<String>
    ) throws -> SQLiteWriteAuthorization {
        try SQLiteWriteAuthorization(
            allowedTables: writing,
            allowedReadTables: reading.union(writing)
        )
    }

    static func executeImmutableInsert(
        database: isolated SQLiteDatabase,
        table: String,
        idColumn: String,
        id: String,
        columns: [(String, SQLiteBinding)],
        payload: Data,
        payloadDigest: String
    ) throws {
        try requireSchemaIdentifier(table)
        try requireSchemaIdentifier(idColumn)
        for (name, _) in columns { try requireSchemaIdentifier(name) }
        let names = [idColumn] + columns.map(\.0) + ["payload", "payload_digest"]
        let placeholders = Array(repeating: "?", count: names.count).joined(separator: ",")
        let sql = "INSERT INTO \(table)(\(names.joined(separator: ","))) VALUES(\(placeholders))"
        let expectedValues = [.text(id)] + columns.map { sqliteValue($0.1) }
            + [.blob(payload), .text(payloadDigest)]
        if try immutableRowAlreadyMatches(
            database: database,
            table: table,
            idColumn: idColumn,
            id: id,
            names: names,
            expectedValues: expectedValues
        ) {
            return
        }
        do {
            let result = try database.execute(
                sql,
                bindings: [.text(id)] + columns.map(\.1) + [.blob(payload), .text(payloadDigest)]
            )
            guard result.changedRowCount == 1 else {
                throw RuntimeGenerationControlError.recordConflict(kind: table, id: id)
            }
        } catch let error as RuntimeGenerationControlError {
            throw error
        } catch {
            // Preserve IOERR, FULL, CORRUPT, foreign-key, and other database
            // failures. Only classify an exact same-ID/different-payload row
            // as an immutable conflict. An exact retry is accepted so every
            // journal phase is crash-idempotent after an ambiguous COMMIT.
            if try immutableRowAlreadyMatches(
                database: database,
                table: table,
                idColumn: idColumn,
                id: id,
                names: names,
                expectedValues: expectedValues
            ) {
                return
            }
            let sameID = try database.query(
                "SELECT \(idColumn) FROM \(table) WHERE \(idColumn) = ? LIMIT 2",
                bindings: [.text(id)],
                maximumDecodedBytes: maximumControlReadBytes
            )
            if sameID.isEmpty == false {
                throw RuntimeGenerationControlError.recordConflict(kind: table, id: id)
            }
            throw error
        }
    }

    static func insertRetentionTransition(
        _ transition: RuntimeGenerationRetentionTransition,
        database: isolated SQLiteDatabase
    ) throws {
        try RuntimeGenerationControlRecordFactory.validate(transition)
        let existing = try database.query(
            "SELECT * FROM runtime_generation_retention_transitions WHERE transition_id = ? LIMIT 2",
            bindings: [.text(transition.transitionID)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        if let row = existing.first {
            guard existing.count == 1,
                  try decodePayload(
                    RuntimeGenerationRetentionTransition.self, row: row
                  ) == transition else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            return
        }
        let candidate = try loadPayload(
            RuntimeGenerationCandidateRecord.self,
            table: "runtime_generation_records",
            idColumn: "generation_id",
            id: transition.generationID.rawValue,
            database: database
        )
        let latest = try database.query(
            "SELECT * FROM runtime_generation_retention_transitions WHERE generation_id = ? ORDER BY occurred_at_ms DESC, transition_id DESC LIMIT 1",
            bindings: [.text(transition.generationID.rawValue)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        let latestTransition = try latest.first.map {
            try decodePayload(RuntimeGenerationRetentionTransition.self, row: $0)
        }
        let current = latestTransition?.toClass ?? candidate.authorityManifest.retentionClass
        guard current == transition.fromClass,
              latestTransition.map({
                transition.occurredAtMilliseconds > $0.occurredAtMilliseconds
              }) ?? true,
              RuntimeGenerationRetentionClass.allowsTransition(
                from: transition.fromClass,
                to: transition.toClass
              ) else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let payload = try RuntimeGenerationControlCodec.encode(transition)
        try executeImmutableInsert(
            database: database,
            table: "runtime_generation_retention_transitions",
            idColumn: "transition_id",
            id: transition.transitionID,
            columns: [
                ("generation_id", .text(transition.generationID.rawValue)),
                ("from_class", transition.fromClass.map { .text($0.rawValue) } ?? .null),
                ("to_class", .text(transition.toClass.rawValue)),
                ("authority_digest", .text(transition.authorityDigest)),
                ("occurred_at_ms", .integer(transition.occurredAtMilliseconds)),
                ("transition_digest", .text(transition.transitionDigest)),
            ],
            payload: payload,
            payloadDigest: LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        )
    }

    static func immutableRowAlreadyMatches(
        database: isolated SQLiteDatabase,
        table: String,
        idColumn: String,
        id: String,
        names: [String],
        expectedValues: [SQLiteValue]
    ) throws -> Bool {
        let rows = try database.query(
            "SELECT \(names.joined(separator: ",")) FROM \(table) WHERE \(idColumn) = ? LIMIT 2",
            bindings: [.text(id)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(kind: table, id: id)
        }
        guard let row = rows.first else { return false }
        guard row.values == expectedValues else {
            throw RuntimeGenerationControlError.recordConflict(kind: table, id: id)
        }
        return true
    }

    static func sqliteValue(_ binding: SQLiteBinding) -> SQLiteValue {
        switch binding {
        case .null: .null
        case let .integer(value): .integer(value)
        case let .real(value): .real(value)
        case let .text(value): .text(value)
        case let .blob(value): .blob(value)
        }
    }

    func load<Value: Codable & Sendable>(
        _ type: Value.Type,
        table: String,
        idColumn: String,
        id: String
    ) async throws -> Value {
        try revalidateAuthority()
        return try await database.transaction(.deferred) { database in
            try Self.loadPayload(
                type,
                table: table,
                idColumn: idColumn,
                id: id,
                database: database
            )
        }
    }

    static func loadPayload<Value: Codable>(
        _ type: Value.Type,
        table: String,
        idColumn: String,
        id: String,
        database: isolated SQLiteDatabase
    ) throws -> Value {
        try requireSchemaIdentifier(table)
        try requireSchemaIdentifier(idColumn)
        let rows = try database.query(
            "SELECT * FROM \(table) WHERE \(idColumn) = ? LIMIT 2",
            bindings: [.text(id)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count == 1 else {
            if rows.isEmpty {
                throw RuntimeGenerationControlError.recordMissing(kind: table, id: id)
            }
            throw RuntimeGenerationControlError.recordCorrupt(kind: table, id: id)
        }
        return try decodePayload(type, row: rows[0])
    }

    /// Unlike `loadPayload`, this preserves the distinction between a missing
    /// immutable journal row and a malformed/non-unique row. It is used only
    /// for exact retry recognition after an ambiguous commit response.
    static func loadOptionalPayload<Value: Codable>(
        _ type: Value.Type,
        table: String,
        idColumn: String,
        id: String,
        database: isolated SQLiteDatabase
    ) throws -> Value? {
        let rows = try database.query(
            "SELECT * FROM \(table) WHERE \(idColumn) = ? LIMIT 2",
            bindings: [.text(id)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count <= 1 else {
            throw RuntimeGenerationControlError.recordCorrupt(kind: table, id: id)
        }
        return try rows.first.map { try decodePayload(type, row: $0) }
    }

    /// A backup is locally eligible only after the exact preparation has both
    /// a durable-byte completion and a publication consumption. The portable
    /// backup payload intentionally contains no installation-local preparation
    /// identity, so that provenance is enforced by this joined control lineage.
    static func loadEligibleBackup(
        id: String,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeGenerationBackupRecord {
        let rows = try database.query(
            """
            SELECT backup.*
            FROM runtime_generation_backups AS backup
            INNER JOIN runtime_generation_backup_preparation_completions AS completion
              ON completion.preparation_id = backup.preparation_id
             AND completion.backup_id = backup.backup_id
             AND completion.backup_digest = backup.backup_digest
            INNER JOIN runtime_generation_backup_preparation_consumptions AS consumption
              ON consumption.preparation_id = backup.preparation_id
             AND consumption.backup_id = backup.backup_id
            WHERE backup.backup_id = ?
            LIMIT 2
            """,
            bindings: [.text(id)],
            maximumDecodedBytes: maximumControlReadBytes
        )
        guard rows.count == 1 else {
            if rows.isEmpty {
                throw RuntimeGenerationControlError.recordMissing(
                    kind: "eligible_backup", id: id
                )
            }
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "eligible_backup", id: id
            )
        }
        let row = rows[0]
        guard case let .text(preparationID)? = row.value(named: "preparation_id")
        else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "eligible_backup", id: id
            )
        }
        try RuntimeGenerationControlValidation.requireIdentifier(
            preparationID, field: "backup_preparation_id"
        )
        let preparation = try loadPayload(
            RuntimeGenerationBackupPreparationRecord.self,
            table: "runtime_generation_backup_preparations",
            idColumn: "preparation_id",
            id: preparationID,
            database: database
        )
        let backup = try decodePayload(RuntimeGenerationBackupRecord.self, row: row)
        let completion = try loadPayload(
            RuntimeGenerationBackupPreparationCompletion.self,
            table: "runtime_generation_backup_preparation_completions",
            idColumn: "preparation_id",
            id: preparationID,
            database: database
        )
        let consumption = try loadPayload(
            RuntimeGenerationBackupPreparationConsumption.self,
            table: "runtime_generation_backup_preparation_consumptions",
            idColumn: "preparation_id",
            id: preparationID,
            database: database
        )
        let consumptionLease = try loadPayload(
            RuntimeGenerationOperationLease.self,
            table: "runtime_generation_operation_leases",
            idColumn: "lease_id",
            id: consumption.operationLeaseID,
            database: database
        )
        guard preparation.backupID == backup.backupID,
              preparation.sourceGenerationID == backup.sourceGenerationID,
              preparation.sourceGenerationDigest == backup.sourceGenerationDigest,
              completion.backup == backup,
              consumption.preparationID == preparationID,
              consumption.backupID == backup.backupID,
              consumptionLease.reservationID == preparation.reservationID,
              consumptionLease.fencingToken == consumption.operationFencingToken,
              consumption.operationFencingToken >= preparation.operationFencingToken,
              consumption.finalDirectoryDevice == completion.directoryDevice,
              consumption.finalDirectoryInode == completion.directoryInode,
              consumption.consumedAtMilliseconds >= completion.completedAtMilliseconds
        else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "eligible_backup", id: id
            )
        }
        return backup
    }

    static func decodePayload<Value: Codable>(
        _ type: Value.Type,
        row: SQLiteRow
    ) throws -> Value {
        guard case let .blob(payload)? = row.value(named: "payload"),
              case let .text(digest)? = row.value(named: "payload_digest"),
              payload.count <= maximumControlReadBytes,
              LocalRuntimeStorageChecksum.sha256Hex(for: payload) == digest
        else {
            throw RuntimeGenerationControlError.malformed(field: "control_payload")
        }
        let value = try RuntimeGenerationControlCodec.decode(type, from: payload)
        try validateDecoded(value)
        try requireRowParity(value, row: row)
        return value
    }

    static func requireSchemaIdentifier(_ value: String) throws {
        guard value.isEmpty == false,
              value.utf8.allSatisfy({ byte in
                  (48...57).contains(byte) || (65...90).contains(byte)
                      || (97...122).contains(byte) || byte == 95
              })
        else {
            throw RuntimeGenerationControlError.malformed(field: "schema_identifier")
        }
    }

    static func validateDecoded<Value>(_ value: Value) throws {
        switch value {
        case let record as RuntimeGenerationCandidateRecord:
            try record.validate()
        case let record as RuntimeGenerationProjectionRebuildCandidateReservation:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationAuthorityManifest:
            try record.validate()
        case let record as RuntimeGenerationReservation:
            try record.validate()
        case let record as RuntimeGenerationOperationLease:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationBackupPreparationRecord:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationBackupPreparationCompletion:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationBackupPreparationConsumption:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationBackupPreparationRecovery:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationCandidatePreparationRecord:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationCandidatePreparationCompletion:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationCandidatePreparationDisposition:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationCandidateReplayAuditRecord:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationBackupRecord:
            try record.validate()
        case let record as RuntimeGenerationMigrationRun:
            try record.validate()
        case let record as RuntimeGenerationProjectionRebuildLifecycleTransition:
            try record.validate()
        case let record as RuntimeGenerationVerificationReport:
            try record.validate()
        case let record as RuntimeGenerationActivationIntent:
            try record.validate()
        case let record as RuntimeGenerationActivationConsumption:
            try record.validate()
        case let record as RuntimeGenerationRestoreBaselinePlan:
            try record.validate()
        case let record as RuntimeGenerationRollbackRecord:
            try record.validate()
        case let record as RuntimeGenerationQuarantineRecord:
            try record.validate()
        case let record as RuntimeGenerationRebuildRecord:
            try record.validate()
        case let record as RuntimeLegacyImportSource:
            try record.validate()
        case let record as RuntimeLegacyImportCheckpoint:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeLegacyImportOrphanQuarantinePlan:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeLegacyImportOrphanQuarantine:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeLegacyImportItem:
            try record.validate()
        case let record as RuntimeLegacyImportDispositionIntent:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeLegacyImportManifest:
            try record.validate()
        case let record as RuntimeLegacyImportReviewPage:
            try record.validate()
        case let record as RuntimeLegacyImportReview:
            try record.validate()
        case let record as RuntimeLegacyImportReviewAuthorization:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationRecoveryAuthorization:
            try record.validate()
        case let record as RuntimeGenerationRecoveryPrecommitWitness:
            try RuntimeGenerationControlRecordFactory.validate(record)
        case let record as RuntimeGenerationRecoveryAuthorizationConsumption:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationPlan:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationConsumption:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationExecutionClaim:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationExecutionReceipt:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationPlanDisposition:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationPlanSuccession:
            try record.validate()
        case let record as RuntimeGenerationRecoveryOperationVerificationBinding:
            try record.validate()
        case let record as RuntimeGenerationRetentionTransition:
            try record.validate()
        default:
            throw RuntimeGenerationControlError.malformed(
                field: "unsupported_control_record"
            )
        }
    }

    static func requireRowParity<Value>(_ value: Value, row: SQLiteRow) throws {
        func require(_ name: String, _ expected: SQLiteValue) throws {
            guard row.value(named: name) == expected else {
                throw RuntimeGenerationControlError.malformed(
                    field: "control_row_\(name)"
                )
            }
        }
        func optionalText(_ value: String?) -> SQLiteValue {
            value.map(SQLiteValue.text) ?? .null
        }
        switch value {
        case let record as RuntimeGenerationCandidateRecord:
            let manifest = record.authorityManifest
            try require("generation_id", .text(manifest.generationID.rawValue))
            try require("schema_version", .integer(Int64(manifest.schemaVersion)))
            try require("manifest_digest", .text(manifest.manifestDigest))
            try require("authority_manifest_file_sha256", .text(record.authorityManifestFileSHA256))
            try require("selector_file_sha256", .text(record.selectorFileSHA256))
            try require("record_digest", .text(record.recordDigest))
            try require("reservation_id", .text(manifest.reservationID))
            try require("migration_run_id", .text(manifest.migrationRunID))
            try require("source_generation_id", optionalText(manifest.sourceGenerationID?.rawValue))
            try require("retention_class", .text(manifest.retentionClass.rawValue))
            try require("created_at_ms", .integer(manifest.createdAtMilliseconds))
        case let record as RuntimeGenerationProjectionRebuildCandidateReservation:
            try require("candidate_reservation_id", .text(record.candidateReservationID))
            try require("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID))
            try require("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID))
            try require("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("reservation_id", .text(record.reservationID))
            try require("candidate_preparation_id", .text(record.candidatePreparationID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("expected_verification_id", .text(record.expectedVerificationID))
            try require("expected_activation_intent_id", .text(record.expectedActivationIntentID))
            try require("reserved_at_ms", .integer(record.reservedAtMilliseconds))
            try require("reservation_digest", .text(record.reservationDigest))
        case let record as RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment:
            try require("commitment_id", .text(record.commitmentID))
            try require("candidate_reservation_id", .text(record.candidateReservationID))
            try require("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID))
            try require("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID))
            try require("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("reservation_id", .text(record.reservationID))
            try require("candidate_preparation_id", .text(record.candidatePreparationID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("expected_verification_id", .text(record.expectedVerificationID))
            try require("expected_activation_intent_id", .text(record.expectedActivationIntentID))
            try require("candidate_record_digest", .text(record.candidateRecord.recordDigest))
            try require("candidate_preparation_completion_digest", .text(record.candidatePreparationCompletion.completionDigest))
            try require("authority_manifest_digest", .text(record.candidateRecord.authorityManifest.manifestDigest))
            try require("authority_manifest_file_sha256", .text(record.candidateRecord.authorityManifestFileSHA256))
            try require("authority_manifest_bytes_sha256", .text(record.authorityManifestBytesSHA256))
            try require("authority_manifest_byte_count", .integer(Int64(record.authorityManifestBytes.count)))
            try require("selector_file_sha256", .text(record.candidateRecord.selectorFileSHA256))
            try require("selector_bytes_sha256", .text(record.selectorBytesSHA256))
            try require("selector_byte_count", .integer(Int64(record.selectorBytes.count)))
            try require("replay_audit_id", .text(record.replayAuditID))
            try require("replay_audit_digest", .text(record.replayAuditDigest))
            try require("replay_reconstruction_digest", .text(record.replayReconstructionDigest))
            try require("rebuild_id", .text(record.rebuild.rebuildID))
            try require("rebuild_digest", .text(record.rebuild.rebuildDigest))
            try require("equivalence_digest", .text(record.rebuild.equivalenceDigest))
            try require("committed_at_ms", .integer(record.committedAtMilliseconds))
            try require("commitment_digest", .text(record.commitmentDigest))
        case let record as RuntimeGenerationAuthorityManifest:
            try require("generation_id", .text(record.generationID.rawValue))
            try require("schema_version", .integer(Int64(record.schemaVersion)))
            try require("manifest_digest", .text(record.manifestDigest))
            try require("reservation_id", .text(record.reservationID))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("source_generation_id", optionalText(record.sourceGenerationID?.rawValue))
            try require("retention_class", .text(record.retentionClass.rawValue))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
        case let record as RuntimeGenerationReservation:
            try require("reservation_id", .text(record.reservationID))
            try require("operation_kind", .text(record.operationKind.rawValue))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("source_generation_id", optionalText(record.sourceGenerationID?.rawValue))
            try require("source_generation_digest", optionalText(record.sourceGenerationDigest))
            try require("expected_active_manifest_digest", optionalText(record.expectedActiveManifestDigest))
            try require("target_schema_version", .integer(Int64(record.targetSchemaVersion)))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
            try require("reservation_digest", .text(record.reservationDigest))
        case let record as RuntimeGenerationOperationLease:
            try require("lease_id", .text(record.leaseID))
            try require("reservation_id", .text(record.reservationID))
            try require("owner_instance_id", .text(record.ownerInstanceID))
            try require("lease_epoch", .integer(record.leaseEpoch))
            try require("fencing_token", .integer(record.fencingToken))
            try require("prior_lease_digest", optionalText(record.priorLeaseDigest))
            try require("issued_at_ms", .integer(record.issuedAtMilliseconds))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("lease_digest", .text(record.leaseDigest))
        case let record as RuntimeGenerationBackupPreparationRecord:
            try require("preparation_id", .text(record.preparationID))
            try require("backup_id", .text(record.backupID))
            try require("reservation_id", .text(record.reservationID))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("source_generation_id", .text(record.sourceGenerationID.rawValue))
            try require("source_generation_digest", .text(record.sourceGenerationDigest))
            try require("expected_active_manifest_digest", .text(record.expectedActiveManifestDigest))
            try require("hidden_directory_name", .text(record.hiddenDirectoryName))
            try require("final_directory_name", .text(record.finalDirectoryName))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
            try require("preparation_digest", .text(record.preparationDigest))
        case let record as RuntimeGenerationBackupPreparationCompletion:
            try require("preparation_id", .text(record.preparationID))
            try require("backup_id", .text(record.backup.backupID))
            try require("backup_digest", .text(record.backup.backupDigest))
            try require("directory_device", .integer(Int64(bitPattern: record.directoryDevice)))
            try require("directory_inode", .integer(Int64(bitPattern: record.directoryInode)))
            try require("interior_artifact_count", .integer(record.interiorArtifactCount))
            try require("interior_byte_count", .integer(record.interiorByteCount))
            try require("interior_inventory_digest", .text(record.interiorInventoryDigest))
            try require("durability_witness_digest", .text(record.durabilityWitnessDigest))
            try require("completed_at_ms", .integer(record.completedAtMilliseconds))
            try require("completion_digest", .text(record.completionDigest))
        case let record as RuntimeGenerationBackupPreparationConsumption:
            try require("preparation_id", .text(record.preparationID))
            try require("backup_id", .text(record.backupID))
            try require("final_directory_device", .integer(Int64(bitPattern: record.finalDirectoryDevice)))
            try require("final_directory_inode", .integer(Int64(bitPattern: record.finalDirectoryInode)))
            try require("consumed_at_ms", .integer(record.consumedAtMilliseconds))
            try require("consumption_digest", .text(record.consumptionDigest))
        case let record as RuntimeGenerationBackupPreparationRecovery:
            try require("preparation_id", .text(record.preparationID))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("classification", .text(record.classification.rawValue))
            try require("recovered_at_ms", .integer(record.recoveredAtMilliseconds))
            try require("recovery_digest", .text(record.recoveryDigest))
        case let record as RuntimeGenerationCandidatePreparationRecord:
            try require("preparation_id", .text(record.preparationID))
            try require("reservation_id", .text(record.reservationID))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("operation_kind", .text(record.operationKind.rawValue))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("source_generation_id", optionalText(record.sourceGenerationID?.rawValue))
            try require("source_generation_digest", optionalText(record.sourceGenerationDigest))
            try require("expected_active_manifest_digest", optionalText(record.expectedActiveManifestDigest))
            try require("staging_directory_name", .text(record.stagingDirectoryName))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
            try require("preparation_digest", .text(record.preparationDigest))
        case let record as RuntimeGenerationCandidatePreparationCompletion:
            try require("preparation_id", .text(record.preparationID))
            try require("candidate_record_digest", .text(record.candidateRecordDigest))
            try require("directory_device", .integer(Int64(bitPattern: record.directoryDevice)))
            try require("directory_inode", .integer(Int64(bitPattern: record.directoryInode)))
            try require("interior_artifact_count", .integer(record.interiorArtifactCount))
            try require("interior_byte_count", .integer(record.interiorByteCount))
            try require("interior_inventory_digest", .text(record.interiorInventoryDigest))
            try require("durability_witness_digest", .text(record.durabilityWitnessDigest))
            try require("completed_at_ms", .integer(record.completedAtMilliseconds))
            try require("completion_digest", .text(record.completionDigest))
        case let record as RuntimeGenerationCandidatePreparationDisposition:
            try require("preparation_id", .text(record.preparationID))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("kind", .text(record.kind.rawValue))
            try require("failure_classification", optionalText(record.failureClassification?.rawValue))
            try require("authority_digest", .text(record.authorityDigest))
            try require("disposed_at_ms", .integer(record.disposedAtMilliseconds))
            try require("disposition_digest", .text(record.dispositionDigest))
        case let record as RuntimeGenerationCandidateReplayAuditRecord:
            try require("audit_id", .text(record.auditID))
            try require("preparation_id", .text(record.preparationID))
            try require("reservation_id", .text(record.reservationID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_lease_epoch", .integer(record.operationLeaseEpoch))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("outcome", .text(record.outcome.rawValue))
            try require("blocked_invariant", optionalText(record.blockedInvariant?.rawValue))
            try require("replay_checkpoint_digest", optionalText(record.replayCheckpointDigest))
            try require("replay_certificate_digest", optionalText(record.replayCertificateDigest))
            try require("reconstruction_digest", optionalText(record.reconstructionDigest))
            try require("audited_at_ms", .integer(record.auditedAtMilliseconds))
            try require("audit_digest", .text(record.auditDigest))
        case let record as RuntimeGenerationBackupRecord:
            try require("backup_id", .text(record.backupID))
            try require("source_generation_id", .text(record.sourceGenerationID.rawValue))
            try require("source_generation_digest", .text(record.sourceGenerationDigest))
            try require("source_fence_digest", .text(record.sourceFence.fenceDigest))
            try require("authority_fence_token_digest", .text(record.authorityFenceToken.tokenDigest))
            try require("backup_digest", .text(record.backupDigest))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
        case let record as RuntimeGenerationMigrationRun:
            try require("migration_run_id", .text(record.migrationRunID))
            try require("reservation_id", .text(record.reservationID))
            try require("executor_instance_id", .text(record.executorInstanceID))
            try require("operation_lease_id", .text(record.operationLeaseID))
            try require("operation_lease_epoch", .integer(record.operationLeaseEpoch))
            try require("operation_fencing_token", .integer(record.operationFencingToken))
            try require("source_safety_backup_id", optionalText(record.sourceSafetyBackupID))
            try require("backup_id", optionalText(record.backupID))
            try require("recovery_authorization_id", optionalText(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", optionalText(record.recoveryAuthorizationDigest))
            try require("recovery_execution_plan_id", optionalText(record.recoveryExecutionPlanID))
            try require("recovery_execution_claim_id", optionalText(record.recoveryExecutionClaimID))
            try require("recovery_execution_claim_epoch", record.recoveryExecutionClaimEpoch.map { .integer($0) } ?? .null)
            try require("operation_kind", .text(record.operationKind.rawValue))
            try require("source_schema_version", record.sourceSchemaVersion.map { .integer(Int64($0)) } ?? .null)
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("provenance_digest", .text(record.provenanceDigest))
            try require("target_schema_version", .integer(Int64(record.targetSchemaVersion)))
            try require("transformation_version", .integer(Int64(record.transformationVersion)))
            try require("started_at_ms", .integer(record.startedAtMilliseconds))
            try require("completed_at_ms", .integer(record.completedAtMilliseconds))
            try require("run_digest", .text(record.runDigest))
        case let record as RuntimeGenerationProjectionRebuildLifecycleTransition:
            try require("transition_id", .text(record.transitionID))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID))
            try require("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID))
            try require("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch))
            try require("phase", .text(record.phase.rawValue))
            try require("prior_transition_digest", optionalText(record.priorTransitionDigest))
            try require("reason_digest", .text(record.reasonDigest))
            try require("occurred_at_ms", .integer(record.occurredAtMilliseconds))
            try require("transition_digest", .text(record.transitionDigest))
        case let record as RuntimeGenerationVerificationReport:
            try require("verification_id", .text(record.verificationID))
            try require("reservation_id", .text(record.reservationID))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("candidate_authority_manifest_digest", .text(record.candidateAuthorityManifestDigest))
            try require("candidate_authority_manifest_file_sha256", .text(record.candidateAuthorityManifestFileSHA256))
            try require("candidate_selector_file_sha256", .text(record.candidateSelectorFileSHA256))
            try require("source_fence_digest", optionalText(record.sourceFenceDigest))
            try require("expected_active_manifest_digest", optionalText(record.expectedActiveManifestDigest))
            try require("accepted", .integer(record.accepted ? 1 : 0))
            try require("verified_at_ms", .integer(record.verifiedAtMilliseconds))
            try require("report_digest", .text(record.reportDigest))
        case let record as RuntimeGenerationActivationIntent:
            try require("intent_id", .text(record.intentID))
            try require("reservation_id", .text(record.reservationID))
            try require("verification_id", .text(record.verificationID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("candidate_authority_manifest_digest", .text(record.candidateAuthorityManifestDigest))
            try require("candidate_authority_manifest_file_sha256", .text(record.candidateAuthorityManifestFileSHA256))
            try require("candidate_selector_file_sha256", .text(record.candidateSelectorFileSHA256))
            try require("expected_active_manifest_digest", optionalText(record.expectedActiveManifestDigest))
            try require("created_at_ms", .integer(record.createdAtMilliseconds))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("intent_digest", .text(record.intentDigest))
        case let record as RuntimeGenerationActivationConsumption:
            try require("intent_id", .text(record.intentID))
            try require("installed_selector_file_sha256", .text(record.installedSelectorFileSHA256))
            try require("prior_generation_id", optionalText(record.priorGenerationID?.rawValue))
            try require("prior_generation_digest", optionalText(record.priorGenerationDigest))
            try require("consumed_at_ms", .integer(record.consumedAtMilliseconds))
            try require("consumption_digest", .text(record.consumptionDigest))
        case let record as RuntimeGenerationRestoreBaselinePlan:
            try require("plan_id", .text(record.planID))
            try require("source_generation_id", .text(record.sourceGenerationID.rawValue))
            try require("source_generation_digest", .text(record.sourceGenerationDigest))
            try require("source_safety_backup_id", .text(record.sourceSafetyBackupID))
            try require("source_safety_fence_digest", .text(record.sourceSafetyFenceDigest))
            try require("target_generation_id", .text(record.targetGenerationID.rawValue))
            try require("target_verification_id", .text(record.targetVerificationID))
            try require("target_activation_baseline_digest", .text(record.targetActivationBaselineDigest))
            try require("recovery_authorization_id", .text(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest))
            try require("prepared_at_ms", .integer(record.preparedAtMilliseconds))
            try require("plan_digest", .text(record.planDigest))
        case let record as RuntimeGenerationRollbackRecord:
            try require("rollback_id", .text(record.rollbackID))
            try require("restore_baseline_plan_id", .text(record.restoreBaselinePlanID))
            try require("source_generation_id", .text(record.sourceGenerationID.rawValue))
            try require("source_safety_fence_digest", .text(record.sourceSafetyFenceDigest))
            try require("target_generation_id", .text(record.targetGenerationID.rawValue))
            try require("target_verification_id", .text(record.targetVerificationID))
            try require("target_observed_fence_digest", .text(record.targetObservedFence.fenceDigest))
            try require("post_activation_event_count", .integer(record.postActivationEventCount))
            try require("post_activation_command_count", .integer(record.postActivationCommandCount))
            try require("post_activation_receipt_count", .integer(record.postActivationReceiptCount))
            try require("post_activation_external_effect_count", .integer(record.postActivationExternalEffectCount))
            try require(
                "post_activation_attachment_lifecycle_count",
                .integer(record.postActivationAttachmentLifecycleCount)
            )
            try require("activated_at_ms", .integer(record.activatedAtMilliseconds))
            try require("rollback_digest", .text(record.rollbackDigest))
        case let record as RuntimeGenerationQuarantineRecord:
            try require("quarantine_id", .text(record.quarantineID))
            try require("reason", .text(record.reason.rawValue))
            try require("original_generation_id", optionalText(record.originalGenerationID?.rawValue))
            try require("original_manifest_digest", optionalText(record.originalManifestDigest))
            try require("diagnostic_fingerprint", .text(record.diagnosticFingerprint))
            try require("quarantined_at_ms", .integer(record.quarantinedAtMilliseconds))
            try require("quarantine_digest", .text(record.quarantineDigest))
        case let record as RuntimeGenerationRebuildRecord:
            try require("rebuild_id", .text(record.rebuildID))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("recovery_execution_plan_id", .text(record.recoveryExecutionPlanID))
            try require("recovery_execution_claim_id", .text(record.recoveryExecutionClaimID))
            try require("recovery_execution_claim_epoch", .integer(record.recoveryExecutionClaimEpoch))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("ready_transition_digest", .text(record.readyTransitionDigest))
            try require("source_generation_id", .text(record.sourceGenerationID.rawValue))
            try require("source_fence_digest", .text(record.sourceFenceDigest))
            try require("equivalence_digest", .text(record.equivalenceDigest))
            try require("published_at_ms", .integer(record.publishedAtMilliseconds))
            try require("rebuild_digest", .text(record.rebuildDigest))
        case let record as RuntimeLegacyImportSource:
            try require("import_id", .text(record.importID))
            try require("source_kind", .text(record.sourceKind.rawValue))
            try require("source_identity_digest", .text(record.sourceIdentityDigest))
            try require("source_schema", .text(record.sourceSchema))
            try require("discovered_at_ms", .integer(record.discoveredAtMilliseconds))
            try require("source_digest", .text(record.sourceDigest))
        case let record as RuntimeLegacyImportCheckpoint:
            try require("checkpoint_id", .text(record.checkpointID))
            try require("import_id", .text(record.importID))
            try require("sequence", .integer(Int64(record.sequence)))
            try require("phase", .text(record.phase.rawValue))
            try require("prior_checkpoint_digest", optionalText(record.priorCheckpointDigest))
            try require("artifact_set_digest", .text(record.artifactSetDigest))
            try require("processed_item_count", .integer(Int64(record.processedItemCount)))
            try require("checkpoint_digest", .text(record.checkpointDigest))
        case let record as RuntimeLegacyImportOrphanQuarantinePlan:
            try require("quarantine_id", .text(record.quarantineID))
            try require("original_entry_name", .text(record.originalEntryName))
            try require("destination_entry_name", .text(record.destinationEntryName))
            try require("planned_at_ms", .integer(record.plannedAtMilliseconds))
            try require("plan_digest", .text(record.planDigest))
        case let record as RuntimeLegacyImportOrphanQuarantine:
            try require("quarantine_id", .text(record.quarantineID))
            try require("original_entry_name", .text(record.originalEntryName))
            try require("preserved_relative_path", .text(record.preservedRelativePath))
            try require("inventory_digest", .text(record.inventoryDigest))
            try require("file_count", .integer(Int64(record.fileCount)))
            try require("total_byte_count", .integer(record.totalByteCount))
            try require("quarantine_digest", .text(record.quarantineDigest))
        case let record as RuntimeLegacyImportItem:
            try require(
                "item_key",
                .text(LocalRuntimeStorageChecksum.sha256Hex(
                    for: "\(record.importID)\n\(record.sourceRecordID)"
                ))
            )
            try require("import_id", .text(record.importID))
            try require("source_record_id", .text(record.sourceRecordID))
            try require("source_record_digest", .text(record.sourceRecordDigest))
            try require("canonical_family", optionalText(record.canonicalFamily))
            try require("canonical_id", optionalText(record.canonicalID))
            try require("canonical_payload_digest", optionalText(record.canonicalPayloadDigest))
            try require("mapped_artifact_binding_digest", optionalText(record.mappedArtifact?.bindingDigest))
            try require("disposition", .text(record.disposition.rawValue))
            try require("lossiness", .text(record.lossiness.rawValue))
            try require("item_digest", .text(record.itemDigest))
        case let record as RuntimeLegacyImportDispositionIntent:
            try require("intent_id", .text(record.intentID))
            try require("import_id", .text(record.importID))
            try require("intent_digest", .text(record.intentDigest))
            try require("disposition", .text(record.disposition.rawValue))
            try require("planned_at_ms", .integer(record.plannedAtMilliseconds))
        case let record as RuntimeLegacyImportManifest:
            try require("import_id", .text(record.importID))
            try require("item_count", .integer(Int64(record.itemCount)))
            try require("ordered_item_set_digest", .text(record.orderedItemSetDigest))
            try require("completed_at_ms", .integer(record.completedAtMilliseconds))
            try require("manifest_digest", .text(record.manifestDigest))
        case let record as RuntimeLegacyImportReviewPage:
            try require("page_id", .text(record.pageID))
            try require("review_id", .text(record.reviewID))
            try require("import_id", .text(record.importID))
            try require("page_index", .integer(Int64(record.pageIndex)))
            try require("after_source_record_id", optionalText(record.afterSourceRecordID))
            try require("last_source_record_id", .text(record.lastSourceRecordID))
            try require("page_digest", .text(record.pageDigest))
        case let record as RuntimeLegacyImportReview:
            try require("review_id", .text(record.reviewID))
            try require("import_id", .text(record.importID))
            try require("source_digest", .text(record.sourceDigest))
            try require("item_count", .integer(Int64(record.itemCount)))
            try require("page_count", .integer(Int64(record.pageCount)))
            try require("ordered_item_set_digest", .text(record.orderedItemSetDigest))
            try require("ordered_decision_set_digest", .text(record.orderedDecisionSetDigest))
            try require("review_authorization_digest", .text(record.reviewerConfirmationDigest))
            try require("reviewed_at_ms", .integer(record.reviewedAtMilliseconds))
            try require("review_digest", .text(record.reviewDigest))
        case let record as RuntimeLegacyImportReviewAuthorization:
            try require("authorization_id", .text(record.authorizationID))
            try require("import_id", .text(record.importID))
            try require("manifest_digest", .text(record.manifestDigest))
            try require("disposition_intent_digest", .text(record.dispositionIntentDigest))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("authorization_digest", .text(record.authorizationDigest))
        case let record as RuntimeGenerationRecoveryAuthorization:
            try require("authorization_id", .text(record.authorizationID))
            try require("action", .text(record.action.rawValue))
            try require("target_digest", .text(record.targetDigest))
            try require("authorized_at_ms", .integer(record.authorizedAtMilliseconds))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("authorization_digest", .text(record.authorizationDigest))
        case let record as RuntimeGenerationRecoveryPrecommitWitness:
            try require("witness_id", .text(record.witnessID))
            try require("activation_intent_id", .text(record.activationIntentID))
            try require("migration_run_id", .text(record.migrationRunID))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("candidate_selector_file_sha256", .text(record.candidateSelectorFileSHA256))
            try require("recovery_authorization_id", .text(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest))
            try require("recovery_target_digest", .text(record.recoveryTargetDigest))
            try require("result_digest", .text(record.resultDigest))
            try require("observed_at_ms", .integer(record.observedAtMilliseconds))
            try require("minimum_remaining_validity_ms", .integer(record.minimumRemainingValidityMilliseconds))
            try require("witness_digest", .text(record.witnessDigest))
        case let record as RuntimeGenerationRecoveryAuthorizationConsumption:
            try require("authorization_id", .text(record.authorizationID))
            try require("action", .text(record.action.rawValue))
            try require("target_digest", .text(record.targetDigest))
            try require("result_digest", .text(record.resultDigest))
            try require("consumed_at_ms", .integer(record.consumedAtMilliseconds))
            try require("consumption_digest", .text(record.consumptionDigest))
        case let record as RuntimeGenerationRecoveryOperationPlan:
            try require("plan_id", .text(record.planID))
            try require("quarantine_id", .text(record.quarantineID))
            try require("action", .text(record.action.rawValue))
            try require("target_digest", .text(record.targetDigest))
            try require("recovery_authorization_id", .text(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest))
            try require("prepared_at_ms", .integer(record.preparedAtMilliseconds))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("plan_digest", .text(record.planDigest))
        case let record as RuntimeGenerationRecoveryOperationConsumption:
            try require("plan_id", .text(record.planID))
            try require("recovery_authorization_id", .text(record.recoveryAuthorizationID))
            try require("action", .text(record.action.rawValue))
            try require("target_digest", .text(record.targetDigest))
            try require("result_digest", .text(record.resultDigest))
            try require("consumed_at_ms", .integer(record.consumedAtMilliseconds))
            try require("consumption_digest", .text(record.consumptionDigest))
        case let record as RuntimeGenerationRecoveryOperationExecutionClaim:
            try require("claim_id", .text(record.claimID))
            try require("plan_id", .text(record.planID))
            try require("executor_instance_id", .text(record.executorInstanceID))
            try require("claim_epoch", .integer(record.claimEpoch))
            try require("claimed_at_ms", .integer(record.claimedAtMilliseconds))
            try require("expires_at_ms", .integer(record.expiresAtMilliseconds))
            try require("claim_digest", .text(record.claimDigest))
        case let record as RuntimeGenerationRecoveryOperationExecutionReceipt:
            try require("receipt_id", .text(record.receiptID))
            try require("plan_id", .text(record.planID))
            try require("claim_id", .text(record.claimID))
            try require("claim_epoch", .integer(record.claimEpoch))
            try require("quarantine_id", .text(record.quarantineID))
            try require("candidate_generation_id", optionalText(record.candidateGenerationID?.rawValue))
            try require("recovery_authorization_id", .text(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", .text(record.recoveryAuthorizationDigest))
            try require("action", .text(record.action.rawValue))
            try require("target_digest", .text(record.targetDigest))
            try require("verification_id", optionalText(record.verificationID))
            try require("verification_report_digest", optionalText(record.verificationReportDigest))
            try require("verification_accepted", record.verificationAccepted.map { .integer($0 ? 1 : 0) } ?? .null)
            try require("authority_classification", .text(record.authorityClassification.rawValue))
            try require("rebuild_id", optionalText(record.rebuildID))
            try require("rebuild_digest", optionalText(record.rebuildDigest))
            try require("outcome_evidence_digest", .text(record.outcomeEvidenceDigest))
            try require("executed_at_ms", .integer(record.executedAtMilliseconds))
            try require("receipt_digest", .text(record.receiptDigest))
        case let record as RuntimeGenerationRecoveryOperationPlanDisposition:
            try require("plan_id", .text(record.planID))
            try require("kind", .text(record.kind.rawValue))
            try require("recovery_authorization_id", optionalText(record.recoveryAuthorizationID))
            try require("recovery_authorization_digest", optionalText(record.recoveryAuthorizationDigest))
            try require("disposed_at_ms", .integer(record.disposedAtMilliseconds))
            try require("disposition_digest", .text(record.dispositionDigest))
        case let record as RuntimeGenerationRecoveryOperationPlanSuccession:
            try require("successor_plan_id", .text(record.successorPlanID))
            try require("predecessor_plan_id", .text(record.predecessorPlanID))
            try require("quarantine_id", .text(record.quarantineID))
            try require("action", .text(record.action.rawValue))
            try require("predecessor_disposition_digest", .text(record.predecessorDispositionDigest))
            try require("recorded_at_ms", .integer(record.recordedAtMilliseconds))
            try require("succession_digest", .text(record.successionDigest))
        case let record as RuntimeGenerationRecoveryOperationVerificationBinding:
            try require("verification_id", .text(record.verificationID))
            try require("verification_report_digest", .text(record.verificationReportDigest))
            try require("plan_id", .text(record.planID))
            try require("claim_id", .text(record.claimID))
            try require("claim_epoch", .integer(record.claimEpoch))
            try require("candidate_generation_id", .text(record.candidateGenerationID.rawValue))
            try require("observed_at_ms", .integer(record.observedAtMilliseconds))
            try require("binding_digest", .text(record.bindingDigest))
        case let record as RuntimeGenerationRetentionTransition:
            try require("transition_id", .text(record.transitionID))
            try require("generation_id", .text(record.generationID.rawValue))
            try require("from_class", optionalText(record.fromClass?.rawValue))
            try require("to_class", .text(record.toClass.rawValue))
            try require("authority_digest", .text(record.authorityDigest))
            try require("occurred_at_ms", .integer(record.occurredAtMilliseconds))
            try require("transition_digest", .text(record.transitionDigest))
        default:
            throw RuntimeGenerationControlError.malformed(
                field: "unsupported_control_record"
            )
        }
    }

    func validateReservation(_ record: RuntimeGenerationReservation) throws {
            try record.validate()
        try RuntimeGenerationControlValidation.requireIdentifier(record.reservationID, field: "reservation_id")
        try RuntimeGenerationControlValidation.requireDigest(record.reservationDigest, field: "reservation_digest")
        guard record.targetSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              record.createdAtMilliseconds >= 0,
              (record.sourceGenerationID == nil) == (record.sourceGenerationDigest == nil)
        else { throw RuntimeGenerationControlError.malformed(field: "reservation") }
    }

    func validateBackup(_ record: RuntimeGenerationBackupRecord) throws {
        try record.validate()
    }

    func validateMigrationRun(_ record: RuntimeGenerationMigrationRun) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        for (value, field) in [
            (record.migrationRunID, "migration_run_id"),
            (record.reservationID, "reservation_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        try RuntimeGenerationControlValidation.requireDigest(record.provenanceDigest, field: "provenance_digest")
        try RuntimeGenerationControlValidation.requireDigest(record.runDigest, field: "run_digest")
        guard record.targetSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              record.transformationVersion > 0,
              record.startedAtMilliseconds >= 0,
              record.completedAtMilliseconds >= record.startedAtMilliseconds else {
            throw RuntimeGenerationControlError.malformed(field: "migration_run")
        }
    }

    func validateVerification(_ record: RuntimeGenerationVerificationReport) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        for evidence in record.evidence {
            try evidence.validate()
        }
        for (value, field) in [
            (record.verificationID, "verification_id"),
            (record.verifierInstanceID, "verifier_instance_id"),
            (record.reservationID, "reservation_id"),
            (record.migrationRunID, "migration_run_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.candidateAuthorityManifestDigest, "candidate_authority_manifest_digest"),
            (record.candidateAuthorityManifestFileSHA256, "candidate_authority_manifest_file_sha256"),
            (record.candidateSelectorFileSHA256, "candidate_selector_file_sha256"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        try RuntimeGenerationControlValidation.requireDigest(record.reportDigest, field: "report_digest")
        guard record.expectedSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              record.verifiedAtMilliseconds >= 0,
              record.hasCompleteEvidence else {
            throw RuntimeGenerationControlError.verificationRejected
        }
    }

    func validateActivationIntent(_ record: RuntimeGenerationActivationIntent) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        for (value, field) in [
            (record.intentID, "intent_id"),
            (record.reservationID, "reservation_id"),
            (record.verificationID, "verification_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.candidateAuthorityManifestDigest, "candidate_authority_manifest_digest"),
            (record.candidateAuthorityManifestFileSHA256, "candidate_authority_manifest_file_sha256"),
            (record.candidateSelectorFileSHA256, "candidate_selector_file_sha256"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        try RuntimeGenerationControlValidation.requireDigest(record.intentDigest, field: "intent_digest")
        guard record.createdAtMilliseconds >= 0,
              record.expiresAtMilliseconds > record.createdAtMilliseconds,
              (record.expectedSourceGenerationID == nil) == (record.expectedSourceGenerationDigest == nil),
              (record.expectedSourceGenerationID == nil) == (record.expectedSourceFenceDigest == nil)
        else { throw RuntimeGenerationControlError.malformed(field: "activation_intent") }
    }

    func validateConsumption(_ record: RuntimeGenerationActivationConsumption) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlValidation.requireIdentifier(record.intentID, field: "intent_id")
        try RuntimeGenerationControlValidation.requireDigest(record.installedSelectorFileSHA256, field: "installed_selector_file_sha256")
        try RuntimeGenerationControlValidation.requireDigest(record.consumptionDigest, field: "consumption_digest")
        guard record.consumedAtMilliseconds >= 0,
              (record.priorGenerationID == nil) == (record.priorGenerationDigest == nil)
        else { throw RuntimeGenerationControlError.malformed(field: "activation_consumption") }
    }

    func validateRollback(_ record: RuntimeGenerationRollbackRecord) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlValidation.requireIdentifier(record.rollbackID, field: "rollback_id")
        try RuntimeGenerationControlValidation.requireIdentifier(record.targetVerificationID, field: "target_verification_id")
        try RuntimeGenerationControlValidation.requireDigest(record.rollbackDigest, field: "rollback_digest")
        guard record.sourceGenerationID != record.targetGenerationID,
              record.postActivationEventCount == 0,
              record.postActivationCommandCount == 0,
              record.postActivationReceiptCount == 0,
              record.postActivationExternalEffectCount == 0,
              record.postActivationAttachmentLifecycleCount == 0,
              record.activatedAtMilliseconds >= 0
        else { throw RuntimeGenerationControlError.rollbackUnsafe }
    }

    func validateQuarantine(_ record: RuntimeGenerationQuarantineRecord) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try record.originalArtifact.validate()
        try RuntimeGenerationControlValidation.requireIdentifier(record.quarantineID, field: "quarantine_id")
        try RuntimeGenerationControlValidation.requireDigest(record.diagnosticFingerprint, field: "diagnostic_fingerprint")
        try RuntimeGenerationControlValidation.requireDigest(record.quarantineDigest, field: "quarantine_digest")
        guard record.allowedActions.isEmpty == false,
              Set(record.allowedActions).count == record.allowedActions.count,
              record.quarantinedAtMilliseconds >= 0,
              record.allowedActions != [.explicitlyAuthorizedReset]
        else { throw RuntimeGenerationControlError.malformed(field: "quarantine") }
    }

    func validateRebuild(_ record: RuntimeGenerationRebuildRecord) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        for (value, field) in [
            (record.sourceFenceDigest, "source_fence_digest"),
            (record.replayReconstructionDigest, "replay_reconstruction_digest"),
            (record.projectionGenerationDigest, "projection_generation_digest"),
            (record.searchGenerationDigest, "search_generation_digest"),
            (record.equivalenceDigest, "equivalence_digest"),
            (record.rebuildDigest, "rebuild_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard record.publishedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "rebuild")
        }
    }

    func validateImportSource(_ record: RuntimeLegacyImportSource) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try record.sourceArtifact.validate()
        try RuntimeGenerationControlValidation.requireIdentifier(record.importID, field: "import_id")
        try RuntimeGenerationControlValidation.requireDigest(record.sourceIdentityDigest, field: "source_identity_digest")
        try RuntimeGenerationControlValidation.requireDigest(record.sourceLocationFingerprint, field: "source_location_fingerprint")
        try RuntimeGenerationControlValidation.requireDigest(record.sourceDigest, field: "source_digest")
        guard ((record.sourceKind == .canonicalV1 &&
                record.sourceSchema == "canonical.sqlite.v1") ||
               (record.sourceKind == .swiftData &&
                record.sourceSchema == objectStoreSwiftDataSchemaVersion)),
              record.discoveredAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "import_source")
        }
    }

    func validateImportItem(_ record: RuntimeLegacyImportItem) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlValidation.requireIdentifier(record.importID, field: "import_id")
        try RuntimeGenerationControlValidation.requireIdentifier(record.sourceRecordID, field: "source_record_id")
        try RuntimeGenerationControlValidation.requireDigest(record.sourceRecordDigest, field: "source_record_digest")
        try RuntimeGenerationControlValidation.requireDigest(record.itemDigest, field: "item_digest")
        guard (record.canonicalFamily == nil) == (record.canonicalID == nil),
              (record.canonicalID == nil) == (record.canonicalPayloadDigest == nil),
              (record.canonicalPayloadDigest == nil) == (record.mappedArtifact == nil),
              (record.disposition == .reviewableDiscovery) ==
                (record.canonicalPayloadDigest != nil),
              record.warningCodes.count <= 64,
              Set(record.warningCodes).count == record.warningCodes.count,
              record.warningCodes == record.warningCodes.sorted()
        else { throw RuntimeGenerationControlError.malformed(field: "import_item") }
        if let mappedArtifact = record.mappedArtifact {
            try RuntimeGenerationControlRecordFactory.validate(mappedArtifact)
            guard mappedArtifact.importID == record.importID,
                  mappedArtifact.sourceRecordID == record.sourceRecordID,
                  mappedArtifact.sourceRecordDigest == record.sourceRecordDigest,
                  mappedArtifact.artifact.sha256 == record.canonicalPayloadDigest else {
                throw RuntimeGenerationControlError.malformed(field: "import_item_artifact")
            }
        }
    }

    func validateImportReview(_ record: RuntimeLegacyImportReview) throws {
        try record.validate()
    }

    func validateRecoveryAuthorization(
        _ record: RuntimeGenerationRecoveryAuthorization
    ) throws {
        try RuntimeGenerationControlRecordFactory.validate(record)
        try RuntimeGenerationControlValidation.requireIdentifier(record.authorizationID, field: "authorization_id")
        for (value, field) in [
            (record.targetDigest, "target_digest"),
            (record.alternativesReviewedDigest, "alternatives_reviewed_digest"),
            (record.consequenceDigest, "consequence_digest"),
            (record.authorizationDigest, "authorization_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard record.authorizedAtMilliseconds >= 0,
              record.expiresAtMilliseconds > record.authorizedAtMilliseconds else {
            throw RuntimeGenerationControlError.malformed(field: "recovery_authorization")
        }
    }
}
