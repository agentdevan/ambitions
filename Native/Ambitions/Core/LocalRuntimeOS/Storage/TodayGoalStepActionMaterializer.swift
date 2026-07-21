import Foundation
import SwiftData

enum TodayGoalStepActionFailurePoint: Sendable, Equatable {
    case none
    case afterFeedback
    case afterEvidence
    case afterCapture
}

enum TodayGoalStepActionStorageError: Error, Equatable {
    case injectedFailure(TodayGoalStepActionFailurePoint)
}

struct SwiftDataTodayGoalStepActionMaterializer: TodayGoalStepActionMaterializing {
    let store: AmbitionsPersistenceStore
    var failurePoint: TodayGoalStepActionFailurePoint = .none

    func validate(_ plan: TodayGoalStepActionPlan) async throws {
        guard plan.shouldWriteGoal else { return }
        let current = try await SwiftDataGoalRepository(store: store).goal(id: plan.goalID)
        guard let current else { return }
        guard current.revision == plan.expectedGoalRevision || current == plan.updatedGoal else {
            throw TodayDurableActionMaterializationError.staleGoalRevision(
                expected: plan.expectedGoalRevision,
                actual: current.revision
            )
        }
    }

    func materialize(_ plan: TodayGoalStepActionPlan) async throws {
        _ = try await store.transaction(id: "today-goal-step-action-\(plan.goalID)-\(plan.stepID)") { context in
            let goalToSave: Goal?
            if plan.shouldWriteGoal {
                let currentGoal = try loadGoal(id: plan.goalID, context: context)
                goalToSave = try convergedGoal(current: currentGoal, plan: plan)
            } else {
                goalToSave = nil
            }

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
                throw TodayGoalStepActionStorageError.injectedFailure(.afterFeedback)
            }

            let evidenceByID = Dictionary(uniqueKeysWithValues:
                try context.fetch(FetchDescriptor<ProgressEvidenceRecord>()).map { ($0.id, $0) }
            )
            for evidence in plan.evidence {
                if let old = evidenceByID[evidence.id] { context.delete(old) }
                context.insert(try RepositoryMapping.evidenceRecord(from: evidence))
            }
            if failurePoint == .afterEvidence {
                throw TodayGoalStepActionStorageError.injectedFailure(.afterEvidence)
            }

            if let capture = plan.capture {
                try SwiftDataCapturePersistence.saveCaptures([capture], in: context)
            }
            if failurePoint == .afterCapture {
                throw TodayGoalStepActionStorageError.injectedFailure(.afterCapture)
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
        let plans = try context.fetch(FetchDescriptor<GoalPlanRecord>())
        let sections = try context.fetch(FetchDescriptor<PlanSectionRecord>())
        let steps = try context.fetch(FetchDescriptor<StepRecord>())
        let planMap = try repository.composePlanMap(
            planRecords: plans,
            sectionRecords: sections,
            stepRecords: steps,
            includeSnapshotFallback: true
        )
        return try RepositoryMapping.goal(from: record, plan: planMap[id], includeSnapshotFallback: true)
    }

    private func convergedGoal(current: Goal?, plan: TodayGoalStepActionPlan) throws -> Goal? {
        guard let current else { return plan.updatedGoal }
        if current == plan.updatedGoal { return nil }
        if current.revision == plan.expectedGoalRevision { return plan.updatedGoal }

        guard let committedStep = plan.updatedGoal.plan?.sections.flatMap(\.steps).first(where: { $0.id == plan.stepID }) else {
            throw TodayDurableActionMaterializationError.staleGoalRevision(
                expected: plan.expectedGoalRevision,
                actual: current.revision
            )
        }
        return replacingStep(in: current, with: committedStep, updatedAt: plan.updatedGoal.updatedAt)
    }

    private func replacingStep(in goal: Goal, with committedStep: Step, updatedAt: String) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id, goalID: section.goalID, title: section.title, summary: section.summary,
                kind: section.kind, orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == committedStep.id ? committedStep : $0 }
            )
        }
        let updatedPlan = goal.plan.map {
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
            plan: updatedPlan, lifeGraph: goal.lifeGraph
        )
    }
}
