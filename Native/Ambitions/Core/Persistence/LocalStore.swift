import Foundation
import SwiftData

enum PersistenceCoding {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static let decoder = JSONDecoder()

    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        try encoder.encode(value)
    }

    static func decode<Value: Decodable>(_ type: Value.Type, from data: Data) throws -> Value {
        try decoder.decode(type, from: data)
    }
}

actor AmbitionsPersistenceStore {
    static let storedModelNames: Set<String> = [
        "ActionReceiptHistoryRecordModel",
        "AmbitionGraphOperationalRecordModel",
        "AmbitionGraphProofRecordModel",
        "AmbitionGraphProjectionRecordModel",
        "AppStateRecord",
        "CaptureRecord",
        "CommandExecutionRecord",
        "EntityRevisionTombstoneRecord",
        "EventLedgerRecord",
        "FeedbackEventRecord",
        "GoalDraftRecord",
        "GoalPlanRecord",
        "GoalRecord",
        "LifeContextBundleRecord",
        "PlanSectionRecord",
        "ProgressEvidenceRecord",
        "ReminderRecord",
        "RuntimeSnapshotLedgerRecord",
        "SideEffectLedgerStorageRecord",
        "StepRecord",
        "TeachingSignalRecord"
    ]

    static let schema = Schema([
        GoalRecord.self,
        GoalDraftRecord.self,
        GoalPlanRecord.self,
        PlanSectionRecord.self,
        StepRecord.self,
        ProgressEvidenceRecord.self,
        FeedbackEventRecord.self,
        CaptureRecord.self,
        ReminderRecord.self,
        TeachingSignalRecord.self,
        EventLedgerRecord.self,
        CommandExecutionRecord.self,
        SideEffectLedgerStorageRecord.self,
        EntityRevisionTombstoneRecord.self,
        AppStateRecord.self,
        ActionReceiptHistoryRecordModel.self,
        RuntimeSnapshotLedgerRecord.self,
        LifeContextBundleRecord.self,
        AmbitionGraphOperationalRecordModel.self,
        AmbitionGraphProofRecordModel.self,
        AmbitionGraphProjectionRecordModel.self
        ])

    private let container: ModelContainer

    init(inMemory: Bool) throws {
        do {
            container = try Self.makeContainer(inMemory: inMemory)
        } catch {
            #if DEBUG
            guard inMemory == false else {
                throw error
            }

            try Self.quarantineIncompatiblePersistentStores(after: error)
            container = try Self.makeContainer(inMemory: false)
            #else
            throw error
            #endif
        }
    }

    private static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: Self.schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: Self.schema, configurations: configuration)
    }

    #if DEBUG
    /// SwiftData can fail to open the development simulator store after rapid schema iteration.
    /// In DEBUG only, move the incompatible local store files into Application Support so the app can
    /// recreate a clean local store instead of trapping at launch. Release builds never auto-reset data.
    private static func quarantineIncompatiblePersistentStores(after error: any Error) throws {
        let fileManager = FileManager.default
        let timestamp = ISO8601DateFormatter()
            .string(from: .now)
            .replacingOccurrences(of: ":", with: "-")
        let quarantineDirectory = try quarantineDirectory(named: "swiftdata-launch-recovery-\(timestamp)", fileManager: fileManager)
        let candidates = persistentStoreCandidateURLs(fileManager: fileManager)
        var movedAnyStoreFile = false

        for candidate in candidates where fileManager.fileExists(atPath: candidate.path) {
            let destination = uniqueDestinationURL(
                for: candidate.lastPathComponent,
                in: quarantineDirectory,
                fileManager: fileManager
            )
            try fileManager.moveItem(at: candidate, to: destination)
            movedAnyStoreFile = true
        }

        guard movedAnyStoreFile else {
            throw error
        }
    }

    private static func persistentStoreCandidateURLs(fileManager: FileManager) -> [URL] {
        let baseDirectories = [
            fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
            fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
            fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        ].compactMap { $0 }

        let fileNames = [
            "default.store",
            "default.store-shm",
            "default.store-wal",
            "default.sqlite",
            "default.sqlite-shm",
            "default.sqlite-wal",
            "Ambitions.store",
            "Ambitions.store-shm",
            "Ambitions.store-wal",
            "Ambitions.sqlite",
            "Ambitions.sqlite-shm",
            "Ambitions.sqlite-wal"
        ]

        return baseDirectories.flatMap { directory in
            fileNames.map { directory.appendingPathComponent($0, isDirectory: false) }
        }
    }

    private static func quarantineDirectory(named name: String, fileManager: FileManager) throws -> URL {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let rootDirectory = supportDirectory.appendingPathComponent("AmbitionsSwiftDataRecovery", isDirectory: true)
        let directory = rootDirectory.appendingPathComponent(name, isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func uniqueDestinationURL(for fileName: String, in directory: URL, fileManager: FileManager) -> URL {
        let baseURL = directory.appendingPathComponent(fileName, isDirectory: false)
        guard fileManager.fileExists(atPath: baseURL.path) else {
            return baseURL
        }

        let ext = baseURL.pathExtension
        let baseName = ext.isEmpty ? baseURL.lastPathComponent : baseURL.deletingPathExtension().lastPathComponent
        for index in 1...1_000 {
            let candidateName = ext.isEmpty ? "\(baseName)-\(index)" : "\(baseName)-\(index).\(ext)"
            let candidate = directory.appendingPathComponent(candidateName, isDirectory: false)
            if fileManager.fileExists(atPath: candidate.path) == false {
                return candidate
            }
        }
        return directory.appendingPathComponent(UUID().uuidString + "-" + fileName, isDirectory: false)
    }
    #endif

    func read<Value>(_ block: @Sendable (ModelContext) throws -> Value) throws -> Value {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return try block(context)
    }

    func write<Value>(_ block: @Sendable (ModelContext) throws -> Value) throws -> Value {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let value = try block(context)
        if context.hasChanges {
            try context.save()
        }
        return value
    }

    func transaction<Value: Sendable>(
        id: String = UUID().uuidString,
        writeScope: AppUnitOfWorkWriteScope = .localSwiftDataSingleContext,
        timestampProvider: @Sendable () -> String = { ISO8601DateFormatter().string(from: .now) },
        _ block: @Sendable (ModelContext) throws -> Value
    ) throws -> AppUnitOfWorkResult<Value> {
        let startedAt = timestampProvider()
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let value = try block(context)
        let didCommitChanges = context.hasChanges
        if didCommitChanges {
            try context.save()
        }
        return AppUnitOfWorkResult(
            value: value,
            receipt: AppUnitOfWorkReceipt(
                id: id,
                startedAt: startedAt,
                completedAt: timestampProvider(),
                writeScope: writeScope,
                didCommitChanges: didCommitChanges,
                rollbackBehavior: AppUnitOfWorkReceipt.rollbackOnThrownError,
                sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects
            )
        )
    }

    func resetAllData() throws {
        let context = ModelContext(container)
        context.autosaveEnabled = false

        try context.fetch(FetchDescriptor<StepRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<PlanSectionRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<GoalPlanRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<GoalRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<GoalDraftRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<ProgressEvidenceRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<FeedbackEventRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<CaptureRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<ReminderRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<TeachingSignalRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<EventLedgerRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<CommandExecutionRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<AppStateRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<LifeContextBundleRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<AmbitionGraphProjectionRecordModel>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<AmbitionGraphProofRecordModel>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<AmbitionGraphOperationalRecordModel>()).forEach(context.delete)

        if context.hasChanges {
            try context.save()
        }
    }
}

extension AmbitionsPersistenceStore {
    nonisolated func healthReport(
        checker: StoreHealthCheck = StoreHealthCheck()
    ) async -> StoreHealthReport {
        await checker.check(store: self)
    }
}

struct SwiftDataAppUnitOfWork: Sendable {
    let store: AmbitionsPersistenceStore

    func perform<Value: Sendable>(
        id: String = UUID().uuidString,
        writeScope: AppUnitOfWorkWriteScope = .localSwiftDataSingleContext,
        timestampProvider: @Sendable () -> String = { ISO8601DateFormatter().string(from: .now) },
        _ operation: @Sendable (ModelContext) throws -> Value
    ) async throws -> AppUnitOfWorkResult<Value> {
        try await store.transaction(
            id: id,
            writeScope: writeScope,
            timestampProvider: timestampProvider,
            operation
        )
    }
}

enum PersistenceError: LocalizedError {
    case invalidStoredValue(String)

    var errorDescription: String? {
        switch self {
        case let .invalidStoredValue(message):
            return message
        }
    }
}
