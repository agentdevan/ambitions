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
    static let schema = Schema([
        GoalRecord.self,
        GoalDraftRecord.self,
        GoalPlanRecord.self,
        PlanSectionRecord.self,
        StepRecord.self,
        ProgressEvidenceRecord.self,
        FeedbackEventRecord.self,
        CaptureRecord.self,
        TeachingSignalRecord.self,
        AppStateRecord.self,
    ])

    private let container: ModelContainer

    init(inMemory: Bool) throws {
        let configuration = ModelConfiguration(
            schema: Self.schema,
            isStoredInMemoryOnly: inMemory
        )
        container = try ModelContainer(for: Self.schema, configurations: configuration)
    }

    func read<Value>(_ block: (ModelContext) throws -> Value) throws -> Value {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return try block(context)
    }

    func write<Value>(_ block: (ModelContext) throws -> Value) throws -> Value {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let value = try block(context)
        if context.hasChanges {
            try context.save()
        }
        return value
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
        try context.fetch(FetchDescriptor<TeachingSignalRecord>()).forEach(context.delete)
        try context.fetch(FetchDescriptor<AppStateRecord>()).forEach(context.delete)

        if context.hasChanges {
            try context.save()
        }
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
