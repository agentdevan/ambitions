#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionCardStyle: Sendable {
    case app
    case widget
    case hero
}

public struct AmbitionSurfaceModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let style: AmbitionCardStyle
    private let state: AmbitionVisualState
    private let accent: Color?

    public init(style: AmbitionCardStyle, state: AmbitionVisualState = .default, accent: Color? = nil) {
        self.style = style
        self.state = state
        self.accent = accent
    }

    public func body(content: Content) -> some View {
        let resolved = theme.stateStyle(for: state, accent: accent)
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .padding(contentPadding)
            .background {
                shape.fill(background)
            }
            .overlay {
                shape
                    .strokeBorder(resolved.stroke.opacity(theme.surfaces.topStrokeOpacity), lineWidth: 1)
            }
            .overlay(alignment: .top) {
                shape
                    .strokeBorder(.white.opacity(theme.surfaces.bottomStrokeOpacity), lineWidth: 0.5)
                    .blur(radius: 0.4)
            }
            .shadow(color: shadow.color.opacity(state == .selected ? 1.05 : 1), radius: shadow.radius, x: shadow.x, y: shadow.y)
            .overlay {
                if state == .selected || state == .celebration {
                    shape
                        .stroke(resolved.glow.opacity(theme.glow.ringOpacity), lineWidth: 1.2)
                        .blur(radius: 0.4)
                }
            }
            .overlay {
                if state == .selected || state == .celebration {
                    shape
                        .fill(resolved.glow.opacity(theme.glow.opacity))
                        .blur(radius: theme.glow.radius)
                        .allowsHitTesting(false)
                }
            }
            .scaleEffect(resolved.scale)
            .opacity(resolved.opacity)
            .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: style == .hero), value: state)
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .app: theme.radius.lg
        case .widget: theme.radius.md
        case .hero: theme.radius.xl
        }
    }

    private var contentPadding: CGFloat {
        switch style {
        case .app: theme.spacing.lg
        case .widget: theme.spacing.sm
        case .hero: theme.spacing.xl
        }
    }

    private var shadow: AmbitionTheme.Shadow {
        switch style {
        case .app: theme.elevation.resting
        case .widget: theme.elevation.resting
        case .hero: theme.elevation.hero
        }
    }

    private var background: LinearGradient {
        switch style {
        case .app:
            theme.surfaces.cardGradient
        case .widget:
            theme.surfaces.widgetGradient
        case .hero:
            theme.surfaces.heroGradient
        }
    }
}

public extension View {
    /// Applies shared Ambitions card chrome to arbitrary content.
    func ambitionSurface(
        _ style: AmbitionCardStyle,
        state: AmbitionVisualState = .default,
        accent: Color? = nil
    ) -> some View {
        modifier(AmbitionSurfaceModifier(style: style, state: state, accent: accent))
    }
}

/// General-purpose content container for primary in-app modules.
public struct AppCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.app, state: state, accent: accent)
    }
}

/// Smaller container for glanceable modules or future widget-style sections.
public struct WidgetCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.widget, state: state, accent: accent)
    }
}

/// High-emphasis surface for top-level moments such as weekly summaries.
public struct HeroCard<Content: View>: View {
    private let state: AmbitionVisualState
    private let accent: Color?
    private let content: Content

    public init(
        state: AmbitionVisualState = .default,
        accent: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accent = accent
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .ambitionSurface(.hero, state: state, accent: accent)
    }
}
#endif
