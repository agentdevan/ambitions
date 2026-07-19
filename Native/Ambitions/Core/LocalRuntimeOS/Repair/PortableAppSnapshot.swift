import Foundation

struct PortableAppSnapshot: Codable, Sendable, Equatable {
    let metadata: PortableAppSnapshotMetadata
    let manifest: PortableExportManifest
    let goals: [Goal]
    let drafts: [PersistedGoalDraft]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]
    let actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord]
    let entityRevisionTombstones: [EntityRevisionTombstone]
    let entityRevisionLineageViews: [EntityRevisionTombstoneLineageView]
    let captures: [Capture]
    let teachingSignals: [GoalTeachingSignal]
    let appState: AppStateSnapshot

    enum CodingKeys: String, CodingKey {
        case metadata
        case manifest
        case goals
        case drafts
        case evidence
        case feedback
        case actionReceiptHistory
        case entityRevisionTombstones
        case entityRevisionLineageViews
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
        actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord] = [],
        entityRevisionTombstones: [EntityRevisionTombstone] = [],
        entityRevisionLineageViews: [EntityRevisionTombstoneLineageView] = [],
        captures: [Capture],
        teachingSignals: [GoalTeachingSignal] = [],
        appState: AppStateSnapshot,
        manifest: PortableExportManifest? = nil
    ) {
        self.metadata = metadata
        self.goals = goals
        self.drafts = drafts
        self.evidence = evidence
        self.feedback = feedback
        self.actionReceiptHistory = actionReceiptHistory
        self.entityRevisionTombstones = entityRevisionTombstones
        self.entityRevisionLineageViews = entityRevisionLineageViews
        self.captures = captures
        self.teachingSignals = teachingSignals
        self.appState = appState
        self.manifest = manifest ?? PortableExportManifest.make(
            selection: .all,
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            actionReceiptHistory: actionReceiptHistory,
            entityRevisionTombstones: entityRevisionTombstones,
            entityRevisionLineageViews: entityRevisionLineageViews,
            captures: captures,
            teachingSignals: teachingSignals,
            appState: appState
        )
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        metadata = try container.decode(PortableAppSnapshotMetadata.self, forKey: .metadata)
        goals = try container.decode([Goal].self, forKey: .goals)
        drafts = try container.decode([PersistedGoalDraft].self, forKey: .drafts)
        evidence = try container.decode([ProgressEvidence].self, forKey: .evidence)
        feedback = try container.decode([PortableStoredGoalFeedbackEvent].self, forKey: .feedback).map(\.event)
        actionReceiptHistory = try container.decodeIfPresent([PortableStoredActionReceiptHistoryRecord].self, forKey: .actionReceiptHistory) ?? []
        entityRevisionTombstones = try container.decodeIfPresent([EntityRevisionTombstone].self, forKey: .entityRevisionTombstones) ?? []
        entityRevisionLineageViews = try container.decodeIfPresent([EntityRevisionTombstoneLineageView].self, forKey: .entityRevisionLineageViews) ?? []
        captures = try container.decode([Capture].self, forKey: .captures)
        teachingSignals = try container.decodeIfPresent([GoalTeachingSignal].self, forKey: .teachingSignals) ?? []
        appState = try container.decode(AppStateSnapshot.self, forKey: .appState)
        manifest = try container.decodeIfPresent(PortableExportManifest.self, forKey: .manifest) ?? PortableExportManifest.make(
            selection: .all,
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            actionReceiptHistory: actionReceiptHistory,
            entityRevisionTombstones: entityRevisionTombstones,
            entityRevisionLineageViews: entityRevisionLineageViews,
            captures: captures,
            teachingSignals: teachingSignals,
            appState: appState
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(manifest, forKey: .manifest)
        try container.encode(goals, forKey: .goals)
        try container.encode(drafts, forKey: .drafts)
        try container.encode(evidence, forKey: .evidence)
        try container.encode(feedback.map(PortableStoredGoalFeedbackEvent.init), forKey: .feedback)
        try container.encode(actionReceiptHistory, forKey: .actionReceiptHistory)
        try container.encode(entityRevisionTombstones, forKey: .entityRevisionTombstones)
        try container.encode(entityRevisionLineageViews, forKey: .entityRevisionLineageViews)
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

struct PortableImportSafetySummary: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let headline: String
    let safeFailureMessage: String
    let requiresExplicitConfirmation: Bool
    let importedItemCount: Int
    let conflictCount: Int
    let warningMessages: [String]
}

struct PortableImportDryRunSafetySummary: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let headline: String
    let safeFailureMessage: String
    let requiresExplicitConfirmation: Bool
    let wouldImportItemCount: Int
    let conflictCount: Int
    let warningMessages: [String]
}

struct PortableImportDryRunReport: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let wouldResetLocalStore: Bool
    let wouldImportGoalCount: Int
    let wouldImportDraftCount: Int
    let wouldImportEvidenceCount: Int
    let wouldImportFeedbackCount: Int
    let wouldImportActionReceiptHistoryCount: Int
    let wouldImportEntityRevisionTombstoneCount: Int
    let wouldImportCaptureCount: Int
    let wouldImportTeachingSignalCount: Int
    let wouldImportAppStateCount: Int
    let conflicts: [PortableConflict]
    let warnings: [PortableImportWarning]
    let safetySummary: PortableImportDryRunSafetySummary
    let durableMutationAllowed: Bool

    init(
        mode: PortableImportMode,
        wouldResetLocalStore: Bool,
        wouldImportGoalCount: Int,
        wouldImportDraftCount: Int,
        wouldImportEvidenceCount: Int,
        wouldImportFeedbackCount: Int,
        wouldImportActionReceiptHistoryCount: Int = 0,
        wouldImportEntityRevisionTombstoneCount: Int = 0,
        wouldImportCaptureCount: Int,
        wouldImportTeachingSignalCount: Int = 0,
        wouldImportAppStateCount: Int,
        conflicts: [PortableConflict],
        warnings: [PortableImportWarning],
        durableMutationAllowed: Bool = false,
        safetySummary: PortableImportDryRunSafetySummary? = nil
    ) {
        self.mode = mode
        self.wouldResetLocalStore = wouldResetLocalStore
        self.wouldImportGoalCount = wouldImportGoalCount
        self.wouldImportDraftCount = wouldImportDraftCount
        self.wouldImportEvidenceCount = wouldImportEvidenceCount
        self.wouldImportFeedbackCount = wouldImportFeedbackCount
        self.wouldImportActionReceiptHistoryCount = wouldImportActionReceiptHistoryCount
        self.wouldImportEntityRevisionTombstoneCount = wouldImportEntityRevisionTombstoneCount
        self.wouldImportCaptureCount = wouldImportCaptureCount
        self.wouldImportTeachingSignalCount = wouldImportTeachingSignalCount
        self.wouldImportAppStateCount = wouldImportAppStateCount
        self.conflicts = conflicts
        self.warnings = warnings
        self.durableMutationAllowed = durableMutationAllowed
        self.safetySummary = safetySummary ?? PortableImportDryRunSafetySummary(
            mode: mode,
            headline: conflicts.isEmpty ? "Dry run completed without durable changes." : "Dry run found items that need review before import.",
            safeFailureMessage: "Dry run does not reset, save, or overwrite local Ambitions data.",
            requiresExplicitConfirmation: mode == .replaceLocalStore,
            wouldImportItemCount: wouldImportGoalCount + wouldImportDraftCount + wouldImportEvidenceCount + wouldImportFeedbackCount + wouldImportActionReceiptHistoryCount + wouldImportEntityRevisionTombstoneCount + wouldImportCaptureCount + wouldImportTeachingSignalCount + wouldImportAppStateCount,
            conflictCount: conflicts.count,
            warningMessages: warnings.map(\.message)
        )
    }
}

enum PortableManualMergeAction: String, Codable, Sendable, Equatable {
    case keepLocal = "keep_local"
    case needsReview = "needs_review"
}

struct PortableManualMergeItem: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let entityKind: PortableConflictEntityKind
    let entityID: String
    let action: PortableManualMergeAction
    let localRevisionMarker: String?
    let incomingRevisionMarker: String?
    let reason: String
}

struct PortableManualMergePlan: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let safeImportItemCount: Int
    let reviewItemCount: Int
    let warningMessages: [String]
    let items: [PortableManualMergeItem]
    let durableMutationAllowed: Bool
    let userDecisionRequired: Bool

    init(dryRunReport: PortableImportDryRunReport) {
        self.mode = .mergeWithConflictReport
        self.safeImportItemCount = dryRunReport.safetySummary.wouldImportItemCount
        self.reviewItemCount = dryRunReport.conflicts.count
        self.warningMessages = dryRunReport.warnings.map(\.message)
        self.items = dryRunReport.conflicts.map { conflict in
            PortableManualMergeItem(
                id: "manual_merge.\(conflict.id)",
                entityKind: conflict.entityKind,
                entityID: conflict.entityID,
                action: conflict.recommendation == .keepLocal ? .keepLocal : .needsReview,
                localRevisionMarker: conflict.localRevisionMarker,
                incomingRevisionMarker: conflict.incomingRevisionMarker,
                reason: conflict.reason
            )
        }
        self.durableMutationAllowed = false
        self.userDecisionRequired = items.contains { $0.action == .needsReview }
    }
}

struct PortableImportReport: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let importedGoalCount: Int
    let importedDraftCount: Int
    let importedEvidenceCount: Int
    let importedFeedbackCount: Int
    let importedActionReceiptHistoryCount: Int
    let importedEntityRevisionTombstoneCount: Int
    let importedCaptureCount: Int
    let importedTeachingSignalCount: Int
    let importedAppStateCount: Int
    let conflicts: [PortableConflict]
    let warnings: [PortableImportWarning]
    let safetySummary: PortableImportSafetySummary

    init(
        mode: PortableImportMode,
        importedGoalCount: Int,
        importedDraftCount: Int,
        importedEvidenceCount: Int,
        importedFeedbackCount: Int,
        importedActionReceiptHistoryCount: Int = 0,
        importedEntityRevisionTombstoneCount: Int = 0,
        importedCaptureCount: Int,
        importedTeachingSignalCount: Int = 0,
        importedAppStateCount: Int,
        conflicts: [PortableConflict],
        warnings: [PortableImportWarning],
        safetySummary: PortableImportSafetySummary? = nil
    ) {
        self.mode = mode
        self.importedGoalCount = importedGoalCount
        self.importedDraftCount = importedDraftCount
        self.importedEvidenceCount = importedEvidenceCount
        self.importedFeedbackCount = importedFeedbackCount
        self.importedActionReceiptHistoryCount = importedActionReceiptHistoryCount
        self.importedEntityRevisionTombstoneCount = importedEntityRevisionTombstoneCount
        self.importedCaptureCount = importedCaptureCount
        self.importedTeachingSignalCount = importedTeachingSignalCount
        self.importedAppStateCount = importedAppStateCount
        self.conflicts = conflicts
        self.warnings = warnings
        self.safetySummary = safetySummary ?? PortableImportSafetySummary(
            mode: mode,
            headline: conflicts.isEmpty ? "Import completed from a local portable package." : "Imported safe items and kept local data where review is needed.",
            safeFailureMessage: "If import cannot complete, your current Ambitions data stays local and the package can be reviewed again.",
            requiresExplicitConfirmation: mode == .replaceLocalStore,
            importedItemCount: importedGoalCount + importedDraftCount + importedEvidenceCount + importedFeedbackCount + importedActionReceiptHistoryCount + importedEntityRevisionTombstoneCount + importedCaptureCount + importedTeachingSignalCount + importedAppStateCount,
            conflictCount: conflicts.count,
            warningMessages: warnings.map(\.message)
        )
    }
}

enum PortableSnapshotError: Error, Equatable {
    case unsupportedSchemaVersion(String)
}
