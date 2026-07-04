import Foundation
import SwiftData

let objectStoreSwiftDataSchemaVersion = "object_store_swiftdata.native.v1"

enum ObjectStoreSwiftDataFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalThread = "goal_thread"
    case goalDraft = "goal_draft"
    case goalPlan = "goal_plan"
    case step = "step"
    case capture = "capture"
    case proof = "proof"
    case receipt = "receipt"
    case teachingSignal = "teaching_signal"
    case eventLedger = "event_ledger"
    case sideEffectLedger = "side_effect_ledger"
    case runtimeSnapshot = "runtime_snapshot"
    case lifeContext = "life_context"
    case appState = "app_state"
}

enum ObjectStoreFieldAuthority: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case queryColumn = "query_column"
    case encodedValue = "encoded_value"
    case snapshotFallback = "snapshot_fallback"
}

struct ObjectStoreSwiftDataFieldRule: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let storedTypeName: String
    let fieldName: String
    let authority: ObjectStoreFieldAuthority
    let encodedTypeName: String?
    let notes: String

    init(
        storedTypeName: String,
        fieldName: String,
        authority: ObjectStoreFieldAuthority,
        encodedTypeName: String? = nil,
        notes: String
    ) {
        self.storedTypeName = storedTypeName
        self.fieldName = fieldName
        self.authority = authority
        self.encodedTypeName = encodedTypeName?.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty
        self.notes = notes
        id = "\(storedTypeName).\(fieldName).\(authority.rawValue)"
    }
}

struct ObjectStoreSwiftDataFamilyDescriptor: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: ObjectStoreSwiftDataFamily
    let storedTypeNames: [String]
    let mutationAuthority: String
    let privacyOwner: String
    let fieldRules: [ObjectStoreSwiftDataFieldRule]

    init(
        id: ObjectStoreSwiftDataFamily,
        storedTypeNames: [String],
        mutationAuthority: String,
        privacyOwner: String = "Core/LocalRuntimeOS/PrivacySecurity",
        fieldRules: [ObjectStoreSwiftDataFieldRule]
    ) {
        self.id = id
        self.storedTypeNames = Self.orderedUnique(storedTypeNames)
        self.mutationAuthority = mutationAuthority
        self.privacyOwner = privacyOwner
        self.fieldRules = fieldRules.sorted { $0.id < $1.id }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct ObjectStoreSwiftDataManifest: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let storageTier: LocalRuntimeStorageTier
    let storedModelNames: [String]
    let families: [ObjectStoreSwiftDataFamilyDescriptor]
    let swiftDataIsCanonicalBackend: Bool

    init(
        schemaVersion: String = objectStoreSwiftDataSchemaVersion,
        storedModelNames: [String],
        families: [ObjectStoreSwiftDataFamilyDescriptor],
        swiftDataIsCanonicalBackend: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        storageTier = .objectStoreSwiftData
        self.storedModelNames = Array(Set(storedModelNames)).sorted()
        self.families = families.sorted { $0.id.rawValue < $1.id.rawValue }
        self.swiftDataIsCanonicalBackend = swiftDataIsCanonicalBackend
    }
}

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

    static let objectStoreManifest = ObjectStoreSwiftDataManifest(
        storedModelNames: Array(storedModelNames),
        families: [
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .goalThread,
                storedTypeNames: ["GoalRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/Commands + Transactions + EventJournal",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalRecord", fieldName: "id", authority: .queryColumn, notes: "Stable local object identity and direct lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalRecord", fieldName: "stateRaw", authority: .queryColumn, notes: "Queryable lifecycle state used for bounded surface reads."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalRecord", fieldName: "planningStrategyData", authority: .encodedValue, encodedTypeName: "PlanningStrategy", notes: "Typed encoded payload owned by repository mapping."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalRecord", fieldName: "progressStrategyData", authority: .encodedValue, encodedTypeName: "ProgressStrategy", notes: "Typed encoded payload owned by repository mapping."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "Goal", notes: "Whole-object fallback for decode resilience, not the query authority for indexed columns.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .goalDraft,
                storedTypeNames: ["GoalDraftRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/CaptureRouteGraph + Transactions",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalDraftRecord", fieldName: "id", authority: .queryColumn, notes: "Stable draft identity."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalDraftRecord", fieldName: "plannedGoalID", authority: .queryColumn, notes: "Promotion lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalDraftRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "PersistedGoalDraft", notes: "Whole-draft decode fallback.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .goalPlan,
                storedTypeNames: ["GoalPlanRecord", "PlanSectionRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/PlanningEngine + Transactions",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalPlanRecord", fieldName: "goalID", authority: .queryColumn, notes: "Goal-to-plan lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalPlanRecord", fieldName: "strategyData", authority: .encodedValue, encodedTypeName: "PlanningStrategy", notes: "Typed planning strategy payload."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "GoalPlanRecord", fieldName: "assumptionsData", authority: .encodedValue, encodedTypeName: "[PlanAssumption]", notes: "Typed local assumption payload."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "PlanSectionRecord", fieldName: "orderIndex", authority: .queryColumn, notes: "Plan section ordering column.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .step,
                storedTypeNames: ["StepRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/PlanningEngine + TimeEngine + Transactions",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "StepRecord", fieldName: "goalID", authority: .queryColumn, notes: "Goal-scoped step lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "StepRecord", fieldName: "stateRaw", authority: .queryColumn, notes: "Queryable step lifecycle column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "StepRecord", fieldName: "dependencyStepIDsData", authority: .encodedValue, encodedTypeName: "[String]", notes: "Typed dependency references."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "StepRecord", fieldName: "actionabilityData", authority: .encodedValue, encodedTypeName: "StepActionability", notes: "Typed actionability payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .capture,
                storedTypeNames: ["CaptureRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/CaptureRouteGraph + Transactions",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "CaptureRecord", fieldName: "id", authority: .queryColumn, notes: "Capture direct lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "CaptureRecord", fieldName: "linkedGoalID", authority: .queryColumn, notes: "Promotion reference column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "CaptureRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "Capture", notes: "Whole-capture fallback owned by repository mapping.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .proof,
                storedTypeNames: ["ProgressEvidenceRecord", "AmbitionGraphProofRecordModel"],
                mutationAuthority: "Core/LocalRuntimeOS/TrustSystem + EventJournal",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "ProgressEvidenceRecord", fieldName: "goalID", authority: .queryColumn, notes: "Proof lookup column."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "AmbitionGraphProofRecordModel", fieldName: "snapshotData", authority: .snapshotFallback, notes: "Proof projection fallback payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .receipt,
                storedTypeNames: ["ActionReceiptHistoryRecordModel", "RuntimeSnapshotLedgerRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/TrustSystem + ProjectionEngine",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "receiptData", authority: .encodedValue, encodedTypeName: "ActionReceipt", notes: "Typed receipt payload."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "runtimeLineageData", authority: .encodedValue, encodedTypeName: "RuntimeTrustLineage", notes: "Runtime commit receipt lineage tying receipt history to transaction, event, rollback, and replay proof."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "RuntimeSnapshotLedgerRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "RuntimeSnapshotLedgerEnvelope", notes: "Replay-validation payload fallback.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .teachingSignal,
                storedTypeNames: ["TeachingSignalRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/PrivateLifeRuntimeKernel",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "TeachingSignalRecord", fieldName: "goalID", authority: .queryColumn, notes: "Goal-scoped local teaching signal lookup."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "TeachingSignalRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "GoalTeachingSignal", notes: "User-approved teaching signal payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .eventLedger,
                storedTypeNames: ["EventLedgerRecord", "CommandExecutionRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/Commands + EventJournal + TrustSystem",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "EventLedgerRecord", fieldName: "kindRaw", authority: .queryColumn, notes: "Trust/history event kind lookup."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "CommandExecutionRecord", fieldName: "commandData", authority: .encodedValue, encodedTypeName: "AmbitionsCommand", notes: "Durable command payload."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "CommandExecutionRecord", fieldName: "resultData", authority: .encodedValue, encodedTypeName: "AmbitionsCommandExecutionResult", notes: "Durable command result payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .sideEffectLedger,
                storedTypeNames: ["SideEffectLedgerStorageRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/SideEffectSystem",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "effectKindRaw", authority: .queryColumn, notes: "Effect outbox kind lookup."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "SideEffectLedgerRecord", notes: "Full side-effect receipt payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .runtimeSnapshot,
                storedTypeNames: ["RuntimeSnapshotLedgerRecord", "AmbitionGraphProjectionRecordModel", "AmbitionGraphOperationalRecordModel"],
                mutationAuthority: "Core/LocalRuntimeOS/ProjectionEngine + TrustSystem",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "AmbitionGraphProjectionRecordModel", fieldName: "snapshotData", authority: .snapshotFallback, notes: "Projection payload fallback."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "AmbitionGraphOperationalRecordModel", fieldName: "snapshotData", authority: .snapshotFallback, notes: "Operational read-model fallback.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .lifeContext,
                storedTypeNames: ["LifeContextBundleRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/PrivateLifeRuntimeKernel",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "LifeContextBundleRecord", fieldName: "id", authority: .queryColumn, notes: "Life context bundle lookup."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "LifeContextBundleRecord", fieldName: "snapshotData", authority: .snapshotFallback, encodedTypeName: "LifeContextBundle", notes: "Local life-context bundle payload.")
                ]
            ),
            ObjectStoreSwiftDataFamilyDescriptor(
                id: .appState,
                storedTypeNames: ["AppStateRecord", "ReminderRecord"],
                mutationAuthority: "Core/LocalRuntimeOS/Commands + ObjectState",
                fieldRules: [
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "AppStateRecord", fieldName: "preferredTabRaw", authority: .queryColumn, notes: "Current canonical surface preference."),
                    ObjectStoreSwiftDataFieldRule(storedTypeName: "ReminderRecord", fieldName: "deliveryPolicyData", authority: .encodedValue, encodedTypeName: "ReminderDeliveryPolicy", notes: "Typed local reminder delivery policy.")
                ]
            )
        ]
    )

    private let container: ModelContainer

    init(inMemory: Bool, persistentStoreURL: URL? = nil) throws {
        try self.init(
            inMemory: inMemory,
            persistentStoreURL: persistentStoreURL,
            legacyPersistentStoreURL: Self.legacyAppGroupPersistentStoreURL()
        )
    }

    init(
        inMemory: Bool,
        persistentStoreURL: URL?,
        legacyPersistentStoreURL: URL? = nil
    ) throws {
        do {
            container = try Self.makeContainer(
                inMemory: inMemory,
                persistentStoreURL: persistentStoreURL,
                legacyPersistentStoreURL: legacyPersistentStoreURL
            )
        } catch {
            #if DEBUG
            guard inMemory == false else {
                throw error
            }

            try Self.quarantineIncompatiblePersistentStores(after: error, persistentStoreURL: persistentStoreURL)
            container = try Self.makeContainer(
                inMemory: false,
                persistentStoreURL: persistentStoreURL,
                legacyPersistentStoreURL: legacyPersistentStoreURL
            )
            #else
            throw error
            #endif
        }
    }

    static func defaultPersistentStoreURL(fileManager: FileManager = .default) throws -> URL {
        guard let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }
        return supportDirectory.appendingPathComponent("default.store", isDirectory: false)
    }

    private static func makeContainer(
        inMemory: Bool,
        persistentStoreURL: URL?,
        legacyPersistentStoreURL: URL?
    ) throws -> ModelContainer {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(
                schema: Self.schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else {
            let storeURL = try persistentStoreURL ?? defaultPersistentStoreURL()
            try migrateLegacyAppGroupPersistentStoreIfNeeded(
                to: storeURL,
                legacyStoreURL: legacyPersistentStoreURL
            )
            try preparePersistentStoreParentDirectory(for: storeURL)
            configuration = ModelConfiguration(
                schema: Self.schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: Self.schema, configurations: configuration)
    }

    static func preparePersistentStoreParentDirectory(
        for storeURL: URL,
        fileManager: FileManager = .default
    ) throws {
        try fileManager.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    #if DEBUG
    /// SwiftData can fail to open the development simulator store after rapid schema iteration.
    /// In DEBUG only, move the incompatible local store files into Application Support so the app can
    /// recreate a clean local store instead of trapping at launch. Release builds never auto-reset data.
    private static func quarantineIncompatiblePersistentStores(after error: any Error, persistentStoreURL: URL?) throws {
        let fileManager = FileManager.default
        let timestamp = ISO8601DateFormatter()
            .string(from: .now)
            .replacingOccurrences(of: ":", with: "-")
        let quarantineDirectory = try quarantineDirectory(named: "swiftdata-launch-recovery-\(timestamp)", fileManager: fileManager)
        let candidates = persistentStoreCandidateURLs(fileManager: fileManager, persistentStoreURL: persistentStoreURL)
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

    private static func persistentStoreCandidateURLs(fileManager: FileManager, persistentStoreURL: URL?) -> [URL] {
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

        let defaultCandidates = baseDirectories.flatMap { directory in
            fileNames.map { directory.appendingPathComponent($0, isDirectory: false) }
        }
        return uniqueURLs(defaultCandidates + persistentStoreSidecarURLs(for: persistentStoreURL))
    }

    private static func uniqueURLs(_ urls: [URL]) -> [URL] {
        var seen = Set<String>()
        var unique: [URL] = []
        for url in urls {
            let path = url.standardizedFileURL.path
            if seen.insert(path).inserted {
                unique.append(url)
            }
        }
        return unique
    }

    private static func quarantineDirectory(named name: String, fileManager: FileManager) throws -> URL {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
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

typealias ObjectStoreSwiftData = AmbitionsPersistenceStore

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
