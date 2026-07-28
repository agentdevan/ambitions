import CryptoKit
import Darwin
import Foundation

enum RuntimeGenerationForensicPreservation: String, Codable, Sendable, Equatable {
    case copied
    case partial
    case absent
    case skippedBudgetExceeded = "skipped_budget_exceeded"
}

/// Raw SQLite main/WAL/SHM files are captured one after another. They are useful
/// forensic bytes, but they are not a transactionally coherent SQLite image and
/// must never be offered to restore, replay, or equivalence verification.
enum RuntimeGenerationForensicCaptureCoherence: String, Codable, Sendable, Equatable {
    case rawSequentialNoncoherent = "raw_sequential_noncoherent"
}

enum RuntimeGenerationForensicDurability: String, Codable, Sendable, Equatable {
    case durable
    case indeterminate
    case notApplicable = "not_applicable"
}

enum RuntimeGenerationForensicPrecedingFailure: Sendable, Equatable {
    case cancellation
    case generationControl(RuntimeGenerationControlError)
    case localStorage(LocalRuntimeStorageError)
    case unclassifiedFingerprint(String)
}

struct RuntimeGenerationForensicOperationAndCleanupError: Error, Sendable, Equatable {
    let precedingFailure: RuntimeGenerationForensicPrecedingFailure
    let cleanupOperation: String
}

enum RuntimeGenerationForensicBudgetError: Error, Sendable, Equatable {
    case sourceCountExceeded(maximumCount: Int, actualCount: Int)
}

struct RuntimeGenerationForensicArtifactObservation: Codable, Sendable, Equatable {
    let reference: RuntimeGenerationForensicArtifactReference
    let observedArtifact: RuntimeGenerationObservedArtifact?
}

private enum RuntimeGenerationForensicFailurePhase: String {
    case sourceByteBudget = "source_byte_budget"
    case captureSetByteBudget = "capture_set_byte_budget"
    case sourceCopy = "source_copy"
    case sourceRead = "source_read"
    case destinationWrite = "destination_write"
    case sourceTrailingRead = "source_trailing_read"
    case sourceFinalValidation = "source_final_validation"
    case sourceRetirement = "source_retirement"
    case destinationFinalValidation = "destination_final_validation"
    case destinationSynchronization = "destination_synchronization"
    case publicationPreflight = "publication_preflight"
    case publication = "publication"
    case publicationVerification = "publication_verification"
    case referenceConstruction = "reference_construction"
}

struct RuntimeGenerationForensicArtifactReference: Codable, Sendable, Equatable {
    let logicalName: String
    let sourceLocationDigest: String
    let byteCount: Int64
    let fileIdentity: RuntimeStoreFileIdentity?
    let preservation: RuntimeGenerationForensicPreservation
    let copiedArtifact: RuntimeGenerationArtifact?
    let failureFingerprint: String?

    // Optional for decode compatibility with evidence written before the raw
    // capture contract recorded coherence, order, time, and durability.
    let captureSetID: String?
    let captureOrder: Int?
    let captureStartedAtMilliseconds: Int64?
    let captureCompletedAtMilliseconds: Int64?
    let captureCoherence: RuntimeGenerationForensicCaptureCoherence?
    let isRestorable: Bool?
    let durability: RuntimeGenerationForensicDurability?
    let preservedRelativePath: String?
    let cleanupIndeterminate: Bool?

    init(
        logicalName: String,
        sourceLocationDigest: String,
        byteCount: Int64,
        fileIdentity: RuntimeStoreFileIdentity?,
        preservation: RuntimeGenerationForensicPreservation,
        copiedArtifact: RuntimeGenerationArtifact?,
        failureFingerprint: String?,
        captureSetID: String? = nil,
        captureOrder: Int? = nil,
        captureStartedAtMilliseconds: Int64? = nil,
        captureCompletedAtMilliseconds: Int64? = nil,
        captureCoherence: RuntimeGenerationForensicCaptureCoherence? = nil,
        isRestorable: Bool? = nil,
        durability: RuntimeGenerationForensicDurability? = nil,
        preservedRelativePath: String? = nil,
        cleanupIndeterminate: Bool? = nil
    ) {
        self.logicalName = logicalName
        self.sourceLocationDigest = sourceLocationDigest
        self.byteCount = byteCount
        self.fileIdentity = fileIdentity
        self.preservation = preservation
        self.copiedArtifact = copiedArtifact
        self.failureFingerprint = failureFingerprint
        self.captureSetID = captureSetID
        self.captureOrder = captureOrder
        self.captureStartedAtMilliseconds = captureStartedAtMilliseconds
        self.captureCompletedAtMilliseconds = captureCompletedAtMilliseconds
        self.captureCoherence = captureCoherence
        self.isRestorable = isRestorable
        self.durability = durability
        self.preservedRelativePath = preservedRelativePath
        self.cleanupIndeterminate = cleanupIndeterminate
    }
}

private extension RuntimeGenerationForensicArtifactReference {
    func recordingCleanupIndeterminate() -> Self {
        Self(
            logicalName: logicalName,
            sourceLocationDigest: sourceLocationDigest,
            byteCount: byteCount,
            fileIdentity: fileIdentity,
            preservation: preservation,
            copiedArtifact: copiedArtifact,
            failureFingerprint: failureFingerprint,
            captureSetID: captureSetID,
            captureOrder: captureOrder,
            captureStartedAtMilliseconds: captureStartedAtMilliseconds,
            captureCompletedAtMilliseconds: captureCompletedAtMilliseconds,
            captureCoherence: captureCoherence,
            isRestorable: isRestorable,
            durability: durability,
            preservedRelativePath: preservedRelativePath,
            cleanupIndeterminate: true
        )
    }
}

enum RuntimeGenerationForensicArtifactPreserver {
    static let maximumSourceCount = 128
    static let maximumCopiedArtifactBytes: Int64 = 8 * 1_024 * 1_024 * 1_024
    static let maximumCaptureSetBytes: Int64 = 8 * 1_024 * 1_024 * 1_024
    static let copyBufferBytes = 1 * 1_024 * 1_024

    static func preserve(
        sources: [(logicalName: String, url: URL)],
        evidenceDirectoryURL: URL,
        evidenceDirectoryRelativePath: String,
        maximumSourceBytes requestedMaximumSourceBytes: Int64 = maximumCopiedArtifactBytes,
        maximumCaptureSetBytes requestedMaximumCaptureSetBytes: Int64 = maximumCaptureSetBytes
    ) throws -> (
        references: [RuntimeGenerationForensicArtifactReference],
        observations: [RuntimeGenerationForensicArtifactObservation],
        copiedArtifacts: [RuntimeGenerationObservedArtifact]
    ) {
        guard requestedMaximumSourceBytes > 0,
              requestedMaximumSourceBytes <= maximumCopiedArtifactBytes,
              requestedMaximumCaptureSetBytes > 0,
              requestedMaximumCaptureSetBytes <= maximumCaptureSetBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(max(requestedMaximumSourceBytes, 0))
            )
        }
        guard sources.count <= maximumSourceCount else {
            throw RuntimeGenerationForensicBudgetError.sourceCountExceeded(
                maximumCount: maximumSourceCount,
                actualCount: sources.count
            )
        }
        let evidenceDirectory = try PinnedForensicDirectory(
            url: evidenceDirectoryURL
        )
        let captureSetID = LocalRuntimeStorageChecksum.sha256Hex(
            for: [
                "ambitions.raw-forensic-capture-set.v1",
                evidenceDirectoryRelativePath,
                sources.map { $0.logicalName }.joined(separator: "\n"),
            ].joined(separator: "\n")
        )
        var references: [RuntimeGenerationForensicArtifactReference] = []
        var observedArtifactsByCaptureOrder: [Int: RuntimeGenerationObservedArtifact] = [:]
        var reservedCaptureSetBytes: Int64 = 0

        do {
            try evidenceDirectory.revalidate()
            for (captureOrder, source) in sources.enumerated() {
            try RuntimeGenerationControlValidation.requireIdentifier(
                source.logicalName,
                field: "forensic_logical_name"
            )
            try withPinnedForensicDirectory(
                at: source.url.standardizedFileURL.deletingLastPathComponent()
            ) { sourceDirectory in
            let sourceURL = source.url.standardizedFileURL
            let sourceName = sourceURL.lastPathComponent
            try requireSafeFileName(sourceName)
            let locationDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: sourceURL.path
            )
            let captureStartedAt = wallClockMilliseconds()
            try sourceDirectory.revalidate()

            var entryStatus = stat()
            if fstatat(
                sourceDirectory.descriptor,
                sourceName,
                &entryStatus,
                AT_SYMLINK_NOFOLLOW
            ) != 0 {
                guard errno == ENOENT else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "inspect_forensic_source_\(source.logicalName)"
                    )
                }
                references.append(RuntimeGenerationForensicArtifactReference(
                    logicalName: source.logicalName,
                    sourceLocationDigest: locationDigest,
                    byteCount: 0,
                    fileIdentity: nil,
                    preservation: .absent,
                    copiedArtifact: nil,
                    failureFingerprint: nil,
                    captureSetID: captureSetID,
                    captureOrder: captureOrder,
                    captureStartedAtMilliseconds: captureStartedAt,
                    captureCompletedAtMilliseconds: wallClockMilliseconds(),
                    captureCoherence: .rawSequentialNoncoherent,
                    isRestorable: false,
                    durability: .notApplicable,
                    preservedRelativePath: nil,
                    cleanupIndeterminate: sourceDirectory.closeIfNeeded() == false
                ))
                return
            }
            let sourceDescriptor = Darwin.openat(
                sourceDirectory.descriptor,
                sourceName,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
            guard sourceDescriptor >= 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            var sourceDescriptorOpen = true
            var sourceDescriptorCloseResult: Bool?
            var destinationDescriptor: Int32 = -1
            var destinationDescriptorOpen = false
            var destinationDescriptorCloseResult: Bool?

            func closeSourceOnce() -> Bool {
                if let sourceDescriptorCloseResult {
                    return sourceDescriptorCloseResult
                }
                guard sourceDescriptorOpen else { return true }
                sourceDescriptorOpen = false
                let result = Darwin.close(sourceDescriptor) == 0
                sourceDescriptorCloseResult = result
                return result
            }

            func closeDestinationOnce() -> Bool {
                if let destinationDescriptorCloseResult {
                    return destinationDescriptorCloseResult
                }
                guard destinationDescriptorOpen else { return true }
                destinationDescriptorOpen = false
                let result = Darwin.close(destinationDescriptor) == 0
                destinationDescriptorCloseResult = result
                return result
            }

            defer {
                _ = closeSourceOnce()
                _ = closeDestinationOnce()
            }

            let sourceSnapshot = try requireBoundRegularFile(
                descriptor: sourceDescriptor,
                directory: sourceDirectory,
                entryName: sourceName,
                expected: nil
            )
            let captureSetReservation = reservedCaptureSetBytes.addingReportingOverflow(
                sourceSnapshot.byteCount
            )
            let budgetFailure: (
                error: RuntimeGenerationControlError,
                phase: RuntimeGenerationForensicFailurePhase
            )?
            if sourceSnapshot.byteCount > requestedMaximumSourceBytes {
                budgetFailure = (
                    .readBudgetExceeded(maximumBytes: Int(requestedMaximumSourceBytes)),
                    .sourceByteBudget
                )
            } else if captureSetReservation.overflow ||
                        captureSetReservation.partialValue > requestedMaximumCaptureSetBytes {
                budgetFailure = (
                    .readBudgetExceeded(maximumBytes: Int(requestedMaximumCaptureSetBytes)),
                    .captureSetByteBudget
                )
            } else {
                budgetFailure = nil
            }
            if let budgetFailure {
                let sourceClosed = closeSourceOnce()
                let sourceDirectoryClosed = sourceDirectory.closeIfNeeded()
                references.append(RuntimeGenerationForensicArtifactReference(
                    logicalName: source.logicalName,
                    sourceLocationDigest: locationDigest,
                    byteCount: sourceSnapshot.byteCount,
                    fileIdentity: sourceSnapshot.identity,
                    preservation: .skippedBudgetExceeded,
                    copiedArtifact: nil,
                    failureFingerprint: failureFingerprint(
                        for: budgetFailure.error,
                        phase: budgetFailure.phase
                    ),
                    captureSetID: captureSetID,
                    captureOrder: captureOrder,
                    captureStartedAtMilliseconds: captureStartedAt,
                    captureCompletedAtMilliseconds: wallClockMilliseconds(),
                    captureCoherence: .rawSequentialNoncoherent,
                    isRestorable: false,
                    durability: .notApplicable,
                    preservedRelativePath: nil,
                    cleanupIndeterminate:
                        sourceClosed == false || sourceDirectoryClosed == false
                ))
                return
            }
            reservedCaptureSetBytes = captureSetReservation.partialValue
            try requireCapacity(
                byteCount: sourceSnapshot.byteCount,
                directory: evidenceDirectory,
                logicalName: source.logicalName
            )

            let destinationName = "Raw-\(source.logicalName)"
            let stagingName = ".Raw-\(source.logicalName)-\(captureOrder).staging"
            let partialName = "Raw-\(source.logicalName).partial-\(captureOrder)"
            try requireSafeFileName(destinationName)
            try requireSafeFileName(stagingName)
            try requireSafeFileName(partialName)
            try evidenceDirectory.requireEntryAbsent(destinationName)
            try evidenceDirectory.requireEntryAbsent(partialName)
            destinationDescriptor = Darwin.openat(
                evidenceDirectory.descriptor,
                stagingName,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
                S_IRUSR | S_IWUSR
            )
            guard destinationDescriptor >= 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "create_forensic_destination_\(source.logicalName)"
                )
            }
            destinationDescriptorOpen = true
            let destinationSnapshot: ForensicFileSnapshot
            do {
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    toOpenFileDescriptor: destinationDescriptor,
                    artifact: "raw_forensic_artifact_reserved"
                )
                destinationSnapshot = try requireBoundRegularFile(
                    descriptor: destinationDescriptor,
                    directory: evidenceDirectory,
                    entryName: stagingName,
                    expected: nil
                )
            } catch {
                let preparationError = error
                let removed = removeOwnedEmptyStaging(
                    descriptor: destinationDescriptor,
                    stagingName: stagingName,
                    directory: evidenceDirectory
                )
                let sourceClosed = closeSourceOnce()
                let destinationClosed = closeDestinationOnce()
                guard removed, sourceClosed, destinationClosed else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "cleanup_unprepared_forensic_destination"
                    )
                }
                throw preparationError
            }

            var hasher = SHA256()
            var copiedByteCount: Int64 = 0
            var currentDestinationEntryName = stagingName
            var failurePhase = RuntimeGenerationForensicFailurePhase.sourceCopy
            do {
                var remaining = sourceSnapshot.byteCount
                var buffer = [UInt8](repeating: 0, count: copyBufferBytes)
                while remaining > 0 {
                    failurePhase = .sourceCopy
                    try Task.checkCancellation()
                    let requested = min(Int64(buffer.count), remaining)
                    failurePhase = .sourceRead
                    let readCount = try retryingRead(
                        descriptor: sourceDescriptor,
                        buffer: &buffer,
                        count: Int(requested),
                        operation: "read_forensic_source_\(source.logicalName)"
                    )
                    guard readCount > 0 else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "short_forensic_source_\(source.logicalName)"
                        )
                    }
                    failurePhase = .destinationWrite
                    try writeAll(
                        descriptor: destinationDescriptor,
                        buffer: buffer,
                        count: readCount,
                        operation: "write_forensic_destination_\(source.logicalName)"
                    )
                    hasher.update(data: Data(buffer.prefix(readCount)))
                    copiedByteCount += Int64(readCount)
                    remaining -= Int64(readCount)
                }
                var trailing = [UInt8](repeating: 0, count: 1)
                failurePhase = .sourceTrailingRead
                guard try retryingRead(
                    descriptor: sourceDescriptor,
                    buffer: &trailing,
                    count: 1,
                    operation: "trailing_read_forensic_source_\(source.logicalName)"
                ) == 0 else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: source.logicalName
                    )
                }
                failurePhase = .sourceFinalValidation
                _ = try requireBoundRegularFile(
                    descriptor: sourceDescriptor,
                    directory: sourceDirectory,
                    entryName: sourceName,
                    expected: sourceSnapshot
                )
                failurePhase = .publicationPreflight
                try Task.checkCancellation()
                // Source identity is no longer needed after this point. Retire
                // both source capabilities before the no-return destination
                // publication boundary, so a close failure can only produce a
                // partial artifact and can never strand an unjournaled final.
                failurePhase = .sourceRetirement
                guard closeSourceOnce(), sourceDirectory.closeIfNeeded() else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_forensic_source_before_publication"
                    )
                }
                failurePhase = .destinationFinalValidation
                _ = try requireBoundRegularFile(
                    descriptor: destinationDescriptor,
                    directory: evidenceDirectory,
                    entryName: stagingName,
                    expected: destinationSnapshot,
                    requireUnchangedContent: false
                )
                failurePhase = .destinationSynchronization
                guard Darwin.fsync(destinationDescriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "finalize_forensic_copy_\(source.logicalName)"
                    )
                }
                // Cancellation is accepted until publication begins. Once the
                // exclusive rename succeeds, the completed artifact is the
                // durable outcome and must not be reported as merely partial.
                failurePhase = .publicationPreflight
                try Task.checkCancellation()
                try evidenceDirectory.revalidate()
                failurePhase = .publication
                guard Darwin.renameatx_np(
                    evidenceDirectory.descriptor,
                    stagingName,
                    evidenceDirectory.descriptor,
                    destinationName,
                    UInt32(RENAME_EXCL)
                ) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "publish_forensic_copy_\(source.logicalName)"
                    )
                }
                currentDestinationEntryName = destinationName
                failurePhase = .publicationVerification
                guard Darwin.fsync(evidenceDirectory.descriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "synchronize_forensic_publication_\(source.logicalName)"
                    )
                }
                let completedDestination = try requireBoundRegularFile(
                    descriptor: destinationDescriptor,
                    directory: evidenceDirectory,
                    entryName: destinationName,
                    expected: destinationSnapshot,
                    requireUnchangedContent: false
                )
                guard completedDestination.byteCount == copiedByteCount else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: destinationName
                    )
                }
                failurePhase = .referenceConstruction
                let semantic = try RuntimeGenerationArtifact(
                    relativePath: "\(evidenceDirectoryRelativePath)/\(destinationName)",
                    sha256: hexDigest(hasher.finalize()),
                    byteCount: copiedByteCount,
                    protectionClass: "complete"
                )
                let observed = try RuntimeGenerationObservedArtifact(
                    semantic: semantic,
                    fileIdentity: destinationSnapshot.identity
                )
                // No throwing operation may occur after these exactly-once close
                // attempts; otherwise a catch path could act on a reused numeric
                // descriptor while trying to preserve partial evidence.
                let sourceClosed = closeSourceOnce()
                let destinationClosed = closeDestinationOnce()
                references.append(RuntimeGenerationForensicArtifactReference(
                    logicalName: source.logicalName,
                    sourceLocationDigest: locationDigest,
                    byteCount: sourceSnapshot.byteCount,
                    fileIdentity: sourceSnapshot.identity,
                    preservation: .copied,
                    copiedArtifact: semantic,
                    failureFingerprint: nil,
                    captureSetID: captureSetID,
                    captureOrder: captureOrder,
                    captureStartedAtMilliseconds: captureStartedAt,
                    captureCompletedAtMilliseconds: wallClockMilliseconds(),
                    captureCoherence: .rawSequentialNoncoherent,
                    isRestorable: false,
                    durability: .durable,
                    preservedRelativePath:
                        "\(evidenceDirectoryRelativePath)/\(destinationName)",
                    cleanupIndeterminate: sourceClosed == false || destinationClosed == false
                ))
                observedArtifactsByCaptureOrder[captureOrder] = observed
            } catch {
                let copyError = error
                let partial = finalizePartialEvidence(
                    logicalName: source.logicalName,
                    sourceLocationDigest: locationDigest,
                    sourceSnapshot: sourceSnapshot,
                    destinationSnapshot: destinationSnapshot,
                    destinationDescriptor: destinationDescriptor,
                    currentEntryName: currentDestinationEntryName,
                    partialName: partialName,
                    evidenceDirectory: evidenceDirectory,
                    evidenceDirectoryRelativePath: evidenceDirectoryRelativePath,
                    captureSetID: captureSetID,
                    captureOrder: captureOrder,
                    captureStartedAtMilliseconds: captureStartedAt,
                    copyError: copyError,
                    failurePhase: failurePhase,
                    closeSource: closeSourceOnce,
                    closeDestination: closeDestinationOnce,
                    closeSourceDirectory: sourceDirectory.closeIfNeeded
                )
                if let observed = partial.observedArtifact {
                    observedArtifactsByCaptureOrder[captureOrder] = observed
                }
                references.append(partial.reference)
                if copyError is CancellationError {
                    guard partial.journalIsDurable,
                          partial.reference.durability == .durable else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "preserve_cancelled_forensic_evidence"
                        )
                    }
                    throw CancellationError()
                }
            }
            }
            }
        } catch {
            let operationError = error
            guard evidenceDirectory.closeIfNeeded() else {
                throw RuntimeGenerationForensicOperationAndCleanupError(
                    precedingFailure: precedingFailure(operationError),
                    cleanupOperation: "close_failed_forensic_evidence_directory"
                )
            }
            throw operationError
        }
        guard evidenceDirectory.closeIfNeeded() else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_failed_forensic_evidence_directory"
            )
        }
        let observations = references.map { reference in
            RuntimeGenerationForensicArtifactObservation(
                reference: reference,
                observedArtifact: reference.captureOrder.flatMap {
                    observedArtifactsByCaptureOrder[$0]
                }
            )
        }
        // Compatibility-only legacy side channel. Raw sequential captures and
        // partial artifacts are never complete/restorable artifacts, so exposing
        // any of them here would erase the reference's truth-bearing status.
        return (references, observations, [])
    }

    private static func finalizePartialEvidence(
        logicalName: String,
        sourceLocationDigest: String,
        sourceSnapshot: ForensicFileSnapshot,
        destinationSnapshot: ForensicFileSnapshot,
        destinationDescriptor: Int32,
        currentEntryName: String,
        partialName: String,
        evidenceDirectory: PinnedForensicDirectory,
        evidenceDirectoryRelativePath: String,
        captureSetID: String,
        captureOrder: Int,
        captureStartedAtMilliseconds: Int64?,
        copyError: Error,
        failurePhase: RuntimeGenerationForensicFailurePhase,
        closeSource: () -> Bool,
        closeDestination: () -> Bool,
        closeSourceDirectory: () -> Bool
    ) -> (
        reference: RuntimeGenerationForensicArtifactReference,
        observedArtifact: RuntimeGenerationObservedArtifact?,
        journalIsDurable: Bool
    ) {
        var durability = RuntimeGenerationForensicDurability.indeterminate
        var preservedRelativePath =
            "\(evidenceDirectoryRelativePath)/\(currentEntryName)"
        var semantic: RuntimeGenerationArtifact?
        var observed: RuntimeGenerationObservedArtifact?
        var cleanupIndeterminate = false

        do {
            guard Darwin.fsync(destinationDescriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_partial_forensic_copy"
                )
            }
            let partialSnapshot = try requireBoundRegularFile(
                descriptor: destinationDescriptor,
                directory: evidenceDirectory,
                entryName: currentEntryName,
                expected: destinationSnapshot,
                requireUnchangedContent: false
            )
            let partialDigest = try digestFile(
                descriptor: destinationDescriptor,
                byteCount: partialSnapshot.byteCount
            )
            try evidenceDirectory.revalidate()
            guard Darwin.renameatx_np(
                evidenceDirectory.descriptor,
                currentEntryName,
                evidenceDirectory.descriptor,
                partialName,
                UInt32(RENAME_EXCL)
            ) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "publish_partial_forensic_copy"
                )
            }
            preservedRelativePath =
                "\(evidenceDirectoryRelativePath)/\(partialName)"
            guard Darwin.fsync(evidenceDirectory.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_partial_forensic_copy"
                )
            }
            _ = try requireBoundRegularFile(
                descriptor: destinationDescriptor,
                directory: evidenceDirectory,
                entryName: partialName,
                expected: destinationSnapshot,
                requireUnchangedContent: false
            )
            semantic = try RuntimeGenerationArtifact(
                relativePath: preservedRelativePath,
                sha256: partialDigest,
                byteCount: partialSnapshot.byteCount,
                protectionClass: "complete"
            )
            if let semantic {
                observed = try RuntimeGenerationObservedArtifact(
                    semantic: semantic,
                    fileIdentity: destinationSnapshot.identity
                )
            }
            durability = .durable
        } catch {
            cleanupIndeterminate = true
        }

        let sourceClosed = closeSource()
        let destinationClosed = closeDestination()
        let sourceDirectoryClosed = closeSourceDirectory()
        if sourceClosed == false || destinationClosed == false ||
            sourceDirectoryClosed == false {
            cleanupIndeterminate = true
        }

        var reference = RuntimeGenerationForensicArtifactReference(
            logicalName: logicalName,
            sourceLocationDigest: sourceLocationDigest,
            byteCount: sourceSnapshot.byteCount,
            fileIdentity: sourceSnapshot.identity,
            preservation: .partial,
            copiedArtifact: semantic,
            failureFingerprint: failureFingerprint(
                for: copyError,
                phase: failurePhase
            ),
            captureSetID: captureSetID,
            captureOrder: captureOrder,
            captureStartedAtMilliseconds: captureStartedAtMilliseconds,
            captureCompletedAtMilliseconds: wallClockMilliseconds(),
            captureCoherence: .rawSequentialNoncoherent,
            isRestorable: false,
            durability: durability,
            preservedRelativePath: preservedRelativePath,
            cleanupIndeterminate: cleanupIndeterminate
        )
        let journalName = "Raw-\(logicalName).partial-\(captureOrder).json"
        let journalIsDurable: Bool
        do {
            let data = try RuntimeGenerationControlCodec.encode(reference)
            try publishSmallEvidence(
                data,
                finalName: journalName,
                directory: evidenceDirectory
            )
            journalIsDurable = true
        } catch {
            journalIsDurable = false
            reference = reference.recordingCleanupIndeterminate()
        }
        return (reference, observed, journalIsDurable)
    }

    private static func publishSmallEvidence(
        _ data: Data,
        finalName: String,
        directory: PinnedForensicDirectory
    ) throws {
        try requireSafeFileName(finalName)
        let stagingName = ".\(finalName).staging"
        try requireSafeFileName(stagingName)
        try directory.requireEntryAbsent(finalName)
        let descriptor = Darwin.openat(
            directory.descriptor,
            stagingName,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "create_forensic_partial_journal"
            )
        }
        var descriptorOpen = true
        defer {
            if descriptorOpen {
                descriptorOpen = false
                _ = Darwin.close(descriptor)
            }
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            toOpenFileDescriptor: descriptor,
            artifact: "forensic_partial_journal_reserved"
        )
        let snapshot = try requireBoundRegularFile(
            descriptor: descriptor,
            directory: directory,
            entryName: stagingName,
            expected: nil
        )
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let result = Darwin.write(
                    descriptor,
                    bytes.baseAddress?.advanced(by: offset),
                    bytes.count - offset
                )
                if result < 0, errno == EINTR { continue }
                guard result > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "write_forensic_partial_journal"
                    )
                }
                offset += result
            }
        }
        guard Darwin.fsync(descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_forensic_partial_journal"
            )
        }
        _ = try requireBoundRegularFile(
            descriptor: descriptor,
            directory: directory,
            entryName: stagingName,
            expected: snapshot,
            requireUnchangedContent: false
        )
        try directory.revalidate()
        guard Darwin.renameatx_np(
            directory.descriptor,
            stagingName,
            directory.descriptor,
            finalName,
            UInt32(RENAME_EXCL)
        ) == 0,
        Darwin.fsync(directory.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "publish_forensic_partial_journal"
            )
        }
        _ = try requireBoundRegularFile(
            descriptor: descriptor,
            directory: directory,
            entryName: finalName,
            expected: snapshot,
            requireUnchangedContent: false
        )
        descriptorOpen = false
        guard Darwin.close(descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_forensic_partial_journal"
            )
        }
    }

    private static func requireCapacity(
        byteCount: Int64,
        directory: PinnedForensicDirectory,
        logicalName: String
    ) throws {
        var filesystem = statfs()
        guard fstatfs(directory.descriptor, &filesystem) == 0,
              filesystem.f_bavail >= 0,
              filesystem.f_bsize > 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_forensic_capacity_\(logicalName)"
            )
        }
        let availableBlocks = UInt64(filesystem.f_bavail)
        let blockSize = UInt64(filesystem.f_bsize)
        let (availableBytes, overflow) = availableBlocks.multipliedReportingOverflow(
            by: blockSize
        )
        guard overflow == false,
              availableBytes >= UInt64(byteCount) + (2 * blockSize) else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "insufficient_forensic_capacity_\(logicalName)"
            )
        }
    }

    private static func withPinnedForensicDirectory<Result>(
        at url: URL,
        _ operation: (PinnedForensicDirectory) throws -> Result
    ) throws -> Result {
        let directory = try PinnedForensicDirectory(url: url)
        do {
            let result = try operation(directory)
            guard directory.closeWasAttempted else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "unretired_forensic_source_directory"
                )
            }
            return result
        } catch {
            let operationError = error
            guard directory.closeIfNeeded() else {
                throw RuntimeGenerationForensicOperationAndCleanupError(
                    precedingFailure: precedingFailure(operationError),
                    cleanupOperation: "close_failed_forensic_source_directory"
                )
            }
            throw operationError
        }
    }

    private static func precedingFailure(
        _ error: Error
    ) -> RuntimeGenerationForensicPrecedingFailure {
        if error is CancellationError { return .cancellation }
        if let error = error as? RuntimeGenerationControlError {
            return .generationControl(error)
        }
        if let error = error as? LocalRuntimeStorageError {
            return .localStorage(error)
        }
        return .unclassifiedFingerprint(
            LocalRuntimeStorageChecksum.sha256Hex(
                for: String(reflecting: type(of: error))
            )
        )
    }

    private static func removeOwnedEmptyStaging(
        descriptor: Int32,
        stagingName: String,
        directory: PinnedForensicDirectory
    ) -> Bool {
        do {
            let snapshot = try requireBoundRegularFile(
                descriptor: descriptor,
                directory: directory,
                entryName: stagingName,
                expected: nil
            )
            guard snapshot.byteCount == 0,
                  Darwin.unlinkat(directory.descriptor, stagingName, 0) == 0,
                  Darwin.fsync(directory.descriptor) == 0 else {
                return false
            }
            return true
        } catch {
            return false
        }
    }

    private static func requireBoundRegularFile(
        descriptor: Int32,
        directory: PinnedForensicDirectory,
        entryName: String,
        expected: ForensicFileSnapshot?,
        requireUnchangedContent: Bool = true
    ) throws -> ForensicFileSnapshot {
        try directory.revalidate()
        var descriptorStatus = stat()
        var entryStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              fstatat(
                directory.descriptor,
                entryName,
                &entryStatus,
                AT_SYMLINK_NOFOLLOW
              ) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFREG,
              entryStatus.st_mode & S_IFMT == S_IFREG,
              descriptorStatus.st_nlink == 1,
              entryStatus.st_nlink == 1,
              descriptorStatus.st_dev == entryStatus.st_dev,
              descriptorStatus.st_ino == entryStatus.st_ino,
              descriptorStatus.st_size >= 0 else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: entryName
            )
        }
        let snapshot = ForensicFileSnapshot(status: descriptorStatus)
        if let expected {
            guard snapshot.identity == expected.identity,
                  requireUnchangedContent == false || snapshot == expected else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: entryName
                )
            }
        }
        return snapshot
    }

    private static func digestFile(
        descriptor: Int32,
        byteCount: Int64
    ) throws -> String {
        guard byteCount >= 0, byteCount <= maximumCopiedArtifactBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(maximumCopiedArtifactBytes)
            )
        }
        var hasher = SHA256()
        var offset: Int64 = 0
        var buffer = [UInt8](repeating: 0, count: copyBufferBytes)
        while offset < byteCount {
            let requested = Int(min(Int64(buffer.count), byteCount - offset))
            let result = buffer.withUnsafeMutableBytes { bytes in
                Darwin.pread(
                    descriptor,
                    bytes.baseAddress,
                    requested,
                    off_t(offset)
                )
            }
            if result < 0, errno == EINTR { continue }
            guard result > 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "read_partial_forensic_digest"
                )
            }
            hasher.update(data: Data(buffer.prefix(result)))
            offset += Int64(result)
        }
        return hexDigest(hasher.finalize())
    }

    private static func retryingRead(
        descriptor: Int32,
        buffer: inout [UInt8],
        count: Int,
        operation: String
    ) throws -> Int {
        while true {
            let result = buffer.withUnsafeMutableBytes { bytes in
                Darwin.read(descriptor, bytes.baseAddress, count)
            }
            if result >= 0 { return result }
            if errno == EINTR { continue }
            throw LocalRuntimeStorageError.canonicalIOFailure(operation: operation)
        }
    }

    private static func writeAll(
        descriptor: Int32,
        buffer: [UInt8],
        count: Int,
        operation: String
    ) throws {
        var written = 0
        while written < count {
            let result = buffer.withUnsafeBytes { bytes in
                Darwin.write(
                    descriptor,
                    bytes.baseAddress?.advanced(by: written),
                    count - written
                )
            }
            if result > 0 {
                written += result
            } else if result < 0, errno == EINTR {
                continue
            } else {
                throw LocalRuntimeStorageError.canonicalIOFailure(operation: operation)
            }
        }
    }

    private static func requireSafeFileName(_ value: String) throws {
        guard value.isEmpty == false,
              value != ".",
              value != "..",
              value.utf8.allSatisfy({ $0 != 0 && $0 != 47 }) else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }

    private static func wallClockMilliseconds() -> Int64? {
        var value = timespec()
        guard clock_gettime(CLOCK_REALTIME, &value) == 0,
              value.tv_sec >= 0 else { return nil }
        let seconds = Int64(value.tv_sec)
        let milliseconds = Int64(value.tv_nsec / 1_000_000)
        guard seconds <= (Int64.max - milliseconds) / 1_000 else {
            return nil
        }
        return seconds * 1_000 + milliseconds
    }

    private static func hexDigest(_ digest: SHA256.Digest) -> String {
        digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func failureFingerprint(
        for error: Error,
        phase: RuntimeGenerationForensicFailurePhase
    ) -> String {
        LocalRuntimeStorageChecksum.sha256Hex(
            for: [
                "ambitions.raw-forensic-failure.v2",
                phase.rawValue,
                privacySafeErrorCode(error),
            ].joined(separator: "\n")
        )
    }

    /// Returns only a stable case identifier. Associated values are deliberately
    /// excluded because they may contain paths, SQL, schema fields, object IDs,
    /// or system-provided messages.
    private static func privacySafeErrorCode(_ error: Error) -> String {
        if error is CancellationError { return "cancellation" }
        if let error = error as? RuntimeGenerationControlError {
            return switch error {
            case .malformed: "control.malformed"
            case .unsupportedVersion: "control.unsupported_version"
            case .futureVersion: "control.future_version"
            case .recordConflict: "control.record_conflict"
            case .recordMissing: "control.record_missing"
            case .recordCorrupt: "control.record_corrupt"
            case .readBudgetExceeded: "control.read_budget_exceeded"
            case .reservationExpired: "control.reservation_expired"
            case .reservationConsumed: "control.reservation_consumed"
            case .activationReconciliationPending: "control.activation_reconciliation_pending"
            case .verificationRejected: "control.verification_rejected"
            case .verificationStale: "control.verification_stale"
            case .activationIntentConsumed: "control.activation_intent_consumed"
            case .activationIntentExpired: "control.activation_intent_expired"
            case .activationFenceAdvanced: "control.activation_fence_advanced"
            case .activationAuthorityMismatch: "control.activation_authority_mismatch"
            case .rollbackUnsafe: "control.rollback_unsafe"
            case .restoreSourceUnverified: "control.restore_source_unverified"
            case .recoveryAuthorizationRequired: "control.recovery_authorization_required"
            case .sourceQuarantined: "control.source_quarantined"
            case .importReviewRequired: "control.import_review_required"
            case .importLossNotAccepted: "control.import_loss_not_accepted"
            case .unsupportedSourceSchema: "control.unsupported_source_schema"
            case .generationWorkerBarrierBusy: "control.worker_barrier_busy"
            case .generationWorkerBarrierMismatch: "control.worker_barrier_mismatch"
            case .controlAuthorityUnavailable: "control.authority_unavailable"
            case .derivedCandidateCloseFailed: "control.derived_candidate_close_failed"
            case .derivedCanonicalMutationDenied: "control.derived_canonical_mutation_denied"
            }
        }
        if let error = error as? LocalRuntimeStorageError {
            return switch error {
            case .protectedDataUnavailable: "storage.protected_data_unavailable"
            case .canonicalManifestMissing: "storage.manifest_missing"
            case .canonicalManifestMalformed: "storage.manifest_malformed"
            case .canonicalManifestMismatch: "storage.manifest_mismatch"
            case .canonicalManifestUnverified: "storage.manifest_unverified"
            case .canonicalFutureManifestSchema: "storage.future_manifest_schema"
            case .canonicalUnsupportedManifestSchema: "storage.unsupported_manifest_schema"
            case .canonicalFutureDatabaseSchema: "storage.future_database_schema"
            case .canonicalUnsupportedDatabaseSchema: "storage.unsupported_database_schema"
            case .canonicalGenerationAlreadyExists: "storage.generation_already_exists"
            case .canonicalGenerationMissing: "storage.generation_missing"
            case .canonicalStorageFull: "storage.full"
            case .canonicalIOFailure: "storage.io_failure"
            case .canonicalSQLiteFailure: "storage.sqlite_failure"
            case .canonicalIntegrityFailure: "storage.integrity_failure"
            case .canonicalForeignKeyFailure: "storage.foreign_key_failure"
            case .canonicalFileProtectionFailure: "storage.file_protection_failure"
            case .canonicalPathAuthorityDenied: "storage.path_authority_denied"
            case .canonicalActivationBusy: "storage.activation_busy"
            case .canonicalActivationLockFailed: "storage.activation_lock_failed"
            case .canonicalFileIdentityChanged: "storage.file_identity_changed"
            case .canonicalReadPageTooLarge: "storage.read_page_too_large"
            case .canonicalActivationFailed: "storage.activation_failed"
            case .canonicalActivationStateUnknown: "storage.activation_state_unknown"
            case .canonicalActivationIsolationIndeterminate:
                "storage.activation_isolation_indeterminate"
            case .canonicalActivationSucceededWithCleanupFailure:
                "storage.activation_cleanup_failure"
            case .canonicalStagingCleanupFailed: "storage.staging_cleanup_failed"
            case .sqliteOpenFailed: "storage.sqlite_open_failed"
            case .sqlitePrepareFailed: "storage.sqlite_prepare_failed"
            case .sqliteStepFailed: "storage.sqlite_step_failed"
            case .sqliteBindFailed: "storage.sqlite_bind_failed"
            case .sqliteMissingRow: "storage.sqlite_missing_row"
            case .sqliteCorruptText: "storage.sqlite_corrupt_text"
            case .sqliteCorruptBlob: "storage.sqlite_corrupt_blob"
            case .unsupportedSchema: "storage.unsupported_schema"
            case .checksumMismatch: "storage.checksum_mismatch"
            case .unsafeExternalSnapshot: "storage.unsafe_external_snapshot"
            case .emptyPayload: "storage.empty_payload"
            case .pathEscape: "storage.path_escape"
            }
        }
        return "unclassified"
    }
}

private struct ForensicFileSnapshot: Sendable, Equatable {
    let identity: RuntimeStoreFileIdentity
    let byteCount: Int64
    let modifiedSeconds: Int64
    let modifiedNanoseconds: Int64
    let changedSeconds: Int64
    let changedNanoseconds: Int64

    init(status: stat) {
        identity = RuntimeStoreFileIdentity(
            device: UInt64(status.st_dev),
            inode: UInt64(status.st_ino)
        )
        byteCount = Int64(status.st_size)
        modifiedSeconds = Int64(status.st_mtimespec.tv_sec)
        modifiedNanoseconds = Int64(status.st_mtimespec.tv_nsec)
        changedSeconds = Int64(status.st_ctimespec.tv_sec)
        changedNanoseconds = Int64(status.st_ctimespec.tv_nsec)
    }
}

/// Owns one directory descriptor and binds it to its pathname for the complete
/// duration of descriptor-relative forensic work. A close is attempted once;
/// numeric descriptors are never retried after an indeterminate close result.
private final class PinnedForensicDirectory {
    let descriptor: Int32
    let url: URL
    private let identity: RuntimeStoreFileIdentity
    private var descriptorOpen = true
    private var descriptorCloseResult: Bool?

    var closeWasAttempted: Bool { descriptorCloseResult != nil }

    init(url: URL) throws {
        self.url = url.standardizedFileURL
        descriptor = Darwin.open(
            self.url.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorStatus = stat()
        var pathStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              lstat(self.url.path, &pathStatus) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFDIR,
              pathStatus.st_mode & S_IFMT == S_IFDIR,
              descriptorStatus.st_dev == pathStatus.st_dev,
              descriptorStatus.st_ino == pathStatus.st_ino else {
            _ = Darwin.close(descriptor)
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        identity = RuntimeStoreFileIdentity(
            device: UInt64(descriptorStatus.st_dev),
            inode: UInt64(descriptorStatus.st_ino)
        )
    }

    deinit {
        _ = closeIfNeeded()
    }

    func revalidate() throws {
        guard descriptorOpen else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorStatus = stat()
        var pathStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              lstat(url.path, &pathStatus) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFDIR,
              pathStatus.st_mode & S_IFMT == S_IFDIR,
              RuntimeStoreFileIdentity(
                device: UInt64(descriptorStatus.st_dev),
                inode: UInt64(descriptorStatus.st_ino)
              ) == identity,
              RuntimeStoreFileIdentity(
                device: UInt64(pathStatus.st_dev),
                inode: UInt64(pathStatus.st_ino)
              ) == identity else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }

    func requireEntryAbsent(_ name: String) throws {
        var status = stat()
        guard fstatat(descriptor, name, &status, AT_SYMLINK_NOFOLLOW) != 0,
              errno == ENOENT else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }

    func closeIfNeeded() -> Bool {
        if let descriptorCloseResult { return descriptorCloseResult }
        guard descriptorOpen else { return true }
        descriptorOpen = false
        let result = Darwin.close(descriptor) == 0
        descriptorCloseResult = result
        return result
    }
}
