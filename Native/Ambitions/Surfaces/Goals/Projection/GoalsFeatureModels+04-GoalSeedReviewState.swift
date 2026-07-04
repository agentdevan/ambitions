import AmbitionsDesignSystem
import Foundation

struct GoalSeedReviewState: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let whyGoalLabel: String
    let startingPositionLabel: String
    let firstMilestoneLabel: String
    let firstStepLabel: String
    let proofSourceSeedLabel: String
    let confirmationLabel: String
    let state: AmbitionVisualState

    var accessibilityValue: String {
        [
            whyGoalLabel,
            startingPositionLabel,
            firstMilestoneLabel,
            firstStepLabel,
            proofSourceSeedLabel,
            confirmationLabel
        ].joined(separator: ". ")
    }
}

extension CreateGoalPreviewState {
    var goalSeedReviewState: GoalSeedReviewState {
        let activeStage = pathStages.first { stage in
            stage.position == .current || stage.position == .blocked
        } ?? pathStages.first
        let firstMilestone = milestonePreview.first
        let firstStep = firstMilestone?.title ?? activeStage?.highlight

        return GoalSeedReviewState(
            id: "goal-seed-review-\(normalizedTitle.lowercased().filter { $0.isLetter || $0.isNumber })",
            title: "Goal Seed Incubator",
            whyGoalLabel: whyGoalLabel,
            startingPositionLabel: "Starting position: \(activeStage?.title ?? "Needs one clearer starting point").",
            firstMilestoneLabel: "First milestone: \(firstMilestone?.summary ?? activeStage?.summary ?? "Hold the setup until a first milestone is visible.").",
            firstStepLabel: "First recommended step: \(firstStep ?? "Add one concrete next step before this becomes active.").",
            proofSourceSeedLabel: "Proof/source seed: current setup only; review before saving.",
            confirmationLabel: confirmationLabel,
            state: renderState.visualState
        )
    }

    var whyGoalLabel: String {
        switch resultKind {
        case .planned, .starterPlanned:
            "Why this might be a goal: \(summary)"
        case .clarificationRequired:
            "Why this might be a goal: the idea has signal, but one clarification is needed first."
        case .blocked:
            "Why this might be a goal: the blocker is visible before anything goes live."
        }
    }

    var confirmationLabel: String {
        switch resultKind {
        case .planned, .starterPlanned:
            "Confirmation: create the goal only when you choose Create Goal."
        case .clarificationRequired, .blocked:
            "Confirmation: save a draft until the setup is clear enough."
        }
    }
}

struct GoalDetailActionState: Identifiable, Sendable {
    let kind: GoalDetailActionKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

enum GoalDetailActionKind: String, Sendable {
    case complete
    case delay
    case skip
    case createReminder
    case createCalendarEvent
    case askForSmallerStep
    case askWhyThisMatters
    case markNotRelevant
    case breakThisDownSmaller
    case imStuck
    case showPath
    case switchToUntimed
    case showSupportMode
    case raisePriority
    case lowerPriority
}

struct GoalClarificationQuestionState: Identifiable, Sendable {
    let id: String
    let field: MissingFieldKey
    let prompt: String
    let rationale: String
    let gentleDefault: String
    let existingAnswer: String?
}

struct GoalClarificationAnswerRequest: Sendable {
    let target: GoalRouteTarget
    let questionID: String
    let field: MissingFieldKey
    let answer: String
}

struct GoalDetailActionRequest: Sendable {
    let target: GoalRouteTarget
    let kind: GoalDetailActionKind
    let stepID: String?
}

enum GoalExplainabilityCorrectionControlKind: String, Sendable {
    case markSupportNotRelevant = "mark_support_not_relevant"
    case confirmContradiction = "confirm_contradiction"
    case dismissContradiction = "dismiss_contradiction"
    case requestLighterVersion = "request_lighter_version"
}

struct GoalWhyThisState: Sendable {
    let compactSummary: String
    let lines: [String]
}

struct GoalSourceAuditRowState: Identifiable, Sendable {
    let id: String
    let resourceID: String
    let title: String
    let subtitle: String
    let detailLabels: [String]
    let state: AmbitionVisualState
}

struct GoalSourceAuditSectionState: Sendable {
    let rows: [GoalSourceAuditRowState]
}

struct GoalFreshnessState: Sendable {
    let posture: GoalFreshnessPosture
    let postureLabel: String
    let severityLabel: String
    let detailLabels: [String]
}

struct GoalConfidenceState: Sendable {
    let understandingConfidence: RecommendationConfidence
    let pathConfidence: RecommendationConfidence?
    let detailLabels: [String]
}

struct GoalContradictionSummaryState: Identifiable, Sendable {
    let id: String
    let code: GoalContradictionCode
    let title: String
    let summary: String
    let severityLabel: String
    let state: AmbitionVisualState
}

struct GoalCorrectionControlState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let kind: GoalExplainabilityCorrectionControlKind
    let artifactKind: GoalTeachingArtifactKind
    let teachingSignalKind: GoalTeachingSignalKind
    let payload: GoalTeachingPayload
    let target: GoalTeachingCaptureTarget
    let state: AmbitionVisualState
}

struct GoalAppliedTeachingBadgeState: Identifiable, Sendable {
    let id: String
    let signalID: String
    let title: String
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperPillState: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperState: Sendable {
    let title: String
    let subtitle: String
    let pillLine: String
    let pills: [GoalTrustWhisperPillState]
}

struct GoalExplainabilityState: Sendable {
    let whisper: GoalTrustWhisperState
    let whyThis: GoalWhyThisState
    let sourceAudit: GoalSourceAuditSectionState
    let freshness: GoalFreshnessState
    let confidence: GoalConfidenceState
    let contradictions: [GoalContradictionSummaryState]
    let correctionControls: [GoalCorrectionControlState]
    let appliedTeachingBadges: [GoalAppliedTeachingBadgeState]
}

struct GoalExplainabilityCorrectionRequest: Sendable {
    let target: GoalRouteTarget
    let control: GoalCorrectionControlState
}

struct GoalDetailInlineMessage: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let state: AmbitionVisualState

    init(id: String = UUID().uuidString, title: String, body: String, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.body = body
        self.state = state
    }
}

struct GoalDetailActionResponse: Sendable {
    let message: GoalDetailInlineMessage?
    let unitOfWorkReceipt: AppUnitOfWorkReceipt?

    init(
        message: GoalDetailInlineMessage?,
        unitOfWorkReceipt: AppUnitOfWorkReceipt? = nil
    ) {
        self.message = message
        self.unitOfWorkReceipt = unitOfWorkReceipt
    }
}

struct GoalDetailHeadline: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let renderState: GoalRenderState
    let modeLabel: String
    let timingLabel: String
    let supportLabel: String?
}

struct GoalDetailProgress: Sendable {
    let label: String
    let detail: String
    let value: Double
    let evidenceLabel: String
}

struct GoalDetailStrategicStatus: Sendable {
    let title: String
    let summary: String
    let supportingDetail: String
}

enum GoalPathStagePosition: String, Sendable {
    case completed
    case current
    case blocked
    case upcoming

    var title: String {
        switch self {
        case .completed: "Completed"
        case .current: "Current"
        case .blocked: "Blocked"
        case .upcoming: "Upcoming"
        }
    }
}

struct GoalDetailStepItem: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timingLabel: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailSectionState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let kindLabel: String
    let steps: [GoalDetailStepItem]
}

struct GoalPathStage: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let stepCountLabel: String
    let position: GoalPathStagePosition
    let statusLabel: String
    let highlight: String?
    let state: AmbitionVisualState
}
