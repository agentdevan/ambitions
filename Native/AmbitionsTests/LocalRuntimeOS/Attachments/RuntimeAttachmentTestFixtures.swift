import CryptoKit
import Darwin
import Foundation
@testable import Ambitions

actor FixedRuntimeAttachmentKeyCustody: RuntimeAttachmentKeyCustody {
    private let wrapping = SymmetricKey(data: Data(repeating: 0x41, count: 32))
    private let address = SymmetricKey(data: Data(repeating: 0x42, count: 32))
    private let dataKey = SymmetricKey(data: Data(repeating: 0x43, count: 32))
    private let keyID = RuntimeBlobKeyID(rawValue: "attachment-test-wrapping-key")!

    func currentWrappingKey() async throws -> RuntimeAttachmentWrappingKey {
        RuntimeAttachmentWrappingKey(id: keyID, version: 1, key: wrapping)
    }

    func wrappingKey(id: RuntimeBlobKeyID, version: Int) async throws -> RuntimeAttachmentWrappingKey {
        guard id == keyID, version == 1 else {
            throw RuntimeCanonicalAttachmentError.keyCustodyUnavailable
        }
        return RuntimeAttachmentWrappingKey(id: keyID, version: 1, key: wrapping)
    }

    func contentAddressKey() async throws -> SymmetricKey { address }

    func makeDataEncryptionKey() async throws -> SymmetricKey {
        try Task.checkCancellation()
        return dataKey
    }

    func wrap(_ key: SymmetricKey, for blobID: RuntimeBlobID) async throws -> RuntimeBlobKeyEnvelope {
        let sealed = try AES.GCM.seal(
            key.withUnsafeBytes { Data($0) },
            using: wrapping,
            authenticating: Data("ambitions.attachment.keywrap.v1\u{0}\(blobID.rawValue)".utf8)
        )
        let unsigned = RuntimeBlobKeyEnvelope(
            version: 1, blobID: blobID, wrappingKeyID: keyID, wrappingKeyVersion: 1,
            algorithm: "AES.GCM.keywrap.v1", nonce: Data(sealed.nonce),
            wrappedDataEncryptionKey: try XCTAttachmentFixtures.unwrapCombined(sealed),
            envelopeDigest: String(repeating: "0", count: 64)
        )
        return RuntimeBlobKeyEnvelope(
            version: unsigned.version, blobID: unsigned.blobID,
            wrappingKeyID: unsigned.wrappingKeyID, wrappingKeyVersion: unsigned.wrappingKeyVersion,
            algorithm: unsigned.algorithm, nonce: unsigned.nonce,
            wrappedDataEncryptionKey: unsigned.wrappedDataEncryptionKey,
            envelopeDigest: try RuntimeAttachmentCodec.digest(
                unsigned, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
            )
        )
    }

    func unwrap(_ envelope: RuntimeBlobKeyEnvelope) async throws -> SymmetricKey {
        try RuntimeAttachmentCodec.validate(envelope)
        do {
            let raw = try AES.GCM.open(
                AES.GCM.SealedBox(combined: envelope.wrappedDataEncryptionKey),
                using: wrapping,
                authenticating: Data("ambitions.attachment.keywrap.v1\u{0}\(envelope.blobID.rawValue)".utf8)
            )
            guard raw.count == 32 else { throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid }
            return SymmetricKey(data: raw)
        } catch let error as RuntimeCanonicalAttachmentError {
            throw error
        } catch {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
    }
}

actor RecordingRuntimeAttachmentQuotaAuthorizer: RuntimeAttachmentQuotaAuthorizing {
    private var released: [RuntimeBlobQuotaReservationID] = []

    func authorizeAttachmentIntake(
        reservationID: RuntimeBlobQuotaReservationID,
        privacyDomain: RuntimeAttachmentPrivacyDomain,
        maximumBytes: Int64,
        now: Date
    ) async throws -> RuntimeAttachmentQuotaAuthorization {
        RuntimeAttachmentQuotaAuthorization(
            reservationID: reservationID,
            privacyDomain: privacyDomain,
            ownerID: "attachment-intake-test",
            reservedBytes: maximumBytes,
            expiresAt: now.addingTimeInterval(60),
            authorizationDigest: String(repeating: "a", count: 64)
        )
    }

    func releaseAttachmentIntakeAuthorization(
        _ authorization: RuntimeAttachmentQuotaAuthorization,
        now _: Date
    ) async throws {
        released.append(authorization.reservationID)
    }

    func releasedReservationIDs() -> [RuntimeBlobQuotaReservationID] { released }
}

actor FixedRuntimeAttachmentCleanupJobCustody: RuntimeAttachmentPortableCleanupJobCustody {
    private let key = SymmetricKey(data: Data(repeating: 0x45, count: 32))

    func authenticationKey() async throws -> SymmetricKey { key }
}

enum XCTAttachmentFixtures {
    static let now = Date(timeIntervalSince1970: 1_774_089_600)
    static let intakeProofKey = SymmetricKey(data: Data(repeating: 0x44, count: 32))

    static func directory(_ label: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-attachment-\(label)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    static func createRawNamedFile(in directory: URL, nameBytes: [UInt8]) throws {
        guard nameBytes.isEmpty == false,
              nameBytes.count <= Int(MAXNAMLEN),
              nameBytes.contains(0) == false,
              nameBytes.contains(UInt8(ascii: "/")) == false else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var path = Array(directory.path.utf8)
        path.append(UInt8(ascii: "/"))
        path.append(contentsOf: nameBytes)
        path.append(0)
        let cPath = path.map { CChar(bitPattern: $0) }
        let descriptor = cPath.withUnsafeBufferPointer { pointer in
            Darwin.open(
                pointer.baseAddress!, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC,
                S_IRUSR | S_IWUSR
            )
        }
        guard descriptor >= 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        guard Darwin.close(descriptor) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
    }

    static func vault(root: URL, token: String = "opaque-test-token") throws -> RuntimeAttachmentVault {
        try RuntimeAttachmentVault(
            rootDirectory: root,
            keyCustody: FixedRuntimeAttachmentKeyCustody(),
            intakeProofKey: intakeProofKey,
            chunkSize: RuntimeAttachmentLimits.minimumChunkBytes,
            opaqueToken: { token }
        )
    }

    static func stage(
        vault: RuntimeAttachmentVault,
        root: URL,
        bytes: Data = Data((0..<40_000).map { UInt8($0 % 251) }),
        blob: String = "blob-test-1",
        attachment: String = "attachment-test-1",
        revision: String = "attachment-revision-test-1",
        revisionNumber: UInt64 = 1,
        filename: String = "evidence.bin",
        contentType: String = "application/octet-stream"
    ) async throws -> (RuntimeAttachmentStageBundle, URL) {
        let source = root.appendingPathComponent("source-\(blob).bin")
        try bytes.write(to: source, options: .atomic)
        #if os(iOS)
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete], ofItemAtPath: source.path
        )
        #endif
        var metadata = stat()
        guard lstat(source.path, &metadata) == 0 else {
            throw RuntimeCanonicalAttachmentError.pathAuthorityDenied
        }
        let classification = RuntimeAttachmentContentClassification(
            normalizedFilename: filename, declaredContentType: contentType,
            detectedContentType: contentType, signatureVersion: 1,
            byteCount: Int64(bytes.count)
        )
        let revisionID = RuntimeAttachmentRevisionID(rawValue: revision)!
        let blobID = RuntimeBlobID(rawValue: blob)!
        let proof = try RuntimeAttachmentCodec.issueIntakeProof(
            revisionID: revisionID, blobID: blobID,
            ownedFilename: source.lastPathComponent,
            sourceDevice: UInt64(metadata.st_dev), sourceInode: UInt64(metadata.st_ino),
            device: UInt64(metadata.st_dev), inode: UInt64(metadata.st_ino),
            byteCount: Int64(bytes.count),
            plaintextDigest: RuntimeAttachmentCodec.sha256(bytes),
            classification: classification, issuedAt: now,
            key: intakeProofKey
        )
        let bundle = try await vault.stage(RuntimeAttachmentVaultStageRequest(
            attachmentID: RuntimeAttachmentID(rawValue: attachment)!,
            revisionID: revisionID, revision: revisionNumber,
            blobID: blobID, ownedPlaintextURL: source, intakeProof: proof,
            normalizedFilename: filename, declaredContentType: contentType,
            detectedContentType: contentType, privacy: .sensitive,
            dedupPolicy: .withinPrivacyDomain,
            provenance: provenance(source: attachment),
            reservationID: RuntimeBlobQuotaReservationID(rawValue: "reservation-\(blob)")!,
            expectedByteCount: Int64(bytes.count), retentionUntil: nil, createdAt: now
        ))
        return (bundle, source)
    }

    static func graph(
        _ bundle: RuntimeAttachmentStageBundle,
        lifecycle: RuntimeAttachmentCurrentLifecycle? = nil,
        envelope: RuntimeBlobKeyEnvelope? = nil
    ) -> RuntimeAttachmentAuthorityGraph {
        RuntimeAttachmentAuthorityGraph(
            revision: bundle.revision, manifest: bundle.manifest,
            envelope: envelope ?? bundle.envelope, lifecycle: lifecycle ?? bundle.lifecycle,
            references: [], referenceHistory: [], history: [], holds: [], tombstone: nil
        )
    }

    static func payloadURL(root: URL, manifest: RuntimeBlobManifestAuthority) -> URL {
        root.appendingPathComponent(manifest.opaqueRelativeDirectory, isDirectory: true)
            .appendingPathComponent("payload.aead")
    }

    static func provenance(source: String = "attachment-test") -> RuntimeAttachmentProvenance {
        RuntimeAttachmentProvenance(
            version: 1, kind: .capture, sourceRecordID: source, receivedAt: now,
            sourceApplicationFingerprint: nil
        )
    }

    static func unwrapCombined(_ sealed: AES.GCM.SealedBox) throws -> Data {
        guard let combined = sealed.combined else {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
        return combined
    }
}
