import Foundation
import SwiftData

private struct StoredGoalFeedbackEvent: Codable, Sendable, Equatable {
    let schemaVersion: String?
    let kind: GoalHistoryEventKind
    let base: GoalFeedbackEventBase
    let actualDuration: Int?
    let effortLevel: GoalFeedbackEffortLevel?
    let confidenceDelta: Double?
    let reasonCode: GoalStepSkipReasonCode?
    let timingAdjustment: GoalTimingAdjustment?
    let adjustedDate: String?
    let rewrittenText: String?
    let confusionType: GoalConfusionType?
}

private extension StoredGoalFeedbackEvent {
    init(event: GoalFeedbackEvent) {
        switch event {
        case let .completed(base, actualDuration, effortLevel, confidenceDelta):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .completed, base: base, actualDuration: actualDuration, effortLevel: effortLevel, confidenceDelta: confidenceDelta, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .skipped(base, reasonCode):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .skipped, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: reasonCode, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .delayed(base, timingAdjustment, date):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .delayed, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: timingAdjustment, adjustedDate: date, rewrittenText: nil, confusionType: nil)
        case let .edited(base, rewrittenText):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .edited, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: rewrittenText, confusionType: nil)
        case let .confused(base, confusionType):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .confused, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: confusionType)
        case let .tooBig(base):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooBig, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .tooEasy(base):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooEasy, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .notRelevant(base):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .notRelevant, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedForSmallerVersion(base):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedForSmallerVersion, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedWhyThisMatters(base):
            self = StoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedWhyThisMatters, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        }
    }

    var event: GoalFeedbackEvent {
        switch kind {
        case .completed:
            return .completed(base: base, actualDuration: actualDuration, effortLevel: effortLevel ?? .medium, confidenceDelta: confidenceDelta)
        case .skipped:
            return .skipped(base: base, reasonCode: reasonCode ?? .notNow)
        case .delayed:
            return .delayed(base: base, timingAdjustment: timingAdjustment ?? .laterToday, date: adjustedDate)
        case .edited:
            return .edited(base: base, rewrittenText: rewrittenText ?? "")
        case .confused:
            return .confused(base: base, confusionType: confusionType ?? .unclearAction)
        case .tooBig:
            return .tooBig(base: base)
        case .tooEasy:
            return .tooEasy(base: base)
        case .notRelevant:
            return .notRelevant(base: base)
        case .askedForSmallerVersion:
            return .askedForSmallerVersion(base: base)
        case .askedWhyThisMatters:
            return .askedWhyThisMatters(base: base)
        }
    }
}

private enum RepositoryMapping {
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

    static func goal(from record: GoalRecord, plan: GoalPlan?) throws -> Goal {
        if let snapshot = try? PersistenceCoding.decode(Goal.self, from: record.snapshotData) {
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
                plan: plan
            )
        }

        return Goal(
            schemaVersion: record.schemaVersion,
            id: record.id,
            revision: record.revision,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            state: GoalLifecycleState(rawValue: record.stateRaw) ?? .active,
            title: record.title,
            summary: record.summaryText,
            mode: GoalMode(rawValue: record.modeRaw) ?? .project,
            relationshipKind: GoalRelationshipKind(rawValue: record.relationshipKindRaw) ?? .independent,
            actor: GoalActor(
                actorID: record.actorOwnershipRaw,
                displayName: record.actorDisplayName,
                ownership: ExecutionOwnership(rawValue: record.actorOwnershipRaw) ?? .self,
                roleLabel: nil,
                isPrimary: true
            ),
            parentGoalID: record.parentGoalID,
            childGoalIDs: try PersistenceCoding.decode([String].self, from: record.childGoalIDsData),
            supportGoalIDs: try PersistenceCoding.decode([String].self, from: record.supportGoalIDsData),
            tags: try PersistenceCoding.decode([String].self, from: record.tagsData),
            timing: GoalTiming(
                tempo: GoalTempo(rawValue: record.tempoRaw) ?? .untimed,
                timingType: TimingType(rawValue: record.timingTypeRaw) ?? .logWhenDone,
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
            plan: plan
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

    static func plan(from record: GoalPlanRecord, sections: [PlanSection]) throws -> GoalPlan {
        if let snapshot = try? PersistenceCoding.decode(GoalPlan.self, from: record.snapshotData) {
            return GoalPlan(
                id: snapshot.id,
                goalID: snapshot.goalID,
                version: snapshot.version,
                generatedAt: snapshot.generatedAt,
                summary: snapshot.summary,
                strategy: snapshot.strategy,
                sections: sections,
                assumptions: snapshot.assumptions,
                lint: snapshot.lint
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
            lint: try PersistenceCoding.decode(PlanLintResult.self, from: record.lintData)
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

    static func step(from record: StepRecord) throws -> Step {
        if let snapshot = try? PersistenceCoding.decode(Step.self, from: record.snapshotData) {
            return snapshot
        }

        return Step(
            id: record.id,
            sectionID: record.sectionID,
            title: record.title,
            summary: record.summaryText,
            type: StepType(rawValue: record.typeRaw) ?? .actionUnit,
            state: StepLifecycleState(rawValue: record.stateRaw) ?? .planned,
            owner: GoalActor(actorID: record.ownerOwnershipRaw, displayName: record.ownerDisplayName, ownership: ExecutionOwnership(rawValue: record.ownerOwnershipRaw) ?? .self, roleLabel: nil, isPrimary: true),
            timing: GoalTiming(
                tempo: GoalTempo(rawValue: record.tempoRaw) ?? .untimed,
                timingType: TimingType(rawValue: record.timingTypeRaw) ?? .logWhenDone,
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
            evidenceKind: ProgressEvidenceKind(rawValue: record.evidenceKindRaw) ?? .stepCompleted,
            source: EvidenceSource(rawValue: record.sourceRaw) ?? .manual,
            capturedAt: record.capturedAt,
            progressDelta: record.progressDelta,
            confidenceDelta: record.confidenceDelta,
            minutesInvested: record.minutesInvested,
            note: record.note
        )
    }

    static func feedbackRecord(from event: GoalFeedbackEvent, goalID: String) throws -> FeedbackEventRecord {
        let stored = StoredGoalFeedbackEvent(event: event)
        return FeedbackEventRecord(
            id: stored.base.id,
            goalID: goalID,
            stepID: stored.base.stepID,
            occurredAt: stored.base.occurredAt,
            kindRaw: stored.kind.rawValue,
            note: stored.base.note,
            payloadData: try PersistenceCoding.encode(stored)
        )
    }

    static func feedback(from record: FeedbackEventRecord) throws -> GoalFeedbackEvent {
        try PersistenceCoding.decode(StoredGoalFeedbackEvent.self, from: record.payloadData).event
    }

    static func captureRecord(from capture: Capture) throws -> CaptureRecord {
        CaptureRecord(
            id: capture.id,
            createdAt: capture.createdAt,
            updatedAt: capture.updatedAt,
            rawText: capture.rawText,
            sourceTypeRaw: capture.sourceType?.rawValue,
            statusRaw: capture.status.rawValue,
            linkedGoalID: capture.linkedGoalID,
            snapshotData: try PersistenceCoding.encode(capture)
        )
    }

    static func capture(from record: CaptureRecord) throws -> Capture {
        if let snapshot = try? PersistenceCoding.decode(Capture.self, from: record.snapshotData) {
            return snapshot
        }

        return Capture(
            id: record.id,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            rawText: record.rawText,
            sourceType: record.sourceTypeRaw.flatMap(CaptureSourceType.init(rawValue:)),
            status: captureStatus(from: record.statusRaw),
            linkedGoalID: record.linkedGoalID
        )
    }

    static func captureStatus(from rawValue: String) -> CaptureStatus {
        switch rawValue {
        case "pending":
            return .actionable
        case "processed":
            return .goalBound
        default:
            return CaptureStatus(rawValue: rawValue) ?? .actionable
        }
    }

    static func draftRecord(from draft: PersistedGoalDraft) throws -> GoalDraftRecord {
        GoalDraftRecord(
            id: draft.id,
            createdAt: draft.createdAt,
            updatedAt: draft.updatedAt,
            title: draft.draft.title,
            modeRaw: draft.draft.mode.rawValue,
            resultKindRaw: draft.latestResultKind?.rawValue,
            readinessRaw: draft.clarification?.readiness.rawValue,
            plannedGoalID: draft.plannedGoalID,
            snapshotData: try PersistenceCoding.encode(draft)
        )
    }

    static func storedDraft(from record: GoalDraftRecord) throws -> PersistedGoalDraft {
        try PersistenceCoding.decode(PersistedGoalDraft.self, from: record.snapshotData)
    }

    static func appStateRecord(from state: AppStateSnapshot) throws -> AppStateRecord {
        AppStateRecord(
            id: state.id,
            preferredTabRaw: state.preferredTab.rawValue,
            userDisplayName: state.userDisplayName,
            appearancePreferenceRaw: state.appearancePreference.rawValue,
            hasCompletedBootstrap: state.hasCompletedBootstrap,
            lastBootstrapSourceRaw: state.lastBootstrapSource?.rawValue,
            lastBootstrapAt: state.lastBootstrapAt,
            lastSeedVersion: state.lastSeedVersion,
            lastSeededAt: state.lastSeededAt,
            lastOpenedGoalID: state.lastOpenedGoalID,
            snapshotData: try PersistenceCoding.encode(state)
        )
    }

    static func appState(from record: AppStateRecord) throws -> AppStateSnapshot {
        if let snapshot = try? PersistenceCoding.decode(AppStateSnapshot.self, from: record.snapshotData) {
            return snapshot
        }

        return AppStateSnapshot(
            id: record.id,
            preferredTab: AppTab(rawValue: record.preferredTabRaw) ?? .today,
            userDisplayName: record.userDisplayName,
            appearancePreference: AppAppearancePreference(rawValue: record.appearancePreferenceRaw) ?? .system,
            reviewCadenceDays: 7,
            localOnlyModeEnabled: true,
            hasCompletedBootstrap: record.hasCompletedBootstrap,
            lastBootstrapSource: record.lastBootstrapSourceRaw.flatMap(AppSession.BootstrapSource.init(rawValue:)),
            lastBootstrapAt: record.lastBootstrapAt,
            lastSeedVersion: record.lastSeedVersion,
            lastSeededAt: record.lastSeededAt,
            lastImportSummary: nil,
            lastOpenedGoalID: record.lastOpenedGoalID,
            goalPriorityOrder: []
        )
    }
}

private extension Array where Element == Step {
    func sortedForActionability() -> [Step] {
        sorted { lhs, rhs in
            let lhsKey = lhs.timing.dueAt ?? lhs.timing.targetBy ?? lhs.timing.suggestedNextAt ?? lhs.timing.startsOn ?? "9999-12-31T23:59:59Z"
            let rhsKey = rhs.timing.dueAt ?? rhs.timing.targetBy ?? rhs.timing.suggestedNextAt ?? rhs.timing.startsOn ?? "9999-12-31T23:59:59Z"
            return lhsKey == rhsKey ? lhs.title < rhs.title : lhsKey < rhsKey
        }
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
                .sorted { $0.updatedAt > $1.updatedAt }
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
        try await listGoals().first(where: { $0.id == id })
    }

    func saveGoals(_ goals: [Goal]) async throws {
        try await store.write { context in
            let goalIndex = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalRecord>()).map { ($0.id, $0) })
            let planRecords = try context.fetch(FetchDescriptor<GoalPlanRecord>())
            let sectionRecords = try context.fetch(FetchDescriptor<PlanSectionRecord>())
            let stepRecords = try context.fetch(FetchDescriptor<StepRecord>())

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
                .map(RepositoryMapping.step(from:))
                .filter { $0.state != .completed && $0.state != .cancelled }
                .sortedForActionability()
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
                .map(RepositoryMapping.step(from:))
        }
    }

    private func composePlanMap(
        planRecords: [GoalPlanRecord],
        sectionRecords: [PlanSectionRecord],
        stepRecords: [StepRecord]
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
                        .map(RepositoryMapping.step(from:))
                    return PlanSection(
                        id: sectionRecord.id,
                        goalID: sectionRecord.goalID,
                        title: sectionRecord.title,
                        summary: sectionRecord.summaryText,
                        kind: PlanSectionKind(rawValue: sectionRecord.kindRaw) ?? .overview,
                        orderIndex: sectionRecord.orderIndex,
                        steps: steps
                    )
                }
            map[planRecord.goalID] = try RepositoryMapping.plan(from: planRecord, sections: sections)
        }

        return map
    }
}

struct SwiftDataGoalDraftRepository: GoalDraftRepository {
    let store: AmbitionsPersistenceStore

    func listDrafts() async throws -> [PersistedGoalDraft] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<GoalDraftRecord>())
                .sorted { $0.updatedAt > $1.updatedAt }
                .map(RepositoryMapping.storedDraft(from:))
        }
    }

    func draft(id: String) async throws -> PersistedGoalDraft? {
        try await listDrafts().first(where: { $0.id == id })
    }

    func saveDrafts(_ drafts: [PersistedGoalDraft]) async throws {
        try await store.write { context in
            let existing = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<GoalDraftRecord>()).map { ($0.id, $0) })
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

    func deleteDraft(id: String) async throws {
        try await store.write { context in
            for record in try context.fetch(FetchDescriptor<GoalDraftRecord>()) where record.id == id {
                context.delete(record)
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
                .sorted { $0.capturedAt > $1.capturedAt }
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
                .sorted { $0.occurredAt > $1.occurredAt }
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
                .sorted { $0.updatedAt > $1.updatedAt }
                .map(RepositoryMapping.capture(from:))
        }
    }

    func capture(id: String) async throws -> Capture? {
        try await listCaptures().first(where: { $0.id == id })
    }

    func saveCaptures(_ captures: [Capture]) async throws {
        try await store.write { context in
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
}

struct SwiftDataAppStateRepository: AppStateRepository {
    let store: AmbitionsPersistenceStore

    func loadState() async throws -> AppStateSnapshot {
        try await store.read { context in
            guard let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first else {
                return .default
            }
            return try RepositoryMapping.appState(from: record)
        }
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        try await store.write { context in
            if let record = try context.fetch(FetchDescriptor<AppStateRecord>()).first(where: { $0.id == state.id }) {
                record.preferredTabRaw = state.preferredTab.rawValue
                record.userDisplayName = state.userDisplayName
                record.appearancePreferenceRaw = state.appearancePreference.rawValue
                record.hasCompletedBootstrap = state.hasCompletedBootstrap
                record.lastBootstrapSourceRaw = state.lastBootstrapSource?.rawValue
                record.lastBootstrapAt = state.lastBootstrapAt
                record.lastSeedVersion = state.lastSeedVersion
                record.lastSeededAt = state.lastSeededAt
                record.lastOpenedGoalID = state.lastOpenedGoalID
                record.snapshotData = try PersistenceCoding.encode(state)
            } else {
                context.insert(try RepositoryMapping.appStateRecord(from: state))
            }
        }
    }
}
