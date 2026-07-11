import SwiftUI

struct TodayObjectView: View {
    let experience: TodayExperience
    let approvedReplacementRail: AmbitionsDayRailViewState?
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState, AmbitionsDayRailViewState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void
    let clock: any AmbitionsClock

    var body: some View {
        let displayExecution = approvedReplacementRail.map { experience.execution.replacingDayRail($0) } ?? experience.execution
        let displayRail = displayExecution.dayRail
        RealityMeridianView(
            state: displayRail,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail,
            onShowAnother: { step in onShowAnother(step, displayRail) },
            onNotThis: onNotThis,
            clock: clock
        )
        .accessibilityLabel(TodayAccessibility.rootSummary(
            startHereTitle: displayRail.heroStep?.title ?? "None",
            meridianState: displayRail.contextSummary,
            recoveryState: displayRail.continuity.markers.isEmpty ? "Stable" : "Active",
            proofState: displayRail.proofSlot.noSilentChanges ? "Reviewable" : "Pending"
        ))
    }
}
import AmbitionsTimeFoundation
