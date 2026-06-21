import AmbitionsDesignSystem
import SwiftUI

struct RecoveryBand: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(detail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        } icon: {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .foregroundStyle(theme.semanticColors.recovery)
        }
        .padding(theme.spacing.sm)
        .background(SurfaceMorphBackdrop(role: .detailObject))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("product.recovery-band")
    }
}
