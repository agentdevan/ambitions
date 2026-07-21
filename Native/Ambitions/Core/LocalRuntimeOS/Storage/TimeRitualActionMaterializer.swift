import Foundation
import SwiftData

enum TimeRitualActionFailurePoint: Sendable, Equatable {
    case none
    case afterFeedback
    case afterEvidence
}

enum TimeRitualActionStorageError: Error, Equatable {
    case injectedFailure(TimeRitualActionFailurePoint)
}

struct SwiftDataTimeRitualActionMaterializer: TimeRitualActionMaterializing {
    let store: AmbitionsPersistenceStore
    var failurePoint: TimeRitualActionFailurePoint = .none

    func validate(_ plan: TimeRitualActionPlan) async throws {
        let current = try await SwiftDataGoalRepository(store: store).goal(id: plan.goalID)
        guard let current else { throw TimeRitualDurableActionError.unavailable }
        guard current.plan?.sections.flatMap(\.steps).contains(where: { $0.id == plan.stepID }) == true else {
            throw TimeRitualDurableActionError.unavailable
        }
        guard current.revision == plan.expectedGoalRevision || current == plan.updatedGoal else {
            throw TimeRitualDurableActionError.staleGoalRevision(
                expected: plan.expectedGoalRevision,
                actual: current.revision
            )
        }
    }

    func materialize(_ plan: TimeRitualActionPlan) async throws {
        _ = try await store.transaction(id: "time-ritual-action-\(plan.goalID)-\(plan.stepID)") { context in
            guard let currentGoal = try loadGoal(id: plan.goalID, context: context),
                  currentGoal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == plan.stepID }) == true else {
                throw TimeRitualDurableActionError.unavailable
            }
            let goalToSave = plan.writesGoal ? convergedGoal(current: currentGoal, plan: plan) : nil

            var feedbackByID = Dictionary(uniqueKeysWithValues:
                try context.fetch(FetchDescriptor<FeedbackEventRecord>())
                    .filter { $0.goalID == plan.goalID }
                    .map { ($0.id, $0) }
            )
            for stored in plan.feedbackEvents {
                if let old = feedbackByID.removeValue(forKey: stored.event.base.id) {
                    context.delete(old)
                }
                context.insert(try RepositoryMapping.feedbackRecord(from: stored.event, goalID: plan.goalID))
            }
            if failurePoint == .afterFeedback {
                throw TimeRitualActionStorageError.injectedFailure(.afterFeedback)
            }

            let evidenceByID = Dictionary(uniqueKeysWithValues:
                try context.fetch(FetchDescriptor<ProgressEvidenceRecord>()).map { ($0.id, $0) }
            )
            for evidence in plan.evidence {
                if let old = evidenceByID[evidence.id] { context.delete(old) }
                context.insert(try RepositoryMapping.evidenceRecord(from: evidence))
            }
            if failurePoint == .afterEvidence {
                throw TimeRitualActionStorageError.injectedFailure(.afterEvidence)
            }

            guard let goalToSave else { return }
            let goalIndex = Dictionary(uniqueKeysWithValues:
                try context.fetch(FetchDescriptor<GoalRecord>()).map { ($0.id, $0) }
            )
            try SwiftDataGoalPersistence.saveGoals(
                [goalToSave],
                in: context,
                goalIndex: goalIndex,
                planRecords: try context.fetch(FetchDescriptor<GoalPlanRecord>()),
                sectionRecords: try context.fetch(FetchDescriptor<PlanSectionRecord>()),
                stepRecords: try context.fetch(FetchDescriptor<StepRecord>())
            )
        }
    }

    private func loadGoal(id: String, context: ModelContext) throws -> Goal? {
        guard let record = try context.fetch(FetchDescriptor<GoalRecord>()).first(where: { $0.id == id }) else {
            return nil
        }
        let repository = SwiftDataGoalRepository(store: store)
        let planMap = try repository.composePlanMap(
            planRecords: context.fetch(FetchDescriptor<GoalPlanRecord>()),
            sectionRecords: context.fetch(FetchDescriptor<PlanSectionRecord>()),
            stepRecords: context.fetch(FetchDescriptor<StepRecord>()),
            includeSnapshotFallback: true
        )
        return try RepositoryMapping.goal(from: record, plan: planMap[id], includeSnapshotFallback: true)
    }

    private func convergedGoal(current: Goal?, plan: TimeRitualActionPlan) -> Goal? {
        guard let current else { return plan.updatedGoal }
        if current == plan.updatedGoal { return nil }
        if current.revision == plan.expectedGoalRevision { return plan.updatedGoal }
        if plan.actionKind == .markNotRelevant {
            return copy(current, state: .paused, updatedAt: plan.updatedGoal.updatedAt)
        }
        guard let committedStep = plan.updatedGoal.plan?.sections
            .flatMap(\.steps).first(where: { $0.id == plan.stepID }) else { return nil }
        return replacingStep(in: current, with: committedStep, updatedAt: plan.updatedGoal.updatedAt)
    }

    private func replacingStep(in goal: Goal, with step: Step, updatedAt: String) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id, goalID: section.goalID, title: section.title, summary: section.summary,
                kind: section.kind, orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == step.id ? step : $0 }
            )
        }
        let plan = goal.plan.map {
            GoalPlan(
                id: $0.id, goalID: $0.goalID, version: $0.version, generatedAt: $0.generatedAt,
                summary: $0.summary, strategy: $0.strategy, sections: sections ?? $0.sections,
                assumptions: $0.assumptions, lint: $0.lint
            )
        }
        return Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1,
            createdAt: goal.createdAt, updatedAt: updatedAt, state: goal.state, title: goal.title,
            summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: plan, lifeGraph: goal.lifeGraph
        )
    }

    private func copy(_ goal: Goal, state: GoalLifecycleState, updatedAt: String) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1,
            createdAt: goal.createdAt, updatedAt: updatedAt, state: state, title: goal.title,
            summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: goal.plan, lifeGraph: goal.lifeGraph
        )
    }
}
