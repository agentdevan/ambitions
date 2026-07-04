import AmbitionsDesignSystem
import Foundation

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
    let shellSummary: GoalShellSummaryState?

    init(
        id: String,
        title: String,
        subtitle: String,
        timingLabel: String,
        statusLabel: String,
        progress: Double,
        state: AmbitionVisualState,
        primaryAction: TodayInlineAction?,
        secondaryAction: TodayInlineAction?,
        shellSummary: GoalShellSummaryState? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.timingLabel = timingLabel
        self.statusLabel = statusLabel
        self.progress = progress
        self.state = state
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.shellSummary = shellSummary
    }
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
    let shellSummary: GoalShellSummaryState?
}

struct TodayFocusStarterState: Sendable {
    let title: String
    let subtitle: String
    let reassurance: String
    let timingLabel: String
    let assumptions: [String]
    let actions: [TodayInlineAction]
    let shellSummary: GoalShellSummaryState?
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

struct TodayDayPressureState: Sendable {
    let title: String
    let detail: String
    let label: String
    let state: AmbitionVisualState
}

struct TodayOpenWindowState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timingLabel: String
    let state: AmbitionVisualState
    let action: TodayInlineAction?
}

struct TodayTimeApertureState: Sendable {
    let title: String
    let subtitle: String
    let pressure: TodayDayPressureState
    let windows: [TodayOpenWindowState]
    let emptyMessage: String?
    let bestUseTitle: String
    let bestUseDetail: String
    let bestUseAction: TodayInlineAction?
    let trustWhisper: TodayTrustWhisperState?
}

struct TodayRecoveryOptionState: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
    let action: TodayInlineAction
}

struct TodayRecoveryBloomState: Sendable {
    let title: String
    let subtitle: String
    let explanation: String
    let pressureFieldLabel: String
    let recoveryLoopLabel: String
    let smallerStepAnchorLabel: String
    let recoveryReceiptPreviewLabel: String
    let options: [TodayRecoveryOptionState]
}

struct TodayStepSessionState: Sendable {
    let title: String
    let subtitle: String
    let detail: String
    let primaryAction: TodayInlineAction
    let secondaryActions: [TodayInlineAction]
    let trustWhisper: TodayTrustWhisperState?
    let contextReminderLabel: String
    let goalConnectionLabel: String
    let timerLabel: String
    let sessionControlActions: [TodayInlineAction]
    let receiptGenerationLabel: String
    let exitBoundaryLabel: String

    init(
        title: String,
        subtitle: String,
        detail: String,
        primaryAction: TodayInlineAction,
        secondaryActions: [TodayInlineAction],
        trustWhisper: TodayTrustWhisperState?,
        contextReminderLabel: String = "",
        goalConnectionLabel: String = "",
        timerLabel: String = "",
        sessionControlActions: [TodayInlineAction] = [],
        receiptGenerationLabel: String = "",
        exitBoundaryLabel: String = ""
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.primaryAction = primaryAction
        self.secondaryActions = secondaryActions
        self.trustWhisper = trustWhisper
        self.contextReminderLabel = contextReminderLabel
        self.goalConnectionLabel = goalConnectionLabel
        self.timerLabel = timerLabel
        self.sessionControlActions = sessionControlActions
        self.receiptGenerationLabel = receiptGenerationLabel
        self.exitBoundaryLabel = exitBoundaryLabel
    }

    var visibleCopy: String {
        ([
            title,
            subtitle,
            detail,
            contextReminderLabel,
            goalConnectionLabel,
            timerLabel,
            receiptGenerationLabel,
            exitBoundaryLabel,
            trustWhisper?.title,
            trustWhisper?.detail
        ].compactMap { $0 } + [primaryAction.title] + sessionControlActions.map(\.title) + secondaryActions.map(\.title))
            .joined(separator: " ")
    }
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
    let shellSummary: GoalShellSummaryState?
}

struct TodayMomentumState: Sendable {
    let title: String
    let subtitle: String
    let metrics: [TodayMetricState]
    let note: String
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

struct TodayRitualLoopState: Sendable {
    let kind: RitualKind
    let title: String
    let subtitle: String
    let thesis: String
    let stateLabel: String
    let signalLabels: [String]
    let action: TodayInlineAction?
}
