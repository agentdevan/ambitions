#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionChromeButtonRole: String, CaseIterable, Sendable {
    case primary
    case secondary
    case trust
    case recovery
    case quiet
    case destructive

    var semanticState: AmbitionSemanticState {
        switch self {
        case .primary: .focus
        case .secondary: .neutral
        case .trust: .trust
        case .recovery: .recovery
        case .quiet: .neutral
        case .destructive: .risk
        }
    }
}

public enum AmbitionChromeButtonScale: String, CaseIterable, Sendable {
    case full
    case compact
    case toolbar

    var minHeight: CGFloat {
        switch self {
        case .full: 56
        case .compact: 46
        case .toolbar: 38
        }
    }
}

public struct AmbitionChromeButton: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let role: AmbitionChromeButtonRole
    private let scale: AmbitionChromeButtonScale
    private let fillsWidth: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        role: AmbitionChromeButtonRole = .primary,
        scale: AmbitionChromeButtonScale = .full,
        fillsWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.role = role
        self.scale = scale
        self.fillsWidth = fillsWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(ChromePressStyle(role: role, scale: scale, fillsWidth: fillsWidth))
        .disabled(isEnabled == false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle ?? role.rawValue)
    }

    private var label: some View {
        HStack(spacing: theme.spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: iconSize, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(scale == .toolbar ? theme.typography.caption : theme.typography.bodyEmphasized)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                if let subtitle, scale != .toolbar {
                    Text(subtitle)
                        .font(theme.typography.micro)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                        .opacity(0.78)
                }
            }

            if fillsWidth {
                Spacer(minLength: theme.spacing.xs)
            }
        }
        .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: .leading)
        .frame(minHeight: scale.minHeight)
    }

    private var iconSize: CGFloat {
        switch scale {
        case .full: 18
        case .compact: 16
        case .toolbar: 14
        }
    }
}

private struct ChromePressStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.isEnabled) private var isEnabled

    let role: AmbitionChromeButtonRole
    let scale: AmbitionChromeButtonScale
    let fillsWidth: Bool

    func makeBody(configuration: Configuration) -> some View {
        let semantic = theme.semanticStyle(for: role.semanticState)
        let isPressed = configuration.isPressed && reduceMotion == false
        let useLiquidGlass = ambitionShouldUseLiquidGlass(
            reduceTransparency: reduceTransparency,
            colorSchemeContrast: colorSchemeContrast
        )
        let shape = Capsule(style: .continuous)

        configuration.label
            .padding(.horizontal, horizontalPadding)
            .foregroundStyle(foreground(semantic: semantic))
            .background {
                if useLiquidGlass {
                    shape
                        .fill(Color.clear)
                        .glassEffect(theme.shell.glass.controlGlass, in: shape)
                } else {
                    ZStack {
                        shape.fill(baseGradient(semantic: semantic))
                        shape.fill(highlightGradient.opacity(isPressed ? 0.18 : 0.34))
                        shape.strokeBorder(theme.colors.textPrimary.opacity(isEnabled ? 0.10 : 0.04), lineWidth: 0.8)
                    }
                }
            }
            .overlay(alignment: .top) {
                shape
                    .stroke(LinearGradient(colors: [Color.white.opacity(0.42), Color.white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                    .blendMode(.screen)
            }
            .overlay(alignment: .bottom) {
                shape
                    .stroke(theme.colors.canvas.opacity(0.46), lineWidth: 1)
            }
            .shadow(color: glowColor(semantic: semantic).opacity(isEnabled ? (isPressed ? 0.16 : 0.28) : 0.0), radius: isPressed ? 8 : 18, x: 0, y: isPressed ? 4 : 12)
            .shadow(color: Color.black.opacity(isEnabled ? 0.22 : 0.04), radius: isPressed ? 8 : 16, x: 0, y: isPressed ? 3 : 9)
            .scaleEffect(isPressed ? 0.982 : 1.0)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }

    private var horizontalPadding: CGFloat {
        switch scale {
        case .full: theme.spacing.md
        case .compact: theme.spacing.sm
        case .toolbar: theme.spacing.xs
        }
    }

    private func foreground(semantic: AmbitionSemanticStyle) -> Color {
        switch role {
        case .primary, .trust, .recovery:
            theme.colors.textPrimary
        case .secondary, .quiet:
            semantic.foreground
        case .destructive:
            theme.semanticColors.risk
        }
    }

    private func glowColor(semantic: AmbitionSemanticStyle) -> Color {
        switch role {
        case .primary: theme.colors.accentSecondary
        case .trust: theme.semanticColors.trust
        case .recovery: theme.semanticColors.recovery
        case .destructive: theme.semanticColors.risk
        case .secondary, .quiet: semantic.stroke
        }
    }

    private func baseGradient(semantic: AmbitionSemanticStyle) -> LinearGradient {
        let accent = glowColor(semantic: semantic)
        let surface = theme.shell.controlBackground
        switch role {
        case .quiet:
            return LinearGradient(colors: [surface.opacity(0.46), surface.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .secondary:
            return LinearGradient(colors: [surface.opacity(0.72), semantic.fill.opacity(0.54), surface.opacity(0.44)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [accent.opacity(0.34), surface.opacity(0.86), accent.opacity(0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var highlightGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.54), Color.white.opacity(0.14), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
#endif
