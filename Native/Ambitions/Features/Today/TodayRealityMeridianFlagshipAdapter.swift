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

    var body: some View {
        FlagshipRuntimeStage(
            kind: .realityMeridian,
            title: "Reality Meridian",
            summary: stageSummary,
            metrics: metrics,
            proofHooks: proofHooks,
            screenshotIdentifier: "today.flagship.reality-meridian"
        ) {
            RealityMeridianView(
                state: state,
                onAction: onAction,
                onOpenStepDetail: onOpenStepDetail,
                onShowAnother: onShowAnother,
                onNotThis: onNotThis
            )
            .accessibilityIdentifier("today.flagship.reality-meridian.content")
        }
        .accessibilityIdentifier("today.flagship.reality-meridian.adapter")
    }

    private var stageSummary: String {
        let motionSummary = reduceMotion ? "Motion is held static." : "Motion may clarify state changes."
        if dynamicTypeSize.isAccessibilitySize {
            return "Start here, proof, and source context stack in a stable VoiceOver order. \(motionSummary)"
        }
        return "Start here stays anchored to current capacity, source context, and protected time. \(motionSummary)"
    }

    private var metrics: [FlagshipRuntimeMetric] {
        [
            FlagshipRuntimeMetric(id: "date", title: "Window", value: state.dateTitle, systemImage: "clock"),
            FlagshipRuntimeMetric(id: "mode", title: "State", value: state.mode.rawValue.capitalized, systemImage: "dial.low"),
            FlagshipRuntimeMetric(id: "duration", title: "Fit", value: state.heroStep?.duration.label ?? "Open", systemImage: "timer")
        ]
    }

    private var proofHooks: [FlagshipRuntimeProofHook] {
        [
            FlagshipRuntimeProofHook(id: "source", title: "Source context", summary: state.privacyProjection.sourceLabel, accessibilityHint: "Names the local context used to hold this step."),
            FlagshipRuntimeProofHook(id: "proof", title: "Proof", summary: state.proofSlot.title, accessibilityHint: "Explains what can be inspected after action."),
            FlagshipRuntimeProofHook(id: "continuity", title: "Continuity", summary: state.continuity.pressureLabel, accessibilityHint: "Explains whether the current window can hold the step.")
        ]
    }
}
