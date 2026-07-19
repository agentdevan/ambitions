import AmbitionsDesignSystem
import SwiftUI

struct ReceiptSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let source: String
    let receipt: String
    let status: String

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: "doc.text.magnifyingglass")
                .foregroundStyle(theme.semanticColors.trust)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(source)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(receipt)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(status)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.sm)
        .background(SurfaceMorphBackdrop(role: .detailObject))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("stage.receipt-surface")
    }
}
