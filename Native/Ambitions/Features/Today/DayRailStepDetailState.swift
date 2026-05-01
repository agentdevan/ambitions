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
    let whyBullets: [String]
    let privacyStateLabel: String?
    let isPrivateProjection: Bool
    let primaryAction: TodayInlineAction
    let secondaryActions: [TodayInlineAction]
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
            whyBullets: privacy.whyBullets(
                primary: whySummary,
                sourceLabel: privacy.sourceSummary(from: sourceLabels),
                contextLabel: contextLabel,
                goalSupport: subtitle
            ),
            privacyStateLabel: privacy.detailPrivacyLabel,
            isPrivateProjection: privacy.isSensitiveProjection,
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: primaryAction.target),
            secondaryActions: DayRailStepDetailState.placeholderActions(target: primaryAction.target),
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
            whyBullets: privacy.whyBullets(
                primary: subtitle,
                sourceLabel: privacy.sourceSummary(from: sourceLabels),
                contextLabel: contextLabel,
                goalSupport: title
            ),
            privacyStateLabel: privacy.detailPrivacyLabel,
            isPrivateProjection: privacy.isSensitiveProjection,
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            secondaryActions: DayRailStepDetailState.placeholderActions(target: TodayActionTarget(goalID: detailTarget.goalID, stepID: detailTarget.stepID, draftID: detailTarget.draftID)),
            detailTarget: detailTarget
        )
    }
}

extension DayRailStepDetailState {
    static func reservedStartNowAction(target: TodayActionTarget) -> TodayInlineAction {
        TodayInlineAction(kind: .startStepSession, title: "Start now", systemImage: "scope", state: .selected, target: target)
    }

    static func placeholderActions(target: TodayActionTarget) -> [TodayInlineAction] {
        [
            TodayInlineAction(kind: .openPlan, title: "Adjust plan", systemImage: "arrow.right.arrow.left", state: .default, target: target),
            TodayInlineAction(kind: .defer, title: "Review later", systemImage: "clock", state: .default, target: target),
        ]
    }

    var visibleCopy: String {
        ([
            title,
            timingBucket,
            durationLabel,
            durationSourceLabel,
            sourceLabel,
            contextLabel,
            privacyStateLabel,
            "Why this?",
            "Recommended because",
            primaryAction.title,
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
