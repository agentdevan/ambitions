import Foundation

let runtimeTrustLineageSchemaVersion = "runtime_trust_lineage.native.v1"

struct RuntimeTrustLineage: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let runtimeCommitReceiptID: String
    let runtimeTransactionID: String
    let runtimeEventID: String
    let runtimeReceiptID: String
    let runtimeProofArtifactID: String
    let runtimeRollbackPlanID: String
    let runtimeReplayTraceID: String
    let runtimeCommandID: String
    let runtimeEventSequence: Int64
    let runtimeEventChecksum: String
    let projectionCursorIDs: [String]
    let projectionCursorChecksums: [String]
    let affectedObjectIDs: [String]
    let objectFamilies: [ObjectStateFamily]
    let committedAt: String
    let checksum: String
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String? = nil,
        runtimeCommitReceiptID: String,
        runtimeTransactionID: String,
        runtimeEventID: String,
        runtimeReceiptID: String,
        runtimeProofArtifactID: String,
        runtimeRollbackPlanID: String,
        runtimeReplayTraceID: String,
        runtimeCommandID: String,
        runtimeEventSequence: Int64,
        runtimeEventChecksum: String,
        projectionCursorIDs: [String],
        projectionCursorChecksums: [String],
        affectedObjectIDs: [String],
        objectFamilies: [ObjectStateFamily],
        committedAt: String,
        checksum: String? = nil,
        localOnly: Bool,
        schemaVersion: String = runtimeTrustLineageSchemaVersion
    ) {
        self.runtimeCommitReceiptID = Self.normalized(runtimeCommitReceiptID)
        self.runtimeTransactionID = Self.normalized(runtimeTransactionID)
        self.runtimeEventID = Self.normalized(runtimeEventID)
        self.runtimeReceiptID = Self.normalized(runtimeReceiptID)
        self.runtimeProofArtifactID = Self.normalized(runtimeProofArtifactID)
        self.runtimeRollbackPlanID = Self.normalized(runtimeRollbackPlanID)
        self.runtimeReplayTraceID = Self.normalized(runtimeReplayTraceID)
        self.runtimeCommandID = Self.normalized(runtimeCommandID)
        self.runtimeEventSequence = max(0, runtimeEventSequence)
        self.runtimeEventChecksum = Self.normalized(runtimeEventChecksum)
        self.projectionCursorIDs = Self.orderedUnique(projectionCursorIDs)
        self.projectionCursorChecksums = Self.orderedUnique(projectionCursorChecksums)
        self.affectedObjectIDs = Self.orderedUnique(affectedObjectIDs)
        self.objectFamilies = Array(Set(objectFamilies)).sorted { $0.rawValue < $1.rawValue }
        self.committedAt = Self.normalized(committedAt)
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
        self.id = Self.normalized(id ?? "runtime.trust-lineage.\(self.runtimeCommitReceiptID)")
        self.checksum = checksum ?? RuntimeTransactionDigest.digest([
            self.id,
            self.runtimeCommitReceiptID,
            self.runtimeTransactionID,
            self.runtimeEventID,
            self.runtimeReceiptID,
            self.runtimeProofArtifactID,
            self.runtimeRollbackPlanID,
            self.runtimeReplayTraceID,
            self.runtimeCommandID,
            String(self.runtimeEventSequence),
            self.runtimeEventChecksum,
            self.projectionCursorIDs.joined(separator: ","),
            self.projectionCursorChecksums.joined(separator: ","),
            self.affectedObjectIDs.joined(separator: ","),
            self.objectFamilies.map(\.rawValue).joined(separator: ","),
            self.committedAt,
            String(self.localOnly),
            self.schemaVersion,
        ])
    }

    init(runtimeCommitReceipt: RuntimeCommitReceipt) {
        self.init(
            runtimeCommitReceiptID: runtimeCommitReceipt.id,
            runtimeTransactionID: runtimeCommitReceipt.transactionID,
            runtimeEventID: runtimeCommitReceipt.eventID,
            runtimeReceiptID: runtimeCommitReceipt.receiptID,
            runtimeProofArtifactID: runtimeCommitReceipt.proofArtifactID,
            runtimeRollbackPlanID: runtimeCommitReceipt.rollbackPlanID,
            runtimeReplayTraceID: runtimeCommitReceipt.replayTraceID,
            runtimeCommandID: runtimeCommitReceipt.commandID,
            runtimeEventSequence: runtimeCommitReceipt.eventCursor.sequence,
            runtimeEventChecksum: runtimeCommitReceipt.eventCursor.checksum,
            projectionCursorIDs: runtimeCommitReceipt.projectionCursors.map(\.projectionID.rawValue),
            projectionCursorChecksums: runtimeCommitReceipt.projectionCursors.map(\.checksum),
            affectedObjectIDs: runtimeCommitReceipt.affectedObjectIDs,
            objectFamilies: runtimeCommitReceipt.objectFamilies,
            committedAt: runtimeCommitReceipt.committedAt,
            checksum: runtimeCommitReceipt.checksum,
            localOnly: runtimeCommitReceipt.localOnly && runtimeCommitReceipt.hasReplayableProof
        )
    }

    var hasCompleteTrustTrace: Bool {
        id.isEmpty == false &&
            runtimeCommitReceiptID.isEmpty == false &&
            runtimeTransactionID.isEmpty == false &&
            runtimeEventID.isEmpty == false &&
            runtimeReceiptID.isEmpty == false &&
            runtimeProofArtifactID.isEmpty == false &&
            runtimeRollbackPlanID.isEmpty == false &&
            runtimeReplayTraceID.isEmpty == false &&
            runtimeCommandID.isEmpty == false &&
            runtimeEventSequence > 0 &&
            runtimeEventChecksum.isEmpty == false &&
            projectionCursorIDs.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            committedAt.isEmpty == false &&
            checksum.isEmpty == false &&
            localOnly
    }

    var metadata: [String: String] {
        [
            "runtimeTrustLineageID": id,
            "runtimeCommitReceiptID": runtimeCommitReceiptID,
            "runtimeTransactionID": runtimeTransactionID,
            "runtimeEventID": runtimeEventID,
            "runtimeReceiptID": runtimeReceiptID,
            "runtimeProofArtifactID": runtimeProofArtifactID,
            "runtimeRollbackPlanID": runtimeRollbackPlanID,
            "runtimeReplayTraceID": runtimeReplayTraceID,
            "runtimeCommandID": runtimeCommandID,
            "runtimeEventSequence": String(runtimeEventSequence),
            "runtimeEventChecksum": runtimeEventChecksum,
            "runtimeProjectionCursorIDs": projectionCursorIDs.joined(separator: ","),
            "runtimeProjectionCursorChecksums": projectionCursorChecksums.joined(separator: ","),
            "runtimeAffectedObjectIDs": affectedObjectIDs.joined(separator: ","),
            "runtimeObjectFamilies": objectFamilies.map(\.rawValue).joined(separator: ","),
            "runtimeCommittedAt": committedAt,
            "runtimeTrustLineageLocalOnly": String(localOnly),
            "runtimeTrustLineageChecksum": checksum,
        ].filter { $0.value.isEmpty == false }
    }

    static func eventMetadataLineage(_ metadata: [String: String]) -> RuntimeTrustLineage? {
        guard let transactionID = metadata["runtimeTransactionID"],
              let eventID = metadata["runtimeEventID"],
              let receiptID = metadata["runtimeReceiptID"] else {
            return nil
        }
        let sequence = Int64(metadata["runtimeEventSequence"] ?? "") ?? 0
        let families = (metadata["runtimeObjectFamilies"] ?? "")
            .split(separator: ",")
            .compactMap { ObjectStateFamily(rawValue: String($0)) }

        return RuntimeTrustLineage(
            id: metadata["runtimeTrustLineageID"],
            runtimeCommitReceiptID: metadata["runtimeCommitReceiptID"] ?? "runtime.commit-receipt.\(metadata["runtimeCommandID"] ?? receiptID)",
            runtimeTransactionID: transactionID,
            runtimeEventID: eventID,
            runtimeReceiptID: receiptID,
            runtimeProofArtifactID: metadata["runtimeProofArtifactID"] ?? "",
            runtimeRollbackPlanID: metadata["runtimeRollbackPlanID"] ?? "",
            runtimeReplayTraceID: metadata["runtimeReplayTraceID"] ?? "",
            runtimeCommandID: metadata["runtimeCommandID"] ?? "",
            runtimeEventSequence: sequence,
            runtimeEventChecksum: metadata["runtimeEventChecksum"] ?? "",
            projectionCursorIDs: Self.csv(metadata["runtimeProjectionCursorIDs"]),
            projectionCursorChecksums: Self.csv(metadata["runtimeProjectionCursorChecksums"]),
            affectedObjectIDs: Self.csv(metadata["runtimeAffectedObjectIDs"]),
            objectFamilies: families,
            committedAt: metadata["runtimeCommittedAt"] ?? "",
            checksum: metadata["runtimeTrustLineageChecksum"],
            localOnly: metadata["runtimeTrustLineageLocalOnly"] != "false"
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map(normalized)
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
            .sorted()
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func csv(_ value: String?) -> [String] {
        value?
            .split(separator: ",")
            .map { normalized(String($0)) }
            .filter { $0.isEmpty == false } ?? []
    }
}
