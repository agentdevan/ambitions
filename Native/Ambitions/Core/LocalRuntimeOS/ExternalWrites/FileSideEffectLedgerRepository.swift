import Foundation

struct FileSideEffectLedgerEnvelope: Codable, Sendable, Equatable {
    static let schemaVersion = 1

    var schemaVersion: Int = Self.schemaVersion
    var records: [SideEffectLedgerRecord] = []
}

enum FileSideEffectLedgerRecoveryError: Error, Sendable, Equatable {
    case recoveryRequired(fileName: String)
}

actor FileSideEffectLedgerRepository: SideEffectLedgerRepository {
    let fileURL: URL
    private let fileManager: FileManager
    private let fileProtectionApplier: @Sendable (URL) throws -> Void

    init(
        fileURL: URL,
        fileManager: FileManager = .default,
        fileProtectionApplier: @escaping @Sendable (URL) throws -> Void = FileSideEffectLedgerRepository.applyDefaultFileProtection
    ) {
        self.fileURL = fileURL
        self.fileManager = fileManager
        self.fileProtectionApplier = fileProtectionApplier
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

    static func defaultExternalSurfaceLedger() -> FileSideEffectLedgerRepository? {
        guard let fileURL = try? SharedExternalCreationStore().sideEffectLedgerFileURL() else {
            return nil
        }
        return FileSideEffectLedgerRepository(fileURL: fileURL)
    }

    static func defaultEventKitLedger() -> FileSideEffectLedgerRepository? {
        guard let localRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return FileSideEffectLedgerRepository(
            fileURL: localRoot
                .appendingPathComponent("Ambitions", isDirectory: true)
                .appendingPathComponent("EventKit", isDirectory: true)
                .appendingPathComponent("eventkit-side-effects.json")
        )
    }

    private func loadEnvelope(at coordinatedURL: URL) throws -> FileSideEffectLedgerEnvelope {
        guard fileManager.fileExists(atPath: coordinatedURL.path) else {
            return FileSideEffectLedgerEnvelope()
        }
        try verifyPrivateFileProtection(at: coordinatedURL)
        let data = try Data(contentsOf: coordinatedURL)
        return try Self.decoder.decode(FileSideEffectLedgerEnvelope.self, from: data)
    }

    private func saveEnvelope(_ envelope: FileSideEffectLedgerEnvelope, at coordinatedURL: URL) throws {
        try fileManager.createDirectory(
            at: coordinatedURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try writeProtectedAtomically(try Self.encoder.encode(envelope), to: coordinatedURL)
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

    private func writeProtectedAtomically(_ data: Data, to destination: URL) throws {
        let directory = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try fileProtectionApplier(directory)
        let stagingFile = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).pending"
        )
        let rollback = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).rollback"
        )
        guard fileManager.createFile(atPath: stagingFile.path, contents: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        var didActivate = false
        do {
            try fileProtectionApplier(stagingFile)
            try verifyPrivateFileProtection(at: stagingFile)
            try data.write(to: stagingFile)
            try verifyPrivateFileProtection(at: stagingFile)
            if fileManager.fileExists(atPath: destination.path) {
                _ = try fileManager.replaceItemAt(
                    destination,
                    withItemAt: stagingFile,
                    backupItemName: rollback.lastPathComponent
                )
                didActivate = true
                try verifyPrivateFileProtection(at: rollback)
            } else {
                try fileManager.moveItem(at: stagingFile, to: destination)
                didActivate = true
            }
            try verifyPrivateFileProtection(at: destination)
            try? fileManager.removeItem(at: rollback)
        } catch {
            var recoveryRequired = false
            if didActivate {
                try? fileManager.removeItem(at: destination)
                if fileManager.fileExists(atPath: destination.path) {
                    recoveryRequired = true
                }
                if fileManager.fileExists(atPath: rollback.path) {
                    if (try? verifyPrivateFileProtection(at: rollback)) != nil {
                        if fileManager.fileExists(atPath: destination.path) == false {
                            try? fileManager.copyItem(at: rollback, to: destination)
                        }
                        if (try? verifyPrivateFileProtection(at: destination)) == nil {
                            try? fileManager.removeItem(at: destination)
                            recoveryRequired = true
                        } else {
                            try? fileManager.removeItem(at: rollback)
                        }
                    } else {
                        recoveryRequired = true
                    }
                }
            }
            try? fileManager.removeItem(at: stagingFile)
            if recoveryRequired {
                throw FileSideEffectLedgerRecoveryError.recoveryRequired(fileName: destination.lastPathComponent)
            }
            throw error
        }
    }

    private func verifyPrivateFileProtection(at url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard (attributes[.protectionKey] as? FileProtectionType) == .complete else {
            throw CocoaError(.fileWriteNoPermission)
        }
        #else
        _ = url
        #endif
    }

    private static func applyDefaultFileProtection(to url: URL) throws {
        #if os(iOS)
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #else
        _ = url
        #endif
    }
}
