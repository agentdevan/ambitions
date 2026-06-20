import CryptoKit
import Foundation

extension AmbitionGraphOperationalRecord {
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

extension AmbitionGraphProofRecord {
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

extension AmbitionGraphProjectionRecord {
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

struct ProjectionHashPayload: Codable, Sendable, Equatable, Hashable {
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

struct ChecksumPayload: Codable, Sendable, Equatable, Hashable {
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
