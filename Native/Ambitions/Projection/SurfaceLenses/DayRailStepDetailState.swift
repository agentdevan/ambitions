import AmbitionsDesignSystem
import Foundation

struct DayRailStepDetailState: Identifiable, Equatable {
    let id: String
    let title: String
    let timingBucket: String
    let durationLabel: String
    let durationSourceLabel: String
    let sourceLabel: String
    let contextLabel: String
    let goalLinkLabel: String
    let whyBullets: [String]
    let privacyStateLabel: String?
    let isPrivateProjection: Bool
    let stepSessionLabel: String
    let primaryAction: TodayInlineAction
    let closureAction: TodayInlineAction
    let secondaryActions: [TodayInlineAction]
    let proofReceiptLabel: String
    let receiptBoundaryLabel: String
    let detailTarget: DayRailDetailTargetState
}


extension DayRailHeroStepState {
    func stepDetail(privacy: DayRailPrivacyProjectionState, contextLabel: String) -> DayRailStepDetailState {
        DayRailStepDetailState(
            id: "step-detail.hero.\(id)",
            title: privacy.detailTitle(title),
            timingBucket: "Start here",
            durationLabel: duration.label,
            durationSourceLabel: duration.source.detailLabel,
            sourceLabel: privacy.sourceSummary(from: sourceLabels),
            contextLabel: privacy.detailContext(contextLabel),
            goalLinkLabel: privacy.goalLinkLabel(from: subtitle),
            whyBullets: privacy.whyBullets(
                primary: whySummary,
                sourceLabel: privacy.sourceSummary(from: sourceLabels),
                contextLabel: contextLabel,
                goalSupport: subtitle
            ),
            privacyStateLabel: privacy.detailPrivacyLabel,
            isPrivateProjection: privacy.isSensitiveProjection,
            stepSessionLabel: DayRailStepDetailState.stepSessionLabel(for: primaryAction.target),
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: primaryAction.target),
            closureAction: DayRailStepDetailState.closeLoopAction(target: primaryAction.target),
            secondaryActions: DayRailStepDetailState.placeholderActions(target: primaryAction.target),
            proofReceiptLabel: DayRailStepDetailState.proofReceiptLabel(isPrivate: privacy.isSensitiveProjection),
            receiptBoundaryLabel: DayRailStepDetailState.receiptBoundaryLabel,
            detailTarget: detailTarget
        )
    }
}

extension DayRailRowState {
    func stepDetail(privacy: DayRailPrivacyProjectionState, contextLabel: String) -> DayRailStepDetailState {
        DayRailStepDetailState(
            id: "step-detail.row.\(id)",
            title: privacy.detailTitle(title),
            timingBucket: slot.title,
            durationLabel: duration.label,
            durationSourceLabel: duration.source.detailLabel,
            sourceLabel: privacy.sourceSummary(from: sourceLabels),
            contextLabel: privacy.detailContext(contextLabel),
            goalLinkLabel: privacy.goalLinkLabel(from: title),
            whyBullets: privacy.whyBullets(
                primary: subtitle,
                sourceLabel: privacy.sourceSummary(from: sourceLabels),
                contextLabel: contextLabel,
                goalSupport: title
            ),
            privacyStateLabel: privacy.detailPrivacyLabel,
            isPrivateProjection: privacy.isSensitiveProjection,
            stepSessionLabel: DayRailStepDetailState.stepSessionLabel(for: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            closureAction: DayRailStepDetailState.closeLoopAction(target: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            secondaryActions: DayRailStepDetailState.placeholderActions(target: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            proofReceiptLabel: DayRailStepDetailState.proofReceiptLabel(isPrivate: privacy.isSensitiveProjection),
            receiptBoundaryLabel: DayRailStepDetailState.receiptBoundaryLabel,
            detailTarget: detailTarget
        )
    }
}

extension DayRailStepDetailState {
    static func reservedStartNowAction(target: TodayActionTarget) -> TodayInlineAction {
        TodayInlineAction(kind: .startStepSession, title: "Start now", systemImage: "scope", state: .selected, target: target)
    }

    static func closeLoopAction(target: TodayActionTarget) -> TodayInlineAction {
        TodayInlineAction(kind: .closeActionClosure, title: "Close the loop", systemImage: "checkmark.seal", state: .success, target: target)
    }

    static func placeholderActions(target: TodayActionTarget) -> [TodayInlineAction] {
        [
            TodayInlineAction(kind: .openTime, title: "Adjust time", systemImage: "arrow.right.arrow.left", state: .default, target: target),
            TodayInlineAction(kind: .defer, title: "Review later", systemImage: "clock", state: .default, target: target),
        ]
    }

    static func stepSessionLabel(for target: TodayActionTarget) -> String {
        target.goalID == nil && target.stepID == nil && target.draftID == nil
            ? "Step session needs a selected step."
            : "Step session opens for this one step."
    }

    static func proofReceiptLabel(isPrivate: Bool) -> String {
        isPrivate
            ? "Proof and receipts stay private until you choose what to close."
            : "Proof and receipts stay attached to this step when you close the loop."
    }

    static var receiptBoundaryLabel: String {
        "Changes stay reviewable."
    }

    var visibleCopy: String {
        ([
            title,
            timingBucket,
            durationLabel,
            durationSourceLabel,
            sourceLabel,
            contextLabel,
            goalLinkLabel,
            privacyStateLabel,
            stepSessionLabel,
            proofReceiptLabel,
            receiptBoundaryLabel,
            "Open step",
            "Recommended because",
            primaryAction.title,
            closureAction.title,
        ].compactMap { $0 } + whyBullets + secondaryActions.map(\.title)).joined(separator: " ")
    }
}

extension DayRailDurationSource {
    var detailLabel: String {
        switch self {
        case .userSet:
            "Duration source: User-set"
        case .suggested:
            "Duration source: Suggested duration"
        case .historicallyBased:
            "Duration source: Historical"
        case .acceptedFromPlan:
            "Duration source: Accepted from plan"
        case .calendarBlock:
            "Duration source: Calendar-derived"
        case .notSet:
            "Duration source: Unset"
        }
    }
}
