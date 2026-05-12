import AmbitionsDesignSystem
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
            lifeGraph: nil
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
            sourceType: persistedOptional(CaptureSourceType.self, rawValue: record.sourceTypeRaw, storedTypeName: "CaptureRecord", fieldName: "sourceTypeRaw"),
            status: captureStatus(from: record.statusRaw),
            linkedGoalID: record.linkedGoalID
        )
    }

    static func teachingSignalRecord(from signal: GoalTeachingSignal) throws -> TeachingSignalRecord {
        TeachingSignalRecord(
            id: signal.id,
            goalID: signal.goalID,
            kindRaw: signal.kind.rawValue,
            sourceRaw: signal.source.rawValue,
            dispositionRaw: signal.disposition.rawValue,
            applicationKey: signal.applicationKey,
            createdAt: signal.createdAt,
            updatedAt: signal.updatedAt,
            snapshotData: try PersistenceCoding.encode(signal)
        )
    }

    static func teachingSignal(from record: TeachingSignalRecord) throws -> GoalTeachingSignal {
        if let snapshot = try? PersistenceCoding.decode(GoalTeachingSignal.self, from: record.snapshotData) {
            return snapshot
        }

        throw PersistenceError.invalidStoredValue("Teaching signal snapshots must decode into GoalTeachingSignal.")
    }

    static func eventLedgerRecord(from event: EventLedgerEntry) throws -> EventLedgerRecord {
        EventLedgerRecord(
            id: event.id,
            kindRaw: event.kind.rawValue,
            occurredAt: event.occurredAt,
            sourceRaw: event.source.rawValue,
            goalID: event.goalID,
            captureID: event.captureID,
            planID: event.planID,
            planScope: event.planScope,
            reviewID: event.reviewID,
            title: event.title,
            summaryText: event.summary,
            semanticState: event.semanticState,
            toneRaw: event.tone.rawValue,
            schemaVersion: event.schemaVersion,
            privacyRaw: event.privacy.rawValue,
            localOnly: event.localOnly,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            evidenceReferencesData: try PersistenceCoding.encode(event.evidenceReferences),
            metadataData: try PersistenceCoding.encode(event.metadata),
            payloadData: try PersistenceCoding.encode(event.payload),
            trustData: try PersistenceCoding.encode(event.trust),
            snapshotData: try PersistenceCoding.encode(event)
        )
    }

    static func apply(_ event: EventLedgerEntry, to record: EventLedgerRecord) throws {
        record.kindRaw = event.kind.rawValue
        record.occurredAt = event.occurredAt
        record.sourceRaw = event.source.rawValue
        record.goalID = event.goalID
        record.captureID = event.captureID
        record.planID = event.planID
        record.planScope = event.planScope
        record.reviewID = event.reviewID
        record.title = event.title
        record.summaryText = event.summary
        record.semanticState = event.semanticState
        record.toneRaw = event.tone.rawValue
        record.schemaVersion = event.schemaVersion
        record.privacyRaw = event.privacy.rawValue
        record.localOnly = event.localOnly
        record.createdAt = event.createdAt
        record.updatedAt = event.updatedAt
        record.evidenceReferencesData = try PersistenceCoding.encode(event.evidenceReferences)
        record.metadataData = try PersistenceCoding.encode(event.metadata)
        record.payloadData = try PersistenceCoding.encode(event.payload)
        record.trustData = try PersistenceCoding.encode(event.trust)
        record.snapshotData = try PersistenceCoding.encode(event)
    }

    static func eventLedgerEntry(from record: EventLedgerRecord) throws -> EventLedgerEntry {
        if let snapshot = try? PersistenceCoding.decode(EventLedgerEntry.self, from: record.snapshotData) {
            return snapshot
        }

        return EventLedgerEntry(
            id: record.id,
            kind: persisted(EventLedgerKind.self, rawValue: record.kindRaw, fallback: .goalUpdated, storedTypeName: "EventLedgerRecord", fieldName: "kindRaw"),
            occurredAt: record.occurredAt,
            source: persisted(EventLedgerSource.self, rawValue: record.sourceRaw, fallback: .system, storedTypeName: "EventLedgerRecord", fieldName: "sourceRaw"),
            goalID: record.goalID,
            captureID: record.captureID,
            planID: record.planID,
            planScope: record.planScope,
            reviewID: record.reviewID,
            title: record.title,
            summary: record.summaryText,
            semanticState: record.semanticState,
            tone: persisted(EventLedgerTone.self, rawValue: record.toneRaw, fallback: .neutral, storedTypeName: "EventLedgerRecord", fieldName: "toneRaw"),
            trust: (try? PersistenceCoding.decode(EventLedgerTrustMetadata.self, from: record.trustData)) ?? EventLedgerTrustMetadata(),
            evidenceReferences: (try? PersistenceCoding.decode([EventLedgerEvidenceReference].self, from: record.evidenceReferencesData)) ?? [],
            metadata: (try? PersistenceCoding.decode([String: String].self, from: record.metadataData)) ?? [:],
            payload: (try? PersistenceCoding.decode([String: String].self, from: record.payloadData)) ?? [:],
            schemaVersion: record.schemaVersion,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "EventLedgerRecord", fieldName: "privacyRaw"),
            localOnly: record.localOnly,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }

    static func commandExecutionRecord(from record: AmbitionsCommandExecutionRecord) throws -> CommandExecutionRecord {
        CommandExecutionRecord(
            id: record.id,
            commandID: record.command.id,
            commandKindRaw: record.command.kind.rawValue,
            commandSourceRaw: record.command.source.rawValue,
            actorRaw: record.command.actor.rawValue,
            executionStatusRaw: record.command.executionStatus.rawValue,
            resultStatusRaw: record.result.status.rawValue,
            recordedAt: record.recordedAt,
            schemaVersion: record.schemaVersion,
            localOnly: record.localOnly,
            privacyRaw: record.privacy.rawValue,
            commandData: try PersistenceCoding.encode(record.command),
            resultData: try PersistenceCoding.encode(record.result)
        )
    }

    static func apply(_ record: AmbitionsCommandExecutionRecord, to persisted: CommandExecutionRecord) throws {
        persisted.commandID = record.command.id
        persisted.commandKindRaw = record.command.kind.rawValue
        persisted.commandSourceRaw = record.command.source.rawValue
        persisted.actorRaw = record.command.actor.rawValue
        persisted.executionStatusRaw = record.command.executionStatus.rawValue
        persisted.resultStatusRaw = record.result.status.rawValue
        persisted.recordedAt = record.recordedAt
        persisted.schemaVersion = record.schemaVersion
        persisted.localOnly = record.localOnly
        persisted.privacyRaw = record.privacy.rawValue
        persisted.commandData = try PersistenceCoding.encode(record.command)
        persisted.resultData = try PersistenceCoding.encode(record.result)
    }

    static func commandExecutionRecord(from record: CommandExecutionRecord) throws -> AmbitionsCommandExecutionRecord {
        let command = try? PersistenceCoding.decode(AmbitionsCommand.self, from: record.commandData)
        let result = try? PersistenceCoding.decode(AmbitionsCommandExecutionResult.self, from: record.resultData)

        let fallbackCommand = AmbitionsCommand(
            id: record.commandID,
            kind: persisted(AmbitionsCommandKind.self, rawValue: record.commandKindRaw, fallback: .openDestination, storedTypeName: "CommandExecutionRecord", fieldName: "commandKindRaw"),
            source: persisted(AmbitionsCommandSource.self, rawValue: record.commandSourceRaw, fallback: .system, storedTypeName: "CommandExecutionRecord", fieldName: "commandSourceRaw"),
            executionStatus: persisted(AmbitionsCommandExecutionStatus.self, rawValue: record.executionStatusRaw, fallback: .blocked, storedTypeName: "CommandExecutionRecord", fieldName: "executionStatusRaw"),
            createdAt: record.recordedAt,
            actor: persisted(AmbitionsCommandActor.self, rawValue: record.actorRaw, fallback: .user, storedTypeName: "CommandExecutionRecord", fieldName: "actorRaw"),
            localOnly: record.localOnly,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "CommandExecutionRecord", fieldName: "privacyRaw"),
            schemaVersion: ambitionsCommandSchemaVersion
        )
        let fallbackResult = AmbitionsCommandExecutionResult(
            status: persisted(AmbitionsCommandExecutionStatus.self, rawValue: record.resultStatusRaw, fallback: .failed, storedTypeName: "CommandExecutionRecord", fieldName: "resultStatusRaw"),
            summary: "Recovered from durable command execution record."
        )

        return AmbitionsCommandExecutionRecord(
            command: command ?? fallbackCommand,
            result: result ?? fallbackResult,
            recordedAt: record.recordedAt,
            localOnly: record.localOnly,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "CommandExecutionRecord", fieldName: "privacyRaw"),
            schemaVersion: record.schemaVersion
        )
    }

    static func sideEffectLedgerStorageRecord(from record: SideEffectLedgerRecord) throws -> SideEffectLedgerStorageRecord {
        SideEffectLedgerStorageRecord(
            id: record.id,
            effectKindRaw: record.effectKind.rawValue,
            statusRaw: record.status.rawValue,
            boundaryRaw: record.boundary.rawValue,
            actionKindRaw: record.actionKind.rawValue,
            sourceDomainRaw: record.sourceDomain.rawValue,
            commandID: record.commandID,
            targetObjectsData: try PersistenceCoding.encode(record.targetObjects),
            requiresConfirmation: record.requiresConfirmation,
            externalEffect: record.externalEffect,
            reasonsData: try PersistenceCoding.encode(record.reasons),
            blockedFactsData: try PersistenceCoding.encode(record.blockedFacts),
            degradedFactsData: try PersistenceCoding.encode(record.degradedFacts),
            receiptID: record.receiptID,
            schemaVersion: record.schemaVersion,
            localOnly: record.localOnly,
            occurredAt: record.occurredAt,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }

    static func apply(_ record: SideEffectLedgerRecord, to storage: SideEffectLedgerStorageRecord) throws {
        storage.effectKindRaw = record.effectKind.rawValue
        storage.statusRaw = record.status.rawValue
        storage.boundaryRaw = record.boundary.rawValue
        storage.actionKindRaw = record.actionKind.rawValue
        storage.sourceDomainRaw = record.sourceDomain.rawValue
        storage.commandID = record.commandID
        storage.targetObjectsData = try PersistenceCoding.encode(record.targetObjects)
        storage.requiresConfirmation = record.requiresConfirmation
        storage.externalEffect = record.externalEffect
        storage.reasonsData = try PersistenceCoding.encode(record.reasons)
        storage.blockedFactsData = try PersistenceCoding.encode(record.blockedFacts)
        storage.degradedFactsData = try PersistenceCoding.encode(record.degradedFacts)
        storage.receiptID = record.receiptID
        storage.schemaVersion = record.schemaVersion
        storage.localOnly = record.localOnly
        storage.occurredAt = record.occurredAt
        storage.snapshotData = try PersistenceCoding.encode(record)
    }

    static func sideEffectLedgerRecord(from storage: SideEffectLedgerStorageRecord) throws -> SideEffectLedgerRecord {
        if let snapshot = try? PersistenceCoding.decode(SideEffectLedgerRecord.self, from: storage.snapshotData) {
            return snapshot
        }

        return SideEffectLedgerRecord(
            id: storage.id,
            effectKind: persisted(SideEffectLedgerEffectKind.self, rawValue: storage.effectKindRaw, fallback: .unknown, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "effectKindRaw"),
            status: persisted(SideEffectLedgerStatus.self, rawValue: storage.statusRaw, fallback: .blocked, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "statusRaw"),
            boundary: persisted(SideEffectLedgerBoundary.self, rawValue: storage.boundaryRaw, fallback: .unsupported, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "boundaryRaw"),
            actionKind: persisted(SafeAutomationActionKind.self, rawValue: storage.actionKindRaw, fallback: .noOp, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "actionKindRaw"),
            sourceDomain: persisted(ActionReceiptSourceDomain.self, rawValue: storage.sourceDomainRaw, fallback: .today, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "sourceDomainRaw"),
            commandID: storage.commandID,
            targetObjects: (try? PersistenceCoding.decode([LifeGraphObjectReference].self, from: storage.targetObjectsData)) ?? [],
            occurredAt: storage.occurredAt,
            localOnly: storage.localOnly,
            requiresConfirmation: storage.requiresConfirmation,
            externalEffect: storage.externalEffect,
            reasons: (try? PersistenceCoding.decode([SafeAutomationPolicyReason].self, from: storage.reasonsData)) ?? [],
            blockedFacts: (try? PersistenceCoding.decode([String].self, from: storage.blockedFactsData)) ?? [],
            degradedFacts: (try? PersistenceCoding.decode([String].self, from: storage.degradedFactsData)) ?? [],
            receiptID: storage.receiptID,
            schemaVersion: storage.schemaVersion
        )
    }

    static func captureStatus(from rawValue: String) -> CaptureStatus {
        persisted(
            CaptureStatus.self,
            rawValue: rawValue,
            fallback: .actionable,
            storedTypeName: "CaptureRecord",
            fieldName: "statusRaw",
            legacyAliases: [
                "pending": .actionable,
                "processed": .goalBound,
            ]
        )
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
            accentFamilyRaw: state.accentFamily.rawValue,
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
            preferredTab: persisted(AppTab.self, rawValue: record.preferredTabRaw, fallback: .today, storedTypeName: "AppStateRecord", fieldName: "preferredTabRaw"),
            userDisplayName: record.userDisplayName,
            appearancePreference: persisted(AppAppearancePreference.self, rawValue: record.appearancePreferenceRaw, fallback: .system, storedTypeName: "AppStateRecord", fieldName: "appearancePreferenceRaw"),
            accentFamily: persistedOptional(AmbitionAccentFamily.self, rawValue: record.accentFamilyRaw, storedTypeName: "AppStateRecord", fieldName: "accentFamilyRaw") ?? .sage,
            reviewCadenceDays: 7,
            localOnlyModeEnabled: true,
            hasCompletedBootstrap: record.hasCompletedBootstrap,
            hasCompletedOnboarding: record.hasCompletedBootstrap,
            onboardingVersion: 1,
            onboardingCompletedAt: record.lastBootstrapAt,
            onboardingEntryChoice: nil,
            lastBootstrapSource: persistedOptional(AppSession.BootstrapSource.self, rawValue: record.lastBootstrapSourceRaw, storedTypeName: "AppStateRecord", fieldName: "lastBootstrapSourceRaw"),
            lastBootstrapAt: record.lastBootstrapAt,
            lastSeedVersion: record.lastSeedVersion,
            lastSeededAt: record.lastSeededAt,
            lastImportSummary: nil,
            lastOpenedGoalID: record.lastOpenedGoalID,
            goalPriorityOrder: []
        )
    }

    static func actionReceiptHistoryRecord(from record: ActionReceiptHistoryRecord) throws -> ActionReceiptHistoryRecordModel {
        ActionReceiptHistoryRecordModel(
            id: record.id,
            schemaVersion: actionClosureReceiptSchemaVersion,
            sourceDomainRaw: record.receipt.sourceDomain.rawValue,
            resultStateRaw: record.receipt.resultState.rawValue,
            privacyLevelRaw: record.privacyLevel.rawValue,
            proofRelevanceRaw: record.proofRelevance.rawValue,
            undoAvailabilityRaw: record.receipt.undoAvailability.rawValue,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse,
            localOnly: record.localOnly,
            createdAt: record.receipt.createdAt,
            occurredAt: record.receipt.occurredAt,
            receiptData: try PersistenceCoding.encode(record.receipt)
        )
    }

    static func apply(_ record: ActionReceiptHistoryRecord, to persisted: ActionReceiptHistoryRecordModel) throws {
        persisted.schemaVersion = actionClosureReceiptSchemaVersion
        persisted.sourceDomainRaw = record.receipt.sourceDomain.rawValue
        persisted.resultStateRaw = record.receipt.resultState.rawValue
        persisted.privacyLevelRaw = record.privacyLevel.rawValue
        persisted.proofRelevanceRaw = record.proofRelevance.rawValue
        persisted.undoAvailabilityRaw = record.receipt.undoAvailability.rawValue
        persisted.requiresConfirmationBeforeBroaderUse = record.requiresConfirmationBeforeBroaderUse
        persisted.localOnly = record.localOnly
        persisted.createdAt = record.receipt.createdAt
        persisted.occurredAt = record.receipt.occurredAt
        persisted.receiptData = try PersistenceCoding.encode(record.receipt)
    }

    static func actionReceiptHistoryRecord(from persistedRecord: ActionReceiptHistoryRecordModel) throws -> ActionReceiptHistoryRecord {
        if let receipt = try? PersistenceCoding.decode(ActionReceipt.self, from: persistedRecord.receiptData) {
            return ActionReceiptHistoryRecord(
                receipt: receipt,
                privacyLevel: RepositoryMapping.persisted(ActionReceiptPrivacyLevel.self, rawValue: persistedRecord.privacyLevelRaw, fallback: .safeToShow, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "privacyLevelRaw"),
                localOnly: persistedRecord.localOnly,
                proofRelevance: RepositoryMapping.persisted(ActionReceiptProofRelevance.self, rawValue: persistedRecord.proofRelevanceRaw, fallback: .notProof, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "proofRelevanceRaw"),
                requiresConfirmationBeforeBroaderUse: persistedRecord.requiresConfirmationBeforeBroaderUse
            )
        }

        return ActionReceiptHistoryRecord(
            receipt: ActionReceipt(
                id: persistedRecord.id,
                resultState: RepositoryMapping.persisted(ActionReceiptResultState.self, rawValue: persistedRecord.resultStateRaw, fallback: .changed, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "resultStateRaw"),
                title: "Recovered receipt",
                summary: "Recovered receipt payload was unavailable.",
                sourceDomain: RepositoryMapping.persisted(ActionReceiptSourceDomain.self, rawValue: persistedRecord.sourceDomainRaw, fallback: .system, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "sourceDomainRaw"),
                occurredAt: persistedRecord.occurredAt,
                createdAt: persistedRecord.createdAt,
                affectedObjects: [],
                changedFacts: [],
                correctionAvailability: .unavailable,
                undoAvailability: RepositoryMapping.persisted(ActionReceiptUndoAvailability.self, rawValue: persistedRecord.undoAvailabilityRaw, fallback: .unavailable, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "undoAvailabilityRaw")
            ),
            privacyLevel: RepositoryMapping.persisted(ActionReceiptPrivacyLevel.self, rawValue: persistedRecord.privacyLevelRaw, fallback: .safeToShow, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "privacyLevelRaw"),
            localOnly: persistedRecord.localOnly,
            proofRelevance: RepositoryMapping.persisted(ActionReceiptProofRelevance.self, rawValue: persistedRecord.proofRelevanceRaw, fallback: .notProof, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "proofRelevanceRaw"),
            requiresConfirmationBeforeBroaderUse: persistedRecord.requiresConfirmationBeforeBroaderUse
        )
    }

    static func entityRevisionTombstoneRecord(from record: EntityRevisionTombstone) throws -> EntityRevisionTombstoneRecord {
        EntityRevisionTombstoneRecord(
            id: record.id,
            entityKindRaw: record.entityKind.rawValue,
            entityID: record.entityID,
            revisionMarker: record.revisionMarker,
            reasonRaw: record.reason.rawValue,
            recordedAt: record.recordedAt,
            localOnly: record.localOnly,
            schemaVersion: record.schemaVersion,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }

    static func apply(_ record: EntityRevisionTombstone, to storage: EntityRevisionTombstoneRecord) throws {
        storage.entityKindRaw = record.entityKind.rawValue
        storage.entityID = record.entityID
        storage.revisionMarker = record.revisionMarker
        storage.reasonRaw = record.reason.rawValue
        storage.recordedAt = record.recordedAt
        storage.localOnly = record.localOnly
        storage.schemaVersion = record.schemaVersion
        storage.snapshotData = try PersistenceCoding.encode(record)
    }

    static func entityRevisionTombstone(from storage: EntityRevisionTombstoneRecord) throws -> EntityRevisionTombstone {
        if let snapshot = try? PersistenceCoding.decode(EntityRevisionTombstone.self, from: storage.snapshotData) {
            return snapshot
        }

        return EntityRevisionTombstone(
            id: storage.id,
            entityKind: persisted(
                EntityRevisionTombstoneEntityKind.self,
                rawValue: storage.entityKindRaw,
                fallback: .unknown,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "entityKindRaw"
            ),
            entityID: storage.entityID,
            revisionMarker: storage.revisionMarker,
            reason: persisted(
                EntityRevisionTombstoneReason.self,
                rawValue: storage.reasonRaw,
                fallback: .unknown,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "reasonRaw"
            ),
            recordedAt: storage.recordedAt,
            localOnly: storage.localOnly,
            schemaVersion: storage.schemaVersion
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
        timestampProvider: () -> String = { ISO8601DateFormatter().string(from: .now) }
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
        timestampProvider: () -> String = { ISO8601DateFormatter().string(from: .now) }
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

private enum SwiftDataGoalPersistence {
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

private enum SwiftDataGoalDraftPersistence {
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
            try SwiftDataCapturePersistence.saveCaptures(captures, in: context)
        }
    }
}

private enum SwiftDataCapturePersistence {
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

actor InMemoryGoalTeachingSignalRepository: GoalTeachingSignalRepository {
    private var signals: [GoalTeachingSignal] = []

    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal] {
        signals
            .filter { goalID == nil || $0.goalID == goalID }
            .sorted {
                if $0.updatedAt != $1.updatedAt {
                    return $0.updatedAt > $1.updatedAt
                }
                return $0.id > $1.id
            }
    }

    func saveSignals(_ signals: [GoalTeachingSignal]) async throws {
        let incomingByID = Dictionary(uniqueKeysWithValues: signals.map { ($0.id, $0) })
        self.signals.removeAll { incomingByID[$0.id] != nil }
        self.signals.append(contentsOf: signals)
    }
}

actor InMemoryEventLedgerRepository: EventLedgerRepository {
    private var events: [EventLedgerEntry] = []

    func append(_ event: EventLedgerEntry) async throws {
        events.removeAll { $0.id == event.id }
        events.append(event)
    }

    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] {
        Array(sorted(events).prefix(max(0, limit)))
    }

    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.goalID == goalID })
    }

    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.captureID == captureID })
    }

    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.kind == kind })
    }

    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.occurredAt >= start && $0.occurredAt <= end })
    }

    func redactEvent(id: String, at timestamp: String) async throws {
        events = events.map { event in
            event.id == id ? event.redacted(at: timestamp) : event
        }
    }

    func deleteEvent(id: String) async throws {
        events.removeAll { $0.id == id }
    }

    private func sorted(_ events: [EventLedgerEntry]) -> [EventLedgerEntry] {
        events.sorted {
            if $0.occurredAt != $1.occurredAt {
                return $0.occurredAt > $1.occurredAt
            }
            return $0.id > $1.id
        }
    }
}

actor InMemoryAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    private var records: [AmbitionsCommandExecutionRecord] = []

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        records.removeAll { $0.command.id == record.command.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        Array(records.sorted { lhs, rhs in
            if lhs.recordedAt == rhs.recordedAt {
                return lhs.command.id > rhs.command.id
            }
            return lhs.recordedAt > rhs.recordedAt
        }.prefix(max(0, limit)))
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        records
            .sorted {
                if $0.recordedAt == $1.recordedAt {
                    return $0.command.id > $1.command.id
                }
                return $0.recordedAt > $1.recordedAt
            }
            .first(where: { $0.command.id == commandID })
    }
}

struct SwiftDataSideEffectLedgerRepository: SideEffectLedgerRepository {
    let store: AmbitionsPersistenceStore

    func append(_ record: SideEffectLedgerRecord) async throws {
        guard record.isWellFormed else { return }
        try await store.write { context in
            if let storage = try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .first(where: { $0.id == record.id }) {
                try RepositoryMapping.apply(record, to: storage)
            } else {
                context.insert(try RepositoryMapping.sideEffectLedgerStorageRecord(from: record))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(try await fetchAll { _ in true }.prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        try await fetchAll { $0.statusRaw == status.rawValue }
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .first(where: { $0.id == id })
                .map(RepositoryMapping.sideEffectLedgerRecord(from:))
        }
    }

    private func fetchAll(where isIncluded: @escaping (SideEffectLedgerStorageRecord) -> Bool) async throws -> [SideEffectLedgerRecord] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .filter(isIncluded)
                .sorted {
                    if $0.occurredAt != $1.occurredAt {
                        return $0.occurredAt > $1.occurredAt
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.sideEffectLedgerRecord(from:))
        }
    }
}

struct SwiftDataEntityRevisionTombstoneRepository: EntityRevisionTombstoneRepository {
    let store: AmbitionsPersistenceStore

    func append(_ tombstone: EntityRevisionTombstone) async throws {
        guard tombstone.isWellFormed else { return }
        try await store.write { context in
            if let storage = try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .first(where: { $0.id == tombstone.id }) {
                try RepositoryMapping.apply(tombstone, to: storage)
            } else {
                context.insert(try RepositoryMapping.entityRevisionTombstoneRecord(from: tombstone))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .sorted {
                    if $0.recordedAt != $1.recordedAt {
                        return $0.recordedAt > $1.recordedAt
                    }
                    return $0.id > $1.id
                }
                .prefix(max(0, limit))
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }

    func fetch(for entityID: String) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .filter { $0.entityID == entityID }
                .sorted {
                    if $0.recordedAt != $1.recordedAt {
                        return $0.recordedAt > $1.recordedAt
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }
}

struct SwiftDataTrustHistoryQueryRepository: TrustHistoryQueryRepository {
    let store: AmbitionsPersistenceStore

    func fetch(_ query: TrustHistoryQuery) async throws -> TrustHistoryQueryProjection {
        try await store.read { context in
            var items: [TrustHistoryQueryResult] = []

            if query.includeReceiptHistory {
                let receiptItems = try context
                    .fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
                    .compactMap { persistedRecord in
                        try? RepositoryMapping.actionReceiptHistoryRecord(from: persistedRecord)
                    }
                    .filter { self.matches($0, query: query) }
                    .map(self.makeResult(from:))
                items.append(contentsOf: receiptItems)
            }

            if query.includeEventLedger {
                let eventItems = try context
                    .fetch(FetchDescriptor<EventLedgerRecord>())
                    .compactMap { persistedRecord in
                        try? RepositoryMapping.eventLedgerEntry(from: persistedRecord)
                    }
                    .filter { self.matches($0, query: query) }
                    .map(self.makeResult(from:))
                items.append(contentsOf: eventItems)
            }

            let sorted = items
                .sorted {
                    if $0.occurredAt != $1.occurredAt { return $0.occurredAt > $1.occurredAt }
                    if $0.kind != $1.kind {
                        return $0.kind == .actionReceipt && $1.kind == .eventLedger
                    }
                    return $0.id < $1.id
                }

            let bounded = max(0, query.limit ?? sorted.count)
            let results = Array(sorted.prefix(min(bounded, sorted.count)))
            let localOnly = results.allSatisfy { $0.localOnly }

            return TrustHistoryQueryProjection(
                query: query,
                results: results,
                totalMatchCount: sorted.count,
                emptyTitle: "Nothing matched",
                emptyDetail: "Try a different query or relax review and proof filters.",
                localOnly: localOnly
            )
        }
    }

    private func makeResult(from record: ActionReceiptHistoryRecord) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "receipt.\(record.receipt.id)",
            kind: .actionReceipt,
            source: record.receipt.sourceDomain.rawValue,
            occurredAt: record.receipt.occurredAt,
            privacy: record.privacyLevel.rawValue,
            proofRelevance: record.proofRelevance,
            trustStatus: record.trustStatus,
            requiresReview: nil,
            userConfirmed: nil,
            proofReferenceKinds: [],
            localOnly: record.localOnly,
            title: record.receipt.title,
            summary: record.receipt.summary
        )
    }

    private func makeResult(from event: EventLedgerEntry) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "event.\(event.id)",
            kind: .eventLedger,
            source: event.source.rawValue,
            occurredAt: event.occurredAt,
            privacy: event.privacy.rawValue,
            proofRelevance: nil,
            trustStatus: nil,
            requiresReview: event.trust.requiresReview,
            userConfirmed: event.trust.isUserConfirmed,
            proofReferenceKinds: event.evidenceReferences
                .map { $0.kind }
                .sorted { lhs, rhs in
                    lhs.rawValue < rhs.rawValue
                },
            localOnly: event.localOnly,
            title: event.title,
            summary: event.summary ?? ""
        )
    }

    private func matches(_ record: ActionReceiptHistoryRecord, query: TrustHistoryQuery) -> Bool {
        if query.includeReceiptHistory == false { return false }
        if let startDate = query.startDate, record.receipt.occurredAt < startDate { return false }
        if let endDate = query.endDate, record.receipt.occurredAt > endDate { return false }
        if query.receiptSourceDomains.isEmpty == false && query.receiptSourceDomains.contains(record.receipt.sourceDomain) == false { return false }
        if query.receiptPrivacyLevels.isEmpty == false && query.receiptPrivacyLevels.contains(record.privacyLevel) == false { return false }
        if query.receiptProofRelevance.isEmpty == false && query.receiptProofRelevance.contains(record.proofRelevance) == false { return false }
        if query.receiptTrustStatuses.isEmpty == false && query.receiptTrustStatuses.contains(record.trustStatus) == false { return false }
        return true
    }

    private func matches(_ event: EventLedgerEntry, query: TrustHistoryQuery) -> Bool {
        if query.includeEventLedger == false { return false }
        if let startDate = query.startDate, event.occurredAt < startDate { return false }
        if let endDate = query.endDate, event.occurredAt > endDate { return false }
        if query.eventSources.isEmpty == false && query.eventSources.contains(event.source) == false { return false }
        if query.eventPrivacyLevels.isEmpty == false && query.eventPrivacyLevels.contains(event.privacy) == false { return false }
        if let requiresReview = query.requiresReview, event.trust.requiresReview != requiresReview { return false }
        if let userConfirmed = query.userConfirmed, event.trust.isUserConfirmed != userConfirmed { return false }
        if let requiresProofReferences = query.requiresProofReferences {
            if event.evidenceReferences.isEmpty == requiresProofReferences { return false }
        }
        if query.proofReferenceKinds.isEmpty == false {
            if event.evidenceReferences.map({ $0.kind }).contains(where: { query.proofReferenceKinds.contains($0) }) == false { return false }
        }
        return true
    }
}

struct SwiftDataEventLedgerRepository: EventLedgerRepository {
    let store: AmbitionsPersistenceStore

    func append(_ event: EventLedgerEntry) async throws {
        try await store.write { context in
            if let record = try context.fetch(FetchDescriptor<EventLedgerRecord>()).first(where: { $0.id == event.id }) {
                try RepositoryMapping.apply(event, to: record)
            } else {
                context.insert(try RepositoryMapping.eventLedgerRecord(from: event))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] {
        let boundedLimit = max(0, limit)
        let events = try await fetchAll { _ in true }
        return events.prefixArray(boundedLimit)
    }

    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.goalID == goalID }
    }

    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.captureID == captureID }
    }

    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.kindRaw == kind.rawValue }
    }

    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] {
        try await fetchAll { $0.occurredAt >= start && $0.occurredAt <= end }
    }

    func redactEvent(id: String, at timestamp: String) async throws {
        try await store.write { context in
            guard let record = try context.fetch(FetchDescriptor<EventLedgerRecord>()).first(where: { $0.id == id }) else {
                return
            }
            let redacted = try RepositoryMapping.eventLedgerEntry(from: record).redacted(at: timestamp)
            try RepositoryMapping.apply(redacted, to: record)
        }
    }

    func deleteEvent(id: String) async throws {
        try await store.write { context in
            for record in try context.fetch(FetchDescriptor<EventLedgerRecord>()) where record.id == id {
                context.delete(record)
            }
        }
    }

    private func fetchAll(where isIncluded: @escaping (EventLedgerRecord) -> Bool) async throws -> [EventLedgerEntry] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EventLedgerRecord>())
                .filter(isIncluded)
                .sorted {
                    if $0.occurredAt != $1.occurredAt {
                        return $0.occurredAt > $1.occurredAt
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.eventLedgerEntry(from:))
        }
    }
}

private extension Array where Element == EventLedgerEntry {
    func prefixArray(_ count: Int) -> [EventLedgerEntry] {
        Array(prefix(count))
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

struct SwiftDataActionReceiptHistoryRepository: ActionReceiptHistoryRepository {
    let store: AmbitionsPersistenceStore

    func save(_ records: [ActionReceiptHistoryRecord]) async throws {
        try await store.write { context in
            let existing = Dictionary(
                uniqueKeysWithValues: try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>()).map { ($0.id, $0) }
            )

            for record in records {
                if let persisted = existing[record.id] {
                    try RepositoryMapping.apply(record, to: persisted)
                } else {
                    context.insert(try RepositoryMapping.actionReceiptHistoryRecord(from: record))
                }
            }
        }
    }

    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection {
        try await store.read { context in
            let persisted = try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
            let records = persisted.compactMap { persistedRecord in
                try? RepositoryMapping.actionReceiptHistoryRecord(from: persistedRecord)
            }
            return ActionReceiptHistoryProjection(records: records).search(query)
        }
    }
}

struct SwiftDataAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    let store: AmbitionsPersistenceStore

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        try await store.write { context in
            if let persisted = try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .first(where: { $0.id == record.id || $0.commandID == record.command.id }) {
                try RepositoryMapping.apply(record, to: persisted)
            } else {
                context.insert(try RepositoryMapping.commandExecutionRecord(from: record))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .sorted {
                    if $0.recordedAt == $1.recordedAt {
                        return $0.id > $1.id
                    }
                    return $0.recordedAt > $1.recordedAt
                }
                .prefix(max(0, limit))
                .map(RepositoryMapping.commandExecutionRecord(from:))
        }
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .first(where: { $0.commandID == commandID })
                .map(RepositoryMapping.commandExecutionRecord(from:))
        }
    }
}
