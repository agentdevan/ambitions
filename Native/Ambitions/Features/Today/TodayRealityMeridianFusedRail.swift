import AmbitionsDesignSystem
import SwiftUI

struct TodayRealityMeridianFusedRail: View {
    @Environment(\.ambitionTheme) private var theme

    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
    }

    var body: some View {
        DayTimelineRail(
            state: state,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail
        )
        .overlay(alignment: .topLeading) {
            RealityMeridianCurrentTimeCursor()
                .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.lg)
                .allowsHitTesting(false)
                .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
        }
        .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }
}
