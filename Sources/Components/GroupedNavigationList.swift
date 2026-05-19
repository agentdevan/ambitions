#if canImport(SwiftUI)
import SwiftUI

public enum GroupedNavigationRowKind: String, CaseIterable, Sendable, Identifiable {
    case navigation
    case disclosure
    case preference
    case status
    case destructive

    public var id: String { rawValue }

    public var accessibilityRole: String {
        switch self {
        case .navigation: "Navigation row"
        case .disclosure: "Disclosure navigation row"
        case .preference: "Preference row"
        case .status: "Status navigation row"
        case .destructive: "Destructive action row"
        }
    }
}

public struct GroupedNavigationBadge: Hashable, Sendable {
    public let title: String
    public let icon: String?
    public let state: AmbitionSemanticState

    public init(
        _ title: String,
        icon: String? = nil,
        state: AmbitionSemanticState = .neutral
    ) {
        self.title = title
        self.icon = icon
        self.state = state
    }
}

public struct GroupedNavigationList<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }
}

public struct GroupedNavigationSection<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String?
    private let footer: String?
    private let content: Content

    public init(
        title: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let title {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.xs)
                    .accessibilityAddTraits(.isHeader)
            }

            VStack(spacing: 0) {
                content
            }
            .background(sectionShape.fill(theme.colors.surfaceOverlay))
            .overlay(sectionShape.stroke(theme.colors.strokeSubtle, lineWidth: 1))

            if let footer {
                Text(footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, theme.spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var sectionShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
    }
}

public struct GroupedNavigationRow: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let trailingValue: String?
    private let badge: GroupedNavigationBadge?
    private let rowAccessibilityIdentifier: String?
    private let accessibilityLabel: String?
    private let accessibilityValue: String?
    private let accessibilityHint: String?
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        trailingValue: String? = nil,
        badge: GroupedNavigationBadge? = nil,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.trailingValue = trailingValue
        self.badge = badge
        self.rowAccessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            GroupedNavigationRowBody(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                trailingValue: trailingValue,
                badge: badge,
                showsChevron: false
            )
        }
        .buttonStyle(GroupedNavigationButtonStyle())
        .focusable()
        .groupedNavigationAccessibility(
            label: accessibilityLabel ?? title,
            value: accessibilityValue ?? accessibilityValueFallback,
            hint: accessibilityHint
        )
        .groupedNavigationIdentifier(rowAccessibilityIdentifier)
    }

    private var accessibilityValueFallback: String? {
        [trailingValue, badge?.title].compactMap { $0 }.joined(separator: ", ").nilIfEmpty
    }
}

public struct GroupedDisclosureNavigationRow: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let trailingValue: String?
    private let badge: GroupedNavigationBadge?
    private let rowAccessibilityIdentifier: String?
    private let accessibilityLabel: String?
    private let accessibilityValue: String?
    private let accessibilityHint: String?
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        trailingValue: String? = nil,
        badge: GroupedNavigationBadge? = nil,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.trailingValue = trailingValue
        self.badge = badge
        self.rowAccessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            GroupedNavigationRowBody(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                trailingValue: trailingValue,
                badge: badge,
                showsChevron: true
            )
        }
        .buttonStyle(GroupedNavigationButtonStyle())
        .focusable()
        .groupedNavigationAccessibility(
            label: accessibilityLabel ?? title,
            value: accessibilityValue ?? accessibilityValueFallback,
            hint: accessibilityHint ?? "Opens details."
        )
        .groupedNavigationIdentifier(rowAccessibilityIdentifier)
    }

    private var accessibilityValueFallback: String? {
        [trailingValue, badge?.title].compactMap { $0 }.joined(separator: ", ").nilIfEmpty
    }
}

public struct GroupedPreferenceRow: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let accessibilityLabel: String?
    private let accessibilityHint: String?
    @Binding private var isOn: Bool

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isOn: Binding<Bool>,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self._isOn = isOn
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            GroupedNavigationRowBody(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                trailingValue: nil,
                badge: nil,
                showsChevron: false,
                trailing: { EmptyView() }
            )
        }
        .toggleStyle(SwitchToggleStyle(tint: theme.colors.accentPrimary))
        .focusable()
        .padding(.trailing, theme.spacing.md)
        .contentShape(Rectangle())
        .frame(minHeight: max(theme.panel.minimumTapTarget, 56))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityHint(accessibilityHint ?? "")
    }
}

public struct GroupedStatusNavigationRow: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let value: String
    private let state: AmbitionSemanticState
    private let accessibilityLabel: String?
    private let accessibilityValue: String?
    private let accessibilityHint: String?
    private let action: (() -> Void)?

    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        value: String,
        state: AmbitionSemanticState = .neutral,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        accessibilityHint: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.value = value
        self.state = state
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        if let action {
            Button(action: action) {
                rowBody(showsChevron: true)
            }
            .buttonStyle(GroupedNavigationButtonStyle())
            .focusable()
            .groupedNavigationAccessibility(
                label: accessibilityLabel ?? title,
                value: accessibilityValue ?? "\(value), \(state.accessibilityText)",
                hint: accessibilityHint ?? "Opens details."
            )
        } else {
            rowBody(showsChevron: false)
                .groupedNavigationAccessibility(
                    label: accessibilityLabel ?? title,
                    value: accessibilityValue ?? "\(value), \(state.accessibilityText)",
                    hint: accessibilityHint
                )
        }
    }

    private func rowBody(showsChevron: Bool) -> some View {
        GroupedNavigationRowBody(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            trailingValue: nil,
            badge: GroupedNavigationBadge(value, state: state),
            showsChevron: showsChevron
        )
    }
}

public struct GroupedDestructiveActionRow: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let accessibilityLabel: String?
    private let accessibilityHint: String?
    private let action: () -> Void

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

private enum GroupedNavigationColorRole {
    case primary
    case secondary
    case destructive
    case accent
}

private struct GroupedNavigationRowBody<Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let titleColorRole: GroupedNavigationColorRole
    private let iconColorRole: GroupedNavigationColorRole
    private let trailingValue: String?
    private let badge: GroupedNavigationBadge?
    private let showsChevron: Bool
    private let trailing: Trailing

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
    private var content: some View {
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
    private var iconView: some View {
        if let systemImage {
            Image(systemName: systemImage)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(color(for: iconColorRole))
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
        }
    }

    private var textColumn: some View {
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
    private func trailingContent(showsChevron: Bool) -> some View {
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

    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(theme.colors.textTertiary)
            .frame(width: 10)
            .accessibilityHidden(true)
    }

    private var hasTrailingContent: Bool {
        trailingValue != nil || badge != nil
    }

    private func color(for role: GroupedNavigationColorRole) -> Color {
        switch role {
        case .primary: theme.colors.textPrimary
        case .secondary: theme.colors.textSecondary
        case .destructive: theme.semanticColors.risk
        case .accent: theme.colors.accentPrimary
        }
    }
}

private struct GroupedNavigationBadgeView: View {
    @Environment(\.ambitionTheme) private var theme

    private let badge: GroupedNavigationBadge

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

private struct GroupedNavigationButtonStyle: ButtonStyle {
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

    private func backgroundColor(isPressed: Bool) -> Color {
        switch role {
        case .standard:
            isPressed ? theme.colors.surfacePrimary.opacity(0.32) : Color.clear
        case .destructive:
            theme.semanticColors.risk.opacity(isPressed ? 0.18 : (theme.mode == .dark ? 0.10 : 0.07))
        }
    }
}

private extension View {
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

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
#endif
