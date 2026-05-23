import AmbitionsDesignSystem
import Foundation

enum TodayExperienceMode: String, Sendable {
    case empty
    case seeded
    case active
}

enum TodayEntryContext: String, Sendable {
    case standard
    case recovery
    case stepSession
    case focus

    var normalized: TodayEntryContext {
        self == .focus ? .stepSession : self
    }
}

enum TodayDayPosture: String, Sendable {
    case stable
    case tight
    case drifted
    case overloaded
    case recovering
    case lowData
    case noPlan

    var label: String {
        switch self {
        case .stable: "Stable day"
        case .tight: "Tight day"
        case .drifted: "Drifted day"
        case .overloaded: "Overloaded"
        case .recovering: "Recovering"
        case .lowData: "Low-data"
        case .noPlan: "No plan"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .stable:
            return .success
        case .tight, .recovering:
            return .selected
        case .drifted, .overloaded, .lowData, .noPlan:
            return .warning
        }
    }
}

enum TodayActionKind: String, Sendable {
    case startStepSession
    case pauseStepSession
    case stopStepSession
    case closeActionClosure
    case complete
    case `defer`
    case split
    case reschedule
    case protectLater
    case openDetail
    case openTime
    case quickLog
    case askForHelp
    case askWhyThisMatters
    case createReminder
    case createCalendarEvent
    case markNotRelevant
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

struct TodayRejectionReasonSheetState: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let contextLabel: String
    let candidateID: String
    let sourceCandidateID: String?
    let sourceStepID: String
    let contextFingerprint: String
    let recordedAt: String
    let options: [TodayRejectionReasonOptionState]
    let customReasonPrompt: String
    let skipTitle: String
    let confirmTitle: String

    init(
        title: String,
        subtitle: String,
        contextLabel: String,
        candidateID: String,
        sourceCandidateID: String?,
        sourceStepID: String,
        contextFingerprint: String,
        recordedAt: String,
        options: [TodayRejectionReasonOptionState] = TodayRejectionReasonOptionState.defaultOptions,
        customReasonPrompt: String = "Add a short local reason if you want to teach the next pass.",
        skipTitle: String = "Save without a reason",
        confirmTitle: String = "Save reason"
    ) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not this" : title
        self.subtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Tell Ambitions why this step should wait or shift." : subtitle
        self.contextLabel = contextLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Today" : contextLabel
        self.candidateID = candidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceCandidateID = sourceCandidateID?.trimmingCharacters(in: .whitespacesAndNewlines).flatMap { $0.isEmpty ? nil : $0 }
        self.sourceStepID = sourceStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.contextFingerprint = contextFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.options = options
        self.customReasonPrompt = customReasonPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Add a short local reason if you want to teach the next pass." : customReasonPrompt
        self.skipTitle = skipTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Save without a reason" : skipTitle
        self.confirmTitle = confirmTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Save reason" : confirmTitle
        self.id = "today.rejection.\(self.candidateID)"
    }
}

struct TodayRejectionReasonOptionState: Identifiable, Sendable, Equatable {
    let id: String
    let reason: StepCandidateRejectionReason
    let title: String
    let detail: String
    let isSensitive: Bool
    let state: AmbitionVisualState

    init(reason: StepCandidateRejectionReasonCode, detail: String, state: AmbitionVisualState = .default) {
        self.reason = StepCandidateRejectionReason(code: reason)
        self.id = reason.rawValue
        self.title = reason.displayLabel
        self.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isSensitive = reason.isSensitive
        self.state = state
    }

    static let defaultOptions: [TodayRejectionReasonOptionState] = [
        TodayRejectionReasonOptionState(reason: .tooLong, detail: "The recommendation asks for more time than fits right now."),
        TodayRejectionReasonOptionState(reason: .tooHard, detail: "The current version is not the right difficulty.", state: .warning),
        TodayRejectionReasonOptionState(reason: .tooEasy, detail: "A more substantial version would be more useful."),
        TodayRejectionReasonOptionState(reason: .tooMuchEnergy, detail: "It needs more energy than the day can spare."),
        TodayRejectionReasonOptionState(reason: .wrongLocation, detail: "The location or access is off for right now."),
        TodayRejectionReasonOptionState(reason: .noEquipment, detail: "You do not have the needed equipment ready."),
        TodayRejectionReasonOptionState(reason: .noTransportation, detail: "Transport is the blocker at the moment."),
        TodayRejectionReasonOptionState(reason: .notEnoughTime, detail: "The window is too small for this version."),
        TodayRejectionReasonOptionState(reason: .emotionallyNotReady, detail: "The safer choice is to wait until you are ready."),
        TodayRejectionReasonOptionState(reason: .blockedBySomeoneElse, detail: "Another person has to move first."),
        TodayRejectionReasonOptionState(reason: .alreadyDidSimilar, detail: "A similar step already happened."),
        TodayRejectionReasonOptionState(reason: .notUseful, detail: "This is not the most useful next step."),
        TodayRejectionReasonOptionState(reason: .unsafeInjuryConcern, detail: "Safety should come first here."),
        TodayRejectionReasonOptionState(reason: .boringLowMotivation, detail: "The current shape does not have enough pull."),
        TodayRejectionReasonOptionState(reason: .preferDifferentPath, detail: "You want a different route to the same goal.")
    ]
}

struct TodayRejectionSubmission: Sendable, Equatable {
    let reason: StepCandidateRejectionReason
    let skippedReason: Bool
    let customText: String?
}

struct TodayRecommendationRejectionInput: Sendable, Equatable {
    let candidateID: String
    let sourceCandidateID: String?
    let sourceStepID: String
    let contextFingerprint: String
    let reason: StepCandidateRejectionReason
    let skippedReason: Bool
    let customText: String?
    let recordedAt: String
}

struct TodayPillState: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let icon: String?
    let state: AmbitionVisualState
}

struct TodayTrustWhisperState: Sendable {
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct TodayReentryState: Sendable {
    let eyebrow: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

struct TodayHeroTruthState: Sendable {
    let greeting: String
    let dominantText: String
    let supportingText: String
    let nowTitle: String
    let nowSubtitle: String
    let nextTitle: String?
    let nextSubtitle: String?
    let posture: TodayDayPosture
    let contextPills: [TodayPillState]
    let trustWhisper: TodayTrustWhisperState?
    let shellSummary: GoalShellSummaryState?
}

struct TodayPrimaryActionState: Sendable {
    let title: String
    let subtitle: String
    let action: TodayInlineAction
    let supportingActions: [TodayInlineAction]
}

struct TodayHeroState: Sendable {
    let truth: TodayHeroTruthState
    let primaryAction: TodayPrimaryActionState
    let reentry: TodayReentryState?
}

struct TodaySupportItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let label: String
    let state: AmbitionVisualState
    let action: TodayInlineAction?
}

struct TodayFixedCommitmentsState: Sendable {
    let title: String
    let summary: String
    let items: [TodaySupportItemState]
    let emptyMessage: String?
}

struct TodayFlexibleRoomState: Sendable {
    let title: String
    let summary: String
    let items: [TodaySupportItemState]
    let emptyMessage: String?
}

struct TodayMetricState: Identifiable, Sendable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let icon: String
    let state: AmbitionVisualState
}

struct TodayMomentumStripState: Sendable {
    let title: String
    let summary: String
    let metrics: [TodayMetricState]
    let note: String
    let celebrationLine: String?
}

struct TodaySupportLayerState: Sendable {
    let timeAperture: TodayTimeApertureState
    let recoveryBloom: TodayRecoveryBloomState?
    let stepSession: TodayStepSessionState?
    let fixedCommitments: TodayFixedCommitmentsState
    let flexibleRoom: TodayFlexibleRoomState
    let momentum: TodayMomentumStripState
    let quickCaptureAction: TodayInlineAction?
    let quickCaptureTitle: String
    let quickCaptureDetail: String
    let timeAction: TodayInlineAction?
    let reflectionPrompt: String?
    let reflectionHighlights: [String]
}

struct TodayExperience: Sendable {
    let mode: TodayExperienceMode
    let hero: TodayHeroState
    let support: TodaySupportLayerState
    let execution: TodayExecutionViewState

    init(
        mode: TodayExperienceMode,
        hero: TodayHeroState,
        support: TodaySupportLayerState,
        execution: TodayExecutionViewState? = nil
    ) {
        self.mode = mode
        self.hero = hero
        self.support = support
        self.execution = execution ?? TodayExecutionViewState.compatibility(
            mode: mode,
            hero: hero,
            support: support
        )
    }
}

// Legacy internal projection scaffolding retained to avoid widening this compatibility seam.
// into planner or service rewrites beyond Today presentation composition.

struct TodayHeaderState: Sendable {
    let greeting: String
    let title: String
    let subtitle: String
    let contextPills: [TodayPillState]
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
