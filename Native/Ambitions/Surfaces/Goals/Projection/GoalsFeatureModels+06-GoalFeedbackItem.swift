import AmbitionsDesignSystem
import Foundation

struct GoalFeedbackItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let categoryLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementState: Sendable {
    let title: String
    let summary: String
    let items: [GoalDetailRecentMovementItem]
}

enum GoalDetailMissionLaneKind: String, Sendable, CaseIterable {
    case overview
    case path
    case steps
    case proof
    case decisions
    case risks
    case archive

    var title: String {
        switch self {
        case .overview: "Overview"
        case .path: "Path"
        case .steps: "Steps"
        case .proof: "Proof"
        case .decisions: "Decisions"
        case .risks: "Risks"
        case .archive: "Archive"
        }
    }

    var accessibilityIdentifier: String {
        "goal-detail.lane.\(rawValue)"
    }
}

struct GoalDetailMissionLaneState: Identifiable, Sendable {
    let kind: GoalDetailMissionLaneKind
    let title: String
    let headline: String
    let summary: String
    let detail: String
    let badgeTitle: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

struct GoalDetailBreadcrumbState: Sendable {
    let title: String
    let labels: [String]
    let fallbackUsed: Bool
}

enum GoalDetailTimelineItemKind: String, Sendable {
    case started
    case previous
    case current
    case next
    case proof
    case decision
    case waiting
    case parked
    case completed
    case cancelled

    var title: String {
        switch self {
        case .started: "Started"
        case .previous: "Previous"
        case .current: "Current"
        case .next: "Next"
        case .proof: "Proof"
        case .decision: "Decision"
        case .waiting: "Waiting"
        case .parked: "Parked"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

struct GoalDetailTimelineItemState: Identifiable, Sendable {
    let id: String
    let kind: GoalDetailTimelineItemKind
    let title: String
    let summary: String
    let timestamp: String?
    let state: AmbitionVisualState
    let isFuture: Bool
}

struct GoalDetailTimelineState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailTimelineItemState]
}

struct GoalDetailAssumptionState: Identifiable, Sendable {
    let id: String
    let title: String
    let status: String
    let whyItMatters: String
    let correctionLabel: String?
    let state: AmbitionVisualState
}

struct GoalDetailProofRailState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalEvidenceItem]
    let spineBeads: [ProofBead]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailReceiptItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailReceiptsState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailReceiptItemState]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailDecisionItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailDecisionsState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailDecisionItemState]
    let emptyTitle: String
    let emptyMessage: String
}

enum GoalAlternatePathDecisionBranchKind: String, Sendable {
    case alternatePath
    case decisionHistory

    var title: String {
        switch self {
        case .alternatePath: "Alternate path"
        case .decisionHistory: "Decision history"
        }
    }

    var symbolName: String {
        switch self {
        case .alternatePath: "arrow.triangle.branch"
        case .decisionHistory: "clock.arrow.circlepath"
        }
    }
}

struct GoalAlternatePathDecisionBranchState: Identifiable, Sendable {
    let id: String
    let kind: GoalAlternatePathDecisionBranchKind
    let title: String
    let summary: String
    let basisLabel: String
    let reviewLabel: String
    let consequenceLabel: String
    let mutationBoundaryLabel: String
    let freshnessLabel: String
    let state: AmbitionVisualState
}

struct GoalAlternatePathDecisionSpineState: Sendable {
    let title: String
    let subtitle: String
    let branches: [GoalAlternatePathDecisionBranchState]
    let emptyTitle: String
    let emptyMessage: String
    let boundaryLabel: String
    let accessibilitySummary: String

    init(
        decisions: GoalDetailDecisionsState,
        pathBuilder: GoalPathBuilderState?
    ) {
        let alternateBranches = (pathBuilder?.forks ?? []).prefix(3).map { fork in
            GoalAlternatePathDecisionBranchState(
                id: "alternate-path-\(fork.id)",
                kind: .alternatePath,
                title: fork.title,
                summary: fork.summary,
                basisLabel: fork.basisSummary,
                reviewLabel: fork.decisionPrompt.localizedCaseInsensitiveContains("review")
                    ? fork.decisionPrompt
                    : "Review first: \(fork.decisionPrompt)",
                consequenceLabel: "Review tradeoffs before this branch changes Today or the goal path.",
                mutationBoundaryLabel: "No automated reroute; no plan changed.",
                freshnessLabel: fork.freshnessLabel,
                state: fork.state
            )
        }

        let decisionBranches = decisions.items.prefix(4).map { item in
            GoalAlternatePathDecisionBranchState(
                id: "decision-history-\(item.id)",
                kind: .decisionHistory,
                title: item.title,
                summary: item.summary,
                basisLabel: "Recorded \(item.timestamp)",
                reviewLabel: "Review why this changed before using it as a route signal.",
                consequenceLabel: "This remains history unless the user changes the goal.",
                mutationBoundaryLabel: "No hidden path mutation.",
                freshnessLabel: "History",
                state: item.state
            )
        }

        let branches = Array((alternateBranches + decisionBranches).prefix(7))
        let boundaryLabel = "Review only. No automated reroute; no hidden plan or path mutation."

        self.title = "Decision Spine"
        self.subtitle = branches.isEmpty
            ? "Alternate path and decision history folds appear here when the goal has real signals."
            : "Alternate paths and real decisions stay folded together before anything changes."
        self.branches = branches
        self.emptyTitle = decisions.emptyTitle
        self.emptyMessage = decisions.emptyMessage
        self.boundaryLabel = boundaryLabel
        self.accessibilitySummary = branches.isEmpty
            ? "\(self.title). \(self.subtitle). \(boundaryLabel)"
            : branches.map {
                "\($0.kind.title): \($0.title). \($0.reviewLabel) \($0.mutationBoundaryLabel)"
            }.joined(separator: " ") + " \(boundaryLabel)"
    }
}

enum GoalDetailReviewTrailKind: String, Sendable {
    case proof
    case decision
    case assumption
    case receipt

    var title: String {
        switch self {
        case .proof: "Proof"
        case .decision: "Decision"
        case .assumption: "Assumption"
        case .receipt: "Receipt"
        }
    }

    var symbolName: String {
        switch self {
        case .proof: "checkmark.seal"
        case .decision: "arrow.triangle.branch"
        case .assumption: "scope"
        case .receipt: "doc.text.magnifyingglass"
        }
    }
}

struct GoalDetailReviewTrailItemState: Identifiable, Sendable {
    let id: String
    let kind: GoalDetailReviewTrailKind
    let title: String
    let summary: String
    let sourceLabel: String
    let reviewLabel: String
    let reversibilityLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailReviewTrailState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailReviewTrailItemState]
    let accessibilitySummary: String
}

struct GoalDetailRiskState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct GoalDetailRisksState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailRiskState]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailArchiveState: Sendable {
    let title: String
    let statusLabel: String
    let summary: String
    let learning: String
    let state: AmbitionVisualState
}

struct GoalDetailMissionControlState: Sendable {
    let currentTruth: String
    let primaryNextMove: GoalNextVisibleStep
    let sourceLabel: String
    let proofBoundaryLabel: String
    let ownershipLabel: String
    let breadcrumb: GoalDetailBreadcrumbState
    let lanes: [GoalDetailMissionLaneState]
    let timeline: GoalDetailTimelineState
    let assumptions: [GoalDetailAssumptionState]
    let proofRail: GoalDetailProofRailState
    let decisions: GoalDetailDecisionsState
    let risks: GoalDetailRisksState
    let archive: GoalDetailArchiveState
    let receipts: GoalDetailReceiptsState
}
