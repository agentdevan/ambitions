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

    private static func versionedID(proofID: String, version: Int) -> String {
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

struct AmbitionGraphProjectionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
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
    let invalidationReason: AmbitionGraphStoreSplitInvalidationReason
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
        previousProjection: AmbitionGraphProjectionRecord? = nil,
        projectionHash: String? = nil,
        checksum: String? = nil,
        invalidationReason: AmbitionGraphStoreSplitInvalidationReason? = nil,
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
        let computedInvalidationReason = invalidationReason ?? Self.invalidationReason(
            previousProjection: previousProjection,
            surface: surface,
            sourceSnapshotID: sourceSnapshotID,
            privacyClass: privacyClass,
            sourceObjectIDs: orderedSourceObjectIDs,
            receiptIDs: orderedReceiptIDs,
            replayTraceIDs: orderedReplayTraceIDs,
            sourceFields: orderedSourceFields,
            projectionHash: computedProjectionHash,
            checksum: computedChecksum
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
        self.invalidationReason = computedInvalidationReason
        self.schemaVersion = schemaVersion
    }

    private static func invalidationReason(
        previousProjection: AmbitionGraphProjectionRecord?,
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String],
        projectionHash: String,
        checksum: String
    ) -> AmbitionGraphStoreSplitInvalidationReason {
        guard let previousProjection else {
            return .initialMaterialization
        }
        if previousProjection.surface != surface {
            return .surfaceChanged
        }
        if previousProjection.sourceSnapshotID != sourceSnapshotID {
            return .sourceSnapshotChanged
        }
        if previousProjection.privacyClass != privacyClass {
            return .privacyChanged
        }
        if previousProjection.sourceObjectIDs != sourceObjectIDs {
            return .sourceObjectIDsChanged
        }
        if previousProjection.receiptIDs != receiptIDs {
            return .receiptIDsChanged
        }
        if previousProjection.replayTraceIDs != replayTraceIDs {
            return .replayTraceIDsChanged
        }
        if previousProjection.sourceFields != sourceFields {
            return .sourceFieldsChanged
        }
        if previousProjection.projectionHash != projectionHash {
            return .projectionHashChanged
        }
        if previousProjection.checksum != checksum {
            return .checksumChanged
        }
        return .unchanged
    }

    static let afepFieldPolicies: [String: AFEPFieldPolicy] = [
        "sourceObjectIDs": AFEPFieldPolicy(
            fieldName: "sourceObjectIDs",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            notes: "Source object identifiers remain non-indexed and redacted by default."
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
        ),
        "invalidationReason": AFEPFieldPolicy(
            fieldName: "invalidationReason",
            privacyClass: .systemOwned,
            indexingPolicy: .notIndexed,
            exportPolicy: .safe,
            notes: "Invalidation reasons are review metadata and stay local-only."
        )
    ]
}

extension AmbitionGraphProjectionStore {
    func operationalRecord(
        for surface: AmbitionGraphProjectionSurface,
        snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        id: String,
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = []
    ) -> AmbitionGraphOperationalRecord {
        let projection = projection(for: surface, from: snapshot, generatedAt: generatedAt, id: id)
        return AmbitionGraphOperationalRecord(
            id: id,
            surface: surface,
            sourceSnapshotID: snapshot.id,
            ambitionID: snapshot.ambition.id,
            generatedAt: generatedAt,
            localProjectionOnly: projection.localProjectionOnly,
            privacyClass: Self.primaryPrivacyClass(
                from: projection.privacyClasses + projection.ambitionPrivacyClasses
            ),
            sourceObjectIDs: projection.sourceObjectIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            sourceFields: projection.sourceFields
        )
    }

    func proofRecord(
        for proof: Proof,
        sourceSnapshotID: String? = nil,
        generatedAt: String,
        version: Int = 1,
        supersedesProofID: String? = nil,
        localProjectionOnly: Bool = true,
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        sourceFields: [String] = []
    ) -> AmbitionGraphProofRecord {
        AmbitionGraphProofRecord(
            proofID: proof.id,
            version: version,
            supersedesProofID: supersedesProofID,
            sourceSnapshotID: sourceSnapshotID,
            ambitionID: proof.ambitionID,
            generatedAt: generatedAt,
            localProjectionOnly: localProjectionOnly,
            privacyClass: proof.privacyClass,
            sourceObjectIDs: [proof.ambitionID, proof.commitmentID, proof.closureEventID].compactMap { $0 },
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            sourceFields: sourceFields
        )
    }

    func projectionRecord(
        for surface: AmbitionGraphProjectionSurface,
        from snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        id: String,
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        previousProjection: AmbitionGraphProjectionRecord? = nil
    ) -> AmbitionGraphProjectionRecord {
        let projection = projection(for: surface, from: snapshot, generatedAt: generatedAt, id: id)
        return AmbitionGraphProjectionRecord(
            id: id,
            surface: surface,
            sourceSnapshotID: snapshot.id,
            ambitionID: snapshot.ambition.id,
            generatedAt: generatedAt,
            localProjectionOnly: projection.localProjectionOnly,
            privacyClass: Self.primaryPrivacyClass(
                from: projection.privacyClasses + projection.ambitionPrivacyClasses
            ),
            sourceObjectIDs: projection.sourceObjectIDs,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            sourceFields: projection.sourceFields,
            previousProjection: previousProjection
        )
    }

    func projectionRecords(
        for snapshot: AmbitionGraphSnapshot,
        generatedAt: String,
        idPrefix: String,
        receiptIDsBySurface: [AmbitionGraphProjectionSurface: [String]] = [:],
        replayTraceIDsBySurface: [AmbitionGraphProjectionSurface: [String]] = [:],
        previousProjectionBySurface: [AmbitionGraphProjectionSurface: AmbitionGraphProjectionRecord] = [:]
    ) -> [AmbitionGraphProjectionRecord] {
        AmbitionGraphProjectionSurface.allCases.map { surface in
            projectionRecord(
                for: surface,
                from: snapshot,
                generatedAt: generatedAt,
                id: "\(idPrefix)-\(surface.rawValue)",
                receiptIDs: receiptIDsBySurface[surface] ?? [],
                replayTraceIDs: replayTraceIDsBySurface[surface] ?? [],
                previousProjection: previousProjectionBySurface[surface]
            )
        }
    }

    func projectionRecord(
        for surface: AmbitionGraphProjectionSurface,
        snapshotID: String,
        generatedAt: String,
        id: String,
        receiptIDs: [String] = [],
        replayTraceIDs: [String] = [],
        previousProjection: AmbitionGraphProjectionRecord? = nil
    ) -> AmbitionGraphProjectionRecord? {
        guard let source = snapshot(by: snapshotID) else {
            return nil
        }
        return projectionRecord(
            for: surface,
            from: source,
            generatedAt: generatedAt,
            id: id,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            previousProjection: previousProjection
        )
    }

    private static func primaryPrivacyClass(from privacyClasses: [AmbitionPrivacyClass]) -> AmbitionPrivacyClass {
        let ranking: [AmbitionPrivacyClass: Int] = [
            .privateProof: 0,
            .privateConstraint: 1,
            .privateUserText: 2,
            .sharedReceipt: 3,
            .systemOwned: 4
        ]
        return privacyClasses
            .sorted {
                let lhs = ranking[$0, default: Int.max]
                let rhs = ranking[$1, default: Int.max]
                if lhs != rhs {
                    return lhs < rhs
                }
                return $0.rawValue < $1.rawValue
            }
            .first ?? .systemOwned
    }
}

private enum AmbitionGraphStoreSplitDigest {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static func digest<Payload: Encodable>(_ payload: Payload) -> String {
        guard let data = try? encoder.encode(payload) else {
            return "sha256:encode_failed"
        }
        return "sha256:\(SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined())"
    }
}

private extension AmbitionGraphOperationalRecord {
    static func makeProjectionHash(
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        ambitionID: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String]
    ) -> String {
        AmbitionGraphStoreSplitDigest.digest(
            ProjectionHashPayload(
                surface: surface,
                sourceSnapshotID: sourceSnapshotID,
                ambitionID: ambitionID,
                localProjectionOnly: localProjectionOnly,
                privacyClass: privacyClass,
                sourceObjectIDs: sourceObjectIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                sourceFields: sourceFields
            )
        )
    }

    static func makeChecksum(
        id: String,
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String],
        projectionHash: String,
        schemaVersion: String
    ) -> String {
        AmbitionGraphStoreSplitDigest.digest(
            ChecksumPayload(
                kind: "operational",
                id: id,
                proofID: nil,
                surface: surface,
                sourceSnapshotID: sourceSnapshotID,
                ambitionID: ambitionID,
                generatedAt: generatedAt,
                localProjectionOnly: localProjectionOnly,
                privacyClass: privacyClass,
                sourceObjectIDs: sourceObjectIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                sourceFields: sourceFields,
                projectionHash: projectionHash,
                version: nil,
                supersedesID: nil,
                invalidationReason: nil,
                schemaVersion: schemaVersion
            )
        )
    }
}

private extension AmbitionGraphProofRecord {
    static func makeChecksum(
        id: String,
        proofID: String,
        version: Int,
        supersedesProofID: String?,
        sourceSnapshotID: String?,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String],
        schemaVersion: String
    ) -> String {
        AmbitionGraphStoreSplitDigest.digest(
            ChecksumPayload(
                kind: "proof",
                id: id,
                proofID: proofID,
                surface: nil,
                sourceSnapshotID: sourceSnapshotID,
                ambitionID: ambitionID,
                generatedAt: generatedAt,
                localProjectionOnly: localProjectionOnly,
                privacyClass: privacyClass,
                sourceObjectIDs: sourceObjectIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                sourceFields: sourceFields,
                projectionHash: nil,
                version: version,
                supersedesID: supersedesProofID,
                invalidationReason: nil,
                schemaVersion: schemaVersion
            )
        )
    }
}

private extension AmbitionGraphProjectionRecord {
    static func makeProjectionHash(
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        ambitionID: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String]
    ) -> String {
        AmbitionGraphStoreSplitDigest.digest(
            ProjectionHashPayload(
                surface: surface,
                sourceSnapshotID: sourceSnapshotID,
                ambitionID: ambitionID,
                localProjectionOnly: localProjectionOnly,
                privacyClass: privacyClass,
                sourceObjectIDs: sourceObjectIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                sourceFields: sourceFields
            )
        )
    }

    static func makeChecksum(
        id: String,
        surface: AmbitionGraphProjectionSurface,
        sourceSnapshotID: String,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClass: AmbitionPrivacyClass,
        sourceObjectIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        sourceFields: [String],
        projectionHash: String,
        schemaVersion: String
    ) -> String {
        AmbitionGraphStoreSplitDigest.digest(
            ChecksumPayload(
                kind: "projection",
                id: id,
                proofID: nil,
                surface: surface,
                sourceSnapshotID: sourceSnapshotID,
                ambitionID: ambitionID,
                generatedAt: generatedAt,
                localProjectionOnly: localProjectionOnly,
                privacyClass: privacyClass,
                sourceObjectIDs: sourceObjectIDs,
                receiptIDs: receiptIDs,
                replayTraceIDs: replayTraceIDs,
                sourceFields: sourceFields,
                projectionHash: projectionHash,
                version: nil,
                supersedesID: nil,
                invalidationReason: nil,
                schemaVersion: schemaVersion
            )
        )
    }
}

private struct ProjectionHashPayload: Codable, Sendable, Equatable, Hashable {
    let surface: AmbitionGraphProjectionSurface
    let sourceSnapshotID: String
    let ambitionID: String
    let localProjectionOnly: Bool
    let privacyClass: AmbitionPrivacyClass
    let sourceObjectIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let sourceFields: [String]
}

private struct ChecksumPayload: Codable, Sendable, Equatable, Hashable {
    let kind: String
    let id: String
    let proofID: String?
    let surface: AmbitionGraphProjectionSurface?
    let sourceSnapshotID: String?
    let ambitionID: String
    let generatedAt: String
    let localProjectionOnly: Bool
    let privacyClass: AmbitionPrivacyClass
    let sourceObjectIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let sourceFields: [String]
    let projectionHash: String?
    let version: Int?
    let supersedesID: String?
    let invalidationReason: AmbitionGraphStoreSplitInvalidationReason?
    let schemaVersion: String
}
