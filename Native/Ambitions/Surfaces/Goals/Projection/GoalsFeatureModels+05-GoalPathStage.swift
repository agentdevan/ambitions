import AmbitionsDesignSystem
import Foundation

extension GoalPathStage {
    var lifecycleMarkerLabel: String {
        switch position {
        case .completed:
            "Proof-backed stage"
        case .current:
            "Current position"
        case .blocked:
            "Friction marker"
        case .upcoming:
            "Horizon marker"
        }
    }

    var progressShapeLabel: String {
        switch position {
        case .completed:
            "Already landed"
        case .current:
            "In motion now"
        case .blocked:
            "Needs recovery"
        case .upcoming:
            "Not yet active"
        }
    }

    var proofMarkerLabel: String? {
        switch position {
        case .completed:
            "Evidence attached"
        case .current:
            "Proof can be added here"
        case .blocked:
            nil
        case .upcoming:
            nil
        }
    }

    var riskMarkerLabel: String? {
        position == .blocked ? "Risk visible" : nil
    }

    var routeIndicatorLabel: String? {
        position == .upcoming ? "Route option" : nil
    }

    var accessibilitySummary: String {
        [
            lifecycleMarkerLabel,
            progressShapeLabel,
            statusLabel,
            stepCountLabel,
            highlight.map { "Highlight: \($0)" },
            proofMarkerLabel,
            riskMarkerLabel,
            routeIndicatorLabel,
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

struct GoalPathBuilderPhaseState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let dependencySummary: String
    let proofSummary: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct GoalPathBuilderForkState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let basisSummary: String
    let decisionPrompt: String
    let freshnessLabel: String
    let state: AmbitionVisualState
}

struct GoalPathTradeoffLaneState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let effortLabel: String
    let timeLabel: String
    let energyLabel: String
    let reviewRequirementLabel: String
    let recoveryLabel: String
    let state: AmbitionVisualState
}

struct GoalPathTradeoffReviewState: Sendable {
    let title: String
    let subtitle: String
    let lanes: [GoalPathTradeoffLaneState]
    let accessibilitySummary: String
}

struct GoalPathBuilderProofState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let handoffLabel: String
    let state: AmbitionVisualState
}

struct GoalPathBuilderState: Sendable {
    let title: String
    let subtitle: String
    let breadcrumbLabels: [String]
    let phases: [GoalPathBuilderPhaseState]
    let forks: [GoalPathBuilderForkState]
    let proofRequirements: [GoalPathBuilderProofState]
    let todayConnectionTitle: String
    let todayConnectionSummary: String
    let planConnectionSummary: String
    let decisionReceiptSummary: String
    let roadmapListTitle: String
    let roadmapListSummary: String
    let performanceBudgetSummary: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct LifePathThreadState: Sendable {
    let title: String
    let subtitle: String
    let nodes: [LifePathThreadNode]
    let proofBeads: [LifePathProofBead]
    let riskPinches: [RiskPinch]
    let alternateRouteFolds: [AlternateRouteFold]
    let sourceFold: GoalPathSourceFold
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String

    init(
        stages: [GoalPathStage],
        pathBuilder: GoalPathBuilderState?,
        privacySensitive: Bool = false
    ) {
        let visibleStages = Array(stages.prefix(6))
        let nodes = visibleStages.enumerated().map { index, stage in
            LifePathThreadNode(
                id: stage.id,
                order: index + 1,
                roleLabel: stage.lifecycleMarkerLabel,
                title: privacySensitive ? "Private path stage" : stage.title,
                summary: privacySensitive ? "Stage detail hidden. The path role remains visible." : stage.summary,
                statusLabel: stage.statusLabel,
                stepCountLabel: stage.stepCountLabel,
                markerLabel: stage.progressShapeLabel,
                nonColorMeaning: stage.accessibilitySummary,
                symbolName: LifePathThreadState.symbolName(for: stage.position),
                state: stage.state
            )
        }
        let stageProof = visibleStages.compactMap { stage -> LifePathProofBead? in
            guard let marker = stage.proofMarkerLabel else { return nil }
            return LifePathProofBead(
                id: "stage-proof-\(stage.id)",
                title: marker,
                summary: privacySensitive ? "Proof detail hidden." : stage.highlight ?? stage.summary,
                state: stage.position == .completed ? .success : .default
            )
        }
        let requirementProof = (pathBuilder?.proofRequirements ?? []).prefix(3).map { proof in
            LifePathProofBead(
                id: "requirement-\(proof.id)",
                title: privacySensitive ? "Private proof check" : proof.title,
                summary: privacySensitive ? "Proof detail hidden." : proof.summary,
                state: proof.state
            )
        }
        let stageRiskPinches = visibleStages.compactMap { stage -> RiskPinch? in
            guard let risk = stage.riskMarkerLabel else { return nil }
            return RiskPinch(
                id: "risk-\(stage.id)",
                title: risk,
                summary: privacySensitive ? "Risk detail hidden." : stage.highlight ?? stage.summary,
                state: .warning
            )
        }
        let phaseRiskPinches = (pathBuilder?.phases ?? []).filter { $0.state == .warning }.prefix(3).map { phase in
            RiskPinch(
                id: "phase-risk-\(phase.id)",
                title: "Risk visible",
                summary: privacySensitive ? "Risk detail hidden." : phase.dependencySummary,
                state: .warning
            )
        }
        let forkRiskPinches = (pathBuilder?.forks ?? []).filter { $0.state == .warning }.prefix(2).map { fork in
            RiskPinch(
                id: "fork-risk-\(fork.id)",
                title: "Route needs review",
                summary: privacySensitive ? "Risk detail hidden." : fork.basisSummary,
                state: .warning
            )
        }
        let alternateRouteFolds = (pathBuilder?.forks ?? []).prefix(3).map { fork in
            AlternateRouteFold(
                id: "alternate-\(fork.id)",
                title: privacySensitive ? "Private alternate route" : fork.title,
                summary: privacySensitive ? "Alternate route detail hidden." : fork.summary,
                reviewLabel: fork.decisionPrompt,
                state: fork.state
            )
        }
        let sourceFold = GoalPathSourceFold(
            id: "goal-path-source-fold",
            title: "GoalPathSourceFold",
            summary: pathBuilder?.performanceBudgetSummary ?? "Thread is based on the visible goal path stages.",
            breadcrumbLabels: pathBuilder?.breadcrumbLabels ?? ["Goal Detail", "LifePath Thread"],
            privacyLabel: privacySensitive ? "Private mode hides titles while preserving path roles." : "Source labels stay visible for review.",
            state: .default
        )

        self.title = "LifePath Thread"
        self.subtitle = "Path roles, proof, risk, and alternate routes stay connected before deeper tactics."
        self.nodes = nodes
        self.proofBeads = Array((stageProof + requirementProof).prefix(6))
        self.riskPinches = Array((stageRiskPinches + phaseRiskPinches + forkRiskPinches).prefix(3))
        self.alternateRouteFolds = Array(alternateRouteFolds)
        self.sourceFold = sourceFold
        self.accessibilityLabel = "LifePath Thread"
        self.accessibilityValue = nodes
            .map { "Order \($0.order), \($0.roleLabel), \($0.statusLabel), \($0.title)" }
            .joined(separator: ". ")
        self.accessibilityHint = privacySensitive
            ? "Private mode preserves accessible path order, proof beads, risk pinch, alternate route fold, and source fold roles without exposing titles."
            : "Review the path in order with proof beads, risk pinch, alternate route fold, and source fold."
    }

    static func symbolName(for position: GoalPathStagePosition) -> String {
        switch position {
        case .completed:
            "checkmark.seal"
        case .current:
            "scope"
        case .blocked:
            "exclamationmark.triangle"
        case .upcoming:
            "arrow.triangle.branch"
        }
    }
}

struct LifePathThreadNode: Identifiable, Sendable {
    let id: String
    let order: Int
    let roleLabel: String
    let title: String
    let summary: String
    let statusLabel: String
    let stepCountLabel: String
    let markerLabel: String
    let nonColorMeaning: String
    let symbolName: String
    let state: AmbitionVisualState
}

struct LifePathProofBead: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct RiskPinch: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let state: AmbitionVisualState
}

struct AlternateRouteFold: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let reviewLabel: String
    let state: AmbitionVisualState
}

struct GoalPathSourceFold: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let breadcrumbLabels: [String]
    let privacyLabel: String
    let state: AmbitionVisualState
}

extension GoalPathBuilderState {
    var tradeoffReview: GoalPathTradeoffReviewState {
        let blockedPhase = phases.first {
            $0.state == .warning ||
            $0.statusLabel.localizedCaseInsensitiveContains("blocked") ||
            $0.dependencySummary.localizedCaseInsensitiveContains("blocked")
        }
        let recoveryLabel = blockedPhase.map {
            "Recovery: review \($0.title) before changing route."
        } ?? "Recovery: park or edit before changing route."
        let lanes = forks.map { fork in
            GoalPathTradeoffLaneState(
                id: "tradeoff-\(fork.id)",
                title: fork.title,
                summary: fork.summary,
                effortLabel: "Effort: compare setup cost before choosing.",
                timeLabel: fork.freshnessLabel == "Current"
                    ? "Time: current context still needs review."
                    : "Time: review the source before using it.",
                energyLabel: "Energy: choose the sustainable path, not the biggest one.",
                reviewRequirementLabel: "User review required before this changes Today or the goal path.",
                recoveryLabel: recoveryLabel,
                state: fork.state
            )
        }

        return GoalPathTradeoffReviewState(
            title: "Tradeoff review",
            subtitle: "Route options stay comparable and reversible before any path changes.",
            lanes: lanes,
            accessibilitySummary: lanes.map {
                "\($0.title). \($0.effortLabel) \($0.timeLabel) \($0.energyLabel) \($0.reviewRequirementLabel)"
            }.joined(separator: " ")
        )
    }
}

struct GoalDetailNextMovement: Sendable {
    let title: String
    let summary: String
    let timingLabel: String
    let rationale: String
    let state: AmbitionVisualState
}

struct GoalDetailTrajectoryState: Sendable {
    let phaseTitle: String
    let phaseSummary: String
    let milestoneSummary: String
    let momentumSummary: String
    let timelineSummary: String
}

struct GoalEvidenceItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}
