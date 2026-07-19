import AmbitionsDesignSystem
import Foundation

enum TimeReflowDecisionOptionKind: String, Sendable, CaseIterable {
    case keepTime = "keep_shape"
    case makeSmaller = "make_smaller"
    case moveLater = "move_later"
    case reviewShape = "review_shape"
    case protectTime = "protect_time"
    case recover = "recover"

    var title: String {
        switch self {
        case .keepTime: "Keep Time"
        case .makeSmaller: "Make smaller"
        case .moveLater: "Move it"
        case .reviewShape: "Review shape"
        case .protectTime: "Protect time"
        case .recover: "Recover"
        }
    }

    var icon: String {
        switch self {
        case .keepTime: "checkmark.seal"
        case .makeSmaller: "arrow.down.right.and.arrow.up.left"
        case .moveLater: "clock.arrow.circlepath"
        case .reviewShape: "list.bullet.clipboard"
        case .protectTime: "clock.badge.checkmark"
        case .recover: "sun.max"
        }
    }
}
enum TimeReflowDecisionActionKind: String, Sendable, CaseIterable, Hashable {
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

struct TimeReflowDecisionActionState: Identifiable, Sendable, Hashable {
    let kind: TimeReflowDecisionActionKind
    let title: String
    let detail: String
    let visualState: AmbitionVisualState
    let isEnabled: Bool

    var id: String { kind.rawValue }
}

struct TimeReflowDecisionOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: TimeReflowDecisionOptionKind
    let title: String
    let detail: String
    let whatChangedLabel: String
    let whyChangedLabel: String
    let impactedStepsLabel: String
    let capacityImpactLabel: String
    let protectedTimeImpactLabel: String
    let beforeAfterPreview: TimeReflowBeforeAfterShapePreviewState
    let impactLabel: String
    let sourceLabel: String
    let trustLabel: String
    let boundaryLabel: String
    let actions: [TimeReflowDecisionActionState]
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    init(
        id: String,
        kind: TimeReflowDecisionOptionKind,
        title: String,
        detail: String,
        whatChangedLabel: String = "What changed: review before changing Time.",
        whyChangedLabel: String = "Why: the current week may need your review before anything changes.",
        impactedStepsLabel: String = "Impacted steps: review before any step shifts.",
        capacityImpactLabel: String = "Capacity impact: reviewed before mutation.",
        protectedTimeImpactLabel: String = "Protected time impact: unchanged until you decide.",
        beforeAfterPreview: TimeReflowBeforeAfterShapePreviewState = .unchanged,
        impactLabel: String,
        sourceLabel: String,
        trustLabel: String,
        boundaryLabel: String,
        actions: [TimeReflowDecisionActionState] = TimeReflowDecisionOptionState.defaultActions,
        visualState: AmbitionVisualState,
        target: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
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
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
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

    private static var defaultActions: [TimeReflowDecisionActionState] {
        [
            TimeReflowDecisionActionState(
                kind: .accept,
                title: "Accept",
                detail: "Review before applying",
                visualState: .selected,
                isEnabled: false
            ),
            TimeReflowDecisionActionState(
                kind: .edit,
                title: "Edit",
                detail: "Review details first",
                visualState: .default,
                isEnabled: false
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

struct TimeReflowBeforeAfterShapePreviewState: Sendable, Hashable {
    let title: String
    let beforeLabel: String
    let afterLabel: String
    let shapeChangeLabel: String
    let receiptPreviewLabel: String

    static let unchanged = TimeReflowBeforeAfterShapePreviewState(
        title: "Before / after",
        beforeLabel: "Before: current Time shape stays visible.",
        afterLabel: "After: no Time shape changes until you choose.",
        shapeChangeLabel: "Shape change: none yet.",
        receiptPreviewLabel: "After review: no mutation recorded."
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

struct TimeReflowDecisionState: Sendable {
    let title: String
    let subtitle: String
    let sourceLabel: String
    let trustLabel: String
    let reasonLabel: String
    let recoveryLabel: String
    let receiptLabel: String
    let options: [TimeReflowDecisionOptionState]
    let visualState: AmbitionVisualState
}
