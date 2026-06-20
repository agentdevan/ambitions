import AmbitionsDesignSystem
import Foundation
import SwiftData

enum SwiftDataGoalPersistence {
    static func saveGoals(_ goals: [Goal], in context: ModelContext) throws {
        let goalIndex = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalRecord>()).map { ($0.id, $0) })
        let planRecords = try context.fetch(FetchDescriptor<GoalPlanRecord>())
        let sectionRecords = try context.fetch(FetchDescriptor<PlanSectionRecord>())
        let stepRecords = try context.fetch(FetchDescriptor<StepRecord>())

        try saveGoals(
            goals,
            in: context,
            goalIndex: goalIndex,
            planRecords: planRecords,
            sectionRecords: sectionRecords,
            stepRecords: stepRecords
        )
    }

    static func saveGoals(
        _ goals: [Goal],
        in context: ModelContext,
        goalIndex: [String: GoalRecord],
        planRecords: [GoalPlanRecord],
        sectionRecords: [PlanSectionRecord],
        stepRecords: [StepRecord]
    ) throws {
        for goal in goals {
            if let record = goalIndex[goal.id] {
                try RepositoryMapping.apply(goal, to: record)
            } else {
                context.insert(try RepositoryMapping.goalRecord(from: goal))
            }

            for step in stepRecords where step.goalID == goal.id {
                context.delete(step)
            }
            for section in sectionRecords where section.goalID == goal.id {
                context.delete(section)
            }
            for plan in planRecords where plan.goalID == goal.id {
                context.delete(plan)
            }

            guard let plan = goal.plan else { continue }
            context.insert(try RepositoryMapping.planRecord(from: plan))
            for section in plan.sections {
                context.insert(RepositoryMapping.sectionRecord(from: section, planID: plan.id))
                for (index, step) in section.steps.enumerated() {
                    context.insert(try RepositoryMapping.stepRecord(from: step, goalID: goal.id, planID: plan.id, orderIndex: index))
                }
            }
        }
    }
}

enum SwiftDataGoalDraftPersistence {
    static func saveDrafts(_ drafts: [PersistedGoalDraft], in context: ModelContext) throws {
        let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalDraftRecord>()).map { ($0.id, $0) })
        try saveDrafts(drafts, in: context, existing: existing)
    }

    static func saveDrafts(
        _ drafts: [PersistedGoalDraft],
        in context: ModelContext,
        existing: [String: GoalDraftRecord]
    ) throws {
        for draft in drafts {
            if let record = existing[draft.id] {
                record.createdAt = draft.createdAt
                record.updatedAt = draft.updatedAt
                record.title = draft.draft.title
                record.modeRaw = draft.draft.mode.rawValue
                record.resultKindRaw = draft.latestResultKind?.rawValue
                record.readinessRaw = draft.clarification?.readiness.rawValue
                record.plannedGoalID = draft.plannedGoalID
                record.snapshotData = try PersistenceCoding.encode(draft)
            } else {
                context.insert(try RepositoryMapping.draftRecord(from: draft))
            }
        }
    }
}

struct SwiftDataProgressEvidenceRepository: ProgressEvidenceRepository {
    let store: AmbitionsPersistenceStore

    func listEvidence(goalID: String?) async throws -> [ProgressEvidence] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<ProgressEvidenceRecord>())
                .filter { goalID == nil || $0.goalID == goalID }
                .sorted {
                    if $0.capturedAt != $1.capturedAt {
                        return $0.capturedAt > $1.capturedAt
                    }
                    return $0.id < $1.id
                }
                .map(RepositoryMapping.evidence(from:))
        }
    }

    func saveEvidence(_ evidence: [ProgressEvidence]) async throws {
        try await store.write { context in
            let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<ProgressEvidenceRecord>()).map { ($0.id, $0) })
            for item in evidence {
                if let record = existing[item.id] {
                    record.goalID = item.goalID
                    record.stepID = item.stepID
                    record.capturedAt = item.capturedAt
                    record.evidenceKindRaw = item.evidenceKind.rawValue
                    record.sourceRaw = item.source.rawValue
                    record.progressDelta = item.progressDelta
                    record.confidenceDelta = item.confidenceDelta
                    record.minutesInvested = item.minutesInvested
                    record.note = item.note
                    record.snapshotData = try PersistenceCoding.encode(item)
                } else {
                    context.insert(try RepositoryMapping.evidenceRecord(from: item))
                }
            }
        }
    }
}

struct SwiftDataFeedbackEventRepository: FeedbackEventRepository {
    let store: AmbitionsPersistenceStore

    func listEvents(goalID: String?) async throws -> [GoalFeedbackEvent] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<FeedbackEventRecord>())
                .filter { goalID == nil || $0.goalID == goalID }
                .sorted {
                    let lhsDate = PersistedTemporalValue.date(from: $0.occurredAt)
                    let rhsDate = PersistedTemporalValue.date(from: $1.occurredAt)
                    if lhsDate != rhsDate { return lhsDate > rhsDate }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.feedback(from:))
        }
    }

    func saveEvents(_ events: [GoalFeedbackEvent], goalID: String) async throws {
        try await store.write { context in
            for record in try context.fetch(FetchDescriptor<FeedbackEventRecord>()) where record.goalID == goalID {
                context.delete(record)
            }
            for event in events {
                context.insert(try RepositoryMapping.feedbackRecord(from: event, goalID: goalID))
            }
        }
    }
}

struct SwiftDataCaptureRepository: CaptureRepository {
    let store: AmbitionsPersistenceStore

    func listCaptures() async throws -> [Capture] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<CaptureRecord>())
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id < $1.id
                }
                .bounded(to: RepositoryQueryBudget.maxCaptureListResults)
                .map(RepositoryMapping.capture(from:))
        }
    }

    func capture(id: String) async throws -> Capture? {
        try await listCaptures().first(where: { $0.id == id })
    }

    func saveCaptures(_ captures: [Capture]) async throws {
        try await store.write { context in
            try SwiftDataCapturePersistence.saveCaptures(captures, in: context)
        }
    }
}

enum SwiftDataCapturePersistence {
    static func saveCaptures(_ captures: [Capture], in context: ModelContext) throws {
        let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<CaptureRecord>()).map { ($0.id, $0) })
        for capture in captures {
            if let record = existing[capture.id] {
                record.createdAt = capture.createdAt
                record.updatedAt = capture.updatedAt
                record.rawText = capture.rawText
                record.sourceTypeRaw = capture.sourceType?.rawValue
                record.statusRaw = capture.status.rawValue
                record.linkedGoalID = capture.linkedGoalID
                record.snapshotData = try PersistenceCoding.encode(capture)
            } else {
                context.insert(try RepositoryMapping.captureRecord(from: capture))
            }
        }
    }
}

struct SwiftDataGoalTeachingSignalRepository: GoalTeachingSignalRepository {
    let store: AmbitionsPersistenceStore

    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<TeachingSignalRecord>())
                .filter { goalID == nil || $0.goalID == goalID }
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.teachingSignal(from:))
        }
    }

    func saveSignals(_ signals: [GoalTeachingSignal]) async throws {
        try await store.write { context in
            let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<TeachingSignalRecord>()).map { ($0.id, $0) })
            for signal in signals {
                if let record = existing[signal.id] {
                    record.goalID = signal.goalID
                    record.kindRaw = signal.kind.rawValue
                    record.sourceRaw = signal.source.rawValue
                    record.dispositionRaw = signal.disposition.rawValue
                    record.applicationKey = signal.applicationKey
                    record.createdAt = signal.createdAt
                    record.updatedAt = signal.updatedAt
                    record.snapshotData = try PersistenceCoding.encode(signal)
                } else {
                    context.insert(try RepositoryMapping.teachingSignalRecord(from: signal))
                }
            }
        }
    }
}

struct SwiftDataAmbitionGraphOperationalRecordRepository: AmbitionGraphOperationalRecordRepository {
    let store: AmbitionsPersistenceStore

    func save(_ records: [AmbitionGraphOperationalRecord]) async throws {
        try await store.write { context in
            let persisted = Dictionary(
                uniqueKeysWithValues: try context.fetch(FetchDescriptor<AmbitionGraphOperationalRecordModel>()).map { ($0.id, $0) }
            )

            for record in records {
                if let current = persisted[record.id] {
                    try RepositoryMapping.apply(record, to: current)
                } else {
                    context.insert(try RepositoryMapping.ambitionGraphOperationalRecordModel(from: record))
                }
            }
        }
    }

    func fetchRecords(
        surface: AmbitionGraphProjectionSurface?,
        snapshotID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphOperationalRecord] {
        try await store.read { context in
            let records = try context.fetch(FetchDescriptor<AmbitionGraphOperationalRecordModel>())
                .filter { model in
                    if let surface, model.surfaceRaw != surface.rawValue {
                        return false
                    }
                    if let snapshotID, model.sourceSnapshotID != snapshotID {
                        return false
                    }
                    return true
                }
                .sorted {
                    if $0.generatedAt != $1.generatedAt {
                        return $0.generatedAt > $1.generatedAt
                    }
                    return $0.id < $1.id
                }

            let bounded = limit.map { max(0, $0) } ?? records.count
            return try records
                .prefix(bounded)
                .map(RepositoryMapping.ambitionGraphOperationalRecord(from:))
        }
    }
}

struct SwiftDataAmbitionGraphProofRecordRepository: AmbitionGraphProofRecordRepository {
    let store: AmbitionsPersistenceStore

    func append(_ record: AmbitionGraphProofRecord) async throws {
        try await store.write { context in
            let existing = try context.fetch(FetchDescriptor<AmbitionGraphProofRecordModel>())
                .filter { $0.proofID == record.proofID }
            let nextVersion = (existing.map(\.version).max() ?? 0) + 1
            let latestID = existing
                .sorted {
                    if $0.version != $1.version { return $0.version > $1.version }
                    return $0.id > $1.id
                }
                .first?
                .id
            let versionedRecord = record.versioned(nextVersion: nextVersion, supersedesProofID: latestID)
            context.insert(try RepositoryMapping.ambitionGraphProofRecordModel(from: versionedRecord))
        }
    }

    func fetchRecords(
        proofID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphProofRecord] {
        try await store.read { context in
            let records = try context.fetch(FetchDescriptor<AmbitionGraphProofRecordModel>())
                .filter { model in
                    if let proofID, model.proofID != proofID {
                        return false
                    }
                    return true
                }
                .sorted {
                    if $0.version != $1.version { return $0.version > $1.version }
                    if $0.generatedAt != $1.generatedAt { return $0.generatedAt > $1.generatedAt }
                    return $0.id < $1.id
                }

            let bounded = limit.map { max(0, $0) } ?? records.count
            return try records
                .prefix(bounded)
                .map(RepositoryMapping.ambitionGraphProofRecord(from:))
        }
    }
}
