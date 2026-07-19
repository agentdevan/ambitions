import Foundation

let localScheduleBlockRepositoryExportSchemaVersion = "local_schedule_block_repository_export.native.v1"

enum LocalScheduleBlockRepositoryError: LocalizedError, Sendable, Equatable {
    case unsupportedExportSchemaVersion(String)

    var errorDescription: String? {
        switch self {
        case let .unsupportedExportSchemaVersion(version):
            return "Unsupported local schedule block export schema version: \(version)"
        }
    }
}

struct LocalScheduleBlockRepositoryExport: Codable, Sendable, Equatable {
    let schemaVersion: String
    let exportedAt: String
    let blocks: [ScheduledAmbitionsBlock]

    init(
        exportedAt: String,
        blocks: [ScheduledAmbitionsBlock],
        schemaVersion: String = localScheduleBlockRepositoryExportSchemaVersion
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.blocks = blocks
    }
}

protocol LocalScheduleBlockRepository: Sendable {
    func listBlocks() async throws -> [ScheduledAmbitionsBlock]
    func block(id: String) async throws -> ScheduledAmbitionsBlock?
    func saveBlocks(_ blocks: [ScheduledAmbitionsBlock]) async throws -> [String]
    func upsertBlock(_ block: ScheduledAmbitionsBlock) async throws -> [String]
    func deleteBlock(id: String) async throws -> String?
    func exportBlocks() async throws -> LocalScheduleBlockRepositoryExport
    func importBlocks(_ export: LocalScheduleBlockRepositoryExport) async throws
}

struct FileLocalScheduleBlockRepository: LocalScheduleBlockRepository {
    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func listBlocks() async throws -> [ScheduledAmbitionsBlock] {
        try await LocalScheduleBlockFileCoordinator.shared.listBlocks(fileURL: fileURL)
    }

    func block(id: String) async throws -> ScheduledAmbitionsBlock? {
        let blocks = try await listBlocks()
        return blocks.first { $0.id == id }
    }

    func saveBlocks(_ blocks: [ScheduledAmbitionsBlock]) async throws -> [String] {
        try await LocalScheduleBlockFileCoordinator.shared.saveBlocks(blocks, fileURL: fileURL)
    }

    func upsertBlock(_ block: ScheduledAmbitionsBlock) async throws -> [String] {
        try await LocalScheduleBlockFileCoordinator.shared.upsertBlock(block, fileURL: fileURL)
    }

    func deleteBlock(id: String) async throws -> String? {
        try await LocalScheduleBlockFileCoordinator.shared.deleteBlock(id: id, fileURL: fileURL)
    }

    func exportBlocks() async throws -> LocalScheduleBlockRepositoryExport {
        LocalScheduleBlockRepositoryExport(
            exportedAt: ISO8601DateFormatter().string(from: .now),
            blocks: try await listBlocks()
        )
    }

    func importBlocks(_ export: LocalScheduleBlockRepositoryExport) async throws {
        guard export.schemaVersion == localScheduleBlockRepositoryExportSchemaVersion else {
            throw LocalScheduleBlockRepositoryError.unsupportedExportSchemaVersion(export.schemaVersion)
        }
        _ = try await saveBlocks(export.blocks)
    }
}

private actor LocalScheduleBlockFileCoordinator {
    static let shared = LocalScheduleBlockFileCoordinator()

    func listBlocks(fileURL: URL) throws -> [ScheduledAmbitionsBlock] {
        try loadLocalScheduleBlocks(from: fileURL, decoder: JSONDecoder())
    }

    func saveBlocks(_ blocks: [ScheduledAmbitionsBlock], fileURL: URL) throws -> [String] {
        try saveLocalScheduleBlocks(blocks, to: fileURL, encoder: makeEncoder())
    }

    func upsertBlock(_ block: ScheduledAmbitionsBlock, fileURL: URL) throws -> [String] {
        try upsertLocalScheduleBlock(block, in: fileURL, decoder: JSONDecoder(), encoder: makeEncoder())
    }

    func deleteBlock(id: String, fileURL: URL) throws -> String? {
        try deleteLocalScheduleBlock(id: id, from: fileURL, decoder: JSONDecoder(), encoder: makeEncoder())
    }

    private nonisolated func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
