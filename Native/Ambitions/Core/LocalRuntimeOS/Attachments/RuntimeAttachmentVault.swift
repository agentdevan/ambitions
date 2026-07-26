import CryptoKit
import Darwin
import Foundation

struct RuntimeAttachmentFinalizationProof: Sendable, Equatable, Hashable {
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let receiptID: RuntimeReceiptID
    let terminalEventSequence: UInt64
    let markerDigest: String
    let finalizedAt: Date
    let proofDigest: String

    fileprivate init(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        receiptID: RuntimeReceiptID,
        terminalEventSequence: UInt64,
        markerDigest: String,
        finalizedAt: Date,
        proofDigest: String
    ) {
        self.blobID = blobID
        self.manifestDigest = manifestDigest
        self.receiptID = receiptID
        self.terminalEventSequence = terminalEventSequence
        self.markerDigest = markerDigest
        self.finalizedAt = finalizedAt
        self.proofDigest = proofDigest
    }
}

struct RuntimeAttachmentPhysicalDeletionProof: Sendable, Equatable, Hashable {
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let leaseID: RuntimeBlobGCLeaseID
    let expectedStateVersion: UInt64
    let disposition: RuntimeAttachmentPhysicalDeletionDisposition
    let directoryDevice: UInt64?
    let directoryInode: UInt64?
    let deletedAt: Date
    let proofDigest: String

    fileprivate init(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        leaseID: RuntimeBlobGCLeaseID,
        expectedStateVersion: UInt64,
        disposition: RuntimeAttachmentPhysicalDeletionDisposition,
        directoryDevice: UInt64?,
        directoryInode: UInt64?,
        deletedAt: Date,
        proofDigest: String
    ) {
        self.blobID = blobID
        self.manifestDigest = manifestDigest
        self.leaseID = leaseID
        self.expectedStateVersion = expectedStateVersion
        self.disposition = disposition
        self.directoryDevice = directoryDevice
        self.directoryInode = directoryInode
        self.deletedAt = deletedAt
        self.proofDigest = proofDigest
    }
}

struct RuntimeAttachmentVaultDeletionClaim: Sendable, Equatable {
    let manifest: RuntimeBlobManifestAuthority
    let manifestDigest: String
    let lease: RuntimeBlobGCLease
    let leaseToken: String
    let originalRelativeDirectory: String
    let quarantineRelativeDirectory: String
    let disposition: RuntimeAttachmentPhysicalDeletionDisposition
    let directoryDevice: UInt64?
    let directoryInode: UInt64?
    let preparedAt: Date
    let claimDigest: String

    fileprivate init(
        manifest: RuntimeBlobManifestAuthority,
        manifestDigest: String,
        lease: RuntimeBlobGCLease,
        leaseToken: String,
        originalRelativeDirectory: String,
        quarantineRelativeDirectory: String,
        disposition: RuntimeAttachmentPhysicalDeletionDisposition,
        directoryDevice: UInt64?,
        directoryInode: UInt64?,
        preparedAt: Date,
        claimDigest: String
    ) {
        self.manifest = manifest
        self.manifestDigest = manifestDigest
        self.lease = lease
        self.leaseToken = leaseToken
        self.originalRelativeDirectory = originalRelativeDirectory
        self.quarantineRelativeDirectory = quarantineRelativeDirectory
        self.disposition = disposition
        self.directoryDevice = directoryDevice
        self.directoryInode = directoryInode
        self.preparedAt = preparedAt
        self.claimDigest = claimDigest
    }
}

struct RuntimeAttachmentVaultManifestDeletionClaim: Sendable, Equatable {
    let claim: RuntimeAttachmentManifestDeletionClaim
    let quarantineRelativeDirectory: String
    let quarantineDevice: UInt64
    let quarantineInode: UInt64
    let preparedAt: Date
    let claimDigest: String

    fileprivate init(
        claim: RuntimeAttachmentManifestDeletionClaim,
        quarantineRelativeDirectory: String,
        quarantineDevice: UInt64,
        quarantineInode: UInt64,
        preparedAt: Date,
        claimDigest: String
    ) {
        self.claim = claim
        self.quarantineRelativeDirectory = quarantineRelativeDirectory
        self.quarantineDevice = quarantineDevice
        self.quarantineInode = quarantineInode
        self.preparedAt = preparedAt
        self.claimDigest = claimDigest
    }
}

struct RuntimeAttachmentManifestDeletionProof: Codable, Sendable, Equatable, Hashable {
    let claimID: String
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let originalRelativeDirectory: String
    let quarantineRelativeDirectory: String
    let directoryDevice: UInt64
    let directoryInode: UInt64
    let deletedAt: Date
    let proofDigest: String

    fileprivate init(
        claimID: String,
        blobID: RuntimeBlobID,
        manifestDigest: String,
        originalRelativeDirectory: String,
        quarantineRelativeDirectory: String,
        directoryDevice: UInt64,
        directoryInode: UInt64,
        deletedAt: Date,
        proofDigest: String
    ) {
        self.claimID = claimID
        self.blobID = blobID
        self.manifestDigest = manifestDigest
        self.originalRelativeDirectory = originalRelativeDirectory
        self.quarantineRelativeDirectory = quarantineRelativeDirectory
        self.directoryDevice = directoryDevice
        self.directoryInode = directoryInode
        self.deletedAt = deletedAt
        self.proofDigest = proofDigest
    }
}

struct RuntimeAttachmentVaultStageRequest: Sendable {
    let attachmentID: RuntimeAttachmentID
    let revisionID: RuntimeAttachmentRevisionID
    let revision: UInt64
    let blobID: RuntimeBlobID
    let ownedPlaintextURL: URL
    let intakeProof: RuntimeAttachmentValidatedIntakeProof
    let normalizedFilename: String
    let declaredContentType: String
    let detectedContentType: String
    let privacy: EventLedgerPrivacyClassification
    let dedupPolicy: RuntimeAttachmentDedupPolicy
    let provenance: RuntimeAttachmentProvenance
    let reservationID: RuntimeBlobQuotaReservationID
    let expectedByteCount: Int64
    let retentionUntil: Date?
    let createdAt: Date
}

struct RuntimeAttachmentFinalizationMarker: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let receiptID: RuntimeReceiptID
    let terminalEventSequence: UInt64
    let finalizedAt: Date
}

struct RuntimeAttachmentReadCursor: Sendable, Equatable {
    let blobID: RuntimeBlobID
    let nextChunkIndex: Int
    let plaintextBytesRead: Int64
}

struct RuntimeAttachmentReadPage: Sendable, Equatable {
    let bytes: Data
    let nextCursor: RuntimeAttachmentReadCursor?
}

struct RuntimeOwnedAttachmentManifestInspection: Sendable, Equatable {
    let manifest: RuntimeBlobManifestAuthority
    let manifestDigest: String
    let directoryDevice: UInt64
    let directoryInode: UInt64
}

struct RuntimeAttachmentFilesystemMalformedEntry: Sendable, Equatable {
    let cursorKey: String
    let redactedNameDigest: String
    let parentScope: String
    let error: RuntimeCanonicalAttachmentError
}

enum RuntimeAttachmentFilesystemEntry: Sendable, Equatable {
    case owned(cursorKey: String, url: URL)
    case malformed(RuntimeAttachmentFilesystemMalformedEntry)

    var cursorKey: String {
        switch self {
        case let .owned(cursorKey, _): cursorKey
        case let .malformed(finding): finding.cursorKey
        }
    }
}

struct RuntimeAttachmentFilesystemPage: Sendable, Equatable {
    let entries: [RuntimeAttachmentFilesystemEntry]
    let nextCursorKey: String?
    let exhausted: Bool
}

actor RuntimeAttachmentVault {
    private static let maximumOwnedTemporaryDirectoryCount = 4_096
    private struct Header: Codable {
        let version: Int
        let blobID: RuntimeBlobID
        let privacyDomain: RuntimeAttachmentPrivacyDomain
        let dedupPolicy: RuntimeAttachmentDedupPolicy
        let keyedContentAddress: RuntimeAttachmentContentAddress
        let chunkSize: Int
        let plaintextByteCount: Int64
        let protectionClass: RuntimeAttachmentProtectionClass
    }

    private struct Terminal: Codable, Equatable {
        let version: Int
        let blobID: RuntimeBlobID
        let headerDigest: String
        let chunkCount: Int
        let plaintextByteCount: Int64
        let framedChunkByteCount: Int64
        let orderedCiphertextDigest: String
    }

    private let rootDirectory: URL
    private let fileManager: FileManager
    private let processLock: FileHandle
    private let keyCustody: any RuntimeAttachmentKeyCustody
    private let intakeProofKey: SymmetricKey
    private let chunkSize: Int
    private let opaqueToken: @Sendable () -> String

    init(
        rootDirectory: URL,
        keyCustody: any RuntimeAttachmentKeyCustody,
        intakeProofKey: SymmetricKey,
        chunkSize: Int = 256 * 1_024,
        fileManager: FileManager = .default,
        opaqueToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() }
    ) throws {
        guard chunkSize >= RuntimeAttachmentLimits.minimumChunkBytes,
              chunkSize <= RuntimeAttachmentLimits.maximumChunkBytes else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let standardizedRoot = rootDirectory.standardizedFileURL
        let processLock = try Self.acquireProcessLock(
            rootDirectory: standardizedRoot, fileManager: fileManager
        )
        self.rootDirectory = standardizedRoot
        self.processLock = processLock
        self.keyCustody = keyCustody
        self.intakeProofKey = intakeProofKey
        self.chunkSize = chunkSize
        self.fileManager = fileManager
        self.opaqueToken = opaqueToken
    }

    private static func acquireProcessLock(
        rootDirectory: URL,
        fileManager: FileManager
    ) throws -> FileHandle {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let rootValues = try rootDirectory.resourceValues(
            forKeys: [.isDirectoryKey, .isSymbolicLinkKey]
        )
        guard rootValues.isDirectory == true, rootValues.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: rootDirectory.path
        )
        let rootAttributes = try fileManager.attributesOfItem(atPath: rootDirectory.path)
        guard rootAttributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif

        let lockURL = rootDirectory.appendingPathComponent(".vault.lock", isDirectory: false)
        let descriptor = Darwin.open(
            lockURL.path,
            O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        do {
            var opened = stat()
            var current = stat()
            guard fstat(descriptor, &opened) == 0,
                  lstat(lockURL.path, &current) == 0,
                  (opened.st_mode & S_IFMT) == S_IFREG,
                  (current.st_mode & S_IFMT) == S_IFREG,
                  opened.st_nlink == 1,
                  UInt64(opened.st_dev) == UInt64(current.st_dev),
                  UInt64(opened.st_ino) == UInt64(current.st_ino) else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            #if os(iOS)
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.complete], ofItemAtPath: lockURL.path
            )
            let attributes = try fileManager.attributesOfItem(atPath: lockURL.path)
            guard attributes[.protectionKey] as? FileProtectionType == .complete else {
                throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
            }
            #endif
            guard Darwin.flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            try synchronizeDirectoryForProcessLock(rootDirectory)
            try synchronizeDirectoryForProcessLock(rootDirectory.deletingLastPathComponent())
            return FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        } catch {
            Darwin.close(descriptor)
            throw error
        }
    }

    private static func synchronizeDirectoryForProcessLock(_ url: URL) throws {
        let descriptor = Darwin.open(url.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFDIR,
              (fcntl(descriptor, F_FULLFSYNC) == 0 || fsync(descriptor) == 0) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    func stage(_ request: RuntimeAttachmentVaultStageRequest) async throws -> RuntimeAttachmentStageBundle {
        try Task.checkCancellation()
        guard request.revision > 0,
              request.expectedByteCount > 0,
              request.expectedByteCount <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              RuntimeAttachmentCodec.validFilename(request.normalizedFilename),
              RuntimeAttachmentCodec.validContentType(request.declaredContentType),
              RuntimeAttachmentCodec.validContentType(request.detectedContentType),
              let privacyDomain = RuntimeAttachmentPrivacyDomain(request.privacy) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try RuntimeAttachmentCodec.validate(request.provenance)
        try RuntimeAttachmentCodec.validateIntakeProof(
            request.intakeProof, request: request, key: intakeProofKey
        )
        let source = try validatedRegularFile(
            request.ownedPlaintextURL,
            expectedDevice: request.intakeProof.device,
            expectedInode: request.intakeProof.inode
        )
        guard source.byteCount == request.expectedByteCount,
              source.byteCount == request.intakeProof.byteCount else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try ensureRoot()

        let plaintextDigest = try digestFile(
            request.ownedPlaintextURL,
            expectedIdentity: source,
            maximumBytes: request.expectedByteCount
        )
        guard RuntimeAttachmentCodec.sha256DigestHex(plaintextDigest) ==
                request.intakeProof.plaintextDigest else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        let addressKey = try await keyCustody.contentAddressKey()
        let contentAddress = RuntimeAttachmentCodec.keyedContentAddress(
            privacyDomain: privacyDomain,
            policy: request.dedupPolicy,
            plaintextDigest: plaintextDigest,
            blobID: request.blobID,
            key: addressKey
        )
        let dataKey = try await keyCustody.makeDataEncryptionKey()
        let envelope = try await keyCustody.wrap(dataKey, for: request.blobID)
        let opaqueDirectory = try opaqueDirectory(for: request.blobID)
        let temporary = rootDirectory.appendingPathComponent(".staging-\(try validatedOpaqueToken())", isDirectory: true)
        try createExclusiveOwnedDirectory(temporary)
        var removeTemporary = true
        defer { if removeTemporary { try? fileManager.removeItem(at: temporary) } }

        let header = Header(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: request.blobID,
            privacyDomain: privacyDomain,
            dedupPolicy: request.dedupPolicy,
            keyedContentAddress: contentAddress,
            chunkSize: chunkSize,
            plaintextByteCount: request.expectedByteCount,
            protectionClass: .complete
        )
        let headerBytes = try RuntimeAttachmentCodec.encode(
            header, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let headerDigest = RuntimeAttachmentCodec.sha256(headerBytes)
        let payloadURL = temporary.appendingPathComponent("payload.aead", isDirectory: false)
        let encryption = try encrypt(
            sourceURL: request.ownedPlaintextURL,
            destinationURL: payloadURL,
            expectedIdentity: source,
            expectedBytes: request.expectedByteCount,
            headerBytes: headerBytes,
            headerDigest: headerDigest,
            blobID: request.blobID,
            expectedPlaintextDigest: plaintextDigest,
            key: dataKey
        )
        let provisional = RuntimeBlobManifestAuthority(
            formatVersion: runtimeCanonicalAttachmentModelVersion,
            blobID: request.blobID,
            privacyDomain: privacyDomain,
            dedupPolicy: request.dedupPolicy,
            keyedContentAddress: contentAddress,
            encryptionAlgorithm: "AES.GCM.chunked.v1",
            chunkSize: chunkSize,
            chunkCount: encryption.chunkCount,
            plaintextByteCount: request.expectedByteCount,
            ciphertextByteCount: encryption.ciphertextBytes,
            headerDigest: headerDigest,
            terminalDigest: encryption.terminalDigest,
            protectionClass: .complete,
            opaqueRelativeDirectory: opaqueDirectory,
            createdAt: request.createdAt
        )
        try RuntimeAttachmentCodec.validate(provisional)
        let manifestBytes = try RuntimeAttachmentCodec.encode(
            provisional, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let manifestDigest = RuntimeAttachmentCodec.sha256(manifestBytes)
        let manifestURL = temporary.appendingPathComponent("manifest.json", isDirectory: false)
        try atomicProtectedWrite(manifestBytes, to: manifestURL)
        try verifyProtection(payloadURL)
        try verifyProtection(manifestURL)
        try synchronizeDirectory(temporary)

        let destination = try ownedURL(relativeDirectory: opaqueDirectory)
        try createAndVerifyOwnedHierarchy(destination.deletingLastPathComponent())
        try fileManager.moveItem(at: temporary, to: destination)
        try synchronizeDirectory(rootDirectory)
        try synchronizeDirectory(destination.deletingLastPathComponent())
        removeTemporary = false
        try verifyOwnedDirectory(destination, expectedRelative: opaqueDirectory)
        try verifyProtection(destination)
        try verifyProtection(destination.appendingPathComponent("payload.aead", isDirectory: false))
        try verifyProtection(destination.appendingPathComponent("manifest.json", isDirectory: false))

        let revision = RuntimeAttachmentRevision(
            version: runtimeCanonicalAttachmentModelVersion,
            revisionID: request.revisionID,
            attachmentID: request.attachmentID,
            revision: request.revision,
            blobID: request.blobID,
            manifestDigest: manifestDigest,
            classification: RuntimeAttachmentContentClassification(
                normalizedFilename: request.normalizedFilename,
                declaredContentType: request.declaredContentType,
                detectedContentType: request.detectedContentType,
                signatureVersion: 1,
                byteCount: request.expectedByteCount
            ),
            privacy: request.privacy,
            provenance: request.provenance,
            createdAt: request.createdAt
        )
        let lifecycle = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: request.blobID,
            state: .staged,
            stateVersion: 1,
            referenceCount: 0,
            manifestDigest: manifestDigest,
            retentionUntil: request.retentionUntil,
            quarantineReasonCode: nil,
            updatedAt: request.createdAt
        )
        return RuntimeAttachmentStageBundle(
            revision: revision, manifest: provisional, envelope: envelope, lifecycle: lifecycle
        )
    }

    func readPage(
        graph: RuntimeAttachmentAuthorityGraph,
        cursor: RuntimeAttachmentReadCursor? = nil
    ) async throws -> RuntimeAttachmentReadPage {
        try await readPage(
            snapshot: RuntimeAttachmentAuthoritySnapshot(
                revision: graph.revision, manifest: graph.manifest,
                envelope: graph.envelope, lifecycle: graph.lifecycle,
                tombstone: graph.tombstone
            ),
            cursor: cursor
        )
    }

    func readPage(
        snapshot: RuntimeAttachmentAuthoritySnapshot,
        cursor: RuntimeAttachmentReadCursor? = nil
    ) async throws -> RuntimeAttachmentReadPage {
        let graph = snapshot
        try Task.checkCancellation()
        guard graph.tombstone == nil,
              graph.lifecycle.state != .quarantined,
              graph.lifecycle.state != .deletionPending else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        try RuntimeAttachmentCodec.validate(graph.manifest)
        let directory = try ownedURL(relativeDirectory: graph.manifest.opaqueRelativeDirectory)
        try verifyOwnedDirectory(directory, expectedRelative: graph.manifest.opaqueRelativeDirectory)
        try verifyProtection(directory)
        let manifestURL = directory.appendingPathComponent("manifest.json", isDirectory: false)
        let payloadURL = directory.appendingPathComponent("payload.aead", isDirectory: false)
        try verifyProtection(manifestURL)
        let openedPayload = try openRegularFile(
            payloadURL, maximumBytes: graph.manifest.ciphertextByteCount
        )
        try verifyProtection(payloadURL, expectedAuthority: openedPayload.authority)
        let handle = openedPayload.handle
        defer { try? handle.close() }
        guard openedPayload.authority.byteCount == graph.manifest.ciphertextByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let headerLength = try readUInt32(handle)
        guard headerLength > 0, headerLength <= RuntimeAttachmentLimits.maximumManifestBytes,
              let headerBytes = try handle.read(upToCount: headerLength), headerBytes.count == headerLength,
              RuntimeAttachmentCodec.sha256(headerBytes) == graph.manifest.headerDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let header = try RuntimeAttachmentCodec.decode(
            Header.self, bytes: headerBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard header.version == graph.manifest.formatVersion,
              header.blobID == graph.manifest.blobID,
              header.privacyDomain == graph.manifest.privacyDomain,
              header.dedupPolicy == graph.manifest.dedupPolicy,
              header.keyedContentAddress == graph.manifest.keyedContentAddress,
              header.chunkSize == graph.manifest.chunkSize,
              header.plaintextByteCount == graph.manifest.plaintextByteCount,
              header.protectionClass == graph.manifest.protectionClass else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let start = cursor?.nextChunkIndex ?? 0
        guard cursor?.blobID == nil || cursor?.blobID == graph.manifest.blobID,
              start >= 0, start < graph.manifest.chunkCount,
              cursor?.plaintextBytesRead == nil ||
                cursor?.plaintextBytesRead == Int64(start * graph.manifest.chunkSize) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        for _ in 0..<start {
            let size = try readUInt32(handle)
            guard size > 0, size <= RuntimeAttachmentLimits.maximumChunkBytes + 64 else {
                throw RuntimeCanonicalAttachmentError.manifestInvalid
            }
            try handle.seek(toOffset: try handle.offset() + UInt64(size))
        }
        let encryptedSize = try readUInt32(handle)
        guard encryptedSize > 0, encryptedSize <= RuntimeAttachmentLimits.maximumChunkBytes + 64,
              let encrypted = try handle.read(upToCount: encryptedSize), encrypted.count == encryptedSize else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let key = try await keyCustody.unwrap(graph.envelope)
        let plaintext: Data
        do {
            plaintext = try AES.GCM.open(
                AES.GCM.SealedBox(combined: encrypted), using: key,
                authenticating: chunkAAD(
                    blobID: graph.manifest.blobID,
                    headerDigest: graph.manifest.headerDigest,
                    index: start
                )
            )
        } catch {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let priorBytes = cursor?.plaintextBytesRead ?? Int64(start * graph.manifest.chunkSize)
        let total = priorBytes + Int64(plaintext.count)
        guard total <= graph.manifest.plaintextByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let next: RuntimeAttachmentReadCursor? = start + 1 == graph.manifest.chunkCount
            ? nil
            : RuntimeAttachmentReadCursor(
                blobID: graph.manifest.blobID,
                nextChunkIndex: start + 1,
                plaintextBytesRead: total
            )
        if next == nil {
            guard total == graph.manifest.plaintextByteCount else {
                throw RuntimeCanonicalAttachmentError.manifestInvalid
            }
            try verifyTerminal(
                handle: handle,
                expectedAuthority: openedPayload.authority,
                manifest: graph.manifest,
                key: key
            )
        }
        guard try fileAuthority(for: handle.fileDescriptor) == openedPayload.authority else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requirePathIdentity(payloadURL, authority: openedPayload.authority)
        try verifyProtection(payloadURL, expectedAuthority: openedPayload.authority)
        return RuntimeAttachmentReadPage(bytes: plaintext, nextCursor: next)
    }

    func verifyAuthenticatedBlob(_ graph: RuntimeAttachmentAuthorityGraph) async throws {
        try await verifyAuthenticatedBlob(RuntimeAttachmentAuthoritySnapshot(
            revision: graph.revision, manifest: graph.manifest,
            envelope: graph.envelope, lifecycle: graph.lifecycle,
            tombstone: graph.tombstone
        ))
    }

    func verifyAuthenticatedBlob(_ snapshot: RuntimeAttachmentAuthoritySnapshot) async throws {
        var cursor: RuntimeAttachmentReadCursor?
        repeat {
            try Task.checkCancellation()
            let page = try await readPage(snapshot: snapshot, cursor: cursor)
            cursor = page.nextCursor
        } while cursor != nil
    }

    func writeFinalizationMarker(
        manifest: RuntimeBlobManifestAuthority,
        manifestDigest: String,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        finalizedAt: Date
    ) throws -> RuntimeAttachmentFinalizationProof {
        guard finalizedAt >= manifest.createdAt else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let requestedMarker = RuntimeAttachmentFinalizationMarker(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: manifest.blobID,
            manifestDigest: manifestDigest,
            receiptID: receiptID,
            terminalEventSequence: lineage.eventSequence,
            finalizedAt: finalizedAt
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            requestedMarker, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let directory = try ownedURL(relativeDirectory: manifest.opaqueRelativeDirectory)
        try verifyOwnedDirectory(directory, expectedRelative: manifest.opaqueRelativeDirectory)
        let markerURL = directory.appendingPathComponent("finalized.json")
        let durableMarker: RuntimeAttachmentFinalizationMarker
        let durableBytes: Data
        if try pathEntryExistsNoFollow(markerURL) {
            let existing = try openRegularFile(
                markerURL, maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
            )
            defer { try? existing.handle.close() }
            let existingBytes = try readExactlyBounded(
                existing.handle, expectedBytes: existing.authority.byteCount,
                maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
            )
            try verifyProtection(markerURL, expectedAuthority: existing.authority)
            let decoded = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentFinalizationMarker.self,
                bytes: existingBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard decoded.version == requestedMarker.version,
                  decoded.blobID == requestedMarker.blobID,
                  decoded.manifestDigest == requestedMarker.manifestDigest,
                  decoded.receiptID == requestedMarker.receiptID,
                  decoded.terminalEventSequence == requestedMarker.terminalEventSequence,
                  decoded.finalizedAt >= manifest.createdAt,
                  decoded.finalizedAt <= finalizedAt else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            durableMarker = decoded
            durableBytes = existingBytes
        } else {
            try atomicProtectedWrite(bytes, to: markerURL)
            durableMarker = requestedMarker
            durableBytes = bytes
        }
        let opened = try openRegularFile(
            markerURL,
            maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        defer { try? opened.handle.close() }
        let reread = try readExactlyBounded(
            opened.handle, expectedBytes: opened.authority.byteCount,
            maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        try verifyProtection(markerURL, expectedAuthority: opened.authority)
        guard reread == durableBytes else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return try finalizationProof(
            marker: durableMarker,
            markerDigest: RuntimeAttachmentCodec.sha256(reread)
        )
    }

    private func finalizationProof(
        marker: RuntimeAttachmentFinalizationMarker,
        markerDigest: String
    ) throws -> RuntimeAttachmentFinalizationProof {
        let unsigned = RuntimeAttachmentFinalizationProof(
            blobID: marker.blobID, manifestDigest: marker.manifestDigest,
            receiptID: marker.receiptID, terminalEventSequence: marker.terminalEventSequence,
            markerDigest: markerDigest, finalizedAt: marker.finalizedAt,
            proofDigest: String(repeating: "0", count: 64)
        )
        return RuntimeAttachmentFinalizationProof(
            blobID: unsigned.blobID, manifestDigest: unsigned.manifestDigest,
            receiptID: unsigned.receiptID,
            terminalEventSequence: unsigned.terminalEventSequence,
            markerDigest: unsigned.markerDigest, finalizedAt: unsigned.finalizedAt,
            proofDigest: try RuntimeAttachmentCodec.finalizationProofDigest(unsigned)
        )
    }

    func prepareLeaseOwnedDeletion(
        _ work: RuntimeBlobGCWork,
        lease: RuntimeBlobGCLease,
        now: Date
    ) throws -> RuntimeAttachmentVaultDeletionClaim {
        let manifest = work.manifest
        let manifestDigest = try RuntimeAttachmentCodec.digest(
            manifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard work.manifestDigest == manifestDigest,
              lease.blobID == manifest.blobID,
              lease.expectedStateVersion == work.lifecycle.stateVersion,
              lease.acquiredAt <= now,
              now < lease.expiresAt else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let leaseToken = try RuntimeAttachmentCodec.gcLeaseToken(lease)
        let original = try ownedURL(relativeDirectory: manifest.opaqueRelativeDirectory)
        let quarantine = try deletionQuarantineURL(
            originalRelativeDirectory: manifest.opaqueRelativeDirectory,
            namespace: "gc",
            token: RuntimeAttachmentCodec.sha256(Data(
                "\(manifest.blobID.rawValue)\u{0}\(manifestDigest)".utf8
            ))
        )
        let originalExists = try pathEntryExistsNoFollow(original)
        let quarantineExists = try pathEntryExistsNoFollow(quarantine.url)
        guard originalExists == false || quarantineExists == false else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let disposition: RuntimeAttachmentPhysicalDeletionDisposition
        let authority: DirectoryAuthority?
        if originalExists {
            try verifyOwnedDirectory(original, expectedRelative: manifest.opaqueRelativeDirectory)
            try verifyDeletionDirectory(original, manifest: manifest, manifestDigest: manifestDigest)
            let ownedAuthority = try directoryAuthority(original)
            guard Darwin.rename(original.path, quarantine.url.path) == 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeDirectory(quarantine.url.deletingLastPathComponent())
            guard try pathEntryExistsNoFollow(original) == false,
                  try directoryAuthority(quarantine.url).device == ownedAuthority.device,
                  try directoryAuthority(quarantine.url).inode == ownedAuthority.inode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            disposition = .removedOwnedDirectory
            authority = ownedAuthority
        } else if quarantineExists {
            disposition = .removedOwnedDirectory
            authority = try directoryAuthority(quarantine.url)
            try verifyDeletionDirectory(
                quarantine.url, manifest: manifest, manifestDigest: manifestDigest
            )
        } else {
            try synchronizeDirectory(quarantine.url.deletingLastPathComponent())
            guard try pathEntryExistsNoFollow(original) == false,
                  try pathEntryExistsNoFollow(quarantine.url) == false else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            disposition = .confirmedAlreadyAbsent
            authority = nil
        }
        let claimDigest = try RuntimeAttachmentCodec.gcDeletionClaimDigest(
            manifestDigest: manifestDigest,
            lease: lease,
            originalRelativeDirectory: manifest.opaqueRelativeDirectory,
            quarantineRelativeDirectory: quarantine.relative,
            disposition: disposition,
            directoryDevice: authority?.device,
            directoryInode: authority?.inode,
            preparedAt: now
        )
        return RuntimeAttachmentVaultDeletionClaim(
            manifest: manifest,
            manifestDigest: manifestDigest,
            lease: lease,
            leaseToken: leaseToken,
            originalRelativeDirectory: manifest.opaqueRelativeDirectory,
            quarantineRelativeDirectory: quarantine.relative,
            disposition: disposition,
            directoryDevice: authority?.device,
            directoryInode: authority?.inode,
            preparedAt: now,
            claimDigest: claimDigest
        )
    }

    func finalizeLeaseOwnedDeletion(
        _ claim: RuntimeAttachmentVaultDeletionClaim,
        now: @Sendable () -> Date
    ) throws -> RuntimeAttachmentPhysicalDeletionProof {
        let startedAt = now()
        guard claim.leaseToken == (try RuntimeAttachmentCodec.gcLeaseToken(claim.lease)),
              claim.claimDigest == (try RuntimeAttachmentCodec.gcDeletionClaimDigest(
                  manifestDigest: claim.manifestDigest,
                  lease: claim.lease,
                  originalRelativeDirectory: claim.originalRelativeDirectory,
                  quarantineRelativeDirectory: claim.quarantineRelativeDirectory,
                  disposition: claim.disposition,
                  directoryDevice: claim.directoryDevice,
                  directoryInode: claim.directoryInode,
                  preparedAt: claim.preparedAt
              )),
              claim.preparedAt <= startedAt,
              startedAt < claim.lease.expiresAt else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        switch claim.disposition {
        case .removedOwnedDirectory:
            guard let directoryDevice = claim.directoryDevice,
                  let directoryInode = claim.directoryInode,
                  directoryDevice > 0, directoryInode > 0 else {
                throw RuntimeCanonicalAttachmentError.invalidLease
            }
        case .confirmedAlreadyAbsent:
            guard claim.directoryDevice == nil, claim.directoryInode == nil else {
                throw RuntimeCanonicalAttachmentError.invalidLease
            }
        }
        let quarantine = try deletionQuarantineURL(
            relativeDirectory: claim.quarantineRelativeDirectory
        )
        if try pathEntryExistsNoFollow(quarantine) {
            guard claim.disposition == .removedOwnedDirectory,
                  let expectedDevice = claim.directoryDevice,
                  let expectedInode = claim.directoryInode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            let authority = try directoryAuthority(quarantine)
            guard authority.device == expectedDevice,
                  authority.inode == expectedInode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            try verifyDeletionDirectory(
                quarantine, manifest: claim.manifest, manifestDigest: claim.manifestDigest
            )
            try fileManager.removeItem(at: quarantine)
        }
        try synchronizeDirectory(quarantine.deletingLastPathComponent())
        let original = try ownedURL(relativeDirectory: claim.originalRelativeDirectory)
        guard try pathEntryExistsNoFollow(quarantine) == false,
              try pathEntryExistsNoFollow(original) == false else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let deletedAt = now()
        guard deletedAt >= startedAt, deletedAt < claim.lease.expiresAt else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let unsigned = RuntimeAttachmentPhysicalDeletionProof(
            blobID: claim.manifest.blobID,
            manifestDigest: claim.manifestDigest,
            leaseID: claim.lease.leaseID,
            expectedStateVersion: claim.lease.expectedStateVersion,
            disposition: claim.disposition,
            directoryDevice: claim.directoryDevice,
            directoryInode: claim.directoryInode,
            deletedAt: deletedAt,
            proofDigest: String(repeating: "0", count: 64)
        )
        return RuntimeAttachmentPhysicalDeletionProof(
            blobID: unsigned.blobID,
            manifestDigest: unsigned.manifestDigest,
            leaseID: unsigned.leaseID,
            expectedStateVersion: unsigned.expectedStateVersion,
            disposition: unsigned.disposition,
            directoryDevice: unsigned.directoryDevice,
            directoryInode: unsigned.directoryInode,
            deletedAt: unsigned.deletedAt,
            proofDigest: try RuntimeAttachmentCodec.physicalDeletionProofDigest(unsigned)
        )
    }

    func prepareUnownedManifestDeletion(
        _ inspection: RuntimeOwnedAttachmentManifestInspection,
        claim: RuntimeAttachmentManifestDeletionClaim,
        now: Date
    ) throws -> RuntimeAttachmentVaultManifestDeletionClaim {
        guard claim.blobID == inspection.manifest.blobID,
              claim.manifestDigest == inspection.manifestDigest,
              claim.opaqueRelativeDirectory == inspection.manifest.opaqueRelativeDirectory,
              claim.observedDevice == inspection.directoryDevice,
              claim.observedInode == inspection.directoryInode,
              claim.claimedAt <= now,
              now < claim.expiresAt else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return try prepareUnownedManifestDeletion(claim, now: now, requiresOriginal: true)
    }

    func resumeUnownedManifestDeletion(
        _ claim: RuntimeAttachmentManifestDeletionClaim,
        now: Date
    ) throws -> RuntimeAttachmentVaultManifestDeletionClaim? {
        let original = try ownedURL(relativeDirectory: claim.opaqueRelativeDirectory)
        return try prepareUnownedManifestDeletion(
            claim,
            now: now,
            requiresOriginal: try pathEntryExistsNoFollow(original)
        )
    }

    func finalizeUnownedManifestDeletion(
        _ vaultClaim: RuntimeAttachmentVaultManifestDeletionClaim,
        now: @Sendable () -> Date
    ) throws -> RuntimeAttachmentManifestDeletionProof {
        let claim = vaultClaim.claim
        let startedAt = now()
        guard claim.claimedAt <= startedAt,
              startedAt < claim.expiresAt,
              vaultClaim.claimDigest == (try RuntimeAttachmentCodec.manifestDeletionVaultClaimDigest(
                  claim,
                  quarantineRelativeDirectory: vaultClaim.quarantineRelativeDirectory,
                  quarantineDevice: vaultClaim.quarantineDevice,
                  quarantineInode: vaultClaim.quarantineInode,
                  preparedAt: vaultClaim.preparedAt
              )) else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let quarantine = try deletionQuarantineURL(
            relativeDirectory: vaultClaim.quarantineRelativeDirectory
        )
        if try pathEntryExistsNoFollow(quarantine) {
            let authority = try directoryAuthority(quarantine)
            guard authority.device == vaultClaim.quarantineDevice,
                  authority.inode == vaultClaim.quarantineInode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            try verifyDeletionDirectory(
                quarantine,
                expectedBlobID: claim.blobID,
                manifestDigest: claim.manifestDigest
            )
            try fileManager.removeItem(at: quarantine)
        }
        try synchronizeDirectory(quarantine.deletingLastPathComponent())
        let original = try ownedURL(relativeDirectory: claim.opaqueRelativeDirectory)
        guard try pathEntryExistsNoFollow(quarantine) == false,
              try pathEntryExistsNoFollow(original) == false else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let deletedAt = now()
        guard deletedAt >= startedAt, deletedAt < claim.expiresAt else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let proofDigest = try RuntimeAttachmentCodec.manifestDeletionProofDigest(
            claimID: claim.claimID,
            blobID: claim.blobID,
            manifestDigest: claim.manifestDigest,
            originalRelativeDirectory: claim.opaqueRelativeDirectory,
            quarantineRelativeDirectory: vaultClaim.quarantineRelativeDirectory,
            directoryDevice: vaultClaim.quarantineDevice,
            directoryInode: vaultClaim.quarantineInode,
            deletedAt: deletedAt
        )
        return RuntimeAttachmentManifestDeletionProof(
            claimID: claim.claimID,
            blobID: claim.blobID,
            manifestDigest: claim.manifestDigest,
            originalRelativeDirectory: claim.opaqueRelativeDirectory,
            quarantineRelativeDirectory: vaultClaim.quarantineRelativeDirectory,
            directoryDevice: vaultClaim.quarantineDevice,
            directoryInode: vaultClaim.quarantineInode,
            deletedAt: deletedAt,
            proofDigest: proofDigest
        )
    }

    func ownedBlobExists(_ manifest: RuntimeBlobManifestAuthority) throws -> Bool {
        let directory = try ownedURL(relativeDirectory: manifest.opaqueRelativeDirectory)
        guard try pathEntryExistsNoFollow(directory) else { return false }
        try verifyOwnedDirectory(directory, expectedRelative: manifest.opaqueRelativeDirectory)
        let payload = directory.appendingPathComponent("payload.aead", isDirectory: false)
        let manifestURL = directory.appendingPathComponent("manifest.json", isDirectory: false)
        guard try pathEntryExistsNoFollow(payload), try pathEntryExistsNoFollow(manifestURL) else {
            return false
        }
        let openedPayload = try openRegularFile(payload, maximumBytes: manifest.ciphertextByteCount)
        let openedManifest = try openRegularFile(
            manifestURL, maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        try? openedPayload.handle.close()
        try? openedManifest.handle.close()
        try verifyProtection(directory)
        try verifyProtection(payload)
        try verifyProtection(manifestURL)
        return true
    }

    func ownedManifestDirectories(
        limit: Int,
        afterCursorKey: String? = nil
    ) throws -> RuntimeAttachmentFilesystemPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let versionRoot = rootDirectory.appendingPathComponent("v1", isDirectory: true)
        guard try pathEntryExistsNoFollow(versionRoot) else {
            return RuntimeAttachmentFilesystemPage(
                entries: [], nextCursorKey: nil, exhausted: true
            )
        }
        try verifyDirectoryEntryNoFollow(versionRoot, parent: rootDirectory)
        var phase = "0m"
        var shardIndex = 0
        var rawCursor: String?
        if let afterCursorKey {
            let fields = afterCursorKey.split(separator: ":", omittingEmptySubsequences: false)
            guard let first = fields.first else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
            phase = String(first)
            if phase == "0m" {
                guard fields.count == 3, let parsed = Int(fields[1]), (0...256).contains(parsed) else {
                    throw RuntimeCanonicalAttachmentError.invalidRecord
                }
                shardIndex = parsed
                rawCursor = fields[2].isEmpty ? nil : String(fields[2])
            } else if phase == "1f" {
                guard fields.count == 2 else {
                    throw RuntimeCanonicalAttachmentError.invalidRecord
                }
                rawCursor = fields[1].isEmpty ? nil : String(fields[1])
            } else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        }
        var discovered: [RuntimeAttachmentFilesystemEntry] = []
        if phase == "0m" {
            while shardIndex < 256 {
                let shardName = String(format: "%02x", shardIndex)
                let shard = versionRoot.appendingPathComponent(shardName, isDirectory: true)
                guard try pathEntryExistsNoFollow(shard) else {
                    shardIndex += 1
                    rawCursor = nil
                    continue
                }
                do {
                    try verifyDirectoryEntryNoFollow(shard, parent: versionRoot)
                } catch let error as RuntimeCanonicalAttachmentError {
                    discovered.append(malformedFilesystemEntry(
                        cursorKey: "0m:\(String(format: "%03d", shardIndex)):shard",
                        rawName: Data(shardName.utf8), parentScope: "v1", error: error
                    ))
                    shardIndex += 1
                    rawCursor = nil
                    if discovered.count == limit {
                        return RuntimeAttachmentFilesystemPage(
                            entries: discovered,
                            nextCursorKey: "0m:\(String(format: "%03d", shardIndex)):",
                            exhausted: false
                        )
                    }
                    continue
                }
                let remaining = max(1, limit - discovered.count)
                let candidatePage = try rawDirectoryEntries(
                    at: shard, limit: remaining, afterRawCursor: rawCursor
                )
                for candidateEntry in candidatePage.entries {
                    let cursorKey = "0m:\(String(format: "%03d", shardIndex)):\(candidateEntry.cursorComponent)"
                    guard let candidateName = candidateEntry.decoded else {
                        discovered.append(malformedFilesystemEntry(
                            cursorKey: cursorKey, rawName: candidateEntry.rawBytes,
                            parentScope: "v1/\(shardName)", error: .pathAuthorityDenied
                        ))
                        continue
                    }
                    if candidateName.hasPrefix(".deletion-") { continue }
                    let relative = "v1/\(shardName)/\(candidateName)"
                    let candidate = shard.appendingPathComponent(candidateName, isDirectory: true)
                    do {
                        guard RuntimeAttachmentCodec.validOpaqueDirectory(relative) else {
                            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
                        }
                        try verifyDirectoryEntryNoFollow(candidate, parent: shard)
                        try verifyOwnedDirectory(candidate, expectedRelative: relative)
                        discovered.append(.owned(cursorKey: cursorKey, url: candidate))
                    } catch let error as RuntimeCanonicalAttachmentError {
                        discovered.append(malformedFilesystemEntry(
                            cursorKey: cursorKey, rawName: candidateEntry.rawBytes,
                            parentScope: "v1/\(shardName)", error: error
                        ))
                    }
                }
                if candidatePage.exhausted == false {
                    return RuntimeAttachmentFilesystemPage(
                        entries: discovered,
                        nextCursorKey: candidatePage.nextRawCursor.map {
                            "0m:\(String(format: "%03d", shardIndex)):\($0)"
                        },
                        exhausted: false
                    )
                }
                shardIndex += 1
                rawCursor = nil
                if discovered.count >= limit {
                    return RuntimeAttachmentFilesystemPage(
                        entries: discovered,
                        nextCursorKey: "0m:\(String(format: "%03d", shardIndex)):",
                        exhausted: false
                    )
                }
            }
            phase = "1f"
            rawCursor = nil
        }
        let foreignPage = try rawDirectoryEntries(
            at: versionRoot,
            limit: max(1, limit - discovered.count),
            afterRawCursor: rawCursor
        )
        for entry in foreignPage.entries {
            let isCanonicalShard = entry.decoded.map { name in
                name.utf8.count == 2 && name.allSatisfy {
                    $0.isHexDigit && $0.isUppercase == false
                }
            } ?? false
            guard isCanonicalShard == false else { continue }
            discovered.append(malformedFilesystemEntry(
                cursorKey: "1f:\(entry.cursorComponent)", rawName: entry.rawBytes,
                parentScope: "v1", error: .pathAuthorityDenied
            ))
        }
        return RuntimeAttachmentFilesystemPage(
            entries: discovered,
            nextCursorKey: foreignPage.nextRawCursor.map { "1f:\($0)" },
            exhausted: foreignPage.exhausted
        )
    }

    func inspectOwnedManifestDirectory(_ directory: URL) throws -> RuntimeOwnedAttachmentManifestInspection {
        let standardized = directory.standardizedFileURL
        guard standardized.path.hasPrefix(rootDirectory.path + "/") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let relative = String(standardized.path.dropFirst(rootDirectory.path.count + 1))
        try verifyOwnedDirectory(standardized, expectedRelative: relative)
        let manifestURL = standardized.appendingPathComponent("manifest.json", isDirectory: false)
        try verifyProtection(standardized)
        try verifyProtection(manifestURL)
        let opened = try openRegularFile(
            manifestURL, maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        defer { try? opened.handle.close() }
        let bytes = try readExactlyBounded(
            opened.handle, expectedBytes: opened.authority.byteCount,
            maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try RuntimeAttachmentCodec.validate(manifest)
        guard manifest.opaqueRelativeDirectory == relative else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let authority = try directoryAuthority(directory)
        return RuntimeOwnedAttachmentManifestInspection(
            manifest: manifest,
            manifestDigest: RuntimeAttachmentCodec.sha256(bytes),
            directoryDevice: authority.device,
            directoryInode: authority.inode
        )
    }

    func inspectOwnedManifest(
        _ expectedManifest: RuntimeBlobManifestAuthority
    ) throws -> RuntimeOwnedAttachmentManifestInspection {
        let directory = try ownedURL(
            relativeDirectory: expectedManifest.opaqueRelativeDirectory
        )
        let inspection = try inspectOwnedManifestDirectory(directory)
        let expectedDigest = try RuntimeAttachmentCodec.digest(
            expectedManifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard inspection.manifest == expectedManifest,
              inspection.manifestDigest == expectedDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return inspection
    }

    func ownedTemporaryDirectories(
        limit: Int,
        afterCursorKey: String? = nil
    ) throws -> RuntimeAttachmentFilesystemPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try ensureRoot()
        let rawCursor: String?
        if let afterCursorKey {
            guard afterCursorKey.hasPrefix("r:") else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
            rawCursor = String(afterCursorKey.dropFirst(2))
        } else {
            rawCursor = nil
        }
        let rawPage = try rawDirectoryEntries(
            at: rootDirectory,
            limit: limit,
            afterRawCursor: rawCursor
        )
        var discovered: [RuntimeAttachmentFilesystemEntry] = []
        for entry in rawPage.entries {
            guard entry.decoded?.hasPrefix(".staging-") == true ||
                    entry.rawBytes.starts(with: Data(".staging-".utf8)) else { continue }
            let cursorKey = "r:\(entry.cursorComponent)"
            guard let name = entry.decoded else {
                discovered.append(malformedFilesystemEntry(
                    cursorKey: cursorKey, rawName: entry.rawBytes,
                    parentScope: "vault-root", error: .pathAuthorityDenied
                ))
                continue
            }
            let candidate = rootDirectory.appendingPathComponent(name, isDirectory: true)
            do {
                try validateStagingDirectoryName(name)
                try verifyDirectoryEntryNoFollow(candidate, parent: rootDirectory)
                discovered.append(.owned(cursorKey: cursorKey, url: candidate))
            } catch let error as RuntimeCanonicalAttachmentError {
                discovered.append(malformedFilesystemEntry(
                    cursorKey: cursorKey, rawName: entry.rawBytes,
                    parentScope: "vault-root", error: error
                ))
            }
        }
        return RuntimeAttachmentFilesystemPage(
            entries: discovered,
            nextCursorKey: rawPage.nextRawCursor.map { "r:\($0)" },
            exhausted: rawPage.exhausted
        )
    }

    func removeOwnedTemporaryDirectory(_ directory: URL) throws {
        let standardized = directory.standardizedFileURL
        guard standardized.deletingLastPathComponent() == rootDirectory,
              standardized.lastPathComponent.hasPrefix(".staging-") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        try validateStagingDirectoryName(standardized.lastPathComponent)
        let allowed = Set(["payload.aead", "manifest.json"])
        try verifyDirectoryEntryNoFollow(standardized, parent: rootDirectory)
        try validateBoundedAllowlistedChildren(
            of: standardized, allowedNames: allowed, maximumChildCount: allowed.count
        )
        try fileManager.removeItem(at: standardized)
        try synchronizeDirectory(rootDirectory)
    }
}

private extension RuntimeAttachmentVault {
    struct RawDirectoryEntry {
        let rawBytes: Data
        let decoded: String?

        var cursorComponent: String {
            rawBytes.map { String(format: "%02x", $0) }.joined()
        }
    }

    struct RawDirectoryPage {
        let entries: [RawDirectoryEntry]
        let nextRawCursor: String?
        let exhausted: Bool
    }

    struct DirectoryAuthority {
        let device: UInt64
        let inode: UInt64
    }

    func prepareUnownedManifestDeletion(
        _ claim: RuntimeAttachmentManifestDeletionClaim,
        now: Date,
        requiresOriginal: Bool
    ) throws -> RuntimeAttachmentVaultManifestDeletionClaim {
        guard RuntimeStoreManifestCodec.isSHA256Hex(claim.claimID),
              RuntimeStoreManifestCodec.isSHA256Hex(claim.manifestDigest),
              claim.claimedAt <= now,
              now < claim.expiresAt else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let original = try ownedURL(relativeDirectory: claim.opaqueRelativeDirectory)
        let quarantine = try deletionQuarantineURL(
            originalRelativeDirectory: claim.opaqueRelativeDirectory,
            namespace: "manifest",
            token: claim.claimID
        )
        let originalExists = try pathEntryExistsNoFollow(original)
        let quarantineExists = try pathEntryExistsNoFollow(quarantine.url)
        if requiresOriginal {
            guard originalExists, quarantineExists == false else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        } else {
            guard originalExists == false else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        }
        let authority: DirectoryAuthority
        if originalExists {
            authority = try directoryAuthority(original)
            guard authority.device == claim.observedDevice,
                  authority.inode == claim.observedInode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            try verifyDeletionDirectory(
                original,
                expectedBlobID: claim.blobID,
                manifestDigest: claim.manifestDigest
            )
            guard Darwin.rename(original.path, quarantine.url.path) == 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeDirectory(quarantine.url.deletingLastPathComponent())
        } else if quarantineExists {
            authority = try directoryAuthority(quarantine.url)
        } else {
            try synchronizeDirectory(quarantine.url.deletingLastPathComponent())
            guard try pathEntryExistsNoFollow(original) == false,
                  try pathEntryExistsNoFollow(quarantine.url) == false else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            authority = DirectoryAuthority(
                device: claim.observedDevice, inode: claim.observedInode
            )
        }
        let quarantinedAuthority = quarantineExists || originalExists
            ? try directoryAuthority(quarantine.url)
            : authority
        guard quarantinedAuthority.device == authority.device,
              quarantinedAuthority.inode == authority.inode,
              quarantinedAuthority.device == claim.observedDevice,
              quarantinedAuthority.inode == claim.observedInode,
              try pathEntryExistsNoFollow(original) == false else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        if try pathEntryExistsNoFollow(quarantine.url) {
            try verifyDeletionDirectory(
                quarantine.url,
                expectedBlobID: claim.blobID,
                manifestDigest: claim.manifestDigest
            )
        }
        let digest = try RuntimeAttachmentCodec.manifestDeletionVaultClaimDigest(
            claim,
            quarantineRelativeDirectory: quarantine.relative,
            quarantineDevice: quarantinedAuthority.device,
            quarantineInode: quarantinedAuthority.inode,
            preparedAt: now
        )
        return RuntimeAttachmentVaultManifestDeletionClaim(
            claim: claim,
            quarantineRelativeDirectory: quarantine.relative,
            quarantineDevice: quarantinedAuthority.device,
            quarantineInode: quarantinedAuthority.inode,
            preparedAt: now,
            claimDigest: digest
        )
    }

    func deletionQuarantineURL(
        originalRelativeDirectory: String,
        namespace: String,
        token: String
    ) throws -> (url: URL, relative: String) {
        guard ["gc", "manifest"].contains(namespace),
              RuntimeStoreManifestCodec.isSHA256Hex(token) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let original = try ownedURL(relativeDirectory: originalRelativeDirectory)
        let filename = ".deletion-\(namespace)-\(token)"
        let url = original.deletingLastPathComponent().appendingPathComponent(
            filename, isDirectory: true
        )
        let relative = originalRelativeDirectory.split(separator: "/").dropLast()
            .map(String.init).joined(separator: "/") + "/" + filename
        return (url.standardizedFileURL, relative)
    }

    func deletionQuarantineURL(relativeDirectory: String) throws -> URL {
        let components = relativeDirectory.split(separator: "/").map(String.init)
        guard components.count == 3,
              components[0] == "v1",
              components[1].utf8.count == 2,
              (components[2].hasPrefix(".deletion-gc-") ||
                components[2].hasPrefix(".deletion-manifest-")) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let url = rootDirectory
            .appendingPathComponent(components[0], isDirectory: true)
            .appendingPathComponent(components[1], isDirectory: true)
            .appendingPathComponent(components[2], isDirectory: true)
            .standardizedFileURL
        guard url.deletingLastPathComponent().deletingLastPathComponent()
                .deletingLastPathComponent() == rootDirectory else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return url
    }

    func verifyDeletionDirectory(
        _ directory: URL,
        manifest: RuntimeBlobManifestAuthority,
        manifestDigest: String
    ) throws {
        let expected = try RuntimeAttachmentCodec.digest(
            manifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard expected == manifestDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        try verifyDeletionDirectory(
            directory, expectedBlobID: manifest.blobID, manifestDigest: manifestDigest
        )
    }

    func verifyDeletionDirectory(
        _ directory: URL,
        expectedBlobID: RuntimeBlobID,
        manifestDigest: String
    ) throws {
        let allowed = Set(["payload.aead", "manifest.json", "finalized.json"])
        try validateBoundedAllowlistedChildren(
            of: directory, allowedNames: allowed, maximumChildCount: allowed.count
        )
        let manifestURL = directory.appendingPathComponent("manifest.json", isDirectory: false)
        try verifyProtection(directory)
        try verifyProtection(manifestURL)
        let opened = try openRegularFile(
            manifestURL, maximumBytes: Int64(RuntimeAttachmentLimits.maximumManifestBytes)
        )
        defer { try? opened.handle.close() }
        try verifyProtection(manifestURL, expectedAuthority: opened.authority)
        guard let bytes = try opened.handle.readToEnd(),
              Int64(bytes.count) == opened.authority.byteCount,
              try fileAuthority(for: opened.handle.fileDescriptor) == opened.authority,
              RuntimeAttachmentCodec.sha256(bytes) == manifestDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        try requirePathIdentity(manifestURL, authority: opened.authority)
        try verifyProtection(manifestURL, expectedAuthority: opened.authority)
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self,
            bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard manifest.blobID == expectedBlobID else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
    }

    struct FileAuthority: Equatable {
        let device: UInt64
        let inode: UInt64
        let byteCount: Int64
    }

    struct OpenedRegularFile {
        let handle: FileHandle
        let authority: FileAuthority
    }

    func rawDirectoryEntries(
        at directory: URL,
        limit: Int,
        afterRawCursor: String?
    ) throws -> RawDirectoryPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize,
              afterRawCursor.map({
                  $0.count <= Int(MAXNAMLEN) * 2 && $0.count.isMultiple(of: 2) &&
                    $0.allSatisfy({ $0.isHexDigit && $0.isUppercase == false })
              }) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let descriptor = Darwin.open(
            directory.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(directory.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino),
              let stream = fdopendir(descriptor) else {
            Darwin.close(descriptor)
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        defer { closedir(stream) }
        var entries: [RawDirectoryEntry] = []
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else {
                    throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
                }
                break
            }
            let rawBytes = withUnsafePointer(to: entry.pointee.d_name) { pointer -> Data in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    Data(bytes: $0, count: strnlen($0, Int(MAXNAMLEN) + 1))
                }
            }
            if rawBytes == Data(".".utf8) || rawBytes == Data("..".utf8) { continue }
            let candidate = RawDirectoryEntry(
                rawBytes: rawBytes,
                decoded: String(data: rawBytes, encoding: .utf8)
            )
            guard afterRawCursor.map({ candidate.cursorComponent > $0 }) ?? true else { continue }
            insertBoundedRawDirectoryEntry(candidate, into: &entries, limit: limit + 1)
        }
        var after = stat()
        guard lstat(directory.path, &after) == 0,
              (after.st_mode & S_IFMT) == S_IFDIR,
              UInt64(after.st_dev) == UInt64(opened.st_dev),
              UInt64(after.st_ino) == UInt64(opened.st_ino) else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        let selected = Array(entries.prefix(limit))
        return RawDirectoryPage(
            entries: selected,
            nextRawCursor: entries.count > limit ? selected.last?.cursorComponent : nil,
            exhausted: entries.count <= limit
        )
    }

    func insertBoundedRawDirectoryEntry(
        _ value: RawDirectoryEntry,
        into values: inout [RawDirectoryEntry],
        limit: Int
    ) {
        var lower = 0
        var upper = values.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            if values[middle].rawBytes.lexicographicallyPrecedes(value.rawBytes) {
                lower = middle + 1
            } else {
                upper = middle
            }
        }
        guard lower < limit else { return }
        values.insert(value, at: lower)
        if values.count > limit { values.removeLast() }
    }

    func malformedFilesystemEntry(
        cursorKey: String,
        rawName: Data,
        parentScope: String,
        error: RuntimeCanonicalAttachmentError
    ) -> RuntimeAttachmentFilesystemEntry {
        .malformed(RuntimeAttachmentFilesystemMalformedEntry(
            cursorKey: cursorKey,
            redactedNameDigest: RuntimeAttachmentCodec.sha256(rawName),
            parentScope: parentScope,
            error: error
        ))
    }

    func directoryAuthority(_ directory: URL) throws -> DirectoryAuthority {
        let descriptor = Darwin.open(
            directory.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(directory.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino) else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        return DirectoryAuthority(device: UInt64(opened.st_dev), inode: UInt64(opened.st_ino))
    }

    func forEachDirectoryEntryName(
        at directory: URL,
        _ visit: (String) throws -> Void
    ) throws {
        let standardized = directory.standardizedFileURL
        let descriptor = Darwin.open(
            standardized.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        var opened = stat()
        var pathMetadata = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(standardized.path, &pathMetadata) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (pathMetadata.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(pathMetadata.st_dev),
              UInt64(opened.st_ino) == UInt64(pathMetadata.st_ino),
              let stream = fdopendir(descriptor) else {
            Darwin.close(descriptor)
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        defer { closedir(stream) }
        while true {
            errno = 0
            guard let entry = readdir(stream) else {
                guard errno == 0 else {
                    throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
                }
                break
            }
            let name = withUnsafePointer(to: entry.pointee.d_name) { pointer in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    String(validatingCString: $0)
                }
            }
            guard let name else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
            if name == "." || name == ".." { continue }
            try visit(name)
        }
        var after = stat()
        guard lstat(standardized.path, &after) == 0,
              (after.st_mode & S_IFMT) == S_IFDIR,
              UInt64(after.st_dev) == UInt64(opened.st_dev),
              UInt64(after.st_ino) == UInt64(opened.st_ino) else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    func insertBoundedSorted(_ value: String, into values: inout [String], limit: Int) {
        var lower = 0
        var upper = values.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            if values[middle] < value { lower = middle + 1 } else { upper = middle }
        }
        guard lower < limit else { return }
        values.insert(value, at: lower)
        if values.count > limit { values.removeLast() }
    }

    func verifyDirectoryEntryNoFollow(_ directory: URL, parent: URL) throws {
        let standardized = directory.standardizedFileURL
        guard standardized.deletingLastPathComponent() == parent.standardizedFileURL else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let descriptor = Darwin.open(
            standardized.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(standardized.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    func validateBoundedAllowlistedChildren(
        of directory: URL,
        allowedNames: Set<String>,
        maximumChildCount: Int
    ) throws {
        guard maximumChildCount > 0, maximumChildCount <= allowedNames.count else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var childCount = 0
        try forEachDirectoryEntryName(at: directory) { name in
            childCount += 1
            guard childCount <= maximumChildCount, allowedNames.contains(name) else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            let candidate = directory.appendingPathComponent(name, isDirectory: false)
            let descriptor = Darwin.open(candidate.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
            guard descriptor >= 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            defer { Darwin.close(descriptor) }
            var opened = stat()
            var current = stat()
            guard fstat(descriptor, &opened) == 0,
                  lstat(candidate.path, &current) == 0,
                  (opened.st_mode & S_IFMT) == S_IFREG,
                  (current.st_mode & S_IFMT) == S_IFREG,
                  opened.st_nlink == 1,
                  UInt64(opened.st_dev) == UInt64(current.st_dev),
                  UInt64(opened.st_ino) == UInt64(current.st_ino) else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try verifyProtection(candidate)
        }
    }

    func validateStagingDirectoryName(_ name: String) throws {
        let token = name.dropFirst(".staging-".count)
        guard name.hasPrefix(".staging-"), token.isEmpty == false,
              token.utf8.count <= 128,
              token.allSatisfy({
                  $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-")
              }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    func validatedRegularFile(
        _ url: URL,
        expectedDevice: UInt64? = nil,
        expectedInode: UInt64? = nil
    ) throws -> FileAuthority {
        let opened = try openRegularFile(url, maximumBytes: RuntimeAttachmentLimits.maximumAttachmentBytes)
        defer { try? opened.handle.close() }
        guard expectedDevice.map({ $0 == opened.authority.device }) ?? true,
              expectedInode.map({ $0 == opened.authority.inode }) ?? true else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try verifyProtection(url, expectedAuthority: opened.authority)
        return opened.authority
    }

    func digestFile(_ url: URL, expectedIdentity: FileAuthority, maximumBytes: Int64) throws -> SHA256.Digest {
        let opened = try openRegularFile(url, maximumBytes: maximumBytes)
        let handle = opened.handle
        defer { try? handle.close() }
        guard opened.authority.device == expectedIdentity.device,
              opened.authority.inode == expectedIdentity.inode,
              opened.authority.byteCount == expectedIdentity.byteCount else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        var hasher = SHA256()
        var total: Int64 = 0
        while true {
            try Task.checkCancellation()
            guard let data = try handle.read(upToCount: chunkSize), data.isEmpty == false else { break }
            total += Int64(data.count)
            guard total <= maximumBytes else { throw RuntimeCanonicalAttachmentError.sizeLimitExceeded }
            hasher.update(data: data)
        }
        let after = try fileAuthority(for: handle.fileDescriptor)
        guard after == opened.authority, after.byteCount == total else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requirePathIdentity(url, authority: after)
        try verifyProtection(url, expectedAuthority: after)
        return hasher.finalize()
    }

    func encrypt(
        sourceURL: URL,
        destinationURL: URL,
        expectedIdentity: FileAuthority,
        expectedBytes: Int64,
        headerBytes: Data,
        headerDigest: String,
        blobID: RuntimeBlobID,
        expectedPlaintextDigest: SHA256.Digest,
        key: SymmetricKey
    ) throws -> (chunkCount: Int, ciphertextBytes: Int64, terminalDigest: String) {
        let openedInput = try openRegularFile(sourceURL, maximumBytes: expectedBytes)
        let input = openedInput.handle
        guard openedInput.authority.device == expectedIdentity.device,
              openedInput.authority.inode == expectedIdentity.inode,
              openedInput.authority.byteCount == expectedIdentity.byteCount else {
            try? input.close()
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try verifyProtection(sourceURL, expectedAuthority: openedInput.authority)
        let output = try createExclusiveFile(destinationURL)
        defer { try? input.close(); try? output.close() }
        try writeUInt32(headerBytes.count, to: output)
        try output.write(contentsOf: headerBytes)
        var index = 0
        var plaintextTotal: Int64 = 0
        var ciphertextTotal = Int64(4 + headerBytes.count)
        var plaintextHasher = SHA256()
        var terminalHasher = SHA256()
        terminalHasher.update(data: headerBytes)
        while true {
            try Task.checkCancellation()
            guard let plaintext = try input.read(upToCount: chunkSize), plaintext.isEmpty == false else { break }
            plaintextTotal += Int64(plaintext.count)
            guard plaintextTotal <= expectedBytes, index < RuntimeAttachmentLimits.maximumChunks else {
                throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
            }
            plaintextHasher.update(data: plaintext)
            let sealed = try AES.GCM.seal(
                plaintext, using: key,
                authenticating: chunkAAD(blobID: blobID, headerDigest: headerDigest, index: index)
            )
            guard let combined = sealed.combined else {
                throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
            }
            try writeUInt32(combined.count, to: output)
            try output.write(contentsOf: combined)
            terminalHasher.update(data: withUnsafeBytes(of: UInt64(index).bigEndian) { Data($0) })
            terminalHasher.update(data: combined)
            ciphertextTotal += Int64(4 + combined.count)
            index += 1
        }
        let after = try fileAuthority(for: input.fileDescriptor)
        guard after == openedInput.authority, plaintextTotal == expectedBytes,
              after.byteCount == expectedBytes, index > 0,
              plaintextHasher.finalize() == expectedPlaintextDigest else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requirePathIdentity(sourceURL, authority: after)
        try verifyProtection(sourceURL, expectedAuthority: after)
        let framedChunkByteCount = ciphertextTotal
        let orderedCiphertextDigest = terminalHasher.finalize().map {
            String(format: "%02x", $0)
        }.joined()
        let terminal = Terminal(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: blobID,
            headerDigest: headerDigest,
            chunkCount: index,
            plaintextByteCount: plaintextTotal,
            framedChunkByteCount: framedChunkByteCount,
            orderedCiphertextDigest: orderedCiphertextDigest
        )
        let terminalBytes = try RuntimeAttachmentCodec.encode(
            terminal, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let sealedTerminal = try AES.GCM.seal(
            terminalBytes, using: key,
            authenticating: terminalAAD(blobID: blobID, headerDigest: headerDigest)
        )
        guard let combinedTerminal = sealedTerminal.combined else {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        try writeUInt32(combinedTerminal.count, to: output)
        try output.write(contentsOf: combinedTerminal)
        ciphertextTotal += Int64(4 + combinedTerminal.count)
        try output.synchronize()
        try applyProtection(destinationURL)
        let outputAuthority = try fileAuthority(for: output.fileDescriptor)
        guard outputAuthority.byteCount == ciphertextTotal else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requirePathIdentity(destinationURL, authority: outputAuthority)
        try verifyProtection(destinationURL, expectedAuthority: outputAuthority)
        return (
            index,
            ciphertextTotal,
            RuntimeAttachmentCodec.sha256(combinedTerminal)
        )
    }

    func chunkAAD(blobID: RuntimeBlobID?, headerDigest: String, index: Int) -> Data {
        Data("ambitions.attachment.chunk.v1\u{0}\(blobID?.rawValue ?? "bound-in-header")\u{0}\(headerDigest)\u{0}\(index)".utf8)
    }

    func terminalAAD(blobID: RuntimeBlobID, headerDigest: String) -> Data {
        Data("ambitions.attachment.terminal.v1\u{0}\(blobID.rawValue)\u{0}\(headerDigest)".utf8)
    }

    func verifyTerminal(
        handle: FileHandle,
        expectedAuthority: FileAuthority,
        manifest: RuntimeBlobManifestAuthority,
        key: SymmetricKey
    ) throws {
        guard try regularFileAuthority(handle.fileDescriptor) == expectedAuthority,
              expectedAuthority.byteCount == manifest.ciphertextByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        try handle.seek(toOffset: 0)
        let headerLength = try readUInt32(handle)
        guard headerLength > 0,
              headerLength <= RuntimeAttachmentLimits.maximumManifestBytes,
              let header = try handle.read(upToCount: headerLength), header.count == headerLength,
              RuntimeAttachmentCodec.sha256(header) == manifest.headerDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        var hasher = SHA256()
        hasher.update(data: header)
        var framedChunkByteCount = Int64(4 + header.count)
        for index in 0..<manifest.chunkCount {
            try Task.checkCancellation()
            let size = try readUInt32(handle)
            guard size > 0, size <= RuntimeAttachmentLimits.maximumChunkBytes + 64,
                  let encrypted = try handle.read(upToCount: size), encrypted.count == size else {
                throw RuntimeCanonicalAttachmentError.manifestInvalid
            }
            hasher.update(data: withUnsafeBytes(of: UInt64(index).bigEndian) { Data($0) })
            hasher.update(data: encrypted)
            framedChunkByteCount += Int64(4 + encrypted.count)
        }
        let orderedCiphertextDigest = hasher.finalize().map {
            String(format: "%02x", $0)
        }.joined()
        let terminalSize = try readUInt32(handle)
        guard terminalSize > 0,
              terminalSize <= RuntimeAttachmentLimits.maximumManifestBytes + 64,
              let encryptedTerminal = try handle.read(upToCount: terminalSize),
              encryptedTerminal.count == terminalSize,
              RuntimeAttachmentCodec.sha256(encryptedTerminal) == manifest.terminalDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let terminalBytes: Data
        do {
            terminalBytes = try AES.GCM.open(
                AES.GCM.SealedBox(combined: encryptedTerminal), using: key,
                authenticating: terminalAAD(
                    blobID: manifest.blobID, headerDigest: manifest.headerDigest
                )
            )
        } catch {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let terminal = try RuntimeAttachmentCodec.decode(
            Terminal.self, bytes: terminalBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let trailing = try handle.read(upToCount: 1) ?? Data()
        guard trailing.isEmpty,
              try regularFileAuthority(handle.fileDescriptor) == expectedAuthority,
              terminal.version == manifest.formatVersion,
              terminal.blobID == manifest.blobID,
              terminal.headerDigest == manifest.headerDigest,
              terminal.chunkCount == manifest.chunkCount,
              terminal.plaintextByteCount == manifest.plaintextByteCount,
              terminal.framedChunkByteCount == framedChunkByteCount,
              terminal.orderedCiphertextDigest == orderedCiphertextDigest else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
    }

    func opaqueDirectory(for blobID: RuntimeBlobID) throws -> String {
        let digest = RuntimeAttachmentCodec.sha256(Data(blobID.rawValue.utf8))
        let token = try validatedOpaqueToken()
        let value = "v1/\(digest.prefix(2))/\(token)"
        guard RuntimeAttachmentCodec.validOpaqueDirectory(value) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return value
    }

    func validatedOpaqueToken() throws -> String {
        let token = opaqueToken().lowercased()
        guard token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return token
    }

    func ownedURL(relativeDirectory: String) throws -> URL {
        guard RuntimeAttachmentCodec.validOpaqueDirectory(relativeDirectory) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let result = relativeDirectory.split(separator: "/").reduce(rootDirectory) {
            $0.appendingPathComponent(String($1), isDirectory: true)
        }.standardizedFileURL
        guard result.path.hasPrefix(rootDirectory.path + "/") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return result
    }

    func ensureRoot() throws {
        try createOwnedDirectory(rootDirectory)
        let values = try rootDirectory.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    func createOwnedDirectory(_ url: URL) throws {
        let existed = fileManager.fileExists(atPath: url.path)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        try applyProtection(url)
        if existed == false {
            try synchronizeDirectory(url)
            try synchronizeDirectory(url.deletingLastPathComponent())
        }
    }

    func createExclusiveOwnedDirectory(_ url: URL) throws {
        guard url.deletingLastPathComponent().standardizedFileURL == rootDirectory else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        try ensureTemporaryDirectoryCapacity()
        guard Darwin.mkdir(url.path, S_IRWXU) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        do {
            try applyProtection(url)
            let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            guard values.isDirectory == true, values.isSymbolicLink != true else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeDirectory(url)
            try synchronizeDirectory(url.deletingLastPathComponent())
        } catch {
            try? fileManager.removeItem(at: url)
            throw error
        }
    }

    func ensureTemporaryDirectoryCapacity() throws {
        var count = 0
        var cursor: String?
        repeat {
            let page = try rawDirectoryEntries(
                at: rootDirectory,
                limit: RuntimeAttachmentLimits.maximumPageSize,
                afterRawCursor: cursor
            )
            for entry in page.entries where
                entry.rawBytes.starts(with: Data(".staging-".utf8)) {
                count += 1
                guard count < Self.maximumOwnedTemporaryDirectoryCount else {
                    throw RuntimeCanonicalAttachmentError.quotaExceeded
                }
            }
            cursor = page.nextRawCursor
            if page.exhausted { break }
        } while cursor != nil
    }

    func createAndVerifyOwnedHierarchy(_ target: URL) throws {
        let standardized = target.standardizedFileURL
        guard standardized.path.hasPrefix(rootDirectory.path + "/") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        var current = rootDirectory
        let relative = standardized.path.dropFirst(rootDirectory.path.count + 1)
        for component in relative.split(separator: "/") {
            guard component.isEmpty == false, component != ".", component != ".." else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            current.appendPathComponent(String(component), isDirectory: true)
            if fileManager.fileExists(atPath: current.path) == false {
                try fileManager.createDirectory(at: current, withIntermediateDirectories: false)
                try applyProtection(current)
                try synchronizeDirectory(current)
                try synchronizeDirectory(current.deletingLastPathComponent())
            }
            let values = try current.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            guard values.isDirectory == true, values.isSymbolicLink != true else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try verifyProtection(current)
        }
    }

    func verifyOwnedDirectory(_ url: URL, expectedRelative: String) throws {
        guard url == try ownedURL(relativeDirectory: expectedRelative) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    func atomicProtectedWrite(_ bytes: Data, to url: URL) throws {
        guard bytes.isEmpty == false, bytes.count <= RuntimeAttachmentLimits.maximumManifestBytes else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        try bytes.write(to: url, options: [.atomic])
        try applyProtection(url)
        let opened = try openRegularFile(url, maximumBytes: Int64(bytes.count))
        try opened.handle.close()
        try verifyProtection(url)
        try synchronizeDirectory(url.deletingLastPathComponent())
    }

    func synchronizeDirectory(_ url: URL) throws {
        let descriptor = Darwin.open(url.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(url.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        if fcntl(descriptor, F_FULLFSYNC) != 0, fsync(descriptor) != 0 {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              UInt64(after.st_dev) == UInt64(opened.st_dev),
              UInt64(after.st_ino) == UInt64(opened.st_ino) else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    func pathEntryExistsNoFollow(_ url: URL) throws -> Bool {
        var metadata = stat()
        if lstat(url.path, &metadata) == 0 { return true }
        if errno == ENOENT { return false }
        throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
    }

    func openRegularFile(_ url: URL, maximumBytes: Int64) throws -> OpenedRegularFile {
        guard maximumBytes > 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        do {
            let authority = try fileAuthority(for: descriptor)
            guard authority.byteCount > 0, authority.byteCount <= maximumBytes else {
                throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
            }
            try requirePathIdentity(url, authority: authority)
            return OpenedRegularFile(
                handle: FileHandle(fileDescriptor: descriptor, closeOnDealloc: true),
                authority: authority
            )
        } catch {
            Darwin.close(descriptor)
            throw error
        }
    }

    func createExclusiveFile(_ url: URL) throws -> FileHandle {
        let descriptor = Darwin.open(
            url.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        return FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    }

    func fileAuthority(for descriptor: Int32) throws -> FileAuthority {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_nlink == 1,
              metadata.st_size > 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return FileAuthority(
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
            byteCount: Int64(metadata.st_size)
        )
    }

    func requirePathIdentity(_ url: URL, authority: FileAuthority) throws {
        var metadata = stat()
        guard lstat(url.path, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_nlink == 1,
              UInt64(metadata.st_dev) == authority.device,
              UInt64(metadata.st_ino) == authority.inode,
              Int64(metadata.st_size) == authority.byteCount else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    func readExactlyBounded(
        _ handle: FileHandle,
        expectedBytes: Int64,
        maximumBytes: Int64
    ) throws -> Data {
        guard expectedBytes > 0, expectedBytes <= maximumBytes,
              expectedBytes <= Int64(Int.max) else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        guard let bytes = try handle.read(upToCount: Int(expectedBytes)),
              bytes.count == Int(expectedBytes),
              (try handle.read(upToCount: 1) ?? Data()).isEmpty else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return bytes
    }

    func applyProtection(_ url: URL) throws {
        #if os(iOS)
        try fileManager.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        #endif
    }

    func verifyProtection(_ url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #else
        _ = url
        #endif
    }

    func verifyProtection(_ url: URL, expectedAuthority: FileAuthority) throws {
        try requirePathIdentity(url, authority: expectedAuthority)
        try verifyProtection(url)
        try requirePathIdentity(url, authority: expectedAuthority)
    }

    func writeUInt32(_ value: Int, to handle: FileHandle) throws {
        guard value > 0, value <= Int(UInt32.max) else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        try handle.write(contentsOf: withUnsafeBytes(of: UInt32(value).bigEndian) { Data($0) })
    }

    func readUInt32(_ handle: FileHandle) throws -> Int {
        guard let bytes = try handle.read(upToCount: 4), bytes.count == 4 else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return bytes.reduce(0) { ($0 << 8) | Int($1) }
    }
}
