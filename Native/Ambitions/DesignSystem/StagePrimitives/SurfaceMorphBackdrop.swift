import AmbitionsDesignSystem
import SwiftUI

struct SurfaceMorphBackdrop: View {
    @Environment(\.ambitionTheme) private var theme

    let role: ProductObjectFrameRole

    var body: some View {
        let colors = AmbitionsColor(theme: theme)
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(fill(colors: colors))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(colors.trustStroke.opacity(strokeOpacity), lineWidth: 1)
            )
            .accessibilityHidden(true)
    }

    private var radius: CGFloat {
        switch role {
        case .rootPrimaryObject: theme.radius.lg
        case .detailObject: theme.radius.md
        case .overlayObject: theme.radius.xl
        }
    }

    private var strokeOpacity: Double {
        role == .rootPrimaryObject ? 0.34 : 0.22
    }

    private func fill(colors: AmbitionsColor) -> Color {
        switch role {
        case .rootPrimaryObject: colors.primaryObjectFill
        case .detailObject: theme.colors.surfaceSecondary.opacity(0.62)
        case .overlayObject: theme.colors.surfaceOverlay.opacity(0.88)
        }
    }
}
