import AmbitionsDesignSystem
import Foundation

enum GoalsFilter: String, CaseIterable, Hashable, Sendable {
    case active
    case onHold
    case achieved

    var title: String {
        switch self {
        case .active: "Active"
        case .onHold: "On Hold"
        case .achieved: "Achieved"
        }
    }
}

enum GoalsSortOption: String, CaseIterable, Hashable, Sendable {
    case relevance
    case momentum
    case urgency
    case manualPriority = "manual_priority"

    var title: String {
        switch self {
        case .relevance: "Relevance"
        case .momentum: "Momentum"
        case .urgency: "Urgency"
        case .manualPriority: "Priority"
        }
    }
}

enum GoalDetailLens: String, CaseIterable, Hashable, Sendable {
    case tasks
    case path

    var title: String {
        switch self {
        case .tasks: "Tasks"
        case .path: "Path"
        }
    }
}

enum GoalRenderState: String, Hashable, Sendable {
    case active
    case starter
    case clarification
    case blocked
    case onHold
    case achieved

    var title: String {
        switch self {
        case .active: "In motion"
        case .starter: "Starter path"
        case .clarification: "Needs clarity"
        case .blocked: "Blocked"
        case .onHold: "On hold"
        case .achieved: "Achieved"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active: .selected
        case .starter: .selected
        case .clarification: .warning
        case .blocked: .warning
        case .onHold: .default
        case .achieved: .success
        }
    }
}

struct GoalsFilterSummary: Sendable {
    let filter: GoalsFilter
    let count: Int
}

struct GoalListItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let subtitle: String
    let mode: GoalMode
    let renderState: GoalRenderState
    let progressValue: Double
    let progressLabel: String
    let statusLabel: String
    let timingLabel: String
    let nextStepHint: String
    let modeLabel: String
    let supportLabel: String?
    let relevanceScore: Double
    let momentumScore: Double
    let urgencyScore: Double
    let manualPriorityRank: Int
    let updatedAt: String
}

struct GoalsOverview: Sendable {
    let title: String
    let subtitle: String
    let contextPills: [String]
    let isSeeded: Bool
    let filterSummaries: [GoalsFilterSummary]
    let items: [GoalListItem]
    let emptyTitle: String
    let emptyMessage: String
}

struct CreateGoalRequest: Sendable {
    let title: String
    let mode: GoalMode?

    init(title: String, mode: GoalMode? = nil) {
        self.title = title
        self.mode = mode
    }
}

struct CreateGoalResponse: Sendable {
    let target: GoalRouteTarget
    let blueprint: GoalBlueprint
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
    let highlight: String?
    let state: AmbitionVisualState
}

struct GoalEvidenceItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalFeedbackItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
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
    let actions: [GoalDetailActionState]
    let primaryStepID: String?
    let canSwitchToUntimed: Bool
    let supportModeActive: Bool
    let defaultLens: GoalDetailLens
}

extension GoalMode {
    var displayTitle: String {
        switch self {
        case .achievement: "Achievement"
        case .project: "Project"
        case .habit: "Habit"
        case .learning: "Learning"
        case .exploration: "Exploration"
        case .maintenance: "Maintenance"
        case .recovery: "Recovery"
        case .delegatedSupport: "Support"
        }
    }
}
