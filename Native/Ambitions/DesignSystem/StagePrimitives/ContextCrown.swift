import AmbitionsDesignSystem
import SwiftUI

struct ContextCrown: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let contextPhrase: String
    let accent: Color
    let wraps: Bool

    init(title: String, contextPhrase: String, accent: Color, wraps: Bool = false) {
        self.title = title
        self.contextPhrase = contextPhrase
        self.accent = accent
        self.wraps = wraps
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Circle()
                .fill(accent)
                .frame(width: 5, height: 5)
                .accessibilityHidden(true)

            Text(title.uppercased())
                .font(theme.typography.micro.weight(.bold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(contextPhrase)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(wraps ? 2 : 1)
                .minimumScaleFactor(0.74)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: wraps)
        }
        .layoutPriority(2)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("shell.header.context-crown")
    }
}
