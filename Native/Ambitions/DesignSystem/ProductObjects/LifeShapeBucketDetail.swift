import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeBucketDetail: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let layer: LifeShapeLayer
    let mark: LifeShapeSemanticMark?
    let todayAnchor: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(layer == .open ? "Open detail" : "Protected detail")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentSecondary)

            Text(mark?.kind.title ?? layer.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(mark?.detail ?? "Time is waiting for more local shape.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)

            Text(todayAnchor)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)

            LifeShapeWhyThisInspection(
                layer: layer,
                mark: mark,
                todayAnchor: todayAnchor
            )
        }
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("time.life-shape-field.bucket-detail")
    }
}
