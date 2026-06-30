import Foundation

let commandReceiptSchemaVersion = "command_receipt.native.v1"

struct CommandReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let idempotencyKey: CommandIdempotencyKey
    let status: AmbitionsCommandExecutionStatus
    let summary: String
    let target: AmbitionsCommandTarget?
    let eventLedgerEntryIDs: [String]
    let commandEnvelopeID: String?
    let commandJournalReceiptID: String?
    let runtimeTransactionID: String?
    let replayDecision: String?
    let issuedAt: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        compilation: CommandCompilation?,
        journalReceipt: CommandJournalAppendReceipt?,
        issuedAt: String,
        schemaVersion: String = commandReceiptSchemaVersion
    ) {
        let key = compilation?.idempotencyKey ?? CommandIdempotencyKey(command: command)
        self.id = "command.receipt.\(command.id)"
        self.commandID = command.id
        self.idempotencyKey = key
        self.status = result.status
        self.summary = result.summary
        self.target = result.target ?? command.target
        self.eventLedgerEntryIDs = result.eventLedgerEntryIDs
        self.commandEnvelopeID = compilation?.envelope.id ?? journalReceipt?.envelopeID
        self.commandJournalReceiptID = journalReceipt?.id
        self.runtimeTransactionID = result.metadata["runtimeTransactionID"]
        self.replayDecision = result.metadata["replayDecision"] ?? result.metadata["runtimeReplayDecision"]
        self.issuedAt = issuedAt
        self.schemaVersion = schemaVersion
    }

    var resultMetadata: [String: String] {
        [
            "commandReceiptID": id,
            "commandReceiptSchemaVersion": schemaVersion,
            "commandReceiptStatus": status.rawValue,
            "commandReceiptIssuedAt": issuedAt,
            "commandReceiptEventLedgerIDs": eventLedgerEntryIDs.joined(separator: ","),
            "commandReceiptEnvelopeID": commandEnvelopeID ?? "",
            "commandReceiptJournalReceiptID": commandJournalReceiptID ?? "",
            "commandReceiptRuntimeTransactionID": runtimeTransactionID ?? "",
            "commandReceiptReplayDecision": replayDecision ?? "",
            "commandIdempotencyKey": idempotencyKey.rawValue
        ].filter { $0.value.isEmpty == false }
    }
}

struct CommandReceiptFactory: Sendable {
    func makeReceipt(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        compilation: CommandCompilation?,
        journalReceipt: CommandJournalAppendReceipt?,
        issuedAt: String
    ) -> CommandReceipt {
        CommandReceipt(
            command: command,
            result: result,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: issuedAt
        )
    }
}
