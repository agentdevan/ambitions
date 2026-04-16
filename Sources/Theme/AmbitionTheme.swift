#if canImport(SwiftUI)
import SwiftUI

/// Shared theme surface for Ambitions SwiftUI UI.
///
/// Inject a theme at the app shell with `.ambitionTheme(theme)` and read it
/// inside reusable primitives with `@Environment(\.ambitionTheme)`.
public struct AmbitionTheme: Sendable {
    public struct Colors: Sendable {
        public let canvas: Color
        public let canvasElevated: Color
        public let canvasSubtle: Color
        public let surfacePrimary: Color
        public let surfaceSecondary: Color
        public let surfaceOverlay: Color
        public let textPrimary: Color
        public let textSecondary: Color
        public let textTertiary: Color
        public let textInverse: Color
        public let strokeSubtle: Color
        public let strokeStrong: Color
        public let accentPrimary: Color
        public let accentSecondary: Color
        public let accentWarm: Color
        public let success: Color
        public let warning: Color
        public let celebration: Color
        public let disabled: Color
        public let skeletonBase: Color
        public let skeletonHighlight: Color
    }

    public struct Surfaces: Sendable {
        public let cardGradient: LinearGradient
        public let heroGradient: LinearGradient
        public let widgetGradient: LinearGradient
        public let successGradient: LinearGradient
        public let warningGradient: LinearGradient
        public let celebrationGradient: LinearGradient
        public let topStrokeOpacity: Double
        public let bottomStrokeOpacity: Double
        public let backgroundBlurOpacity: Double
    }

    public struct Typography: Sendable {
        public init() {}

        public var hero: Font { .system(.largeTitle, design: .rounded).weight(.bold) }
        public var title: Font { .system(.title2, design: .rounded).weight(.bold) }
        public var titleCompact: Font { .system(.title3, design: .rounded).weight(.semibold) }
        public var section: Font { .system(.headline, design: .rounded).weight(.semibold) }
        public var body: Font { .system(.body, design: .default) }
        public var bodyEmphasized: Font { .system(.body, design: .rounded).weight(.semibold) }
        public var caption: Font { .system(.caption, design: .rounded).weight(.medium) }
        public var micro: Font { .system(.caption2, design: .rounded).weight(.semibold) }
        public var numeric: Font { .system(.title3, design: .rounded).weight(.bold).monospacedDigit() }
    }

    public struct Spacing: Sendable {
        public init() {}

        public let xxxs: CGFloat = 4
        public let xxs: CGFloat = 8
        public let xs: CGFloat = 12
        public let sm: CGFloat = 16
        public let md: CGFloat = 20
        public let lg: CGFloat = 24
        public let xl: CGFloat = 32
        public let xxl: CGFloat = 40
        public let xxxl: CGFloat = 56
    }

    public struct Radius: Sendable {
        public init() {}

        public let sm: CGFloat = 12
        public let md: CGFloat = 18
        public let lg: CGFloat = 24
        public let xl: CGFloat = 30
        public let pill: CGFloat = 999
    }

    public struct Shadow: Sendable {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
    }

    public struct Elevation: Sendable {
        public let resting: Shadow
        public let raised: Shadow
        public let hero: Shadow
        public let pressedScale: CGFloat
        public let selectedScale: CGFloat
    }

    public struct Glow: Sendable {
        public let tint: Color
        public let radius: CGFloat
        public let opacity: Double
        public let ringOpacity: Double
    }

    public struct IconTreatment: Sendable {
        public let smallSize: CGFloat
        public let mediumSize: CGFloat
        public let largeSize: CGFloat
        public let symbolWeight: Font.Weight
        public let containerPadding: CGFloat
    }

    public struct Motion: Sendable {
        public let quick: Double
        public let regular: Double
        public let emphasis: Double

        public func animation(reduceMotion: Bool, emphasis: Bool = false) -> Animation? {
            guard reduceMotion == false else { return nil }
            return .spring(
                response: emphasis ? self.emphasis : regular,
                dampingFraction: 0.86,
                blendDuration: quick
            )
        }
    }

    public let colors: Colors
    public let surfaces: Surfaces
    public let typography: Typography
    public let spacing: Spacing
    public let radius: Radius
    public let elevation: Elevation
    public let glow: Glow
    public let icon: IconTreatment
    public let motion: Motion

    public init(
        colors: Colors,
        surfaces: Surfaces,
        typography: Typography = Typography(),
        spacing: Spacing = Spacing(),
        radius: Radius = Radius(),
        elevation: Elevation,
        glow: Glow,
        icon: IconTreatment,
        motion: Motion
    ) {
        self.colors = colors
        self.surfaces = surfaces
        self.typography = typography
        self.spacing = spacing
        self.radius = radius
        self.elevation = elevation
        self.glow = glow
        self.icon = icon
        self.motion = motion
    }
}

public extension AmbitionTheme {
    static let dark = AmbitionTheme(
        colors: .init(
            canvas: Color(red: 0.06, green: 0.07, blue: 0.09),
            canvasElevated: Color(red: 0.10, green: 0.11, blue: 0.14),
            canvasSubtle: Color(red: 0.13, green: 0.14, blue: 0.17),
            surfacePrimary: Color(red: 0.14, green: 0.15, blue: 0.19),
            surfaceSecondary: Color(red: 0.17, green: 0.18, blue: 0.22),
            surfaceOverlay: Color.white.opacity(0.08),
            textPrimary: Color(red: 0.95, green: 0.94, blue: 0.92),
            textSecondary: Color(red: 0.76, green: 0.76, blue: 0.73),
            textTertiary: Color(red: 0.58, green: 0.58, blue: 0.56),
            textInverse: Color(red: 0.10, green: 0.11, blue: 0.14),
            strokeSubtle: Color.white.opacity(0.08),
            strokeStrong: Color.white.opacity(0.16),
            accentPrimary: Color(red: 0.47, green: 0.67, blue: 0.60),
            accentSecondary: Color(red: 0.46, green: 0.60, blue: 0.86),
            accentWarm: Color(red: 0.93, green: 0.66, blue: 0.40),
            success: Color(red: 0.49, green: 0.79, blue: 0.60),
            warning: Color(red: 0.96, green: 0.71, blue: 0.41),
            celebration: Color(red: 1.00, green: 0.61, blue: 0.63),
            disabled: Color.white.opacity(0.18),
            skeletonBase: Color.white.opacity(0.06),
            skeletonHighlight: Color.white.opacity(0.16)
        ),
        surfaces: .init(
            cardGradient: LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.17, blue: 0.22),
                    Color(red: 0.12, green: 0.13, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            heroGradient: LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.32, blue: 0.28),
                    Color(red: 0.16, green: 0.18, blue: 0.25),
                    Color(red: 0.12, green: 0.11, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            widgetGradient: LinearGradient(
                colors: [
                    Color(red: 0.21, green: 0.22, blue: 0.28),
                    Color(red: 0.15, green: 0.16, blue: 0.20)
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            successGradient: LinearGradient(
                colors: [Color(red: 0.21, green: 0.33, blue: 0.27), Color(red: 0.15, green: 0.23, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            warningGradient: LinearGradient(
                colors: [Color(red: 0.34, green: 0.24, blue: 0.14), Color(red: 0.24, green: 0.17, blue: 0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            celebrationGradient: LinearGradient(
                colors: [Color(red: 0.42, green: 0.22, blue: 0.29), Color(red: 0.23, green: 0.14, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            topStrokeOpacity: 0.30,
            bottomStrokeOpacity: 0.10,
            backgroundBlurOpacity: 0.84
        ),
        elevation: .init(
            resting: .init(color: Color.black.opacity(0.24), radius: 14, x: 0, y: 8),
            raised: .init(color: Color.black.opacity(0.32), radius: 22, x: 0, y: 14),
            hero: .init(color: Color.black.opacity(0.38), radius: 28, x: 0, y: 18),
            pressedScale: 0.985,
            selectedScale: 1.01
        ),
        glow: .init(
            tint: Color(red: 0.93, green: 0.66, blue: 0.40),
            radius: 18,
            opacity: 0.20,
            ringOpacity: 0.45
        ),
        icon: .init(
            smallSize: 15,
            mediumSize: 18,
            largeSize: 24,
            symbolWeight: .semibold,
            containerPadding: 10
        ),
        motion: .init(
            quick: 0.18,
            regular: 0.34,
            emphasis: 0.48
        )
    )

    static let light = AmbitionTheme(
        colors: .init(
            canvas: Color(red: 0.96, green: 0.95, blue: 0.93),
            canvasElevated: Color.white,
            canvasSubtle: Color(red: 0.91, green: 0.90, blue: 0.88),
            surfacePrimary: Color.white,
            surfaceSecondary: Color(red: 0.95, green: 0.94, blue: 0.92),
            surfaceOverlay: Color.black.opacity(0.03),
            textPrimary: Color(red: 0.10, green: 0.11, blue: 0.14),
            textSecondary: Color(red: 0.31, green: 0.33, blue: 0.37),
            textTertiary: Color(red: 0.48, green: 0.49, blue: 0.52),
            textInverse: Color.white,
            strokeSubtle: Color.black.opacity(0.08),
            strokeStrong: Color.black.opacity(0.14),
            accentPrimary: Color(red: 0.28, green: 0.47, blue: 0.40),
            accentSecondary: Color(red: 0.29, green: 0.45, blue: 0.74),
            accentWarm: Color(red: 0.78, green: 0.52, blue: 0.27),
            success: Color(red: 0.29, green: 0.57, blue: 0.39),
            warning: Color(red: 0.78, green: 0.50, blue: 0.20),
            celebration: Color(red: 0.82, green: 0.38, blue: 0.50),
            disabled: Color.black.opacity(0.12),
            skeletonBase: Color.black.opacity(0.05),
            skeletonHighlight: Color.black.opacity(0.12)
        ),
        surfaces: .init(
            cardGradient: LinearGradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 0.93)], startPoint: .topLeading, endPoint: .bottomTrailing),
            heroGradient: LinearGradient(colors: [Color(red: 0.90, green: 0.95, blue: 0.90), Color(red: 0.94, green: 0.92, blue: 0.98)], startPoint: .topLeading, endPoint: .bottomTrailing),
            widgetGradient: LinearGradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97)], startPoint: .top, endPoint: .bottom),
            successGradient: LinearGradient(colors: [Color(red: 0.86, green: 0.95, blue: 0.88), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing),
            warningGradient: LinearGradient(colors: [Color(red: 0.98, green: 0.92, blue: 0.84), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing),
            celebrationGradient: LinearGradient(colors: [Color(red: 0.98, green: 0.90, blue: 0.93), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing),
            topStrokeOpacity: 0.16,
            bottomStrokeOpacity: 0.08,
            backgroundBlurOpacity: 0.96
        ),
        elevation: .init(
            resting: .init(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5),
            raised: .init(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10),
            hero: .init(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 14),
            pressedScale: 0.99,
            selectedScale: 1.005
        ),
        glow: .init(
            tint: Color(red: 0.78, green: 0.52, blue: 0.27),
            radius: 16,
            opacity: 0.16,
            ringOpacity: 0.30
        ),
        icon: .init(
            smallSize: 15,
            mediumSize: 18,
            largeSize: 24,
            symbolWeight: .semibold,
            containerPadding: 10
        ),
        motion: .init(
            quick: 0.18,
            regular: 0.34,
            emphasis: 0.48
        )
    )
}

public enum AmbitionVisualState: String, CaseIterable, Sendable {
    case `default`
    case pressed
    case selected
    case disabled
    case loading
    case success
    case warning
    case celebration
}

public struct AmbitionStateStyle: Sendable {
    public let fill: Color
    public let stroke: Color
    public let foreground: Color
    public let accent: Color
    public let glow: Color
    public let opacity: Double
    public let scale: CGFloat
}

public extension AmbitionTheme {
    func stateStyle(for state: AmbitionVisualState, accent: Color? = nil) -> AmbitionStateStyle {
        let accentColor = accent ?? colors.accentPrimary

        switch state {
        case .default:
            return .init(fill: colors.surfaceOverlay, stroke: colors.strokeSubtle, foreground: colors.textPrimary, accent: accentColor, glow: accentColor, opacity: 1, scale: 1)
        case .pressed:
            return .init(fill: colors.surfaceOverlay.opacity(1.3), stroke: accentColor.opacity(0.34), foreground: colors.textPrimary, accent: accentColor, glow: accentColor, opacity: 1, scale: elevation.pressedScale)
        case .selected:
            return .init(fill: accentColor.opacity(0.18), stroke: accentColor.opacity(0.42), foreground: colors.textPrimary, accent: accentColor, glow: accentColor, opacity: 1, scale: elevation.selectedScale)
        case .disabled:
            return .init(fill: colors.disabled, stroke: colors.strokeSubtle, foreground: colors.textTertiary, accent: colors.textTertiary, glow: colors.disabled, opacity: 0.55, scale: 1)
        case .loading:
            return .init(fill: colors.skeletonBase, stroke: colors.skeletonHighlight, foreground: colors.textSecondary, accent: colors.skeletonHighlight, glow: colors.skeletonHighlight, opacity: 1, scale: 1)
        case .success:
            return .init(fill: colors.success.opacity(0.18), stroke: colors.success.opacity(0.42), foreground: colors.textPrimary, accent: colors.success, glow: colors.success, opacity: 1, scale: 1)
        case .warning:
            return .init(fill: colors.warning.opacity(0.18), stroke: colors.warning.opacity(0.42), foreground: colors.textPrimary, accent: colors.warning, glow: colors.warning, opacity: 1, scale: 1)
        case .celebration:
            return .init(fill: colors.celebration.opacity(0.20), stroke: colors.celebration.opacity(0.44), foreground: colors.textPrimary, accent: colors.celebration, glow: colors.celebration, opacity: 1, scale: elevation.selectedScale)
        }
    }
}

private struct AmbitionThemeKey: EnvironmentKey {
    static let defaultValue: AmbitionTheme = .light
}

public extension EnvironmentValues {
    var ambitionTheme: AmbitionTheme {
        get { self[AmbitionThemeKey.self] }
        set { self[AmbitionThemeKey.self] = newValue }
    }
}

/// Applies the Ambitions theme to a subtree.
public struct AmbitionThemeModifier: ViewModifier {
    private let theme: AmbitionTheme

    public init(theme: AmbitionTheme) {
        self.theme = theme
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.ambitionTheme, theme)
            .tint(theme.colors.accentPrimary)
            .foregroundStyle(theme.colors.textPrimary)
            .background(theme.colors.canvas.ignoresSafeArea())
    }
}

public extension View {
    /// Injects a shared Ambitions theme into the current view subtree.
    func ambitionTheme(_ theme: AmbitionTheme) -> some View {
        modifier(AmbitionThemeModifier(theme: theme))
    }
}
#endif
