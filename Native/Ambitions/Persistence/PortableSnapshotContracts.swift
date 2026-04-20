import Foundation

struct PortableSnapshotSchemaVersion: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let v1 = PortableSnapshotSchemaVersion(rawValue: "portable_app_snapshot.v1")
}

enum PortableTrustPosture: String, Codable, Sendable {
    case localOnly = "local_only"
}

enum PortableImportMode: String, Codable, Sendable {
    case replaceLocalStore = "replace_local_store"
    case mergeWithConflictReport = "merge_with_conflict_report"
}

struct PortableAppSnapshotMetadata: Codable, Sendable, Equatable {
    let schemaVersion: PortableSnapshotSchemaVersion
    let exportedAt: String
    let source: String
    let trustPosture: PortableTrustPosture
}

struct PortableAppSnapshot: Codable, Sendable, Equatable {
    let metadata: PortableAppSnapshotMetadata
    let goals: [Goal]
    let drafts: [PersistedGoalDraft]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]
    let captures: [Capture]
    let teachingSignals: [GoalTeachingSignal]
    let appState: AppStateSnapshot

    private enum CodingKeys: String, CodingKey {
        case metadata
        case goals
        case drafts
        case evidence
        case feedback
        case captures
        case teachingSignals
        case appState
    }

    init(
        metadata: PortableAppSnapshotMetadata,
        goals: [Goal],
        drafts: [PersistedGoalDraft],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        captures: [Capture],
        teachingSignals: [GoalTeachingSignal] = [],
        appState: AppStateSnapshot
    ) {
        self.metadata = metadata
        self.goals = goals
        self.drafts = drafts
        self.evidence = evidence
        self.feedback = feedback
        self.captures = captures
        self.teachingSignals = teachingSignals
        self.appState = appState
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metadata = try container.decode(PortableAppSnapshotMetadata.self, forKey: .metadata)
        goals = try container.decode([Goal].self, forKey: .goals)
        drafts = try container.decode([PersistedGoalDraft].self, forKey: .drafts)
        evidence = try container.decode([ProgressEvidence].self, forKey: .evidence)
        feedback = try container.decode([PortableStoredGoalFeedbackEvent].self, forKey: .feedback).map(\.event)
        captures = try container.decode([Capture].self, forKey: .captures)
        teachingSignals = try container.decodeIfPresent([GoalTeachingSignal].self, forKey: .teachingSignals) ?? []
        appState = try container.decode(AppStateSnapshot.self, forKey: .appState)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(goals, forKey: .goals)
        try container.encode(drafts, forKey: .drafts)
        try container.encode(evidence, forKey: .evidence)
        try container.encode(feedback.map(PortableStoredGoalFeedbackEvent.init), forKey: .feedback)
        try container.encode(captures, forKey: .captures)
        try container.encode(teachingSignals, forKey: .teachingSignals)
        try container.encode(appState, forKey: .appState)
    }
}

enum PortableConflictEntityKind: String, Codable, Sendable {
    case goal
    case draft
    case evidence
    case feedback
    case capture
    case teachingSignal = "teaching_signal"
    case appState = "app_state"
}

enum PortableConflictResolutionRecommendation: String, Codable, Sendable {
    case keepLocal = "keep_local"
    case acceptIncoming = "accept_incoming"
    case requiresUserDecision = "requires_user_decision"
}

struct PortableConflict: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let entityKind: PortableConflictEntityKind
    let entityID: String
    let localRevisionMarker: String?
    let incomingRevisionMarker: String?
    let recommendation: PortableConflictResolutionRecommendation
    let reason: String
}

struct PortableImportWarning: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let message: String
}

struct PortableImportReport: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let importedGoalCount: Int
    let importedDraftCount: Int
    let importedEvidenceCount: Int
    let importedFeedbackCount: Int
    let importedCaptureCount: Int
    let importedTeachingSignalCount: Int
    let importedAppStateCount: Int
    let conflicts: [PortableConflict]
    let warnings: [PortableImportWarning]

    init(
        mode: PortableImportMode,
        importedGoalCount: Int,
        importedDraftCount: Int,
        importedEvidenceCount: Int,
        importedFeedbackCount: Int,
        importedCaptureCount: Int,
        importedTeachingSignalCount: Int = 0,
        importedAppStateCount: Int,
        conflicts: [PortableConflict],
        warnings: [PortableImportWarning]
    ) {
        self.mode = mode
        self.importedGoalCount = importedGoalCount
        self.importedDraftCount = importedDraftCount
        self.importedEvidenceCount = importedEvidenceCount
        self.importedFeedbackCount = importedFeedbackCount
        self.importedCaptureCount = importedCaptureCount
        self.importedTeachingSignalCount = importedTeachingSignalCount
        self.importedAppStateCount = importedAppStateCount
        self.conflicts = conflicts
        self.warnings = warnings
    }
}

enum PortableSnapshotError: Error, Equatable {
    case unsupportedSchemaVersion(String)
}

private struct PortableStoredGoalFeedbackEvent: Codable, Sendable, Equatable {
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

    init(
        schemaVersion: String?,
        kind: GoalHistoryEventKind,
        base: GoalFeedbackEventBase,
        actualDuration: Int?,
        effortLevel: GoalFeedbackEffortLevel?,
        confidenceDelta: Double?,
        reasonCode: GoalStepSkipReasonCode?,
        timingAdjustment: GoalTimingAdjustment?,
        adjustedDate: String?,
        rewrittenText: String?,
        confusionType: GoalConfusionType?
    ) {
        self.schemaVersion = schemaVersion
        self.kind = kind
        self.base = base
        self.actualDuration = actualDuration
        self.effortLevel = effortLevel
        self.confidenceDelta = confidenceDelta
        self.reasonCode = reasonCode
        self.timingAdjustment = timingAdjustment
        self.adjustedDate = adjustedDate
        self.rewrittenText = rewrittenText
        self.confusionType = confusionType
    }

    init(event: GoalFeedbackEvent) {
        switch event {
        case let .completed(base, actualDuration, effortLevel, confidenceDelta):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .completed, base: base, actualDuration: actualDuration, effortLevel: effortLevel, confidenceDelta: confidenceDelta, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .skipped(base, reasonCode):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .skipped, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: reasonCode, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .delayed(base, timingAdjustment, date):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .delayed, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: timingAdjustment, adjustedDate: date, rewrittenText: nil, confusionType: nil)
        case let .edited(base, rewrittenText):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .edited, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: rewrittenText, confusionType: nil)
        case let .confused(base, confusionType):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .confused, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: confusionType)
        case let .tooBig(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooBig, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .tooEasy(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooEasy, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .notRelevant(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .notRelevant, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedForSmallerVersion(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedForSmallerVersion, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedWhyThisMatters(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedWhyThisMatters, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
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
