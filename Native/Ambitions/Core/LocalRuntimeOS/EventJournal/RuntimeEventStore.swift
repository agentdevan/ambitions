import Foundation

enum RuntimeEventStoreError: Error, Equatable {
    case invalidUTF8(URL)
    case checksumMismatch(eventID: String)
    case nonAppendOnlySequence(expected: Int64, actual: Int64)
}

protocol RuntimeEventStore: Sendable {
    @discardableResult
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope
    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope]
    func latestCursor() async throws -> RuntimeEventCursor?
}

actor InMemoryRuntimeEventStore: RuntimeEventStore {
    private var envelopes: [RuntimeEventEnvelope] = []
    private let deviceID: String

    init(deviceID: String = "in-memory-runtime-event-store") {
        self.deviceID = deviceID
    }

    @discardableResult
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        let previous = envelopes.last
        let envelope = try RuntimeEventEnvelope.make(
            sequence: Int64(envelopes.count + 1),
            previousChecksum: previous?.checksum,
            event: event,
            deviceID: deviceID
        )
        envelopes.append(envelope)
        return envelope
    }

    func fetchEvents(matching query: RuntimeEventQuery = .all, limit: Int? = nil) async throws -> [RuntimeEventEnvelope] {
        let filtered = Self.apply(query, to: envelopes)
        guard let limit else { return filtered }
        return Array(filtered.prefix(max(0, limit)))
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        envelopes.last?.cursor
    }

    static func apply(_ query: RuntimeEventQuery, to envelopes: [RuntimeEventEnvelope]) -> [RuntimeEventEnvelope] {
        switch query {
        case .all:
            return envelopes
        case let .after(cursor):
            return envelopes.filter { $0.sequence > cursor.sequence }
        case let .commandID(commandID):
            return envelopes.filter { $0.event.commandID == commandID }
        case let .kind(kind):
            return envelopes.filter { $0.event.kind == kind }
        }
    }
}

actor FileRuntimeEventStore: RuntimeEventStore {
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
        encoder = RuntimeEventChecksum.encoder
        decoder = JSONDecoder()
    }

    static func defaultLiveStore() -> FileRuntimeEventStore {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        let fileURL = supportDirectory
            .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
            .appendingPathComponent("RuntimeEventJournal.jsonl", isDirectory: false)
        return FileRuntimeEventStore(fileURL: fileURL)
    }

    @discardableResult
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        let existing = try readEnvelopes()
        let previous = existing.last
        let envelope = try RuntimeEventEnvelope.make(
            sequence: Int64(existing.count + 1),
            previousChecksum: previous?.checksum,
            event: event,
            deviceID: deviceID
        )
        try validateAppend(envelope, after: previous)
        try appendLine(envelope)
        return envelope
    }

    func fetchEvents(matching query: RuntimeEventQuery = .all, limit: Int? = nil) async throws -> [RuntimeEventEnvelope] {
        let envelopes = try readEnvelopes()
        let filtered = InMemoryRuntimeEventStore.apply(query, to: envelopes)
        guard let limit else { return filtered }
        return Array(filtered.prefix(max(0, limit)))
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        try readEnvelopes().last?.cursor
    }

    private func validateAppend(_ envelope: RuntimeEventEnvelope, after previous: RuntimeEventEnvelope?) throws {
        let expectedSequence = (previous?.sequence ?? 0) + 1
        guard envelope.sequence == expectedSequence else {
            throw RuntimeEventStoreError.nonAppendOnlySequence(expected: expectedSequence, actual: envelope.sequence)
        }
        guard RuntimeEventChecksum.isValid(envelope) else {
            throw RuntimeEventStoreError.checksumMismatch(eventID: envelope.id)
        }
    }

    private func appendLine(_ envelope: RuntimeEventEnvelope) throws {
        let fileManager = FileManager.default
        let directory = fileURL.deletingLastPathComponent()
        if fileManager.fileExists(atPath: directory.path) == false {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        if fileManager.fileExists(atPath: fileURL.path) == false {
            fileManager.createFile(atPath: fileURL.path, contents: nil)
        }
        var data = try encoder.encode(envelope)
        data.append(0x0A)
        let handle = try FileHandle(forWritingTo: fileURL)
        handle.seekToEndOfFile()
        handle.write(data)
        handle.synchronizeFile()
        handle.closeFile()
    }

    private func readEnvelopes() throws -> [RuntimeEventEnvelope] {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else { return [] }
        guard let raw = String(data: data, encoding: .utf8) else {
            throw RuntimeEventStoreError.invalidUTF8(fileURL)
        }

        return try raw
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { line in
                let envelope = try decoder.decode(RuntimeEventEnvelope.self, from: Data(line.utf8))
                guard RuntimeEventChecksum.isValid(envelope) else {
                    throw RuntimeEventStoreError.checksumMismatch(eventID: envelope.id)
                }
                return envelope
            }
    }
}
