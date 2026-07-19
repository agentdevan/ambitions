import AmbitionsDesignSystem
import SwiftUI

struct YouPersonalRuntimeGovernanceField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let items: [GroupedNavigationSystemItem]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Priority settings")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Trust, personal context, and receipts stay inspectable before deeper controls.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                ForEach(items) { item in
                    governanceNode(item)
                }
            }
            .padding(.vertical, theme.spacing.sm)
            .background(alignment: .leading) {
                Rectangle()
                    .fill(LivingTabContext.you.accent(in: theme).opacity(0.34))
                    .frame(width: 2)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.64))
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Priority settings")
        .accessibilityIdentifier("you.priority-governance")
    }

    func governanceNode(_ item: GroupedNavigationSystemItem) -> some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        return Button {
            onSelect(item)
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(accent)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(item.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let statusLabel = item.statusLabel {
                            Spacer(minLength: theme.spacing.xs)

                            Text(statusLabel)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                    }

                    Text(compactDetail(for: item))
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.vertical, theme.spacing.xxxs)
            .padding(.leading, theme.spacing.sm)
            .padding(.trailing, theme.spacing.xs)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accent.opacity(0.72))
                    .frame(width: 2)
            }
        }
        .buttonStyle(.plain)
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary(for: item))
        .accessibilityIdentifier("you.priority-node.\(item.id)")
    }

    func accessibilitySummary(for item: GroupedNavigationSystemItem) -> String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    func compactDetail(for item: GroupedNavigationSystemItem) -> String {
        switch item.id {
        case "trust-automation":
            "Proposes first, asks before changing."
        case "personal-runtime":
            "Local context stays inspectable."
        case "receipts-history":
            "Every change keeps a receipt path."
        default:
            item.subtitle
        }
    }
}

struct YouPersonalRuntimeGovernanceControls: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [GroupedNavigationSystemItem]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Priority settings")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Trust, personal context, and receipts stay inspectable before deeper controls.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        YouPersonalRuntimeGovernanceRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.72))
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Priority settings")
        .accessibilityIdentifier("you.priority-governance")
    }
}

struct YouPersonalRuntimeGovernanceRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: GroupedNavigationSystemItem

    var body: some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(Circle().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.bodyEmphasized : theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            if let statusLabel = item.statusLabel {
                Text(statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 0.78)
                    .padding(.top, theme.spacing.xxxs)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .padding(.top, theme.spacing.xxxs)
                .accessibilityHidden(true)
        }
        .padding(.vertical, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(accent.opacity(0.16))
                .frame(width: 2)
        }
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("you.priority-row.\(item.id)")
    }

    var accessibilitySummary: String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}

struct YouPersonalSystemNavigation: View {
    @Environment(\.ambitionTheme) private var theme

    let sections: [GroupedNavigationSystemSection]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(section.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let subtitle = section.subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: theme.spacing.xxs) {
                        ForEach(section.items) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                YouPersonalSystemNavigationRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(section.title)
            }
        }
    }
}
