import CryptoKit
import Darwin
import Foundation
import Security

struct RuntimeAttachmentPortableExportKey: Sendable {
    let identifier: String
    let key: SymmetricKey
}

private enum RuntimeAttachmentPortableKeySelector {
    static let challengeByteCount = 32

    static func makeChallenge() throws -> Data {
        var bytes = Data(repeating: 0, count: challengeByteCount)
        let status = bytes.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, challengeByteCount, buffer.baseAddress!)
        }
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return bytes
    }

    static func derive(from key: SymmetricKey, challenge: Data) throws -> String {
        guard challenge.count == challengeByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        var message = Data("ambitions.attachment.portable.key-selector.v2\u{0}".utf8)
        message.append(challenge)
        return Data(HMAC<SHA256>.authenticationCode(
            for: message,
            using: key
        )).map { String(format: "%02x", $0) }.joined()
    }

    static func matches(_ selector: String, key: SymmetricKey, challenge: Data) -> Bool {
        guard let derived = try? derive(from: key, challenge: challenge) else { return false }
        let expected = Data(derived.utf8)
        let supplied = Data(selector.utf8)
        guard expected.count == supplied.count else { return false }
        var difference: UInt8 = 0
        for index in expected.indices { difference |= expected[index] ^ supplied[index] }
        return difference == 0
    }
}

protocol RuntimeAttachmentPortableExportCustody: Sendable {
    func exportKey() async throws -> RuntimeAttachmentPortableExportKey
    func exportKey(selector: String, challenge: Data) async throws -> RuntimeAttachmentPortableExportKey
}

extension RuntimeAttachmentPortableExportCustody {
    func exportKey(
        selector: String, challenge: Data
    ) async throws -> RuntimeAttachmentPortableExportKey {
        let candidate = try await exportKey()
        guard challenge.count == RuntimeAttachmentPortableKeySelector.challengeByteCount,
              RuntimeStoreManifestCodec.isSHA256Hex(selector),
              RuntimeAttachmentPortableKeySelector.matches(
                  selector, key: candidate.key, challenge: challenge
              ) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return candidate
    }
}

/// Device-local convenience custody. Exports encrypted with this key can be
/// reopened only while this installation's non-synchronizable Keychain item survives.
actor DeviceLocalRuntimeAttachmentExportCustody: RuntimeAttachmentPortableExportCustody {
    private static let account = "attachment-portable-export-key.v1"
    private let service: String

    init(service: String = "com.ambitions.runtime.attachment-exports") {
        self.service = service
    }

    func exportKey() async throws -> RuntimeAttachmentPortableExportKey {
        try Task.checkCancellation()
        if let existing = try load() {
            guard existing.count == 32 else {
                throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
            }
            return RuntimeAttachmentPortableExportKey(
                identifier: "ambitions.attachment.export.main.v1",
                key: SymmetricKey(data: existing)
            )
        }
        let key = SymmetricKey(size: .bits256)
        let bytes = key.withUnsafeBytes { Data($0) }
        var query = baseQuery
        query[kSecValueData as String] = bytes
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem, let raced = try load(), raced.count == 32 {
            return RuntimeAttachmentPortableExportKey(
                identifier: "ambitions.attachment.export.main.v1",
                key: SymmetricKey(data: raced)
            )
        }
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return RuntimeAttachmentPortableExportKey(
            identifier: "ambitions.attachment.export.main.v1", key: key
        )
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Self.account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
    }

    private func load() throws -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let bytes = result as? Data else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return bytes
    }
}

protocol RuntimeAttachmentPortableCleanupJobCustody: Sendable {
    func authenticationKey() async throws -> SymmetricKey
}

/// Independent device-local custody for authenticating plaintext cleanup jobs.
/// Recovery never needs the archive decryption key.
actor DeviceLocalRuntimeAttachmentCleanupJobCustody: RuntimeAttachmentPortableCleanupJobCustody {
    private static let account = "attachment-portable-import-cleanup-key.v1"
    private let service: String

    init(service: String = "com.ambitions.runtime.attachment-import-cleanup") {
        self.service = service
    }

    func authenticationKey() async throws -> SymmetricKey {
        try Task.checkCancellation()
        if let existing = try load() {
            guard existing.count == 32 else {
                throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
            }
            return SymmetricKey(data: existing)
        }
        let key = SymmetricKey(size: .bits256)
        let bytes = key.withUnsafeBytes { Data($0) }
        var query = baseQuery
        query[kSecValueData as String] = bytes
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem, let raced = try load(), raced.count == 32 {
            return SymmetricKey(data: raced)
        }
        guard status == errSecSuccess else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return key
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: Self.account,
            kSecAttrSynchronizable as String: kCFBooleanFalse as Any,
        ]
    }

    private func load() throws -> Data? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let bytes = result as? Data else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return bytes
    }
}

/// Explicit recovery-key-package custody for transfers where the caller moves
/// the same 256-bit key package through a separate, user-controlled channel.
actor RuntimeAttachmentRecoveryKeyPackageCustody: RuntimeAttachmentPortableExportCustody {
    private let value: RuntimeAttachmentPortableExportKey

    init(identifier: String, keyMaterial: Data) throws {
        guard identifier.isEmpty == false, identifier.utf8.count <= 256,
              identifier == identifier.precomposedStringWithCanonicalMapping,
              keyMaterial.count == 32 else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        value = RuntimeAttachmentPortableExportKey(
            identifier: identifier, key: SymmetricKey(data: keyMaterial)
        )
    }

    func exportKey() async throws -> RuntimeAttachmentPortableExportKey {
        try Task.checkCancellation()
        return value
    }
}

struct RuntimeAttachmentPortableExportReceipt: Sendable, Equatable {
    let exportKeyIdentifier: String
    let revisionID: RuntimeAttachmentRevisionID
    let destinationFilename: String
    let encryptedByteCount: Int64
    let exportDigest: String
    let holdReleasePending: Bool
    let holdExpiresAt: Date
}

struct RuntimeAttachmentPortableImportReceipt: Sendable, Equatable {
    let exportKeyIdentifier: String
    let revisionID: RuntimeAttachmentRevisionID
    let manifestDigest: String
    let privacy: EventLedgerPrivacyClassification
    let classification: RuntimeAttachmentContentClassification
    let plaintextByteCount: Int64
    let chunkCount: Int
    let exportDigest: String
    let ownedPlaintextURL: URL
}

struct RuntimeAttachmentPortableImportRequest: Sendable {
    let sourceURL: URL
    let requiresSecurityScopedAccess: Bool
    let attachmentID: RuntimeAttachmentID
    let revisionID: RuntimeAttachmentRevisionID
    let revision: UInt64
    let blobID: RuntimeBlobID
    let reservationID: RuntimeBlobQuotaReservationID
    let dedupPolicy: RuntimeAttachmentDedupPolicy
    let retentionUntil: Date?
    let acceptedAt: Date
}

struct RuntimeAttachmentPortableImportCleanupRecovery: Sendable, Equatable {
    let receipt: RuntimeAttachmentPortableImportReceipt
    let evidenceFingerprint: String
}

enum RuntimeAttachmentPortableImportCleanupState: Sendable, Equatable {
    case completed
    case pendingRecovery(RuntimeAttachmentPortableImportCleanupRecovery)
}

struct RuntimeAttachmentPortableImportResult: Sendable, Equatable {
    let intake: RuntimeAttachmentIntakeBatchResult
    let exportKeyIdentifier: String
    let sourceRevisionID: RuntimeAttachmentRevisionID
    let exportDigest: String
    let cleanup: RuntimeAttachmentPortableImportCleanupState
}

private struct RuntimeAttachmentPortablePreamble: Codable, Equatable {
    let format: String
    let version: Int
    let challenge: Data
    let keySelector: String
}

private struct RuntimeAttachmentPortableHeader: Codable, Equatable {
    let version: Int
    let keyIdentifier: String
    let revisionID: RuntimeAttachmentRevisionID
    let manifestDigest: String
    let privacy: EventLedgerPrivacyClassification
    let classification: RuntimeAttachmentContentClassification
    let chunkSize: Int
    let plaintextByteCount: Int64
}

private struct RuntimeAttachmentPortableTerminal: Codable, Equatable {
    let version: Int
    let preambleDigest: String
    let headerDigest: String
    let encryptedHeaderDigest: String
    let chunkCount: Int
    let plaintextByteCount: Int64
    let framedContentByteCount: Int64
    let orderedCiphertextDigest: String
}

private enum RuntimeAttachmentPortableMetadataPadding {
    static let plaintextByteCount = RuntimeAttachmentLimits.maximumManifestBytes

    static func pad(_ header: Data) throws -> Data {
        guard header.isEmpty == false,
              header.count <= plaintextByteCount - MemoryLayout<UInt32>.size else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        var result = Data(capacity: plaintextByteCount)
        result.append(withUnsafeBytes(of: UInt32(header.count).bigEndian) { Data($0) })
        result.append(header)
        result.append(Data(repeating: 0, count: plaintextByteCount - result.count))
        guard result.count == plaintextByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return result
    }

    static func unpad(_ value: Data) throws -> Data {
        guard value.count == plaintextByteCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let lengthBytes = value.prefix(MemoryLayout<UInt32>.size)
        let length = lengthBytes.reduce(0) { ($0 << 8) | Int($1) }
        guard length > 0, length <= plaintextByteCount - MemoryLayout<UInt32>.size else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let headerEnd = MemoryLayout<UInt32>.size + length
        guard value.suffix(from: headerEnd).allSatisfy({ $0 == 0 }) else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return value.subdata(in: MemoryLayout<UInt32>.size..<headerEnd)
    }
}

actor RuntimeAttachmentPortableExporter {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault
    private let custody: any RuntimeAttachmentPortableExportCustody
    private let accessAuthority: RuntimeAttachmentAccessAuthority
    private let fileManager: FileManager
    private let exportToken: @Sendable () -> String
    private let holdID: @Sendable () -> RuntimeBlobHoldID
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        vault: RuntimeAttachmentVault,
        custody: any RuntimeAttachmentPortableExportCustody,
        accessAuthority: RuntimeAttachmentAccessAuthority,
        fileManager: FileManager = .default,
        exportToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        holdID: @escaping @Sendable () -> RuntimeBlobHoldID = {
            RuntimeBlobHoldID(rawValue: UUID().uuidString.lowercased())!
        },
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.vault = vault
        self.custody = custody
        self.accessAuthority = accessAuthority
        self.fileManager = fileManager
        self.exportToken = exportToken
        self.holdID = holdID
        self.clock = clock
    }

    func export(
        grant: RuntimeAttachmentReadGrant,
        destinationURL: URL,
        requiresSecurityScopedAccess: Bool
    ) async throws -> RuntimeAttachmentPortableExportReceipt {
        let authority = try await accessAuthority.authenticatedAuthority(
            grant: grant, allowedPurpose: .userInitiatedExport
        )
        guard destinationURL.lastPathComponent.isEmpty == false,
              fileManager.fileExists(atPath: destinationURL.path) == false else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let holdExpiresAt = authority.authenticatedAt.addingTimeInterval(
            RuntimeAttachmentLimits.maximumLeaseSeconds
        )
        let holdID = self.holdID()
        let holdAuthorityID = "export-grant:\(grant.receiptID.rawValue):\(holdID.rawValue)"
        let hold = RuntimeBlobRetentionHold(
            version: runtimeCanonicalAttachmentModelVersion, holdID: holdID,
            blobID: authority.blobID, kind: .export,
            authorityID: holdAuthorityID, retainUntil: holdExpiresAt,
            createdAt: authority.authenticatedAt
        )
        let snapshot = try await store.acquireAuthenticatedAttachmentReadHold(
            hold, revisionID: authority.revisionID,
            commandID: authority.commandID, receiptID: authority.receiptID,
            lineage: authority.lineage
        )
        var holdReleased = false
        do {
        let didAccess = requiresSecurityScopedAccess && destinationURL.startAccessingSecurityScopedResource()
        if requiresSecurityScopedAccess && didAccess == false {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        defer { if didAccess { destinationURL.stopAccessingSecurityScopedResource() } }
        let exportKey = try await custody.exportKey()
        guard Self.validKeyIdentifier(exportKey.identifier) else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        let challenge = try RuntimeAttachmentPortableKeySelector.makeChallenge()
        let preamble = RuntimeAttachmentPortablePreamble(
            format: "ambitions.attachment.portable", version: 2,
            challenge: challenge,
            keySelector: try RuntimeAttachmentPortableKeySelector.derive(
                from: exportKey.key, challenge: challenge
            )
        )
        let preambleBytes = try RuntimeAttachmentCodec.encode(
            preamble, maximumBytes: 4_096
        )
        let preambleDigest = RuntimeAttachmentCodec.sha256(preambleBytes)
        let header = RuntimeAttachmentPortableHeader(
            version: 2, keyIdentifier: exportKey.identifier,
            revisionID: snapshot.revision.revisionID,
            manifestDigest: snapshot.revision.manifestDigest,
            privacy: snapshot.revision.privacy,
            classification: snapshot.revision.classification,
            chunkSize: snapshot.manifest.chunkSize,
            plaintextByteCount: snapshot.manifest.plaintextByteCount
        )
        let headerBytes = try RuntimeAttachmentCodec.encode(
            header, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let headerDigest = RuntimeAttachmentCodec.sha256(headerBytes)
        let paddedHeaderBytes = try RuntimeAttachmentPortableMetadataPadding.pad(headerBytes)
        let sealedHeader = try AES.GCM.seal(
            paddedHeaderBytes, using: exportKey.key,
            authenticating: Data(
                "ambitions.attachment.portable.metadata.v2\u{0}\(preambleDigest)".utf8
            )
        )
        guard let encryptedHeaderBytes = sealedHeader.combined else {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let encryptedHeaderDigest = RuntimeAttachmentCodec.sha256(encryptedHeaderBytes)
        let temporary = destinationURL.deletingLastPathComponent()
            .appendingPathComponent(".ambitions-export-\(try validatedExportToken())", isDirectory: false)
        let output = try createExclusiveOutput(temporary)
        var removeTemporary = true
        defer { if removeTemporary { try? fileManager.removeItem(at: temporary) } }
        defer { try? output.close() }
        let preambleLength = try encodedLength(preambleBytes.count)
        let encryptedHeaderLength = try encodedLength(encryptedHeaderBytes.count)
        try output.write(contentsOf: preambleLength)
        try output.write(contentsOf: preambleBytes)
        try output.write(contentsOf: encryptedHeaderLength)
        try output.write(contentsOf: encryptedHeaderBytes)
        var digest = SHA256()
        digest.update(data: preambleLength)
        digest.update(data: preambleBytes)
        digest.update(data: encryptedHeaderLength)
        digest.update(data: encryptedHeaderBytes)
        var orderedCiphertext = SHA256()
        orderedCiphertext.update(data: preambleBytes)
        orderedCiphertext.update(data: encryptedHeaderBytes)
        var cursor: RuntimeAttachmentReadCursor?
        var chunkIndex = 0
        var written = Int64(8 + preambleBytes.count + encryptedHeaderBytes.count)
        var plaintextBytes = Int64(0)
        repeat {
            try Task.checkCancellation()
            guard clock() < holdExpiresAt else {
                throw RuntimeCanonicalAttachmentError.invalidLease
            }
            let page = try await vault.readPage(snapshot: snapshot, cursor: cursor)
            let aad = Data(
                "ambitions.attachment.portable.chunk.v2\u{0}\(preambleDigest)\u{0}\(encryptedHeaderDigest)\u{0}\(chunkIndex)".utf8
            )
            let sealed = try AES.GCM.seal(page.bytes, using: exportKey.key, authenticating: aad)
            guard let combined = sealed.combined else {
                throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
            }
            let frameLength = try encodedLength(combined.count)
            try output.write(contentsOf: frameLength)
            try output.write(contentsOf: combined)
            digest.update(data: frameLength)
            digest.update(data: combined)
            orderedCiphertext.update(data: withUnsafeBytes(of: UInt64(chunkIndex).bigEndian) { Data($0) })
            orderedCiphertext.update(data: combined)
            written += Int64(4 + combined.count)
            plaintextBytes += Int64(page.bytes.count)
            cursor = page.nextCursor
            chunkIndex += 1
        } while cursor != nil
        guard plaintextBytes == snapshot.manifest.plaintextByteCount,
              chunkIndex == snapshot.manifest.chunkCount else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let terminal = RuntimeAttachmentPortableTerminal(
            version: 2, preambleDigest: preambleDigest,
            headerDigest: headerDigest, encryptedHeaderDigest: encryptedHeaderDigest,
            chunkCount: chunkIndex, plaintextByteCount: plaintextBytes,
            framedContentByteCount: written,
            orderedCiphertextDigest: orderedCiphertext.finalize().map {
                String(format: "%02x", $0)
            }.joined()
        )
        let terminalBytes = try RuntimeAttachmentCodec.encode(
            terminal, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let sealedTerminal = try AES.GCM.seal(
            terminalBytes, using: exportKey.key,
            authenticating: Data(
                "ambitions.attachment.portable.terminal.v2\u{0}\(preambleDigest)\u{0}\(encryptedHeaderDigest)".utf8
            )
        )
        guard let combinedTerminal = sealedTerminal.combined else {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let terminalLength = try encodedLength(combinedTerminal.count)
        try output.write(contentsOf: terminalLength)
        try output.write(contentsOf: combinedTerminal)
        digest.update(data: terminalLength)
        digest.update(data: combinedTerminal)
        written += Int64(4 + combinedTerminal.count)
        try output.synchronize()
        try fileManager.moveItem(at: temporary, to: destinationURL)
        do {
            try synchronizeParentDirectory(of: destinationURL)
        } catch {
            try? fileManager.removeItem(at: destinationURL)
            try? synchronizeParentDirectory(of: destinationURL)
            throw error
        }
        removeTemporary = false
        var holdReleasePending = false
        do {
            try await store.releaseAttachmentRetentionHold(
                holdID: holdID, blobID: hold.blobID, authorityID: holdAuthorityID,
                commandID: authority.commandID, receiptID: authority.receiptID,
                lineage: authority.lineage, at: clock()
            )
            holdReleased = true
        } catch is CancellationError {
            // The destination is already atomically installed and synchronized.
            // Report the committed export truthfully; the finite hold can expire
            // or be released by recovery.
            holdReleasePending = true
        } catch {
            holdReleasePending = true
        }
        let receipt = RuntimeAttachmentPortableExportReceipt(
            exportKeyIdentifier: exportKey.identifier,
            revisionID: snapshot.revision.revisionID,
            destinationFilename: destinationURL.lastPathComponent,
            encryptedByteCount: written,
            exportDigest: digest.finalize().map { String(format: "%02x", $0) }.joined(),
            holdReleasePending: holdReleasePending,
            holdExpiresAt: holdExpiresAt
        )
        return receipt
        } catch {
            let exportError = error
            if holdReleased == false {
                do {
                    try await store.releaseAttachmentRetentionHold(
                        holdID: holdID, blobID: hold.blobID, authorityID: holdAuthorityID,
                        commandID: authority.commandID, receiptID: authority.receiptID,
                        lineage: authority.lineage, at: clock()
                    )
                } catch {
                    if exportError is CancellationError {
                        // Before durable destination commit there is no successful
                        // export result. Preserve cancellation; the hold is finite.
                        throw CancellationError()
                    }
                    throw RuntimeCanonicalAttachmentError.retentionHoldReleasePending
                }
            }
            if exportError is CancellationError { throw CancellationError() }
            throw exportError
        }
    }

    private func encodedLength(_ value: Int) throws -> Data {
        guard value > 0, value <= Int(UInt32.max) else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        return withUnsafeBytes(of: UInt32(value).bigEndian) { Data($0) }
    }

    private func createExclusiveOutput(_ url: URL) throws -> FileHandle {
        let descriptor = Darwin.open(
            url.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        return FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    }

    private func synchronizeParentDirectory(of url: URL) throws {
        let parent = url.deletingLastPathComponent().standardizedFileURL
        let descriptor = Darwin.open(
            parent.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(parent.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino),
              (fcntl(descriptor, F_FULLFSYNC) == 0 || fsync(descriptor) == 0) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func validatedExportToken() throws -> String {
        let value = exportToken()
        guard value.isEmpty == false, value.utf8.count <= 128,
              value == value.precomposedStringWithCanonicalMapping,
              value.unicodeScalars.allSatisfy({
                  CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_")).contains($0)
              }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return value
    }

    private static func validKeyIdentifier(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.count <= 256 &&
            value == value.precomposedStringWithCanonicalMapping &&
            value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }
}

actor RuntimeAttachmentPortableImporter {
    private static let maximumCleanupNamespaceEntries = 4_096

    private enum CleanupJobState: String, Codable {
        case authorized
        case destinationCreated = "destination_created"
    }

    private struct CleanupJobMaterial: Codable {
        let version: Int
        let jobID: String
        let plaintextFilename: String
        let state: CleanupJobState
        let device: UInt64?
        let inode: UInt64?
        let createdAt: Date
    }

    private struct CleanupJob: Codable {
        let material: CleanupJobMaterial
        let authenticationCode: Data
    }

    private struct FileAuthority: Equatable {
        let device: UInt64
        let inode: UInt64
        let byteCount: Int64
    }

    private enum CleanupRecoveryEntry {
        case owned(rawName: Data, name: String)
        case malformed(rawName: Data, redactedNameDigest: String)

        var rawName: Data {
            switch self {
            case let .owned(rawName, _), let .malformed(rawName, _): return rawName
            }
        }
    }

    private struct CleanupRecoveryPage {
        let entries: [CleanupRecoveryEntry]
        let nextRawCursor: Data?
        let exhausted: Bool
    }

    private struct CleanupRecoveryCursorMaterial: Codable {
        let version: Int
        let rawCursor: Data?
        let updatedAt: Date
    }

    private struct CleanupRecoveryCursorRecord: Codable {
        let material: CleanupRecoveryCursorMaterial
        let authenticationCode: Data
    }

    private let cleanupCustody: any RuntimeAttachmentPortableCleanupJobCustody
    private let importRoot: URL
    private let fileManager: FileManager
    private let importToken: @Sendable () -> String
    private let clock: @Sendable () -> Date

    init(
        cleanupCustody: any RuntimeAttachmentPortableCleanupJobCustody,
        importRoot: URL,
        fileManager: FileManager = .default,
        importToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        self.cleanupCustody = cleanupCustody
        self.importRoot = importRoot.standardizedFileURL
        self.fileManager = fileManager
        self.importToken = importToken
        self.clock = clock
        try Self.prepareImportRoot(self.importRoot, fileManager: fileManager)
    }

    func decrypt(
        sourceURL: URL,
        requiresSecurityScopedAccess: Bool,
        custody: any RuntimeAttachmentPortableExportCustody
    ) async throws -> RuntimeAttachmentPortableImportReceipt {
        let didAccess = requiresSecurityScopedAccess && sourceURL.startAccessingSecurityScopedResource()
        if requiresSecurityScopedAccess && didAccess == false {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        defer { if didAccess { sourceURL.stopAccessingSecurityScopedResource() } }

        let sourceDescriptor = Darwin.open(sourceURL.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard sourceDescriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        let source = FileHandle(fileDescriptor: sourceDescriptor, closeOnDealloc: true)
        defer { try? source.close() }
        let sourceAuthority = try regularFileAuthority(sourceDescriptor)
        let maximumPortableBytes = RuntimeAttachmentLimits.maximumAttachmentBytes +
            Int64(RuntimeAttachmentLimits.maximumChunks * 128) +
            Int64(RuntimeAttachmentLimits.maximumManifestBytes * 2)
        guard sourceAuthority.byteCount <= maximumPortableBytes else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }

        try verifyImportRoot()
        let cleanupAuthenticationKey = try await cleanupCustody.authenticationKey()
        let importJobID = try validatedImportToken()
        let ownedPlaintextDestinationURL = importRoot.appendingPathComponent(
            "import-\(importJobID).part", isDirectory: false
        )
        let cleanupJobURL = importRoot.appendingPathComponent(
            "cleanup-\(importJobID).json", isDirectory: false
        )
        let authorizedCleanup = CleanupJobMaterial(
            version: 1,
            jobID: importJobID,
            plaintextFilename: ownedPlaintextDestinationURL.lastPathComponent,
            state: .authorized,
            device: nil,
            inode: nil,
            createdAt: clock()
        )
        try persistCleanupJob(
            authorizedCleanup,
            at: cleanupJobURL,
            key: cleanupAuthenticationKey,
            replacingExisting: false
        )
        var preserveForCoordinator = false
        defer {
            if preserveForCoordinator == false {
                try? removeOwnedImportPair(
                    plaintextURL: ownedPlaintextDestinationURL,
                    cleanupJobURL: cleanupJobURL,
                    key: cleanupAuthenticationKey
                )
            }
        }
        let destinationDescriptor = Darwin.open(
            ownedPlaintextDestinationURL.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard destinationDescriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let destination = FileHandle(fileDescriptor: destinationDescriptor, closeOnDealloc: true)
        defer { try? destination.close() }
        let destinationIdentity = try regularFileIdentity(
            destinationDescriptor, allowsEmpty: true, requiresSingleLink: true
        )
        try applyImportProtection(
            ownedPlaintextDestinationURL,
            descriptor: destinationDescriptor,
            expectedAuthority: destinationIdentity
        )
        try persistCleanupJob(
            CleanupJobMaterial(
                version: authorizedCleanup.version,
                jobID: authorizedCleanup.jobID,
                plaintextFilename: authorizedCleanup.plaintextFilename,
                state: .destinationCreated,
                device: destinationIdentity.device,
                inode: destinationIdentity.inode,
                createdAt: authorizedCleanup.createdAt
            ),
            at: cleanupJobURL,
            key: cleanupAuthenticationKey,
            replacingExisting: true
        )

        var exportDigest = SHA256()
        let preambleFrame = try readRequiredFrame(source, maximumBytes: 4_096)
        exportDigest.update(data: preambleFrame.lengthBytes)
        exportDigest.update(data: preambleFrame.bytes)
        let preamble = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentPortablePreamble.self, bytes: preambleFrame.bytes,
            maximumBytes: 4_096
        )
        guard preamble.format == "ambitions.attachment.portable",
              preamble.version == 2,
              preamble.challenge.count == RuntimeAttachmentPortableKeySelector.challengeByteCount,
              RuntimeStoreManifestCodec.isSHA256Hex(preamble.keySelector) else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let exportKey = try await custody.exportKey(
            selector: preamble.keySelector, challenge: preamble.challenge
        )
        let preambleDigest = RuntimeAttachmentCodec.sha256(preambleFrame.bytes)
        let encryptedHeaderFrame = try readRequiredFrame(
            source, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes + 64
        )
        exportDigest.update(data: encryptedHeaderFrame.lengthBytes)
        exportDigest.update(data: encryptedHeaderFrame.bytes)
        let encryptedHeaderDigest = RuntimeAttachmentCodec.sha256(encryptedHeaderFrame.bytes)
        let paddedHeaderBytes: Data
        do {
            paddedHeaderBytes = try AES.GCM.open(
                AES.GCM.SealedBox(combined: encryptedHeaderFrame.bytes),
                using: exportKey.key,
                authenticating: Data(
                    "ambitions.attachment.portable.metadata.v2\u{0}\(preambleDigest)".utf8
                )
            )
        } catch {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let headerBytes = try RuntimeAttachmentPortableMetadataPadding.unpad(paddedHeaderBytes)
        let header = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentPortableHeader.self, bytes: headerBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard header.version == 2,
              Self.validKeyIdentifier(header.keyIdentifier),
              header.keyIdentifier == exportKey.identifier,
              RuntimeAttachmentPortableKeySelector.matches(
                  preamble.keySelector, key: exportKey.key, challenge: preamble.challenge
              ),
              RuntimeStoreManifestCodec.isSHA256Hex(header.manifestDigest),
              RuntimeAttachmentCodec.validFilename(header.classification.normalizedFilename),
              RuntimeAttachmentCodec.validContentType(header.classification.declaredContentType),
              RuntimeAttachmentCodec.validContentType(header.classification.detectedContentType),
              header.classification.signatureVersion == 1,
              header.classification.byteCount == header.plaintextByteCount,
              header.chunkSize >= RuntimeAttachmentLimits.minimumChunkBytes,
              header.chunkSize <= RuntimeAttachmentLimits.maximumChunkBytes,
              header.plaintextByteCount > 0,
              header.plaintextByteCount <= RuntimeAttachmentLimits.maximumAttachmentBytes else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        let headerDigest = RuntimeAttachmentCodec.sha256(headerBytes)
        var orderedCiphertext = SHA256()
        orderedCiphertext.update(data: preambleFrame.bytes)
        orderedCiphertext.update(data: encryptedHeaderFrame.bytes)
        var current = try readRequiredFrame(
            source, maximumBytes: RuntimeAttachmentLimits.maximumChunkBytes + 64
        )
        var chunkIndex = 0
        var plaintextBytes = Int64(0)
        var framedContentBytes = Int64(
            8 + preambleFrame.bytes.count + encryptedHeaderFrame.bytes.count
        )

        while let next = try readFrameOrEOF(
            source, maximumBytes: RuntimeAttachmentLimits.maximumChunkBytes + 64
        ) {
            try Task.checkCancellation()
            let plaintext: Data
            do {
                plaintext = try AES.GCM.open(
                    AES.GCM.SealedBox(combined: current.bytes), using: exportKey.key,
                    authenticating: Data(
                        "ambitions.attachment.portable.chunk.v2\u{0}\(preambleDigest)\u{0}\(encryptedHeaderDigest)\u{0}\(chunkIndex)".utf8
                    )
                )
            } catch {
                throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
            }
            guard plaintext.isEmpty == false,
                  plaintext.count <= header.chunkSize,
                  chunkIndex < RuntimeAttachmentLimits.maximumChunks,
                  plaintextBytes <= header.plaintextByteCount - Int64(plaintext.count) else {
                throw RuntimeCanonicalAttachmentError.manifestInvalid
            }
            try destination.write(contentsOf: plaintext)
            plaintextBytes += Int64(plaintext.count)
            exportDigest.update(data: current.lengthBytes)
            exportDigest.update(data: current.bytes)
            orderedCiphertext.update(
                data: withUnsafeBytes(of: UInt64(chunkIndex).bigEndian) { Data($0) }
            )
            orderedCiphertext.update(data: current.bytes)
            framedContentBytes += Int64(4 + current.bytes.count)
            chunkIndex += 1
            current = next
        }

        exportDigest.update(data: current.lengthBytes)
        exportDigest.update(data: current.bytes)
        let terminalBytes: Data
        do {
            terminalBytes = try AES.GCM.open(
                AES.GCM.SealedBox(combined: current.bytes), using: exportKey.key,
                authenticating: Data(
                    "ambitions.attachment.portable.terminal.v2\u{0}\(preambleDigest)\u{0}\(encryptedHeaderDigest)".utf8
                )
            )
        } catch {
            throw RuntimeCanonicalAttachmentError.chunkAuthenticationFailed
        }
        let terminal = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentPortableTerminal.self, bytes: terminalBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let orderedDigest = orderedCiphertext.finalize().map {
            String(format: "%02x", $0)
        }.joined()
        guard terminal.version == 2,
              terminal.preambleDigest == preambleDigest,
              terminal.headerDigest == headerDigest,
              terminal.encryptedHeaderDigest == encryptedHeaderDigest,
              terminal.chunkCount == chunkIndex,
              terminal.plaintextByteCount == plaintextBytes,
              terminal.plaintextByteCount == header.plaintextByteCount,
              terminal.framedContentByteCount == framedContentBytes,
              terminal.orderedCiphertextDigest == orderedDigest,
              try regularFileAuthority(sourceDescriptor) == sourceAuthority else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        try destination.synchronize()
        let completedIdentity = try regularFileIdentity(
            destinationDescriptor, allowsEmpty: false, requiresSingleLink: true
        )
        guard completedIdentity.device == destinationIdentity.device,
              completedIdentity.inode == destinationIdentity.inode,
              completedIdentity.byteCount == plaintextBytes else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try applyImportProtection(
            ownedPlaintextDestinationURL,
            descriptor: destinationDescriptor,
            expectedAuthority: completedIdentity
        )
        try synchronizeImportRoot()
        preserveForCoordinator = true
        return RuntimeAttachmentPortableImportReceipt(
            exportKeyIdentifier: header.keyIdentifier,
            revisionID: header.revisionID,
            manifestDigest: header.manifestDigest,
            privacy: header.privacy,
            classification: header.classification,
            plaintextByteCount: plaintextBytes,
            chunkCount: chunkIndex,
            exportDigest: exportDigest.finalize().map { String(format: "%02x", $0) }.joined(),
            ownedPlaintextURL: ownedPlaintextDestinationURL
        )
    }

    func removeOwnedImport(_ receipt: RuntimeAttachmentPortableImportReceipt) async throws {
        let candidate = receipt.ownedPlaintextURL.standardizedFileURL
        let jobID = try validatedImportJobID(candidate.lastPathComponent)
        let jobURL = importRoot.appendingPathComponent(
            "cleanup-\(jobID).json", isDirectory: false
        )
        let key = try await cleanupCustody.authenticationKey()
        try removeOwnedImportPair(plaintextURL: candidate, cleanupJobURL: jobURL, key: key)
    }

    /// Bounded startup recovery for authenticated cleanup jobs. An authenticated
    /// raw-byte cursor advances before an error is returned, so a persistently
    /// failing early entry cannot starve later pages across process restarts.
    /// Recovery does not consult archive-key custody or decrypt source archives.
    func recoverInterruptedImports(limit: Int) async throws -> Int {
        guard limit > 0, limit <= 4_096 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try verifyImportRoot()
        let key = try await cleanupCustody.authenticationKey()
        let rawCursor = try loadCleanupRecoveryCursor(key: key)
        let page = try cleanupRecoveryPage(limit: limit, afterRawCursor: rawCursor)
        var recovered = 0
        var firstFailure: Error?
        for entry in page.entries {
            let name: String
            switch entry {
            case let .malformed(_, redactedNameDigest):
                // Malformed entries are represented and advance the raw
                // cursor, but never gain cleanup authority.
                guard RuntimeStoreManifestCodec.isSHA256Hex(redactedNameDigest) else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
                continue
            case let .owned(_, ownedName):
                name = ownedName
            }
            do {
                if name.hasSuffix(".pending") {
                    try removeOwnedRegularFile(
                        importRoot.appendingPathComponent(name, isDirectory: false),
                        expectedAuthority: nil
                    )
                    recovered += 1
                    continue
                }
                let jobURL = importRoot.appendingPathComponent(name, isDirectory: false)
                let job = try loadAuthenticatedCleanupJob(at: jobURL, key: key)
                let plaintextURL = importRoot.appendingPathComponent(
                    job.material.plaintextFilename, isDirectory: false
                )
                try removeOwnedImportPair(
                    plaintextURL: plaintextURL, cleanupJobURL: jobURL, key: key
                )
                recovered += 1
            } catch {
                if firstFailure == nil { firstFailure = error }
            }
        }
        let nextCursor = page.exhausted ? nil : page.nextRawCursor
        if page.exhausted == false, nextCursor == nil {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        try persistCleanupRecoveryCursor(nextCursor, key: key)
        if let firstFailure { throw firstFailure }
        return recovered
    }

    private func persistCleanupJob(
        _ material: CleanupJobMaterial,
        at jobURL: URL,
        key: SymmetricKey,
        replacingExisting: Bool
    ) throws {
        if replacingExisting == false {
            try ensureCleanupNamespaceCapacity()
        }
        let validatedID = try validatedCleanupJobFilename(jobURL.lastPathComponent)
        guard validatedID == material.jobID,
              material.version == 1,
              material.plaintextFilename == "import-\(material.jobID).part",
              (material.state == .authorized && material.device == nil && material.inode == nil) ||
                (material.state == .destinationCreated && material.device != nil && material.inode != nil)
        else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let materialBytes = try RuntimeAttachmentCodec.encode(material, maximumBytes: 4_096)
        let authenticationCode = Data(HMAC<SHA256>.authenticationCode(
            for: materialBytes, using: key
        ))
        let bytes = try RuntimeAttachmentCodec.encode(
            CleanupJob(material: material, authenticationCode: authenticationCode),
            maximumBytes: 8_192
        )
        let pendingURL = importRoot.appendingPathComponent(
            ".\(jobURL.lastPathComponent).pending", isDirectory: false
        )
        guard try pathEntryExistsNoFollow(pendingURL) == false,
              replacingExisting || (try pathEntryExistsNoFollow(jobURL) == false) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let descriptor = Darwin.open(
            pendingURL.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        do {
            let initialAuthority = try regularFileIdentity(
                descriptor, allowsEmpty: true, requiresSingleLink: true
            )
            try applyImportProtection(
                pendingURL, descriptor: descriptor,
                expectedAuthority: initialAuthority
            )
            try handle.write(contentsOf: bytes)
            try handle.synchronize()
            let completedAuthority = try regularFileIdentity(
                descriptor, allowsEmpty: false, requiresSingleLink: true
            )
            guard completedAuthority.device == initialAuthority.device,
                  completedAuthority.inode == initialAuthority.inode,
                  completedAuthority.byteCount == Int64(bytes.count) else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            try applyImportProtection(
                pendingURL, descriptor: descriptor,
                expectedAuthority: completedAuthority
            )
            try handle.close()
            guard Darwin.rename(pendingURL.path, jobURL.path) == 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeImportRoot()
            _ = try loadAuthenticatedCleanupJob(at: jobURL, key: key)
        } catch {
            try? handle.close()
            throw error
        }
    }

    private func loadAuthenticatedCleanupJob(
        at jobURL: URL,
        key: SymmetricKey
    ) throws -> CleanupJob {
        let expectedID = try validatedCleanupJobFilename(jobURL.lastPathComponent)
        let descriptor = Darwin.open(jobURL.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        defer { try? handle.close() }
        let authority = try regularFileIdentity(
            descriptor, allowsEmpty: false, requiresSingleLink: true
        )
        try requireImportPathIdentity(
            jobURL, authority: authority, requiresSingleLink: true
        )
        try verifyImportProtection(jobURL)
        guard authority.byteCount <= 8_192,
              let bytes = try handle.readToEnd(),
              Int64(bytes.count) == authority.byteCount else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        let job = try RuntimeAttachmentCodec.decode(
            CleanupJob.self, bytes: bytes, maximumBytes: 8_192
        )
        let materialBytes = try RuntimeAttachmentCodec.encode(job.material, maximumBytes: 4_096)
        guard job.material.version == 1,
              job.material.jobID == expectedID,
              job.material.plaintextFilename == "import-\(expectedID).part",
              HMAC<SHA256>.isValidAuthenticationCode(
                  job.authenticationCode, authenticating: materialBytes, using: key
              ),
              try regularFileIdentity(
                  descriptor, allowsEmpty: false, requiresSingleLink: true
              ) == authority else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        try requireImportPathIdentity(
            jobURL, authority: authority, requiresSingleLink: true
        )
        try verifyImportProtection(jobURL)
        return job
    }

    private func removeOwnedImportPair(
        plaintextURL: URL,
        cleanupJobURL: URL,
        key: SymmetricKey
    ) throws {
        try verifyImportRoot()
        let jobExists = try pathEntryExistsNoFollow(cleanupJobURL)
        let plaintextExists = try pathEntryExistsNoFollow(plaintextURL)
        if jobExists == false {
            guard plaintextExists == false else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeImportRoot()
            return
        }
        let job = try loadAuthenticatedCleanupJob(at: cleanupJobURL, key: key)
        guard plaintextURL == importRoot.appendingPathComponent(
            job.material.plaintextFilename, isDirectory: false
        ) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let expectedAuthority: FileAuthority? = {
            guard let device = job.material.device, let inode = job.material.inode else { return nil }
            return FileAuthority(device: device, inode: inode, byteCount: -1)
        }()
        if plaintextExists {
            try removeOwnedRegularFile(plaintextURL, expectedAuthority: expectedAuthority)
        } else {
            try synchronizeImportRoot()
        }
        guard try pathEntryExistsNoFollow(plaintextURL) == false else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        try removeOwnedRegularFile(cleanupJobURL, expectedAuthority: nil)
        guard try pathEntryExistsNoFollow(cleanupJobURL) == false else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func removeOwnedRegularFile(
        _ candidate: URL,
        expectedAuthority: FileAuthority?
    ) throws {
        guard candidate.deletingLastPathComponent().standardizedFileURL == importRoot else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        var pathMetadata = stat()
        if lstat(candidate.path, &pathMetadata) != 0 {
            guard errno == ENOENT else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeImportRoot()
            return
        }
        guard (pathMetadata.st_mode & S_IFMT) == S_IFREG else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let descriptor = Darwin.open(candidate.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        let authority = try regularFileIdentity(
            descriptor, allowsEmpty: true, requiresSingleLink: true
        )
        if let expectedAuthority {
            guard expectedAuthority.device == authority.device,
                  expectedAuthority.inode == authority.inode else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
        }
        try applyImportProtection(
            candidate, descriptor: descriptor, expectedAuthority: authority
        )
        var current = stat()
        guard lstat(candidate.path, &current) == 0,
              (current.st_mode & S_IFMT) == S_IFREG,
              current.st_nlink == 1,
              UInt64(current.st_dev) == authority.device,
              UInt64(current.st_ino) == authority.inode,
              try regularFileIdentity(
                  descriptor, allowsEmpty: true, requiresSingleLink: true
              ) == authority else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try fileManager.removeItem(at: candidate)
        try synchronizeImportRoot()
        var deleted = stat()
        guard lstat(candidate.path, &deleted) != 0, errno == ENOENT else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    private func loadCleanupRecoveryCursor(key: SymmetricKey) throws -> Data? {
        let cursorURL = importRoot.appendingPathComponent(
            ".cleanup-recovery-cursor", isDirectory: false
        )
        let pendingURL = importRoot.appendingPathComponent(
            ".cleanup-recovery-cursor.pending", isDirectory: false
        )
        if try pathEntryExistsNoFollow(pendingURL) {
            _ = try authenticatedCleanupRecoveryCursor(at: pendingURL, key: key)
            if try pathEntryExistsNoFollow(cursorURL) {
                _ = try authenticatedCleanupRecoveryCursor(at: cursorURL, key: key)
            }
            guard Darwin.rename(pendingURL.path, cursorURL.path) == 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeImportRoot()
        }
        guard try pathEntryExistsNoFollow(cursorURL) else { return nil }
        return try authenticatedCleanupRecoveryCursor(at: cursorURL, key: key).rawCursor
    }

    private func persistCleanupRecoveryCursor(
        _ rawCursor: Data?,
        key: SymmetricKey
    ) throws {
        guard rawCursor.map({
            $0.isEmpty == false && $0.count <= Int(MAXNAMLEN) &&
                $0.contains(0) == false && $0.contains(UInt8(ascii: "/")) == false
        }) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let cursorURL = importRoot.appendingPathComponent(
            ".cleanup-recovery-cursor", isDirectory: false
        )
        let pendingURL = importRoot.appendingPathComponent(
            ".cleanup-recovery-cursor.pending", isDirectory: false
        )
        guard try pathEntryExistsNoFollow(pendingURL) == false else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        if try pathEntryExistsNoFollow(cursorURL) {
            _ = try authenticatedCleanupRecoveryCursor(at: cursorURL, key: key)
        }
        let material = CleanupRecoveryCursorMaterial(
            version: 1, rawCursor: rawCursor, updatedAt: clock()
        )
        let materialBytes = try RuntimeAttachmentCodec.encode(material, maximumBytes: 2_048)
        let record = CleanupRecoveryCursorRecord(
            material: material,
            authenticationCode: Data(HMAC<SHA256>.authenticationCode(
                for: materialBytes, using: key
            ))
        )
        let bytes = try RuntimeAttachmentCodec.encode(record, maximumBytes: 4_096)
        let descriptor = Darwin.open(
            pendingURL.path,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        do {
            let initial = try regularFileIdentity(
                descriptor, allowsEmpty: true, requiresSingleLink: true
            )
            try applyImportProtection(
                pendingURL, descriptor: descriptor, expectedAuthority: initial
            )
            try handle.write(contentsOf: bytes)
            try handle.synchronize()
            let completed = try regularFileIdentity(
                descriptor, allowsEmpty: false, requiresSingleLink: true
            )
            guard completed.device == initial.device, completed.inode == initial.inode,
                  completed.byteCount == Int64(bytes.count) else {
                throw RuntimeCanonicalAttachmentError.fileIdentityChanged
            }
            try applyImportProtection(
                pendingURL, descriptor: descriptor, expectedAuthority: completed
            )
            try handle.close()
            guard Darwin.rename(pendingURL.path, cursorURL.path) == 0 else {
                throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
            }
            try synchronizeImportRoot()
            let durable = try authenticatedCleanupRecoveryCursor(at: cursorURL, key: key)
            guard durable.rawCursor == rawCursor else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        } catch {
            try? handle.close()
            throw error
        }
    }

    private func authenticatedCleanupRecoveryCursor(
        at url: URL,
        key: SymmetricKey
    ) throws -> CleanupRecoveryCursorMaterial {
        guard url.deletingLastPathComponent().standardizedFileURL == importRoot,
              [".cleanup-recovery-cursor", ".cleanup-recovery-cursor.pending"]
                .contains(url.lastPathComponent) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        defer { try? handle.close() }
        let authority = try regularFileIdentity(
            descriptor, allowsEmpty: false, requiresSingleLink: true
        )
        guard authority.byteCount <= 4_096,
              let bytes = try handle.readToEnd(),
              Int64(bytes.count) == authority.byteCount else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        try requireImportPathIdentity(url, authority: authority, requiresSingleLink: true)
        try verifyImportProtection(url)
        let record = try RuntimeAttachmentCodec.decode(
            CleanupRecoveryCursorRecord.self, bytes: bytes, maximumBytes: 4_096
        )
        let materialBytes = try RuntimeAttachmentCodec.encode(
            record.material, maximumBytes: 2_048
        )
        guard record.material.version == 1,
              record.material.rawCursor.map({
                  $0.isEmpty == false && $0.count <= Int(MAXNAMLEN) &&
                      $0.contains(0) == false &&
                      $0.contains(UInt8(ascii: "/")) == false
              }) ?? true,
              HMAC<SHA256>.isValidAuthenticationCode(
                  record.authenticationCode, authenticating: materialBytes, using: key
              ),
              try regularFileIdentity(
                  descriptor, allowsEmpty: false, requiresSingleLink: true
              ) == authority else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        try requireImportPathIdentity(url, authority: authority, requiresSingleLink: true)
        try verifyImportProtection(url)
        return record.material
    }

    private func cleanupRecoveryPage(
        limit: Int,
        afterRawCursor: Data?
    ) throws -> CleanupRecoveryPage {
        guard limit > 0, limit <= 4_096 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var entries: [CleanupRecoveryEntry] = []
        var matchingCount = 0
        try forEachRawDirectoryEntry(at: importRoot) { rawBytes in
            let isJob = rawBytes.starts(with: Data("cleanup-".utf8)) &&
                rawBytes.suffix(Data(".json".utf8).count) == Data(".json".utf8)
            let isPending = rawBytes.starts(with: Data(".cleanup-".utf8)) &&
                rawBytes.suffix(Data(".json.pending".utf8).count) == Data(".json.pending".utf8)
            guard isJob || isPending else { return }
            matchingCount += 1
            guard matchingCount <= Self.maximumCleanupNamespaceEntries + 1 else {
                throw RuntimeCanonicalAttachmentError.quotaExceeded
            }
            guard afterRawCursor.map({ $0.lexicographicallyPrecedes(rawBytes) }) ?? true else {
                return
            }
            let entry: CleanupRecoveryEntry
            guard let name = String(data: rawBytes, encoding: .utf8) else {
                entry = .malformed(
                    rawName: rawBytes,
                    redactedNameDigest: RuntimeAttachmentCodec.sha256(rawBytes)
                )
                insertBoundedCleanupEntry(entry, into: &entries, limit: limit + 1)
                return
            }
            do {
                if isPending {
                    let core = String(name.dropFirst().dropLast(".pending".count))
                    _ = try validatedCleanupJobFilename(core)
                } else {
                    _ = try validatedCleanupJobFilename(name)
                }
            } catch {
                entry = .malformed(
                    rawName: rawBytes,
                    redactedNameDigest: RuntimeAttachmentCodec.sha256(rawBytes)
                )
                insertBoundedCleanupEntry(entry, into: &entries, limit: limit + 1)
                return
            }
            entry = .owned(rawName: rawBytes, name: name)
            insertBoundedCleanupEntry(entry, into: &entries, limit: limit + 1)
        }
        let selected = Array(entries.prefix(limit))
        return CleanupRecoveryPage(
            entries: selected,
            nextRawCursor: entries.count > limit ? selected.last?.rawName : nil,
            exhausted: entries.count <= limit
        )
    }

    private func ensureCleanupNamespaceCapacity() throws {
        var count = 0
        try forEachRawDirectoryEntry(at: importRoot) { rawBytes in
            let isJob = rawBytes.starts(with: Data("cleanup-".utf8)) &&
                rawBytes.suffix(Data(".json".utf8).count) == Data(".json".utf8)
            let isPending = rawBytes.starts(with: Data(".cleanup-".utf8)) &&
                rawBytes.suffix(Data(".json.pending".utf8).count) == Data(".json.pending".utf8)
            guard isJob || isPending else { return }
            count += 1
            guard count < Self.maximumCleanupNamespaceEntries else {
                throw RuntimeCanonicalAttachmentError.quotaExceeded
            }
        }
    }

    private func insertBoundedCleanupEntry(
        _ value: CleanupRecoveryEntry,
        into values: inout [CleanupRecoveryEntry],
        limit: Int
    ) {
        var lower = 0
        var upper = values.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            if values[middle].rawName.lexicographicallyPrecedes(value.rawName) {
                lower = middle + 1
            } else {
                upper = middle
            }
        }
        guard lower < limit else { return }
        values.insert(value, at: lower)
        if values.count > limit { values.removeLast() }
    }

    private func validatedCleanupJobFilename(_ filename: String) throws -> String {
        guard filename.hasPrefix("cleanup-"), filename.hasSuffix(".json") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let token = String(filename.dropFirst("cleanup-".count).dropLast(".json".count))
        guard token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return token
    }

    private func validatedImportJobID(_ filename: String) throws -> String {
        guard filename.hasPrefix("import-"), filename.hasSuffix(".part") else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let token = String(filename.dropFirst("import-".count).dropLast(".part".count))
        guard token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return token
    }

    private struct Frame {
        let lengthBytes: Data
        let bytes: Data
    }

    private func readRequiredFrame(_ handle: FileHandle, maximumBytes: Int) throws -> Frame {
        guard let frame = try readFrameOrEOF(handle, maximumBytes: maximumBytes) else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return frame
    }

    private func readFrameOrEOF(_ handle: FileHandle, maximumBytes: Int) throws -> Frame? {
        let lengthBytes = try handle.read(upToCount: 4) ?? Data()
        if lengthBytes.isEmpty { return nil }
        guard lengthBytes.count == 4 else { throw RuntimeCanonicalAttachmentError.manifestInvalid }
        let length = lengthBytes.reduce(0) { ($0 << 8) | Int($1) }
        guard length > 0, length <= maximumBytes,
              let bytes = try handle.read(upToCount: length), bytes.count == length else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
        return Frame(lengthBytes: lengthBytes, bytes: bytes)
    }

    private func regularFileAuthority(_ descriptor: Int32) throws -> FileAuthority {
        let authority = try regularFileIdentity(
            descriptor, allowsEmpty: false, requiresSingleLink: false
        )
        guard authority.byteCount > 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return authority
    }

    private func regularFileIdentity(
        _ descriptor: Int32,
        allowsEmpty: Bool,
        requiresSingleLink: Bool
    ) throws -> FileAuthority {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              requiresSingleLink == false || metadata.st_nlink == 1,
              metadata.st_size >= 0,
              allowsEmpty || metadata.st_size > 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        return FileAuthority(
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
            byteCount: Int64(metadata.st_size)
        )
    }

    private func requireImportPathIdentity(
        _ url: URL,
        authority: FileAuthority,
        requiresSingleLink: Bool
    ) throws {
        var metadata = stat()
        guard lstat(url.path, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              requiresSingleLink == false || metadata.st_nlink == 1,
              UInt64(metadata.st_dev) == authority.device,
              UInt64(metadata.st_ino) == authority.inode,
              Int64(metadata.st_size) == authority.byteCount else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    private func applyImportProtection(
        _ url: URL,
        descriptor: Int32,
        expectedAuthority: FileAuthority
    ) throws {
        guard try regularFileIdentity(
            descriptor, allowsEmpty: expectedAuthority.byteCount == 0,
            requiresSingleLink: true
        ) == expectedAuthority else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requireImportPathIdentity(
            url, authority: expectedAuthority, requiresSingleLink: true
        )
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path
        )
        try verifyImportProtection(url)
        #endif
        guard try regularFileIdentity(
            descriptor, allowsEmpty: expectedAuthority.byteCount == 0,
            requiresSingleLink: true
        ) == expectedAuthority else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
        try requireImportPathIdentity(
            url, authority: expectedAuthority, requiresSingleLink: true
        )
    }

    private func pathEntryExistsNoFollow(_ url: URL) throws -> Bool {
        var metadata = stat()
        if lstat(url.path, &metadata) == 0 { return true }
        if errno == ENOENT { return false }
        throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
    }

    private func forEachRawDirectoryEntry(
        at directory: URL,
        _ visit: (Data) throws -> Void
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
            let rawBytes = withUnsafePointer(to: entry.pointee.d_name) { pointer -> Data in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    Data(bytes: $0, count: strnlen($0, Int(MAXNAMLEN) + 1))
                }
            }
            if rawBytes == Data(".".utf8) || rawBytes == Data("..".utf8) { continue }
            try visit(rawBytes)
        }
        var after = stat()
        guard lstat(standardized.path, &after) == 0,
              (after.st_mode & S_IFMT) == S_IFDIR,
              UInt64(after.st_dev) == UInt64(opened.st_dev),
              UInt64(after.st_ino) == UInt64(opened.st_ino) else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    private func verifyImportProtection(_ url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif
    }

    private static func prepareImportRoot(_ root: URL, fileManager: FileManager) throws {
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        let values = try root.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: root.path
        )
        let attributes = try fileManager.attributesOfItem(atPath: root.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif
    }

    private func verifyImportRoot() throws {
        let values = try importRoot.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: importRoot.path)
        guard attributes[.protectionKey] as? FileProtectionType == .complete else {
            throw RuntimeCanonicalAttachmentError.protectedDataUnavailable
        }
        #endif
    }

    private func validatedImportToken() throws -> String {
        let token = importToken().lowercased()
        guard token.isEmpty == false, token.utf8.count <= 128,
              token.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }) else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        return token
    }

    private static func validKeyIdentifier(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.count <= 256 &&
            value == value.precomposedStringWithCanonicalMapping &&
            value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }

    private func synchronizeImportRoot() throws {
        let descriptor = Darwin.open(
            importRoot.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else { throw RuntimeCanonicalAttachmentError.pathAuthorityDenied }
        defer { Darwin.close(descriptor) }
        var opened = stat()
        var current = stat()
        guard fstat(descriptor, &opened) == 0,
              lstat(importRoot.path, &current) == 0,
              (opened.st_mode & S_IFMT) == S_IFDIR,
              (current.st_mode & S_IFMT) == S_IFDIR,
              UInt64(opened.st_dev) == UInt64(current.st_dev),
              UInt64(opened.st_ino) == UInt64(current.st_ino),
              (fcntl(descriptor, F_FULLFSYNC) == 0 || fsync(descriptor) == 0) else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }
}

/// Owns the decrypt-to-intake handoff and always attempts to remove the
/// protected plaintext import. A failed removal is returned as explicit,
/// retryable recovery authority instead of being swallowed.
actor RuntimeAttachmentPortableImportCoordinator {
    private let importer: RuntimeAttachmentPortableImporter
    private let intake: RuntimeAttachmentIntake
    private let custody: any RuntimeAttachmentPortableExportCustody
    private var completedStartupRecovery = false

    init(
        importer: RuntimeAttachmentPortableImporter,
        intake: RuntimeAttachmentIntake,
        custody: any RuntimeAttachmentPortableExportCustody
    ) {
        self.importer = importer
        self.intake = intake
        self.custody = custody
    }

    func importAndStage(
        _ request: RuntimeAttachmentPortableImportRequest
    ) async throws -> RuntimeAttachmentPortableImportResult {
        if completedStartupRecovery == false {
            _ = try await importer.recoverInterruptedImports(limit: 4_096)
            completedStartupRecovery = true
        }
        let receipt = try await importer.decrypt(
            sourceURL: request.sourceURL,
            requiresSecurityScopedAccess: request.requiresSecurityScopedAccess,
            custody: custody
        )
        let intakeResult = await intake.stagePortableImport(
            RuntimeAttachmentPortableIntakeRequest(
                attachmentID: request.attachmentID,
                revisionID: request.revisionID,
                revision: request.revision,
                blobID: request.blobID,
                reservationID: request.reservationID,
                importReceipt: receipt,
                dedupPolicy: request.dedupPolicy,
                retentionUntil: request.retentionUntil,
                acceptedAt: request.acceptedAt
            )
        )
        let cleanup = await cleanupState(for: receipt)
        return RuntimeAttachmentPortableImportResult(
            intake: intakeResult,
            exportKeyIdentifier: receipt.exportKeyIdentifier,
            sourceRevisionID: receipt.revisionID,
            exportDigest: receipt.exportDigest,
            cleanup: cleanup
        )
    }

    func resumeCleanup(
        _ recovery: RuntimeAttachmentPortableImportCleanupRecovery
    ) async -> RuntimeAttachmentPortableImportCleanupState {
        await cleanupState(for: recovery.receipt)
    }

    func recoverInterruptedImports(limit: Int = 4_096) async throws -> Int {
        let recovered = try await importer.recoverInterruptedImports(limit: limit)
        completedStartupRecovery = true
        return recovered
    }

    private func cleanupState(
        for receipt: RuntimeAttachmentPortableImportReceipt
    ) async -> RuntimeAttachmentPortableImportCleanupState {
        do {
            try await importer.removeOwnedImport(receipt)
            return .completed
        } catch {
            let evidence = RuntimeAttachmentCodec.sha256(Data(
                "ambitions.attachment.portable-import.cleanup.v1\u{0}\(receipt.exportDigest)\u{0}\(receipt.ownedPlaintextURL.lastPathComponent)".utf8
            ))
            return .pendingRecovery(RuntimeAttachmentPortableImportCleanupRecovery(
                receipt: receipt, evidenceFingerprint: evidence
            ))
        }
    }
}
