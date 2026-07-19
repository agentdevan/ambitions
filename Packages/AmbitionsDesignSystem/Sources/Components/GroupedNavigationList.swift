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

    let content: Content

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

    let title: String?
    let footer: String?
    let content: Content

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

    var sectionShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
    }
}

public struct GroupedNavigationRow: View {
    let title: String
    let subtitle: String?
    let systemImage: String?
    let trailingValue: String?
    let badge: GroupedNavigationBadge?
    let rowAccessibilityIdentifier: String?
    let accessibilityLabel: String?
    let accessibilityValue: String?
    let accessibilityHint: String?
    let action: () -> Void

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

    var accessibilityValueFallback: String? {
        [trailingValue, badge?.title].compactMap { $0 }.joined(separator: ", ").nilIfEmpty
    }
}

public struct GroupedDisclosureNavigationRow: View {
    let title: String
    let subtitle: String?
    let systemImage: String?
    let trailingValue: String?
    let badge: GroupedNavigationBadge?
    let rowAccessibilityIdentifier: String?
    let accessibilityLabel: String?
    let accessibilityValue: String?
    let accessibilityHint: String?
    let action: () -> Void

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

    var accessibilityValueFallback: String? {
        [trailingValue, badge?.title].compactMap { $0 }.joined(separator: ", ").nilIfEmpty
    }
}

public struct GroupedPreferenceRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let systemImage: String?
    let accessibilityLabel: String?
    let accessibilityHint: String?
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
    let title: String
    let subtitle: String?
    let systemImage: String?
    let value: String
    let state: AmbitionSemanticState
    let accessibilityLabel: String?
    let accessibilityValue: String?
    let accessibilityHint: String?
    let action: (() -> Void)?

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

    func rowBody(showsChevron: Bool) -> some View {
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
#endif
