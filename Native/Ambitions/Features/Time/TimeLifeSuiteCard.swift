import AmbitionsDesignSystem
import SwiftUI

struct TimeLifeSuiteCard: View {
    @Environment(\.ambitionTheme) private var theme

    let suite: TimeLifeSuiteState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: suite.title, subtitle: suite.subtitle)

                TimeLifeShapeField(suite: suite)

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 220), spacing: theme.spacing.sm)
                    ],
                    alignment: .leading,
                    spacing: theme.spacing.sm
                ) {
                    ForEach(suite.shapes) { shape in
                        TimeLifeSuiteShapeTile(shape: shape)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    TagPill(suite.calendarBoundaryLabel, icon: "calendar.badge.checkmark", state: .selected)
                    TagPill(suite.manualFallbackLabel, icon: "hand.raised", state: .default)
                }

                Label(suite.trustLabel, systemImage: "checkmark.shield")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("time.life-suite")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimeLifeSuiteShapeTile: View {
    @Environment(\.ambitionTheme) private var theme

    let shape: TimeLifeSuiteShapeState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: shape.visualState).accent)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(shape.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(shape.question)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(shape.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                ForEach(shape.facts, id: \.self) { fact in
                    Label(fact, systemImage: "checkmark.circle")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(shape.boundaryLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.stateStyle(for: shape.visualState).accent)
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.stateStyle(for: shape.visualState).stroke.opacity(0.5), lineWidth: 1)
        )
        .accessibilityIdentifier("time.life-suite.\(shape.kind.rawValue)")
    }

    private var iconName: String {
        switch shape.kind {
        case .day:
            return "sun.max"
        case .week:
            return "calendar"
        case .life:
            return "map"
        }
    }
}
