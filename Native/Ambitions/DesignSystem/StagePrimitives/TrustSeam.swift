import AmbitionsDesignSystem
import SwiftUI

struct TrustSeam<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let summary: String
    let content: Content

    init(title: String = "Trust details", summary: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.summary = summary
        self.content = content()
    }

    var body: some View {
        DisclosureGroup {
            content
                .padding(.top, theme.spacing.xs)
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("stage.trust-seam")
    }
}
