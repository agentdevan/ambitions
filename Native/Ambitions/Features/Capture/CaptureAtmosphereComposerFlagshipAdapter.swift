import AmbitionsDesignSystem
import SwiftUI

struct CaptureAtmosphereComposerFlagshipAdapter<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: LivingVisualState
    let summary: String
    let content: Content

    init(
        state: LivingVisualState,
        summary: String,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.summary = summary
        self.content = content()
    }

    var body: some View {
        FlagshipRuntimeStage(
            kind: .atmosphereComposer,
            title: "Atmosphere Composer",
            summary: stageSummary,
            metrics: metrics,
            proofHooks: proofHooks,
            screenshotIdentifier: "capture.flagship.atmosphere-composer"
        ) {
            content
                .accessibilityIdentifier("capture.flagship.atmosphere-composer.content")
        }
        .accessibilityIdentifier("capture.flagship.atmosphere-composer.adapter")
    }

    private var stageSummary: String {
        let motionLine = reduceMotion ? "Route feedback remains static." : "Route feedback can settle with motion."
        if dynamicTypeSize.isAccessibilitySize {
            return "Open Field, suggested path, and review stay in one readable stage. \(motionLine)"
        }
        return "\(summary) \(motionLine)"
    }

    private var metrics: [FlagshipRuntimeMetric] {
        [
            FlagshipRuntimeMetric(id: "input", title: "Input", value: state.title, systemImage: "text.cursor"),
            FlagshipRuntimeMetric(id: "controls", title: "Controls", value: "Ready", systemImage: "slider.horizontal.3"),
            FlagshipRuntimeMetric(id: "route", title: "Route", value: "Editable", systemImage: "arrow.triangle.branch"),
            FlagshipRuntimeMetric(id: "privacy", title: "Storage", value: "On device", systemImage: "lock.shield")
        ]
    }

    private var proofHooks: [FlagshipRuntimeProofHook] {
        [
            FlagshipRuntimeProofHook(id: "route", title: "Suggested path", summary: "Placement appears after input and stays editable before save.", accessibilityHint: "Explains why Capture has not created planned work yet."),
            FlagshipRuntimeProofHook(id: "review", title: "Review before save", summary: "The user keeps control of what becomes a Step, Goal, Time item, or saved note.", accessibilityHint: "Confirms capture changes remain reviewable."),
            FlagshipRuntimeProofHook(id: "proof", title: "On-device record", summary: "Capture remains local-first until the user chooses where it belongs.", accessibilityHint: "States the privacy posture for captured text."),
            FlagshipRuntimeProofHook(id: "controls", title: "Expandable controls", summary: "Camera, photos, files, scan, date, reminder, repeat, location, goal, flag, full composer, place later, protected time, and proof stay part of one intake grammar.", accessibilityHint: "Summarizes the composer control set.")
        ]
    }
}

extension View {
    func flagshipCaptureComposerStage(state: LivingVisualState, summary: String) -> some View {
        CaptureAtmosphereComposerFlagshipAdapter(state: state, summary: summary) {
            self
        }
    }
}
