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
    let privacyClass: AFEPStoragePrivacyClass
    let indexingPolicy: AFEPIndexingPolicy
    let exportPolicy: AFEPExportPolicy
    let measurementEvidenceState: AFEPMeasurementEvidenceState
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
                privacyClass: category.privacyClass,
                indexingPolicy: category.indexingPolicy,
                exportPolicy: category.exportPolicy,
                measurementEvidenceState: category.measurementEvidenceState,
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

    static func itemCount(
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

extension PortableExportCategory {
    var privacyClass: AFEPStoragePrivacyClass {
        switch self {
        case .goalsAndPlans:
            return .privateSensitive
        case .captures:
            return .privateSensitive
        case .proof:
            return .proofRestricted
        case .receipts:
            return .proofRestricted
        case .memory:
            return .localOnly
        case .settings:
            return .systemOwned
        }
    }

    var indexingPolicy: AFEPIndexingPolicy {
        switch self {
        case .settings:
            return .indexed
        case .goalsAndPlans, .captures, .proof, .receipts, .memory:
            return .notIndexed
        }
    }

    var exportPolicy: AFEPExportPolicy {
        switch self {
        case .settings:
            return .safe
        case .goalsAndPlans, .captures, .proof, .receipts, .memory:
            return .exportReviewOnly
        }
    }

    var measurementEvidenceState: AFEPMeasurementEvidenceState {
        .planned
    }

    var containsSensitiveUserText: Bool {
        privacyClass.requiresRedaction
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
