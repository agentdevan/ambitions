import AmbitionsDesignSystem
import Foundation

enum TodayExperienceMode: String, Sendable {
    case empty
    case seeded
    case active
}

enum TodayActionKind: String, Sendable {
    case complete
    case delay
    case skip
    case askForSmallerStep
    case askWhyThisMatters
    case markNotRelevant
    case openDetail
    case quickLog
    case askForHelp
    case dismissCelebration
}

struct TodayActionTarget: Hashable, Sendable {
    let goalID: String?
    let stepID: String?
    let draftID: String?

    init(goalID: String? = nil, stepID: String? = nil, draftID: String? = nil) {
        self.goalID = goalID
        self.stepID = stepID
        self.draftID = draftID
    }
}

struct TodayInlineAction: Identifiable, Hashable, Sendable {
    let kind: TodayActionKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState
    let target: TodayActionTarget

    var id: String { "\(kind.rawValue)-\(title)-\(target.goalID ?? "none")-\(target.stepID ?? "none")" }
}

struct TodayInlineMessage: Identifiable, Sendable {
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

struct TodayActionResponse: Sendable {
    let message: TodayInlineMessage?
}

struct TodayHeaderState: Sendable {
    let greeting: String
    let title: String
    let subtitle: String
    let contextPills: [TodayPillState]
}

struct TodayPillState: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let icon: String?
    let state: AmbitionVisualState
}

struct TodayTargetItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timingLabel: String
    let statusLabel: String
    let progress: Double
    let state: AmbitionVisualState
    let primaryAction: TodayInlineAction?
    let secondaryAction: TodayInlineAction?
}

struct TodayDailyTargetsState: Sendable {
    let title: String
    let subtitle: String
    let completionLabel: String
    let items: [TodayTargetItem]
    let emptyMessage: String?
}

struct TodayFocusPlannedState: Sendable {
    let title: String
    let subtitle: String
    let reason: String
    let timingLabel: String
    let energyLabel: String
    let progress: Double
    let supportingText: [String]
    let actions: [TodayInlineAction]
}

struct TodayFocusStarterState: Sendable {
    let title: String
    let subtitle: String
    let reassurance: String
    let timingLabel: String
    let assumptions: [String]
    let actions: [TodayInlineAction]
}

struct TodayClarificationQuestionState: Identifiable, Sendable {
    let id: String
    let prompt: String
    let rationale: String
    let gentleDefault: String
}

struct TodayFocusClarificationState: Sendable {
    let title: String
    let subtitle: String
    let questions: [TodayClarificationQuestionState]
    let actions: [TodayInlineAction]
}

struct TodayFocusBlockedState: Sendable {
    let title: String
    let subtitle: String
    let blockerSummary: String
    let nextBestAction: String
    let actions: [TodayInlineAction]
}

struct TodayEmptyPanelState: Sendable {
    let title: String
    let message: String
    let actions: [TodayInlineAction]
}

enum TodayFocusState: Sendable {
    case planned(TodayFocusPlannedState)
    case starter(TodayFocusStarterState)
    case clarification(TodayFocusClarificationState)
    case blocked(TodayFocusBlockedState)
    case empty(TodayEmptyPanelState)
}

struct TodayOpportunityState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timingLabel: String
    let state: AmbitionVisualState
    let action: TodayInlineAction?
}

struct TodayFreeTimeState: Sendable {
    let title: String
    let subtitle: String
    let opportunities: [TodayOpportunityState]
}

struct TodayMilestoneState: Sendable {
    let title: String
    let subtitle: String
    let prompt: String
    let confidenceLabel: String
    let action: TodayInlineAction?
}

struct TodayMetricState: Identifiable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let icon: String
    let state: AmbitionVisualState
}

struct TodayMomentumState: Sendable {
    let title: String
    let subtitle: String
    let metrics: [TodayMetricState]
    let note: String
}

struct TodayCelebrationState: Sendable {
    let title: String
    let subtitle: String
    let achievements: [String]
    let actions: [TodayInlineAction]
}

struct TodayQuickCaptureState: Sendable {
    let title: String
    let subtitle: String
    let prompt: String
    let helpText: String
    let actions: [TodayInlineAction]
}

struct TodayReflectionState: Sendable {
    let title: String
    let subtitle: String
    let prompt: String
    let highlights: [String]
    let actions: [TodayInlineAction]
}

struct TodayExperience: Sendable {
    let mode: TodayExperienceMode
    let header: TodayHeaderState
    let dailyTargets: TodayDailyTargetsState
    let focus: TodayFocusState
    let freeTime: TodayFreeTimeState
    let milestone: TodayMilestoneState
    let momentum: TodayMomentumState
    let celebration: TodayCelebrationState?
    let quickCapture: TodayQuickCaptureState
    let reflection: TodayReflectionState
}
