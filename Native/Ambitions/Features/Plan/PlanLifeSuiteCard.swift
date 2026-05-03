import AmbitionsDesignSystem
import SwiftUI

struct PlanLifeSuiteCard: View {
    @Environment(\.ambitionTheme) private var theme

    let suite: PlanLifeSuiteState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: suite.title, subtitle: suite.subtitle)

                LifeShapeMap(suite: suite)

                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 220), spacing: theme.spacing.sm)
                    ],
                    alignment: .leading,
                    spacing: theme.spacing.sm
                ) {
                    ForEach(suite.shapes) { shape in
                        PlanLifeSuiteShapeTile(shape: shape)
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
        .accessibilityIdentifier("plan.life-suite")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct LifeShapeMap: View {
    @Environment(\.ambitionTheme) private var theme

    let suite: PlanLifeSuiteState

    var body: some View {
        StateDrivenMaterialPanel(context: .plan, state: .active) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text("LifeShapeMap")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer(minLength: theme.spacing.sm)
                    AmbitionChip(suite.calendarBoundaryLabel, role: .time, semanticState: .calendarDerived)
                }

                HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                    ForEach(suite.shapes) { shape in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                .fill(theme.stateStyle(for: shape.visualState).accent.opacity(0.74))
                                .frame(height: height(for: shape))
                            Text(shape.kind.rawValue.capitalized)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    }
                }
                .accessibilityHidden(true)

                EvidenceLabel(
                    "Shape before schedule",
                    detail: suite.subtitle,
                    source: suite.manualFallbackLabel,
                    state: .active,
                    context: .plan
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Life Shape Map")
        .accessibilityValue(suite.shapes.map { "\($0.title), \($0.summary)" }.joined(separator: ". "))
    }

    private func height(for shape: PlanLifeSuiteShapeState) -> CGFloat {
        switch shape.kind {
        case .day:
            54
        case .week:
            78
        case .life:
            42
        }
    }
}

private struct PlanLifeSuiteShapeTile: View {
    @Environment(\.ambitionTheme) private var theme

    let shape: PlanLifeSuiteShapeState

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
        .accessibilityIdentifier("plan.life-suite.\(shape.kind.rawValue)")
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
