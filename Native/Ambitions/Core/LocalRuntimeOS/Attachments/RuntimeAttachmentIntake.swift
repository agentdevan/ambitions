import CryptoKit
import Darwin
import Foundation
import UniformTypeIdentifiers

struct RuntimeAttachmentIntakePart: Sendable {
    let attachmentID: RuntimeAttachmentID
    let revisionID: RuntimeAttachmentRevisionID
    let revision: UInt64
    let blobID: RuntimeBlobID
    let sourceURL: URL
    let originalFilename: String
    let declaredContentType: String
    let privacy: EventLedgerPrivacyClassification
    let dedupPolicy: RuntimeAttachmentDedupPolicy
    let provenance: RuntimeAttachmentProvenance
    let reservationID: RuntimeBlobQuotaReservationID
    let expectedMaximumBytes: Int64
    let retentionUntil: Date?
    let requiresSecurityScopedAccess: Bool
    let acceptedAt: Date
}

enum RuntimeAttachmentIntakePartResult: Sendable, Equatable {
    case staged(RuntimeAttachmentStageBundle, reservationID: RuntimeBlobQuotaReservationID)
    case quarantined(
        attachmentID: RuntimeAttachmentID,
        reason: RuntimeAttachmentQuarantineReason,
        evidenceFingerprint: String
    )
}

struct RuntimeAttachmentIntakeBatchResult: Sendable, Equatable {
    let parts: [RuntimeAttachmentIntakePartResult]
    let wasCancelled: Bool
    var staged: [RuntimeAttachmentStageBundle] {
        parts.compactMap { if case let .staged(value, _) = $0 { value } else { nil } }
    }
}

struct RuntimeAttachmentPortableIntakeRequest: Sendable {
    let attachmentID: RuntimeAttachmentID
    let revisionID: RuntimeAttachmentRevisionID
    let revision: UInt64
    let blobID: RuntimeBlobID
    let reservationID: RuntimeBlobQuotaReservationID
    let importReceipt: RuntimeAttachmentPortableImportReceipt
    let dedupPolicy: RuntimeAttachmentDedupPolicy
    let retentionUntil: Date?
    let acceptedAt: Date
}

actor RuntimeAttachmentIntake {
    private static let maximumOwnedIntakeLeftoverCount = 4_096
    private let intakeRoot: URL
    private let vault: RuntimeAttachmentVault
    private let quotaAuthorizer: any RuntimeAttachmentQuotaAuthorizing
    private let intakeProofKey: SymmetricKey
    private let fileManager: FileManager
    private let bufferBytes: Int
    private let intakeToken: @Sendable () -> String
    private let clock: @Sendable () -> Date

    init(
        intakeRoot: URL,
        vault: RuntimeAttachmentVault,
        quotaAuthorizer: any RuntimeAttachmentQuotaAuthorizing,
        intakeProofKey: SymmetricKey,
        bufferBytes: Int = 256 * 1_024,
        fileManager: FileManager = .default,
        intakeToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        guard bufferBytes >= RuntimeAttachmentLimits.minimumChunkBytes,
              bufferBytes <= RuntimeAttachmentLimits.maximumChunkBytes else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        self.intakeRoot = intakeRoot.standardizedFileURL
        self.vault = vault
        self.quotaAuthorizer = quotaAuthorizer
        self.intakeProofKey = intakeProofKey
        self.bufferBytes = bufferBytes
        self.fileManager = fileManager
        self.intakeToken = intakeToken
        self.clock = clock
    }

    func stage(parts: [RuntimeAttachmentIntakePart]) async -> RuntimeAttachmentIntakeBatchResult {
        guard parts.count <= RuntimeAttachmentLimits.maximumReferences else {
            return RuntimeAttachmentIntakeBatchResult(
                parts: parts.map { part in
                    .quarantined(
                        attachmentID: part.attachmentID,
                        reason: .sizeLimitExceeded,
                        evidenceFingerprint: evidenceFingerprint(
                            part: part, error: .sizeLimitExceeded
                        )
                    )
                },
                wasCancelled: false
            )
        }
        var results: [RuntimeAttachmentIntakePartResult] = []
        results.reserveCapacity(parts.count)
        for part in parts {
            do {
                try Task.checkCancellation()
                results.append(.staged(try await stage(part), reservationID: part.reservationID))
            } catch is CancellationError {
                return RuntimeAttachmentIntakeBatchResult(parts: results, wasCancelled: true)
            } catch let error as RuntimeCanonicalAttachmentError {
                results.append(.quarantined(
                    attachmentID: part.attachmentID,
                    reason: quarantineReason(error),
                    evidenceFingerprint: evidenceFingerprint(part: part, error: error)
                ))
            } catch {
                results.append(.quarantined(
                    attachmentID: part.attachmentID,
                    reason: .malformedSource,
                    evidenceFingerprint: evidenceFingerprint(part: part, error: .invalidRecord)
                ))
            }
        }
        return RuntimeAttachmentIntakeBatchResult(parts: results, wasCancelled: false)
    }

    func stagePortableImport(
        _ request: RuntimeAttachmentPortableIntakeRequest
    ) async -> RuntimeAttachmentIntakeBatchResult {
        let receipt = request.importReceipt
        let part = RuntimeAttachmentIntakePart(
            attachmentID: request.attachmentID, revisionID: request.revisionID,
            revision: request.revision, blobID: request.blobID,
            sourceURL: receipt.ownedPlaintextURL,
            originalFilename: receipt.classification.normalizedFilename,
            declaredContentType: receipt.classification.declaredContentType,
            privacy: receipt.privacy, dedupPolicy: request.dedupPolicy,
            provenance: RuntimeAttachmentProvenance(
                version: runtimeCanonicalAttachmentModelVersion, kind: .importArchive,
                sourceRecordID: receipt.revisionID.rawValue, receivedAt: request.acceptedAt,
                sourceApplicationFingerprint: nil
            ),
            reservationID: request.reservationID,
            expectedMaximumBytes: receipt.plaintextByteCount,
            retentionUntil: request.retentionUntil,
            requiresSecurityScopedAccess: false, acceptedAt: request.acceptedAt
        )
        do {
            let bundle = try await stage(part, expectedClassification: receipt.classification)
            return RuntimeAttachmentIntakeBatchResult(
                parts: [.staged(bundle, reservationID: request.reservationID)],
                wasCancelled: false
            )
        } catch is CancellationError {
            return RuntimeAttachmentIntakeBatchResult(parts: [], wasCancelled: true)
        } catch let error as RuntimeCanonicalAttachmentError {
            return RuntimeAttachmentIntakeBatchResult(parts: [
                .quarantined(
                    attachmentID: request.attachmentID,
                    reason: quarantineReason(error),
                    evidenceFingerprint: evidenceFingerprint(part: part, error: error)
                ),
            ], wasCancelled: false)
        } catch {
            return RuntimeAttachmentIntakeBatchResult(parts: [
                .quarantined(
                    attachmentID: request.attachmentID, reason: .malformedSource,
                    evidenceFingerprint: evidenceFingerprint(part: part, error: .invalidRecord)
                ),
            ], wasCancelled: false)
        }
    }

    func ownedIntakeLeftovers(
        limit: Int,
        afterCursorKey: String? = nil
    ) throws -> RuntimeAttachmentFilesystemPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try ensureIntakeRoot()
        try verifyIntakeProtection(intakeRoot)
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
            at: intakeRoot, limit: limit, afterRawCursor: rawCursor
        )
        var discovered: [RuntimeAttachmentFilesystemEntry] = []
        for entry in rawPage.entries {
            guard entry.decoded?.hasPrefix("intake-") == true ||
                    entry.rawBytes.starts(with: Data("intake-".utf8)) else { continue }
            let cursorKey = "r:\(entry.cursorComponent)"
            guard let name = entry.decoded else {
                discovered.append(.malformed(RuntimeAttachmentFilesystemMalformedEntry(
                    cursorKey: cursorKey,
                    redactedNameDigest: RuntimeAttachmentCodec.sha256(entry.rawBytes),
                    parentScope: "intake-root",
                    error: .pathAuthorityDenied
                )))
                continue
            }
            let candidate = intakeRoot.appendingPathComponent(name, isDirectory: false)
            do {
                try validateOwnedIntakeFilename(name)
                let descriptor = Darwin.open(candidate.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
                guard descriptor >= 0 else {
                    throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
                }
                defer { Darwin.close(descriptor) }
                let opened = try ownedLeftoverAuthority(descriptor: descriptor)
                var current = stat()
                guard lstat(candidate.path, &current) == 0,
                      (current.st_mode & S_IFMT) == S_IFREG,
                      UInt64(current.st_dev) == opened.device,
                      UInt64(current.st_ino) == opened.inode else {
                    throw RuntimeCanonicalAttachmentError.fileIdentityChanged
                }
                try verifyIntakeProtection(candidate)
                discovered.append(.owned(cursorKey: cursorKey, url: candidate))
            } catch let error as RuntimeCanonicalAttachmentError {
                discovered.append(.malformed(RuntimeAttachmentFilesystemMalformedEntry(
                    cursorKey: cursorKey,
                    redactedNameDigest: RuntimeAttachmentCodec.sha256(entry.rawBytes),
                    parentScope: "intake-root",
                    error: error
                )))
            }
        }
        return RuntimeAttachmentFilesystemPage(
            entries: discovered,
            nextCursorKey: rawPage.nextRawCursor.map { "r:\($0)" },
            exhausted: rawPage.exhausted
        )
    }

    func removeOwnedIntakeLeftover(_ leftover: URL) throws {
        let candidate = leftover.standardizedFileURL
        guard candidate.deletingLastPathComponent() == intakeRoot else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        try validateOwnedIntakeFilename(candidate.lastPathComponent)
        try ensureIntakeRoot()
        try verifyIntakeProtection(intakeRoot)
        var initial = stat()
        if lstat(candidate.path, &initial) != 0 {
            guard errno == ENOENT else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeIntakeRoot()
            guard lstat(candidate.path, &initial) != 0, errno == ENOENT else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            return
        }
        guard (initial.st_mode & S_IFMT) == S_IFREG else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let descriptor = Darwin.open(candidate.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        let opened = try ownedLeftoverAuthority(descriptor: descriptor)
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: candidate.path
        )
        #endif
        try verifyIntakeProtection(candidate)
        var current = stat()
        guard lstat(candidate.path, &current) == 0,
              (current.st_mode & S_IFMT) == S_IFREG,
              current.st_nlink == 1,
              UInt64(current.st_dev) == opened.device,
              UInt64(current.st_ino) == opened.inode,
              try ownedLeftoverAuthority(descriptor: descriptor) == opened else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try fileManager.removeItem(at: candidate)
        var after = stat()
        guard lstat(candidate.path, &after) != 0, errno == ENOENT else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        try synchronizeIntakeRoot()
        guard lstat(candidate.path, &after) != 0, errno == ENOENT else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func stage(
        _ part: RuntimeAttachmentIntakePart,
        expectedClassification: RuntimeAttachmentContentClassification? = nil
    ) async throws -> RuntimeAttachmentStageBundle {
        guard part.revision > 0,
              part.expectedMaximumBytes > 0,
              part.expectedMaximumBytes <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              let privacyDomain = RuntimeAttachmentPrivacyDomain(part.privacy),
              let declared = UTType(mimeType: part.declaredContentType.lowercased()),
              declared.isDeclared || declared.isDynamic else {
            throw RuntimeCanonicalAttachmentError.contentTypeMismatch
        }
        try RuntimeAttachmentCodec.validate(part.provenance)
        let authorization = try await quotaAuthorizer.authorizeAttachmentIntake(
            reservationID: part.reservationID,
            privacyDomain: privacyDomain,
            maximumBytes: part.expectedMaximumBytes,
            now: clock()
        )
        do {
            guard authorization.reservationID == part.reservationID,
                  authorization.privacyDomain == privacyDomain,
                  authorization.ownerID.isEmpty == false,
                  authorization.ownerID.utf8.count <= 1_024,
                  authorization.reservedBytes >= part.expectedMaximumBytes,
                  authorization.expiresAt > clock(),
                  RuntimeStoreManifestCodec.isSHA256Hex(authorization.authorizationDigest) else {
                throw RuntimeCanonicalAttachmentError.quotaExceeded
            }
            return try await stageAuthorized(
                part, declared: declared, expectedClassification: expectedClassification
            )
        } catch {
            let original = error
            try await quotaAuthorizer.releaseAttachmentIntakeAuthorization(
                authorization, now: clock()
            )
            throw original
        }
    }

    private func stageAuthorized(
        _ part: RuntimeAttachmentIntakePart,
        declared: UTType,
        expectedClassification: RuntimeAttachmentContentClassification?
    ) async throws -> RuntimeAttachmentStageBundle {
        let normalizedFilename = try normalizeFilename(part.originalFilename)
        let didAccess: Bool
        if part.requiresSecurityScopedAccess {
            didAccess = part.sourceURL.startAccessingSecurityScopedResource()
            guard didAccess else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        } else {
            didAccess = false
        }
        defer { if didAccess { part.sourceURL.stopAccessingSecurityScopedResource() } }

        try ensureIntakeRoot()
        try ensureIntakeLeftoverCapacity()
        let token = intakeToken().lowercased()
        guard token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        let ownedURL = intakeRoot.appendingPathComponent("intake-\(token).part", isDirectory: false)
        do {
            let copy = try copyBounded(
                source: part.sourceURL,
                destination: ownedURL,
                maximumBytes: part.expectedMaximumBytes
            )
            if declared.conforms(to: .plainText) {
                try validateCompleteUTF8(
                    ownedURL, expectedAuthority: copy.authority,
                    maximumBytes: copy.byteCount
                )
            }
            let detected = try detectContentType(
                filename: normalizedFilename, declared: declared,
                prefix: copy.prefix, completeUTF8Validated: declared.conforms(to: .plainText)
            )
            let detectedContentType = detected.preferredMIMEType ?? part.declaredContentType.lowercased()
            let classification = RuntimeAttachmentContentClassification(
                normalizedFilename: normalizedFilename,
                declaredContentType: part.declaredContentType.lowercased(),
                detectedContentType: detectedContentType,
                signatureVersion: 1,
                byteCount: copy.byteCount
            )
            if let expectedClassification {
                guard expectedClassification == classification else {
                    throw RuntimeCanonicalAttachmentError.contentTypeMismatch
                }
            }
            let proof = try RuntimeAttachmentCodec.issueIntakeProof(
                revisionID: part.revisionID, blobID: part.blobID,
                ownedFilename: ownedURL.lastPathComponent,
                sourceDevice: copy.sourceAuthority.device,
                sourceInode: copy.sourceAuthority.inode,
                device: copy.authority.device, inode: copy.authority.inode,
                byteCount: copy.byteCount, plaintextDigest: copy.plaintextDigest,
                classification: classification, issuedAt: clock(), key: intakeProofKey
            )
            let staged = try await vault.stage(RuntimeAttachmentVaultStageRequest(
                attachmentID: part.attachmentID,
                revisionID: part.revisionID,
                revision: part.revision,
                blobID: part.blobID,
                ownedPlaintextURL: ownedURL,
                intakeProof: proof,
                normalizedFilename: normalizedFilename,
                declaredContentType: part.declaredContentType.lowercased(),
                detectedContentType: detectedContentType,
                privacy: part.privacy,
                dedupPolicy: part.dedupPolicy,
                provenance: part.provenance,
                reservationID: part.reservationID,
                expectedByteCount: copy.byteCount,
                retentionUntil: part.retentionUntil,
                createdAt: part.acceptedAt
            ))
            // Plaintext cleanup is part of successful intake, not a best-effort
            // deferred side effect.
            try removeOwnedIntakeLeftover(ownedURL)
            return staged
        } catch {
            let intakeError = error
            do {
                try removeOwnedIntakeLeftover(ownedURL)
            } catch {
                // The bounded, protected intake namespace is recovery-scanned.
                // Keep the primary failure (especially cancellation) truthful.
            }
            if intakeError is CancellationError { throw CancellationError() }
            throw intakeError
        }
    }

    private struct SourceAuthority: Equatable {
        let device: UInt64
        let inode: UInt64
        let byteCount: Int64
    }

    private struct OwnedLeftoverAuthority: Equatable {
        let device: UInt64
        let inode: UInt64
    }

    private struct RawDirectoryEntry {
        let rawBytes: Data
        let decoded: String?

        var cursorComponent: String {
            rawBytes.map { String(format: "%02x", $0) }.joined()
        }
    }

    private struct RawDirectoryPage {
        let entries: [RawDirectoryEntry]
        let nextRawCursor: String?
        let exhausted: Bool
    }

    private struct CopyResult {
        let prefix: Data
        let byteCount: Int64
        let plaintextDigest: String
        let sourceAuthority: SourceAuthority
        let authority: SourceAuthority
    }

    private func copyBounded(
        source: URL,
        destination: URL,
        maximumBytes: Int64
    ) throws -> CopyResult {
        let inputDescriptor = Darwin.open(source.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard inputDescriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        let input = FileHandle(fileDescriptor: inputDescriptor, closeOnDealloc: true)
        let sourceBefore: SourceAuthority
        do {
            sourceBefore = try sourceAuthority(descriptor: inputDescriptor)
        } catch {
            try? input.close()
            throw error
        }
        guard sourceBefore.byteCount <= maximumBytes else {
            try? input.close()
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        let outputDescriptor = Darwin.open(
            destination.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard outputDescriptor >= 0 else {
            try? input.close()
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let output = FileHandle(fileDescriptor: outputDescriptor, closeOnDealloc: true)
        defer { try? input.close(); try? output.close() }
        var total: Int64 = 0
        var prefix = Data()
        var hasher = SHA256()
        while true {
            try Task.checkCancellation()
            guard let bytes = try input.read(upToCount: bufferBytes), bytes.isEmpty == false else { break }
            total += Int64(bytes.count)
            guard total <= maximumBytes else { throw RuntimeCanonicalAttachmentError.sizeLimitExceeded }
            if prefix.count < RuntimeAttachmentLimits.maximumSignatureBytes {
                prefix.append(bytes.prefix(RuntimeAttachmentLimits.maximumSignatureBytes - prefix.count))
            }
            hasher.update(data: bytes)
            try output.write(contentsOf: bytes)
        }
        try output.synchronize()
        guard total == sourceBefore.byteCount,
              try sourceAuthority(descriptor: inputDescriptor) == sourceBefore else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        let outputAuthority = try ownedPlaintextAuthority(descriptor: outputDescriptor)
        guard outputAuthority.byteCount == total else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requirePathIdentity(destination, authority: outputAuthority)
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: destination.path
        )
        let attributes = try fileManager.attributesOfItem(atPath: destination.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif
        try requirePathIdentity(destination, authority: outputAuthority)
        guard try ownedPlaintextAuthority(descriptor: outputDescriptor) == outputAuthority else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        return CopyResult(
            prefix: prefix, byteCount: total,
            plaintextDigest: RuntimeAttachmentCodec.sha256DigestHex(hasher.finalize()),
            sourceAuthority: sourceBefore,
            authority: outputAuthority
        )
    }

    private func ownedPlaintextAuthority(descriptor: Int32) throws -> SourceAuthority {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_nlink == 1,
              metadata.st_size > 0,
              Int64(metadata.st_size) <= RuntimeAttachmentLimits.maximumAttachmentBytes else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return SourceAuthority(
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
            byteCount: Int64(metadata.st_size)
        )
    }

    private func requirePathIdentity(_ url: URL, authority: SourceAuthority) throws {
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

    private func detectContentType(
        filename: String,
        declared: UTType,
        prefix: Data,
        completeUTF8Validated: Bool
    ) throws -> UTType {
        let extensionType = URL(fileURLWithPath: filename).pathExtension.isEmpty
            ? nil
            : UTType(filenameExtension: URL(fileURLWithPath: filename).pathExtension)
        let signatureType: UTType? = {
            let bytes = [UInt8](prefix)
            if bytes.starts(with: [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]) { return .png }
            if bytes.starts(with: [0xff, 0xd8, 0xff]) { return .jpeg }
            if bytes.starts(with: [0x25, 0x50, 0x44, 0x46, 0x2d]) { return .pdf }
            if bytes.starts(with: [0x50, 0x4b, 0x03, 0x04]) { return .zip }
            if declared.conforms(to: .plainText), completeUTF8Validated { return declared }
            return nil
        }()
        guard let detected = signatureType,
              detected.conforms(to: declared) || declared.conforms(to: detected) else {
            throw RuntimeCanonicalAttachmentError.signatureMismatch
        }
        if let extensionType,
           extensionType.conforms(to: declared) == false,
           declared.conforms(to: extensionType) == false {
            throw RuntimeCanonicalAttachmentError.contentTypeMismatch
        }
        return detected
    }

    private func sourceAuthority(descriptor: Int32) throws -> SourceAuthority {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_size > 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return SourceAuthority(
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
            byteCount: Int64(metadata.st_size)
        )
    }

    private func ownedLeftoverAuthority(descriptor: Int32) throws -> OwnedLeftoverAuthority {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_nlink == 1,
              metadata.st_size >= 0,
              Int64(metadata.st_size) <= RuntimeAttachmentLimits.maximumAttachmentBytes else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return OwnedLeftoverAuthority(
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino)
        )
    }

    private func validateCompleteUTF8(
        _ url: URL,
        expectedAuthority: SourceAuthority,
        maximumBytes: Int64
    ) throws {
        let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        defer { try? handle.close() }
        let authority = try ownedPlaintextAuthority(descriptor: descriptor)
        guard authority == expectedAuthority, authority.byteCount <= maximumBytes else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        var expectedContinuations = 0
        var scalar: UInt32 = 0
        var minimumScalar: UInt32 = 0
        var total: Int64 = 0
        while true {
            try Task.checkCancellation()
            guard let bytes = try handle.read(upToCount: bufferBytes), bytes.isEmpty == false else { break }
            total += Int64(bytes.count)
            guard total <= maximumBytes else {
                throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
            }
            for byte in bytes {
                if expectedContinuations == 0 {
                    switch byte {
                    case 0x00...0x7f:
                        continue
                    case 0xc2...0xdf:
                        expectedContinuations = 1
                        scalar = UInt32(byte & 0x1f)
                        minimumScalar = 0x80
                    case 0xe0...0xef:
                        expectedContinuations = 2
                        scalar = UInt32(byte & 0x0f)
                        minimumScalar = 0x800
                    case 0xf0...0xf4:
                        expectedContinuations = 3
                        scalar = UInt32(byte & 0x07)
                        minimumScalar = 0x10000
                    default:
                        throw RuntimeCanonicalAttachmentError.signatureMismatch
                    }
                } else {
                    guard byte & 0xc0 == 0x80 else {
                        throw RuntimeCanonicalAttachmentError.signatureMismatch
                    }
                    scalar = (scalar << 6) | UInt32(byte & 0x3f)
                    expectedContinuations -= 1
                    if expectedContinuations == 0 {
                        guard scalar >= minimumScalar, scalar <= 0x10ffff,
                              (0xd800...0xdfff).contains(scalar) == false else {
                            throw RuntimeCanonicalAttachmentError.signatureMismatch
                        }
                    }
                }
            }
        }
        guard expectedContinuations == 0, total == authority.byteCount,
              try ownedPlaintextAuthority(descriptor: descriptor) == authority else {
            throw RuntimeCanonicalAttachmentError.signatureMismatch
        }
        try requirePathIdentity(url, authority: authority)
    }

    private func normalizeFilename(_ raw: String) throws -> String {
        let source = URL(fileURLWithPath: raw).lastPathComponent
            .precomposedStringWithCanonicalMapping
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let invalid = CharacterSet(charactersIn: "/\\:").union(.controlCharacters)
        let components = source.components(separatedBy: invalid).filter { $0.isEmpty == false }
        let normalized = components.joined(separator: "-")
        guard RuntimeAttachmentCodec.validFilename(normalized) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return normalized
    }

    private func rawDirectoryEntries(
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
        guard lstat(standardized.path, &after) == 0,
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

    private func insertBoundedRawDirectoryEntry(
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

    private func insertBoundedSorted(
        _ value: String,
        into values: inout [String],
        limit: Int
    ) {
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

    private func ensureIntakeRoot() throws {
        try fileManager.createDirectory(at: intakeRoot, withIntermediateDirectories: true)
        let values = try intakeRoot.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: intakeRoot.path
        )
        try verifyIntakeProtection(intakeRoot)
        #endif
    }

    private func ensureIntakeLeftoverCapacity() throws {
        var count = 0
        var cursor: String?
        repeat {
            let page = try rawDirectoryEntries(
                at: intakeRoot,
                limit: RuntimeAttachmentLimits.maximumPageSize,
                afterRawCursor: cursor
            )
            for entry in page.entries where
                entry.rawBytes.starts(with: Data("intake-".utf8)) &&
                entry.rawBytes.suffix(Data(".part".utf8).count) == Data(".part".utf8) {
                count += 1
                guard count < Self.maximumOwnedIntakeLeftoverCount else {
                    throw RuntimeCanonicalAttachmentError.quotaExceeded
                }
            }
            cursor = page.nextRawCursor
            if page.exhausted { break }
        } while cursor != nil
    }

    private func validateOwnedIntakeFilename(_ filename: String) throws {
        let token = filename.dropFirst("intake-".count).dropLast(".part".count)
        guard filename.hasPrefix("intake-"), filename.hasSuffix(".part"),
              filename == filename.precomposedStringWithCanonicalMapping,
              token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func verifyIntakeProtection(_ url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif
    }

    private func synchronizeIntakeRoot() throws {
        let descriptor = Darwin.open(
            intakeRoot.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(intakeRoot.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino),
              (fcntl(descriptor, F_FULLFSYNC) == 0 || fsync(descriptor) == 0) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func quarantineReason(_ error: RuntimeCanonicalAttachmentError) -> RuntimeAttachmentQuarantineReason {
        switch error {
        case .contentTypeMismatch: .contentTypeMismatch
        case .signatureMismatch: .signatureMismatch
        case .sizeLimitExceeded, .quotaExceeded: .sizeLimitExceeded
        case .manifestInvalid: .manifestMismatch
        case .chunkAuthenticationFailed, .keyEnvelopeInvalid: .authenticationFailed
        case .protectedDataUnavailable: .protectionInsufficient
        case .pathAuthorityDenied, .symbolicLinkDenied, .fileIdentityChanged: .pathAuthorityViolation
        case let .unsupportedVersion(_, _): .futureFormat
        default: .malformedSource
        }
    }

    private func evidenceFingerprint(
        part: RuntimeAttachmentIntakePart, error: RuntimeCanonicalAttachmentError
    ) -> String {
        RuntimeAttachmentCodec.sha256(Data(
            "ambitions.attachment.intake-failure.v1\u{0}\(part.attachmentID.rawValue)\u{0}\(part.revisionID.rawValue)\u{0}\(String(describing: error))".utf8
        ))
    }
}
