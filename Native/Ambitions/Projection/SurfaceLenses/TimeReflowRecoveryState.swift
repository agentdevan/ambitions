import AmbitionsDesignSystem
import Foundation

struct TimeReflowBoundaryState: Sendable, Hashable {
    let actionKind: SafeAutomationActionKind
    let confirmationRequirement: SafeAutomationConfirmationRequirement
    let undoAvailability: ActionReceiptUndoAvailability
    let safetyLabel: String

    var confirmationLabel: String {
        switch confirmationRequirement {
        case .notRequired: "Safe local suggestion"
        case .required: "Needs confirmation"
        case .requiredForExternalEffect: "External change needs confirmation"
        case .requiredForDestructiveChange: "Drop needs confirmation"
        case .requiredForBroadReflow: "Wide Time change needs confirmation"
        case .notAllowed: "Not supported"
        }
    }

    var undoLabel: String {
        switch undoAvailability {
        case .availableLocal: "Undo can be local"
        case .requiresConfirmation: "Undo needs confirmation"
        case .unavailable: "Undo unavailable"
        case .unsafe: "Undo unsafe"
        case .notSupportedYet: "Undo not supported yet"
        }
    }
}

struct TimeReflowSuggestionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: TimeReflowSuggestionKind
    let title: String
    let detail: String
    let impactLabel: String
    let boundary: TimeReflowBoundaryState
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    init(
        id: String,
        kind: TimeReflowSuggestionKind,
        title: String,
        detail: String,
        impactLabel: String,
        boundary: TimeReflowBoundaryState,
        visualState: AmbitionVisualState,
        target: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.impactLabel = impactLabel
        self.boundary = boundary
        self.visualState = visualState
        self.target = target
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
}

struct TimeRealityReflowState: Sendable {
    let title: String
    let detail: String
    let reasonKind: TimeRealityBreakReasonKind
    let reasonDetail: String
    let recommendedAdjustment: String
    let noChangeCopy: String
    let suggestions: [TimeReflowSuggestionState]
    let visualState: AmbitionVisualState
}

struct TimeRecoveryGradientOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let order: Int
    let kind: TimeReflowSuggestionKind
    let title: String
    let detail: String
    let boundary: TimeReflowBoundaryState
    let visualState: AmbitionVisualState
}

struct TimeRecoveryGradientState: Sendable {
    let title: String
    let detail: String
    let options: [TimeRecoveryGradientOptionState]
}

struct TimeSaveTheDayState: Sendable {
    let title: String
    let detail: String
    let oneQuestion: String?
    let protectedItem: String
    let adjustment: String
    let recoveryExplanation: String
    let boundary: String
    let visualState: AmbitionVisualState
}

struct TimeReflowReceiptPreviewState: Sendable {
    let title: String
    let detail: String
    let whatChanged: [String]
    let whatWouldNotChange: [String]
    let momentumReflowContract: [String]
    let confirmationRequired: String
    let undoAvailability: String
    let safeFailureFallback: String
    let visualState: AmbitionVisualState
}

struct TimeRecoveryMaturitySignalState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
}

struct TimeRecoveryMaturityState: Sendable {
    let title: String
    let detail: String
    let timeFitLabel: String
    let confirmationBoundary: String
    let calendarBoundary: String
    let socialBoundary: String
    let receiptBoundary: String
    let signals: [TimeRecoveryMaturitySignalState]
}

struct TimeSecondaryDestination: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    init(
        id: String,
        title: String,
        detail: String,
        valueLabel: String,
        icon: String,
        visualState: AmbitionVisualState,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.valueLabel = valueLabel
        self.icon = icon
        self.visualState = visualState
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
}

