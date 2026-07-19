import Foundation

let commandIdempotencyKeySchemaVersion = "command_idempotency_key.native.v1"

struct CommandIdempotencyKey: Codable, Sendable, Equatable, Hashable, Identifiable {
    let rawValue: String
    let schemaVersion: String

    init(
        _ rawValue: String,
        schemaVersion: String = commandIdempotencyKeySchemaVersion
    ) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = schemaVersion
    }

    init(
        command: AmbitionsCommand,
        schemaVersion: String = commandIdempotencyKeySchemaVersion
    ) {
        self.init(command.id, schemaVersion: schemaVersion)
    }

    var id: String {
        rawValue
    }

    var isWellFormed: Bool {
        rawValue.isEmpty == false
    }

    var ledgerKey: LedgerIdempotencyKey {
        LedgerIdempotencyKey(rawValue)
    }
}
