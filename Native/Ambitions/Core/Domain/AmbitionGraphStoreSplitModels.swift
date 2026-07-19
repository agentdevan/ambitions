import CryptoKit
import Foundation

let ambitionGraphStoreSplitSchemaVersion = "ambition_graph_store_split.native.v1"

enum AmbitionGraphStoreSplitInvalidationReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case initialMaterialization = "initial_materialization"
    case unchanged
    case sourceSnapshotChanged = "source_snapshot_changed"
    case surfaceChanged = "surface_changed"
    case privacyChanged = "privacy_changed"
    case sourceObjectIDsChanged = "source_object_ids_changed"
    case receiptIDsChanged = "receipt_ids_changed"
    case replayTraceIDsChanged = "replay_trace_ids_changed"
    case sourceFieldsChanged = "source_fields_changed"
    case projectionHashChanged = "projection_hash_changed"
    case checksumChanged = "checksum_changed"
}

struct AmbitionGraphOperationalRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: AmbitionGraphProjectionSurface
    let sourceSnapshotID: String
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClass: AmbitionPrivacyClass
    let sourceObjectIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let sourceFields: [String]
    let projectionHash: String
    let checksum: String
    let schemaVersion: String

    init(
        id: String,
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        sourceFields: [String] = [],
        projectionHash: String? = nil,
        checksum: String? = nil,
        schemaVersion: String = ambitionGraphStoreSplitSchemaVersion
    ) {
        let orderedSourceObjectIDs = AmbitionGraphProjectionSnapshot.orderedUnique(sourceObjectIDs)
        let orderedReceiptIDs = AmbitionGraphProjectionSnapshot.orderedUnique(receiptIDs)
        let orderedReplayTraceIDs = AmbitionGraphProjectionSnapshot.orderedUnique(replayTraceIDs)
        let orderedSourceFields = AmbitionGraphProjectionSnapshot.orderedUnique(sourceFields)
        let computedProjectionHash = projectionHash ?? Self.makeProjectionHash(
            surface: surface,
            sourceSnapshotID: sourceSnapshotID,
            ambitionID: ambitionID,
            localProjectionOnly: localProjectionOnly,
            privacyClass: privacyClass,
            sourceObjectIDs: orderedSourceObjectIDs,
            receiptIDs: orderedReceiptIDs,
            replayTraceIDs: orderedReplayTraceIDs,
            sourceFields: orderedSourceFields
        )
        let computedChecksum = checksum ?? Self.makeChecksum(
            id: id,
            surface: surface,
            sourceSnapshotID: sourceSnapshotID,
            ambitionID: ambitionID,
            generatedAt: generatedAt,
            localProjectionOnly: localProjectionOnly,
            privacyClass: privacyClass,
            sourceObjectIDs: orderedSourceObjectIDs,
            receiptIDs: orderedReceiptIDs,
            replayTraceIDs: orderedReplayTraceIDs,
            sourceFields: orderedSourceFields,
            projectionHash: computedProjectionHash,
            schemaVersion: schemaVersion
        )
        self.id = id
        self.surface = surface
        self.sourceSnapshotID = sourceSnapshotID
        self.ambitionID = ambitionID
        self.generatedAt = generatedAt
        self.localProjectionOnly = localProjectionOnly
        self.privacyClass = privacyClass
        self.sourceObjectIDs = orderedSourceObjectIDs
        self.receiptIDs = orderedReceiptIDs
        self.replayTraceIDs = orderedReplayTraceIDs
        self.sourceFields = orderedSourceFields
        self.projectionHash = computedProjectionHash
        self.checksum = computedChecksum
        self.schemaVersion = schemaVersion
    }

    var sourceRecordIDs: [String] {
        sourceObjectIDs
    }

    static let afepFieldPolicies: [String: AFEPFieldPolicy] = [
        "sourceObjectIDs": AFEPFieldPolicy(
            fieldName: "sourceObjectIDs",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Source object identifiers are non-indexed and redacted by default."
        ),
        "receiptIDs": AFEPFieldPolicy(
            fieldName: "receiptIDs",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            notes: "Receipt references remain proof-restricted and redacted by default."
        ),
        "replayTraceIDs": AFEPFieldPolicy(
            fieldName: "replayTraceIDs",
            privacyClass: .replayRestricted,
            exportPolicy: .redacted,
            notes: "Replay trace references remain replay-restricted and redacted by default."
        ),
        "sourceFields": AFEPFieldPolicy(
            fieldName: "sourceFields",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Source field names are non-indexed and redacted by default."
        ),
        "projectionHash": AFEPFieldPolicy(
            fieldName: "projectionHash",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Projection hashes are integrity metadata and stay local-only."
        ),
        "checksum": AFEPFieldPolicy(
            fieldName: "checksum",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Checksums are integrity metadata and stay local-only."
        )
    ]
}

struct AmbitionGraphProofRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let proofID: String
    let version: Int
    let supersedesProofID: String?
    let sourceSnapshotID: String?
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClass: AmbitionPrivacyClass
    let sourceObjectIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let sourceFields: [String]
    let checksum: String
    let schemaVersion: String

    init(
        id: String? = nil,
        proofID: String,
        version: Int = 1,
        supersedesProofID: String? = nil,
        sourceSnapshotID: String? = nil,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        sourceFields: [String] = [],
        checksum: String? = nil,
        schemaVersion: String = ambitionGraphStoreSplitSchemaVersion
    ) {
        let normalizedVersion = max(1, version)
        let computedID = id ?? Self.versionedID(proofID: proofID, version: normalizedVersion)
        let orderedSourceObjectIDs = AmbitionGraphProjectionSnapshot.orderedUnique(sourceObjectIDs)
        let orderedReceiptIDs = AmbitionGraphProjectionSnapshot.orderedUnique(receiptIDs)
        let orderedReplayTraceIDs = AmbitionGraphProjectionSnapshot.orderedUnique(replayTraceIDs)
        let orderedSourceFields = AmbitionGraphProjectionSnapshot.orderedUnique(sourceFields)
        let computedChecksum = checksum ?? Self.makeChecksum(
            id: computedID,
            proofID: proofID,
            version: normalizedVersion,
            supersedesProofID: supersedesProofID,
            sourceSnapshotID: sourceSnapshotID,
            ambitionID: ambitionID,
            generatedAt: generatedAt,
            localProjectionOnly: localProjectionOnly,
            privacyClass: privacyClass,
            sourceObjectIDs: orderedSourceObjectIDs,
            receiptIDs: orderedReceiptIDs,
            replayTraceIDs: orderedReplayTraceIDs,
            sourceFields: orderedSourceFields,
            schemaVersion: schemaVersion
        )
        self.id = computedID
        self.proofID = proofID
        self.version = normalizedVersion
        self.supersedesProofID = supersedesProofID
        self.sourceSnapshotID = sourceSnapshotID
        self.ambitionID = ambitionID
        self.generatedAt = generatedAt
        self.localProjectionOnly = localProjectionOnly
        self.privacyClass = privacyClass
        self.sourceObjectIDs = orderedSourceObjectIDs
        self.receiptIDs = orderedReceiptIDs
        self.replayTraceIDs = orderedReplayTraceIDs
        self.sourceFields = orderedSourceFields
        self.checksum = computedChecksum
        self.schemaVersion = schemaVersion
    }

    func versioned(nextVersion: Int, supersedesProofID: String?) -> AmbitionGraphProofRecord {
        AmbitionGraphProofRecord(
            proofID: proofID,
            version: nextVersion,
            supersedesProofID: supersedesProofID,
            sourceSnapshotID: sourceSnapshotID,
            ambitionID: ambitionID,
            generatedAt: generatedAt,
            localProjectionOnly: localProjectionOnly,
            privacyClass: privacyClass,
            sourceObjectIDs: sourceObjectIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            sourceFields: sourceFields,
            schemaVersion: schemaVersion
        )
    }

    static func versionedID(proofID: String, version: Int) -> String {
        "\(proofID).v\(max(1, version))"
    }

    static let afepFieldPolicies: [String: AFEPFieldPolicy] = [
        "proofID": AFEPFieldPolicy(
            fieldName: "proofID",
            privacyClass: .systemOwned,
            indexingPolicy: .indexed,
            exportPolicy: .safe,
            notes: "Proof identifiers are safe to index for local lookup."
        ),
        "supersedesProofID": AFEPFieldPolicy(
            fieldName: "supersedesProofID",
            privacyClass: .lineageRestricted,
            exportPolicy: .redacted,
            notes: "Proof supersession lineage remains redacted by default."
        ),
        "sourceSnapshotID": AFEPFieldPolicy(
            fieldName: "sourceSnapshotID",
            privacyClass: .lineageRestricted,
            exportPolicy: .redacted,
            notes: "Source snapshot references stay lineage-restricted."
        ),
        "sourceObjectIDs": AFEPFieldPolicy(
            fieldName: "sourceObjectIDs",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Source object identifiers are non-indexed and redacted by default."
        ),
        "receiptIDs": AFEPFieldPolicy(
            fieldName: "receiptIDs",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            notes: "Receipt references remain proof-restricted and redacted by default."
        ),
        "replayTraceIDs": AFEPFieldPolicy(
            fieldName: "replayTraceIDs",
            privacyClass: .replayRestricted,
            exportPolicy: .redacted,
            notes: "Replay trace references remain replay-restricted and redacted by default."
        ),
        "sourceFields": AFEPFieldPolicy(
            fieldName: "sourceFields",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Source field names are non-indexed and redacted by default."
        ),
        "checksum": AFEPFieldPolicy(
            fieldName: "checksum",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Checksums are integrity metadata and stay local-only."
        )
    ]
}
