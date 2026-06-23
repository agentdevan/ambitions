import AmbitionsDesignSystem
import SwiftUI

struct YouPersonalSystemNavigationRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: GroupedNavigationSystemItem

    var body: some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        content(accent: accent)
        .padding(.vertical, theme.spacing.sm)
        .padding(.horizontal, theme.spacing.xs)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("you.row.\(item.id)")
    }

    @ViewBuilder
    func content(accent: Color) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityContent(accent: accent)
        } else {
            compactContent(accent: accent)
        }
    }

    func compactContent(accent: Color) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            icon(accent: accent)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                titleText(lineLimit: nil)
                statusPill(accent: accent)
                subtitleText(lineLimit: nil)
            }
            .layoutPriority(1)

            Spacer(minLength: theme.spacing.sm)
            chevron
        }
    }

    func accessibilityContent(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                icon(accent: accent)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    titleText(lineLimit: 3)
                    statusPill(accent: accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(2)

                chevron
            }

            subtitleText(lineLimit: 4)
                .padding(.leading, 42)
        }
    }

    func icon(accent: Color) -> some View {
        Image(systemName: item.symbolName)
            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(accent)
            .frame(width: 34, height: 34)
            .background(Circle().fill(accent.opacity(0.12)))
            .accessibilityHidden(true)
    }

    func titleText(lineLimit: Int?) -> some View {
        Text(item.title)
            .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.section : theme.typography.bodyEmphasized)
            .foregroundStyle(theme.colors.textPrimary)
            .lineLimit(lineLimit)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func statusPill(accent: Color) -> some View {
        if let statusLabel = item.statusLabel {
            Text(statusLabel)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 0.78)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xxxs)
                .background(Capsule().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)
        }
    }

    func subtitleText(lineLimit: Int?) -> some View {
        Text(item.subtitle)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .lineLimit(lineLimit)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(theme.colors.textTertiary)
            .padding(.top, theme.spacing.xxs)
            .accessibilityHidden(true)
    }

    var accessibilitySummary: String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}
