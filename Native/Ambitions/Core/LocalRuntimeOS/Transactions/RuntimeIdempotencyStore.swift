import Foundation

let runtimeIdempotencyRecordSchemaVersion = "runtime_idempotency_record.native.v1"

struct RuntimeIdempotencyRecord: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let key: LedgerIdempotencyKey
    let commandID: String
    let receipt: RuntimeCommitReceipt
    let recordedAt: String
    let schemaVersion: String

    init(
        key: LedgerIdempotencyKey,
        commandID: String,
        receipt: RuntimeCommitReceipt,
        recordedAt: String,
        schemaVersion: String = runtimeIdempotencyRecordSchemaVersion
    ) {
        self.id = "runtime.idempotency.\(key.rawValue)"
        self.key = key
        self.commandID = commandID
        self.receipt = receipt
        self.recordedAt = recordedAt
        self.schemaVersion = schemaVersion
    }
}

actor RuntimeIdempotencyStore {
    private var recordsByKey: [LedgerIdempotencyKey: RuntimeIdempotencyRecord] = [:]

    func record(_ receipt: RuntimeCommitReceipt, recordedAt: String) throws -> RuntimeIdempotencyRecord {
        guard receipt.idempotencyKey.isWellFormed else {
            throw RuntimeTransactionError.idempotencyKeyMalformed(receipt.idempotencyKey.rawValue)
        }
        let record = RuntimeIdempotencyRecord(
            key: receipt.idempotencyKey,
            commandID: receipt.commandID,
            receipt: receipt,
            recordedAt: recordedAt
        )
        recordsByKey[record.key] = record
        return record
    }

    func receipt(for key: LedgerIdempotencyKey) -> RuntimeCommitReceipt? {
        recordsByKey[key]?.receipt
    }

    func record(for key: LedgerIdempotencyKey) -> RuntimeIdempotencyRecord? {
        recordsByKey[key]
    }

    func committedReceipts() -> [RuntimeCommitReceipt] {
        recordsByKey.values.map(\.receipt).sorted { $0.id < $1.id }
    }

    func contains(_ key: LedgerIdempotencyKey) -> Bool {
        recordsByKey[key] != nil
    }
}
