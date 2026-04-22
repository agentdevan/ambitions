#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionButtonTier: Sendable {
    case hero
    case secondary
    case tertiary
}

public struct AmbitionButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let tier: AmbitionButtonTier
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        tier: AmbitionButtonTier,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) {
        self.tier = tier
        self.state = state
        self.accent = accent
    }

    public func makeBody(configuration: Configuration) -> some View {
        let effectiveState: AmbitionVisualState = configuration.isPressed ? .pressed : state
        let resolved = theme.stateStyle(for: effectiveState, accent: accent)

        return configuration.label
            .font(font)
            .foregroundStyle(foregroundColor(for: resolved))
            .frame(minHeight: minHeight)
            .frame(maxWidth: tier == .tertiary ? nil : .infinity)
            .padding(.horizontal, horizontalPadding)
            .background(backgroundShape.fill(fill(for: resolved)))
            .overlay(backgroundShape.stroke(stroke(for: resolved), lineWidth: tier == .tertiary ? 0 : 1))
            .scaleEffect(configuration.isPressed && reduceMotion == false ? theme.depth.pressedScale : resolved.scale)
            .opacity(resolved.opacity)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }

    private var font: Font {
        switch tier {
        case .hero: theme.typography.bodyEmphasized
        case .secondary: theme.typography.bodyEmphasized
        case .tertiary: theme.typography.caption
        }
    }

    private var minHeight: CGFloat {
        switch tier {
        case .hero: 48
        case .secondary: 44
        case .tertiary: 32
        }
    }

    private var horizontalPadding: CGFloat {
        switch tier {
        case .hero: theme.spacing.md
        case .secondary: theme.spacing.sm
        case .tertiary: theme.spacing.xs
        }
    }

    private var backgroundShape: some InsettableShape {
        Capsule(style: .continuous)
    }

    private func fill(for resolved: AmbitionStateStyle) -> Color {
        switch tier {
        case .hero:
            return resolved.accent
        case .secondary:
            return resolved.fill
        case .tertiary:
            return .clear
        }
    }

    private func stroke(for resolved: AmbitionStateStyle) -> Color {
        switch tier {
        case .hero:
            return resolved.accent.opacity(0.9)
        case .secondary:
            return resolved.stroke
        case .tertiary:
            return .clear
        }
    }

    private func foregroundColor(for resolved: AmbitionStateStyle) -> Color {
        switch tier {
        case .hero:
            return theme.colors.textInverse
        case .secondary:
            return resolved.foreground
        case .tertiary:
            return resolved.accent
        }
    }
}

public struct StatusChip: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let icon: String?
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        _ title: String,
        icon: String? = nil,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) {
        self.title = title
        self.icon = icon
        self.state = state
        self.accent = accent
    }

    public var body: some View {
        let style = theme.stateStyle(for: state, accent: accent)

        HStack(spacing: theme.spacing.xxxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            }

            Text(title)
                .font(theme.typography.micro)
                .lineLimit(1)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(RoundedRectangle(cornerRadius: theme.radius.chip, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.chip, style: .continuous).stroke(style.stroke, lineWidth: 1))
    }
}

public struct AmbitionBand<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let accent: Color?
    private let content: Content

    public init(accent: Color? = nil, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            content
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.band, style: .continuous)
                .fill(theme.surfaces.bandGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.band, style: .continuous)
                .stroke((accent ?? theme.colors.strokeSubtle).opacity(0.45), lineWidth: 1)
        )
    }
}

public struct AmbitionRowShell<Leading: View, Trailing: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let leading: Leading
    private let trailing: Trailing
    private let title: String
    private let subtitle: String?

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
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

            Spacer(minLength: theme.spacing.sm)
            trailing
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.surfaces.overlayGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

public struct SectionContainer<Header: View, Content: View>: View {
    private let header: Header
    private let content: Content
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.header = header()
        self.content = content()
    }

    public var body: some View {
        AppCard(state: state, accent: accent) {
            VStack(alignment: .leading, spacing: 16) {
                header
                content
            }
        }
    }
}
#endif
