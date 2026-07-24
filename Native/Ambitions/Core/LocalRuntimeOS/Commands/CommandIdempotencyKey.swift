import Foundation

let commandIdempotencyKeySchemaVersion = "command_idempotency_key.native.v1"

struct CommandIdempotencyKey: Codable, Sendable, Equatable, Hashable, Identifiable {
    let rawValue: String
    let schemaVersion: String

    init(
        _ rawValue: String,
        schemaVersion: String = commandIdempotencyKeySchemaVersion
    ) {
        self.rawValue = rawValue
        self.schemaVersion = schemaVersion
    }

    init(
        command: AmbitionsCommand,
        schemaVersion: String = commandIdempotencyKeySchemaVersion
    ) {
        self.init(command.idempotencyKey.rawValue, schemaVersion: schemaVersion)
    }

    var id: String {
        rawValue
    }

    var isWellFormed: Bool {
        rawValue.isEmpty == false &&
            rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines) &&
            rawValue == rawValue.precomposedStringWithCanonicalMapping &&
            rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }

    var ledgerKey: LedgerIdempotencyKey {
        LedgerIdempotencyKey(rawValue)
    }
}
