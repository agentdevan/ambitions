import Foundation

struct FileSideEffectLedgerEnvelope: Codable, Sendable, Equatable {
    static let schemaVersion = 1

    var schemaVersion: Int = Self.schemaVersion
    var records: [SideEffectLedgerRecord] = []
}

actor FileSideEffectLedgerRepository: SideEffectLedgerRepository {
    let fileURL: URL
    private let fileManager: FileManager

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    func append(_ record: SideEffectLedgerRecord) async throws {
        guard record.isWellFormed else { return }
        try coordinatedWrite { envelope in
            envelope.records.removeAll { $0.id == record.id }
            envelope.records.append(record)
        }
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(try coordinatedRead().records.sorted(by: Self.sort).prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        try coordinatedRead().records
            .filter { $0.status == status }
            .sorted(by: Self.sort)
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        try coordinatedRead().records.first { $0.id == id }
    }

    func claim(_ record: SideEffectLedgerRecord, token: String) async throws -> SideEffectLedgerClaimResult {
        var result: SideEffectLedgerClaimResult?
        try coordinatedWrite { envelope in
            if let existing = envelope.records.first(where: { $0.id == record.id }) {
                result = .existing(existing)
                return
            }
            let claimed = record.claiming(token: token)
            envelope.records.append(claimed)
            result = .claimed(claimed)
        }
        guard let result else { throw CocoaError(.fileWriteUnknown) }
        return result
    }

    func insertIfAbsent(_ record: SideEffectLedgerRecord) async throws -> SideEffectLedgerClaimResult {
        var result: SideEffectLedgerClaimResult?
        try coordinatedWrite { envelope in
            if let existing = envelope.records.first(where: { $0.id == record.id }) {
                result = .existing(existing)
                return
            }
            envelope.records.append(record)
            result = .claimed(record)
        }
        guard let result else { throw CocoaError(.fileWriteUnknown) }
        return result
    }

    func finalize(_ record: SideEffectLedgerRecord, token: String) async throws -> Bool {
        var didFinalize = false
        try coordinatedWrite { envelope in
            guard let index = envelope.records.firstIndex(where: { $0.id == record.id }),
                  envelope.records[index].claimToken == token else { return }
            envelope.records[index] = record.finalized()
            didFinalize = true
        }
        return didFinalize
    }

    func drainRecords() async throws -> [SideEffectLedgerRecord] {
        var drained: [SideEffectLedgerRecord] = []
        try coordinatedWrite { envelope in
            drained = envelope.records.sorted(by: Self.sort)
            envelope.records.removeAll()
        }
        return drained
    }

    static func defaultExternalSurfaceLedger() -> FileSideEffectLedgerRepository {
        FileSideEffectLedgerRepository(fileURL: SharedExternalCreationStore().sideEffectLedgerFileURL())
    }

    static func defaultEventKitLedger() -> FileSideEffectLedgerRepository {
        let externalURL = SharedExternalCreationStore().sideEffectLedgerFileURL()
        return FileSideEffectLedgerRepository(
            fileURL: externalURL.deletingLastPathComponent().appendingPathComponent("eventkit-side-effects.json")
        )
    }

    private func loadEnvelope(at coordinatedURL: URL) throws -> FileSideEffectLedgerEnvelope {
        guard fileManager.fileExists(atPath: coordinatedURL.path) else {
            return FileSideEffectLedgerEnvelope()
        }
        let data = try Data(contentsOf: coordinatedURL)
        return try Self.decoder.decode(FileSideEffectLedgerEnvelope.self, from: data)
    }

    private func saveEnvelope(_ envelope: FileSideEffectLedgerEnvelope, at coordinatedURL: URL) throws {
        try fileManager.createDirectory(
            at: coordinatedURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try Self.encoder.encode(envelope)
        try data.write(to: coordinatedURL, options: [.atomic])
    }

    private func coordinatedRead() throws -> FileSideEffectLedgerEnvelope {
        let directoryURL = fileURL.deletingLastPathComponent()
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var result: Result<FileSideEffectLedgerEnvelope, Error>?
        coordinator.coordinate(
            readingItemAt: directoryURL,
            options: [],
            error: &coordinationError
        ) { coordinatedDirectoryURL in
            let coordinatedURL = coordinatedDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
            result = Result { try loadEnvelope(at: coordinatedURL) }
        }
        if let coordinationError { throw coordinationError }
        guard let result else { throw CocoaError(.fileReadUnknown) }
        return try result.get()
    }

    private func coordinatedWrite(_ mutation: (inout FileSideEffectLedgerEnvelope) throws -> Void) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let directoryURL = fileURL.deletingLastPathComponent()
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var result: Result<Void, Error>?
        coordinator.coordinate(
            writingItemAt: directoryURL,
            options: [],
            error: &coordinationError
        ) { coordinatedDirectoryURL in
            let coordinatedURL = coordinatedDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
            result = Result {
                var envelope = try loadEnvelope(at: coordinatedURL)
                try mutation(&envelope)
                try saveEnvelope(envelope, at: coordinatedURL)
            }
        }
        if let coordinationError { throw coordinationError }
        guard let result else { throw CocoaError(.fileWriteUnknown) }
        try result.get()
    }

    private static func sort(_ lhs: SideEffectLedgerRecord, _ rhs: SideEffectLedgerRecord) -> Bool {
        if lhs.occurredAt != rhs.occurredAt {
            return lhs.occurredAt > rhs.occurredAt
        }
        return lhs.id < rhs.id
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    private static let decoder = JSONDecoder()
}
