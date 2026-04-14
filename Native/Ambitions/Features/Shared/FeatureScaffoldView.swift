import AmbitionsDesignSystem
import SwiftUI

struct FeatureScaffoldView<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String
    private let content: Content

    init(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                HeroCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text(title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text(subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }

                content
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
    }
}
