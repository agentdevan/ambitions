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

enum PlanReflowDecisionActionKind: String, Sendable, CaseIterable, Hashable {
    case accept
    case edit
    case decline

    var title: String {
        switch self {
        case .accept: "Accept"
        case .edit: "Edit"
        case .decline: "Decline"
        }
    }

    var icon: String {
        switch self {
        case .accept: "checkmark.circle"
        case .edit: "slider.horizontal.3"
        case .decline: "xmark.circle"
        }
    }
}

struct PlanReflowDecisionActionState: Identifiable, Sendable, Hashable {
    let kind: PlanReflowDecisionActionKind
    let title: String
    let detail: String
    let visualState: AmbitionVisualState
    let isEnabled: Bool

    var id: String { kind.rawValue }
}

struct PlanReflowDecisionOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: PlanReflowDecisionOptionKind
    let title: String
    let detail: String
    let whatChangedLabel: String
    let whyChangedLabel: String
    let impactedStepsLabel: String
    let capacityImpactLabel: String
    let protectedTimeImpactLabel: String
    let beforeAfterPreview: PlanReflowBeforeAfterShapePreviewState
    let impactLabel: String
    let sourceLabel: String
    let trustLabel: String
    let boundaryLabel: String
    let actions: [PlanReflowDecisionActionState]
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let planRoute: PlanRouteTarget?

    init(
        id: String,
        kind: PlanReflowDecisionOptionKind,
        title: String,
        detail: String,
        whatChangedLabel: String = "What changed: review before changing the plan.",
        whyChangedLabel: String = "Why: the current plan may need a user-owned reflow decision.",
        impactedStepsLabel: String = "Impacted steps: review before anything moves.",
        capacityImpactLabel: String = "Capacity impact: reviewed before mutation.",
        protectedTimeImpactLabel: String = "Protected time impact: unchanged until you decide.",
        beforeAfterPreview: PlanReflowBeforeAfterShapePreviewState = .unchanged,
        impactLabel: String,
        sourceLabel: String,
        trustLabel: String,
        boundaryLabel: String,
        actions: [PlanReflowDecisionActionState] = PlanReflowDecisionOptionState.defaultActions,
        visualState: AmbitionVisualState,
        target: GoalRouteTarget?,
        planRoute: PlanRouteTarget?
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.whatChangedLabel = whatChangedLabel
        self.whyChangedLabel = whyChangedLabel
        self.impactedStepsLabel = impactedStepsLabel
        self.capacityImpactLabel = capacityImpactLabel
        self.protectedTimeImpactLabel = protectedTimeImpactLabel
        self.beforeAfterPreview = beforeAfterPreview
        self.impactLabel = impactLabel
        self.sourceLabel = sourceLabel
        self.trustLabel = trustLabel
        self.boundaryLabel = boundaryLabel
        self.actions = actions
        self.visualState = visualState
        self.target = target
        self.planRoute = planRoute
    }

    var accessibilityValue: String {
        [
            detail,
            whatChangedLabel,
            whyChangedLabel,
            impactedStepsLabel,
            capacityImpactLabel,
            protectedTimeImpactLabel,
            beforeAfterPreview.accessibilityValue,
            trustLabel,
            boundaryLabel,
            actions.map(\.title).joined(separator: ", ")
        ].joined(separator: ". ")
    }

    private static var defaultActions: [PlanReflowDecisionActionState] {
        [
            PlanReflowDecisionActionState(
                kind: .accept,
                title: "Accept",
                detail: "Review before applying",
                visualState: .selected,
                isEnabled: false
            ),
            PlanReflowDecisionActionState(
                kind: .edit,
                title: "Edit",
                detail: "Review details first",
                visualState: .default,
                isEnabled: false
            ),
            PlanReflowDecisionActionState(
                kind: .decline,
                title: "Decline",
                detail: "Keep plan as-is",
                visualState: .success,
                isEnabled: true
            )
        ]
    }
}

struct PlanReflowBeforeAfterShapePreviewState: Sendable, Hashable {
    let title: String
    let beforeLabel: String
    let afterLabel: String
    let shapeChangeLabel: String
    let receiptPreviewLabel: String

    static let unchanged = PlanReflowBeforeAfterShapePreviewState(
        title: "Before / after",
        beforeLabel: "Before: current plan stays visible.",
        afterLabel: "After: no plan shape changes until you choose.",
        shapeChangeLabel: "Shape change: none yet.",
        receiptPreviewLabel: "Receipt preview: no mutation recorded."
    )

    var accessibilityValue: String {
        [
            title,
            beforeLabel,
            afterLabel,
            shapeChangeLabel,
            receiptPreviewLabel
        ].joined(separator: ". ")
    }
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
            reasonLabel: reflow.reasonDetail,
            receiptPreview: receiptPreview,
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
        reasonLabel: String,
        receiptPreview: PlanReflowReceiptPreviewState,
        sourceLabel: String,
        trustLabel: String
    ) -> [PlanReflowDecisionOptionState] {
        let mapped = suggestions.map { suggestion in
            option(
                from: suggestion,
                reasonLabel: reasonLabel,
                receiptPreview: receiptPreview,
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
                whatChangedLabel: "What changed: nothing yet.",
                whyChangedLabel: "Why: the plan does not need a reflow decision.",
                impactedStepsLabel: "Impacted steps: none.",
                capacityImpactLabel: "Capacity impact: unchanged.",
                protectedTimeImpactLabel: "Protected time impact: unchanged.",
                beforeAfterPreview: PlanReflowBeforeAfterShapePreviewState(
                    title: "Before / after",
                    beforeLabel: "Before: current plan stays visible.",
                    afterLabel: "After: plan remains unchanged.",
                    shapeChangeLabel: "Shape change: none.",
                    receiptPreviewLabel: "Receipt preview: no mutation recorded."
                ),
                impactLabel: "No plan mutation",
                sourceLabel: sourceLabel,
                trustLabel: trustLabel,
                boundaryLabel: "Safe local suggestion",
                actions: actions(canNavigate: false),
                visualState: .default,
                target: nil,
                planRoute: nil
            ))
        }

        return Array(result.prefix(5))
    }

    private func option(
        from suggestion: PlanReflowSuggestionState,
        reasonLabel: String,
        receiptPreview: PlanReflowReceiptPreviewState,
        sourceLabel: String,
        trustLabel: String
    ) -> PlanReflowDecisionOptionState {
        let kind = decisionKind(for: suggestion.kind)
        let canNavigate = suggestion.target != nil || suggestion.planRoute != nil
        return PlanReflowDecisionOptionState(
            id: "reflow-decision-\(kind.rawValue)-\(suggestion.id)",
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

    private func actions(
        canNavigate: Bool,
        confirmation: String = "Safe local suggestion"
    ) -> [PlanReflowDecisionActionState] {
        [
            PlanReflowDecisionActionState(
                kind: .accept,
                title: "Accept",
                detail: confirmation,
                visualState: .selected,
                isEnabled: canNavigate
            ),
            PlanReflowDecisionActionState(
                kind: .edit,
                title: "Edit",
                detail: "Review details first",
                visualState: .default,
                isEnabled: canNavigate
            ),
            PlanReflowDecisionActionState(
                kind: .decline,
                title: "Decline",
                detail: "Keep plan as-is",
                visualState: .success,
                isEnabled: true
            )
        ]
    }

    private func whatChangedLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepPlanUnchanged:
            return "What changed: nothing yet."
        case .protectOneItem:
            return "What changed: one item may become protected."
        case .shrinkAction:
            return "What changed: one step may become smaller."
        case .splitAction:
            return "What changed: one step may split into a first part."
        case .moveLocalActionLater:
            return "What changed: one local action may move later."
        case .deferGoalOrItem:
            return "What changed: one item may leave this plan window."
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

    private func impactedStepsLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepPlanUnchanged, .askForConfirmation:
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

    private func capacityImpactLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepPlanUnchanged:
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

    private func protectedTimeImpactLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .protectOneItem, .recoverRest:
            return "Protected time impact: one protected pocket stays defended."
        case .moveLocalActionLater:
            return "Protected time impact: Calendar is untouched."
        case .keepPlanUnchanged, .askForConfirmation:
            return "Protected time impact: unchanged."
        default:
            return "Protected time impact: reviewed before anything moves."
        }
    }

    private func beforeAfterPreview(
        for suggestion: PlanReflowSuggestionState,
        receiptPreview: PlanReflowReceiptPreviewState
    ) -> PlanReflowBeforeAfterShapePreviewState {
        PlanReflowBeforeAfterShapePreviewState(
            title: "Before / after",
            beforeLabel: beforeLabel(for: suggestion),
            afterLabel: afterLabel(for: suggestion),
            shapeChangeLabel: "Shape change: \(suggestion.impactLabel).",
            receiptPreviewLabel: "Receipt preview: \(receiptPreview.confirmationRequired)"
        )
    }

    private func beforeLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepPlanUnchanged, .askForConfirmation:
            return "Before: current plan stays visible."
        case .protectOneItem:
            return "Before: protected time is not defended yet."
        case .recoverRest:
            return "Before: recovery space is not protected yet."
        case .moveLocalActionLater, .deferGoalOrItem, .dropOptionalWork, .parkGoal:
            return "Before: load still sits in the current plan window."
        case .markWaiting:
            return "Before: waiting stays mixed with doing."
        case .shrinkAction, .splitAction:
            return "Before: the next ask is still too large."
        }
    }

    private func afterLabel(for suggestion: PlanReflowSuggestionState) -> String {
        switch suggestion.kind {
        case .keepPlanUnchanged:
            return "After: plan remains unchanged."
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
