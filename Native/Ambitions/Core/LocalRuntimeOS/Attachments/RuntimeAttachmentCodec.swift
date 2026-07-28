import CryptoKit
import Foundation

enum RuntimeAttachmentCodec {
    static let maximumSQLiteInteger = UInt64(Int64.max)

    static func sqliteInteger(_ value: UInt64) throws -> Int64 {
        guard value <= maximumSQLiteInteger else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        return Int64(value)
    }

    static func nextSQLiteVersion(after value: UInt64) throws -> UInt64 {
        guard value < maximumSQLiteInteger else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        return value + 1
    }

    static func gcLeaseToken(_ lease: RuntimeBlobGCLease) throws -> String {
        sha256(Data([
            "ambitions.attachment.gc-lease-token.v1", lease.blobID.rawValue,
            lease.leaseID.rawValue, lease.ownerID, String(lease.expectedStateVersion),
            String(try RuntimeSemanticEventHashing.milliseconds(lease.acquiredAt)),
            String(try RuntimeSemanticEventHashing.milliseconds(lease.expiresAt)),
        ].joined(separator: "\u{0}").utf8))
    }

    static func gcDeletionClaimDigest(
        manifestDigest: String,
        lease: RuntimeBlobGCLease,
        originalRelativeDirectory: String,
        quarantineRelativeDirectory: String,
        disposition: RuntimeAttachmentPhysicalDeletionDisposition,
        directoryDevice: UInt64?,
        directoryInode: UInt64?,
        preparedAt: Date
    ) throws -> String {
        sha256(Data([
            "ambitions.attachment.gc-deletion-claim.v2", manifestDigest,
            try gcLeaseToken(lease), originalRelativeDirectory, quarantineRelativeDirectory,
            disposition.rawValue,
            directoryDevice.map(String.init) ?? "absent",
            directoryInode.map(String.init) ?? "absent",
            String(try RuntimeSemanticEventHashing.milliseconds(preparedAt)),
        ].joined(separator: "\u{0}").utf8))
    }

    static func manifestDeletionVaultClaimDigest(
        _ claim: RuntimeAttachmentManifestDeletionClaim,
        quarantineRelativeDirectory: String,
        quarantineDevice: UInt64,
        quarantineInode: UInt64,
        preparedAt: Date
    ) throws -> String {
        sha256(Data([
            "ambitions.attachment.unowned-manifest-vault-claim.v1", claim.claimID,
            claim.blobID.rawValue, claim.manifestDigest, claim.opaqueRelativeDirectory,
            String(claim.observedDevice), String(claim.observedInode),
            String(try RuntimeSemanticEventHashing.milliseconds(claim.claimedAt)),
            String(try RuntimeSemanticEventHashing.milliseconds(claim.expiresAt)),
            String(claim.stateVersion), quarantineRelativeDirectory,
            String(quarantineDevice), String(quarantineInode),
            String(try RuntimeSemanticEventHashing.milliseconds(preparedAt)),
        ].joined(separator: "\u{0}").utf8))
    }

    static func manifestDeletionProofDigest(
        claimID: String,
        blobID: RuntimeBlobID,
        manifestDigest: String,
        originalRelativeDirectory: String,
        quarantineRelativeDirectory: String,
        directoryDevice: UInt64,
        directoryInode: UInt64,
        deletedAt: Date
    ) throws -> String {
        sha256(Data([
            "ambitions.attachment.unowned-manifest-deletion-proof.v1", claimID,
            blobID.rawValue, manifestDigest, originalRelativeDirectory,
            quarantineRelativeDirectory, String(directoryDevice), String(directoryInode),
            String(try RuntimeSemanticEventHashing.milliseconds(deletedAt)),
        ].joined(separator: "\u{0}").utf8))
    }

    private static func makeEncoder() -> JSONEncoder {
        let value = JSONEncoder()
        value.dateEncodingStrategy = .millisecondsSince1970
        value.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return value
    }

    private static func makeDecoder() -> JSONDecoder {
        let value = JSONDecoder()
        value.dateDecodingStrategy = .millisecondsSince1970
        return value
    }

    static func encode<T: Encodable>(_ value: T, maximumBytes: Int) throws -> Data {
        let bytes = try makeEncoder().encode(value)
        guard bytes.isEmpty == false, bytes.count <= maximumBytes else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        return bytes
    }

    static func decode<T: Decodable>(_ type: T.Type, bytes: Data, maximumBytes: Int) throws -> T {
        guard bytes.isEmpty == false, bytes.count <= maximumBytes else {
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
        do {
            return try makeDecoder().decode(type, from: bytes)
        } catch {
            // Decoder details can contain private payload fragments; the attachment
            // boundary deliberately exposes only the typed corrupt-payload result.
            throw RuntimeCanonicalAttachmentError.malformedPayload
        }
    }

    static func digest<T: Encodable>(_ value: T, maximumBytes: Int) throws -> String {
        sha256(try encode(value, maximumBytes: maximumBytes))
    }

    static func sha256(_ bytes: Data) -> String {
        SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
    }

    static func sha256DigestHex(_ digest: SHA256.Digest) -> String {
        digest.map { String(format: "%02x", $0) }.joined()
    }

    static func issueIntakeProof(
        revisionID: RuntimeAttachmentRevisionID,
        blobID: RuntimeBlobID,
        ownedFilename: String,
        sourceDevice: UInt64,
        sourceInode: UInt64,
        device: UInt64,
        inode: UInt64,
        byteCount: Int64,
        plaintextDigest: String,
        classification: RuntimeAttachmentContentClassification,
        issuedAt: Date,
        key: SymmetricKey
    ) throws -> RuntimeAttachmentValidatedIntakeProof {
        let unsigned = RuntimeAttachmentValidatedIntakeProof(
            version: runtimeCanonicalAttachmentModelVersion,
            revisionID: revisionID, blobID: blobID,
            ownedFilename: ownedFilename,
            sourceDevice: sourceDevice, sourceInode: sourceInode,
            device: device, inode: inode,
            byteCount: byteCount, plaintextDigest: plaintextDigest,
            classification: classification, protectionClass: .complete,
            issuedAt: issuedAt, authenticationCode: Data()
        )
        try validateIntakeProofMaterial(unsigned)
        return RuntimeAttachmentValidatedIntakeProof(
            version: unsigned.version, revisionID: unsigned.revisionID,
            blobID: unsigned.blobID, ownedFilename: unsigned.ownedFilename,
            sourceDevice: unsigned.sourceDevice, sourceInode: unsigned.sourceInode,
            device: unsigned.device, inode: unsigned.inode,
            byteCount: unsigned.byteCount, plaintextDigest: unsigned.plaintextDigest,
            classification: unsigned.classification,
            protectionClass: unsigned.protectionClass, issuedAt: unsigned.issuedAt,
            authenticationCode: Data(HMAC<SHA256>.authenticationCode(
                for: try intakeProofAuthenticationMessage(unsigned), using: key
            ))
        )
    }

    static func validateIntakeProof(
        _ proof: RuntimeAttachmentValidatedIntakeProof,
        request: RuntimeAttachmentVaultStageRequest,
        key: SymmetricKey
    ) throws {
        try validateIntakeProofMaterial(proof)
        guard proof.authenticationCode.count == 32,
              HMAC<SHA256>.isValidAuthenticationCode(
                  proof.authenticationCode,
                  authenticating: try intakeProofAuthenticationMessage(proof),
                  using: key
              ),
              proof.revisionID == request.revisionID,
              proof.blobID == request.blobID,
              proof.ownedFilename == request.ownedPlaintextURL.lastPathComponent,
              proof.byteCount == request.expectedByteCount,
              proof.classification.normalizedFilename == request.normalizedFilename,
              proof.classification.declaredContentType == request.declaredContentType,
              proof.classification.detectedContentType == request.detectedContentType,
              proof.classification.byteCount == request.expectedByteCount else {
            throw RuntimeCanonicalAttachmentError.fileIdentityChanged
        }
    }

    private static func validateIntakeProofMaterial(
        _ proof: RuntimeAttachmentValidatedIntakeProof
    ) throws {
        guard proof.version == runtimeCanonicalAttachmentModelVersion,
              proof.sourceDevice <= UInt64(Int64.max),
              proof.sourceInode > 0, proof.sourceInode <= UInt64(Int64.max),
              proof.device <= UInt64(Int64.max),
              proof.inode > 0, proof.inode <= UInt64(Int64.max),
              proof.byteCount > 0,
              proof.byteCount <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              isSHA(proof.plaintextDigest),
              validFilename(proof.ownedFilename),
              validFilename(proof.classification.normalizedFilename),
              validContentType(proof.classification.declaredContentType),
              validContentType(proof.classification.detectedContentType),
              proof.classification.signatureVersion == 1,
              proof.classification.byteCount == proof.byteCount,
              proof.protectionClass == .complete else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
    }

    private static func intakeProofAuthenticationMessage(
        _ proof: RuntimeAttachmentValidatedIntakeProof
    ) throws -> Data {
        Data([
            "ambitions.attachment.intake-proof.v1",
            String(proof.version), proof.revisionID.rawValue, proof.blobID.rawValue,
            proof.ownedFilename, String(proof.sourceDevice), String(proof.sourceInode),
            String(proof.device), String(proof.inode),
            String(proof.byteCount), proof.plaintextDigest,
            proof.classification.normalizedFilename,
            proof.classification.declaredContentType,
            proof.classification.detectedContentType,
            String(proof.classification.signatureVersion),
            String(proof.classification.byteCount), proof.protectionClass.rawValue,
            String(try RuntimeSemanticEventHashing.milliseconds(proof.issuedAt)),
        ].joined(separator: "\u{0}").utf8)
    }

    static func keyedContentAddress(
        privacyDomain: RuntimeAttachmentPrivacyDomain,
        policy: RuntimeAttachmentDedupPolicy,
        plaintextDigest: SHA256.Digest,
        blobID: RuntimeBlobID,
        key: SymmetricKey
    ) -> RuntimeAttachmentContentAddress {
        var material = Data("ambitions.attachment.content-address.v1\u{0}\(privacyDomain.rawValue)\u{0}\(policy.rawValue)\u{0}".utf8)
        material.append(contentsOf: plaintextDigest)
        if policy == .never {
            material.append(0)
            material.append(contentsOf: blobID.rawValue.utf8)
        }
        let value = HMAC<SHA256>.authenticationCode(for: material, using: key)
            .map { String(format: "%02x", $0) }.joined()
        return RuntimeAttachmentContentAddress(rawValue: value)!
    }

    static func validate(_ value: RuntimeBlobManifestAuthority) throws {
        guard value.formatVersion == runtimeCanonicalAttachmentModelVersion,
              value.chunkSize >= RuntimeAttachmentLimits.minimumChunkBytes,
              value.chunkSize <= RuntimeAttachmentLimits.maximumChunkBytes,
              value.chunkCount > 0,
              value.chunkCount <= RuntimeAttachmentLimits.maximumChunks,
              value.plaintextByteCount > 0,
              value.plaintextByteCount <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              value.ciphertextByteCount > value.plaintextByteCount,
              isSHA(value.headerDigest), isSHA(value.terminalDigest),
              validOpaqueDirectory(value.opaqueRelativeDirectory),
              value.protectionClass == .complete,
              value.encryptionAlgorithm == "AES.GCM.chunked.v1" else {
            throw RuntimeCanonicalAttachmentError.manifestInvalid
        }
    }

    static func validate(_ value: RuntimeBlobKeyEnvelope) throws {
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.wrappingKeyVersion > 0,
              value.algorithm == "AES.GCM.keywrap.v1",
              value.nonce.count == 12,
              value.wrappedDataEncryptionKey.isEmpty == false,
              value.wrappedDataEncryptionKey.count <= RuntimeAttachmentLimits.maximumEnvelopeBytes,
              isSHA(value.envelopeDigest) else {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
        let unsigned = RuntimeBlobKeyEnvelope(
            version: value.version,
            blobID: value.blobID,
            wrappingKeyID: value.wrappingKeyID,
            wrappingKeyVersion: value.wrappingKeyVersion,
            algorithm: value.algorithm,
            nonce: value.nonce,
            wrappedDataEncryptionKey: value.wrappedDataEncryptionKey,
            envelopeDigest: String(repeating: "0", count: 64)
        )
        let expected = try digest(unsigned, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes)
        guard expected == value.envelopeDigest else {
            throw RuntimeCanonicalAttachmentError.keyEnvelopeInvalid
        }
    }

    static func validate(_ value: RuntimeAttachmentRevision) throws {
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.revision > 0,
              value.revision <= maximumSQLiteInteger,
              isSHA(value.manifestDigest),
              value.classification.signatureVersion == 1,
              value.classification.byteCount > 0,
              value.classification.byteCount <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              validFilename(value.classification.normalizedFilename),
              validContentType(value.classification.declaredContentType),
              validContentType(value.classification.detectedContentType),
              (try? validate(value.provenance)) != nil else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
    }

    static func validate(_ value: RuntimeAttachmentProvenance) throws {
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.sourceRecordID.isEmpty == false,
              value.sourceRecordID.utf8.count <= 1_024,
              value.sourceRecordID == value.sourceRecordID.precomposedStringWithCanonicalMapping,
              value.sourceRecordID == value.sourceRecordID.trimmingCharacters(
                  in: .whitespacesAndNewlines
              ),
              value.sourceRecordID.unicodeScalars.contains(
                  where: CharacterSet.controlCharacters.contains
              ) == false,
              value.sourceApplicationFingerprint.map({ isSHA($0) }) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
    }

    static func validate(_ value: RuntimeAttachmentCurrentLifecycle) throws {
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.stateVersion > 0,
              value.stateVersion <= maximumSQLiteInteger,
              value.referenceCount >= 0,
              value.referenceCount <= RuntimeAttachmentLimits.maximumReferences,
              isSHA(value.manifestDigest),
              lifecycleCoherent(value) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
    }

    static func validate(_ value: RuntimeAttachmentCommandIntent) throws {
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.expectedLifecycleVersion > 0,
              value.expectedLifecycleVersion <= maximumSQLiteInteger,
              value.expectedReplacedLifecycleVersion.map({
                  $0 > 0 && $0 <= maximumSQLiteInteger
              }) ?? true,
              isSHA(value.manifestDigest),
              (try? validate(value.provenance)) != nil else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        switch value.action {
        case .linkStaged:
            guard value.referenceID != nil, value.target != nil, value.quarantineReason == nil,
                  value.quarantineEvidenceFingerprint == nil,
                  hasNoReplacementAuthority(value) else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        case .unlink:
            guard value.referenceID != nil, value.target != nil, value.quarantineReason == nil,
                  value.quarantineEvidenceFingerprint == nil,
                  hasNoReplacementAuthority(value) else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        case .replaceRevision:
            guard value.referenceID != nil, value.replacesReferenceID != nil,
                  value.replacesRevisionID != nil, value.replacesBlobID != nil,
                  value.target != nil, value.expectedReplacedLifecycleVersion != nil,
                  value.replacesManifestDigest.map(isSHA) == true,
                  value.quarantineReason == nil, value.quarantineEvidenceFingerprint == nil else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        case .authorizeDeletion:
            guard value.referenceID == nil, value.target == nil, value.quarantineReason == nil,
                  value.quarantineEvidenceFingerprint == nil,
                  hasNoReplacementAuthority(value) else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        case .quarantine:
            guard value.referenceID == nil, value.target == nil, value.quarantineReason != nil,
                  value.quarantineEvidenceFingerprint.map(isSHA) == true,
                  hasNoReplacementAuthority(value) else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
        }
    }

    static func referenceTransitionDigest(_ value: RuntimeAttachmentReferenceHistory) throws -> String {
        let unsigned = RuntimeAttachmentReferenceHistory(
            version: value.version, historyID: value.historyID,
            referenceID: value.referenceID, revisionID: value.revisionID, blobID: value.blobID,
            fromState: value.fromState, toState: value.toState,
            commandID: value.commandID, receiptID: value.receiptID,
            lineage: value.lineage, occurredAt: value.occurredAt,
            transitionDigest: String(repeating: "0", count: 64)
        )
        return try digest(unsigned, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
    }

    static func tombstoneDigest(_ value: RuntimeBlobDeletionTombstone) throws -> String {
        let unsigned = RuntimeBlobDeletionTombstone(
            version: value.version, tombstoneID: value.tombstoneID,
            blobID: value.blobID, manifestDigest: value.manifestDigest,
            finalStateVersion: value.finalStateVersion,
            deletionAuthorizationID: value.deletionAuthorizationID,
            physicalDeletionConfirmed: value.physicalDeletionConfirmed,
            physicalDeletionDisposition: value.physicalDeletionDisposition,
            deletedAt: value.deletedAt, tombstoneDigest: String(repeating: "0", count: 64)
        )
        return try digest(unsigned, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
    }

    static func transitionDigest(_ value: RuntimeAttachmentLifecycleHistory) throws -> String {
        let unsigned = RuntimeAttachmentLifecycleHistory(
            version: value.version,
            historyID: value.historyID,
            blobID: value.blobID,
            stateVersion: value.stateVersion,
            fromState: value.fromState,
            toState: value.toState,
            fromReferenceCount: value.fromReferenceCount,
            toReferenceCount: value.toReferenceCount,
            commandID: value.commandID,
            receiptID: value.receiptID,
            lineage: value.lineage,
            systemAuthority: value.systemAuthority,
            occurredAt: value.occurredAt,
            transitionDigest: String(repeating: "0", count: 64)
        )
        return try digest(unsigned, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
    }

    static func finalizationProofDigest(_ value: RuntimeAttachmentFinalizationProof) throws -> String {
        let material = [
            "ambitions.attachment.finalization-proof.v1", value.blobID.rawValue,
            value.manifestDigest, value.receiptID.rawValue,
            String(value.terminalEventSequence), value.markerDigest,
            String(try RuntimeSemanticEventHashing.milliseconds(value.finalizedAt)),
        ].joined(separator: "\u{0}")
        return sha256(Data(material.utf8))
    }

    static func physicalDeletionProofDigest(_ value: RuntimeAttachmentPhysicalDeletionProof) throws -> String {
        let material = [
            "ambitions.attachment.physical-deletion-proof.v2", value.blobID.rawValue,
            value.manifestDigest, value.leaseID.rawValue,
            String(value.expectedStateVersion),
            value.disposition.rawValue,
            value.directoryDevice.map(String.init) ?? "absent",
            value.directoryInode.map(String.init) ?? "absent",
            String(try RuntimeSemanticEventHashing.milliseconds(value.deletedAt)),
        ].joined(separator: "\u{0}")
        return sha256(Data(material.utf8))
    }

    static func validFilename(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.count <= RuntimeAttachmentLimits.maximumFilenameBytes &&
            value == value.lastPathComponent && value.contains("..") == false &&
            value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }

    static func validContentType(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.count <= RuntimeAttachmentLimits.maximumContentTypeBytes &&
            value == value.lowercased() && value.contains("/") && value.contains(" ") == false
    }

    static func validOpaqueDirectory(_ value: String) -> Bool {
        let components = value.split(separator: "/", omittingEmptySubsequences: false)
        return components.count == 3 && components.allSatisfy { component in
            component.isEmpty == false && component != "." && component != ".." &&
                component.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
        }
    }

    static func isSHA(_ value: String) -> Bool { RuntimeStoreManifestCodec.isSHA256Hex(value) }

    private static func lifecycleCoherent(_ value: RuntimeAttachmentCurrentLifecycle) -> Bool {
        switch value.state {
        case .staged, .orphaned, .deletionPending:
            return value.referenceCount == 0
        case .quarantined:
            return value.referenceCount >= 0
        case .referenced, .finalized:
            return value.referenceCount > 0
        }
    }

    static func allowsLifecycleTransition(
        from: RuntimeAttachmentLifecycleState?,
        to: RuntimeAttachmentLifecycleState,
        fromReferenceCount: Int?,
        toReferenceCount: Int
    ) -> Bool {
        guard toReferenceCount >= 0 else { return false }
        switch (from, to) {
        case (nil, .staged):
            return fromReferenceCount == nil && toReferenceCount == 0
        case (.staged, .referenced), (.orphaned, .referenced), (.orphaned, .finalized):
            return fromReferenceCount == 0 && toReferenceCount > 0
        case (.staged, .quarantined), (.orphaned, .quarantined):
            return fromReferenceCount == 0 && toReferenceCount == 0
        case (.staged, .deletionPending), (.orphaned, .deletionPending),
             (.quarantined, .deletionPending), (.deletionPending, .deletionPending):
            return fromReferenceCount == 0 && toReferenceCount == 0
        case (.referenced, .referenced), (.finalized, .finalized):
            return fromReferenceCount != nil && toReferenceCount > 0
        case (.referenced, .finalized):
            return fromReferenceCount == toReferenceCount && toReferenceCount > 0
        case (.referenced, .orphaned), (.finalized, .orphaned):
            return fromReferenceCount == 1 && toReferenceCount == 0
        case (.referenced, .quarantined), (.finalized, .quarantined),
             (.quarantined, .quarantined):
            return fromReferenceCount != nil && toReferenceCount >= 0
        default:
            return false
        }
    }

    private static func hasNoReplacementAuthority(_ value: RuntimeAttachmentCommandIntent) -> Bool {
        value.replacesReferenceID == nil && value.replacesRevisionID == nil &&
            value.replacesBlobID == nil && value.expectedReplacedLifecycleVersion == nil &&
            value.replacesManifestDigest == nil
    }
}

private extension String {
    var lastPathComponent: String { URL(fileURLWithPath: self).lastPathComponent }
}
