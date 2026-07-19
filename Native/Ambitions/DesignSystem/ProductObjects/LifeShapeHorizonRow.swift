import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeHorizonRowView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    let mark: LifeShapeSemanticMark
    let selected: Bool
    let action: () -> Void

    var body: some View {
        let style = theme.stateStyle(for: selected ? .selected : mark.visualState)
        Button(action: action) {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: mark.kind.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(mark.kind.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text(mark.accessibilitySummary)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                if reduceMotion {
                    Text(mark.valueLabel)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(style.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                } else {
                    Capsule()
                        .fill(style.accent.opacity(contrast == .increased ? 0.78 : 0.42))
                        .frame(width: max(28, CGFloat(76 * mark.intensity)), height: contrast == .increased ? 10 : 8)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.vertical, theme.spacing.xs)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(style.stroke.opacity(contrast == .increased ? 0.82 : 0.42))
                    .frame(height: contrast == .increased ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("time.life-shape-field.horizon-row.\(mark.id)")
        .accessibilityLabel(mark.kind.title)
        .accessibilityValue(mark.accessibilitySummary)
    }
}
