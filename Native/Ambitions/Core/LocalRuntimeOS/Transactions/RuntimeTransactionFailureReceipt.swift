import Foundation

let runtimeTransactionFailureReceiptSchemaVersion = "runtime_transaction_failure_receipt.native.v1"

struct RuntimeTransactionFailureReceipt: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let commandKind: AmbitionsCommandKind
    let reason: String
    let missingEvidenceKeys: [String]
    let blockedAt: String
    let attemptedResultStatus: AmbitionsCommandExecutionStatus
    let checksum: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        reason: String,
        missingEvidenceKeys: [String],
        blockedAt: String,
        attemptedResultStatus: AmbitionsCommandExecutionStatus,
        schemaVersion: String = runtimeTransactionFailureReceiptSchemaVersion
    ) {
        self.id = "runtime.failure-receipt.\(command.id)"
        self.commandID = command.id
        self.commandKind = command.kind
        self.reason = reason
        self.missingEvidenceKeys = Array(Set(missingEvidenceKeys.filter { $0.isEmpty == false })).sorted()
        self.blockedAt = blockedAt
        self.attemptedResultStatus = attemptedResultStatus
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            commandID,
            commandKind.rawValue,
            reason,
            self.missingEvidenceKeys.joined(separator: ","),
            blockedAt,
            attemptedResultStatus.rawValue,
            schemaVersion,
        ])
    }

    var resultMetadata: [String: String] {
        [
            "runtimeTransactionDisposition": "not_committed",
            "runtimeCommitPolicy": "meaningful_mutation_requires_commit",
            "runtimeCommitEvidence": "missing",
            "runtimeCommitFailureReceiptID": id,
            "runtimeCommitFailureReceiptSchemaVersion": schemaVersion,
            "runtimeCommitFailureReason": reason,
            "runtimeMissingCommitEvidence": missingEvidenceKeys.joined(separator: ","),
            "runtimeCommitFailureBlockedAt": blockedAt,
        ].filter { $0.value.isEmpty == false }
    }
}
