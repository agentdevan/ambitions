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

enum PortableExportCategory: String, Codable, Sendable, CaseIterable, Hashable {
    case goalsAndPlans = "goals_and_plans"
    case captures
    case proof
    case receipts
    case memory
    case settings

    var title: String {
        switch self {
        case .goalsAndPlans:
            return "Goals and plans"
        case .captures:
            return "Captures"
        case .proof:
            return "Proof"
        case .receipts:
            return "Receipts and history"
        case .memory:
            return "Memory"
        case .settings:
            return "Settings"
        }
    }
}

struct PortableExportSelection: Sendable, Equatable {
    let categories: Set<PortableExportCategory>

    init(categories: Set<PortableExportCategory> = Set(PortableExportCategory.allCases)) {
        self.categories = categories
    }

    static let all = PortableExportSelection()

    func includes(_ category: PortableExportCategory) -> Bool {
        categories.contains(category)
    }
}

struct PortableExportCategorySummary: Codable, Sendable, Equatable, Identifiable {
    var id: String { category.rawValue }

    let category: PortableExportCategory
    let title: String
    let isIncluded: Bool
    let itemCount: Int
    let containsSensitiveUserText: Bool
    let previewRule: String
    let detail: String
}

struct PortableExportExclusion: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let reason: String
}

struct PortableExportManifest: Codable, Sendable, Equatable {
    let categories: [PortableExportCategorySummary]
    let exclusions: [PortableExportExclusion]
    let privacyRules: [String]
    let userSummary: String

    static func make(
        selection: PortableExportSelection,
        goals: [Goal],
        drafts: [PersistedGoalDraft],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord] = [],
        entityRevisionTombstones: [EntityRevisionTombstone] = [],
        entityRevisionLineageViews: [EntityRevisionTombstoneLineageView] = [],
        captures: [Capture],
        teachingSignals: [GoalTeachingSignal],
        appState: AppStateSnapshot
    ) -> PortableExportManifest {
        let categories = PortableExportCategory.allCases.map { category in
            PortableExportCategorySummary(
                category: category,
                title: category.title,
                isIncluded: selection.includes(category),
                itemCount: itemCount(
                    category: category,
                    selection: selection,
                    goals: goals,
                    drafts: drafts,
                    evidence: evidence,
                    feedback: feedback,
                    actionReceiptHistory: actionReceiptHistory,
                    entityRevisionTombstones: entityRevisionTombstones,
                    captures: captures,
                    teachingSignals: teachingSignals,
                    appState: appState
                ),
                containsSensitiveUserText: category.containsSensitiveUserText,
                previewRule: category.previewRule,
                detail: category.detail
            )
        }
        let excludedBySelection = PortableExportCategory.allCases
            .filter { selection.includes($0) == false }
            .map {
                PortableExportExclusion(
                    id: "excluded.\($0.rawValue)",
                    title: $0.title,
                    reason: "Not selected for this portable package."
                )
            }

        return PortableExportManifest(
            categories: categories,
            exclusions: excludedBySelection + [
                PortableExportExclusion(id: "excluded.raw-calendar-events", title: "Raw calendar events", reason: "Ambitions only keeps local derived planning context; raw calendar event titles are not exported."),
                PortableExportExclusion(id: "excluded.cloud-sync-account", title: "Cloud sync or account data", reason: "No cloud account or Apple-first sync data exists in this local-only package."),
                PortableExportExclusion(id: "excluded.external-rendered-state", title: "Rendered widget or Live Activity state", reason: "External surfaces can rebuild from safe local snapshots; rendered platform state is not portable user data.")
            ],
            privacyRules: [
                "The package is local-only and user-initiated.",
                "Preview surfaces must use redacted receipt/proof summaries for private or sensitive details.",
                "Import must report conflicts instead of silently overwriting newer local records.",
                "Replace-local-store mode requires explicit confirmation before use."
            ],
            userSummary: "This package can move selected local Ambitions data without requiring an account or cloud sync."
        )
    }

    func summary(for category: PortableExportCategory) -> PortableExportCategorySummary? {
        categories.first { $0.category == category }
    }

    private static func itemCount(
        category: PortableExportCategory,
        selection: PortableExportSelection,
        goals: [Goal],
        drafts: [PersistedGoalDraft],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        actionReceiptHistory: [PortableStoredActionReceiptHistoryRecord],
        entityRevisionTombstones: [EntityRevisionTombstone],
        captures: [Capture],
        teachingSignals: [GoalTeachingSignal],
        appState: AppStateSnapshot
    ) -> Int {
        guard selection.includes(category) else { return 0 }
        switch category {
        case .goalsAndPlans:
            return goals.count + drafts.count
        case .captures:
            return captures.count
        case .proof:
            return evidence.count
        case .receipts:
            return feedback.count + actionReceiptHistory.count + entityRevisionTombstones.count
        case .memory:
            return teachingSignals.count
        case .settings:
            return appState == .default ? 0 : 1
        }
    }
}

private extension PortableExportCategory {
    var containsSensitiveUserText: Bool {
        switch self {
        case .goalsAndPlans, .captures, .proof, .receipts, .memory:
            return true
        case .settings:
            return false
        }
    }

    var previewRule: String {
        switch self {
        case .goalsAndPlans:
            return "Show goal titles and plan summaries only after user review."
        case .captures:
            return "Show capture text only in explicit export review."
        case .proof:
            return "Use D05 redacted proof summaries before showing private details."
        case .receipts:
            return "Use receipt history redaction rules before showing changed facts, revision markers, or lineage views."
        case .memory:
            return "Show source and freshness before exposing teaching/correction details."
        case .settings:
            return "Show preference labels, not implementation keys."
        }
    }

    var detail: String {
        switch self {
        case .goalsAndPlans:
            return "Goals, embedded Steps, draft plans, assumptions, blockers, and local planning context."
        case .captures:
            return "Open captures, placed captures, and Needs a Place items."
        case .proof:
            return "Progress evidence that can support proof and review flows."
        case .receipts:
            return "Goal feedback, canonical action receipts, revision tombstones, and redacted lineage views that can explain what changed."
        case .memory:
            return "Explicit teaching signals and correction anchors."
        case .settings:
            return "Local app preferences, selected tab, display name, and import summary."
        }
    }
}

struct PortableAppSnapshotMetadata: Codable, Sendable, Equatable {
    let schemaVersion: PortableSnapshotSchemaVersion
    let exportedAt: String
    let source: String
    let trustPosture: PortableTrustPosture
}

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

    private enum CodingKeys: String, CodingKey {
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

struct PortableStoredActionReceiptHistoryRecord: Codable, Sendable, Equatable {
    let receipt: ActionReceipt
    let privacyLevel: ActionReceiptPrivacyLevel
    let localOnly: Bool
    let proofRelevance: ActionReceiptProofRelevance
    let requiresConfirmationBeforeBroaderUse: Bool
    let proofFreshnessLineage: ActionReceiptProofFreshnessLineage

    init(
        receipt: ActionReceipt,
        privacyLevel: ActionReceiptPrivacyLevel,
        localOnly: Bool,
        proofRelevance: ActionReceiptProofRelevance,
        requiresConfirmationBeforeBroaderUse: Bool,
        proofFreshnessLineage: ActionReceiptProofFreshnessLineage
    ) {
        self.receipt = receipt
        self.privacyLevel = privacyLevel
        self.localOnly = localOnly
        self.proofRelevance = proofRelevance
        self.requiresConfirmationBeforeBroaderUse = requiresConfirmationBeforeBroaderUse
        self.proofFreshnessLineage = proofFreshnessLineage
    }

    init(_ record: ActionReceiptHistoryRecord) {
        self.init(
            receipt: record.receipt,
            privacyLevel: record.privacyLevel,
            localOnly: record.localOnly,
            proofRelevance: record.proofRelevance,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse,
            proofFreshnessLineage: record.proofFreshnessLineage
        )
    }

    var record: ActionReceiptHistoryRecord {
        ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: privacyLevel,
            localOnly: localOnly,
            proofRelevance: proofRelevance,
            requiresConfirmationBeforeBroaderUse: requiresConfirmationBeforeBroaderUse,
            proofFreshnessLineage: proofFreshnessLineage
        )
    }
}
