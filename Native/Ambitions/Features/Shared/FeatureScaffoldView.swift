import AmbitionsDesignSystem
import SwiftUI

struct FeatureScaffoldView<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let subtitle: String
    private let eyebrow: String?
    private let content: Content

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                HeroCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        if let eyebrow {
                            Text(eyebrow)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.accentWarm)
                        }

                        Text(title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text(subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .ambitionPanelAccessibility()

                content
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: title)
    }
}
