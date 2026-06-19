import AmbitionsDesignSystem
import SwiftUI

struct TodayEmptyPathAction: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let action: TodayInlineAction
}

enum TodayMeridianZoom: String, CaseIterable {
    case window
    case day

    var title: String {
        switch self {
        case .window: "Start Here"
        case .day: "Meridian"
        }
    }
}

/// The Reality Meridian surface for Today - the primary object presenting the daily execution rail.
struct RealityMeridianView: View {
    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void
    let clock: any AmbitionsClock

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in },
        clock: any AmbitionsClock = SystemClock()
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
        self.clock = clock
    }

    var body: some View {
        AmbitionsDayRailView(
            state: state,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail,
            onShowAnother: onShowAnother,
            onNotThis: onNotThis,
            clock: clock
        )
    }
}
