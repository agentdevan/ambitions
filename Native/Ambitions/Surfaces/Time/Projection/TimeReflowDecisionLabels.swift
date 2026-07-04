import AmbitionsDesignSystem
import Foundation

extension TimeReflowDecisionProjector {
    func whatChangedLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepTimeUnchanged:
            return "What changed: nothing yet."
        case .protectOneItem:
            return "What changed: one item may become protected."
        case .shrinkAction:
            return "What changed: one step may become smaller."
        case .splitAction:
            return "What changed: one step may split into a first part."
        case .moveLocalActionLater:
            return "What changed: one local step may shift later."
        case .deferGoalOrItem:
            return "What changed: one item may leave this Time window."
        case .dropOptionalWork:
            return "What changed: optional work may be removed after confirmation."
        case .parkGoal:
            return "What changed: one goal may be parked after confirmation."
        case .markWaiting:
            return "What changed: one dependency may become waiting."
        case .recoverRest:
            return "What changed: recovery time may become protected."
        case .askForConfirmation:
            return "What changed: nothing until you confirm."
        }
    }

    func impactedStepsLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepTimeUnchanged, .askForConfirmation:
            return "Impacted steps: none yet."
        case .recoverRest:
            return "Impacted steps: recovery or rest stays visible."
        case .dropOptionalWork:
            return "Impacted steps: optional work only."
        case .deferGoalOrItem, .parkGoal:
            return "Impacted steps: lower-fit work only after review."
        case .markWaiting:
            return "Impacted steps: the blocked or waiting item."
        default:
            return "Impacted steps: one local step."
        }
    }

    func capacityImpactLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepTimeUnchanged:
            return "Capacity impact: unchanged."
        case .protectOneItem, .recoverRest:
            return "Capacity impact: protects breathing room."
        case .shrinkAction, .splitAction:
            return "Capacity impact: lowers the ask."
        case .moveLocalActionLater, .deferGoalOrItem, .dropOptionalWork, .parkGoal:
            return "Capacity impact: creates room after confirmation."
        case .markWaiting:
            return "Capacity impact: separates waiting from doing."
        case .askForConfirmation:
            return "Capacity impact: unchanged until you decide."
        }
    }

    func protectedTimeImpactLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .protectOneItem, .recoverRest:
            return "Protected time impact: one protected pocket stays defended."
        case .moveLocalActionLater:
            return "Protected time impact: Calendar is untouched."
        case .keepTimeUnchanged, .askForConfirmation:
            return "Protected time impact: Calendar is untouched."
        default:
            return "Protected time impact: reviewed before any step shifts."
        }
    }

    func beforeAfterPreview(
        for suggestion: TimeReflowSuggestionState,
        receiptPreview: TimeReflowReceiptPreviewState
    ) -> TimeReflowBeforeAfterShapePreviewState {
        TimeReflowBeforeAfterShapePreviewState(
            title: "Before / after",
            beforeLabel: beforeLabel(for: suggestion),
            afterLabel: afterLabel(for: suggestion),
            shapeChangeLabel: "Shape change: \(suggestion.impactLabel).",
            receiptPreviewLabel: "After review: \(receiptPreview.confirmationRequired)"
        )
    }

    func beforeLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepTimeUnchanged, .askForConfirmation:
            return "Before: current Time shape stays visible."
        case .protectOneItem:
            return "Before: protected time is not defended yet."
        case .recoverRest:
            return "Before: recovery space is not protected yet."
        case .moveLocalActionLater, .deferGoalOrItem, .dropOptionalWork, .parkGoal:
            return "Before: load still sits in the current Time window."
        case .markWaiting:
            return "Before: waiting stays mixed with doing."
        case .shrinkAction, .splitAction:
            return "Before: the next ask is still too large."
        }
    }

    func afterLabel(for suggestion: TimeReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepTimeUnchanged:
            return "After: Time remains unchanged."
        case .askForConfirmation:
            return "After: nothing changes until you confirm."
        case .protectOneItem:
            return "After: one protected pocket is clearer."
        case .recoverRest:
            return "After: recovery has visible room."
        case .moveLocalActionLater, .deferGoalOrItem, .dropOptionalWork, .parkGoal:
            return "After: capacity has more room after confirmation."
        case .markWaiting:
            return "After: waiting is separated from doing."
        case .shrinkAction, .splitAction:
            return "After: the ask is smaller and reviewable."
        }
    }
}
