#if canImport(SwiftUI)
import SwiftUI

public struct GroupedDestructiveActionRow: View {
    let title: String
    let subtitle: String?
    let systemImage: String?
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = "exclamationmark.triangle.fill",
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            GroupedNavigationRowBody(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                titleColorRole: .destructive,
                iconColorRole: .destructive,
                trailingValue: "Confirm",
                badge: nil,
                showsChevron: false
            )
        }
        .buttonStyle(GroupedNavigationButtonStyle(role: .destructive))
        .focusable()
        .groupedNavigationAccessibility(
            label: accessibilityLabel ?? title,
            value: "Requires confirmation.",
            hint: accessibilityHint ?? "The next step must confirm this action."
        )
    }
}

enum GroupedNavigationColorRole {
    case primary
    case secondary
    case destructive
    case accent
}

struct GroupedNavigationRowBody<Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String?
    let systemImage: String?
    let titleColorRole: GroupedNavigationColorRole
    let iconColorRole: GroupedNavigationColorRole
    let trailingValue: String?
    let badge: GroupedNavigationBadge?
    let showsChevron: Bool
    let trailing: Trailing

    init(
        title: String,
        subtitle: String?,
        systemImage: String?,
        titleColorRole: GroupedNavigationColorRole = .primary,
        iconColorRole: GroupedNavigationColorRole = .accent,
        trailingValue: String?,
        badge: GroupedNavigationBadge?,
        showsChevron: Bool,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.titleColorRole = titleColorRole
        self.iconColorRole = iconColorRole
        self.trailingValue = trailingValue
        self.badge = badge
        self.showsChevron = showsChevron
        self.trailing = trailing()
    }

    var body: some View {
        content
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.xs)
        .frame(maxWidth: .infinity, minHeight: max(theme.panel.minimumTapTarget, 56), alignment: .leading)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    var content: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    iconView
                    textColumn
                    Spacer(minLength: theme.spacing.xs)
                    if showsChevron {
                        chevronView
                    }
                }

                if hasTrailingContent {
                    HStack {
                        Spacer()
                        trailingContent(showsChevron: false)
                    }
                    .padding(.leading, systemImage == nil ? 0 : 42)
                }
            }
        } else {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                iconView
                textColumn
                    .layoutPriority(3)
                Spacer(minLength: theme.spacing.xs)
                trailingContent(showsChevron: showsChevron)
                    .frame(maxWidth: 132, alignment: .trailing)
                    .layoutPriority(1)
            }
        }
    }

    @ViewBuilder
    var iconView: some View {
        if let systemImage {
            Image(systemName: systemImage)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(color(for: iconColorRole))
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
        }
    }

    var textColumn: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(color(for: titleColorRole))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .truncationMode(.tail)
                .allowsTightening(true)

            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .truncationMode(.tail)
                    .allowsTightening(true)
            }
        }
    }

    @ViewBuilder
    func trailingContent(showsChevron: Bool) -> some View {
        HStack(spacing: theme.spacing.xs) {
            trailing

            if let trailingValue {
                Text(trailingValue)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .multilineTextAlignment(.trailing)
                    .truncationMode(.tail)
            }

            if let badge {
                GroupedNavigationBadgeView(badge)
            }

            if showsChevron {
                chevronView
            }
        }
    }

    var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(theme.colors.textTertiary)
            .frame(width: 10)
            .accessibilityHidden(true)
    }

    var hasTrailingContent: Bool {
        trailingValue != nil || badge != nil
    }

    func color(for role: GroupedNavigationColorRole) -> Color {
        switch role {
        case .primary: theme.colors.textPrimary
        case .secondary: theme.colors.textSecondary
        case .destructive: theme.semanticColors.risk
        case .accent: theme.colors.accentPrimary
        }
    }
}

struct GroupedNavigationBadgeView: View {
    @Environment(\.ambitionTheme) private var theme

    let badge: GroupedNavigationBadge

    init(_ badge: GroupedNavigationBadge) {
        self.badge = badge
    }

    var body: some View {
        let style = theme.semanticStyle(for: badge.state)

        HStack(spacing: theme.spacing.xxxs) {
            Image(systemName: badge.icon ?? badge.state.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .accessibilityHidden(true)

            Text(badge.title)
                .font(theme.typography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .truncationMode(.tail)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .frame(maxWidth: 104, alignment: .trailing)
        .background(RoundedRectangle(cornerRadius: theme.radius.chip, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.chip, style: .continuous).stroke(style.stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(badge.title), \(badge.state.accessibilityText)")
    }
}

struct GroupedNavigationButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Role {
        case standard
        case destructive
    }

    let role: Role

    init(role: Role = .standard) {
        self.role = role
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Rectangle()
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .scaleEffect(configuration.isPressed && reduceMotion == false ? theme.depth.pressedScale : 1)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }

    func backgroundColor(isPressed: Bool) -> Color {
        switch role {
        case .standard:
            isPressed ? theme.colors.surfacePrimary.opacity(0.32) : Color.clear
        case .destructive:
            theme.semanticColors.risk.opacity(isPressed ? 0.18 : (theme.mode == .dark ? 0.10 : 0.07))
        }
    }
}

extension View {
    func groupedNavigationAccessibility(
        label: String,
        value: String?,
        hint: String?
    ) -> some View {
        accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
            .accessibilityHint(hint ?? "")
    }

    @ViewBuilder
    func groupedNavigationIdentifier(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
#endif
