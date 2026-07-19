import AmbitionsDesignSystem
import Foundation
import SwiftData

extension RepositoryMapping {
    static func persisted<Value>(
        _ type: Value.Type,
        rawValue: String,
        fallback: Value,
        storedTypeName: String,
        fieldName: String,
        legacyAliases: [String: Value] = [:]
    ) -> Value where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        PersistedValueDegradation
            .resolve(
                type,
                rawValue: rawValue,
                fallback: fallback,
                storedTypeName: storedTypeName,
                fieldName: fieldName,
                legacyAliases: legacyAliases
            )
            .value
    }


    static func persistedOptional<Value>(
        _ type: Value.Type,
        rawValue: String?,
        storedTypeName: String,
        fieldName: String,
        legacyAliases: [String: Value] = [:]
    ) -> Value? where Value: RawRepresentable & Sendable & Equatable, Value.RawValue == String {
        PersistedValueDegradation
            .resolveOptional(
                type,
                rawValue: rawValue,
                storedTypeName: storedTypeName,
                fieldName: fieldName,
                legacyAliases: legacyAliases
            )
            .value
    }


    static func goalRecord(from goal: Goal) throws -> GoalRecord {
        GoalRecord(
            id: goal.id,
            schemaVersion: goal.schemaVersion,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            stateRaw: goal.state.rawValue,
            title: goal.title,
            summaryText: goal.summary,
            modeRaw: goal.mode.rawValue,
            relationshipKindRaw: goal.relationshipKind.rawValue,
            actorDisplayName: goal.actor.displayName,
            actorOwnershipRaw: goal.actor.ownership.rawValue,
            parentGoalID: goal.parentGoalID,
            childGoalIDsData: try PersistenceCoding.encode(goal.childGoalIDs),
            supportGoalIDsData: try PersistenceCoding.encode(goal.supportGoalIDs),
            tagsData: try PersistenceCoding.encode(goal.tags),
            tempoRaw: goal.timing.tempo.rawValue,
            timingTypeRaw: goal.timing.timingType.rawValue,
            startsOn: goal.timing.startsOn,
            dueAt: goal.timing.dueAt,
            targetBy: goal.timing.targetBy,
            windowStart: goal.timing.windowStart,
            windowEnd: goal.timing.windowEnd,
            suggestedNextAt: goal.timing.suggestedNextAt,
            repeatEveryDays: goal.timing.repeatEveryDays,
            progressReviewCadenceDays: goal.timing.progressReviewCadenceDays,
            planningStrategyData: try PersistenceCoding.encode(goal.planningStrategy),
            progressStrategyData: try PersistenceCoding.encode(goal.progressStrategy),
            snapshotData: try PersistenceCoding.encode(goal)
        )
    }


    static func apply(_ goal: Goal, to record: GoalRecord) throws {
        record.schemaVersion = goal.schemaVersion
        record.revision = goal.revision
        record.createdAt = goal.createdAt
        record.updatedAt = goal.updatedAt
        record.stateRaw = goal.state.rawValue
        record.title = goal.title
        record.summaryText = goal.summary
        record.modeRaw = goal.mode.rawValue
        record.relationshipKindRaw = goal.relationshipKind.rawValue
        record.actorDisplayName = goal.actor.displayName
        record.actorOwnershipRaw = goal.actor.ownership.rawValue
        record.parentGoalID = goal.parentGoalID
        record.childGoalIDsData = try PersistenceCoding.encode(goal.childGoalIDs)
        record.supportGoalIDsData = try PersistenceCoding.encode(goal.supportGoalIDs)
        record.tagsData = try PersistenceCoding.encode(goal.tags)
        record.tempoRaw = goal.timing.tempo.rawValue
        record.timingTypeRaw = goal.timing.timingType.rawValue
        record.startsOn = goal.timing.startsOn
        record.dueAt = goal.timing.dueAt
        record.targetBy = goal.timing.targetBy
        record.windowStart = goal.timing.windowStart
        record.windowEnd = goal.timing.windowEnd
        record.suggestedNextAt = goal.timing.suggestedNextAt
        record.repeatEveryDays = goal.timing.repeatEveryDays
        record.progressReviewCadenceDays = goal.timing.progressReviewCadenceDays
        record.planningStrategyData = try PersistenceCoding.encode(goal.planningStrategy)
        record.progressStrategyData = try PersistenceCoding.encode(goal.progressStrategy)
        record.snapshotData = try PersistenceCoding.encode(goal)
    }


    static func goal(from record: GoalRecord, plan: GoalPlan?, includeSnapshotFallback: Bool = false) throws -> Goal {
        let snapshot = try? PersistenceCoding.decode(Goal.self, from: record.snapshotData)
        if let snapshot, includeSnapshotFallback {
            return Goal(
                schemaVersion: snapshot.schemaVersion,
                id: snapshot.id,
                revision: snapshot.revision,
                createdAt: snapshot.createdAt,
                updatedAt: snapshot.updatedAt,
                state: snapshot.state,
                title: snapshot.title,
                summary: snapshot.summary,
                mode: snapshot.mode,
                relationshipKind: snapshot.relationshipKind,
                actor: snapshot.actor,
                parentGoalID: snapshot.parentGoalID,
                childGoalIDs: snapshot.childGoalIDs,
                supportGoalIDs: snapshot.supportGoalIDs,
                tags: snapshot.tags,
                timing: snapshot.timing,
                planningStrategy: snapshot.planningStrategy,
                progressStrategy: snapshot.progressStrategy,
                plan: plan,
                lifeGraph: snapshot.lifeGraph
            )
        }

        return Goal(
            schemaVersion: record.schemaVersion,
            id: record.id,
            revision: record.revision,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            state: persisted(GoalLifecycleState.self, rawValue: record.stateRaw, fallback: .active, storedTypeName: "GoalRecord", fieldName: "stateRaw"),
            title: record.title,
            summary: record.summaryText,
            mode: persisted(GoalMode.self, rawValue: record.modeRaw, fallback: .project, storedTypeName: "GoalRecord", fieldName: "modeRaw"),
            relationshipKind: persisted(GoalRelationshipKind.self, rawValue: record.relationshipKindRaw, fallback: .independent, storedTypeName: "GoalRecord", fieldName: "relationshipKindRaw"),
            actor: GoalActor(
                actorID: record.actorOwnershipRaw,
                displayName: record.actorDisplayName,
                ownership: persisted(ExecutionOwnership.self, rawValue: record.actorOwnershipRaw, fallback: .self, storedTypeName: "GoalRecord", fieldName: "actorOwnershipRaw"),
                roleLabel: nil,
                isPrimary: true
            ),
            parentGoalID: record.parentGoalID,
            childGoalIDs: try PersistenceCoding.decode([String].self, from: record.childGoalIDsData),
            supportGoalIDs: try PersistenceCoding.decode([String].self, from: record.supportGoalIDsData),
            tags: try PersistenceCoding.decode([String].self, from: record.tagsData),
            timing: GoalTiming(
                tempo: persisted(GoalTempo.self, rawValue: record.tempoRaw, fallback: .untimed, storedTypeName: "GoalRecord", fieldName: "tempoRaw"),
                timingType: persisted(TimingType.self, rawValue: record.timingTypeRaw, fallback: .logWhenDone, storedTypeName: "GoalRecord", fieldName: "timingTypeRaw"),
                startsOn: record.startsOn,
                dueAt: record.dueAt,
                targetBy: record.targetBy,
                windowStart: record.windowStart,
                windowEnd: record.windowEnd,
                suggestedNextAt: record.suggestedNextAt,
                repeatEveryDays: record.repeatEveryDays,
                progressReviewCadenceDays: record.progressReviewCadenceDays
            ),
            planningStrategy: try PersistenceCoding.decode(PlanningStrategy.self, from: record.planningStrategyData),
            progressStrategy: try PersistenceCoding.decode(ProgressStrategy.self, from: record.progressStrategyData),
            plan: plan,
            lifeGraph: snapshot?.lifeGraph
        )
    }


    static func planRecord(from plan: GoalPlan) throws -> GoalPlanRecord {
        GoalPlanRecord(
            id: plan.id,
            goalID: plan.goalID,
            version: plan.version,
            generatedAt: plan.generatedAt,
            summaryText: plan.summary,
            strategyData: try PersistenceCoding.encode(plan.strategy),
            assumptionsData: try PersistenceCoding.encode(plan.assumptions),
            lintData: try PersistenceCoding.encode(plan.lint),
            snapshotData: try PersistenceCoding.encode(plan)
        )
    }


    static func plan(from record: GoalPlanRecord, sections: [PlanSection], includeSnapshotFallback: Bool = false) throws -> GoalPlan {
        if includeSnapshotFallback, let snapshot = try? PersistenceCoding.decode(GoalPlan.self, from: record.snapshotData) {
            return GoalPlan(
                id: snapshot.id,
                goalID: snapshot.goalID,
                version: snapshot.version,
                generatedAt: snapshot.generatedAt,
                summary: snapshot.summary,
                strategy: snapshot.strategy,
                sections: sections,
                assumptions: snapshot.assumptions,
                lint: snapshot.lint,
                evaluation: snapshot.evaluation
            )
        }

        return GoalPlan(
            id: record.id,
            goalID: record.goalID,
            version: record.version,
            generatedAt: record.generatedAt,
            summary: record.summaryText,
            strategy: try PersistenceCoding.decode(PlanningStrategy.self, from: record.strategyData),
            sections: sections,
            assumptions: try PersistenceCoding.decode([PlanAssumption].self, from: record.assumptionsData),
            lint: try PersistenceCoding.decode(PlanLintResult.self, from: record.lintData),
            evaluation: nil
        )
    }


    static func sectionRecord(from section: PlanSection, planID: String) -> PlanSectionRecord {
        PlanSectionRecord(
            id: section.id,
            goalID: section.goalID,
            planID: planID,
            title: section.title,
            summaryText: section.summary,
            kindRaw: section.kind.rawValue,
            orderIndex: section.orderIndex
        )
    }


    static func stepRecord(from step: Step, goalID: String, planID: String, orderIndex: Int) throws -> StepRecord {
        StepRecord(
            id: step.id,
            goalID: goalID,
            planID: planID,
            sectionID: step.sectionID,
            orderIndex: orderIndex,
            title: step.title,
            summaryText: step.summary,
            typeRaw: step.type.rawValue,
            stateRaw: step.state.rawValue,
            ownerDisplayName: step.owner.displayName,
            ownerOwnershipRaw: step.owner.ownership.rawValue,
            tempoRaw: step.timing.tempo.rawValue,
            timingTypeRaw: step.timing.timingType.rawValue,
            startsOn: step.timing.startsOn,
            dueAt: step.timing.dueAt,
            targetBy: step.timing.targetBy,
            windowStart: step.timing.windowStart,
            windowEnd: step.timing.windowEnd,
            suggestedNextAt: step.timing.suggestedNextAt,
            repeatEveryDays: step.timing.repeatEveryDays,
            progressReviewCadenceDays: step.timing.progressReviewCadenceDays,
            dependencyStepIDsData: try PersistenceCoding.encode(step.dependencyStepIDs),
            successSignalsData: try PersistenceCoding.encode(step.successSignals),
            actionabilityData: try PersistenceCoding.encode(step.actionability),
            isOptional: step.isOptional,
            isRepeatable: step.isRepeatable,
            evidenceRequired: step.evidenceRequired,
            snapshotData: try PersistenceCoding.encode(step)
        )
    }


    static func step(from record: StepRecord, includeSnapshotFallback: Bool = false) throws -> Step {
        if includeSnapshotFallback, let snapshot = try? PersistenceCoding.decode(Step.self, from: record.snapshotData) {
            return snapshot
        }

        return Step(
            id: record.id,
            sectionID: record.sectionID,
            title: record.title,
            summary: record.summaryText,
            type: persisted(StepType.self, rawValue: record.typeRaw, fallback: .actionUnit, storedTypeName: "StepRecord", fieldName: "typeRaw"),
            state: persisted(StepLifecycleState.self, rawValue: record.stateRaw, fallback: .planned, storedTypeName: "StepRecord", fieldName: "stateRaw"),
            owner: GoalActor(actorID: record.ownerOwnershipRaw, displayName: record.ownerDisplayName, ownership: persisted(ExecutionOwnership.self, rawValue: record.ownerOwnershipRaw, fallback: .self, storedTypeName: "StepRecord", fieldName: "ownerOwnershipRaw"), roleLabel: nil, isPrimary: true),
            timing: GoalTiming(
                tempo: persisted(GoalTempo.self, rawValue: record.tempoRaw, fallback: .untimed, storedTypeName: "StepRecord", fieldName: "tempoRaw"),
                timingType: persisted(TimingType.self, rawValue: record.timingTypeRaw, fallback: .logWhenDone, storedTypeName: "StepRecord", fieldName: "timingTypeRaw"),
                startsOn: record.startsOn,
                dueAt: record.dueAt,
                targetBy: record.targetBy,
                windowStart: record.windowStart,
                windowEnd: record.windowEnd,
                suggestedNextAt: record.suggestedNextAt,
                repeatEveryDays: record.repeatEveryDays,
                progressReviewCadenceDays: record.progressReviewCadenceDays
            ),
            dependencyStepIDs: try PersistenceCoding.decode([String].self, from: record.dependencyStepIDsData),
            isOptional: record.isOptional,
            isRepeatable: record.isRepeatable,
            evidenceRequired: record.evidenceRequired,
            successSignals: try PersistenceCoding.decode([String].self, from: record.successSignalsData),
            actionability: try PersistenceCoding.decode(StepActionability.self, from: record.actionabilityData)
        )
    }


    static func evidenceRecord(from evidence: ProgressEvidence) throws -> ProgressEvidenceRecord {
        ProgressEvidenceRecord(
            id: evidence.id,
            goalID: evidence.goalID,
            stepID: evidence.stepID,
            capturedAt: evidence.capturedAt,
            evidenceKindRaw: evidence.evidenceKind.rawValue,
            sourceRaw: evidence.source.rawValue,
            progressDelta: evidence.progressDelta,
            confidenceDelta: evidence.confidenceDelta,
            minutesInvested: evidence.minutesInvested,
            note: evidence.note,
            snapshotData: try PersistenceCoding.encode(evidence)
        )
    }


    static func evidence(from record: ProgressEvidenceRecord) throws -> ProgressEvidence {
        if let snapshot = try? PersistenceCoding.decode(ProgressEvidence.self, from: record.snapshotData) {
            return snapshot
        }

        return ProgressEvidence(
            id: record.id,
            goalID: record.goalID,
            stepID: record.stepID,
            evidenceKind: persisted(ProgressEvidenceKind.self, rawValue: record.evidenceKindRaw, fallback: .stepCompleted, storedTypeName: "ProgressEvidenceRecord", fieldName: "evidenceKindRaw"),
            source: persisted(EvidenceSource.self, rawValue: record.sourceRaw, fallback: .manual, storedTypeName: "ProgressEvidenceRecord", fieldName: "sourceRaw"),
            capturedAt: record.capturedAt,
            progressDelta: record.progressDelta,
            confidenceDelta: record.confidenceDelta,
            minutesInvested: record.minutesInvested,
            note: record.note
        )
    }
}
