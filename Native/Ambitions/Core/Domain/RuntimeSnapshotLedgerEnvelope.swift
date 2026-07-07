import CryptoKit
import Foundation

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

    var privacyPostureLabel: String {
        switch compatibilityStatus {
        case .current:
            return "Local-only runtime snapshot"
        case .migratedOlder:
            return "Migrated local-only runtime snapshot"
        case .unsupported:
            return "Unsupported snapshot stays review-only"
        }
    }

    var exportPostureLabel: String {
        exportSafeProjection.isExportSafe ? "Export-safe snapshot summary" : "Export review required"
    }

    var provenanceSummaryLabel: String {
        "Checksum \(checksum) · provenance \(provenanceHash)"
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

    static let afepReadBudget = AFEPQueryBudgetDescriptor(
        scope: .runtimeSnapshotLedger,
        maximumReads: 4,
        notes: "Runtime snapshot ledger reads stay local-only and bounded by contract."
    )

    static let afepFieldPolicies: [String: AFEPFieldPolicy] = [
        "sourceRecordIDs": AFEPFieldPolicy(
            fieldName: "sourceRecordIDs",
            privacyClass: .localOnly,
            exportPolicy: .redacted,
            notes: "SourceRecord references remain local-only and are redacted in export review."
        ),
        "receiptIDs": AFEPFieldPolicy(
            fieldName: "receiptIDs",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            notes: "Receipt references are proof-restricted and redacted by default."
        ),
        "replayTraceIDs": AFEPFieldPolicy(
            fieldName: "replayTraceIDs",
            privacyClass: .replayRestricted,
            exportPolicy: .redacted,
            notes: "ReplayTrace references are replay-restricted and redacted by default."
        ),
        "recommendationInputReferenceIDs": AFEPFieldPolicy(
            fieldName: "recommendationInputReferenceIDs",
            privacyClass: .localOnly,
            exportPolicy: .redacted,
            notes: "Recommendation inputs remain local-only and redacted by default."
        ),
        "proofInputReferenceIDs": AFEPFieldPolicy(
            fieldName: "proofInputReferenceIDs",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            notes: "Proof inputs stay proof-restricted and redacted by default."
        ),
        "afep02LineageReferenceIDs": AFEPFieldPolicy(
            fieldName: "afep02LineageReferenceIDs",
            privacyClass: .lineageRestricted,
            exportPolicy: .redacted,
            notes: "Lineage references stay lineage-restricted and redacted by default."
        ),
        "fieldRedactions": AFEPFieldPolicy(
            fieldName: "fieldRedactions",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Redaction classes are policy metadata and remain safe to inspect locally."
        ),
        "checksum": AFEPFieldPolicy(
            fieldName: "checksum",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Checksum supports integrity checks and is not treated as user metadata."
        ),
        "provenanceHash": AFEPFieldPolicy(
            fieldName: "provenanceHash",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Provenance hash supports replay validation and is not treated as user metadata."
        )
    ]

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
