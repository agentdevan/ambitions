import CryptoKit
import Foundation

let commandJournalEntrySchemaVersion = "command_journal_entry.native.v1"
let commandJournalAppendReceiptSchemaVersion = "command_journal_append_receipt.native.v1"

enum CommandJournalStoreError: Error, Equatable {
    case invalidUTF8(URL)
    case checksumMismatch(entryID: String)
    case nonAppendOnlySequence(expected: Int64, actual: Int64)
}

struct CommandJournalQuery: Sendable, Equatable {
    let commandID: String?

    static let all = CommandJournalQuery(commandID: nil)

    static func commandID(_ commandID: String) -> CommandJournalQuery {
        CommandJournalQuery(commandID: commandID)
    }
}

struct CommandJournalChecksumMaterial: Codable, Sendable, Equatable, Hashable {
    let id: String
    let sequence: Int64
    let previousChecksum: String?
    let envelope: CommandEnvelope
    let appendedAt: String
    let deviceID: String
    let schemaVersion: String
}

enum CommandJournalChecksum {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static func digest(_ material: CommandJournalChecksumMaterial) throws -> String {
        let data = try encoder.encode(material)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func isValid(_ entry: CommandJournalEntry) -> Bool {
        (try? digest(entry.checksumMaterial)) == entry.checksum
    }
}

struct CommandJournalEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sequence: Int64
    let previousChecksum: String?
    let envelope: CommandEnvelope
    let appendedAt: String
    let deviceID: String
    let checksum: String
    let schemaVersion: String

    static func make(
        sequence: Int64,
        previousChecksum: String?,
        envelope: CommandEnvelope,
        appendedAt: String,
        deviceID: String = RuntimeLocalDeviceID.current,
        schemaVersion: String = commandJournalEntrySchemaVersion
    ) throws -> CommandJournalEntry {
        let normalizedSequence = max(1, sequence)
        let id = "command.journal.entry.\(normalizedSequence)"
        let material = CommandJournalChecksumMaterial(
            id: id,
            sequence: normalizedSequence,
            previousChecksum: previousChecksum,
            envelope: envelope,
            appendedAt: appendedAt,
            deviceID: deviceID,
            schemaVersion: schemaVersion
        )
        return CommandJournalEntry(
            id: id,
            sequence: normalizedSequence,
            previousChecksum: previousChecksum,
            envelope: envelope,
            appendedAt: appendedAt,
            deviceID: deviceID,
            checksum: try CommandJournalChecksum.digest(material),
            schemaVersion: schemaVersion
        )
    }

    var checksumMaterial: CommandJournalChecksumMaterial {
        CommandJournalChecksumMaterial(
            id: id,
            sequence: sequence,
            previousChecksum: previousChecksum,
            envelope: envelope,
            appendedAt: appendedAt,
            deviceID: deviceID,
            schemaVersion: schemaVersion
        )
    }
}

struct CommandJournalAppendReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let envelopeID: String
    let idempotencyKey: CommandIdempotencyKey
    let phase: CommandEnvelopePhase
    let sequence: Int64
    let checksum: String
    let appendedAt: String
    let schemaVersion: String

    init(
        entry: CommandJournalEntry,
        schemaVersion: String = commandJournalAppendReceiptSchemaVersion
    ) {
        self.id = "command.journal.append.\(entry.envelope.commandID)"
        self.commandID = entry.envelope.commandID
        self.envelopeID = entry.envelope.id
        self.idempotencyKey = entry.envelope.idempotencyKey
        self.phase = entry.envelope.phase
        self.sequence = entry.sequence
        self.checksum = entry.checksum
        self.appendedAt = entry.appendedAt
        self.schemaVersion = schemaVersion
    }

    var resultMetadata: [String: String] {
        [
            "commandJournalReceiptID": id,
            "commandJournalEnvelopeID": envelopeID,
            "commandJournalPhase": phase.rawValue,
            "commandJournalSequence": String(sequence),
            "commandJournalChecksum": checksum,
            "commandJournalAppendedAt": appendedAt,
            "commandIdempotencyKey": idempotencyKey.rawValue
        ]
    }
}

protocol CommandJournal: Sendable {
    @discardableResult
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt
    func fetchEntries(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandJournalEntry]
    func fetchEnvelopes(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandEnvelope]
}

actor InMemoryCommandJournal: CommandJournal {
    private var entries: [CommandJournalEntry] = []
    private let deviceID: String

    init(deviceID: String = "in-memory-command-journal") {
        self.deviceID = deviceID
    }

    @discardableResult
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt {
        let previous = entries.last
        let entry = try CommandJournalEntry.make(
            sequence: Int64(entries.count + 1),
            previousChecksum: previous?.checksum,
            envelope: envelope,
            appendedAt: envelope.receivedAt,
            deviceID: deviceID
        )
        entries.append(entry)
        return CommandJournalAppendReceipt(entry: entry)
    }

    func fetchEntries(matching query: CommandJournalQuery = .all, limit: Int? = nil) async throws -> [CommandJournalEntry] {
        let filtered = Self.apply(query, to: entries)
        guard let limit else { return filtered }
        return Array(filtered.prefix(max(0, limit)))
    }

    func fetchEnvelopes(matching query: CommandJournalQuery = .all, limit: Int? = nil) async throws -> [CommandEnvelope] {
        try await fetchEntries(matching: query, limit: limit).map(\.envelope)
    }

    static func apply(_ query: CommandJournalQuery, to entries: [CommandJournalEntry]) -> [CommandJournalEntry] {
        guard let commandID = query.commandID else { return entries }
        return entries.filter { $0.envelope.commandID == commandID }
    }
}

actor FileCommandJournal: CommandJournal {
    private let fileURL: URL
    private let deviceID: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileURL: URL,
        deviceID: String = RuntimeLocalDeviceID.current
    ) {
        self.fileURL = fileURL
        self.deviceID = deviceID
        self.encoder = CommandJournalChecksum.encoder
        self.decoder = JSONDecoder()
    }

    static func defaultLiveStore() -> FileCommandJournal {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        let fileURL = supportDirectory
            .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
            .appendingPathComponent("CommandJournal.jsonl", isDirectory: false)
        return FileCommandJournal(fileURL: fileURL)
    }

    @discardableResult
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt {
        let existing = try readEntries()
        let previous = existing.last
        let entry = try CommandJournalEntry.make(
            sequence: Int64(existing.count + 1),
            previousChecksum: previous?.checksum,
            envelope: envelope,
            appendedAt: envelope.receivedAt,
            deviceID: deviceID
        )
        try validateAppend(entry, after: previous)
        try appendLine(entry)
        return CommandJournalAppendReceipt(entry: entry)
    }

    func fetchEntries(matching query: CommandJournalQuery = .all, limit: Int? = nil) async throws -> [CommandJournalEntry] {
        let filtered = InMemoryCommandJournal.apply(query, to: try readEntries())
        guard let limit else { return filtered }
        return Array(filtered.prefix(max(0, limit)))
    }

    func fetchEnvelopes(matching query: CommandJournalQuery = .all, limit: Int? = nil) async throws -> [CommandEnvelope] {
        try await fetchEntries(matching: query, limit: limit).map(\.envelope)
    }

    private func validateAppend(_ entry: CommandJournalEntry, after previous: CommandJournalEntry?) throws {
        let expectedSequence = (previous?.sequence ?? 0) + 1
        guard entry.sequence == expectedSequence else {
            throw CommandJournalStoreError.nonAppendOnlySequence(expected: expectedSequence, actual: entry.sequence)
        }
        guard CommandJournalChecksum.isValid(entry) else {
            throw CommandJournalStoreError.checksumMismatch(entryID: entry.id)
        }
    }

    private func appendLine(_ entry: CommandJournalEntry) throws {
        let fileManager = FileManager.default
        let directory = fileURL.deletingLastPathComponent()
        if fileManager.fileExists(atPath: directory.path) == false {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        if fileManager.fileExists(atPath: fileURL.path) == false {
            fileManager.createFile(atPath: fileURL.path, contents: nil)
        }
        var data = try encoder.encode(entry)
        data.append(0x0A)
        let handle = try FileHandle(forWritingTo: fileURL)
        handle.seekToEndOfFile()
        handle.write(data)
        handle.synchronizeFile()
        handle.closeFile()
    }

    private func readEntries() throws -> [CommandJournalEntry] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else { return [] }
        guard let raw = String(data: data, encoding: .utf8) else {
            throw CommandJournalStoreError.invalidUTF8(fileURL)
        }

        return try raw
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { line in
                let entry = try decoder.decode(CommandJournalEntry.self, from: Data(line.utf8))
                guard CommandJournalChecksum.isValid(entry) else {
                    throw CommandJournalStoreError.checksumMismatch(entryID: entry.id)
                }
                return entry
            }
    }
}
