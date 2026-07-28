import AmbitionsRuntimeSQLite
import CryptoKit
import Darwin
import Foundation
import SwiftData

enum RuntimeLegacyCanonicalSchemaVersion: Int, Codable, Sendable, Equatable, CaseIterable {
    case v1 = 1
}

struct RuntimeLegacyDecodedValue: Codable, Sendable, Equatable {
    let column: String
    let kind: String
    let value: String
}

struct RuntimeLegacyDecodedRecord: Codable, Sendable, Equatable {
    let table: String
    let primaryKey: [RuntimeLegacyDecodedValue]
    let values: [RuntimeLegacyDecodedValue]
}

private struct RuntimeLegacyDecodedRecordPayload: Codable, Sendable, Equatable {
    let table: String
    let values: [RuntimeLegacyDecodedValue]
}

struct RuntimeSwiftDataImportRecord: Codable, Sendable, Equatable {
    let payloadVersion: Int
    let envelope: RuntimeLegacySwiftDataSourceEnvelope

    var sourceIdentity: RuntimeLegacySwiftDataSourceIdentity { envelope.sourceIdentity }
    var stableRecordID: String { envelope.sourceIdentity.stableRecordID }
    var modelType: RuntimeLegacySwiftDataSourceModelType { envelope.sourceIdentity.modelType }

    func canonicalSourceRecordID() throws -> String {
        try RuntimeGenerationControlCodec.encode(sourceIdentity).base64EncodedString()
    }

    /// Stable across export sessions and physical artifact locations. This is
    /// the only digest eligible for record deduplication and record-set identity.
    func semanticRecordDigest() throws -> String {
        try envelope.validate()
        return try RuntimeGenerationControlCodec.digest(
            RuntimeSwiftDataSemanticRecordDigestMaterial(
                payloadVersion: payloadVersion,
                envelopeFormatVersion: envelope.formatVersion,
                sourceIdentityDigest: sourceIdentity.identityDigest,
                sourceDisposition: envelope.sourceDisposition,
                requiresReview: envelope.requiresReview,
                materializationAuthorized: envelope.materializationAuthorized,
                payloadDigest: envelope.payloadDigest,
                relationshipSetDigest: envelope.relationshipSetDigest
            )
        )
    }
}

private struct RuntimeSwiftDataSemanticRecordDigestMaterial: Encodable {
    let payloadVersion: Int
    let envelopeFormatVersion: RuntimeLegacySwiftDataEnvelopeVersion
    let sourceIdentityDigest: String
    let sourceDisposition: RuntimeLegacySwiftDataSourceDisposition
    let requiresReview: Bool
    let materializationAuthorized: Bool
    let payloadDigest: String
    let relationshipSetDigest: String
}

struct RuntimeLegacyCanonicalSQLiteArtifact: Codable, Sendable, Equatable {
    let sourceSchemaVersion: RuntimeLegacyCanonicalSchemaVersion
    let table: String
    let canonicalFamily: String
    let canonicalID: String
    let payloadVersion: Int
    let payload: Data
    let payloadChecksum: String
    let sourceRecord: RuntimeLegacyDecodedRecord
}

enum RuntimeLegacyMappedImportPayload: Codable, Sendable, Equatable {
    case canonicalSQLite(RuntimeLegacyCanonicalSQLiteArtifact)
    case swiftData(RuntimeLegacySwiftDataSourceEnvelope)
}

struct RuntimeLegacyMappedImportArtifact: Codable, Sendable, Equatable {
    let formatVersion: Int
    let importID: String
    let sourceSchema: String
    let sourceRecordID: String
    let sourceRecordDigest: String
    let canonicalFamily: String
    let canonicalID: String
    let payloadVersion: Int
    let payload: RuntimeLegacyMappedImportPayload
}

/// Pure authentication boundary for a decoded mapped artifact. Filesystem I/O
/// remains descriptor-owned by the loader; all semantic reference, item, and
/// typed-payload bindings are decided here without ambient state.
enum RuntimeLegacyMappedArtifactAuthenticator {
    static func authenticate(
        item: RuntimeLegacyImportItem,
        observedArtifact: RuntimeGenerationArtifact,
        decodedArtifact: RuntimeLegacyMappedImportArtifact
    ) throws {
        try RuntimeGenerationControlRecordFactory.validate(item)
        guard item.disposition == .reviewableDiscovery,
              let reference = item.mappedArtifact else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try RuntimeGenerationControlRecordFactory.validate(reference)
        guard observedArtifact.semanticallyMatches(reference.artifact),
              decodedArtifact.formatVersion == reference.formatVersion,
              decodedArtifact.importID == item.importID,
              decodedArtifact.sourceRecordID == item.sourceRecordID,
              decodedArtifact.sourceRecordDigest == item.sourceRecordDigest,
              decodedArtifact.payloadVersion == reference.payloadVersion,
              decodedArtifact.canonicalFamily == item.canonicalFamily,
              decodedArtifact.canonicalID == item.canonicalID else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        switch decodedArtifact.payload {
        case let .canonicalSQLite(canonical):
            let rebuilt: RuntimeLegacyMappedRecord
            do {
                guard let mapped = try RuntimeLegacyCanonicalSQLiteMapper.map(
                    canonical.sourceRecord,
                    sourceSchemaVersion: canonical.sourceSchemaVersion
                ) else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                rebuilt = mapped
            } catch {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            guard decodedArtifact.formatVersion == 1,
                  decodedArtifact.sourceSchema ==
                    "canonical.sqlite.v\(canonical.sourceSchemaVersion.rawValue)",
                  rebuilt.sourceRecordID == decodedArtifact.sourceRecordID,
                  rebuilt.sourceRecordDigest == decodedArtifact.sourceRecordDigest,
                  rebuilt.canonicalFamily == decodedArtifact.canonicalFamily,
                  rebuilt.canonicalID == decodedArtifact.canonicalID,
                  rebuilt.payloadVersion == decodedArtifact.payloadVersion,
                  rebuilt.lossiness == item.lossiness,
                  rebuilt.warningCodes.sorted() == item.warningCodes,
                  case let .canonicalSQLite(rebuiltCanonical) = rebuilt.payload,
                  rebuiltCanonical == canonical else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let .swiftData(envelope):
            let record = RuntimeSwiftDataImportRecord(
                payloadVersion: decodedArtifact.payloadVersion,
                envelope: envelope
            )
            let reconstructedSourceRecordID: String
            let reconstructedSourceRecordDigest: String
            do {
                try RuntimeGenerationLegacyImportService.authenticateSwiftDataRecord(record)
                reconstructedSourceRecordID = try record.canonicalSourceRecordID()
                reconstructedSourceRecordDigest = try record.semanticRecordDigest()
            } catch {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let expectedWarnings = [
                "typed_swiftdata_v3",
                "review_only_\(envelope.sourceDisposition.rawValue)"
            ].sorted()
            guard decodedArtifact.formatVersion == 2,
                  decodedArtifact.sourceSchema == objectStoreSwiftDataSchemaVersion,
                  reconstructedSourceRecordID == decodedArtifact.sourceRecordID,
                  reconstructedSourceRecordDigest == decodedArtifact.sourceRecordDigest,
                  decodedArtifact.canonicalFamily == envelope.sourceIdentity.modelType.rawValue,
                  decodedArtifact.canonicalID == envelope.sourceIdentity.stableRecordID,
                  item.lossiness == .none,
                  item.warningCodes == expectedWarnings,
                  envelope.requiresReview,
                  envelope.materializationAuthorized == false else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        }
    }
}

/// Immutable, explicitly versioned production mapper used both when staging a
/// canonical legacy record and when authenticating its persisted mapped form.
enum RuntimeLegacyCanonicalSQLiteMapper {
    static func map(
        _ record: RuntimeLegacyDecodedRecord,
        sourceSchemaVersion: RuntimeLegacyCanonicalSchemaVersion
    ) throws -> RuntimeLegacyMappedRecord? {
        switch sourceSchemaVersion {
        case .v1:
            try RuntimeGenerationLegacyImportService.mapVersionedCanonicalSQLiteRecord(
                record,
                schemaVersion: .v1
            )
        }
    }
}

struct RuntimeLegacyMappedRecord: Sendable {
    let sourceRecordID: String
    let sourceRecordDigest: String
    let canonicalFamily: String
    let canonicalID: String
    let payloadVersion: Int
    let payload: RuntimeLegacyMappedImportPayload
    let lossiness: RuntimeLegacyImportLossiness
    let warningCodes: [String]
}

private struct RuntimeLegacyRejectedRecord: Sendable {
    let sourceRecordID: String
    let sourceRecordDigest: String
    let disposition: RuntimeLegacyImportDisposition
    let warningCodes: [String]
    let lossiness: RuntimeLegacyImportLossiness
}

struct RuntimeSwiftDataImportExportHeader: Codable, Sendable, Equatable {
    let formatVersion: Int
    let schemaVersion: String
    let transportSessionDigest: String
}

struct RuntimeSwiftDataImportExportFooter: Codable, Sendable, Equatable {
    let recordCount: Int
    let recordSetDigest: String
}

enum RuntimeSwiftDataImportExportFrame: Codable, Sendable, Equatable {
    case header(RuntimeSwiftDataImportExportHeader)
    case record(RuntimeSwiftDataImportRecord)
    case footer(RuntimeSwiftDataImportExportFooter)
}

struct RuntimeLegacyImportStagingResult: Sendable, Equatable {
    let source: RuntimeLegacyImportSource
    let manifest: RuntimeLegacyImportManifest
    let quarantine: RuntimeGenerationQuarantineRecord?
}

struct RuntimeSwiftDataTypedExportResult: Sendable, Equatable {
    let url: URL
    let artifact: RuntimeGenerationObservedArtifact
    let recordCount: Int
    let recordSetDigest: String
}

struct RuntimeSwiftDataExportRecord: Sendable {
    let payload: RuntimeLegacySwiftDataSourcePayload
    let relationshipClaims: [RuntimeLegacySwiftDataRelationshipClaim]
}

/// Bounded descriptor writer used only by one synchronous `store.read` closure.
/// The unchecked conformance is limited to transporting the descriptor owner
/// into that store-actor closure; no other task receives the instance.
private final class RuntimeSwiftDataExportStream: @unchecked Sendable {
    private let descriptor: Int32
    private let transportSessionDigest: String
    private(set) var encodedByteCount: Int64 = 0
    private(set) var decodedByteCount: Int64 = 0
    private(set) var recordCount = 0
    private(set) var recordSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
        for: "ambitions.swiftdata.export.semantic-records.v4"
    )
    private var transportHasher = SHA256()
    private var transportHashFinalized = false
    private var priorOrderingKey: RuntimeLegacySwiftDataCompositeOrderingKey?

    init(descriptor: Int32, transportSessionDigest: String) {
        self.descriptor = descriptor
        self.transportSessionDigest = transportSessionDigest
    }

    func appendHeader() throws {
        try write(.header(.init(
            formatVersion: 4,
            schemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: transportSessionDigest
        )))
    }

    func append(_ exportRecord: RuntimeSwiftDataExportRecord) throws {
        try Task.checkCancellation()
        let derivedClaims = try exportRecord.payload.derivedRelationshipClaims()
        guard exportRecord.relationshipClaims == derivedClaims else {
            throw RuntimeGenerationControlError.malformed(
                field: "swiftdata_export_relationship_claim_derivation"
            )
        }
        let envelope = try RuntimeLegacySwiftDataSourceEnvelope.make(
            sourceSchemaVersion: objectStoreSwiftDataSchemaVersion,
            transportSessionDigest: transportSessionDigest,
            payload: exportRecord.payload,
            relationshipClaims: derivedClaims
        )
        let orderingKey = envelope.sourceIdentity.orderingKey
        guard recordCount < RuntimeGenerationLegacyImportService.maximumRecords,
              priorOrderingKey.map({ $0 < orderingKey }) ?? true else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let decodedPayload = try RuntimeGenerationControlCodec.encode(envelope)
        guard decodedPayload.count <= RuntimeGenerationControlCodec.maximumRecordBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
            )
        }
        let decodedIncrement = decodedByteCount.addingReportingOverflow(
            Int64(decodedPayload.count)
        )
        guard decodedIncrement.overflow == false,
              decodedIncrement.partialValue <=
                RuntimeGenerationLegacyImportService.maximumImportDecodedBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(
                    RuntimeGenerationLegacyImportService.maximumImportDecodedBytes
                )
            )
        }
        let record = RuntimeSwiftDataImportRecord(
            payloadVersion: 1,
            envelope: envelope
        )
        try RuntimeGenerationLegacyImportService.validateSwiftDataRecord(record)
        let recordDigest = try record.semanticRecordDigest()
        let sourceRecordID = try record.canonicalSourceRecordID()
        recordSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "\(recordSetDigest)\n\(sourceRecordID)\n\(recordDigest)"
        )
        let frame = try RuntimeGenerationControlCodec.encode(
            RuntimeSwiftDataImportExportFrame.record(record)
        )
        guard frame.count <= RuntimeGenerationControlCodec.maximumRecordBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
            )
        }
        try writeEncodedFrame(frame)
        decodedByteCount = decodedIncrement.partialValue
        recordCount += 1
        priorOrderingKey = orderingKey
    }

    func appendFooter() throws {
        try write(.footer(.init(
            recordCount: recordCount,
            recordSetDigest: recordSetDigest
        )))
    }

    func finalizeTransportDigest() throws -> String {
        guard transportHashFinalized == false else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        transportHashFinalized = true
        return transportHasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private func write(_ frame: RuntimeSwiftDataImportExportFrame) throws {
        try writeEncodedFrame(try RuntimeGenerationControlCodec.encode(frame))
    }

    private func writeEncodedFrame(_ data: Data) throws {
        let framedCount = data.count.addingReportingOverflow(1)
        guard framedCount.overflow == false else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(RuntimeGenerationLegacyImportService.maximumSourceBytes)
            )
        }
        let total = encodedByteCount.addingReportingOverflow(Int64(framedCount.partialValue))
        guard total.overflow == false,
              total.partialValue <= RuntimeGenerationLegacyImportService.maximumSourceBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(RuntimeGenerationLegacyImportService.maximumSourceBytes)
            )
        }
        try data.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                try Task.checkCancellation()
                let written = Darwin.write(
                    descriptor,
                    raw.baseAddress?.advanced(by: offset),
                    raw.count - offset
                )
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "write_swiftdata_typed_export"
                    )
                }
                transportHasher.update(
                    data: Data(
                        bytes: raw.baseAddress!.advanced(by: offset),
                        count: written
                    )
                )
                offset += written
            }
        }
        var newline: UInt8 = 0x0A
        while true {
            let written = Darwin.write(descriptor, &newline, 1)
            if written < 0, errno == EINTR { continue }
            guard written == 1 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "write_swiftdata_typed_export_newline"
                )
            }
            transportHasher.update(data: Data([newline]))
            break
        }
        encodedByteCount = total.partialValue
    }
}

private final class RuntimeLegacyImportReconciliationLockScope: @unchecked Sendable {
    /// The lock makes the unchecked conformance concrete: descriptor ownership
    /// is transferred to exactly one closer before any syscall is attempted.
    private let stateLock = NSLock()
    private var descriptor: Int32?

    init(descriptor: Int32) {
        self.descriptor = descriptor
    }

    func close() throws {
        stateLock.lock()
        guard let descriptor else {
            stateLock.unlock()
            return
        }
        self.descriptor = nil
        stateLock.unlock()
        let unlocked = Darwin.flock(descriptor, LOCK_UN) == 0
        let closed = Darwin.close(descriptor) == 0
        guard unlocked, closed else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
    }

    deinit {
        stateLock.lock()
        let ownedDescriptor = descriptor
        descriptor = nil
        stateLock.unlock()
        if let descriptor = ownedDescriptor {
            _ = Darwin.flock(descriptor, LOCK_UN)
            _ = Darwin.close(descriptor)
        }
    }
}

private enum RuntimeLegacyImportPinnedArtifactIO {
    static func requireEntryName(_ name: String) throws {
        guard name.isEmpty == false, name != ".", name != "..",
              name.contains("/") == false,
              name.utf8.count <= Int(MAXNAMLEN),
              name.unicodeScalars.allSatisfy({ $0.value >= 0x20 && $0.value != 0x7f }) else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }

    static func inspect(
        parentDescriptor: Int32,
        name: String,
        relativePath: String,
        maximumBytes: Int64,
        retainBytes: Bool
    ) throws -> (artifact: RuntimeGenerationObservedArtifact, bytes: Data?) {
        try requireEntryName(name)
        guard maximumBytes >= 0 else {
            throw RuntimeGenerationControlError.readBudgetExceeded(maximumBytes: 0)
        }
        try RuntimeGenerationControlValidation.requireRelativePath(relativePath)
        var entryBefore = stat()
        guard fstatat(parentDescriptor, name, &entryBefore, AT_SYMLINK_NOFOLLOW) == 0,
              entryBefore.st_mode & S_IFMT == S_IFREG,
              entryBefore.st_nlink == 1,
              entryBefore.st_size >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let byteCount = Int64(entryBefore.st_size)
        guard byteCount <= maximumBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(min(maximumBytes, Int64(Int.max)))
            )
        }
        let descriptor = Darwin.openat(
            parentDescriptor, name, O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorOpen = true
        do {
            var opened = stat()
            guard fstat(descriptor, &opened) == 0,
                  opened.st_mode & S_IFMT == S_IFREG,
                  opened.st_nlink == 1,
                  opened.st_dev == entryBefore.st_dev,
                  opened.st_ino == entryBefore.st_ino,
                  opened.st_size == entryBefore.st_size,
                  opened.st_gen == entryBefore.st_gen,
                  opened.st_mtimespec.tv_sec == entryBefore.st_mtimespec.tv_sec,
                  opened.st_mtimespec.tv_nsec == entryBefore.st_mtimespec.tv_nsec,
                  opened.st_ctimespec.tv_sec == entryBefore.st_ctimespec.tv_sec,
                  opened.st_ctimespec.tv_nsec == entryBefore.st_ctimespec.tv_nsec,
                  Darwin.fcntl(descriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "legacy_import_artifact"
                )
            }
            var hasher = SHA256()
            var retained = retainBytes ? Data() : nil
            retained?.reserveCapacity(Int(byteCount))
            var remaining = byteCount
            var buffer = [UInt8](repeating: 0, count: 128 * 1_024)
            while remaining > 0 {
                try Task.checkCancellation()
                let requested = min(buffer.count, Int(remaining))
                let readCount = buffer.withUnsafeMutableBytes {
                    Darwin.read(descriptor, $0.baseAddress, requested)
                }
                if readCount < 0, errno == EINTR { continue }
                guard readCount > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "read_legacy_import_artifact"
                    )
                }
                let chunk = Data(buffer.prefix(readCount))
                hasher.update(data: chunk)
                retained?.append(chunk)
                remaining -= Int64(readCount)
            }
            var trailing: UInt8 = 0
            var trailingCount: Int
            repeat {
                trailingCount = Darwin.read(descriptor, &trailing, 1)
            } while trailingCount < 0 && errno == EINTR
            var descriptorAfter = stat()
            var entryAfter = stat()
            guard trailingCount == 0,
                  fstat(descriptor, &descriptorAfter) == 0,
                  fstatat(parentDescriptor, name, &entryAfter, AT_SYMLINK_NOFOLLOW) == 0,
                  descriptorAfter.st_mode & S_IFMT == S_IFREG,
                  descriptorAfter.st_nlink == 1,
                  descriptorAfter.st_dev == opened.st_dev,
                  descriptorAfter.st_ino == opened.st_ino,
                  descriptorAfter.st_size == opened.st_size,
                  descriptorAfter.st_gen == opened.st_gen,
                  descriptorAfter.st_mtimespec.tv_sec == opened.st_mtimespec.tv_sec,
                  descriptorAfter.st_mtimespec.tv_nsec == opened.st_mtimespec.tv_nsec,
                  descriptorAfter.st_ctimespec.tv_sec == opened.st_ctimespec.tv_sec,
                  descriptorAfter.st_ctimespec.tv_nsec == opened.st_ctimespec.tv_nsec,
                  entryAfter.st_mode & S_IFMT == S_IFREG,
                  entryAfter.st_nlink == 1,
                  entryAfter.st_dev == opened.st_dev,
                  entryAfter.st_ino == opened.st_ino,
                  entryAfter.st_size == opened.st_size,
                  entryAfter.st_gen == opened.st_gen,
                  entryAfter.st_mtimespec.tv_sec == opened.st_mtimespec.tv_sec,
                  entryAfter.st_mtimespec.tv_nsec == opened.st_mtimespec.tv_nsec,
                  entryAfter.st_ctimespec.tv_sec == opened.st_ctimespec.tv_sec,
                  entryAfter.st_ctimespec.tv_nsec == opened.st_ctimespec.tv_nsec,
                  Darwin.fcntl(descriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "legacy_import_artifact"
                )
            }
            descriptorOpen = false
            guard Darwin.close(descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_legacy_import_artifact"
                )
            }
            let semantic = try RuntimeGenerationArtifact(
                relativePath: relativePath,
                sha256: hasher.finalize().map { String(format: "%02x", $0) }.joined(),
                byteCount: byteCount,
                protectionClass: "complete"
            )
            return (
                try RuntimeGenerationObservedArtifact(
                    semantic: semantic,
                    fileIdentity: RuntimeStoreFileIdentity(
                        device: UInt64(opened.st_dev), inode: UInt64(opened.st_ino)
                    )
                ),
                retained
            )
        } catch {
            let operationError = error
            if descriptorOpen {
                descriptorOpen = false
                guard Darwin.close(descriptor) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
    }
}

/// Actor-owned, read-only SwiftData snapshot exporter. Every registered model
/// has an explicit review-only source disposition and bounded typed mapping;
/// any malformed, colliding, or unrepresentable record fails the export closed.
actor RuntimeSwiftDataTypedExporter {
    private static let exportPageSize = 16
    private let store: AmbitionsPersistenceStore

    init(store: AmbitionsPersistenceStore) {
        self.store = store
    }

    /// Writes only into a service-owned, already-created import staging
    /// directory. The import service holds its cross-process reconciliation
    /// lock until the artifact and initial source checkpoint commit atomically.
    func export(
        to url: URL,
        parentDescriptor: Int32,
        relativePath: String,
        transportSessionDigest: String
    ) async throws -> RuntimeSwiftDataTypedExportResult {
        try RuntimeGenerationControlValidation.requireRelativePath(relativePath)
        try RuntimeGenerationControlValidation.requireDigest(
            transportSessionDigest,
            field: "swiftdata_transport_session_digest"
        )
        let directory = url.deletingLastPathComponent()
        try RuntimeStorePathValidation.requireContained(url, in: directory)
        var directoryStatus = stat()
        guard fstat(parentDescriptor, &directoryStatus) == 0,
              directoryStatus.st_mode & S_IFMT == S_IFDIR,
              Darwin.fcntl(parentDescriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let descriptor = Darwin.openat(
            parentDescriptor,
            url.lastPathComponent,
            O_CREAT | O_EXCL | O_RDWR | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "create_swiftdata_typed_export"
            )
        }
        let stream = RuntimeSwiftDataExportStream(
            descriptor: descriptor,
            transportSessionDigest: transportSessionDigest
        )
        var closeAttempted = false
        var completedArtifact: RuntimeGenerationObservedArtifact?
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: descriptor,
                artifact: "swiftdata_typed_export"
            )
            try stream.appendHeader()
            try await store.read { context in
                try context.transaction {
                    try Self.exportAllModels(
                        from: context,
                        to: stream
                    )
                }
            }
            try stream.appendFooter()
            guard Darwin.fsync(descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_swiftdata_typed_export"
                )
            }
            var descriptorStatus = stat()
            var stagingStatus = stat()
            guard fstat(descriptor, &descriptorStatus) == 0,
                  fstatat(
                      parentDescriptor,
                      url.lastPathComponent,
                      &stagingStatus,
                      AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  descriptorStatus.st_mode & S_IFMT == S_IFREG,
                  descriptorStatus.st_nlink == 1, stagingStatus.st_nlink == 1,
                  descriptorStatus.st_dev == stagingStatus.st_dev,
                  descriptorStatus.st_ino == stagingStatus.st_ino,
                  descriptorStatus.st_size == stream.encodedByteCount else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "swiftdata_typed_export"
                )
            }
            let intendedTransportDigest = try stream.finalizeTransportDigest()
            var observedHasher = SHA256()
            var readOffset: Int64 = 0
            var readBuffer = [UInt8](repeating: 0, count: 128 * 1_024)
            while readOffset < Int64(descriptorStatus.st_size) {
                try Task.checkCancellation()
                let requested = min(
                    readBuffer.count,
                    Int(Int64(descriptorStatus.st_size) - readOffset)
                )
                let readCount = readBuffer.withUnsafeMutableBytes {
                    Darwin.pread(
                        descriptor,
                        $0.baseAddress,
                        requested,
                        off_t(readOffset)
                    )
                }
                if readCount < 0, errno == EINTR { continue }
                guard readCount > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "read_swiftdata_typed_export"
                    )
                }
                observedHasher.update(data: Data(readBuffer.prefix(readCount)))
                readOffset += Int64(readCount)
            }
            var trailingByte: UInt8 = 0
            var trailingCount: Int
            repeat {
                trailingCount = Darwin.pread(
                    descriptor,
                    &trailingByte,
                    1,
                    off_t(descriptorStatus.st_size)
                )
            } while trailingCount < 0 && errno == EINTR
            let observedTransportDigest = observedHasher.finalize().map {
                String(format: "%02x", $0)
            }.joined()
            var verifiedDescriptorStatus = stat()
            var verifiedEntryStatus = stat()
            guard trailingCount == 0,
                  observedTransportDigest == intendedTransportDigest,
                  fstat(descriptor, &verifiedDescriptorStatus) == 0,
                  fstatat(
                      parentDescriptor,
                      url.lastPathComponent,
                      &verifiedEntryStatus,
                      AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  verifiedDescriptorStatus.st_mode & S_IFMT == S_IFREG,
                  verifiedDescriptorStatus.st_nlink == 1,
                  verifiedDescriptorStatus.st_dev == descriptorStatus.st_dev,
                  verifiedDescriptorStatus.st_ino == descriptorStatus.st_ino,
                  verifiedDescriptorStatus.st_size == descriptorStatus.st_size,
                  verifiedDescriptorStatus.st_gen == descriptorStatus.st_gen,
                  verifiedDescriptorStatus.st_mtimespec.tv_sec ==
                    descriptorStatus.st_mtimespec.tv_sec,
                  verifiedDescriptorStatus.st_mtimespec.tv_nsec ==
                    descriptorStatus.st_mtimespec.tv_nsec,
                  verifiedDescriptorStatus.st_ctimespec.tv_sec ==
                    descriptorStatus.st_ctimespec.tv_sec,
                  verifiedDescriptorStatus.st_ctimespec.tv_nsec ==
                    descriptorStatus.st_ctimespec.tv_nsec,
                  verifiedEntryStatus.st_mode & S_IFMT == S_IFREG,
                  verifiedEntryStatus.st_nlink == 1,
                  verifiedEntryStatus.st_dev == descriptorStatus.st_dev,
                  verifiedEntryStatus.st_ino == descriptorStatus.st_ino,
                  verifiedEntryStatus.st_size == descriptorStatus.st_size,
                  verifiedEntryStatus.st_gen == descriptorStatus.st_gen,
                  verifiedEntryStatus.st_mtimespec.tv_sec ==
                    descriptorStatus.st_mtimespec.tv_sec,
                  verifiedEntryStatus.st_mtimespec.tv_nsec ==
                    descriptorStatus.st_mtimespec.tv_nsec,
                  verifiedEntryStatus.st_ctimespec.tv_sec ==
                    descriptorStatus.st_ctimespec.tv_sec,
                  verifiedEntryStatus.st_ctimespec.tv_nsec ==
                    descriptorStatus.st_ctimespec.tv_nsec else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "swiftdata_typed_export"
                )
            }
            let semantic = try RuntimeGenerationArtifact(
                relativePath: relativePath,
                sha256: observedTransportDigest,
                byteCount: Int64(descriptorStatus.st_size),
                protectionClass: "complete"
            )
            completedArtifact = try RuntimeGenerationObservedArtifact(
                semantic: semantic,
                fileIdentity: RuntimeStoreFileIdentity(
                    device: UInt64(descriptorStatus.st_dev),
                    inode: UInt64(descriptorStatus.st_ino)
                )
            )
            closeAttempted = true
            guard Darwin.close(descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_swiftdata_typed_export"
                )
            }
            guard Darwin.fsync(parentDescriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_swiftdata_typed_export_directory"
                )
            }
            var publishedStatus = stat()
            guard fstatat(
                parentDescriptor,
                url.lastPathComponent,
                &publishedStatus,
                AT_SYMLINK_NOFOLLOW
            ) == 0,
                  publishedStatus.st_dev == descriptorStatus.st_dev,
                  publishedStatus.st_ino == descriptorStatus.st_ino,
                  publishedStatus.st_mode & S_IFMT == S_IFREG,
                  publishedStatus.st_nlink == 1,
                  publishedStatus.st_size == descriptorStatus.st_size,
                  publishedStatus.st_gen == descriptorStatus.st_gen,
                  publishedStatus.st_mtimespec.tv_sec ==
                    descriptorStatus.st_mtimespec.tv_sec,
                  publishedStatus.st_mtimespec.tv_nsec ==
                    descriptorStatus.st_mtimespec.tv_nsec,
                  publishedStatus.st_ctimespec.tv_sec ==
                    descriptorStatus.st_ctimespec.tv_sec,
                  publishedStatus.st_ctimespec.tv_nsec ==
                    descriptorStatus.st_ctimespec.tv_nsec else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "published_swiftdata_typed_export"
                )
            }
        } catch {
            if closeAttempted == false {
                closeAttempted = true
                guard Darwin.close(descriptor) == 0 else {
                    guard Darwin.fsync(parentDescriptor) == 0 else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "preserve_failed_swiftdata_export_after_close_failure"
                        )
                    }
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_failed_swiftdata_typed_export"
                    )
                }
            }
            // The service-owned staging directory remains visible and locked;
            // any failure is preserved for startup orphan reconciliation.
            guard Darwin.fsync(parentDescriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "preserve_failed_swiftdata_typed_export"
                )
            }
            throw error
        }
        guard let artifact = completedArtifact else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        var directoryAfter = stat()
        guard fstat(parentDescriptor, &directoryAfter) == 0,
              directoryAfter.st_dev == directoryStatus.st_dev,
              directoryAfter.st_ino == directoryStatus.st_ino else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "swiftdata_typed_export_root"
            )
        }
        return RuntimeSwiftDataTypedExportResult(
            url: url,
            artifact: artifact,
            recordCount: stream.recordCount,
            recordSetDigest: stream.recordSetDigest
        )
    }

    private nonisolated static func exportAllModels(
        from context: ModelContext,
        to stream: RuntimeSwiftDataExportStream
    ) throws {
        // Model ordinal plus exact model-owned composite keysets yields a
        // stable, bounded snapshot without loading a whole model family.
        try exportGoalPages(context, stream)
        try exportGoalDraftPages(context, stream)
        try exportGoalPlanPages(context, stream)
        try exportPlanSectionPages(context, stream)
        try exportStepPages(context, stream)
        try exportProgressEvidencePages(context, stream)
        try exportFeedbackEventPages(context, stream)
        try exportCapturePages(context, stream)
        try exportReminderPages(context, stream)
        try exportTeachingSignalPages(context, stream)
        try exportEventLedgerPages(context, stream)
        try exportCommandExecutionPages(context, stream)
        try exportSideEffectPages(context, stream)
        try exportTombstonePages(context, stream)
        try exportAppStatePages(context, stream)
        try exportActionReceiptPages(context, stream)
        try exportRuntimeSnapshotPages(context, stream)
        try exportLifeContextPages(context, stream)
        try exportGraphOperationalPages(context, stream)
        try exportGraphProofPages(context, stream)
        try exportGraphProjectionPages(context, stream)
    }

    private nonisolated static func exportPages(
        modelType: RuntimeLegacySwiftDataSourceModelType,
        to stream: RuntimeSwiftDataExportStream,
        fetch: (RuntimeLegacySwiftDataModelCursor?) throws -> [RuntimeSwiftDataExportRecord]
    ) throws {
        var afterCursor: RuntimeLegacySwiftDataModelCursor?
        while true {
            try Task.checkCancellation()
            let page = try fetch(afterCursor)
            guard page.count <= exportPageSize,
                  page.allSatisfy({ $0.payload.modelType == modelType }) else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            guard page.isEmpty == false else { return }
            var pagePriorCursor = afterCursor
            for record in page {
                let cursor = try RuntimeLegacySwiftDataModelCursor(
                    modelType: modelType,
                    components: record.payload.orderingComponents
                )
                guard pagePriorCursor.map({ cursor.isStrictlyAfter($0) }) ?? true else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                try stream.append(record)
                pagePriorCursor = cursor
            }
            afterCursor = pagePriorCursor
            if page.count < exportPageSize { return }
        }
    }

    private nonisolated static func cursorInt(
        _ components: RuntimeLegacySwiftDataModelCursor,
        at index: Int
    ) throws -> Int {
        guard index >= 0,
              index < components.count,
              let value = Int(components[index]),
              value >= 0 else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        return value
    }

    private nonisolated static func exportGoalPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .goal, to: stream) { cursor in
            let predicate: Predicate<GoalRecord>?
            if let cursor {
                guard cursor.count == 3 else { throw RuntimeGenerationControlError.importReviewRequired }
                let updatedAt = cursor[0]
                let revision = try cursorInt(cursor, at: 1)
                let id = cursor[2]
                predicate = #Predicate<GoalRecord> {
                    $0.updatedAt > updatedAt ||
                    ($0.updatedAt == updatedAt && $0.revision > revision) ||
                    ($0.updatedAt == updatedAt && $0.revision == revision && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<GoalRecord>(
                predicate: predicate,
                sortBy: [
                    SortDescriptor(\GoalRecord.updatedAt),
                    SortDescriptor(\GoalRecord.revision),
                    SortDescriptor(\GoalRecord.id)
                ]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportGoalDraftPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .goalDraft, to: stream) { cursor in
            let predicate: Predicate<GoalDraftRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let updatedAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<GoalDraftRecord> {
                    $0.updatedAt > updatedAt || ($0.updatedAt == updatedAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<GoalDraftRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\GoalDraftRecord.updatedAt), SortDescriptor(\GoalDraftRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportGoalPlanPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .goalPlan, to: stream) { cursor in
            let predicate: Predicate<GoalPlanRecord>?
            if let cursor {
                guard cursor.count == 3 else { throw RuntimeGenerationControlError.importReviewRequired }
                let goalID = cursor[0]
                let version = try cursorInt(cursor, at: 1)
                let id = cursor[2]
                predicate = #Predicate<GoalPlanRecord> {
                    $0.goalID > goalID ||
                    ($0.goalID == goalID && $0.version > version) ||
                    ($0.goalID == goalID && $0.version == version && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<GoalPlanRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\GoalPlanRecord.goalID), SortDescriptor(\GoalPlanRecord.version), SortDescriptor(\GoalPlanRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportPlanSectionPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .planSection, to: stream) { cursor in
            let predicate: Predicate<PlanSectionRecord>?
            if let cursor {
                guard cursor.count == 4 else { throw RuntimeGenerationControlError.importReviewRequired }
                let goalID = cursor[0]
                let planID = cursor[1]
                let orderIndex = try cursorInt(cursor, at: 2)
                let id = cursor[3]
                predicate = #Predicate<PlanSectionRecord> {
                    $0.goalID > goalID ||
                    ($0.goalID == goalID && $0.planID > planID) ||
                    ($0.goalID == goalID && $0.planID == planID && $0.orderIndex > orderIndex) ||
                    ($0.goalID == goalID && $0.planID == planID && $0.orderIndex == orderIndex && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<PlanSectionRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\PlanSectionRecord.goalID), SortDescriptor(\PlanSectionRecord.planID), SortDescriptor(\PlanSectionRecord.orderIndex), SortDescriptor(\PlanSectionRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportStepPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .step, to: stream) { cursor in
            let predicate: Predicate<StepRecord>?
            if let cursor {
                guard cursor.count == 5 else { throw RuntimeGenerationControlError.importReviewRequired }
                let goalID = cursor[0]
                let planID = cursor[1]
                let sectionID = cursor[2]
                let orderIndex = try cursorInt(cursor, at: 3)
                let id = cursor[4]
                predicate = #Predicate<StepRecord> {
                    $0.goalID > goalID ||
                    ($0.goalID == goalID && $0.planID > planID) ||
                    ($0.goalID == goalID && $0.planID == planID && $0.sectionID > sectionID) ||
                    ($0.goalID == goalID && $0.planID == planID && $0.sectionID == sectionID && $0.orderIndex > orderIndex) ||
                    ($0.goalID == goalID && $0.planID == planID && $0.sectionID == sectionID && $0.orderIndex == orderIndex && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<StepRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\StepRecord.goalID), SortDescriptor(\StepRecord.planID), SortDescriptor(\StepRecord.sectionID), SortDescriptor(\StepRecord.orderIndex), SortDescriptor(\StepRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportProgressEvidencePages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .progressEvidence, to: stream) { cursor in
            let predicate: Predicate<ProgressEvidenceRecord>?
            if let cursor {
                guard cursor.count == 5,
                      cursor[2] == "0" || cursor[2] == "1" else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                let capturedAt = cursor[0]
                let goalID = cursor[1]
                let optionalTag = cursor[2]
                let stepID = cursor[3]
                let id = cursor[4]
                if optionalTag == "0" {
                    guard stepID.isEmpty else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                    predicate = #Predicate<ProgressEvidenceRecord> {
                        $0.capturedAt > capturedAt ||
                        ($0.capturedAt == capturedAt && $0.goalID > goalID) ||
                        ($0.capturedAt == capturedAt && $0.goalID == goalID && $0.stepID != nil) ||
                        ($0.capturedAt == capturedAt && $0.goalID == goalID && $0.stepID == nil && $0.id > id)
                    }
                } else {
                    predicate = #Predicate<ProgressEvidenceRecord> {
                        $0.capturedAt > capturedAt ||
                        ($0.capturedAt == capturedAt && $0.goalID > goalID) ||
                        ($0.capturedAt == capturedAt && $0.goalID == goalID && $0.stepID != nil && ($0.stepID ?? "") > stepID) ||
                        ($0.capturedAt == capturedAt && $0.goalID == goalID && $0.stepID != nil && ($0.stepID ?? "") == stepID && $0.id > id)
                    }
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<ProgressEvidenceRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\ProgressEvidenceRecord.capturedAt), SortDescriptor(\ProgressEvidenceRecord.goalID), SortDescriptor(\ProgressEvidenceRecord.stepID), SortDescriptor(\ProgressEvidenceRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportFeedbackEventPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .feedbackEvent, to: stream) { cursor in
            let predicate: Predicate<FeedbackEventRecord>?
            if let cursor {
                guard cursor.count == 4 else { throw RuntimeGenerationControlError.importReviewRequired }
                let occurredAt = cursor[0]
                let goalID = cursor[1]
                let stepID = cursor[2]
                let id = cursor[3]
                predicate = #Predicate<FeedbackEventRecord> {
                    $0.occurredAt > occurredAt ||
                    ($0.occurredAt == occurredAt && $0.goalID > goalID) ||
                    ($0.occurredAt == occurredAt && $0.goalID == goalID && $0.stepID > stepID) ||
                    ($0.occurredAt == occurredAt && $0.goalID == goalID && $0.stepID == stepID && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<FeedbackEventRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\FeedbackEventRecord.occurredAt), SortDescriptor(\FeedbackEventRecord.goalID), SortDescriptor(\FeedbackEventRecord.stepID), SortDescriptor(\FeedbackEventRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportCapturePages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .capture, to: stream) { cursor in
            let predicate: Predicate<CaptureRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let createdAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<CaptureRecord> {
                    $0.createdAt > createdAt || ($0.createdAt == createdAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<CaptureRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\CaptureRecord.createdAt), SortDescriptor(\CaptureRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportReminderPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .reminder, to: stream) { cursor in
            let predicate: Predicate<ReminderRecord>?
            if let cursor {
                guard cursor.count == 4,
                      cursor[0] == "0" || cursor[0] == "1" else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                let optionalTag = cursor[0]
                let triggerAt = cursor[1]
                let createdAt = cursor[2]
                let id = cursor[3]
                if optionalTag == "0" {
                    guard triggerAt.isEmpty else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                    predicate = #Predicate<ReminderRecord> {
                        $0.triggerAt != nil ||
                        ($0.triggerAt == nil && $0.createdAt > createdAt) ||
                        ($0.triggerAt == nil && $0.createdAt == createdAt && $0.id > id)
                    }
                } else {
                    predicate = #Predicate<ReminderRecord> {
                        $0.triggerAt != nil && ($0.triggerAt ?? "") > triggerAt ||
                        ($0.triggerAt != nil && ($0.triggerAt ?? "") == triggerAt && $0.createdAt > createdAt) ||
                        ($0.triggerAt != nil && ($0.triggerAt ?? "") == triggerAt && $0.createdAt == createdAt && $0.id > id)
                    }
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<ReminderRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\ReminderRecord.triggerAt), SortDescriptor(\ReminderRecord.createdAt), SortDescriptor(\ReminderRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportTeachingSignalPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .teachingSignal, to: stream) { cursor in
            let predicate: Predicate<TeachingSignalRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let createdAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<TeachingSignalRecord> {
                    $0.createdAt > createdAt || ($0.createdAt == createdAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<TeachingSignalRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\TeachingSignalRecord.createdAt), SortDescriptor(\TeachingSignalRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportEventLedgerPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .eventLedger, to: stream) { cursor in
            let predicate: Predicate<EventLedgerRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let occurredAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<EventLedgerRecord> {
                    $0.occurredAt > occurredAt || ($0.occurredAt == occurredAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<EventLedgerRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\EventLedgerRecord.occurredAt), SortDescriptor(\EventLedgerRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportCommandExecutionPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .commandExecution, to: stream) { cursor in
            let predicate: Predicate<CommandExecutionRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let recordedAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<CommandExecutionRecord> {
                    $0.recordedAt > recordedAt || ($0.recordedAt == recordedAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<CommandExecutionRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\CommandExecutionRecord.recordedAt), SortDescriptor(\CommandExecutionRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportSideEffectPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .sideEffectLedger, to: stream) { cursor in
            let predicate: Predicate<SideEffectLedgerStorageRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let occurredAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<SideEffectLedgerStorageRecord> {
                    $0.occurredAt > occurredAt || ($0.occurredAt == occurredAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<SideEffectLedgerStorageRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\SideEffectLedgerStorageRecord.occurredAt), SortDescriptor(\SideEffectLedgerStorageRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportTombstonePages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .entityRevisionTombstone, to: stream) { cursor in
            let predicate: Predicate<EntityRevisionTombstoneRecord>?
            if let cursor {
                guard cursor.count == 5 else { throw RuntimeGenerationControlError.importReviewRequired }
                let recordedAt = cursor[0]
                let entityKind = cursor[1]
                let entityID = cursor[2]
                let revisionMarker = cursor[3]
                let id = cursor[4]
                predicate = #Predicate<EntityRevisionTombstoneRecord> {
                    $0.recordedAt > recordedAt ||
                    ($0.recordedAt == recordedAt && $0.entityKindRaw > entityKind) ||
                    ($0.recordedAt == recordedAt && $0.entityKindRaw == entityKind && $0.entityID > entityID) ||
                    ($0.recordedAt == recordedAt && $0.entityKindRaw == entityKind && $0.entityID == entityID && $0.revisionMarker > revisionMarker) ||
                    ($0.recordedAt == recordedAt && $0.entityKindRaw == entityKind && $0.entityID == entityID && $0.revisionMarker == revisionMarker && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<EntityRevisionTombstoneRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\EntityRevisionTombstoneRecord.recordedAt), SortDescriptor(\EntityRevisionTombstoneRecord.entityKindRaw), SortDescriptor(\EntityRevisionTombstoneRecord.entityID), SortDescriptor(\EntityRevisionTombstoneRecord.revisionMarker), SortDescriptor(\EntityRevisionTombstoneRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportAppStatePages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .appState, to: stream) { cursor in
            let predicate: Predicate<AppStateRecord>?
            if let cursor {
                guard cursor.count == 1 else { throw RuntimeGenerationControlError.importReviewRequired }
                let id = cursor[0]
                predicate = #Predicate<AppStateRecord> { $0.id > id }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<AppStateRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\AppStateRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportActionReceiptPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .actionReceipt, to: stream) { cursor in
            let predicate: Predicate<ActionReceiptHistoryRecordModel>?
            if let cursor {
                guard cursor.count == 3 else { throw RuntimeGenerationControlError.importReviewRequired }
                let occurredAt = cursor[0]
                let createdAt = cursor[1]
                let id = cursor[2]
                predicate = #Predicate<ActionReceiptHistoryRecordModel> {
                    $0.occurredAt > occurredAt ||
                    ($0.occurredAt == occurredAt && $0.createdAt > createdAt) ||
                    ($0.occurredAt == occurredAt && $0.createdAt == createdAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<ActionReceiptHistoryRecordModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\ActionReceiptHistoryRecordModel.occurredAt), SortDescriptor(\ActionReceiptHistoryRecordModel.createdAt), SortDescriptor(\ActionReceiptHistoryRecordModel.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportRuntimeSnapshotPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .runtimeSnapshot, to: stream) { cursor in
            let predicate: Predicate<RuntimeSnapshotLedgerRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let generatedAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<RuntimeSnapshotLedgerRecord> {
                    $0.generatedAt > generatedAt || ($0.generatedAt == generatedAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<RuntimeSnapshotLedgerRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\RuntimeSnapshotLedgerRecord.generatedAt), SortDescriptor(\RuntimeSnapshotLedgerRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportLifeContextPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .lifeContext, to: stream) { cursor in
            let predicate: Predicate<LifeContextBundleRecord>?
            if let cursor {
                guard cursor.count == 2 else { throw RuntimeGenerationControlError.importReviewRequired }
                let updatedAt = cursor[0]
                let id = cursor[1]
                predicate = #Predicate<LifeContextBundleRecord> {
                    $0.updatedAt > updatedAt || ($0.updatedAt == updatedAt && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<LifeContextBundleRecord>(
                predicate: predicate,
                sortBy: [SortDescriptor(\LifeContextBundleRecord.updatedAt), SortDescriptor(\LifeContextBundleRecord.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportGraphOperationalPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .graphOperational, to: stream) { cursor in
            let predicate: Predicate<AmbitionGraphOperationalRecordModel>?
            if let cursor {
                guard cursor.count == 3 else { throw RuntimeGenerationControlError.importReviewRequired }
                let generatedAt = cursor[0]
                let ambitionID = cursor[1]
                let id = cursor[2]
                predicate = #Predicate<AmbitionGraphOperationalRecordModel> {
                    $0.generatedAt > generatedAt ||
                    ($0.generatedAt == generatedAt && $0.ambitionID > ambitionID) ||
                    ($0.generatedAt == generatedAt && $0.ambitionID == ambitionID && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<AmbitionGraphOperationalRecordModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\AmbitionGraphOperationalRecordModel.generatedAt), SortDescriptor(\AmbitionGraphOperationalRecordModel.ambitionID), SortDescriptor(\AmbitionGraphOperationalRecordModel.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportGraphProofPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .graphProof, to: stream) { cursor in
            let predicate: Predicate<AmbitionGraphProofRecordModel>?
            if let cursor {
                guard cursor.count == 4 else { throw RuntimeGenerationControlError.importReviewRequired }
                let ambitionID = cursor[0]
                let version = try cursorInt(cursor, at: 1)
                let proofID = cursor[2]
                let id = cursor[3]
                predicate = #Predicate<AmbitionGraphProofRecordModel> {
                    $0.ambitionID > ambitionID ||
                    ($0.ambitionID == ambitionID && $0.version > version) ||
                    ($0.ambitionID == ambitionID && $0.version == version && $0.proofID > proofID) ||
                    ($0.ambitionID == ambitionID && $0.version == version && $0.proofID == proofID && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<AmbitionGraphProofRecordModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\AmbitionGraphProofRecordModel.ambitionID), SortDescriptor(\AmbitionGraphProofRecordModel.version), SortDescriptor(\AmbitionGraphProofRecordModel.proofID), SortDescriptor(\AmbitionGraphProofRecordModel.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func exportGraphProjectionPages(
        _ context: ModelContext,
        _ stream: RuntimeSwiftDataExportStream
    ) throws {
        try exportPages(modelType: .graphProjection, to: stream) { cursor in
            let predicate: Predicate<AmbitionGraphProjectionRecordModel>?
            if let cursor {
                guard cursor.count == 3 else { throw RuntimeGenerationControlError.importReviewRequired }
                let generatedAt = cursor[0]
                let ambitionID = cursor[1]
                let id = cursor[2]
                predicate = #Predicate<AmbitionGraphProjectionRecordModel> {
                    $0.generatedAt > generatedAt ||
                    ($0.generatedAt == generatedAt && $0.ambitionID > ambitionID) ||
                    ($0.generatedAt == generatedAt && $0.ambitionID == ambitionID && $0.id > id)
                }
            } else { predicate = nil }
            var descriptor = FetchDescriptor<AmbitionGraphProjectionRecordModel>(
                predicate: predicate,
                sortBy: [SortDescriptor(\AmbitionGraphProjectionRecordModel.generatedAt), SortDescriptor(\AmbitionGraphProjectionRecordModel.ambitionID), SortDescriptor(\AmbitionGraphProjectionRecordModel.id)]
            )
            descriptor.fetchLimit = exportPageSize
            return try context.fetch(descriptor).map(TypedEnvelopeMapper.map)
        }
    }

    private nonisolated static func column(
        _ name: String,
        _ type: String,
        _ bytes: Data,
        encoding: RuntimeLegacySwiftDataEncodedColumnEncoding = .canonicalJSON
    ) throws -> RuntimeLegacySwiftDataEncodedColumn {
        try .make(
            columnName: name,
            encodedTypeName: type,
            encoding: encoding,
            bytes: bytes
        )
    }

    private nonisolated static func claim(
        _ column: String,
        _ kind: RuntimeLegacySwiftDataRelationshipKind,
        targetModel: RuntimeLegacySwiftDataSourceModelType? = nil,
        targetType: String,
        id: String,
        required: Bool,
        order: Int? = nil
    ) throws -> RuntimeLegacySwiftDataRelationshipClaim {
        try .make(
            sourceColumnName: column,
            kind: kind,
            targetModelType: targetModel,
            targetTypeName: targetType,
            targetStableID: id,
            isRequired: required,
            orderIndex: order
        )
    }

    private nonisolated static func optionalClaim(
        _ column: String,
        _ kind: RuntimeLegacySwiftDataRelationshipKind,
        targetModel: RuntimeLegacySwiftDataSourceModelType? = nil,
        targetType: String,
        id: String?
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        guard let id else { return [] }
        return [try claim(
            column,
            kind,
            targetModel: targetModel,
            targetType: targetType,
            id: id,
            required: false
        )]
    }

    private nonisolated static func stringClaims(
        _ column: String,
        _ kind: RuntimeLegacySwiftDataRelationshipKind,
        targetModel: RuntimeLegacySwiftDataSourceModelType? = nil,
        targetType: String,
        bytes: Data
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        let ids = try JSONDecoder().decode([String].self, from: bytes)
        return try ids.enumerated().map { index, id in
            try claim(
                column,
                kind,
                targetModel: targetModel,
                targetType: targetType,
                id: id,
                required: false,
                order: index
            )
        }
    }

    private nonisolated static func exportRecord(
        _ record: GoalRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try optionalClaim(
            "parentGoalID", .parent, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            id: record.parentGoalID
        )
        claims += try stringClaims(
            "childGoalIDsData", .child, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            bytes: record.childGoalIDsData
        )
        claims += try stringClaims(
            "supportGoalIDsData", .reference, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            bytes: record.supportGoalIDsData
        )
        return RuntimeSwiftDataExportRecord(
            payload: .goal(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                revision: record.revision,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                stateRaw: record.stateRaw,
                title: record.title,
                summaryText: record.summaryText,
                modeRaw: record.modeRaw,
                relationshipKindRaw: record.relationshipKindRaw,
                actorDisplayName: record.actorDisplayName,
                actorOwnershipRaw: record.actorOwnershipRaw,
                parentGoalID: record.parentGoalID,
                childGoalIDs: try column("childGoalIDsData", "[String]", record.childGoalIDsData),
                supportGoalIDs: try column("supportGoalIDsData", "[String]", record.supportGoalIDsData),
                tags: try column("tagsData", "[String]", record.tagsData),
                tempoRaw: record.tempoRaw,
                timingTypeRaw: record.timingTypeRaw,
                startsOn: record.startsOn,
                dueAt: record.dueAt,
                targetBy: record.targetBy,
                windowStart: record.windowStart,
                windowEnd: record.windowEnd,
                suggestedNextAt: record.suggestedNextAt,
                repeatEveryDays: record.repeatEveryDays,
                progressReviewCadenceDays: record.progressReviewCadenceDays,
                planningStrategy: try column(
                    "planningStrategyData", "PlanningStrategy", record.planningStrategyData
                ),
                progressStrategy: try column(
                    "progressStrategyData", "ProgressStrategy", record.progressStrategyData
                ),
                snapshot: try column("snapshotData", "Goal", record.snapshotData)
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: GoalDraftRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .goalDraft(.init(
                id: record.id,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                title: record.title,
                modeRaw: record.modeRaw,
                resultKindRaw: record.resultKindRaw,
                readinessRaw: record.readinessRaw,
                plannedGoalID: record.plannedGoalID,
                snapshot: try column(
                    "snapshotData", "PersistedGoalDraft", record.snapshotData
                )
            )),
            relationshipClaims: try optionalClaim(
                "plannedGoalID", .reference, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.plannedGoalID
            )
        )
    }

    private nonisolated static func exportRecord(
        _ record: GoalPlanRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .goalPlan(.init(
                id: record.id,
                goalID: record.goalID,
                version: record.version,
                generatedAt: record.generatedAt,
                summaryText: record.summaryText,
                strategy: try column("strategyData", "PlanningStrategy", record.strategyData),
                assumptions: try column(
                    "assumptionsData", "[PlanAssumption]", record.assumptionsData
                ),
                lint: try column("lintData", "PlanLintResult", record.lintData),
                snapshot: try column("snapshotData", "GoalPlan", record.snapshotData)
            )),
            relationshipClaims: [try claim(
                "goalID", .parent, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.goalID,
                required: true
            )]
        )
    }

    private nonisolated static func exportRecord(
        _ record: PlanSectionRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .planSection(.init(
                id: record.id,
                goalID: record.goalID,
                planID: record.planID,
                title: record.title,
                summaryText: record.summaryText,
                kindRaw: record.kindRaw,
                orderIndex: record.orderIndex
            )),
            relationshipClaims: [
                try claim(
                    "goalID", .parent, targetModel: .goal,
                    targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                    id: record.goalID,
                    required: true
                ),
                try claim(
                    "planID", .parent, targetModel: .goalPlan,
                    targetType: RuntimeLegacySwiftDataSourceModelType.goalPlan.rawValue,
                    id: record.planID,
                    required: true,
                    order: record.orderIndex
                )
            ]
        )
    }

    private nonisolated static func exportRecord(
        _ record: StepRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = [
            try claim(
                "goalID", .parent, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.goalID, required: true
            ),
            try claim(
                "planID", .parent, targetModel: .goalPlan,
                targetType: RuntimeLegacySwiftDataSourceModelType.goalPlan.rawValue,
                id: record.planID, required: true
            ),
            try claim(
                "sectionID", .orderedChild, targetModel: .planSection,
                targetType: RuntimeLegacySwiftDataSourceModelType.planSection.rawValue,
                id: record.sectionID, required: true, order: record.orderIndex
            )
        ]
        claims += try stringClaims(
            "dependencyStepIDsData", .dependency, targetModel: .step,
            targetType: RuntimeLegacySwiftDataSourceModelType.step.rawValue,
            bytes: record.dependencyStepIDsData
        )
        return RuntimeSwiftDataExportRecord(
            payload: .step(.init(
                id: record.id,
                goalID: record.goalID,
                planID: record.planID,
                sectionID: record.sectionID,
                orderIndex: record.orderIndex,
                title: record.title,
                summaryText: record.summaryText,
                typeRaw: record.typeRaw,
                stateRaw: record.stateRaw,
                ownerDisplayName: record.ownerDisplayName,
                ownerOwnershipRaw: record.ownerOwnershipRaw,
                tempoRaw: record.tempoRaw,
                timingTypeRaw: record.timingTypeRaw,
                startsOn: record.startsOn,
                dueAt: record.dueAt,
                targetBy: record.targetBy,
                windowStart: record.windowStart,
                windowEnd: record.windowEnd,
                suggestedNextAt: record.suggestedNextAt,
                repeatEveryDays: record.repeatEveryDays,
                progressReviewCadenceDays: record.progressReviewCadenceDays,
                dependencyStepIDs: try column(
                    "dependencyStepIDsData", "[String]", record.dependencyStepIDsData
                ),
                successSignals: try column(
                    "successSignalsData", "[String]", record.successSignalsData
                ),
                actionability: try column(
                    "actionabilityData", "StepActionability", record.actionabilityData
                ),
                isOptional: record.isOptional,
                isRepeatable: record.isRepeatable,
                evidenceRequired: record.evidenceRequired,
                snapshot: try column("snapshotData", "Step", record.snapshotData)
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: ProgressEvidenceRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = [try claim(
            "goalID", .parent, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            id: record.goalID, required: true
        )]
        claims += try optionalClaim(
            "stepID", .reference, targetModel: .step,
            targetType: RuntimeLegacySwiftDataSourceModelType.step.rawValue,
            id: record.stepID
        )
        return RuntimeSwiftDataExportRecord(
            payload: .progressEvidence(.init(
                id: record.id,
                goalID: record.goalID,
                stepID: record.stepID,
                capturedAt: record.capturedAt,
                evidenceKindRaw: record.evidenceKindRaw,
                sourceRaw: record.sourceRaw,
                progressDelta: record.progressDelta,
                confidenceDelta: record.confidenceDelta,
                minutesInvested: record.minutesInvested,
                note: record.note,
                snapshot: try column(
                    "snapshotData", "ProgressEvidence", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: FeedbackEventRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .feedbackEvent(.init(
                id: record.id,
                goalID: record.goalID,
                stepID: record.stepID,
                occurredAt: record.occurredAt,
                kindRaw: record.kindRaw,
                note: record.note,
                payload: try column(
                    "payloadData", "StoredGoalFeedbackEvent", record.payloadData
                )
            )),
            relationshipClaims: [
                try claim(
                    "goalID", .parent, targetModel: .goal,
                    targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                    id: record.goalID, required: true
                ),
                try claim(
                    "stepID", .reference, targetModel: .step,
                    targetType: RuntimeLegacySwiftDataSourceModelType.step.rawValue,
                    id: record.stepID, required: true
                )
            ]
        )
    }

    private nonisolated static func exportRecord(
        _ record: CaptureRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .capture(.init(
                id: record.id,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                rawText: record.rawText,
                sourceTypeRaw: record.sourceTypeRaw,
                statusRaw: record.statusRaw,
                linkedGoalID: record.linkedGoalID,
                snapshot: try column("snapshotData", "Capture", record.snapshotData)
            )),
            relationshipClaims: try optionalClaim(
                "linkedGoalID", .reference, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.linkedGoalID
            )
        )
    }

    private nonisolated static func exportRecord(
        _ record: ReminderRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try optionalClaim(
            "receiptID", .receipt, targetModel: .actionReceipt,
            targetType: RuntimeLegacySwiftDataSourceModelType.actionReceipt.rawValue,
            id: record.receiptID
        )
        claims += try optionalClaim(
            "replayTraceID", .replayTrace,
            targetType: "RuntimeReplayTrace", id: record.replayTraceID
        )
        claims += try optionalClaim(
            "sourceRecordID", .source,
            targetType: "SourceRecord", id: record.sourceRecordID
        )
        claims += try optionalClaim(
            "attachedObjectID", .attachedObject,
            targetType: "CanonicalObject", id: record.attachedObjectID
        )
        return RuntimeSwiftDataExportRecord(
            payload: .reminder(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                deletedAt: record.deletedAt,
                title: record.title,
                summaryText: record.summaryText,
                triggerAt: record.triggerAt,
                kindRaw: record.kindRaw,
                stateRaw: record.stateRaw,
                receiptID: record.receiptID,
                replayTraceID: record.replayTraceID,
                sourceRecordID: record.sourceRecordID,
                attachedObjectID: record.attachedObjectID,
                deliveryPolicy: try column(
                    "deliveryPolicyData", "ReminderDeliveryPolicy",
                    record.deliveryPolicyData
                ),
                source: try column("sourceData", "ReminderSource", record.sourceData),
                attachment: try record.attachmentData.map {
                    try column("attachmentData", "ReminderAttachment", $0)
                },
                snapshot: try column(
                    "snapshotData", "ReminderTrigger", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: TeachingSignalRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .teachingSignal(.init(
                id: record.id,
                goalID: record.goalID,
                kindRaw: record.kindRaw,
                sourceRaw: record.sourceRaw,
                dispositionRaw: record.dispositionRaw,
                applicationKey: record.applicationKey,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                snapshot: try column(
                    "snapshotData", "GoalTeachingSignal", record.snapshotData
                )
            )),
            relationshipClaims: [try claim(
                "goalID", .parent, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.goalID, required: true
            )]
        )
    }

    private nonisolated static func eventEvidenceClaims(
        _ data: Data
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        let references = try JSONDecoder().decode(
            [EventLedgerEvidenceReference].self,
            from: data
        )
        return try references.enumerated().map { index, reference in
            let target: (RuntimeLegacySwiftDataSourceModelType?, String)
            switch reference.kind {
            case .goal:
                target = (.goal, RuntimeLegacySwiftDataSourceModelType.goal.rawValue)
            case .capture:
                target = (.capture, RuntimeLegacySwiftDataSourceModelType.capture.rawValue)
            case .plan:
                target = (.goalPlan, RuntimeLegacySwiftDataSourceModelType.goalPlan.rawValue)
            case .feedbackEvent:
                target = (
                    .feedbackEvent,
                    RuntimeLegacySwiftDataSourceModelType.feedbackEvent.rawValue
                )
            case .progressEvidence:
                target = (
                    .progressEvidence,
                    RuntimeLegacySwiftDataSourceModelType.progressEvidence.rawValue
                )
            case .teachingSignal:
                target = (
                    .teachingSignal,
                    RuntimeLegacySwiftDataSourceModelType.teachingSignal.rawValue
                )
            case .review:
                target = (nil, "Review")
            case .recommendation:
                target = (nil, "Recommendation")
            case .calendarContext:
                target = (nil, "CalendarContext")
            case .accessibilityAudit:
                target = (nil, "AccessibilityAudit")
            case .syncConflict:
                target = (nil, "SyncConflict")
            case .externalCommand:
                target = (nil, "AmbitionsCommand")
            }
            return try claim(
                "evidenceReferencesData", .reference,
                targetModel: target.0,
                targetType: target.1,
                id: reference.id,
                required: false,
                order: index
            )
        }
    }

    private nonisolated static func exportRecord(
        _ record: EventLedgerRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try optionalClaim(
            "goalID", .reference, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            id: record.goalID
        )
        claims += try optionalClaim(
            "captureID", .reference, targetModel: .capture,
            targetType: RuntimeLegacySwiftDataSourceModelType.capture.rawValue,
            id: record.captureID
        )
        claims += try optionalClaim(
            "planID", .reference, targetModel: .goalPlan,
            targetType: RuntimeLegacySwiftDataSourceModelType.goalPlan.rawValue,
            id: record.planID
        )
        claims += try optionalClaim(
            "reviewID", .reference, targetType: "Review", id: record.reviewID
        )
        claims += try eventEvidenceClaims(record.evidenceReferencesData)
        return RuntimeSwiftDataExportRecord(
            payload: .eventLedger(.init(
                id: record.id,
                kindRaw: record.kindRaw,
                occurredAt: record.occurredAt,
                occurredAtDate: record.occurredAtDate,
                sourceRaw: record.sourceRaw,
                goalID: record.goalID,
                captureID: record.captureID,
                planID: record.planID,
                planScope: record.planScope,
                reviewID: record.reviewID,
                title: record.title,
                summaryText: record.summaryText,
                semanticState: record.semanticState,
                toneRaw: record.toneRaw,
                schemaVersion: record.schemaVersion,
                privacyRaw: record.privacyRaw,
                localOnly: record.localOnly,
                createdAt: record.createdAt,
                createdAtDate: record.createdAtDate,
                updatedAt: record.updatedAt,
                updatedAtDate: record.updatedAtDate,
                evidenceReferences: try column(
                    "evidenceReferencesData", "[EventLedgerEvidenceReference]",
                    record.evidenceReferencesData
                ),
                metadata: try column(
                    "metadataData", "[String: String]", record.metadataData
                ),
                payload: try column(
                    "payloadData", "[String: String]", record.payloadData
                ),
                trust: try column(
                    "trustData", "EventLedgerTrustMetadata", record.trustData
                ),
                snapshot: try column(
                    "snapshotData", "EventLedgerEntry", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: CommandExecutionRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .commandExecution(.init(
                id: record.id,
                commandID: record.commandID,
                commandKindRaw: record.commandKindRaw,
                commandSourceRaw: record.commandSourceRaw,
                actorRaw: record.actorRaw,
                executionStatusRaw: record.executionStatusRaw,
                resultStatusRaw: record.resultStatusRaw,
                recordedAt: record.recordedAt,
                recordedAtDate: record.recordedAtDate,
                schemaVersion: record.schemaVersion,
                localOnly: record.localOnly,
                privacyRaw: record.privacyRaw,
                command: try column(
                    "commandData", "AmbitionsCommand", record.commandData,
                    encoding: .runtimeCommandCodec
                ),
                result: try column(
                    "resultData", "AmbitionsCommandExecutionResult", record.resultData
                )
            )),
            relationshipClaims: [try claim(
                "commandID", .reference,
                targetType: "AmbitionsCommand",
                id: record.commandID,
                required: true
            )]
        )
    }

    private nonisolated static func targetObjectClaims(
        _ data: Data
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        let references = try JSONDecoder().decode(
            [LifeGraphObjectReference].self,
            from: data
        )
        return try references.enumerated().map { index, reference in
            try claim(
                "targetObjectsData", .reference,
                targetType: "LifeGraphObject.\(reference.kind.rawValue)",
                id: reference.id,
                required: false,
                order: index
            )
        }
    }

    private nonisolated static func exportRecord(
        _ record: SideEffectLedgerStorageRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try optionalClaim(
            "commandID", .reference,
            targetType: "AmbitionsCommand", id: record.commandID
        )
        claims += try optionalClaim(
            "receiptID", .receipt, targetModel: .actionReceipt,
            targetType: RuntimeLegacySwiftDataSourceModelType.actionReceipt.rawValue,
            id: record.receiptID
        )
        claims += try targetObjectClaims(record.targetObjectsData)
        return RuntimeSwiftDataExportRecord(
            payload: .sideEffectLedger(.init(
                id: record.id,
                effectKindRaw: record.effectKindRaw,
                statusRaw: record.statusRaw,
                boundaryRaw: record.boundaryRaw,
                actionKindRaw: record.actionKindRaw,
                sourceDomainRaw: record.sourceDomainRaw,
                commandID: record.commandID,
                targetObjects: try column(
                    "targetObjectsData", "[LifeGraphObjectReference]",
                    record.targetObjectsData
                ),
                requiresConfirmation: record.requiresConfirmation,
                externalEffect: record.externalEffect,
                reasons: try column(
                    "reasonsData", "[SafeAutomationPolicyReason]", record.reasonsData
                ),
                blockedFacts: try column(
                    "blockedFactsData", "[String]", record.blockedFactsData
                ),
                degradedFacts: try column(
                    "degradedFactsData", "[String]", record.degradedFactsData
                ),
                receiptID: record.receiptID,
                schemaVersion: record.schemaVersion,
                localOnly: record.localOnly,
                occurredAt: record.occurredAt,
                occurredAtDate: record.occurredAtDate,
                snapshot: try column(
                    "snapshotData", "SideEffectLedgerRecord", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: EntityRevisionTombstoneRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = [
            try claim(
                "entityID", .reference,
                targetType: "CanonicalEntity.\(record.entityKindRaw)",
                id: record.entityID, required: true
            ),
            try claim(
                "lineageID", .source,
                targetType: "EntityLineage", id: record.lineageID, required: true
            )
        ]
        claims += try stringClaims(
            "ancestryLineageIDsData", .source,
            targetType: "EntityLineage", bytes: record.ancestryLineageIDsData
        )
        claims += try optionalClaim(
            "sourceRecordID", .source,
            targetType: "SourceRecord", id: record.sourceRecordID
        )
        claims += try optionalClaim(
            "receiptID", .receipt, targetModel: .actionReceipt,
            targetType: RuntimeLegacySwiftDataSourceModelType.actionReceipt.rawValue,
            id: record.receiptID
        )
        claims += try optionalClaim(
            "replayTraceID", .replayTrace,
            targetType: "RuntimeReplayTrace", id: record.replayTraceID
        )
        return RuntimeSwiftDataExportRecord(
            payload: .entityRevisionTombstone(.init(
                id: record.id,
                entityKindRaw: record.entityKindRaw,
                entityID: record.entityID,
                revisionMarker: record.revisionMarker,
                reasonRaw: record.reasonRaw,
                recordedAt: record.recordedAt,
                recordedAtDate: record.recordedAtDate,
                localOnly: record.localOnly,
                lineageID: record.lineageID,
                ancestryLineageIDs: try column(
                    "ancestryLineageIDsData", "[String]",
                    record.ancestryLineageIDsData
                ),
                lifecycleStateRaw: record.lifecycleStateRaw,
                privacyClassRaw: record.privacyClassRaw,
                sourceRecordID: record.sourceRecordID,
                receiptID: record.receiptID,
                replayTraceID: record.replayTraceID,
                schemaVersion: record.schemaVersion,
                snapshot: try column(
                    "snapshotData", "EntityRevisionTombstone", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: AppStateRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .appState(.init(
                id: record.id,
                preferredTabRaw: record.preferredTabRaw,
                userDisplayName: record.userDisplayName,
                appearancePreferenceRaw: record.appearancePreferenceRaw,
                accentFamilyRaw: record.accentFamilyRaw,
                hasCompletedBootstrap: record.hasCompletedBootstrap,
                lastBootstrapSourceRaw: record.lastBootstrapSourceRaw,
                lastBootstrapAt: record.lastBootstrapAt,
                lastSeedVersion: record.lastSeedVersion,
                lastSeededAt: record.lastSeededAt,
                lastOpenedGoalID: record.lastOpenedGoalID,
                snapshot: try column(
                    "snapshotData", "AppStateSnapshot", record.snapshotData
                )
            )),
            relationshipClaims: try optionalClaim(
                "lastOpenedGoalID", .reference, targetModel: .goal,
                targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
                id: record.lastOpenedGoalID
            )
        )
    }

    private nonisolated static func receiptLineageClaims(
        proofData: Data,
        runtimeData: Data?
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        let proof = try JSONDecoder().decode(
            ActionReceiptProofFreshnessLineage.self,
            from: proofData
        )
        var claims = [try claim(
            "proofFreshnessLineageData", .receipt,
            targetType: "ActionReceipt",
            id: proof.receiptID,
            required: true
        )]
        if let sourceObjectID = proof.sourceObjectID {
            claims.append(try claim(
                "proofFreshnessLineageData", .source,
                targetType: proof.sourceObjectKind.map {
                    "LifeGraphObject.\($0.rawValue)"
                } ?? "CanonicalObject",
                id: sourceObjectID,
                required: false
            ))
        }
        claims += try proof.lineageObjectIDs.enumerated().map { index, id in
            try claim(
                "proofFreshnessLineageData", .source,
                targetType: "LineageObject", id: id,
                required: false, order: index
            )
        }
        claims += try proof.proofReferenceIDs.enumerated().map { index, id in
            try claim(
                "proofFreshnessLineageData", .reference,
                targetType: "ProofReference", id: id,
                required: false, order: index
            )
        }
        if let runtimeData {
            let runtime = try JSONDecoder().decode(
                RuntimeTrustLineage.self,
                from: runtimeData
            )
            let direct: [(RuntimeLegacySwiftDataRelationshipKind, String, String)] = [
                (.receipt, "RuntimeCommitReceipt", runtime.runtimeCommitReceiptID),
                (.reference, "RuntimeTransaction", runtime.runtimeTransactionID),
                (.reference, "RuntimeEvent", runtime.runtimeEventID),
                (.receipt, "RuntimeReceipt", runtime.runtimeReceiptID),
                (.reference, "RuntimeProofArtifact", runtime.runtimeProofArtifactID),
                (.reference, "RuntimeRollbackPlan", runtime.runtimeRollbackPlanID),
                (.replayTrace, "RuntimeReplayTrace", runtime.runtimeReplayTraceID),
                (.reference, "AmbitionsCommand", runtime.runtimeCommandID)
            ]
            claims += try direct.map { kind, type, id in
                try claim(
                    "runtimeLineageData", kind,
                    targetType: type, id: id, required: true
                )
            }
            claims += try runtime.affectedObjectIDs.enumerated().map { index, id in
                try claim(
                    "runtimeLineageData", .reference,
                    targetType: "CanonicalObject", id: id,
                    required: false, order: index
                )
            }
        }
        return claims
    }

    private nonisolated static func exportRecord(
        _ record: ActionReceiptHistoryRecordModel
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .actionReceipt(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                sourceDomainRaw: record.sourceDomainRaw,
                resultStateRaw: record.resultStateRaw,
                privacyLevelRaw: record.privacyLevelRaw,
                proofRelevanceRaw: record.proofRelevanceRaw,
                undoAvailabilityRaw: record.undoAvailabilityRaw,
                requiresConfirmationBeforeBroaderUse:
                    record.requiresConfirmationBeforeBroaderUse,
                localOnly: record.localOnly,
                createdAt: record.createdAt,
                createdAtDate: record.createdAtDate,
                occurredAt: record.occurredAt,
                occurredAtDate: record.occurredAtDate,
                receipt: try column(
                    "receiptData", "ActionReceipt", record.receiptData
                ),
                proofFreshnessLineage: try column(
                    "proofFreshnessLineageData", "ActionReceiptProofFreshnessLineage",
                    record.proofFreshnessLineageData
                ),
                runtimeLineage: try record.runtimeLineageData.map {
                    try column("runtimeLineageData", "RuntimeTrustLineage", $0)
                }
            )),
            relationshipClaims: try receiptLineageClaims(
                proofData: record.proofFreshnessLineageData,
                runtimeData: record.runtimeLineageData
            )
        )
    }

    private nonisolated static func exportRecord(
        _ record: RuntimeSnapshotLedgerRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try stringClaims(
            "sourceRecordIDsData", .source,
            targetType: "SourceRecord", bytes: record.sourceRecordIDsData
        )
        claims += try stringClaims(
            "receiptIDsData", .receipt, targetModel: .actionReceipt,
            targetType: RuntimeLegacySwiftDataSourceModelType.actionReceipt.rawValue,
            bytes: record.receiptIDsData
        )
        claims += try stringClaims(
            "replayTraceIDsData", .replayTrace,
            targetType: "RuntimeReplayTrace", bytes: record.replayTraceIDsData
        )
        claims += try stringClaims(
            "recommendationInputReferenceIDsData", .reference,
            targetType: "RecommendationInput",
            bytes: record.recommendationInputReferenceIDsData
        )
        claims += try stringClaims(
            "proofInputReferenceIDsData", .reference,
            targetType: "ProofInput", bytes: record.proofInputReferenceIDsData
        )
        claims += try stringClaims(
            "afep02LineageReferenceIDsData", .source,
            targetType: "AFEP02Lineage",
            bytes: record.afep02LineageReferenceIDsData
        )
        return RuntimeSwiftDataExportRecord(
            payload: .runtimeSnapshot(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                generatedAt: record.generatedAt,
                sourceRecordIDs: try column(
                    "sourceRecordIDsData", "[String]", record.sourceRecordIDsData
                ),
                receiptIDs: try column(
                    "receiptIDsData", "[String]", record.receiptIDsData
                ),
                replayTraceIDs: try column(
                    "replayTraceIDsData", "[String]", record.replayTraceIDsData
                ),
                recommendationInputReferenceIDs: try column(
                    "recommendationInputReferenceIDsData", "[String]",
                    record.recommendationInputReferenceIDsData
                ),
                proofInputReferenceIDs: try column(
                    "proofInputReferenceIDsData", "[String]",
                    record.proofInputReferenceIDsData
                ),
                afep02LineageReferenceIDs: try column(
                    "afep02LineageReferenceIDsData", "[String]",
                    record.afep02LineageReferenceIDsData
                ),
                fieldRedactions: try column(
                    "fieldRedactionsData", "[RuntimeSnapshotLedgerFieldRedaction]",
                    record.fieldRedactionsData
                ),
                compatibilityStatusRaw: record.compatibilityStatusRaw,
                checksum: record.checksum,
                provenanceHash: record.provenanceHash,
                snapshot: try column(
                    "snapshotData", "RuntimeSnapshotLedgerEnvelope",
                    record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: LifeContextBundleRecord
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .lifeContext(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt,
                deletedAt: record.deletedAt,
                snapshot: try column(
                    "snapshotData", "LifeContextBundle", record.snapshotData
                )
            )),
            relationshipClaims: []
        )
    }

    private nonisolated static func graphClaims(
        sourceSnapshotID: String?,
        ambitionID: String,
        sourceObjectIDsData: Data,
        receiptIDsData: Data,
        replayTraceIDsData: Data
    ) throws -> [RuntimeLegacySwiftDataRelationshipClaim] {
        var claims = try optionalClaim(
            "sourceSnapshotID", .source, targetModel: .runtimeSnapshot,
            targetType: RuntimeLegacySwiftDataSourceModelType.runtimeSnapshot.rawValue,
            id: sourceSnapshotID
        )
        claims.append(try claim(
            "ambitionID", .reference, targetModel: .goal,
            targetType: RuntimeLegacySwiftDataSourceModelType.goal.rawValue,
            id: ambitionID, required: true
        ))
        claims += try stringClaims(
            "sourceObjectIDsData", .source,
            targetType: "CanonicalObject", bytes: sourceObjectIDsData
        )
        claims += try stringClaims(
            "receiptIDsData", .receipt, targetModel: .actionReceipt,
            targetType: RuntimeLegacySwiftDataSourceModelType.actionReceipt.rawValue,
            bytes: receiptIDsData
        )
        claims += try stringClaims(
            "replayTraceIDsData", .replayTrace,
            targetType: "RuntimeReplayTrace", bytes: replayTraceIDsData
        )
        return claims
    }

    private nonisolated static func exportRecord(
        _ record: AmbitionGraphOperationalRecordModel
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .graphOperational(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                surfaceRaw: record.surfaceRaw,
                sourceSnapshotID: record.sourceSnapshotID,
                ambitionID: record.ambitionID,
                generatedAt: record.generatedAt,
                localProjectionOnly: record.localProjectionOnly,
                privacyClassRaw: record.privacyClassRaw,
                sourceObjectIDs: try column(
                    "sourceObjectIDsData", "[String]", record.sourceObjectIDsData
                ),
                receiptIDs: try column(
                    "receiptIDsData", "[String]", record.receiptIDsData
                ),
                replayTraceIDs: try column(
                    "replayTraceIDsData", "[String]", record.replayTraceIDsData
                ),
                sourceFields: try column(
                    "sourceFieldsData", "[String]", record.sourceFieldsData
                ),
                projectionHash: record.projectionHash,
                checksum: record.checksum,
                snapshot: try column(
                    "snapshotData", "AmbitionGraphOperationalRecord",
                    record.snapshotData
                )
            )),
            relationshipClaims: try graphClaims(
                sourceSnapshotID: record.sourceSnapshotID,
                ambitionID: record.ambitionID,
                sourceObjectIDsData: record.sourceObjectIDsData,
                receiptIDsData: record.receiptIDsData,
                replayTraceIDsData: record.replayTraceIDsData
            )
        )
    }

    private nonisolated static func exportRecord(
        _ record: AmbitionGraphProofRecordModel
    ) throws -> RuntimeSwiftDataExportRecord {
        var claims = try graphClaims(
            sourceSnapshotID: record.sourceSnapshotID,
            ambitionID: record.ambitionID,
            sourceObjectIDsData: record.sourceObjectIDsData,
            receiptIDsData: record.receiptIDsData,
            replayTraceIDsData: record.replayTraceIDsData
        )
        claims += try optionalClaim(
            "supersedesProofID", .supersedes, targetModel: .graphProof,
            targetType: RuntimeLegacySwiftDataSourceModelType.graphProof.rawValue,
            id: record.supersedesProofID
        )
        return RuntimeSwiftDataExportRecord(
            payload: .graphProof(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                proofID: record.proofID,
                version: record.version,
                supersedesProofID: record.supersedesProofID,
                sourceSnapshotID: record.sourceSnapshotID,
                ambitionID: record.ambitionID,
                generatedAt: record.generatedAt,
                localProjectionOnly: record.localProjectionOnly,
                privacyClassRaw: record.privacyClassRaw,
                sourceObjectIDs: try column(
                    "sourceObjectIDsData", "[String]", record.sourceObjectIDsData
                ),
                receiptIDs: try column(
                    "receiptIDsData", "[String]", record.receiptIDsData
                ),
                replayTraceIDs: try column(
                    "replayTraceIDsData", "[String]", record.replayTraceIDsData
                ),
                sourceFields: try column(
                    "sourceFieldsData", "[String]", record.sourceFieldsData
                ),
                checksum: record.checksum,
                snapshot: try column(
                    "snapshotData", "AmbitionGraphProofRecord", record.snapshotData
                )
            )),
            relationshipClaims: claims
        )
    }

    private nonisolated static func exportRecord(
        _ record: AmbitionGraphProjectionRecordModel
    ) throws -> RuntimeSwiftDataExportRecord {
        RuntimeSwiftDataExportRecord(
            payload: .graphProjection(.init(
                id: record.id,
                schemaVersion: record.schemaVersion,
                surfaceRaw: record.surfaceRaw,
                sourceSnapshotID: record.sourceSnapshotID,
                ambitionID: record.ambitionID,
                generatedAt: record.generatedAt,
                localProjectionOnly: record.localProjectionOnly,
                privacyClassRaw: record.privacyClassRaw,
                sourceObjectIDs: try column(
                    "sourceObjectIDsData", "[String]", record.sourceObjectIDsData
                ),
                receiptIDs: try column(
                    "receiptIDsData", "[String]", record.receiptIDsData
                ),
                replayTraceIDs: try column(
                    "replayTraceIDsData", "[String]", record.replayTraceIDsData
                ),
                sourceFields: try column(
                    "sourceFieldsData", "[String]", record.sourceFieldsData
                ),
                projectionHash: record.projectionHash,
                checksum: record.checksum,
                invalidationReasonRaw: record.invalidationReasonRaw,
                snapshot: try column(
                    "snapshotData", "AmbitionGraphProjectionRecord",
                    record.snapshotData
                )
            )),
            relationshipClaims: try graphClaims(
                sourceSnapshotID: record.sourceSnapshotID,
                ambitionID: record.ambitionID,
                sourceObjectIDsData: record.sourceObjectIDsData,
                receiptIDsData: record.receiptIDsData,
                replayTraceIDsData: record.replayTraceIDsData
            )
        )
    }

    /// Pure typed mapping boundary shared by the shipping exporter and focused
    /// source-level verification. Every persisted SwiftData family is an
    /// explicit overload; adding a model cannot silently fall through a generic
    /// or reflection-based mapper.
    enum TypedEnvelopeMapper {
        static func map(_ value: GoalRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: GoalDraftRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: GoalPlanRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: PlanSectionRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: StepRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: ProgressEvidenceRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: FeedbackEventRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: CaptureRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: ReminderRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: TeachingSignalRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: EventLedgerRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: CommandExecutionRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: SideEffectLedgerStorageRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: EntityRevisionTombstoneRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: AppStateRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: ActionReceiptHistoryRecordModel) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: RuntimeSnapshotLedgerRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: LifeContextBundleRecord) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: AmbitionGraphOperationalRecordModel) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: AmbitionGraphProofRecordModel) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
        static func map(_ value: AmbitionGraphProjectionRecordModel) throws -> RuntimeSwiftDataExportRecord {
            try RuntimeSwiftDataTypedExporter.exportRecord(value)
        }
    }
}

enum RuntimeLegacyImportFaultPhase: String, Sendable, CaseIterable {
    case startupBeforeOrphanPlanReconciliation
    case startupAfterOrphanPlanReconciliation
    case startupBeforeDirectoryReconciliation
    case startupAfterDirectoryReconciliation
    case startupBeforeSourceAuthentication
    case startupAfterSourceAuthentication
    case preservationBeforeSourceCapture
    case preservationAfterSourceCapture
    case preservationBeforeAuthorityCommit
    case preservationAfterAuthorityCommit
}

/// Immutable injection boundary. Production uses the fault-free implementation;
/// focused verification can inject only thrown errors (including CancellationError)
/// at named durable boundaries without global state, timing, or debug branches.
protocol RuntimeLegacyImportFaultChecking: Sendable {
    func check(_ phase: RuntimeLegacyImportFaultPhase) throws
}

struct RuntimeLegacyImportFaultFreeExecution: RuntimeLegacyImportFaultChecking {
    func check(_ phase: RuntimeLegacyImportFaultPhase) throws {}
}

actor RuntimeGenerationLegacyImportService {
    static let pageSize = 128
    static let maximumRecords = 100_000
    static let maximumTableCount = 256
    static let maximumColumnCount = 256
    static let maximumDecodedBytes = 32 * 1_024 * 1_024
    static let maximumSourceBytes: Int64 = 512 * 1_024 * 1_024
    static let maximumImportDecodedBytes: Int64 = 256 * 1_024 * 1_024

    /// Narrow pure access points for semantic authentication. These forward to
    /// private implementation details without exposing actor state or widening
    /// the service's stateful mutation surface.
    nonisolated static func authenticateSwiftDataRecord(
        _ record: RuntimeSwiftDataImportRecord
    ) throws {
        try validateSwiftDataRecord(record)
    }

    nonisolated static func mapVersionedCanonicalSQLiteRecord(
        _ record: RuntimeLegacyDecodedRecord,
        schemaVersion: RuntimeLegacyCanonicalSchemaVersion
    ) throws -> RuntimeLegacyMappedRecord? {
        try mapCanonicalSQLiteRecord(record, schemaVersion: schemaVersion)
    }

    nonisolated static func swiftDataSemanticSourceIdentity(
        schemaVersion: String,
        recordCount: Int,
        recordSetDigest: String
    ) -> String {
        LocalRuntimeStorageChecksum.sha256Hex(
            for: [
                "ambitions.swiftdata.semantic-source.v4",
                schemaVersion,
                String(recordCount),
                recordSetDigest
            ].joined(separator: "\n")
        )
    }

    private let controlStore: RuntimeGenerationControlStore
    private let generationManager: RuntimeStoreGenerationManager
    private let faultHook: any RuntimeLegacyImportFaultChecking
    private var environment: RuntimeEnvironment
    private enum StartupState { case pending, reconciling, complete }
    private var startupState: StartupState = .pending

    init(
        controlStore: RuntimeGenerationControlStore,
        generationManager: RuntimeStoreGenerationManager,
        environment: RuntimeEnvironment,
        faultHook: any RuntimeLegacyImportFaultChecking = RuntimeLegacyImportFaultFreeExecution()
    ) {
        self.controlStore = controlStore
        self.generationManager = generationManager
        self.environment = environment
        self.faultHook = faultHook
    }

    func stageCanonicalSQLiteV1(
        sourceURL: URL
    ) async throws -> RuntimeLegacyImportStagingResult {
        try await ensureStartupReconciled()
        let expectedVersion = RuntimeLegacyCanonicalSchemaVersion.v1
        var staged = try await stageSQLiteSourceFile(
            sourceURL: sourceURL,
            sourceKind: .canonicalV1,
            sourceSchema: "canonical.sqlite.v\(expectedVersion.rawValue)"
        )
        let recorded = try await recordImportSource(staged)
        let source = recorded.source
        staged = recorded.staged
        if let manifest = try await controlStore.importManifestIfPresent(
            importID: source.importID
        ) {
            return RuntimeLegacyImportStagingResult(
                source: source, manifest: manifest, quarantine: nil
            )
        }
        let database = try SQLiteDatabase(
            url: staged.url,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(
                openMode: .readOnlyExisting
            )
        )
        let accumulator = ImportAccumulator(
            importID: source.importID,
            durableProcessedFloor: try await controlStore.latestImportCheckpoint(
                importID: source.importID
            )?.processedItemCount ?? 0
        )
        do {
            let pageCount = try await database.query(
                "PRAGMA page_count", maximumDecodedBytes: 4 * 1_024
            )
            let pageSize = try await database.query(
                "PRAGMA page_size", maximumDecodedBytes: 4 * 1_024
            )
            guard pageCount.count == 1, pageSize.count == 1,
                  let pages = pageCount[0].values.first.flatMap(Self.integerValue),
                  let bytesPerPage = pageSize[0].values.first.flatMap(Self.integerValue),
                  pages >= 0, bytesPerPage > 0,
                  pages <= Self.maximumSourceBytes / bytesPerPage else {
                throw RuntimeGenerationControlError.readBudgetExceeded(
                    maximumBytes: Int(Self.maximumSourceBytes)
                )
            }
            let versionRows = try await database.query(
                "PRAGMA user_version", maximumDecodedBytes: 4 * 1_024
            )
            guard versionRows.count == 1,
                  versionRows[0].values.first == .integer(Int64(expectedVersion.rawValue)) else {
                throw RuntimeGenerationControlError.unsupportedSourceSchema(
                    actual: versionRows.first?.values.first.flatMap(Self.integerValue) ?? -1
                )
            }
            let integrity = try await database.integrityCheck()
            let foreignKeyViolations = try await database.foreignKeyCheck()
            guard integrity.isOK, foreignKeyViolations.isEmpty else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.requireExactLegacyV1Schema(in: database)
            }
            try await decodeTablesByKeyset(database: database) { record in
                let mapped: RuntimeLegacyMappedRecord?
                let rejected: RuntimeLegacyRejectedRecord?
                do {
                    mapped = try RuntimeLegacyCanonicalSQLiteMapper.map(
                        record, sourceSchemaVersion: expectedVersion
                    )
                    rejected = nil
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    guard Self.canonicalTableSpecs(for: expectedVersion)[record.table] != nil else {
                        throw error
                    }
                    mapped = nil
                    rejected = RuntimeLegacyRejectedRecord(
                        sourceRecordID: try Self.sourceRecordID(for: record),
                        sourceRecordDigest: try Self.decodedRecordPayloadDigest(record),
                        disposition: .malformed,
                        warningCodes: ["typed_payload_validation_failed"],
                        lossiness: .lossyRequiresReview
                    )
                }
                try await appendDecodedRecord(
                    record,
                    mapped: mapped,
                    rejected: rejected,
                    staged: staged,
                    source: source,
                    schemaVersion: expectedVersion,
                    accumulator: accumulator
                )
            }
        } catch {
            let operationError = error
            do { try await database.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_legacy_import_source"
                )
            }
            throw operationError
        }
        do { try await database.close() }
        catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_legacy_import_source"
            )
        }
        return try await finalizeImport(
            staged: staged,
            source: source,
            accumulator: accumulator
        )
    }

    func stageSwiftDataRepositoryExport(
        sourceURL: URL
    ) async throws -> RuntimeLegacyImportStagingResult {
        try await ensureStartupReconciled()
        let staged = try await stageSourceFile(
            sourceURL: sourceURL,
            sourceKind: .swiftData,
            sourceSchema: objectStoreSwiftDataSchemaVersion
        )
        return try await ingestPreparedSwiftDataSource(staged)
    }

    func stageCurrentSwiftDataStore(
        exporter: RuntimeSwiftDataTypedExporter
    ) async throws -> RuntimeLegacyImportStagingResult {
        try await ensureStartupReconciled()
        let locations = await generationManager.locations
        let importsPin = try ensurePinnedProtectedDirectory(
            locations.importsURL,
            parent: locations.rootURL,
            artifact: "generation_imports_root"
        )
        let importID = nextID()
        try RuntimeStorePathValidation.requireSafeComponent(importID)
        let lock = try acquireImportReconciliationLock(locations: locations)
        do {
            let directory = locations.importsURL.appendingPathComponent(
                importID,
                isDirectory: true
            )
            let stagingPin = try ensurePinnedProtectedDirectory(
                directory,
                parent: locations.importsURL,
                artifact: "generation_swiftdata_import_staging"
            )
            try importsPin.revalidate()
            let url = directory.appendingPathComponent("Raw-source")
            let transportSessionDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: [
                    "ambitions.swiftdata.transport-session.v4",
                    objectStoreSwiftDataSchemaVersion,
                    importID
                ].joined(separator: "\n")
            )
            try faultHook.check(.preservationBeforeSourceCapture)
            let export = try await exporter.export(
                to: url,
                parentDescriptor: stagingPin.descriptor,
                relativePath: "\(importID)/Raw-source",
                transportSessionDigest: transportSessionDigest
            )
            try faultHook.check(.preservationAfterSourceCapture)
            let semanticSourceIdentity = Self.swiftDataSemanticSourceIdentity(
                schemaVersion: objectStoreSwiftDataSchemaVersion,
                recordCount: export.recordCount,
                recordSetDigest: export.recordSetDigest
            )
            let staged = StagedSource(
                id: importID,
                url: url,
                artifact: export.artifact,
                sourceKind: .swiftData,
                sourceSchema: objectStoreSwiftDataSchemaVersion,
                sourceIdentityDigest: semanticSourceIdentity,
                sourceLocationFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                    for: [
                        "ambitions.swiftdata.store-export-location.v4",
                        transportSessionDigest
                    ].joined(separator: "\n")
                ),
                reconciliationLock: lock
            )
            return try await ingestPreparedSwiftDataSource(staged)
        } catch {
            let operationError = error
            do { try lock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    private func ingestPreparedSwiftDataSource(
        _ prepared: StagedSource
    ) async throws -> RuntimeLegacyImportStagingResult {
        var staged = prepared
        let preflight = try await streamSwiftDataExport(staged) { _ in }
        let semanticSourceIdentity = Self.swiftDataSemanticSourceIdentity(
            schemaVersion: staged.sourceSchema,
            recordCount: preflight.recordCount,
            recordSetDigest: preflight.recordSetDigest
        )
        staged = StagedSource(
            id: staged.id,
            url: staged.url,
            artifact: staged.artifact,
            sourceKind: staged.sourceKind,
            sourceSchema: staged.sourceSchema,
            sourceIdentityDigest: semanticSourceIdentity,
            sourceLocationFingerprint: staged.sourceLocationFingerprint,
            reconciliationLock: staged.reconciliationLock
        )
        let recorded = try await recordImportSource(staged)
        let source = recorded.source
        staged = recorded.staged
        if let manifest = try await controlStore.importManifestIfPresent(
            importID: source.importID
        ) {
            return RuntimeLegacyImportStagingResult(
                source: source, manifest: manifest, quarantine: nil
            )
        }
        let accumulator = ImportAccumulator(
            importID: source.importID,
            durableProcessedFloor: try await controlStore.latestImportCheckpoint(
                importID: source.importID
            )?.processedItemCount ?? 0
        )
        var priorOrderingKey: RuntimeLegacySwiftDataCompositeOrderingKey?
        try await streamSwiftDataExport(staged) { record in
            if let priorOrderingKey {
                guard priorOrderingKey < record.sourceIdentity.orderingKey else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
            }
            let sourceRecordID = try record.canonicalSourceRecordID()
            guard sourceRecordID.utf8.count <= 1_024 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            priorOrderingKey = record.sourceIdentity.orderingKey
            try Self.validateSwiftDataRecord(record)
            let sourceRecordDigest = try record.semanticRecordDigest()
            let mapped = RuntimeLegacyMappedRecord(
                sourceRecordID: sourceRecordID,
                sourceRecordDigest: sourceRecordDigest,
                canonicalFamily: record.modelType.rawValue,
                canonicalID: record.stableRecordID,
                payloadVersion: record.payloadVersion,
                payload: .swiftData(record.envelope),
                lossiness: .none,
                warningCodes: [
                    "typed_swiftdata_v3",
                    "review_only_\(record.envelope.sourceDisposition.rawValue)"
                ]
            )
            try await appendMappedRecord(
                mapped,
                staged: staged,
                source: source,
                accumulator: accumulator
            )
        }
        return try await finalizeImport(
            staged: staged,
            source: source,
            accumulator: accumulator
        )
    }

    func reviewItemsPage(
        staging: RuntimeLegacyImportStagingResult,
        afterSourceRecordID: String? = nil
    ) async throws -> [RuntimeLegacyImportItem] {
        try await ensureStartupReconciled()
        try await controlStore.importItemsPage(
            importID: staging.source.importID,
            afterSourceRecordID: afterSourceRecordID,
            limit: Self.pageSize
        )
    }

    func loadAuthenticatedMappedArtifact(
        for item: RuntimeLegacyImportItem
    ) async throws -> RuntimeLegacyMappedImportArtifact {
        try await ensureStartupReconciled()
        return try await loadAuthenticatedMappedArtifactAfterStartup(for: item)
    }

    private func loadAuthenticatedMappedArtifactAfterStartup(
        for item: RuntimeLegacyImportItem
    ) async throws -> RuntimeLegacyMappedImportArtifact {
        guard item.disposition == .reviewableDiscovery,
              let reference = item.mappedArtifact else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        try RuntimeGenerationControlRecordFactory.validate(reference)
        let locations = await generationManager.locations
        let components = reference.artifact.relativePath.split(separator: "/").map(String.init)
        guard components.count == 3,
              components[0] == item.importID,
              components[1] == "Mapped",
              components[2].hasSuffix(".json") else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let parentURL = locations.importsURL
            .appendingPathComponent(components[0], isDirectory: true)
            .appendingPathComponent(components[1], isDirectory: true)
        let parentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parentURL,
            createFinalComponentIfMissing: false
        )
        try parentPin.revalidate()
        let captured = try RuntimeLegacyImportPinnedArtifactIO.inspect(
            parentDescriptor: parentPin.descriptor,
            name: components[2],
            relativePath: reference.artifact.relativePath,
            maximumBytes: Int64(RuntimeGenerationControlCodec.maximumRecordBytes),
            retainBytes: true
        )
        try parentPin.revalidate()
        guard let bytes = captured.bytes,
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == reference.artifact.sha256 else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let artifact = try RuntimeGenerationControlCodec.decode(
            RuntimeLegacyMappedImportArtifact.self, from: bytes
        )
        try RuntimeLegacyMappedArtifactAuthenticator.authenticate(
            item: item,
            observedArtifact: captured.artifact.semanticArtifact(),
            decodedArtifact: artifact
        )
        return artifact
    }

    func recordReviewPage(
        staging: RuntimeLegacyImportStagingResult,
        reviewID: String,
        pageIndex: Int,
        afterSourceRecordID: String?,
        decisions: [RuntimeLegacyImportReviewDecisionEntry]
    ) async throws -> RuntimeLegacyImportReviewPage {
        try await ensureStartupReconciled()
        let items = try await reviewItemsPage(
            staging: staging, afterSourceRecordID: afterSourceRecordID
        )
        guard items.isEmpty == false,
              items.count == decisions.count,
              let lastSourceRecordID = items.last?.sourceRecordID else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let page = try RuntimeGenerationControlRecordFactory.importReviewPage(
            id: nextID(),
            reviewID: reviewID,
            importID: staging.source.importID,
            pageIndex: pageIndex,
            afterSourceRecordID: afterSourceRecordID,
            lastSourceRecordID: lastSourceRecordID,
            entries: decisions
        )
        try await controlStore.recordImportReviewPage(page)
        return page
    }

    func finalizeReview(
        staging: RuntimeLegacyImportStagingResult,
        reviewID: String,
        authorization: RuntimeLegacyImportReviewAuthorization
    ) async throws -> RuntimeLegacyImportReview {
        try await ensureStartupReconciled()
        let review = try await controlStore.finalizeImportReview(
            reviewID: reviewID,
            importID: staging.source.importID,
            authorization: authorization,
            reviewedAtMilliseconds: try nowMilliseconds()
        )
        try await appendCheckpoint(
            source: staging.source, phase: .reviewConsumed,
            artifactSetDigest: staging.manifest.orderedItemSetDigest,
            lastSourceRecordID: nil, processedItemCount: review.itemCount,
            evidence: .reviewConsumed(
                reviewDigest: review.reviewDigest,
                authorizationDigest: authorization.authorizationDigest
            )
        )
        let intent = try await controlStore.importDispositionIntent(
            digest: authorization.dispositionIntentDigest
        )
        if intent.disposition == .noActivationAllRejected ||
            intent.disposition == .noActivationReviewOnly {
            try await appendCheckpoint(
                source: staging.source, phase: .completedNoActivation,
                artifactSetDigest: staging.manifest.orderedItemSetDigest,
                lastSourceRecordID: nil, processedItemCount: review.itemCount,
                evidence: .completedNoActivation(
                    dispositionIntentDigest: intent.intentDigest,
                    reviewDigest: review.reviewDigest,
                    authorizationDigest: authorization.authorizationDigest
                )
            )
        }
        return review
    }

    func planNoActivationDispositionIntent(
        staging: RuntimeLegacyImportStagingResult,
        orderedDecisionSetDigest: String,
        retainedForFutureMigrationItemCount: Int,
        retainedLossyForFutureMigrationItemCount: Int,
        rejectedItemCount: Int,
        lossinessConsequenceDigest: String,
        discoveryTransformationVersion: Int,
        reviewContractDigest: String,
        disposition: RuntimeLegacyImportCandidateDisposition
    ) async throws -> RuntimeLegacyImportDispositionIntent {
        try await ensureStartupReconciled()
        // No SwiftData or legacy family currently has a dependency-complete
        // v8 causal-closure materializer. Planning activation from reviewed
        // discovery artifacts would overstate authority, so this foundation
        // permits only terminal no-activation review dispositions.
        let retained = retainedForFutureMigrationItemCount.addingReportingOverflow(
            retainedLossyForFutureMigrationItemCount
        )
        let total = retained.partialValue.addingReportingOverflow(rejectedItemCount)
        let dispositionCountsAreValid =
            (disposition == .noActivationAllRejected && retained.partialValue == 0) ||
            (disposition == .noActivationReviewOnly && retained.partialValue > 0)
        guard retained.overflow == false,
              total.overflow == false,
              total.partialValue == staging.manifest.itemCount,
              dispositionCountsAreValid else {
            throw RuntimeGenerationControlError.unsupportedSourceSchema(
                actual: discoveryTransformationVersion
            )
        }
        let intent = try RuntimeGenerationControlRecordFactory.importDispositionIntent(
            id: nextID(), importID: staging.source.importID,
            sourceDigest: staging.source.sourceDigest,
            manifestDigest: staging.manifest.manifestDigest,
            orderedItemSetDigest: staging.manifest.orderedItemSetDigest,
            orderedDecisionSetDigest: orderedDecisionSetDigest,
            itemCount: staging.manifest.itemCount,
            retainedForFutureMigrationItemCount: retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: rejectedItemCount,
            lossinessConsequenceDigest: lossinessConsequenceDigest,
            discoveryTransformationVersion: discoveryTransformationVersion,
            reviewContractDigest: reviewContractDigest,
            disposition: disposition, plannedAtMilliseconds: try nowMilliseconds()
        )
        try await controlStore.recordImportDispositionIntent(intent)
        try await appendCheckpoint(
            source: staging.source, phase: .reviewPlanned,
            artifactSetDigest: staging.manifest.orderedItemSetDigest,
            lastSourceRecordID: nil, processedItemCount: staging.manifest.itemCount,
            evidence: .reviewPlanned(dispositionIntentDigest: intent.intentDigest)
        )
        return intent
    }

    func issueReviewAuthorization(
        staging: RuntimeLegacyImportStagingResult,
        dispositionIntent: RuntimeLegacyImportDispositionIntent,
        lifetimeMilliseconds: Int64 = 5 * 60 * 1_000
    ) async throws -> RuntimeLegacyImportReviewAuthorization {
        try await ensureStartupReconciled()
        let now = try nowMilliseconds()
        guard lifetimeMilliseconds > 0, now <= Int64.max - lifetimeMilliseconds else {
            throw RuntimeGenerationControlError.importLossNotAccepted
        }
        let authorization = try RuntimeGenerationControlRecordFactory
            .importReviewAuthorization(
                id: nextID(), importID: staging.source.importID,
                sourceDigest: staging.source.sourceDigest,
                manifestDigest: staging.manifest.manifestDigest,
                itemCount: dispositionIntent.itemCount,
                retainedForFutureMigrationItemCount:
                    dispositionIntent.retainedForFutureMigrationItemCount,
                retainedLossyForFutureMigrationItemCount:
                    dispositionIntent.retainedLossyForFutureMigrationItemCount,
                rejectedItemCount: dispositionIntent.rejectedItemCount,
                orderedItemSetDigest: staging.manifest.orderedItemSetDigest,
                orderedDecisionSetDigest: dispositionIntent.orderedDecisionSetDigest,
                lossinessConsequenceDigest: dispositionIntent.lossinessConsequenceDigest,
                dispositionIntentDigest: dispositionIntent.intentDigest,
                nonce: nextID(), authorizedAtMilliseconds: now,
                expiresAtMilliseconds: now.addingReportingOverflow(
                    lifetimeMilliseconds
                ).partialValue
            )
        try await controlStore.recordImportReviewAuthorization(authorization)
        try await appendCheckpoint(
            source: staging.source, phase: .reviewAuthorized,
            artifactSetDigest: staging.manifest.orderedItemSetDigest,
            lastSourceRecordID: nil, processedItemCount: staging.manifest.itemCount,
            evidence: .reviewAuthorized(
                authorizationDigest: authorization.authorizationDigest
            )
        )
        return authorization
    }

}

private extension RuntimeGenerationLegacyImportService {
    func ensureStartupReconciled() async throws {
        switch startupState {
        case .complete: return
        case .reconciling:
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        case .pending:
            startupState = .reconciling
        }
        do {
            try await reconcileStartupImports()
            startupState = .complete
        } catch {
            startupState = .pending
            throw error
        }
    }

    func reconcileStartupImports() async throws {
        let locations = await generationManager.locations
        let lock = try acquireImportReconciliationLock(locations: locations)
        do {
            try await reconcileStartupImportsLocked(locations: locations)
            try lock.close()
        } catch {
            let operationError = error
            do { try lock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    func reconcileStartupImportsLocked(
        locations: RuntimeStoreLocations
    ) async throws {
        try faultHook.check(.startupBeforeOrphanPlanReconciliation)
        var planCursor: String?
        repeat {
            let plans = try await controlStore.importOrphanQuarantinePlansPage(
                afterQuarantineID: planCursor,
                limit: Self.pageSize
            )
            for plan in plans {
                try Task.checkCancellation()
                try await reconcileOrphanQuarantinePlan(plan, locations: locations)
            }
            planCursor = plans.last?.quarantineID
            if plans.count < Self.pageSize { break }
        } while true
        try faultHook.check(.startupAfterOrphanPlanReconciliation)

        try faultHook.check(.startupBeforeDirectoryReconciliation)
        let rootPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.rootURL,
            createFinalComponentIfMissing: false
        )
        let importsName = locations.importsURL.lastPathComponent
        var importsStatus = stat()
        if fstatat(
            rootPin.descriptor,
            importsName,
            &importsStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0 {
            guard importsStatus.st_mode & S_IFMT == S_IFDIR else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            let importsDescriptor = Darwin.openat(
                rootPin.descriptor,
                importsName,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard importsDescriptor >= 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            var importsDescriptorOpen = true
            do {
                var openedImports = stat()
                guard fstat(importsDescriptor, &openedImports) == 0,
                      openedImports.st_dev == importsStatus.st_dev,
                      openedImports.st_ino == importsStatus.st_ino else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: "legacy_import_root"
                    )
                }
                let enumerationDescriptor = Darwin.dup(importsDescriptor)
                guard enumerationDescriptor >= 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "open_import_root_enumerator"
                    )
                }
                guard let entries = fdopendir(enumerationDescriptor) else {
                    guard Darwin.close(enumerationDescriptor) == 0 else {
                        throw RuntimeGenerationControlError.controlAuthorityUnavailable
                    }
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "open_import_root_enumerator"
                    )
                }
                var streamOpen = true
                do {
                    var entryCount = 0
                    while true {
                        try Task.checkCancellation()
                        errno = 0
                        guard let entry = readdir(entries) else {
                            guard errno == 0 else {
                                throw LocalRuntimeStorageError.canonicalIOFailure(
                                    operation: "read_import_root_entry"
                                )
                            }
                            break
                        }
                        let rawName = withUnsafePointer(to: entry.pointee.d_name) {
                            pointer -> Data in
                            pointer.withMemoryRebound(
                                to: CChar.self,
                                capacity: Int(MAXNAMLEN) + 1
                            ) {
                                Data(bytes: $0, count: strnlen($0, Int(MAXNAMLEN) + 1))
                            }
                        }
                        if rawName == Data(".".utf8) || rawName == Data("..".utf8) {
                            continue
                        }
                        guard let name = String(data: rawName, encoding: .utf8) else {
                            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                        }
                        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
                        entryCount += 1
                        guard entryCount <= Self.maximumRecords else {
                            throw RuntimeGenerationControlError.readBudgetExceeded(
                                maximumBytes: Self.maximumRecords
                            )
                        }
                        var entryStatus = stat()
                        guard fstatat(
                            importsDescriptor,
                            name,
                            &entryStatus,
                            AT_SYMLINK_NOFOLLOW
                        ) == 0,
                        entryStatus.st_mode & S_IFMT == S_IFDIR else {
                            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                        }
                        if name == locations.coordinatedLegacySourcesURL.lastPathComponent {
                            continue
                        }
                        guard try await controlStore.importSource(importID: name) != nil else {
                            try await quarantineOrphanImportDirectoryLocked(
                                locations.importsURL.appendingPathComponent(
                                    name,
                                    isDirectory: true
                                ),
                                locations: locations
                            )
                            continue
                        }
                    }
                    streamOpen = false
                    guard closedir(entries) == 0 else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "close_import_root_enumerator"
                        )
                    }
                } catch {
                    let operationError = error
                    if streamOpen {
                        streamOpen = false
                        guard closedir(entries) == 0 else {
                            throw RuntimeGenerationControlError.controlAuthorityUnavailable
                        }
                    }
                    throw operationError
                }
                var importsAfter = stat()
                var entryAfter = stat()
                guard fstat(importsDescriptor, &importsAfter) == 0,
                      fstatat(
                          rootPin.descriptor,
                          importsName,
                          &entryAfter,
                          AT_SYMLINK_NOFOLLOW
                      ) == 0,
                      importsAfter.st_dev == openedImports.st_dev,
                      importsAfter.st_ino == openedImports.st_ino,
                      entryAfter.st_dev == openedImports.st_dev,
                      entryAfter.st_ino == openedImports.st_ino else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: "legacy_import_root"
                    )
                }
                importsDescriptorOpen = false
                guard Darwin.close(importsDescriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_import_root"
                    )
                }
            } catch {
                let operationError = error
                if importsDescriptorOpen {
                    importsDescriptorOpen = false
                    guard Darwin.close(importsDescriptor) == 0 else {
                        throw RuntimeGenerationControlError.controlAuthorityUnavailable
                    }
                }
                throw operationError
            }
        } else if errno != ENOENT {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_import_root"
            )
        }
        try faultHook.check(.startupAfterDirectoryReconciliation)

        try faultHook.check(.startupBeforeSourceAuthentication)
        var sourceCursor: String?
        repeat {
            let sources = try await controlStore.importSourcesPage(
                afterImportID: sourceCursor,
                limit: Self.pageSize
            )
            for source in sources {
                try Task.checkCancellation()
                let sourceURL = locations.importsURL.appendingPathComponent(
                    source.sourceArtifact.relativePath
                )
                do {
                guard try inspectPinnedImportSourceArtifact(
                    source.sourceArtifact,
                    importID: source.importID,
                    locations: locations
                ) == source.sourceArtifact else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                if let checkpoint = try await controlStore.latestImportCheckpoint(
                    importID: source.importID
                ) {
                    guard checkpoint.sourceArtifactSHA256 == source.sourceArtifact.sha256 else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                } else {
                    let initial = try RuntimeGenerationControlRecordFactory
                        .importCheckpoint(
                            id: nextID(),
                            importID: source.importID,
                            sequence: 0,
                            phase: .sourcePreserved,
                            priorCheckpointDigest: nil,
                            sourceArtifactSHA256: source.sourceArtifact.sha256,
                            artifactSetDigest: source.sourceArtifact.sha256,
                            lastSourceRecordID: nil,
                            processedItemCount: 0,
                            occurredAtMilliseconds: try nowMilliseconds(),
                            evidence: .sourcePreserved(
                                sourceDigest: source.sourceDigest
                            )
                        )
                    try await controlStore.recordImportSourceAndInitialCheckpoint(
                        source: source,
                        checkpoint: initial
                    )
                }
                var cursor: String?
                repeat {
                    let page = try await controlStore.importItemsPage(
                        importID: source.importID,
                        afterSourceRecordID: cursor,
                        limit: Self.pageSize
                    )
                    for item in page where item.disposition == .reviewableDiscovery {
                        try Task.checkCancellation()
                        _ = try await loadAuthenticatedMappedArtifactAfterStartup(for: item)
                    }
                    cursor = page.last?.sourceRecordID
                    if page.count < Self.pageSize { break }
                } while true
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    guard Self.isTerminalImportSourceFailure(error) else { throw error }
                    let latest = try await controlStore.latestImportCheckpoint(
                        importID: source.importID
                    )
                    if latest?.phase != .abandoned && latest?.phase != .quarantined &&
                        latest?.phase != .completedNoActivation {
                        try await appendCheckpoint(
                            source: source, phase: .abandoned,
                            artifactSetDigest: source.sourceArtifact.sha256,
                            lastSourceRecordID: latest?.lastSourceRecordID,
                            processedItemCount: latest?.processedItemCount ?? 0,
                            evidence: .abandoned(
                                reasonCode: "source_artifact_invalid",
                                recoveryActions: [.exportOriginal, .inspectReadOnly]
                            )
                        )
                    }
                }
            }
            sourceCursor = sources.last?.importID
            if sources.count < Self.pageSize { break }
        } while true
        try faultHook.check(.startupAfterSourceAuthentication)
    }

    static func isTerminalImportSourceFailure(_ error: Error) -> Bool {
        if let error = error as? RuntimeGenerationControlError {
            switch error {
            case .malformed, .unsupportedVersion, .futureVersion, .recordCorrupt,
                 .verificationRejected, .sourceQuarantined, .importReviewRequired,
                 .unsupportedSourceSchema:
                return true
            default:
                return false
            }
        }
        if let error = error as? LocalRuntimeStorageError {
            switch error {
            case .canonicalManifestMalformed, .canonicalManifestMismatch,
                 .canonicalIntegrityFailure, .canonicalForeignKeyFailure,
                 .canonicalFileProtectionFailure, .canonicalPathAuthorityDenied,
                 .canonicalFileIdentityChanged:
                return true
            default:
                return false
            }
        }
        return false
    }

    func quarantineOrphanImportDirectory(
        _ url: URL,
        locations: RuntimeStoreLocations
    ) async throws {
        let lock = try acquireImportReconciliationLock(locations: locations)
        do {
            try await quarantineOrphanImportDirectoryLocked(url, locations: locations)
            try lock.close()
        } catch {
            let operationError = error
            do { try lock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    func quarantineOrphanImportDirectoryLocked(
        _ url: URL,
        locations: RuntimeStoreLocations
    ) async throws {
        try RuntimeStorePathValidation.requireContained(url, in: locations.importsURL)
        _ = try ensurePinnedProtectedDirectory(
            locations.quarantineURL, parent: locations.rootURL,
            artifact: "generation_quarantine_root"
        )
        let importsPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.importsURL,
            createFinalComponentIfMissing: false
        )
        let sourceName = url.lastPathComponent
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(sourceName)
        var sourceStatus = stat()
        guard fstatat(
            importsPin.descriptor,
            sourceName,
            &sourceStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0,
              sourceStatus.st_mode & S_IFMT == S_IFDIR,
              sourceStatus.st_nlink >= 1 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let quarantineID = nextID()
        let destinationName = "orphan-import-\(quarantineID)"
        let plan = try RuntimeGenerationControlRecordFactory
            .importOrphanQuarantinePlan(
                id: quarantineID,
                originalEntryName: sourceName,
                originalEntryIdentity: RuntimeStoreFileIdentity(
                    device: UInt64(sourceStatus.st_dev),
                    inode: UInt64(sourceStatus.st_ino)
                ),
                destinationEntryName: destinationName,
                maximumInventoryFileCount: Self.maximumRecords,
                maximumInventoryByteCount: Self.maximumSourceBytes,
                plannedAtMilliseconds: try nowMilliseconds()
            )
        try await controlStore.recordImportOrphanQuarantinePlan(plan)
        try await reconcileOrphanQuarantinePlan(plan, locations: locations)
    }

    func reconcileOrphanQuarantinePlan(
        _ plan: RuntimeLegacyImportOrphanQuarantinePlan,
        locations: RuntimeStoreLocations
    ) async throws {
        try RuntimeGenerationControlRecordFactory.validate(plan)
        if let completed = try await controlStore.importOrphanQuarantine(
            id: plan.quarantineID
        ) {
            guard completed.originalEntryIdentity == plan.originalEntryIdentity,
                  completed.originalEntryName == plan.originalEntryName,
                  completed.preservedRelativePath == plan.destinationEntryName else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let destination = locations.quarantineURL.appendingPathComponent(
                completed.preservedRelativePath,
                isDirectory: true
            )
            let destinationPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                destination,
                createFinalComponentIfMissing: false
            )
            guard destinationPin.identity == completed.originalEntryIdentity else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "completed_orphan_import_quarantine_pin"
                )
            }
            let inventory = try inventoryQuarantinedImportDirectory(
                rootDescriptor: destinationPin.descriptor,
                expectedRootIdentity: completed.originalEntryIdentity,
                maximumFileCount: plan.maximumInventoryFileCount,
                maximumByteCount: plan.maximumInventoryByteCount
            )
            try destinationPin.revalidate()
            guard inventory.digest == completed.inventoryDigest,
                  inventory.fileCount == completed.fileCount,
                  inventory.totalByteCount == completed.totalByteCount else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            return
        }
        let importsPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.importsURL,
            createFinalComponentIfMissing: false
        )
        let quarantinePin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.quarantineURL,
            createFinalComponentIfMissing: false
        )
        try importsPin.revalidate(); try quarantinePin.revalidate()
        guard try await controlStore.importSource(
            importID: plan.originalEntryName
        ) == nil else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        var sourceStatus = stat()
        var destinationStatus = stat()
        let sourceExists = fstatat(
            importsPin.descriptor,
            plan.originalEntryName,
            &sourceStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0
        if sourceExists == false, errno != ENOENT {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_planned_orphan_import_source"
            )
        }
        let destinationExists = fstatat(
            quarantinePin.descriptor,
            plan.destinationEntryName,
            &destinationStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0
        if destinationExists == false, errno != ENOENT {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_planned_orphan_import_destination"
            )
        }
        let sourceMatches = sourceExists &&
            RuntimeStoreFileIdentity(
                device: UInt64(sourceStatus.st_dev),
                inode: UInt64(sourceStatus.st_ino)
            ) == plan.originalEntryIdentity &&
            sourceStatus.st_mode & S_IFMT == S_IFDIR
        let destinationMatches = destinationExists &&
            RuntimeStoreFileIdentity(
                device: UInt64(destinationStatus.st_dev),
                inode: UInt64(destinationStatus.st_ino)
            ) == plan.originalEntryIdentity &&
            destinationStatus.st_mode & S_IFMT == S_IFDIR
        if sourceMatches && destinationExists == false {
            let sourceDescriptor = Darwin.openat(
                importsPin.descriptor,
                plan.originalEntryName,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard sourceDescriptor >= 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            var immediateSourceStatus = stat()
            let sourceIdentityMatches = fstat(sourceDescriptor, &immediateSourceStatus) == 0 &&
                RuntimeStoreFileIdentity(
                    device: UInt64(immediateSourceStatus.st_dev),
                    inode: UInt64(immediateSourceStatus.st_ino)
                ) == plan.originalEntryIdentity
            let sourceClosed = Darwin.close(sourceDescriptor) == 0
            guard sourceIdentityMatches, sourceClosed else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "planned_orphan_import_source_pre_move"
                )
            }
            guard Darwin.renameatx_np(
                importsPin.descriptor,
                plan.originalEntryName,
                quarantinePin.descriptor,
                plan.destinationEntryName,
                UInt32(RENAME_EXCL)
            ) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "quarantine_planned_orphan_import"
                )
            }
            var immediateDestinationStatus = stat()
            guard fstatat(
                quarantinePin.descriptor,
                plan.destinationEntryName,
                &immediateDestinationStatus,
                AT_SYMLINK_NOFOLLOW
            ) == 0,
                  RuntimeStoreFileIdentity(
                    device: UInt64(immediateDestinationStatus.st_dev),
                    inode: UInt64(immediateDestinationStatus.st_ino)
                  ) == plan.originalEntryIdentity else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "planned_orphan_import_destination_post_move"
                )
            }
            guard Darwin.fsync(importsPin.descriptor) == 0,
                  Darwin.fsync(quarantinePin.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_planned_orphan_import_move"
                )
            }
        } else if destinationMatches && sourceExists == false {
            // Crash occurred after rename and before completion. Continue from
            // the exact planned destination inode.
        } else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "planned_orphan_import_move"
            )
        }
        try importsPin.revalidate(); try quarantinePin.revalidate()
        let destinationDescriptor = Darwin.openat(
            quarantinePin.descriptor,
            plan.destinationEntryName,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard destinationDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var destinationDescriptorOpen = true
        var destinationDescriptorStatus = stat()
        var finalDestinationStatus = stat()
        guard fstat(destinationDescriptor, &destinationDescriptorStatus) == 0,
              fstatat(
                  quarantinePin.descriptor,
                  plan.destinationEntryName,
                  &finalDestinationStatus,
                  AT_SYMLINK_NOFOLLOW
              ) == 0,
              destinationDescriptorStatus.st_dev == finalDestinationStatus.st_dev,
              destinationDescriptorStatus.st_ino == finalDestinationStatus.st_ino,
              RuntimeStoreFileIdentity(
                device: UInt64(destinationDescriptorStatus.st_dev),
                inode: UInt64(destinationDescriptorStatus.st_ino)
              ) == plan.originalEntryIdentity else {
            destinationDescriptorOpen = false
            guard Darwin.close(destinationDescriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "orphan_import_directory"
            )
        }
        let inventory: (digest: String, fileCount: Int, totalByteCount: Int64)
        do {
            inventory = try inventoryQuarantinedImportDirectory(
                rootDescriptor: destinationDescriptor,
                expectedRootIdentity: plan.originalEntryIdentity,
                maximumFileCount: plan.maximumInventoryFileCount,
                maximumByteCount: plan.maximumInventoryByteCount
            )
            try importsPin.revalidate(); try quarantinePin.revalidate()
            var postInventoryStatus = stat()
            guard fstat(destinationDescriptor, &postInventoryStatus) == 0,
                  postInventoryStatus.st_dev == destinationDescriptorStatus.st_dev,
                  postInventoryStatus.st_ino == destinationDescriptorStatus.st_ino else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "inventoried_orphan_import_directory"
                )
            }
            destinationDescriptorOpen = false
            guard Darwin.close(destinationDescriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_inventoried_orphan_import_directory"
                )
            }
        } catch {
            if destinationDescriptorOpen {
                destinationDescriptorOpen = false
                guard Darwin.close(destinationDescriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_failed_orphan_import_inventory"
                    )
                }
            }
            throw error
        }
        var destinationAfterInventory = stat()
        guard fstatat(
            quarantinePin.descriptor,
            plan.destinationEntryName,
            &destinationAfterInventory,
            AT_SYMLINK_NOFOLLOW
        ) == 0,
              RuntimeStoreFileIdentity(
                device: UInt64(destinationAfterInventory.st_dev),
                inode: UInt64(destinationAfterInventory.st_ino)
              ) == plan.originalEntryIdentity else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "orphan_import_directory"
            )
        }
        let record = try RuntimeGenerationControlRecordFactory.importOrphanQuarantine(
            id: plan.quarantineID,
            originalEntryName: plan.originalEntryName,
            originalEntryIdentity: plan.originalEntryIdentity,
            preservedRelativePath: plan.destinationEntryName,
            inventoryDigest: inventory.digest, fileCount: inventory.fileCount,
            totalByteCount: inventory.totalByteCount,
            quarantinedAtMilliseconds: try nowMilliseconds()
        )
        try await controlStore.recordImportOrphanQuarantine(record)
    }

    func inventoryQuarantinedImportDirectory(
        rootDescriptor: Int32,
        expectedRootIdentity: RuntimeStoreFileIdentity,
        maximumFileCount: Int,
        maximumByteCount: Int64
    ) throws -> (digest: String, fileCount: Int, totalByteCount: Int64) {
        guard maximumFileCount > 0,
              maximumFileCount <= Self.maximumRecords,
              maximumByteCount > 0,
              maximumByteCount <= Self.maximumSourceBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Int(min(maximumByteCount, Int64(Int.max)))
            )
        }
        var rootStatus = stat()
        guard fstat(rootDescriptor, &rootStatus) == 0,
              rootStatus.st_mode & S_IFMT == S_IFDIR,
              RuntimeStoreFileIdentity(
                  device: UInt64(rootStatus.st_dev),
                  inode: UInt64(rootStatus.st_ino)
              ) == expectedRootIdentity else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "orphan_import_inventory_root"
            )
        }
        // Order-independent, bounded-memory inventory. Unique relative paths
        // make each leaf unique; two domain-separated 256-bit accumulators per
        // bucket avoid retaining an attacker-sized tuple array.
        var bucketCounts = [UInt64](repeating: 0, count: 256)
        var bucketPrimary = [[UInt8]](
            repeating: [UInt8](repeating: 0, count: 32), count: 256
        )
        var bucketSecondary = [[UInt8]](
            repeating: [UInt8](repeating: 0, count: 32), count: 256
        )
        var fileCount = 0
        var totalByteCount: Int64 = 0
        var visitedEntryCount = 0
        let maximumEntryCount = maximumFileCount * 4 + 1_024
        try inventoryQuarantinedImportDirectoryDescriptor(
            rootDescriptor,
            relativeComponents: [],
            depth: 0,
            maximumEntryCount: maximumEntryCount,
            maximumFileCount: maximumFileCount,
            maximumByteCount: maximumByteCount,
            visitedEntryCount: &visitedEntryCount,
            fileCount: &fileCount,
            totalByteCount: &totalByteCount,
            bucketCounts: &bucketCounts,
            bucketPrimary: &bucketPrimary,
            bucketSecondary: &bucketSecondary
        )
        var finalRootStatus = stat()
        guard fstat(rootDescriptor, &finalRootStatus) == 0,
              finalRootStatus.st_dev == rootStatus.st_dev,
              finalRootStatus.st_ino == rootStatus.st_ino else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "orphan_import_inventory_root"
            )
        }
        var inventoryMaterial = Data("ambitions.import.orphan-inventory.v3\n".utf8)
        for bucket in 0..<256 where bucketCounts[bucket] > 0 {
            inventoryMaterial.append(UInt8(bucket))
            for shift in stride(from: 56, through: 0, by: -8) {
                inventoryMaterial.append(
                    UInt8((bucketCounts[bucket] >> UInt64(shift)) & 0xff)
                )
            }
            inventoryMaterial.append(contentsOf: bucketPrimary[bucket])
            inventoryMaterial.append(contentsOf: bucketSecondary[bucket])
        }
        inventoryMaterial.append(Data("\n\(fileCount)\n\(totalByteCount)".utf8))
        let digest = LocalRuntimeStorageChecksum.sha256Hex(for: inventoryMaterial)
        return (digest, fileCount, totalByteCount)
    }

    private func inventoryQuarantinedImportDirectoryDescriptor(
        _ directoryDescriptor: Int32,
        relativeComponents: [Data],
        depth: Int,
        maximumEntryCount: Int,
        maximumFileCount: Int,
        maximumByteCount: Int64,
        visitedEntryCount: inout Int,
        fileCount: inout Int,
        totalByteCount: inout Int64,
        bucketCounts: inout [UInt64],
        bucketPrimary: inout [[UInt8]],
        bucketSecondary: inout [[UInt8]]
    ) throws {
        guard depth <= 64 else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: maximumEntryCount
            )
        }
        var directoryBefore = stat()
        guard fstat(directoryDescriptor, &directoryBefore) == 0,
              directoryBefore.st_mode & S_IFMT == S_IFDIR else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let enumerationDescriptor = Darwin.dup(directoryDescriptor)
        guard enumerationDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "open_orphan_import_inventory_stream"
            )
        }
        guard let stream = fdopendir(enumerationDescriptor) else {
            guard Darwin.close(enumerationDescriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "open_orphan_import_inventory_stream"
            )
        }
        var streamOpen = true
        do {
            while true {
                try Task.checkCancellation()
                errno = 0
                guard let entry = readdir(stream) else {
                    guard errno == 0 else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "read_orphan_import_inventory_entry"
                        )
                    }
                    break
                }
                let rawName = withUnsafePointer(to: entry.pointee.d_name) { pointer -> Data in
                    pointer.withMemoryRebound(
                        to: CChar.self,
                        capacity: Int(MAXNAMLEN) + 1
                    ) {
                        Data(bytes: $0, count: strnlen($0, Int(MAXNAMLEN) + 1))
                    }
                }
                if rawName == Data(".".utf8) || rawName == Data("..".utf8) { continue }
                guard rawName.isEmpty == false,
                      rawName.count <= Int(MAXNAMLEN),
                      let name = String(data: rawName, encoding: .utf8) else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
                visitedEntryCount += 1
                guard visitedEntryCount <= maximumEntryCount else {
                    throw RuntimeGenerationControlError.readBudgetExceeded(
                        maximumBytes: maximumEntryCount
                    )
                }
                let components = relativeComponents + [rawName]
                let pathByteCount = components.reduce(components.count - 1) {
                    $0 + $1.count
                }
                guard pathByteCount <= 4_096 else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                var entryBefore = stat()
                guard fstatat(
                    directoryDescriptor,
                    name,
                    &entryBefore,
                    AT_SYMLINK_NOFOLLOW
                ) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "inspect_orphan_import_inventory_entry"
                    )
                }
                let entryType = entryBefore.st_mode & S_IFMT
                guard entryType != S_IFLNK else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                if entryType == S_IFDIR {
                    guard entryBefore.st_dev == directoryBefore.st_dev else {
                        throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                    }
                    let childDescriptor = Darwin.openat(
                        directoryDescriptor,
                        name,
                        O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
                    )
                    guard childDescriptor >= 0 else {
                        throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                    }
                    var childOpen = true
                    do {
                        var openedChild = stat()
                        guard fstat(childDescriptor, &openedChild) == 0,
                              openedChild.st_mode & S_IFMT == S_IFDIR,
                              openedChild.st_dev == entryBefore.st_dev,
                              openedChild.st_ino == entryBefore.st_ino else {
                            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                                artifact: "orphan_import_inventory_directory"
                            )
                        }
                        try inventoryQuarantinedImportDirectoryDescriptor(
                            childDescriptor,
                            relativeComponents: components,
                            depth: depth + 1,
                            maximumEntryCount: maximumEntryCount,
                            maximumFileCount: maximumFileCount,
                            maximumByteCount: maximumByteCount,
                            visitedEntryCount: &visitedEntryCount,
                            fileCount: &fileCount,
                            totalByteCount: &totalByteCount,
                            bucketCounts: &bucketCounts,
                            bucketPrimary: &bucketPrimary,
                            bucketSecondary: &bucketSecondary
                        )
                        var childAfter = stat()
                        var childPathAfter = stat()
                        guard fstat(childDescriptor, &childAfter) == 0,
                              fstatat(
                                  directoryDescriptor,
                                  name,
                                  &childPathAfter,
                                  AT_SYMLINK_NOFOLLOW
                              ) == 0,
                              childAfter.st_dev == openedChild.st_dev,
                              childAfter.st_ino == openedChild.st_ino,
                              childPathAfter.st_mode & S_IFMT == S_IFDIR,
                              childPathAfter.st_dev == openedChild.st_dev,
                              childPathAfter.st_ino == openedChild.st_ino else {
                            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                                artifact: "orphan_import_inventory_directory"
                            )
                        }
                        childOpen = false
                        guard Darwin.close(childDescriptor) == 0 else {
                            throw LocalRuntimeStorageError.canonicalIOFailure(
                                operation: "close_orphan_import_inventory_directory"
                            )
                        }
                    } catch {
                        let operationError = error
                        if childOpen {
                            childOpen = false
                            guard Darwin.close(childDescriptor) == 0 else {
                                throw RuntimeGenerationControlError.controlAuthorityUnavailable
                            }
                        }
                        throw operationError
                    }
                    continue
                }
                guard entryType == S_IFREG,
                      entryBefore.st_nlink == 1,
                      entryBefore.st_size >= 0,
                      fileCount < maximumFileCount else {
                    if entryType == S_IFREG, fileCount >= maximumFileCount {
                        throw RuntimeGenerationControlError.readBudgetExceeded(
                            maximumBytes: maximumFileCount
                        )
                    }
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                let byteCount = Int64(entryBefore.st_size)
                let prospectiveByteCount = totalByteCount.addingReportingOverflow(byteCount)
                guard prospectiveByteCount.overflow == false,
                      prospectiveByteCount.partialValue <= maximumByteCount else {
                    throw RuntimeGenerationControlError.readBudgetExceeded(
                        maximumBytes: Int(maximumByteCount)
                    )
                }
                let fileDescriptor = Darwin.openat(
                    directoryDescriptor,
                    name,
                    O_RDONLY | O_NOFOLLOW | O_CLOEXEC
                )
                guard fileDescriptor >= 0 else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                var fileOpen = true
                let contentDigest: [UInt8]
                do {
                    var openedFile = stat()
                    guard fstat(fileDescriptor, &openedFile) == 0,
                          openedFile.st_mode & S_IFMT == S_IFREG,
                          openedFile.st_nlink == 1,
                          openedFile.st_dev == entryBefore.st_dev,
                          openedFile.st_ino == entryBefore.st_ino,
                          openedFile.st_size == entryBefore.st_size,
                          openedFile.st_gen == entryBefore.st_gen,
                          openedFile.st_mtimespec.tv_sec == entryBefore.st_mtimespec.tv_sec,
                          openedFile.st_mtimespec.tv_nsec == entryBefore.st_mtimespec.tv_nsec,
                          openedFile.st_ctimespec.tv_sec == entryBefore.st_ctimespec.tv_sec,
                          openedFile.st_ctimespec.tv_nsec == entryBefore.st_ctimespec.tv_nsec else {
                        throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                            artifact: "orphan_import_inventory_file"
                        )
                    }
                    var hasher = SHA256()
                    var remaining = byteCount
                    var buffer = [UInt8](repeating: 0, count: 128 * 1_024)
                    while remaining > 0 {
                        try Task.checkCancellation()
                        let requested = min(buffer.count, Int(remaining))
                        let readCount = buffer.withUnsafeMutableBytes {
                            Darwin.read(fileDescriptor, $0.baseAddress, requested)
                        }
                        if readCount < 0, errno == EINTR { continue }
                        guard readCount > 0 else {
                            throw LocalRuntimeStorageError.canonicalIOFailure(
                                operation: "read_orphan_import_inventory_file"
                            )
                        }
                        hasher.update(data: Data(buffer.prefix(readCount)))
                        remaining -= Int64(readCount)
                    }
                    var trailingByte: UInt8 = 0
                    var trailingCount: Int
                    repeat {
                        trailingCount = Darwin.read(fileDescriptor, &trailingByte, 1)
                    } while trailingCount < 0 && errno == EINTR
                    var fileAfter = stat()
                    var filePathAfter = stat()
                    guard trailingCount == 0,
                          fstat(fileDescriptor, &fileAfter) == 0,
                          fstatat(
                              directoryDescriptor,
                              name,
                              &filePathAfter,
                              AT_SYMLINK_NOFOLLOW
                          ) == 0,
                          fileAfter.st_dev == openedFile.st_dev,
                          fileAfter.st_ino == openedFile.st_ino,
                          fileAfter.st_size == openedFile.st_size,
                          fileAfter.st_gen == openedFile.st_gen,
                          fileAfter.st_mtimespec.tv_sec == openedFile.st_mtimespec.tv_sec,
                          fileAfter.st_mtimespec.tv_nsec == openedFile.st_mtimespec.tv_nsec,
                          fileAfter.st_ctimespec.tv_sec == openedFile.st_ctimespec.tv_sec,
                          fileAfter.st_ctimespec.tv_nsec == openedFile.st_ctimespec.tv_nsec,
                          fileAfter.st_nlink == 1,
                          filePathAfter.st_mode & S_IFMT == S_IFREG,
                          filePathAfter.st_dev == openedFile.st_dev,
                          filePathAfter.st_ino == openedFile.st_ino,
                          filePathAfter.st_size == openedFile.st_size,
                          filePathAfter.st_gen == openedFile.st_gen,
                          filePathAfter.st_mtimespec.tv_sec == openedFile.st_mtimespec.tv_sec,
                          filePathAfter.st_mtimespec.tv_nsec == openedFile.st_mtimespec.tv_nsec,
                          filePathAfter.st_ctimespec.tv_sec == openedFile.st_ctimespec.tv_sec,
                          filePathAfter.st_ctimespec.tv_nsec == openedFile.st_ctimespec.tv_nsec,
                          filePathAfter.st_nlink == 1 else {
                        throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                            artifact: "orphan_import_inventory_file"
                        )
                    }
                    contentDigest = Array(hasher.finalize())
                    fileOpen = false
                    guard Darwin.close(fileDescriptor) == 0 else {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "close_orphan_import_inventory_file"
                        )
                    }
                } catch {
                    let operationError = error
                    if fileOpen {
                        fileOpen = false
                        guard Darwin.close(fileDescriptor) == 0 else {
                            throw RuntimeGenerationControlError.controlAuthorityUnavailable
                        }
                    }
                    throw operationError
                }
                totalByteCount = prospectiveByteCount.partialValue
                fileCount += 1
                var material = Data("ambitions.import.inventory.leaf.v3\n".utf8)
                appendInventoryUInt64(UInt64(components.count), to: &material)
                for component in components {
                    appendInventoryUInt64(UInt64(component.count), to: &material)
                    material.append(component)
                }
                material.append(contentsOf: contentDigest)
                appendInventoryUInt64(UInt64(byteCount), to: &material)
                let bucketDigest = SHA256.hash(
                    data: Data("ambitions.import.inventory.bucket.v3\n".utf8) + material
                )
                let bucket = Int(bucketDigest.first ?? 0)
                let primary = Array(SHA256.hash(
                    data: Data("ambitions.import.inventory.primary.v3\n".utf8) + material
                ))
                let secondary = Array(SHA256.hash(
                    data: Data("ambitions.import.inventory.secondary.v3\n".utf8) + material
                ))
                for index in 0..<32 {
                    bucketPrimary[bucket][index] ^= primary[index]
                    bucketSecondary[bucket][index] ^= secondary[index]
                }
                bucketCounts[bucket] += 1
            }
            streamOpen = false
            guard closedir(stream) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_orphan_import_inventory_stream"
                )
            }
        } catch {
            let operationError = error
            if streamOpen {
                streamOpen = false
                guard closedir(stream) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
        var directoryAfter = stat()
        guard fstat(directoryDescriptor, &directoryAfter) == 0,
              directoryAfter.st_dev == directoryBefore.st_dev,
              directoryAfter.st_ino == directoryBefore.st_ino,
              directoryAfter.st_mtimespec.tv_sec == directoryBefore.st_mtimespec.tv_sec,
              directoryAfter.st_mtimespec.tv_nsec == directoryBefore.st_mtimespec.tv_nsec,
              directoryAfter.st_ctimespec.tv_sec == directoryBefore.st_ctimespec.tv_sec,
              directoryAfter.st_ctimespec.tv_nsec == directoryBefore.st_ctimespec.tv_nsec else {
            throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                artifact: "orphan_import_inventory_directory"
            )
        }
    }

    private func appendInventoryUInt64(_ value: UInt64, to data: inout Data) {
        for shift in stride(from: 56, through: 0, by: -8) {
            data.append(UInt8((value >> UInt64(shift)) & 0xff))
        }
    }

    struct StagedSource: Sendable {
        let id: String
        let url: URL
        let artifact: RuntimeGenerationObservedArtifact
        let sourceKind: RuntimeLegacyImportSourceKind
        let sourceSchema: String
        /// Semantic identity of the logical source. For typed SwiftData this is
        /// derived from semantic record content, never transport bytes/inodes.
        let sourceIdentityDigest: String
        let sourceLocationFingerprint: String
        let reconciliationLock: RuntimeLegacyImportReconciliationLockScope
    }

    func inspectPinnedImportSourceArtifact(
        _ artifact: RuntimeGenerationObservedArtifact,
        importID: String,
        locations: RuntimeStoreLocations
    ) throws -> RuntimeGenerationObservedArtifact {
        let components = artifact.relativePath.split(separator: "/").map(String.init)
        guard components.count == 2,
              components[0] == importID,
              components[1] == "Raw-source" else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let parentURL = locations.importsURL.appendingPathComponent(
            importID,
            isDirectory: true
        )
        let parentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parentURL,
            createFinalComponentIfMissing: false
        )
        try parentPin.revalidate()
        let observed = try RuntimeLegacyImportPinnedArtifactIO.inspect(
            parentDescriptor: parentPin.descriptor,
            name: components[1],
            relativePath: artifact.relativePath,
            maximumBytes: Self.maximumSourceBytes,
            retainBytes: false
        ).artifact
        try parentPin.revalidate()
        return observed
    }

    func stageSourceFile(
        sourceURL: URL,
        sourceKind: RuntimeLegacyImportSourceKind,
        sourceSchema: String
    ) async throws -> StagedSource {
        let locations = await generationManager.locations
        let importID = nextID()
        try RuntimeStorePathValidation.requireSafeComponent(importID)
        let importsPin = try ensurePinnedProtectedDirectory(
            locations.importsURL,
            parent: locations.rootURL,
            artifact: "generation_imports_root"
        )
        let reconciliationLock = try acquireImportReconciliationLock(
            locations: locations
        )
        do {
        let directory = locations.importsURL.appendingPathComponent(importID, isDirectory: true)
        let stagingPin = try ensurePinnedProtectedDirectory(
            directory,
            parent: locations.importsURL,
            artifact: "generation_import_staging"
        )
        try importsPin.revalidate()
        try faultHook.check(.preservationBeforeSourceCapture)
        let copied = try RuntimeGenerationForensicArtifactPreserver.preserve(
            sources: [("source", sourceURL)],
            evidenceDirectoryURL: directory,
            evidenceDirectoryRelativePath: importID,
            maximumSourceBytes: Self.maximumSourceBytes,
            maximumCaptureSetBytes: Self.maximumSourceBytes
        )
        guard copied.references.count == 1,
              copied.references[0].preservation == .copied,
              let artifact = copied.references[0].copiedArtifact else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        guard Darwin.fsync(stagingPin.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_generation_import_staging"
            )
        }
        try faultHook.check(.preservationAfterSourceCapture)
        return StagedSource(
            id: importID,
            url: directory.appendingPathComponent("Raw-source"),
            artifact: artifact,
            sourceKind: sourceKind,
            sourceSchema: sourceSchema,
            sourceIdentityDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.legacy.physical-source.v1\n\(artifact.sha256)\n\(artifact.byteCount)\n\(sourceSchema)"
            ),
            sourceLocationFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.external-import-session.v1\n\(importID)"
            ),
            reconciliationLock: reconciliationLock
        )
        } catch {
            let operationError = error
            do { try reconciliationLock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    /// Captures a transactionally consistent SQLite image, including committed
    /// WAL frames, from an app-private, coordinator-owned namespace. SQLite may
    /// update bounded SHM coordination bytes while the exclusive namespace
    /// lock is held; it does not checkpoint the source or mutate canonical rows.
    func stageSQLiteSourceFile(
        sourceURL: URL,
        sourceKind: RuntimeLegacyImportSourceKind,
        sourceSchema: String
    ) async throws -> StagedSource {
        let locations = await generationManager.locations
        let importID = nextID()
        try RuntimeStorePathValidation.requireSafeComponent(importID)
        let importsPin = try ensurePinnedProtectedDirectory(
            locations.importsURL,
            parent: locations.rootURL,
            artifact: "generation_imports_root"
        )
        let coordinatedSourceRoot = locations.coordinatedLegacySourcesURL
        try ensurePinnedProtectedDirectory(
            coordinatedSourceRoot,
            parent: locations.importsURL,
            artifact: "coordinated_legacy_sources_root"
        )
        let standardizedSourceURL = sourceURL.standardizedFileURL
        guard standardizedSourceURL.deletingLastPathComponent() == coordinatedSourceRoot,
              standardizedSourceURL.lastPathComponent.isEmpty == false,
              standardizedSourceURL.lastPathComponent != ".",
              standardizedSourceURL.lastPathComponent != ".." else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let sourceRootPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            coordinatedSourceRoot,
            createFinalComponentIfMissing: false
        )
        try sourceRootPin.revalidate()
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: standardizedSourceURL,
            artifact: "coordinated_legacy_sqlite_source"
        )
        let coordinationLockURL = coordinatedSourceRoot.appendingPathComponent(
            ".canonical-v1-import.lock", isDirectory: false
        )
        try ensureCoordinationLock(at: coordinationLockURL, parent: coordinatedSourceRoot)
        let reconciliationLock = try acquireImportReconciliationLock(
            locations: locations
        )
        do {
        let directory = locations.importsURL.appendingPathComponent(
            importID, isDirectory: true
        )
        let stagingPin = try ensurePinnedProtectedDirectory(
            directory,
            parent: locations.importsURL,
            artifact: "generation_sqlite_import_staging"
        )
        try importsPin.revalidate()
        let destination = directory.appendingPathComponent("Raw-source", isDirectory: false)
        var snapshotConfiguration = CanonicalRuntimeStore.sqliteConfiguration(
            openMode: .readOnlySnapshot
        )
        snapshotConfiguration.readOnlySnapshotAuthority =
            SQLiteReadOnlySnapshotAuthority(
                appPrivateRootURL: coordinatedSourceRoot,
                coordinationLockURL: coordinationLockURL,
                allowsBoundedSharedMemoryCoordination: true
            )
        let sourceDatabase = try SQLiteDatabase(
            url: standardizedSourceURL,
            configuration: snapshotConfiguration
        )
        try faultHook.check(.preservationBeforeSourceCapture)
        do {
            _ = try await sourceDatabase.backup(
                to: destination,
                prepareReservedDestination: { _, _, descriptor in
                    try RuntimeStoreFileDurability.applyCompleteProtection(
                        toOpenFileDescriptor: descriptor,
                        artifact: "generation_sqlite_import_reserved"
                    )
                }
            )
        } catch {
            let operationError = error
            do { try await sourceDatabase.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_sqlite_import_source"
                )
            }
            throw operationError
        }
        do { try await sourceDatabase.close() }
        catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_sqlite_import_source"
            )
        }
        try sourceRootPin.revalidate()
        guard Darwin.fsync(stagingPin.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_generation_sqlite_import_staging"
            )
        }
        let artifact = try RuntimeLegacyImportPinnedArtifactIO.inspect(
            parentDescriptor: stagingPin.descriptor,
            name: "Raw-source",
            relativePath: "\(importID)/Raw-source",
            maximumBytes: Self.maximumSourceBytes,
            retainBytes: false
        ).artifact
        try stagingPin.revalidate()
        try faultHook.check(.preservationAfterSourceCapture)
        return StagedSource(
            id: importID,
            url: destination,
            artifact: artifact,
            sourceKind: sourceKind,
            sourceSchema: sourceSchema,
            sourceIdentityDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.legacy.physical-source.v1\n\(artifact.sha256)\n\(artifact.byteCount)\n\(sourceSchema)"
            ),
            sourceLocationFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.coordinated-sqlite-import-session.v1\n\(importID)"
            ),
            reconciliationLock: reconciliationLock
        )
        } catch {
            let operationError = error
            do { try reconciliationLock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    func quarantineImportArtifact(
        source: RuntimeLegacyImportSource
    ) async throws -> RuntimeGenerationObservedArtifact {
        let locations = await generationManager.locations
        let quarantineRootPin = try ensurePinnedProtectedDirectory(
            locations.quarantineURL,
            parent: locations.rootURL,
            artifact: "generation_quarantine_root"
        )
        let quarantineDirectory = locations.quarantineURL.appendingPathComponent(
            "import-\(source.importID)",
            isDirectory: true
        )
        let quarantinePin = try ensurePinnedProtectedDirectory(
            quarantineDirectory,
            parent: locations.quarantineURL,
            artifact: "ambiguous_import_quarantine"
        )
        try quarantineRootPin.revalidate()
        let copied = try RuntimeGenerationForensicArtifactPreserver.preserve(
            sources: [(
                "import-source",
                locations.importsURL.appendingPathComponent(
                    source.sourceArtifact.relativePath
                )
            )],
            evidenceDirectoryURL: quarantineDirectory,
            evidenceDirectoryRelativePath: "import-\(source.importID)",
            maximumSourceBytes: Self.maximumSourceBytes,
            maximumCaptureSetBytes: Self.maximumSourceBytes
        )
        guard copied.references.count == 1,
              copied.observations.count == 1,
              copied.references[0].preservation == .copied,
              copied.references[0].isRestorable == false,
              let artifact = copied.observations[0].observedArtifact else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        guard Darwin.fsync(quarantinePin.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_ambiguous_import_quarantine"
            )
        }
        return artifact
    }

    @discardableResult
    func ensurePinnedProtectedDirectory(
        _ url: URL,
        parent: URL,
        artifact: String
    ) throws -> RuntimeStoreDirectoryPin {
        let standardizedParent = parent.standardizedFileURL
        let standardizedURL = url.standardizedFileURL
        let name = standardizedURL.lastPathComponent
        guard standardizedURL.deletingLastPathComponent() == standardizedParent,
              name.isEmpty == false,
              name != ".", name != "..",
              name.contains("/") == false,
              name.utf8.count <= Int(MAXNAMLEN) else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let parentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            standardizedParent,
            createFinalComponentIfMissing: false
        )
        try parentPin.revalidate()
        let creationResult = Darwin.mkdirat(parentPin.descriptor, name, S_IRWXU)
        guard creationResult == 0 || errno == EEXIST else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "create_\(artifact)"
            )
        }
        let childDescriptor = Darwin.openat(
            parentPin.descriptor,
            name,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
        )
        guard childDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var childOpen = true
        do {
            var childStatus = stat()
            var entryStatus = stat()
            guard fstat(childDescriptor, &childStatus) == 0,
                  fstatat(
                      parentPin.descriptor,
                      name,
                      &entryStatus,
                      AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  childStatus.st_mode & S_IFMT == S_IFDIR,
                  entryStatus.st_mode & S_IFMT == S_IFDIR,
                  childStatus.st_dev == entryStatus.st_dev,
                  childStatus.st_ino == entryStatus.st_ino else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: artifact
                )
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: childDescriptor,
                artifact: artifact
            )
            guard Darwin.fsync(childDescriptor) == 0,
                  Darwin.fsync(parentPin.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_\(artifact)"
                )
            }
            try parentPin.revalidate()
            var finalEntryStatus = stat()
            guard fstatat(
                parentPin.descriptor,
                name,
                &finalEntryStatus,
                AT_SYMLINK_NOFOLLOW
            ) == 0,
            finalEntryStatus.st_mode & S_IFMT == S_IFDIR,
            finalEntryStatus.st_dev == childStatus.st_dev,
            finalEntryStatus.st_ino == childStatus.st_ino,
            Darwin.fcntl(childDescriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: artifact
                )
            }
            childOpen = false
            return RuntimeStoreDirectoryPin(
                descriptor: childDescriptor,
                identity: RuntimeStoreFileIdentity(
                    device: UInt64(childStatus.st_dev),
                    inode: UInt64(childStatus.st_ino)
                ),
                pathURL: standardizedURL
            )
        } catch {
            let operationError = error
            if childOpen {
                childOpen = false
                guard Darwin.close(childDescriptor) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
    }

    func acquireImportReconciliationLock(
        locations: RuntimeStoreLocations
    ) throws -> RuntimeLegacyImportReconciliationLockScope {
        let controlPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.controlURL,
            createFinalComponentIfMissing: false
        )
        try controlPin.revalidate()
        let lockName = ".import-reconciliation.lock"
        var descriptor = Darwin.openat(
            controlPin.descriptor,
            lockName,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        if descriptor < 0, errno == EEXIST {
            descriptor = Darwin.openat(
                controlPin.descriptor,
                lockName,
                O_RDWR | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 0,
              Darwin.flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            if descriptor >= 0, Darwin.close(descriptor) != 0 {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        var descriptorStatus = stat()
        var pathStatus = stat()
        guard fstat(descriptor, &descriptorStatus) == 0,
              fstatat(
                  controlPin.descriptor,
                  lockName,
                  &pathStatus,
                  AT_SYMLINK_NOFOLLOW
              ) == 0,
              descriptorStatus.st_mode & S_IFMT == S_IFREG,
              descriptorStatus.st_nlink == 1,
              descriptorStatus.st_dev == pathStatus.st_dev,
                  descriptorStatus.st_ino == pathStatus.st_ino else {
            let unlocked = Darwin.flock(descriptor, LOCK_UN) == 0
            let closed = Darwin.close(descriptor) == 0
            guard unlocked, closed else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: descriptor,
                artifact: "import_reconciliation_lock"
            )
            guard Darwin.fsync(controlPin.descriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            try controlPin.revalidate()
        } catch {
            let operationError = error
            let unlocked = Darwin.flock(descriptor, LOCK_UN) == 0
            let closed = Darwin.close(descriptor) == 0
            guard unlocked, closed else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw operationError
        }
        return RuntimeLegacyImportReconciliationLockScope(descriptor: descriptor)
    }

    func ensureCoordinationLock(at url: URL, parent: URL) throws {
        try RuntimeStorePathValidation.requireContained(url, in: parent)
        let name = url.lastPathComponent
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
        let parentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parent,
            createFinalComponentIfMissing: false
        )
        try parentPin.revalidate()
        let descriptor = Darwin.openat(
            parentPin.descriptor,
            name,
            O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorStatus = stat()
        var pathStatus = stat()
        let valid = fstat(descriptor, &descriptorStatus) == 0 &&
            fstatat(
                parentPin.descriptor, name, &pathStatus, AT_SYMLINK_NOFOLLOW
            ) == 0 &&
            descriptorStatus.st_mode & S_IFMT == S_IFREG &&
            descriptorStatus.st_nlink == 1 &&
            descriptorStatus.st_dev == pathStatus.st_dev &&
            descriptorStatus.st_ino == pathStatus.st_ino
        guard valid else {
            guard Darwin.close(descriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorOpen = true
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: descriptor,
                artifact: "coordinated_legacy_source_lock"
            )
            guard Darwin.fsync(descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_coordinated_legacy_source_lock"
                )
            }
            descriptorOpen = false
            guard Darwin.close(descriptor) == 0,
                  Darwin.fsync(parentPin.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_coordinated_legacy_source_lock"
                )
            }
        } catch {
            let operationError = error
            if descriptorOpen {
                descriptorOpen = false
                guard Darwin.close(descriptor) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
        try parentPin.revalidate()
    }

    /// Actor-confined mutable staging state. It is never returned, stored in a
    /// task, or transferred across an isolation boundary.
    final class ImportAccumulator {
        let importID: String
        var itemCount = 0
        var requiresQuarantine = false
        var decodedByteCount: Int64 = 0
        var lastSourceRecordID: String?
        var mappedArtifactSetDigest: String
        let durableProcessedFloor: Int

        init(importID: String, durableProcessedFloor: Int) {
            self.importID = importID
            self.durableProcessedFloor = durableProcessedFloor
            mappedArtifactSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: "ambitions.import.mapped-artifacts.v1\n\(importID)"
            )
        }

        func consumeDecodedBytes(_ count: Int) throws {
            guard count >= 0,
                  Int64(count) <=
                    RuntimeGenerationLegacyImportService.maximumImportDecodedBytes,
                  decodedByteCount <=
                    RuntimeGenerationLegacyImportService.maximumImportDecodedBytes - Int64(count)
            else {
                throw RuntimeGenerationControlError.readBudgetExceeded(
                    maximumBytes: Int(
                        RuntimeGenerationLegacyImportService.maximumImportDecodedBytes
                    )
                )
            }
            decodedByteCount += Int64(count)
        }
    }

    func recordImportSource(
        _ staged: StagedSource
    ) async throws -> (source: RuntimeLegacyImportSource, staged: StagedSource) {
        do {
            let result = try await recordImportSourceLocked(staged)
            try staged.reconciliationLock.close()
            return result
        } catch {
            let operationError = error
            do { try staged.reconciliationLock.close() }
            catch { throw RuntimeGenerationControlError.controlAuthorityUnavailable }
            throw operationError
        }
    }

    func recordImportSourceLocked(
        _ staged: StagedSource
    ) async throws -> (source: RuntimeLegacyImportSource, staged: StagedSource) {
        let identityDigest = staged.sourceIdentityDigest
        if let existing = try await controlStore.importSource(
            identityDigest: identityDigest, schema: staged.sourceSchema
        ) {
            guard existing.sourceKind == staged.sourceKind,
                  existing.sourceSchema == staged.sourceSchema else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let locations = await generationManager.locations
            if existing.importID == staged.id {
                guard existing.sourceIdentityDigest == staged.sourceIdentityDigest,
                      existing.sourceArtifact == staged.artifact,
                      existing.sourceLocationFingerprint == staged.sourceLocationFingerprint,
                      try inspectPinnedImportSourceArtifact(
                          existing.sourceArtifact,
                          importID: existing.importID,
                          locations: locations
                      ) == existing.sourceArtifact else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                return (existing, staged)
            }
            try await quarantineOrphanImportDirectoryLocked(
                staged.url.deletingLastPathComponent(),
                locations: locations
            )
            let sourceURL = locations.importsURL.appendingPathComponent(
                existing.sourceArtifact.relativePath
            )
            guard try inspectPinnedImportSourceArtifact(
                existing.sourceArtifact,
                importID: existing.importID,
                locations: locations
            ) == existing.sourceArtifact else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            return (
                existing,
                StagedSource(
                    id: existing.importID,
                    url: sourceURL,
                    artifact: existing.sourceArtifact,
                    sourceKind: existing.sourceKind,
                    sourceSchema: existing.sourceSchema,
                    sourceIdentityDigest: existing.sourceIdentityDigest,
                    sourceLocationFingerprint: existing.sourceLocationFingerprint,
                    reconciliationLock: staged.reconciliationLock
                )
            )
        }
        let source = try RuntimeGenerationControlRecordFactory.importSource(
            id: staged.id,
            sourceKind: staged.sourceKind,
            sourceIdentityDigest: identityDigest,
            sourceSchema: staged.sourceSchema,
            sourceArtifact: staged.artifact,
            sourceLocationFingerprint: staged.sourceLocationFingerprint,
            discoveredAtMilliseconds: try nowMilliseconds()
        )
        let checkpoint = try RuntimeGenerationControlRecordFactory.importCheckpoint(
            id: nextID(),
            importID: source.importID,
            sequence: 0,
            phase: .sourcePreserved,
            priorCheckpointDigest: nil,
            sourceArtifactSHA256: source.sourceArtifact.sha256,
            artifactSetDigest: source.sourceArtifact.sha256,
            lastSourceRecordID: nil,
            processedItemCount: 0,
            occurredAtMilliseconds: try nowMilliseconds(),
            evidence: .sourcePreserved(sourceDigest: source.sourceDigest)
        )
        try faultHook.check(.preservationBeforeAuthorityCommit)
        try await controlStore.recordImportSourceAndInitialCheckpoint(
            source: source,
            checkpoint: checkpoint
        )
        try faultHook.check(.preservationAfterAuthorityCommit)
        return (source, staged)
    }

    func decodeTablesByKeyset(
        database: SQLiteDatabase,
        consume: (RuntimeLegacyDecodedRecord) async throws -> Void
    ) async throws {
        let tableRows = try await database.query(
            "SELECT name, sql FROM sqlite_schema WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name LIMIT ?",
            bindings: [.integer(Int64(Self.maximumTableCount + 1))],
            maximumDecodedBytes: Self.maximumDecodedBytes
        )
        guard tableRows.count <= Self.maximumTableCount else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: Self.maximumTableCount
            )
        }
        var recordCount = 0
        for tableRow in tableRows {
            try Task.checkCancellation()
            guard case let .text(table)? = tableRow.value(named: "name"),
                  case let .text(createSQL)? = tableRow.value(named: "sql"),
                  Self.isSafeSQLiteIdentifier(table) else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let columnRows = try await database.query(
                "PRAGMA table_info(\(table))",
                maximumDecodedBytes: Self.maximumDecodedBytes
            )
            guard columnRows.count <= Self.maximumColumnCount else {
                throw RuntimeGenerationControlError.readBudgetExceeded(
                    maximumBytes: Self.maximumColumnCount
                )
            }
            let columnMetadata = try columnRows.map { row -> (String, Int64) in
                guard case let .text(name)? = row.value(named: "name"),
                      case let .integer(primaryKeyOrdinal)? = row.value(named: "pk"),
                      Self.isSafeSQLiteIdentifier(name) else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                return (name, primaryKeyOrdinal)
            }
            let columns = columnMetadata.map(\.0)
            guard columns.isEmpty == false else { continue }
            let quotedColumns = columns.map { "\"\($0)\"" }
            let withoutRowID = createSQL.uppercased().contains("WITHOUT ROWID")
            let primaryKeyColumns = columnMetadata.filter { $0.1 > 0 }
                .sorted { $0.1 < $1.1 }.map(\.0)
            guard withoutRowID == false || primaryKeyColumns.isEmpty == false else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let cursorColumns = withoutRowID ? primaryKeyColumns : ["rowid"]
            var cursorValues: [SQLiteValue]?
            while true {
                try Task.checkCancellation()
                let selectPrefix = withoutRowID
                    ? "SELECT \(quotedColumns.joined(separator: ", "))"
                    : "SELECT rowid AS __ambitions_rowid__, \(quotedColumns.joined(separator: ", "))"
                let order = cursorColumns.map { "\"\($0)\"" }.joined(separator: ", ")
                let sql: String
                let bindings: [SQLiteBinding]
                if let cursorValues {
                    let tuple = cursorColumns.map { "\"\($0)\"" }.joined(separator: ", ")
                    let placeholders = Array(repeating: "?", count: cursorValues.count)
                        .joined(separator: ", ")
                    sql = "\(selectPrefix) FROM \"\(table)\" WHERE (\(tuple)) > (\(placeholders)) ORDER BY \(order) LIMIT ?"
                    bindings = try cursorValues.map(Self.binding) + [.integer(Int64(Self.pageSize))]
                } else {
                    sql = "\(selectPrefix) FROM \"\(table)\" ORDER BY \(order) LIMIT ?"
                    bindings = [.integer(Int64(Self.pageSize))]
                }
                let rows = try await database.query(
                    sql,
                    bindings: bindings,
                    maximumDecodedBytes: Self.maximumDecodedBytes
                )
                for row in rows {
                    guard recordCount < Self.maximumRecords else {
                        throw RuntimeGenerationControlError.readBudgetExceeded(
                            maximumBytes: Self.maximumRecords
                        )
                    }
                    let sourcePairs = withoutRowID
                        ? Array(zip(row.columnNames, row.values))
                        : Array(zip(row.columnNames.dropFirst(), row.values.dropFirst()))
                    let decodedValues = sourcePairs.map(Self.decodedValue)
                    let primaryKey: [RuntimeLegacyDecodedValue]
                    if withoutRowID {
                        primaryKey = try primaryKeyColumns.map { name in
                            guard let value = row.value(named: name) else {
                                throw RuntimeGenerationControlError.importReviewRequired
                            }
                            return Self.decodedValue((name, value))
                        }
                    } else {
                        guard let rowID = row.value(named: "__ambitions_rowid__") else {
                            throw RuntimeGenerationControlError.importReviewRequired
                        }
                        primaryKey = [Self.decodedValue(("rowid", rowID))]
                    }
                    let record = RuntimeLegacyDecodedRecord(
                        table: table,
                        primaryKey: primaryKey,
                        values: decodedValues
                    )
                    let encoded = try RuntimeGenerationControlCodec.encode(record)
                    guard encoded.count <= RuntimeGenerationControlCodec.maximumRecordBytes else {
                        throw RuntimeGenerationControlError.readBudgetExceeded(
                            maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
                        )
                    }
                    try await consume(record)
                    recordCount += 1
                }
                if rows.count < Self.pageSize { break }
                guard let last = rows.last else { break }
                if withoutRowID {
                    cursorValues = try primaryKeyColumns.map { name in
                        guard let value = last.value(named: name), value != .null else {
                            throw RuntimeGenerationControlError.importReviewRequired
                        }
                        return value
                    }
                } else {
                    guard let value = last.value(named: "__ambitions_rowid__"),
                          case .integer = value else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                    cursorValues = [value]
                }
            }
        }
    }

    func appendDecodedRecord(
        _ record: RuntimeLegacyDecodedRecord,
        mapped: RuntimeLegacyMappedRecord?,
        rejected: RuntimeLegacyRejectedRecord?,
        staged: StagedSource,
        source: RuntimeLegacyImportSource,
        schemaVersion: RuntimeLegacyCanonicalSchemaVersion?,
        accumulator: ImportAccumulator
    ) async throws {
        try accumulator.consumeDecodedBytes(
            RuntimeGenerationControlCodec.encode(record).count
        )
        let recordDigest = try Self.decodedRecordPayloadDigest(record)
        let sourceRecordID = try Self.sourceRecordID(for: record)
        guard mapped == nil || mapped?.sourceRecordID == sourceRecordID,
              mapped == nil || mapped?.sourceRecordDigest == recordDigest,
              rejected == nil || rejected?.sourceRecordID == sourceRecordID,
              rejected == nil || rejected?.sourceRecordDigest == recordDigest,
              mapped == nil || rejected == nil else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let duplicate = try await controlStore.importContainsSourceRecordDigest(
            importID: source.importID, sourceRecordDigest: recordDigest
        )
        let disposition: RuntimeLegacyImportDisposition
        let canonicalPayloadDigest: String?
        let mappedArtifact: RuntimeLegacyMappedArtifactReference?
        if duplicate {
            disposition = .duplicate
            canonicalPayloadDigest = nil
            mappedArtifact = nil
        } else if let mapped {
            disposition = .reviewableDiscovery
            mappedArtifact = try await persistMappedArtifact(mapped, staged: staged)
            canonicalPayloadDigest = mappedArtifact?.artifact.sha256
        } else if let rejected {
            disposition = rejected.disposition
            canonicalPayloadDigest = nil
            mappedArtifact = nil
        } else {
            disposition = .ambiguous
            canonicalPayloadDigest = nil
            mappedArtifact = nil
        }
        let lossiness = mapped?.lossiness ?? rejected?.lossiness ?? .lossyRequiresReview
        let item = try RuntimeGenerationControlRecordFactory.importItem(
            importID: source.importID,
            sourceRecordID: sourceRecordID,
            sourceRecordDigest: recordDigest,
            canonicalFamily: disposition == .reviewableDiscovery ? mapped?.canonicalFamily : nil,
            canonicalID: disposition == .reviewableDiscovery ? mapped?.canonicalID : nil,
            canonicalPayloadDigest: canonicalPayloadDigest,
            mappedArtifact: mappedArtifact,
            disposition: disposition,
            warningCodes: duplicate ? ["duplicate_source_payload"] :
                mapped?.warningCodes ?? rejected?.warningCodes ?? Self.warningCodes(
                    disposition: disposition,
                    lossiness: lossiness,
                    schemaVersion: schemaVersion
                ),
            lossiness: duplicate ? .none : lossiness
        )
        try await controlStore.recordImportItem(item)
        try await advanceAccumulator(accumulator, item: item, source: source)
        accumulator.requiresQuarantine = accumulator.requiresQuarantine ||
            [.ambiguous, .unsupported, .malformed].contains(item.disposition)
    }

    func appendMappedRecord(
        _ mapped: RuntimeLegacyMappedRecord,
        staged: StagedSource,
        source: RuntimeLegacyImportSource,
        accumulator: ImportAccumulator
    ) async throws {
        try accumulator.consumeDecodedBytes(
            RuntimeGenerationControlCodec.encode(mapped.payload).count
        )
        let duplicate = try await controlStore.importContainsSourceRecordDigest(
            importID: source.importID,
            sourceRecordDigest: mapped.sourceRecordDigest
        )
        let mappedArtifact = duplicate
            ? nil
            : try await persistMappedArtifact(mapped, staged: staged)
        let item = try RuntimeGenerationControlRecordFactory.importItem(
            importID: source.importID,
            sourceRecordID: mapped.sourceRecordID,
            sourceRecordDigest: mapped.sourceRecordDigest,
            canonicalFamily: duplicate ? nil : mapped.canonicalFamily,
            canonicalID: duplicate ? nil : mapped.canonicalID,
            canonicalPayloadDigest: mappedArtifact?.artifact.sha256,
            mappedArtifact: mappedArtifact,
            disposition: duplicate ? .duplicate : .reviewableDiscovery,
            warningCodes: duplicate ? ["duplicate_source_payload"] : mapped.warningCodes,
            lossiness: duplicate ? .none : mapped.lossiness
        )
        try await controlStore.recordImportItem(item)
        try await advanceAccumulator(accumulator, item: item, source: source)
    }

    func finalizeImport(
        staged: StagedSource,
        source: RuntimeLegacyImportSource,
        accumulator: ImportAccumulator
    ) async throws -> RuntimeLegacyImportStagingResult {
        let mappedDirectory = staged.url.deletingLastPathComponent()
            .appendingPathComponent("Mapped", isDirectory: true)
        let importDirectoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            staged.url.deletingLastPathComponent(),
            createFinalComponentIfMissing: false
        )
        var mappedStatus = stat()
        if fstatat(
            importDirectoryPin.descriptor,
            "Mapped",
            &mappedStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0 {
            guard mappedStatus.st_mode & S_IFMT == S_IFDIR else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            let mappedDescriptor = Darwin.openat(
                importDirectoryPin.descriptor,
                "Mapped",
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC
            )
            guard mappedDescriptor >= 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            var mappedOpen = true
            do {
                var openedMapped = stat()
                guard fstat(mappedDescriptor, &openedMapped) == 0,
                      openedMapped.st_dev == mappedStatus.st_dev,
                      openedMapped.st_ino == mappedStatus.st_ino else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: "mapped_import_directory"
                    )
                }
                try await quarantineStrandedMappedArtifacts(
                    in: mappedDirectory,
                    parentDescriptor: mappedDescriptor,
                    staged: staged
                )
                var mappedAfter = stat()
                var entryAfter = stat()
                guard fstat(mappedDescriptor, &mappedAfter) == 0,
                      fstatat(
                          importDirectoryPin.descriptor,
                          "Mapped",
                          &entryAfter,
                          AT_SYMLINK_NOFOLLOW
                      ) == 0,
                      mappedAfter.st_dev == openedMapped.st_dev,
                      mappedAfter.st_ino == openedMapped.st_ino,
                      entryAfter.st_dev == openedMapped.st_dev,
                      entryAfter.st_ino == openedMapped.st_ino else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: "mapped_import_directory"
                    )
                }
                mappedOpen = false
                guard Darwin.close(mappedDescriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_mapped_import_directory"
                    )
                }
            } catch {
                let operationError = error
                if mappedOpen {
                    mappedOpen = false
                    guard Darwin.close(mappedDescriptor) == 0 else {
                        throw RuntimeGenerationControlError.controlAuthorityUnavailable
                    }
                }
                throw operationError
            }
        } else if errno != ENOENT {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "inspect_mapped_import_directory"
            )
        }
        var cursor: String?
        var observedCount = 0
        var itemSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "ambitions.import.items.v2\n\(source.importID)"
        )
        repeat {
            try Task.checkCancellation()
            let page = try await controlStore.importItemsPage(
                importID: source.importID,
                afterSourceRecordID: cursor,
                limit: Self.pageSize
            )
            for item in page {
                itemSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
                    for: "\(itemSetDigest)\n\(item.sourceRecordID)\n\(item.itemDigest)"
                )
                let increment = observedCount.addingReportingOverflow(1)
                guard increment.overflow == false else {
                    throw RuntimeGenerationControlError.readBudgetExceeded(
                        maximumBytes: Self.maximumRecords
                    )
                }
                observedCount = increment.partialValue
                cursor = item.sourceRecordID
            }
            if page.count < Self.pageSize { break }
        } while true
        guard observedCount == accumulator.itemCount else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let latest = try await controlStore.latestImportCheckpoint(importID: source.importID)
        if latest?.phase != .decoding || latest?.processedItemCount != accumulator.itemCount {
            try await appendCheckpoint(
                source: source, phase: .decoding,
                artifactSetDigest: accumulator.mappedArtifactSetDigest,
                lastSourceRecordID: accumulator.lastSourceRecordID,
                processedItemCount: accumulator.itemCount,
                evidence: .decoding(cursorDigest: accumulator.lastSourceRecordID.map {
                    LocalRuntimeStorageChecksum.sha256Hex(for: $0)
                })
            )
        }
        let manifest = try RuntimeGenerationControlRecordFactory.importManifest(
            importID: source.importID,
            itemCount: observedCount,
            orderedItemSetDigest: itemSetDigest,
            completedAtMilliseconds: try nowMilliseconds()
        )
        try await controlStore.recordImportManifest(manifest)
        try await appendCheckpoint(
            source: source, phase: .mapped,
            artifactSetDigest: accumulator.mappedArtifactSetDigest,
            lastSourceRecordID: accumulator.lastSourceRecordID,
            processedItemCount: accumulator.itemCount,
            evidence: .mapped(
                manifestDigest: manifest.manifestDigest,
                mappedArtifactSetDigest: accumulator.mappedArtifactSetDigest
            )
        )
        let quarantine: RuntimeGenerationQuarantineRecord?
        if accumulator.requiresQuarantine {
            let quarantineArtifact = try await quarantineImportArtifact(
                source: source
            )
            let record = try RuntimeGenerationControlRecordFactory.quarantine(
                id: nextID(),
                reason: .ambiguousImport,
                originalArtifact: quarantineArtifact,
                originalGenerationID: nil,
                originalManifestDigest: nil,
                diagnosticFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "legacy_import_review\nambiguous_import"
                ),
                allowedActions: [.inspectReadOnly, .exportOriginal],
                quarantinedAtMilliseconds: try nowMilliseconds()
            )
            try await controlStore.recordQuarantine(record)
            try await appendCheckpoint(
                source: source,
                phase: .quarantined,
                artifactSetDigest: record.quarantineDigest,
                lastSourceRecordID: accumulator.lastSourceRecordID,
                processedItemCount: accumulator.itemCount,
                evidence: .quarantined(
                    quarantineDigest: record.quarantineDigest,
                    recoveryActions: record.allowedActions
                )
            )
            quarantine = record
        } else {
            quarantine = nil
        }
        return RuntimeLegacyImportStagingResult(
            source: source,
            manifest: manifest,
            quarantine: quarantine
        )
    }

    func advanceAccumulator(
        _ accumulator: ImportAccumulator,
        item: RuntimeLegacyImportItem,
        source: RuntimeLegacyImportSource
    ) async throws {
        let increment = accumulator.itemCount.addingReportingOverflow(1)
        guard increment.overflow == false else {
            throw RuntimeGenerationControlError.readBudgetExceeded(maximumBytes: Self.maximumRecords)
        }
        accumulator.itemCount = increment.partialValue
        accumulator.lastSourceRecordID = item.sourceRecordID
        if let binding = item.mappedArtifact?.bindingDigest {
            accumulator.mappedArtifactSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: "\(accumulator.mappedArtifactSetDigest)\n\(item.sourceRecordID)\n\(binding)"
            )
        }
        if accumulator.itemCount > accumulator.durableProcessedFloor,
           accumulator.itemCount.isMultiple(of: Self.pageSize) {
            try await appendCheckpoint(
                source: source, phase: .decoding,
                artifactSetDigest: accumulator.mappedArtifactSetDigest,
                lastSourceRecordID: item.sourceRecordID,
                processedItemCount: accumulator.itemCount,
                evidence: .decoding(
                    cursorDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: item.sourceRecordID
                    )
                )
            )
        }
    }

    func appendCheckpoint(
        source: RuntimeLegacyImportSource,
        phase: RuntimeLegacyImportPhase,
        artifactSetDigest: String,
        lastSourceRecordID: String?,
        processedItemCount: Int,
        evidence: RuntimeLegacyImportCheckpointEvidence
    ) async throws {
        let prior = try await controlStore.latestImportCheckpoint(importID: source.importID)
        let nextSequence: Int
        if let prior {
            let increment = prior.sequence.addingReportingOverflow(1)
            guard increment.overflow == false else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            nextSequence = increment.partialValue
        } else {
            nextSequence = 0
        }
        let checkpoint = try RuntimeGenerationControlRecordFactory.importCheckpoint(
            id: nextID(), importID: source.importID, sequence: nextSequence,
            phase: phase, priorCheckpointDigest: prior?.checkpointDigest,
            sourceArtifactSHA256: source.sourceArtifact.sha256,
            artifactSetDigest: artifactSetDigest,
            lastSourceRecordID: lastSourceRecordID,
            processedItemCount: processedItemCount,
            occurredAtMilliseconds: try nowMilliseconds(), evidence: evidence
        )
        try await controlStore.recordImportCheckpoint(checkpoint)
    }

    static func warningCodes(
        disposition: RuntimeLegacyImportDisposition,
        lossiness: RuntimeLegacyImportLossiness,
        schemaVersion: RuntimeLegacyCanonicalSchemaVersion?
    ) -> [String] {
        var warnings: [String] = []
        if disposition == .ambiguous { warnings.append("unmapped_family") }
        if disposition == .duplicate { warnings.append("duplicate_source_payload") }
        if lossiness != .none { warnings.append("lossiness_\(lossiness.rawValue)") }
        if let schemaVersion { warnings.append("decode_only_v\(schemaVersion.rawValue)") }
        return warnings
    }

    static func validateSwiftDataRecord(_ record: RuntimeSwiftDataImportRecord) throws {
        try record.envelope.validate()
        guard record.payloadVersion == 1,
              record.stableRecordID.isEmpty == false,
              record.envelope.sourceIdentity.sourceSchemaVersion ==
                objectStoreSwiftDataSchemaVersion,
              record.envelope.payload.stableRecordID == record.stableRecordID,
              record.envelope.payload.modelType == record.modelType,
              record.envelope.sourceDisposition == record.modelType.sourceDisposition,
              record.envelope.requiresReview,
              record.envelope.materializationAuthorized == false else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
    }

    struct CanonicalTableSpec: Sendable {
        let family: String
        let identityColumns: [String]
        let versionColumn: String
        let acceptedVersions: Set<Int>
        let payloadColumn: String
        let checksumColumn: String
    }

    static func mapCanonicalSQLiteRecord(
        _ record: RuntimeLegacyDecodedRecord,
        schemaVersion: RuntimeLegacyCanonicalSchemaVersion
    ) throws -> RuntimeLegacyMappedRecord? {
        guard let spec = canonicalTableSpecs(for: schemaVersion)[record.table] else {
            return nil
        }
        var values: [String: RuntimeLegacyDecodedValue] = [:]
        values.reserveCapacity(record.values.count)
        for value in record.values {
            guard values.updateValue(value, forKey: value.column) == nil else {
                throw RuntimeGenerationControlError.malformed(
                    field: "legacy_\(record.table)_duplicate_column"
                )
            }
        }
        let identity = try spec.identityColumns.map { column -> String in
            guard let value = values[column], value.kind == "text", value.value.isEmpty == false else {
                throw RuntimeGenerationControlError.malformed(
                    field: "legacy_\(record.table)_\(column)"
                )
            }
            return value.value
        }
        guard let versionValue = values[spec.versionColumn],
              versionValue.kind == "integer",
              let payloadVersion = Int(versionValue.value),
              spec.acceptedVersions.contains(payloadVersion),
              let payloadValue = values[spec.payloadColumn],
              payloadValue.kind == "blob_base64",
              let payload = Data(base64Encoded: payloadValue.value),
              payload.isEmpty == false,
              payload.count <= RuntimeGenerationControlCodec.maximumRecordBytes,
              let checksumValue = values[spec.checksumColumn],
              checksumValue.kind == "text",
              LocalRuntimeStorageChecksum.sha256Hex(for: payload) == checksumValue.value else {
            throw RuntimeGenerationControlError.malformed(
                field: "legacy_\(record.table)_payload"
            )
        }
        let typed = try validateAndUpcastCanonicalPayload(
            record: record,
            spec: spec,
            values: values,
            payloadVersion: payloadVersion,
            payload: payload,
            storedChecksum: checksumValue.value
        )
        let sourceRecordDigest = try decodedRecordPayloadDigest(record)
        let canonicalID = try canonicalIdentityID(
            table: record.table,
            columns: spec.identityColumns,
            values: identity
        )
        let artifact = RuntimeLegacyCanonicalSQLiteArtifact(
            sourceSchemaVersion: schemaVersion,
            table: record.table,
            canonicalFamily: spec.family,
            canonicalID: canonicalID,
            payloadVersion: payloadVersion,
            payload: typed.payload,
            payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: typed.payload),
            sourceRecord: record
        )
        return RuntimeLegacyMappedRecord(
            sourceRecordID: try sourceRecordID(for: record),
            sourceRecordDigest: sourceRecordDigest,
            canonicalFamily: spec.family,
            canonicalID: canonicalID,
            payloadVersion: payloadVersion,
            payload: .canonicalSQLite(artifact),
            lossiness: typed.lossiness,
            warningCodes: typed.warnings
        )
    }

    /// Every decode-only source version has an explicit accepted-table catalog.
    /// A later schema cannot inherit acceptance accidentally: adding or changing
    /// a version requires editing its branch and the corresponding source tests.
    static func canonicalTableSpecs(
        for version: RuntimeLegacyCanonicalSchemaVersion
    ) -> [String: CanonicalTableSpec] {
        switch version {
        case .v1: canonicalV1PayloadTableSpecs()
        }
    }

    static func canonicalV1PayloadTableSpecs() -> [String: CanonicalTableSpec] {
        let specifications = [
            CanonicalTableSpec(
                family: "aggregate",
                identityColumns: ["aggregate_kind", "aggregate_id"],
                versionColumn: "payload_version",
                acceptedVersions: [1],
                payloadColumn: "payload",
                checksumColumn: "payload_checksum"
            ),
            CanonicalTableSpec(
                family: "receipt",
                identityColumns: ["receipt_id"],
                versionColumn: "receipt_version",
                acceptedVersions: [runtimeCommittedReceiptCoreVersion],
                payloadColumn: "payload",
                checksumColumn: "payload_checksum"
            ),
            CanonicalTableSpec(
                family: "tombstone",
                identityColumns: ["object_kind", "object_id"],
                versionColumn: "tombstone_version",
                acceptedVersions: [1],
                payloadColumn: "payload",
                checksumColumn: "checksum"
            ),
        ]
        return Dictionary(uniqueKeysWithValues: zip(
            [
                "runtime_aggregates",
                "runtime_receipts",
                "runtime_tombstones",
            ],
            specifications
        ))
    }

    static func validateAndUpcastCanonicalPayload(
        record: RuntimeLegacyDecodedRecord,
        spec: CanonicalTableSpec,
        values: [String: RuntimeLegacyDecodedValue],
        payloadVersion: Int,
        payload: Data,
        storedChecksum: String
    ) throws -> (
        payload: Data,
        lossiness: RuntimeLegacyImportLossiness,
        warnings: [String]
    ) {
        switch spec.family {
        case "aggregate":
            guard let kind = values["aggregate_kind"]?.value,
                  let identifier = values["aggregate_id"]?.value,
                  let revisionValue = values["revision"],
                  revisionValue.kind == "integer",
                  let revision = UInt64(revisionValue.value) else {
                throw RuntimeGenerationControlError.malformed(field: "legacy_aggregate_identity")
            }
            let state = try RuntimeCanonicalAggregateStateCodec().decode(payload)
            guard state.aggregate.kind.rawValue == kind,
                  state.aggregate.id.rawValue == identifier,
                  state.revision == revision else {
                throw RuntimeGenerationControlError.malformed(field: "legacy_aggregate_parity")
            }
            let current = try RuntimeCanonicalAggregateStateCodec().encode(state)
            if current == payload {
                return (current, .none, ["canonical_v1_typed_aggregate"])
            }
            return (
                current,
                .metadataOnly,
                ["canonical_v1_typed_aggregate", "source_bytes_upcast_requires_review"]
            )
        case "receipt":
            let core = try RuntimeCommittedReceiptCodec.decodeCore(
                payload, storedChecksum: storedChecksum
            )
            guard core.facts.version == payloadVersion,
                  core.facts.receiptID.rawValue == values["receipt_id"]?.value,
                  core.facts.commandID.rawValue == values["command_id"]?.value else {
                throw RuntimeGenerationControlError.malformed(field: "legacy_receipt_parity")
            }
            return (payload, .none, ["canonical_v1_typed_receipt"])
        case "tombstone":
            let decoder = JSONDecoder()
            let draft = try decoder.decode(RuntimeCanonicalTombstoneDraft.self, from: payload)
            let canonical = try RuntimeCommittedReceiptCodec.encode(draft)
            guard canonical == payload,
                  draft.family == values["object_kind"]?.value,
                  draft.objectID.rawValue == values["object_id"]?.value,
                  values["revision"]?.value == String(draft.terminalRevision) else {
                throw RuntimeGenerationControlError.malformed(field: "legacy_tombstone_parity")
            }
            return (payload, .none, ["canonical_v1_typed_tombstone"])
        default:
            throw RuntimeGenerationControlError.malformed(field: "legacy_payload_family")
        }
    }

    func persistMappedArtifact(
        _ mapped: RuntimeLegacyMappedRecord,
        staged: StagedSource
    ) async throws -> RuntimeLegacyMappedArtifactReference {
        let artifactFormatVersion: Int
        switch mapped.payload {
        case .canonicalSQLite:
            artifactFormatVersion = 1
        case .swiftData:
            artifactFormatVersion = 2
        }
        let artifact = RuntimeLegacyMappedImportArtifact(
            formatVersion: artifactFormatVersion,
            importID: staged.id,
            sourceSchema: staged.sourceSchema,
            sourceRecordID: mapped.sourceRecordID,
            sourceRecordDigest: mapped.sourceRecordDigest,
            canonicalFamily: mapped.canonicalFamily,
            canonicalID: mapped.canonicalID,
            payloadVersion: mapped.payloadVersion,
            payload: mapped.payload
        )
        let bytes = try RuntimeGenerationControlCodec.encode(artifact)
        guard bytes.count <= RuntimeGenerationControlCodec.maximumRecordBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
            )
        }
        let digest = LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        let directory = staged.url.deletingLastPathComponent().appendingPathComponent(
            "Mapped", isDirectory: true
        )
        try ensurePinnedProtectedDirectory(
            directory,
            parent: staged.url.deletingLastPathComponent(),
            artifact: "legacy_import_mapped_artifacts"
        )
        let directoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            directory,
            createFinalComponentIfMissing: false
        )
        try directoryPin.revalidate()
        try await quarantineStrandedMappedArtifacts(
            in: directory,
            parentDescriptor: directoryPin.descriptor,
            staged: staged
        )
        let destinationName = "\(digest).json"
        let temporaryName = "Pending-\(nextID()).json"
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(destinationName)
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(temporaryName)
        let destination = directory.appendingPathComponent(destinationName)
        try writeImmutableMappedArtifact(
            bytes,
            parentDescriptor: directoryPin.descriptor,
            name: temporaryName
        )
        let linkResult = Darwin.linkat(
            directoryPin.descriptor, temporaryName,
            directoryPin.descriptor, destinationName, 0
        )
        if linkResult != 0 {
            let linkError = errno
            guard linkError == EEXIST else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "publish_mapped_import_artifact"
                )
            }
            if try mappedArtifactMatches(
                bytes, digest: digest,
                parentDescriptor: directoryPin.descriptor,
                name: destinationName
            ) == false {
                let conflictName = "Conflict-\(nextID()).json"
                try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(conflictName)
                let conflict = directory.appendingPathComponent(conflictName)
                guard Darwin.renameatx_np(
                    directoryPin.descriptor, temporaryName,
                    directoryPin.descriptor, conflictName,
                    UInt32(RENAME_EXCL)
                ) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "preserve_mapped_import_conflict"
                    )
                }
                guard Darwin.fsync(directoryPin.descriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "synchronize_mapped_import_conflict"
                    )
                }
                try await quarantineMappedArtifactFiles(
                    [destination, conflict], staged: staged, reasonCode: "digest_path_conflict"
                )
                throw RuntimeGenerationControlError.importReviewRequired
            }
        }
        guard Darwin.unlinkat(directoryPin.descriptor, temporaryName, 0) == 0 ||
                errno == ENOENT else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "remove_mapped_import_pending_artifact"
            )
        }
        guard Darwin.fsync(directoryPin.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_mapped_import_publication"
            )
        }
        try directoryPin.revalidate()
        let storedArtifact = try RuntimeLegacyImportPinnedArtifactIO.inspect(
            parentDescriptor: directoryPin.descriptor,
            name: destinationName,
            relativePath: "\(staged.id)/Mapped/\(digest).json",
            maximumBytes: Int64(RuntimeGenerationControlCodec.maximumRecordBytes),
            retainBytes: false
        ).artifact
        return try RuntimeGenerationControlRecordFactory.mappedArtifactReference(
            importID: staged.id,
            sourceRecordID: mapped.sourceRecordID,
            sourceRecordDigest: mapped.sourceRecordDigest,
            artifact: storedArtifact,
            formatVersion: artifactFormatVersion,
            payloadVersion: mapped.payloadVersion
        )
    }

    func quarantineStrandedMappedArtifacts(
        in directory: URL,
        parentDescriptor: Int32,
        staged: StagedSource
    ) async throws {
        let enumerationDescriptor = Darwin.dup(parentDescriptor)
        guard enumerationDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "open_mapped_import_artifact_enumerator"
            )
        }
        guard let entries = fdopendir(enumerationDescriptor) else {
            guard Darwin.close(enumerationDescriptor) == 0 else {
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "open_mapped_import_artifact_enumerator"
            )
        }
        var streamOpen = true
        var stranded: [URL] = []
        do {
        while true {
            try Task.checkCancellation()
            errno = 0
            guard let entry = readdir(entries) else {
                guard errno == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "read_mapped_import_artifact_entry"
                    )
                }
                break
            }
            let rawName = withUnsafePointer(to: entry.pointee.d_name) { pointer -> Data in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) {
                    Data(bytes: $0, count: strnlen($0, Int(MAXNAMLEN) + 1))
                }
            }
            if rawName == Data(".".utf8) || rawName == Data("..".utf8) { continue }
            guard let name = String(data: rawName, encoding: .utf8) else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
            var entryStatus = stat()
            guard fstatat(
                parentDescriptor, name, &entryStatus, AT_SYMLINK_NOFOLLOW
            ) == 0,
            entryStatus.st_mode & S_IFMT == S_IFREG,
            entryStatus.st_nlink == 1 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            let entryURL = directory.appendingPathComponent(name)
            if name.hasPrefix("Pending-") || name.hasPrefix("Conflict-") {
                stranded.append(entryURL)
                if stranded.count == Self.pageSize { break }
                continue
            }
            guard name.hasSuffix(".json") else {
                stranded.append(entryURL)
                if stranded.count == Self.pageSize { break }
                continue
            }
            let digest = String(name.dropLast(5))
            guard digest.utf8.count == 64,
                  digest.utf8.allSatisfy({
                      ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
                  }),
                  try await controlStore.importContainsCanonicalPayloadDigest(
                    importID: staged.id,
                    canonicalPayloadDigest: digest
                  ) else {
                stranded.append(entryURL)
                if stranded.count == Self.pageSize { break }
                continue
            }
        }
        streamOpen = false
        guard closedir(entries) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_mapped_import_artifact_enumerator"
            )
        }
        } catch {
            let operationError = error
            if streamOpen {
                streamOpen = false
                guard closedir(entries) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
        guard stranded.isEmpty else {
            try await quarantineMappedArtifactFiles(
                stranded, staged: staged, reasonCode: "stranded_unbound_artifact"
            )
            throw RuntimeGenerationControlError.importReviewRequired
        }
    }

    func quarantineMappedArtifactFiles(
        _ files: [URL],
        staged: StagedSource,
        reasonCode: String
    ) async throws {
        let locations = await generationManager.locations
        let quarantineRootPin = try ensurePinnedProtectedDirectory(
            locations.quarantineURL,
            parent: locations.rootURL,
            artifact: "generation_quarantine_root"
        )
        let token = nextID()
        let directory = locations.quarantineURL.appendingPathComponent(
            "import-artifact-\(token)", isDirectory: true
        )
        let quarantinePin = try ensurePinnedProtectedDirectory(
            directory,
            parent: locations.quarantineURL,
            artifact: "mapped_import_artifact_quarantine"
        )
        try quarantineRootPin.revalidate()
        let sources = files.enumerated().map { index, url in
            ("mapped-\(index)", url)
        }
        let preservation = try RuntimeGenerationForensicArtifactPreserver.preserve(
            sources: sources,
            evidenceDirectoryURL: directory,
            evidenceDirectoryRelativePath: "import-artifact-\(token)",
            maximumSourceBytes: Int64(RuntimeGenerationControlCodec.maximumRecordBytes),
            maximumCaptureSetBytes: Self.maximumSourceBytes
        )
        guard preservation.references.count == files.count,
              preservation.observations.count == files.count,
              preservation.references.allSatisfy({
                  $0.preservation == .copied && $0.isRestorable == false
              }),
              preservation.observations.allSatisfy({ $0.observedArtifact != nil }) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        for observation in preservation.observations {
            guard let artifact = observation.observedArtifact else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            let quarantine = try RuntimeGenerationControlRecordFactory.quarantine(
                id: nextID(),
                reason: .corruption,
                originalArtifact: artifact,
                originalGenerationID: nil,
                originalManifestDigest: nil,
                diagnosticFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "mapped_import_quarantine\n\(reasonCode)"
                ),
                allowedActions: [.inspectReadOnly, .exportOriginal],
                quarantinedAtMilliseconds: try nowMilliseconds()
            )
            try await controlStore.recordQuarantine(quarantine)
        }
        if let sourceParent = files.first?.deletingLastPathComponent() {
            guard files.allSatisfy({ $0.deletingLastPathComponent() == sourceParent }) else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            let sourceParentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                sourceParent,
                createFinalComponentIfMissing: false
            )
            try sourceParentPin.revalidate()
            for (index, source) in files.enumerated() {
                let name = source.lastPathComponent
                try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
                guard index < preservation.references.count,
                      let expectedIdentity = preservation.references[index].fileIdentity else {
                    throw RuntimeGenerationControlError.importReviewRequired
                }
                var current = stat()
                guard fstatat(
                    sourceParentPin.descriptor,
                    name,
                    &current,
                    AT_SYMLINK_NOFOLLOW
                ) == 0,
                current.st_mode & S_IFMT == S_IFREG,
                current.st_nlink == 1,
                RuntimeStoreFileIdentity(
                    device: UInt64(current.st_dev),
                    inode: UInt64(current.st_ino)
                ) == expectedIdentity else {
                    throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                        artifact: "quarantined_import_artifact_source"
                    )
                }
                guard Darwin.unlinkat(sourceParentPin.descriptor, name, 0) == 0 ||
                        errno == ENOENT else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "remove_quarantined_import_artifact"
                    )
                }
            }
            guard Darwin.fsync(sourceParentPin.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "synchronize_quarantined_import_artifact_removal"
                )
            }
            try sourceParentPin.revalidate()
        }
        guard Darwin.fsync(quarantinePin.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "synchronize_mapped_import_artifact_quarantine"
            )
        }
    }

    func writeImmutableMappedArtifact(
        _ bytes: Data,
        parentDescriptor: Int32,
        name: String
    ) throws {
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
        let descriptor = Darwin.openat(
            parentDescriptor,
            name,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "create_mapped_import_artifact"
            )
        }
        var descriptorToClose = descriptor
        do {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: descriptorToClose,
                artifact: "legacy_import_mapped_artifact"
            )
            var offset = 0
            while offset < bytes.count {
                try Task.checkCancellation()
                let written = bytes.withUnsafeBytes { rawBuffer -> Int in
                    guard let baseAddress = rawBuffer.baseAddress else { return -1 }
                    return Darwin.write(
                        descriptorToClose,
                        baseAddress.advanced(by: offset),
                        bytes.count - offset
                    )
                }
                if written < 0, errno == EINTR { continue }
                guard written > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "write_mapped_import_artifact"
                    )
                }
                offset += written
            }
            guard Darwin.fsync(descriptorToClose) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "sync_mapped_import_artifact"
                )
            }
            guard Darwin.close(descriptorToClose) == 0 else {
                descriptorToClose = -1
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_mapped_import_artifact"
                )
            }
            descriptorToClose = -1
        } catch {
            let operationError = error
            if descriptorToClose >= 0 {
                let ownedDescriptor = descriptorToClose
                descriptorToClose = -1
                guard Darwin.close(ownedDescriptor) == 0 else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            }
            throw operationError
        }
    }

    func mappedArtifactMatches(
        _ bytes: Data,
        digest: String,
        parentDescriptor: Int32,
        name: String
    ) throws -> Bool {
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(name)
        let captured = try RuntimeLegacyImportPinnedArtifactIO.inspect(
            parentDescriptor: parentDescriptor,
            name: name,
            relativePath: "mapped-match/\(name)",
            maximumBytes: Int64(bytes.count),
            retainBytes: true
        )
        return captured.bytes == bytes && captured.artifact.sha256 == digest
    }

    static func decodedValue(_ pair: (String, SQLiteValue)) -> RuntimeLegacyDecodedValue {
        let (column, value) = pair
        switch value {
        case .null:
            return .init(column: column, kind: "null", value: "")
        case let .integer(item):
            return .init(column: column, kind: "integer", value: String(item))
        case let .real(item):
            return .init(column: column, kind: "real_bits", value: String(item.bitPattern))
        case let .text(item):
            return .init(column: column, kind: "text", value: item)
        case let .blob(item):
            return .init(column: column, kind: "blob_base64", value: item.base64EncodedString())
        }
    }

    static func decodedRecordPayloadDigest(
        _ record: RuntimeLegacyDecodedRecord
    ) throws -> String {
        LocalRuntimeStorageChecksum.sha256Hex(
            for: try RuntimeGenerationControlCodec.encode(
                RuntimeLegacyDecodedRecordPayload(
                    table: record.table,
                    values: record.values
                )
            )
        )
    }

    static func sourceRecordID(
        for record: RuntimeLegacyDecodedRecord
    ) throws -> String {
        guard record.primaryKey.isEmpty == false,
              record.primaryKey.allSatisfy({ $0.kind != "null" }) else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        return LocalRuntimeStorageChecksum.sha256Hex(
            for: try RuntimeGenerationControlCodec.encode(
                RuntimeLegacyDecodedRecord(
                    table: record.table,
                    primaryKey: record.primaryKey,
                    values: []
                )
            )
        )
    }

    static func canonicalIdentityID(
        table: String,
        columns: [String],
        values: [String]
    ) throws -> String {
        guard columns.count == values.count, columns.isEmpty == false else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        let typed = zip(columns, values).map {
            RuntimeLegacyDecodedValue(column: $0.0, kind: "text", value: $0.1)
        }
        return LocalRuntimeStorageChecksum.sha256Hex(
            for: try RuntimeGenerationControlCodec.encode(
                RuntimeLegacyDecodedRecordPayload(table: table, values: typed)
            )
        )
    }

    static func binding(_ value: SQLiteValue) throws -> SQLiteBinding {
        switch value {
        case .null:
            throw RuntimeGenerationControlError.importReviewRequired
        case let .integer(item):
            return .integer(item)
        case let .real(item):
            return .real(item)
        case let .text(item):
            return .text(item)
        case let .blob(item):
            return .blob(item)
        }
    }

    static func integerValue(_ value: SQLiteValue) -> Int? {
        guard case let .integer(item) = value else { return nil }
        return Int(exactly: item)
    }

    static func isSafeSQLiteIdentifier(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.allSatisfy { byte in
            (byte >= 48 && byte <= 57) ||
                (byte >= 65 && byte <= 90) ||
                (byte >= 97 && byte <= 122) ||
                byte == 95
        }
    }

    /// Actor-confined parser state for one synchronously owned file stream.
    final class SwiftDataStreamState {
        var sawHeader = false
        var sawFooter = false
        var transportSessionDigest: String?
        var recordCount = 0
        var recordSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "ambitions.swiftdata.export.semantic-records.v4"
        )
    }

    struct SwiftDataStreamSummary: Sendable, Equatable {
        let transportSessionDigest: String
        let recordCount: Int
        let recordSetDigest: String
    }

    func streamSwiftDataExport(
        _ staged: StagedSource,
        consume: (RuntimeSwiftDataImportRecord) async throws -> Void
    ) async throws -> SwiftDataStreamSummary {
        let parentURL = staged.url.deletingLastPathComponent()
        let fileName = staged.url.lastPathComponent
        try RuntimeLegacyImportPinnedArtifactIO.requireEntryName(fileName)
        let parentPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parentURL,
            createFinalComponentIfMissing: false
        )
        try parentPin.revalidate()
        let descriptor = Darwin.openat(
            parentPin.descriptor,
            fileName,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var descriptorOpen = true
        let state = SwiftDataStreamState()
        do {
            var status = stat()
            var pathStatus = stat()
            guard fstat(descriptor, &status) == 0,
                  fstatat(
                    parentPin.descriptor, fileName, &pathStatus,
                    AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  status.st_mode & S_IFMT == S_IFREG,
                  status.st_nlink == 1,
                  status.st_dev == pathStatus.st_dev,
                  status.st_ino == pathStatus.st_ino,
                  status.st_size == staged.artifact.byteCount,
                  staged.artifact.fileIdentity == RuntimeStoreFileIdentity(
                    device: UInt64(status.st_dev),
                    inode: UInt64(status.st_ino)
                  ) else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "swiftdata_import_export"
                )
            }
            var remaining = status.st_size
            var fileHasher = SHA256()
            var pending = Data()
            var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
            while remaining > 0 {
                try Task.checkCancellation()
                let requested = Int(min(Int64(buffer.count), remaining))
                let count: Int
                while true {
                    let result = buffer.withUnsafeMutableBytes {
                        Darwin.read(descriptor, $0.baseAddress, requested)
                    }
                    if result >= 0 {
                        count = result
                        break
                    }
                    if errno != EINTR {
                        throw LocalRuntimeStorageError.canonicalIOFailure(
                            operation: "read_swiftdata_import_export"
                        )
                    }
                }
                guard count > 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "short_swiftdata_import_export"
                    )
                }
                let chunk = Data(buffer[0..<count])
                fileHasher.update(data: chunk)
                pending.append(chunk)
                remaining -= Int64(count)
                guard pending.count <= RuntimeGenerationControlCodec.maximumRecordBytes * 2 else {
                    throw RuntimeGenerationControlError.readBudgetExceeded(
                        maximumBytes: RuntimeGenerationControlCodec.maximumRecordBytes
                    )
                }
                while let newline = pending.firstIndex(of: 0x0A) {
                    let line = pending[..<newline]
                    pending.removeSubrange(...newline)
                    guard line.isEmpty == false,
                          line.count <= RuntimeGenerationControlCodec.maximumRecordBytes else {
                        throw RuntimeGenerationControlError.importReviewRequired
                    }
                    let frame = try RuntimeGenerationControlCodec.decode(
                        RuntimeSwiftDataImportExportFrame.self,
                        from: Data(line)
                    )
                    switch frame {
                    case let .header(header):
                        guard state.sawHeader == false,
                              state.sawFooter == false,
                              state.recordCount == 0,
                              header.formatVersion == 4,
                              header.schemaVersion == objectStoreSwiftDataSchemaVersion else {
                            throw RuntimeGenerationControlError.importReviewRequired
                        }
                        try RuntimeGenerationControlValidation.requireDigest(
                            header.transportSessionDigest,
                            field: "swiftdata_transport_session_digest"
                        )
                        state.sawHeader = true
                        state.transportSessionDigest = header.transportSessionDigest
                    case let .record(record):
                        guard state.sawHeader,
                              state.sawFooter == false,
                              state.recordCount < Self.maximumRecords,
                              record.envelope.transportSessionDigest ==
                                state.transportSessionDigest else {
                            throw RuntimeGenerationControlError.importReviewRequired
                        }
                        try Self.validateSwiftDataRecord(record)
                        let recordDigest = try record.semanticRecordDigest()
                        state.recordSetDigest = LocalRuntimeStorageChecksum.sha256Hex(
                            for: "\(state.recordSetDigest)\n\(try record.canonicalSourceRecordID())\n\(recordDigest)"
                        )
                        state.recordCount += 1
                        try await consume(record)
                    case let .footer(footer):
                        guard state.sawHeader,
                              state.sawFooter == false,
                              footer.recordCount == state.recordCount,
                              footer.recordSetDigest == state.recordSetDigest else {
                            throw RuntimeGenerationControlError.importReviewRequired
                        }
                        state.sawFooter = true
                    }
                }
            }
            guard pending.isEmpty,
                  state.sawHeader,
                  state.sawFooter,
                  state.transportSessionDigest != nil,
                  Data(fileHasher.finalize()).map({ String(format: "%02x", $0) }).joined() ==
                    staged.artifact.sha256 else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
            var finalStatus = stat()
            var finalPathStatus = stat()
            guard fstat(descriptor, &finalStatus) == 0,
                  fstatat(
                    parentPin.descriptor, fileName, &finalPathStatus,
                    AT_SYMLINK_NOFOLLOW
                  ) == 0,
                  finalStatus.st_dev == status.st_dev,
                  finalStatus.st_ino == status.st_ino,
                  finalStatus.st_size == status.st_size,
                  finalStatus.st_nlink == 1,
                  finalStatus.st_dev == finalPathStatus.st_dev,
                  finalStatus.st_ino == finalPathStatus.st_ino else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "swiftdata_import_export"
                )
            }
            try parentPin.revalidate()
        } catch {
            let operationError = error
            if descriptorOpen {
                guard Darwin.close(descriptor) == 0 else {
                    descriptorOpen = false
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_swiftdata_import_export"
                    )
                }
                descriptorOpen = false
            }
            throw operationError
        }
        guard descriptorOpen, Darwin.close(descriptor) == 0 else {
            descriptorOpen = false
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_swiftdata_import_export"
            )
        }
        descriptorOpen = false
        guard let transportSessionDigest = state.transportSessionDigest else {
            throw RuntimeGenerationControlError.importReviewRequired
        }
        return SwiftDataStreamSummary(
            transportSessionDigest: transportSessionDigest,
            recordCount: state.recordCount,
            recordSetDigest: state.recordSetDigest
        )
    }

    func nextID() -> String {
        environment.uuid.nextUUID().uuidString.lowercased()
    }

    func nowMilliseconds() throws -> Int64 {
        let value = environment.clock.now.timeIntervalSince1970 * 1_000
        guard value.isFinite, value >= 0, value <= Double(Int64.max) else {
            throw RuntimeGenerationControlError.malformed(field: "clock")
        }
        return Int64(value.rounded(.towardZero))
    }
}

#if DEBUG
extension RuntimeGenerationLegacyImportService {
    static func testOnlyAcceptedCanonicalTables(
        for version: RuntimeLegacyCanonicalSchemaVersion
    ) -> Set<String> {
        Set(canonicalTableSpecs(for: version).keys)
    }

    static func testOnlyMapCanonicalSQLiteRecord(
        _ record: RuntimeLegacyDecodedRecord,
        version: RuntimeLegacyCanonicalSchemaVersion
    ) throws -> (family: String, identifier: String, lossiness: RuntimeLegacyImportLossiness)? {
        try mapCanonicalSQLiteRecord(record, schemaVersion: version).map {
            ($0.canonicalFamily, $0.canonicalID, $0.lossiness)
        }
    }
    static func testOnlyValidateSwiftDataRecord(
        _ record: RuntimeSwiftDataImportRecord
    ) throws {
        try validateSwiftDataRecord(record)
    }
}
#endif
