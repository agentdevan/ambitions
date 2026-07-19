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
        var envelope = try loadEnvelope()
        envelope.records.removeAll { $0.id == record.id }
        envelope.records.append(record)
        try saveEnvelope(envelope)
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(try loadEnvelope().records.sorted(by: Self.sort).prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        try loadEnvelope().records
            .filter { $0.status == status }
            .sorted(by: Self.sort)
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        try loadEnvelope().records.first { $0.id == id }
    }

    func drainRecords() async throws -> [SideEffectLedgerRecord] {
        let records = try loadEnvelope().records.sorted(by: Self.sort)
        guard records.isEmpty == false else { return [] }
        try? fileManager.removeItem(at: fileURL)
        return records
    }

    static func defaultExternalSurfaceLedger() -> FileSideEffectLedgerRepository {
        FileSideEffectLedgerRepository(fileURL: SharedExternalCreationStore().sideEffectLedgerFileURL())
    }

    private func loadEnvelope() throws -> FileSideEffectLedgerEnvelope {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return FileSideEffectLedgerEnvelope()
        }
        let data = try Data(contentsOf: fileURL)
        return try Self.decoder.decode(FileSideEffectLedgerEnvelope.self, from: data)
    }

    private func saveEnvelope(_ envelope: FileSideEffectLedgerEnvelope) throws {
        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try Self.encoder.encode(envelope)
        try data.write(to: fileURL, options: [.atomic])
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
