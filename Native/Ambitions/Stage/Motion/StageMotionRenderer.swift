import AmbitionsDesignSystem
import SwiftUI

struct StageMotionRenderer: View {
    @Environment(\.ambitionTheme) private var theme

    let layer: StageMotionLayer
    let onAction: (MotionCurrentAction) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                MotionContextCrown(state: layer.projection.crown)
                MotionCurrentField(
                    state: layer.projection.field,
                    lanes: layer.projection.lanes,
                    reduceMotion: layer.reduceMotion,
                    onAction: onAction
                )
                MotionReentryPrompt()
                MotionLaneCluster(lanes: layer.projection.lanes)
                MotionSourceReceiptAffordance(state: layer.projection.affordance)
                MotionContinuityDock(actions: layer.projection.dockActions, onAction: onAction)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(layer.accessibilityPlan.label)
        .accessibilityValue(layer.accessibilityPlan.value)
        .accessibilityHint(layer.accessibilityPlan.hint)
        .accessibilityIdentifier(layer.rendererIdentifier)
    }
}
