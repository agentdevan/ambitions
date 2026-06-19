import AmbitionsDesignSystem
import Foundation

extension TimeReflowDecisionProjector {
    func preferredOptions(
        from suggestions: [TimeReflowSuggestionState],
        reasonLabel: String,
        receiptPreview: TimeReflowReceiptPreviewState,
        sourceLabel: String,
        trustLabel: String
    ) -> [TimeReflowDecisionOptionState] {
        let mapped = suggestions.map { suggestion in
            option(
                from: suggestion,
                reasonLabel: reasonLabel,
                receiptPreview: receiptPreview,
                sourceLabel: sourceLabel,
                trustLabel: trustLabel
            )
        }
        let prioritizedKinds: [TimeReflowDecisionOptionKind] = [
            .keepTime,
            .protectTime,
            .makeSmaller,
            .moveLater,
            .reviewShape,
            .recover
        ]

        var result: [TimeReflowDecisionOptionState] = []
        for kind in prioritizedKinds {
            if let option = mapped.first(where: { $0.kind == kind }),
               result.contains(where: { $0.kind == kind }) == false {
                result.append(option)
            }
        }

        if result.isEmpty {
            result.append(TimeReflowDecisionOptionState(
                id: "time-change-decision-keep-time",
                kind: .keepTime,
                title: TimeReflowDecisionOptionKind.keepTime.title,
                detail: "Leave Time unchanged until there is enough evidence to adjust it.",
                whatChangedLabel: "What changed: nothing yet.",
                whyChangedLabel: "Why: Time does not need a change review.",
                impactedStepsLabel: "Impacted steps: none.",
                capacityImpactLabel: "Capacity impact: unchanged.",
                protectedTimeImpactLabel: "Protected time impact: unchanged.",
                beforeAfterPreview: TimeReflowBeforeAfterShapePreviewState(
                    title: "Before / after",
                    beforeLabel: "Before: current Time shape stays visible.",
                    afterLabel: "After: Time remains unchanged.",
                    shapeChangeLabel: "Shape change: none.",
                    receiptPreviewLabel: "After review: no mutation recorded."
                ),
                impactLabel: "No Time mutation",
                sourceLabel: sourceLabel,
                trustLabel: trustLabel,
                boundaryLabel: "Safe local suggestion",
                actions: actions(canNavigate: false),
                visualState: .default,
                target: nil,
                timeRoute: nil
            ))
        }

        return Array(result.prefix(5))
    }

    func option(
        from suggestion: TimeReflowSuggestionState,
        reasonLabel: String,
        receiptPreview: TimeReflowReceiptPreviewState,
        sourceLabel: String,
        trustLabel: String
    ) -> TimeReflowDecisionOptionState {
        let kind = decisionKind(for: suggestion.kind)
        let canNavigate = suggestion.target != nil || suggestion.timeRoute != nil || suggestion.interactionIntent != nil
        return TimeReflowDecisionOptionState(
            id: "time-change-decision-\(kind.rawValue)-\(suggestion.id)",
            kind: kind,
            title: kind.title,
            detail: suggestion.detail,
            whatChangedLabel: whatChangedLabel(for: suggestion),
            whyChangedLabel: "Why: \(reasonLabel)",
            impactedStepsLabel: impactedStepsLabel(for: suggestion),
            capacityImpactLabel: capacityImpactLabel(for: suggestion),
            protectedTimeImpactLabel: protectedTimeImpactLabel(for: suggestion),
            beforeAfterPreview: beforeAfterPreview(for: suggestion, receiptPreview: receiptPreview),
            impactLabel: suggestion.impactLabel,
            sourceLabel: sourceLabel,
            trustLabel: trustLabel,
            boundaryLabel: "\(suggestion.boundary.confirmationLabel). \(suggestion.boundary.undoLabel).",
            actions: actions(
                canNavigate: canNavigate,
                confirmation: receiptPreview.confirmationRequired
            ),
            visualState: suggestion.visualState,
            target: suggestion.target,
            timeRoute: suggestion.timeRoute,
            interactionIntent: suggestion.interactionIntent
        )
    }

    func decisionKind(for suggestionKind: TimeReflowSuggestionKind) -> TimeReflowDecisionOptionKind {
        switch suggestionKind {
        case .keepTimeUnchanged:
            .keepTime
        case .protectOneItem:
            .protectTime
        case .shrinkAction, .splitAction:
            .makeSmaller
        case .moveLocalActionLater, .deferGoalOrItem:
            .moveLater
        case .recoverRest:
            .recover
        case .dropOptionalWork, .parkGoal, .markWaiting, .askForConfirmation:
            .reviewShape
        }
    }

    func actions(
        canNavigate: Bool,
        confirmation: String = "Safe local suggestion"
    ) -> [TimeReflowDecisionActionState] {
        [
            TimeReflowDecisionActionState(
                kind: .accept,
                title: "Accept",
                detail: confirmation,
                visualState: .selected,
                isEnabled: canNavigate
            ),
            TimeReflowDecisionActionState(
                kind: .edit,
                title: "Edit",
                detail: "Review details first",
                visualState: .default,
                isEnabled: canNavigate
            ),
            TimeReflowDecisionActionState(
                kind: .decline,
                title: "Decline",
                detail: "Keep Time as-is",
                visualState: .success,
                isEnabled: true
            )
        ]
    }

}
