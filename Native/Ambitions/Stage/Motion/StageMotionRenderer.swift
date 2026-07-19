import AmbitionsDesignSystem
import SwiftUI

struct StageMotionRenderer: View {
    @Environment(\.ambitionTheme) private var theme

    let layer: StageMotionLayer
    let onAction: (MotionCurrentAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            MotionCurrentField(
                state: layer.projection.field,
                lanes: layer.projection.lanes,
                reduceMotion: layer.reduceMotion,
                onAction: onAction
            )
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(layer.accessibilityPlan.label)
        .accessibilityValue(layer.accessibilityPlan.value)
        .accessibilityHint(layer.accessibilityPlan.hint)
        .accessibilityIdentifier(layer.rendererIdentifier)
    }
}
