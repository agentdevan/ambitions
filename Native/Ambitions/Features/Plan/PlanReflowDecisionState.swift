import AmbitionsDesignSystem
import Foundation

enum PlanReflowDecisionOptionKind: String, Sendable, CaseIterable {
    case keepPlan = "keep_plan"
    case makeSmaller = "make_smaller"
    case moveLater = "move_later"
    case reviewPlan = "review_plan"
    case protectTime = "protect_time"
    case recover = "recover"

    var title: String {
        switch self {
        case .keepPlan: "Keep plan"
        case .makeSmaller: "Make smaller"
        case .moveLater: "Move later"
        case .reviewPlan: "Review plan"
        case .protectTime: "Protect time"
        case .recover: "Recover"
        }
    }

    var icon: String {
        switch self {
        case .keepPlan: "checkmark.seal"
        case .makeSmaller: "arrow.down.right.and.arrow.up.left"
        case .moveLater: "clock.arrow.circlepath"
        case .reviewPlan: "list.bullet.clipboard"
        case .protectTime: "clock.badge.checkmark"
        case .recover: "sun.max"
        }
    }
}

struct PlanReflowDecisionOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: PlanReflowDecisionOptionKind
    let title: String
    let detail: String
    let impactLabel: String
    let sourceLabel: String
    let trustLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanReflowDecisionState: Sendable {
    let title: String
    let subtitle: String
    let sourceLabel: String
    let trustLabel: String
    let reasonLabel: String
    let recoveryLabel: String
    let receiptLabel: String
    let options: [PlanReflowDecisionOptionState]
    let visualState: AmbitionVisualState
}

struct PlanReflowDecisionProjector: Sendable {
    func project(
        reflow: PlanRealityReflowState,
        recoveryEntry: PlanRecoveryEntryState,
        saveTheDay: PlanSaveTheDayState,
        receiptPreview: PlanReflowReceiptPreviewState
    ) -> PlanReflowDecisionState {
        let sourceLabel = "Based on your plan"
        let trustLabel = "No silent changes"
        let options = preferredOptions(
            from: reflow.suggestions,
            sourceLabel: sourceLabel,
            trustLabel: trustLabel
        )

        return PlanReflowDecisionState(
            title: "Reflow decisions",
            subtitle: reflow.reasonKind == .stillBelievable
                ? "The plan still holds together. Keep the path visible unless you choose to adjust it."
                : "Choose one path before anything changes.",
            sourceLabel: sourceLabel,
            trustLabel: trustLabel,
            reasonLabel: reflow.reasonDetail,
            recoveryLabel: recoveryEntry.boundary,
            receiptLabel: "\(receiptPreview.confirmationRequired). \(saveTheDay.boundary)",
            options: options,
            visualState: reflow.visualState
        )
    }

    private func preferredOptions(
        from suggestions: [PlanReflowSuggestionState],
        sourceLabel: String,
        trustLabel: String
    ) -> [PlanReflowDecisionOptionState] {
        let mapped = suggestions.map { suggestion in
            option(
                from: suggestion,
                sourceLabel: sourceLabel,
                trustLabel: trustLabel
            )
        }
        let prioritizedKinds: [PlanReflowDecisionOptionKind] = [
            .keepPlan,
            .protectTime,
            .makeSmaller,
            .moveLater,
            .reviewPlan,
            .recover
        ]

        var result: [PlanReflowDecisionOptionState] = []
        for kind in prioritizedKinds {
            if let option = mapped.first(where: { $0.kind == kind }),
               result.contains(where: { $0.kind == kind }) == false {
                result.append(option)
            }
        }

        if result.isEmpty {
            result.append(PlanReflowDecisionOptionState(
                id: "reflow-decision-keep-plan",
                kind: .keepPlan,
                title: PlanReflowDecisionOptionKind.keepPlan.title,
                detail: "Leave the plan unchanged until there is enough evidence to adjust it.",
                impactLabel: "No plan mutation",
                sourceLabel: sourceLabel,
                trustLabel: trustLabel,
                boundaryLabel: "Safe local suggestion",
                visualState: .default,
                target: nil,
                planRoute: nil
            ))
        }

        return Array(result.prefix(5))
    }

    private func option(
        from suggestion: PlanReflowSuggestionState,
        sourceLabel: String,
        trustLabel: String
    ) -> PlanReflowDecisionOptionState {
        let kind = decisionKind(for: suggestion.kind)
        return PlanReflowDecisionOptionState(
            id: "reflow-decision-\(kind.rawValue)-\(suggestion.id)",
            kind: kind,
            title: kind.title,
            detail: suggestion.detail,
            impactLabel: suggestion.impactLabel,
            sourceLabel: sourceLabel,
            trustLabel: trustLabel,
            boundaryLabel: "\(suggestion.boundary.confirmationLabel). \(suggestion.boundary.undoLabel).",
            visualState: suggestion.visualState,
            target: suggestion.target,
            planRoute: suggestion.planRoute
        )
    }

    private func decisionKind(for suggestionKind: PlanReflowSuggestionKind) -> PlanReflowDecisionOptionKind {
        switch suggestionKind {
        case .keepPlanUnchanged:
            .keepPlan
        case .protectOneItem:
            .protectTime
        case .shrinkAction, .splitAction:
            .makeSmaller
        case .moveLocalActionLater, .deferGoalOrItem:
            .moveLater
        case .recoverRest:
            .recover
        case .dropOptionalWork, .parkGoal, .markWaiting, .askForConfirmation:
            .reviewPlan
        }
    }
}
