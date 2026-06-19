import AmbitionsDesignSystem
import Foundation

struct YouMemoryControlState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let consent: YouPersonalizationConsentState
    let privateModeControls: [YouPrivateModeControl]
    let groups: [YouMemoryGroup]
    let narrativeMemories: [YouNarrativeMemory]
    let conservativePatterns: [YouMemoryPattern]
    let memoryLensItems: [YouMemoryLensItem]
    let runtimeInspectionItems: [YouRuntimeInspectionItem]
    let localLearningControls: [YouLocalLearningControl]
    let recoverySummary: String
    let footer: String

    init(
        title: String,
        subtitle: String,
        items: [SettingsItem],
        consent: YouPersonalizationConsentState,
        privateModeControls: [YouPrivateModeControl],
        groups: [YouMemoryGroup],
        narrativeMemories: [YouNarrativeMemory],
        conservativePatterns: [YouMemoryPattern],
        memoryLensItems: [YouMemoryLensItem],
        runtimeInspectionItems: [YouRuntimeInspectionItem] = [],
        localLearningControls: [YouLocalLearningControl] = [],
        recoverySummary: String,
        footer: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.consent = consent
        self.privateModeControls = privateModeControls
        self.groups = groups
        self.narrativeMemories = narrativeMemories
        self.conservativePatterns = conservativePatterns
        self.memoryLensItems = memoryLensItems
        self.runtimeInspectionItems = runtimeInspectionItems
        self.localLearningControls = localLearningControls
        self.recoverySummary = recoverySummary
        self.footer = footer
    }
}

enum YouEverythingSearchObjectKind: String, Sendable, Equatable, CaseIterable {
    case goal
    case capture
    case proof
    case evidence
    case feedback
    case teaching
    case eventLedger = "event_ledger"
    case lifeContext = "life_context"

    var title: String {
        switch self {
        case .goal:
            return "Goal"
        case .capture:
            return "Capture"
        case .proof:
            return "Proof"
        case .evidence:
            return "Evidence"
        case .feedback:
            return "Feedback"
        case .teaching:
            return "Teaching"
        case .eventLedger:
            return "Event Ledger"
        case .lifeContext:
            return "Life Context"
        }
    }

    var systemImage: String {
        switch self {
        case .goal:
            return "target"
        case .capture:
            return "tray.full"
        case .proof:
            return "checkmark.seal"
        case .evidence:
            return "doc.text.magnifyingglass"
        case .feedback:
            return "bubble.left.and.bubble.right"
        case .teaching:
            return "slider.horizontal.3"
        case .eventLedger:
            return "list.bullet.rectangle"
        case .lifeContext:
            return "map"
        }
    }
}

struct YouEverythingSearchAction: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let statusLabel: String
    let detail: String
    let state: AmbitionVisualState
}

struct YouEverythingSearchItem: Identifiable, Sendable, Equatable {
    let id: String
    let kind: YouEverythingSearchObjectKind
    let title: String
    let summary: String
    let sourceLabel: String
    let freshness: YouMemoryFreshness
    let primaryActions: [YouEverythingSearchAction]
    let matchedTerms: [String]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouEverythingSearchState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let queryPrompt: String
    let filters: [SettingsItem]
    let scannedCandidateCount: Int
    let matchedCandidateCount: Int
    let returnedItemCount: Int
    let hitPerformanceBudget: Bool
    let performanceBudgetSummary: String
    let items: [YouEverythingSearchItem]
    let footer: String

    static let empty = YouEverythingSearchState(
        title: "Everything Search",
        subtitle: "Find anything local across goals, captures, proof, teaching, feedback, event history, and life context.",
        queryPrompt: "Find anything local",
        filters: [],
        scannedCandidateCount: 0,
        matchedCandidateCount: 0,
        returnedItemCount: 0,
        hitPerformanceBudget: false,
        performanceBudgetSummary: "No local search candidates loaded yet.",
        items: [],
        footer: "Search stays local, inspectable, and source-tied. No external service is used."
    )

    func filteredItems(matching query: String) -> [YouEverythingSearchItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.isEmpty == false else {
            return items
        }

        return items.filter { item in
            let searchable = [
                item.kind.title,
                item.title,
                item.summary,
                item.sourceLabel,
                item.freshness.label,
                item.primaryActions.map(\.title).joined(separator: " "),
                item.primaryActions.map(\.detail).joined(separator: " "),
                item.matchedTerms.joined(separator: " ")
            ]
            .joined(separator: " ")
            .lowercased()

            return searchable.contains(trimmed)
        }
    }

    func summary(for query: String) -> String {
        let filtered = filteredItems(matching: query)
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(returnedItemCount) local objects are ready to inspect."
        }
        let visibleCount = min(filtered.count, 12)
        return "Showing \(visibleCount) of \(filtered.count) matched local objects."
    }
}

enum YouSourceAtlasKnowledgeRuntimeUseState: String, Sendable, Equatable {
    case usedToPlan = "used_to_plan"
    case notUsed = "not_used"

    var label: String {
        switch self {
        case .usedToPlan:
            return "Used to Plan"
        case .notUsed:
            return "Not Used"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .usedToPlan:
            return .success
        case .notUsed:
            return .default
        }
    }
}

struct YouSourceAtlasKnowledgeRow: Identifiable, Sendable, Equatable {
    let id: String
    let icon: String
    let title: String
    let usedWhat: String
    let whyUsed: String
    let sourceName: String
    let sourceStateLabel: String
    let freshnessStateLabel: String
    let riskStateLabel: String
    let runtimeUseState: YouSourceAtlasKnowledgeRuntimeUseState
    let reviewNeedLabel: String
    let correctionPath: String
    let reviewPath: String
    let state: AmbitionVisualState
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct YouSourceAtlasKnowledgeSection: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let rows: [YouSourceAtlasKnowledgeRow]
    let footer: String?
}

struct YouSourceAtlasKnowledgeState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let sections: [YouSourceAtlasKnowledgeSection]
    let footer: String

    static let empty = YouSourceAtlasKnowledgeState(
        title: "Source Atlas & Goal Knowledge",
        subtitle: "What Ambitions used, why it used it, and where review or correction stays supported.",
        sections: [],
        footer: "Goal Knowledge stays local, inspectable, and correction-aware."
    )
}

struct YouAssumptionCorrectionState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

struct YouAutomationBoundaryState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let rules: [YouConstitutionRule]
    let footer: String
}

struct YouReceiptAuditState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [SettingsItem]
    let footer: String
}

enum YouTrustHistoryCategory: String, Sendable, Equatable, CaseIterable {
    case receipts
    case proof
    case changes
    case sourceReview
    case privacy
    case automation

    var title: String {
        switch self {
        case .receipts: "Receipts"
        case .proof: "Proof"
        case .changes: "Changes"
        case .sourceReview: "Source Review"
        case .privacy: "Privacy"
        case .automation: "Automation"
        }
    }
}

struct YouTrustHistoryItem: Identifiable, Sendable, Equatable {
    let id: String
    let category: YouTrustHistoryCategory
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let privacyLabel: String
    let reversibilityLabel: String
    let state: AmbitionVisualState
}

struct YouTrustHistoryCenterState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [YouTrustHistoryItem]
    let footer: String

    static let empty = YouTrustHistoryCenterState(
        title: "Trust History",
        subtitle: "Receipts, proof, source review, changes, privacy, and automation boundaries stay reviewable from You.",
        items: [],
        footer: "This is a review surface, not a feed. Detail stays behind the owning surface."
    )
}

struct YouReviewsState: Sendable, Equatable {
    let projection: ReviewsV1Projection
    let title: String
    let subtitle: String
    let footer: String
}

struct YouContextVaultItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let detail: String
}

struct YouSignalPolicyItem: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct YouContextVaultState: Sendable, Equatable {
    let title: String
    let subtitle: String
    let items: [YouContextVaultItem]
    let policyItems: [YouSignalPolicyItem]
    let footer: String
}

enum YouPersonalVaultRowKind: String, Sendable, Equatable, CaseIterable {
    case signal
    case permission

    var label: String {
        switch self {
        case .signal:
            return "Signal"
        case .permission:
            return "Permission"
        }
    }
}
