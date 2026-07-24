import AmbitionsDesignSystem
import Foundation

enum TodayExecutionHeroKind: String, Equatable {
    case nextAction
    case recovery
    case empty
}

enum TodayExecutionPanelKind: String, Equatable {
    case contextLens
    case capture
    case time
    case todayTime
    case oneStepGoals
    case priority
    case recovery
    case waiting
    case friction
    case closure
}

enum TodayContractEntryKind: String, Equatable {
    case protectedMustDo
    case recommendedStep
    case notToday
    case recoveryFallback
    case whyThisMatters
    case actionClosure
}

enum TodayQualitativeDayState: String, Equatable {
    case clear = "Clear"
    case steady = "Steady"
    case tight = "Tight"
    case fragile = "Fragile"
    case atRisk = "At risk"
    case recovered = "Recovered"
    case protected = "Kept in view"
}


struct TodayLensChipState: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let state: AmbitionVisualState
    let isActive: Bool
}

struct TodayCommandMappingState: Identifiable, Equatable {
    let id: String
    let actionKind: TodayActionKind
    let commandPayload: RuntimeCommandPayload
    let destination: AmbitionsCommandDestination?
    let validationState: AmbitionsCommandValidationState
    let explanationID: String?
    let recoveryOptionID: String?
}

struct TodayExplanationAffordanceState: Identifiable, Equatable {
    let id: String
    let title: String
    let summary: String
    let explanationID: String?
    let state: AmbitionVisualState
}

struct TodayExecutionHeroState: Equatable {
    let kind: TodayExecutionHeroKind
    let eyebrow: String
    let title: String
    let subtitle: String
    let semanticState: AmbitionSemanticState
    let confidenceLabel: String
    let primaryAction: TodayInlineAction
    let secondaryActions: [TodayInlineAction]
    let explanation: TodayExplanationAffordanceState?
    let smallestUsefulNextStep: String?
    let accessibilityLabel: String
    let accessibilityValue: String
}

struct TodayContractEntryState: Identifiable, Equatable {
    let id: String
    let kind: TodayContractEntryKind
    let title: String
    let subtitle: String
    let value: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
    let explanation: TodayExplanationAffordanceState?
}

struct TodayExecutionPanelState: Identifiable, Equatable {
    let id: String
    let kind: TodayExecutionPanelKind
    let title: String
    let subtitle: String
    let value: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
    let explanation: TodayExplanationAffordanceState?
}

struct TodayExecutionDeepDiveState: Identifiable, Equatable {
    let id: String
    let title: String
    let rows: [TodayExecutionPanelState]
}

struct TodayTimeLayerItemState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let timingLabel: String
    let sourceLabel: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
}

struct TodayTimeLayerState: Equatable {
    let title: String
    let subtitle: String
    let compactTimelineLabel: String
    let openWindowLabel: String
    let calendarSourceLabel: String
    let items: [TodayTimeLayerItemState]
    let moveAction: TodayInlineAction
    let parkAction: TodayInlineAction
    let markDoneAction: TodayInlineAction?
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}

struct TodayOneStepGoalPreviewState: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let statusLabel: String
    let semanticState: AmbitionSemanticState
    let action: TodayInlineAction?
}

struct TodayOneStepGoalsPanelState: Equatable {
    let title: String
    let subtitle: String
    let value: String
    let previews: [TodayOneStepGoalPreviewState]
    let emptyMessage: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
}


struct TodayExecutionViewState: Equatable {
    let dayRail: AmbitionsDayRailViewState
    let activeLens: TodayLensChipState
    let availableLenses: [TodayLensChipState]
    let lensSummary: String
    let dayState: TodayQualitativeDayState
    let dayStateSummary: String
    let protectedMustDo: TodayContractEntryState
    let recommendedStep: TodayContractEntryState
    let notToday: TodayContractEntryState
    let recoveryFallback: TodayContractEntryState
    let whyThisMatters: TodayContractEntryState
    let actionClosureEntry: TodayContractEntryState
    let saveTheDayAction: TodayInlineAction?
    let frictionSignal: TodayExecutionPanelState
    let hero: TodayExecutionHeroState
    let todayTimeLayer: TodayTimeLayerState
    let oneStepGoalsPanel: TodayOneStepGoalsPanelState
    let supportingPanels: [TodayExecutionPanelState]
    let deeperSections: [TodayExecutionDeepDiveState]
    let commandMappings: [TodayCommandMappingState]
    let timeRequestsCalendarPermission: Bool
    let emptyGuidance: TodayExecutionPanelState?
    let realityMeridianContinuity: RealityMeridianContinuityProjectionState
}
