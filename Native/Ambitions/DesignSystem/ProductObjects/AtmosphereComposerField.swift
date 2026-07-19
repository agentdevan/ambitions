import AmbitionsDesignSystem
import SwiftUI

struct AtmosphereComposerField: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let isReady: Bool

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: isReady ? "square.and.pencil" : "pencil.and.outline")
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(theme.spacing.sm)
        .background(SurfaceMorphBackdrop(role: .detailObject))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("product.atmosphere-composer-field")
    }
}
