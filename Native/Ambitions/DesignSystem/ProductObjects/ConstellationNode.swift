import AmbitionsDesignSystem
import SwiftUI

struct ConstellationNode: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Image(systemName: isSelected ? "sparkle.magnifyingglass" : "circle")
                .foregroundStyle(isSelected ? theme.colors.accentSecondary : theme.colors.textTertiary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("product.constellation-node")
    }
}
