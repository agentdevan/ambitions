#if canImport(SwiftUI)
import SwiftUI

/// Compact segmented selection bar for switching timeframes or modes.
public struct SegmentedFilterBar<Item: Hashable>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String

    public init(
        items: [Item],
        selection: Binding<Item>,
        title: @escaping (Item) -> String
    ) {
        self.items = items
        self._selection = selection
        self.title = title
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(items, id: \.self) { item in
                let state: AmbitionVisualState = item == selection ? .selected : .default

                Button {
                    selection = item
                } label: {
                    Text(title(item))
                        .font(theme.typography.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: state))
                .accessibilityAddTraits(item == selection ? [.isSelected] : [])
            }
        }
        .padding(theme.spacing.xxs)
        .background(Capsule(style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(Capsule(style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: selection)
    }
}

/// Chevron row shell for navigation lists and drill-in settings groups.
public struct ListChevronRow<Leading: View, Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let leading: Leading
    private let trailing: Trailing
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.md) {
                leading

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }

                Spacer()
                trailing
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(theme.spacing.md)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Reusable bottom navigation shell for future screen modules.
public struct BottomNavShell<Item: Hashable>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let items: [Item]
    @Binding private var selection: Item
    private let title: (Item) -> String
    private let icon: (Item) -> String

    public init(
        items: [Item],
        selection: Binding<Item>,
        title: @escaping (Item) -> String,
        icon: @escaping (Item) -> String
    ) {
        self.items = items
        self._selection = selection
        self.title = title
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(items, id: \.self) { item in
                let selected = item == selection

                Button {
                    selection = item
                } label: {
                    VStack(spacing: theme.spacing.xxxs) {
                        Image(systemName: icon(item))
                            .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                        Text(title(item))
                            .font(theme.typography.micro)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .padding(.vertical, theme.spacing.xs)
                    .foregroundStyle(selected ? theme.colors.textPrimary : theme.colors.textSecondary)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(selected ? theme.colors.accentPrimary.opacity(0.18) : .clear)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? [.isSelected] : [])
            }
        }
        .padding(theme.spacing.xs)
        .background {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .background {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.canvasElevated.opacity(theme.surfaces.backgroundBlurOpacity))
        }
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .shadow(color: theme.elevation.raised.color, radius: theme.elevation.raised.radius, x: 0, y: theme.elevation.raised.y)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: selection)
    }
}

public struct AmbitionPressableButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let state: AmbitionVisualState
    private let accent: Color?

    public init(state: AmbitionVisualState = .default, accent: Color? = nil) {
        self.state = state
        self.accent = accent
    }

    public func makeBody(configuration: Configuration) -> some View {
        let effectiveState: AmbitionVisualState = configuration.isPressed ? .pressed : state
        let resolved = theme.stateStyle(for: effectiveState, accent: accent)

        return configuration.label
            .foregroundStyle(resolved.foreground)
            .contentShape(Capsule(style: .continuous))
            .background(Capsule(style: .continuous).fill(resolved.fill))
            .overlay(Capsule(style: .continuous).stroke(resolved.stroke, lineWidth: 1))
            .shadow(
                color: configuration.isPressed
                    ? theme.elevation.resting.color.opacity(0.12)
                    : theme.elevation.resting.color.opacity(0.28),
                radius: configuration.isPressed ? 6 : 10,
                x: 0,
                y: configuration.isPressed ? 2 : 5
            )
            .offset(y: configuration.isPressed && reduceMotion == false ? 1 : 0)
            .scaleEffect(resolved.scale)
            .opacity(resolved.opacity)
            .animation(theme.motion.animation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}
#endif
