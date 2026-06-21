import AmbitionsDesignSystem
import SwiftUI

struct ShellChromeFlagshipAdapter<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let content: Content

    init(title: String, subtitle: String?, posture: AppShellHeaderPosture, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.posture = posture
        self.content = content()
    }

    var body: some View {
        FlagshipRuntimeStage(
            kind: .shellChrome,
            title: title,
            summary: stageSummary,
            metrics: metrics,
            proofHooks: proofHooks,
            screenshotIdentifier: "shell.flagship.chrome"
        ) { content }
        .accessibilityIdentifier("shell.flagship.chrome.stage")
    }

    private var stageSummary: String {
        let motion = reduceMotion ? "Static shell." : "Adaptive shell."
        return dynamicTypeSize.isAccessibilitySize ? "Readable shell hierarchy. \(motion)" : "\(subtitle ?? posture.continuityMessage) \(motion)"
    }

    private var metrics: [FlagshipRuntimeMetric] {
        [
            FlagshipRuntimeMetric(id: "posture", title: "Posture", value: posture.title, systemImage: posture.systemImage),
            FlagshipRuntimeMetric(id: "surface", title: "Surface", value: title, systemImage: "iphone")
        ]
    }

    private var proofHooks: [FlagshipRuntimeProofHook] {
        [
            FlagshipRuntimeProofHook(id: "navigation", title: "Navigation", summary: "Primary tabs stay under one shell law.", accessibilityHint: "Explains the current shell frame."),
            FlagshipRuntimeProofHook(id: "accessibility", title: "Accessibility", summary: "Dynamic Type and Reduce Motion keep the same hierarchy.", accessibilityHint: "Confirms accessibility state does not change meaning.")
        ]
    }
}

extension View {
    func flagshipShellChromeStage(title: String, subtitle: String?, posture: AppShellHeaderPosture) -> some View {
        ShellChromeFlagshipAdapter(title: title, subtitle: subtitle, posture: posture) { self }
    }
}
