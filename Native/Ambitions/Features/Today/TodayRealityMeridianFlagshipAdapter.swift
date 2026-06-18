import AmbitionsDesignSystem
import SwiftUI

struct TodayRealityMeridianFlagshipAdapter: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void
    let clock: any AmbitionsClock

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void,
        onShowAnother: @escaping (DayRailHeroStepState) -> Void,
        onNotThis: @escaping (DayRailHeroStepState) -> Void,
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
        FlagshipRuntimeStage(
            kind: .realityMeridian,
            title: "Reality Meridian",
            summary: stageSummary,
            metrics: metrics,
            screenshotIdentifier: "today.flagship.reality-meridian"
        ) {
            RealityMeridianView(
                state: state,
                onAction: onAction,
                onOpenStepDetail: onOpenStepDetail,
                onShowAnother: onShowAnother,
                onNotThis: onNotThis,
                clock: clock
            )
            .accessibilityIdentifier("today.flagship.reality-meridian.content")
        }
        .accessibilityIdentifier("today.flagship.reality-meridian.adapter")
    }

    private var stageSummary: String {
        let motionSummary = reduceMotion ? "Motion is restrained for stability." : "Motion marks state transitions."
        if dynamicTypeSize.isAccessibilitySize {
            return "Start here stays in a stable VoiceOver order. \(motionSummary)"
        }
        return "Start here stays anchored to this time and context. \(motionSummary)"
    }

    private var metrics: [FlagshipRuntimeMetric] {
        guard TodayViewportSafety.layout(
            dynamicTypeSize: dynamicTypeSize,
            showsNavigationChrome: false
        ).showsStageMetrics else {
            return []
        }

        return [
            FlagshipRuntimeMetric(id: "date", title: "Window", value: state.dateTitle, systemImage: "clock"),
            FlagshipRuntimeMetric(id: "mode", title: "State", value: state.mode.rawValue.capitalized, systemImage: "dial.low"),
            FlagshipRuntimeMetric(id: "duration", title: "Fit", value: state.heroStep?.duration.label ?? "Open", systemImage: "timer")
        ]
    }

}
