import AmbitionsDesignSystem
import SwiftUI

struct InsightsRouteHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let trustWhisper: String
    let state: AmbitionVisualState

    var body: some View {
        HeroCard(state: state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(dominantTruth)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(trustWhisper)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct InsightsRouteActionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let state: AmbitionVisualState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            Image(systemName: "arrow.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: state).accent)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}
