import AmbitionsDesignSystem
import Foundation
import SwiftData

extension Array where Element == Step {
    func sortedForActionability() -> [Step] {
        sorted { lhs, rhs in
            let lhsKey = lhs.timing.dueAt ?? lhs.timing.targetBy ?? lhs.timing.suggestedNextAt ?? lhs.timing.startsOn ?? "9999-12-31T23:59:59Z"
            let rhsKey = rhs.timing.dueAt ?? rhs.timing.targetBy ?? rhs.timing.suggestedNextAt ?? rhs.timing.startsOn ?? "9999-12-31T23:59:59Z"
            if lhsKey != rhsKey { return lhsKey < rhsKey }
            if lhs.title != rhs.title { return lhs.title < rhs.title }
            return lhs.id < rhs.id
        }
    }
}

enum RepositoryQueryBudget {
    static let maxGoalListResults = 500
    static let maxActionableStepResults = 500
    static let maxCaptureListResults = 500
    static let maxReminderListResults = 500

    static var majorSurfaceReadBudgets: [AFEPQueryBudgetDescriptor] {
        AFEPQueryBudgetCatalog.majorSurfaceReadBudgets
    }

    static var projectionReadBudgets: [AFEPQueryBudgetDescriptor] {
        AFEPQueryBudgetCatalog.projectionReadBudgets
    }

    static var allBudgets: [AFEPQueryBudgetDescriptor] {
        AFEPQueryBudgetCatalog.all
    }
}

extension Array {
    func bounded(to limit: Int) -> [Element] {
        Array(prefix(Swift.max(0, limit)))
    }
}

struct SwiftDataGoalRepository: GoalRepository {
    let store: AmbitionsPersistenceStore

    func listGoals() async throws -> [Goal] {
        try await store.read { context in
            let goals = try context.fetch(FetchDescriptor<GoalRecord>())
            let plans = try context.fetch(FetchDescriptor<GoalPlanRecord>())
            let sections = try context.fetch(FetchDescriptor<PlanSectionRecord>())
            let steps = try context.fetch(FetchDescriptor<StepRecord>())
            let planMap = try composePlanMap(planRecords: plans, sectionRecords: sections, stepRecords: steps)

            return try goals
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id < $1.id
                }
                .bounded(to: RepositoryQueryBudget.maxGoalListResults)
                .map { try RepositoryMapping.goal(from: $0, plan: planMap[$0.id]) }
        }
    }

    func listHabitGoals() async throws -> [Goal] {
        try await listGoals().filter { goal in
            if [.habit, .maintenance, .recovery].contains(goal.mode) {
                return true
            }
            return goal.timing.tempo == .ongoing && goal.state != .completed && goal.state != .archived
        }
    }

    func goal(id: String) async throws -> Goal? {
        try await store.read { context in
            guard let goal = try context.fetch(FetchDescriptor<GoalRecord>()).first(where: { $0.id == id }) else {
                return nil
            }
            let plans = try context.fetch(FetchDescriptor<GoalPlanRecord>())
            let sections = try context.fetch(FetchDescriptor<PlanSectionRecord>())
            let steps = try context.fetch(FetchDescriptor<StepRecord>())
            let planMap = try composePlanMap(
                planRecords: plans,
                sectionRecords: sections,
                stepRecords: steps,
                includeSnapshotFallback: true
            )
            return try RepositoryMapping.goal(from: goal, plan: planMap[goal.id], includeSnapshotFallback: true)
        }
    }

    func saveGoals(_ goals: [Goal]) async throws {
        try await store.write { context in
            let goalIndex = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalRecord>()).map { ($0.id, $0) })
            let planRecords = try context.fetch(FetchDescriptor<GoalPlanRecord>())
            let sectionRecords = try context.fetch(FetchDescriptor<PlanSectionRecord>())
            let stepRecords = try context.fetch(FetchDescriptor<StepRecord>())

            try SwiftDataGoalPersistence.saveGoals(
                goals,
                in: context,
                goalIndex: goalIndex,
                planRecords: planRecords,
                sectionRecords: sectionRecords,
                stepRecords: stepRecords
            )
        }
    }

    func deleteGoal(id: String) async throws {
        try await store.write { context in
            for goal in try context.fetch(FetchDescriptor<GoalRecord>()) where goal.id == id { context.delete(goal) }
            for plan in try context.fetch(FetchDescriptor<GoalPlanRecord>()) where plan.goalID == id { context.delete(plan) }
            for section in try context.fetch(FetchDescriptor<PlanSectionRecord>()) where section.goalID == id { context.delete(section) }
            for step in try context.fetch(FetchDescriptor<StepRecord>()) where step.goalID == id { context.delete(step) }
        }
    }

    func listActionableSteps() async throws -> [Step] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<StepRecord>())
                .map { try RepositoryMapping.step(from: $0) }
                .filter { $0.state != .completed && $0.state != .cancelled }
                .sortedForActionability()
                .bounded(to: RepositoryQueryBudget.maxActionableStepResults)
        }
    }

    func listSteps(goalID: String) async throws -> [Step] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<StepRecord>())
                .filter { $0.goalID == goalID }
                .sorted {
                    if $0.sectionID != $1.sectionID { return $0.sectionID < $1.sectionID }
                    return $0.orderIndex < $1.orderIndex
                }
                .map { try RepositoryMapping.step(from: $0) }
        }
    }

    func composePlanMap(
        planRecords: [GoalPlanRecord],
        sectionRecords: [PlanSectionRecord],
        stepRecords: [StepRecord],
        includeSnapshotFallback: Bool = false
    ) throws -> [String: GoalPlan] {
        let stepsBySection = Dictionary(grouping: stepRecords, by: \.sectionID)
        let sectionsByPlan = Dictionary(grouping: sectionRecords, by: \.planID)
        var map: [String: GoalPlan] = [:]

        for planRecord in planRecords {
            let sections = try (sectionsByPlan[planRecord.id] ?? [])
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { sectionRecord in
                    let steps = try (stepsBySection[sectionRecord.id] ?? [])
                        .sorted { $0.orderIndex < $1.orderIndex }
                        .map { try RepositoryMapping.step(from: $0, includeSnapshotFallback: includeSnapshotFallback) }
                    return PlanSection(
                        id: sectionRecord.id,
                        goalID: sectionRecord.goalID,
                        title: sectionRecord.title,
                        summary: sectionRecord.summaryText,
                        kind: RepositoryMapping.persisted(
                            PlanSectionKind.self,
                            rawValue: sectionRecord.kindRaw,
                            fallback: .overview,
                            storedTypeName: "PlanSectionRecord",
                            fieldName: "kindRaw"
                        ),
                        orderIndex: sectionRecord.orderIndex,
                        steps: steps
                    )
                }
            map[planRecord.goalID] = try RepositoryMapping.plan(
                from: planRecord,
                sections: sections,
                includeSnapshotFallback: includeSnapshotFallback
            )
        }

        return map
    }
}

struct SwiftDataGoalDraftRepository: GoalDraftRepository {
    let store: AmbitionsPersistenceStore

    func listDrafts() async throws -> [PersistedGoalDraft] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<GoalDraftRecord>())
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id < $1.id
                }
                .map(RepositoryMapping.storedDraft(from:))
        }
    }

    func draft(id: String) async throws -> PersistedGoalDraft? {
        try await listDrafts().first(where: { $0.id == id })
    }

    func saveDrafts(_ drafts: [PersistedGoalDraft]) async throws {
        try await store.write { context in
            let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalDraftRecord>()).map { ($0.id, $0) })
            try SwiftDataGoalDraftPersistence.saveDrafts(drafts, in: context, existing: existing)
        }
    }

    func deleteDraft(id: String) async throws {
        try await store.write { context in
            for record in try context.fetch(FetchDescriptor<GoalDraftRecord>()) where record.id == id {
                context.delete(record)
            }
        }
    }
}

enum GoalCreationUnitOfWorkProbeError: Error, Equatable {
    case afterGoalWriteBeforeDraftWrite
}

enum GoalCreationUnitOfWorkFailureInjection: Sendable, Equatable {
    case afterGoalWriteBeforeDraftWrite
}

struct SwiftDataGoalCreationUnitOfWork: GoalCreationUnitOfWorking {
    let store: AmbitionsPersistenceStore
    let failureInjection: GoalCreationUnitOfWorkFailureInjection?

    init(
        store: AmbitionsPersistenceStore,
        failureInjection: GoalCreationUnitOfWorkFailureInjection? = nil
    ) {
        self.store = store
        self.failureInjection = failureInjection
    }

    func saveGoalCreation(
        _ payload: GoalCreationUnitOfWorkPayload,
        id: String = UUID().uuidString,
        timestampProvider: @Sendable () -> String = { ISO8601DateFormatter().string(from: .now) }
    ) async throws -> AppUnitOfWorkResult<GoalCreationUnitOfWorkCommit> {
        try await store.transaction(
            id: id,
            writeScope: .localSwiftDataSingleContext,
            timestampProvider: timestampProvider
        ) { context in
            if let goal = payload.goal {
                try SwiftDataGoalPersistence.saveGoals([goal], in: context)

                if failureInjection == .afterGoalWriteBeforeDraftWrite {
                    throw GoalCreationUnitOfWorkProbeError.afterGoalWriteBeforeDraftWrite
                }
            }

            try SwiftDataGoalDraftPersistence.saveDrafts([payload.draft], in: context)

            return GoalCreationUnitOfWorkCommit(
                goalID: payload.goal?.id,
                draftID: payload.draft.id,
                resultKind: payload.draft.latestResultKind
            )
        }
    }
}

enum CapturePromotionUnitOfWorkProbeError: Error, Equatable {
    case afterGoalDraftWriteBeforeCaptureWrite
}

enum CapturePromotionUnitOfWorkFailureInjection: Sendable, Equatable {
    case afterGoalDraftWriteBeforeCaptureWrite
}

struct SwiftDataCapturePromotionUnitOfWork: CapturePromotionUnitOfWorking {
    let store: AmbitionsPersistenceStore
    let failureInjection: CapturePromotionUnitOfWorkFailureInjection?

    init(
        store: AmbitionsPersistenceStore,
        failureInjection: CapturePromotionUnitOfWorkFailureInjection? = nil
    ) {
        self.store = store
        self.failureInjection = failureInjection
    }

    func saveCapturePromotion(
        _ payload: CapturePromotionUnitOfWorkPayload,
        id: String = UUID().uuidString,
        timestampProvider: @Sendable () -> String = { ISO8601DateFormatter().string(from: .now) }
    ) async throws -> AppUnitOfWorkResult<CapturePromotionUnitOfWorkCommit> {
        try await store.transaction(
            id: id,
            writeScope: .localSwiftDataSingleContext,
            timestampProvider: timestampProvider
        ) { context in
            try SwiftDataGoalPersistence.saveGoals([payload.goal], in: context)
            try SwiftDataGoalDraftPersistence.saveDrafts([payload.draft], in: context)

            if failureInjection == .afterGoalDraftWriteBeforeCaptureWrite {
                throw CapturePromotionUnitOfWorkProbeError.afterGoalDraftWriteBeforeCaptureWrite
            }

            try SwiftDataCapturePersistence.saveCaptures([payload.capture], in: context)

            return CapturePromotionUnitOfWorkCommit(
                goalID: payload.goal.id,
                draftID: payload.draft.id,
                captureID: payload.capture.id,
                resultKind: payload.draft.latestResultKind
            )
        }
    }
}
