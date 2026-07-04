import Foundation

let runtimeRollbackPlanSchemaVersion = "runtime_rollback_plan.native.v1"

struct RuntimeRollbackPlan: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let transactionID: String
    let commandID: String
    let restoresSnapshotID: String
    let restoresSnapshotSummary: String
    let affectedObjectIDs: [String]
    let objectFamilies: [ObjectStateFamily]
    let sourceReceiptID: String
    let proofArtifactID: String
    let reason: String
    let localOnly: Bool
    let checksum: String
    let schemaVersion: String

    init(
        transactionID: String,
        plan: RuntimeMutationPlan,
        reason: String = "Restore the pre-transaction snapshot and invalidate derived projections.",
        schemaVersion: String = runtimeRollbackPlanSchemaVersion
    ) {
        self.id = "runtime.rollback.\(plan.command.id)"
        self.transactionID = transactionID
        self.commandID = plan.command.id
        self.restoresSnapshotID = plan.mutation.stageMutation.beforeSnapshot.id
        self.restoresSnapshotSummary = plan.mutation.stageMutation.beforeSnapshot.summary
        self.affectedObjectIDs = plan.writeSet.affectedObjectIDs
        self.objectFamilies = plan.writeSet.objectFamilies
        self.sourceReceiptID = plan.writeSet.receiptID
        self.proofArtifactID = plan.writeSet.proofArtifactID
        self.reason = reason
        self.localOnly = plan.command.localOnly && plan.validation.privacyBoundary.localOnly
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            transactionID,
            commandID,
            restoresSnapshotID,
            restoresSnapshotSummary,
            affectedObjectIDs.joined(separator: ","),
            objectFamilies.map(\.rawValue).joined(separator: ","),
            sourceReceiptID,
            proofArtifactID,
            reason,
            String(localOnly),
            schemaVersion,
        ])
    }

    var isExecutable: Bool {
        transactionID.isEmpty == false &&
            commandID.isEmpty == false &&
            restoresSnapshotID.isEmpty == false &&
            restoresSnapshotSummary.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            sourceReceiptID.isEmpty == false &&
            proofArtifactID.isEmpty == false &&
            localOnly
    }
}
