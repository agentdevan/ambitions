import CryptoKit
import Foundation

let runtimeSnapshotLedgerSchemaVersion = "runtime_snapshot_ledger.native.v1"
let runtimeSnapshotLedgerLegacySchemaVersion = "runtime_snapshot_ledger.native.v0"

enum RuntimeSnapshotLedgerCompatibilityStatus: String, Codable, Sendable, Equatable, Hashable {
    case current
    case migratedOlder = "migrated_older"
    case unsupported
}

enum RuntimeSnapshotLedgerArtifactKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceRecord = "source_record"
    case receipt
    case replayTrace = "replay_trace"
    case recommendationInput = "recommendation_input"
    case proofInput = "proof_input"
    case lineageReference = "lineage_reference"
}

enum RuntimeSnapshotFieldRedactionClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case clear
    case localOnly = "local_only"
    case proofRestricted = "proof_restricted"
    case replayRestricted = "replay_restricted"
    case lineageRestricted = "lineage_restricted"
    case redacted
}

struct RuntimeSnapshotLedgerFieldRedaction: Codable, Sendable, Equatable, Hashable {
    let fieldName: String
    let redactionClass: RuntimeSnapshotFieldRedactionClass

    init(fieldName: String, redactionClass: RuntimeSnapshotFieldRedactionClass) {
        self.fieldName = fieldName
        self.redactionClass = redactionClass
    }
}

struct RuntimeSnapshotLedgerArtifactReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RuntimeSnapshotLedgerArtifactKind
    let artifactID: String
    let envelopeID: String
    let envelopeChecksum: String?

    init(
        kind: RuntimeSnapshotLedgerArtifactKind,
        artifactID: String,
        envelopeID: String,
        envelopeChecksum: String? = nil
    ) {
        self.kind = kind
        self.artifactID = artifactID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.envelopeID = envelopeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.envelopeChecksum = Self.normalizedOptional(envelopeChecksum)
        self.id = Self.makeID(kind: kind, artifactID: self.artifactID, envelopeID: self.envelopeID)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func makeID(kind: RuntimeSnapshotLedgerArtifactKind, artifactID: String, envelopeID: String) -> String {
        "runtime_snapshot_reference.\(kind.rawValue).\(artifactID.replacingOccurrences(of: " ", with: "_")).\(envelopeID.replacingOccurrences(of: " ", with: "_"))"
    }
}

struct RuntimeSnapshotLedgerFieldProjection: Codable, Sendable, Equatable, Hashable {
    let fieldName: String
    let redactionClass: RuntimeSnapshotFieldRedactionClass
    let visibleValues: [String]
    let redactedValue: String?

    var isRedacted: Bool {
        redactedValue != nil
    }
}

struct RuntimeSnapshotLedgerExportProjection: Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus
    let checksum: String
    let provenanceHash: String
    let fields: [RuntimeSnapshotLedgerFieldProjection]
    let summary: String

    var isExportSafe: Bool {
        fields.allSatisfy { $0.isRedacted || $0.redactionClass == .clear }
    }
}

enum RuntimeSnapshotLedgerReplayValidationOutcome: String, Codable, Sendable, Equatable, Hashable {
    case valid
    case missingEnvelope = "missing_envelope"
    case unsupportedEnvelope = "unsupported_envelope"
    case checksumMismatch = "checksum_mismatch"
    case ambiguousEnvelope = "ambiguous_envelope"
}

struct RuntimeSnapshotLedgerReplayValidationReport: Codable, Sendable, Equatable, Hashable {
    let reference: RuntimeSnapshotLedgerArtifactReference
    let outcome: RuntimeSnapshotLedgerReplayValidationOutcome
    let envelopeID: String?
    let envelopeSchemaVersion: String?
    let compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus?
    let matchedEnvelopeCount: Int
    let observedChecksum: String?
    let expectedChecksum: String?
    let message: String

    var isValid: Bool {
        outcome == .valid
    }
}

struct RuntimeSnapshotLedgerEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let recommendationInputReferenceIDs: [String]
    let proofInputReferenceIDs: [String]
    let afep02LineageReferenceIDs: [String]
    let fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction]
    let compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus
    let checksum: String
    let provenanceHash: String

    init(
        id: String? = nil,
        schemaVersion: String = runtimeSnapshotLedgerSchemaVersion,
        generatedAt: String,
        sourceRecordIDs: [String] = [],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        recommendationInputReferenceIDs: [String] = [],
        proofInputReferenceIDs: [String] = [],
        afep02LineageReferenceIDs: [String] = [],
        fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction]? = nil
    ) {
        let normalizedGeneratedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSourceRecordIDs = Self.normalized(sourceRecordIDs)
        let normalizedReceiptIDs = Self.normalized(receiptIDs)
        let normalizedReplayTraceIDs = Self.normalized(replayTraceIDs)
        let normalizedRecommendationInputReferenceIDs = Self.normalized(recommendationInputReferenceIDs)
        let normalizedProofInputReferenceIDs = Self.normalized(proofInputReferenceIDs)
        let normalizedAFEP02LineageReferenceIDs = Self.normalized(afep02LineageReferenceIDs)
        let normalizedFieldRedactions = Self.normalized(fieldRedactions ?? Self.defaultFieldRedactions)

        let computedID = Self.makeID(
            generatedAt: normalizedGeneratedAt,
            sourceRecordIDs: normalizedSourceRecordIDs,
            receiptIDs: normalizedReceiptIDs,
            replayTraceIDs: normalizedReplayTraceIDs,
            recommendationInputReferenceIDs: normalizedRecommendationInputReferenceIDs,
            proofInputReferenceIDs: normalizedProofInputReferenceIDs,
            afep02LineageReferenceIDs: normalizedAFEP02LineageReferenceIDs,
            fieldRedactions: normalizedFieldRedactions,
            schemaVersion: schemaVersion
        )
        let normalizedID = id?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = (normalizedID?.isEmpty == false ? normalizedID : nil) ?? computedID
        self.schemaVersion = schemaVersion
        self.generatedAt = normalizedGeneratedAt
        self.sourceRecordIDs = normalizedSourceRecordIDs
        self.receiptIDs = normalizedReceiptIDs
        self.replayTraceIDs = normalizedReplayTraceIDs
        self.recommendationInputReferenceIDs = normalizedRecommendationInputReferenceIDs
        self.proofInputReferenceIDs = normalizedProofInputReferenceIDs
        self.afep02LineageReferenceIDs = normalizedAFEP02LineageReferenceIDs
        self.fieldRedactions = normalizedFieldRedactions
        self.compatibilityStatus = Self.compatibilityStatus(for: schemaVersion)
        self.checksum = Self.checksum(
            schemaVersion: schemaVersion,
            generatedAt: normalizedGeneratedAt,
            sourceRecordIDs: normalizedSourceRecordIDs,
            receiptIDs: normalizedReceiptIDs,
            replayTraceIDs: normalizedReplayTraceIDs,
            recommendationInputReferenceIDs: normalizedRecommendationInputReferenceIDs,
            proofInputReferenceIDs: normalizedProofInputReferenceIDs,
            afep02LineageReferenceIDs: normalizedAFEP02LineageReferenceIDs,
            fieldRedactions: normalizedFieldRedactions,
            compatibilityStatus: self.compatibilityStatus
        )
        self.provenanceHash = Self.provenanceHash(
            sourceRecordIDs: normalizedSourceRecordIDs,
            receiptIDs: normalizedReceiptIDs,
            replayTraceIDs: normalizedReplayTraceIDs,
            recommendationInputReferenceIDs: normalizedRecommendationInputReferenceIDs,
            proofInputReferenceIDs: normalizedProofInputReferenceIDs,
            afep02LineageReferenceIDs: normalizedAFEP02LineageReferenceIDs,
            fieldRedactions: normalizedFieldRedactions,
            compatibilityStatus: self.compatibilityStatus,
            checksum: self.checksum
        )
    }

    var isSupported: Bool {
        compatibilityStatus != .unsupported
    }

    var isCurrentVersion: Bool {
        schemaVersion == runtimeSnapshotLedgerSchemaVersion
    }

    var exportSafeProjection: RuntimeSnapshotLedgerExportProjection {
        RuntimeSnapshotLedgerExportProjection(
            id: id,
            schemaVersion: schemaVersion,
            generatedAt: generatedAt,
            compatibilityStatus: compatibilityStatus,
            checksum: checksum,
            provenanceHash: provenanceHash,
            fields: Self.exportSafeFields(
                sourceRecordIDs: sourceRecordIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                recommendationInputReferenceIDs: recommendationInputReferenceIDs,
                proofInputReferenceIDs: proofInputReferenceIDs,
                afep02LineageReferenceIDs: afep02LineageReferenceIDs,
                fieldRedactions: fieldRedactions
            ),
            summary: "Runtime snapshot ledger envelope \(id) is \(compatibilityStatus.rawValue) and export-safe for local review."
        )
    }

    func references(for kind: RuntimeSnapshotLedgerArtifactKind) -> [RuntimeSnapshotLedgerArtifactReference] {
        switch kind {
        case .sourceRecord:
            return sourceRecordIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        case .receipt:
            return receiptIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        case .replayTrace:
            return replayTraceIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        case .recommendationInput:
            return recommendationInputReferenceIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        case .proofInput:
            return proofInputReferenceIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        case .lineageReference:
            return afep02LineageReferenceIDs.map { RuntimeSnapshotLedgerArtifactReference(kind: kind, artifactID: $0, envelopeID: id, envelopeChecksum: checksum) }
        }
    }

    func validate(reference: RuntimeSnapshotLedgerArtifactReference) -> RuntimeSnapshotLedgerReplayValidationReport {
        if reference.envelopeID.isEmpty == false, reference.envelopeID != id {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .missingEnvelope,
                envelopeID: nil,
                envelopeSchemaVersion: nil,
                compatibilityStatus: nil,
                matchedEnvelopeCount: 0,
                observedChecksum: nil,
                expectedChecksum: reference.envelopeChecksum,
                message: "No runtime snapshot envelope matched reference \(reference.artifactID)."
            )
        }

        guard references(for: reference.kind).contains(where: { $0.artifactID == reference.artifactID }) else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .missingEnvelope,
                envelopeID: id,
                envelopeSchemaVersion: schemaVersion,
                compatibilityStatus: compatibilityStatus,
                matchedEnvelopeCount: 1,
                observedChecksum: checksum,
                expectedChecksum: reference.envelopeChecksum,
                message: "Envelope \(id) does not contain reference \(reference.artifactID)."
            )
        }

        guard isSupported else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .unsupportedEnvelope,
                envelopeID: id,
                envelopeSchemaVersion: schemaVersion,
                compatibilityStatus: compatibilityStatus,
                matchedEnvelopeCount: 1,
                observedChecksum: checksum,
                expectedChecksum: reference.envelopeChecksum,
                message: "Envelope \(id) uses unsupported schema version \(schemaVersion)."
            )
        }

        guard let expectedChecksum = reference.envelopeChecksum else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .valid,
                envelopeID: id,
                envelopeSchemaVersion: schemaVersion,
                compatibilityStatus: compatibilityStatus,
                matchedEnvelopeCount: 1,
                observedChecksum: checksum,
                expectedChecksum: nil,
                message: "Envelope \(id) matched reference \(reference.artifactID)."
            )
        }

        guard expectedChecksum == checksum else {
            return RuntimeSnapshotLedgerReplayValidationReport(
                reference: reference,
                outcome: .checksumMismatch,
                envelopeID: id,
                envelopeSchemaVersion: schemaVersion,
                compatibilityStatus: compatibilityStatus,
                matchedEnvelopeCount: 1,
                observedChecksum: checksum,
                expectedChecksum: expectedChecksum,
                message: "Envelope \(id) checksum mismatch for reference \(reference.artifactID)."
            )
        }

        return RuntimeSnapshotLedgerReplayValidationReport(
            reference: reference,
            outcome: .valid,
            envelopeID: id,
            envelopeSchemaVersion: schemaVersion,
            compatibilityStatus: compatibilityStatus,
            matchedEnvelopeCount: 1,
            observedChecksum: checksum,
            expectedChecksum: expectedChecksum,
            message: "Envelope \(id) matched reference \(reference.artifactID)."
        )
    }
}

private extension RuntimeSnapshotLedgerEnvelope {
    struct CanonicalPayload: Codable, Sendable, Equatable, Hashable {
        let schemaVersion: String
        let generatedAt: String
        let sourceRecordIDs: [String]
        let receiptIDs: [String]
        let replayTraceIDs: [String]
        let recommendationInputReferenceIDs: [String]
        let proofInputReferenceIDs: [String]
        let afep02LineageReferenceIDs: [String]
        let fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction]
        let compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus
    }

    static let defaultFieldRedactions: [RuntimeSnapshotLedgerFieldRedaction] = [
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "sourceRecordIDs", redactionClass: .localOnly),
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "receiptIDs", redactionClass: .localOnly),
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "replayTraceIDs", redactionClass: .replayRestricted),
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "recommendationInputReferenceIDs", redactionClass: .localOnly),
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "proofInputReferenceIDs", redactionClass: .proofRestricted),
        RuntimeSnapshotLedgerFieldRedaction(fieldName: "afep02LineageReferenceIDs", redactionClass: .lineageRestricted)
    ]

    static func compatibilityStatus(for schemaVersion: String) -> RuntimeSnapshotLedgerCompatibilityStatus {
        switch schemaVersion {
        case runtimeSnapshotLedgerSchemaVersion:
            return .current
        case runtimeSnapshotLedgerLegacySchemaVersion:
            return .migratedOlder
        default:
            return .unsupported
        }
    }

    static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }

    static func normalized(_ values: [RuntimeSnapshotLedgerFieldRedaction]) -> [RuntimeSnapshotLedgerFieldRedaction] {
        Array(
            Dictionary(
                grouping: values,
                by: { $0.fieldName.trimmingCharacters(in: .whitespacesAndNewlines) }
            )
            .compactMap { key, grouped in
                guard key.isEmpty == false else { return nil }
                let redactionClass = grouped.last?.redactionClass ?? .redacted
                return RuntimeSnapshotLedgerFieldRedaction(fieldName: key, redactionClass: redactionClass)
            }
            .sorted { $0.fieldName < $1.fieldName }
        )
    }

    static func makeID(
        generatedAt: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        recommendationInputReferenceIDs: [String],
        proofInputReferenceIDs: [String],
        afep02LineageReferenceIDs: [String],
        fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction],
        schemaVersion: String
    ) -> String {
        let payload = CanonicalPayload(
            schemaVersion: schemaVersion,
            generatedAt: generatedAt,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            recommendationInputReferenceIDs: recommendationInputReferenceIDs,
            proofInputReferenceIDs: proofInputReferenceIDs,
            afep02LineageReferenceIDs: afep02LineageReferenceIDs,
            fieldRedactions: fieldRedactions,
            compatibilityStatus: compatibilityStatus(for: schemaVersion)
        )
        return "runtime_snapshot.\(sha256Hex(of: payload))"
    }

    static func checksum(
        schemaVersion: String,
        generatedAt: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        recommendationInputReferenceIDs: [String],
        proofInputReferenceIDs: [String],
        afep02LineageReferenceIDs: [String],
        fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction],
        compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus
    ) -> String {
        sha256Hex(of: CanonicalPayload(
            schemaVersion: schemaVersion,
            generatedAt: generatedAt,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            recommendationInputReferenceIDs: recommendationInputReferenceIDs,
            proofInputReferenceIDs: proofInputReferenceIDs,
            afep02LineageReferenceIDs: afep02LineageReferenceIDs,
            fieldRedactions: fieldRedactions,
            compatibilityStatus: compatibilityStatus
        ))
    }

    static func provenanceHash(
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        recommendationInputReferenceIDs: [String],
        proofInputReferenceIDs: [String],
        afep02LineageReferenceIDs: [String],
        fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction],
        compatibilityStatus: RuntimeSnapshotLedgerCompatibilityStatus,
        checksum: String
    ) -> String {
        sha256Hex(of: CanonicalPayload(
            schemaVersion: "\(compatibilityStatus.rawValue).provenance",
            generatedAt: checksum,
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            recommendationInputReferenceIDs: recommendationInputReferenceIDs,
            proofInputReferenceIDs: proofInputReferenceIDs,
            afep02LineageReferenceIDs: afep02LineageReferenceIDs,
            fieldRedactions: fieldRedactions,
            compatibilityStatus: compatibilityStatus
        ))
    }

    static func exportSafeFields(
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        recommendationInputReferenceIDs: [String],
        proofInputReferenceIDs: [String],
        afep02LineageReferenceIDs: [String],
        fieldRedactions: [RuntimeSnapshotLedgerFieldRedaction]
    ) -> [RuntimeSnapshotLedgerFieldProjection] {
        let redactionByField = Dictionary(uniqueKeysWithValues: fieldRedactions.map { ($0.fieldName, $0.redactionClass) })

        return [
            Self.makeProjection(fieldName: "sourceRecordIDs", values: sourceRecordIDs, redactionByField: redactionByField),
            Self.makeProjection(fieldName: "receiptIDs", values: receiptIDs, redactionByField: redactionByField),
            Self.makeProjection(fieldName: "replayTraceIDs", values: replayTraceIDs, redactionByField: redactionByField),
            Self.makeProjection(fieldName: "recommendationInputReferenceIDs", values: recommendationInputReferenceIDs, redactionByField: redactionByField),
            Self.makeProjection(fieldName: "proofInputReferenceIDs", values: proofInputReferenceIDs, redactionByField: redactionByField),
            Self.makeProjection(fieldName: "afep02LineageReferenceIDs", values: afep02LineageReferenceIDs, redactionByField: redactionByField)
        ]
    }

    static func makeProjection(
        fieldName: String,
        values: [String],
        redactionByField: [String: RuntimeSnapshotFieldRedactionClass]
    ) -> RuntimeSnapshotLedgerFieldProjection {
        let redactionClass = redactionByField[fieldName] ?? .redacted
        switch redactionClass {
        case .clear:
            return RuntimeSnapshotLedgerFieldProjection(
                fieldName: fieldName,
                redactionClass: redactionClass,
                visibleValues: values,
                redactedValue: nil
            )
        default:
            return RuntimeSnapshotLedgerFieldProjection(
                fieldName: fieldName,
                redactionClass: redactionClass,
                visibleValues: [],
                redactedValue: "[redacted]"
            )
        }
    }

    static func sha256Hex<Value: Encodable>(of value: Value) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            return "sha256:encode_failed"
        }
        return "sha256:\(SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined())"
    }
}
