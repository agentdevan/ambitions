import Foundation

let runtimeTransactionFailureReceiptSchemaVersion = "runtime_transaction_failure_receipt.native.v2"

struct RuntimeTransactionFailureReceipt: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let commandPayload: RuntimeCommandPayload?
    let legacyCommandOperation: RuntimeCommandOperation?
    let reason: String
    let missingEvidenceKeys: [String]
    let blockedAt: String
    let attemptedResultStatus: AmbitionsCommandExecutionStatus
    let checksum: String
    let schemaVersion: String

    private enum CodingKeys: String, CodingKey {
        case id, commandID
        case commandPayload
        case legacyCommandOperation = "commandKind"
        case reason, missingEvidenceKeys, blockedAt, attemptedResultStatus, checksum, schemaVersion
    }

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
        self.commandPayload = command.typedPayload
        self.legacyCommandOperation = nil
        self.reason = reason
        self.missingEvidenceKeys = Array(Set(missingEvidenceKeys.filter { $0.isEmpty == false })).sorted()
        self.blockedAt = blockedAt
        self.attemptedResultStatus = attemptedResultStatus
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            commandID,
            Self.commandPayloadIdentity(command.typedPayload),
            reason,
            self.missingEvidenceKeys.joined(separator: ","),
            blockedAt,
            attemptedResultStatus.rawValue,
            schemaVersion,
        ])
    }

    private static func commandPayloadIdentity(_ payload: RuntimeCommandPayload) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let bytes = try? encoder.encode(payload),
              let canonical = String(data: bytes, encoding: .utf8) else {
            return RuntimeTransactionDigest.digest([payload.diagnosticFamily, payload.diagnosticCase])
        }
        return RuntimeTransactionDigest.digest([canonical])
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        commandID = try values.decode(String.self, forKey: .commandID)
        commandPayload = try values.decodeIfPresent(RuntimeCommandPayload.self, forKey: .commandPayload)
        legacyCommandOperation = try values.decodeIfPresent(RuntimeCommandOperation.self, forKey: .legacyCommandOperation)
        guard commandPayload != nil || legacyCommandOperation != nil else {
            throw DecodingError.dataCorruptedError(forKey: .commandPayload, in: values, debugDescription: "Failure receipt has no typed or legacy command identity.")
        }
        reason = try values.decode(String.self, forKey: .reason)
        missingEvidenceKeys = try values.decode([String].self, forKey: .missingEvidenceKeys)
        blockedAt = try values.decode(String.self, forKey: .blockedAt)
        attemptedResultStatus = try values.decode(AmbitionsCommandExecutionStatus.self, forKey: .attemptedResultStatus)
        checksum = try values.decode(String.self, forKey: .checksum)
        schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(commandID, forKey: .commandID)
        try values.encodeIfPresent(commandPayload, forKey: .commandPayload)
        try values.encodeIfPresent(legacyCommandOperation, forKey: .legacyCommandOperation)
        try values.encode(reason, forKey: .reason)
        try values.encode(missingEvidenceKeys, forKey: .missingEvidenceKeys)
        try values.encode(blockedAt, forKey: .blockedAt)
        try values.encode(attemptedResultStatus, forKey: .attemptedResultStatus)
        try values.encode(checksum, forKey: .checksum)
        try values.encode(schemaVersion, forKey: .schemaVersion)
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
