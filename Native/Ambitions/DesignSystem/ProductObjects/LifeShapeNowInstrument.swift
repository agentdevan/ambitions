import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeNowInstrument: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let caption: String
    let detail: String
    let primaryActionTitle: String
    let visualState: AmbitionVisualState
    let action: () -> Void

    private var textIndent: CGFloat {
        30 + theme.spacing.sm
    }

    var body: some View {
        let style = theme.stateStyle(for: visualState)
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: reduceMotion ? "clock" : "dot.radiowaves.left.and.right")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(caption)
                        .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.caption : theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                        .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.82 : 1.0)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, textIndent)

            Button(action: action) {
                Label(primaryActionTitle, systemImage: "arrow.forward.circle.fill")
                    .font(theme.typography.body.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(style.accent)
            .accessibilityIdentifier("time.life-shape-field.primary-action")
        }
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .padding(.leading, theme.spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Now instrument")
        .accessibilityValue([title, caption, detail].joined(separator: ". "))
        .accessibilityIdentifier("time.life-shape-field.now-instrument")
    }
}
