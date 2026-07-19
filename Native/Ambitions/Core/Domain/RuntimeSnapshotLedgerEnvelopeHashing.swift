import CryptoKit
import Foundation

extension RuntimeSnapshotLedgerEnvelope {
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
        let policy = RuntimeSnapshotLedgerEnvelope.afepFieldPolicies[fieldName] ?? AFEPFieldPolicy(
            fieldName: fieldName,
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Conservative default: this field stays non-indexed and redacted unless a policy explicitly allows more."
        )
        let requestedRedactionClass = redactionByField[fieldName] ?? .redacted
        if policy.exportPolicy == .safe, requestedRedactionClass == .clear {
            return RuntimeSnapshotLedgerFieldProjection(
                fieldName: fieldName,
                redactionClass: requestedRedactionClass,
                policy: policy,
                visibleValues: values,
                redactedValue: nil
            )
        }
        return RuntimeSnapshotLedgerFieldProjection(
            fieldName: fieldName,
            redactionClass: requestedRedactionClass == .clear ? .redacted : requestedRedactionClass,
            policy: policy,
            visibleValues: [],
            redactedValue: "[redacted]"
        )
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
