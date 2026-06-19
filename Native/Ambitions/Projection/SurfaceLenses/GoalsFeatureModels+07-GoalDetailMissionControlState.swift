import AmbitionsDesignSystem
import Foundation

extension GoalDetailMissionControlState {
    var reviewTrail: GoalDetailReviewTrailState {
        let proofSummary = proofRail.items.first.map {
            "\($0.title): \($0.subtitle)"
        } ?? proofRail.emptyMessage
        let decisionSummary = decisions.items.first.map {
            "\($0.title): \($0.summary)"
        } ?? decisions.emptyMessage
        let assumption = assumptions.first(where: { $0.state == .warning }) ?? assumptions.first
        let assumptionSummary = assumption.map {
            "\($0.title) \($0.status). \($0.whyItMatters)"
        } ?? "No assumptions are visible for review."
        let receiptSummary = receipts.items.first.map {
            "\($0.title): \($0.summary)"
        } ?? receipts.emptyMessage

        let items = [
            GoalDetailReviewTrailItemState(
                id: "review-proof",
                kind: .proof,
                title: proofRail.items.isEmpty ? proofRail.emptyTitle : "Proof attached",
                summary: proofSummary,
                sourceLabel: "Evidence",
                reviewLabel: "Review proof",
                reversibilityLabel: "Proof is attached when saved",
                state: proofRail.items.isEmpty ? .default : .selected
            ),
            GoalDetailReviewTrailItemState(
                id: "review-decision",
                kind: .decision,
                title: decisions.items.isEmpty ? decisions.emptyTitle : "Decision recorded",
                summary: decisionSummary,
                sourceLabel: "Decision",
                reviewLabel: "Review decision trail",
                reversibilityLabel: "Change reasons stay visible",
                state: decisions.items.isEmpty ? .default : .selected
            ),
            GoalDetailReviewTrailItemState(
                id: "review-assumption",
                kind: .assumption,
                title: assumption?.title ?? "No assumptions visible",
                summary: assumptionSummary,
                sourceLabel: "Assumption",
                reviewLabel: assumption?.correctionLabel.map { "Review: \($0)" } ?? "Review assumption",
                reversibilityLabel: "Review before changing the path",
                state: assumption?.state ?? .default
            ),
            GoalDetailReviewTrailItemState(
                id: "review-receipt",
                kind: .receipt,
                title: receipts.items.isEmpty ? receipts.emptyTitle : "Receipt recorded",
                summary: receiptSummary,
                sourceLabel: "Receipt",
                reviewLabel: "Review receipts",
                reversibilityLabel: "Reversibility only when available",
                state: receipts.items.isEmpty ? .default : .selected
            )
        ]

        return GoalDetailReviewTrailState(
            title: "Review trail",
            subtitle: "Proof, decisions, assumptions, and receipts stay separated before anything changes.",
            items: items,
            accessibilitySummary: items.map {
                "\($0.kind.title): \($0.title). \($0.summary). \($0.reversibilityLabel)"
            }.joined(separator: " ")
        )
    }
}

struct GoalClarificationState: Sendable {
    let title: String
    let subtitle: String
    let questions: [GoalClarificationQuestionState]
}

struct GoalBlockedState: Sendable {
    let title: String
    let subtitle: String
    let blockers: [String]
}

struct GoalDetailPresentation: Sendable {
    let target: GoalRouteTarget
    let headline: GoalDetailHeadline
    let outcome: String
    let intent: String
    let progress: GoalDetailProgress
    let strategicStatus: GoalDetailStrategicStatus
    let nextMovement: GoalDetailNextMovement?
    let trajectory: GoalDetailTrajectoryState
    let timingNote: String
    let progressNote: String
    let manualPriorityLabel: String
    let assumptions: [String]
    let suggestions: [GoalDetailStepItem]
    let pathStages: [GoalPathStage]
    let sections: [GoalDetailSectionState]
    let clarification: GoalClarificationState?
    let blocked: GoalBlockedState?
    let evidence: [GoalEvidenceItem]
    let history: [GoalFeedbackItem]
    let recentMovement: GoalDetailRecentMovementState
    let actions: [GoalDetailActionState]
    let explainability: GoalExplainabilityState?
    let primaryStepID: String?
    let canSwitchToUntimed: Bool
    let supportModeActive: Bool
    let defaultLens: GoalDetailLens
    let missionControl: GoalDetailMissionControlState?
    let pathBuilder: GoalPathBuilderState?

    init(
        target: GoalRouteTarget,
        headline: GoalDetailHeadline,
        outcome: String,
        intent: String,
        progress: GoalDetailProgress,
        strategicStatus: GoalDetailStrategicStatus,
        nextMovement: GoalDetailNextMovement?,
        trajectory: GoalDetailTrajectoryState,
        timingNote: String,
        progressNote: String,
        manualPriorityLabel: String,
        assumptions: [String],
        suggestions: [GoalDetailStepItem],
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        clarification: GoalClarificationState?,
        blocked: GoalBlockedState?,
        evidence: [GoalEvidenceItem],
        history: [GoalFeedbackItem],
        recentMovement: GoalDetailRecentMovementState,
        actions: [GoalDetailActionState],
        explainability: GoalExplainabilityState?,
        primaryStepID: String?,
        canSwitchToUntimed: Bool,
        supportModeActive: Bool,
        defaultLens: GoalDetailLens,
        missionControl: GoalDetailMissionControlState? = nil,
        pathBuilder: GoalPathBuilderState? = nil
    ) {
        self.target = target
        self.headline = headline
        self.outcome = outcome
        self.intent = intent
        self.progress = progress
        self.strategicStatus = strategicStatus
        self.nextMovement = nextMovement
        self.trajectory = trajectory
        self.timingNote = timingNote
        self.progressNote = progressNote
        self.manualPriorityLabel = manualPriorityLabel
        self.assumptions = assumptions
        self.suggestions = suggestions
        self.pathStages = pathStages
        self.sections = sections
        self.clarification = clarification
        self.blocked = blocked
        self.evidence = evidence
        self.history = history
        self.recentMovement = recentMovement
        self.actions = actions
        self.explainability = explainability
        self.primaryStepID = primaryStepID
        self.canSwitchToUntimed = canSwitchToUntimed
        self.supportModeActive = supportModeActive
        self.defaultLens = defaultLens
        self.missionControl = missionControl
        self.pathBuilder = pathBuilder
    }

    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .goalDetail,
            firstScreenContent: [
                "Object identity header",
                "Goal detail lanes"
            ],
            panels: [
                .objectIdentityHeader,
                .missionControlLanes,
                .progress,
                .timeline,
                .proofRail,
                .recovery,
                .trust,
                .receipt
            ],
            actions: [.startStep, .addProof, .changePath, .park, .archive],
            drillDowns: GoalDetailMissionLaneKind.allCases.map(\.title),
            copySamples: [
                headline.title,
                headline.subtitle,
                strategicStatus.title,
                strategicStatus.summary,
                missionControl?.lanes.map(\.title).joined(separator: " ") ?? "",
                missionControl?.proofRail.title ?? "",
                missionControl?.decisions.title ?? "",
                missionControl?.risks.title ?? "",
                missionControl?.archive.title ?? "",
                missionControl?.receipts.title ?? "",
                pathBuilder?.title ?? "",
                pathBuilder?.todayConnectionTitle ?? ""
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: missionControl?.lanes.isEmpty == false,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}
