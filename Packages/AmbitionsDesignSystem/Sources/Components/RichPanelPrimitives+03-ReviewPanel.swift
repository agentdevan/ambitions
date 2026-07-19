#if canImport(SwiftUI)
import SwiftUI

public struct ReviewPanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .review), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct SettingsPreferencePanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .settingsPreference), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public extension AmbitionRichPanelConfiguration {
    func with(kind: AmbitionPanelKind) -> AmbitionRichPanelConfiguration {
        AmbitionRichPanelConfiguration(
            kind: kind,
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            icon: icon,
            semanticState: semanticState == self.kind.defaultSemanticState ? kind.defaultSemanticState : semanticState,
            confidenceLabel: confidenceLabel,
            progressValue: progressValue,
            explanationTitle: explanationTitle,
            explanation: explanation,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
            accessibilityLabel: accessibilityLabel,
            accessibilityHint: accessibilityHint,
            accessibilityValue: accessibilityValue
        )
    }
}
#endif
