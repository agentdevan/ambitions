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

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func makeID(kind: RuntimeSnapshotLedgerArtifactKind, artifactID: String, envelopeID: String) -> String {
        "runtime_snapshot_reference.\(kind.rawValue).\(artifactID.replacingOccurrences(of: " ", with: "_")).\(envelopeID.replacingOccurrences(of: " ", with: "_"))"
    }
}

struct RuntimeSnapshotLedgerFieldProjection: Codable, Sendable, Equatable, Hashable {
    let fieldName: String
    let redactionClass: RuntimeSnapshotFieldRedactionClass
    let policy: AFEPFieldPolicy
    let visibleValues: [String]
    let redactedValue: String?

    var isRedacted: Bool {
        redactedValue != nil
    }

    var isExportSafe: Bool {
        switch policy.exportPolicy {
        case .safe:
            return redactionClass == .clear && redactedValue == nil
        case .redacted:
            return isRedacted && visibleValues.isEmpty
        case .exportReviewOnly, .blocked:
            return false
        }
    }

    var storagePrivacyClass: AFEPStoragePrivacyClass {
        policy.privacyClass
    }

    var indexingPolicy: AFEPIndexingPolicy {
        policy.indexingPolicy
    }

    var exportPolicy: AFEPExportPolicy {
        policy.exportPolicy
    }

    var measurementEvidenceState: AFEPMeasurementEvidenceState {
        policy.measurementEvidenceState
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
        fields.allSatisfy(\.isExportSafe)
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

enum AFEPStoragePrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicMetadata = "public_metadata"
    case systemOwned = "system_owned"
    case localOnly = "local_only"
    case privateSensitive = "private_sensitive"
    case proofRestricted = "proof_restricted"
    case replayRestricted = "replay_restricted"
    case lineageRestricted = "lineage_restricted"

    var requiresRedaction: Bool {
        switch self {
        case .publicMetadata, .systemOwned:
            return false
        case .localOnly, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted:
            return true
        }
    }
}

enum AFEPIndexingPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case indexed
    case notIndexed = "not_indexed"
}

enum AFEPExportPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safe
    case redacted
    case exportReviewOnly = "export_review_only"
    case blocked

    var isExportSafe: Bool {
        switch self {
        case .safe, .redacted:
            return true
        case .exportReviewOnly, .blocked:
            return false
        }
    }
}

struct AFEPFieldPolicy: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let fieldName: String
    let privacyClass: AFEPStoragePrivacyClass
    let indexingPolicy: AFEPIndexingPolicy
    let exportPolicy: AFEPExportPolicy
    let measurementEvidenceState: AFEPMeasurementEvidenceState
    let notes: String

    init(
        id: String? = nil,
        fieldName: String,
        privacyClass: AFEPStoragePrivacyClass,
        indexingPolicy: AFEPIndexingPolicy = .notIndexed,
        exportPolicy: AFEPExportPolicy = .redacted,
        measurementEvidenceState: AFEPMeasurementEvidenceState = .planned,
        notes: String
    ) {
        self.id = id ?? "afep.field.\(fieldName)"
        self.fieldName = fieldName
        self.privacyClass = privacyClass
        self.indexingPolicy = indexingPolicy
        self.exportPolicy = exportPolicy
        self.measurementEvidenceState = measurementEvidenceState
        self.notes = notes
    }

    var isConservativelyProtected: Bool {
        indexingPolicy == .notIndexed && exportPolicy.isExportSafe
    }
}
