import AmbitionsDesignSystem
import SwiftUI

struct ContinuityDockAction: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let systemImage: String
}

struct ContinuityDock: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [ContinuityDockAction]
    let onSelect: (ContinuityDockAction) -> Void

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                Button {
                    onSelect(action)
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                        .labelStyle(.iconOnly)
                        .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityLabel(action.title)
                .accessibilityIdentifier("stage.continuity-dock.\(action.id)")
            }
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(Capsule(style: .continuous).fill(theme.shell.bottomBarMaterial))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stage.continuity-dock")
    }
}
